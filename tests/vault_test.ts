import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new vault",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", 
        [types.ascii("My Vault")], 
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, "(ok u1)");
    
    // Verify vault data
    let vault = chain.callReadOnlyFn(
      "vault",
      "get-vault",
      [types.uint(1)],
      wallet_1.address
    );
    
    assertEquals(vault.result.expectSome().expectTuple(), {
      owner: wallet_1.address,
      name: "My Vault",
      size: "u0",
      files: "u0",
      score: "u100",
      last-update: block.height.toString()
    });
  },
});

Clarinet.test({
  name: "Cannot update vault if not owner",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    // Create vault
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", 
        [types.ascii("My Vault")], 
        wallet_1.address
      )
    ]);
    
    // Try to update with different wallet
    block = chain.mineBlock([
      Tx.contractCall("vault", "update-vault-stats",
        [types.uint(1), types.uint(100), types.uint(10)],
        wallet_2.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, "(err u403)");
  },
});
