	.text
	.global uart_init		; Finished
	.global gpio_btn_and_LED_init ; Finished
	.global output_character ; Finished
	.global read_character ; Finished
	.global read_string		; Finished
	.global output_string	; Finished
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED	; Finished
	.global read_tiva_push_button ; Finished
	.global division		; Finished
	.global multiplication	; Finished


	.global string2int
	.global int2string

U0FR: 	.equ 0x18	; UART0 Flag Register

;------------------------------------------------------------------------------------------------------
uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r0, #0xE618
	MOVT r0, #0x400F
	MOV r1, #1
	STR r1, [r0]

	MOV r0, #0xE608
	MOVT r0, #0x400F
	MOV r1, #1
	STR r1, [r0]

	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #0
	STR r1, [r0]


	MOV r0, #0xC024
	MOVT r0, #0x4000
	MOV r1, #8
	STR r1, [r0]

	MOV r0, #0xC028
	MOVT r0, #0x4000
	MOV r1, #44
	STR r1, [r0]

	MOV r0, #0xCFC8
	MOVT r0, #0x4000
	MOV r1, #0
	STR r1, [r0]

	MOV r0, #0xC02C
	MOVT r0, #0x4000
	MOV r1, #0x60
	STR r1, [r0]

	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #0x301
	STR r1, [r0]

	MOV r0, #0x451C
	MOVT r0, #0x4000
	LDR r2, [r0]
	MOV r1, #0x03
	ORR r1, r1, r2
	STR r1, [r0]

	MOV r0, #0x4420
	MOVT r0, #0x4000
	LDR r2, [r0]
	MOV r1, #0x03
	ORR r1, r1, r2
	STR r1, [r0]

	MOV r0, #0x452C
	MOVT r0, #0x4000
	LDR r2, [r0]
	MOV r1, #0x11
	ORR r1, r1, r2
	STR r1, [r0]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

