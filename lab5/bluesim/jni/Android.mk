
include $(CLEAR_VARS)
DTOP?=/home/dywane_zhu/MIT_6.175/lab5/bluesim
CONNECTALDIR?=/home/dywane_zhu/MIT_6.175/lab5/connectal
LOCAL_ARM_MODE := arm
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
LOCAL_SRC_FILES := /home/dywane_zhu/MIT_6.175/lab5/main.cpp /home/dywane_zhu/MIT_6.175/lab5/connectal/cpp/dmaManager.c /home/dywane_zhu/MIT_6.175/lab5/connectal/cpp/platformMemory.cpp /home/dywane_zhu/MIT_6.175/lab5/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)

LOCAL_PATH :=
LOCAL_MODULE := android.exe
LOCAL_MODULE_TAGS := optional
LOCAL_LDLIBS := -llog   
LOCAL_CPPFLAGS := "-march=armv7-a"
LOCAL_CFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CXXFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp  -Wno-error=address -Wno-address -Werror
LOCAL_CFLAGS2 := $(cdefines2)s

include $(BUILD_EXECUTABLE)
