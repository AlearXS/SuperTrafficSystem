proth  EQU 280h 
protlr EQU   298h 
io8255a EQU     288h   
io8255b EQU     28bh   
io8255c EQU     28ah   
DATA      SEGMENT 
min1       DB  00h,01h,02h,03h, 04h,05h,06h,07h     ;共八列
BUFF1      DB  00h,00h,00h,00h,0ffh,00h,00h,00h,1   ;数字1-8 
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
          MOV DX,io8255b    ;设8255为C口输入,A口输出
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
         XLAT               ;得到第一行码
         MOV  DX,proth 
         OUT  DX,AL 
         MOV  AL,AH 
         MOV  DX,protlr 
         OUT  DX,AL           ;显示第一行红
         SHL  AH,01 
         INC  SI 
         PUSH CX 
         MOV  CX,0ffh 
delay2:  LOOP delay2       ;延时
         POP  CX 
         LOOP next 
         POP  CX 
         CALL delay 
         LOOP d2             ;至此显示完一个楼层
         MOV  AH,01           ;键盘有无键按下
         INT  16h 
         JNZ  a2 
inout:   MOV  DX,io8255c    ;从C口输入一数据
         IN   AL,DX 
         MOV  DX,io8255a    ;从A口输出刚才自C口
         OUT  DX,AL         ;所输入的数据
         CMP  AL,0          ;看k0-k7哪位是一
         JZ   L3            ;都不是一则转L3 
L4:      MOV  DL,0                    
L5:      SHR  AL,1 
         INC  DL 
         JNC  L5            ;无进位代表无请求继续查找
         MOV  DH,[BX+8]      ;有进位则向下执行，取到当前楼层的层数
         CMP  DH,DL         ;与请求的楼层比较
         JNZ  L3            ;不相等则顺序执行
L6:      MOV  DX,io8255c    ;从C口输入一数据
         IN   AL,DX   
         CMP  AL,0            ;查看哪一楼层有请求
         JZ   L3 
         MOV  CL,8          ;响应完后，右移八位清空
         SHR  AL,CL                   
         SUB  SI,8                    
         JMP  d2             ;跳至开头继续执行
L3:      ADD  BX,9     ;取下一楼层的数据
         MOV  AL,[BX] 
         CMP  AL,'$'               
         JNZ  agn           ;不是顶层则继续向下一数据区取数
         JMP  L1            ;运行到顶层则从头开始
;---------------------------------------------------------------- 
DELAY    PROC NEAR          ;延迟子程序
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
a2:     MOV  AH,4CH          ;返回
        INT  21H 
CODE    ENDS 
        END  START