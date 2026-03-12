;  Executable name : hexdump1gcc
;  Version         : 2.0
;  Created date    : 5/9/2022
;  Last update     : 5/8/2023
;  Author          : Jeff Duntemann
;  Description     : A simple program in assembly for Linux, using NASM 2.15
;    under the SASM IDE, demonstrating the conversion of binary values to 
;    hexadecimal strings. It acts as a very simple hex dump utility for files, 
;    without the ASCII equivalent column.
;
;  Run it this way:
;    hexdump1gcc < (input file)  
;
;  Build using SASM's default build setup for x64

;
SECTION .data             ; Section containing initialised data

    HexStrTemplate:	db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN               equ $-HexStrTemplate

    Digits: db "0123456789ABCDEF"
		
SECTION .bss              ; Section containing uninitialized data

	BUFFLEN	equ 16        ; We read the file 16 bytes at a time
	Buff: 	resb BUFFLEN  ; Text buffer itself, reserve 16 bytes

        HexStr:  resb HEXLEN

SECTION .text             ; Section containing code

global  main              ; Linker needs this to find the entry point!
	
main:
    mov rbp,rsp       ; SASM Needs this for debugging

; Read a buffer full of text from stdin:
Read:
; Copy first HexStrTemplate into HexStr

    lea     rsi, [HexStrTemplate]       ; RSI = source      address
    lea     rdi, [HexStr]               ; RDI = destination address
    mov     rcx, HEXLEN                 ; RCX = byte count (includes the x0A)
    cld                                 ; Clear Direction Flag (ensures we move forward)
    rep     movsb                       ; Repeat "mov [rdi], [rsi]" RCX times
                                        ; or copy RCX bytes from RSI → RDI


    mov rax,0             ; Specify sys_read call 0
    mov rdi,0             ; Specify File Descriptor 0: Standard Input
    mov rsi,Buff          ; Pass offset of the buffer to read to
    mov rdx,BUFFLEN       ; Pass number of bytes to read at one pass
    syscall               ; Call sys_read to fill the buffer
    mov r12,rax           ; Save # of bytes read from file for later
    cmp rax,0             ; If rax=0, sys_read reached EOF on stdin
    je Done               ; Jump If Equal (to 0, from compare)

                                        
; Set up the registers for the process buffer step:parm
;    mov rsi,Buff          ; Place address of file buffer into esi
;    mov rdi,HexStr        ; Place address of line string into edi

    
;FOR RCX = 0 to R12-1 (number of bytes in buffer) STEP 1
    xor rcx,rcx           ; Clear line string pointer to 0

; Go through the buffer and convert binary values to hex digits:
ForNextLoopScan:

    xor rax,rax           ; Clear rax to 0

; Here we calculate the offset into the line string, which is rcx X 3
    mov rdx,rcx               ; Copy the pointer into line string into rdx
;   shl rdx,1                 ; Multiply pointer by 2 using left shift
;   add rdx,rcx               ; Complete the multiplication X3
    lea rdx,[rdx*3]           ; This line is coded the same as below
;    lea rdx,[rdx*2+rdx]       ; This does what the above 2 lines do!
                              ; See discussion of LEA later in Ch. 9

; Get a character from the buffer and put it in both rax and rbx:
    mov al,byte [rsi+rcx]     ; Put a byte from the input buffer into al
    mov rbx,rax               ; Duplicate byte in bl for second nybble

; Look up low nybble character and insert it into the string:
    and al,0Fh                   ; Mask out all but the low nybble
    mov al,byte [Digits+rax]     ; Look up the char equivalent of nybble
    mov byte [HexStr+rdx+2],al   ; Write the char equivalent to line string

; Look up high nybble character and insert it into the string:
    shr bl,4                     ; Shift high 4 bits of char into low 4 bits
    mov bl,byte [Digits+rbx]     ; Look up char equivalent of nybble
    mov byte [HexStr+rdx+1],bl   ; Write the char equivalent to line string

; Bump the buffer pointer to the next character and see if we're done:
    inc rcx         ; Increment line string pointer                             (STEP 1)
    cmp rcx,r12     ; Compare to the number of characters in the buffer
;    jna Scan        ; Loop back if rcx is <= number of chars in buffer         (BUG)
    jb  ForNextLoopScan ; Loop back if rcx is < number of chars in buffer
                        ; if rcx = number of chars in buffer, exit loop
; NEXT RCX


; Write the line of hexadecimal values to stdout:
    mov rax,1       ; Specify syscall call 1: sys_write
    mov rdi,1       ; Specify File Descriptor 1: Standard output
    mov rsi,HexStr  ; Pass address of line string in rsi
    mov rdx,HEXLEN  ; Pass size of the line string in rdx
    syscall         ; Make kernel call to display line string
    jmp Read        ; Loop back and load file buffer again

; All done! Let's end this party:
Done:
    ret             ; Return to the glibc shutdown code

