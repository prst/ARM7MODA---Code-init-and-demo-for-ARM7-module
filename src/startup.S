/***********************************************************************/
/*  This file is part of the CA ARM C Compiler package                 */
/*  Copyright KEIL ELEKTRONIK GmbH 2002-2004                           */
/***********************************************************************/
/*                                                                     */
/*  SAM7S.S:  Startup file for Atmel AT91SAM7S device series           */
/*                                                                     */
/***********************************************************************/


/* 
//*** <<< Use Configuration Wizard in Context Menu >>> *** 
*/


# *** Startup Code (executed after Reset) ***


# Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

        .equ    Mode_USR,       0x10
        .equ    Mode_FIQ,       0x11
        .equ    Mode_IRQ,       0x12
        .equ    Mode_SVC,       0x13
        .equ    Mode_ABT,       0x17
        .equ    Mode_UND,       0x1B
        .equ    Mode_SYS,       0x1F

        .equ    I_Bit,          0x80    /* when I bit is set, IRQ is disabled */
        .equ    F_Bit,          0x40    /* when F bit is set, FIQ is disabled */


/*
// <h> Stack Configuration
*/
        .equ    Top_Stack,      0x00210000
        .equ    UND_Stack_Size, 0x00000004
        .equ    SVC_Stack_Size, 0x00000004
        .equ    ABT_Stack_Size, 0x00000004
        .equ    FIQ_Stack_Size, 0x00000004
        .equ    IRQ_Stack_Size, 0x00000100
        .equ    USR_Stack_Size, 0x00000400


# Advanced Interrupt controller (AIC) definitions
	.equ	AIC_BASE,	0xFFFFF000
	.equ	AIC_IVR,	0x100
	.equ	AIC_EOICR,	0x130
# Embedded Flash Controller (EFC) definitions
        .equ    EFC_BASE,       0xFFFFFF00  /* EFC Base Address */
        .equ    EFC_FMR,        0x60        /* EFC_FMR Offset */

/*
// <e> Embedded Flash Controller (EFC)
*/
        .equ    EFC_SETUP,      1
@        .equ    EFC_FMR_Val,    0x00320100
        .equ    EFC_FMR_Val,    0x00320100


# Watchdog Timer (WDT) definitions
        .equ    WDT_BASE,       0xFFFFFD40  /* WDT Base Address */
        .equ    WDT_MR,         0x04        /* WDT_MR Offset */

/*
// <e> Watchdog Timer (WDT)
*/
        .equ    WDT_SETUP,      1
        .equ    WDT_MR_Val,     0x00008000


# Power Mangement Controller (PMC) definitions
        .equ    PMC_BASE,       0xFFFFFC00  /* PMC Base Address */
        .equ    PMC_MOR,        0x20        /* PMC_MOR Offset */
        .equ    PMC_MCFR,       0x24        /* PMC_MCFR Offset */
        .equ    PMC_PLLR,       0x2C        /* PMC_PLLR Offset */
        .equ    PMC_MCKR,       0x30        /* PMC_MCKR Offset */
        .equ    PMC_SR,         0x68        /* PMC_SR Offset */
        .equ    PMC_MOSCEN,     (1<<0)      /* Main Oscillator Enable */
        .equ    PMC_OSCBYPASS,  (1<<1)      /* Main Oscillator Bypass */
        .equ    PMC_OSCOUNT,    (0xFF<<8)   /* Main OScillator Start-up Time */
        .equ    PMC_DIV,        (0xFF<<0)   /* PLL Divider */
        .equ    PMC_PLLCOUNT,   (0x3F<<8)   /* PLL Lock Counter */
        .equ    PMC_OUT,        (0x03<<14)  /* PLL Clock Frequency Range */
        .equ    PMC_MUL,        (0x7FF<<16) /* PLL Multiplier */
        .equ    PMC_USBDIV,     (0x03<<28)  /* USB Clock Divider */
        .equ    PMC_CSS,        (3<<0)      /* Clock Source Selection */
        .equ    PMC_PRES,       (7<<2)      /* Prescaler Selection */
        .equ    PMC_MOSCS,      (1<<0)      /* Main Oscillator Stable */
        .equ    PMC_LOCK,       (1<<2)      /* PLL Lock Status */
	.equ	PMC_MCKRDY,	(1<<3)	    /* Master clock ready */

/*
// <e> Power Mangement Controller (PMC)
*/
@        .equ    PMC_SETUP,      1
        .equ    PMC_SETUP,      1

@        .equ    PMC_MOR_Val,    0x0000ff01
        .equ    PMC_MOR_Val,    0x00000f01 @ slow

@        .equ    PMC_PLLR_Val,   0x00007F01
@        .equ    PMC_PLLR_Val,   0x000F3F02
        .equ    PMC_PLLR_Val,   0x00000000 @ slow

