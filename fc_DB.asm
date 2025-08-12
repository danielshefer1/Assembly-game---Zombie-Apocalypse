DATASEG

CODESEG

; this function's purpose is to excute the player precedure
proc player_precedure
    
    push offset gravity
    call gr_add

    push [gravity]
    push offset player_x
    push offset player_y
    call floor_check

    call key_check_complete

    push offset player_alive
    push [player_y]
    push [player_x]
    push offset zombie_x
    call player_hit
    
    push offset switch_round
    push offset round_num
    push offset number_of_hearts
    push offset zombie_alive
    push offset player_alive
    call check_if_win

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

    call full_screen_DB

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

; this function gets:
; [word ptr bp + 4] = offset state
; this function's purpose is to extand the cycle mechanism
proc ext_cycle
    push bp
    mov bp, sp
    push ax
    push bx
    mov bx, [word ptr bp + 4]
    mov ax, [bx]
    cmp ax, 4
    jz restart_cycle
    jnz inc_cycle

restart_cycle:
    mov ax, 1
    jmp ext_cycle_end

inc_cycle:
    inc ax

ext_cycle_end:
    mov [bx], ax
    pop bx
    pop ax
    pop bp
    ret 2
endp ext_cycle

; this function gets:
; [word ptr bp + 4] = offset zombie_x
; [word ptr bp + 6] = offset player_x
; [word ptr bp + 8] = zombie_speed
; [word ptr bp + 10] = offset zombie_alive
; [word ptr bp + 12] = offset zombie_state
; [word ptr bp + 14] = offset zombie_look
; this function returns nothing
; this function moves the zombies according to where the player is
proc zombie_mov
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, [word ptr bp + 4] ; offset zombie_x
    mov si, [word ptr bp + 6] ; offset player_x
    mov di, [word ptr bp + 12] ; offset zombie_state
    mov ax, [si] ; player_x
    mov si, [word ptr bp + 10] ; offset zombie_alive
    mov cx, 5


zombie_mov_loop:    
    mov dl, [si]
    cmp dl, 0
    jz zombie_mov_loop_exit
    push di
    call ext_cycle
    mov dx, [bx] ; zombie_x
    cmp dx, ax
    jl zombie_mov_right
    
; zombie_mov_left:
    push bx
    push ax

    mov bx, [word ptr bp + 14]
    mov ax, left
    mov [bx], ax

    pop ax
    pop bx
    sub dx, [word ptr bp + 8]
    jmp zombie_mov_loop_exit

zombie_mov_right:
    push bx
    push ax

    mov bx, [word ptr bp + 14]
    mov ax, right
    mov [bx], ax

    pop ax
    pop bx
    add dx, [word ptr bp + 8]

zombie_mov_loop_exit:
    mov [bx], dx
    add bx, 2
    inc si
    add di, 2
    add [word ptr bp + 14], 2
    loop zombie_mov_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 12
endp zombie_mov

; this function gets:
; [word ptr bp + 4] = Y2
; [word ptr bp + 6] = X2
; [word ptr bp + 8] = Width2
; [word ptr bp + 10] = Height2
; [word ptr bp + 12] = Y1
; [word ptr bp + 14] = X1
; [word ptr bp + 16] = Width1
; [word ptr bp + 18] = Height1
; [word ptr bp + 20] = free_space
; this function returns 1 or 0
; this function checks if two boxes hit each other
proc BoxCollision
    push bp
    mov bp, SP

    push ax
    push bx
    push cx
    push dx
    push di
    push si
    ; Load box 1 parameters
    mov ax, [bp+18]  ; Width1
    mov cx, [bp+14]  ; X1
    add ax, cx       ; ax = X1 + Width1
    mov si, ax       ; si = Right edge of Box 1

    mov ax, [bp+12]  ; Y1
    mov cx, [bp+16]  ; Height1
    add ax, cx       ; ax = Y1 + Height1
    mov di, ax       ; di = Bottom edge of Box 1

    ; Load box 2 parameters
    mov bx, [bp+10]  ; Width2
    mov cx, [bp+06]  ; X2
    add bx, cx       ; bx = X2 + Width2
    mov DX, bx       ; DX = Right edge of Box 2

    mov bx, [bp+04]  ; Y2
    mov cx, [bp+08]  ; Height2
    add bx, cx       ; bx = Y2 + Height2
    mov cx, bx       ; cx = Bottom edge of Box 2

    ; Check for overlap
    ; if (X1 < X2 + Width2 && X1 + Width1 > X2 && Y1 < Y2 + Height2 && Y1 + Height1 > Y2)
    ; Compare X1 < X2 + Width2 (Right edge of Box 2)
    mov ax, [bp+14]  ; X1
    cmp ax, DX
    jge NoCollision

    ; Compare X1 + Width1 > X2
    cmp si, [bp+06]  ; Right edge of Box 1 vs X2
    jle NoCollision

    ; Compare Y1 < Y2 + Height2 (Bottom edge of Box 2)
    mov ax, [bp+12]  ; Y1
    cmp ax, cx
    jge NoCollision

    ; Compare Y1 + Height1 > Y2
    cmp di, [bp+04]  ; Bottom edge of Box 1 vs Y2
    jle NoCollision

    ; If all conditions are met, boxes collide
    mov ax, 1
    jmp StoreResult

