;********************;
;* 8255薄膜按键实验 *;
;********************;
include io.inc
 a8255        equ 288H    ;8255 A口    
 c8255        equ 28aH    ;8255 C口
 k8255        equ 28bH    ;8255控制口
data segment
 table1    dw 0770h,0B70h,0D70h,0E70h,07B0h,0BB0h,0DB0h,0EB0h
           dw 07D0h,0BD0h,0DD0h,0ED0h,07E0h,0BE0h,0DE0h,0EE0h    ;键盘扫描码表
 LED       DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH
           DB 39h,5EH,79h,71h,0ffh   ;LED段码表，0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f
 char  db '0123456789ABCDEF'                    ;字符表
mes   db 0ah,0dh,'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH E ',0ah,0dh,'$'
 key_in db 0h
data ends
stacks segment stack    ;堆栈空间
     db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
    mov ax,stacks
        mov ss,ax
        mov dx,offset mes       ;显示提示信息
        mov ah,09
        int 21h  
        MOV DX,k8255            ;初始化8255控制字
        mov al,88h
        out dx,al          
main_key:
        call key                ;get a char in (key_in) and display it
        call dispbb
        call dispcrlf
        jmp main_key
        mov ax,4c00h            ;if (dl)='E' return to EXIT!
        int 21h                 ;退出
key proc near
key_loop:
        mov ah,1
        int 16h
        jnz exit                    ;pc键盘有键按下则退出
       
        mov dx,c8255
        in al,dx                    ;读行扫描值
        and al,0f0h
        cmp al,0f0h
        jz key_loop                                          ;未发现有键按下则转
        mov ah, al
        
key_waitup:
        mov dx,c8255
        in al,dx           ;读行扫描值
        and al,0f0h
        cmp al,0f0h
        jnz key_waitup     ;按键未抬起转
        call delay         ;delay for amoment
        mov al, ah
        ret
exit:        mov byte ptr key_in,'E'
        ret
key endp
delay proc near
        push ax            ;delay 50ms--100ms
        mov ah,0
        int 1ah
        mov bx,dx
delay1:
        mov ah,0
        int 1ah
        cmp bx,dx
        jz delay1
        mov bx,dx
delay2:
        mov ah,0
        int 1ah
        cmp bx,dx
        jz delay2
        pop ax
       ret
delay endp
DISPLY    PROC NEAR
        PUSH ax
        MOV BX,OFFSET LED
        MOV AL,byte ptr key_in
      SUB al,30h
      CMP al,09h
      JNG  DIS2
       SUB al,07h
DIS2:  XLAT
         MOV DX,a8255
         OUT DX,AL                     ;输出显示数据，段码
       POP AX
         RET
DISPLY    ENDP

code ends
end start
