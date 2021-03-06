#
#  tail.mk
#  Apple2BuildPipelineSample
#
#  Part of a sample build pipeline for Apple II software development
#
#  Created by Quinn Dunki on 8/15/14.
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#

export PATH := $(PATH):$(CC65_BIN)

CWD=$(shell pwd)

C_OBJS=$(C_SRCS:.c=.o)
C_DEPS=$(C_SRCS:.c=.u)
ASM_OBJS=$(ASM_SRCS:.s=.o)
ASM_LSTS=$(ASM_SRCS:.s=.lst)
OBJS=$(C_OBJS) $(ASM_OBJS)

MAPFILE=$(PGM).map
DISKIMAGE=$(PGM).dsk

LINK_ARGS=

EXECCMD=

ALLTARGET=$(DISKIMAGE)
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	ifneq ($(RUNTARGET),)
		ALLTARGET=$(RUNTARGET)
    endif
endif

ifneq ($(START_ADDR),)
# If the MACHINE is set to an option which does not support a variable start
# address, then error.
    ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
        $(error You cannot change start address with this machine type)
    endif
else
    # If not set, then use the default for the config as per cc65 documentation
    ifneq ($(filter $(MACHINE), apple2 apple2-dos33 apple2enh apple2enh-dos33),)
    	START_ADDR=803
    endif
    ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
    	START_ADDR=2000
    endif
    ifneq ($(filter $(MACHINE), apple2-loader apple2-reboot apple2enh-loader apple2enh-reboot),)
    	START_ADDR=800
    endif
endif
LDFLAGS += --start-addr 0x$(START_ADDR)

ifneq ($(filter $(MACHINE), apple2 apple2enh apple2-dos33 apple2enh-dos33),)
    EXECCMD=$(shell echo brun $(PGM) | tr '[a-z]' '[A-Z]')
endif

MACHCONFIG= -t apple2

ifneq ($(filter $(MACHINE), apple2enh apple2enh-dos33 apple2enh-system apple2enh-loader apple2enh-reboot),)
    MACHCONFIG= -t apple2enh
endif

ifeq ($(filter $(MACHINE), apple2 apple2enh),)
    MACHCONFIG += -C $(MACHINE).cfg
else
# The configuration current.cfg will be apple2(enh)-asm.cfg if there is only asembly.
# or apple2(enh).cfg if there is any c code.
	MACHCONFIG += -C current.cfg
endif

.PHONY: all execute virtual2 a2usbdsk transfer clean
	
all: $(ALLTARGET)

clean:
	rm -f "$(PGM)"
	rm -f $(OBJS)
	rm -f $(C_DEPS)
	rm -f $(MAPFILE)
	rm -f $(ASM_LSTS)
	rm -f "$(DISKIMAGE)"
	rm -f "current.cfg"


createPackage:
	pkg/createPackage

cleanMacCruft:
	rm -rf pkg

$(PGM): $(OBJS)
	$(CL65) $(MACHCONFIG) --mapfile $(MAPFILE) $(LDFLAGS) -o "$(PGM)" $(OBJS)

$(DISKIMAGE): $(PGM)
	make/createDiskImage $(AC) $(MACHINE) "$(DISKIMAGE)" "$(PGM)" "$(START_ADDR)"

a2usbdsk: $(DISKIMAGE)
	/usr/local/bin/a2usbdsk -1 $(CWD)/$(DISKIMAGE)

execute virtual2: $(DISKIMAGE)
	osascript \
-e "tell application \"Virtual ][\"" \
-e "	activate" \
-e "	tell front machine" \
-e "		eject device \"S6D1\"" \
-e "		insert \"$(CWD)/$(DISKIMAGE)\" into device \"S6D1\"" \
-e "		delay 0.5" \
-e "		restart" \
-e "		delay 0.25" \
-e "		if (\"$(EXECCMD)\" is not equal to \"\") then" \
-e "				type line \"$(EXECCMD)\"" \
-e "		end if" \
-e "	end tell" \
-e "end tell"


%.o %cgf:	%.c
	$(CL65) $(MACHCONFIG) $(CFLAGS) --create-dep $*.u -c -o $@ $<
	sed -i .bak 's/\.s:/.o:/' $(@:.o=.u)
	rm -f $(@:.o=.u).bak
# Overwrite a previous cfg file which may have less requirements.
	cp $(CC65_HOME)/../cfg/$(MACHINE).cfg ./current.cfg


%.o %cgf:	%.s
	$(CL65) $(MACHCONFIG) --cpu $(CPU) $(ASMFLAGS) -l $*.lst -c -o $@ $<
# Don't overwrite (but don't error on) a previous cfg file which may have extra requirements.
	cp -n $(CC65_HOME)/../cfg/$(MACHINE)-asm.cfg ./current.cfg ||:

$(OBJS): Makefile

-include $(C_DEPS)
