        .syntax unified
	
	      .include "efm32gg.s"

	/////////////////////////////////////////////////////////////////////////////
	//
  // Exception vector table
  // This table contains addresses for all exception handlers
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .section .vectors
	
	      .long   stack_top               /* Top of Stack                 */
	      .long   _reset                  /* Reset Handler                */
	      .long   dummy_handler           /* NMI Handler                  */
	      .long   dummy_handler           /* Hard Fault Handler           */
	      .long   dummy_handler           /* MPU Fault Handler            */
	      .long   dummy_handler           /* Bus Fault Handler            */
	      .long   dummy_handler           /* Usage Fault Handler          */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* SVCall Handler               */
	      .long   dummy_handler           /* Debug Monitor Handler        */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* PendSV Handler               */
	      .long   dummy_handler           /* SysTick Handler              */

	      /* External Interrupts */
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO even handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO odd handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler

	      .section .text

	/////////////////////////////////////////////////////////////////////////////
	//
	// Reset handler
  // The CPU will start executing here after a reset
	//
	/////////////////////////////////////////////////////////////////////////////

	      .globl  _reset
	      .type   _reset, %function
        .thumb_func
_reset: 
          
          //Set CMU clock for GPIO
          ldr r0, =CMU_BASE //load base address of CMU
          ldr r1, [r0, #CMU_HFPERCLKEN0] // load current value of CMU HFPERCLKEN0 register
          mov r2, #1 // load reg r2 with value 1 or lsb 1
          lsl r2,r2, #CMU_HFPERCLKEN0_GPIO // set 13th bit of r2 reg
          orr r1,r1,r2 // set 13th bit of r1 reg
          str r1, [r0, #CMU_HFPERCLKEN0] // set 13th bit of CMU HFPERCLKEN0 register
          
          // loading some freq used base addresses
          ldr r0, =GPIO_BASE    // load r0 with base address of GPIO
          ldr r1, =GPIO_PA_BASE // load r1 with base address of GPIO_PA
          ldr r2, =GPIO_PC_BASE // load r2 with base address of GPIO_PC
          
          // Set high drive strength for GPIO
          mov r3, #0x2 // load r3 with value 0x2
          str r3, [r1, #GPIO_CTRL] // writing 0x2 to GPIO_PA_CTRL reg
          
          // Set GPIO pins 8-15 to output (leds)
          ldr r3, =0x55555555 // load reg r3 with value of 0x55555555
          str r3, [r1, #GPIO_MODEH] // write 0x55555555 to GPIO_PA_MODEH reg 
          
          // Set GPIO pins 0-7 to input (buttons)
	      ldr r3, =0x33333333 // load reg r3 with value 0x33333333
          str r3, [r2, #GPIO_MODEL] // write value 0x33333333 to GPIO_PC_MODEL 
          
          // Enable GPIO internal pull-up
          ldr r3, =0xFF // load reg r3 with value 0xFF
          str r3, [r2, #GPIO_DOUT] // write this 0xFF value to  GPIO_PC_DOUT 
    
          // lighting corresponding led to buttons
          loop:
          ldr r3, [r2, #GPIO_DIN]     // reading button num from GPIO_PC_DIN
          lsl r3, r3, #8              // left shift the read button num
          str r3, [r1, #GPIO_DOUT]    // write back to GPIO_PA_DOUT to light corresponding led
          b loop
    
	      b .  // do nothing
	
	/////////////////////////////////////////////////////////////////////////////
	//
  // GPIO handler
  // The CPU will jump here when there is a GPIO interrupt
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
gpio_handler:  
          
	      b .  // do nothing
	
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
dummy_handler:  
        
        b .  // do nothing

