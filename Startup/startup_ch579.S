/* startup_ch579.S for GNU toolchain.
 * Converted from the MDK-ARM startup file startup_ARMCM0.s of the WCH EVT.
 * Notice of the original file:
/ ************************************************************************** // **
 * @file     startup_ARMCM0.s
 * @brief    CMSIS Core Device Startup File for
 *           ARMCM0 Device Series
 * @version  V1.08
 * @date     23. November 2012
 *
 * @note
 *
 ****************************************************************************** /
/ * Copyright (c) 2011 - 2012 ARM LIMITED

   All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
   - Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
   - Neither the name of ARM nor the names of its contributors may be used
     to endorse or promote products derived from this software without
     specific prior written permission.
   *
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
   ---------------------------------------------------------------------------* /
 */

    .syntax unified
    .cpu cortex-m0
    .thumb

/*******************************************************************************
 * Vector Table Mapped to Address 0 at Reset
 *******************************************************************************/
    .section .isr_vector, "a", %progbits
    .align 2
    .global __Vectors
    .type __Vectors, %object
__Vectors:
    .word _eusrstack
    .word Reset_Handler
    .word NMI_Handler
    .word HardFault_Handler
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word SVC_Handler
    .word 0
    .word 0
    .word PendSV_Handler
    .word SysTick_Handler
    .word TMR0_IRQHandler
    .word GPIO_IRQHandler
    .word SLAVE_IRQHandler
    .word SPI0_IRQHandler
    .word BB_IRQHandler
    .word LLE_IRQHandler
    .word USB_IRQHandler
    .word ETH_IRQHandler
    .word TMR1_IRQHandler
    .word TMR2_IRQHandler
    .word UART0_IRQHandler
    .word UART1_IRQHandler
    .word RTC_IRQHandler
    .word ADC_IRQHandler
    .word SPI1_IRQHandler
    .word LED_IRQHandler
    .word TMR3_IRQHandler
    .word UART2_IRQHandler
    .word UART3_IRQHandler
    .word WDT_IRQHandler
    .size __Vectors, . - __Vectors

/*******************************************************************************
 * Reset Handler
 *******************************************************************************/
    .section .text.Reset_Handler, "ax", %progbits
    .weak Reset_Handler
    .type Reset_Handler, %function
Reset_Handler:
    ldr r0, =_eusrstack
    mov sp, r0
/* Load data section from flash to RAM */
    ldr r0, =_data_lma
    ldr r1, =_data_vma
    ldr r2, =_edata
    b 2f
1:
    ldr r3, [r0]
    str r3, [r1]
    adds r0, r0, #4
    adds r1, r1, #4
2:
    cmp r1, r2
    blo 1b
/* Clear bss section */
    ldr r0, =_sbss
    ldr r1, =_ebss
    movs r2, #0
    b 2f
1:
    str r2, [r0]
    adds r0, r0, #4
2:
    cmp r0, r1
    blo 1b

#if defined(__PIO_CPP_SUPPORT__)
    /* register fini (destructor array) call at exit if wanted (bloats up RAM+Flash) */
    #if defined(__PIO_CPP_CALL_FINI__)
    ldr r0, =__libc_fini_array
    bl atexit
    #endif
    /* call into C++ constructors now */
    bl __libc_init_array
#endif
    bl SystemInit
#if defined(__PIO_BUILD_RT_THREAD__)
    /* RT-Thread has special entry point, it will call our main() later */
    bl entry
#else
    bl main
#endif
    b .
    .size Reset_Handler, . - Reset_Handler

/*******************************************************************************
 * Dummy Exception Handlers (infinite loops which can be modified)
 *******************************************************************************/
    .section .text.Default_Handler, "ax", %progbits
    .weak Default_Handler
    .type Default_Handler, %function
Default_Handler:
    b .
    .size Default_Handler, . - Default_Handler

    .weak NMI_Handler
    .thumb_set NMI_Handler, Default_Handler
    .weak HardFault_Handler
    .thumb_set HardFault_Handler, Default_Handler
    .weak SVC_Handler
    .thumb_set SVC_Handler, Default_Handler
    .weak PendSV_Handler
    .thumb_set PendSV_Handler, Default_Handler
    .weak SysTick_Handler
    .thumb_set SysTick_Handler, Default_Handler
    .weak TMR0_IRQHandler
    .thumb_set TMR0_IRQHandler, Default_Handler
    .weak GPIO_IRQHandler
    .thumb_set GPIO_IRQHandler, Default_Handler
    .weak SLAVE_IRQHandler
    .thumb_set SLAVE_IRQHandler, Default_Handler
    .weak SPI0_IRQHandler
    .thumb_set SPI0_IRQHandler, Default_Handler
    .weak BB_IRQHandler
    .thumb_set BB_IRQHandler, Default_Handler
    .weak LLE_IRQHandler
    .thumb_set LLE_IRQHandler, Default_Handler
    .weak USB_IRQHandler
    .thumb_set USB_IRQHandler, Default_Handler
    .weak ETH_IRQHandler
    .thumb_set ETH_IRQHandler, Default_Handler
    .weak TMR1_IRQHandler
    .thumb_set TMR1_IRQHandler, Default_Handler
    .weak TMR2_IRQHandler
    .thumb_set TMR2_IRQHandler, Default_Handler
    .weak UART0_IRQHandler
    .thumb_set UART0_IRQHandler, Default_Handler
    .weak UART1_IRQHandler
    .thumb_set UART1_IRQHandler, Default_Handler
    .weak RTC_IRQHandler
    .thumb_set RTC_IRQHandler, Default_Handler
    .weak ADC_IRQHandler
    .thumb_set ADC_IRQHandler, Default_Handler
    .weak SPI1_IRQHandler
    .thumb_set SPI1_IRQHandler, Default_Handler
    .weak LED_IRQHandler
    .thumb_set LED_IRQHandler, Default_Handler
    .weak TMR3_IRQHandler
    .thumb_set TMR3_IRQHandler, Default_Handler
    .weak UART2_IRQHandler
    .thumb_set UART2_IRQHandler, Default_Handler
    .weak UART3_IRQHandler
    .thumb_set UART3_IRQHandler, Default_Handler
    .weak WDT_IRQHandler
    .thumb_set WDT_IRQHandler, Default_Handler
