;*******************
;*     ¼����      *
;*******************
data segment
 luport        equ 29ah                  ;¼���ڵ�ַ
 fangport      equ 290h                  ;�����ڵ�ַ
 
 data_qu  db 10000 dup(?)                         ;¼�����ݴ��������
 news_1   db 'Press any key to record:',24h       ;¼����ʾ
 news_2   db 0dh,0ah,' Press SPACE to Playing,other key is exit:',24h    ;������ʾ
data  ends
code  segment
     assume cs:code,ds:data,es:data
;.386
begin:  
     mov ax,data                           ;��ʼ��
     mov  ds,ax
     mov  es,ax
     mov  dx,offset news_1                 ;��ʾ¼����ʾ
     mov  ah,9
     int  21h
test_1:  
     mov  ah,1                              ;�ȴ���������
     int  16h
     jz  test_1                             ;��������ѭ���ȴ�
     call  lu                               ;����¼���ӳ���
     mov dx,offset news_2                   ;��ʾ������ʾ
     mov ah,9
     int 21h
fy:  call fang                              ;���÷����ӳ���
     mov ax,0c07h
     int 21h
     cmp al,20h
     jz fy
     mov ah,4ch                             ;����
     int 21h

lu proc near                                ;¼���ӳ���
    mov di, offset data_qu                  ;���������׵�ַΪDI
    mov cx,10000                            ;¼10000������
    cld
    mov dx,luport                           ;����A/D
xunhuan:
    out dx,al                                
    in al,dx                                ;��A/D�����ݵ�AL
    stosb                                   ;����������,ʹDI��1 
    loop xunhuan                            ;ѭ��
    ret                                     ;�ӳ��򷵻�
lu endp

fang proc near                              ;�����ӳ���
     mov si,offset data_qu                  ;���������׵�ַΪSI
     mov cx,10000                           ;��10000������
     cld
     mov dx,fangport                        ;����D/A
fang_yin: 
     lodsb                                  ;��������ȡ������
     out dx,al                              ;����                                  
     mov bx,5000
delay:
    dec bx
    jnz delay
    loop fang_yin                           ;ѭ��
     ret                                    ;�ӳ��򷵻�
fang endp
code ends
end begin
