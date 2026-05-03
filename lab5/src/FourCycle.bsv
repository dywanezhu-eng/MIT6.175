// FourCycle.bsv
//
// This is a four cycle implementation of the RISC-V processor.

import Types::*;
import ProcTypes::*;
import CMemTypes::*;
import MemInit::*;
import RFile::*;
import DelayedMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import GetPut::*;


typedef enum {
	Fetch,
	Decode,
	Execute,
	WriteBack
} Stage deriving(Bits, Eq, FShow);

(* synthesize *)
module mkProc(Proc);
    Reg#(Addr)    pc <- mkRegU;
    RFile         rf <- mkRFile;
    DelayedMemory mem <- mkDelayedMemory;
	let dummyInit     <- mkDummyMemInit;
    CsrFile       csrf <- mkCsrFile;

    //state Reg 
    Reg#(Stage) state <- mkReg(Fetch);
    //f2d Reg

    //d2e Reg
    Reg#(DecodedInst)  dInst  <- mkRegU;
    Reg#(Data)  rVal1  <- mkRegU;
    Reg#(Data)  rVal2  <- mkRegU;
    Reg#(Data)  csrVal <- mkRegU;
    //e2w Reg
    Reg#(ExecInst)  eInst <- mkRegU;

    Bool memReady = mem.init.done && dummyInit.done;
    
    // TO DO ex2
    
    rule test (!memReady);
        let e = tagged InitDone;
        mem.init.request.put(e);
        dummyInit.request.put(e);
    endrule

    rule fetch (csrf.started && state == Fetch);
        $display("cycle fetch");
        mem.req(MemReq{op: Ld, addr :pc, data: ?});
        state <= Decode;
        
    endrule

    rule decode (csrf.started && state == Decode);
        Instruction inst <- mem.resp();
        $display("cycle decode");
        // trace - print the instruction
        $display("pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));
	$fflush(stdout);
        DecodedInst dInst_noReg = decode(inst);

        // read general purpose register values 
        Data rVal1_noReg = rf.rd1(fromMaybe(?, dInst_noReg.src1));
        rVal1 <= rVal1_noReg;
        Data rVal2_noReg = rf.rd2(fromMaybe(?, dInst_noReg.src2));
        rVal2 <= rVal2_noReg;

        // read CSR values (for CSRR inst)
        Data csrVal_noReg = csrf.rd(fromMaybe(?, dInst_noReg.csr));
        csrVal <= csrVal_noReg;

        dInst <= dInst_noReg;
        state <= Execute;
        
    endrule

    rule execute (csrf.started && state == Execute);
        $display("cycle execute");
        ExecInst eInst_noReg = exec(dInst, rVal1, rVal2, pc, ?, csrVal); 

        // memory
        if(eInst_noReg.iType == Ld) begin
            mem.req(MemReq{op: Ld, addr: eInst_noReg.addr, data: ?});
        end else if(eInst_noReg.iType == St) begin
            mem.req(MemReq{op: St, addr: eInst_noReg.addr, data: eInst_noReg.data});
        end
        // check unsupported instruction at commit time. Exiting
        if(eInst_noReg.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pc);
            $finish;
        end

        eInst <= eInst_noReg;
        state <= WriteBack;
    endrule

    rule writeback (csrf.started && state == WriteBack);
        $display("cycle writeback");
        ExecInst eInst_noReg_1 = eInst;
        if(eInst_noReg_1.iType == Ld) begin
            eInst_noReg_1.data <- mem.resp(); 
        end
        // write back to reg file
        if(isValid(eInst_noReg_1.dst)) begin
            rf.wr(fromMaybe(?, eInst_noReg_1.dst), eInst_noReg_1.data);
        end

        // update the pc depending on whether the branch is taken or not
        pc <= eInst_noReg_1.brTaken ? eInst_noReg_1.addr : pc + 4;

        // CSR write for sending data to host & stats
        csrf.wr(eInst_noReg_1.iType == Csrw ? eInst_noReg_1.csr : Invalid, eInst_noReg_1.data);

        state <= Fetch;
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret <- csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
        csrf.start(0); // only 1 core, id = 0
        pc <= startpc;
    endmethod

	interface iMemInit = dummyInit;
    interface dMemInit = mem.init;
endmodule

