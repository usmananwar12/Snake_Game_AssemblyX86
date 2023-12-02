[org 0x100]
jmp start

section .bss
    board resb 2000
section .text
message db 'Snake Game', 0
message4 db 'press "x" key to continue', 0
message2 db 'Usman Anwar 22f-8769', 0
message3 db 'Muhammad Ali 22F-3398', 0
score dw 0
score_str db 'SCORE:   ', 0
gameover db 'WASTED!', 0
level dw 1
is_game_over dw 0
snake_direction db 8
snake_head_x db 40
snake_head_y db 15
snake_head_previous_x db 40
snake_head_previous_y db 15
snake_tail_x db 40
snake_tail_y db 15
snake_tail_previous_x db 40
snake_tail_previous_y db 15

board_clear:
    ; initialize with spaces
    mov bx, 0
next:
    mov byte [board + bx], ' '
    inc bx
    cmp bx, 2000
    jnz next
    ret

    ;si = string address
	;di = board destination 
board_print_string:
	next_c:
		mov al, [si]
		cmp al, 0
		jz endl
		mov byte [board + di], al
		inc di
		inc si
		jmp next_c
	endl:
		ret
print_score:
		mov si, score_str
		mov di, 35
		call board_print_string
		mov ax, [score]
		mov di, 43
	next_digit:
		xor dx, dx
		mov bx, 10
		div bx
		push ax
		mov al, dl
		add al, 48
		mov byte [board + di], al
		pop ax
		dec di
		cmp ax, 0
		jnz next_digit
		ret
		
ret

print_main:
	mov si, message
	mov di, 672
	call board_print_string
	mov si, message2
	mov di, 907	
	call board_print_string
	mov si, message3
	mov di, 987	
	call board_print_string
	mov si, message4
	mov di, 1305	
	call board_print_string
	call board_render

check_level:
	mov ax, [level]
	cmp ax, 1
		je lvl1
	cmp ax, 2
		je lvl2
	cmp ax, 3
		je lvl3
	jmp ex	
lvl1:
	call delay
	call delay
	call delay
	jmp ex
lvl2:
	call delay
	call delay
	jmp ex
lvl3:	
	call delay
	jmp ex
ex:	
	ret
	

print_Gameover:
	mov si, gameover
	mov di, 995	
	call board_print_string


draw_border:
    mov di, 0
next_x:
    mov byte [board + di], 205
    mov byte [board + 80 + di], 205
    mov byte [board + 1920 + di], 205
    inc di
    cmp di, 80
    jnz next_x
    mov di, 0
next_y:
    mov byte [board + 80 + di], 186
    mov byte [board + 159 + di], 186
    add di, 80
    cmp di, 2000
    jnz next_y
corners:
    mov byte [board + 80], 201
    mov byte [board + 159], 187
    mov byte [board + 1920], 200
    mov byte [board + 1999], 188
    ret
	

	
board_render:
	mov ax, 0b800h
	mov es, ax
	mov di, board
	mov si, 0
next1:
	mov bl, [di]
	cmp bl, 8
	jz is_snake
	cmp bl, 4
	jz is_snake
	cmp bl, 2
	jz is_snake
	cmp bl, 1
	jz is_snake
	jmp write
is_snake:
	mov bl, 254
write:
	mov byte [es:si], bl
	inc di
	add si, 2
	cmp si, 4000
	jnz next1
	ret

delay:
    push dx
    mov dx,0x0000
    jm:
        inc dx
        cmp dx,0xffff
    jne jm
    pop dx
    ret
	
board_write:
	mov di, board
	mov al, 80
	mul dl
	add ax, cx
	add di, ax
	mov byte [di], bl
	ret

board_read:
	mov di, board
	mov al, 80
	mul dl
	add ax, cx
	add di, ax
	mov bl, [di]
	ret


create_food:
	try_again:
		mov ah, 0
		int 1ah ; cx = hi dx = low
		mov ax, dx
		and ax, 0fffh
		mul dx
		mov dx, ax
		mov ax, dx
		mov cx, 2000
		xor dx, dx
		div cx ; dx = rest of division
		mov bx, dx
		mov di, board
		mov al, [di + bx]
		cmp al, ' ' ; create food just in empty position
		jnz try_again
		mov byte [di + bx], '*'
		ret
		
		
