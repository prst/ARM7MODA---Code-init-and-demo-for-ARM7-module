#  ----------------------------------------------------------------------------
#          ATMEL Microcontroller Software Support
#  ----------------------------------------------------------------------------
#  Copyright (c) 2009, Atmel Corporation
#
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  - Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the disclaimer below.
#
#  Atmel's name may not be used to endorse or promote products derived from
#  this software without specific prior written permission. 
#
#  DISCLAIMER: THIS SOFTWARE IS PROVIDED BY ATMEL "AS IS" AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
#  DISCLAIMED. IN NO EVENT SHALL ATMEL BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
#  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
#  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  ----------------------------------------------------------------------------

if { [ catch { source "$libPath(extLib)/common/generic.tcl"} errMsg] } {
    messageDialg  error.gif "Common library file not found:\n$errMsg" "File not found" ok
    exit
}

namespace eval BOARD {
    variable sramSize         0x00010000
    variable maxBootSize      0
    # Vdd Memory 1.8V = 0 / Vdd Memory 3.3V = 1
    variable extRamVdd 1
    # External SDRAM = 0 / External DDR = 1 External PSRAM = 2 
    variable extRamType 2
    # Set bus width (16 or 32)
    variable extRamDataBusWidth 16
    # DDRAM Model (not used)
    variable extDDRamModel 0
}

################################################################################
## PROCEDURES FOR COMPATIBILITY WITH OLDER SAM-BA VERSIONS AND USER DEFINED
################################################################################
if { [ catch { source "$libPath(extLib)/common/functions.tcl"} errMsg] } {
    messageDialg  error.gif "Function file not found:\n$errMsg" "File not found" ok
    exit
}

array set memoryAlgo {
	"SRAM"       "::at91sam3u4_sram0"
	"SRAM 1"       "::at91sam3u4_sram1"
	"Flash 0"      "::at91sam3u4_flash0"
	"Flash 1"      "::at91sam3u4_flash1"
	"PSRAM"        "::at91sam3u4_psram"
	"NandFlash"    "::at91sam3u4_nandflash"
    "Peripheral"   "::at91sam3u4_peripheral"
    "REMAP"        "::at91sam3u4_remap"
}

################################################################################
## SRAM
################################################################################
array set at91sam3u4_sram0 {
	dftDisplay  1
    dftDefault  0
	dftAddress  0x20000000
	dftSize     0x8000
	dftSend     "RAM::sendFile"
	dftReceive  "RAM::receiveFile"
	dftScripts  ""
}
array set at91sam3u4_sram1 {
	dftDisplay  1
    dftDefault  0
	dftAddress  0x20080000
	dftSize     0x4000
	dftSend     "RAM::sendFile"
	dftReceive  "RAM::receiveFile"
	dftScripts  ""
}

################################################################################
## NANDFLASH
################################################################################
array set at91sam3u4_nandflash {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x0
    dftSize     "$GENERIC::memorySize"
    dftSend     "GENERIC::SendFile"
    dftReceive  "GENERIC::ReceiveFile"
    dftScripts  "::at91sam3u4_nandflash_scripts"
}

array set at91sam3u4_nandflash_scripts {
    "Enable NandFlash"    "NANDFLASH::Init"
    "Send Boot File"      "GENERIC::SendBootFileGUI"
    "Erase All"           "GENERIC::EraseAll"
    "Scrub NandFlash"     "GENERIC::EraseAll $NANDFLASH::scrubErase"
    "List Bad Blocks"     "NANDFLASH::BadBlockList"
}
set NANDFLASH::appletAddr          0x60000000
set NANDFLASH::appletMailboxAddr   0x60000040
set NANDFLASH::appletFileName      "$libPath(extLib)/$target(board)/isp-nandflash-at91sam3u4.bin"


################################################################################
## PSRAM
################################################################################
array set at91sam3u4_psram {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x60000000
    dftSize     "$GENERIC::memorySize"
    dftSend     "RAM::sendFile"
    dftReceive  "RAM::receiveFile"
    dftScripts  "::at91samsam3u4_psram_scripts"
}

puts "-I- External RAM Settings :  extRamVdd=$BOARD::extRamVdd, extRamType=$BOARD::extRamType, extRamDataBusWidth=$BOARD::extRamDataBusWidth, extDDRamModel=$BOARD::extDDRamModel"

set RAM::appletAddr          0x20001000
set RAM::appletMailboxAddr   0x20001040
set RAM::appletFileName      "$libPath(extLib)/$target(board)/isp-extram-at91sam3u4.bin"

