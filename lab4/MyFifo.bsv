import Ehr::*;
import Vector::*;

//////////////////
// Fifo interface 

interface Fifo#(numeric type n, type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

/////////////////
// Conflict FIFO

module mkMyConflictFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));//???
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n)))    enqP     <- mkReg(0);
    Reg#(Bit#(TLog#(n)))    deqP     <- mkReg(0);
    // Reg#(Bool)              empty    <- mkReg(True);
    // Reg#(Bool)              full     <- mkReg(False);

    // useful value
    Bit#(TLog#(n))          max_index = fromInteger(valueOf(n)-1);
    // Reg#(Bit#(TLog#(n)))       valid_num <- mkReg(0);
    Reg#(Bool)       last_write <- mkReg(False);

    // TODO: Implement all the methods for this module
    method Bool notFull;
        // return (!(enqP == deqP && valid_num == max_index + 1));
        // return (!full);
        return (!(enqP == deqP && last_write == True));
    endmethod

    method Action enq(t x);
        if (!(enqP == deqP && last_write == True))begin
            data[enqP] <= x;
            if (enqP == max_index)begin
                enqP<= 0;
            end
            else begin
                enqP <= enqP + 1;
            end
            // valid_num <= valid_num + 1;
            // empty <= False;
            last_write <= True;
            // $display("enq:%b , valid_num :%b",enqP,valid_num);
        end
        // full <= (valid_num == max_index);
        // $display("full: %b , max_index: %d",full , max_index); 
    endmethod

    method Bool notEmpty;
        // return (!(enqP == deqP && valid_num == 0));
        // return (!empty);
        return (!(enqP == deqP && last_write == False));
    endmethod

    method Action deq;
        if (!(enqP == deqP && last_write == False))begin
            if (deqP == max_index)begin
                deqP <= 0;
            end
            else begin
                deqP <= deqP + 1;
            end
            // valid_num <= valid_num - 1;
            // full <= False;
            last_write <= False;
            // $display("deqP: %b, valid_num :%b",deqP,valid_num);
        end
        // empty <= ( valid_num == 1);
    endmethod

    method t first;
        return data[deqP];
    endmethod

    method Action clear;
        enqP <= 0;
        deqP <= 0;
        // empty <= True;
        // full <= False;
        last_write <= False;
        // valid_num <= 0;
        
    endmethod
endmodule

/////////////////
// Pipeline FIFO

// Intended schedule:
//      {notEmpty, first, deq} < {notFull, enq} < clear
module mkMyPipelineFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Ehr#(2,Bit#(TLog#(n)))    enqP     <- mkEhr(0);
    Ehr#(3,Bit#(TLog#(n)))    deqP     <- mkEhr(0);

    // useful value
    Bit#(TLog#(n))          max_index = fromInteger(valueOf(n)-1);
    Ehr#(3,Bool)            last_write <- mkEhr(False);

    // TODO: Implement all the methods for this module
    method Bool notFull;
        return (!(enqP[0] == deqP[1] && last_write[1] == True));
    endmethod

    method Action enq(t x);
        if (!(enqP[0] == deqP[1] && last_write[1] == True))begin
            data[enqP[0]] <= x;
            if (enqP[0] == max_index)begin
                enqP[0] <= 0;
            end
            else begin
                enqP[0] <= enqP[0] + 1;
            end
            last_write[1] <= True;
            // $display("enq:%b , valid_num :%b",enqP,valid_num);
        end
        // $display("full: %b , max_index: %d",full , max_index); 
    endmethod

    method Bool notEmpty;
        return (!(enqP[0] == deqP[0] && last_write[0] == False));
    endmethod

    method Action deq;
        if (!(enqP[0] == deqP[0] && last_write[0] == False))begin
            if (deqP[0] == max_index)begin
                deqP[0] <= 0;
            end
            else begin
                deqP[0] <= deqP[0] + 1;
            end
            last_write[0] <= False;
            // $display("deqP: %b, valid_num :%b",deqP,valid_num);
        end
    endmethod

    method t first;
        return data[deqP[0]];
    endmethod

    method Action clear;
        enqP[1] <= 0;
        deqP[2] <= 0;
        last_write[2] <= False;
    endmethod

endmodule

/////////////////////////////
// Bypass FIFO without clear

