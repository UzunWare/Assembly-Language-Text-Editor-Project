[org 100h]
jmp start

message: db 'Press enter to start typing . . .',0
message2: db 'B y e e . . .',0
message3: db 'Total Characters: ',0
message4: db 'Line: ',0
message5: db 'Col: ',0
col: times 25 db 0
count: db 0
indexCol: db 0
header: db '- - - Text Editor - - -',0
totalCount: dw 0
line: times 160 db '_'
linelen: db 0
text: times 2000 db ' '



clrscreen:
push word 0xb800
pop es
xor di,di
mov cx,2000
mov ax,0x0720

cld
rep stosw
ret


printstr:
mov bp,sp
mov si,[bp+2]
push word 0xb800
pop es
xor di,di
mov ah,0x95

print:
lodsb
cmp al,0
je exit
stosw
jmp print

exit:
ret





printResult:
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov si,message3
push word 0xb800
pop es
xor di,di
mov di,116
mov ah,0x75

print2:
lodsb
cmp al,0
je continue2
stosw
jmp print2


continue2:
xor ax,ax
xor cx,cx
xor bx,bx

mov ax,[totalCount]
mov bx,10

nextdigit:
mov dx,0
div bx
add dl,0x30
push dx
inc cx
cmp ax,0
jnz nextdigit

nextpos:
pop dx
mov dh,0x75
mov [es:di],dx
add di,2
Loop nextpos

exit2:
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret






printLines:
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

sub dh,2
mov si,message4
push word 0xb800
pop es
xor di,di
mov di,60
mov ah,0x75

print3:
lodsb
cmp al,0
je continue3
stosw
jmp print3


continue3:
xor ax,ax
xor cx,cx
xor bx,bx

mov al,dh
mov bx,10

nextdigit2:
mov dx,0
div bx
add dl,0x30
push dx
inc cx
cmp ax,0
jnz nextdigit2

nextpos2:
pop dx
mov dh,0x75
mov [es:di],dx
add di,2
Loop nextpos2

exit3:
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret




printCol:
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov si,message5
push word 0xb800
pop es
xor di,di
mov di,80
mov ah,0x75

print4:
lodsb
cmp al,0
je continue4
stosw
jmp print4


continue4:
xor ax,ax
xor cx,cx
xor bx,bx

mov al,dl
mov bx,10

nextdigit3:
mov dx,0
div bx
add dl,0x30
push dx
inc cx
cmp ax,0
jnz nextdigit3

nextpos3:
pop dx
mov dh,0x75
mov [es:di],dx
add di,2
Loop nextpos3

exit4:
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret




printHeader:
mov si,header
push word 0xb800
pop es
mov di,0
mov ah,0x75

headerPrnt:
lodsb
cmp al,0
je exitHeader
stosw
jmp headerPrnt

exitHeader:
ret








start:
call clrscreen

mov bx,message
push bx
call printstr

mov ah,00h
int 16h

cmp al,13
je startProgram
jmp quitProgram

startProgram:
call clrscreen

call printHeader

mov al, 1
mov bh, 0
mov bl, 0111_0101b
mov cx, linelen-line ;dizi boyutu hesaplama
mov dl, 0
mov dh, 1
mov bp, line
mov ah, 13h
int 10h

;positining the cursor
mov dh,2
mov dl,0
mov bh,0
mov ah,2h
int 10h

mainProgram:
call printResult
call printLines
call printCol


;taking input
mov ah,00h
int 16h

;quit the program if ESC is pressed!!!
cmp al,27
je quitProgram

;remove a character if backspace is pressed!!!
cmp al,8
je remove

;go to new line if enter is pressed!!!
cmp al,13
je newLine
jmp continue


remove:
cmp dh,2
je firstLine
jmp notFirstLine

firstLine:
cmp dl,0
je dontIncrease
jmp notFirstColumn

notFirstLine:
cmp dl,0
je decreaseRow
jmp notFirstColumn

decreaseRow:
dec byte[indexCol]
mov si,[indexCol]
mov cl,[col+si]
mov [count],cl
mov dl,[col+si]
dec dh
mov ah,02h
int 10h
jmp return


notFirstColumn: 
dec dl
mov ah,2h
int 10h
dec byte[count]
cmp word[totalCount],0
je dontIncrease

dec word[totalCount]

dontIncrease:
mov ah,0ah
mov al,' '
mov cx,1
int 10h
jmp return

continue:
;printing character on the screen
mov ah,0ah
mov cx,1
mov bh,0
int 10h

inc dl
mov ah,2h
int 10h
mov si,[totalCount]
mov [text+si],al
inc word[totalCount]
inc byte[count]
cmp byte[count],80
jne return

newLine:
mov si,[indexCol]
mov cl,[count]
mov byte[col+si],cl
mov byte[count],0
inc byte[indexCol]
inc dh
xor dl,dl

mov ah,02h
int 10h

return:
jmp mainProgram

quitProgram:
call clrscreen

mov bx,message2
push message2
call printstr


mov ah,00h
int 16h
mov ax,0x4c00
int 21h