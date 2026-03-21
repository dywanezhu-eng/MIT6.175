function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) xor1( Bit#(1) a, Bit#(1) b );
    return a ^ b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~ a;
endfunction

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    let sel_not = not1(sel);
    let out_and_0 = and1(a, sel_not);
    let out_and_1 = and1(b, sel);
    let out = or1(out_and_0, out_and_1);
    return out;
endfunction

function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    // Bit#(5) out;
    // for (Integer i = 0; i < 5; i = i + 1) begin
    //     out[i] = multiplexer1(sel, a[i], b[i]);
    // end
    // return out;
    return multiplexer_n(sel, a, b);
endfunction

typedef 5 N;
function Bit#(N) multiplexerN(Bit#(1) sel, Bit#(N) a, Bit#(N) b);
    return (sel == 0)? a : b;
endfunction

//typedef 32 N; // Not needed
function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) out;
    for (Integer i = 0 ; i < valueOf(n) ; i = i + 1 ) begin
        out[i] = multiplexer1(sel, a[i], b[i]);
    end
    return out;
    //return (sel == 0)? a : b;
endfunction
