[bits 64]

section .data
struc id64struc
  .offset1: resw 1
  .selector: resw 1
  .ist: resb 1
  .typeatr: resb 1
  .offset2: resw 1
  .offset3: resd 1
  .zero: resd 1
endstruc

id64:
  istruc id64struc
    at .offset1, dw 0
    at .selector, dw 0
    at .ist, db 0
    at .typeatr, db 0
    at .offset2, dw 0
    at .offset3, dd 0
    at .zero, dd 0
  iend

struc idtptrstruc
  .limit: resw 1
  .base: resq 1
endstruc

idtptr:
  istruc idtptrstruc
    at .limit, dw 0
    at .limit, dq 0
  iend

section .text
init_idt:
  push rax

  mov r8, 128
  shl r8, 8

  mov word [idtptr + idtptrstruc.limit], 

  pop rax
idt_set_gate:

