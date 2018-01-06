;Jared Foulds

#define LCD_LIBONLY
.include "lcd.asm"


.cseg

	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16

;part of program which initilizes lcd and line pointers
startprogram:
;r25 and r24 are set and used to cause the up button to stop scrolling
;and for the down scrolling to start scrolling again
	clr r25
	clr r24
	call lcd_init			; call lcd_init to Initialize the LCD
	call lcd_clr
	call init_strings
	call init_pointer1
	call init_pointer2
	ldi r26, 0x20
	ldi r20, 0x20

;loop for each iteration for letters on LCD to move
lp:
	call clear_buffer1
	call clear_buffer2
	call fill_line1
	call fill_line2
	call display_buffers


	call move_pointers1
	call move_pointers2
	push r20
	mov r20, r26
	call delay
	pop r20
	jmp lp
;moves line pointer 1 one space msg2 each iteration
move_pointers1:

	push XH
	push XL
	push r16
	push ZH
	push ZL
;if r25 is one, up has been pressed, so we stop moving ptr1 to
;make it seem the LCD is stopped
	cpi r25, 0x01
	breq move1

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)

	ld ZL, X+
	ld ZH, X

;increment and load contents of Z to check if 0
	adiw Z, 1
	ld r16, Z

;if this is the end of msg1, reset l1ptr to beginning
;branch to reset1 to reinitilize l1ptr
	cpi r16, 0x00
	breq reset1

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)

	st X+, ZL
	st X, ZH

	jmp move1
;reinitlizes pointer 1
reset1:
	call init_pointer1
	jmp move1

move1:

	pop ZL
	pop ZH
	pop r16
	pop XL
	pop XH

	ret
;moves line pointer 2 one space msg2 each iteration
move_pointers2:

	push XH
	push XL
	push r16
	push ZH
	push ZL
;if r25 is one, up has been pressed, so we stop moving ptr2 to
;make it seem the LCD is stopped
	cpi r25, 0x01
	breq move2

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)

	ld ZL, X+
	ld ZH, X
;increment and load contents of Z to check if 0
	adiw Z, 1
	ld r16, Z

;if this is the end of msg2, reset l1ptr to beginning
;branch to reset2 to reinitilize lineptr2
	cpi r16, 0x00
	breq reset2

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)

	st X+, ZL
	st X, ZH

	jmp move2
;reinitilizes pointer 2
reset2:
	call init_pointer2
	jmp move2

move2:
	pop ZL
	pop ZH
	pop r16
	pop XL
	pop XH

	ret

;function uses lptr1 which points to msg1 and copies a letter of msg1 into
;line1 16 times and then ends with a 0
fill_line1:

	push r16
	push r17
	push XH
	push XL
	push YH
	push YL
	push ZH
	push ZL

	ldi YH, high(line1)
	ldi YL, low(line1)

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)

	ld ZL, X+
	ld ZH, X

	ldi r17, 0x10
;loop that fills up line (r17 used so it goes through 16 times)
fill1:
	ld r16, Z+

;if r16 contains 0, then end of msg1 so reset back to beginning
	cpi r16, 0
	breq restart1
;if r17 is 0, done looping
	cpi r17, 0x00
	breq finished1

	st Y+, r16
	dec r17
	jmp fill1

;reset Z to beginning of msg1
restart1:

	ldi ZH, high(msg1)
	ldi ZL, low(msg1)

	jmp fill1

finished1:
; set last letter of line1 to 0
	ldi YH, high(line1)
	ldi YL, low(line1)
	adiw YH:YL, 0x10
	ldi r16, 0x0
	st Y, r16

	pop ZL
	pop ZH
	pop YL
	pop YH
	pop XL
	pop XH
	pop r17
	pop r16

	ret

;function uses lptr2 which points to msg2 and copies a letter of msg1 into
;line1 16 times and then ends with a 0
fill_line2:

	push r16
	push r17
	push XH
	push XL
	push YH
	push YL
	push ZH
	push ZL

	ldi YH, high(line2)
	ldi YL, low(line2)

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)

	ld ZL, X+
	ld ZH, X

	ldi r17, 0x10
;loop that fills up line (r17 used so it goes through 16 times)
fill2:
	ld r16, Z+
;if r16 contains 0, then end of msg1 so reset back to beginning
	cpi r16, 0
	breq restart2
;if r17 is 0, done looping
	cpi r17, 0x00
	breq finished2

	st Y+, r16
	dec r17
	jmp fill2

finished2:
; set last letter of line1 to 0
	ldi YH, high(line2)
	ldi YL, low(line2)
	adiw YH:YL, 0x10
	ldi r16, 0x0
	st Y, r16

	pop ZL
	pop ZH
	pop YL
	pop YH
	pop XL
	pop XH
	pop r17
	pop r16

	ret
