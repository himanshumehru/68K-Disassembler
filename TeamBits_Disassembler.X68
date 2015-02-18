*	INCLUDE "FINALTEST.X68"
*-----------------------------------------------------------
* Title      :  Team Bits Disassembler
* Written by :  Himanshu Mehru, William Tanna, Igor Ummel
* Date       :  02-18-2014
* Description:  This program disassembles machine code back
*               to 68K Assembly Language instructions
*-----------------------------------------------------------
    ORG    $1000
START:                  
    
        LEA        INTRO,A1         Display intro message
        MOVE.B     #14,D0           Trap task 14 prints data in D0 to screen
        TRAP       #15              Execute task 14
		MOVE.B     #0, LINE_COUNT   Initilize the LINE_COUNTER variable 
START_ADDR  
        LEA        ST_ADDR_MSG,A1   Display starting address message
        MOVE.B     #14,D0           Trap task 14 prints data in D0 to screen
        TRAP       #15              Execute task 14           
        LEA        ST_INPUT,A1      Stores user input into memory
        MOVEQ      #2,D0            Trap task 2 scans user input from the console
        TRAP       #15              Execute task2           
        JSR        CORRECT_LEN      Test the input string for Correct Length
        CMP.B      #1, D4           D4==1 means true. Input has passed the test
        BEQ        CONT_ST2         Correct input so continue with the program
IN_FAIL     
        LEA        IN_FAIL_MSG,A1   but if it fails, then 
        MOVE.B     #14,D0           Trap task 14 prints data in D0 to screen
        TRAP       #15              Print IN_FAIL_MSG to console
        BRA        START_ADDR       Prompt for starting address again           
CONT_ST2    
        JSR        ASC_HEX          Convert ascii to hex
        MOVEA.L    D3,A5            Store starting address into A5
        JSR        ODD_TEST         Check to see if input is odd
        CMP.B      #1,D4            D4==1 means true. Input has passed the test
        BEQ        CONT_ST3         input passed the odd test continue with further testing
        BRA        START_ADDR       failed the odd test so ask for input again
CONT_ST3    
        JSR        RANGE_TEST       Test if the input is within the valid address range
        CMP.B      #0,D4            Check if input failed the range test
        BEQ        START_ADDR       ask for starting address again
        MOVE.L     D3,D7            Move the address to D1 for comparison with ending address           
        MOVEA.L    D3,A5            input address passed all addresses
END_ADDR    
        LEA        EN_ADDR_MSG,A1   Display starting address message
        MOVE.B     #14,D0           Trap task 14 prints data in D0 to screen
        TRAP       #15              Execute task 14
        LEA        EN_INPUT,A1      Stores user input into memory
        MOVEQ      #2,D0            Trap task 2 scans user input from the console
        TRAP       #15              Execute task 2
        CLR.L      D3               Clear D3 so that ending address can be stored            
        JSR        CORRECT_LEN      Test to see if ending address passes the input tests
        CMP.B      #1,D4            D4==1 means true. Input has passed the test.
        BEQ        CONT_END2        Passed the length test. continue to further testing
        LEA        IN_FAIL_MSG,A1   but if it fails, then 
        MOVE.B     #14,D0
        TRAP       #15              Print IN_FAIL_MSG to console
        BRA        END_ADDR         Ask for ending address again            
CONT_END2   
        JSR        ASC_HEX          Branch to ascii to hex convesion 
        MOVEA.L    D3,A6            Store ending address into A6
        JSR        ODD_TEST         Check to see if input is odd
        CMP.B      #1,D4            D4==1 means true. Input has passed the test
        BEQ        CONT_END3        Input passed the odd test continue with further testing
        BRA        END_ADDR         failed the odd test so ask for input again
CONT_END3   
        JSR        RANGE_TEST       Test if the input is within the valid address range
        CMP.B      #0,D4            Check if input failed the range test
        BEQ        END_ADDR         ask for starting address again
        MOVEA.L    D3,A6            input address passed all addresses
        JSR        STLTEN           Is starting address less than ending address?
        CMP.B      #0,D4            Check if input failed the test
        BEQ        END_ADDR         ask for ending address again    
        MOVEA.L    D3,A6            input address passed all addresses
        CLR.L      D7               Empty D7 and delete starting address from here
        ADD        #2, A6           Set offset in A6 to grab last data
        LEA        NEXT_STEP, A1    Load NEXT_STEP Message to A1
        MOVE.B     #14,D0           Print odd address error message
        TRAP       #15              Call Trap 15 for output
        BRA        GETKEY           Call the GETKEY function to figure out the user input
ASC_HEX     
        CMPI.B      #$0,D1          Check to see if all ascii characters are converted
        BEQ         DONE
        MOVE.B     (A1)+,D2         Move first number to data register
        CMPI.B      #$39,D2         See if D2 is a number
        BLE         CON_NUM        
CON_LET     
        SUBI.B      #$37,D2         Convert ascii to hex letter
        BRA         COUNTER 
CON_NUM     
        SUBI.B      #$30,D2         Convert ascii to hex number
        BRA         COUNTER            
COUNTER     
        SUBI.B      #$1,D1          Decrement counter
        ADD.B       D2,D3           Add converted number to rest of convereted address
        CMPI.B      #$0,D1          Check to see if all ascii characters are converted
        BEQ         ASC_HEX        
        ROL.L       #4,D3           Move converted address number to the left to add new number.
        BRA         ASC_HEX
DONE        
        RTS
CORRECT_LEN  
        CLR.L      D4              	Empty D4 in order to store new test resuls
        MOVEQ      #$0,D5          	Empty out D5 to test if input == null
        CMP.B      D5,D1           	is the input==null? length of input is in D1. is it ==0?
        BEQ        INPUT_FAIL      	input was null
        CMPI       #$8,D1          	is input longer than a longword?
        BGT        INPUT_FAIL      	input was longer than a longword
        MOVE.B     #$1,D4          	input is of correct length
        RTS
INPUT_FAIL   
        MOVEQ      #$0,D4          	put 0 (test fail) in D4
        RTS             
ODD_TEST     
        CLR.L       D2             	Empty D2 for use with this Sub routine
        CLR.L       D4             	Empty D4 in order to store new test results
        MOVE.W      D3,D2          	Copy address to D2 to use with this Sub routine
        MOVE.L      #$00000002,D1  	Put 2 in D1 so we can use it to divide input by 2
        DIVU        D1,D2          	Divide the input address by 2
        SWAP        D2             	Store the remainder in D2
        CMP.B       #1,D2          	Is the remainder ==1
        BEQ         ODD_TEST_FAIL  	Remainder is 1 so input fails odd test
        MOVE.B     #$1,D4          	Odd test passed so store 1 in D4
        RTS                        	ODD_TEST passed so just return
ODD_TEST_FAIL   
        LEA     ODD_ADD_MSG,A1  	Load ODD_ADD_MSG to A1
        MOVE.B  #14,D0          	Print odd address error message
        TRAP    #15                     
        MOVEQ   #$0,D4          	put 0 (test fail) in D4 
        CLR.L   D3              	Empty the address for redo
        RTS                
RANGE_TEST   
        CLR.L      D4              	Empty D4 in order to store new test results
        MOVE.L     #MIN_ST_ADD,D1  	load minimum address into D1 for later comparison
        CMP.L      D1,D3           	Compare minimum address with input
        BLT        TOO_LOW_ERROR   	input is too low. 
        MOVE.L     #MAX_EN_ADD,D1  	load maximum possible address into d2 for comparison
        CMP.L      D1,D3           	compare maximum address with input
        BGT        TOO_HI_ERROR    	input is too high
        MOVEQ      #$1,D4          	test passed so store 1 in D4
        RTS                        	input is within range
TOO_LOW_ERROR    
        LEA    TOO_LOW_MSG,A1  		load too low error message into A1
        MOVE.B #14,D0          		print error message to screen
        TRAP   #15
        MOVE.B #$0,D4          		test failed so put 0 in D4 
        CLR.L  D3              		Empty the address for redo
        RTS
TOO_HI_ERROR    
        LEA     TOO_HI_MSG,A1   	load too high error message in A1
        MOVE.B  #14,D0          	Print error message to screen
        TRAP    #15
        MOVE.B  #$0,D4          	test failed so put 0 in D4
        CLR.L   D3              	Empty the address for redo
        RTS    
STLTEN  
        CLR.L   D4              	Empty D4 in order to store new test results
        CMP.L   D3,D7           	Compare starting address with ending address
        BGT     STLT_ERROR      	Ending address cannot be less than the starting address
        MOVEQ   #$1,D4          	Pass the test
        RTS
STLT_ERROR
        LEA     STLT_MSG,A1     	Print error message:ending address cannot be less than starting address
        MOVE.B  #14,D0				Set print trap
        TRAP    #15					Call print
        MOVE.B  #$0,D4          	Test Failed
        CLR.L   D3          		Clear the register
        RTS							Return
LOOP        
        MOVE.W  (A5)+, D6           Move instruction to D6
        LEA     GOOD_BUFFER, A3     initialize good buffer
        LEA     BAD_BUFFER, A4      initialize bad buffer
        JSR     PUSHADDR            Push the current address to the good buffer for printing
        JSR		SETUPBADDATA		Setup the bad data printing
        JSR     FIRST4BITS          Get the first 4 bits of the instruction
        CMP.B   $FF,D7              Is the instruction bad data?
        BEQ     PRINTBADDATA		It is! Print it out
        MOVE.B  #$00,(A3)+          Add 00 good buffer.
        LEA     GOOD_BUFFER,A1		Print good data
        MOVEQ   #13,D0				Set trap printing
        TRAP    #15					Call Trap
CONTINUELOOP        
        CMP.W   A5, A6				Compare starting and ending address
        BEQ     END					They are equal! End program
        CMP.W	A6, A5				Compare starting and ending address
        BGT		END					The starting is greater than ending!! End program
        ADD.B   #1, LINE_COUNT      Add +1 to the Line Counter
        CMP.B   #29, LINE_COUNT     If we hit the page limit, check what the user wants to do next
        BEQ     CHECK_STATUS		Hit end of page, see what the user wants to do
        BRA     LOOP				Else go back to the loop and print next instruction

SETUPBADDATA
   	    MOVE.B	#'B',(A4)+			Insert B into the output
        MOVE.B	#'A',(A4)+			Insert A into the output
        MOVE.B	#'D',(A4)+			Insert D into the output
        MOVE.B	#' ',(A4)+			Insert a space into the output
        MOVE.B	#'D',(A4)+			Insert D into output
        MOVE.B	#'A',(A4)+			Insert A into output
        MOVE.B	#'T',(A4)+			Insert T into output
        MOVE.B	#'A',(A4)+			Insert A into output
        MOVE.B	#' ',(A4)+			Insert a space into output
        MOVE.B	#'$',(A4)+			Insert a $ into output

GETBADDATA            
        MOVEQ	#4,D0               Move counter to D0
        MOVE.W  D6,D4               Move longword address into D4
DATA_PREP9                      	
    	ROL.W  #4,D4               	Move the MSB to LSB
    	MOVE.L D4,D5               	Move longword address to D5
    	ANDI.L #$0000000F,D5       	Clear everything except for MSB
DATA_ASC9
    	CMPI.B #$09,D5             	Is the character a number?
    	BLE    DATA_NUM9            Branch if yes.
DATA_LET9
    	ADDI.B #$37,D5             	Convert into a prinatble ascii letter
    	BRA    DATA_CHAR9
DATA_NUM9 
    	ADDI.B #$30,D5             	Convert into a prinatble ascii number
    	BRA    DATA_CHAR9
DATA_CHAR9
    	SUBI.B #1,D0               	Decrement counter
    	MOVE.B D5,(A4)+            	Move ascii into bad buffer also
    	CMPI.B #0,D0               	Have we moved all characters?
    	BGT    DATA_PREP9          	if not, repeat loop
    	RTS
PRINTBADDATA
        MOVE.B  #$00,(A4)+          Add 00 BAD_BUFFER so we can end the line.
        LEA     BAD_BUFFER,A1		Load the bad data into A1
        MOVEQ   #13,D0				set print trap
        TRAP    #15					Call trap
        CLR.L	D7					Clear the bad data flag
        BRA     CONTINUELOOP		Go back to main loop
OPCODESETUP
        MOVE.B  #11, D0             Task 11 - Clear screen
        MOVE.W  #$FF00, D1          Clear Screen
        TRAP    #15                 Call Trap
        BRA     LOOP                Call loop to start OP code stuff
CHECK_STATUS
        MOVEQ   #13,D0              Set trap to 13 to print
        MOVE.B  #$00, LINE_COUNT    Reset the Line Count
        LEA     NEXT_STEP, A1       Print out next step instruction
        MOVE.B  #13, D0             Set trap to 13 to print
        TRAP    #15                 Call trap
        BRA     GETKEY              Find out what the user wants to do
END
        LEA     END_STEP, A1       	Print out next step message
        MOVE.B  #13, D0             Set trap to 13 to print
        TRAP    #15                 Call trap
        BRA     ENDGETKEY           Find out what the user wants to do
RESTART     
        MOVE.B  #11, D0             Task 11 - Clear screen
        MOVE.W  #$FF00, D1          Clear Screen
        TRAP    #15                 Call Trap
        MOVE.B  #12,D0              Keyboard echo
        MOVE.B  #1,D1               Visible
        TRAP    #15
        MOVE.L  #$0000000, A0       Reset A1
        MOVE.L  #$0000000, A1       Reset A1
        MOVE.L  #$0000000, A2       Reset A2
        MOVE.L  #$0000000, A3       Reset the Good Buffer
        MOVE.L  #$0000000, A4       Reset A4
        MOVE.L  #$0000000, A5       Reset the Starting address
        MOVE.L  #$0000000, A6       Reset the Ending Address
        MOVEA.L #$01000000,A7       Reset stack pointer
        CLR.L   D1                  Reset D1
        CLR.L   D1                  Reset D1
        CLR.L   D2                  Reset D2
        CLR.L   D3                  Reset D3
        CLR.L   D4                  Reset D4
        CLR.L   D5                  Reset D5
        CLR.L   D6                  Reset D6
        BRA     START               Restart the program
