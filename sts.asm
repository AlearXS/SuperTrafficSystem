include io.inc
.model small
.stack
.data
; PA 段码
; PB 7-2 LED 1-0 扬声器
; PC 上半数字键盘的列 下半位码
time_green equ 30


DENG   db  30h,50h,10h,50h,10h,50h,10h     ;六个灯P7~P5:L7~L5
                    ;P4~P2:L2~L0
       db  84h,88h,80h,88h,80h,88h,80h     ;灯的状态数据
       db  0ffh                          ;结束标志
DENG1   db   90H;出现故障两个方向红灯全亮  
led    byte 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh    ;段码
ledDENG byte 40h;0100 0000;hgfedcba,40是-
buf    byte 3,0           ;存放要显示的十位和个位
disp_buf byte 0,0,3,0     ;显示缓存
bz    word ?           ;位码  ;没用上
sta   byte 0            ;总状态变量，0普通，1紧急1,2紧急2, 3紧急3，4警告模式
light_sta byte 0        ;用于普通状态的灯状态变量，00南北绿，01南北黄，10东西绿，11东西黄
yellow_sta byte 0          ;控制黄灯显示的状态量
yellow_bit equ 01001000b;黄灯位码      
yellow_mask byte 10110111b;黄灯掩码
N      word 0          ;控制灯显示
flag   byte 0             ;存放灯状态,有绿灯为0，黄灯非0
intseg    dw ?           ;存段基地址
intoff    dw ?           ;存原中断服务程序的偏移地址
intimr    db ?           ;存中断控制字

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
    mov   al,88h                ;将8255设为A和B口输出
    out   dx,al           
 
    mov   al,0              ;关掉数码管显示
    mov   dx,28ah
    out   dx,al

    mov   ax,350bh    ;中断设置
    int   21h
    mov   intseg,es
    mov   intoff,bx
    ;
    cli
    push  ds                     ;设置新中断向量表项
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

    mov   dx,283h      ;向8253写控制字
    mov   al,36h       ;使通道0为工作方式3;0011 0110
    out   dx,al
    mov   ax,1000      ;写入循环计数初值1000
    mov   dx,280h     
    

    out   dx,al        ;先写入低字节
    mov   al,ah
    out   dx,al        ;后写入高字节

    mov   dx,283h
    mov   al,76h       ;设8253通道1工作方式3
    out   dx,al
    mov   ax,1000      ;写入循环计数初值1000
    mov   dx,281h
    out   dx,al        ;先写低字节
    mov   al,ah
    out   dx,al        ;后写高字节

    sti
a:
    mov  N,0 
again:
    mov   bx,N
    mov   al,DENG[bx]
   
    cmp sta, 4
    jne flash
    mov al, yellow_bit
    and al, yellow_mask
    
 flash:
    mov   dx,289h    ;c口
    out   dx,al           ;点亮相应的灯
    cmp   al, 0ffh  ;判断是否是结束状态标识
    jz    a   ;返回到初始灯的状态初值
       ;数码管显示
    ;判断当前状态，只有普通状态显示数码管
    cmp sta, 0
    jne end_tube
    
disp_tube:
    ;buf[0]为十位
    mov al, buf
    mov disp_buf + 1, al
    mov disp_buf  + 3, al
    mov al, buf + 1
    mov disp_buf, al
    mov disp_buf  + 2, al
    mov cx, 0


    cmp light_sta, 00b
    jne disp_tube2
    
    ;南北绿，则东西加6
    mov bx, offset disp_buf
    
    mov al, '&'
    call dispc
    mov ax, bx
    call dispsiw
    call dispcrlf
    
    mov al, 6

    call addbyte
    
disp_tube2:
    cmp light_sta, 10b
    jne disp_tube1
    
    ;东西绿，则南北加6
    mov bx, offset [disp_buf + 2]
    
    mov ax, bx
    mov al, '*'
    call dispc
    call dispsiw
    call dispcrlf
    mov al, 6
    
    call addbyte
        
disp_tube1:
    mov   dx, 28ah     ;自8255的A口输出（A口数码管）
    mov   al, 1
    shl   al, cl        
    out   dx, al        ;选中当前循环的显示位
    
    mov   bx, cx
    mov   bl, disp_buf[bx]      ;bl为要显示的十位数
    mov   bh, 0
    mov   al, led[bx]  ;求出对应的led数码
    mov   dx, 288h     ;段码PA端口
    out   dx, al
    call  delay      ;延时
    
    mov   al,0       ;关掉数码管显示（避免重影）
    mov   dx,288h
    out   dx,al
    
    
    inc cx
    cmp cx, 4
    jbe disp_tube1
    
    mov  al,0               ;关掉数码管显示
    mov  dx,28ah
    out  dx,al
end_tube:
    
    mov  ah,06h   ;控制台输入输出
    mov dl,0ffh  ;选择输入
    int  21h
    jmp st1 
to_again:
    jmp again

st1:
    cmp al,13
    jne  st2  ;zf=0跳转       ;enter键按下红灯
    jmp ans1


st2: cmp al,49    ;"1"键
    jne st3
    jmp ans2
st3: cmp al,50     ;"2"键
     jne st4
     jmp ans3

