;  Executable name : textfile
;  Version         : 3.0
;  Created date    : 11/21/1999
;  Last update     : 7/18/2023
;  Author          : Jeff Duntemann
;  Description     : A text file I/O demo for Linux, using NASM 2.14.02
;
;  Build executable using these commands:
;    nasm -f elf64 -g -F dwarf textfile.asm
;    nasm -f elf64 -g -F dwarf linlib.asm
;    gcc textfile.o linlib.o -o textfile -no-pie
;
;  Note that the textfile program requires several procedures
;  in an external library named LINLIB.ASM.

[SECTION .data]     ; Section containing initialized data
		
IntFormat   dq '%d',0
WriteBase   db 'Line # %d: %s',10,0	
NewFilename db 'testeroo.txt',0			
DiskHelpNm  db 'helptextfile.txt',0
WriteCode   db 'w',0
OpenCode    db 'r',0			
CharTbl     db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-@'	
Err1        db 'ERROR: The first command line argument must be an integer!',10,0
HelpMsg     db 'TEXTTEST: Generates a test file.  Arg(1) should be the # of ',10,0
HELPSIZE    EQU $-HelpMsg
            db 'lines to write to the file.  All other args are concatenated',10,0
            db 'into a single line and written to the file.  If no text args',10,0
            db 'are entered, random text is written to the file.  This msg  ',10,0
            db 'appears only if the file HELPTEXTFILE.TXT cannot be opened. ',10,0
HelpEnd     dq 0

[SECTION .bss]             ; Section containing uninitialized data

LineCount   resq 1         ; Reserve integer to hold line count
IntBuffer   resq 1         ; Reserve integer for sscanf's return value
HELPLEN     EQU 72         ; Define length of a line of help text data
HelpLine    resb HELPLEN   ; Reserve space for disk-based help text line
BUFSIZE     EQU 64         ; Define length of text line buffer buff
Buff        resb BUFSIZE+5 ; Reserve space for a line of text 
		
[SECTION .text]            ; Section containing code

;; These externals are all from the glibc standard C library:	 
extern fopen
extern fclose
extern fgets	
extern fprintf
extern printf		
extern sscanf
extern time

;; These externals are from the associated library linlib.asm:
;extern seedit           ; Seeds the random number generator
;extern pull6            ; Generates a 6-bit random number from 0-63

global main             ; Required so linker can find entry point
	
main:
    push rbp            ; Prolog: Set up stack frame
    mov rbp,rsp
    and rsp,-16

    mov r12,rdi         ; Save the argument count in r12
    mov r13,rsi         ; Save the argument pointer table to r13

    call seedit         ; Seed the random number generator

    ;; First test is to see if there are command-line arguments at all.
    ;; If there are none, we show the help info as several lines.  Don't
    ;; forget that the first arg is always the program name, so there's
    ;; always at least 1 command-line argument, even if we don't use it!

    cmp r12,1           ; If count in r12 is 1, there are no arguments
    ja chkarg2          ; Continue if arg count is > 1
    mov rbx,DiskHelpNm  ; Put address of help file name in rbx 
    call diskhelp       ; If only 1 arg, show help info...
    jmp gohome          ; ...and exit the program

    ;; Next we check for a numeric command line argument 1:

chkarg2:
    mov rdi,qword [r13+8] ; Pass address of an argument in rdi
    mov rsi,IntFormat   ; Pass address of integer format code in rsi
    mov rdx,IntBuffer   ; Pass address of integer buffer for sscanf output
    xor rax,rax         ; 0 says there will be no vector parameters
    call sscanf         ; Convert string arg to number with sscanf()    
    cmp rax,1           ; Return value of 1 says we got a number
    je chkdata          ; If we got a number, go on; else abort

    mov rdi,Err1        ; Pass address of error 1-line message in rdi
    xor rax,rax         ; 0 says there will be no vector parameters
    call printf         ; Show the error message
    jmp gohome          ; Exit the program

    ;; Here we're looking to see if there are more arguments.  If there
    ;; are, we concatenate them into a single string no more than BUFSIZE
    ;; chars in size.  (Yes, I DO know this does what strncat does...)

chkdata:
    mov r15,[IntBuffer] ; Store the # of lines to write in r15
    cmp r12,3           ; Is there a second argument?
    jae getlns          ; If so, we have text to fill a file with
    call randline       ; If not, generate a line of random text for file
                        ; Note that randline returns ptr to line in rsi
    jmp genfile         ; Go on to create the file

    ;; Here we copy as much command line text as we have, up to BUFSIZE
    ;; chars, into the line buffer Buff. We skip the first two args
    ;; (which at this point we know exist) but we know we have at least
    ;; one text arg in arg(2). Going into this section, we know that
    ;; r13 contains the pointer to the arg table. All other bets are off.

getlns:
    mov r14,2           ; We know we have at least arg(2), start there
    mov rdi,Buff        ; Destination pointer is start of char buffer
    xor rax,rax         ; Clear rax to 0 for the character counter
    cld                 ; Clear direction flag for up-memory movsb