FIRST4BITS
        CLR.B   D1					Clear D1 so other tests don't get bugged
        MOVE.W  D6, D5              Move the instruction so we can shift it
        LSR.W   #8, D5				Shift 8 bits to the right
        LSR.W   #4, D5				Shift 4 biths to the right
        MULU    #8, D5             	Offset D5 to show the word binary for the instruction
        LEA     INSTTABLE, A0      	Set the table to A0 so we know where to jump to
        JSR     0(A0,D5)          	Set jumptable
        RTS

ENDGETKEY
        MOVE.B  #12,D0              Use keyboard echo trap
        MOVE.B  #0,D1               Reset Keyboard input
        TRAP    #15                 Reset Keyboard input
        MOVE.B  #5, D0              Set the trap to 15 for keyboard echo
        TRAP    #15                 Use trap
        CMP.B   #$72, D1            Compare the key press with R
        BEQ     RESTART             it's RESTART, restart program
        CMP.B   #$52, D1            Compare the key press with r
        BEQ     RESTART             it's RESTART, restart program
        CMP.B   #$71, D1            Compare the key press with q
        BEQ     THE_END             it's q, end program
        CMP.B   #$51, D1            Compare the key press with Q
        BEQ     THE_END             It's Q, end program
        CMP.B   #$5D, D1            Check the key press with [
        BNE     GETKEY              If it is 0, we haven't pressed the correct key
        BRA     THE_END				Else just end the program

GETKEY
        MOVE.B  #12,D0              Use keyboard echo trap
        MOVE.B  #0,D1               Reset Keyboard input
        TRAP    #15                 Reset Keyboard input
        MOVE.B  #5, D0              Set the trap to 15 for keyboard echo
        TRAP    #15                 Use trap
        CMP.B   #$D, D1             Compare the key press with ENTER
        BEQ     OPCODESETUP         it's Enter, continue
        CMP.B   #$72, D1            Compare the key press with R
        BEQ     RESTART             it's RESTART, restart program
        CMP.B   #$52, D1            Compare the key press with r
        BEQ     RESTART             it's RESTART, restart program
        CMP.B   #$71, D1            Compare the key press with q
        BEQ     THE_END             it's q, end program
        CMP.B   #$51, D1            Compare the key press with Q
        BEQ     THE_END             It's Q, end program
        CMP.B   #$5D, D1            Check the key press with [
        BNE     GETKEY              If it is 0, we haven't pressed the correct key
        BRA     OPCODESETUP         Continue anyway if they know the secret key
PUSHADDR
        MOVEQ	#8,D0               Move counter to D0
        MOVE.L  A5,D4               Move longword address into D4
       SUB.B	#2, D4				Subtract 2 to compensate for increment to get instruction
DATA_PREP8                     
       ROL.L  #4,D4               	Move the MSB
       MOVE.L D4,D5               	Move longword address to D5
       ANDI.L #$0000000F,D5       	Clear everything except for MSB
DATA_ASC8
        CMPI.B #$09,D5             	Is the character a number?
        BLE    DATA_NUM8            Branch if yes.
DATA_LET8
        ADDI.B #$37,D5             	Convert into a prinatble ascii letter
        BRA    DATA_CHAR8
DATA_NUM8 
        ADDI.B #$30,D5             	Convert into a prinatble ascii number
        BRA    DATA_CHAR8
DATA_CHAR8
        SUBI.B #1,D0               	Decrement counter
        MOVE.B D5,(A3)+            	Move ascii into good buffer
        MOVE.B D5,(A4)+            	Move ascii into bad buffer also
        CMPI.B #0,D0               	Have we moved all characters?
        BGT    DATA_PREP8          	if not, repeat loop
        MOVE.B  #$20,(A3)+         	add a couple spaces after the address 
        MOVE.B  #$20,(A3)+         	for good buffer
        MOVE.B  #$20,(A4)+        	add a couple spaces after the address 
        MOVE.B  #$20,(A4)+         	for bad buffer
        RTS                        	If so, return
********************************************************
* OP CODE                                              *
********************************************************       
INSTTABLE
		JSR     INSTR0000           Call function for instructions that start with 0000
    	RTS
    	JSR     INSTR0001           Call function for instructions that start with 0001
    	RTS
    	JSR     INSTR0010           Call function for instructions that start with 0010
    	RTS
    	JSR     INSTR0011           Call function for instructions that start with 0011
	    RTS
	    JSR     INSTR0100           Call function for instructions that start with 0100
	    RTS
	    JSR     INSTR0101           Call function for instructions that start with 0101
	    RTS
	    JSR     INSTR0110           Call function for instructions that start with 0110
	    RTS
	    JSR     INSTR0111           Call function for instructions that start with 0111
	    RTS
	    JSR     INSTR1000           Call function for instructions that start with 1000
	    RTS
	    JSR     INSTR1001           Call function for instructions that start with 1001
	    RTS
	    JSR     INSTR1010           Call function for instructions that start with 1010
	    RTS
	    JSR     INSTR1011           Call function for instructions that start with 1011
	    RTS
	    JSR     INSTR1100           Call function for instructions that start with 1100
	    RTS
	    JSR     INSTR1101           Call function for instructions that start with 1101
	    RTS
	    JSR     INSTR1110           Call function for instructions that start with 1110
	    RTS
	    JSR     INSTR1111           Call function for instructions that start with 1111
	    RTS

********************************************************
* 0000 - ADDI, ANDI, BCHG, CMPI, EORI INSTRUCTION'S    *
********************************************************
INSTR0000
    MOVE.W  D6, D5						Move the instruction to D5 for bit shifting
    LSR.W   #$8, D5 					Shift 8 bits to the right
    ANDI.W  #$000F, D5					Just get the first 4 bits
    MULU    #$8, D5						Set offset by 8
    LEA     ZERINST,A0					Set ZERINST jumptabe
    JSR     0(A0, D5)					Call it
    RTS									Return instruction
********************************************************
* 0001 - MOVE.B INSTRUCTION                            *
********************************************************
INSTR0001   
    MOVE.B  #'M',(A3)+                  Insert M into the output
    MOVE.B  #'O',(A3)+                  Insert O into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'E',(A3)+                  Insert E into the output
    MOVE.B  #'.',(A3)+                  Insert . into the output
    MOVE.B  #'B',(A3)+                  Insert B into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     EAMOVE                      Call the special EA move function
    RTS                                 Return the instruction
********************************************************
* 0010 - MOVE.L INSTRUCTION                            *
********************************************************
INSTR0010
    MOVE.B  #'M',(A3)+                  Insert M into the output
    MOVE.B  #'O',(A3)+                  Insert O into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'E',(A3)+                  Insert E into the output
    MOVE.B  #'.',(A3)+                  Insert . into the output
    MOVE.B  #'L',(A3)+                  Insert L into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVEQ   #1,D1                       Flag that we may need a longword of immediate data
    JSR     EAMOVE                      Call the special EA move function
    RTS                                 Return the instruction
********************************************************
* 0011 - MOVE.W INSTRUCTION                            *
********************************************************
INSTR0011
    MOVE.B  #'M',(A3)+                  Insert M into the output   
    MOVE.B  #'O',(A3)+                  Insert O into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'E',(A3)+                  Insert E into the output
    MOVE.B  #'.',(A3)+                  Insert . into the output
    MOVE.B  #'W',(A3)+                  Insert W into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     EAMOVE                      Call the special EA move function
    RTS                                 Return the instruction
********************************************************
* 0100 - CLR, JSR, LEA, MOVEM, RTS INSTRUCTION'S       *                              
********************************************************
INSTR0100
    MOVE.W  D6, D5                      Move instruction for shifting
    LSR.W   #$8, D5						Shift 8 bits to the right
    ANDI.W  #$000F, D5					Just get the first 4 bits
    MULU    #8, D5						Set offset by 8
    LEA     FOURTABLE, A0				Set FOURTABLE jump table
    JSR     00(A0,D5)   				Call jumptable
    RTS									Return instruction
********************************************************
* 0101 - SUBQ INSTRUCTION                              *       
********************************************************
INSTR0101
    MOVE.B  #'S',(A3)+                  Insert S into the output
    MOVE.B  #'U',(A3)+                  Insert U into the output
    MOVE.B  #'B',(A3)+                  Insert B into the output
    MOVE.B  #'Q',(A3)+                  Insert Q into the output
    MOVE.B  #'.',(A3)+                  Insert . into the output
    JSR     GETSIZE                     Get the size of ADD
    CMP.B   #%00, D3                    Is it Byte data?
    BEQ     BYTEDATASUBQ                If so go to BYTEDATASUBQ
    CMP.B   #$01, D3                    Is it Word data?
    BEQ     WORDDATASUBQ                If so go to WORDDATASUBQ
    CMP.B   #$02, D3                    Is it Long data?
    BEQ     LONGDATASUBQ                If so go to LONGDATASUBQ
    MOVE.B  $11, D7                     It's not a byte, word or long, so it's bad data
    RTS                                 Return bad data
BYTEDATASUBQ
    MOVE.B  #'B',(A3)+                  Move B into output
    BRA     FINISHSUBQ                  Finish the SUBQ instruction
WORDDATASUBQ
    MOVE.B  #'W',(A3)+                  Move W into output
    BRA     FINISHSUBQ                  Finish the SUBQ instruction
LONGDATASUBQ
    MOVE.B  #'L',(A3)+                  Move L into output
    MOVEQ   #1,D1                       Flag that we may need a longword of immediate data
    BRA     FINISHSUBQ                  Finish the SUBQ instruction

FINISHSUBQ
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVE.B  #'#',(A3)+                  Insert a # into the output
    MOVE.W  D6, D3                      Get the number the Dn is in
    LSL.W   #4, D3                      Shift left by 4 bits
    LSR.W   #8, D3                      Shift right by 8 bits
    LSR.W   #5, D3                      Shift right by 8 bits
    MULU    #6, D3                      Set the offset for the jump table
    LEA     REGISTER,A0                 Set the table to A0
    JSR     00(A0,D3)                   Set jumptable
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     EACODE						Call EA Code
    RTS                                 Return the instruction
********************************************************
* 0110 - BGT, BLE, BVS INSTRUCTION'S                   *                  
********************************************************
INSTR0110
    MOVE.W  D6, D5                      Prep instruction for shifting
    LSL.W   #4, D5                      Shift 4 bits to the left
    LSR.W   #8, D5                      Shift 8 bits to the right
    LSR.W   #4, D5                      Shift 4 bits to the right
    CMP.B   #%1110, D5                  Does it equal $E?
    BEQ     BGTINST                     Yup, go to BGT Instruction
    CMP.B   #%1111, D5                  Does it equal $F?
    BEQ     BLEINST                     Yup, go to BLE Instruction
    CMP.B   #%1001, D5                  Does it equal $9?
    BEQ     BVSINST                     Yup, go to BVS Instruction
    MOVE.B  $11, D7                     Else this is bad data
    RTS                                 Return bad data

BGTINST
    MOVE.B  #'B',(A3)+                  Insert B into the output
    MOVE.B  #'G',(A3)+                  Insert G into the output
    MOVE.B  #'T',(A3)+                  Insert T into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     BCCCODE                     Get the EA stuff
    RTS                                 Return instruction
BLEINST
    MOVE.B  #'B',(A3)+                  Insert B into the output
    MOVE.B  #'L',(A3)+                  Insert L into the output
    MOVE.B  #'E',(A3)+                  Insert E into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     BCCCODE                      Get the EA stuff
    RTS                                 Return instruction
BVSINST
    MOVE.B  #'B',(A3)+                  Insert B into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'S',(A3)+                  Insert S into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     BCCCODE                     Get the EA stuff
    RTS                                 Return instruction

BCCCODE
	MOVE.W	A5, D5						Move current address into D5
	SUB.B	#2, D5						Subtract 2 so we can compensate for the increment
	MOVE.W	(A5)+,D4        			Move displacement word address into D4
	ADD.W	#2, D4						Add plus 2 to displacement
	ADD.W	D4, D5						Add the displacement to the current address
	MOVE.B	#'$',(A3)+					Insert a $ into the output
	
	MOVE.W D5, D4
    MOVEQ  #4,D0               			Move counter to D0
BCCDATA_PREP                      
    ROL.W  #4,D4               			Move the MSB
    *ROL.W  #4,D4
    MOVE.L D4,D5               			Move longword address to D5
    ANDI.L #$0000000F,D5       			Clear everything except for MSB
BCCDATA_ASC
    CMPI.B #$09,D5             			Is the character a number?
    BLE    BCCDATA_NUM            		Branch if yes.
BCCDATA_LET
    ADDI.B #$37,D5             			Convert into a prinatble ascii letter
    BRA    BCCDATA_CHAR
BCCDATA_NUM 
    ADDI.B #$30,D5             			Convert into a prinatble ascii number
    BRA    BCCDATA_CHAR
BCCDATA_CHAR
    SUBI.B #1,D0               			Decrement counter
    MOVE.B D5,(A3)+            			Move ascii into good buffer
    *ROL.W   #8, D4
    CMPI.B #0,D0               			Have we moved all characters?
    BGT    BCCDATA_PREP           		If not, repeat loop
    RTS

********************************************************
* 0111 - MOVEQ INSTRUCTION                             *        
********************************************************
INSTR0111
    MOVE.B  #'M',(A3)+                  Insert M into the output
    MOVE.B  #'O',(A3)+                  Insert O into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'E',(A3)+                  Insert E into the output
    MOVE.B  #'.',(A3)+                  Insert . into the output
    MOVE.B  #'Q',(A3)+                  Insert Q into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    MOVE.B  #'#',(A3)+
    MOVE.B  #'$',(A3)+
