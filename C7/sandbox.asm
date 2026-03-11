section .data
section .text

	global main

main:

    mov rbp, rsp; for correct debugging
    push rbp

;    mov rbp,rsp  ; Save stack pointer for debugger

     nop
; Put your experiments between the two nops...


;    xor rdx,rdx
;    mov rax, 0
;    mov rbx, 17
;    div rbx
    

;    mov rdx, 0FFFFFFFFFFFFFFFFh     ; Arithmetic exception
;    mov rdx, 0FFFFFFFFFFFFFFFEh
;    mov rax, 0FFFFFFFFFFFFFFFFh
;    mov rbx, 0FFFFFFFFFFFFFFFFh
;    div rbx

    ; rdx:rax = Divident
    ; rbx     = Divisor
    ; rax     = Quotient, if it does not fit, Arithmetic exception
    ; rdx     = Remainder

;    mov eax, 0FFFFFFFFh
;    mov edx, 03B72h
;    mul edx
    

;    mov eax, 447
;    mov edx, 1739
;    mul edx


;    xor rax, rax
;    mov ax, -42
;    movsx rbx, ax


;    mov rax, 07FFFFFFFFFFFFFFFh
;    inc rax


;    mov rax, 7FFFFFFFFFFFFFFFh
;    neg rax
;    add rax, 7FFFFFFFFFFFFFFFh


;    mov rax, 07FFFFFFFh
    xor rax, rax
;    neg rax
;    add rax, 07FFFFFFFh
    add rax, 080000000h


;    mov rax, 7Fh
;    neg rax
;    add rax, 7Fh


;    mov rax, 42
;    neg rax
;    add rax, 42


;    mov rax, 8000000000000000h
;    neg rax
;    add rax, 8000000000000000h


;    mov eax, 1
;    inc eax
;    mov eax, 0
;    neg eax
 
       
;    mov eax, 5
;DoMore:
;    dec eax
;    jmp DoMore


;    xor rax, rax
;    xor rbx, rbx
    
;    mov rax, 0FFFFFFFFh
;    mov rbx, 02Dh
;    dec rbx
;    inc rax

        
;    xor rcx, rcx
    
;    mov rax, 067FEh
;    mov rbx, rax
;    mov cl,  bh
;    mov ch,  bl
    
;    xchg cl, ch

; Put your experiments between the two nops...
     nop
     
    pop rbp
    mov rax,60          ; 60 = exit the program
    mov rdi,0           ; Return value in rdi 0 = nothing to return
    syscall             ; Call syscall to exit

    
section .bss
