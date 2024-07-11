data   segment
  chip db 13,10
       db 13,10
       db '             Program to test the chip of 74LS138',13,10
       db 13,10
       db 13,10
       db '              +------------------------------+',13,10
       db '              |Y0  Y1  Y2  Y3  Y4  Y5  Y6  Y7|',13,10
       db '              |                              |',13,10
       db '              |           74LS138            |',13,10
       db '              |                              |',13,10
       db '              |   A    B    C   G1  G2A+G2B  |',13,10
       db '              +------------------------------+',13,10,'$'
  mess db 'After you have ready,Please press any key !','$'
  mes2 db 'Test Again ?(Y/N)','$'
  InA  db 0
  OutC db 0
  cll  db '                                           ','$'
data   ends

;********************************************************************
code   segment        
       assume cs:code,ds:data
start: mov      ax,data
       mov      ds,ax
again: call     cls
       call     InputB
       
mov      dx,28bh                      ;指向8255控制口    
       mov      al,10001011b          ;A口输出C口输入
       out      dx,al               ;写入命令字  

       mov      dx,288h               ;指向A口
       mov      al,InA                ;将键盘输入得变量
       out      dx,al                ;写入到A口输出

       call     OutputC                ;显示测试的结果
jmp1:  mov      ah,2                ;移动光标
       mov      dh,15                ;至15行、20列
       mov      dl,20
       int      10h
       mov      ah,09                ;显示字符串mes2
       lea      dx,mes2
       int      21h
       
        mov      ah,1                ;等待键盘输入键值（AL=输入的字符）
       int      21h
       cmp      al,'y'                ;字符 ='y' ?
       je       again                ;字符 ='y'时，返回继续
       cmp      al,'n'                ;字符 ='n' ?
       je       exit                   ;字符 ='n'时，转exit

       mov      ah,2                ;移动光标至15行、第0列
       mov      dh,15        
       mov      dl,0        
       int      10h

       lea      dx,cll                ;显示字符串 cll(一个空行)    
       mov      ah,9                ;实际上是将屏幕上原有的mess字符串消掉
       int      21h
       jmp      jmp1
exit:  mov      ah,4ch                ;退出程序、返回DOS
       int      21h

;******************************************************************************
;          INPUT B：在屏幕上显示138图形，接收、显示键盘输入的变量
;        （输入5个变量A、B、C、G、G2A并保存在InA单元中----向左靠齐）
;               （输入时：只能输入"0"或"1"，其它字符无效）
;******************************************************************************
InputB proc    near            
       mov     ah,2           ;光标定位（AH=02:功能号 ---光标定位）
       mov     bh,0           ;第0行、第0列（DX=行、列号、BH=页号）
       mov     dx,0           ;当前页
       int     10h
       mov     ah,09          ;显示字符串 chip            
       lea     dx,chip        ;DS:DX指向数据块首地址。将chip字符串显示在屏幕上。      
       int     21h            ; 0D为 CR（回车）码、0A为 LF(换行)码、'$'为结束码
       
mov     ah,2           ;光标定位（AH=02:功能号 ---光标定位）
       mov     bh,0           ;光标移至第15行、第10列、当前页
       mov     dh,15        
       mov     dl,10
       int     10h
       
mov     ah,09h         ;显示字符串 mess
       lea     dx,mess
       int     21h
       
mov     ah,0ch            ;清除键盘缓冲区
       mov     al,08h            ;缓冲区数量
       int     21h

wait1: mov     ah,0Bh            ;检查键盘输入状态 AL=00H：无键盘操作
       int     21h                ;AL=FFH：有键盘操作
       cmp     al,0
       jne     wait1            ;无键盘操作时，返回等待

       mov     ah,2            ;有键盘操作时，首先移动光标至15行、10列、当前页
       mov     bh,0
       mov     dh,15
       mov     dl,10
       int     10h

       lea     dx,cll            ; 显示字符串 cll(一个空行)
       mov     ah,9            ; 实际上是将屏幕上原有的mess字符串消掉
       int     21h

       mov     dh,12            ;移动光标至当前页的12行、18列
       mov     dl,18            ;将光标移至138图形的A脚下方
jmp3:  push    dx
       mov     ah,2
       mov     bh,0
       int     10h

jmp4:  mov     ah,7                ;键盘输入A变量，AL=输入字符
       int     21h

       cmp     al,'1'            ;AL=1 ?
       jne     jmp2                ;AL≠1 时转jmp2
       mov     ah,2                ;显示输出的字符
       xchg    al,dl            ;DL装载带AL中的显示字符
       int     21h

       mov     cl,1
       mov     bl,InA            ;取出变量进行处理
       sal     bl,cl
       add     bl,1
       mov     InA,bl            ;处理后变量A被移入InA中
       jmp     jmp5
jmp2:  cmp     al,'0'
       jne     jmp4            ;如果AL≠0 则转jmp4继续等待输入A变量
       mov     ah,2                ;显示输出的字符（DL=显示字符）
       xchg    al,dl            ;DL装载带AL中的显示字符
       int     21h
       mov     cl,1
       mov     bl,InA            ;取出变量进行处理
       sal     bl,cl
       mov     InA,bl            ;处理后变量A被移入InA中
jmp5:  pop     dx
       add     dl,5                ;光标的列值加5，指向屏幕138下一个引脚位置
       cmp     dl,43
       jb      jmp3                ;如果小于43，则转jmp3（共循环5次、输入5个变量）
       mov     cl,3             ;如果列值大于、等于43，则输入完成
       mov     bl,InA            ;将InA中的得到的第5位（对应A、B、C、G、G2A）左移3次
       sal     bl,cl            ;使DL中的数据与8255A口与138的输入相对应
       mov     InA,bl            ;处理完后将输入变量送回InA单元
       ret
InputB endp
;******************************************************************************
;                      CLS  清屏操作
;******************************************************************************
cls    proc    near
       mov     ah,6
       mov     al,0
       mov     ch,0
       mov     cl,0
       mov     dh,24
       mov     dl,79
       mov     bh,7
       int     10h
       ret
cls    endp
;******************************************************************************
;           OUTPUT C：将OutC 单元中的8255A的C口读入的变量送屏幕显示（8位）
;******************************************************************************
OutputC proc     near
       mov      dx,28ah             ;指向8255A的C口
       in       al,dx               ;读入C口数据
       mov      OutC,al             ;送OutC单元暂存

       mov      dh,4                ;移动光标至第4行、第16列
       mov      dl,16               ;对应138的译码器图形的输出位置
j:     push     dx
       mov      ah,2
       mov      bh,0
       int      10h
       mov      al,OutC             ;将输入得变量逐一送出在屏幕上显示
       mov      bl,01h
       and      bl,al               ;只保留变量的最低位并送BL暂存，AL不变
       mov      cl,1
       shr      al,cl               ;将变量右移一位并送回到OutC单元
       mov      OutC,al
       add      bl,30h              ;变量的最低位转换为ASCII码（0或1的ASCII码）
       xchg     bl,dl               ;交换到DL准备显示（DL=显示的字符）
       mov      ah,2
       int      21h
       pop      dx
       add      dl,4                ;光标列值加4
       cmp      dl,46
       jb       j                    ;如果DL小于46，则转J行继续
       ret
OutputC endp
;***************************************************************************
code   ends            
       end      start
;***************************************************************************
