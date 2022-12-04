TITLE Project6    (Proj6_wiricka.asm)

; Author: Aimee Wirick
; Last Modified: 11/20/2022
; OSU email address: wiricka@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   6              Due Date: 12/04/2022
; Description: A MASM program that showcases skills in designing, implementing,
			;and calling low-level I/O procedures and implements and uses macros
			;goal is to get 10 valid number inputs from a user, store them in an array,
			;display the integers, their sum, and their truncated average.
			;displays error message If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers
			;displays error message if user enters nothing
			;parameters are passed on the stack, registers are saved and restored
			;Procedure LOCAL variable and push/pop directory format is per ED Discussions "LOCAL variables (optional)#437" -by TA Megan Steele & Kevin Kuei (thank you!)

INCLUDE Irvine32.inc

; description: Displays a prompt and get's user's keyboard input in to a memory location
; preconditions: variables set up in Main and pushed to ReadString 
; postconditions: Variables someInput and bytes have been filled with current information
; receives: input parameters : prompt(by reference), availLength
; returns: the user's input(by reference), number of byes
mGetString	MACRO	prompt, availLength, someInput, bytes
	PUSHAD
	XOR		EDX,EDX
	MOV		EDX, prompt ;prompt user to enter a number
	CALL	WriteString
	MOV		EDX, someInput ;moves address for someInput; placholder for variable to EDX which will then have user number in it CHANGE OFFSET?
	MOV		ECX, availLength ;sets the length of user input this is necessary for ReadString to work
	CALL	ReadString 
	MOV		bytes, EAX ;moves EAX value of bytes in user string to byteCount placeholder variable
	POPAD
ENDM  

; description: Prints the string that has been given to it by address
; preconditions: variable someStringAddress has been filled with an address
; postconditions: Prints string
; receives: someStringAddress by reference 
; returns: Prints string
mDisplayString	MACRO	someStringAddress
	PUSHAD
	XOR		EDX,EDX
	MOV     EDX, someStringAddress
	CALL	WriteString

	POPAD
ENDM