check_snake_new_position:
		mov ch, 0
		mov cl, [snake_head_x]
		mov dh, 0
		mov dl, [snake_head_y]
		call board_read
		cmp bl, 8
		jle set_game_over
		cmp bl, '*'
		je food
		cmp bl, ' '
		je empty_space
	set_game_over:
		cmp al, 1
		mov byte [is_game_over], al 
	write_new_head:
		mov bl, 1
		mov ch, 0
		mov cl, [snake_head_x]
		mov ch, 0
		mov dl, [snake_head_y]
		call board_write
		ret
	food:
		inc dword [score]
		cmp dword[score], 3
			jne updated_level
			mov dword[level], 2
		cmp dword[score], 7
			jne updated_level
			mov dword[level], 3
		cmp dword[score], 15
			jne updated_level
			mov dword[level], 4
	updated_level:
		call write_new_head
		call create_food
		jmp end1
	empty_space:
		call update_snake_tail
		call write_new_head
	end1:
		ret			


update_snake_tail:
		mov al, [snake_tail_y]
		mov byte [snake_tail_previous_y], al
		mov al, [snake_tail_x]
		mov byte [snake_tail_previous_x], al
		mov ch, 0
		mov cl, [snake_tail_x]
		mov dh, 0
		mov dl, [snake_tail_y]
		call board_read
		cmp bl, 8 ; up
		jz up1
		cmp bl, 4 ; down
		jz down1
		cmp bl, 2; left
		jz left1
		cmp bl, 1; right
		jz right1
		jmp end2 
	up1:
		dec word [snake_tail_y]
		jmp end2
	down1:
		inc word [snake_tail_y]
		jmp end2
	left1:
		dec word [snake_tail_x]
		jmp end2
	right1:
		inc word [snake_tail_x]
	end2:
		mov bl, ' '
		mov ch, 0
		mov cl, [snake_tail_previous_x]
		mov ch, 0
		mov dl, [snake_tail_previous_y]
		call board_write
	ret

update_snake_head:
		mov al, [snake_head_y]
		mov byte [snake_head_previous_y], al
		mov al, [snake_head_x]
		mov byte [snake_head_previous_x], al
		mov ah, [snake_direction]
		cmp ah, 8 ; up
		jz up
		cmp ah, 4 ; down
		jz down
		cmp ah, 2; left
		jz left
		cmp ah, 1; right
		jz right
	up:
		dec word [snake_head_y]
		jmp end
	down:
		inc word [snake_head_y]
		jmp end
	left:
		dec word [snake_head_x]
		jmp end
	right:
		inc word [snake_head_x]
	end:
		mov bl, [snake_direction]
		mov ch, 0
		mov cl, [snake_head_previous_x]
		mov dl, [snake_head_previous_y]
		call board_write
		ret
			
			
			
update_snake_direction:
	mov ah, 1	
	int 0x16
	jz done
	mov ah, 0h
	int 0x16
	cmp al, 'w'
		je w
	cmp al, 'a'
		je a
	cmp al, 's'
		je s
	cmp al, 'd'
		je d
	cmp al, 'x'
		je exit	
	s:	
		mov byte [snake_direction], 4
		jmp done			
	a:	
		mov byte [snake_direction], 2
		jmp done	
	w:  
		mov byte [snake_direction], 8
		jmp done	
	d:	
		mov byte [snake_direction], 1
		jmp done	
done:
			ret	

wait_for_key:
    xor ah, ah       
    int 0x16
	cmp al, 'x'
	jne wait_for_key	
    ret

start:
    call board_clear
	call print_main
	call wait_for_key
    call board_clear
    call draw_border
	call create_food
playing_loop:
		mov si, 2
		call check_level
		
		call update_snake_direction
		call update_snake_head
		call check_snake_new_position
		call print_score
		call board_render
	
		mov al, [is_game_over]
		cmp al, 0
		jz playing_loop
		
exit:	
	call board_clear
	call print_Gameover	
	call board_render
    mov ax, 0x4c00
    int 0x21