FINDDATA
    MOVE.W  D6, D4						Move instruction for ASCII conversion
    MOVEQ  #2,D0               			Move counter to D0
DATA_PREP                      
    ROL.W  #8,D4               			Move the MSB
    ROL.W  #4,D4
    MOVE.L D4,D5               			Move longword address to D5
    ANDI.L #$0000000F,D5       			Clear everything except for MSB
DATA_ASC	
    CMPI.B #$09,D5             			Is the character a number?
    BLE    DATA_NUM            			Branch if yes.
DATA_LET
    ADDI.B #$37,D5             			Convert into a prinatble ascii letter
    BRA    DATA_CHAR
DATA_NUM 
    ADDI.B #$30,D5             			Convert into a prinatble ascii number
    BRA    DATA_CHAR
DATA_CHAR
    SUBI.B #1,D0               			Decrement counter
    MOVE.B D5,(A3)+            			Move ascii into good buffer
    ROL.W   #8, D4						Rotate the word by 8 bits to the left
    CMPI.B #0,D0              		 	Have we moved all characters?
    BGT    DATA_PREP           			If not, repeat loop
FINDDN
    MOVE.W  D6, D5                      Move the byte data of the word into D5
    ANDI.W  #$0E00,D5					Just get the 3 bits for register number
    ROR.W   #5,D5						Rotate the word so it's in the LSB
    ROR.W   #4,D5						Rotate the word so it's in the LSB
    MULU    #6, D5                      Set the offset for the jump table
    MOVE.B  #',',(A3)+                  Move a , into the output
    MOVE.B  #'D',(A3)+                  Move D into good buffer
    LEA     REGISTER,A0                 Set the table to A0
    JSR     00(A0,D5)                   Set jumptable  
    RTS                                 Return the instruction

********************************************************
* 1000 - DIVU INSTRUCTION                              *
********************************************************
INSTR1000
    MOVE.B  #'D',(A3)+                  Insert D into the output
    MOVE.B  #'I',(A3)+                  Insert I into the output
    MOVE.B  #'V',(A3)+                  Insert V into the output
    MOVE.B  #'U',(A3)+                  Insert U into the output
    MOVE.B  #' ',(A3)+                  Insert a space into the output
    JSR     EACODE                      Call EA code
    MOVE.B  #',',(A3)+					Insert a , into the output
    MOVE.B  #'D',(A3)+					Insert a D into the output
    MOVE.W  D6, D3                      Get the number the Dn is in
    LSL.W   #4, D3                      Shift left by 4 bits
    LSR.W   #8, D3                      Shift right by 8 bits
    LSR.W   #5, D3                      Shift right by 8 bits
    MULU    #6, D3                      Set the offset for the jump table
    LEA     REGISTER,A0                 Set the table to A0
    JSR     00(A0,D3)                   Set jumptable
    RTS                                 Return the instruction
********************************************************
* 1001 - SUB, SUBA INSTRUCTION'S                       *              
********************************************************
INSTR1001
    MOVE.B  #'S', (A3)+                 Else it is a AND function, move A into output
    MOVE.B  #'U', (A3)+                 Move N into output
    MOVE.B  #'B', (A3)+                 Move D into output
    BRA     SKIPSUBA					Check to see if it's a SUBA instruction
ISASUBAINST
    MOVE.B  #'A',(A3)+					Insert a A into the output
    BRA     CONTSUB						Continue with the program
SKIPSUBA
    MOVE.W  D6, D5                      Move instruction for shifting prep to check for SUBA
    LSL.W   #8, D5                      Shift 8 bits to the left, %11 is in MSB
    LSR.W   #8, D5                      Shift 8 bits to the right
    LSR.W   #6, D5                      Shift 6 bits to the right. If there is a %11 it's in LSB now
    CMP.B   #$03, D5                    Check if %11 is in the LSB
    BEQ     ISASUBAINST                 It is a %11 go to ISASUBAINST
CONTSUB
    MOVE.B  #'.',(A3)+                  Move . into the output
    JSR     GETSIZE                     Get the size of ADD
    CMP.B   #%00, D3                    Is it Byte data?
    BEQ     BYTEDATASUB                 If so go to BYTEDATAADD
    CMP.B   #$01, D3                    Is it Word data?
    BEQ     WORDDATASUB                 If so go to WORDDATAADD
    CMP.B   #$02, D3                    Is it Long data?
    BEQ     LONGDATASUB                 If so go to LONGDATAADD
    CMP.B   #$03, D3                    Is it a WORD size for SUBA?
    JSR		GETOPMODESIZE				Get the 3 bits of size we need for SUBA
    CMP.B	#$03, D3					Is it a a WORD size data?
    BEQ     WORDDATASUBA                If so call the WORD size function
    CMP.B   #$07, D3                    Is it a LONG size for SUBA?
    BEQ     LONGDATASUBA                If so call the WORD size function
	MOVE.B  $11, D7                     It's not a byte, word or long, so it's bad data
    RTS                                 Return bad data
BYTEDATASUB
    MOVE.B  #'B',(A3)+                  Move B into output
    BRA     FINISHSUB                   Finish the SUB instruction
WORDDATASUBA
	MOVE.B	#'W',(A3)+					Move W into the output
	BRA		STOREANREGISTER				Finish the SUB with an An Register
	RTS
LONGDATASUBA
	MOVE.B	#'L',(A3)+					Move L into the output
    MOVEQ   #1,D1                       Flag that we may need a longword of immediate data
	BRA		STOREANREGISTER				Finish the SUB with an An Register
	RTS
WORDDATASUB
    MOVE.B  #'W',(A3)+                  Move W into output
    BRA     FINISHSUB                   Finish the ADD instruction
LONGDATASUB
    MOVE.B  #'L',(A3)+                  Move L into output
    BRA     FINISHSUB                   Finish the ADD instruction

FINISHSUB
    MOVE.B  #' ',(A3)+                  Move a space into the output
    MOVE.W  D6, D5                      Prepare instruction for shifting
    LSL.W   #7, D5                      This gets the direction to MSB
    LSR.W   #8, D5                      Bring the direction to LSB
    LSR.W   #7, D5                      Bring the direction to LSB
    CMP.B   #00, D5                     Is the destination a Dn?
    BEQ     DNISDEST                    Yes it is, go to DNISDEST
    CMP.B   #$01,D5                     Is the destination not a Dn?
    BEQ     EAISDEST                    corrent, go to EAISDEST    
    MOVE.B  $11, D7                     else there is bad data, return
    RTS                                 Return bad data
********************************************************
* 1010 - ILLEGAL INSTRUCTION'S                         *              
********************************************************
INSTR1010
    MOVE.B  $11, D7                     Bad data   
    RTS                                 Return Bad Data flag
********************************************************
* 1011 - CMP, CMPA, EOR INSTRUCTION'S                  *                   
********************************************************
INSTR1011
    MOVE.W  D6, D5						Move instruction for bit shifting
    LSL.W   #7, D5						Shift 7 bits to the left
    LSR.W   #8, D5						Shift 8 bits to the right
    LSR.W   #5, D5						Shift 5 bits to the right, making the MSB, LSB
    MULU    #8, D5						Multiply by 8 to set offset
    LEA     BINSTTABLE,A0				Set up BINSTTable
    JSR     0(A0, D5)					Call jump table
    RTS									Return instruction

********************************************************
* 1011 - CMP, CMPA, EOR INSTRUCTION TABLES             *                   
********************************************************
BINSTTABLE
    JSR     BTABLE000                   CMP.B Instruction
    RTS
    JSR     BTABLE001                   CMP.W Instruction
    RTS
    JSR     BTABLE010                   CMP.L Instruction
    RTS
    JSR     BTABLE011                   CMPA.W Instruction
    RTS
    JSR     BTABLE100                   EOR.B Instruction
    RTS     
    JSR     BTABLE101                   EOR.W Instruction
    RTS
    JSR     BTABLE110                   EOR.L Instruction
    RTS
    JSR     BTABLE111                   CMPA.L Instruction
    RTS

GETREGISTERVALUE
    MULU    #6, D3						Set offset by 6
    LEA     REGISTER,A0                 Set the table to A0
    JSR     00(A0,D3)                   Set jumptable
    RTS									Return instruction

FINISHINST
    MOVE.B  #' ',(A3)+
    JSR     EACODE                      Get EA Code first
    JSR     REGISTERBITS                Find out which Dn register this is
    MOVE.B  #',',(A3)+                  Insert a , into output
    MOVE.B  #'D',(A3)+                  Insert D for Data Register
    JSR     GETREGISTERVALUE            Find the register number and insert into output
    RTS									Return Instruction

********************************************************
* CMP.B Instruction                                    *                   
********************************************************
BTABLE000
    MOVE.B  #'C',(A3)+               	Insert C into output
    MOVE.B  #'M',(A3)+             	    Insert M into output
    MOVE.B  #'P',(A3)+         	        Insert P into output
    MOVE.B  #'.',(A3)+     	            Insert . into output
    MOVE.B  #'B',(A3)+                  Insert B into output
    JSR     FINISHINST                  Finish the output of the instruction
    RTS                                 Return instruction
********************************************************
* CMP.W Instruction                                    *                   
********************************************************
BTABLE001
    MOVE.B  #'C',(A3)+                  Insert C into output
    MOVE.B  #'M',(A3)+                  Insert M into output
    MOVE.B  #'P',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'W',(A3)+                  Insert B into output
    JSR     FINISHINST                  Finish the output of the instruction
    RTS                                 Return instruction
********************************************************
* CMP.L Instruction                                    *                   
********************************************************
BTABLE010
    MOVE.B  #'C',(A3)+                  Insert C into output
    MOVE.B  #'M',(A3)+                  Insert M into output
    MOVE.B  #'P',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'L',(A3)+                  Insert B into output
    MOVEQ   #1,D1                       Flag that we may need a longword of immediate data
    JSR     FINISHINST                  Finish the output of the instruction
    RTS                                 Return instruction
********************************************************
* CMPA.W Instruction                                    *                   
********************************************************
BTABLE011
    MOVE.B  #'C',(A3)+                  Insert C into output
    MOVE.B  #'M',(A3)+                  Insert M into output
    MOVE.B  #'P',(A3)+                  Insert P into output
    MOVE.B  #'A',(A3)+                  Insert A into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'W',(A3)+                  Insert B into output
    MOVE.B  #' ',(A3)+
    JSR     EACODE                      Get EA Code first
    JSR     REGISTERBITS                Find out which Dn register this is
    MOVE.B  #',',(A3)+                  Insert a , into output
    MOVE.B  #'A',(A3)+                  Insert A for Data Register
    JSR     GETREGISTERVALUE            Find the register number and insert into output
    RTS
********************************************************
* EOR.B Instruction                                    *                   
********************************************************
BTABLE100
    MOVE.B  #'E',(A3)+                  Insert C into output
    MOVE.B  #'O',(A3)+                  Insert M into output
    MOVE.B  #'R',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'B',(A3)+                  Insert B into output
    JSR     FINISHINST                  Finish the output of the instruction
    RTS                                 Return instruction
********************************************************
* EOR.W Instruction                                    *                   
********************************************************
BTABLE101
    MOVE.B  #'E',(A3)+                  Insert C into output
    MOVE.B  #'O',(A3)+                  Insert M into output
    MOVE.B  #'R',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'W',(A3)+                  Insert B into output
    MOVE.B  #' ',(A3)+					Inser a space into output
    JSR     REGISTERBITS                Find out which Dn register this is
    MOVE.B  #'D',(A3)+                  Insert D for Data Register
    JSR     GETREGISTERVALUE            Find the register number and insert into output
    MOVE.B  #',',(A3)+                  Insert a , into output
    JSR     EACODE                      Get EA Code last
    RTS                                 Return instruction
********************************************************
* EOR.L Instruction                                    *                   
********************************************************
BTABLE110
    MOVE.B  #'E',(A3)+                  Insert C into output
    MOVE.B  #'O',(A3)+                  Insert M into output
    MOVE.B  #'R',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'L',(A3)+                  Insert B into output
    MOVE.B  #' ',(A3)+					Insert a space into output
    JSR     REGISTERBITS                Find out which Dn register this is
    MOVE.B  #'D',(A3)+                  Insert D for Data Register
    JSR     GETREGISTERVALUE            Find the register number and insert into output
    MOVE.B  #',',(A3)+                  Insert a , into output
    JSR     EACODE                      Get EA Code last
    RTS                                 Return instruction
********************************************************
* CMPA.L Instruction                                   *                   
********************************************************
BTABLE111
    MOVE.B  #'C',(A3)+                  Insert C into output
    MOVE.B  #'M',(A3)+                  Insert M into output
    MOVE.B  #'P',(A3)+                  Insert P into output
    MOVE.B  #'A',(A3)+                  Insert P into output
    MOVE.B  #'.',(A3)+                  Insert . into output
    MOVE.B  #'L',(A3)+                  Insert B into outpuT
    MOVE.B  #' ',(A3)+					Insert a space into output
    MOVEQ   #1,D1                       Flag that we may need a longword of immediate data
    JSR     EACODE                      Get EA Code first
    JSR     REGISTERBITS                Find out which Dn register this is
    MOVE.B  #',',(A3)+                  Insert a , into output
    MOVE.B  #'A',(A3)+                  Insert A for Data Register
    JSR     GETREGISTERVALUE            Find the register number and insert into output 
    RTS

