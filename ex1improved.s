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
          
          // Set low drive strength for GPIO
          mov r3, #0x1 // load r3 with value 0x2 Lowering voltqge leds
         // mov r3, #0x2 // load r3 with value 0x2 higher voltage leds
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
    
          // Enabling the external interrupts on GPIO pins on PORT C.This will select PORT C as the trigger for the interrupt ﬂags.
          ldr r3, =0x22222222 // load r3 reg with the value of 0x22222222
          str r3, [r0, #GPIO_EXTIPSELL] // Write 0x22222222 to GPIO EXTIPSELL
    
          // setting the rising and the falling edge triggers  
          ldr r3, =0xFF // load r3 reg with value 0xFF
          str r3, [r0, #GPIO_EXTIFALL] // Set interrupt on 1->0 transition by writing 0xﬀ to GPIO EXTIFALL
          str r3, [r0, #GPIO_EXTIRISE] // Set interrupt on 0->1 transition by twriting 0xﬀ to GPIO EXTIRISE

          // Enable interrupt generation
          str r3, [r0, #GPIO_IEN] // by writing 0xﬀ to GPIO_IEN 
	      
	      // Enable interrupt handling	
          ldr r3, =0x802 // load r3 with value 0x802
          ldr r4, =ISER0 // load r4 with address of iser0
          str r3, [r4] // write the value 0x802 to iser0
          
          //Enable deep sleep mode
	      mov R3, #6 // load r3 red with value 6
	      ldr R4, =SCR // load address of SCR reg
	      str R3, [R4] // write 6 to SCR reg  
	      
	      //sleep and wait for interrupt
	      wfi // enter sleep mode.   
	      
	      
	
	/////////////////////////////////////////////////////////////////////////////
	//
  // GPIO handler
  // The CPU will jump here when there is a GPIO interrupt
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
gpio_handler: 
           
           ldr r3, [r0, #GPIO_IF] //read interrupt source
           str r3, [r0, #GPIO_IFC] //clear interrupt flag 
           
           //read input, process it and write to output
           ldr r3, [r2, #GPIO_DIN]     // read input button
           lsl r3, r3, #8              // left shift the read value
           str r3, [r1, #GPIO_DOUT] // write to output led
    
           bx lr
          
	      
	
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
dummy_handler:  
        
        b .  // do nothing