NoCollision:
    mov ax, 0

StoreResult:
    mov [word ptr bp + 20], ax

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ; Clean up and return
    pop bp
    ret 16
endp BoxCollision
; this function returns nothing
; this function's purpose is to excute the key_check procedure with the correct parameters
proc key_check_complete

    push offset player_look
    push offset gravity
    push offset player_state
    push offset player_y
    push offset player_x
    call key_check

    ret
endp key_check_complete

proc print_bullet
    mov dx, [bullet_dir]
    mov bx, [bullet_y]
    mov ax, [bullet_x]

    push ds
    mov cx, bullet_seg
    mov ds, cx

    cmp dx, left
    jz bullet_print_left
    push offset bulletR
    jmp bullet_print_end

bullet_print_left:
    push offset bulletL
bullet_print_end:


    push 255
    push bullet_height
    push bullet_width
    push bx
    push ax
    call print
    pop ds

    ret
endp print_bullet

; this function returns nothing
; this function's purpose is to delete the bullet
proc delete_bullet
    push bullet_height
    push bullet_width
    push [bullet_y]
    push [bullet_x]
    call delete

    ret
endp delete_bullet

; this function gets:
; [word ptr bp + 4] = offset bullet_dir
; [word ptr bp + 6] = player_look
; [word ptr bp + 8] = offset player_x
; [word ptr bp + 10] = offset player_y
; [word ptr bp + 12] = offset bullet_x
; [word ptr bp + 14] = offset bullet_y
; this function returns nothing
; this function fires the bullet 
proc fire_bullet
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    ; y set_up
    mov bx, [word ptr bp + 10] ; player_y
    mov si, [word ptr bp + 14] ; bullet_y
    mov ax, [bx]
    add ax, player_height / 3
    mov [si], ax

    mov bx, [word ptr bp + 8] ; player_x
    mov si, [word ptr bp + 12] ; bullet_x
    mov di, [word ptr bp + 4] ; bullet_dir
    ; dir Setup
    mov ax, [word ptr bp + 6] ; player_look
    mov [di], ax

    cmp ax, left
    jz fire_left

fire_right:
    ; x Setup
    mov ax, [bx]
    add ax, player_width
    jmp fire_exit

fire_left:
    ; x Setup
    mov ax, [bx]
    sub ax, bullet_width


fire_exit:
    mov [si], ax
    mov [bullet_active], 1
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 12
endp fire_bullet

; this function gets:
; [word ptr bp + 4] = bullet_x
; [word ptr bp + 6] = offset bullet_active
; [word ptr bp + 8] = bullet_dir 
; this function returns nothing
; this function checks if the bullet hit one of the borders.
proc bullet_delete
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di


    mov bx, [word ptr bp + 6] ; bullet_active
    mov al, [byte ptr bx]
    cmp al, 0
    jz bullet_border_exit
    mov ax, [word ptr bp + 8] ; bullet_dir
    cmp ax, right
    jz bullet_right_check
    
bullet_left_check:
    mov ax, [word ptr bp + 4] ; bullet_x
    cmp ax, left_border
    jz bullet_hit_border
    sub ax, bullet_speed
    cmp ax, left_border
    jl bullet_hit_border
    jmp bullet_not_hit_border

