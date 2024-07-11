;*******************
;*     录音机      *
;*******************
data segment
 luport        equ 29ah                  ;录音口地址
 fangport      equ 290h                  ;放音口地址
 
 data_qu  db 10000 dup(?)                         ;录音数据存放数据区
 news_1   db 'Press any key to record:',24h       ;录音提示
 news_2   db 0dh,0ah,' Press SPACE to Playing,other key is exit:',24h    ;放音提示
data  ends
code  segment
     assume cs:code,ds:data,es:data
;.386
begin:  
     mov ax,data                           ;初始化
     mov  ds,ax
     mov  es,ax
     mov  dx,offset news_1                 ;显示录音提示
     mov  ah,9
     int  21h
test_1:  
     mov  ah,1                              ;等待键盘输入
     int  16h
     jz  test_1                             ;若不是则循环等待
     call  lu                               ;调用录音子程序
     mov dx,offset news_2                   ;显示放音提示
     mov ah,9
     int 21h
fy:  call fang                              ;调用放音子程序
     mov ax,0c07h
     int 21h
     cmp al,20h
     jz fy
     mov ah,4ch                             ;返回
     int 21h

lu proc near                                ;录音子程序
    mov di, offset data_qu                  ;置数据区首地址为DI
    mov cx,10000                            ;录10000个数据
    cld
    mov dx,luport                           ;启动A/D
xunhuan:
    out dx,al                                
    in al,dx                                ;从A/D读数据到AL
    stosb                                   ;存入数据区,使DI加1 
    loop xunhuan                            ;循环
    ret                                     ;子程序返回
lu endp

fang proc near                              ;放音子程序
     mov si,offset data_qu                  ;置数据区首地址为SI
     mov cx,10000                           ;放10000个数据
     cld
     mov dx,fangport                        ;启动D/A
fang_yin: 
     lodsb                                  ;从数据区取出数据
     out dx,al                              ;放音                                  
     mov bx,5000
delay:
    dec bx
    jnz delay
    loop fang_yin                           ;循环
     ret                                    ;子程序返回
fang endp
code ends
end begin