grab:
    mov rsi,qword [r13+r14*8]   ; Copy pointer to next arg into rsi
.copy:
    cmp byte [rsi],0    ; Have we found the end of the arg?
    je .next            ; If so, bounce to the next arg
    movsb               ; Copy char from [rsi] to [rdi]; inc rdi & rsi
    inc rax             ; Increment total character count
    cmp rax,BUFSIZE     ; See if we've filled the buffer to max count
    je addnul           ; If so, go add a null to Buff & we're done
    jmp .copy

.next:	
    mov byte [rdi],' ' ; Copy space to Buff to separate the args
    inc rdi            ; Increment destination pointer for space
    inc rax            ; Add one to character count too
    cmp rax,BUFSIZE    ; See if we've now filled Buff
    je addnul          ; If so, go down to add a nul and we're done
    inc r14            ; Otherwise, increment the arg processed count
    cmp r14,r12        ; Compare against argument count in r12
    jae addnul         ; If r14 = arg count in r12, we're done
    jmp grab           ; Otherwise, go back and copy it

addnul:
    mov byte [rdi],0   ; Tack a null on the end of Buff
    mov rsi,Buff       ; File write code expects ptr to text in rsi

    ;; Now we create a file to fill with the text we have:	
genfile:
    mov rdi,NewFilename ; Pass filename to fopen in RDI
    mov rsi,WriteCode   ; Pass pointer to write/create code ('w') in rsi
    call fopen          ; Create/open file
    mov rbx,rax         ; rax contains the file handle; save in rbx

    ;; File is open.  Now let's fill it with text:
    mov r14,1           ; R14 now holds the line # in the text file

writeline:
    cmp qword r15,0     ; Has the line count gone to 0?
    je closeit          ; If so, close the file and exit
    mov rdi,rbx         ; Pass the file handle in rdi
    mov rsi,WriteBase   ; Pass the base string in rsi
    mov rdx,r14         ; Pass the line number in rdx
    mov rcx,Buff        ; Pass the pointer to the text buffer in rcx
    xor rax,rax         ; 0 says there will be no vector parameters  
    call fprintf        ; Write the text line to the file
    dec r15             ; Decrement the count of lines to be written
    inc r14             ; Increment the line number
    jmp writeline       ; Loop back and do it again

    ;; We're done writing text; now let's close the file:
closeit:
    mov rdi,rbx         ; Pass the handle of the file to be closed in rdi
    call fclose         ; Closes the file

gohome:	                ; End program execution
	mov rsp,rbp         ; Epilog: Destroy stack frame before returning
	pop rbp
	ret                 ; Return control to to the C shutdown code


;;; SUBROUTINES================================================================

;------------------------------------------------------------------------------
;  Disk-based mini-help subroutine  --  Last update 12/16/2022
;
;  This routine reads text from a text file, the name of which is passed by
;  way of a pointer to the name string in ebx. The routine opens the text file,   
;  reads the text from it, and displays it to standard output.  If the file   
;  cannot be opened, a very short memory-based message is displayed instead.          
;------------------------------------------------------------------------------	
diskhelp:
    mov rdi,DiskHelpNm  ; Pointer to name of help file is passed in rdi
    mov rsi,OpenCode    ; Pointer to open-for-read code "r" gpes in rsi
    call fopen          ; Attempt to open the file for reading
    cmp rax,0           ; fopen returns null if attempted open failed
    jne .disk           ; Read help info from disk, else from memory
    call memhelp		
    ret

.disk:
    mov rbx,rax         ; Save handle of opened file in ebx
.rdln:	
    mov rdi,HelpLine    ; Pass pointer to buffer in rdi
    mov rsi,HELPLEN     ; Pass buffer size in rsi
    mov rdx,rbx         ; Pass file handle to fgets in rdx
    call fgets          ; Read a line of text from the file
    cmp rax,0           ; A returned null indicates error or EOF
    jle .done           ; If we get 0 in rax, close up & return
    mov rdi,HelpLine    ; Pass address of help line in rdi
    xor rax,rax         ; Passs 0 to show there will be no fp registers    
    call printf         ; Call printf to display help line
    jmp .rdln

.done:	
    mov rdi,rbx         ; Pass the handle of the file to be closed in rdi
    call fclose         ; Close the file 
    jmp gohome          ; Go home

memhelp:
    mov rax,5           ; rax contains the number of newlines we want 
    mov rbx,HelpMsg     ; Load address of help text into rbx
.chkln:	
    cmp qword [rbx],0   ; Does help msg pointer point to a null?
    jne .show           ; If not, show the help lines
    ret                 ; If yes, go home
.show:
    mov rdi,rbx         ; Pass address of help line in rdi
    xor rax,rax         ; 0 in RAX says there will be no vector parameters
    call printf         ; Display the line
    add rbx,HELPSIZE    ; Increment address by length of help line
    jmp .chkln          ; Loop back and check to see if we're done yet