bullet_right_check:
    mov ax, [word ptr bp + 4] ; bullet_x
    cmp ax, right_border
    jz bullet_hit_border
    add ax, 25
    cmp ax, right_border
    jge bullet_hit_border
    jmp bullet_not_hit_border

bullet_hit_border:    
    mov bx, [word ptr bp + 6]
    mov al, 0
    mov [byte ptr bx], al
    call delete_bullet
    jmp bullet_border_exit
    
bullet_not_hit_border:
   call print_bullet

bullet_border_exit:


    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp bullet_delete
; this function gets:
; [word ptr bp + 4] = offset bullet_x
; [word ptr bp + 6] = bullet_dir
; this function returns nothing
; this function moves the bullet according to it's direction
proc bullet_mov
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ax, [word ptr bp + 6]
    mov bx, [word ptr bp + 4]
    mov dx, [bx]
    cmp ax, left
    jz bullet_mov_left

bullet_mov_right:
    add dx, bullet_speed
    jmp bullet_mov_exit

bullet_mov_left:
    sub dx, bullet_speed

bullet_mov_exit:
    mov [bx], dx

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
endp bullet_mov 

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

proc full_bullet_hit

    mov al, [bullet_active]
    cmp al, 1
    jnz full_bullet_hit_exit

    push offset bullet_active
    push offset zombie_alive
    push [bullet_y]
    push [bullet_x]
    push offset zombie_x
    call bullet_hit

full_bullet_hit_exit:

    ret
endp full_bullet_hit

; this function gets:
; [word ptr bp + 4] = offset zombie_x
; [word ptr bp + 6] = player_x
; [word ptr bp + 8] = player_y
; [word ptr bp + 10] = offset player_alive
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

    mov bx, [word ptr bp + 10] ; offset player_alive
    mov si, [word ptr bp + 4] ; offset zombie_x

    mov cx, 5

player_hit_loop:
    mov al, [bx]
    cmp al, 0
    jz player_hit_exit
    mov ax, [word ptr si]

    push ax
    push player_height
    push 1
    push [word ptr bp + 6] ; player_x
    push [word ptr bp + 8] ; player_y
    ; ---------------------------
    push zombie_height
    push 1
    push ax ; zombie_x
    push zombie_y
    call BoxCollision
    pop ax

    cmp ax, 1
    jnz player_hit_exit

    mov al, 0
    mov [bx], al

player_hit_exit:
    add si, 2
    loop player_hit_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8
endp player_hit

; this function gets:
; [word ptr bp + 4] = player_x (pass by reference)
; [word ptr bp + 6] = player_y (pass by reference)
; [word ptr bp + 8] = player_state (pass by reference)
; [word ptr bp + 10] = gravity (pass by reference)
; [word ptr bp + 12] = player_look (pass by reference)
; it returns nothing
; the purpose of this function is to check which key was pressed and respond accordingly
proc key_check 
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    ; checks if a key was pressed
    xor al, al
    in al, 64h ; read the keyboard status port
    cmp al, 10b
    jz connect_key

    ; if a key was pressed checks what it is
    in al, 60h

    ; checks what is the input
    cmp al, up
    jz mov_key
    cmp al, right
    jz mov_key
    cmp al, left
    jz mov_key
    cmp al, space_key
    jz mov_key

    cmp al, esc_key
    jz connect_esc_key

    jmp no_key


mov_key:
    push player_height
    push player_width
    push [player_y]
    push [player_x]
    call delete
    cmp al, up
    jz jump_key
    cmp al, right
    jz mov_right_key
    cmp al, left
    jz mov_left_key
    cmp al, space_key
    jz fire_bullet_key

; ---------------------------------
connect_esc_key:
    jmp esc_program

connect_key:
    jmp no_key
; ---------------------------------

jump_key:
    ; checks if the player is on the floor
    push ax ; free space
    push [word ptr bp + 4] ; offset player_x
    push [word ptr bp + 6] ; offset player_y
    call check_if_on_floor
    pop ax ; result

    ; if the player is on the floor it can jump
    cmp ax, 1
    jnz cycle_check
    mov bx, [word ptr bp + 10] ; offset gravity
    xor ax, ax
    mov [bx], al
    mov bx, [word ptr bp + 6] ; offset player_y
    mov ax, [bx]
    sub ax, jump_height
    mov [bx], ax
    jmp cycle_check