********************************************************
* 1100 - AND, MULS INSTRUCTION'S                       *              
********************************************************
INSTR1100
    MOVE.W  D6, D5                          Move instruction for shifting prep to check for MULS
    LSL.W   #7, D5                          Shift 7 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the right
    CMP.B   #$07, D5                        Check if %111 is in the LSB
    BEQ     MULSINST                        It is a %111 go to MULUSINST
    MOVE.B  #'A', (A3)+                     Else it is a AND function, move A into output
    MOVE.B  #'N', (A3)+                     Move N into output
    MOVE.B  #'D', (A3)+                     Move D into output
    MOVE.B  #'.',(A3)+                      Move . into the output
    JSR     GETSIZE                         Get the size of ADD
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATAAND                     If so go to BYTEDATAADD
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATAAND                     If so go to WORDDATAADD
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATAAND                     If so go to LONGDATAADD
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
BYTEDATAAND
    MOVE.B  #'B',(A3)+                      Move B into output
    BRA     FINISHAND                       Finish the ADD instruction
WORDDATAAND
    MOVE.B  #'W',(A3)+                      Move W into output
    BRA     FINISHAND                       Finish the ADD instruction
LONGDATAAND
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVEQ	#1, D1
    BRA     FINISHAND                       Finish the ADD instruction

FINISHAND
    MOVE.B  #' ',(A3)+                      Move a space into the output
    MOVE.W  D6, D5                          Prepare instruction for shifting
    LSL.W   #7, D5                          This gets the direction to MSB
    LSR.W   #8, D5                          Bring the direction to LSB
    LSR.W   #7, D5                          Bring the direction to LSB
    CMP.B   #00, D5                         Is the destination a Dn?
    BEQ     DNISDEST                         Yes it is, go to DNISDEST
    CMP.B   #$01,D5                         Is the destination not a Dn?
    BEQ     EAISDEST                        corrent, go to EAISDEST    
    MOVE.B  $11, D7                         else there is bad data, return
    RTS                                     Return bad data
MULSINST
    MOVE.B  #'M',(A3)+                      Move M into output
    MOVE.B  #'U',(A3)+                      Move U into output
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVE.B  #'S',(A3)+                      Move S into output
    MOVE.B  #'.',(A3)+                      Move a . into output
    MOVE.B	#'W',(A3)+						Move a W into output
    MOVE.B	#' ',(A3)+						Move a space into output
    JSR     EACODE                          Get the EA code for MULUS intruction
    MOVE.W  D6, D5                          Prep instruction for shifting so we can figure out the register
    LSL.W   #4, D5                          Shift 4 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the right
    MULU    #6, D5                          Set the offset for the jump table
    MOVE.B  #',',(A3)+                      Move a , into the output
    MOVE.B  #'D',(A3)+                      Move D into good buffer
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D5)                       Set jumptable    
    RTS                                     Return the full instruction
********************************************************
* 1110 - ASR, LSL, ROL INSTRUCTION'S                   *                  
********************************************************
INSTR1110 
    MOVE.W  D6, D5                          Prep insruction for bit shift check
    
    LSL.W	#8, D5							Check if there are %11 bits in 6 and 7 in the format
    LSR.W	#8, D5							Check if there are %11 bits in 6 and 7 in the format
    LSR.W	#6, D5							Check if there are %11 bits in 6 and 7 in the format
    CMP.B	#03, D5							is it a memory shift instruction
    BEQ		MEMORYCHECKS					YUP
SHIFTCONT
    MOVE.W	D6, D5							Reset to check for register shifts
    LSL.W   #8, D5                          Shift 8 bits to the left
    LSL.W   #3, D5                          Shift 3 bits to the left, the instruction check is now at the MSB
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #6, D5                          Shift 6 bits to the right, now the check is at LSB
    CMP.B   #$00, D5                        Is it a ASR instruction?
    BEQ     ASRINSTR                        Yup, disassemble ASR
    CMP.B   #$01, D5                        Is it a LSL instruction?
    BEQ     LSLINSTR                        Yup, disassemble LSL
    CMP.B   #$03, D5                        Is it a ROL/ROR instruction?
    BEQ     ROLRINSTR                       Yup, disassemble ROL/ROR
    MOVE.B  $11, D7                         ELSE it's bad data
    RTS                                     So return the bad data
ASRINSTR
    MOVE.W  D6, D5                          Prepare instruction for bit shift check
    LSL.W   #7, D5                          Shift 7 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #7, D5                          Shift 7 bits to the right, now the direction is LSB
    CMP.B   #$00, D5                        If it's $00 then it's a ASR
    BEQ     ASRIGHTSHIFT                    It is, go to ASRIGHTSHIFT function
    MOVE.B  $11, D7                         Insert bad data flag
    RTS                                     Return bad data
ASRIGHTSHIFT
    MOVE.B  #'A',(A3)+						Insert A into output
    MOVE.B  #'S',(A3)+						Insert S into output
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #'.',(A3)+						Inser a . into output
    JSR     GETSIZE                         Get the size of ASR
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATASHIFT                   If so go to BYTEDATASHIFT
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATASHIFT                   If so go to WORDDATASHIFT
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATASHIFT                   If so go to LONGDATASHIFT
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
	JSR     EACODE  
    RTS                                     Return bad data
LSLINSTR
    MOVE.W  D6, D5                          Prepare instruction for bit shift check
    LSL.W   #7, D5                          Shift 7 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #7, D5                          Shift 7 bits to the right, now the direction is LSB
    CMP.B   #$01, D5                        If it's $01 then it's a LSL
    BEQ     LSLEFTSHIFT                       It is, go to LEFTSHIFT function
    MOVE.B  $11, D7                         Insert bad data flag
    JSR     EACODE  
    RTS                                     Return bad data
LSLEFTSHIFT
    MOVE.B  #'L',(A3)+                      Insert L into the output
    MOVE.B  #'S',(A3)+                      Insert S into the output
    MOVE.B  #'L',(A3)+                      Insert L into the output
    MOVE.B  #'.',(A3)+                      Insert a . into the output
    JSR     GETSIZE                         Get the size of LSL
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATASHIFT                   If so go to BYTEDATASHIFT
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATASHIFT                   If so go to WORDDATASHIFT
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATASHIFT                   If so go to LONGDATASHIFT
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    JSR     EACODE  
    RTS                                     Return bad data
BYTEDATASHIFT
    MOVE.B  #'B',(A3)+                      Move B into output
    BRA     GETDATANUMBER                   Check the IR for where to put EA in output
WORDDATASHIFT
    MOVE.B  #'W',(A3)+                      Move W into output
    BRA     GETDATANUMBER                   Check the IR for where to put EA in output
LONGDATASHIFT
    MOVE.B  #'L',(A3)+                      Move L into output
    BRA     GETDATANUMBER                   Check the IR for where to put EA in output

ROLRINSTR
    MOVE.W  D6, D5                          Prepare instruction for bit shift check
    LSL.W   #7, D5                          Shift 7 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #7, D5                          Shift 7 bits to the right, now the direction is LSB
    CMP.B   #$01, D5                        If it's $01 then it's a ROL
    BEQ     ROLEFTSHIFT                     It is, go to ROLEFTSHIFT function
    CMP.B   #$00, D5                        If it's $00 then it's a ROR
    BEQ     RORIGHTSHIFT                    It is, go to the RORIGHSHIFT
    MOVE.B  $11, D7                         Insert bad data flag
    JSR     EACODE  
    RTS                                     Return bad data
ROLEFTSHIFT
    MOVE.B  #'R',(A3)+                      Insert R into output
    MOVE.B  #'O',(A3)+                      Insert O into output
    MOVE.B  #'L',(A3)+                      Insert L into output
    MOVE.B  #'.',(A3)+                      Insert a . into output
    JSR     GETSIZE                         Get the size of LSL
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATASHIFT                   If so go to BYTEDATASHIFT
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATASHIFT                   If so go to WORDDATASHIFT
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATASHIFT                   If so go to LONGDATASHIFT
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    JSR     EACODE  
    RTS                                     Return bad data
RORIGHTSHIFT
    MOVE.B  #'R',(A3)+                      Insert R into output
    MOVE.B  #'O',(A3)+                      Insert O into output
    MOVE.B  #'R',(A3)+                      Insert L into output
    MOVE.B  #'.',(A3)+                      Insert a . into output
    JSR     GETSIZE                         Get the size of LSL
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATASHIFT                   If so go to BYTEDATASHIFT
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATASHIFT                   If so go to WORDDATASHIFT
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATASHIFT                   If so go to LONGDATASHIFT
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    JSR     EACODE  
    RTS                                     Return bad data
GETDATANUMBER
    MOVE.W  D6, D3                          Get the number the Dn is in
    LSL.W   #4, D3                          Shift left by 4 bits
    LSR.W   #8, D3                          Shift right by 8 bits
    LSR.W   #5, D3                          Shift right by 8 bits

CHECKIRSHIFT
    MOVE.B  #' ',(A3)+                      Add a space into the output for EA stuff
    MOVE.W  D6, D5                          Prep instruction for bit shift check
    LSL.W   #8,D5                           Shift 8 bits to the left
    LSL.W   #2,D5                           Shift 2 bits to the left, ir is now MSB
    LSR.W   #8,D5                           Shift 8 bits to the right
    LSR.W   #7,D5                           Shift 7 bits to the right, ir is now LSB
    CMP.B   #$01, D5                        Is ir = 1?
    BEQ     IRISONE                         Yup, go to IR = 1 function
    CMP.B   #$00, D5                        Is ir = 0?
    BEQ     IRISZERO                        Yup, go to IR = 0 function
    MOVE.B  $11, D7                        It' not a 1 or 0, therefore bad data
    RTS                                     Return bad data


IRISONE
    MULU    #6, D3                          Set the offset for the jump table
    MOVE.B  #'D',(A3)+                      Insert D into input
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D3)                       Set jumptable
    MOVE.B  #',',(A3)+                      Move a comma into the output
    JSR     SHIFTREGISTERBITS               Get last 3 bits of instruction
    MOVE.B  #'D',(A3)+                      Insert D into output
    MULU    #6, D3                          Set offset of last 3 bits
    LEA     REGISTER, A0                    Load jump table
    JSR     00(A0,D3)                       Search Jumpt table for Dn
    RTS                                     Return the instruction
IRISZERO
    MULU    #6, D3                          Set the offset for the jump table
    MOVE.B  #'#',(A3)+                      Insert # into output
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D3)                       Go to jumptable
    MOVE.B  #',',(A3)+                      Insert a comma into output
    JSR     SHIFTREGISTERBITS               Get last 3 bits of instruction
    MOVE.B  #'D',(A3)+                      Insert D into output
    MULU    #6, D3                          Set offset of 3 bits by 6
    LEA     REGISTER, A0                    Load jumpt table
    JSR     00(A0,D3)                       Search jump table
    RTS                                     Return the instruction

MEMORYCHECKS
    MOVE.W  D6, D5                          Prep instruction for bit shift
    LSR.W   #6, D5                          Move 6 bits to the right to check word data
    CMP.W   #$038F, D5                      Does the word equal 038F?
    BEQ     LSLMEMORY                       Yup, it's an LSL Memory shift
    CMP.W   #$0383, D5                      Does the word equal 0383?
    BEQ     ASRMEMORY                       Yup, it's an ASR Memory shift
    CMP.W   #$039F, D5                      Does the word equal 039F?
    BEQ     ROLMEMORY                       Yup, it's an ROL Memory shift
    CMP.W   #$039B, D5                      Does the word equal 039B?
    BEQ     RORMEMORY                       Yup, it's an ROR Memory shift
    BRA		SHIFTCONT                       It's still nothing, so return, to check for register

LSLMEMORY
    MOVE.B  #'L',(A3)+						Insert L into output
    MOVE.B  #'S',(A3)+						Insert S into output
    MOVE.B  #'L',(A3)+						Insert L into output
    MOVE.B  #' ',(A3)+						Insert a space into output
    BRA     FINISHMEMORYSHIFTEA             Finish memory shifting                      
ASRMEMORY
    MOVE.B  #'A',(A3)+						Insert A into output
    MOVE.B  #'S',(A3)+						Insert S into output
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #' ',(A3)+						Insert a space into output
    BRA     FINISHMEMORYSHIFTEA             Finish memory shifting
ROLMEMORY
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #'O',(A3)+						Insert O into output
    MOVE.B  #'L',(A3)+						Insert L into output
    MOVE.B  #' ',(A3)+						Insert a space into output
    BRA     FINISHMEMORYSHIFTEA				Finish memory shifting
RORMEMORY
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #'O',(A3)+						Insert O into output
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #' ',(A3)+						Insert a space into output
    BRA     FINISHMEMORYSHIFTEA        		Finish memory shifting

FINISHMEMORYSHIFTEA
    JSR     EACODE                          Else call EA code
    RTS   									Return instruction
SENDBADDATA									
    MOVE.B  $11, D7							Set bad data flag
    RTS										Return bad data
********************************************************
* 1101 - ADD, ADDA INSTRUCTION'S                       *               
********************************************************
INSTR1101
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'D',(A3)+                      Move D into the output
    MOVE.B  #'D',(A3)+                      Move D into the output
    BRA     CHECKIFADDA						Check if this is an ADDA instruction
NOTADDA
    MOVE.B  #'.',(A3)+                      Move . into the output
    JSR     GETSIZE                         Get the size of ADD
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATAADD                     If so go to BYTEDATAADD
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATAADD                     If so go to WORDDATAADD
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATAADD                     If so go to LONGDATAADD
    MOVE.B  $11, D7                        	It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
BYTEDATAADD
    MOVE.B  #'B',(A3)+                      Move B into output
    BRA     FINISHADD                       Finish the ADD instruction
WORDDATAADD
    MOVE.B  #'W',(A3)+                      Move W into output
    BRA     FINISHADD                       Finish the ADD instruction
LONGDATAADD
    MOVE.B  #'L',(A3)+                      Move L into output
    BRA     FINISHADD                       Finish the ADD instruction
CHECKIFADDA
    MOVE.W  D6,D5                           Prep instruction for shifting so we can check if ADDA
    LSL.W   #7, D5                          Shift 7 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the left
    CMP.B   #$03, D5                        Does it equal %011?
    BEQ     WORDADDRESS                     yes, It's a word address
    CMP.B   #$07, D5                        Does it equal %111?
    BEQ     LONGWORDADDRESS                 yes, It's a long address
    BRA     NOTADDA                         It's not a ADDA return and do ADD
