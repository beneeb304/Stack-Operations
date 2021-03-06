; multi-segment executable file template.
.MODEL  small
.STACK  100h
   
.DATA
    ; add your data here!
    welcome_msg DB      "Push, Pop, and Print!$"
    bye_msg     DB      "Thanks for participating in this positively pleasant practice program$"
    hextable    DB      '0123456789ABCDEF'  ;An array of all Hex values
    comma       DB      ", $"   

.CODE
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here     
    
    call    display_welcome_msg     ;Call procedure to display message
    
    mov cx, 00              ;Initially, set cx to zero
    
    pushLoop:   
         ADD    cx, 02      ;Add 2 to the CX every loop iteration
         
         push   cx          ;Push our new CX value to the stack
         
         cmp    cx, 100     ;Loop 50 times, so compare CX to 100
         jnz    pushLoop

    popLoop:
        
        pop     cx          ;Pop the stack value to CX
        
        mov     ax,cx       ;Move what we popped to the ax so we can print it's hex equivalent
        
        call    display_hex ;Print the hex (thanks for the handy routine Prof!)
        
        cmp     cx,2        ;Loop 50 times, so compare CX to 2 (what we initially pushed to the stack)
            
        jz      quit        ;If we are done, jump to quit (where we'll end the program). Else, we need to print a comma and loop

        call    print_comma  
        
        jmp     popLoop  
        
    quit:
         
        call    display_bye_msg     ;Call procedure to display message
          
        mov ax, 4c00h ; exit to operating system.
        int 21h 
 
 ;--------------------------------------
 ; display_welcome_msg - used to display a text message
 ;--------------------------------------

  display_welcome_msg   PROC    near
                ;Print message
                lea     dx,welcome_msg
                mov     ah,09h
                int     21h 
                
                ;Set cursor 3 rows from top
                mov     ah,02h
                mov     bh,00h      ; page 0
                mov     dx,0200h
                int     10h
                
                ret             ;Return control to calling program
  display_welcome_msg   ENDP
  
 ;--------------------------------------
 ; display_bye_msg - used to display a text message
 ;--------------------------------------

  display_bye_msg   PROC    near
                ;Set cursor 8 rows from top
                mov     ah,02h
                mov     bh,00h      ; page 0
                mov     dx,0700h
                int     10h
                
                ;Print message
                lea     dx,bye_msg
                mov     ah,09h
                int     21h 
                ret             ;Return control to calling program
  display_bye_msg   ENDP
 
 ;--------------------------------------
 ; print_comma - used to print a comma and space between terms
 ;--------------------------------------  
  print_comma   PROC    near
        lea     dx,comma
                mov     ah,09h
                int     21h
                ret             ;Return control to calling program                            
  print_comma   ENDP
  
 ;--------------------------------------
 ; display_hex - converts a decimal number to hex one hex digit at a time and then displays the converted digit
 ;--------------------------------------

 display_hex   PROC    near

            ;---
            ;--- We will use ax, bx, cx and dx in this routine
            ;--- which would corrupt whatever data was in them
            ;--- from the main program.  Therefore, we should
            ;--- preserve a copy on the stack by pushing them...

            push       ax
            push       bx
            push       cx
            push       dx

            mov        bx,ax   ;Copy decimal number to bx which
                               ;is what we will dissect to get
                               ;4 binary digits to look up in
                               ;table

            mov        cl,04   ;We will be rotating 4 digits at a time

            mov        ch,04   ;Loop counter -- There are 4 hex digits max
                                ;in a word (which is size of ax)

  proc_digit:
            rol        bx,cl   ;Rotate bits left to get digit to convert in
                                ;last 4 bits of bl

            mov        al,bl   	     ;Copy the BL into the AL
            and        al,00001111b  ;Clear bits 4-7 of AL
                                      ;-- bits 0-3 contain the digit and
                                      ;  we can now point at table

            push       bx            ;Save the BX's contents since we need
                                      ;to convert other digits

            lea        bx,hextable   ;Load the hextable's address into BX

            xlat                     ;This instruction is used to look up
                                     ;information in a table.  The BX must
                                     ;point to the table's start (offset)
                                     ;and AL must point to an entry (element)
                                     ;in the table.  Once xlat is done AL
                                     ;will contain the value from the table.

            pop        bx            ;Restore bx for next digit

            mov        dl,al         ;Call an interrupt to print out the 
                                      ;digit we got from the table
            mov        ah,02h
            int        21h

            dec        ch            ;Decrement the ch counter by 1
            jnz        proc_digit

            ;---
            ;--- Reload original register values prior to this proc call
            ;---

            pop        dx
            pop        cx
            pop        bx
            pop        ax
               
            ret                        ;Return control to calling program
 ;display_hex 
 
end start ; set entry point and stop the assembler.