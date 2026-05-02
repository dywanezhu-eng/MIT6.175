CONNECTALDIR ?= connectal
S2H_INTERFACES = \
	ConnectalProcRequest:ConnectalWrapper.connectProc
H2S_INTERFACES = \
	ConnectalWrapper:ConnectalProcIndication
BSVFILES += \
	src/includes/Ifc.bsv
BSVPATH += / \
	src/ \
	src/includes \
	$(CONNECTALDIR)/bsv
CPPFILES += \
	main.cpp

#CONNECTALFLAGS += --mainclockperiod=20
#CONNECTALFLAGS += --verilog=ddr3_v2_0/
SOFTWARE_SOCKET_NAME=/tmp/connectal$(USER)
export SOFTWARE_SOCKET_NAME
CONNECTALFLAGS += -D $(VPROC) 
CONNECTALFLAGS += --bscflags " -D $(VPROC) -steps-max-intervals 50 +RTS -K256M -RTS"
CONNECTALFLAGS += --bscflags " -show-schedule"
#CONNECTALFLAGS += --cxxflags="-g -std=gnu++11"
CONNECTALFLAGS += --cxxflags="-Wno-error=address -Wno-address" #关闭 GCC 对数组地址的严格检查

include $(CONNECTALDIR)/Makefile.connectal


clean:
	rm -rf bluesim

