import Types::*;
import CMemTypes::*;
import RegFile::*;
import MemInit::*;

interface IMemory;
    method MemResp req(Addr a);
    interface MemInitIfc init;
endinterface

(* synthesize *)
module mkIMemory(IMemory);
	// In simulation we always init memory from a fixed VMH file (for speed)
	RegFile#(Bit#(16), Data) mem <- mkRegFileFullLoad("mem.vmh");
	MemInitIfc memInit <- mkDummyMemInit;
   // RegFile#(Bit#(16), Data) mem <- mkRegFileFull();
   // MemInitIfc memInit <- mkMemInitRegFile(mem);

    method MemResp req(Addr a) if (memInit.done());
        // $display("Instruction Memory: addr %h", a);
        // Bit#(16) data1 = truncate(a>>2);
        // Bit#(16) data2 = truncate((a-32'h200)>>2);
        // $display("mem.sub input: %h", data1);
        // $display("mem.sub input: %h", mem.sub(data1));
        return mem.sub(truncate(a>>2));
    endmethod

    interface MemInitIfc init = memInit;
endmodule

