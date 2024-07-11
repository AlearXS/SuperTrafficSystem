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
       
mov      dx,28bh                      ;ָ��8255���ƿ�    
       mov      al,10001011b          ;A�����C������
       out      dx,al               ;д��������  

       mov      dx,288h               ;ָ��A��
       mov      al,InA                ;����������ñ���
       out      dx,al                ;д�뵽A�����

       call     OutputC                ;��ʾ���ԵĽ��
jmp1:  mov      ah,2                ;�ƶ����
       mov      dh,15                ;��15�С�20��
       mov      dl,20
       int      10h
       mov      ah,09                ;��ʾ�ַ���mes2
       lea      dx,mes2
       int      21h
       
        mov      ah,1                ;�ȴ����������ֵ��AL=������ַ���
       int      21h
       cmp      al,'y'                ;�ַ� ='y' ?
       je       again                ;�ַ� ='y'ʱ�����ؼ���
       cmp      al,'n'                ;�ַ� ='n' ?
       je       exit                   ;�ַ� ='n'ʱ��תexit

       mov      ah,2                ;�ƶ������15�С���0��
       mov      dh,15        
       mov      dl,0        
       int      10h

       lea      dx,cll                ;��ʾ�ַ��� cll(һ������)    
       mov      ah,9                ;ʵ�����ǽ���Ļ��ԭ�е�mess�ַ�������
       int      21h
       jmp      jmp1
exit:  mov      ah,4ch                ;�˳����򡢷���DOS
       int      21h

;******************************************************************************
;          INPUT B������Ļ����ʾ138ͼ�Σ����ա���ʾ��������ı���
;        ������5������A��B��C��G��G2A��������InA��Ԫ��----�����룩
;               ������ʱ��ֻ������"0"��"1"�������ַ���Ч��
;******************************************************************************
InputB proc    near            
       mov     ah,2           ;��궨λ��AH=02:���ܺ� ---��궨λ��
       mov     bh,0           ;��0�С���0�У�DX=�С��кš�BH=ҳ�ţ�
       mov     dx,0           ;��ǰҳ
       int     10h
       mov     ah,09          ;��ʾ�ַ��� chip            
       lea     dx,chip        ;DS:DXָ�����ݿ��׵�ַ����chip�ַ�����ʾ����Ļ�ϡ�      
       int     21h            ; 0DΪ CR���س����롢0AΪ LF(����)�롢'$'Ϊ������
       
mov     ah,2           ;��궨λ��AH=02:���ܺ� ---��궨λ��
       mov     bh,0           ;���������15�С���10�С���ǰҳ
       mov     dh,15        
       mov     dl,10
       int     10h
       
mov     ah,09h         ;��ʾ�ַ��� mess
       lea     dx,mess
       int     21h
       
mov     ah,0ch            ;������̻�����
       mov     al,08h            ;����������
       int     21h

wait1: mov     ah,0Bh            ;����������״̬ AL=00H���޼��̲���
       int     21h                ;AL=FFH���м��̲���
       cmp     al,0
       jne     wait1            ;�޼��̲���ʱ�����صȴ�

       mov     ah,2            ;�м��̲���ʱ�������ƶ������15�С�10�С���ǰҳ
       mov     bh,0
       mov     dh,15
       mov     dl,10
       int     10h

       lea     dx,cll            ; ��ʾ�ַ��� cll(һ������)
       mov     ah,9            ; ʵ�����ǽ���Ļ��ԭ�е�mess�ַ�������
       int     21h

       mov     dh,12            ;�ƶ��������ǰҳ��12�С�18��
       mov     dl,18            ;���������138ͼ�ε�A���·�
jmp3:  push    dx
       mov     ah,2
       mov     bh,0
       int     10h

jmp4:  mov     ah,7                ;��������A������AL=�����ַ�
       int     21h

       cmp     al,'1'            ;AL=1 ?
       jne     jmp2                ;AL��1 ʱתjmp2
       mov     ah,2                ;��ʾ������ַ�
       xchg    al,dl            ;DLװ�ش�AL�е���ʾ�ַ�
       int     21h

       mov     cl,1
       mov     bl,InA            ;ȡ���������д���
       sal     bl,cl
       add     bl,1
       mov     InA,bl            ;��������A������InA��
       jmp     jmp5
jmp2:  cmp     al,'0'
       jne     jmp4            ;���AL��0 ��תjmp4�����ȴ�����A����
       mov     ah,2                ;��ʾ������ַ���DL=��ʾ�ַ���
       xchg    al,dl            ;DLװ�ش�AL�е���ʾ�ַ�
       int     21h
       mov     cl,1
       mov     bl,InA            ;ȡ���������д���
       sal     bl,cl
       mov     InA,bl            ;��������A������InA��
jmp5:  pop     dx
       add     dl,5                ;������ֵ��5��ָ����Ļ138��һ������λ��
       cmp     dl,43
       jb      jmp3                ;���С��43����תjmp3����ѭ��5�Ρ�����5��������
       mov     cl,3             ;�����ֵ���ڡ�����43�����������
       mov     bl,InA            ;��InA�еĵõ��ĵ�5λ����ӦA��B��C��G��G2A������3��
       sal     bl,cl            ;ʹDL�е�������8255A����138���������Ӧ
       mov     InA,bl            ;���������������ͻ�InA��Ԫ
       ret
InputB endp
;******************************************************************************
;                      CLS  ��������
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
;           OUTPUT C����OutC ��Ԫ�е�8255A��C�ڶ���ı�������Ļ��ʾ��8λ��
;******************************************************************************
OutputC proc     near
       mov      dx,28ah             ;ָ��8255A��C��
       in       al,dx               ;����C������
       mov      OutC,al             ;��OutC��Ԫ�ݴ�

       mov      dh,4                ;�ƶ��������4�С���16��
       mov      dl,16               ;��Ӧ138��������ͼ�ε����λ��
j:     push     dx
       mov      ah,2
       mov      bh,0
       int      10h
       mov      al,OutC             ;������ñ�����һ�ͳ�����Ļ����ʾ
       mov      bl,01h
       and      bl,al               ;ֻ�������������λ����BL�ݴ棬AL����
       mov      cl,1
       shr      al,cl               ;����������һλ���ͻص�OutC��Ԫ
       mov      OutC,al
       add      bl,30h              ;���������λת��ΪASCII�루0��1��ASCII�룩
       xchg     bl,dl               ;������DL׼����ʾ��DL=��ʾ���ַ���
       mov      ah,2
       int      21h
       pop      dx
       add      dl,4                ;�����ֵ��4
       cmp      dl,46
       jb       j                    ;���DLС��46����תJ�м���
       ret
OutputC endp
;***************************************************************************
code   ends            
       end      start
;***************************************************************************
