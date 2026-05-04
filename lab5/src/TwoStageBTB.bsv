// TwoStageBTB.bsv
//
// This is a two stage pipelined (with BTB) implementation of the RISC-V processor.

import Types::*;
import ProcTypes::*;
import CMemTypes::*;
import MemInit::*;
import RFile::*;
import DMemory::*;
import IMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import Btb::*;
import GetPut::*;


typedef struct {
	DecodedInst dInst;
	Addr pc;
	Addr predPc;
} Dec2Ex deriving (Bits, Eq);

(* synthesize *)
module mkProc(Proc);
    Ehr#(2, Addr) pc <- mkEhrU;
    RFile      rf <- mkRFile;
	IMemory  iMem <- mkIMemory;
    DMemory  dMem <- mkDMemory;
    CsrFile  csrf <- mkCsrFile;
    Btb#(6)   btb <- mkBtb; // 64-entry BTB

    Reg#(Dec2Ex)  dec2ex <- mkRegU;
    Ehr#(2,Bool)  dec2ex_valid <- mkEhr(False);

    Bool memReady = iMem.init.done() && dMem.init.done();
    
    rule test (!memReady);
        let e = tagged InitDone;
        iMem.init.request.put(e);
        dMem.init.request.put(e);
    endrule

    rule pipeline(csrf.started);
        Data inst = iMem.req(pc[0]);
        
        // trace - print the instruction
        $display("pc: %h inst: (%h) expanded: ", pc[0], inst, showInst(inst));
	    $fflush(stdout);
        //branch predict
        Addr pre_pc = btb.predPc(pc[0]);
        pc[0] <= pre_pc;

        DecodedInst dInst_noReg = decode(inst);
        dec2ex <= Dec2Ex{dInst: dInst_noReg, pc: pc[0], predPc: pre_pc};
        dec2ex_valid[0] <= True;

        // read general purpose register values
        if(dec2ex_valid[0])begin
            Data rVal1 = rf.rd1(fromMaybe(?, dec2ex.dInst.src1));
            Data rVal2 = rf.rd2(fromMaybe(?, dec2ex.dInst.src2));

            // read CSR values (for CSRR inst)
            Data csrVal = csrf.rd(fromMaybe(?, dec2ex.dInst.csr));

            // execute
            ExecInst eInst = exec(dec2ex.dInst, rVal1, rVal2, dec2ex.pc, dec2ex.predPc, csrVal);  
            // The fifth argument above is the predicted pc, to detect if it was mispredicted. 

            // memory
            if(eInst.iType == Ld) begin
                eInst.data <- dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
            end else if(eInst.iType == St) begin
                let d <- dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
            end

            // check unsupported instruction at commit time. Exiting
            if(eInst.iType == Unsupported) begin
                $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", dec2ex.pc);
                $finish;
            end

            // write back to reg file
            if(isValid(eInst.dst)) begin
                rf.wr(fromMaybe(?, eInst.dst), eInst.data);
            end

            // branch misPredict
            if (eInst.mispredict) begin
                $display("mispredict taken!");
                btb.update(dec2ex.pc, eInst.addr);
                pc[1] <= eInst.addr;
                dec2ex_valid[1] <= False;
            end else begin
                dec2ex_valid[1] <= dec2ex_valid[0];
            end

            // CSR write for sending data to host & stats
            csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
        end
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret <- csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
        csrf.start(0); // only 1 core, id = 0
        pc[0] <= startpc;
    endmethod

	interface iMemInit = iMem.init;
    interface dMemInit = dMem.init;
endmodule

