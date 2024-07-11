.model small
.stack
.data
DENG   db  30h,50h,10h,50h,10h,50h,10h     ;������P7~P5:L7~L5
                    ;P4~P2:L2~L0
       db  84h,88h,80h,88h,80h,88h,80h     ;�Ƶ�״̬����
       db  0ffh                          ;������־
DENG1   db   90H;���ֹ�������������ȫ��
led    byte 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh    ;����
ledDENG byte 40h;0100 0000;hgfedcba,40��-
buf    byte 3,0           ;���Ҫ��ʾ��ʮλ�͸�λ
bz    word ?           ;λ��  ;û����
N      word 0          ;���Ƶ���ʾ
flag   byte 0             ;��ŵ�״̬,���̵�Ϊ0���ƵƷ�0
intseg    dw ?           ;��λ���ַ
intoff    dw ?           ;��ԭ�жϷ�������ƫ�Ƶ�ַ
intimr    db ?           ;���жϿ�����

MESSAGE DB  '-------------------------------MENU-------------------------------',13,10, '1.Press any key to start',13,10,'2.Press the enter button to enter an emergency state',13,10,'3.Press"1"to maintain control in the north-south direction',13,10,'4.Press"2"to maintain control in the east-west direction ',13,10,'5.Press the Space bar to end the emergency state ',13,10,'-----------------------------------------------------------------',13,10,'$'
.code  
start:
    mov   ax,@data
    mov   ds,ax
    mov ah,9
    mov dx,offset MESSAGE
    int 21h
    mov ah,1
    int 21h

    mov   dx,28bh
    mov   al,80h                ;��8255��ΪA��C�����
    out   dx,al           
 
    mov   al,0              ;�ص��������ʾ
    mov   dx,28ah
    out   dx,al

    mov   ax,350bh    ;�ж�����
    int   21h
    mov   intseg,es
    mov   intoff,bx
    ;
    cli
    push  ds                     ;�������ж���������
    mov   dx,offset intproc   
    mov   ax,seg intproc
    mov   ds,ax
    mov   ax,250bh
    int   21h
    pop   ds
    ;
    in    al,21h                             
    mov   intimr,al
    and   al,0f7h
    out   21h,al

    mov   dx,283h      ;��8253д������
    mov   al,36h       ;ʹͨ��0Ϊ������ʽ3;0011 0110
    out   dx,al
    mov   ax,1000      ;д��ѭ��������ֵ1000
    mov   dx,280h     
    

    out   dx,al        ;��д����ֽ�
    mov   al,ah
    out   dx,al        ;��д����ֽ�

    mov   dx,283h
    mov   al,76h       ;��8253ͨ��1������ʽ3
    out   dx,al
    mov   ax,1000      ;д��ѭ��������ֵ1000
    mov   dx,281h
    out   dx,al        ;��д���ֽ�
    mov   al,ah
    out   dx,al        ;��д���ֽ�

    sti
a:
    mov  N,0 
again:
    mov   bx,N
    mov   al,DENG[bx]
   
    mov   dx,28ah    ;c��
    out   dx,al           ;������Ӧ�ĵ�
    cmp   al, 0ffh  ;�ж��Ƿ��ǽ���״̬��ʶ
    jz    a   ;���ص���ʼ�Ƶ�״̬��ֵ
       ;�������ʾ
    mov   bl,buf      ;blΪҪ��ʾ��ʮλ��
    mov   bh,0
    mov   al,led[bx]  ;�����Ӧ��led����
    mov   dx,288h     ;��8255��A�������A������ܣ�
    out   dx,al
    mov   al,2        ;ʹ��ߵ��������
    mov   dx,28ah     ;ʮλ��λ����PC1
    out   dx,al
    call  delay      ;��ʱ

    mov   al,0       ;�ص��������ʾ��������Ӱ��
    mov   dx,28ah
    out   dx,al

    mov   bl,buf+1      ;blΪҪ��ʾ������buf�ĵڶ�λ����ַ����
    mov   bh,0
    mov   al,led[bx]    ;�����Ӧ��led����
    mov   dx,288h       ;��8255��A�����
    out   dx,al
    mov   al,1         ;ʹ�ұߵ��������
    mov   dx,28ah
    out   dx,al
    call  delay        ;��ʱ
    
    mov  al,0               ;�ص��������ʾ
    mov  dx,28ah
    out  dx,al
    
    mov  ah,06h   ;����̨�������
    mov dl,0ffh  ;ѡ������
    int  21h
    jmp st1

st1:
    cmp al,13
    jne  st2  ;zf=0��ת       ;enter�����º��
    jmp ans1

st2: cmp al,49    ;"1"��
    jne st3
    jmp ans2