;reset Z to beginning of msg2
restart2:

	ldi ZH, high(msg2)
	ldi ZL, low(msg2)

	jmp fill2
;essentially fills line1 with 0's
clear_buffer1:

	push r16
	push r17
	push XH
	push XL
	push YH
	push YL
	push ZH
	push ZL

	ldi YH, high(line1)
	ldi YL, low(line1)

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)

	ld ZL, X+
	ld ZH, X

	ldi r17, 0x10
	ldi r16, 0x00

blank1:

  cpi r17, 0x00
  breq doneblank1
	st Y+, r16
	dec r17
	jmp blank1

doneblank1:

  st Y, r16
	pop ZL
	pop ZH
	pop YL
	pop YH
	pop XL
	pop XH
	pop r17
	pop r16

	ret
;essentially fills line2 with 0's
clear_buffer2:

	push r16
	push r17
	push XH
	push XL
	push YH
	push YL
	push ZH
	push ZL

	ldi YH, high(line2)
	ldi YL, low(line2)

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)

	ld ZL, X+
	ld ZH, X

	ldi r17, 0x10
	ldi r16, 0x00

blank2:

	cpi r17, 0x00
    breq doneblank2
	st Y+, r16
	dec r17
	jmp blank2

doneblank2:

	st Y, r16

	pop ZL
	pop ZH
	pop YL
	pop YH
	pop XL
	pop XH
	pop r17
	pop r16

	ret
;provided code, displays line1 and line2 on LCD
display_buffers:

	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16

	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16
	ret

init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

init_pointer1:

;initializes l1ptr to point to beginning of msg1
	push XH
	push XL
	push r16
	push r17

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)

	ldi r16, high(msg1)
	ldi r17, low(msg1)

	st X+, r17
	st X, r16

	pop r17
	pop r16
	pop XL
	pop XH

	ret

init_pointer2:

;;initializes l2ptr to point to beginning of msg2

	push XH
	push XL
	push r16
	push r17

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)

	ldi r16, high(msg2)
	ldi r17, low(msg2)

	st X+, r17
	st X, r16

	pop r17
	pop r16
	pop XL
	pop XH

	ret

;delay function which is defaulted to delay 1/2 second
delay:
del1:	nop
		call check_button
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1
		ret


; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
;
check_button:
		push r16
		push r17

		; start a2d
		lds	r16, ADCSRA
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		clr r24
		cpi r17, 3			;  if > 0x3E8, no button pressed
		brne bsk1		    ;
		cpi r16, 0xE8		;
		brsh bsk_done		;
bsk1:	tst r17				; if ADCH is 0, might be right or up
		brne bsk2			;
		cpi r16, 0x32		; < 0x32 is right
		brsh bsk3
		ldi r24, 0x01		; right button

							;this section of code increases the scroll
		push r16			;speed if right is pressed
		ldi r16, 0x06
		sub r26, r16
		cpi r26, 0x11
		brlt minimum
		jmp endleft
minimum:
		ldi r26, 0x10
endleft:
		pop r16


		rjmp bsk_done
bsk3:	cpi r16, 0xC3
		brsh bsk4
		ldi r24, 0x02		; up
		ldi r25, 0x01        ;up has been pressed, set r25 to 1 so it will skip moving pointers and appeared stop
		rjmp bsk_done
bsk4:	ldi r24, 0x04		; down (can happen in two tests)
		clr r25             ;clear r25 so display is no longer 1 (stopped)
		rjmp bsk_done
bsk2:	cpi r17, 0x01		; could be up,down, left or select
		brne bsk5
		cpi r16, 0x7c		;
		brsh bsk7
		ldi r24, 0x04		; other possiblity for down
		clr r25             ;clear r25 so display is no longer 1 (stopped), so it will now move pointers
		rjmp bsk_done
bsk7:	ldi r24, 0x08		; left


		push r16
		ldi r16, 0x06
		add r26, r16
		cpi r26, 0x40
		brge maximum
		jmp endright
maximum:
		ldi r26, 0x40
endright:
		pop r16

		rjmp bsk_done
bsk5:	cpi r17, 0x02
		brne bsk6
		cpi r16, 0x2b
		brsh bsk6
		ldi r24, 0x08
		rjmp bsk_done
bsk6:	ldi r24, 0x10
bsk_done:
		pop r17
		pop r16
		ret


; These are in program memory
msg1_p: .db "This is the message on the first line. Here it goes.", 0
msg2_p: .db "--- buy --- more --- pop --- buy ", 0

.dseg

msg1: .byte 200
msg2: .byte 200

line1: .byte 17
line2: .byte 17

l1ptr: .byte 2
l2ptr: .byte 2
