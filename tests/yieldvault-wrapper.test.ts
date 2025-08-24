
import { describe, expect, it } from "vitest";
import { simnet } from "@hirosystems/clarinet-sdk";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

/*
  The test below is an example. To learn more, read the testing documentation here:
  https://docs.hiro.so/stacks/clarinet-js-sdk
*/

describe("yieldvault-wrapper tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("can get initial user position", () => {
    const { result } = simnet.callReadOnlyFn("yieldvault-wrapper", "get-user-position", [address1], address1);
    expect(result).toBeOk({
      "sbtc-collateral": 0n,
      "usdh-minted": 0n,
      "last-yield-block": 0n
    });
  });

  it("can mint USDh with 100 test coins as collateral", () => {
    // Test minting 50 USDh with 100 sBTC (200% collateral ratio)
    const { result } = simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);
    expect(result).toBeOk(true);
  });

  it("can get user position after minting", () => {
    // First mint
    simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);

    // Check position
    const { result } = simnet.callReadOnlyFn("yieldvault-wrapper", "get-user-position", [address1], address1);
    expect(result).toBeOk({
      "sbtc-collateral": 100n,
      "usdh-minted": 50n,
      "last-yield-block": 2n // Block height after mint
    });
  });

  it("can calculate collateral ratio", () => {
    // First mint
    simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);

    // Check collateral ratio (should be 200% = 20000 basis points)
    const { result } = simnet.callReadOnlyFn("yieldvault-wrapper", "get-collateral-ratio", [address1], address1);
    expect(result).toBeUint(20000n);
  });

  it("can calculate pending yield after blocks", () => {
    // First mint
    simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);

    // Mine some blocks to accrue yield
    simnet.mineEmptyBlocks(100);

    // Check pending yield
    const { result } = simnet.callReadOnlyFn("yieldvault-wrapper", "get-pending-yield", [address1], address1);
    expect(result).toBeUint(expect.any(BigInt));
  });

  it("can claim accrued yield", () => {
    // First mint
    simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);

    // Mine blocks to accrue yield
    simnet.mineEmptyBlocks(1000);

    // Claim yield
    const { result } = simnet.callPublicFn("yieldvault-wrapper", "claim-yield", [], address1);
    expect(result).toBeOk(expect.any(BigInt));
  });

  it("can redeem USDh and get back sBTC", () => {
    // First mint
    simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);

    // Redeem half
    const { result } = simnet.callPublicFn("yieldvault-wrapper", "redeem-usdh", [25n], address1);
    expect(result).toBeOk(50n); // Should get back 50 sBTC for 25 USDh
  });

  it("rejects mint with insufficient collateral ratio", () => {
    // Try to mint with insufficient collateral (100% ratio)
    const { result } = simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 100n], address1);
    expect(result).toBeErr(2n); // ERR_INSUFFICIENT_BALANCE
  });
});
