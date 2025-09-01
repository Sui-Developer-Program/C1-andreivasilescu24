/// Module: tip_jar_live
module tip_jar_live::tip_jar_live;

use sui::{event, coin::{Self, Coin}};
use sui::sui::SUI;

public struct TipSent has copy, drop {
    from: address,
    tip_jar: ID,
    jar_owner: address,
    amount: u64,
    token: ID,
    timestamp: u64
}

public struct TipJar has key {
    id: UID,
    balance: u64,
    total_tips: u64,
    owner: address
}

fun init(ctx: &mut TxContext) {
    let jar = TipJar {
        id: object::new(ctx),
        balance: 0,
        total_tips: 0,
        owner: ctx.sender()
    };

    sui::transfer::share_object(jar);
}

public fun tip(jar: &mut TipJar, amount: Coin<SUI>, ctx: &TxContext) {
    let value = coin::value(&amount);
    assert!(value > 0, 24); // Tip amount must be greater than zero

    let token_id = object::id(&amount);

    jar.balance = jar.balance + coin::value(&amount);
    jar.total_tips = jar.total_tips + 1;

    sui::transfer::public_transfer(amount, jar.owner);

    event::emit(TipSent{
        from: ctx.sender(),
        tip_jar: object::id(jar),
        jar_owner: jar.owner,
        amount: value,
        token: token_id,
        timestamp: ctx.epoch_timestamp_ms()
    })
}
