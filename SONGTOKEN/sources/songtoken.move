module songtoken::songtoken;

use sui::url;
use sui::coin;
use sui::coin::TreasuryCap;


public struct SONGTOKEN<phantom ID> has drop{}

public struct TokenVault<phantom T> has key {
	id: UID,
	treasury_cap: TreasuryCap<T>,
	remaining: u64,
	payment_vault: coin::TreasuryCap<SUI>,
	dao_multisig: address,
}
public fun create_artist_token<ID>(
	witness: ArtistToken<ID>,
	percentage: u64,
	symbol: vector<u8>,
	name: vector<u8>,
	description: vector<u8>,
	icon_url: vector<u8>,
	ctx: &mut TxContext
): TokenVault<ArtistToken> {
	let (treasury, metadata) = coin::create_currency(
		witness,
		8, // decimals
		symbol,
		name,
		description,
		option::some(url::new_unsafe_from_bytes(icon_url)),
		ctx
	);
	transfer::public_freeze_object(metadata);
	
	let token_multiplier: u64 = 1000;
	let total_supply = percentage * token_multiplier;
	
	let payment_vault = coin::zero<SUI>(ctx);
	
	TokenVault {
		id: object::new(ctx),
		treasury_cap: treasury,
		remaining: total_supply,
		artist: ctx.sender(),
		payment_vault,
	}
}
