#  ----------------------------------------------------------------------------
#          ATMEL Microcontroller Software Support
#  ----------------------------------------------------------------------------
#  Copyright (c) 2008, Atmel Corporation
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




################################################################################
## BOARD SPECIFIC PARAMETERS
################################################################################
namespace eval BOARD {
    variable sramSize         $AT91C_IRAM_SIZE
    variable maxBootSize      [expr 28 * 1024]

    # Vdd Memory 1.8V = 0 / Vdd Memory 3.3V = 1
    variable extRamVdd 0
    # External SDRAM = 0 / External DDR = 1
    variable extRamType 1
    # Set bus width (16 or 32)
    variable extRamDataBusWidth 16 
    # DDRAM Model (only one for DK board)
    variable extDDRamModel 0
}

# Source procedures for compatibility with older SAM-BA versions
if { [ catch { source "$libPath(extLib)/common/functions.tcl"} errMsg] } {
    messageDialg  error.gif "Function file not found:\n$errMsg" "File not found" ok
    exit
}

array set memoryAlgo {
    "SRAM"                    "::at91cap9_dk_sram"
    "DDRAM"                   "::at91cap9_dk_ddram"    
    "DataFlash AT45DB/DCB"    "::at91cap9_dk_dataflash"
    "SerialFlash AT25/AT26"   "::at91cap9_dk_serialflash"
    "NandFlash"               "::at91cap9_dk_nandflash"   
    "EEPROM AT24"             "::at91cap9_dk_eeprom"
    "Peripheral"              "::at91cap9_dk_peripheral"
    "ROM"                     "::at91cap9_dk_rom"
    "REMAP"                   "::at91cap9_dk_remap"
    "LCD"                     "::at91cap9_dk_lcd"    
}

################################################################################
## SRAM
################################################################################
array set at91cap9_dk_sram {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x00100000
    dftSize     0x8000
    dftSend     "RAM::sendFile"
    dftReceive  "RAM::receiveFile"
    dftScripts  ""
}

################################################################################
## DDRAM
################################################################################
array set at91cap9_dk_ddram {
    dftDisplay  1
    dftDefault  0
    dftAddress  "0x70000000"
    dftSize     "$GENERIC::memorySize"
    dftSend     "RAM::sendFile"
    dftReceive  "RAM::receiveFile"
    dftScripts  "::at91cap9_dk_ddram_scripts"
}

puts "-I- External RAM Settings :  extRamVdd=$BOARD::extRamVdd, extRamType=$BOARD::extRamType, extRamDataBusWidth=$BOARD::extRamDataBusWidth, extDDRamModel=$BOARD::extDDRamModel"

set RAM::appletAddr          0x101000
set RAM::appletMailboxAddr   0x101004
set RAM::appletFileName      "$libPath(extLib)/at91cap9-dk/isp-extram-at91cap9.bin"

array set at91cap9_dk_ddram_scripts {
    "Enable DDRAM"   "GENERIC::Init $RAM::appletAddr $RAM::appletMailboxAddr $RAM::appletFileName [list $::target(comType) $::target(traceLevel) $BOARD::extRamVdd $BOARD::extRamType $BOARD::extRamDataBusWidth $BOARD::extDDRamModel]"
}

# Initialize DDRAMC
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

################################################################################
## DATAFLASH
################################################################################
array set at91cap9_dk_dataflash {
    dftDisplay  1
    dftDefault  1
    dftAddress  0x0
    dftSize     "$GENERIC::memorySize"
    dftSend     "GENERIC::SendFile"
    dftReceive  "GENERIC::ReceiveFile"
    dftScripts  "::at91cap9_dk_dataflash_scripts"
}

array set at91cap9_dk_dataflash_scripts {
    "Enable Dataflash (SPI0 CS0)"                        "DATAFLASH::Init 0"
    "Send Boot File"                                     "GENERIC::SendBootFileGUI"
    "Erase All"                                          "DATAFLASH::EraseAll"
    "Set DF in Power-Of-2 Page Size mode (Binary mode)"  "DATAFLASH::BinaryPage"
}

set DATAFLASH::appletAddr          0x70000000
set DATAFLASH::appletMailboxAddr   0x70000004
set DATAFLASH::appletFileName      "$libPath(extLib)/at91cap9-dk/isp-dataflash-at91cap9.bin"

