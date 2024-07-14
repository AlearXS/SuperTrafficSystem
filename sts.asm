include io.inc
.model small
.stack
.data
;����˵��
;�˿ڵ�ַ�ο��겿��
; PA ����
; PB 7-2 LED 0 ������
; PC �ϰ����ּ��̵��� �°�λ��
;������0�ӵ�
time_green equ 30
time_yellow equ 7

port_lattice_h  equ 290h
port_lattice_r  equ 298h
port_lattice_g  equ 2a0h
port8255        equ 288h 
port8255a       equ port8255
port8255b       equ port8255 + 1
port8255c       equ port8255 + 2
port8255k       equ port8255 + 3

light        db  30h,50h,10h,50h,10h,50h,10h     ;������P7~P5:L7~L5
                    ;P4~P2:L2~L0
            db  84h,88h,80h,88h,80h,88h,80h     ;�Ƶ�״̬����
            db  0ffh                            ;������־

light1       db   90H;���ֹ�������������ȫ��  
led         byte 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh    ;����
ledlight     byte 40h;0100 0000;hgfedcba,40��-
buf         byte 3,0            ;���Ҫ��ʾ��ʮλ�͸�λ
disp_buf    byte 0,0,3,0        ;��ʾ����

sta         byte 0              ;��״̬������0��ͨ��1����1,2����2, 3����3��4����ģʽ
light_sta   byte 0              ;������ͨ״̬�ĵ�״̬������00�ϱ��̣�01�ϱ��ƣ�10�����̣�11������
yellow_sta  byte 0              ;���ƻƵ���ʾ��״̬��
yellow_bit  equ 01001000b       ;�Ƶ�λ��      
yellow_mask byte 10110111b      ;�Ƶ�����

light_index word 0              ;���Ƶ���ʾ
flag        byte 0              ;��ŵ�״̬,�̵�Ϊ0���ƵƷ�0

buzzer      byte 0              ;���Ʒ��������л����Ƶ�ʱ����1���´�һ���ж�ʱ��0

;˫ɫ��������ģ���б�ʾ������
arrows    db  18h, 30h, 60h, 0feh, 0feh, 60h, 30h, 18h
cross     db  81h, 42h, 24h, 18h, 18h, 24h, 42h, 81h
cross2    db  0c1h, 63h, 36h, 1ch, 38h, 6ch, 0c6h, 83h

lattice_rot     db 0 ;��¼���������л�ʱˢ�£�ÿ���ж�+1ȡģ
lattice_pattern dw arrows ;��ǰͼ��

key_in db 0

intseg    dw ?           ;��λ���ַ
intoff    dw ?           ;��ԭ�жϷ�������ƫ�Ƶ�ַ
intimr    db ?           ;���жϿ�����




MESSAGE DB  '-------------------------------MENU-------------------------------',13,10
        DB  '1.Press any key to start',13,10,'2.Press "C" to enter an emergency state',13,10
        DB  '3.Press "D" to maintain control in the north-south direction',13,10
        DB  '4.Press "E" to maintain control in the east-west direction ',13,10
        DB   '5.Press "F" to enter an warning state',13,10
        DB   '6.Press any key to end the emergency state ',13,10
        DB   '-----------------------------------------------------------------',13,10,'$'
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
    mov   al,88h                ;��8255��ΪA��B�����, C���ϰ����룬�°����
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
    mov  light_index ,0 
again:
    
    mov   bx,light_index 
    mov   al,light[bx]
   
    cmp sta, 4
    jne flash
    mov al, yellow_bit
    and al, yellow_mask
    
 flash:
    mov   dx,289h    ;B��
    or    al, buzzer      ;���Ϸ�����״̬
    out   dx,al           ;������Ӧ�ĵ�
    cmp   al, 0ffh  ;�ж��Ƿ��ǽ���״̬��ʶ
    jz    a   ;���ص���ʼ�Ƶ�״̬��ֵ
    
    ;�жϵ�ǰ״̬��ֻ����ͨ״̬��ʾ����ܺ�˫ɫ����
    cmp sta, 0
    jne end_disp
    
    ;��ʾ˫ɫ����
disp_lattice:
    cmp light_sta, 00
    jne disp_cross
    mov bx, offset arrows
    mov al, 1
    mov ah, lattice_rot
    call lattice
    jmp end_lattice
