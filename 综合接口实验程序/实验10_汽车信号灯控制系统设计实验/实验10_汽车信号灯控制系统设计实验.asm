data segment                                              ;���ݶ�
proth    equ      280h
protlr    equ       298h
protly    equ      290h 
io8255a equ 288H                                        ;8255��A�ڵ�ַ
io8255b equ 289H                                        ;8255��B�ڵ�ַ
io8255c equ 28aH     ;8255��C�ڵ�ַ
io8255con equ 28bH   
min1      DB  00h,01h,02h,03h,04h,05h,06h,07h
count     db  0
BUFF      DB  0fh,09h,0fh,00h,0cfh,89h,89h,0ffh ;8255A�Ŀ��ƿڵ�ַ
ctr    db 'enter c key to continue!',0ah,0dh   ;�����ʼ��ʾ��Ϣ
       db 'enter other keys to exit to dos!',0ah,0dh,'$'
ctr01  db '1. zuo zhuan wan...',0ah,0dh,'$';��ת��ʱ��ʾ��Ϣ���������ƣ�
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
Sstack segment stack                                          ;��ջ��
sta dw 50 dup(?)
Sstack ends
code segment                                               ;�����
     assume cs:code,ds:data,es:data,ss:Sstack
main proc far
start: push ds
       sub ax,ax
       push ax
       mov ax,data
       mov ds,ax
       mov es,ax 
 ccc:  mov dx,offset ctr     ;��ʾ��ʾ��Ϣ
       mov ah,09h
       int 21h
      mov ah,01h
       int 21h
       cmp al,'c'            ;������'C'�������ִ�У����򷵻ص�DOS
       jz eee
       ;jmp exit
agn:    mov    cx,80h
d2:      mov    ah,01h
      push    cx
      mov    cx,0008h
      mov    si,offset min1
next:     mov    al,[si]
      mov    bx,offset buff
      xlat                             ;�õ���һ����
      mov    dx,proth
      out    dx,al
      mov    al,ah
      mov    dx,protlr
      out    dx,al                       ;��ʾ��һ�к�
      mov al,0
      out dx,al
      shl    ah,01
      inc    si
      push    cx
      mov    cx,0ffh;ffh
delay2:      loop  delay2                       ;��ʱ
      pop    cx
      loop    next
      pop    cx
      call    delay00
      loop    d2
      mov    al,00
      mov    dx,protlr
      out    dx,al 
agn1:      mov    cx,80h                     ;agn1Ϊ��ʾ��ɫ
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
eee:  mov dx,io8255con ;��8255A���뷽ʽ������89H ����ΪA�����,C������
       mov al,89h
       out dx,al 
       mov dx,io8255c        ;��4�����ص�״̬����AL
       in  al,dx 
       mov cx,0020h          ;����ѭ������
bb1:   cmp al,01h            ;��al��ֵ������01H��0AH�Ƚ�
jnz bb2 ;����01H��תbb1ִ��,��������ж�����Ļ����ʾ��Ӧ��ʾ��Ϣ��˳��ִ��
 mov dx,offset ctr01;��ת��״̬��ʵ����յ��״̬Ϊ��������������������
 mov ah,09h
 int 21h               ;����09���жϣ�����Ļ����ʾ������������ת��״̬
 mov dx,io8255a
left: mov al,00101010b ;��յ��״̬Ϊ�������������������������λûӰ�죩
       out dx,al
       call delay0        ;����ʱ�ӳ���
       loop left
       jmp ccc
bb2:   cmp al,02h
       jnz bb3
       mov dx,offset ctr02
;��ת��״̬��ʵ����յ��״̬Ϊ������������������
       mov ah,09h
       int 21h
       mov dx,io8255a
right: mov al,00010101b ;��յ��״̬Ϊ������������������
       out dx,al
       call delay0
       loop right
       jmp ccc
bb3:   cmp al,03h
       jnz bb4
       mov dx,offset ctr03 ;�������غ���
       mov ah,09h
       int 21h
       mov dx,io8255a
hurry: mov al,00000000b  ;��յ��״̬Ϊ������������������������
       out dx,al
       call delay0
       mov al,00111111b
       out dx,al
       call delay0
       loop hurry
       jmp ccc
bb4:   cmp al,04h
       jnz bb5
       mov dx,offset ctr04    ;ɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
break:  mov al,00000011b ;��յ��״̬Ϊ����������������
       out dx,al
       call delay0
       loop break
       jmp ccc
bb5:   cmp al,05h
       jnz bb6
       mov dx,offset ctr05  ;��ת��ɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
leftbreak: mov al,00001010b  ;��յ��״̬Ϊ��������������������
           out dx,al
           call delay0
           loop leftbreak
           jmp ccc
bb6:   cmp al,06h
       jnz bb7
       mov dx,offset ctr06   ;��ת��ɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
rightbreak: mov al,00000101b ;��յ��״̬Ϊ������������������
            out dx,al
            call delay0
            loop rightbreak
            jmp ccc
bb7:   cmp al,07h
       jnz bb8
       mov dx,offset ctr07   ;����ɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
hurrybreak: mov al,00111111b ;��յ��״̬Ϊ������������������������
            out dx,al
            call delay0
            loop hurrybreak
            jmp ccc  
bb8:   cmp al,08h
       jnz bb9
       mov dx,offset ctr08   ;������תɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
hurryleftbreak: mov al,00111111b ;��յ��״̬Ϊ������������������������
                out dx,al
                call delay0
                mov al,00011111b
                out dx,al
                call delay0
                loop hurryleftbreak
                jmp ccc
bb9:   cmp al,09h
       jnz bb10
       mov dx,offset ctr09   ;������תɲ��
       mov ah,09h
       int 21h
       mov dx,io8255a
hurryrightbreak:mov al,00111111b ;��յ��״̬Ϊ������������������������
                 out dx,al
                 call delay0
                 mov al,00101111b
                 out dx,al
                 call delay0
                 loop hurryrightbreak
                 jmp ccc
bb10:  cmp al,0ah
       jnz bb11
       mov dx,offset ctr10  ;ͣ��
       mov ah,09h
       int 21h
       mov dx,io8255a
stop:  mov al,00001100b       ;��յ��״̬Ϊ��������������������
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
delay  proc near                            ;��ʱ�ӳ���
       push cx
       mov cx,0ffh
pp:    loop pp
       pop cx
       ret
delay  endp
delay0 proc near                            ;��ʱ�ӳ���
       push cx
       push ax
       mov cx,0080h
pp0:   call delay
       loop pp0
       pop ax
       pop cx
       ret
delay0 endp
DELAY00      PROC    NEAR                           ;�ӳ��ӳ���
      push    cx
      mov    cx,0ffh;ffh
cccc:      loop    cccc
      pop    cx
      ret
DELAY00      ENDP   
code   ends
       end start
