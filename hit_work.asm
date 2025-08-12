
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

DATASEG

    player_counter dw 1 
    bullet_counter dw 1
    zombie_counter dw 1

    player_x dw width_ / 2  
    player_y dw floor - player_height 
    player_look dw right 
    player_state dw 1 
    player_alive db 1 

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
    player_speed equ 10
    
    gravity_acc equ 6
    gravity_max equ 90
    DrawBack equ 42
    jump_height equ 5

    zombie_width equ 21
    zombie_height equ 35
    zombie_y equ floor - zombie_height

    up equ 11h
    right equ 20h
    left equ 1Eh

    space_key equ 39h
    esc_key equ 1
    I equ 17h
    S equ 1Fh
    
    graphical equ [es:di]
    clock equ  [es:6Ch]



CODESEG

include 'pr_fe.asm'
include 'fc_works.asm'
include 'jmp_proc.asm'

; this function gets:
; [word ptr bp + 4] = offset zombie_x
; [word ptr bp + 6] = bullet_x
; [word ptr bp + 8] = bullet_y
; [word ptr bp + 10] = offset zombie_alive
; [word ptr bp + 12] = offset bullet_active
; this function returns nothing
; this function checks if the bullet hit the zombies
proc bullet_hit
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, [word ptr bp + 10] ; offset zombie_alive
    mov si, [word ptr bp + 4] ; offset zombie_x

    mov cx, 5

bullet_hit_loop:
    mov al, [bx]
    cmp al, 0
    jz bullet_hit_exit
    mov ax, [word ptr si]

    push ax
    push bullet_height
    push bullet_width
    push [word ptr bp + 6] ; bullet_x
    push [word ptr bp + 8] ; bullet_y
    ; ---------------------------
    push zombie_height
    push zombie_width
    push ax ; zombie_x
    push zombie_y
    call BoxCollision
    pop ax

    cmp ax, 1
    jnz bullet_hit_exit
    call delete_bullet&zombie
    mov al, 0
    mov [bx], al
    push bx
    mov bx, [word ptr bp + 12]
    mov [bx], al
    pop bx

bullet_hit_exit:
    add si, 2
    inc bx
    loop bullet_hit_loop


    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
endp bullet_hit

proc delete_bullet&zombie

    push bullet_height
    push bullet_width
    push [word ptr bp + 8]
    push [word ptr bp + 6]
    call delete
    
    mov ax, [word ptr si]
    push zombie_height
	push zombie_width
	push floor - zombie_height
	push ax
	call delete

    ret
endp delete_bullet&zombie


; this function gets:
; [word ptr bp + 4] = offset zombie_x
; [word ptr bp + 6] = offset zombie_y
; [word ptr bp + 8] = player_x
; [word ptr bp + 10] = player_y
; [word ptr bp + 12] = offset player_alive
; this function returns nothing
; this function checks if the zombies hit the player
proc player_hit
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, [word ptr bp + 12] ; offset player_alive
    mov si, [word ptr bp + 4] ; offset zombie_x
    mov di, [word ptr bp + 6] ; offset zombie_y

    mov cx, 5

player_hit_loop:
    mov ax, [bx]
    cmp ax, 0
    jz player_hit_exit
    
    push ax ; free_space
    push bullet_height ; player = boxB
    push zombie_height ; zombie = boxA
    push player_width
    push player_width
    push [word ptr bp + 10]
    push [word ptr bp + 8]
    push [di]
    push [si]
    ;call check_if_hit
    pop ax
    cmp ax, 0
    jz player_hit_exit
    mov al, 0
    mov [bx], al

player_hit_exit:
    add di, 2
    add si, 2
    inc bx
    loop player_hit_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
endp player_hit

; this function's purpose is to excute the player precedure
proc player_precedure
    
    push offset gravity
    call gr_add

    push [gravity]
    push offset player_x
    push offset player_y
    call floor_check

    call key_check_complete
    
    push [player_state]
    push [player_y]
    push [player_x]
    push [player_look]
    call print_player
    ret
endp player_precedure

; this function returns nothing
; this function's purpose is to do the bullet's procedure
proc bullet_procedure
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    call delete_bullet
    
    push [bullet_dir]
    push offset bullet_x
    call bullet_mov

    call full_bullet_hit

    push [bullet_dir]
    push offset bullet_active
    push [bullet_x]
    call bullet_delete

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
endp bullet_procedure

proc zombie_procedure
    
    call delete_zombies

    push offset zombie_look
    push offset zombie_state
    push offset zombie_alive
    push [zombie_speed]
    push offset player_x
    push offset zombie_x
    call zombie_mov

    push offset zombie_alive
    push offset zombie_state
    push offset zombie_x
    push offset zombie_look
    call print_zombies
    ret
endp zombie_procedure

start:
    mov ax, 0A000h
    mov es, ax
    mov ax, @data
    mov ds, ax

    call enter_graphical

    push offset map
    call full_pic

    ;mov ah, 00
    ;int 16h

game_loop:
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
    jmp game_loop
   
    mov ah, 00
    int 16h

exit:
    mov ax, 4c00h
    int 21h
END start