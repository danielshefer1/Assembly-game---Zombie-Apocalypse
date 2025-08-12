DATASEG

CODESEG

; this function gets:
; [word ptr bp + 4] = gravity (pass by reference)
; this function returns nothing
; this function's purpose is to add gravity_acc to gravity until gravity_max
proc gr_add
    push bp
    mov bp, sp    
    push ax
    push bx
    push cx
    push dx

    ; gets the gravity,
    ; checks if it's gravity_max and if it is not adds gravity_acc to it
    xor ax, ax
    mov bx, [word ptr bp + 4]
    mov ax, [word ptr bx]
    cmp ax, gravity_max
    jz cont_gr
    add ax, gravity_acc
    mov [word ptr bx], ax

cont_gr:
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2
endp gr_add

; this function gets:
; [word ptr bp + 4] = player_y (pass by reference)
; [word ptr bp + 6] = player_x (pass by reference)
; [word ptr bp + 8] = gravity (pass by value)
; this function returns nothing
; this function's purpose is to check if the player is on the floor or the platform and responds to it
proc floor_check
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di



    mov bx, [word ptr bp + 4] ; player_y
    mov si, [word ptr bp + 6] ; player_x

    mov dx, [bx] ; player_y
    mov cx, [si] ; player_x

    xor ax, ax

    cmp dx, floor - player_height
    jz connect_floor
    add dx, [word ptr bp + 8] ; gravity
    sub dx, DrawBack
    cmp dx, floor - player_height
    jge lock_to_floor

    cmp cx, platform_left - player_width / 2
    jl not_on_floor_check
    cmp cx, platform_right - player_width / 2
    jg not_on_floor_check
    mov dx, [bx] ; player_y
    cmp dx, platform_high - player_height
    jz floor_check_exit
    add dx, 20
    cmp dx, platform_high - player_height
    jl not_on_floor_check
    cmp dx, platform_high
    jge not_on_floor_check
    jl lock_to_platform

connect_floor:
    jmp floor_check_exit

not_on_floor_check:
    mov ax, [bx]
    push player_height
    push player_width
    push ax
    push cx
    call delete
    add ax, [word ptr bp + 8] ; gravity
    sub ax , DrawBack
    mov [bx], ax
    
    jmp floor_check_exit

lock_to_platform:
    mov ax, [bx]
    push player_height
    push player_width
    push ax
    push cx
    call delete
    mov ax, platform_high - player_height
    mov [bx], ax
    jmp floor_check_exit

lock_to_floor:
    mov ax, [bx]
    push player_height
    push player_width
    push ax
    push cx
    call delete
    mov ax, floor - player_height
    mov [bx], ax


floor_check_exit:

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp floor_check

; this function gets:
; [word ptr bp + 4] = player_y (pass by reference)
; [word ptr bp + 6] = player_x (pass by reference)
; [word ptr bp + 8] = free_space
; this function returns 1 or 0
; this function's purpose is to check if the player is on the floor
proc check_if_on_floor
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov bx, [word ptr bp + 4] ; player_y
    mov si, [word ptr bp + 6] ; player_x

    mov dx, [bx] ; player_y
    mov cx, [si] ; player_x

    xor ax, ax

    cmp dx, floor - player_height
    jz on_floor_check2
    add dx, [word ptr bp + 8] ; gravity
    sub dx, DrawBack
    cmp dx, floor - player_height
    jge on_floor_check2

    cmp cx, platform_left - player_width / 2
    jl on_floor_check_exit
    cmp cx, platform_right - player_width / 2
    jg on_floor_check_exit
    mov dx, [bx] ; player_y
    cmp dx, platform_high - player_height
    jz on_floor_check2
    add dx, 20
    cmp dx, platform_high - player_height
    jl on_floor_check_exit
    cmp dx, platform_high
    jge on_floor_check_exit
    
on_floor_check2:
    mov ax, 1

on_floor_check_exit:
    mov [word ptr bp + 8], ax

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
endp check_if_on_floor
