.model small
stacks segment stack    ;��ջ�ռ�
     db 100 dup (?)
stacks ends
IO_ADDRESS      equ  288h

DATA            SEGMENT
HZ_TAB          DW 0A3B3H,0A3B2H,0CEBBH,0CEA2H,0BBFAH,0BDCCH,0D1A7H,0CAB5H
                DW 0D1E9H,0CFB5H,0CDB3H,0D5FDH,0D4DAH,0D1DDH,0CABEH,0D6D0H   
HZ_ADR          DB  ?           ;�����ʾ����ʼ�˿ڵ�ַ

DATA            ENDS

code segment
   assume cs:code,ds:data
START:  MOV AX,DATA
                MOV DS,AX               
                MOV DX,IO_ADDRESS
                ADD DX,3
                MOV AL,80H
                OUT DX,AL                       ;8255��ʼ��
               mov al,0ffh
               mov dx,IO_ADDRESS
               out dx, al
                CALL CLEAR              ;LCD ���
          ;     CALL FUNCUP              ;LCD ��������
                LEA BX,  HZ_TAB
                MOV CH,2                        ;��ʾ��2����Ϣ 
                CALL  LCD_DISP
                LEA BX, HZ_TAB
                MOV CH,3                  ;    ��ʾ��3����Ϣ
                CALL LCD_DISP
        l1:     jmp     start ;l1

        CLEAR           PROC
                MOV AL,0CH
                MOV DX, IO_ADDRESS
                OUT DX,AL               ;����CLEAR����
                CALL CMD_SETUP          ;����LCDִ������
                RET
CLEAR           ENDP

FUNCUP          PROC
         ;      MOV AL, 0fH             ;LCD������������
         ;      OUT DX, AL
         ;      CALL CMD_SETUP
                MOV AL, 34H             ;LCD��ʾ״̬����
                OUT DX, AL
                CALL CMD_SETUP
                RET
FUNCUP           ENDP

LCD_DISP        PROC
                LEA BX, HZ_TAB
                CMP CH, 2
                JZ  DISP_SEC
                MOV BYTE PTR HZ_ADR, 88H        ;��������ʼ�˿ڵ�ַ
                ADD BX,16                        ;ָ��ڶ�����Ϣ
                JMP  next
DISP_SEC:       MOV BYTE PTR HZ_ADR,90H
next:           mov cl,8
continue:       push cx
                MOV AL,HZ_ADR
                MOV DX, IO_ADDRESS
                OUT DX, AL
                CALL CMD_SETUP          ;�趨DDRAM��ַ����
                MOV AX,[BX]
                PUSH AX
                MOV AL,AH               ;���ͺ��ֱ����λ
                MOV DX,IO_ADDRESS
                OUT DX,AL
                CALL DATA_SETUP         ;������ֱ�����ֽ�
                CALL DELAY              ;�ӳ�
                POP AX
                MOV DX,IO_ADDRESS
                OUT DX, AL
                CALL DATA_SETUP         ;������ֱ�����ֽ�
                CALL DELAY
                INC BX
                INC BX                  ;�޸���ʾ���뻺����ָ��
                INC BYTE PTR HZ_ADR     ;�޸�LCD��ʾ�˿ڵ�ַ
                POP CX
                DEC CL
                JNZ  CONTINUE
                RET
LCD_DISP   ENDP

CMD_SETUP       PROC
                MOV DX,IO_ADDRESS                ;ָ��8255�˿ڿ��ƶ˿�
                ADD DX,2
                NOP
                MOV AL,00000000B                ;PC1��0,pc0��0 ��LCD I��=0��W�ˣ�0��
                OUT DX, AL
                call delay
                NOP
                MOV AL,00000100B                ;PC2��1 ��LCD E�ˣ�1��
                OUT DX, AL
                NOP
                call delay
                MOV AL, 00000000B               ;PC2��0,��LCD E����0��
                OUT DX, AL
                call delay

                RET
CMD_SETUP       ENDP

DATA_SETUP      PROC
                MOV DX,IO_ADDRESS                ;ָ��8255���ƶ˿�
                ADD DX,2
                MOV AL,00000001B                ;PC1��0��PC0=1 ��LCD I��=1��
                OUT DX, AL
                NOP
                call delay
                MOV AL,00000101B                ;PC2��1 ��LCD E�ˣ�1��
                OUT DX, AL
                NOP
                call delay
                MOV AL, 00000001B               ;PC2��0,��LCD E�ˣ�0��
                OUT DX, AL
                NOP
                call delay
                RET
DATA_SETUP      ENDP

DELAY           PROC
                push cx
                push dx
                MOV CX, 0fffh
 x1:           loop   x1
                pop dx
                pop cx
                RET
DELAY           ENDP


code ends
     end start
