	.data
	.global prompt
	.global mydata
	.global yllwpts
	.global bluepts
	.global totalatt

placeholder:.cstring " "
formfeed: 	.cstring "\f"
starter:	.cstring "Welcome to the \033[1;31mReflex Game\033[0m: \n      \033[4;32mPress Any Keys\033[0m to \033[32mStart the Game\033[0m"
moto:	 	.cstring "                   Living by the moto: 'It's not a \033[4;32mbug\033[0m, ma. It's a \033[4;32mfeature\033[0m'            "
howto: 		.cstring "\033[4;37mHow To Play\033[0m: \n\r 1) Wait for the LED to go Green or The UART to output GO. \n\r 2) Press the Spacebar or the SW1 on the Tiva. \n\r 3) The Result will be display on the Tiva or the UART\n\r4) Each Win worth 5 points (Why? Cuz I like the number 5)\n\r"
rules:		.cstring "\033[4;37mThings to Note\033[0m: \n\r1) \033[1;34m BLUE \033[0m is for the player using SW1 on the Tiva \n\r2) \033[1;33mYELLOW\033[0m is for the player using the Spacebar \n\r3) Once you press G, the LED on the Tiva will turn \033[1;32mGreen\033[0m and the Terminal will display \033[1;32mGO\033[0m\n\r 4) Press the Buttons too early can result in not earning any points \n\r\n\r"
ready:		.cstring "                            \033[4;33mPRESS G TO START THE GAME\033[0m                 "

pending:	.cstring "Pending..."
GO:			.cstring "\033[4;32mGO\033[0m"

pickprompt:	.cstring "Press: \n\r1: to Play Again\n\r2: to View the Score and Play Again\n\r3: to View the Score and End the Game"
bluescore: 	.cstring "\033[1;34mBlue\033[0m Player Score: "
ylwscore:	.cstring "\033[1;33mYELLOW\033[0m Player Score: "

blue_error_msg: .cstring "                        \033[1;34mBLUE\033[0m Player Press the Button Early\n\r\n\r"
yellow_error_msg: .cstring "                       \033[1;33mYELLOW\033[0m Player Press the Button Early\n\r\n\r"

blue_win_msg: .cstring "                                  \033[1;34mBLUE\033[0m Player Won\n\r\n\r"
yellow_win_msg: .cstring "                               \033[1;33mYELLOW\033[0m Player Won\n\r\n\r"


endprompt:	.cstring "Well Played, Here are the Scores:\n\r\n\r"
total_prompt: .cstring "Total Attempts: "
tie_prompt:	.cstring "It's a Tie"
bluewinner:	.cstring "And the Winner is: \033[1;34mBlue\033[0m"
yllwwinner: .cstring "And the Winner is: \033[1;33mYELLOW\033[0m"

yllwpts: .word	0x00
bluepts: .word	0x00
totalatt: .word 0x00

mydata:	.byte	0x00	; This is where you can store data.
						; The .byte assembler directive stores a byte
						; (initialized to 0x20 in this case) at the label
						; mydata.  Halfwords & Words can be stored using the
						; directives .half & .word


	.text
	.global read_character
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global simple_read_character	; read_character modified for interrupts
	.global output_character	; This is from your Lab #4 Library
	.global read_string		; This is from your Lab #4 Library
	.global output_string		; This is from your Lab #4 Library
	.global uart_init		; This is from your Lab #4 Library
	.global lab5

	.global string2int
	.global int2string
	.global illuminate_RGB_LED	; Finished

ptr_clear:		.word formfeed
ptr_to_holder:	.word placeholder
ptr_to_starter:		.word starter
ptr_to_moto:		.word moto
ptr_to_howto:		.word howto
ptr_to_rules:		.word rules
ptr_to_mydata:		.word mydata
ptr_to_ready:		.word ready

ptr_to_pending:		.word pending
ptr_to_go:			.word GO
ptr_b_msg:			.word blue_error_msg
ptr_y_msg:			.word yellow_error_msg

ptr_b_wmsg:			.word blue_win_msg
ptr_y_wmsg:			.word yellow_win_msg

ptr_to_bluescore:	.word bluescore
ptr_to_ylwscore:	.word ylwscore
ptr_to_pick_next:	.word pickprompt


ptr_to_bluepts:		.word bluepts
ptr_to_yllwpts:		.word yllwpts
ptr_to_totalatt:	.word totalatt

ptr_to_end:			.word endprompt
ptr_to_tie:			.word tie_prompt
ptr_to_bluewinner:	.word bluewinner
ptr_to_yllwwinner:		.word yllwwinner
ptr_to_totalprompt:		.word total_prompt

