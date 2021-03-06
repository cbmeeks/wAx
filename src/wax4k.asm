;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                                     wAx 4K
;                            Integrated Monitor Tools
;                             (c)2020, Jason Justian
;                  
; Release 1  - May 16, 2020
; Release 2  - May 23, 2020
; Release 3  - May 30, 2020
; Release 4K - June 14, 2020
; Release 5  - July 6, 2020
; Assembled with XA
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2020, Jason Justian
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; LABEL DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

; Configuration
*           = $6000             ; Assembly location
LIST_NUM    = $10               ; Display this many lines
SEARCH_L    = $10               ; Search this many pages (s * 256 bytes)
DEF_DEVICE  = $08               ; Default device number
SYM_END     = $02ff             ; Top of Symbol Table
MAX_LAB     = 19                ; Maximum number of user labels + 1
MAX_FWD     = 12                ; Maximum number of forward references

; Tool Setup
TOOL_COUNT  = $14               ; How many tools are there?
T_DIS       = "."               ; Wedge character . for disassembly
T_XDI       = ","               ; Wedge character , for extended opcodes
T_ASM       = "@"               ; Wedge character @ for assembly
T_MEM       = ":"               ; Wedge character : for memory dump
T_BIN       = "%"               ; Wedge character % for binary dump
T_TST       = $b2               ; Wedge character = for tester
T_BRK       = "!"               ; Wedge character ! for breakpoint
T_REG       = ";"               ; Wedge character ; for register set
T_EXE       = $5f               ; Wedge character left-arrow for code execute
T_SAV       = $b1               ; Wedge character > for save
T_LOA       = $b3               ; Wedge character < for load
T_SRC       = $ad               ; Wedge character / for search
T_CPY       = "&"               ; Wedge character & for copy
T_H2T       = "$"               ; Wedge character $ for hex to base 10
T_T2H       = "#"               ; Wedge character # for base 10 to hex
T_SYM       = $ac               ; Wedge character * for symbol table management
T_BAS       = $ae               ; Wedge character ^ for BASIC stage select
T_USR       = "'"               ; Wedge character ' for user tool
T_USL       = $5c               ; Wedge character GPB for user list
LABEL       = $ab               ; Forward relative branch character

; System resources - Routines
GONE        = $c7e4
CHRGET      = $0073
CHRGOT      = $0079
PRTFIX      = $ddcd             ; Print base-10 number
SYS         = $e12d             ; BASIC SYS start
SYS_BRK     = $e133             ; BASIC SYS continue after BRK
SYS_TAIL    = $e144             ; BAIC SYS end
CHROUT      = $ffd2             ; Print one character
WARM_START  = $0302             ; BASIC warm start vector
READY       = $c002             ; BASIC warm start with READY.
NX_BASIC    = $c7ae             ; Get next BASIC command
CUST_ERR    = $c447             ; Custom BASIC error message
SYNTAX_ERR  = $cf08             ; BASIC syntax error
ERROR_NO    = $c43b             ; Show error in Accumulator
SETLFS      = $ffba             ; Setup logical file
SETNAM      = $ffbd             ; Setup file name
SAVE        = $ffd8             ; Save
LOAD        = $ffd5             ; Load
CLOSE       = $ffc3             ; Close logical file
OPEN        = $ffc0             ; Open logical file
CHKIN       = $ffc6             ; Define file as input
CHRIN       = $ffcf             ; Get input
CLRCHN      = $ffcc             ; Close channel
ASCFLT      = $dcf3             ; Convert base-10 to FAC1
MAKADR      = $d7f7             ; FAC1 to Integer
DEVICE      = $ba               ; Save device
ISCNTC      = $ffe1             ; Check Stop key

; System resources - Vectors and Pointers
IGONE       = $0308             ; Vector to GONE
CBINV       = $0316             ; BRK vector
BUFPTR      = $7a               ; Pointer to buffer
ERROR_PTR   = $22               ; BASIC error text pointer
SYS_DEST    = $14               ; Pointer for SYS destination

; System resources - Data
KEYWORDS    = $c09e             ; Start of BASIC kewords for detokenize
BUF         = $0200             ; Input buffer
CHARAC      = $07               ; Temporary character
KEYBUFF     = $0277             ; Keyboard buffer and size, for automatically
CURLIN      = $39               ; Current line number
KBSIZE      = $c6               ;   advancing the assembly address
MISMATCH    = $c2cd             ; "MISMATCH"
KEYCVTRS    = $028d             ; Keyboard codes

; System resources - Registers
ACC         = $030c             ; Saved Accumulator
XREG        = $030d             ; Saved X Register
YREG        = $030e             ; Saved Y Register
PROC        = $030f             ; Saved Processor Status

; Constants
; Addressing mode encodings
INDIRECT    = $10               ; e.g., JMP ($0306)
INDIRECT_X  = $20               ; e.g., STA ($1E,X)
INDIRECT_Y  = $30               ; e.g., CMP ($55),Y
ABSOLUTE    = $40               ; e.g., JSR $FFD2
ABSOLUTE_X  = $50               ; e.g., STA $1E00,X
ABSOLUTE_Y  = $60               ; e.g., LDA $8000,Y
ZEROPAGE    = $70               ; e.g., BIT $A2
ZEROPAGE_X  = $80               ; e.g., CMP $00,X
ZEROPAGE_Y  = $90               ; e.g., LDX $FA,Y
IMMEDIATE   = $a0               ; e.g., LDA #$2D
IMPLIED     = $b0               ; e.g., INY
RELATIVE    = $c0               ; e.g., BCC $181E
ACCUM       = $d0               ; e.g., ROR A

; Other constants
TABLE_END   = $f2               ; Indicates the end of mnemonic table
XTABLE_END  = $d2               ; End of extended instruction table
QUOTE       = $22               ; Quote character
LF          = $0d               ; Linefeed
CRSRUP      = $91               ; Cursor up
CRSRRT      = $1d               ; Cursor right
CRSRLF      = $9d               ; Cursor left
RVS_ON      = $12               ; Reverse on
RVS_OFF     = $92               ; Reverse off

; Assembler symbol table
; You can relocate and/or resize the symbol table by settnig SYM_END,
; MAX_LAB, and MAX_FWD to meet your needs. The remaining labels will be
; set automatically, and you shouldn't need to touch them.
;
; Note that one of the labels is reserved for the special @/> label, so
; add one more to MAX_LAB than you need.
ST_SIZE     = (MAX_LAB + MAX_FWD) * 3 + 1
SYMBOL_D    = SYM_END-ST_SIZE+1 ; Symbol label definitions
SYMBOL_AL   = SYMBOL_D+MAX_LAB  ; Symbol address low bytes
SYMBOL_AH   = SYMBOL_AL+MAX_LAB ; Symbol address high bytes
SYMBOL_F    = SYMBOL_AH+MAX_LAB ; Symbol unresolved forward references
SYMBOL_FL   = SYMBOL_F+MAX_FWD  ;   Forward reference low bytes
SYMBOL_FH   = SYMBOL_FL+MAX_FWD ;   Forward reference high bytes
OVERFLOW_F  = SYMBOL_FH+MAX_FWD ; Symbol unresolved reference overflow count