st3: cmp al,50     ;"2"��
     jne again
     jmp ans3
ans1:;ȫ���
    mov dx,28ah
    mov al,90h
    out dx,al
    
    mov  ah,06h   
    mov dl,0ffh
    int  21h
    cmp al,32
    jne  a1
      
    jmp  again

    jmp ans1
a1:  jmp ans1
a2:  jmp ans2
a3: jmp  ans3
ans2:;�����죬�ϱ���
    mov dx,28ah
    mov al,30h
    out dx,al
   mov  ah,06h   ;KZTSRSC
    mov dl,0ffh
    int  21h
    cmp al,32
    jne  a2
    jmp  again
  
    jmp ans2
ans3:;�����̣��ϱ���
    mov dx,28ah
    mov al,84h
    out dx,al
   mov  ah,06h   ;KZTSRSC
    mov dl,0ffh
    int  21h
    cmp al,32   ;�ո��
    jne  a3
    jmp  again
   
    jmp ans3
                   
    ;�ж���������
    cli;CPUִ�����жϱ�־λָ��cli��ʹIF��־λΪ0��
    ;CPU����Ӧ�жϡ�
    ;��Ŀ����Ϊ�˱�֤�����ڲ��ĳ�ʼ�����ò������ĸ���
    mov al,intimr
    out 21h,al;Ȼ��CPUִ��IO��дָ�
    ;�����ṩ��8259���ַ�˿ڵĶ˿ڵ�ַ21h��
    ;�����������������֣�д�����μĴ���IMR��
    mov dx,intoff
    mov ax,intseg
    mov ds,ax
    mov ax,250bh;��������250fh���͵�ax�Ĵ�����
    ;����ah��ֵΪ25h��al��ֵΪ0fh��
    int 21h;CPUִ���ж�ָ��,�ж����ͺ�21h
    sti

.exit
delay    proc      ;��ʱ  Ϊ�˱�֤�ܸ�λʮλͬʱ��ʾ
    push cx
    mov cx,3000
delay1:    loop delay1
    pop cx
    ret
delay    endp
;�ж���ʱ�ӳ���
intproc    proc
    sti
    push ax
    push ds
    ;
    mov ax,@data
    mov ds,ax
    ;
    cmp flag,0;�ж��Ƿ����̵�
    jnz yellow;flag!=0,תȥ�Ƶ�
    mov al,buf+1    ;flag=0,�̵ƣ���ֵ��λ
    dec al;��λ��һ
    cmp al,9;��9�Ƚ�
    jb  intp2;al<9��ת
    mov al,9;���¸�ֵ9(10s����ʱ����,ʮλ�ü�һ)
    jmp  intp;��ת10λ����

yellow:
    inc N;N+1,������һ����״̬��ʾ
    mov al,buf+1;��ʾ��λ
    dec al;�ݼ�
    cmp al,6
    ;���ñ�־λCF,ZF
    jb  intp2;jb���ж������޷�����
    ;jb:CF=1,ZF=0,��al<6��ת
    ;ja:CF=0,ZF=0,��al>6��ת
    mov al,6;���¸�ֵ6
    jmp intp2;ִ������ܵ���ʱ

intp:
    mov ah,buf;ʮλ��ֵ
    dec ah;
    cmp ah,3;
    jb intp1
    mov ah,0 
    jmp intp2


intp1:   
    mov buf,ah    
intp2:    ;al<6
    mov buf+1,al;���ָ���λ��ֵ
 
    mov al,buf+1;
    mov ah,buf;ʮλ��ֵ
    cmp ax,0
    jnz  e;�����Ϊ0������ʱû������,��ת
    cmp flag,0;�ж�flag�Ƿ�Ϊ0
    jz  f;Ϊ0����ת������ʱ��������Ҫ����־λ��
    mov buf,02h;flag��Ϊ0,�Ƶƽ�����ʮλ��ֵ2
    mov buf+1,09h ;��λ��ֵ9���̵Ƶ���ʱ��

f:
    not flag        ;ȡ��
e:
    
    mov al,20h;CPUִ�����ݴ���ָ���������20h���͸�al�Ĵ�����
    out 20h,al;CPUִ��IO��дָ������ṩ��8259��ż��ַ�˿ڵ�
    ;��ַ20h����al�Ĵ��������ݣ�д������������OCW2�С�
    ;��������D4D3Ϊ00�������˷��ʵ���OCW2������OCW2�ĸ�ʽ��
    ;����D5Ϊ1��8259����EOI�жϽ������
    ;ʹ��ǰ����Ĵ���ISR��Ӧ��D7��һλ���㡣
    pop ds
    pop ax
    iret
intproc endp

    end start
