processor 16F88

; PIC16F88 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTRC oscillator; port I/O function on both RA6/OSC2/CLKO pin and RA7/OSC1/CLKI pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable bit (BOR enabled)
  CONFIG  LVP = OFF              ; Low-Voltage Programming Enable bit (RB3/PGM pin has PGM function, Low-Voltage Programming enabled)
  CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Code protection off)
  CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off)
  CONFIG  CCPMX = RB0           ; CCP1 Pin Selection bit (CCP1 function on RB0)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

; CONFIG2
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal External Switchover mode enabled)

// config statements should precede project file includes.
#include <xc.inc>

FLAGS equ 0x20
TIMER_COUNTER equ 0x21
LAST_INPUT equ 0x22
NEW_INPUT equ 0x23
TEXT_POINTER equ 0x24
SCRATCHPAD equ 0x25

; Program
PSECT resetVect, class=CODE, delta=2
resetVect:
    PAGESEL main
    goto main
    
PSECT interruptVect, class=CODE, delta=2
interruptVector:
    btfsc INTCON, 2
    goto interruptVector_TM0OVF
interruptVector_TM0OVF:
    BANKSEL TIMER_COUNTER
    decfsz TIMER_COUNTER
    goto interruptVector_TM0OVF_end
    movlw 8
    movwf TIMER_COUNTER
    BANKSEL FLAGS
    bsf FLAGS, 0
    nop
interruptVector_TM0OVF_end:
    bcf INTCON, 2
    retfie

PSECT code, delta=2
main:
    BANKSEL OSCCON
    movlw 0b01100010
    movwf OSCCON
    ; At startup, all ports are inputs.
    ; Set Port B to all outputs.
    BANKSEL FLAGS
    movlw 0x00
    movwf FLAGS
    BANKSEL LAST_INPUT
    movwf LAST_INPUT
    BANKSEL TEXT_POINTER
    movwf TEXT_POINTER
    
    BANKSEL ANSEL ; Select Bank of ANSEL
    movlw 0x00 ; Configure all pins
    movwf ANSEL ; as digital inputs
    
    BANKSEL TRISA
    movlw 0b00000011
    movWf TRISA
    
    BANKSEL TRISB
    movlw 0b00000000
    movwf TRISB ; copy w to TRIS B itself
    
    BANKSEL PORTB
    movlw 0b00000000 ; w := binary 00000000
    movwf PORTB ; copy w to port B control reg

    BANKSEL OPTION_REG
    movlw 0b10000111	; TMR0 prescaller 1:256
    movwf OPTION_REG
    BANKSEL TIMER_COUNTER
    movlw 8
    movwf TIMER_COUNTER
    BANKSEL INTCON
    bsf INTCON, 5	; Enable TMR0 interrupt
    bcf INTCON, 2	; Clear TMR0OVF flag
    bsf INTCON, 7 ;enable interrupts

main_loop:
    BANKSEL FLAGS
    btfss FLAGS, 0
    goto main_loop
    BANKSEL PORTA
    movf PORTA, W
    andlw 0x03
    BANKSEL NEW_INPUT
    movwf NEW_INPUT
    BANKSEL LAST_INPUT
    subwf LAST_INPUT, W
    btfsc STATUS, 2
    goto main_check_clk
    ; Input changed
    movlw 0x00
    BANKSEL TEXT_POINTER
    movwf TEXT_POINTER	    ; Zero out text pointer
    BANKSEL PORTB
    movwf PORTB	    ; Turn off leds
    BANKSEL TIMER_COUNTER
    movlw 8
    movwf TIMER_COUNTER
main_set_last_input:
    BANKSEL NEW_INPUT
    movf NEW_INPUT, W
    BANKSEL LAST_INPUT
    movwf LAST_INPUT
    goto main_end   ; Initially after status change do nothing
main_check_clk:    
    BANKSEL PORTB
    btfsc PORTB, 5
    goto main_clear_clk
main_is_input0:
    movf NEW_INPUT, W
    sublw 0x00
    btfsc STATUS, 2
    goto main_set_new_char
    goto main_is_input1
main_is_input1:
    movf NEW_INPUT, W
    sublw 0x01
    btfsc STATUS, 2
    goto main_set_new_char
    goto main_is_input2
main_is_input2:
    movf NEW_INPUT, W
    sublw 0x02
    btfsc STATUS, 2
    goto main_set_new_char
    goto main_is_input3
main_is_input3:
    ; No other options left - just update
    movf NEW_INPUT, W
main_set_new_char:
    call get_next_character
    BANKSEL SCRATCHPAD
    movwf SCRATCHPAD
    sublw 0x00
    btfsc STATUS, 2 ; Z
    goto main_set_new_char_zero_case
    BANKSEL TEXT_POINTER
    incf TEXT_POINTER, F
    goto main_set_new_char_transfer 
main_set_new_char_zero_case:
    movlw 0x00
    BANKSEL TEXT_POINTER
    movwf TEXT_POINTER
main_set_new_char_transfer:
    BANKSEL SCRATCHPAD
    movf SCRATCHPAD, W
    andlw 0x1F	; Mask five bits only
    movwf PORTB
    bsf PORTB, 5
    goto main_end
main_clear_clk:
    bcf PORTB, 5
main_end:
    bcf FLAGS, 0
    goto main_loop
    
get_next_character:
    BANKSEL LAST_INPUT
    movf LAST_INPUT, W
    sublw 0x00
    btfss STATUS, 2
    goto get_next_character_input1
    ;addlw LOW(text0_data)
    ;movwf SCRATCHPAD
    ;movlw HIGH(text0_data)
    ;goto get_next_character_perform
    movlw LOW(text0_data)
    addwf TEXT_POINTER, W
    movwf SCRATCHPAD
    movlw HIGH(text0_data)
    btfsc STATUS, 0 ;C
    movwf PCLATH
    movf SCRATCHPAD, W
    movwf PCL
    
get_next_character_input1:
    movf LAST_INPUT, W
    sublw 0x01
    btfss STATUS, 2
    goto get_next_character_input2
    ;addlw LOW(text1_data)
    ;movwf SCRATCHPAD
    ;movlw HIGH(text1_data)
    ;goto get_next_character_perform
    movlw LOW(text1_data)
    addwf TEXT_POINTER, W
    movwf SCRATCHPAD
    movlw HIGH(text1_data)
    btfsc STATUS, 0 ;C
    movwf PCLATH
    movf SCRATCHPAD, W
    movwf PCL
get_next_character_input2:
    movf LAST_INPUT, W
    sublw 0x02
    btfss STATUS, 2
    goto get_next_character_set_text3
    ;addlw LOW(text2_data)
    ;movwf SCRATCHPAD
    ;movlw HIGH(text2_data)
    ;goto get_next_character_perform
    movlw LOW(text2_data)
    addwf TEXT_POINTER, W
    movwf SCRATCHPAD
    movlw HIGH(text2_data)
    btfsc STATUS, 0 ;C
    movwf PCLATH
    movf SCRATCHPAD, W
    movwf PCL
get_next_character_set_text3:
    movlw LOW(text3_data)
    addwf TEXT_POINTER, W
    movwf SCRATCHPAD
    movlw HIGH(text3_data)
    btfsc STATUS, 0 ;C
    movwf PCLATH
    movf SCRATCHPAD, W
    movwf PCL
    
#include "text.inc"
    
    end resetVect ; program ends here


