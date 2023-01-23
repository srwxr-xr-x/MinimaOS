  [bits 64]
  [global _start]
  %define LIMINE_COMMON_MAGIC dq 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b ; First Magic number, used to distinguish requests to limine

struc limine_framebuffer_response ;
    .rev: resq 1
    .count: resq 1
    .framebuffers: resq 1
endstruc

struc limine_framebuffer
    .addr: resq 1               ;
    .width: resq 1              ; Number of pixels on a horizontal line
    .height: resq 1             ; Number of horizontal lines present
    .pitch: resq 1              ; Number of *bytes* of vram to skip one pixel down
    .bpp: resw 1                ; Bits per pixel
    .memory_model: resb 1       ;
    .red_mask_size: resb 1      ;
    .red_mask_shift: resb 1     ;
    .green_mask_size: resb 1    ;
    .green_mask_shift: resb 1   ;
    .blue_mask_size: resb 1     ;
    .blue_mask_shift: resb 1    ;
    .unused: resb 7             ;
    .edid_size: resq 1          ;
    .edid: resq 1               ;
    ; revision 1
    .mode_count: resq 1         ;
    .modes: resq 1              ;
endstruc

struc framebuffer_req
  .id: resq 4
  .rev: resq 1
  .response: resq 1
endstruc

frame:
  istruc framebuffer_req
  at framebuffer_req.id, dq 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b, 0x9d5827dcd881dd75, 0xa3148604f6fab11b
  at framebuffer_req.rev, dq 0
  at framebuffer_req.response, dq 0
  iend

section .text
_start:
  push rbp
  mov rbp, rsp
  mov rax, [framebuffer_req.response + limine_framebuffer_response.framebuffers]
                                ; todo maybe check the count
  mov rax, [rax] ; *response->framebuffers
                                ; now rax has limine_framebuffer*
  mov rbx, [rax + limine_framebuffer.addr]
                                ; rbx = framebuffer base

  mov r8, 32166
  add rbx, r8

  mov dword [r8], 0xff0000
  .forever:
    hlt
    jmp .forever
  mov rsp, rbp
  pop rbp
