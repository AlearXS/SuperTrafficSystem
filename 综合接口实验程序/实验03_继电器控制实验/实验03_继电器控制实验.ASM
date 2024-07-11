;***************************;
;*     继电器控制          *;
;***************************;
io8253a         equ 280h
io8253b         equ 281h
io8253c         equ 283h
io8255a         equ 288h
io8255c         equ 28ah
io8255ctl       equ 28bh
code segment
      assume cs:code
start:  mov dx,io8255ctl         
        mov al,90h
lll:    out dx,al
        mov dx,io8255c
        mov al,01           ;将PC0置位
    out dx,al
    call delay          ;延时5s
           mov al,0            ;将PC0复位
    out dx,al
    call delay          ;延时5s
    jmp lll             ;转lll
delay proc near           ;延时子程序
    push dx
        mov dx,io8253c         ;设8254计数器为方式3
    mov al,36h
    out dx,al
        mov dx,io8253a
        mov ax,10000          ;写入计数器初值10000
    out dx,al
    mov al,ah
    out dx,al
        mov dx,io8253c
    mov al,70h          ;设计数器1为工作方式0
    out dx,al
        mov dx,io8253b
    mov ax,500          ;写入计数器初值500
    out dx,al
    mov al,ah
    out dx,al
ll2:    mov ah,06            ;是否有键按下
    mov dl,0ffh
    int 21h
    jne exit            ;若有则转exit
        mov dx,io8255a
    in  al,dx           ;查询8255的Pa0是否为高电平
        and al,01h
    jz  ll2             ;若不是则继续
    pop dx
    ret                 ;定时时间到，子程序返回
exit:   mov ah,4ch
    int 21h
delay endp
    code ends
    end start
