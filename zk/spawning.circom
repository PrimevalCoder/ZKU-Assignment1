pragma circom 2.0.0;
include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
    signal input x;
    signal input y;

    signal output h;

    /* check x^2 + y^2 < r^2 */
    component comp_lt = LessThan(64);
    component comp_gt = GreaterThan(64);

    // check x^2 + y^2 <= 64^2. we assume x, y >= 0
    signal xSq;
    signal ySq;
    signal rSq;
    xSq <== x * x;
    ySq <== y * y;
    rSq <== 64 * 64;    // radius is 64
    comp_lt.in[0] <== xSq + ySq;
    comp_lt.in[1] <== rSq;
    comp_lt.out === 1;

    // check x^2 + y^2 > 32^2
    comp_gt.in[0] <== xSq + ySq;
    comp_gt.in[1] <== 32 * 32;
    comp_gt.out === 1;

    /* check MiMCSponge(x,y) = pub */
    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    h <== mimc.outs[0];

    // gcd(x, y) > 1 & not prime. We compute the gcd using Euclid's algorithm
    var a = x, b = y;
    var r;
    while(b)
    {
        r = a%b;
        a = b;
        b = r;
    }
    // 'a' will contain the gcd after these steps.
    var gcd = a;
    // check gcd > 1 & gcd not prime
    signal s_gcd;
    var ok = 1;
    ok = gcd > 1 ? 1 : 0;
    var primes[18] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61];
    for(var i = 0; i < 18 && ok; i++)
    {
        if(gcd == primes[i])
            ok = 0;
    }
    s_gcd <-- ok;
    s_gcd === 1;
    // should we use comparator circuits instead?
}

component main = Main();