disp_cross:
    mov bx, offset cross
    mov al, 0 ;��ɫ
    mov ah, 0 ;����ת
    call lattice
end_lattice:
    
    ;�������ʾ
    call tube
end_disp:
    
    call key
    mov key_in, al
    
    cmp sta, 0
    je st1 ;��ͨ״̬�µļ����߼�
    
    ;����ͨ״̬�£���������˳�����ͨģʽ
    cmp al, 11110000b
    je again
    mov sta, 0
to_again:
    jmp again

    ;��ͨ״̬�ļ����߼�
st1:
    cmp al,01110000b   ;"C"��
    jne  st2   
    jmp ans1

st2: cmp al,10110000b ;"D"��
    jne st3
    jmp ans2
st3: cmp al,11010000b ;"E"��
     jne st4
     jmp ans3

st4: cmp al,11100000b ;"F"��
     jne to_again
     jmp ans4 
     
ans1:;ȫ���
    mov sta, 1 ;����״̬����
    mov dx,289H
    mov al,90h
    out dx,al
    
    call key
    cmp al, 0f0h
    je ans1
    mov sta, 0
    jmp  again

    jmp ans1

ans2:;�����죬�ϱ���
    mov sta, 2 ;����״̬����
    mov dx,289H
    mov al,30h
    out dx,al
    
    call key
    cmp al, 0f0h
    je ans2
    mov sta, 0 ;�ص���ͨ״̬
    jmp  again
  
    jmp ans2
ans3:;�����̣��ϱ���
    mov sta, 3 ;����״̬����
    mov dx,289H
    mov al,84h
    out dx,al
    
    call key
    cmp al, 0f0h
    je ans3
    mov sta, 0 ;�ص���ͨ״̬
    jmp  again
   
ans4:;����ģʽ���Ƶ���˸���������ر�
    mov sta, 4 ;����״̬����    
    jmp again 
                      
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

;�ж��ӳ���
intproc    proc
    sti
    push ax
    push dx
    push ds
    ;
    mov ax,@data
    mov ds,ax
    
    ;�޸ĻƵ�״̬
    xor yellow_sta, 1
    xor yellow_mask, yellow_bit
    ;���÷�����״̬
    mov buzzer, 0
    
    cmp sta, 0
    jne to_e ;ֻ������ͨ״̬�²Ż��޸�״̬
        
    ;��ת��+1
    inc lattice_rot
    cmp lattice_rot, 8
    jl lattice_rot_fi
    mov lattice_rot, 0
lattice_rot_fi:    

    cmp flag,0;�ж��Ƿ����̵�
    jnz yellow;flag!=0,תȥ�Ƶ�
    
    mov al,buf+1    ;flag=0,�̵ƣ���ֵ��λ
    dec al;��λ��һ
    cmp al,9;��9�Ƚ�
    jb  intp2;al<9��ת
    mov al,9;���¸�ֵ9(10s����ʱ����,ʮλ�ü�һ)
    jmp  intp;��ת10λ����

yellow:
    inc light_index ;light_index +1,������һ����״̬��ʾ
    mov al,buf+1;��ʾ��λ
    dec al;��1
    cmp al,6
    jb  intp2;jb:CF=1,ZF=0,��al<6��ת
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
    mov buf+1,09h ;��λ��ֵ9���̵Ƶ� ʱ��

    jmp f
to_e:
    jmp e

f:
    mov lattice_rot, 0
    not flag        ;ȡ��
    
    ;�л����Ƶ�ʱ�򿪷�����
    jne f2
    mov buzzer, 1
    
f2:
    inc light_sta   ;�л���״̬
    cmp light_sta, 4
    jb e
    mov light_sta, 0 
e:
    
    mov al,20h;�жϽ���
    out 20h,al
 
    pop ds
    pop dx
    pop ax
    iret
intproc endp
          
addbyte proc
    ;brief ���ڴ�һ����λ��ʾ��ʮ����������һ����λ��
    ;para alΪ���ӵ�ֵ��bxΪ��ʼ��ַ, al \in [0, 9]�� ����ÿ�������һλ������û������λ��
    ;ret �������֮���λ�������λ�ĵ�ַ
    
    addbyte1:
    add al, [bx]
    cmp al, 10
    jb  addbyte_exit
    
    sub al, 10
    mov [bx], al
    mov al, 1
    inc bx
    jmp addbyte1