st4: cmp al,51     ;"3"键
     jne st5
     jmp ans4     
     
st5:
    cmp al, 32
    jne to_again
    mov sta, 0 ;回到普通状态
    jmp again
ans1:;全红灯
    mov sta, 1 ;设置状态变量
    mov dx,289H
    mov al,90h
    out dx,al
    
    mov  ah,06h   
    mov dl,0ffh
    int  21h
    cmp al,32
    jne  ans1
    mov sta, 0
    jmp  again

    jmp ans1

ans2:;东西红，南北绿
    mov sta, 2 ;设置状态变量
    mov dx,289H
    mov al,30h
    out dx,al
   mov  ah,06h   ;KZTSRSC
    mov dl,0ffh
    int  21h
    cmp al,32
    jne  ans2
    mov sta, 0 ;回到普通状态
    jmp  again
  
    jmp ans2
ans3:;东西绿，南北红
    mov sta, 3 ;设置状态变量
    mov dx,289H
    mov al,84h
    out dx,al
   mov  ah,06h   ;KZTSRSC
    mov dl,0ffh
    int  21h
    cmp al,32   ;空格键
    mov sta, 0 ;回到普通状态

    jne  ans3
    jmp  again
   
    jmp ans3
ans4:;警告模式，黄灯闪烁，蜂鸣器关闭
    mov sta, 4 ;设置状态变量
    mov al, 06h
    mov dl, 0ffh; dos功能调用，getc
    cmp al, 32
    jmp again
    
    jmp again 
                      
    ;中断向量设置
    cli;CPU执行清中断标志位指令cli，使IF标志位为0，
    ;CPU不响应中断。
    ;其目的是为了保证后续内部的初始化设置不受外界的干扰
    mov al,intimr
    out 21h,al;然后CPU执行IO的写指令，
    ;根据提供的8259奇地址端口的端口地址21h，
    ;将经过处理后的屏蔽字，写到屏蔽寄存器IMR中
    mov dx,intoff
    mov ax,intseg
    mov ds,ax
    mov ax,250bh;将立即数250fh传送到ax寄存器。
    ;这样ah的值为25h，al的值为0fh。
    int 21h;CPU执行中断指令,中断类型号21h
    sti

.exit
delay    proc      ;延时  为了保证能个位十位同时显示
    push cx
    mov cx,3000
delay1:    loop delay1
    pop cx
    ret
delay    endp
;中断延时子程序
intproc    proc
    sti
    push ax
    push ds
    ;
    mov ax,@data
    mov ds,ax
    ;修改黄灯状态
    xor yellow_sta, 1
    xor yellow_mask, yellow_bit
    ;
    cmp flag,0;判断是否是绿灯
    jnz yellow;flag!=0,转去黄灯
    mov al,buf+1    ;flag=0,绿灯，赋值个位
    dec al;个位减一
    cmp al,9;与9比较
    jb  intp2;al<9跳转
    mov al,9;重新赋值9(10s倒计时结束,十位得减一)
    jmp  intp;跳转10位控制

yellow:
    inc N;N+1,控制下一个灯状态显示
    mov al,buf+1;显示个位
    dec al;递减
    cmp al,6
    ;设置标志位CF,ZF
    jb  intp2;jb，判断两个无符号数
    ;jb:CF=1,ZF=0,即al<6跳转
    ;ja:CF=0,ZF=0,即al>6跳转
    mov al,6;重新赋值6
    jmp intp2;执行数码管倒计时

intp:
    mov ah,buf;十位赋值
    dec ah;
    cmp ah,3;
    jb intp1
    mov ah,0 
    jmp intp2


intp1:   
    mov buf,ah    
intp2:    ;al<6
    mov buf+1,al;数字给个位赋值
 
    mov al,buf+1;
    mov ah,buf;十位赋值
    cmp ax,0
    jnz  e;结果不为0（倒计时没结束）,跳转
    cmp flag,0;判断flag是否为0
    jz  f;为0则跳转（倒计时结束，需要换标志位）
    mov buf,02h;flag不为0,黄灯结束，十位赋值2
    mov buf+1,09h ;个位赋值9（绿灯倒计时）

f:
    not flag        ;取反
    inc light_sta   ;切换灯状态
    cmp light_sta, 4
    jb e
    mov light_sta, 0 
e:
    
    mov al,20h;CPU执行数据传送指令，将立即数20h传送给al寄存器。
    out 20h,al;CPU执行IO的写指令，根据提供的8259的偶地址端口的
    ;地址20h，将al寄存器的数据，写到操作命令字OCW2中。
    ;这是由于D4D3为00，决定了访问的是OCW2。根据OCW2的格式，
    ;由于D5为1，8259产生EOI中断结束命令，
    ;使当前服务寄存器ISR对应的D7这一位清零。
    pop ds
    pop ax
    iret
intproc endp
          
addbyte proc
    ;brief 将内存一个逐位表示的十进制数加上一个个位数
    ;para al为增加的值，bx为起始地址, al \in [0, 9]， 假设每次至多进一位，假设没有增加位数
    ;ret 计算完成之后进位到的最高位的地址
    
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



    end start