@        .equ    PMC_MCKR_Val,   0x00000001
        .equ    PMC_MCKR_Val,   0x00000001 @ slow


# Starupt Code must be linked first at Address at which it expects to run.
        .text
        .arm

        .global _startup
        .func   _startup
_startup:
        .globl _start
_start:

# Exception Vectors
#  Mapped to Address 0.
#  Absolute addressing mode must be used.
#  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors:        
		LDR     PC, Reset_Addr         
                LDR     PC, Undef_Addr
                LDR     PC, SWI_Addr
                LDR     PC, PAbt_Addr
                LDR     PC, DAbt_Addr
                NOP                            /* Reserved Vector */
		LDR     PC, IRQ_Addr
@;                LDR     PC,[PC,#-0xF20]        /* Vector From AIC_IVR */
@;               LDR     PC,FIQ_Addr
                LDR     PC, [PC,#-0xF20]        /* Vector From AIC_FVR */

Reset_Addr:     .word   Reset_Handler
Undef_Addr:     .word   Undef_Handler
SWI_Addr:       .word   SWI_Handler
PAbt_Addr:      .word   PAbt_Handler
DAbt_Addr:      .word   DAbt_Handler
                .word   0                      /* Reserved Address */
IRQ_Addr:       .word   IRQ_Handler
FIQ_Addr:       .word   FIQ_Handler
@;------------------------------------------------------
@    .global	sendComPort
Undef_String:	.ascii	"\r\n UNDEF exeption\0"
DAbt_String:	.ascii	"\r\n Data abort exeption\0"
PAbt_String:	.ascii	"\r\n Prefetch abort exeption\0"
@;------------------------------------------------------
Undef_Handler:
@;------------------------------------------------------
	stmdb	sp!, {r0-r3, lr}
	
	ldr	r0, =Undef_String
@	bl	sendComPort

	ldmia	sp!, {r0-r3, pc}^

@;------------------------------------------------------
SWI_Handler:
@;------------------------------------------------------
	stmdb	sp!, {r0, r1, lr}
	
	b	0
	
	ldmia	sp!, {r0, r1, pc}^

@;------------------------------------------------------
PAbt_Handler:
@;------------------------------------------------------
	sub	lr, lr, #4
	stmdb	sp!, {r0-r3, lr}
	
	ldr	r0, =PAbt_String
@	bl	sendComPort
	
	ldmia	sp!, {r0-r3, pc}^

@;------------------------------------------------------
@    .global	sendStack
DAbt_Handler:
@;------------------------------------------------------
	sub	lr, lr, #8
	stmdb	sp!, {r0-r3, lr}
	
	ldr	r0, =DAbt_String
@	bl	sendComPort
	
	mov	r0, sp
@	bl	sendStack
	
	ldmia	sp!, {r0-r3, pc}^
@;------------------------------------------------------
FIQ_Handler:
@;------------------------------------------------------
	/* FIQ code 5 */
	ldr	r0, =0xFFFFF400
	ldr	r1, =~5
	str	r1, [r0, #0x38]
	
	b	0
	
	ldmia	sp!, {r0, r1, pc}^

	.global		IRQ_Handler

@;------------------------------------------------------
IRQ_Handler:
@;---------------------------
	sub	lr, lr, #4
        stmdb	sp!, {r0, r1, lr}

@;- Read ISR address from IVR
        ldr	r0, =AIC_BASE
        ldr	r1, [r0, #AIC_IVR]
@;- Save SPSR and in IRQ stack
        mrs	r0, SPSR
        stmdb	sp!, {r0}
@;- Enable Interrupts and Switch in SYS Mode
        mrs	r0, CPSR
        bic	r0, r0, #I_Bit
        orr	r0, r0, #Mode_SYS
        msr	CPSR, r0
@;- Branch to ISR
	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, r10, fp, ip, lr}
	mov	lr, pc
	bx	r1
	ldmia	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, r10, fp, ip, lr}
@;- Disable Interrupt and switch back in IRQ mode
        mrs	r0, CPSR
        bic	r0, r0, #Mode_SYS
        orr	r0, r0, #(I_Bit | Mode_IRQ)
        msr	CPSR, r0
@;- Mark the End of Interrupt on the AIC
        ldr	r0, =AIC_BASE
        str	r0, [r0, #AIC_EOICR]
@;- Restore SPSR_irq from IRQ stack
        ldmia	sp!, {r0}
        msr	SPSR, r0
@;- Restore adjusted LR_irq from IRQ stack directly in the PC
        ldmia	sp!, {r0, r1, pc}^
@;------------------------------------------------------
	.global	spuriousInterrupt
spuriousInterrupt:
	sub	lr, lr, #4
	stmdb	sp!, {r0, r1, lr}
	ldr	r0, =AIC_BASE
	str	r0, [r0, #AIC_EOICR]	
	
	ldmia	sp!, {r0, r1, lr}

# Reset Handler

Reset_Handler:  


# Setup EFC
.if EFC_SETUP
EFC_setup:
                LDR     R0, =EFC_BASE
                LDR     R1, =EFC_FMR_Val
                STR     R1, [R0, #EFC_FMR]
.endif


# Setup WDT
.if WDT_SETUP
WDT_setup:
                LDR     R0, =WDT_BASE
                LDR     R1, =WDT_MR_Val
                STR     R1, [R0, #WDT_MR]
.endif


# Setup PMC
.if PMC_SETUP
PMC_setup:
                LDR     R0, =PMC_BASE

#  Added by Max: switch to RC oscillator and turn off PLL
		mov	R1, #0
		str	R1, [R0, #PMC_MCKR]
RC_MCKRDY_Loop:
		ldr	R2, [r0, #PMC_SR]
		ands	R2, R2, #PMC_MCKRDY
		beq	RC_MCKRDY_Loop
		str	R1, [R0, #PMC_PLLR]
		
#  Setup Main Oscillator
                LDR     R1, =PMC_MOR_Val
                STR     R1, [R0, #PMC_MOR]

#  Wait until Main Oscillator is stablilized
.if (PMC_MOR_Val & PMC_MOSCEN)
MOSCS_Loop:     LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_MOSCS
                BEQ     MOSCS_Loop
.endif

#  Setup the PLL
.if (PMC_PLLR_Val & PMC_MUL)
                LDR     R1, =PMC_PLLR_Val
                STR     R1, [R0, #PMC_PLLR]

#  Wait until PLL is stabilized
PLL_Loop:       LDR     R2, [R0, #PMC_SR]
                ANDS    R2, R2, #PMC_LOCK
                BEQ     PLL_Loop
.endif

#  Select Clock
Load_MCKR:
                LDR     R1, =PMC_MCKR_Val
                STR     R1, [R0, #PMC_MCKR]
MCKRDY_Loop:
		LDR	R2, [r0, #PMC_SR]
		ANDS	R2, R2, #PMC_MCKRDY
		BEQ	MCKRDY_Loop
.endif


# Remap Memory (when Interrupt Vectors are in RAM)
        .equ    MC_BASE,0xFFFFFF00  /* MC Base Address */
        .equ    MC_RCR, 0x00        /* MC_RCR Offset */
	.equ	RAM_MODE, 1

.if (RAM_MODE)
# Added by Max: Check RAM is already mapped
Init_RAM_MODE:
		@ read address 0x100000
		ldr	r0, =0x100000
		ldr	r1, [r0]
		@ write ~[0x100000] to 0x200000
		mvn	r1, r1
		ldr	r2, =0x200000
		str	r1, [r2]
		@ compare 0x000000 and 0x200000
		ldr	r0, =0x000000
		ldr	r3, [r0]	@; r3 = [0x000000]
		cmp	r3, r1
		beq	End_of_RAM_remap
RAM_Remap:
		@ RAM remap
                LDR     R0, =MC_BASE
                MOV     R1, #1
                STR     R1, [R0, #MC_RCR]
End_of_RAM_remap:
# Added by Max: load vectors to RAM
		ldr	r0, =0x200000
		ldr	r1, =Vectors
		ldr	r2, =16
vectorsCopyLoop:
		ldr	r3, [r1], #4
		str	r3, [r0], #4
		subs	r2, r2, #1
		cmp	r2, #0
		bne	vectorsCopyLoop
.endif


# Setup Stack for each mode
Stack_config:
                LDR     R0, =Top_Stack

#  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND|I_Bit|F_Bit
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

#  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT|I_Bit|F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

#  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ|I_Bit|F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

#  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ|I_Bit|F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

#  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC|I_Bit|F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

#  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0

#  Setup a default Stack Limit (when compiled with "-mapcs-stack-check")
               SUB     SL, SP, #USR_Stack_Size

# Relocate .data section (Copy from ROM to RAM)
Data_init:
                LDR     R1, =_etext
                LDR     R2, =_data
                LDR     R3, =_edata
LoopRel:        CMP     R2, R3
                LDRLO   R0, [R1], #4
                STRLO   R0, [R2], #4
                BLO     LoopRel


# Clear .bss section (Zero init)
Clear_bss:
                MOV     R0, #0
                LDR     R1, =__bss_start__
                LDR     R2, =__bss_end__
LoopZI:         CMP     R1, R2
                STRLO   R0, [R1], #4
                BLO     LoopZI
		
# Enter the C code
goto_main:
                ADR     LR, __main_exit
                LDR     R0, =main
                BX      R0

__main_exit:    B       __main_exit



        .size   _startup, . - _startup
        .endfunc


        .end
/*=========================================================*/