WORDADDRESS
     MOVE.B #'A',(A3)+                      Move A to the output
     MOVE.B #'.',(A3)+                      Move . to the output
     MOVE.B #'W',(A3)+                      Move W to the output
     BRA    STOREANREGISTER                 Continue with ADDA function
LONGWORDADDRESS
     MOVE.B #'A',(A3)+                      Move A to the output
     MOVE.B #'.',(A3)+                      Move . to the output
     MOVE.B #'L',(A3)+                      Move L to the output
     MOVEQ   #1,D1                          Flag that we may need a longword of immediate data
     BRA    STOREANREGISTER                 Continue with ADDA function
STOREANREGISTER
    MOVE.B  #' ',(A3)+                      Move a space into the output
	JSR     EACODE                          Get the EA for this instruction
	MOVE.B  #',',(A3)+                      Move a , into the output    
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.W  D6, D5                          Prep instruction for shifting so we can figure out the register
    LSL.W   #4, D5                          Shift 4 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the right
    MULU    #6, D5                          Set the offset for the jump table
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D5)                       Set jumptable
    RTS                                     Return full instruction

FINISHADD
    MOVE.B  #' ',(A3)+                      Move a space into the output
    MOVE.W  D6, D5                          Prepare instruction for shifting
    LSL.W   #7, D5                          This gets the direction to MSB
    LSR.W   #8, D5                          Bring the direction to LSB
    LSR.W   #7, D5                          Bring the direction to LSB
    CMP.B   #00, D5                         Is the destination a Dn?
    BEQ     DNISDEST                         Yes it is, go to DNISDEST
    CMP.B   #$01,D5                         Is the destination not a Dn?
    BEQ     EAISDEST                        corrent, go to EAISDEST    
    MOVE.B  $11, D7                         else there is bad data, return
    RTS                                     Return bad data
DNISDEST
    JSR     EACODE							Call EA code
    MOVE.W  D6, D5                          Prep instruction for shifting so we can figure out the register
    LSL.W   #4, D5                          Shift 4 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the right
    MULU    #6, D5                          Set the offset for the jump table
    MOVE.B  #',',(A3)+                      Move a , into the output
    MOVE.B  #'D',(A3)+                      Move D into good buffer
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D5)                       Set jumptable    
    RTS                                     Return the full instruction
EAISDEST    
    MOVE.W  D6, D5                          Prep instruction for shifting so we can figure out the register
    LSL.W   #4, D5                          Shift 4 bits to the left
    LSR.W   #8, D5                          Shift 8 bits to the right
    LSR.W   #5, D5                          Shift 5 bits to the right
    MULU    #6, D5                          Set the offset for the jump table
    MOVE.B  #'D',(A3)+                      Move D into good buffer
    LEA     REGISTER,A0                     Set the table to A0
    JSR     00(A0,D5)                       Set jumptable
    MOVE.B  #',',(A3)+                      Move , into output
    JSR     EACODE                          Get the EA for this instruction
    RTS                                     Return full instruction

********************************************************
* 1111 - ILLEGAL INSTRUCTION'S                         *                  
********************************************************
INSTR1111
	MOVE.B	$11, D7   
    RTS

********************************************************
* 0000 Jump Table ADDI, ANDI, BCHG, CMPI, EORI         *               
********************************************************
ZERINST     
    JSR     ZER0000                         ILLEGAL INSTRUCTION
    RTS
    JSR     ZER0001                         BCHG D0 Instruction
    RTS
    JSR     ZER0010                         Instruction for ANDI
    RTS
    JSR     ZER0011                         BCHG D1 Instruction
    RTS
    JSR     ZER0100                         ILLEGAL INSTRUCTION
    RTS
    JSR     ZER0101                         BCHG D2 Instruction
    RTS
    JSR     ZER0110                         Instruction for ADDI
    RTS
    JSR     ZER0111                         BCHG D3 Instruction
    RTS
    JSR     ZER1000                         Instruction for BCHG
    RTS
    JSR     ZER1001                         BCHG D4 Instruction
    RTS
    JSR     ZER1010                         Instruction for EORI
    RTS
    JSR     ZER1011                         BCHG D5 Instruction
    RTS
    JSR     ZER1100                         Instruction for CMPI
    RTS
    JSR     ZER1101                         BCHG D6 Instruction
    RTS
    JSR     ZER1110                         ILLEGAL INSTRUCTION
    RTS
    JSR     ZER1111                         BCHG D7 Instruction
    RTS

********************************************************
* 0000 0010 - ANDI                                     *               
********************************************************
ZER0010
    MOVE.B  #'A',(A3)+                      Insert A into the output
    MOVE.B  #'N',(A3)+                      Insert N into the output
    MOVE.B  #'D',(A3)+                      Insert D into the output
    MOVE.B  #'I',(A3)+                      Insert I into the output
    MOVE.B  #'.',(A3)+                      Insert . into the output
    JSR     GETSIZE                         Get the size of CLR
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     ANDIBYTEDATA                    YES
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     ANDIWORDDATA                    YES
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     ANDILONGDATA                    YES
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
ANDIBYTEDATA
    MOVE.B  #'B',(A3)+                      Move B into output
    MOVE.B	#' ',(A3)+						Move a space into output
    JSR		ABSOLUTE100						Call Immediate Number function
    MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHANDI  					Finish the ANDI function
ANDIWORDDATA
    MOVE.B  #'W',(A3)+                      Move W into output
    MOVE.B	#' ',(A3)+						Move a space into output
 	JSR		ABSOLUTE100						Call Immediate Number function
 	MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHANDI                      Finish the ANDI instruction
ANDILONGDATA
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVE.B	#' ',(A3)+						Move a space into output
    MOVEQ   #1,D1                           Flag that we may need a longword of immediate data
    JSR     ABSOLUTE100						Call Immediate Number function
    MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHANDI                      Finish the CLR instruction
FINISHANDI
    JSR     EACODE                          Get the EA code for ANDI
    RTS                                     Return the instruction
********************************************************
* 0000 0110 - ADDI                                     *               
********************************************************
ZER0110
    MOVE.B  #'A',(A3)+                      Insert A into the output
    MOVE.B  #'D',(A3)+                      Insert D into the output
    MOVE.B  #'D',(A3)+                      Insert D into the output
    MOVE.B  #'I',(A3)+                      Insert I into the output
    MOVE.B  #'.',(A3)+                      Insert . into the output
    JSR     GETSIZE                         Get the size of CLR
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     ADDIBYTEDATA                    YES
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     ADDIWORDDATA                    YES
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     ADDILONGDATA                    YES
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
ADDIBYTEDATA
    MOVE.B  #'B',(A3)+                      Move B into output
    MOVE.B	#' ',(A3)+						Move a space into output
    JSR		ABSOLUTE100						Call Immediate data function
    MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHADDI                      Finish the ADDI instruction
ADDIWORDDATA
    MOVE.B  #'W',(A3)+                      Move W into output
    MOVE.B	#' ',(A3)+						Move a space into output
 	JSR		ABSOLUTE100						Call Immediate data function
 	MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHADDI                      Finish the CLR instruction
ADDILONGDATA
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVE.B	#' ',(A3)+						Move a space into output
    MOVEQ   #1,D1                           Flag that we may need a longword of immediate data
    JSR     ABSOLUTE100						Call Immediate data function
    MOVE.B	#',',(A3)+						Move a , into output
    BRA     FINISHADDI                      Finish the CLR instruction
FINISHADDI
    JSR     EACODE                          Get the EA code for ADDI
    RTS                                     Return the instruction

********************************************************
* 0000 1010 - EORI                                     *               
********************************************************
ZER1010
    MOVE.B  #'E',(A3)+                      Insert E into the output
    MOVE.B  #'O',(A3)+                      Insert O into the output
    MOVE.B  #'R',(A3)+                      Insert R into the output
    MOVE.B  #'I',(A3)+                      Insert I into the output
    MOVE.B  #'.',(A3)+                      Insert . into the output
    JSR     GETSIZE                         Get the size of CLR
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     EORIBYTEDATA                    YES
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     EORIWORDDATA                    YES
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     EORILONGDATA                    YES
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
EORIBYTEDATA
    MOVE.B  #'B',(A3)+                      Insert B into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHEORI                      Finish the EORI instruction
EORIWORDDATA
    MOVE.B  #'W',(A3)+                      Insert W into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHEORI                      Finish the EORI instruction
EORILONGDATA
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    MOVEQ   #1,D1                           Flag that we may need a longword of immediate data
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHEORI                      Finish the EORI instruction
FINISHEORI
    JSR     EACODE                          Get the EA code for EORI
    RTS                                     Return the instruction
********************************************************
* 0000 1100 - CMPI                                     *               
********************************************************
ZER1100
	MOVE.B  #'C',(A3)+                      Insert E into the output
    MOVE.B  #'M',(A3)+                      Insert O into the output
    MOVE.B  #'P',(A3)+                      Insert R into the output
    MOVE.B  #'I',(A3)+                      Insert I into the output
    MOVE.B  #'.',(A3)+                      Insert . into the output
    JSR     GETSIZE                         Get the size of CMPI
    JSR     GETSIZE                         Get the size of CMPI
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     CMPIBYTEDATA                    YES
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     CMPIWORDDATA                    YES
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     CMPILONGDATA                    YES
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
CMPIBYTEDATA
    MOVE.B  #'B',(A3)+                      Insert B into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHCMPI                      Finish the CMPI instruction
CMPIWORDDATA
    MOVE.B  #'W',(A3)+                      Insert W into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHCMPI                      Finish the CMPI instruction
CMPILONGDATA
    MOVE.B  #'L',(A3)+                      Insert L into output
    MOVE.B	#' ',(A3)+						Insert a space into output
    MOVEQ   #1,D1                           Flag that we may need a longword of immediate data
    JSR		ABSOLUTE100						Call the specific EA code for immediate instruction
    MOVE.B	#',',(A3)+						Insert a , into output
    BRA     FINISHCMPI                     	Finish the CMPI instruction
FINISHCMPI
    JSR     EACODE                          Get the EA code for CMPI
    RTS                                     Return the instruction

********************************************************
* 0000 1000 - BCHG                                     *               
********************************************************
ZER1000
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
    JSR		ABSOLUTE100					Call Immediate data function
    MOVE.B	#',',(A3)+					insert a , into output
	JSR		EACODE						Call EA code
	RTS									Return instruction

********************************************************
* 0000 0001 - BCHG D0                                  *               
********************************************************
ZER0001
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'0',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 0011 - BCHG D1                                  *               
********************************************************
ZER0011
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'1',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 0101 - BCHG D2                                  *               
********************************************************
ZER0101
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'2',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 0111 - BCHG D3                                  *               
********************************************************
ZER0111
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'3',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 1001 - BCHG D4                                  *               
********************************************************
ZER1001
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'4',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 1011 - BCHG D5                                  *               
********************************************************
ZER1011
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'5',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 1101 - BCHG D6                                  *               
********************************************************
ZER1101
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'6',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* 0000 1111 - BCHG D7                                  *               
********************************************************
ZER1111
	MOVE.B	#'B',(A3)+					Insert B into the output
	MOVE.B	#'C',(A3)+					Insert C into the output
	MOVE.B	#'H',(A3)+					Insert H into the output
	MOVE.B	#'G',(A3)+					Insert G into the output
	MOVE.B	#' ',(A3)+					Insert a space into the output
	MOVE.B	#'D',(A3)+					Insert D into the output
	MOVE.B	#'7',(A3)+					Insert the Dn into the output
	MOVE.B	#',',(A3)+					Insert a , into the output
	JSR		EACODE						Get the EA
	RTS									Return the instruction
********************************************************
* ILLEGAL INSTRUCTION                                  *               
********************************************************
ZER0100
ZER0000
ZER1110
    MOVE.B  $11, D7                     BAD DATA
    RTS                                 Return bad data


*********************************************************
* 0100 Jump Table CLR, JSR, LEA, MOVEM, RTS INSTRUCTIONS*               
*********************************************************
FOURTABLE     
    JSR     FOUR0000                    Illegal Instruction
    RTS                                 Return Bad Instruction
    JSR     FOUR0001                    LEA instruction with An = 0
    RTS                                 Return full instruction
    JSR     FOUR0010                    CLR instruction
    RTS                                 Return full instruction
    JSR     FOUR0011                    LEA instruction with An = 1
    RTS                                 Return full instruction
    JSR     FOUR0100                    Illegal Instruction
    RTS                                 Return Bad Instruction
    JSR     FOUR0101                    LEA instruction with An = 2
    RTS                                 Return full instruction
    JSR     FOUR0110                    Illegal Instruction
    RTS                                 Return Bad Instruction
    JSR     FOUR0111                    LEA instruction with An = 3
    RTS                                 Return full instruction
    JSR     FOUR1000                    MOVEM instruction for Register to Memory
    RTS                                 Return full instruction
    JSR     FOUR1001                    LEA instruction with An = 3
    RTS                                 Return full instruction
    JSR     FOUR1010                    Illegal Instruction
    RTS                                 Return Bad Instruction
    JSR     FOUR1011                    LEA instruction with An = 4
    RTS                                 Return full instruction
    JSR     FOUR1100                    MOVEM instruction for Memory to Register
    RTS                                 Return full instruction
    JSR     FOUR1101                    LEA instruction with An = 5
    RTS                                 Return full instruction
    JSR     FOUR1110                    JSR and RTS instructions
    RTS                                 Return full instruction
    JSR     FOUR1111                    LEA instruction with An = 6
    RTS

********************************************************
* Illegal Instruction                                  *     
********************************************************
FOUR0000
    MOVE.B  $11, D7							Create bad data flag
    RTS                                     Return the instruction
