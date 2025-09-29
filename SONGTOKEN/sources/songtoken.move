
module songtoken::songtoken;

use sui::transfer;
use sui::object::{Self, UID};
use usdc::usdc::USDC;
use sui::coin::{Self, Coin, TreasuryCap};
use sui::balance::{Self, Balance};



public struct SONGTOKEN has drop {}

public struct TokenVault has key {
	id: UID,
	treasury_cap: TreasuryCap<SONGTOKEN>,
	token_balance: Coin<SONGTOKEN>,
	remaining: u64,
	payment_vault: Balance<USDC>,
	artist: address,
}

fun init(witness: SONGTOKEN, ctx: &mut TxContext) {
	let (treasury, metadata) = coin::create_currency(
		witness,
		8,
		b"SONG",
		b"SongToken",
		b"Base token for songs",
		option::none(),
		ctx
	);
	transfer::public_freeze_object(metadata);
	transfer::public_transfer(treasury, ctx.sender());
}
public fun mint_artist_token(
	mut treasury_cap: TreasuryCap<SONGTOKEN>,
	percentage: u64,
	ctx: &mut TxContext
) {
		let token_multiplier: u64 = 100000000;
		let total_supply = percentage * token_multiplier;
		
		let minted_tokens = coin::mint(&mut treasury_cap, total_supply, ctx);
		let payment_vault = balance::zero<USDC>();
	
		let vault = TokenVault {
			id: object::new(ctx),
			treasury_cap,
			token_balance: minted_tokens,
			remaining: total_supply,
			payment_vault,
			artist: ctx.sender(),
		};
	transfer::transfer(vault, ctx.sender());
	
}

public fun buy_songtoken_with_usdc(
    vault: &mut TokenVault,
    payment: Coin<USDC>,
    ctx: &mut TxContext
){
    let amount_paid = coin::value(&payment);
    
    // Simple 1:1 ratio for now - 1 USDC unit = 1 SONGTOKEN unit
    // Since USDC has 6 decimals and SONGTOKEN has 8 decimals,
    // we need to scale up USDC by 100 (10^2) to match
    let tokens_to_buy = amount_paid - 1000;
	
	assert!(tokens_to_buy > 0, 0);
    
    let available_tokens = coin::value(&vault.token_balance);
    
    // Add debug assertions to see what's happening
    assert!(available_tokens > 0, 2); // Vault must have tokens
    assert!(tokens_to_buy <= available_tokens, 1);
    
    balance::join(&mut vault.payment_vault, coin::into_balance(payment));
    
    let buyer_tokens = coin::split(&mut vault.token_balance, tokens_to_buy, ctx);
    
    vault.remaining = vault.remaining - tokens_to_buy;
    
    transfer::public_transfer(buyer_tokens,ctx.sender());
}
