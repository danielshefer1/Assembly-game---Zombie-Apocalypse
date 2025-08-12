
IDEAL
MODEL small
STACK 100h

segment zombie public
    include 'zombie.inc'
ends zombie

segment player public
    include 'player.inc'
ends player

segment bullet_seg public
    include 'bullet.inc'
ends bullet_seg

segment double_buffer public
    double db 320 * 200 dup (5)
ends double_buffer

DATASEG

    player_counter dw 1 
    bullet_counter dw 1
    zombie_counter dw 1

    player_x dw width_ / 2  
    player_y dw floor - player_height 
    player_look dw right 
    player_state dw 1 
    player_alive db 1 
    number_of_hearts dw 3
    round_num dw 1
    switch_round db 0

    gravity dw gravity_max


    bullet_x dw 0 
    bullet_y dw 0 
    bullet_active db 0 
    bullet_dir dw 0 
    
    
    
    zombie_x dw left_border + 5, left_border + 10 + zombie_width, left_border + 20 + zombie_width * 2
    dw right_border - zombie_width - 5, right_border - zombie_width * 2 - 10

    zombie_look dw 3 dup (right), 2 dup (left)
    zombie_alive db 5 dup (1)
    zombie_state dw 5 dup (4)
    zombie_speed dw 2
 
    Menu db 'Menu.bmp', 0
    map db 'map.bmp', 0
    death db 'death.bmp', 0
    round_1 db 'round1.bmp', 0
    round_2 db 'round2.bmp', 0
    round_3 db 'round3.bmp', 0
    round_4 db 'round4.bmp', 0
    round_5 db 'round5.bmp', 0
    lose db 'lose.bmp', 0
    win db 'win.bmp', 0
    info db 'info.bmp', 0

    player_counter_max equ 10000
    bullet_counter_max equ 1000
    zombie_counter_max equ 12000

    floor equ 191
    ceiling equ 3
    left_border equ 4
    right_border equ 313
    
    width_ equ 320
    height_ equ 200

    platform_high equ 98
    platform_low equ 106
    platform_left equ 36
    platform_right equ 266
    platform_height equ platform_low - platform_high
    platform_width equ platform_right - platform_left

    bullet_speed equ 5
    bullet_height equ 13
    bullet_width equ 20

    player_height equ 35
    player_width equ 27
    player_speed equ 15
    
    gravity_acc equ 6
    gravity_max equ 90
    DrawBack equ 42
    jump_height equ 5

    zombie_width equ 21
    zombie_height equ 35
    zombie_y equ floor - zombie_height

    heart_width equ 20
    heart_height equ 19
    heart_y equ ceiling + 5

    up equ 11h
    right equ 20h
    left equ 1Eh

    space_key equ 39h
    esc_key equ 1
    I equ 17h
    S equ 1Fh
 
    graphical equ [es:di]
    clock equ  [es:6Ch]

    time_of_break equ 20

CODESEG

include 'pr_feDB.asm'
include 'fc_DB.asm'
include 'jmp_proc.asm'

; full min game!!!!
; this function gets:
; this function's purpose is to excute the full min game
proc full_mini_game
    push bp
    mov bp, sp

    call enter_graphical

    push offset map
    call full_pic

    push [number_of_hearts]
    call print_hearts

mini_game_loop:
    ;--------- player precedure
    mov ax, [player_counter]
    dec ax
    mov [player_counter], ax
    cmp ax, 0
    jnz player_counter_cont
    call player_precedure
    mov [player_counter], player_counter_max
player_counter_cont:
    ;--------- player precedure

    ;--------- bullet procedure
    mov ax, [bullet_counter]
    dec ax
    mov [bullet_counter], ax
    cmp ax, 0
    jnz bullet_counter_cont
    cmp [bullet_active], 0
    jz bullet_counter_cont
    call bullet_procedure
    mov [bullet_counter], bullet_counter_max

bullet_counter_cont:
    ;--------- bullet procedure

    ;--------- zombie procedure
    mov ax, [zombie_counter]
    dec ax
    mov [zombie_counter], ax
    cmp ax, 0
    jnz zombie_counter_cont
    call zombie_procedure
    mov [zombie_counter], zombie_counter_max

zombie_counter_cont:
    ;--------- zombie procedure
    mov al, [player_alive]
    cmp al, 0
    jz mini_game_exit
    jmp mini_game_loop

mini_game_exit:

    pop bp
    ret 2
endp full_mini_game

proc death_screen

    call exit_graphical
    call enter_graphical

    push offset death
    call full_pic

    push time_of_break
    call delay

    call exit_graphical

    ret
endp death_screen


; this function returns nothing
; this function's purpose is to reset the game
proc reset
    mov [player_x], width_ / 2
    mov [player_y], floor - player_height
    mov [player_alive], 1
    mov [bullet_active], 0
    mov [bullet_x], 0
    mov [bullet_y], 0
    mov [zombie_counter], zombie_counter_max
    mov [player_counter], player_counter_max
    mov [bullet_counter], bullet_counter_max

    mov cx, 5
    mov di, offset zombie_alive
    mov si, offset zombie_state

reset_zombie_loop:
    mov al, 1
    mov dx, 4
    mov [di], al
    mov [si], dx

    inc di
    add si, 2
    loop reset_zombie_loop

    mov [zombie_x], left_border + 5
    mov [zombie_x + 2], left_border + 10 + zombie_width
    mov [zombie_x + 4], left_border + 20 + zombie_width * 2
    mov [zombie_x + 6], right_border - zombie_width - 5
    mov [zombie_x + 8], right_border - zombie_width * 2 - 10

    mov [zombie_look], right
    mov [zombie_look + 2], right
    mov [zombie_look + 4], right
    mov [zombie_look + 6], left
    mov [zombie_look + 8], left

    mov [gravity], gravity_max

    ret
endp reset

proc full_reset
    call reset
    mov ax, 1
    mov [word ptr round_num], ax
    mov al, 0
    mov [switch_round], 0
    ret
endp full_reset

start:
    mov ax, 0A000h
    mov es, ax
    mov ax, @data
    mov ds, ax

start_screen:
    call enter_graphical
    push offset Menu
    call full_pic
wait_for_input:
    in al, 64h
    cmp al, 10b
    jz wait_for_input

    in al, 60h
    cmp al, I
    jz info_show
    cmp al, esc_key
    jz start_screen
    cmp al, S
    jz full_game
    jmp wait_for_input

info_show:
    call enter_graphical
    push offset info
    call full_pic
    jmp wait_for_input

full_game:
    push [round_num]
    call print_round
    call reset

    push [number_of_hearts]
    call full_mini_game
    call reset

    mov ax, [number_of_hearts]
    dec ax
    mov [number_of_hearts], ax

    mov al, [switch_round]
    cmp al, 0
    jz died

    mov ax, [round_num]
    cmp ax, 6
    jz won


    mov ax, [zombie_speed]
    add ax, 2
    mov [zombie_speed], ax

    mov al, 0
    mov [switch_round], al
    jmp full_game

died:
    call death_screen

    mov ax, [number_of_hearts]
    cmp ax, 0
    jnz full_game

    call enter_graphical
    push offset lose
    call full_pic
    push time_of_break
    call delay
    jmp start_screen

won:
    call enter_graphical
    push offset win
    call full_pic
    push time_of_break
    call delay
    jmp start_screen

exit:
    mov ax, 4c00h
    int 21h
END start