********************************************************
* 0100 0001 - LEA instruction with An = 0              *     
********************************************************
FOUR0001
    JSR     LEAMAIN
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'0',(A3)+                      Move 0 into the output
    RTS                                     Return the instruction
********************************************************
* 0100 0010 - CLR                                      *     
********************************************************
FOUR0010
    MOVE.B  #'C',(A3)+                      Move C into output
    MOVE.B  #'L',(A3)+                      Move L into output
    MOVE.B  #'R',(A3)+                      MOVE R into output
    MOVE.B  #'.',(A3)+                      MOVE . into output
    JSR     GETSIZE                         Get the size of CLR
    CMP.B   #%00, D3                        Is it Byte data?
    BEQ     BYTEDATA                        If so go to BYTEDATA
    CMP.B   #$01, D3                        Is it Word data?
    BEQ     WORDDATA                        If so go to WORDDATA
    CMP.B   #$02, D3                        Is it Long data?
    BEQ     LONGDATA                        If so go to LONGDATA
    MOVE.B  $11, D7                         It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
BYTEDATA
    MOVE.B  #'B',(A3)+                      Move B into output
    BRA     FINISHCLR                       Finish the CLR instruction
WORDDATA
    MOVE.B  #'W',(A3)+                      Move W into output
    BRA     FINISHCLR                       Finish the CLR instruction
LONGDATA
    MOVE.B  #'L',(A3)+                      Move L into output
    BRA     FINISHCLR                       Finish the CLR instruction
FINISHCLR    
    MOVE.B  #' ',(A3)+                      Move a space into the output
    JSR     EACODE                          Call EA code
    RTS                                     Return the instruction

********************************************************
* 0100 0011 - LEA instruction with An = 1              *     
********************************************************
FOUR0011
    JSR     LEAMAIN							Jump to main output printing routine
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'1',(A3)+                      Move 1 into the output
    RTS                                     Return the instruction
********************************************************
* Illegal Instruction                                  *     
********************************************************
FOUR0100
    MOVE.B  $11, D7							Set bad data flag
    RTS                                     Return the instruction
********************************************************
* 0100 0101 - LEA instruction with An = 2              *     
********************************************************
FOUR0101
    JSR     LEAMAIN
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'2',(A3)+                      Move 2 into the output
    RTS                                     Return the instruction
********************************************************
* Illegal Instruction                                  *     
********************************************************
FOUR0110
	MOVE.B	$11, D7
    RTS                                     Return the instruction
********************************************************
* 0100 1001 - LEA instruction with An = 3              *     
********************************************************
FOUR0111
    JSR     LEAMAIN							Jump to main output printing routine
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'3',(A3)+                      Move 3 into the output
    RTS                                     Return the instruction
********************************************************
* 0100 1000 - MOVEM: Register to Memory                *     
********************************************************
FOUR1000
    MOVE.B  #'M',(A3)+                      Move M to the output
    MOVE.B  #'O',(A3)+                      Move O to the output
    MOVE.B  #'V',(A3)+                      Move V to the output
    MOVE.B  #'E',(A3)+                      Move E to the output
    MOVE.B  #'M',(A3)+                      Move M to the output
    MOVE.B  #'.',(A3)+                      Move . to the output
    JSR     GETSIZEONEBIT                   Check size of the instruction
    CMP.B   #%0, D3                         Is it Word data?
    BEQ     WORDDATAR2M                     If so go to MWORDDATA
    CMP.B   #$1, D3                         Is it Long data?
    BEQ     LONGDATAR2M                     If so go to LONGDATA
    MOVE.B  #$11, D7                        It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
FINDLIST2M
    MOVE.B  #' ',(A3)+                      Move a space into the output
    MOVE.W  (A5)+,D5                        Load next word in memory
    MOVE.W  D5,D4 
    CLR.B   D1                              Clear D1 register (reset counter)
    CLR.L   D3                              Clear D3 register
    MOVE.B  D6,D3                           Used to find EA
    ANDI.B  #$38,D3                         Isolate EA mode
    CMPI.B  #$20,D3
    BEQ     FINDDATAREG_PREDEC              It is a predecremnt do the algorithm with differently
FINDDATAREG
    LSR.B   #1,D5                           Shift to the right
    BCS     FOUNDFIRSTDATA                  Is there at least 1 data register?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     FINDADDRESSREG                  If so, time to compare address register
    BRA     FINDDATAREG  
FOUNDFIRSTDATA
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                          Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
LISTDATALOOP1
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     PRINTLISTDATA1                  If so, print  
    LSR.B   #1,D5                           Shift to the right
    BCS     FOUNDSECONDDATA                 Are there more data registers?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all in the data register list?
    BEQ     PRINTLISTDATA1                  If so, print
    BRA     LISTDATALOOP1                   If not, repeat loop
PRINTLISTDATA1
    MOVE.B  #'/',(A3)+                      Add / to goodbuffer
    BRA     FINDADDRESSREG                  Time to compare address register
FOUNDSECONDDATA  
    MOVE.B  #'-',(A3)+
LISTDATALOOP2
    LSR.B   #1,D5                           Shift to the right
    BCC     PRINTLISTDATA2
    CMPI.B  #7,D1                           Have we compared all in the data register list?
    BEQ     PRINTLISTDATA2                  If so, time to compare address register
    ADDI.B  #1,D1                           Increment counter
    BRA     LISTDATALOOP2    
PRINTLISTDATA2
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    MOVE.B  #'/',(A3)+                      Add D to goodbuffer
    MOVEQ   #8,D1
    BRA     FINDADDRESSREG        
FINDADDRESSREG
    LSL.W   #1,D5                           Shift to the left
    BCS     FOUNDFIRSTADDRESS               Is there at least 1 address register?
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                  If so, branch to finish
    BRA     FINDADDRESSREG  
FOUNDFIRSTADDRESS
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
ADDRESSLOOP1
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                  If so, branch to finish 
    LSL.W   #1,D5                           Shift to the right
    BCS     FOUNDSECONDADDRESS              Are there more address registers?
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                  If so, branch to finish 
    BRA     ADDRESSLOOP1                    If not, repeat loop   
FOUNDSECONDADDRESS 
    MOVE.B  #'-',(A3)+
LISTADDRESSLOOP2
    LSL.W   #1,D5                           Shift to the left
    BCC     PRINTLISTADDRESS2
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     PRINTLISTADDRESS2
    BRA     LISTADDRESSLOOP2    
PRINTLISTADDRESS2
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                          Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    BRA     FINISHMOVEMR2M  
    ************************
FINDDATAREG_PREDEC 
    LSL.W   #1,D5                           Shift to the right
    BCS     FOUNDFIRSTDATA_PREDEC           Is there at least 1 data register?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     FINDADDRESSREG_PREDEC           If so, time to compare address register
    BRA     FINDDATAREG_PREDEC   
FOUNDFIRSTDATA_PREDEC
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
LISTDATALOOP1_PREDEC
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     PRINTLISTDATA1_PREDEC           If so, print  
    LSL.W   #1,D5                           Shift to the right
    BCS     FOUNDSECONDDATA_PREDEC          Are there more data registers?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all in the data register list?
    BEQ     PRINTLISTDATA1_PREDEC           If so, print
    BRA     LISTDATALOOP1_PREDEC            If not, repeat loop
PRINTLISTDATA1_PREDEC
    MOVE.B  #'/',(A3)+                      Add / to goodbuffer
    BRA     FINDADDRESSREG_PREDEC           Time to compare address register
FOUNDSECONDDATA_PREDEC  
    MOVE.B  #'-',(A3)+
LISTDATALOOP2_PREDEC
    LSL.W   #1,D5                           Shift to the right
    BCC     PRINTLISTDATA2_PREDEC
    CMPI.B  #7,D1                           Have we compared all in the data register list?
    BEQ     PRINTLISTDATA2_PREDEC           If so, time to compare address register
    ADDI.B  #1,D1                           Increment counter
    BRA     LISTDATALOOP2_PREDEC    
PRINTLISTDATA2_PREDEC
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    MOVE.B  #'/',(A3)+                      Add D to goodbuffer
    MOVEQ   #8,D1
    BRA     FINDADDRESSREG_PREDEC        
FINDADDRESSREG_PREDEC
    MOVE.B  D4,D5
FINDADDRESSREG_LOOP
    LSR.B   #1,D5                           Shift to the left
    BCS     FOUNDFIRSTADDRESS_PREDEC        Is there at least 1 address register?
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                 	If so, branch to finish
    BRA     FINDADDRESSREG_LOOP  
FOUNDFIRSTADDRESS_PREDEC
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
ADDRESSLOOP1_PREDEC
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                  If so, branch to finish 
    LSR.B   #1,D5                           Shift to the right
    BCS     FOUNDSECONDADDRESS_PREDEC       Are there more address registers?
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEMR2M                  If so, branch to finish 
    BRA     ADDRESSLOOP1_PREDEC             If not, repeat loop   
FOUNDSECONDADDRESS_PREDEC 
    MOVE.B  #'-',(A3)+
LISTADDRESSLOOP2_PREDEC 
    LSR.B   #1,D5                           Shift to the left
    BCC     PRINTLISTADDRESS2_PREDEC 
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     PRINTLISTADDRESS2_PREDEC
    BRA     LISTADDRESSLOOP2_PREDEC     
PRINTLISTADDRESS2_PREDEC 
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                          Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    BRA     FINISHMOVEMR2M  
FINISHMOVEMR2M
    CLR.B   D1
    MOVE.B  #',',(A3)+                      Move a comma into the output
    JSR     EACODE                          Go to EA Code to finish instruction
    RTS                                     Return the instruction
WORDDATAR2M
    MOVE.B  #'W',(A3)+                      Move W to the output
    BRA     FINDLIST2M                  	Finish the instruction
LONGDATAR2M
    MOVE.B  #'L',(A3)+                      Move L to the output
    BRA     FINDLIST2M                  	Finish the instruction


********************************************************
* 0100 1001 - LEA instruction with An = 4              *     
********************************************************
FOUR1001
    JSR     LEAMAIN
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'4',(A3)+                      Move 4 into the output
    RTS                                     Return the instruction
********************************************************
* Illegal Instruction                                  *     
********************************************************
FOUR1010
    MOVE.B  $11, D7							Flag bad data
    RTS                                     Return the instruction
********************************************************
* 0100 1011 - LEA instruction with An = 5              *     
********************************************************
FOUR1011
    JSR     LEAMAIN							Jump to main output printing routine
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'5',(A3)+                      Move 5 into the output
    RTS                                     Return the instruction
********************************************************
* 0100 1100 - MOVEM: Memory to Register                *     
********************************************************
FOUR1100
    MOVE.B  #'M',(A3)+                      Move M to the output
    MOVE.B  #'O',(A3)+                      Move O to the output
    MOVE.B  #'V',(A3)+                      Move V to the output
    MOVE.B  #'E',(A3)+                      Move E to the output
    MOVE.B  #'M',(A3)+                      Move M to the output
    MOVE.B  #'.',(A3)+                      Move . to the output
    JSR     GETSIZEONEBIT                   Check size of the instruction
    CMP.B   #%0, D3                         Is it Word data?
    BEQ     MWORDDATAM2R                    If so go to MWORDDATA
    CMP.B   #$1, D3                         Is it Long data?
    BEQ     MLONGDATAM2R                    If so go to LONGDATA
    MOVE.B  #$11, D7                        It's not a byte, word or long, so it's bad data
    RTS                                     Return bad data
FINDLIST2R
    MOVE.B  #' ',(A3)+                      Move a space into the output
    MOVEQ   #1,D7
    CLR.B   D3
    JSR     EACODE                          Go to EA Code to finish instruction
    MOVE.B  #',',(A3)+                      Move a space into the output
    MOVE.W  (A5)+,D5                        Load next word in memory 
    CLR.B   D1                              Clear D1 register (reset counter)
FINDDATAREG_
    LSR.B   #1,D5                           Shift to the right
    BCS     FOUNDFIRSTDATA_                  Is there at least 1 data register?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     FINDADDRESSREG_                  If so, time to compare address register
    BRA     FINDDATAREG_  
FOUNDFIRSTDATA_
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                          Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
LISTDATALOOP1_
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all the data register list?
    BEQ     PRINTLISTDATA1_                  If so, print  
    LSR.B   #1,D5                           Shift to the right
    BCS     FOUNDSECONDDATA_                 Are there more data registers?
    ADDI.B  #1,D1                           Increment counter
    CMPI.B  #8,D1                           Have we compared all in the data register list?
    BEQ     PRINTLISTDATA1_                  If so, print
    BRA     LISTDATALOOP1_                   If not, repeat loop
PRINTLISTDATA1_
    MOVE.B  #'/',(A3)+                      Add / to goodbuffer
    BRA     FINDADDRESSREG_                  Time to compare address register
FOUNDSECONDDATA_  
    MOVE.B  #'-',(A3)+
LISTDATALOOP2_
    LSR.B   #1,D5                           Shift to the right
    BCC     PRINTLISTDATA2_
    CMPI.B  #7,D1                           Have we compared all in the data register list?
    BEQ     FINDADDRESSREG_                  If so, time to compare address register
    ADDI.B  #1,D1                           Increment counter
    BRA     LISTDATALOOP2_    
PRINTLISTDATA2_
    MOVE.B  #'D',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    MOVE.B  #'/',(A3)+                      Add D to goodbuffer
    MOVEQ   #8,D1
    BRA     FINDADDRESSREG_        
FINDADDRESSREG_
    LSL.W   #1,D5                           Shift to the left
    BCS     FOUNDFIRSTADDRESS_               Is there at least 1 address register?
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEM2R                  If so, branch to finish
    BRA     FINDADDRESSREG_  
FOUNDFIRSTADDRESS_
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
ADDRESSLOOP1_
    SUBI.B  #1,D1                           Decrement counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEM2R                  If so, branch to finish 
    LSL.W   #1,D5                           Shift to the right
    BCS     FOUNDSECONDADDRESS_              Are there more address registers?
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINISHMOVEM2R                  If so, branch to finish 
    BRA     ADDRESSLOOP1_                    If not, repeat loop   