gpio_btn_and_LED_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r0, #0xE000
	MOVT r0, #0x400F
	LDR r1, [r0, #0x608]
	ORR r1, r1, #0x20
	STR r1, [r0, #0x608];Clock Enable


 	MOV r0, #0x5000
 	MOVT r0, #0x4002	; Port F

 	LDR r1, [r0, #0x400] ; Config pin direction
 	BIC r1, r1, #0x10
 	ORR r1, r1, #0xE
 	STR r1, [r0, #0x400]

 	LDR r1, [r0, #0x51C] ; Config I/O DEN
 	ORR r1, r1, #0x1E
 	STR r1, [r0, #0x51C]

 	LDR r1, [r0, #0x510] ; Enable pull-up resistor
 	ORR r1, r1, #0x10
 	STR r1, [r0, #0x510]


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

output_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r4, #0xC000			; Loading UART Data Register Address in r4
	MOVT r4, #0x4000

output_character_loop:

	LDRB r5, [r4, #U0FR]	; Loading into r5 the Flag Register
	AND r5, r5, #0x20
	CMP r5, #32				; Flag Checking
	BEQ output_character_loop

	STRB r0, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

read_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r4, #0xC000
	MOVT r4, #0x4000		; Loading UART Mapped-Memory

read_poll_output_character:
	LDRB r5, [r4, #U0FR]
	AND r5, r5, #16
	CMP r5, #16
	BEQ read_poll_output_character
	LDRB r0, [r4]


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

read_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

         				; Your code is placed here

	MOV r4, r0
	MOV r12, #0			; Initializing the counter

read_string_loop:
	BL read_character	;


enter_check:
	CMP r0, #0xD		;
	BEQ read_string_exit;

range_check:

	CMP r0, #0x39
	BGT loop_back

	CMP r0, #0x30
	BLT loop_back

	STRB r0, [r4, r12]	;
	ADD r12, r12, #1

only_output:
	BL output_character ;

loop_back:

	B read_string_loop;

read_string_exit:

	MOV r0, #0x00
	STRB r0, [r4, r12]	;

	MOV r0, #0xD		;
	BL output_character	;

	MOV r0, #0xA		;
	BL output_character	;

	MOV r0, r4


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

output_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r12, #0			; Initialize the Counter to r12: To count up the [Offset]
						; being loaded into the output_character from the base address.

	MOV r11, r0			; Copies the base address that was passed into r0 to r1 to
						; save the address.

output_string_loop:
	LDRB r4, [r11, r12]
	CMP r4, #0x00		;
	BEQ output_string_exit;


	MOV r0, r4			;
	BL output_character	;
	ADD r12, r12, #1	;
	BNE output_string_loop;


output_string_exit:

	MOV r0, #0xD		;
	BL output_character	;

	MOV r0, #0xA		;
	BL output_character	;


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

read_from_push_btns:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r4, #0x7000
    MOVT r4, #0x4000

    	;read PF4 from GPIODATA
	LDR r5, [r4, #0x3FC]  	; data register offset
	AND r6, r5, #0x0F    	; mask PF4 (0000 1111)
	MOV r0, r6		; copy r6 into r0, r0 holds the decimal value of which buttons were pressed

          ; Your code is placed here

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

illuminate_LEDs:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	;port B address
	MOV r4, #0x5000
    MOVT r4, #0x4000

	AND r5, r0, #0x0F  ; mask to extract bit 0,1,2,3

	STR r5, [r4, #0x3FC] ;writes to the data register for port B

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

illuminate_RGB_LED:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

 	LSL r0, r0, #1

	MOV r1, #0x5000
 	MOVT r1, #0x4002
 	LDR r2, [r1, #0x3FC]

 	BIC r2, r2, #0xE
 	ORR r2, r2, r0

 	STR r2, [r1, #0x3FC]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

read_tiva_push_button:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r1, #0x5000
 	MOVT r1, #0x4002

 	LDR r2, [r1, #0x3FC]
	AND r2, r2, #0x10

	EOR r2, r2, #0x10
	LSR r2, r2, #4

	MOV r0, r2

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

division:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

	MOV r4, #16			; Initialize Counter (r4) to 16, so when we loop back, the counter can be 15
	MOV r2, #0			; Initialize Quotient (r2) to 0

	LSL r1, #15			; Logically Shift the Divisor (r1) by 15 places
	MOV r3, r0			; COPIES the remainder (r3) from the Dividend (r0)

LOOP_DIV:
	SUB r4, r4, #1		; Substract the counter
	SUB r3, r3, r1

	CMP r3, #0
	BLT NEGATIVE

	LSL r2, #1
	ORR r2, r2, #1
	LSR r1, #1

	CMP r4, #0
	BGT LOOP_DIV
	BLE STOP

NEGATIVE:
	ADD r3, r3, r1
	LSL r2, #1

	LSR r1, #1
	CMP r4, #0
	BGT LOOP_DIV
	BLE STOP

STOP:
	MOV r0, r3

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;------------------------------------------------------------------------------------------------------

multiplication:
	PUSH {r4-r12,lr}	; Spill registers to stack

          				; Your code is placed here

		MOV r2, #0

	CMP r1, #0
	BGT LOOP
	BLE MULT_STOP
				; Your code for the multiplication routine goes here.
LOOP:
	ADD r2, r2, r0
	SUB r1, r1, #1

	CMP r1, #0
	BGT LOOP

MULT_STOP:
	MOV r0, r2

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

;-------------------------------------------------------------------------------------------------------------

int2string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.
						; Your code for your int2string routine is placed here
	MOV r4, r0			; r0 holds base_addr of the string
						; r1 hold the value of the value of the integer


	MOV r5, r1
	MOV r12, #0			; Counter for the length of the String in base-10
	MOV r11, #3			; Counter for the Comma Function

i2s_set_counter:
	MOV r2, #10
	UDIV r5, r5, r2
	ADD r12, r12, #1

	CMP r11, #0
	BNE comma_check
	ADD r12, r12, #1

comma_check:
	SUB r11, r11, #1
	CMP r5, #0
	BNE i2s_set_counter

	MOV r0, #0x00
	STRB r0, [r4, r12]
	SUB r12, r12, #1	; Storing the NULL-Terminate Byte into the memory and Move the [OffSet] back by 1

	MOV r5, r1
	MOV r2, #10
	MOV r11, #3

i2s_store_process:
	CMP r12, #0
	BEQ i2s_store_exit

	CMP r11, #0
	BEQ i2s_store_comma

	UDIV r6, r5, r2
	MUL r6, r6, r2

	SUB r6, r5, r6
	ORR r0, r6, #0x30
	STRB r0, [r4, r12]
	SUB r12, r12, #1
	SUB r11, r11, #1

	UDIV r5, r5, r2

	B i2s_store_process

i2s_store_comma:
	MOV r11, #3
	MOV r0, #0x2C
	STRB r0, [r4, r12]
	SUB r12, r12, #1

	B i2s_store_process

i2s_store_exit:
	ORR r0, r5, #0x30
	STRB r0, [r4, r12]

i2s_exit:
	MOV r0, r4
						; No storing needed, TODO: store the string at all the label
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr

;---------------------------------------------------

string2int:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
						; that are used in your routine.  Include lr if this
						; routine calls another routine.

						; Your code for your string2int routine is placed here
	MOV r10, #10		; Initializing value for MUL
	MOV r5, #0			; Initializing the final integer value
	MOV r11, #0			; Initializing the counter r11

string2int_loop:

	LDRB r4, [r0, r11]	; Loading into r4 the values in ASCII value
	CMP r4, #0x00		;
	BEQ string2int_exit	;

	AND r4, r4, #0x0F	; Mask the value into integer digit

	ADD r11, r11, #1
	ADD r5, r5, r4
	MULT r5, r5, r10	;

	BNE string2int_loop

string2int_exit:
	UDIV r0, r5, r10

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
						; PUSH at the top of this routine from the stack.
	mov pc, lr


	.end