U0FR: 	.equ 0x18
lab5:				; This is your main routine which is called from
					; your C wrapper.
	PUSH {r4-r12,lr}   	; Preserve registers to adhere to the AAPCS
begin:
 	bl uart_init
	bl uart_interrupt_init
	bl gpio_interrupt_init

	; This is where you should implement a loop, waiting for the user to
	; indicate if they want to end the program.

	LDR r0, ptr_clear
	BL output_string

	LDR r1, ptr_to_mydata

	LDR r0, ptr_clear
	BL output_character

	LDR r0, ptr_to_starter
	BL output_string

	LDR r0, ptr_to_moto
	BL output_string		; Above are just outputting the prompt to the UART

poll_any_keys:
	LDRB r0, [r1]
	CMP r0, #0x00
	BEQ poll_any_keys		; Enter any keys to begin the program

;---------------------------------

	LDR r0, ptr_clear
	BL output_string

	LDR r0, ptr_to_howto
	BL output_string

	LDR r0, ptr_to_rules
	BL output_string		 ; Above are just outputting another (HowTo and Rules) prompt to the UART

get_ready:


	LDR r0, ptr_to_ready
	BL output_string		 ; Printing Press G to Start the Program

	MOV r0, #0x00
	STRB r0, [r1]			 ; Clearing the mydata in the memory

poll_G:

	LDR r1, ptr_to_mydata
	LDRB r0, [r1]
	CMP r0, #0x67
	BNE poll_G

	MOV r0, #0
	BL illuminate_RGB_LED

	LDR r1, ptr_to_totalatt
	LDR r0, [r1]
	ADD r0, r0, #1
	STR r0, [r1]

	LDR r0, ptr_clear		 ; Clearing the page for the next part
	BL output_string

	LDR r0, ptr_to_pending	 ; Message for Pending
	BL output_string


	MOV r0, #0x00
	LDR r1, ptr_to_mydata
	STRB r0, [r1]			 ; Clearing the mydata in the memory

	MOV r2, #0x5555
	MOVT r2, #0x0055		 ; Delay Timmer

timer:
	SUB r2, r2, #1
	LDRB r0, [r1]

	CMP r0, #0x20
	BEQ yellow_error			; This is where we are going to spot the player's early error
	CMP r0, #0xAA
	BEQ blue_error

	CMP r2, #0
	BNE timer

	LDR r0, ptr_to_go
	BL output_string

	MOV r0, #4
	BL illuminate_RGB_LED		; This is where the game start, and the players can press their buttons

game_poll:
	LDR r1, ptr_to_mydata
	LDRB r0, [r1]

	CMP r0, #0x20
	BEQ yellow_win
	CMP r0, #0xAA
	BEQ blue_win
	B game_poll					; This poll pretty much trynna read who input the button first


;----------------------------------------------------------------------
blue_error:
	LDR r1, ptr_to_mydata
	MOV r0, #0x00
	STRB r0, [r1]

	LDR r0, ptr_b_msg
	BL output_string

	MOV r0, #1
	BL illuminate_RGB_LED
	B pick_next

yellow_error:
	LDR r1, ptr_to_mydata
	MOV r0, #0x00
	STRB r0, [r1]

	LDR r0, ptr_y_msg
	BL output_string

	MOV r0, #1
	BL illuminate_RGB_LED
	B pick_next


blue_win:
	LDR r0, ptr_clear
	BL output_string

	LDR r1, ptr_to_mydata
	MOV r0, #0x00
	STRB r0, [r1]

	LDR r2, ptr_to_bluepts
	LDR r0, [r2]
	ADD r0, r0, #5
	STR r0, [r2]

	LDR r0, ptr_b_wmsg
	BL output_string

	MOV r0, #2
	BL illuminate_RGB_LED
	B pick_next

yellow_win:
	LDR r0, ptr_clear
	BL output_string

	LDR r1, ptr_to_mydata
	MOV r0, #0x00
	STRB r0, [r1]

	LDR r1, ptr_to_yllwpts
	LDR r0, [r1]
	ADD r0, r0, #5
	STR r0, [r1]

	LDR r0, ptr_y_wmsg
	BL output_string

	MOV r0, #5
	BL illuminate_RGB_LED
	B pick_next

pick_next:
	LDR r1, ptr_to_mydata
	LDRB r0, [r1]

	LDR r0, ptr_to_pick_next
	BL output_string

pick_next_poll:

	LDR r1, ptr_to_mydata
	LDRB r0, [r1]

	CMP r0, #0x31
	BEQ play_again

	CMP r0, #0x32
	BEQ score_play

	CMP r0, #0x33
	BEQ end_game

	B pick_next_poll

play_again:
	LDR r0, ptr_clear
	BL output_string
	B get_ready