FOUNDSECONDADDRESS_ 
    MOVE.B  #'-',(A3)+    
LISTADDRESSLOOP2_
    LSL.W   #1,D5                           Shift to the left
    BCC     PRINTLISTADDRESS2_
    SUBI.B  #1,D1                           Increment counter
    CMPI.B  #0,D1                           Have we compared all in the address register list?
    BEQ     FINDADDRESSREG_                  If so, time to compare address register
    BRA     LISTADDRESSLOOP2_    
PRINTLISTADDRESS2_
    MOVE.B  #'A',(A3)+                      Add D to goodbuffer
    MOVE.B  D1,D0                           Move register number to D0.
    SUBI.B  #1,D0
    ADDI.B  #$30,D0                         Convert hex to ascii
    MOVE.B  D0,(A3)+                        Move ascii number to good buffer
    BRA     FINISHMOVEM2R   
    
    
    
    
MWORDDATAM2R
    MOVE.B  #'W',(A3)+                      Move W to the output
    BRA     FINDLIST2R                  Finish the instruction
MLONGDATAM2R
    MOVE.B  #'L',(A3)+                      Move L to the output
    BRA     FINDLIST2R                  Finish the instruction
FINISHMOVEM2R
    CMPI.B  #1,D3
    BEQ     ADDADDRESSWORD
    CMPI.B  #2,D3
    BEQ     ADDADDRESSLONGWORD
    BRA     RTN
ADDADDRESSWORD
    ADDA.L  #2,A5
    BRA     RTN
ADDADDRESSLONGWORD
    ADDA.L  #4,A5
    BRA     RTN
RTN    RTS                                     Return the instruction
********************************************************
* 0100 1101 - LEA instruction with An = 6              *     
********************************************************
FOUR1101
    JSR     LEAMAIN							Jump to main output printing routine
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'6',(A3)+                      Move 6 into the output
    RTS                                     Return the instruction
********************************************************
*0100 1110 - JSR & RTS                                 *     
********************************************************
FOUR1110
    CMP.W   #$4E75, D6                      Is this an RTS function
    BEQ     ITSARTS                         If so go to the ITSARTS function
    MOVE.B  #'J',(A3)+                      Move J into the output
    MOVE.B  #'S',(A3)+                      Move S into the output
    MOVE.B  #'R',(A3)+                      Move R into the output
    MOVE.B  #' ',(A3)+                      Move a space into the output
    JSR     EACODE                          call the EA code
    RTS										Return instruction

ITSARTS
    MOVE.B  #'R',(A3)+						Insert R into output
    MOVE.B  #'T',(A3)+						Insert T into output
    MOVE.B  #'S',(A3)+						Insert S into output
    RTS                                     Return the instruction
********************************************************
* 0100 1111 - LEA instruction with An = 7              *     
********************************************************
FOUR1111
    JSR     LEAMAIN							Jump to main output printing routine
    MOVE.B  #',',(A3)+                      Move a comma into the output
    MOVE.B  #'A',(A3)+                      Move A into the output
    MOVE.B  #'7',(A3)+                      Move 7 into the output
    RTS                                     Return the instruction
********************************************************
* LEA instruction                                      *     
********************************************************
LEAMAIN
    MOVE.B  #'L',(A3)+                      Move L into the ouput
    MOVE.B  #'E',(A3)+                      Move E into the ouput
    MOVE.B  #'A',(A3)+                      Move A into the ouput
    MOVE.B  #' ',(A3)+                      Move a space into the ouput
    JSR     EACODE                          Call EACODE to grab the only EA
    RTS                                     Return to finish LEA

********************************************************
* SHIFTREGISTERBITS - Get last 3 bits of an instruction*               
********************************************************
SHIFTREGISTERBITS
    MOVE.B  D6, D3                          Prep instruction for getting last 3 bits
    LSL.B   #5, D3                          Shift 5 to left to put number in MSB
    LSR.B   #5, D3                          Shift 5 to the right to put number in LSB
    RTS                                     Return the register number

********************************************************
* SHIFTMODEBITS - Get second to last 3 bits           *               
********************************************************
SHIFTMODEBITS
    MOVE.B  D6, D3                          Prep instruction for getting mode 3 bits
    LSL.B   #1, D3                          Shift 1 bit to the left
    LSR.B   #5, D3                          Shift 5 bits to the right, making the 3 digits be in LSB
    RTS                                     Return the Mode number

********************************************************
* GETSIZEONEBIT FUNCTION                               *
********************************************************
GETSIZEONEBIT
    MOVE.B  D6, D3                          Move instruction over for shifting
    LSL.B   #1, D3                          Shift 1 to the left so the MSB is the size
    LSR.B   #7, D3                          Shift 7 to the right so the MSB (which is the size) is in the LSB
    RTS                                     Return D3

********************************************************
* GETSIZE FUNCTION                                     *
********************************************************
GETSIZE
    MOVE.B  D6, D3                          Move instruction over for shifting
    LSR.B   #6, D3                          Shift the bits 6 to the right to put the size in the LSB
    RTS                                     Retrun D3

********************************************************
* GETOPMODE SIZE FUNCTION                              *
********************************************************
GETOPMODESIZE
    MOVE.W  D6, D3                          Move instruction over for shifting
    LSL.W   #7, D3                          Shift the bits 7 to the left to put the size in the LSB
    LSR.W	#8, D3							Shift the bits 8 to the right
    LSR.W	#5, D3							Shift the bits 5 to the right
    RTS                                     Retrun D3

********************************************************
* Return Bad Data                                      *
********************************************************
BADDATA
	MOVE.B	$11, D7							Flag bad data
	RTS										Return bad data

********************************************************
* GET BITS 9-11 IN INSTRUCTION FORMAT                  *
********************************************************
REGISTERBITS
    MOVE.W  D6, D3							Set instruction to D3 for bit shifting
    LSL.W   #4, D3							Shift 4 to the right to put the 3 bits in the MSB
    LSR.W   #8, D3							Shift to the right to make them LSB
    LSR.W   #5, D3							Shift to the right to make them LSB
    RTS										Return the 3 bits

********************************************************
* Get word of data from illegal instruction
********************************************************
GETWORDFORBADDATA
   	MOVE.B	 #' ',(A4)+						Move a space into bad buffer
    MOVE.B	#'$',(A4)+						Move $ into bad buffer
    MOVEQ  #4,D0               				Move counter to D0
    MOVE.W (A5)+,D4            				Move longword address into D4
LONGWORD_PREP1                  
    ROL.W  #4,D4               				Move the MSB
    MOVE.W D4,D5               				Move longword address to D5
    ANDI.L #$0000000F,D5       				Clear everything except for MSB
LONGWORD_ASC1
    CMPI.B #$09,D5             				Is the character a number?
    BLE    LONGWORD_NUM1        			Branch if yes.
LONGWORD_LET1
    ADDI.B #$37,D5             				Convert into a prinatble ascii letter
    BRA    NEXT_LONGWORD_CHAR1
LONGWORD_NUM1 
    ADDI.B #$30,D5             				Convert into a prinatble ascii number
    BRA    NEXT_LONGWORD_CHAR1
NEXT_LONGWORD_CHAR1
    SUBI.B #1,D0               				Decrement counter
    MOVE.B	D5,(A4)+						Push ASCII into bad buffer
    CMPI.B #0,D0               				Have we moved all characters?
    BGT    LONGWORD_PREP1       			If not, repeat loop
    RTS                        				If so, return

********************************************************
* EA FOR ALL OPCODE                                    *
********************************************************
EACODE
    CLR.W  D4           		Clear previous data in D4
    CLR.W  D5					Clear the D5 register
    MOVE.B D6,D5        		Move to isolate register
    MOVE.B D6,D4       			Move to isolate mode
    ANDI.B #$07,D5     			Isolate regster
    LSR.B  #3,D4        		Shift to isolate mode
    ANDI.B #$07,D4      		Isolate mode
    MULU   #$6,D4       		Find offset for mode
    LEA    FORMAT,A0    		Set the table to A0
    JSR    00(A0,D4)    		Set jumptable
    RTS 

********************************************************
* EA FOR MOVE OPCODE                                   *
********************************************************
EAMOVE
**************** Disect First EA Command****************
    CLR.W  D4           		Clear previous data in D4
    MOVE.B D6,D5        		Move to isolate register
    MOVE.B D6,D4        		Move to isolate mode
    ANDI.B #$07,D5      		Isolate regster
    LSR.B  #3,D4        		Shift to isolate mode
    ANDI.B #$07,D4      		Isolate mode
    MULU   #$6,D4       		Find offset for mode
    LEA    FORMAT,A0    		Set the table to A0
    JSR    00(A0,D4)    		Set jumptable 
    
    MOVE.B  #',',(A3)+
**************** Disect Second EA Command****************
    CLR.W  D4           		Clear previous data in D4
    MOVE.W D6,D5        		Move to isolate register
    MOVE.W D6,D4        		Move to isolate mode
    LSR.W  #4,D5        		Shift to isolate register
    LSR.W  #5,D5        		Shift to isolate register
    ANDI.B #$07,D5      		Isolate regster
    LSR.W  #6,D4       		    Shift to isolate mode
    ANDI.B #$07,D4      		Isolate mode
    MULU   #$6,D4       		Find offset for mode
    LEA    FORMAT,A0    		Set the table to A0
    JSR    00(A0,D4)    		Set jumptable
    RTS

FORMAT
    JMP    FORMAT000      		Call function with EA mode of 000
    JMP    FORMAT001      		Call function with EA mode of 001
    JMP    FORMAT010      		Call function with EA mode of 010
    JMP    FORMAT011      		Call function with EA mode of 011
    JMP    FORMAT100      		Call function with EA mode of 100
    JMP    FORMAT101      		Call function with EA mode of 101
    JMP    FORMAT110     		Call function with EA mode of 110
    JMP    FORMAT111     		Call function with EA mode of 111

********************************************************
* 000 - Dn INSTRUCTION                                 *               
********************************************************
FORMAT000
    MOVE.B #'D',(A3)+   		Move D into good buffer
    MULU   #$6,D5       		Find offset for register number
    LEA    REGISTER,A1  		Set the table to A0
    JSR    00(A1,D5)    		Set jumptable
    RTS
********************************************************
* 001 - An INSTRUCTION                                 *               
********************************************************
FORMAT001
    MOVE.B #'A',(A3)+   		Move D into good buffer
    MULU   #$6,D5       		Find offset for register number
    LEA    REGISTER,A1  		Set the table to A0
    JSR    00(A1,D5)    		Set jumptable  
    RTS
********************************************************
* 010 - (An) INSTRUCTION                               *               
********************************************************
FORMAT010  
    MOVE.B #'(',(A3)+   		Move (A) into good buffer
    MOVE.B #'A',(A3)+   		Move (A) into good buffer
    MULU   #$6,D5       		Find offset for register number
    LEA    REGISTER,A1  		Set the table to A0
    JSR    00(A1,D5)    		Set jumptable
    MOVE.B #')',(A3)+   		Move (A) into good buffer
    RTS
********************************************************
* 011 - (An)+ INSTRUCTION                              *               
********************************************************
FORMAT011 
    *CMP.B	#7, D5		 		If's a 7 it's the SP which you can't do
    *BEQ		BADDATA				Return bad data
    MOVE.B #'(',(A3)+   		Move (An)+ into good buffer
    MOVE.B #'A',(A3)+   		Move (An)+ into good buffer
    MULU   #$6,D5       		Find offset for register number
    LEA    REGISTER,A1  		Set the table to A0
    JSR    00(A1,D5)    		Set jumptable 
    MOVE.B #')',(A3)+   		Move (An)+ into good buffer 
    MOVE.B #'+',(A3)+   		Move (An)+ into good buffer
    RTS
********************************************************
* 100 - -(An) INSTRUCTION                              *               
********************************************************
FORMAT100  
    *CMP.B	#7, D5		 		If's a 7 it's the SP which you can't do
    *BEQ		BADDATA		 		Return bad data
    MOVE.B	#'-',(A3)+   		Move -(An) into good buffer
    MOVE.B	#'(',(A3)+   		Move -(An) into good buffer
    MOVE.B	#'A',(A3)+   		Move -(An) into good buffer
    MULU	#$6,D5       		Find offset for register number
    LEA		REGISTER,A1  		Set the table to A0
    JSR    	00(A1,D5)    		Set jumptable 
    MOVE.B 	#')',(A3)+   		Move -(An) into good buffer

    RTS
********************************************************
* 101 - (d16,An) INSTRUCTION                           *               
********************************************************
FORMAT101  
    MOVE.B  $11, D7             This is bad data
    BRA		GETWORDFORBADDATA	Branch to bad data that has word
********************************************************
* 110 - (d8,An,Xn) INSTRUCTION                         *               
********************************************************
FORMAT110 
    MOVE.B  $11, D7             This is bad data 
    RTS							return bad data
********************************************************
* 111 - XXX.W,XXX.L, #<data> INSTRUCTION               *               
********************************************************
FORMAT111
    MULU   #$6,D5       		Find offset for register number
    LEA    ABSOLUTE,A1  		Set the table to A0 
    JSR    00(A1,D5)    		Set jumptable 
    RTS
    
REGISTER
    JMP    REGISTER000      	Call function with EA register of 000
    JMP    REGISTER001      	Call function with EA register of 001
    JMP    REGISTER010      	Call function with EA register of 010
    JMP    REGISTER011      	Call function with EA register of 011
    JMP    REGISTER100      	Call function with EA register of 100
    JMP    REGISTER101      	Call function with EA register of 101
    JMP    REGISTER110      	Call function with EA register of 110
    JMP    REGISTER111      	Call function with EA register of 111
    
