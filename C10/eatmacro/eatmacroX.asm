%line 16+1 eatmacro.asm
[section .data]

 SCRWIDTH: equ 80
 PosTerm: db 27,"[01;01H"
 POSLEN: equ $-PosTerm
 ClearTerm: db 27,"[2J"
 CLEARLEN equ $-ClearTerm
 AdMsg: db "Eat At Joe's!"
 ADLEN: equ $-AdMsg
 Prompt: db "Press Enter: "
 PROMPTLEN: equ $-Prompt









 Digits: db "0001020304050607080910111213141516171819"
 db "2021222324252627282930313233343536373839"
 db "4041424344454647484950515253545556575859"
 db "606162636465666768697071727374757677787980"

[section .bss]

[section .text]











%line 63+1 eatmacro.asm












%line 80+1 eatmacro.asm












%line 105+1 eatmacro.asm












%line 133+1 eatmacro.asm















%line 174+1 eatmacro.asm













%line 200+1 eatmacro.asm


[global _start]

_start:
 push rbp
 mov rbp,rsp
 and rsp,-16


%line 118+1 eatmacro.asm
 push rax
 push rbx
 push rcx
 push rdx
 push rsi
 push rdi

%line 93+1 eatmacro.asm
 push r11
 push rax
 push rcx
 mov rax,1
 mov rdi,1
 mov rsi,ClearTerm
 mov rdx,CLEARLEN
 syscall
 pop rcx
 pop rax
 pop r11
%line 126+1 eatmacro.asm
 pop rdi
 pop rsi
 pop rdx
 pop rcx
 pop rbx
 pop rax
%line 211+1 eatmacro.asm

%line 188+1 eatmacro.asm
 push rbx
 push rdx
 mov rdx,ADLEN
 xor rbx,rbx
 mov bl,SCRWIDTH
 sub bl,dl
 shr bl,1
%line 149+1 eatmacro.asm
 push rdx
 push rcx
 push rbx
 push rax
 push rsi
 push rdi
 xor rdx,rdx
 xor rcx,rcx

 mov dl,12
 mov cx,word [Digits+rdx*2]
 mov word [PosTerm+2],cx

 mov dl,bl
 mov cx,word [Digits+rdx*2]
 mov word [PosTerm+5],cx

%line 93+1 eatmacro.asm
 push r11
 push rax
 push rcx
 mov rax,1
 mov rdi,1
 mov rsi,PosTerm
 mov rdx,POSLEN
 syscall
 pop rcx
 pop rax
 pop r11
%line 167+1 eatmacro.asm

 pop rdi
 pop rsi
 pop rbx
 pop rcx
 pop rdx
%line 93+1 eatmacro.asm
 push r11
 push rax
 push rcx
 mov rax,1
 mov rdi,1
 mov rsi,AdMsg
 mov rdx,ADLEN
 syscall
 pop rcx
 pop rax
 pop r11
%line 197+1 eatmacro.asm
 pop rdx
 pop rbx
%line 213+1 eatmacro.asm

%line 149+1 eatmacro.asm
 push rdx
 push rcx
 push rbx
 push rax
 push rsi
 push rdi
 xor rdx,rdx
 xor rcx,rcx

 mov dl,23
 mov cx,word [Digits+rdx*2]
 mov word [PosTerm+2],cx

 mov dl,1
 mov cx,word [Digits+rdx*2]
 mov word [PosTerm+5],cx

%line 93+1 eatmacro.asm
 push r11
 push rax
 push rcx
 mov rax,1
 mov rdi,1
 mov rsi,PosTerm
 mov rdx,POSLEN
 syscall
 pop rcx
 pop rax
 pop r11
%line 167+1 eatmacro.asm

 pop rdi
 pop rsi
 pop rbx
 pop rcx
 pop rdx
%line 215+1 eatmacro.asm

%line 93+1 eatmacro.asm
 push r11
 push rax
 push rcx
 mov rax,1
 mov rdi,1
 mov rsi,Prompt
 mov rdx,PROMPTLEN
 syscall
 pop rcx
 pop rax
 pop r11
%line 217+1 eatmacro.asm

%line 76+1 eatmacro.asm
 mov rax,0
 mov rdi,0
 syscall
%line 219+1 eatmacro.asm

%line 56+1 eatmacro.asm
 mov rsp,rbp
 pop rbp

 mov rax,60
 mov rdi,0
 syscall
%line 221+1 eatmacro.asm

