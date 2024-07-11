;filename: io.inc
;A include file used with io.lib for DOS
	.nolist    ; Do not list following content

;declare procedures for inputting and outputting charactor or string
	extern readc:near,readmsg:near,readkey:near
	extern dispc:near,dispmsg:near,dispcrlf:near
;declare procedures for inputting and outputting binary number
	extern readbb:near,readbw:near
	extern dispbb:near,dispbw:near
;declare procedures for inputting and outputting hexadecimal number
	extern readhb:near,readhw:near
	extern disphb:near,disphw:near
;declare procedures for inputting and outputting unsigned integer number
	extern readuib:near,readuiw:near
	extern dispuib:near,dispuiw:near
;declare procedures for inputting and outputting signed integer number
	extern readsib:near,readsiw:near
	extern dispsib:near,dispsiw:near
;declare procedures for outputting registers
	extern disprb:near,disprw:near,disprf:near

;declare I/O libraries
	includelib io.lib

	.list