addbyte_exit:
    mov [bx], al
    ret
addbyte endp

lattice proc
    ;������ʾ˫ɫ����
    ;param bx: ָ����ģ��ʼ��ַ, al: �Ƶ���ɫ��0��ɫ����0��ɫ, ah: ����λ��
    ;ret void
    push cx
    push dx
    push si
    
    mov cl, ah
    test al, 0ffh
    jnz lattice_else
    mov si, port_lattice_r
    jmp lattice_fi
lattice_else:
    mov si, port_lattice_g
lattice_fi:

    mov ah, 1    
    
lattice_again:
    mov dx, port_lattice_h
    mov al, [bx]
    rol al, cl
    out dx, al
    
    mov dx, si
    mov al, ah
    out dx, al
    call delay
    call delay
    call delay
    mov al, 0
    out dx, al
    inc bx
    rol ah, 1
    test ah, 1 ;��λλ��
    jz lattice_again
    
    mov dx, port_lattice_h
    mov al, 0
    out dx, al
    mov dx, port_lattice_r
    out dx, al
    mov dx, port_lattice_g
    out dx, al
    
    pop si
    pop dx       
    pop cx

    ret

lattice endp

tube proc
    ;����buff��light_sta��ʾ�����
    push ax
    push dx
    push cx
disp_tube:
    ;buf[0]Ϊʮλ
    mov al, buf
    mov disp_buf + 1, al
    mov disp_buf  + 3, al
    mov al, buf + 1
    mov disp_buf, al
    mov disp_buf  + 2, al
    mov cx, 0
    
    cmp light_sta, 00b
    je disp_tube3
    cmp light_sta, 10b
    je disp_tube2
    ;��ʱ״ֻ̬�����ǻƵƣ��ڼ�ʱ��Ϊ0ʱ���ж����ж�
    mov ax, word ptr buf
    cmp ax, 0
    jne disp_tube1
    
    cmp light_sta, 01b
    je disp_tube3
    cmp light_sta, 11b
    je disp_tube2
    jmp disp_tube1
    
    
disp_tube3:
    ;�ϱ��̣����ϱ�����buff=0��������7
    mov bx, offset disp_buf
    mov al, 7

    call addbyte
    jmp disp_tube1
disp_tube2:    
    ;�����̣���������buff=0�����ϱ���6
    mov bx, offset [disp_buf + 2]
    
    mov al, 7
    
    call addbyte
    jmp disp_tube1
        
disp_tube1:
    mov   dx, 28ah     ;��8255��A�������A������ܣ�
    mov   al, 1
    shl   al, cl        
    out   dx, al        ;ѡ�е�ǰѭ������ʾλ
    
    mov   bx, cx
    mov   bl, disp_buf[bx]      ;blΪҪ��ʾ��ʮλ��
    mov   bh, 0
    mov   al, led[bx]  ;�����Ӧ��led����
    mov   dx, 288h     ;����PA�˿�
    out   dx, al
    call  delay      ;��ʱ
    
    mov   al,0       ;�ص��������ʾ��������Ӱ��
    mov   dx,288h
    out   dx,al
    
    
    inc cx
    cmp cx, 4
    jbe disp_tube1
    
    mov  al,0               ;�ص��������ʾ
    mov  dx,28ah
    out  dx,al
    
end_tube:

    pop cx
    pop dx
    pop ax
    ret
tube endp

key proc
    ;ɨ������޼�����ʱֱ���˳����м����������������ɿ�
    ;ret key_in, al ����ļ�ֵ                                                                                                                                                        
    ;register: ax, dx
port_key equ port8255c

        push dx       
        mov dx,port_key
        in al,dx                    ;����ɨ��ֵ
        mov key_in, al
        and al,0f0h
        cmp al,0f0h
        je key_ret                                          ;δ�����м������򷵻�
        
key_waitup:
        mov dx,port_key
        in al,dx           ;����ɨ��ֵ
        and al,0f0h
        cmp al,0f0h
        jne key_waitup     ;����δ̧��ת
        call delay         ;delay for amoment
key_ret:
        mov al, key_in
        pop dx
        ret
key endp


    end start
