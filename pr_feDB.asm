DATASEG
    BmpLeft dw 0 ; x
    BmpTop dw 0 ; y
    BmpColSize dw 0 ; width
    BmpRowSize dw 0 ; height
    ; Variables used ONLY in the following procedures:
	OneBmpLine 	db 200 dup (0)  ; One Color line read buffer
    ScreenLineMax db 320 dup (0)  ; One Color line read buffer
	FileHandle	dw ?
	Header 	    db 54 dup (0)
	Palette 	db 400h dup (0)


CODESEG
; this function gets:
; [word ptr bp + 4] = offset player
; this function returns nothing
; this function's purpose is to print the player according to the state and look
proc print_dynamic_player
	push bp
	mov bp, sp

    mov bx, [player_y]
    mov ax, [player_x]

    push ds
    mov cx, player
    mov ds, cx

    push [word ptr bp + 4]
    push 255
    push player_height
    push player_width
    push bx
    push ax
    call print
    pop ds
    
	pop bp
    ret 2
endp print_dynamic_player
; this function gets:
; [word ptr bp + 4] = player_look (pass by value)
; [word ptr bp + 6] = player_x (pass by value)
; [word ptr bp + 8] = player_y (pass by value)
; [word ptr bp + 10] = player_state (pass by value)
; this function returns nothing
; this function's purpose is to print the player in the correct state and look
proc print_player
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	

	mov ax, [word ptr bp + 10] ; player_state
	mov cx, [word ptr bp + 4] ; player_look

	cmp cx, left
	jz player_printL

player_printR:
	cmp ax, 1
	jz player_printR1
	cmp ax, 2
	jz player_printR2
	cmp ax, 3
	jz player_printR3
	cmp ax, 4
	jz player_printR4

player_printR1:
	push offset playerR1
	jmp player_print_end
player_printR2:
	push offset playerR2
	jmp player_print_end
player_printR3:
	push offset playerR3
	jmp player_print_end
player_printR4:
	push offset playerR4
	jmp player_print_end

player_printL:
	cmp ax, 1
	jz player_printL1
	cmp ax, 2
	jz player_printL2
	cmp ax, 3
	jz player_printL3
	cmp ax, 4
	jz player_printL4

player_printL1:
	push offset playerL1
	jmp player_print_end

player_printL2:
	push offset playerL2
	jmp player_print_end

player_printL3:
	push offset playerL3
	jmp player_print_end

player_printL4:
	push offset playerL4
	jmp player_print_end

player_print_end:
	call print_dynamic_player

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8
endp print_player 

; this function gets: 
; [word ptr bp + 4] = zombie_look (pass by refrence)
; [word ptr bp + 6] = zombie_x (pass by refrence)
; [word ptr bp + 8] = zombie_state (pass by refrence)
; [word ptr bp + 10] = zombie_alive (pass by refrence)
; this function returns nothing
; this function's purpose is to print the zombie in the correct state and look
proc print_zombies
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov cx, 5
	mov bx, [word ptr bp + 8] ; zombie_state
	mov di, [word ptr bp + 6] ; zombie_x

zombie_print_loop:
	push di
	mov di, [word ptr bp + 10] ; zombie_alive
	mov al, [di]
	pop di
	cmp al, 1
	jnz connect_zombies_not_print

	mov ax, [bx] ; zombie_state
	push bx
	mov bx, [word ptr bp + 4] ; zombie_look
	mov dx, [bx] ; zombie_look
	pop bx

	cmp dx, left
	jz zombie_printL

zombie_printR:
	cmp ax, 1
	jz zombie_printR1
	cmp ax, 2
	jz zombie_printR2
	cmp ax, 3
	jz zombie_printR3
	cmp ax, 4
	jz zombie_printR4

zombie_printR1:
	push offset zombieR1
	jmp connect_print_zombie_foward
zombie_printR2:
	push offset zombieR2
	jmp connect_print_zombie_foward
zombie_printR3:
	push offset zombieR3
	jmp connect_print_zombie_foward
zombie_printR4:
	push offset zombieR4
	jmp connect_print_zombie_foward

connect_zombies_not_print:
	jmp zombies_not_print

connect_print_zombie_foward:
	jmp zombie_print_end

zombie_printL:
	cmp ax, 1
	jz zombie_printL1
	cmp ax, 2
	jz zombie_printL2
	cmp ax, 3
	jz zombie_printL3
	cmp ax, 4
	jz zombie_printL4

