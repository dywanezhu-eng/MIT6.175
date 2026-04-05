function Bit#(n) sra(Bit#(n) x ,Integer i );
    Int#(n) x_int = unpack(x);
    return pack(x_int >> i);
endfunction

function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) xor1( Bit#(1) a, Bit#(1) b );
    return a ^ b;
endfunction

function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return xor1( xor1( a, b ), c_in );
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return or1( and1( a, b ), and1( xor1( a, b ), c_in ) );
endfunction

function Bit#(TAdd#(n,1)) addN( Bit#(n) a, Bit#(n) b, Bit#(1) c_in );
    Bit#(n) sum;
    Bit#(TAdd#(n,1)) c = 0;
    c[0] = c_in;
    for (Integer i = 0 ; i < valueOf(n); i = i+1)begin
        sum[i] = fa_sum(a[i], b[i], c[i]);
        c[i+1] = fa_carry(a[i], b[i], c[i]); 
    end
    return {c[valueOf(n)],sum};
endfunction