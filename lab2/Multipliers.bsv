// Reference functions that use Bluespec's '*' operator
function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction



// Multiplication by repeated addition
function Bit#(TAdd#(n,n)) multiply_by_adding( Bit#(n) a, Bit#(n) b );
    // Bit#(TAdd#(n,n)) result = 0;
    // for(Integer i = 0; i < valueOf(n); i = i+1) begin
    //     if(b[i] == 1) begin
    //         Bit#(TAdd#(n,n)) partial = zeroExtend(a) << i;
    //         // Bit#(TAdd#(n,n)) partial = signExtend(a) << i;
    //         result = result + partial;
    //     end
    // end
    // return result;
    Bit#(n) tp = 0;
    Bit#(n) result = 0;
    for(Integer i = 0; i < valueOf(n); i = i+1) begin
        Bit#(n) c = (b[i] == 0) ? 0 : a;
        Bit#(TAdd#(n,1)) sum = zeroExtend(tp) + zeroExtend(c);
        tp = sum[valueOf(n):1];
        result[i] = sum[0];
    end 
    return {tp,result};
endfunction



// Multiplier Interface
interface Multiplier#( numeric type n );
    method Bool start_ready();
    method Action start( Bit#(n) a, Bit#(n) b );
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface



// Folded multiplier by repeated addition
module mkFoldedMultiplier( Multiplier#(n) )provisos (Add#(1, __any, n));//添加约束条件，让编译器知道n>=2
    // You can use these registers or create your own if you want
    Reg#(Bit#(n)) a <- mkRegU();
    Reg#(Bit#(n)) b <- mkRegU();
    Reg#(Bit#(n)) prod <- mkRegU();
    Reg#(Bit#(n)) tp <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n) + 1) );

    rule mulStep(i < fromInteger(valueOf(n)) ); //guard的写法
        Bit#(n) m = (a[0] == 0) ? 0 : b;
        a <= a >> 1;
        Bit#(TAdd#(n,1)) sum = zeroExtend(tp) + zeroExtend(m);
        // prod[i] <= sum[0];//会综合出多路选择器，电路开销非常大
        prod <= {sum[0] , prod[valueOf(n)-1 : 1]};//一旦调用n就是确定的，所以不属于变量移位寄存器
        tp <= truncate(sum >> 1);  //高位截断
        i <= i + 1;
    endrule

    method Bool start_ready();
        return i == fromInteger(valueOf(n) + 1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        a <= aIn;
        b <= bIn;
        prod <= 0;
        tp <= 0;
        i <= 0;
    endmethod

    method Bool result_ready();
        return i == fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        i <= fromInteger(valueOf(n) + 1);
        return {tp, prod};
    endmethod
endmodule



// Booth Multiplier
module mkBoothMultiplier( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mul_step;//( /* guard goes here */ );
        // TODO: Implement this in Exercise 6
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 6
        return False;
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 6
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 6
        return False;
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 6
        return 0;
    endmethod
endmodule



// Radix-4 Booth Multiplier
module mkBoothMultiplierRadix4( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)/2+1) );

    rule mul_step;//( /* guard goes here */ );
        // TODO: Implement this in Exercise 8
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 8
        return False;
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 8
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 8
        return False;
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 8
        return 0;
    endmethod
endmodule

