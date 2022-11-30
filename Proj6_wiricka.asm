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

INCLUDE Irvine32.inc

; Macros
mGetString	MACRO	prompt, availLength, someInput, bytes
	PUSH	EDX ;sets up stack
	PUSH	ECX
	MOV		EDX, prompt ;prompt user to enter a number
	CALL	WriteString
	MOV		EDX, someInput ;moves address for someInput; placholder for variable to EDX which will then have user number in it CHANGE OFFSET?
	MOV		ECX, availLength ;sets the length of user input this is necessary for ReadString to work
	CALL	ReadString 
	MOV		bytes, EAX ;moves EAX value of bytes in user string to byteCount placeholder variable
	POP		ECX  ;resets stack
	POP		EDX
ENDM  

mDisplayString	MACRO	someStringAddress
	PUSH	EDX
	MOV     EDX, someStringAddress
	CALL	WriteString
	POP		EDX
ENDM

.data

intro			BYTE	"PROJECT 6:	The sacred design of I/O procedures and low-level programming",9,9,"by Aimee Wirick",10,10,0
directions		BYTE	"DIRECTIONS:",10,"Input 10 positive or negative integers that can fit in a 32 bit register.",10,"When you are done, the list of your numbers, their sum, and average will be displayed.",13,10,0
numbrPrmpt		BYTE	"Enter your signed number here:", 0 ;prompt user to enter number
errorPrmpt		BYTE	"ERROR:  You didn't enter a number, or your number was an incorrect format.",10,"Give it another try:", 0
currPrmpt		DWORD	?
maxLen			DWORD	12 ;maximum length of usrInput
usrInput		SDWORD	? ; number from user
correctNum		SDWORD	? ; checked  number value
numCount		DWORD	? ;number of numbers from user
byteCount		DWORD	? ;number of bytes in user input
byteCountArray	DWORD	10 DUP(?)
revByteArray	DWORD	10 DUP(?) ;tracks each number's origianl length
usrArray		SDWORD  10 DUP(?)
localNum		SDWORD  ?
arrayLen		BYTE	3 ;CHANGE TO 10

.code
main PROC
	mDisplayString	OFFSET intro		;print intro
	mDisplayString	OFFSET directions	;print directions
	CALL	CrLf
	;start 10 count loop here
	MOV		ECX, 0
	MOV		CL, arrayLen				;THIS NEEDS TO CHANGE TO 10
	MOV		EDI, OFFSET usrArray
	MOV		ESI, OFFSET byteCountArray
	_fillLoop:
		PUSH	OFFSET	errorPrmpt	;4 bytes address
		PUSH	OFFSET	numbrPrmpt	;4 bytes address
		PUSH	maxLen				;4 bytes DWORD
		PUSH	OFFSET  usrInput	;4 bytes address
		PUSH	OFFSET	byteCount	;4 bytes address
		CALL	ReadVal				;4 bytes return address
		MOV		byteCount, EBX
		MOV		[ESI], EBX ;store information on how dang long the numbers
		ADD		ESI, 4
		MOV		[EDI], EDX;store number in array
		ADD		EDI, 4
		MOV		correctNum, EDX ;this should add to userArray in EDI
		LOOP _fillLoop
	;ADD A LOOP THAT LOADS EACH ELEMENT IN THE ARRAY AND PRINTS
	_returnLoop:

		_setNumberLoop:
			;set up loop backwards
			MOV    CL, arrayLen
			MOV    ESI, OFFSET usrArray
			;MOV	   EAX, ECX
			;IMUL   EAX, 4
			;ADD    ESI, EAX ;sets us at the end of the array
			;SUB	   ESI, 4
			MOV	   EAX, 0
		_revArray:
			CLD
			STD
			LODSD
			MOV		localNum, EAX
			CLD
			PUSH	localNum	;4 bytes SDWORD
			CALL	WriteVal	;4 bytes return address
		  LOOP   _revArray


	Invoke ExitProcess,0	; exit to operating system
main ENDP

