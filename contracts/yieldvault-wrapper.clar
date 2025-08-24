;; title: yieldvault-wrapper
;; version: 1.0.0
;; summary: sBTC YieldVault - A wrapper contract for Hermetica's USDh stablecoin enabling sBTC as collateral
;; description: This contract wraps Hermetica's USDh stablecoin functionality, allowing users to mint USDh using sBTC as collateral and accrue yields up to 25% APY

;; traits
;; SIP-010 trait for USDh compatibility (will be added when integrating with actual contracts)
;; (use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
;;

;; constants
;; Error codes
(define-constant ERR_NOT_AUTHORIZED (err u1))
(define-constant ERR_INSUFFICIENT_BALANCE (err u2))
(define-constant ERR_INVALID_AMOUNT (err u3))
(define-constant ERR_CONTRACT_CALL_FAILED (err u4))

;; Contract addresses (placeholder addresses for MVP - will be updated with actual addresses)
(define-constant HERMETICA_USDH_CONTRACT 'SP000000000000000000002Q6VF78.hermetica-usdh)
(define-constant SBTC_CONTRACT 'SP000000000000000000002Q6VF78.sbtc-token)

;; Minimum collateral ratio (150% = 15000 basis points)
(define-constant MIN_COLLATERAL_RATIO u15000)

;; Yield parameters (targeting 25% APY)
;; Blocks per year on Stacks (approximately 52,560 blocks assuming 10 min block time)
(define-constant BLOCKS_PER_YEAR u52560)
;; Yield rate: 25% APY = 2500 basis points
(define-constant ANNUAL_YIELD_RATE u2500)

;; data vars
(define-data-var contract-owner principal tx-sender)

;; data maps
;; Track user positions: collateral amount, minted USDh, last yield update block
(define-map user-positions
  principal
  {
    sbtc-collateral: uint,
    usdh-minted: uint,
    last-yield-block: uint
  }
)

;; public functions
;; Mint USDh using sBTC as collateral
(define-public (mint-usdh (sbtc-amount uint) (usdh-amount uint))
  (let (
    (caller tx-sender)
    (current-position (get-user-position caller))
    (new-sbtc-total (+ (get sbtc-collateral current-position) sbtc-amount))
    (new-usdh-total (+ (get usdh-minted current-position) usdh-amount))
    (collateral-ratio (calculate-collateral-ratio new-sbtc-total new-usdh-total))
  )
    ;; Basic validation
    (asserts! (> sbtc-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> usdh-amount u0) ERR_INVALID_AMOUNT)

    ;; Check minimum collateral ratio (150%)
    (asserts! (>= collateral-ratio MIN_COLLATERAL_RATIO) ERR_INSUFFICIENT_BALANCE)

    ;; Update yield before changing position
    (update-user-yield caller)

    ;; TODO: Transfer sBTC from user to contract (placeholder for actual sBTC contract call)
    ;; (try! (contract-call? .sbtc-token transfer sbtc-amount caller (as-contract tx-sender) none))

    ;; TODO: Call Hermetica's mint function (placeholder for actual Hermetica contract call)
    ;; (try! (contract-call? .hermetica-usdh mint usdh-amount caller))

    ;; Update user position
    (map-set user-positions caller {
      sbtc-collateral: new-sbtc-total,
      usdh-minted: new-usdh-total,
      last-yield-block: stacks-block-height
    })

    ;; Emit event
    (print {
      action: "mint-usdh",
      user: caller,
      sbtc-amount: sbtc-amount,
      usdh-amount: usdh-amount,
      new-collateral-ratio: collateral-ratio,
      block-height: stacks-block-height
    })

    (ok true)
  )
)

;; Redeem USDh and get back sBTC collateral plus yield
(define-public (redeem-usdh (usdh-amount uint))
  (let (
    (caller tx-sender)
    (current-position (get-user-position caller))
    (current-usdh (get usdh-minted current-position))
    (current-sbtc (get sbtc-collateral current-position))
    (sbtc-to-return (/ (* current-sbtc usdh-amount) current-usdh))
    (new-usdh-total (- current-usdh usdh-amount))
    (new-sbtc-total (- current-sbtc sbtc-to-return))
  )
    ;; Basic validation
    (asserts! (> usdh-amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= usdh-amount current-usdh) ERR_INSUFFICIENT_BALANCE)

    ;; Update yield before changing position
    (update-user-yield caller)

    ;; TODO: Burn USDh tokens (placeholder for actual Hermetica contract call)
    ;; (try! (contract-call? .hermetica-usdh burn usdh-amount caller))

    ;; TODO: Transfer sBTC back to user (placeholder for actual sBTC contract call)
    ;; (try! (as-contract (contract-call? .sbtc-token transfer sbtc-to-return tx-sender caller none)))

    ;; Update user position
    (if (is-eq new-usdh-total u0)
      ;; If fully redeemed, remove position
      (map-delete user-positions caller)
      ;; Otherwise update position
      (map-set user-positions caller {
        sbtc-collateral: new-sbtc-total,
        usdh-minted: new-usdh-total,
        last-yield-block: stacks-block-height
      })
    )

    ;; Emit event
    (print {
      action: "redeem-usdh",
      user: caller,
      usdh-amount: usdh-amount,
      sbtc-returned: sbtc-to-return,
      block-height: stacks-block-height
    })

    (ok sbtc-to-return)
  )
)

;; Claim accrued yield without redeeming collateral
(define-public (claim-yield)
  (let (
    (caller tx-sender)
    (pending-yield (get-pending-yield caller))
  )
    ;; Check if there's yield to claim
    (asserts! (> pending-yield u0) ERR_INVALID_AMOUNT)

    ;; Update user yield (this will add yield to USDh balance)
    (update-user-yield caller)

    ;; TODO: Mint additional USDh tokens for the yield (placeholder for actual Hermetica contract call)
    ;; (try! (contract-call? .hermetica-usdh mint pending-yield caller))

    ;; Emit event
    (print {
      action: "claim-yield",
      user: caller,
      yield-claimed: pending-yield,
      block-height: stacks-block-height
    })

    (ok pending-yield)
  )
)

;; read only functions
;; Get user position
(define-read-only (get-user-position (user principal))
  (default-to
    {sbtc-collateral: u0, usdh-minted: u0, last-yield-block: u0}
    (map-get? user-positions user)
  )
)

;; Calculate collateral ratio for a user
(define-read-only (get-collateral-ratio (user principal))
  (let ((position (get-user-position user)))
    (if (is-eq (get usdh-minted position) u0)
      u0
      ;; Simplified calculation: (collateral * 10000) / minted
      ;; In production, this would use price oracles
      (calculate-collateral-ratio (get sbtc-collateral position) (get usdh-minted position))
    )
  )
)

;; Calculate pending yield for a user
(define-read-only (get-pending-yield (user principal))
  (let (
    (position (get-user-position user))
    (blocks-elapsed (- stacks-block-height (get last-yield-block position)))
    (usdh-balance (get usdh-minted position))
  )
    (if (is-eq usdh-balance u0)
      u0
      ;; Calculate yield: (balance * yield_rate * blocks_elapsed) / (10000 * blocks_per_year)
      (/ (* (* usdh-balance ANNUAL_YIELD_RATE) blocks-elapsed) (* u10000 BLOCKS_PER_YEAR))
    )
  )
)

;; Get user position with pending yield included
(define-read-only (get-user-position-with-yield (user principal))
  (let (
    (position (get-user-position user))
    (pending-yield (get-pending-yield user))
  )
    (merge position {pending-yield: pending-yield})
  )
)

;; private functions
;; Update user yield by adding accrued yield to their USDh balance
(define-private (update-user-yield (user principal))
  (let (
    (current-position (get-user-position user))
    (pending-yield (get-pending-yield user))
    (new-usdh-balance (+ (get usdh-minted current-position) pending-yield))
  )
    (if (> pending-yield u0)
      (begin
        ;; Update position with accrued yield
        (map-set user-positions user {
          sbtc-collateral: (get sbtc-collateral current-position),
          usdh-minted: new-usdh-balance,
          last-yield-block: stacks-block-height
        })
        ;; Emit yield event
        (print {
          action: "yield-accrued",
          user: user,
          yield-amount: pending-yield,
          new-usdh-balance: new-usdh-balance,
          block-height: stacks-block-height
        })
        true
      )
      true
    )
  )
)

;; Calculate collateral ratio given amounts
(define-private (calculate-collateral-ratio (sbtc-amount uint) (usdh-amount uint))
  (if (is-eq usdh-amount u0)
    u0
    ;; Assuming 1:1 price ratio for MVP (sbtc-amount * 10000) / usdh-amount
    ;; In production, this would use price oracles
    (/ (* sbtc-amount u10000) usdh-amount)
  )
)

