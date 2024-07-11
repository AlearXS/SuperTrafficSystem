;********************************
;*     本程序为模拟抢答器       *
;********************************
data  segment
proth          equ 280h
prothlr        equ 298h
prothly        equ 290h
io8255a        equ 28ah
io8255b        equ 28bh
io8255c        equ 288h
led      db   3fh,06h,5bh,4fh,66h,6dh,7dh,07h ;数码表
minl     db   00h,01h,02h,03h,04h,05h,06h,07h
cunt     db   0
buff     db   81h,42h,24h,0ffh,00h,0ffh,81h,0ffh ;ok
data ends
code  segment
    assume cs:code,ds:data
start: mov ax,data
       mov ds,ax
       mov dx,io8255b        ;设8255为A口输出,C口输入
       mov ax,89h
       out dx,al
       mov bx,offset led  ;使BX指向段码管首址
sss:   mov dx,io8255a
       in  al,dx          ;从8255的C口输入数据
       or  al,al          ;比较是否为0
       je  sss            ;若为0,则表明无键按下，转sss
       mov cl,0ffh        ;cl作计数器,初值为-1
rr:   shr al,1
    inc cl
    jnc rr
    mov al,cl
    xlat
    mov dx,io8255c
    out dx,al
start2: mov ax,data
        mov ds,ax
agin:   mov cx,80h
d2:     mov ah,01h
        push cx
        mov  cx,0008h
        mov  si,offset minl
next:   mov  al,[si]
        mov  bx,offset buff
        xlat
        mov  dx,proth
        out  dx,al
        mov  al,ah
        mov  dx,prothlr
        out  dx,al
        mov  al,0
        out  dx,al
         shl  ah,01
        inc  si
        push  cx
        mov   cx,0ffh
delay2: loop  delay2
        pop   cx
        loop  next
        pop   cx
        call  delay
        loop  d2
        mov   al,00
        mov   dx,prothlr
        out   dx,al
agn1:   mov   cx,80h
d1:     mov   si,offset minl
        mov   ah,01
        push  cx
        mov   cx,0008h
next1:  mov   al,[si]
        mov   bx,offset buff
        xlat
        mov  dx,proth
        out  dx,al
        mov  al,ah
        mov  dx,prothly
        out  dx,al
        mov  al,0
        out  dx,al
        shl  ah,01
        inc  si
        push cx
        mov  cx,0ffh
delay1: loop  delay1
       ; mov   cx,0ffh
delay3:  loop delay3
         pop  cx
        loop  next1
        pop   cx
        call  delay
       loop   d1
       mov    al,00
       mov    dx,prothly
       out    dx,al       
wai:  mov ah,1
    int 21h
    cmp al,20h         ;是否为空格
    jne eee            ;不是,转eee
    mov al,0           ;是,关灭灯
    mov dx,io8255c
    out dx,al
    jmp start
delay   proc  near
        push  cx
        mov   cx,0ffh
ccc:    loop  ccc
        pop   cx
        ret
delay   endp
a2      proc  near
        mov   ax,4c00h
        int   21h
        ret
a2      endp
eee:    mov ah,4ch         ;返回
    int 21h
code  ends
    end start