ReadVal	PROC

	;.data	;local variables to keep my head straight :)

	LOCAL	prompt:DWORD	
	LOCAL	errTryAgain:DWORD	
	LOCAL	lengthMax:DWORD
	LOCAL	inputNum:SDWORD	
	LOCAL	byteNum:DWORD	
	LOCAL	outNum:SDWORD
	LOCAL	prevNum:SDWORD	
	LOCAL	sign:DWORD
	LOCAL	errorMes:DWORD
	LOCAL	countNum:BYTE
	;set up variable data
	MOV		errorMes, 0
	MOV		countNum, 0

	PUSH	ECX
	PUSH	EDI
	PUSH	ESI
	;.code
	MOV		EBX, 0
	MOV		EBX, [EBP+8]	;find bytes
	MOV		byteNum, EBX	;fill byte variable
	MOV		EBX,[EBP+12]	;find user input number
	MOV		inputNum, EBX	;fill user input variable
	MOV		EBX, [EBP+16]	;find max length
	MOV		lengthMax, EBX	;fill max length variable
	MOV		EBX, [EBP+20]	;find prompt
	MOV		prompt, EBX		;fill prompt variable
	MOV		EBX, [EBP+24]	;find error message
	MOV		errTryAgain, EBX;fill error message prompt
	_start: 
	;clear variables
	MOV prevNum, 0
	
	MOV sign, 0
	
	MOV errorMes, 0
	MOV countNum, 0 
	mGetString	prompt, lengthMax, inputNum, byteNum ;get string
	CLD
	MOV	ECX, byteNum ;start counter for gathering each byte
	MOV	ESI, inputNum ;start pointers for gathering each byte

	_conversionLoop:
	 CMP  countNum, 10 ;keeps track if our number is over 10 bytes long (disregards + -)
	 JE	  _errorMSG
	 MOV  EAX, 0 ;clears EAX register for introducing our first byte
	 LODSB  ;puts byte in AL
		CMP		AL, 43 ; +
		JE		_setSignPositive
		CMP		AL, 45 ; -
		JE		_setSignNegative
		CMP		AL, 48 ;checks for numerical value against the lowest ascii numerical representation
		JGE     _checkHi
		_setSignPositive: ;sets a local variable so we can track if the number is positive
			MOV		sign, 0
			MOV		EBX, byteNum
			CMP		EBX, 1
			JE		_errorMSG
			JMP		_end
		_setSignNegative: ;sets a local variable so we can track if number is negative
			MOV		sign, 1
			MOV		EBX, byteNum
			CMP		EBX, 1
			JE		_errorMSG
			JMP		_end
		_checkHi: ;checks against the highest ascii numerical representation 57
			CMP		AL, 57
			JLE		_convert
		    JMP		_errorMSG

		_convert: ;had to make this because the loop was too big.  This uses local variables from ReadVal
			MOV	EBX, sign
			MOV EDX, prevNum
			CALL	Convert
			MOV	errorMes, EBX
			MOV EBX, 0
			MOV EDX, 0
			JO	 _errorMSG
			CMP		errorMes, 1
			JE		_errorMSG
			JMP  _store
		_errorMSG:
			MOV		EBX, errTryAgain
			MOV		prompt, EBX ;sets error prompt
			MOV		EBX, 0
			JMP _start

		_store:
			MOV		prevNum, EAX ;stores the number as prevNum so we can progress
			INC		countNum
		_end:
	LOOP _conversionLoop
	MOV outNum, EAX ;moves the total into our outNum variable (do not erase)


	MOV		EDX, outNum
	MOV		EBX, byteNum
	POP		ESI
	POP		EDI
	POP		ECX
	RET		20
ReadVal	ENDP

