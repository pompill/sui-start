module bridge::bridge {

    use sui::object::UID;
    use sui::object;
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
        amount : u64
    }

    struct Pool has key {
        id :UID,
        coin_sui: Balance<SUI>,
    }

    fun init(_: BRIDGE, ctx: &mut TxContext){
        //admin cap
        let bc = BridgeCap{
            id: object::new(ctx)
        };
        let pool = Pool{
            id: object::new(ctx),
            coin_sui: balance::zero(),
        };
        transfer::share_object(pool);
        //admin cap to contract
        transfer::public_transfer(bc, tx_context::sender(ctx));
    }

    //ask admin to get pool.coin
    public fun transferCoin(_:&mut BridgeCap, pool : &mut Pool,amount: u64,ctx: &mut TxContext): Coin<SUI>{
        coin::take(&mut pool.coin_sui, amount, ctx)
    }

    public entry fun deposit(inVec : vector<Coin<SUI>>, pool : &mut Pool, amount_x: u64, ctx: &mut TxContext){
        let coin_x = coin::zero<SUI>(ctx);
        pay::join_vec(&mut coin_x, inVec);
        let actual_amount = coin::value(&coin_x);
        assert!(actual_amount >= amount_x,0x11);

        let in_x = coin::split(&mut coin_x, amount_x, ctx);

        //add in to pool
        coin::put(&mut pool.coin_sui, in_x);

        let addr = tx_context::sender(ctx);

        event::emit(BridgeEvent{
            changeAddr: addr,
            amount: amount_x
        });

        //return exact coin to sender
        transfer::public_transfer(coin_x, tx_context::sender(ctx));
    }
}