.data
;string variables
intro			BYTE	"PROJECT 6:	The sacred design of I/O procedures and low-level programming",9,9,"by Aimee Wirick",13,10,10,0
directions		BYTE	"DIRECTIONS:",10,"Input 10 positive or negative integers that can fit in a 32 bit register.",10,"When you are done, the list of your numbers, their sum, and average will be displayed.",13,10,0
numbrPrmpt		BYTE	"Enter your signed number here:", 0 ;prompt user to enter number
errorPrmpt		BYTE	"ERROR:  You didn't enter a number, or your number was an incorrect format.",10,"Give it another try:", 0
yourNumbers		BYTE	"The numbers you entered are: ",0
yourAverage		BYTE	"The truncated average of your numbers is: ",0
yourSum			BYTE	"The Sum of your numbers is: ",0
totalText		BYTE	"The running total is: ",0
goodbye			BYTE	"Goodbye, Happy End of Term, and Happy Holidays!!", 13,10,10,0
ecOne			BYTE	"**EC: Number each line. Add running subtotal. Use WriteVal.",13,10,10,0
;playing with ascii
hhLine1			BYTE	32,32,124,32,32,124,32,32,32,61,61,32,32,32,61,61,61,32,32,32,61,61,61,32,32,32,61,32,32,61,13,10,0
hhLine2			BYTE	32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,13,10,0
hhLine3			BYTE	32,32,61,61,61,61,32,32,61,61,61,61,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,13,10,0
hhLine4			BYTE	32,32,124,32,32,124,32,32,124,32,32,124,32,32,61,61,61,32,32,32,61,61,61,32,32,32,32,61,61,32,13,10,0
hhLine5			BYTE	32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,32,32,32,124,32,32,32,32,32,32,32,124,32,13,10,0
hhLine6			BYTE	32,32,124,32,32,124,32,32,124,32,32,124,32,32,124,32,32,32,32,32,124,32,32,32,32,32,32,32,124,32,13,10,10,0
hhLine7			BYTE	32,32,124,32,32,124,32,32,61,61,32,32,124,32,32,32,61,61,61,32,61,61,32,32,61,61,61,32,124,32,124,32,61,61,61,13,10,0
hhLine8			BYTE	32,32,124,32,32,124,32,124,32,32,124,32,124,32,32,32,32,124,32,32,124,32,124,32,124,32,124,32,124,32,124,32,124,13,10,0
hhLine9			BYTE	32,32,124,61,61,124,32,124,32,32,124,32,124,32,32,32,32,124,32,32,124,32,124,32,61,61,61,32,61,61,61,32,61,61,61,13,10,0
hhLine10		BYTE	32,32,124,32,32,124,32,124,32,32,124,32,124,32,32,32,32,124,32,32,124,32,124,32,124,32,124,32,32,124,32,32,32,32,124,13,10,0
hhLine11		BYTE	32,32,124,32,32,124,32,32,61,61,32,32,61,61,61,32,61,61,61,32,61,61,32,32,124,32,124,32,32,124,32,32,61,61,61,13,10,10,0
;setting up variables with data
maxLen			DWORD	12 ;maximum length of usrInput
usrInput		SDWORD	11 DUP(?) ; number from user
byteCount		DWORD	? ;number of bytes in user input
usrArray		SDWORD  11 DUP(?)
localNum		SDWORD  ?
arrayLen		DWORD	10 ;ten numbers long
counter			SDWORD	?
numberSum		SDWORD  ?
avrgNum			SDWORD	?
corrNum			SDWORD	?
lineNum			SDWORD	1
runTotal		SDWORD	?
.code
; description: MAIN Procedure, Uses procedures ReadVal called withing loop in main to get and store 10 integers
;	and WriteVal to display the integers.  Main also calculates and displays the integers and their truncated average
; preconditions: Variables are set up, ReadVal and WriteVal are set up as well as the macros mDisplayString, and mGetString
; postconditions: Converts string to number, stores, coverts number to string
; receives: number inputs obtained as string values
; returns: prints array of input, sum, average as output
main PROC
	_intro:
	mDisplayString	OFFSET intro		;print intro
	mDisplayString  OFFSET ecOne		;print extra credit text
	mDisplayString	OFFSET directions	;print directions
	CALL	CrLf

	_setupArray:
	MOV		ECX, 0
	MOV		ECX, arrayLen				
	MOV		EDI, OFFSET usrArray
	_fillArray:
		PUSH	lineNum				;4 bytes SDWORD
		CALL	WriteVal			;4 bytes return address, write line number
		MOV		AL, 32
		CALL	WriteChar
		PUSH	OFFSET	corrNum		;4 bytes address
		PUSH	OFFSET	errorPrmpt	;4 bytes address
		PUSH	OFFSET	numbrPrmpt	;4 bytes address
		PUSH	maxLen				;4 bytes DWORD
		PUSH	OFFSET  usrInput	;4 bytes address
		PUSH	OFFSET	byteCount	;4 bytes address
		CALL	ReadVal				;4 bytes return address
		mDisplayString OFFSET totalText ;dialogue for running total
		INC		lineNum
		MOV		EAX, runTotal  ;calculate running total
		ADD		EAX, corrNum
		MOV		runTotal, EAX
		PUSH	runTotal
		CALL	WriteVal		;display total
		CALL	CrLf	
		CALL	CrLf
		MOV		EBX, corrNum
		MOV		[EDI], EBX			;store number in array
		ADD		EDI, 4
		LOOP _fillArray
	
	_returnResults:
		_dialogue1:
		CALL	CrLF
		CALL	CrLf
		mDisplayString	OFFSET yourNumbers ;dialogue to display numbers
		_setNumberLoop:
		MOV    ECX, arrayLen
		MOV    ESI, OFFSET usrArray
		XOR	   EAX,EAX
		_revArray: ;displays numbers in usrArray
			CLD
			LODSD
			MOV		localNum, EAX
			CLD
			PUSH	localNum	;4 bytes SDWORD
			ADD		numberSum, EAX ;adds the number to the numberSum to track total
			MOV		counter, ECX
			CALL	WriteVal	;4 bytes return address .... writes the numbers individually
			CMP		ECX, 1 ;leaves off comma and space if it is last number
			JE		_finish
			MOV		AL, 44 ;adds comma
			CALL	WriteChar
			MOV		AL, 32 ;adds space
			CALL	WriteChar
			_finish:
			MOV		ECX, counter
			LOOP   _revArray
		CALL CrLf
		CALL CrLf
		_dialogue2: ;dialogue to display sum of array numbers
		mDisplayString	OFFSET yourSum
		PUSH	numberSum ;4 bytes SDWORD
		CALL	WriteVal ;4 bytes return address .... writes the sum
		CALL	CrLf
		CALL	CrLf
		_findAverage: ;calculates the average of the array numbers
		MOV	EAX, numberSum
		MOV EBX, arrayLen
		CDQ
		IDIV EBX
		MOV avrgNum, EAX
		XOR EAX,EAX
		XOR EBX,EBX
		_dialogue3: ;dialogue to display average of array numbers
		mDisplayString	OFFSET yourAverage
		PUSH	avrgNum ;4 bytes SDWORD
		CALL	WriteVal ;4 bytes return address .... writes the average
		CALL	CrLf
		CALL	CrLf
		_goodbye:
		mDisplayString OFFSET goodbye
		CALL CrLf
		;just for fun for the holidays a little playing with ascii
		mDisplayString OFFSET hhLine1
		mDisplayString OFFSET hhLine2
		mDisplayString OFFSET hhLine3
		mDisplayString OFFSET hhLine4
		mDisplayString OFFSET hhLine5
		mDisplayString OFFSET hhLine6
		mDisplayString OFFSET hhLine7
		mDisplayString OFFSET hhLine8
		mDisplayString OFFSET hhLine9
		mDisplayString OFFSET hhLine10
		mDisplayString OFFSET hhLine11
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; description: Invokes mGetString macro to get user input in the form of string.  Converts string using string primitives to ascii digits
				;validates that user input is within the required parameters.  Stores the value by reference