; if it is legal moves the player
mov_left_key:
    ; check if the player can move left
    mov bx, [word ptr bp + 4] ; offset player_x
    mov ax, [bx]
    sub ax, player_speed
    cmp ax, left_border
    jle connect_key_left

    ; moves the player
    mov bx, [word ptr bp + 4] ; offset player_x
    mov [bx], ax

    mov bx, [word ptr bp + 12] ; offset player_look
    mov al, left
    mov [bx], al
    jmp cycle_check

mov_right_key:
; check if the player can move right
    mov bx, [word ptr bp + 4] ; offset player_x
    mov ax, [bx]
    add ax, player_speed
    cmp ax, right_border - player_width
    jge connect_key_left

    ; moves the player
    mov bx, [word ptr bp + 4] ; offset player_x
    mov [bx], ax

    mov bx, [word ptr bp + 12] ; offset player_look
    mov al, right
    mov [bx], al

cycle_check:
    push [word ptr bp + 8] ; offset player_state
    call ext_cycle
connect_key_left:
    jmp is_key

fire_bullet_key:
    cmp [bullet_active], 0
    jnz is_key
    push offset bullet_y
    push offset bullet_x
    push offset player_y ; offset player_y
    push offset player_x ; offset player_x
    push [player_look]
    push offset bullet_dir
    call fire_bullet
    jmp is_key

esc_program:
    mov ax, 4c00h
    int 21h

no_key:
    mov bx, [word ptr bp + 8] ; offset player_state
    mov ax, [bx]
    cmp ax, 1
    jz is_key
    push player_height
    push player_width
    push [player_y]
    push [player_x]
    call delete
    mov ax, 1
    mov [bx], ax

is_key:

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
endp key_check


; this function gets:
; [word ptr bp + 4] = offset player_alive
; [word ptr bp + 6] = offset zombie_alive
; [word ptr bp + 8] = offset number_of_hearts
; [word ptr bp + 10] = offset round_num
; [word ptr bp + 12] = offset switch_round
; this function returns nothing
; this function checks if the player has won
proc check_if_win
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    xor ax, ax
    mov bx, [word ptr bp + 6] ; offset zombie_alive
    mov cx, 5

check_if_win_loop:
    mov dl, [bx]
    cmp dl, 0
    jnz check_if_win_loop_exit
    inc ax

check_if_win_loop_exit:
    inc bx
    loop check_if_win_loop

    cmp ax, 5
    jnz check_if_win_exit

    mov bx, [word ptr bp + 4] ; offset player_alive
    mov al, 0
    mov [byte ptr bx], al
    mov bx, [word ptr bp + 8] ; offset number_of_hearts
    mov ax, [bx]
    inc ax
    mov [bx], ax

    mov bx, [word ptr bp + 10] ; offset round_num
    mov ax, [bx]
    inc ax
    mov [bx], ax

    mov bx, [word ptr bp + 12] ; offset switch_round
    mov al, 1
    mov [byte ptr bx], al


check_if_win_exit:


    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 10
endp check_if_win

; this function gets:
; [word ptr bp + 4] = time of delay
; it returns nothing
; the purpose of this function is to create a delay

; the delay procedure uses the system clock to measure time intervals and introduces 
; a delay by repeatedly checking the current time against the initial time until the specified delay duration has passed.
; this mechanism allows the program to wait for a specified period before continuing execution.
proc delay
    push bp
    mov bp, sp
    push bx
    push dx
    push es

    ; moves the clock into bx
    mov ax, 40h
    mov es, ax
    mov ax, clock

    ; compares the curren clock to the original clock and see how much time has passed, if a selected number of ticks have passed the function exits
delay_loop:
    mov bx, clock
    sub bx, ax
    cmp bx, [word ptr bp + 4]
    jl delay_loop

    pop es
    pop dx
    pop bx
    pop bp
    ret 2
endp delay

; this function returns nothing
; this function's purpose is to enter graphical mode
proc enter_graphical
	push ax

    mov ah, 0
    mov al, 13h  ; set VGA graphics mode
    int 10h      ; call BIOS video services

	pop ax
	ret
endp enter_graphical

; this function returns nothing
; this function's purpose is to exit graphical mode
proc exit_graphical
	push ax
	mov ah, 0
	mov al, 3
	int 10h
	pop ax
	ret
endp exit_graphical