********************************************************
* 000- Register number of 0                            *               
********************************************************
REGISTER000
    MOVE.B #'0',(A3)+   		Move 0 into good buffer
    RTS
********************************************************
* 001- Register number of 1                            *               
********************************************************
REGISTER001
    MOVE.B #'1',(A3)+   		Move 1 into good buffer
    RTS
********************************************************
* 010- Register number of 2                            *               
********************************************************
REGISTER010
    MOVE.B #'2',(A3)+   		Move 2 into good buffer
    RTS
********************************************************
* 011- Register number of 3                            *               
********************************************************
REGISTER011
    MOVE.B #'3',(A3)+  		    Move 3 into good buffer
    RTS
********************************************************
* 100- Register number of 4                            *               
********************************************************
REGISTER100
    MOVE.B #'4',(A3)+   		Move 4 into good buffer
    RTS
********************************************************
* 101- Register number of 5                            *               
********************************************************
REGISTER101
    MOVE.B #'5',(A3)+   		Move 5 into good buffer
    RTS
********************************************************
* 110- Register number of 6                            *               
********************************************************
REGISTER110
    MOVE.B #'6',(A3)+   		Move 6 into good buffer
    RTS
********************************************************
* 111- Register number of 7                            *               
********************************************************
REGISTER111
    MOVE.B #'7',(A3)+   		Move 7 into good buffer
    RTS
    
ABSOLUTE
    JMP    ABSOLUTE000      	Call function with absolute register of 000
    JMP    ABSOLUTE001      	Call function with absolute register of 001
    JMP    ABSOLUTE010      	Call function with absolute register of 100
    JMP    ABSOLUTE011      	Call function with absolute register of 100
    JMP    ABSOLUTE100      	Call function with absolute register of 100

********************************************************
* 000- (XXX).W                                         *               
********************************************************
ABSOLUTE000
    MOVE.B 	#'$',(A3)+      	Move $ into good buffer
    MOVE.B	#' ',(A4)+			Move a space into bad buffer
    MOVE.B	#'$',(A4)+			Move $ into bad buffer
    MOVEQ  	#4,D0            Move counter to D0
    CMPI.B 	#1,D7            For MOVEM
    BEQ    	ADDWORD          We have to skip over a word.
    BRA    	MOVEWORD
ADDWORD
    MOVEA.L A5,A2
    ADDA.L 	#$2,A2
    MOVE.W 	(A2)+,D4
    BRA 	WORD_PREP
MOVEWORD
    MOVE.W (A5)+,D4         Move word address into D4
WORD_PREP
    ROL.W  #4,D4            	Move the MSB
    MOVE.W D4,D5            	Move word address to D5
    ANDI.W #$000F,D5        	Clear everything except for MSB
WORD_ASC
    CMPI.B #$09,D5          	Is the character a number?
    BLE    WORD_NUM         	Branch if yes.
WORD_LET
    ADDI.B #$37,D5			
    BRA    NEXT_WORD_CHAR   	Convert into a prinatble ascii letter

WORD_NUM
    ADDI.B #$30,D5
    BRA    NEXT_WORD_CHAR   	Convert into a prinatble ascii number
NEXT_WORD_CHAR
    SUBI.B #1,D0            	Decrement counter
    MOVE.B D5,(A3)+         	Move ascii into good buffer
    MOVE.B D5,(A4)+				Move ascii into bad buffer
    CMPI.B #0,D0            	Have we moved all characters?
    BGT    WORD_PREP        	If not, repeat loop
    MOVEQ  #1,D3
    RTS                     	If so, return
********************************************************
* 001- (XXX).L                                         *               
********************************************************
ABSOLUTE001
    MOVE.B 	#'$',(A3)+          Move $ into good buffer
    MOVE.B	#' ',(A4)+
    MOVE.B	#'$',(A4)+			Move $ into bad buffer
    MOVEQ  #8,D0               	Move counter to D0
    CMPI.B #1,D7            	For MOVEM
    BEQ    ADDLONGWORD          We have to skip over a word.
    BRA    MOVELONGWORD
ADDLONGWORD
    MOVEA.L A5,A2
    ADDA.L #$2,A2
    MOVE.L (A2)+,D4
    BRA LONGWORD_PREP
MOVELONGWORD
    MOVE.L (A5)+,D4            	Move longword address into D4
LONGWORD_PREP                  
    ROL.L  #4,D4               	Move the MSB
    MOVE.L D4,D5               	Move longword address to D5
    ANDI.L #$0000000F,D5       	Clear everything except for MSB
LONGWORD_ASC
    CMPI.B #$09,D5             	Is the character a number?
    BLE    LONGWORD_NUM        	Branch if yes.
LONGWORD_LET
    ADDI.B #$37,D5             	Convert into a prinatble ascii letter
    BRA    NEXT_LONGWORD_CHAR
LONGWORD_NUM 
    ADDI.B #$30,D5             	Convert into a prinatble ascii number
    BRA    NEXT_LONGWORD_CHAR
NEXT_LONGWORD_CHAR
    SUBI.B #1,D0               	Decrement counter
    MOVE.B 	D5,(A3)+            Move ascii into good buffer
    MOVE.B	D5,(A4)+
    CMPI.B #0,D0               	Have we moved all characters?
    BGT    LONGWORD_PREP       	If not, repeat loop
    MOVEQ  #2,D3
    RTS                        	If so, return
********************************************************
* 010- (d16, PC)                                      *               
********************************************************
ABSOLUTE010
	MOVE.B  $11, D7             This is bad data
	BRA		GETWORDFORBADDATA	Branch to bad data with word
********************************************************
* 011- (d8,PC,Xn)                                      *               
********************************************************
ABSOLUTE011
	MOVE.B  $11, D7             This is bad data
    BRA		GETWORDFORBADDATA	Branch to bad data with word
********************************************************
* 100- #<data>                                         *               
********************************************************
ABSOLUTE100
    MOVE.B #'#',(A3)+          	Move # into good buffer
    MOVE.B #'$',(A3)+          	Move # into good buffer
    MOVE.B #' ',(A4)+			Insert a space into bad buffer
    MOVE.B #'#',(A4)+			Insert a # into bad buffer
    MOVE.B #'$',(A4)+			Insert a $ into bad buffer
    CMPI.B #1,D1               	Do we need to specifically pull a longword of data?
    BEQ    LONGWORD_DATA       	If yes, branch.
WORD_DATA
    MOVEQ  #4,D0               	Move counter to D0
    MOVE.W (A5)+,D4            	Move word address into D4
DATA_WORD_PREP                 
    ROL.W  #4,D4               	Move the MSB
    MOVE.W D4,D5               	Move word address to D5
    ANDI.L #$0000000F,D5       	Clear everything except for MSB
DATA_WORD_ASC
    CMPI.B #$09,D5             	Is the character a number?
    BLE    DATA_WORD_NUM       	Branch if yes.
DATA_WORD_LET
    ADDI.B #$37,D5             	Convert into a prinatble ascii letter
    BRA    DATA_WORD_CHAR
DATA_WORD_NUM
    ADDI.B #$30,D5             	Convert into a prinatble ascii number
    BRA    DATA_WORD_CHAR
DATA_WORD_CHAR
    SUBI.B #1,D0               	Decrement counter
    MOVE.B D5,(A3)+            	Move ascii into good buffer
    MOVE.B D5,(A4)+				Move ascii into bad buffer
    CMPI.B #0,D0               	Have we moved all characters?
    BGT    DATA_WORD_PREP      	If not, repeat loop
    RTS                        	If so, return
LONGWORD_DATA
    MOVEQ  #8,D0               	Move counter to D0
    MOVE.L (A5)+,D4            	Move longword address into D4
DATA_LONGWORD_PREP             	
    ROL.L  #4,D4               	Move the MSB
    MOVE.W D4,D5               	Move longword address to D5
    ANDI.L #$0000000F,D5       	Clear everything except for MSB
DATA_LONGWORD_ASC
    CMPI.B #$09,D5             	Is the character a number?
    BLE    DATA_LONGWORD_NUM   	Branch if yes.
DATA_LONGWORD_LET
    ADDI.B #$37,D5             	Convert into a prinatble ascii letter
    BRA    DATA_LONGWORD_CHAR
DATA_LONGWORD_NUM
    ADDI.B #$30,D5             	Convert into a prinatble ascii number
    BRA    DATA_LONGWORD_CHAR
DATA_LONGWORD_CHAR
    SUBI.B #1,D0               	Decrement counter
    MOVE.B D5,(A3)+            	Move ascii into good buffer
    MOVE.B D5,(A4)+				Move ascii into bad buffer
    CMPI.B #0,D0               	Have we moved all characters?
    BGT    DATA_LONGWORD_PREP  	If not, repeat loop
    RTS                        	If so, return


THE_END     
	LEA     THE_END_MSG,A1      print the end message on the screen
    MOVEQ   #14,D0				Set printing trap
    TRAP    #15					Call trip

    SIMHALT             ; halt simulator
    
********************************************************
* DISPLAY MESSAGES                                     *
********************************************************
CR          EQU     $0D
LF          EQU     $0A
INTRO       DC.B   '\__   __/(  ____ \(  ___  )(       )',CR,LF
            DC.B   '   ) (   | (    \/| (   ) || () () |',CR,LF
            DC.B   '   | |   | (__    | (___) || || || |',CR,LF
            DC.B   '   | |   |  __)   |  ___  || |(_)| |',CR,LF
            DC.B   '   | |   | (      | (   ) || |   | |',CR,LF
            DC.B   '   | |   | (____/\| )   ( || )   ( |',CR,LF
            DC.B   '   )_(   (_______/|/     \||/     \|',CR,LF
            DC.B   ' ______  __________________ _______ ',CR,LF
            DC.B   '(  ___ \ \__   __/\__   __/(  ____ \',CR,LF
            DC.B   '| (   ) )   ) (      ) (   | (    \/',CR,LF
            DC.B   '| (__/ /    | |      | |   | (_____ ',CR,LF
            DC.B   '|  __ (     | |      | |   (_____  )',CR,LF
            DC.B   '| (  \ \    | |      | |         ) |',CR,LF
            DC.B   '| )___) )___) (___   | |   /\____) |',CR,LF
            DC.B   '|/ \___/ \_______/   )_(   \_______)',CR,LF
            DC.B   '________  .__                                           ___.   .__                ',CR,LF
            DC.B   '\______ \ |__| ___________    ______ ______ ____   _____\_ |__ |  |   ___________ ',CR,LF
            DC.B   ' |    |  \|  |/  ___/\__  \  /  ___//  ___// __ \ /     \| __ \|  | _/ __ \_  __ \',CR,LF
            DC.B   ' |    `   \  |\___ \  / __ \_\___ \ \___ \\  ___/|  Y Y  \ \_\ \  |_\  ___/|  | \/',CR,LF
            DC.B   '/_______  /__/____  >(____  /____  >____  >\___  >__|_|  /___  /____/\___  >__|   ',CR,LF
            DC.B   '        \/        \/      \/     \/     \/     \/      \/    \/          \/ ',CR,LF,CR,LF,0
ST_ADDR_MSG DC.B    'Please enter a starting address(MUST BE CAPS): ',0
EN_ADDR_MSG DC.B    'Please enter an ending address(MUST BE CAPS): ',0
IN_FAIL_MSG DC.B    'Sorry, you have entered an invalid address. Please try again!',CR,LF,0
YORN        DS.B    8
LINE_COUNT  DS.B    1
ST_INPUT    DS.B    80                  Stores starting address input
EN_INPUT    DS.B    80                  Stores ending address input
MIN_ST_ADD  EQU    $00007000 *this is the minimum starting address
MAX_EN_ADD  EQU    $00FFFFFE *this is the maximum ending address
ODD_ADD_MSG DC.B    'Oops!You have entered an odd address. Please enter an even address.',CR,LF,0
TOO_LOW_MSG DC.B    'Address too low! Please enter an address >= $7000',CR,LF,0
TOO_HI_MSG  DC.B    'Address too high! Please enter an address <= $FFFFFE',CR,LF,0    
STLT_MSG    DC.B    'Sorry, ending address cannot be less than starting address',CR,LF,0
EMPTY_LINE  DC.B    '  ', CR, LF, 0
RESTART_MSG DC.B   'Press (y) to run the program again. Press any other key to end: ',CR,LF,0
THE_END_MSG DC.B   '\__   __/|\     /|(  ____ \  (  ____ \( (    /|(  __  \ ',CR,LF
            DC.B   '   ) (   | )   ( || (    \/  | (    \/|  \  ( || (  \  )',CR,LF
            DC.B   '   | |   | (___) || (__      | (__    |   \ | || |   ) |',CR,LF
            DC.B   '   | |   |  ___  ||  __)     |  __)   | (\ \) || |   | |',CR,LF
            DC.B   '   | |   | (   ) || (        | (      | | \   || |   ) |',CR,LF
            DC.B   '   | |   | )   ( || (____/\  | (____/\| )  \  || (__/  )',CR,LF
            DC.B   '   )_(   |/     \|(_______/  (_______/|/    )_)(______/',CR,LF,CR,LF,0
END_STEP	DC.B	'Press [r] to restart, or [q] to quit', CR, LF, 0
NEXT_STEP   DC.B    'Press [Enter] to Continue, [r] to restart, or [q] to quit', CR, LF, 0
BAD_BUFFER   DC.L	1
FILLER		DC.L	80
FILLER2		DC.L	80
FILLER3		DC.L	80
FILLER4		DC.L	80
FILLER5		DC.L	80
FILLER6		DC.L	80
FILLER7		DC.L	80
FILLER8		DC.L	80
FILLER9		DC.L	80
FILLER10		DC.L	80
FILLER11		DC.L	80
FILLER12		DC.L	80
FILLER13		DC.L	80
FILLER14		DC.L	80
FILLER15		DC.L	80
GOOD_BUFFER  DC.L   1  
    END    START        ; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
