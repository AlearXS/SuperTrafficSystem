proth  EQU 280h 
protlr EQU   298h 
io8255a EQU     288h   
io8255b EQU     28bh   
io8255c EQU     28ah   
DATA      SEGMENT 
min1       DB  00h,01h,02h,03h, 04h,05h,06h,07h     ;������
BUFF1      DB  00h,00h,00h,00h,0ffh,00h,00h,00h,1   ;����1-8 
BUFF2      DB  00h,00h,79h,49h, 49h,4fh,00h,00h,2 
BUFF3      DB  00h,00h,7fh,49h, 49h,49h,00h,00h,3 
BUFF4      DB  00h,08h,0ffh,48h,28h,18h,08h,00h,4 
BUFF5      DB  00h,00h,9fh,91h,91h,0f1h,00h,00h,5 
BUFF6      DB  00h,00h,4fh,49h,49h, 7fh,00h,00h,6 
BUFF7      DB  00h,00h,60h,50h,4fh, 40h,00h,00h,7 
BUFF8      DB  00h,00h,7fh,49h,49h, 7fh,00h,00h,8 
           DB  00h,00h,60h,50h,4fh, 40h,00h,00h,7 
           DB  00h,00h,4fh,49h,49h, 7fh,00h,00h,6 
           DB  00h,00h,9fh,91h,91h,0f1h,00h,00h,5 
           DB  00h,08h,0ffh,48h,28h,18h,08h,00h,4 
           DB  00h,00h,7fh,49h,49h, 49h,00h,00h,3 
           DB  00h,00h,79h,49h,49h, 4fh,00h,00h,2 
BUFF       DB  '$' 
DATA      ENDS 
;----------------------------------------------------------- 
CODE      SEGMENT 
ASSUME    CS:CODE,DS:DATA 
;------------------------------------------------------------ 
START:    MOV AX,DATA
          MOV DS,AX 
          MOV DX,io8255b    ;��8255ΪC������,A�����
          MOV AL,8bh 
          OUT DX,AL 
;------------------------------------------------------------ 
L1:      MOV  BX,OFFSET buff1 
agn:     MOV  CX,80h 
d2:      MOV  AH,01h                       
         PUSH CX 
         MOV  CX,0008h 
         MOV  SI,OFFSET min1 
next:    MOV  AL,[SI] 
         XLAT               ;�õ���һ����
         MOV  DX,proth 
         OUT  DX,AL 
         MOV  AL,AH 
         MOV  DX,protlr 
         OUT  DX,AL           ;��ʾ��һ�к�
         SHL  AH,01 
         INC  SI 
         PUSH CX 
         MOV  CX,0ffh 
delay2:  LOOP delay2       ;��ʱ
         POP  CX 
         LOOP next 
         POP  CX 
         CALL delay 
         LOOP d2             ;������ʾ��һ��¥��
         MOV  AH,01           ;�������޼�����
         INT  16h 
         JNZ  a2 
inout:   MOV  DX,io8255c    ;��C������һ����
         IN   AL,DX 
         MOV  DX,io8255a    ;��A������ղ���C��
         OUT  DX,AL         ;�����������
         CMP  AL,0          ;��k0-k7��λ��һ
         JZ   L3            ;������һ��תL3 
L4:      MOV  DL,0                    
L5:      SHR  AL,1 
         INC  DL 
         JNC  L5            ;�޽�λ�����������������
         MOV  DH,[BX+8]      ;�н�λ������ִ�У�ȡ����ǰ¥��Ĳ���
         CMP  DH,DL         ;�������¥��Ƚ�
         JNZ  L3            ;�������˳��ִ��
L6:      MOV  DX,io8255c    ;��C������һ����
         IN   AL,DX   
         CMP  AL,0            ;�鿴��һ¥��������
         JZ   L3 
         MOV  CL,8          ;��Ӧ������ư�λ���
         SHR  AL,CL                   
         SUB  SI,8                    
         JMP  d2             ;������ͷ����ִ��
L3:      ADD  BX,9     ;ȡ��һ¥�������
         MOV  AL,[BX] 
         CMP  AL,'$'               
         JNZ  agn           ;���Ƕ������������һ������ȡ��
         JMP  L1            ;���е��������ͷ��ʼ
;---------------------------------------------------------------- 
DELAY    PROC NEAR          ;�ӳ��ӳ���
         PUSH CX 
         PUSH DX 
         MOV  CX,0ffh 
ccc:     MOV  DX,0FFH 
CC:      DEC  DX 
         JG   CC 
         LOOP ccc 
         POP DX  
         POP CX 
         RET 
DELAY    ENDP    
;--------------------------------------------------------------------
a2:     MOV  AH,4CH          ;����
        INT  21H 
CODE    ENDS 
        END  START