 ;*******************************;
;*    DMA����ʵ�飨�鴫�ͣ�    *;
;*                             *;
;*******************************;
io8237        equ 280h     ;��8237��ַ
code segment
     assume cs:code
start:
     mov ax,0D000h
     mov es,ax
     mov bx,4000h
     mov cx,0ffH;�������
     mov dl,40h;�ַ�A
rep1:    inc dl
     mov es:[bx],dl
     inc bx
     cmp dl,5ah
     jnz ss1
     mov dl,40h
ss1: loop rep1                   ;��8237Ϊ��������,DRQ0ΪUSB�ӿڿ���ʹ��,��Ҫ��
                                 ;�临λ�Ϳ��ƼĴ�����ʼ��
     mov dx,1bh                  ;��8237Ϊ������ʽ
     mov al,0cdh
     out dx,al
     mov al,01                   ;��ͨ������DRQ1
     out 1ah,al                  ;����DMA

     mov dx,io8237+08h            ;�رմ�8237
     mov al,04h
     out dx,al
     mov dx,io8237+0dh            ;��λ��8237
     mov al,00h
     out dx,al 
     mov dx,io8237+0ch            ;���ֽ�ָ�� 
     mov al,00
     out dx,al             
     mov dx,io8237+02h            ;дĿ�ĵ�ַ��λ
     mov al,00h
     out dx,al
     mov dx,io8237+02h            ;дĿ�ĵ�ַ��λ
     mov al,42h
     out dx,al
     mov dx,io8237+03h            ;�����ֽ�����λ
     mov al,0ffh
     out dx,al     
     mov dx,io8237+03h            ;�����ֽ�����λ
     mov al,00h
     out dx,al   
     mov dx,io8237+00h            ;Դ��ַ��λ
     mov al,00h
     out dx,al
     mov dx,io8237+00h            ;Դ��ַ��λ
     mov al,40h
     out dx,al
     mov dx,io8237+0bh            ;ͨ��1д����,��ַ��
     mov al,85h
     out dx,al
     mov dx,io8237+0bh            ;ͨ��0������,��ַ��
     mov al,88h
     out dx,al
     mov dx,io8237+08h            ;DREQ�͵�ƽ��Ч,�洢�����洢��,������8237
     mov al,41h
     out dx,al
     mov dx,io8237+09h            ;ͨ��1����
     mov al,04h              
     out dx,al

     mov cx,0F000h
delay:  loop delay
     mov ax,0D000h                 
     mov es,ax
     mov bx,04200h;Ŀ�ĵ�ַ��ʼ
     mov cx,0ffh;�����ַ�����
rep2:mov dl,es:[bx]
     mov ah,02h
     int 21h
     inc bx
     loop rep2
     mov ax,4c00h
     int 21h
code ends
end start
