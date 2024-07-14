module bridge::bridge {

    // use std::string::{Self,String};
    use sui::clock::{Self, Clock};
    use sui::object::{Self, UID};
    use sui::transfer::{Self};
    use sui::tx_context::{Self,TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::event;
    use sui::pay;

    struct BRIDGE has drop {}

    struct BridgeCap has key, store{
        id: UID
    }

    struct BridgeEvent has copy, drop{
        changeAddr : address,
        amount : u64,
        orderId : u64
    }

    struct FinishOrderEvent has copy, drop{
        orderId: u64,
        amount: u64,
        receiveAddr: address,
        timeMs: u64
    }

    struct Pool has key {
        id :UID,
        coin_sui: Balance<SUI>,
        sequence: u64
    }

    fun init(_: BRIDGE, ctx: &mut TxContext){
        //admin cap
        let bc = BridgeCap{
            id: object::new(ctx)
        };
        let pool = Pool{
            id: object::new(ctx),
            coin_sui: balance::zero(),
            sequence: 0
        };
        transfer::share_object(pool);
        //admin cap to contract
        transfer::public_transfer(bc, tx_context::sender(ctx));
    }

    //ask admin to get pool.coin
    public entry fun transferCoin(_ : &mut BridgeCap, pool : &mut Pool,amount: u64, receiveAddr: address, orderId: u64, clock: &Clock, ctx: &mut TxContext){
        let coin = coin::take(&mut pool.coin_sui, amount, ctx);
        transfer::public_transfer(coin, receiveAddr);
        event::emit(FinishOrderEvent{
            orderId,
            amount,
            receiveAddr,
            timeMs: clock::timestamp_ms(clock),
        })
    }

    public entry fun deposit(inVec : vector<Coin<SUI>>, pool : &mut Pool, amount_x: u64, clock: &Clock, ctx: &mut TxContext){
        let coin_x = coin::zero<SUI>(ctx);
        pay::join_vec(&mut coin_x, inVec);
        let actual_amount = coin::value(&coin_x);
        assert!(actual_amount >= amount_x,0x11);

        let in_x = coin::split(&mut coin_x, amount_x, ctx);

        //add in to pool
        coin::put(&mut pool.coin_sui, in_x);

        let addr = tx_context::sender(ctx);

        let sequence = pool.sequence;

        //return exact coin to sender
        transfer::public_transfer(coin_x, tx_context::sender(ctx));

        event::emit(BridgeEvent{
            changeAddr: addr,
            amount: amount_x,
            orderId:genOrderId(clock, sequence)
        });
        pool.sequence = (pool.sequence + 1) % 100
    }

    fun genOrderId(clock: &Clock, sequence: u64): u64{
        let unix = clock::timestamp_ms(clock);
        let random = (unix + sequence) % 1000000;
        let orderId = (unix << 6) + random;
        return orderId
    }
}