; preconditions: mGetString is set up, and reference perameters have been pushed from main to fill local variables, for the user input and number outputs.
; postconditions: Converts and Stores the converted user input into the array by address
; receives: pushed variables from main for user input, number of bytes, maximum allowable length, and destination address for converted number
; returns: converted number to destination address
ReadVal	PROC

;local variables to keep my head straight :)
	LOCAL	origPrompt:DWORD
	LOCAL	prompt:DWORD	
	LOCAL	errTryAgain:DWORD	
	LOCAL	lengthMax:DWORD
	LOCAL	inputNum[11]:SDWORD	
	LOCAL	byteNum:DWORD	
	LOCAL	prevNum:SDWORD	
	LOCAL	sign:DWORD
	LOCAL	errorMes:DWORD
	LOCAL	countNum:DWORD
	LOCAL   currNum:SDWORD
	LOCAL	correctNum:SDWORD
	LOCAL   tempPrev:SDWORD
	PUSHAD ;push all directories 32 bytes

	;clear variables
	MOV		errorMes, 0
	MOV		countNum, 0
	MOV		prevNum, 0
	MOV		sign, 0
	MOV		correctNum, 0

	;set up variable data
	MOV		EBX, 0
	MOV		EBX, [EBP+8]	;find bytes
	MOV		byteNum, EBX	;fill byte variable
	MOV		EBX,[EBP+12]	;find user input number
	MOV		inputNum, EBX	;fill user input variable
	MOV		EBX, [EBP+16]	;find max length
	MOV		lengthMax, EBX	;fill max length variable
	MOV		EBX, [EBP+20]	;find prompt
	MOV		origPrompt, EBX	;fill prompt variable
	MOV		EBX, [EBP+24]	;find error message
	MOV		errTryAgain, EBX;fill error message prompt
	MOV		EBX, [EBP+28]	;find corrNum address
	MOV		correctNum, EBX ;fill the correctNumber address

	MOV		EBX, origPrompt
	MOV		prompt, EBX

	_start:
	mGetString	prompt, lengthMax, inputNum, byteNum ;get string
	CLD
	MOV sign,0
	MOV EBX, origPrompt ;this sets the original
	MOV prompt, EBX
	MOV	ECX, byteNum ;start counter for gathering each byte
	MOV	ESI, inputNum ;start pointers for gathering each byte
	CMP byteNum, 0
	JE	_errorMSG
	_conversionLoop:
	 XOR	EAX,EAX;clears EAX register for introducing our first byte
	 LODSB  ;puts byte in AL
		CMP		AL, 43 ; +
		JE		_setSignPositive
		CMP		AL, 45 ; -
		JE		_setSignNegative
		CMP		AL, 48 ;checks for numerical value against the lowest ascii numerical representation
		JGE     _checkHi
		JMP		_errorMSG
		_setSignPositive: ;sets a local variable so we can track if the number is positive
			MOV		sign, 0
			MOV		EBX, byteNum
			CMP		EBX, 1
			JE		_errorMSG
			JMP		_end
		_setSignNegative: ;sets a local variable so we can track if number is negative
			MOV		EBX, byteNum
			CMP		EBX, 1
			JE		_errorMSG
			MOV		sign, 1
			JMP		_end
		_checkHi: ;checks against the highest ascii numerical representation 57
			CMP		AL, 57
			JLE		_convert
		    JMP		_errorMSG

		_convert: ;had to make this because the loop was too big.  This uses local variables from ReadVal
			MOV		currNum, EAX	
			PUSH	prevNum			;4 byte SDWORD
			PUSH	currNum			;4 byte SDWORD
			PUSH	sign			;4 byte DWORD
			LEA		EBX, tempPrev   
			PUSH	EBX				;4 byte register
			LEA     EBX, errorMes
			PUSH	EBX				;4 byte register
			CALL	Convert
			JO	 _errorMSG  ;this is important and catches the error if the last number flagged overflow when added
			CMP		errorMes, 1
			JE		_errorMSG
			JMP  _store
		_errorMSG:
			MOV		EBX, errTryAgain
			MOV		prompt, EBX ;sets error prompt
			XOR     EBX,EBX
			MOV     errorMes, EBX ;clears errorMes
			MOV		countNum, EBX ;clears countNum
			MOV     prevNum, EBX ;clears prevNum
			MOV		tempPrev, EBX ;clears tempPrev
			JMP _start

		_store:
			MOV		EAX, tempPrev ;finds the temporary number
			MOV		prevNum, EAX ;stores the number as prevNum so we can progress
			INC		countNum
		_end:
	
	LOOP _conversionLoop

	MOV  EDI, correctNum ;address for corrNum
	MOV	 [EDI], EAX ;moves the corrected number in to address for the variable corrNum in main

	POPAD ;pop all directoreis
	RET		24
