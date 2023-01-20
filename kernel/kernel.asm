  [bits 64]
  [global _start]
_start:
  push rbp
  mov rbp, rsp

  mov rax, 0

  mov rsp, rbp
  pop rbp
