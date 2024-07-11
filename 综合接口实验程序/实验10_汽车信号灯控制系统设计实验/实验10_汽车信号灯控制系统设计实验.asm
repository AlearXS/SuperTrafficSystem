data segment                                              ;数据段
proth    equ      280h
protlr    equ       298h
protly    equ      290h 
io8255a equ 288H                                        ;8255的A口地址
io8255b equ 289H                                        ;8255的B口地址
io8255c equ 28aH     ;8255的C口地址
io8255con equ 28bH   
min1      DB  00h,01h,02h,03h,04h,05h,06h,07h
count     db  0
BUFF      DB  0fh,09h,0fh,00h,0cfh,89h,89h,0ffh ;8255A的控制口地址
ctr    db 'enter c key to continue!',0ah,0dh   ;程序初始提示信息
       db 'enter other keys to exit to dos!',0ah,0dh,'$'
ctr01  db '1. zuo zhuan wan...',0ah,0dh,'$';左转弯时提示信息（以下类似）
ctr02  db '2. you zhuan wan.....',0ah,0dh,'$'
ctr03  db '3. jin ji kai guan.....',0ah,0dh,'$'
ctr04  db '4. sha che.....',0ah,0dh,'$'
ctr05  db '5. zuo zhuan wan sha che.....',0ah,0dh,'$'
ctr06  db '6. you zhuan wan sha che.....',0ah,0dh,'$'
ctr07  db '7. jin ji sha che.....',0ah,0dh,'$'
ctr08  db '8. jin ji zuo zhuan sha che.....',0ah,0dh,'$'
ctr09  db '9. jin ji you zhuan sha che.....',0ah,0dh,'$'
ctr10  db '10. ting kao.....',0ah,0dh,'$'
data ends
Sstack segment stack                                          ;堆栈段
sta dw 50 dup(?)
Sstack ends
code segment                                               ;代码段
     assume cs:code,ds:data,es:data,ss:Sstack
main proc far
start: push ds
       sub ax,ax
       push ax
       mov ax,data
       mov ds,ax
       mov es,ax 
 ccc:  mov dx,offset ctr     ;显示提示信息
       mov ah,09h
       int 21h
      mov ah,01h
       int 21h
       cmp al,'c'            ;若输入'C'，则继续执行，否则返回到DOS
       jz eee
       ;jmp exit
agn:    mov    cx,80h
d2:      mov    ah,01h
      push    cx
      mov    cx,0008h
      mov    si,offset min1
next:     mov    al,[si]
      mov    bx,offset buff
      xlat                             ;得到第一行码
      mov    dx,proth
      out    dx,al
      mov    al,ah
      mov    dx,protlr
      out    dx,al                       ;显示第一行红
      mov al,0
      out dx,al
      shl    ah,01
      inc    si
      push    cx
      mov    cx,0ffh;ffh
delay2:      loop  delay2                       ;延时
      pop    cx
      loop    next
      pop    cx
      call    delay00
      loop    d2
      mov    al,00
      mov    dx,protlr
      out    dx,al 
agn1:      mov    cx,80h                     ;agn1为显示黄色
d1:       mov    si,offset min1
      mov    ah,01
      push    cx
      mov    cx,0008h
next1:      mov    al,[si]
      mov    bx,offset buff
      xlat
      mov    dx,proth
      out    dx,al
      mov    al,ah
      mov    dx,protly
      out    dx,al
      mov al,0
      out dx,al
      shl    ah,01
      inc    si
      push    cx
      mov    cx,0ffh;ffh
delay1:      loop  delay1
      mov    cx,0ffh;ffh
delay3:      loop  delay3
      pop    cx
      loop    next1
      pop    cx
      call    delay00
      loop    d1
      mov    al,00
      mov    dx,protly
      out    dx,al
      jmp agn
     mov ax,4c00h
       int 21h
eee:  mov dx,io8255con ;给8255A送入方式控制字89H 设置为A口输出,C口输入
       mov al,89h
       out dx,al 
       mov dx,io8255c        ;将4个开关的状态送入AL
       in  al,dx 
       mov cx,0020h          ;设置循环次数