; wAx workspace
X_PC        = $03               ; Persistent Counter (2 bytes)
USER_VECT   = $05               ; User tool vector (2 bytes)
WORK        = $a4               ; Temporary workspace (2 bytes)
MNEM        = $a4               ; Current Mnemonic (2 bytes)
EFADDR      = $a6               ; Program Counter (2 bytes)
CHARDISP    = $a8               ; Character display for Memory (2 bytes)
LANG_PTR    = $a8               ; Language Pointer (2 bytes)
OPCODE      = $aa               ; Assembly target for hypotesting
OPERAND     = $ab               ; Operand storage (2 bytes)
IDX_OUT     = $ad               ; Buffer index - Output
IDX_IN      = $ae               ; Buffer index - Input
TOOL_CHR    = $af               ; Current function (T_ASM, T_DIS)
OUTBUFFER   = $0218             ; Output buffer (24 bytes)
INBUFFER    = $0230             ; Input buffer (22 bytes)
USR_STORE   = $0247             ; User tool storage (8 bytes)
IDX_SYM     = $024f             ; Temporary symbol index storage
SEARCH_C    = $0250             ; Search counter
INSTSIZE    = $0251             ; Instruction size
IGNORE_RB   = $0252             ; Ignore relative branch range for forward refs
TEMP_CALC   = $0253             ; Temporary calculation
RANGE_END   = $0254             ; End of range for Save and Copy (2 bytes)
BREAKPOINT  = $0256             ; Breakpoint data (3 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; INSTALLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
Install:    jsr Rechain         ; Rechain BASIC program
            jsr SetupVec        ; Set up vectors (IGONE and BRK)
            lda #DEF_DEVICE     ; Set default device number
            sta DEVICE          ; ,,
            lda #<Install       ; Set default User tool (to Install)
            sta USER_VECT       ; ,,
            lda #>Install       ; ,,
            sta USER_VECT+1     ; ,,
            lda #<Intro         ; Print introduction message
            ldy #>Intro         ; ,,
            jsr PrintStr        ; ,,
            jmp (READY)         ; Warm start with READY prompt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; MAIN PROGRAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;              
main:       jsr CHRGET          ; Get the character from input or BASIC
            ldy #$00            ; Is it one of the wedge characters?
-loop:      cmp ToolTable,y     ; ,,
            beq Prepare         ; If so, run the selected tool
            iny                 ; Else, check the characters in turn
            cpy #TOOL_COUNT     ; ,,
            bne loop            ; ,,
exit:       jsr CHRGOT          ; Restore flags for the found character
            jmp GONE+3          ; +3 because the CHRGET is already done

; Prepare for Tool Run
; A wedge character has been entered, and will now be interpreted as a wedge
; command. Prepare for execution by
; (1) Setting a return point
; (2) Putting the tool's start address-1 on the stack
; (3) Transcribing from BASIC or input buffer to the wAx input buffer
; (4) Reading the first four hexadecimal characters used by all wAx tools and
;     setting the Carry flag if there's a valid 16-bit number provided
; (5) RTS to route to the selected tool            
Prepare:    sta TOOL_CHR        ; Store the tool character
            lda #>Return-1      ; Push the address-1 of Return onto the stack
            pha                 ;   as the destination for RTS of the
            lda #<Return-1      ;   selected tool
            pha                 ;   ,,
            lda ToolAddr_H,y    ; Push the looked-up address-1 of the selected
            pha                 ;   tool onto the stack. The RTS below will
            lda ToolAddr_L,y    ;   pull off the address and route execution
            pha                 ;   to the appropriate tool
            jsr ResetIn         ; Initialize the input index for write
            sta IGNORE_RB       ; Clear Ignore Relative Branch flag
            jsr Transcribe      ; Transcribe from CHRGET to INBUFFER
            lda #$ef            ; $0082 BEQ $008a -> BEQ $0073 (maybe)
            sta $83             ; ,,
RefreshPC:  jsr ResetIn         ; Re-initialize for buffer read
            jsr Buff2Byte       ; Convert 2 characters to a byte   
            bcc main_r          ; Fail if the byte couldn't be parsed
            sta EFADDR+1        ; Save to the EFADDR high byte
            jsr Buff2Byte       ; Convert next 2 characters to byte
            bcc main_r          ; Fail if the byte couldn't be parsed
            sta EFADDR          ; Save to the EFADDR low byte
main_r:     rts                 ; Pull address-1 off stack and go there
    
; Return from Wedge
; Return in one of two ways--
; (1) In direct mode, to a BASIC warm start without READY.
; (2) In a program, find the next BASIC command
Return:     jsr DirectMode      ; If in Direct Mode, warm start without READY.
            bne in_program      ;   ,,
            jmp (WARM_START)    ;   ,,           
in_program: lda #$00            ; In a program, reset the keyboard buffer size
            sta KBSIZE          ;   to 0 to avoid any prompts
            jmp NX_BASIC        ; Otherwise, continue to next BASIC command   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; COMMON LIST COMPONENT
; Shared entry point for Disassembler and Memory Dump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
List:       bcs addr_ok         ; If the provided address is OK, disassemble
            lda X_PC            ; Otherwise, set the effective addresss to the
            sta EFADDR          ;  persistent counter to continue listing
            lda X_PC+1          ;  after the last address
            sta EFADDR+1        ;  ,,
            jmp check_dir       ;  ,,
addr_ok:    lda INBUFFER+4      ; If there's stuff after the list command,
            beq check_dir       ;   treat it as an assemble command by routing
            jmp Assemble        ;   to Assemble
check_dir:  jsr DirectMode      ; If the tool is in direct mode,
            bne start_list      ;   cursor up to overwrite the original input
            lda #CRSRUP         ;   ,,
            jsr CHROUT          ;   ,,
start_list: ldx #LIST_NUM       ; Default if no number has been provided
ListLine:   txa
            pha
            jsr ResetOut
            jsr BreakInd        ; Indicate breakpoint, if it's here
            lda TOOL_CHR        ; Start each line with the wedge character
            jsr CharOut
            jsr ShowAddr           
            lda TOOL_CHR        ; What tool is being used?
            cmp #T_MEM          ; Memory Dump
            beq to_mem          ; ,,
            cmp #T_BIN          ; Binary Dump
            beq to_bin          ; ,,
            cmp #T_USL          ; User list tool
            beq to_usr          ; ,,
            jsr Space           ; Space goes after address for Disassembly
            jsr Disasm
            jmp continue
to_mem:     jsr CharOut         ; Memory editor character goes after address
            jsr Memory          ; Do Memory display
            jmp continue
to_bin:     jsr CharOut         ; Binary editor character goes after address
            jsr BinaryDisp      ; Do Binary display
            jmp continue
to_usr:     jsr UserTool            
continue:   jsr PrintBuff      
            pla
            tax
            jsr ISCNTC          ; Exit if STOP key is pressed
            beq list_stop       ; ,,          
            dex                 ; Exit if loop is done
            bne ListLine        ; ,,
            inx                 ; But if the loop is done, but a SHift key
            lda KEYCVTRS        ;   is engaged, then go back for one more
            and #$01            ;   ,,
            bne ListLine        ;   ,,
            lda TOOL_CHR        ; If the breakpoint was set, don't update
            cmp #T_BRK          ;   the persistent counter or show a tool
            beq list_r          ;   prompt
list_stop:  jsr EAtoPC          ; Update persistent counter with effective addr
            lda TOOL_CHR        ; Provide a tool for the next page in the key-
            sta KEYBUFF         ;   board buffer.
            lda #CRSRLF         ; ,,
            sta KEYBUFF+1       ; ,,
            lda #$02            ; ,,
            sta KBSIZE          ; ,,
list_r:     jmp EnableBP        ; Re-enable breakpoint, if necessary

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; DISASSEMBLER COMPONENTS
; https://github.com/Chysn/wAx/wiki/6502-Disassembler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disassemble
; Disassemble a single instruction at the effective address
Disasm:     jsr IncAddr         ; Get opcode
            jsr Lookup          ; Look it up
            bcc Unknown         ; Clear carry indicates an unknown opcode
            pha                 ; Store addressing mode for later
            jsr DMnemonic       ; Display mnemonic
            lda TOOL_CHR        ; If the search is being run, go directly
            cmp #T_SRC          ;   to the operand
            beq disasm_op       ;   ,,
            jsr Space
disasm_op:  pla                 ; Pass addressing mode to operand routine
            jmp DOperand        ; Display operand

; Unknown Opcode
Unknown:    lda #T_MEM          ; Memory entry before an unknown byte
            jsr CharOut         ; ,,
            lda OPCODE          ; The unknown opcode is still here   
            jmp Hex             
            
; Mnemonic Display
DMnemonic:  lda MNEM+1          ; These locations are going to rotated, so
            pha                 ;   save them on a stack for after the
            lda MNEM            ;   display
            pha                 ;   ,,
            ldx #$03            ; Three characters...
-loop:      lda #$00
            sta CHARAC
            ldy #$05            ; Each character encoded in five bits, shifted
shift_l:    lda #$00            ;   as a 24-bit register into CHARAC, which
            asl MNEM+1          ;   winds up as a ROT0 code (A=1 ... Z=26)
            rol MNEM            ;   ,,
            rol CHARAC          ;   ,,
            dey
            bne shift_l
            lda CHARAC
            ;clc                ; Carry is clear from the last ROL
            adc #"@"            ; Get the PETSCII character
            jsr CharOut
            dex
            bne loop
            pla
            sta MNEM
            pla
            sta MNEM+1
mnemonic_r: rts

; Operand Display
; Dispatch display routines based on addressing mode
DOperand:   cmp #IMPLIED        ; Handle each addressing mode with a subroutine
            beq mnemonic_r      ; Implied has no operand, so it goes to some RTS
            cmp #ACCUM          ;
            bne ch_rel          ; Handle accumulator mode right here, because
            lda #"A"            ;   it's super-small
            jmp CharOut         ;   ,,
ch_rel:     cmp #RELATIVE
            beq DisRel
            cmp #IMMEDIATE
            beq DisImm
            cmp #ZEROPAGE       ; Subsumes all zeropage modes
            bcs DisZP
            cmp #ABSOLUTE       ; Subsumes all absolute modes
            bcs DisAbs
            ; Fall through to DisInd, because it's the only one left

; Disassemble Indirect Operand
DisInd:     pha
            lda #"("
            jsr CharOut
            pla
            cmp #INDIRECT
            bne ind_xy
            jsr Param_16
            jmp CloseParen
ind_xy:     pha
            jsr Param_8
            pla
            cmp #INDIRECT_X
            bne ind_y
            jsr Comma
            lda #"X"
            jsr CharOut
            jmp CloseParen
ind_y:      jsr CloseParen
            jsr Comma
            lda #"Y"
            jmp CharOut

; Disassemble Immediate Operand         
DisImm:     lda #"#"
            jsr CharOut
            jmp Param_8

; Disassemble Zeropage Operand
DisZP:      pha
            jsr Param_8
            pla
            sec
            sbc #ZEROPAGE
            jmp draw_xy         ; From this point, it's the same as Absolute            

; Disassemble Relative Operand
DisRel:     jsr HexPrefix
            jsr IncAddr         ; Get the operand of the instruction
            sta WORK
            and #$80            ; Get the sign of the operand
            beq sign
            ora #$ff            ; Extend the sign out to 16 bits, if negative
sign:       sta WORK+1          ; Set the high byte to either $00 or $ff
            lda WORK            ; Calculate offset from next instructions
            clc                 ; ,,
            adc EFADDR          ; ,,
            sta WORK            ; ,,
            lda WORK+1          ; ,,
            adc EFADDR+1        ; ,,
            jsr Hex             ; No need to save the high byte, just show it
            lda WORK            ; Show the low byte of the computed address
            jmp Hex             ; ,,
                            
; Disassemble Absolute Operand           
DisAbs:     pha                 ; Save addressing mode for use later
            jsr Param_16
            pla
            sec
            sbc #ABSOLUTE
draw_xy:    ldx #"X"
            cmp #$10
            beq abs_ind
            ldx #"Y"
            cmp #$20
            beq abs_ind
            rts
abs_ind:    jsr Comma           ; This is an indexed addressing mode, so
            txa                 ;   write a comma and index register
            jmp CharOut         ;   ,,
                        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; MEMORY EDITOR COMPONENTS
; https://github.com/Chysn/wAx/wiki/Memory-Editor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MemEditor:  sta TOOL_CHR        ; Update tool character for Prompt
            lda #$04            ; The number of allowed bytes is temporarily
            sta CHARAC          ;   stored in CHARAC.
            jsr DirectMode      ; If MemEditor is run in a BASIC program, allow
            beq start_mem       ;   more bytes per line, because we don't need
            lda #$08            ;   to worry about intrference with the PETSCII
            sta CHARAC          ;   display.
start_mem:  ldy #$00
-loop:      jsr Buff2Byte
            bcc edit_exit       ; Bail out on the first non-hex byte
            sta (EFADDR),y      
            iny
            cpy CHARAC
            bne loop
edit_exit:  cpy #$00
            beq asm_error
            tya
            tax
            jsr Prompt          ; Prompt for the next address
            jsr ClearBP         ; Clear breakpoint if anything was changed
edit_r:     rts

; Text Editor
; If the input starts with a quote, add characters until we reach another
; quote, or 0
TextEdit:   ldy #$00            ; Y=Data Index
-loop:      jsr CharGet
            beq asm_error       ; Return to MemEditor if 0
            cmp #QUOTE          ; Is this the closing quote?
            beq edit_exit       ; Return to MemEditor if quote
            sta (EFADDR),y      ; Populate data
            iny
            cpy #$10            ; String size limit
            beq edit_exit
            jmp loop
            
; Binary Editor
; If the input starts with a %, get one binary byte and store it in memory                   
BinaryEdit: sta TOOL_CHR        ; Update tool character for prompt
            jsr BinaryByte      ; Get 8 binary bits
            ;bcc edit_r         ; If invalid, errors at BinaryByte
            ldy #$00            ; Store the valid byte to memory
            sta (EFADDR),y      ; ,,
            iny                 ; Increment the byte count and return to
            jmp edit_exit       ;   editor            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; ASSEMBLER COMPONENTS
; https://github.com/Chysn/wAx/wiki/6502-Assembler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Centrally-located error jump
asm_error:  jmp AsmError

; Assemble 6502 Instruction
; Or data
Assemble:   bcc asm_r           ; Bail if the address is no good
            lda INBUFFER+4      ; If the user just pressed Return at the prompt,
            beq asm_r           ;   go back to BASIC
-loop:      jsr CharGet         ; Look through the buffer for either
            beq test            ;   0, which should indicate implied mode, or:
            ldy IDX_IN          ; If we've gone past the first character after
            cpy #$05            ;   the address, no longer pay attention to
            bne op_parts        ;   pre-data stuff
            cmp #LABEL          ; - = New label
            beq DefLabel        ; ,,
            cmp #T_MEM          ; Colon = Byte entry (route to hex editor)
            beq MemEditor       ; ,,
            cmp #QUOTE          ; " = Text entry (route to text editor)
            beq TextEdit        ; ,,
            cmp #T_BIN          ; % = Binary entry (route to binary editor)
            beq BinaryEdit      ; ,,
op_parts:   cmp #"#"            ; # = Parse immediate operand (quotes and %)
            beq ImmedOp         ; ,,         
            cmp #"$"            ; $ = Parse the operand
            bne loop            ; ,,
main_op:    jsr GetOperand      ; Once $ is found, then grab the operand
test:       jsr Hypotest        ; Line is done; hypothesis test for a match
            bcc asm_error       ; Clear carry means the test failed
            ldy #$00            ; A match was found! Transcribe the good code
            lda OPCODE          ;   to the effective address. The number of
            sta (EFADDR),y      ;   bytes to transcribe is stored in the
            ldx INSTSIZE        ;   INTSIZE location.
            cpx #$02            ; Store the low operand byte, if indicated
            bcc nextline        ; ,,
            lda OPERAND         ; ,,
            iny                 ; ,,
            sta (EFADDR),y      ; ,,
            cpx #$03            ; Store the high operand byte, if indicated
            bcc nextline        ; ,,
            lda OPERAND+1       ; ,,
            iny                 ; ,,
            sta (EFADDR),y      ; ,,
nextline:   jsr ClearBP         ; Clear breakpoint on successful assembly
            jsr Prompt          ; Prompt for next line if in direct mode
asm_r:      rts

; Define Label
; Create a new label entry, and resolve any forward references to the
; new label.
DefLabel:   jsr CharGet         ; Get the next character after the label;
            jsr SymbolIdx       ; Get a symbol index for the label in A
            bcs have_label      ;
            jmp SymError        ; Error if no symbol index could be secured
have_label: jsr IsDefined       ; If this label is not yet defined, then
            bne is_def          ;   resolve the forward reference, if it
            sty IDX_SYM         ;   was used
            jsr ResolveFwd      ;   ,,
            ldy IDX_SYM
is_def:     lda EFADDR          ; Set the label address
            sta SYMBOL_AL,y     ; ,,
            lda EFADDR+1        ; ,,
            sta SYMBOL_AH,y     ; ,,
            jsr CharGet
            cmp #$00
            bne pull_code
            ldx #$00            ; Return to BASIC or prompt for the same
            jmp Prompt          ;   address again
pull_code:  ldy #$00            ; If there's code after the label, pull it
-loop:      iny                 ;   two spaces, replacing the label. This
            lda INBUFFER+5,y    ;   positions the instruction for use with
            sta INBUFFER+3,y    ;   Hypotest later
            bne loop            ;   ,,
            lda #$04            ; Reset the buffer position to the start
            sta IDX_IN          ;   of the code  
            sec                 ;   ,,
            jmp Assemble        ;   ,,
 
; Parse Immediate Operand
; Immediate operand octets are expressed in the following formats--
; (1) $dd       - Hexadecimal 
; (2) "c"       - Character
; (3) %bbbbbbbb - Binary
; (4) #d[d][d]  - Base 10
ImmedOp:    jsr CharGet         ; This is the character right after #
            cmp #"$"            ; If it's $, go back to get regular $ operand
            beq main_op         ; ,,
try_quote:  cmp #QUOTE          ; If it's a double quote, make sure it's a one
            bne try_binary      ;   character surrounded by quotes. If it is,
            jsr CharGet         ;   set it as the operand and convert it to
            sta OPERAND         ;   hex for the hypotester
            jsr CharGet         ;   ,,
            cmp #QUOTE          ;   ,,
            bne AsmError        ;   ,, Error if the second quote isn't here
            beq insert_hex      ;   ,,
try_binary: cmp #"%"            ; If it's a binary prefix sigil %, convert
            bne try_base10      ;   the eight binary bits and, if valid,
            jsr BinaryByte      ;   set the operand and convert it to hex
            ;bcc AsmError       ;   ,, (errors at BinaryByte)
            sta OPERAND         ;   ,,
            bcs insert_hex      ;   ,,
try_base10: lda $7b             ; Now look for a base-10 number by temporarily
            pha                 ;   setting CHRGET's buffer to wAx's input
            lda $7a             ;   buffer and scanning for base-10 digits.
            pha                 ;   ,,
            ldy #<INBUFFER+8    ; Point the CHRGET buffer at the location
            lda #>INBUFFER+8    ;   after the #
            sty $7a             ;   ,, 
            sta $7b             ;   ,,
            jsr CHRGOT          ; Call CHRGOT to start verifying numbers
            bcs AsmError        ;   ,,
            jsr ASCFLT          ; Convert the buffer text into FAC1
            jsr MAKADR          ; Convert FAC1 to 16-bit unsigned integer
            cmp #$00            ; High byte from MAKADR is in A
            bne AsmError        ; Error if high byte is set; too big for immed
            sty OPERAND         ; Low byte from MAKADR is in Y
            pla                 ; Put the CHRGET buffer back so BASIC doesn't
            sta $7a             ;   freak out
            pla                 ;   ,,
            sta $7b             ;   ,,
            ; Fall through to insert_hex
insert_hex: jsr ResetOut        ; Store the hex value of the operand after the
            sta INBUFFER+11     ;   #, so it can be matched by Hypotest.
            lda #"$"            ;   End it with 0 as a line delimiter
            sta INBUFFER+8      ;   ,,
            lda OPERAND         ;   ,,
            jsr Hex             ;   ,,
            lda OUTBUFFER       ;   ,,
            sta INBUFFER+9      ;   ,,
            lda OUTBUFFER+1     ;   ,,
            sta INBUFFER+10     ;   ,,
            jmp test
            
; Error Message
; Invalid opcode or formatting (ASSEMBLY)
; Failed boolean assertion (MISMATCH, borrowed from ROM)
AsmError:   ldx #$00            ; ?ASSMEBLY ERROR
            .byte $3c           ; TOP (skip word)
MisError:   ldx #$01            ; ?MISMATCH ERROR
            .byte $3c           ; TOP (skip word)
SymError:   ldx #$02            ; ?SYMBOL ERROR
            .byte $3c           ; TOP (skip word)
CannotRes:  ldx #$03            ; ?CAN'T RESOLVE ERROR 
            .byte $3c           ; TOP (skip word)
OutOfRange: ldx #$04            ; ?TOO FAR ERROR
            lda ErrAddr_L,x
            sta ERROR_PTR
            lda ErrAddr_H,x
            sta ERROR_PTR+1
            jmp CUST_ERR          

; Get Operand
; Populate the operand for an instruction by looking forward in the buffer and
; counting upcoming hex digits.
GetOperand: jsr Buff2Byte       ; Get the first byte
            bcc getop_r         ; If invalid, return
            sta OPERAND+1       ; Default to being high byte
            jsr Buff2Byte
            bcs high_byte       ; If an 8-bit operand is provided, move the high
            lda OPERAND+1       ;   byte to the low byte. Otherwise, just
high_byte:  sta OPERAND         ;   set the low byte with the input
getop_r:    rts
            
; Hypothesis Test
; Search through the language table for each opcode and disassemble it using
; the opcode provided for the candidate instruction. If there's a match, then
; that's the instruction to assemble at the effective address. If Hypotest tries
; all the opcodes without a match, then the candidate instruction is invalid.
Hypotest:   jsr ResetLang       ; Reset language table
reset:      ldy #$06            ; Offset disassembly by 6 bytes for buffer match   
            sty IDX_OUT         ;   b/c output buffer will be "$00AC INST"
            lda #OPCODE         ; Write location to effective addr for hypotesting
            sta EFADDR          ; ,,
            ldy #$00            ; Set the effective address high byte
            sty EFADDR+1        ; ,,
            jsr NextInst        ; Get next instruction in 6502 table
            cmp #XTABLE_END     ; If we've reached the end of the table,
            beq bad_code        ;   the assembly candidate is no good
            sta OPCODE          ; Store opcode to hypotesting location
            jsr IncAddr  
            jsr DMnemonic       ; Add mnemonic to buffer
            ldy #$01            ; Addressing mode is at (LANG_PTR)+1
            lda (LANG_PTR),y    ; Get addressing mode to pass to DOperand
            pha
            jsr DOperand        ; Add formatted operand to buffer
            lda #$00            ; Add 0 delimiter to end of output buffer so
            jsr CharOut         ;  the match knows when to stop
            pla
            cmp #RELATIVE       ; If the addressing mode is relative, test
            beq test_rel        ;   separately and check range
            cmp #ACCUM          ; If the addressing mode is accumulator,
            bne run_match       ;   test separately
            lda IDX_IN          ; If the candidate is greater than 4 characters,
            cmp #$0a            ;   it cannot be an accumulator instruction
            bcs reset           ;   ,, 
            ldy #$07            ; For accumulator mode, the character following
            lda INBUFFER,y      ;   the mnemonic may be either $00 (ROR), or
            beq ch_accum        ;   "A" (ROR A).
            cmp #"A"            ;   ,,
            bne reset
ch_accum:   lda #$09
            sta IDX_OUT
run_match:  jsr IsMatch
            bcc reset
match:      lda EFADDR          ; Set the INSTSIZE location to the number of
            sec                 ;   bytes that need to be programmed
            sbc #OPCODE         ;   ,,
            sta INSTSIZE        ;   ,,
            jmp RefreshPC       ; Restore the effective address to target addr
test_rel:   lda #$0a            ; For relative branch instructions, first check
            sta IDX_OUT         ;   the name of the instruction. If that checks
            jsr IsMatch         ;   out, compute the relative branch offset and
            bcc reset           ;   insert it into memory, if it's within range
            jsr RefreshPC       ;   ,,
            jsr ComputeRB       ;   ,,
            sty OPERAND         ;   ,,
            lda #$02            ;   ,, 
            sta INSTSIZE        ;   ,,
            sec                 ; Set carry to indicate success
            rts
bad_code:   clc                 ; Clear carry flag to indicate failure
            rts
            
; Compute Relative Branch Offset
; With branch instruction in EFADDR and target in OPERAND
; Return offset in Y if valid, or error message if too far
ComputeRB:  lda EFADDR+1        ; Stash the effective address, as the offset
            pha                 ;   is computed from the start of the next
            lda EFADDR          ;   instruction
            pha                 ;   ,,
            jsr IncAddr         ; EFADDR += 2
            jsr IncAddr         ; ,,
            lda OPERAND         ; Subtract operand from effective address
            sec                 ;   to get offset
            sbc EFADDR          ;   ,,
            tay                 ;   ,, (Y will be the RB offset)
            lda OPERAND+1       ;   ,,
            sbc EFADDR+1        ;   ,,
            tax                 ;   ,,
            pla                 ; Put back the tool's effective address
            sta EFADDR          ; ,,
            pla                 ; ,,
            sta EFADDR+1        ; ,,
            cpx #$ff            ; Check the range; the difference must be between
            beq neg             ;   $ff80 and $007f, inclusive
            cpx #$00            ;   ,,
            beq pos             ;   ,,
rb_err:     lda IGNORE_RB
            bne compute_r
            jmp OutOfRange      ; BASIC error if out of range
neg:        cpy #$80
            bcc rb_err
            rts
pos:        cpy #$80
            bcs rb_err
compute_r:  rts            
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; MEMORY DUMP COMPONENT
; https://github.com/Chysn/wAx/wiki/Memory-Dump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Memory:     ldy #$00
-loop:      lda (EFADDR),y
            sta CHARDISP,y
            jsr Hex
            iny
            cpy #$04
            beq show_char
            jsr Space
            jmp loop       
show_char:  jsr ReverseOn       ; Reverse on for the characters
            ldy #$00
-loop:      lda CHARDISP,y
            cmp #$a0            ; Everything from 160 on is allowed in the
            bcs add_char        ;   display unchaged
            cmp #$80            ; Change everything between 128 and 159 
            bcs alter_char      ; ,,
            cmp #$20            ; Show everything else at and above space
            bcs add_char        ; ,,
alter_char: lda #" "            ; Everything else gets a space
add_char:   jsr CharOut         ; ,,
            jsr IncAddr
next_char:  iny
            cpy #04
            bne loop            
            rts
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BINARY DUMP COMPONENT
; https://github.com/Chysn/wAx/wiki/Memory-Dump#binary-dump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BinaryDisp: jsr IncAddr         ; Get byte at effetive address
            sta TEMP_CALC       ; Store byte for binary conversion
            pha                 ; Push for use as a hex number
            lda #%10000000      ; Start with high bit
-loop:      pha
            bit TEMP_CALC
            beq is_zero
            jsr ReverseOn
            lda #"1"
            jsr CharOut
            lda #RVS_OFF
            .byte $3c           ; TOP (skip word)
is_zero:    lda #"0"
            jsr CharOut
            pla
            lsr
            bne loop
            jsr Space
            pla
            jmp Hex

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; ASSERTION TESTER COMPONENT
; https://github.com/Chysn/wAx/wiki/Assertion-Tester 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Tester:     ldy #$00
-loop:      jsr Buff2Byte
            bcc test_r          ; Bail out on the first non-hex byte
            cmp (EFADDR),y
            bne test_err      
            iny
            bne loop
test_r:     tya                 ; Update effective address with number of
            clc                 ;   bytes tested, in order to update the
            adc EFADDR          ;   persistent counter
            sta X_PC            ;   ,,
            lda #$00            ;   ,,
            adc EFADDR+1        ;   ,,
            sta X_PC+1          ;   ,,
            rts
test_err:   jmp MisError

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; SUBROUTINE EXECUTION COMPONENT
; https://github.com/Chysn/wAx/wiki/Subroutine-Execution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Execute:    bcc iterate         ; No address was provided; continue from BRKpt
            lda EFADDR          ; Set the temporary INT storage to the program
            sta SYS_DEST        ;   counter. This is what SYS uses for its
            lda EFADDR+1        ;   execution address, and I'm using that
            sta SYS_DEST+1      ;   system to borrow saved Y,X,A,P values
            lda #>RegDisp-1     ; Add the register display return address to
            pha                 ;   the stack, as the return point after the
            lda #<RegDisp-1     ;   SYS tail
            pha                 ;   ,,
            jsr SetupVec        ; Make sure the BRK handler is enabled
            jmp SYS             ; Call BASIC SYS, after the parameter parsing
iterate:    pla                 ; Remove return to Return from the stack; it
            pla                 ;   is not needed
            jsr SetupVec        ; Make sure the BRK handler is enabled
            jmp SYS_BRK         ; SYS with no tail return address
                        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; REGISTER COMPONENTS
; https://github.com/Chysn/wAx/wiki/Register-Editor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Register:   jsr ResetIn
            jsr Buff2Byte
            bcc RegDisp
            sta ACC
            jsr Buff2Byte
            bcc register_r
            sta XREG
            jsr Buff2Byte
            bcc register_r
            sta YREG
            jsr Buff2Byte
            bcc register_r
            sta PROC
register_r: rts

; Register Display            
RegDisp:    jsr ResetOut
            lda #<Registers     ; Print register display bar
            ldy #>Registers     ; ,,
            jsr PrintStr        ; ,,
            ldy #$00            ; Get registers' values from storage and add
-loop:      lda ACC,y           ;   each one to the buffer. These values came
            jsr Hex             ;   from the hardware IRQ, and are A,X,Y,P
            jsr Space           ;   ,,
            iny                 ;   ,,
            cpy #$04            ;   ,,
            bne loop            ;   ,,
            tsx                 ; Add stack pointer to the buffer
            txa                 ; ,,
            jsr Hex             ; ,,
            jsr Space           ; ,,
            lda SYS_DEST+1      ; Print high byte of SYS destination
            jsr Hex             ; ,,
            lda SYS_DEST        ; Print low byte of SYS destination
            jsr Hex             ; ,,
            jmp PrintBuff       ; Print the buffer
                        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BREAKPOINT COMPONENTS
; https://github.com/Chysn/wAx/wiki/Breakpoint-Manager
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetBreak:   php
            jsr ClearBP         ; Clear the old breakpoint, if it exists
            plp                 ; If no breakpoint is chosen (e.g., if ! was
            bcc SetupVec        ;   by itself), just clear the breakpoint
            lda EFADDR          ; Add a new breakpoint at the effective address
            sta BREAKPOINT      ; ,,
            lda EFADDR+1        ; ,,
            sta BREAKPOINT+1    ; ,,
            ;ldy #$00           ; (Y is already 0 from ClearBP)
            lda (EFADDR),y      ; Stash it in the Breakpoint data structure,
            sta BREAKPOINT+2    ;   to be restored on the next break
            tya                 ; Write BRK to the breakpoint location
            sta (EFADDR),y      ;   ,,
            lda #CRSRUP         ; Cursor up to overwrite the command
            jsr CHROUT          ; ,,
            jsr DirectMode      ; When run inside a BASIC program, skip the
            bne SetupVec        ;   BRK line display
            ldx #$01            ; List a single line for the user to review
            jsr ListLine        ; ,,
            ; Fall through to SetupVec

; Set Up Vectors
; Used by installation, and also by the breakpoint manager                    
SetupVec:   lda #<main          ; Intercept GONE to process wedge
            sta IGONE           ;   tool invocations
            lda #>main          ;   ,,
            sta IGONE+1         ;   ,,
            lda #<Break         ; Set the BRK interrupt vector
            sta CBINV           ; ,,
            lda #>Break         ; ,,
            sta CBINV+1         ; ,,
            rts

; BRK Trapper
; Replaces the default BRK handler. Gets registers from hardware interrupt
; and puts them in the SYS register storage locations. Gets program counter
; and stores it in the persistent counter location. Then falls through
; to register display.
Break:      pla                 ; Get values from stack and put them in the
            tay                 ;   proper registers
            pla                 ;   ,,
            tax                 ;   ,,
            pla                 ;   ,,
            plp                 ; Get the processor status
            cld                 ; Escape hatch for accidentally-set Decimal flag
            jsr SYS_TAIL        ; Store regiters in SYS locations
            pla                 ; Get Program Counter from interrupt and put
            sta SYS_DEST        ;   it in the persistent counter
            pla                 ;   ,,
            sta SYS_DEST+1      ;   ,,
            lda #<BreakMsg      ; Print BRK indicator
            ldy #>BreakMsg      ; ,,
            jsr PrintStr        ; ,,
            jsr RegDisp         ; Show the register display
            jmp (WARM_START)
            
; Clear Breakpoint   
; Restore breakpoint byte and zero out breakpoint data         
ClearBP:    lda BREAKPOINT      ; Get the breakpoint
            sta CHARAC          ; Stash it in a zeropage location
            lda BREAKPOINT+1    ; ,,
            sta CHARAC+1        ; ,,
            ldy #$00
            lda (CHARAC),y      ; What's currently at the Breakpoint?
            bne bp_reset        ; If it's not a BRK, then preserve what's there
            lda BREAKPOINT+2    ; Otherwise, get the breakpoint byte and
            sta (CHARAC),y      ;   put it back 
bp_reset:   sty BREAKPOINT      ; And then clear out the whole
            sty BREAKPOINT+1    ;   breakpoint data structure
            sty BREAKPOINT+2    ;   ,,
            rts

; Breakpoint Indicator
; Also restores the breakpoint byte, temporarily
BreakInd:   ldy #$00            ; Is this a BRK instruction?
            lda (EFADDR),y      ; ,,
            bne ind_r           ; If not, do nothing
            lda BREAKPOINT      ; If it is a BRK, is it our breakpoint?
            cmp EFADDR          ; ,,
            bne ind_r           ; ,,
            lda BREAKPOINT+1    ; ,,
            cmp EFADDR+1        ; ,,
            bne ind_r           ; ,,
            jsr ReverseOn       ; Reverse on for the breakpoint
            lda BREAKPOINT+2    ; Temporarily restore the breakpoint byte
            sta (EFADDR),y      ;   for disassembly purposes
ind_r:      rts        
                 
; Enable Breakpoint
; Used after disassembly, in case the BreakInd turned the breakpoint off
EnableBP:   lda BREAKPOINT+2
            beq enable_r
            lda BREAKPOINT
            sta CHARAC
            lda BREAKPOINT+1
            sta CHARAC+1
            ldy #$00            ; Write BRK to the breakpoint
            tya                 ; ,,
            sta (CHARAC),y      ; ,,
enable_r:   rts
                                                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; MEMORY SAVE AND LOAD COMPONENTS
; https://github.com/Chysn/wAx/wiki/Memory-Save-and-Load
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MemSave:    bcc save_err        ; Bail if the address is no good
            jsr Buff2Byte       ; Convert 2 characters to a byte   
            bcc save_err        ; Fail if the byte couldn't be parsed
            sta RANGE_END+1     ; Save to the range high byte
            jsr Buff2Byte       ; Convert next 2 characters to byte
            bcc save_err        ; Fail if the byte couldn't be parsed
            sta RANGE_END       ; Save to the range low byte
            jsr FileSetup       ; SETLFS, get filename length, etc.  
            ldx #<INBUFFER+9    ; ,,
            ldy #>INBUFFER+9    ; ,,
            jsr SETNAM          ; ,,
            lda #EFADDR         ; Set up SAVE call
            ldx RANGE_END       ; ,,
            ldy RANGE_END+1     ; ,,
            jsr SAVE            ; ,,
            bcs FileError
            jmp Linefeed
save_err:   jmp SYNTAX_ERR      ; To ?SYNTAX ERROR      

; Show System Disk Error            
FileError:  bne show_error      ; Error in A will be $00 if a cassette save is
            lda #$1e            ;   stopped, so override that to ?BREAK ERROR
show_error: jmp ERROR_NO 
            
; Memory Load
MemLoad:    jsr ResetIn         ; Reset the input buffer because there's no addr
            jsr FileSetup       ; SETLFS, get filename length, etc.
            ldx #<INBUFFER+1    ; Set location of filename
            ldy #>INBUFFER+1    ; ,,
            jsr SETNAM          ; ,,
            ldx DEVICE          ; If the device numbr is 1, skip the extra
            cpx #$01            ;   OPEN and go directly to LOAD
            beq cassette        ;   ,,
            jsr OPEN
            bcs open_err
            ldx #$42
            jsr CHKIN
            bcs open_err
            jsr CHRIN
            sta X_PC
            jsr CHRIN
            sta X_PC+1
open_err:   jsr CLRCHN
            lda #$42
            jsr CLOSE       
            ldx DEVICE          ; ,,
cassette:   ldy #$01            ; ,, (load to header location)
            jsr SETLFS          ; ,,
            lda #$00            ; Command for LOAD
            jsr LOAD            
            bcs FileError
            jsr DirectMode      ; Show the loaded range if the load is done in
            beq show_range      ;   direct mode
load_r:     rts
show_range: jsr ResetOut
            jsr Linefeed
            lda #T_DIS          ; Show the loaded range, if from disk
            jsr CharOut         ; ,,
            ldx DEVICE          ; If the device numbr is 1, skip the start/end
            cpx #$01            ;   display
            bne disk
            ldx $033d           ; Update the persistent counter with the start
            stx X_PC            ;   of memory loaded from cassette
            ldx $033e           ;   ,,
            stx X_PC+1          ;   ,,
disk:       jsr ShowPC          ; Show the persistent counter
            jsr Semicolon       ; Comment so disassembly works
            lda $af             ; Show the end of the loaded range
            jsr Hex             ; ,,
            lda $ae             ; ,,
            jsr Hex             ; ,,
            jmp PrintBuff       ; ,,
        
; Disk Setup
; Clear breakpoint, set up logical file, get filename length, return in A
; for call to SETNAM            
FileSetup:  jsr ClearBP         ; Clear breakpoint
            lda #$42            ; Set up logical file
            ldx DEVICE          ; ,,
            ldy #$00            ; ,,
            jsr SETLFS          ; ,,
            jsr CharGet         ; Check that the filename begins with a
            cmp #QUOTE          ;   quote. If not, treat it as a zero-length
            bne setup_r         ;   name.
            ldy #$00
-loop:      jsr CharGet
            beq setup_err
            cmp #QUOTE
            beq setup_r
            iny
            bne loop            
setup_r:    tya
            rts
setup_err:  jmp save_err
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; SEARCH COMPONENTS
; https://github.com/Chysn/wAx/wiki/Search
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Search:     bcc srch_r          ; Bail if the address is no good
            lda INBUFFER+4      ; Bail if there's nothing to search
            beq srch_r          ; ,,
            lda #SEARCH_L       ; Set the search limit (in pages)
            sta SEARCH_C        ; ,,
next_srch:  jsr ISCNTC          ; Keep searching code until the user presses
            beq srch_stop       ;   Stop key
            lda EFADDR+1        ; Store the effective address high byte for
            pha                 ;   later comparison
            jsr ResetOut        ; Clear output buffer for possible result
            lda INBUFFER+4      ; What kind of search is this?
            cmp #QUOTE          ; Character search
            beq MemSearch       ; ,,
            cmp #":"            ; Convert a hex search into a character search
            beq SetupHex        ; ,,
            bne CodeSearch      ; Default to code search
check_end:  pla                 ; Has the effective address high byte advanced?
            cmp EFADDR+1        ;   ,,
            beq next_srch       ; If not, continue the search
            dec SEARCH_C        ; If so, decrement the search counter, and
            bne next_srch       ;   end the search if it's done
            inc SEARCH_C        ; If the shift key is held down, keep the
            lda KEYCVTRS        ;   search going
            and #$01            ;   ,,
            bne next_srch       ;   ,,
srch_stop:  jsr ResetOut        ; Start a new output buffer to indicate the
            lda #"/"            ;   ending search address
            jsr CharOut         ;   ,,
            jsr ShowAddr        ;   ,,
            jsr PrintBuff       ;   ,,
srch_r:     rts   

; Code Search
; Disassemble code from the effective address. If the disassembly at that
; address matches the input, indicate the starting address of the match.
CodeSearch: lda #T_DIS
            jsr CharOut
            jsr ShowAddr
            jsr Semicolon       ; Adds comment so the disassembly works
            jsr Disasm          ; Disassmble the code at the effective address
            jsr IsMatch         ; If it matches the input, show the address
            bcc check_end       ; ,,
            jsr PrintBuff       ; Print address and disassembly   
            jmp check_end       ; Go back for more    

; Memory Search
; Compare a sequence of bytes in memory to the input. If there's a match,
; indicate the starting address of the match.            
MemSearch:  ldy #$00
-loop:      lda INBUFFER+5,y
            cmp (EFADDR),y
            bne no_match
            iny
            bne loop
no_match:   cmp #QUOTE          ; Is this the end of the search?
            bne next_check
            lda #T_MEM
            jsr CharOut            
            jsr ShowAddr
            jsr PrintBuff
next_check: jsr IncAddr  
            jmp check_end
            
; Setup Hex Search
; by converting a hex search into a memory search. Transcribe hex characters
; into the input as values.       
SetupHex:   lda #QUOTE          ; Changing the start of INBUFFER to a quote
            sta INBUFFER+4      ;   turns it into a memory search
            lda #$05            ; Place the input index after the quote so
            sta IDX_IN          ;   it can get hex bytes
            ldy #$00            ; Count the number of hex bytes
-loop:      jsr Buff2Byte       ; Is it a valid hex character?
            bcc setup_done      ; If not, the transcription is done
            sta INBUFFER+5,y    ; Store the byte in the buffer
            iny
            cpy #$08
            bne loop
setup_done: lda #QUOTE
            sta INBUFFER+5,y
            jmp check_end    
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; COPY COMPONENTS
; https://github.com/Chysn/wAx/wiki/Copy-and-Fill
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy
MemCopy:    bcc copy_err        ; Get parameters as 16-bit hex addresses for
            jsr Buff2Byte       ; Source end
            bcc copy_err        ; ,,
            sta RANGE_END+1     ; ,,
            jsr Buff2Byte       ; ,,
            bcc copy_err        ; ,,
            sta RANGE_END       ; ,,
            jsr Buff2Byte       ; Target
            bcc copy_err        ; ,,
            sta X_PC+1          ; ,,
            jsr Buff2Byte       ; ,,    
            bcc copy_err        ; ,,
            sta X_PC            ; ,,
            ldx #$00            ; Copy memory from the start address...
-loop:      lda (EFADDR,x)      ; ,,
            sta (X_PC,x)        ; ...To the target address
            lda EFADDR+1        ; ,,
            cmp RANGE_END+1     ; Have we reached the end of the copy range?
            bne advance         ; ,,
            lda EFADDR          ; ,,
            cmp RANGE_END       ; ,,
            beq copy_end        ; If so, leave the copy tool
advance:    jsr IncAddr         ; If not, advance the effective address and the
            jsr IncPC           ;   persistent counter
            jmp loop            ;   and copy the next byte
copy_end:   jmp IncPC           ; Advance persistent counter  
copy_err:   jmp SYNTAX_ERR      ; ?SYNTAX ERROR if invalid parameters
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; NUMERIC CONVERSION COMPONENTS
; https://github.com/Chysn/wAx/wiki/Numeric-Conversion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Hex to Base-10
Hex2Base10: jsr ResetIn         ; Reset input buffer
            jsr Buff2Byte
            bcc hex_conv_r      ; There's no byte available, so bail
            sta EFADDR+1
            jsr Buff2Byte
            sta EFADDR
            bcs two_bytes       ; There are two good bytes
            lda EFADDR+1        ; If there's only one good byte, then
            sta EFADDR          ;   treat that as a low byte, and make the
            lda #$00            ;   high byte zero
            sta EFADDR+1        ;   ,,
two_bytes:  lda #"#"
            jsr CHROUT
            ldx EFADDR          ; Set up PRTFIX for base-10 integer output
            lda EFADDR+1        ; ,,
            jsr PRTFIX          ; ,,
            jsr Linefeed
hex_conv_r: rts            
            
; Base-10 to Hex
Base102Hex: jsr ResetOut
            jsr HexPrefix
            ldy #<INBUFFER
            lda #>INBUFFER
            sty $7a
            sta $7b
            jsr CHRGOT
            jsr ASCFLT
            jsr MAKADR
            lda SYS_DEST+1
            beq only_low
            jsr Hex
only_low:   lda SYS_DEST
            jsr Hex
b102h_r:    jmp PrintBuff
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; SYMBOLIC ASSEMBLER COMPONENTS
; https://github.com/Chysn/wAx/wiki/Symbol-Table-Manager
; https://github.com/Chysn/wAx/wiki/Labels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Initialize Symbol Table
; And also, initialize the location counter
InitSym:    lda INBUFFER        
            beq LabelList       ; If the tool is alone, show the symbol table
            cmp #LABEL          ; If - follows the tool, clear the symbol list
            beq init_clear      ; ,,
            jsr RefreshPC       ; If no valid address is provided, just leave
            bcc init_r          ;   X_PC as it was
            lda #$00            ; Reset forward reference overflow counter
            sta OVERFLOW_F      ; ,,
EAtoPC:     lda EFADDR          ; Initialize persistent counter with effective
            sta X_PC            ;   address
            lda EFADDR+1        ;   ,,
            sta X_PC+1          ;   ,,
            rts
init_clear: lda #$00            ; Initialize bytes for the symbol table
            ldy #ST_SIZE-1      ;   See the Symbol Table section at the top for
-loop:      sta SYMBOL_D,y      ;   information about resizing or relocating the
            dey                 ;   symbol table
            bpl loop            ;   ,,
init_r:     rts
            
; Get Symbol Index            
SymbolIdx:  cmp #"@"            ; @ and > are special symbols that are always
            bne spec_fwd        ;   defined as the highest symbol index.
            ldy #MAX_LAB-1      ;   ,,
            bne spec_lab        ;   ,,
spec_fwd:   cmp #$b1            ; Handle the > label by giving it the special
            bne sym_range       ;   symbol index, and then clearing out the
            ldy #MAX_LAB-1      ;   address for the symbol so that it's treated
            tya                 ;   as a forward reference
            tax
            lda #$00
            sta SYMBOL_AL,x
            sta SYMBOL_AH,x
spec_lab:   lda #"@"+$80            ;   > is a forward reference, when used,
            pha                 ;   but the special symbol is always "@"
            bne sym_found
sym_range:  cmp #"0"
            bcc bad_label       ; Symbol no good if less than "0"
            cmp #"Z"+1
            bcs bad_label
            cmp #"9"+1
            bcc good_label
            cmp #"A"
            bcs good_label
bad_label:  clc
            rts      
good_label: ora #$80            ; High bit set indicates symbol is defined
            pha
            ldy #MAX_LAB-2      ; See if the label is already in the table
-loop:      cmp SYMBOL_D,y      ; ,,
            beq sym_found       ; ,,
            dey                 ; ,,
            bpl loop            ; ,,
            ldy #MAX_LAB-2      ; If the symbol isn't already in use, look for
-loop:      lda SYMBOL_D,y      ;   an empty record
            beq sym_found       ;   ,,
            dey                 ;   ,,
            bpl loop            ;   ,,
            pla                 ; No empty symbol is found; all symbols are in        
            jmp bad_label       ;   use. Return for error
sym_found:  pla
            sta SYMBOL_D,y      ; Populate the symbol label table with the name
            sec                 ; Set Carry flag indicates success
            rts            
            
; Show Label List           
LabelList:  ldx #$00
-loop:      txa                 ; Save the iterator from PrintBuff, etc.
            pha                 ; ,,
            tay                 ; ,,
            lda SYMBOL_AL,y     ; Stash the current value in EFADDR
            sta EFADDR          ; ,,
            lda SYMBOL_AH,y     ; ,,
            sta EFADDR+1        ; ,,
            lda EFADDR          ; If this symbol is undefined (meaning, it is
            bne show_label      ;   $0000, then skip it)
            lda EFADDR+1        ;   ,,
            beq undefd          ; Undefined, but it might be a forward reference
show_label: jsr LabListCo       ; Add elements common to both listed item
            jsr ShowAddr
            jsr PrintBuff
next_label: pla
            tax
            inx
            cpx #MAX_LAB
            bne loop
            jsr ResetOut        ; Show the value of the persistent counter
            jsr Space           ; ,,
            lda #"*"            ; ,,
            jsr CharOut         ; ,,
            jsr Space           ; ,,
            jsr ShowPC          ; ,,
            lda OVERFLOW_F      ; Show the overflow forward reference count
            beq lablist_r       ;   (if any)
            pha                 ;   ,,
            jsr Space           ;   ,,
            jsr ReverseOn       ;   ,,
            jsr GT              ;   ,,
            pla                 ;   ,,
            jsr Hex             ;   ,,
lablist_r:  jsr PrintBuff       ;   ,,
            rts
undefd:     stx IDX_SYM
            ldy #$00            ; Forward reference count for this label
            ldx #$00            ; Forward record index
-loop:      lda SYMBOL_F,x
            bpl next_undef
            and #$3f
            cmp IDX_SYM
            bne next_undef
            iny
next_undef: inx
            cpx #MAX_FWD
            bne loop
            cpy #$00
            beq next_label
show_fwd:   tya
            pha
            ldx IDX_SYM
            jsr LabListCo
            jsr ReverseOn
            jsr GT
            pla
            jsr Hex
fwd_d:      jsr PrintBuff
            jmp next_label

; Label List Common            
LabListCo:  jsr ResetOut
            lda #"-"
            jsr CharOut
            lda SYMBOL_D,x
            and #$7f
            jsr CharOut
            jmp Space
            
; Symbol is Defined
; Zero flag is clear if symbol is defined
IsDefined:  lda SYMBOL_AL,y
            bne is_defined
            lda SYMBOL_AH,y
is_defined: rts             

; Expand Symbol
; and return to Transcribe
ExpandSym:  sty IDX_SYM
            jsr ResetOut
            jsr HexPrefix
            ldy #$01            ; See if the user has entered H or L after
            lda ($7a),y         ;   the label
            pha
            ldy IDX_SYM
            cmp #"L"            ; If L is specified, jump right to the low
            beq insert_lo       ;   byte
            lda SYMBOL_AH,y     ; Otherwise, add the high byte
            jsr Hex             ; ,,
            pla                 ; Pull and push back the CHRGET input
            pha                 ; ,,
            cmp #"H"            ; If the high byte was specified, skip
            beq do_expand       ;   the low byte
insert_lo:  lda SYMBOL_AL,y
            jsr Hex
do_expand:  lda #$00            ; Add delimiter, since the hex operand can
            jsr CharOut         ;   vary in length
            ldy #$00            ; Transcribe symbol expansion into the
-loop:      lda OUTBUFFER,y     ;   input buffer
            beq end_expand      ;   ,,
            jsr AddInput        ;   ,,
            iny                 ;   ,,
            jmp loop            ;   ,,
end_expand: pla                 ; Get the CHRGET character back
            cmp #"L"            ; Discard L or H,
            beq discard         ; ,,
            cmp #"H"            ; ,,
            bne expand_r
discard:    jsr CHRGET
expand_r:   jmp Transcribe        
            
; Resolve Forward Reference            
ResolveFwd: lda IDX_SYM
            ora #$80            ; Set high bit, which is what we look for here
            ldx #$00            ; First order of business is finding unresolved
-loop:      cmp SYMBOL_F,x      ;   records that match the label
            beq fwd_used
            ora #$40            ; Also check for high-byte specifier
            cmp SYMBOL_F,x
            beq fwd_used
            and #%10111111      ; Mask away high-byte specifier for next check
            inx
            cpx #MAX_FWD
            bne loop
            rts                 ; Label not found in forward reference table
fwd_used:   lda SYMBOL_FL,x     ; A forward reference for this label has been
            sta CHARAC          ;   found; store the address in zero page for
            lda SYMBOL_FH,x     ;   updating the code at this address.
            sta CHARAC+1        ;   ,,
            ldy #$00            ; Get the byte at the reference address, which
            lda (CHARAC),y      ;   should be an instruction opcode
            jsr Lookup          ; Look it up
            bcs get_admode      ; ,,
            jmp CannotRes       ; Not a valid instruction; CAN'T RESOLVE ERROR
get_admode: cmp #RELATIVE       ; If it's a relative branch instruction,
            beq load_rel        ;   calculate the branch offset
            cmp #ABSOLUTE       ; Two bytes will be replaced, so make sure
            beq load_abs        ;   this instruction is one of the
            cmp #ABSOLUTE_X     ;   absolute addressing modes, or indirect mode
            beq load_abs        ;   ,,
            cmp #ABSOLUTE_Y     ;   ,,
            beq load_abs        ;   ,,
            cmp #INDIRECT       ;   ,,
            beq load_abs        ;   ,,
            cmp #IMPLIED        ; If an implied mode instruction is somehow
            bne load_immed      ;   being resolved, throw ASSEMBLY ERROR
            jmp CannotRes       ;   ,,
load_abs:   lda EFADDR          ; For an absolute mode instruction, just
            ldy #$01            ;   transfer the two bytes over
            sta (CHARAC),y      ;   ,,
            lda EFADDR+1        ;   ,,
            iny                 ;   ,,
            sta (CHARAC),y      ;   ,,
            jmp clear_back      ; Go back and see if there are more to resolve
load_rel:   lda EFADDR          ; The target is the current effective address
            sec                 ; Subtract the reference address and add
            sbc CHARAC          ;   two to get the offset
            sec                 ;   ,,
            sbc #$02            ;   ,,
            ldy #$01            ; Store the computed offset in the forward
            sta (CHARAC),y      ;   reference operand address
            jmp clear_back      ; Go back and see if there are more to resolve
load_immed: lda #$40            ; Check bit 6 of the label byte of the forward
            and SYMBOL_F,x      ;   reference symbol record. If it's set, it
            beq load_low        ;   means that the user wants the high byte
            lda EFADDR+1        ;   of the symbol target
            .byte $3c           ; Skip word
load_low:   lda EFADDR          ; For other instructions
            ldy #$01
            sta (CHARAC),y
clear_back: lda #$00            ; Clear the forward reference table record for
            sta SYMBOL_F,x      ;   re-use, and go back for additional
            jmp ResolveFwd      ;   forward references
            
; Add Forward Record
; For label in Y            
; Each forward reference record consists of three bytes-
; Offset 0 - Label Index OR %10000000
AddFwdRec:  ldx #$00            ; Search the forward symbol table for a
-loop:      lda SYMBOL_FL,x     ;   record in use with the same address.
            cmp EFADDR          ;   If such a record is found, re-use it
            bne next_used       ;   rather than searching the empty records
            lda SYMBOL_FH,x     ;   ,,
            cmp EFADDR+1        ;   ,,
            beq empty_rec       ;   ,,
next_used:  inx                 ;   ,,
            cpx #MAX_FWD        ;   ,,
            bne loop            ;   ,,
find_empty: ldx #$00            ; Now, search ALL the records, this time looking
-loop:      lda SYMBOL_F,x      ;   for an unused record.
            beq empty_rec       ; This is an empty record, so use it
            inx
            cpx #MAX_FWD        ; Check the limit of forward reference records
            bne loop
overflow:   inc OVERFLOW_F      ; Increment overflow counter if no records are
            beq overflow        ;   left; if it rolls to 0, set it to 1 instead
            jsr DirectMode      ; If the overflow happens in direct mode, show
            bne addfwd_r        ;   the Symbol Error. In BASIC, this condition
            jmp SymError        ;   can be caught, so keep going for multi-pass
empty_rec:  tya
            ora #$80            ; Set the high bit to indicate record in use
            pha
            ldy #$01            ; Look at the next character in the CHRGET
            lda ($7a),y         ;   buffer
            tay
            pla
            cpy #"H"            ; If the next character is H, then set bit 6
            bne store_rec       ;   to indicate that the high byte should
            ora #$40            ;   be used on resolution
store_rec:  sta SYMBOL_F,x      ; Store the label index in the record
            lda EFADDR          ; Store the current effective address in the
            sta SYMBOL_FL,x     ;   forward reference record for (hopefully)
            lda EFADDR+1        ;   later resolution
            sta SYMBOL_FH,x     ;   ,,
addfwd_r:   rts
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BASIC STAGE SELECT COMPONENT
; https://github.com/Chysn/wAx/wiki/Change-BASIC-Stage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
BASICStage: jsr ResetIn         ; Reset the input buffer index
            sta EFADDR          ; Set default end page
            jsr Buff2Byte       ; Get the first hex byte
            bcc st_range        ; If no valid address was provided, show range
            sta EFADDR+1        ; This is the stage's starting page number
            jsr Buff2Byte       ; But the default can be overridden if a valid
            bcc ch_length       ;   starting page is provided
            sta EFADDR          ;   ,,
ch_length:  lda EFADDR+1        ; Make sure that the ending page isn't lower
            cmp EFADDR          ;   in memory than the starting page. If it is,
            bcc set_ptrs        ;   default the stage size to 3.5K
            clc                 ;   ,,
            adc #$0e            ;   ,,
            sta EFADDR          ;   ,,
set_ptrs:   lda EFADDR+1        ; Set up the BASIC start and end pointers
            sta $2c             ;   and stuff
            sta $2e             ;   ,,
            sta $30             ;   ,,
            sta $32             ;   ,,
            lda #$01            ;   ,,
            sta $2b             ;   ,,
            lda #$03            ;   ,,
            sta $2d             ;   ,,
            sta $2f             ;   ,,
            sta $31             ;   ,,
            lda #$00            ;   ,,
            sta $33             ;   ,,
            sta $37             ;   ,,
            lda EFADDR          ;   ,,
            sta $34             ;   ,,
            sta $38             ;   ,,
            ldy #$00            ; Clear the low byte. From here on out, we're     
            sty EFADDR          ;   dealing with the start of the BASIC stage
            ldy #$00            ; Look through the input buffer for an "N"
-loop:      lda INBUFFER,y      ;   character. This indicates that it is a
            beq finish          ;   new stage.
            cmp #"N"            ;   ,,
            beq new             ;   ,,
            iny
            cpy #$16            ; If we reach the end without seeing an "N",
            bne loop            ;   just rechain the area as if it were a BASIC
            beq finish          ;   program
new:        lda #$00            ; Zero out the first few bytes of the stage so
            ldy #$02            ;   that it looks like a NEW program. I'm not
-loop:      sta (EFADDR),y      ;   using BASIC's NEW at $c642 because it does
            dey                 ;   not store $00 at the page boundary, which
            bpl loop            ;   causes problems.
finish:     jsr Rechain
            jmp (READY)
st_range:   jsr ResetOut        ; Show the start and end pages of the current
            jsr HexPrefix       ;   BASIC stage
            lda $2c             ;   ,,
            jsr Hex             ;   ,,
            jsr Space           ;   ,,
            lda $34             ;   ,,
            jsr Hex             ;   ,,
            jmp PrintBuff       ;   ,,

; Rechain BASIC program
Rechain:    jsr $c533           ; Re-chain BASIC program to set BASIC
            lda $22             ;   pointers as a courtesy to the user
            ;clc                ;   ,, ($c533 always exits with Carry clear)
            adc #$02            ;   ,,
            sta $2D             ;   ,,
            lda $23             ;   ,,
            jmp $C655           ;   ,,
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; User Tool
; https://github.com/Chysn/wAx/wiki/User-Tool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UserTool:   jmp (USER_VECT)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; SUBROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Look up opcode
; Reset Language Table            
Lookup:     sta OPCODE          ; OPCODE is the found opcode
            jsr ResetLang       ; Reset the language table reference
-loop:      jsr NextInst        ; Get the next 6502 instruction in the table
            ldy TOOL_CHR        ; If the tool is the extended disassembly,
            cpy #T_XDI          ;   use the end of the extended table,
            bne std_table       ;   otherwise, use the standard 6502 table
            cmp #XTABLE_END     ; If we've reached the end of the table,
            .byte $3c           ; TOP (skip word)
std_table:  cmp #TABLE_END            
            beq not_found       ;   then the instruction is invalid
            cmp OPCODE          ; If the instruction doesn't match the opcode,
            bne loop            ;   keep searching.
found:      ldy #$01
            lda (LANG_PTR),y    ; A match was found! Set the addressing mode
            sec                 ;   and set the carry flag to indicate success
            rts
not_found:  clc                 ; Reached the end of the language table without
            rts                 ;   finding a matching instruction
                                    
; Reset Language Table            
ResetLang:  lda #<InstrSet-2    ; Start two bytes before the Instruction Set
            sta LANG_PTR        ;   table, because advancing the table will be
            lda #>InstrSet-2    ;   an early thing we do
            sta LANG_PTR+1      ;   ,,
            rts
            
; Next Instruction in Language Table
; Handle mnemonics by recording the last found mnemonic and then advancing
; to the following instruction. The opcode is returned in A.
NextInst:   lda #$02            ; Each language entry is two bytes. Advance to
            clc                 ;   the next entry in the table
            adc LANG_PTR        ;   ,,
            sta LANG_PTR        ;   ,,
            bcc ch_mnem         ;   ,,
            inc LANG_PTR+1      ;   ,,
ch_mnem:    ldy #$01            ; Is this entry an instruction record?
            lda (LANG_PTR),y    ; ,,
            and #$01            ; ,,
            beq adv_lang_r      ; If it's an instruction, return
            lda (LANG_PTR),y    ; Otherwise, set the mnemonic in the workspace
            sta MNEM+1          ;   as two bytes, five bits per character for
            dey                 ;   three characters. See the 6502 table for
            lda (LANG_PTR),y    ;   a description of the data encoding
            sta MNEM            ;   ,,
            jmp NextInst        ; Go to what should now be an instruction
adv_lang_r: ldy #$00            ; When an instruction is found, set A to its
            lda (LANG_PTR),y    ;   opcode and return
            rts
            
; Get Character
; Akin to CHRGET, but scans the INBUFFER, which has already been detokenized            
CharGet:    ldx IDX_IN
            lda INBUFFER,x
            php
            inc IDX_IN
            plp
            rts             
            
; Buffer to Byte
; Get two characters from the buffer and evaluate them as a hex byte
Buff2Byte:  jsr CharGet
            jsr Char2Nyb
            bcc buff2_r         ; Return with Carry clear if invalid
            asl                 ; Multiply high nybble by 16
            asl                 ;   ,,
            asl                 ;   ,,
            asl                 ;   ,,
            sta WORK
            jsr CharGet
            jsr Char2Nyb
            bcc buff2_r         ; Clear Carry flag indicates invalid hex
            ora WORK            ; Combine high and low nybbles
            ;sec                ; Set Carry flag indicates success
buff2_r:    rts
       
; Is Buffer Match            
; Does the input buffer match the output buffer?
; Carry is set if there's a match, clear if not
IsMatch:    ldy #$06            ; Offset for character after address
-loop:      lda OUTBUFFER,y     ; Compare the assembly with the disassembly
            cmp INBUFFER-2,y    ;   in the buffers
            bne not_found       ; See Lookup subroutine above
            iny
            cpy IDX_OUT
            bne loop            ; Loop until the buffer is done
            sec                 ; This matches; set carry
            rts

; Character to Nybble
; A is the character in the text buffer to be converted into a nybble
Char2Nyb:   cmp #"9"+1          ; Is the character in range 0-9?
            bcs not_digit       ; ,,
            cmp #"0"            ; ,,
            bcc not_digit       ; ,,
            sbc #"0"            ; If so, nybble value is 0-9
            rts
not_digit:  cmp #"F"+1          ; Is the character in the range A-F?
            bcs not_found       ; See Lookup subroutine above
            cmp #"A"         
            bcc not_found       ; See Lookup subroutine above
            sbc #"A"-$0a        ; The nybble value is 10-15
            rts
            
; Increment Effective Address
; Get the EA byte and advance EA by one
IncAddr:    ldx #$00
            lda (EFADDR,x)
            inc EFADDR
            bne next_r
            inc EFADDR+1
next_r:     rts

; Incremenet Persistent Counter
IncPC:      inc X_PC 
            bne pc_r 
            inc X_PC+1
pc_r:       rts 

; Commonly-Used Characters
Semicolon:  lda #";"            
            .byte $3c           ; TOP (skip word)
GT:         lda #">"
            .byte $3c           ; TOP (skip word)
ReverseOn   lda #RVS_ON
            .byte $3c           ; TOP (skip word)
CloseParen: lda #")"
            .byte $3c           ; TOP (skip word)
Comma:      lda #","
            .byte $3c           ; TOP (skip word)
Space:      lda #" "
            .byte $3c           ; TOP (skip word)
HexPrefix:  lda #"$"
            ; Fall through to CharOut
            
; Character to Output
; Add the character in A to the outut byffer            
CharOut:    sta CHARAC          ; Save temporary character
            tya                 ; Save registers
            pha                 ; ,,
            txa                 ; ,,
            pha                 ; ,,
            ldx IDX_OUT         ; Write to the next OUTBUFFER location
            lda CHARAC          ; ,,
            sta OUTBUFFER,x     ; ,,
            inc IDX_OUT         ; ,,
            pla                 ; Restore registers
            tax                 ; ,,
            pla                 ; ,,
            tay                 ; ,,
write_r:    rts             
            
; Write hexadecimal character
Hex:        pha                 ; Hex converter based on from WOZ Monitor,
            lsr                 ;   Steve Wozniak, 1976
            lsr
            lsr
            lsr
            jsr prhex
            pla
prhex:      and #$0f
            ora #"0"
            cmp #"9"+1
            bcc echo
            adc #$06
echo:       jmp CharOut

; Get Binary Byte
; Return in A     
BinaryByte: lda #$00
            sta TEMP_CALC
            lda #%10000000
-loop:      pha
            jsr CharGet
            cmp #"1"
            bne zero
            pla
            pha
            ora TEMP_CALC
            sta TEMP_CALC
            jmp next_bit
zero:       cmp #"0"
            bne bad_bin
next_bit:   pla
            lsr
            bne loop
            lda TEMP_CALC
            sec
            rts
bad_bin:    jmp AsmError
 
; Show Effective Address
; 16-bit hex address at effective address          
ShowAddr:   lda EFADDR+1
            jsr Hex
            lda EFADDR
            jmp Hex 

; Show Persistent Counter
; 16-bit hex address at persistent counter address          
ShowPC:     lda X_PC+1
            jsr Hex
            lda X_PC
            jmp Hex
            
; Show 8-bit Parameter           
Param_8:    jsr HexPrefix
            jsr IncAddr   
            jmp Hex            
            
; Show 16-Bit Parameter            
Param_16:   jsr HexPrefix
            jsr IncAddr   
            pha
            jsr IncAddr   
            jsr Hex
            pla
            jmp Hex

; Transcribe to Buffer
; Get a character from the input buffer and transcribe it to the
; input buffer. If the character is a BASIC token, then possibly
; explode it into individual characters.
Transcribe: jsr CHRGET          ; Get character from input buffer
            cmp #$00            ; If it's 0, then quit transcribing and return
            beq xscribe_r       ; ,,
            cmp #$ac            ; Replace an asterisk with the persistent
            beq ExpandXPC       ;   counter
            cmp #";"            ; If it's a comment, then quit transcribing
            beq comment         ;   unless we're in quote mode
            cmp #LABEL          ; Handle symbolic labels
            beq handle_sym      ; ,,
            cmp #QUOTE          ; If a quote is found, modify CHRGET so that
            bne ch_token        ;   spaces are no longer filtered out
            lda #$06            ; $0082 BEQ $0073 -> BEQ $008a
            sta $83             ; ,,
            lda #QUOTE          ; Put quote back so it can be added to buffer
ch_token:   cmp #$80            ; Is the character in A a BASIC token?
            bcc x_add           ; If it's not a token, just add it to buffer
            ldy $83             ; If it's a token, check the CHRGET routine
            cpy #$06            ;  and skip detokenization if it's been
            beq x_add           ;  modified.
            jsr Detokenize      ; Detokenize and continue transciption
            jmp Transcribe      ; ,, (Carry is always set by Detokenize)
x_add:      jsr AddInput        ; Add the text to the buffer
            jmp Transcribe      ; (Carry is always set by AddInput)
xscribe_r:  jmp AddInput        ; Add the final zero, and fix CHRGET...
handle_sym: ldy TOOL_CHR        ; The label character is not handled by the
            cpy #T_SYM          ;   symbol init tool, because it's used to
            beq x_add           ;   clear the symbol table
            ldy $83             ; Don't handle symbols if the - is in quotes
            cpy #$06            ;   (as in an immediate operand, or text entry)
            beq x_add           ;   ,,
            ldy IDX_IN          ; If the label character occurs deep in the
            cpy #$0d            ;   input, don't handle a symbol. It's in the
            bcs x_add           ;   memory dump display.            
            lda IDX_IN          ; If - is the first character in the input
            cmp #$04            ;   buffer after the address, defer the
            bne start_exp       ;   symbol for handling by the assembler
            lda #LABEL          ;   ,,
            jsr AddInput        ;   ,,
            jmp Transcribe      ;   ,,
start_exp:  jsr CHRGET          ; Get the next character, the label
            jsr SymbolIdx       ; Get the symbol index
            bcs get_label
            jmp SymError        ; If not, ?SYMBOL ERROR
get_label:  jsr IsDefined
            bne go_expand
            lda IDX_IN          ; The symbol has not yet been defined; parse
            pha                 ;   the first hex numbers to set the program
            jsr RefreshPC       ;   counter, then return the input index to
            pla                 ;   its original position
            sta IDX_IN          ;   ,,
            jsr AddFwdRec       ; Add forward reference record for label Y
            inc IGNORE_RB       ; Set relative branch ignore flag
go_expand:  jmp ExpandSym       ; Use $0000 as a placeholder
comment:    ldy $83
            cpy #$06
            beq add_only
            lda #$06            ; Move into quote mode so that label characters
            sta $83             ; are no longer expanded
            lda #$00
add_only:   beq x_add

; Expand External Program Counter
; Replace asterisk with the X_PC
ExpandXPC:  jsr ResetOut
            jsr ShowPC
            ldy #$00
-loop:      lda OUTBUFFER,y
            jsr AddInput
            iny
            cpy #$04
            bne loop
            jmp Transcribe
           
; Reset Output Buffer
ResetOut:   lda #$00
            sta IDX_OUT
            rts    

; Reset Input Buffer
ResetIn:    lda #$00
            sta IDX_IN
            rts
                 
; Add Input
; Add a character to the input buffer and advance the counter
AddInput:   ldx IDX_IN
            cpx #$16            ; Wedge lines are limited to the physical
            bcs add_r           ;   line length
            sta INBUFFER,x
            inc IDX_IN
add_r:      rts
           
; Detokenize
; If a BASIC token is found, explode that token into PETSCII characters 
; so it can be disassembled. This is based on the ROM uncrunch code around $c71a
Detokenize: ldy #$65
            tax                 ; Copy token number to X
get_next:   dex
            beq explode         ; Token found, go write
-loop       iny                 ; Else increment index
            lda KEYWORDS,y      ; Get byte from keyword table
            bpl loop            ; Loop until end marker
            bmi get_next
explode:    iny                 ; Found the keyword; get characters from
            lda KEYWORDS,y      ;   table
            bmi last_char       ; If there's an end marker, mask byte and
            jsr AddInput        ;   add to input buffer
            bne explode
last_char:  and #$7f            ; Take out bit 7 and
            jmp AddInput        ;   add to input buffer
 
; Print Buffer
; Add a $00 delimiter to the end of the output buffer, and print it out           
PrintBuff:  lda #$00
            jsr CharOut
            lda #<OUTBUFFER
            ldy #>OUTBUFFER
            jsr PrintStr
print_done: lda #RVS_OFF        ; Reverse off after each line
            jsr CHROUT          ; ,,
            ; Fall through to Linefeed

Linefeed:   lda #LF
            jmp CHROUT             
           
; Print String
; Like BASIC's $cb1e, but not destructive to BASIC memory when coming from
; the BASIC input buffer (see $d4bb)         
PrintStr:   sta CHARAC
            sty CHARAC+1
            ldy #$00
-loop:      lda (CHARAC),y
            beq print_r
            jsr CHROUT
            lda #$00            ; Turn off quote mode for each character
            sta $d4             ; ,,
            iny
            bne loop
print_r:    rts            
            
; Prompt for Next Line
; X should be set to the number of bytes the effective address should be
; advanced
Prompt:     txa                 ; Based on the incoming X register, advance
            clc                 ;   the effecive address and store in the
            adc EFADDR          ;   persistent counter. This is how wAx
            sta X_PC            ;   remembers where it was
            lda #$00            ;   ,,
            adc EFADDR+1        ;   ,,
            sta X_PC+1          ;   ,,
            jsr ResetOut        ; Reset the output buffer to generate the prompt
            lda #T_ASM          ; The prompt begins with the assembler tool's
            jsr CharOut         ;   wedge character
            jsr ShowPC          ; Show persistent counter
            lda TOOL_CHR        ; Check the tool character
            cmp #T_ASM          ; If it's assembler, then add a space
            bne crsr_over       ; ,,
            lda #" "            ; ,,
            .byte $3c           ; TOP (skip word)
crsr_over:  lda #CRSRRT         ; Cursor right if not assembler tool
            jsr CharOut
            ldy #$00
-loop:      lda OUTBUFFER,y     ; Copy the output buffer into KEYBUFF, which
            sta KEYBUFF,y       ;   will simulate user entry
            iny                 ;   ,,
            cpy #$06            ;   ,,
            bne loop            ;   ,,
            sty KBSIZE          ; Setting the buffer size will make it go
prompt_r:   rts            
                            
; In Direct Mode
; If the wAx tool is running in Direct Mode, the Zero flag will be set
DirectMode: ldy CURLIN+1
            iny
            rts
                        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ToolTable contains the list of tools and addresses for each tool
ToolTable:	.byte T_DIS,T_ASM,T_MEM,T_REG,T_EXE,T_BRK,T_TST,T_SAV,T_LOA,T_BIN
            .byte T_XDI,T_SRC,T_CPY,T_H2T,T_T2H,T_SYM,T_BAS,T_USR,T_USL
ToolAddr_L: .byte <List-1,<Assemble-1,<List-1,<Register-1,<Execute-1
            .byte <SetBreak-1,<Tester-1,<MemSave-1,<MemLoad-1,<List-1
            .byte <List-1,<Search-1,<MemCopy-1,<Hex2Base10-1,<Base102Hex-1
            .byte <InitSym-1,<BASICStage-1,<UserTool-1,<List-1
ToolAddr_H: .byte >List-1,>Assemble-1,>List-1,>Register-1,>Execute-1
            .byte >SetBreak-1,>Tester-1,>MemSave-1,>MemLoad-1,>List-1
            .byte >List-1,>Search-1,>MemCopy-1,>Hex2Base10-1,>Base102Hex-1
            .byte >InitSym-1,>BASICStage-1,>UserTool-1,>List-1

; Addresses for error message text
ErrAddr_L:  .byte <AsmErrMsg,<MISMATCH,<LabErrMsg,<ResErrMsg,<RBErrMsg
ErrAddr_H:  .byte >AsmErrMsg,>MISMATCH,>LabErrMsg,>ResErrMsg,>RBErrMsg

; Text display tables  
Intro:      .asc LF,"  BEIGEMAZE.COM/WAX",LF,$00                   
Registers:  .asc LF,$b0,"A",$c0,$c0,"X",$c0,$c0,"Y",$c0,$c0
            .asc "P",$c0,$c0,"S",$c0,$c0,"PC",$c0,$c0,LF,";",$00
BreakMsg:   .asc LF,RVS_ON,"BRK",RVS_OFF,$00

; Error messages
AsmErrMsg:  .asc "ASSEMBL",$d9
LabErrMsg:  .asc "SYMBO",$cc
ResErrMsg:  .asc "CAN",$27,"T RESOLV",$c5
RBErrMsg:   .asc "TOO FA",$d2

; Instruction Set
; This table contains two types of one-word records--mnemonic records and
; instruction records. Every word in the table is in big-endian format, so
; the high byte is first.
;
; Mnemonic records are formatted like this...
;     fffffsss ssttttt1
; where f is first letter, s is second letter, and t is third letter. Bit
; 0 of the word is set to 1 to identify this word as a mnemonic record.
;
; Each mnemonic record has one or more instruction records after it.
; Instruction records are formatted like this...
;     oooooooo aaaaaaa0
; where o is the opcode and a is the addressing mode (see Constants section
; at the top of the code). Bit 0 of the word is set to 0 to identify this
; word as an instruction record.
InstrSet:   .byte $09,$07       ; ADC
            .byte $69,$a0       ; * ADC #immediate
            .byte $65,$70       ; * ADC zeropage
            .byte $75,$80       ; * ADC zeropage,X
            .byte $6d,$40       ; * ADC absolute
            .byte $7d,$50       ; * ADC absolute,X
            .byte $79,$60       ; * ADC absolute,Y
            .byte $61,$20       ; * ADC (indirect,X)
            .byte $71,$30       ; * ADC (indirect),Y
            .byte $0b,$89       ; AND
            .byte $29,$a0       ; * AND #immediate
            .byte $25,$70       ; * AND zeropage
            .byte $35,$80       ; * AND zeropage,X
            .byte $2d,$40       ; * AND absolute
            .byte $3d,$50       ; * AND absolute,X
            .byte $39,$60       ; * AND absolute,Y
            .byte $21,$20       ; * AND (indirect,X)
            .byte $31,$30       ; * AND (indirect),Y
            .byte $0c,$d9       ; ASL
            .byte $06,$70       ; * ASL zeropage
            .byte $16,$80       ; * ASL zeropage,X
            .byte $0e,$40       ; * ASL absolute
            .byte $1e,$50       ; * ASL absolute,X
            .byte $0a,$d0       ; * ASL accumulator
            .byte $10,$c7       ; BCC
            .byte $90,$c0       ; * BCC relative
            .byte $10,$e7       ; BCS
            .byte $b0,$c0       ; * BCS relative
            .byte $11,$63       ; BEQ
            .byte $f0,$c0       ; * BEQ relative
            .byte $12,$69       ; BIT
            .byte $24,$70       ; * BIT zeropage
            .byte $2c,$40       ; * BIT absolute
            .byte $13,$53       ; BMI
            .byte $30,$c0       ; * BMI relative
            .byte $13,$8b       ; BNE
            .byte $d0,$c0       ; * BNE relative
            .byte $14,$19       ; BPL
            .byte $10,$c0       ; * BPL relative
            .byte $14,$97       ; BRK
            .byte $00,$b0       ; * BRK implied
            .byte $15,$87       ; BVC
            .byte $50,$c0       ; * BVC relative
            .byte $15,$a7       ; BVS
            .byte $70,$c0       ; * BVS relative
            .byte $1b,$07       ; CLC
            .byte $18,$b0       ; * CLC implied
            .byte $1b,$09       ; CLD
            .byte $d8,$b0       ; * CLD implied
            .byte $1b,$13       ; CLI
            .byte $58,$b0       ; * CLI implied
            .byte $1b,$2d       ; CLV
            .byte $b8,$b0       ; * CLV implied
            .byte $1b,$61       ; CMP
            .byte $c9,$a0       ; * CMP #immediate
            .byte $c5,$70       ; * CMP zeropage
            .byte $d5,$80       ; * CMP zeropage,X
            .byte $cd,$40       ; * CMP absolute
            .byte $dd,$50       ; * CMP absolute,X
            .byte $d9,$60       ; * CMP absolute,Y
            .byte $c1,$20       ; * CMP (indirect,X)
            .byte $d1,$30       ; * CMP (indirect),Y
            .byte $1c,$31       ; CPX
            .byte $e0,$a0       ; * CPX #immediate
            .byte $e4,$70       ; * CPX zeropage
            .byte $ec,$40       ; * CPX absolute
            .byte $1c,$33       ; CPY
            .byte $c0,$a0       ; * CPY #immediate
            .byte $c4,$70       ; * CPY zeropage
            .byte $cc,$40       ; * CPY absolute
            .byte $21,$47       ; DEC
            .byte $c6,$70       ; * DEC zeropage
            .byte $d6,$80       ; * DEC zeropage,X
            .byte $ce,$40       ; * DEC absolute
            .byte $de,$50       ; * DEC absolute,X
            .byte $21,$71       ; DEX
            .byte $ca,$b0       ; * DEX implied
            .byte $21,$73       ; DEY
            .byte $88,$b0       ; * DEY implied
            .byte $2b,$e5       ; EOR
            .byte $49,$a0       ; * EOR #immediate
            .byte $45,$70       ; * EOR zeropage
            .byte $55,$80       ; * EOR zeropage,X
            .byte $4d,$40       ; * EOR absolute
            .byte $5d,$50       ; * EOR absolute,X
            .byte $59,$60       ; * EOR absolute,Y
            .byte $41,$20       ; * EOR (indirect,X)
            .byte $51,$30       ; * EOR (indirect),Y
            .byte $4b,$87       ; INC
            .byte $e6,$70       ; * INC zeropage
            .byte $f6,$80       ; * INC zeropage,X
            .byte $ee,$40       ; * INC absolute
            .byte $fe,$50       ; * INC absolute,X
            .byte $4b,$b1       ; INX
            .byte $e8,$b0       ; * INX implied
            .byte $4b,$b3       ; INY
            .byte $c8,$b0       ; * INY implied
            .byte $53,$61       ; JMP
            .byte $4c,$40       ; * JMP absolute
            .byte $6c,$10       ; * JMP indirect
            .byte $54,$e5       ; JSR
            .byte $20,$40       ; * JSR absolute
            .byte $61,$03       ; LDA
            .byte $a9,$a0       ; * LDA #immediate
            .byte $a5,$70       ; * LDA zeropage
            .byte $b5,$80       ; * LDA zeropage,X
            .byte $ad,$40       ; * LDA absolute
            .byte $bd,$50       ; * LDA absolute,X
            .byte $b9,$60       ; * LDA absolute,Y
            .byte $a1,$20       ; * LDA (indirect,X)
            .byte $b1,$30       ; * LDA (indirect),Y
            .byte $61,$31       ; LDX
            .byte $a2,$a0       ; * LDX #immediate
            .byte $a6,$70       ; * LDX zeropage
            .byte $b6,$90       ; * LDX zeropage,Y
            .byte $ae,$40       ; * LDX absolute
            .byte $be,$60       ; * LDX absolute,Y
            .byte $61,$33       ; LDY
            .byte $a0,$a0       ; * LDY #immediate
            .byte $a4,$70       ; * LDY zeropage
            .byte $b4,$80       ; * LDY zeropage,X
            .byte $ac,$40       ; * LDY absolute
            .byte $bc,$50       ; * LDY absolute,X
            .byte $64,$e5       ; LSR
            .byte $46,$70       ; * LSR zeropage
            .byte $56,$80       ; * LSR zeropage,X
            .byte $4e,$40       ; * LSR absolute
            .byte $5e,$50       ; * LSR absolute,X
            .byte $4a,$d0       ; * LSR accumulator
            .byte $73,$e1       ; NOP
            .byte $ea,$b0       ; * NOP implied
            .byte $7c,$83       ; ORA
            .byte $09,$a0       ; * ORA #immediate
            .byte $05,$70       ; * ORA zeropage
            .byte $15,$80       ; * ORA zeropage,X
            .byte $0d,$40       ; * ORA absolute
            .byte $1d,$50       ; * ORA absolute,X
            .byte $19,$60       ; * ORA absolute,Y
            .byte $01,$20       ; * ORA (indirect,X)
            .byte $11,$30       ; * ORA (indirect),Y
            .byte $82,$03       ; PHA
            .byte $48,$b0       ; * PHA implied
            .byte $82,$21       ; PHP
            .byte $08,$b0       ; * PHP implied
            .byte $83,$03       ; PLA
            .byte $68,$b0       ; * PLA implied
            .byte $83,$21       ; PLP
            .byte $28,$b0       ; * PLP implied
            .byte $93,$d9       ; ROL
            .byte $26,$70       ; * ROL zeropage
            .byte $36,$80       ; * ROL zeropage,X
            .byte $2e,$40       ; * ROL absolute
            .byte $3e,$50       ; * ROL absolute,X
            .byte $2a,$d0       ; * ROL accumulator
            .byte $93,$e5       ; ROR
            .byte $66,$70       ; * ROR zeropage
            .byte $76,$80       ; * ROR zeropage,X
            .byte $6e,$40       ; * ROR absolute
            .byte $7e,$50       ; * ROR absolute,X
            .byte $6a,$d0       ; * ROR accumulator
            .byte $95,$13       ; RTI
            .byte $40,$b0       ; * RTI implied
            .byte $95,$27       ; RTS
            .byte $60,$b0       ; * RTS implied
            .byte $98,$87       ; SBC
            .byte $e9,$a0       ; * SBC #immediate
            .byte $e5,$70       ; * SBC zeropage
            .byte $f5,$80       ; * SBC zeropage,X
            .byte $ed,$40       ; * SBC absolute
            .byte $fd,$50       ; * SBC absolute,X
            .byte $f9,$60       ; * SBC absolute,Y
            .byte $e1,$20       ; * SBC (indirect,X)
            .byte $f1,$30       ; * SBC (indirect),Y
            .byte $99,$47       ; SEC
            .byte $38,$b0       ; * SEC implied
            .byte $99,$49       ; SED
            .byte $f8,$b0       ; * SED implied
            .byte $99,$53       ; SEI
            .byte $78,$b0       ; * SEI implied
            .byte $9d,$03       ; STA
            .byte $85,$70       ; * STA zeropage
            .byte $95,$80       ; * STA zeropage,X
            .byte $8d,$40       ; * STA absolute
            .byte $9d,$50       ; * STA absolute,X
            .byte $99,$60       ; * STA absolute,Y
            .byte $81,$20       ; * STA (indirect,X)
            .byte $91,$30       ; * STA (indirect),Y
            .byte $9d,$31       ; STX
            .byte $86,$70       ; * STX zeropage
            .byte $96,$90       ; * STX zeropage,Y
            .byte $8e,$40       ; * STX absolute
            .byte $9d,$33       ; STY
            .byte $84,$70       ; * STY zeropage
            .byte $94,$80       ; * STY zeropage,X
            .byte $8c,$40       ; * STY absolute
            .byte $a0,$71       ; TAX
            .byte $aa,$b0       ; * TAX implied
            .byte $a0,$73       ; TAY
            .byte $a8,$b0       ; * TAY implied
            .byte $a4,$f1       ; TSX
            .byte $ba,$b0       ; * TSX implied
            .byte $a6,$03       ; TXA
            .byte $8a,$b0       ; * TXA implied
            .byte $a6,$27       ; TXS
            .byte $9a,$b0       ; * TXS implied
            .byte $a6,$43       ; TYA
            .byte $98,$b0       ; * TYA implied
            .byte TABLE_END,$00 ; End of 6502 table
Extended:   .byte $0b,$87       ; ANC
            .byte $0b,$a0       ; * ANC immediate
            .byte $2b,$a0       ; * ANC immediate
            .byte $98,$71       ; SAX
            .byte $87,$70       ; * SAX zero page
            .byte $97,$90       ; * SAX zero page,y
            .byte $83,$20       ; * SAX (indirect,x)
            .byte $8f,$40       ; * SAX absolute
            .byte $0c,$a5       ; ARR
            .byte $6b,$a0       ; * ARR immediate
            .byte $0c,$e5       ; ASR
            .byte $4b,$a0       ; * ASR immediate
            .byte $66,$03       ; LXA
            .byte $ab,$a0       ; * LXA immediate
            .byte $9a,$03       ; SHA
            .byte $9f,$60       ; * SHA absolute,y
            .byte $93,$30       ; * SHA (indirect),y
            .byte $98,$b1       ; SBX
            .byte $cb,$a0       ; * SBX immediate
            .byte $20,$e1       ; DCP
            .byte $c7,$70       ; * DCP zero page
            .byte $d7,$80       ; * DCP zero page,x
            .byte $cf,$40       ; * DCP absolute
            .byte $df,$50       ; * DCP absolute,x
            .byte $db,$60       ; * DCP absolute,y
            .byte $c3,$20       ; * DCP (indirect,x)
            .byte $d3,$30       ; * DCP (indirect),y
            .byte $23,$e1       ; DOP
            .byte $04,$70       ; * DOP zero page
            .byte $14,$80       ; * DOP zero page,x
            .byte $34,$80       ; * DOP zero page,x
            .byte $44,$70       ; * DOP zero page
            .byte $54,$80       ; * DOP zero page,x
            .byte $64,$70       ; * DOP zero page
            .byte $74,$80       ; * DOP zero page,x
            .byte $80,$a0       ; * DOP immediate
            .byte $82,$a0       ; * DOP immediate
            .byte $89,$a0       ; * DOP immediate
            .byte $c2,$a0       ; * DOP immediate
            .byte $d4,$80       ; * DOP zero page,x
            .byte $e2,$a0       ; * DOP immediate
            .byte $f4,$80       ; * DOP zero page,x
            .byte $4c,$c5       ; ISB
            .byte $e7,$70       ; * ISB zero page
            .byte $f7,$80       ; * ISB zero page,x
            .byte $ef,$40       ; * ISB absolute
            .byte $ff,$50       ; * ISB absolute,x
            .byte $fb,$60       ; * ISB absolute,y
            .byte $e3,$20       ; * ISB (indirect,x)
            .byte $f3,$30       ; * ISB (indirect),y
            .byte $60,$4b       ; LAE
            .byte $bb,$60       ; * LAE absolute,y
            .byte $60,$71       ; LAX
            .byte $a7,$70       ; * LAX zero page
            .byte $b7,$90       ; * LAX zero page,y
            .byte $af,$40       ; * LAX absolute
            .byte $bf,$60       ; * LAX absolute,y
            .byte $a3,$20       ; * LAX (indirect,x)
            .byte $b3,$30       ; * LAX (indirect),y
            .byte $73,$e1       ; NOP
            .byte $1a,$b0       ; * NOP implied
            .byte $3a,$b0       ; * NOP implied
            .byte $5a,$b0       ; * NOP implied
            .byte $7a,$b0       ; * NOP implied
            .byte $da,$b0       ; * NOP implied
            .byte $fa,$b0       ; * NOP implied
            .byte $93,$03       ; RLA
            .byte $27,$70       ; * RLA zero page
            .byte $37,$80       ; * RLA zero page,x
            .byte $2f,$40       ; * RLA absolute
            .byte $3f,$50       ; * RLA absolute,x
            .byte $3b,$60       ; * RLA absolute,y
            .byte $23,$20       ; * RLA (indirect,x)
            .byte $33,$30       ; * RLA (indirect),y
            .byte $94,$83       ; RRA
            .byte $67,$70       ; * RRA zero page
            .byte $77,$80       ; * RRA zero page,x
            .byte $6f,$40       ; * RRA absolute
            .byte $7f,$50       ; * RRA absolute,x
            .byte $7b,$60       ; * RRA absolute,y
            .byte $63,$20       ; * RRA (indirect,x)
            .byte $73,$30       ; * RRA (indirect),y
            .byte $98,$87       ; SBC
            .byte $eb,$a0       ; * SBC immediate
            .byte $9b,$1f       ; SLO
            .byte $07,$70       ; * SLO zero page
            .byte $17,$80       ; * SLO zero page,x
            .byte $0f,$40       ; * SLO absolute
            .byte $1f,$50       ; * SLO absolute,x
            .byte $1b,$60       ; * SLO absolute,y
            .byte $03,$20       ; * SLO (indirect,x)
            .byte $13,$30       ; * SLO (indirect),y
            .byte $9c,$8b       ; SRE
            .byte $47,$70       ; * SRE zero page
            .byte $57,$80       ; * SRE zero page,x
            .byte $4f,$40       ; * SRE absolute
            .byte $5f,$50       ; * SRE absolute,x
            .byte $5b,$60       ; * SRE absolute,y
            .byte $43,$20       ; * SRE (indirect,x)
            .byte $53,$30       ; * SRE (indirect),y
            .byte $9a,$31       ; SHX
            .byte $9e,$60       ; * SHX absolute,y
            .byte $9a,$33       ; SHY
            .byte $9c,$50       ; * SHY absolute,x
            .byte $a3,$e1       ; TOP
            .byte $0c,$40       ; * TOP absolute
            .byte $1c,$50       ; * TOP absolute,x
            .byte $3c,$50       ; * TOP absolute,x
            .byte $5c,$50       ; * TOP absolute,x
            .byte $7c,$50       ; * TOP absolute,x
            .byte $dc,$50       ; * TOP absolute,x
            .byte $fc,$50       ; * TOP absolute,x
            .byte $0b,$8b       ; ANE
            .byte $8b,$a0       ; * ANE immediate
            .byte $9a,$27       ; SHS
            .byte $9b,$60       ; * SHS absolute,y
            .byte $50,$5b       ; JAM
            .byte $02,$b0       ; * JAM implied           
            .byte $43,$29       ; HLT
            .byte $02,$b0       ; * HLT implied
            .byte XTABLE_END,$00; End of 6502 extended table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; wAx API JUMP TABLE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This JMP table starts at $7000
jBuff2Byte: jmp Buff2Byte
jCharGet:   jmp CharGet
jCharOut:   jmp CharOut
jHex:       jmp Hex
jIncAddr:   jmp IncAddr
jIncPC:     jmp IncPC
jLookup:    jmp Lookup
jPrintBuff: jmp PrintBuff
jResetIn:   jmp ResetIn
jResetOut:  jmp ResetOut
jShowAddr:  jmp ShowAddr
jShowPC:    jmp ShowPC
jEAtoPC:    jmp EAtoPC
