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
    at .id, dq 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b, 0x9d5827dcd881dd75, 0xa3148604f6fab11b
    at .rev, dq 0
    at .response, dq 0
  iend

section .data
struc terminal_res
  .cursor_x: resq 1
  .cursor_y: resq 1
  .width:  resw 1
  .height: resw 1
  .scroll: resb 1
endstruc

terminal:
  istruc terminal_res
    at .cursor_x, dq 0
    at .cursor_y, dq 0
    at .width,  dw 1280
    at .height, dw 800
    at .scroll, db 0
  iend

section .text
_start:
  push rbp
  mov rbp, rsp

  mov rax, [frame + framebuffer_req.response]		    	;; Should be 0xffff80007ff78000
  mov rax, [rax + limine_framebuffer_response.framebuffers] 	;; 0xffff80007ff75000, addr to .response
  mov rax, [rax]					    	;; Should be 0xffff8000fd000000, .response is another address to the beginning of limine_framebuffer, so we mov the contents of the address
  mov rbx, [rax + limine_framebuffer.addr]		   	;; At 0xffff80007ff79000, which is 0xffff8000fd00000, the beginning of the framebuffer

  mov r8, rbx						    	;; Mov it into R8 for convenience

  mov qword [terminal + terminal_res.cursor_x], 640	   	;; Set the x position for the cursor to 640
  mov qword [terminal + terminal_res.cursor_y], 400		;; Set the y position for the cursor to 400


  call .screensetup						;; Iterate through the screen and set it to a nice background
  call .cursorsetup						;; Draw a cursor based on where cursor_x and cursor_y is
  jmp .forever							;; Loop forever

.forever:
  hlt
  jmp .forever

  mov rsp, rbp
  pop rbp

.screensetup:
  push rbp
  mov rbp, rsp

  mov r9d, 0x282828						;; Color to write to the screen

.loop1:
  cmp r12w, word [terminal + terminal_res.width]   		;; Check if we are at the end of the screen
  jge .loop2							;; If so, move down one column
  inc r12							;; Increment to the next pixel
  call .putpixel						;; Put down a pixel there
  jmp .loop1							;; Repeat
.loop2:
  cmp r13w, [terminal + terminal_res.height]			;; Check to see if we are on the last row
  jge .screendone						;; If so, end
  xor r12, r12							;; Else, start over at X = 0 on new line
  inc r13							;; Increment Y Position to new line
  jmp .loop1							;; Repeat
.screendone:
  mov rsp, rbp
  pop rbp
  ret

.cursorsetup:
  push rbp
  mov rbp, rsp

  mov r12, [terminal + terminal_res.cursor_x]	;; Set the beginning of the X Position to the value we want
  mov r13, [terminal + terminal_res.cursor_y]	;; Set the beginning of the Y Position to the value we want

  mov r10, [terminal + terminal_res.cursor_y]	;; Mov the Y value into a seperate register we will use for the end position
  add r10, 16					;; Add 16 to the Y, as we want an 8x*16* pixel font size

  mov r11, [terminal + terminal_res.cursor_x]	;; Mov the X value into a seperate register we will use for the end position
  add r11, 8					;; Add 8 to the X, as we want an *8*x16 pixel font size
.for1:
  inc r13					;; Increment Y index
  cmp r13, r10 					;; Compare to the end
  jle .for2					;; Jump to next X loop
.for2:
  inc r12					;; Increment X register
  mov r9d, 0x7E7165				;; Get a color to tell apart
  call .putpixel				;; Put pixel on the screen
  cmp r12, r11					;; See if we are at the end of the screen yet
  jle .for2					;; if not, keep printing

  cmp r13, r10					;; If we are, check if we should stop
  je .cursordone				;; Exit if we are
  mov r12, [terminal + terminal_res.cursor_x]	;; Else, clear X and start over on next line
  jmp .for1					;; Jump over to the beginning
.cursordone:
  mov rsp, rbp
  pop rbp
  ret


.putpixel:
  push rbp
  push r10
  push r11
  push r14
  push r15
  mov rbp, rsp
  						;; R12 = X Position to use
						;; R13 = Y Position
						;; R9 = Color
  mov r10w, word [rax + limine_framebuffer.bpp]	;; Bits per pixel
  mov r11, [rax + limine_framebuffer.pitch]     ;; Pitch

  push rax					;; We need to keep RAX, but MUL uses RDXRAX
  movzx rax, r10w				;; Mov R10 into RAX so we can multiply
  mul r12					;; Multiply X by Bits Per Pixel
  mov r14, rax 					;; Mov the result into R14
  pop rax					;; Get the old value back

  push rax 					;; Push RAX again so we can use it without losing the old value
  mov rax, r11					;; Mov R11 into RAX so we can multiply
  mul r13					;; Multiply Y by Pitch
  mov r15, rax					;; Mov the result into R15
  pop rax					;; Annnnd get the old value back again

  shr r14, 3
  add r14, r15					;; Add the 2 values together
  mov r8, rbx					;; Move the address to the beginning of the framebuffer.

  add r8, r14					;; add offset we got to framebuffer

  mov dword [r8], r9d   			;; Display pixel!
  mov rsp, rbp
  pop r15
  pop r14
  pop r11
  pop r10
  pop rbp
  ret