showerr:
    mov rdi,rax         ; On entry, rax contains address of error message
    xor rax,rax         ; 0 in RAX says there will be no vector parameters
    call printf         ; Show the error message
    ret                 ; Pass control to shutdown code; no returned values

randline:
    mov rbx,BUFSIZE     ; BUFSIZE tells us how many chars to pull
    mov byte [Buff+BUFSIZE+1],0 ; Put a null at the end of the buffer first
.loopback:
    dec rbx             ; BUFSIZE is 1-based, so decrement
    call pull6          ; Go get a random number from 0-63
    mov cl,[CharTbl+rax]  ; Use random # in rax as offset into char table
                          ;  and copy character from table into cl
    mov [Buff+rbx],cl   ; Copy char from cl to character buffer
    cmp rbx,0           ; Are we done having fun yet?
    jne .loopback       ; If not, go back and pull another
    mov rsi,Buff        ; Copy address of the buffer into rsi
    ret                 ;   and go home



;  Source name     : linlib.asm
;  Executable name : None -- This is a library of subroutines!
;  Version         : 3.0
;  Created date    : 12/4/1999
;  Last update     : 12/10/2022
;  Author          : Jeff Duntemann
;  Description     : A procedure library in assembly using NASM 2.14.02
;
;  Assemble using this command:
;    nasm -f elf64 -g -F dwarf linlib.asm

[SECTION .data]		; Section containing initialised data

LineBase    db 'Number is: %d',10,0
nl	        db 10,10,10,10,10,10,10,10,10,10,0	

[SECTION .bss]		; Section containing uninitialized data

[SECTION .text]		; Section containing code

extern printf		; All of these are in the standard C library glibc	
extern rand	
extern srand
extern time
		
global seedit		; Seeds the random number generator with a time value
global pull31		; Pulls a 31-bit random number
global pull16		; Pulls a 16-bit random number; in the range 0-65,535
global pull8		; Pulls an 8-bit random number; in the range 0-255
global pull7		; Pulls a 7-bit random number; in the range 0-127
global pull6		; Pulls a 6-bit random number; in the range 0-63
global pull4		; Pulls a (marginal) 4-bit random number; range 0-15
global newline		; Outputs a specified number of newlines to stdout
	

;------------------------------------------------------------------------------
;  Random number generator procedures  --  Last update 12/10/2022
;
;  This routine provides 6 entry points, and returns 6 different "sizes" of
;  pseudorandom numbers based on the value returned by rand. Note first of 
;  all that rand pulls a 31-bit value. The high 16 bits are the most "random"
;  so to return numbers in a smaller range, you fetch a 31-bit value and then
;  right-shift it to zero-fill all but the number of bits you want. An 8-bit
;  random value will range from 0-255, a 7-bit value from 0-127, and so on.
;  Respects RBP, RSI, RDI, RBX, and RSP. Returns random value in RAX.
;------------------------------------------------------------------------------
pull31: mov rcx,0		; For 31 bit random, we don't shift
	jmp pull
pull20: mov rcx,11      ; For 20 bit random, shift by 11 bits
    jmp pull
pull16: mov rcx,15		; For 16 bit random, shift by 15 bits
	jmp pull
pull8:	mov rcx,23		; For 8 bit random, shift by 23 bits
	jmp pull
pull7:  mov rcx,24		; For 7 bit random, shift by 24 bits
	jmp pull
pull6:	mov rcx,25		; For 6 bit random, shift by 25 bits
	jmp pull
pull4:	mov rcx,27		; For 4 bit random, shift by 27 bits

pull:	
    push rcx		; rand trashes rcx; save shift value on stack
	call rand		; Call rand for random value; returned in RAX
	pop rcx			; Pop stashed shift value back into RCX
	shr rax,cl		; Shift the random value in RAX by the chosen factor
				    ;  keeping in mind that part we want is in CL
	ret			    ; Go home with random number in RAX

;---------------------------------------------------------------------------
;  Random number seed routine  --  Last update 12/10/2022
;
;  This routine fetches a time_t value from the system clock using the C
;  library's time function, and uses that time value to seed the random number    
;  generator through the function srand.  No values need be passed into it    
;  nor returned from it.                                                     
;---------------------------------------------------------------------------

seedit:	
    xor rdi,rdi		; Mske sure rdi starts out with a 0
	call time	    ; Returns time_t value (64-bit integer) in rax
	mov rdi,rax	    ; Pass srand a time_t seed in rdi
	call srand	    ; Seed the random number generator
    ret             ; No return value

;------------------------------------------------------------------------------
;  Newline outputter  --  Last update 5/29/2009
;
;  This routine allows you to output a number of newlines to stdout, given by
;  the value passed in rax.  Legal values are 1-10. Passing a 0 value in rax 
;  will result in no newlines being issued.
;------------------------------------------------------------------------------

newline:
	mov rcx,10		; We need a skip value, which is 10 minus the
	sub rcx,rax		;   number of newlines the caller wants.
	add rcx,nl		; This skip value is added to the address of
	mov rdi,rcx		;   the newline buffer nl before calling printf.
	call printf		; Display the selected number of newlines
	ret			; Go home