ReadVal	ENDP

; description: A sub procedure of ReadVal with conversion process to convert string numbers to ascii.  Returns an error message if the converted number gets to big for register
; preconditions: The previous number in the sequence, the current number, the sign, the address to return converted number to, and the address for error message
					;are pushed to Convert via ReadVal
; postconditions: returns converted number to address sent by ReadVal, returns error if there is one.
; receives: numbers and addresses from ReadVal
; returns: converted number or error message
Convert PROC ;subprocedure of ReadVal
	LOCAL	MAX:SDWORD
	LOCAL	MIN:SDWORD
	LOCAL	negSign:SDWORD
	LOCAL	tempNum:SDWORD
	LOCAL	subNum:SDWORD
	LOCAL	previousNum:SDWORD ;actual number from parent procedure
	LOCAL	errorMes:DWORD ;address for error message in parent procedure
	LOCAL	sign2:DWORD    ;actual number 1 or 0 indicating sign
	LOCAL   current:SDWORD ;address for current number from EAX in parent procedure
	LOCAL   outNumAddr:SDWORD
	
	PUSHAD	
	MOV		EBX, 0
	MOV		EBX, [EBP+8]	
	MOV		errorMes, EBX	;error message address
	MOV		EBX,[EBP+12]	;find out number address
	MOV		outNumAddr, EBX ;address of what we send to parent procedures
	MOV		EBX, [EBP+16]
	MOV		sign2, EBX		;1 or 0 indicating sign
	MOV		EBX, [EBP+20]   ;current number in parent procedure under EAX
	MOV		current, EBX
	MOV		EBX, [EBP+24]   ;previous number in parent procedure
	MOV		previousNum, EBX

	MOV		negSign, -1
	MOV		MIN, -214748364
	MOV		MAX, +214748364
	MOV		EDI, errorMes
	MOV		EBX,0
	MOV		[EDI],EBX ;clears error message in ReadVal ...was having trouble keeping this cleared after starting a new number post error
	XOR		EAX,EAX
	MOV		tempNum, 0
	_convert:
			MOV		EAX, current
			SUB		EAX, 48 ;changes to ascii number
			MOV		EBX, sign2
			CMP		EBX, 1 ;EBX checks if the sign is negative
			JE		_fixSign
			JMP		_continue
			_fixSign:
			MOV		tempNum, EAX
			MOV		EAX, negSign
			IMUL	EAX, tempNum ;multiplies our temporary number by -1
			_continue: ;continues conversion process
			MOV		subNum, EAX
			MOV		EAX, 0
			MOV		EAX, previousNum 
			CMP		EAX, MIN ;compares previous number to MIN to make sure it isn't too small so far
			JL		_error
			CMP		EAX, MAX ;compares previous number to MAX to make sure it isn't too big so far
			JG		_error
			MOV		EBX, 10
			IMUL	EBX     ;changes the place of previous number by 10
			ADD		EAX, subNum ;adds the new integer
			JMP		_store
			_error:
			MOV	EDI, errorMes
			MOV EBX, 1 
			MOV [EDI], EBX ;alerts parent procedure that there has been an error
			XOR EBX,EBX ;clears the EBX register
			JMP _end ;doesn't store this number
			_store:
			MOV EDI, outNumAddr ;finds address to send to ReadVal
			MOV [EDI], EAX ;sends converted number back to ReadVal
			_end:
	POPAD
	RET 20
Convert ENDP

