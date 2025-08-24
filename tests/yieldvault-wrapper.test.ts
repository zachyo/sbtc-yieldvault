
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

  it("can call mint-usdh function", () => {
    const { result } = simnet.callPublicFn("yieldvault-wrapper", "mint-usdh", [100n, 50n], address1);
    expect(result).toBeOk(true);
  });
});
