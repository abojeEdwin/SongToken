module songtoken::songtoken;

use sui::url;
use sui::coin;
use sui::coin::TreasuryCap;
use sui::sui::SUI;
use sui::balance::Balance;
use sui::balance;


public struct SONGTOKEN has drop{}

public struct TokenVault has key {
	id: UID,
	treasury_cap: TreasuryCap<SONGTOKEN>,
	remaining: u64,
	payment_vault: Balance<SUI>,
	artist: address,
}

public entry fun init(ctx: &mut TxContext) {
	let witness = SONGTOKEN{};
	transfer::share_object(witness);
}

public fun create_artist_token<>(
	witness: SONGTOKEN,
	percentage: u64,
	symbol: vector<u8>,
	name: vector<u8>,
	description: vector<u8>,
	icon_url: vector<u8>,
	ctx: &mut TxContext
): TokenVault {
	let (treasury, metadata) = coin::create_currency(
		witness,
		8,
		symbol,
		name,
		description,
		option::some(url::new_unsafe_from_bytes(icon_url)),
		ctx
	);
	transfer::public_freeze_object(metadata);
	
	let token_multiplier: u64 = 1000;
	let total_supply = percentage * token_multiplier;
	let payment_vault = balance::zero<SUI>();
	
	TokenVault {
		id: object::new(ctx),
		treasury_cap: treasury,
		remaining: total_supply,
		artist: ctx.sender(),
		payment_vault,
	}
}