; description: A procedure that takes an ascii number and converts its digits to a string and returns it
; preconditions: An ascii number is passed via the stack from main
; postconditions: A string is returned via reference 
; receives: An ascii number passed on the stack
; returns: A string made of converted ascii digits
WriteVal	PROC 

		LOCAL	numDigits:DWORD	;number of digits in the number
		LOCAL	number:SDWORD	
		LOCAL	copyNumber:SDWORD
		LOCAL	arrayAddress:DWORD	 ;address for array
		LOCAL	revString[12]:BYTE	
		LOCAL	newNum:DWORD	
		LOCAL	remainder:DWORD
		LOCAL	quotient:DWORD	
		LOCAL	isNeg:BYTE
		LOCAL	newString[12]:BYTE
		LOCAL	byteQuotient:DWORD

		PUSHAD
		;clear local variables for the new number
		MOV		numDigits, 0
		MOV		number, 0
		MOV		copyNumber, 0
		MOV		arrayAddress, 0
		MOV		revString, 0
		MOV		newNum, 0
		MOV		remainder, 0
		MOV		quotient, 0
		MOV		isNeg, 0
		XOR		EAX,EAX
		MOV		ECX, 12 ;gives our counter 10 rounds with buffer for negative sign
		LEA		EBX, newString
		MOV		EDI, EBX
		CLD
		REP     STOSB ;clears newString variable for starting fresh
		MOV		byteQuotient, 0
	
		;get informatinon to fill variables from the stack
		MOV		EBX,0
		MOV		EBX,[EBP+8]	;find user input number
		MOV		number, EBX		;fill user input variable


		;fill local variables
		MOV		revString, 0
		;Set up the perameters for _writeLoop		
		_checkSign:
		MOV	EAX, 0 ;clear eax for new byte
		MOV	EAX, number
		SUB	EAX, 0 ;checks if our number is negative
		JS _negative
		JMP _next
        _negative:
		MOV		isNeg, 1
		IMUL	EAX, -1 ;changes it to positive so that we can evaluate easier
		MOV		number, EAX	
		_next:
		MOV		newNum, EAX ;moves our now positive valued number into newNum
		MOV		byteQuotient, EAX ;moves to the quotient variable for calculating number of digits
		_findNumberOfDigits: ;decreases by a place value each iteration so we can count digits (excluding negative sign)
			MOV	EAX, byteQuotient
			MOV	EDX, 0
			MOV	EBX, 10
			DIV EBX
			MOV EBX, 0
			MOV	EBX, 1
			ADD	numDigits, EBX
			CMP EAX, 0
			JE	_stringConvert
			MOV byteQuotient, EAX
			JMP _findNumberOfDigits
		_stringConvert:
		LEA	EDI, revString
		CLD
		MOV		ECX, 0
		MOV		ECX, numDigits
		CMP		ECX, 1
		JE		_writeSingleLoop ;converts number without changing place value loop
		_writeMultipleLoop: ;for when there are more than one number and place values need to be considered
			MOV EAX, newNum
			MOV EDX, 0
			MOV EBX, 10
			DIV	EBX
			MOV	remainder, EDX
			MOV quotient, EAX
			MOV EDX, remainder
			ADD	EDX, 48 ;converts
			MOV	[EDI], EDX
			ADD	EDI, 1 ;adds number to next address in string
			MOV newNum, EAX ;saves the result as newNum
			LOOP _writeMultipleLoop
			JMP _postLoop
		_writeSingleLoop: ;for if there is only one number
			MOV EAX, newNum
			ADD EAX, 48
			MOV [EDI], EAX
			ADD EDI, 1
			MOV EAX, 0
		_postLoop:	;finishes our string		
			MOV	AL, isNeg ;adds negative at end of string so that when we reverse it it will be read at beginning
			CMP	AL, 1
			JE	_addNeg
			JMP _end
			_addNeg:
			MOV EBX, 45
			MOV	[EDI], EBX
			MOV	isNeg, 0
			INC	numDigits
			_end:
		  ; Reverse the string
	_loopReversal:
	  MOV	 ECX, 0
	  MOV    ECX, numDigits ;how long string is
	  LEA    ESI, revString ;finds the source string
	  ADD    ESI, ECX ;finds address of end of string
	  DEC    ESI ;starts at the end of revString
	  LEA    EDI, newString;address destination of our correctly ordered string
	  MOV	EAX, 0	
	  MOV newString, 0
	  ;   Reverse string
	_revLoop: ;reverses string
		STD
		LODSB
		CLD
		STOSB
	  LOOP   _revLoop
	LEA	EAX, newString;finds address of newString
	mDisplayString	EAX ;stores item in string

	POPAD

	RET		4
WriteVal	ENDP
END main