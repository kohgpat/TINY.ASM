; Approximate PI
; --------------
;
; by Markus Siemens <markus@es-netze.de>

; Define constants
    $MAX_RAND_SQUARE   = 144    ; (RAND_MAX/2) ** 2

    ; Subroutines
    $return         = [_]   ; Return value
    $jump_back      = [_]   ; Jump back address
    $arg0           = [_]
    $arg1           = [_]
    $arg2           = [_]

    ; Approximate PI
    $pi_iterations   = 100  ; Iteration count
    $pi_rand_divider = 2    ; Divide the RANDOM numbers by this, so we don't overflow
    $pi_counter     = [_]   ; Loop counter
    $pi_rand0       = [_]   ; First RANDOM number
    $pi_rand1       = [_]   ; Second RANDOM number
    $pi_rand_sum    = [_]
    $pi_inside      = [_]   ; Number of dots inside the circle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
    MOV $pi_counter     0               ; Initialize memory

    main_loop:                          ; The main loop
                                        ; Loop break condition: $pi_counter == $pi_iterations
    JEQ     :print      $pi_counter     $pi_iterations
    APRINT  '.'

    MOV     $pi_rand_sum 0              ; Reset sum of rand0^2 and rand1^2

                                        ; Get random numbers
    RANDOM  $pi_rand0
    MOV     $arg0       $pi_rand0       ; Divide by 2, so adding the squares doesn't overflow
    MOV     $arg1       $pi_rand_divider
    MOV     $jump_back  :pi_jb_div0
    JMP     :math_divide
    pi_jb_div0:
    MOV     $pi_rand0   $return

    RANDOM  $pi_rand1
    MOV     $arg0       $pi_rand1       ; Divide by 2, so adding the squares doesn't overflow
    MOV     $arg1       $pi_rand_divider
    MOV     $jump_back  :pi_jb_div1
    JMP     :math_divide
    pi_jb_div1:
    MOV     $pi_rand1   $return

                                        ; rand0 * rand0
    MOV     $arg0       $pi_rand0       ; Prepare arguments and jump back
    MOV     $arg1       $pi_rand0
    MOV     $jump_back :pi_jb_rand0

    JMP     :math_multiply              ; Call subroutine and retrive result
    pi_jb_rand0:
    MOV     $pi_rand0   $return

                                        ; rand1 * rand1
    MOV     $arg0       $pi_rand1       ; Prepare arguments and jump back
    MOV     $arg1       $pi_rand1
    MOV     $jump_back  :pi_jb_rand1

    JMP     :math_multiply              ; Call subroutine and retrive result
    pi_jb_rand1:
    MOV     $pi_rand1   $return

    ADD     $pi_rand_sum    $pi_rand0   ; Add $pi_rand0^2 and $pi_rand1^2
    ADD     $pi_rand_sum    $pi_rand1

                                        ; If $pi_rand_sum > $MAX_RAND_SQUARE, GOTO FI
    JGT     :pi_fi_indot    $pi_rand_sum    $MAX_RAND_SQUARE
    ADD     $pi_inside      1

    pi_fi_indot:

                                        ; If pi_counter_0 == 255
    ADD     $pi_counter     1
    JMP     :main_loop                 ; Next loop iteration

print:                                  ; SUBROUTINE
                                        ; Calculate PI using 'inside / total * 4' as float
    APRINT '\n'
    DPRINT  $pi_inside
    APRINT  '/'
    DPRINT  $pi_iterations
    APRINT  '*'
    DPRINT  4

    JMP     :end


end:
                                        ; SUBROUTINE
                                        ; End the programm execution
    HALT

#include lib/math/multiply.asm
#include lib/math/divide.asm