DATA    SEGMENT
io8255a  EQU     288H
IO8255B  EQU     289H
IO8255C  EQU     28aH
IO8255T  EQU     28bH
DATA    ENDS
SSTACK   SEGMENT STACK
STA      DW      50 DUP(?)
SSTACK   ENDS
CODE    SEGMENT
        ASSUME  CS:CODE,DS:DATA,ES:DATA,ES:SSTACK
START:   MOV     AX,DATA
         MOV     DS,AX
         MOV     ES,AX
         MOV     DX,IO8255T                  ;8255������
         MOV     AL,82H
         OUT     DX,AL
         MOV     DX,IO8255B                  ;����״̬
         IN      AL,DX
         MOV     BL,AL
         MOV     BH,BL
         CMP     BH,00H              ;K1��K0Ϊ0��תQQQ
         JZ      QQQ
         CMP       BH,01H                 ;K1Ϊ0��K0Ϊ1��תBBB
         JZ      BBB
         CMP       BH,02H
         JZ           DDD                 ;K1Ϊ1��K0Ϊ0��תDDD
         CMP       BH,03H
         JZ           SSS                 ;K1Ϊ1��K0Ϊ1��תSSS

QQQ:    CALL QQQ1

BBB:    MOV     dx,io8255a             ;�������ʾ1
        MOV     al,06h
        out     dx,al
        MOV     DX,IO8255C             ;��ˮ��
        MOV     AL,01H
        OUT     DX,AL
        CALL    DELAY10
        CALL    DELAY10
        MOV     BL,07H    
LLL:    ROL     AL,1
        OUT     DX,AL
        CALL    DELAY10
         CALL    DELAY10
        CMP     AL,80H
        JNZ     LLL
        JZ      RRR
RRR:    CALL    DELAY10
        ROR     AL,1
        OUT     DX,AL
        CMP     AL,01H
        OUT     DX,AL
        CALL    DELAY10
         CALL    DELAY10
        JNZ     RRR
        JZ      KKK    
DDD:    MOV     dx,io8255a                     ;�������ʾ2
        MOV     al,05bh
        out     dx,al
        MOV      DX,IO8255C                     ;��������˸
        MOV     AL,55H
        OUT     DX,AL
        CALL    DELAY10    
        MOV     AL,00H
        OUT     DX,AL
        CALL    DELAY10 
        LOOP    KKK

SSS:    MOV     dx,io8255a                   ;�������ʾ3
        MOV     al,04fh
        out     dx,al
        MOV        DX,IO8255C                      ;ż������˸
        MOV     AL,0AAH
        OUT     DX,AL
        CALL    DELAY10    
        MOV     AL,00H
        OUT     DX,AL
        CALL    DELAY10 
        LOOP    KKK
KKK:     MOV     DX,IO8255B                   
        IN      AL,DX
        MOV     BL,AL
        MOV     BH,BL
         MOV    AH,06H
        MOV    DL,0FFH
        INT        21H
        JNZ        PPP    
        CMP     BH,00H
        JZ      QQQ
         CMP    BH,01H    
        JZ      BBB
         CMP    BH,02H
        JZ      DDD
        CMP     BH,03H
        JZ      SSS
QQQ1    PROC
        MOV     dx,io8255a                   ;�������ʾ0
        MOV     al,03fh
        out     dx,al
        MOV     DX,IO8255C                  ;������ȫ��
        MOV     AL,0FFH
        OUT     DX,AL
        CALL    DELAY10                     ;��ʱ
         CALL      DELAY10
         CALL      DELAY10
        LOOP    KKK
    RET
QQQ1 ENDP

PPP:     MOV      AX,4C00H                   ;��ֹ����
         INT      21H
DELAY1  PROC    NEAR
        PUSH    CX
        MOV     CX,0FFFFH
CCC:    LOOP    CCC
        POP     CX
        RET
DELAY1  ENDP
DELAY10 PROC    NEAR
        PUSH    AX
        PUSH    CX
        MOV     CX,000FH
UUU:    CALL    DELAY1
        LOOP    UUU
        POP     CX
        POP     AX
        RET
DELAY10 ENDP
CODE    ENDS
        END     START