bb1:   cmp al,01h            ;将al的值依次与01H到0AH比较
jnz bb2 ;不是01H则转bb1执行,是则调用中断在屏幕上显示相应提示信息，顺序执行
 mov dx,offset ctr01;左转弯状态，实现六盏灯状态为：闪、灭、闪、灭、闪、灭
 mov ah,09h
 int 21h               ;调用09号中断，在屏幕上显示现在正处于左转弯状态
 mov dx,io8255a
left: mov al,00101010b ;六盏灯状态为：亮、灭、亮、灭、亮、灭（最高两位没影响）
       out dx,al
       call delay0        ;调延时子程序
       loop left
       jmp ccc
bb2:   cmp al,02h
       jnz bb3
       mov dx,offset ctr02
;右转弯状态，实现六盏灯状态为：灭、亮、灭、亮、灭、亮
       mov ah,09h
       int 21h
       mov dx,io8255a
right: mov al,00010101b ;六盏灯状态为：灭、亮、灭、亮、灭、亮
       out dx,al
       call delay0
       loop right
       jmp ccc
bb3:   cmp al,03h
       jnz bb4
       mov dx,offset ctr03 ;紧急开关合上
       mov ah,09h
       int 21h
       mov dx,io8255a
hurry: mov al,00000000b  ;六盏灯状态为：闪、闪、闪、闪、闪、闪
       out dx,al
       call delay0
       mov al,00111111b
       out dx,al
       call delay0
       loop hurry
       jmp ccc
bb4:   cmp al,04h
       jnz bb5
       mov dx,offset ctr04    ;刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
break:  mov al,00000011b ;六盏灯状态为：灭、灭、灭、灭、亮、亮
       out dx,al
       call delay0
       loop break
       jmp ccc
bb5:   cmp al,05h
       jnz bb6
       mov dx,offset ctr05  ;左转弯刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
leftbreak: mov al,00001010b  ;六盏灯状态为：亮、灭、亮、灭、亮、灭
           out dx,al
           call delay0
           loop leftbreak
           jmp ccc
bb6:   cmp al,06h
       jnz bb7
       mov dx,offset ctr06   ;右转弯刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
rightbreak: mov al,00000101b ;六盏灯状态为：灭、亮、灭、亮、灭、亮
            out dx,al
            call delay0
            loop rightbreak
            jmp ccc
bb7:   cmp al,07h
       jnz bb8
       mov dx,offset ctr07   ;紧急刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
hurrybreak: mov al,00111111b ;六盏灯状态为：亮、亮、亮、亮、亮、亮
            out dx,al
            call delay0
            loop hurrybreak
            jmp ccc  
bb8:   cmp al,08h
       jnz bb9
       mov dx,offset ctr08   ;紧急左转刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
hurryleftbreak: mov al,00111111b ;六盏灯状态为：亮、亮、亮、亮、亮、亮
                out dx,al
                call delay0
                mov al,00011111b
                out dx,al
                call delay0
                loop hurryleftbreak
                jmp ccc
bb9:   cmp al,09h
       jnz bb10
       mov dx,offset ctr09   ;紧急右转刹车
       mov ah,09h
       int 21h
       mov dx,io8255a
hurryrightbreak:mov al,00111111b ;六盏灯状态为：亮、亮、亮、亮、亮、亮
                 out dx,al
                 call delay0
                 mov al,00101111b
                 out dx,al
                 call delay0
                 loop hurryrightbreak
                 jmp ccc
bb10:  cmp al,0ah
       jnz bb11
       mov dx,offset ctr10  ;停靠
       mov ah,09h
       int 21h
       mov dx,io8255a
stop:  mov al,00001100b       ;六盏灯状态为：灭、灭、亮、亮、闪、闪
       out dx,al
       call delay0
       mov al,00001111b
       out dx,al
       call delay0
       loop stop
       jmp ccc
       
bb11:  jmp ccc
       ret   
main   endp
delay  proc near                            ;延时子程序
       push cx
       mov cx,0ffh
pp:    loop pp
       pop cx
       ret
delay  endp
delay0 proc near                            ;延时子程序
       push cx
       push ax
       mov cx,0080h
pp0:   call delay
       loop pp0
       pop ax
       pop cx
       ret
delay0 endp
DELAY00      PROC    NEAR                           ;延迟子程序
      push    cx
      mov    cx,0ffh;ffh
cccc:      loop    cccc
      pop    cx
      ret
DELAY00      ENDP   
code   ends
       end start
