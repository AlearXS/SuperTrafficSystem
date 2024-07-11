.nolist    ; Do not list following content

;filename: io16.inc
;A include file used with io16.lib for DOS

	.model small
	.686
	.stack

exit	MACRO dwexitcode
	mov ax,4c00h+dwexitcode
	int 21h
	ENDM

;declare procedures for inputting and outputting charactor or string
	extern readc:near,readmsg:near
	extern dispc:near,dispmsg:near,dispcrlf:near
;declare procedures for inputting and outputting binary number
	extern readbb:near,readbw:near,readbd:near
	extern dispbb:near,dispbw:near,dispbd:near
;declare procedures for inputting and outputting hexadecimal number
	extern readhb:near,readhw:near,readhd:near
	extern disphb:near,disphw:near,disphd:near
;declare procedures for inputting and outputting unsigned integer number
	extern readuib:near,readuiw:near,readuid:near
	extern dispuib:near,dispuiw:near,dispuid:near
;declare procedures for inputting and outputting signed integer number
	extern readsib:near,readsiw:near,readsid:near
	extern dispsib:near,dispsiw:near,dispsid:near
;declare procedures for outputting registers
	extern disprb:near,disprw:near,disprd:near,disprf:near

;declare I/O libraries
	includelib io16.lib

;define macros
ReadChar MACRO data
	push eax
	call readc
	mov data,al
	pop eax
	ENDM
ReadString MACRO string
	lea eax,string
	call readmsg
	ENDM
WriteChar MACRO data
	push eax
	mov al,data
	call dispc
	pop eax
	ENDM
WriteString MACRO string
	push eax
	lea eax,string
	call dispmsg
	pop eax
	ENDM
WriteCrlf MACRO
	call dispcrlf
	ENDM

ReadBinByte MACRO data
	push eax
	call readbb
	mov data,al
	pop eax
	ENDM
ReadBinWord MACRO data
	push eax
	call readbw
	mov data,ax
	pop eax
	ENDM
ReadBinDword MACRO data
	push eax
	call readbd
	mov data,eax
	pop eax
	ENDM
WriteBinDword MACRO data
	push eax
	mov eax,data
	call dispbd
	pop eax
	ENDM
WriteBinWord MACRO data
	push eax
	mov ax,data
	call dispbw
	pop eax
	ENDM
WriteBinByte MACRO data
	push eax
	mov al,data
	call dispbb
	pop eax
	ENDM

ReadHexByte MACRO data
	push eax
	call readhb
	mov data,al
	pop eax
	ENDM
ReadHexWord MACRO data
	push eax
	call readhw
	mov data,ax
	pop eax
	ENDM
ReadHexDword MACRO data
	push eax
	call readhd
	mov data,eax
	pop rax
	ENDM
WriteHexDword MACRO data
	push eax
	mov eax,data
	call disphd
	pop eax
	ENDM
WriteHexWord MACRO data
	push eax
	mov ax,data
	call disphw
	pop eax
	ENDM
WriteHexByte MACRO data
	push eax
	mov al,data
	call disphb
	pop eax
	ENDM

ReadSDecDword MACRO data
	push eax
	call readsid
	mov data,eax
	pop eax
	ENDM
ReadSDecWord MACRO data
	push eax
	call readsiw
	mov data,ax
	pop eax
	ENDM
ReadSDecByte MACRO data
	push eax
	call readsib
	mov data,al
	pop eax
	ENDM
WriteSDecDword MACRO data
	push eax
	mov eax,data
	call dispsid
	pop eax
	ENDM
WriteSDecWord MACRO data
	push eax
	mov ax,data
	call dispsiw
	pop eax
	ENDM
WriteSDecByte MACRO data
	push eax
	mov al,data
	call dispsib
	pop eax
	ENDM

ReadUDecDword MACRO data
	push eax
	call readuid
	mov data,eax
	pop eax
	ENDM
ReadUDecWord MACRO data
	push eax
	call readuiw
	mov data,ax
	pop eax
	ENDM
ReadUDecByte MACRO data
	push eax
	call readuib
	mov data,al
	pop eax
	ENDM
WriteUDecDword MACRO data
	push eax
	mov eax,data
	call dispuid
	pop eax
	endm
WriteUDecWord MACRO data
	push eax
	mov ax,data
	call dispuiw
	pop eax
	ENDM
WriteUDecByte MACRO data
	push eax
	mov al,data
	call dispuib
	pop eax
	ENDM

WriteRegDword MACRO
	call disprd
	ENDM
WriteRegWord MACRO
	call disprw
	ENDM
WriteRegByte MACRO
	call disprb
	ENDM
WriteFlags MACRO
	call disprf
	ENDM

.list