score_play:

	LDR r0, ptr_clear
	BL output_string

	LDR r0, ptr_to_bluescore
	BL output_string

	LDR r1, ptr_to_bluepts
	LDR r1, [r1]

	LDR r0, ptr_to_holder
	BL int2string
	BL output_string

	LDR r0, ptr_to_ylwscore
	BL output_string

	LDR r1, ptr_to_yllwpts
	LDR r1, [r1]

	LDR r0, ptr_to_holder
	BL int2string
	BL output_string

	B get_ready

end_game:
	LDR r0, ptr_clear
	BL output_string

	LDR r0, ptr_to_end
	BL output_string

	MOV r0, #0
	BL illuminate_RGB_LED

	LDR r0, ptr_to_totalprompt
	BL output_string

	LDR r1, ptr_to_totalatt
	LDR r1, [r1]

	LDR r0, ptr_to_holder
	BL int2string
	BL output_string

	LDR r0, ptr_to_bluescore
	BL output_string

	LDR r1, ptr_to_bluepts
	LDR r1, [r1]

	LDR r0, ptr_to_holder
	BL int2string
	BL output_string

	LDR r0, ptr_to_ylwscore
	BL output_string

	LDR r1, ptr_to_yllwpts
	LDR r1, [r1]

	LDR r0, ptr_to_holder
	BL int2string
	BL output_string

	LDR r2, ptr_to_bluepts
	LDR r0, [r2]

	LDR r2, ptr_to_yllwpts
	LDR r1, [r2]


	CMP r0, r2
	BLT blue_game

	CMP r0, r2
	BEQ tie_game

	CMP r0,r2
	BGT yellow_game

tie_game:
	LDR r0, ptr_to_tie
	BL output_string
	B end

blue_game:
	LDR r0, ptr_to_bluewinner
	BL output_string
	B end

yellow_game:
	LDR r0, ptr_to_yllwwinner
	BL output_string
	B end

end:


	POP {r4-r12,lr}		; Restore registers to adhere to the AAPCS
	MOV pc, lr


;===================================================================================================

uart_interrupt_init:

	; Your code to initialize the UART0 interrupt goes here

	MOV r0, #0xC000
	MOVT r0, #0x4000
	LDR r1, [r0, #0x038] ; Loading the UART Interupt Mask Register into r1
	ORR r1, r1, #0x10	 ; Setting the RXIM bit
	STR r1, [r0, #0x038]

	MOV r0, #0xE000
	MOVT r0, #0xE000
	LDR r1, [r0, #0x100] ; Loading the Interupt 0-31 Set Enable Register
	ORR r1, r1, #0x20
	STR r1, [r0, #0x100]

	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.


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

 	LDR r1, [r0, #0x404]
	BIC r1, r1, #0x10
	STR r1, [r0, #0x404]  ; Setting Edge Sensitive

	LDR r1, [r0, #0x408]
	BIC r1, r1, #0x10
	STR r1, [r0, #0x404] ; Enable GIPIOEV Register to Control the Edge

	LDR r1, [r0, #0x40C]
	BIC r1, r1, #0x10
	STR r1, [r0, #0x40C] ; Decide the Edge, '0' for Falling Edge

	LDR r1, [r0, #0x410]
	ORR r1, r1, #0x10
	STR r1, [r0, #0x410] ; Interrupt Mask

	MOV r0, #0xE000
	MOVT r0, #0xE000		; Interrupt bit 30 to set GPIOF (Bit 30) to 1

	LDR r1, [r0, #0x100]
	MOV r2, #0x0000
	MOVT r2, #0x4000
	ORR r1, r1, r2
	STR r1, [r0, #0x100]

	MOV pc, lr


UART0_Handler:

 	PUSH {r4-r12}

	MOV r0, #0xC000
	MOVT r0, #0x4000

	LDR r1, [r0, #0x044]
	ORR r1, r1, #0x10
	STR r1, [r0, #0x044]

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

	LDR r0, [r0]
	MOV r4, #0x00FF
	AND r0, r0, r4
	LDR r1, ptr_to_mydata
	STRB r0, [r1]

	POP {r4-r12}

	BX lr       	; Return


Switch_Handler:

	; Your code for your Switch handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

 	PUSH {r4-r12}

	MOV r0, #0x5000
 	MOVT r0, #0x4002
 	LDR r1, [r0, #0x41C]	; Port F GPIOIC
 	ORR r1, r1, #0x10
 	STR r1, [r0, #0x41C]


	MOV r0, #0xAA
	LDR r1, ptr_to_mydata
	STR r0, [r1]

	POP {r4-r12}
	BX lr


Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.

	BX lr       	; Return


simple_read_character:

	MOV pc, lr	; Return

	.end