array set at91samsam3u4_psram_scripts {
    "Enable PSRAM"   "GENERIC::Init $RAM::appletAddr $RAM::appletMailboxAddr $RAM::appletFileName [list $::target(comType) $::target(traceLevel) $BOARD::extRamVdd $BOARD::extRamType $BOARD::extRamDataBusWidth $BOARD::extDDRamModel]"
}


################################################################################
## FLASH
################################################################################
# The size of FLASH 0 set here is the total flash size (0 + 1) to allow a file
# larger than 128kbytes to be programmed across the two banks.
# The bank switching is managed by flash applet.
array set at91sam3u4_flash0 {
	dftDisplay  1
    dftDefault  1
    dftAddress  0x80000
    dftSize     0x40000
    dftSend     "FLASH::SendFile"
    dftReceive  "FLASH::ReceiveFile"
    dftScripts  "::at91sam3u4_flash0_scripts"
}
array set at91sam3u4_flash0_scripts {
        "Enable Security Bit (GPNVM0)"         "FLASH::ScriptSetSecurityBit"
        "Boot from Flash (GPNVM1)"             "FLASH::ScriptGPNMV 2"
        "Boot from ROM (GPNVM1)"               "FLASH::ScriptGPNMV 3"
        "Select FLASH0 for boot (GPNVM2)"      "FLASH::ScriptGPNMV 5"
        "Select FLASH1 for boot (GPNVM2)"      "FLASH::ScriptGPNMV 4"
        "Erase All Flash"                      "FLASH::EraseAll"
        "Enable Flash access"                  "FLASH::Init 0"
        "Read unique ID"                       "FLASH::ReadUniqueID"
}

array set at91sam3u4_flash1 {
	dftDisplay  1
    dftDefault  0
    dftAddress  0x100000
    dftSize     0x20000
    dftSend     "FLASH::SendFile"
    dftReceive  "FLASH::ReceiveFile"
    dftScripts  "::at91sam3u4_flash1_scripts"
}
array set at91sam3u4_flash1_scripts {
        "Enable Security Bit (GPNVM0)"         "FLASH::ScriptSetSecurityBit"
        "Boot from Flash (GPNVM1)"             "FLASH::ScriptGPNMV 2"
        "Boot from ROM (GPNVM1)"               "FLASH::ScriptGPNMV 3"
        "Select FLASH0 for boot (GPNVM2)"      "FLASH::ScriptGPNMV 5"
        "Select FLASH1 for boot (GPNVM2)"      "FLASH::ScriptGPNMV 4"
        "Erase All Flash"                      "FLASH::EraseAll"
        "Enable Flash access"                  "FLASH::Init 1"
}

set FLASH::appletAddr             0x20001000
set FLASH::appletMailboxAddr      0x20001040
set FLASH::appletFileName         "$libPath(extLib)/$target(board)/isp-flash-at91sam3u4.bin"

# Initialize PSRAM
if {[catch {GENERIC::Init $RAM::appletAddr $RAM::appletMailboxAddr $RAM::appletFileName [list $::target(comType) $::target(traceLevel) $BOARD::extRamVdd $BOARD::extRamType $BOARD::extRamDataBusWidth $BOARD::extDDRamModel]} dummy_err] } {
        set abort 1
        if {$commandLineMode == 0} {
            set abort [messageDialg warning.gif "External RAM initialization failed.\nExternal RAM access is required to run applets.\nContinue anyway ?" "External RAM init." yesno]
        }
        puts "-E- Error during external RAM initialization."
        puts "-E- External RAM access is required to run applets."
        # Close link
        if {$abort} {
            TCL_Close $target(handle)
            exit
        }
} else {
        puts "-I- External RAM initialized"
}

# Initialize FLASH
if {[catch {FLASH::Init 0} dummy_err]} {
        if {$commandLineMode == 0} {
            messageDialg error.gif "Failed to initialize FLASH access" "FLASH init." ok
        }
        puts "-E- Error during FLASH initialization"
        # Close link
        TCL_Close $target(handle)
        exit
} else {
        puts "-I- FLASH initialized"
}

if {$commandLineMode == 0} {
    messageDialg warning.gif "Do not forget to run the script \"Enable Flash access\" in Flash 0 or 1 pane before writing/reading a file in the corresponding flash." "Flash 0 and Flash 1 access" ok
}

################################################################################
array set at91sam3u4_peripheral {
	dftDisplay  0
    dftDefault  0
	dftAddress  0x40000000
	dftSize     0x10000000
	dftSend     ""
	dftReceive  ""
	dftScripts  ""
}

array set at91sam3u4_remap {
	dftDisplay  0
    dftDefault  0
	dftAddress  0x00000000
	dftSize     0x40000
	dftSend     ""
	dftReceive  ""
	dftScripts  ""
}