connect_print_zombie_back:
	jmp zombie_print_loop

zombie_printL1:
	push offset zombieL1
	jmp zombie_print_end

zombie_printL2:
	push offset zombieL2
	jmp zombie_print_end

zombie_printL3:
	push offset zombieL3
	jmp zombie_print_end

zombie_printL4:
	push offset zombieL4
	jmp zombie_print_end

zombie_print_end:
	mov ax, [di] ; zombie_x
	push ax ; zombie_x
	call print_dynamic_zombie
zombies_not_print:
	add bx, 2
	add di, 2
	add [word ptr bp + 4], 2
	inc [byte ptr bp + 10]
	loop connect_print_zombie_back

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp print_zombies
; this function gets:
; [word ptr bp + 4] = zombie_x
; [word ptr bp + 6] = offset zombie
proc print_dynamic_zombie
	push bp
	mov bp, sp

	push ax
	push bx
	push cx

    mov ax, [word ptr bp + 4]

    push ds
    mov cx, zombie
    mov ds, cx

    push [word ptr bp + 6]
    push 255
    push zombie_height
    push zombie_width
    push floor - zombie_height
    push ax
    call print
    pop ds

	pop cx
	pop bx
	pop ax

	pop bp
	ret 4
endp print_dynamic_zombie

; this function gets:
; [word ptr bp + 4] = x
; [word ptr bp + 6] = y
; [word ptr bp + 8] = width
; [word ptr bp + 10] = height
; [word ptr bp + 12] = no_color
; [word ptr bp + 14] = offset picture
; this function returns nothing
; this function's purpose is to print a picture to the screen
proc print
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov bx, [word ptr bp + 14]

    push ds
    mov ax, double_buffer
    mov ds, ax

    mov di, offset double

    
    ; puts the singular position in di
    mov cx, di
    shl di, 8
    shl cx, 6
    add di, cx
    add di, [word ptr bp + 4] 

    mov cx, [word ptr bp + 8] ; width
    add cx, [word ptr bp + 4] ; width + x
    mov ax, [word ptr bp + 10] ; height
    add ax, [word ptr bp + 6] ; height + y

    push ax ; bp - 16: height + y
    push cx ; bp - 18: width + x
    
    mov dx, [word ptr bp + 6] ; y
    mov si, [word ptr bp + 4] ; x    

draw_loop:
    xor ax, ax
    mov al, [byte ptr bx] ; current color
    cmp ax, [word ptr bp + 12] ; no_color
    jz not_print
    mov [di], al

not_print:
    inc bx
    inc di
    inc si
    cmp si, [word ptr bp - 16]
    jnz draw_loop

    ; reset the x and go down a line in the pos
    mov si, [word ptr bp + 4] ; x
    add di, 320
    sub di, [word ptr bp + 8] ; width

    inc dx
    cmp dx, [word ptr bp - 14]
    jnz draw_loop

    pop ax
    pop bx
    
    pop ds

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 12
endp print

proc delete_zombies
	push ax
	push bx
	push cx
	push dx
	push si
	push di


	mov di, offset zombie_alive
	mov bx, offset zombie_x
	mov cx, 5

zombies_delete_loop:
	mov al, [byte ptr di]
	cmp al, 1
	jnz zombies_skip_delete

	mov ax, [word ptr bx]
	push zombie_height
	push zombie_width
	push floor - zombie_height
	push ax
	call delete

zombies_skip_delete:
	inc di
	add bx, 2
	loop zombies_delete_loop


	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp delete_zombies

; this function gets:
; [word ptr bp + 4] = x
; [word ptr bp + 6] = y
; [word ptr bp + 8] = width
; [word ptr bp + 10] = height
; this function returns nothing
; this function's purpose is to delete a section of the screen
proc delete
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    push ds
    mov ax, double_buffer
    mov ds, ax

    ; puts the singular positon in di
    mov di, offset double
    mov cx, di
    shl di, 8
    shl cx, 6
    add di, cx
    add di, [word ptr bp + 4] 

    mov cx, [word ptr bp + 8] ; width
    add cx, [word ptr bp + 4] ; width + x
    mov ax, [word ptr bp + 10] ; height
    add ax, [word ptr bp + 6] ; height + y

    push ax ; bp - 16: height + y
    push cx ; bp - 18: width + x
    
    mov dx, [word ptr bp + 6] ; y
    mov si, [word ptr bp + 4] ; x   

	mov al, 255
	xor ah, ah

