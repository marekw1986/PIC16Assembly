processor 16F88

; PIC16F88 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = EXTRCCLK       ; Oscillator Selection bits (EXTRC oscillator; CLKO function on RA6/OSC2/CLKO)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is MCLR)
  CONFIG  BOREN = ON            ; Brown-out Reset Enable bit (BOR enabled)
  CONFIG  LVP = ON              ; Low-Voltage Programming Enable bit (RB3/PGM pin has PGM function, Low-Voltage Programming enabled)
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
SCRATCHPAD0 equ 0x24

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
    decfsz TIMER_COUNTER
    goto interruptVector_TM0OVF_end
    movlw 8
    movwf TIMER_COUNTER
    bsf FLAGS, 0
    nop
interruptVector_TM0OVF_end:
    bcf INTCON, 2
    retfie

PSECT code, delta=2
main:
    ; At startup, all ports are inputs.
    ; Set Port B to all outputs.
    BANKSEL FLAGS
    movlw 0x00
    movwf FLAGS
    BANKSEL LAST_INPUT
    movwf LAST_INPUT
    
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
    btfss FLAGS, 0
    goto main_loop
    BANKSEL PORTA
    movf PORTA, W
    andlw 0x03
    BANKSEL NEW_INPUT
    movwf NEW_INPUT
    subwf LAST_INPUT, W
    btfsc STATUS, 2
    goto main_update_output
    BANKSEL SCRATCHPAD0
main_is_input0:
    movf NEW_INPUT, W
    sublw 0x00
    btfsc STATUS, 2
    goto main_set_last_input
    goto main_is_input1
main_is_input1:
    movf NEW_INPUT, W
    sublw 0x01
    btfsc STATUS, 2
    goto main_set_last_input
    goto main_is_input2
main_is_input2:
    movf NEW_INPUT, W
    sublw 0x02
    btfsc STATUS, 2
    goto main_set_last_input
    goto main_is_input3
main_is_input3:
    movf NEW_INPUT, W
    sublw 0x03
    btfsc STATUS, 2
main_set_last_input:
    movf NEW_INPUT, W
    BANKSEL NEW_INPUT
    movf NEW_INPUT, W
    BANKSEL LAST_INPUT
    movwf LAST_INPUT
main_update_output:    
    BANKSEL PORTB
    btfsc PORTB, 5
    goto main_clear_clk
    goto main_set_new_char
main_set_new_char:
    movlw 0xFF
    movwf PORTB
    goto main_end
main_clear_clk:
    bcf PORTB, 5
main_end:
    bcf FLAGS, 0
    goto main_loop
    
    
ascii_to_baudot:
    return
    
    db "Tekst 1"
    db "Tekst 2"
    db "Tekst 3"
    db "Tekst 4"
    
    end resetVect ; program ends here


