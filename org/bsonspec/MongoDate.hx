package org.bsonspec;

import haxe.Int64;
import UInt;
using haxe.Int64;

@:forward
abstract MongoDate(Date) {

    public inline function new(date:Date)
    {
        this = date;
    }

    @:from public inline static function fromInt64time(ms:Int64):MongoDate
    {
        // double = high << 32 + low
        //    with  a << b = a*(1 << b)
        return new MongoDate(Date.fromTime(POW32f*ms.high + unsigned((ms.low:Int))));
    }

    @:to public inline function getTimeInt64():Int64
    {
        var t = this.getTime();
        // compute using only xx bits for each i32 part
        // to avoid problems with overflow and (TODO) precision
        var f = t/POWxxf;
        var high = Std.int(f);
        var ti = POWxxf*high;
        var low = Std.int(t - ti);  // remainder
        // trace('t: $t, f: $f, high: $high, POWxxf*high: $ti, low: $low, lowf: ${t - ti}');
        // adjust for int32
        low |= high << xx;
        high = high >> (32 - xx);
        // trace('high: $high, low: $low');
        return Int64.make(high, low);
    }

    static function unsigned(i:UInt):Float
    {
        // conversion peformed by UInt.toFloat()
        // basically, when negative, return POW32f + i
        return i;
    }

    static var xx = 31;
    static var POWxxf = Math.pow(2, xx);
    static var POW32f = Math.pow(2, 32);

}

// random note: 1 << 32 = u0xffffffff + 1 = 4294967296

