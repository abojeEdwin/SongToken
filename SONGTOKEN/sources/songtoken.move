module songtoken::songtoken;

use sui::coin::Coin;
use sui::coin;
use sui::coin::TreasuryCap;
use sui::sui::SUI;
use sui::balance::Balance;
use sui::balance;


public struct SONGTOKEN has drop{}

public struct TokenVault has key {
	id: UID,
	treasury_cap: TreasuryCap<SONGTOKEN>,
	token_balance: Coin<SONGTOKEN>,
	remaining: u64,
	payment_vault: Balance<SUI>,
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

public fun create_artist_token(
	treasury: &mut TreasuryCap<SONGTOKEN>,
	percentage: u64,
	ctx: &mut TxContext
): TokenVault {
	let token_multiplier: u64 = 1000;
	let total_supply = percentage * token_multiplier;
	
	let minted_tokens = coin::mint(treasury, total_supply, ctx);
	
	let payment_vault = balance::zero<SUI>();
	
	TokenVault {
		id: object::new(ctx),
		treasury_cap: *treasury,
		token_balance: minted_tokens,
		remaining: total_supply,
		payment_vault,
		artist: ctx.sender(),
	}
}

public fun buy_songtoken(
	vault: &mut TokenVault,
	mut payment: Coin<SUI>,
	ctx: &mut TxContext
): Coin<SONGTOKEN> {
	let price_per_token: u64 = 1;
	
	let amount_paid = coin::value(&payment);
	let tokens_to_buy = amount_paid / price_per_token;
	
	assert!(tokens_to_buy > 0, 0);
	assert!(tokens_to_buy <= vault.remaining, 1);
	
	let (to_store, refund) = coin::split(payment, tokens_to_buy * price_per_token, ctx);
	vault.payment_vault = balance::join(vault.payment_vault, coin::into_balance(to_store));
	
	if (coin::value(&refund) > 0) {
		transfer::public_transfer(refund, ctx.sender());
	} else {
		coin::destroy_zero(refund);
	};
	
	let (buyer_tokens, new_vault_balance) = coin::split(vault.token_balance, tokens_to_buy, ctx);
	vault.token_balance = new_vault_balance;
	
	vault.remaining = vault.remaining - tokens_to_buy;
	
	buyer_tokens
}






//
// public fun buy_songtoken(
// 	vault: &mut TokenVault,
// 	mut payment: Coin<SUI>,
// 	ctx: &mut TxContext
// ): Coin<SONGTOKEN> {
// 	let price_per_token = 1 ;
//
// 	let amount_paid = coin::value(&payment);
// 	let tokens_to_mint = amount_paid * price_per_token;
//
// 	assert!(tokens_to_mint > 0, 0);
// 	assert!(tokens_to_mint <= vault.remaining, 1);
//
// 	let refund = coin::split(&mut payment, tokens_to_mint * price_per_token, ctx);
// 	//balance::join(&mut vault.payment_vault, coin::into_balance(refund));
//
// 	if (coin::value(&refund) > 0) {
// 		transfer::public_transfer(refund, ctx.sender());
// 	} else {
// 		coin::destroy_zero(refund);
// 	};
//
// 	let minted = coin::mint(&mut vault.treasury_cap, tokens_to_mint, ctx);
//
// 	vault.remaining = vault.remaining - tokens_to_mint;
//
// 	minted
// }
//
//
