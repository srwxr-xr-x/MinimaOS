  [bits 64]
  [global _start]
_start:
  push rbp
  mov rbp, rsp

  mov dword [0xb8000], 0x07690748
  hlt
  
  mov rsp, rbp
  pop rbp