// Intended schedule:
//      {notFull, enq} < {notEmpty, first, deq} < clear
module mkMyBypassFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Ehr#(2,t))     data     <- replicateM(mkEhrU());
    Ehr#(3,Bit#(TLog#(n)))    enqP     <- mkEhr(0);
    Ehr#(2,Bit#(TLog#(n)))    deqP     <- mkEhr(0);

    // useful value
    Bit#(TLog#(n))          max_index = fromInteger(valueOf(n)-1);
    Ehr#(3,Bool)            last_write <- mkEhr(False);

    // TODO: Implement all the methods for this module
    method Bool notFull;
        return (!(enqP[0] == deqP[0] && last_write[0] == True));
    endmethod

    method Action enq(t x);
        if (!(enqP[0] == deqP[0] && last_write[0] == True))begin
            data[enqP[0]][0] <= x;
            if (enqP[0] == max_index)begin
                enqP[0] <= 0;
            end
            else begin
                enqP[0] <= enqP[0] + 1;
            end
            last_write[0] <= True;
            // $display("enq:%b , valid_num :%b",enqP,valid_num);
        end
        // $display("full: %b , max_index: %d",full , max_index); 
    endmethod

    method Bool notEmpty;
        return (!(enqP[1] == deqP[0] && last_write[1] == False));
    endmethod

    method Action deq;
        if (!(enqP[1] == deqP[0] && last_write[1] == False))begin
            if (deqP[0] == max_index)begin
                deqP[0] <= 0;
            end
            else begin
                deqP[0] <= deqP[0] + 1;
            end
            last_write[1] <= False;
            // $display("deqP: %b, valid_num :%b",deqP,valid_num);
        end
    endmethod

    method t first;
        return data[deqP[0]][1];
    endmethod

    method Action clear;
        enqP[2] <= 0;
        deqP[1] <= 0;
        last_write[2] <= False;
    endmethod
endmodule

//////////////////////
// Conflict free fifo

// Intended schedule:
//      {notFull, enq} CF {notEmpty, first, deq}
//      {notFull, enq, notEmpty, first, deq} < clear
module mkMyCFFifo( Fifo#(n, t) ) provisos (Bits#(t,tSz));
    // n is size of fifo
    // t is data type of fifo
    Vector#(n, Reg#(t))     data     <- replicateM(mkRegU());
    Ehr#(2, Bit#(TLog#(n)))    enqP     <- mkEhr(0);
    Ehr#(2, Bit#(TLog#(n)))    deqP     <- mkEhr(0);

    // useful value
    Bit#(TLog#(n))             max_index = fromInteger(valueOf(n)-1);
    Ehr#(3, Bool)              last_write <- mkEhr(False);

    //EHR
    Ehr#(3, Maybe#(t)) ehr_enq <- mkEhr(Invalid);
    Ehr#(3, Bool) ehr_deq <- mkEhr(False);

    (* no_implicit_conditions, fire_when_enabled *)
    rule canonicalize;
        if(isValid(ehr_enq[2]))begin
            data[enqP[1]] <= fromMaybe(?,ehr_enq[2]);
            if (enqP[1] == max_index)begin
                enqP[1] <= 0;
            end
            else begin
                enqP[1] <= enqP[1] + 1;
            end
            last_write[1] <= True;
        end
        if (ehr_deq[2])begin
            if (deqP[1] == max_index)begin
                deqP[1] <= 0;
            end
            else begin
                deqP[1] <= deqP[1] + 1;
            end
            last_write[2] <= False;
        end
        ehr_enq[2] <= Invalid;
        ehr_deq[2] <= False;
    endrule

    method Bool notFull;
        return (!(enqP[0] == deqP[0] && last_write[0] == True));
    endmethod

    method Action enq(t x);
        if (!(enqP[0] == deqP[0] && last_write[0] == True))begin
            ehr_enq[0] <= Valid(x);
        end
    endmethod

    method Bool notEmpty;
        return (!(enqP[0] == deqP[0] && last_write[0] == False));
    endmethod

    method Action deq;
        if (!(enqP[0] == deqP[0] && last_write[0] == False))begin
            ehr_deq[0] <= True;
        end
    endmethod

    method t first;
        return data[deqP[0]];
    endmethod

    method Action clear;
        enqP[0] <= 0;
        deqP[0] <= 0;
        last_write[0] <= False;
        ehr_enq[1] <= Invalid;
        ehr_deq[1] <= False;
    endmethod

endmodule

