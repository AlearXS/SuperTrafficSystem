 ;*******************************;
;*    DMA传送实验（块传送）    *;
;*                             *;
;*******************************;
io8237        equ 280h     ;从8237地址
code segment
     assume cs:code
start:
     mov ax,0D000h
     mov es,ax
     mov bx,4000h
     mov cx,0ffH;传输个数
     mov dl,40h;字符A
rep1:    inc dl
     mov es:[bx],dl
     inc bx
     cmp dl,5ah
     jnz ss1
     mov dl,40h
ss1: loop rep1                   ;主8237为主控制器,DRQ0为USB接口控制使用,不要对
                                 ;其复位和控制寄存器初始化
     mov dx,1bh                  ;主8237为级联方式
     mov al,0cdh
     out dx,al
     mov al,01                   ;清通道屏蔽DRQ1
     out 1ah,al                  ;启动DMA

     mov dx,io8237+08h            ;关闭从8237
     mov al,04h
     out dx,al
     mov dx,io8237+0dh            ;复位从8237
     mov al,00h
     out dx,al 
     mov dx,io8237+0ch            ;清字节指针 
     mov al,00
     out dx,al             
     mov dx,io8237+02h            ;写目的地址低位
     mov al,00h
     out dx,al
     mov dx,io8237+02h            ;写目的地址高位
     mov al,42h
     out dx,al
     mov dx,io8237+03h            ;传送字节数低位
     mov al,0ffh
     out dx,al     
     mov dx,io8237+03h            ;传送字节数高位
     mov al,00h
     out dx,al   
     mov dx,io8237+00h            ;源地址低位
     mov al,00h
     out dx,al
     mov dx,io8237+00h            ;源地址高位
     mov al,40h
     out dx,al
     mov dx,io8237+0bh            ;通道1写传输,地址增
     mov al,85h
     out dx,al
     mov dx,io8237+0bh            ;通道0读传输,地址增
     mov al,88h
     out dx,al
     mov dx,io8237+08h            ;DREQ低电平有效,存储器到存储器,开启从8237
     mov al,41h
     out dx,al
     mov dx,io8237+09h            ;通道1请求
     mov al,04h              
     out dx,al

     mov cx,0F000h
delay:  loop delay
     mov ax,0D000h                 
     mov es,ax
     mov bx,04200h;目的地址起始
     mov cx,0ffh;读出字符个数
rep2:mov dl,es:[bx]
     mov ah,02h
     int 21h
     inc bx
     loop rep2
     mov ax,4c00h
     int 21h
code ends
end start
