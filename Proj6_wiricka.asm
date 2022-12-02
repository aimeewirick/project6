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
			;Procedure Local variable and push/pop directory format is per ED Discussions "LOCAL variables (optional)#437" -by TA Megan Steele (thank you!)

INCLUDE Irvine32.inc

; Macros
mGetString	MACRO	prompt, availLength, someInput, bytes
	PUSHAD
	MOV		EDX, prompt ;prompt user to enter a number
	CALL	WriteString
	MOV		EDX, someInput ;moves address for someInput; placholder for variable to EDX which will then have user number in it CHANGE OFFSET?
	MOV		ECX, availLength ;sets the length of user input this is necessary for ReadString to work
	CALL	ReadString 
	MOV		bytes, EAX ;moves EAX value of bytes in user string to byteCount placeholder variable
	POPAD
ENDM  

mDisplayString	MACRO	someStringAddress
	PUSHAD
	MOV     EDX, someStringAddress
	CALL	WriteString

	POPAD
ENDM

.data

intro			BYTE	"PROJECT 6:	The sacred design of I/O procedures and low-level programming",9,9,"by Aimee Wirick",10,10,0
directions		BYTE	"DIRECTIONS:",10,"Input 10 positive or negative integers that can fit in a 32 bit register.",10,"When you are done, the list of your numbers, their sum, and average will be displayed.",13,10,0
numbrPrmpt		BYTE	"Enter your signed number here:", 0 ;prompt user to enter number
errorPrmpt		BYTE	"ERROR:  You didn't enter a number, or your number was an incorrect format.",10,"Give it another try:", 0
yourNumbers		BYTE	"The numbers you entered are: ", 13,10,0
yourAverage		BYTE	"The average of your numbers is: ",13,10,0
yourSum			BYTE	"The Sum of your numbers is: ", 13,10,0
maxLen			DWORD	12 ;maximum length of usrInput
usrInput		SDWORD	11 DUP(?) ; number from user
byteCount		DWORD	? ;number of bytes in user input
usrArray		SDWORD  11 DUP(?)
localNum		SDWORD  ?
arrayLen		DWORD	3 ;ten numbers long
counter			SDWORD	?
numberSum		SDWORD  ?
avrgNum			SDWORD	?
corrNum			SDWORD	?

.code
main PROC
	_intro:
	mDisplayString	OFFSET intro		;print intro
	mDisplayString	OFFSET directions	;print directions
	CALL	CrLf

	_setupArray:
	MOV		ECX, 0
	MOV		ECX, arrayLen				
	MOV		EDI, OFFSET usrArray
	_fillArray:
		PUSH	OFFSET	corrNum		;4 bytes address
		PUSH	OFFSET	errorPrmpt	;4 bytes address
		PUSH	OFFSET	numbrPrmpt	;4 bytes address
		PUSH	maxLen				;4 bytes DWORD
		PUSH	OFFSET  usrInput	;4 bytes address
		PUSH	OFFSET	byteCount	;4 bytes address
		CALL	ReadVal				;4 bytes return address
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
			CMP		ECX, 1
			JE		_finish
			MOV		AL, 44
			CALL	WriteChar
			MOV		AL, 32
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
	Invoke ExitProcess,0	; exit to operating system
main ENDP

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
	MOV		origPrompt, EBX		;fill prompt variable
	MOV		EBX, [EBP+24]	;find error message
	MOV		errTryAgain, EBX;fill error message prompt
	MOV		EBX, [EBP+28]	;find corrNum address
	MOV		correctNum, EBX

	MOV		EBX, origPrompt
	MOV		prompt, EBX
	_start:
	mGetString	prompt, lengthMax, inputNum, byteNum ;get string
	CLD
	MOV sign,0
	MOV EBX, origPrompt
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
			LEA		EBX, tempPrev   ;MAKE THIS A LOCAL VARIABLE IN Convert? Take it out here
			PUSH	EBX				;4 byte register
			LEA     EBX, errorMes
			PUSH	EBX				;4 byte register
			CALL	Convert
			JO	 _errorMSG
			CMP		errorMes, 1
			JE		_errorMSG
			JMP  _store
		_errorMSG:
			MOV		EBX, errTryAgain
			MOV		prompt, EBX ;sets error prompt
			XOR     EBX,EBX
			MOV     errorMes, EBX
			MOV		countNum, EBX
			MOV     prevNum, EBX
			MOV		tempPrev, EBX
			JMP _start

		_store:
			MOV		EAX, tempPrev
			MOV		prevNum, EAX ;stores the number as prevNum so we can progress
			INC		countNum
		_end:
	LOOP _conversionLoop

	MOV  EDI, correctNum ;address for corrNum
	MOV	 [EDI], EAX ;moves the corrected number in to address for the variable corrNum in main

	POPAD ;pop all directoreis
	RET		24
ReadVal	ENDP

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
	MOV		[EDI],EBX
	XOR		EAX,EAX
	MOV		tempNum, 0
	_convert:
			MOV		EAX, current
			SUB		EAX, 48
			MOV		EBX, sign2
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
			MOV		EAX, previousNum
			CMP		EAX, MIN
			JL		_error
			CMP		EAX, MAX
			JG		_error
			MOV		EBX, 10
			IMUL	EBX
			ADD		EAX, subNum
			JMP		_store
			_error:
			MOV	EDI, errorMes
			MOV EBX, 1
			MOV [EDI], EBX
			XOR EBX,EBX

			JMP _end
			_store:
			MOV EDI, outNumAddr
			MOV [EDI], EAX
			_end:
	POPAD
	RET 20
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

		PUSHAD

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
		MOV		ECX, 12
		LEA		EBX, newString
		MOV		EDI, EBX
		CLD
		REP     STOSB
		MOV		byteQuotient, 0
	

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
		CMP		ECX, 1
		JE		_writeSingleLoop
		_writeMultipleLoop:
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
			LOOP _writeMultipleLoop
			JMP _postLoop
		_writeSingleLoop:
			MOV EAX, newNum
			ADD EAX, 48
			MOV [EDI], EAX
			ADD EDI, 1
			MOV EAX, 0
		_postLoop:			
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
			;ADD ANOTHER WRITE USING STOSB AND REVERSING STRING TO CREATE FORWARDS STRING FOR WRITING?
		  ; Reverse the string
	_loopReversal:
	  MOV	 ECX, 0
	  MOV    ECX, numDigits
	  LEA    ESI, revString 
	  ADD    ESI, ECX
	  DEC    ESI
	  LEA    EDI, newString;SHOULD THIS BE STORED IN arrayAddress? MAYBE MAYBE NOT
	  MOV	EAX, 0	
	  MOV newString, 0
	  ;   Reverse string
	_revLoop: ;this isn't working
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