################################################################################
## SERIALFLASH
################################################################################
array set at91cap9_dk_serialflash {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x0
    dftSize     "$GENERIC::memorySize"
    dftSend     "GENERIC::SendFile"
    dftReceive  "GENERIC::ReceiveFile"
    dftScripts  "::at91cap9_dk_serialflash_scripts"
}

array set at91cap9_dk_serialflash_scripts {
    "Enable Serialflash (SPI0 CS0)"   "SERIALFLASH::Init 0"
    "Send Boot File"                  "GENERIC::SendBootFileGUI"
    "Erase All"                       "SERIALFLASH::EraseAll"
}

set SERIALFLASH::appletAddr          0x70000000
set SERIALFLASH::appletMailboxAddr   0x70000004
set SERIALFLASH::appletFileName      "$libPath(extLib)/at91cap9-dk/isp-serialflash-at91cap9.bin"

################################################################################
## NANDFLASH
################################################################################
array set at91cap9_dk_nandflash {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x0
    dftSize     "$GENERIC::memorySize"
    dftSend     "GENERIC::SendFile"
    dftReceive  "GENERIC::ReceiveFile"
    dftScripts  "::at91cap9_dk_nandflash_scripts"
}

array set at91cap9_dk_nandflash_scripts {
    "Enable NandFlash"    "NANDFLASH::Init"
    "Send Boot File"      "GENERIC::SendBootFileGUI"
    "Erase All"           "GENERIC::EraseAll"
    "Scrub NandFlash"     "GENERIC::EraseAll $NANDFLASH::scrubErase"
    "List Bad Blocks"     "NANDFLASH::BadBlockList"
}
set NANDFLASH::appletAddr          0x70000000
set NANDFLASH::appletMailboxAddr   0x70000004
set NANDFLASH::appletFileName      "$libPath(extLib)/at91cap9-dk/isp-nandflash-at91cap9.bin"

#TCL_Write_Int $target(handle) 0x4000000 0xfffff410
#TCL_Write_Int $target(handle) 0x4000000 0xfffff430

################################################################################
## EEPROM
################################################################################
array set at91cap9_dk_eeprom {
    dftDisplay  1
    dftDefault  0
    dftAddress  0x0
    dftSize     "$GENERIC::memorySize"
    dftSend     "GENERIC::SendFile"
    dftReceive  "GENERIC::ReceiveFile"
    dftScripts  "::at91cap9_dk_eeprom_scripts"
}

array set at91cap9_dk_eeprom_scripts {
    "Enable EEPROM AT24C01x"          "EEPROM::Init 0"
    "Enable EEPROM AT24C02x"          "EEPROM::Init 1"
    "Enable EEPROM AT24C04x"          "EEPROM::Init 2"
    "Enable EEPROM AT24C08x"          "EEPROM::Init 3"
    "Enable EEPROM AT24C16x"          "EEPROM::Init 4"
    "Enable EEPROM AT24C32x"          "EEPROM::Init 5"
    "Enable EEPROM AT24C64x"          "EEPROM::Init 6"
    "Enable EEPROM AT24C128x"         "EEPROM::Init 7"
    "Enable EEPROM AT24C256x"         "EEPROM::Init 8"
    "Enable EEPROM AT24C512x"         "EEPROM::Init 9"
    "Enable EEPROM AT24C1024x"        "EEPROM::Init 10"
    "Send Boot File"                  "GENERIC::SendBootFileGUI"    
}

set EEPROM::appletAddr          0x70000000
set EEPROM::appletMailboxAddr   0x70000004
set EEPROM::appletFileName      "$libPath(extLib)/at91cap9-dk/isp-eeprom-at91cap9.bin"

################################################################################
array set at91cap9_dk_peripheral {
    dftDisplay  0
    dftDefault  0
    dftAddress  0xFF000000
    dftSize     0x10000000
    dftSend     ""
    dftReceive  ""
    dftScripts  ""
}

array set at91cap9_dk_rom {
    dftDisplay  0
    dftDefault  0
    dftAddress  0x400000
    dftSize     0x8000
    dftSend     ""
    dftReceive  ""
    dftScripts  ""
}

array set at91cap9_dk_remap {
    dftDisplay  0
    dftDefault  0
    dftAddress  0x00000000
    dftSize     0x10000
    dftSend     ""
    dftReceive  ""
    dftScripts  ""
}

array set at91cap9_dk_lcd {
    dftDisplay  0
    dftDefault  0
    dftAddress  0x500000
    dftSize     0x8000
    dftSend     ""
    dftReceive  ""
    dftScripts  ""
}

