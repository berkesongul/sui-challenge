module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;
use sui::tx_context::{Self, TxContext};
use sui::object::{Self, UID, ID};
use sui::transfer;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {

    // NOTE: The init function runs once when the module is published
    // TODO: Initialize the module by creating AdminCap
    let adminCap = AdminCap {
        id: object::new(ctx)
    };
    // TODO: Transfer it to the module publisher (ctx.sender()) using transfer::public_transfer() function
    transfer::public_transfer(adminCap, tx_context::sender(ctx));
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {

    // TODO: Create a list_hero object for marketplace
    let list_hero = ListHero {
        id: object::new(ctx),
        nft,
        price,
        seller: tx_context::sender(ctx)
    };
    
    // TODO: Emit HeroListed event with listing details (Don't forget to use object::id(&list_hero) )
    event::emit(HeroListed {
        list_hero_id: object::id(&list_hero),
        price,
        seller: tx_context::sender(ctx),
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });
    
    // Düzeltme: transfer::share_object() yerine önerilen transfer::public_share_object() kullanıldı.
    transfer::public_share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {

    let ListHero {id, nft, price, seller} = list_hero;
    
    // YENİ MANTIK: Coin'in değeri TAM olarak listelenen fiyata eşit olmalıdır. 
    // Eksik (too_low) veya fazla (too_high) ödeme durumunda EInvalidPayment hatası verilir.
    assert!(coin::value(&coin) == price, EInvalidPayment);
    
    // COIN TRANSFERİ: Coin'i satıcıya gönder.
    transfer::public_transfer(coin, seller);
    
    // NFT TRANSFERİ: Hero NFT'yi alıcıya gönder.
    transfer::public_transfer(nft, tx_context::sender(ctx));
    
    // EVENT: HeroBought olayını yay.
    event::emit(HeroBought {
        list_hero_id: object::uid_to_inner(&id), 
        price,
        buyer: tx_context::sender(ctx),
        seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });
    
    // DELETE: Listing ID'yi sil.
    object::delete(id);
}
    
    // 3. COIN TRANSFERİ: Kalan coin'i satıcıya gönder.
    transfer::public_transfer(coin, seller);
    
    // 4. NFT TRANSFERİ: Hero NFT'yi alıcıya gönder.
    transfer::public_transfer(nft, tx_context::sender(ctx));
    
    // 5. EVENT: HeroBought olayını yay.
    event::emit(HeroBought {
        list_hero_id: object::uid_to_inner(&id), 
        price,
        buyer: tx_context::sender(ctx),
        seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });
    
    // 6. DELETE: Listing ID'yi sil.
    // Düzeltme: Yinelenen object::delete(id) satırları temizlendi.
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {

    // NOTE: The AdminCap parameter ensures only admin can call this
    // TODO: Implement admin delist functionality
    
    // Düzeltme: Kullanılmayan price değişkeni (price: _) ile atlandı.
    let ListHero {id, nft, price: _, seller} = list_hero; 
    
    // TODO:Transfer NFT back to original seller
    transfer::public_transfer(nft, seller);
    
    // TODO:Delete the listing ID (object::delete(id))
    object::delete(id);
    
    // Düzeltme: Fazladan kapanış parantezi silindi.
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    
    // NOTE: The AdminCap parameter ensures only admin can call this
    // list_hero has &mut so price can be modified 
    // TODO: Update the listing price
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, tx_context::sender(ctx));
}