delete_loop:
	mov al, 255
	cmp dx, floor
	jge change_color
	cmp si, left_border
	jle change_color
	cmp si, right_border
	jge change_color
	cmp si, platform_right
	jge change_color
	cmp si, platform_left
	jl change_color
	cmp dx, platform_high
	jl change_color
	cmp dx, platform_low
	jg change_color
	mov al, 0

change_color:
	mov [di], al

    inc di
    inc si
    cmp si, [word ptr bp - 16]
    jnz delete_loop

    ; reset the x and go down a line in the pos
    mov si, [word ptr bp + 4] ; x
    add di, 320
    sub di, [word ptr bp + 8] ; width

    inc dx
    cmp dx, [word ptr bp - 14]
    jnz delete_loop

    pop ax
    pop bx

    pop ds

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8
endp delete

; this function gets:
; [word ptr bp + 4] = number_of_hearts
; this function returns nothing
; this function's purpose is to print the hearts according to how much health the player has
proc print_hearts
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx

	mov cx, [word ptr bp + 4] ; number_of_hearts
	mov ax, left_border + 5

heart_print_loop:
	push ax
	call print_dynamic_heart

	add ax, heart_width + 5 
	loop heart_print_loop

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp print_hearts

; this function gets:
; [word ptr bp + 4] = heart_x
; this function returns nothing
; this function's purpose is to print a heart according to the x position
proc print_dynamic_heart
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx

    mov ax, [word ptr bp + 4]

    push ds
    mov cx, bullet_seg
    mov ds, cx

    push offset heart
    push 255
    push heart_height
    push heart_width
    push heart_y
    push ax
    call print
    pop ds


	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp print_dynamic_heart

; this function gets:
; [word ptr bp + 4] = round_num
; this function returns nothing
; this function's purpose is to print the correct round
proc print_round
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	
	call enter_graphical

	mov ax, [word ptr bp + 4]
	cmp ax, 5
	jz round5
	cmp ax, 4
	jz round4
	cmp ax, 3
	jz round3
	cmp ax, 2
	jz round2

round1:
	push offset round_1
	jmp print_round_exit

round2:
	push offset round_2
	jmp print_round_exit

round3:
	push offset round_3
	jmp print_round_exit

round4:
	push offset round_4
	jmp print_round_exit

round5:
	push offset round_5

print_round_exit:
	call full_pic
	push 10
	call delay

	call exit_graphical

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp print_round

; input :
;	1.BmpLeft offset from left (where to start draw the picture) 
;	2. BmpTop offset from top
;	3. BmpColSize picture width , 
;	4. BmpRowSize bmp height 
;	5. dx offset to file name with zero at the end 
proc OpenShowBmp
	push cx
	push bx
	call OpenBmpFile
	cmp ax, 0
	je exitp
	
	call ReadBmpHeader
	; from  here assume bx is global param with file handle. 
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseBmpFile

	exitp:
	pop bx
	pop cx
	ret
endp OpenShowBmp	
; input dx filename to open
proc OpenBmpFile
	mov ah, 3Dh
	xor al, al
	int 21h
	jc ErrorAtOpen
	mov [FileHandle], ax
	jmp exitt
	
ErrorAtOpen:
	mov ax, 0
exitt:	
	ret
endp OpenBmpFile

proc CloseBmpFile
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile

; Read 54 bytes the Header
proc ReadBmpHeader
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader

proc ReadBmpPalette ; Read BMP file color palette, 256 colors * 4 bytes (400h)
	; 4 bytes for each color BGR + null
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	mov bp,dx
	
	mov dx,[BmpLeft]
	
NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScreenLineMax
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScreenLineMax
	rep movsb ; Copy line to the screen
	pop dx
	pop cx
	loop NextLine
	pop cx
	ret
endp ShowBMP


; this function gets:
; [word ptr bp + 4] = file name (pass by rereference)
; this function returns nothing
; this function's purpose is to print a pic to the screen
proc full_pic
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx

	mov dx, [word ptr bp + 4] ; filename
	mov [BmpTop], 0
	mov [BmpLeft], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp full_pic

proc full_screen_DB

    push di
    push cx

    push ds
    mov ax, double_buffer
    mov ds, ax

    mov di, offset double
    mov cx, 320 * 200


full_screen_loop:
    mov al, [di]
    cmp al, 5
    jz full_screen_exit
    mov graphical, al
full_screen_exit:
    inc di
    loop full_screen_loop


    pop ds
    pop cx
    pop di
    ret
endp full_screen_DB