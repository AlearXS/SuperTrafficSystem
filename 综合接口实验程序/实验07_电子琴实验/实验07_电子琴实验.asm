;*******************************;
;*         ������ʵ��          *;
;*******************************;
;��ʵ��������£�
;8254 CLK0��1MHZʱ�ӣ�GATE0��8255��PA1��OUT0�����������1��CS��280H��287H��
;8255 PA0�����������2��CS��288H��28FH��
data segment
io8255a     equ 289h
io8255ctl   equ 28bh
io8253a     equ 282h
io8253b     equ 283h
table dw 524,588,660,698,784,880,988,1048;������
;table dw 262,294,330,347,392,440,494,524;������
msg db 'Press 1,2,3,4,5,6,7,8,ESC:',0dh,0ah,'$'
data ends

code segment
assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax

    mov dx,offset msg
    mov ah,9
    int 21h              ;��ʾ��ʾ��Ϣ
sing:    
    mov ah,7
    int 21h              ;�Ӽ��̽����ַ�,������
    cmp al,1bh
    je finish            ;��ΪESC��,��תfinish
    cmp al,'1'
    jl  sing
    cmp al,'8'
    jg sing              ;������'1'-'8'֮��תsing
    
    sub al,31h
    shl al,1             ;תΪ���ƫ����
    mov bl,al            ;����ƫ�Ƶ�bx
    mov bh,0
    
    mov ax,4240H         ;������ֵ = 1000000 / Ƶ��, ���浽AX
    mov dx,0FH
    div word ptr[table+bx]
    mov bx,ax
    
    mov dx,io8253b          ;����8254��ʱ��0��ʽ3, �ȶ�д���ֽ�, �ٶ�д���ֽ�
    mov al,00110110B
    out dx,al

    mov dx,io8253a         
    mov ax,bx
    out dx,al            ;д������ֵ���ֽ�
    
    mov al,ah
    out dx,al            ;д������ֵ���ֽ�
    
    mov dx,io8255ctl          ;����8255 A�����
    mov al,10000000B
    out dx,al
    
    mov dx,io8255a            
    mov al,03h
    out dx,al            ;��PA1PA0 = 11(��������)
    call delay           ;��ʱ
    mov al,0h
    out dx,al            ;��PA1PA0 = 00(��������)
    
    jmp sing
finish:
    mov ax,4c00h
    int 21h
    
delay proc near          ;��ʱ�ӳ���
    push cx
    push ax
    mov ax,15
x1: mov cx,0ffffh
x2: dec cx
    jnz x2
    dec ax
    jnz x1
    pop ax
    pop cx
    ret
delay endp
code ends
end start