Convert PROC ;subprocedure of ReadVal
	LOCAL	MAX:SDWORD
	LOCAL	MIN:SDWORD
	LOCAL	negSign:SDWORD
	LOCAL	tempNum:SDWORD
	LOCAL	subNum:SDWORD
	LOCAL	prevNum:SDWORD
	LOCAL	errorMes:BYTE
	
	PUSH	EDX
	MOV		prevNum, EDX
	MOV		EDX, 0
	MOV		negSign, -1
	MOV		MIN, -214748364
	MOV		MAX, +214748364
	_convert:
			SUB		EAX, 48
			CMP		EBX, 1 ;EBX should have sign value
			JE		_fixSign
			JMP		_continue
			_fixSign:
			MOV		tempNum, EAX
			MOV		EAX, negSign
			IMUL	EAX, tempNum;this is changing the register to a crazy number
			_continue:
			MOV		subNum, EAX
			MOV		EAX, 0
			MOV		EAX, prevNum
			CMP		EAX, MIN
			JL		_error
			CMP		EAX, MAX
			JG		_error
			MOV		EBX, 10
			IMUL	EBX
			ADD		EAX, subNum
			JMP		_end
			_error:
			MOV		EBX, 1
			_end:

	POP		EDX
	RET		
Convert ENDP

WriteVal	PROC ;this works

		LOCAL	numDigits:DWORD	;USE Str_length TO GET THIS INSTEAD BECAUSE THIS WILL HAVE CHANGED
		LOCAL	number:SDWORD	
		LOCAL	copyNumber:SDWORD
		LOCAL	arrayAddress:DWORD	 ;does this have to be an array set-up since it is just an address?
		LOCAL	revString[12]:BYTE	
		LOCAL	newNum:DWORD	
		LOCAL	remainder:DWORD
		LOCAL	quotient:DWORD	
		LOCAL	isNeg:BYTE
		LOCAL	newString[12]:BYTE
		LOCAL	byteQuotient:DWORD

		MOV		numDigits, 0
		MOV		number, 0
		MOV		copyNumber, 0
		MOV		arrayAddress, 0
		MOV		revString, 0
		MOV		newNum, 0
		MOV		remainder, 0
		MOV		quotient, 0
		MOV		isNeg, 0
		MOV		newString, 0
		MOV		byteQuotient, 0
		PUSHAD

		MOV		EBX,0
		MOV		EBX,[EBP+8]	;find user input number
		MOV		number, EBX		;fill user input variable



		MOV		revString, 0
		;Set up the perameters for _writeLoop		
		_checkSign:
		MOV	EAX, 0 ;clear eax for new byte
		MOV	EAX, number
		SUB	EAX, 0
		JS _negative
		JMP _next
        _negative:
		MOV		isNeg, 1
		IMUL	EAX, -1
		MOV		number, EAX	
		_next:
		MOV		newNum, EAX
		MOV		byteQuotient, EAX
		_findNumberOfDigits:
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

		_writeLoop:
			MOV EAX, newNum
			MOV EDX, 0
			MOV EBX, 10
			DIV	EBX
			MOV	remainder, EDX
			MOV quotient, EAX
			MOV EDX, remainder
			ADD	EDX, 48
			MOV	[EDI], EDX
			ADD	EDI, 1 ;may need to change back to 4?
			MOV newNum, EAX
			LOOP _writeLoop
						
			MOV	AL, isNeg ;adds negative at end of string so that when we reverse it it will be read at beginning
			CMP	AL, 1
			JE	_addNeg
			JMP _end
			_addNeg:
			MOV EBX, 45
			MOV	[EDI], EBX
			ADD	EDI,1
			MOV	isNeg, 0
			INC	numDigits
			_end:
			;ADD ANOTHER WRITE USING STOSB AND REVERSING STRING TO CREATE FORWARDS STRING FOR WRITING?
		  ; Reverse the string
	_loopReversal:
	  MOV    ECX, numDigits
	  LEA    ESI, revString 
	  ADD    ESI, ECX
	  DEC    ESI
	  LEA    EDI, newString;SHOULD THIS BE STORED IN arrayAddress? MAYBE MAYBE NOT
  
	  ;   Reverse string
	_revLoop:
		STD
		LODSB
		CLD
		STOSB
	  LOOP   _revLoop
	LEA	EAX, newString;SHOULD THIS BE STORED IN arrayAddress? MAYBE MAYBE NOT
	mDisplayString	EAX
	POPAD

	RET		4
WriteVal	ENDP
END main