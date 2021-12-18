TITLE String Primitives and Macros     (Proj6_grahamol.asm)

; Author:	Oliver Graham
; Last Modified:	6/6/2021
; OSU email address: grahamol@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:	6             Due Date:	6/6/2021
; Description:	This program reads 10 character arrays (strings) of user input, validated to be digits 0 though 9, and
;				converts each character array into an integer. It stores these 10 integers in an array of its own.
;				The sum of the 10 integers and their average are calculated. Next, the integer array is converted to a
;				character array, one integer at a time, and displayed. Finally, the sum and average of the numbers are conveted
;				to character arrays and displayed.

INCLUDE Irvine32.inc

; ---mGetString---
; Displays a passed string reference parameter, and calls ReadString to get user input.
; Preconditions: Data segment identifiers and mDisplayString macro must exist.
;				 Don't use EAX, ECX, or EDX as arguments.
; Postconditions: None
; Receives: Parameters prompt, userInput.
; Returns: User input as a string and the number of bytes written as output parameters.
mGetString MACRO prompt, userInputBuffer, bytesRead
	PUSH	EAX	
	PUSH	ECX
	PUSH	EDX

	; Display prompt.
	mDisplayString	prompt

	; Get user input.
	MOV		EDX, userInputBuffer			
	MOV		ECX, INPUT_MAX_LENGTH
	Call	ReadString	
	
	; Save values in output parameters.
	MOV		userInputBuffer, EDX	
	MOV		[bytesRead], EAX
	
	POP		EDX
	POP		ECX
	POP		EAX
ENDM

; ---mGetString---
; Displays passed string reference parameter.
; Receives: reference to string as parameter.
mDisplayString MACRO outputString
	PUSH	EDX
	MOV		EDX, outputString
	Call	WriteString
	POP		EDX
ENDM

	MAXIMUM_DIGITS		 = 10		; more than 10 digits in a single number will exceed the limit of a 32-bit register
	INPUT_MAX_LENGTH	 = 30		; to account for a several leading zeros or leading space characters
	
	; Pertinent ascii codes.
	MINUS_SIGN			 = 2Dh		; '-'
	PLUS_SIGN			 = 2Bh		; '+'
	LOWEST_IN_RANGE		 = 30h		; '0'
	HIGHEST_IN_RANGE	 = 39h		; '9'

	HEX_TO_DIGIT_CONVERSION_VALUE = 30h

	LARGEST_INTEGER		 = 2147483647	; 7FFFFFFFh
	SMALLEST_INTEGER	 = -2147483648  ; 80000000h 

.data
	programName				BYTE	" --------- String Primitives and Macros --------- ", 0	
	myName					BYTE	"Author: Oliver Graham", 13, 10, 13, 10, 0

	extraCreditOption1		BYTE	"**EC1: Displays line numbers next to user input. ", 13, 10, 13, 10, 0

	explainProgramInteger	BYTE	"You will be asked to enter 10 signed (positive or negative) decimal integers, one at a time.", 13, 10,
									"Each number must be small enough to fit in a 32-bit register and should not contain more than 10 digits.", 13, 10,
									"After input is finished, the integers themselves, their sum and their average value will be displayed.", 13, 10, 13, 10, 0							

	integerPrompt			BYTE	". Please enter a signed integer: ", 0

	userInput				BYTE	INPUT_MAX_LENGTH DUP(?)	
	bytesRead				BYTE	?
	
	errorMessage			BYTE	"Error! Your input was invalid. Please try again.", 13, 10, 0		

	userNumbersMessage		BYTE	13, 10, "Here are all the valid numbers you entered:", 13, 10, 0
	sumMessage				BYTE	13, 10, 13, 10, "The sum of the numbers is: ", 0
	averageMessage			BYTE	13, 10, "The rounded average of the numbers is: ", 0
	farewellMessage			BYTE	13, 10, 13, 10, "Thank you for using this program. Goodbye!", 13, 10, 13, 10, 0

	commaChar				BYTE	',',0
	spaceChar				BYTE	' ',0

	sumOfNumbers			SDWORD	?
	averageOfNumbers		SDWORD	?

	integerElement			SDWORD	?
	integerArray			SDWORD	10 DUP(?)

	; For extra credit 1:
	subtotalMessage			BYTE	"Subtotal: ", 0
	subtotalOfNumbers		SDWORD	?
	newLine					BYTE	13, 10, 0	

.code
main PROC

	; Display introductions.
	mDisplayString OFFSET programName
	mDisplayString OFFSET myName
	mDisplayString OFFSET extraCreditOption1
	mDisplayString OFFSET explainProgramInteger

	; Parameters for readVal.
	; These can be pushed outside the loop, instead of every pass through the loop.	
	PUSH	OFFSET newLine
	PUSH	OFFSET subtotalMessage
	PUSH	OFFSET errorMessage
	PUSH	OFFSET integerPrompt
	PUSH	OFFSET userInput			; remnants of user input will remain at this address, but the null-terminated
										; byte left by ReadString prevents the old information from being used
	PUSH	OFFSET bytesRead

	MOV		ECX, 1						; while ECX < 11
	MOV		EDI, OFFSET integerArray	; this will store the values returned from readVal

_readValLoop:
	
	; These three parameters are updated each pass through the loop and deferenced each call to readVal.
	; On final pass, readVal will dereference all parameters on the stack.	
	PUSH	EDI
	PUSH	OFFSET subtotalOfNumbers
	PUSH	ECX
	Call	readVal		

	; Increment to next position in array.
	ADD		EDI, TYPE integerArray
	
	INC		ECX			
	CMP		ECX, 11
	JNE		_readValLoop

	; Prepare for output loop.
	mDisplayString	OFFSET userNumbersMessage
	MOV		ESI, OFFSET integerArray
	MOV		ECX, 0						; while ECX < 10

_writeValLoop:

	; Pass value of current element in array, display the value and increment the array.
	PUSH	[ESI]
	Call	writeVal
	ADD		ESI, TYPE integerArray

	; Don't write a comma and space after the last output value.
	CMP		ECX, 9
	JE		_lastTimeNoComma

	mDisplayString	OFFSET commaChar
	mDisplayString	OFFSET spaceChar

_lastTimeNoComma:

	INC		ECX			
	CMP		ECX, 10
	JNE		_writeValLoop

	; Next, get the sum of the numbers and display.
	PUSH	OFFSET sumOfNumbers
	PUSH	OFFSET integerArray
	Call	getSum

	mDisplayString	OFFSET sumMessage
	PUSH	[sumOfNumbers]
	Call	writeVal

	; Find the average of the numbers and display.
	PUSH	OFFSET averageOfNumbers
	PUSH	[sumOfNumbers]
	PUSH	LENGTHOF integerArray
	Call	getAverage

	mDisplayString	OFFSET averageMessage
	PUSH	[averageOfNumbers]
	Call	writeVal

	; Bye bye!
	mDisplayString	OFFSET farewellMessage

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---readVal---
; Converts a string of characters into an integer and keeps a running subtotal of the integers that have been converted.
; Preconditions: Data segment identifiers, mGetString macro and constants must exist.
; Postconditions: Converted integer is added to location in passed-array.
; Receives: Parameters subtotalMessage, errorMessage, integerPrompt, userInput, bytesRead,
;			reference to a location in an array, an output reference (subtotalOfNumbers) and an input integer by value (ECX from main).
; Returns: An output reference integer.
readVal PROC
	LOCAL	counterFromMain:	BYTE	; used to determine how many bytes to deference at end of procedure	
	LOCAL	currentChar:		SDWORD	; will help with building the integer value later on	
	LOCAL	signByte:			BYTE	
	
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI
	
	MOV		signByte, 0				; if user enters a negative sign, this will be updated

	JMP		_tryToGetString

_errorMessageBeforeMoreInput:
	
	; If user entered only a negative sign, signByte needs to be reset.
	MOV		signByte, 0

	; Write condescending error message (just kidding!)
	mDisplayString [EBP + 32]

_tryToGetString:

	; display counter from main using writeVal. This shows the current line number (number of valid inputs).
	PUSH	[EBP + 8]
	Call	WriteVal

	; Parameters are: prompt, userInputBuffer and bytesRead
	mGetString [EBP + 28], [EBP + 24], [EBP + 20]

	; Number of bytes read from user.
	MOV		EBX, [EBP + 20]
	CMP		EBX, 0							; none? no good
	JE		_errorMessageBeforeMoreInput
	
	MOV		ESI, [EBP + 24]		; userInput; returned from macro filled with input
	MOV		EAX, 0				; clear register for subsequent string primitive operations
	CLD							; will be moving forward in array	

	; Every time a character from the string has been read, decrement EBX.
	; If the user entered zero, comparing EBX to 0 will prevent
	; a following loop from discarding it.
	LODSB
	DEC		EBX		

	CMP		EBX, 0
	JE		_prepareForConversion
	
_potentialSignByte:
	
	; If input starts with either a plus sign or minus sign, it's valid.
	CMP		AL, BYTE PTR PLUS_SIGN
	JE		_skipSignByte

	CMP		AL, BYTE PTR MINUS_SIGN
	JNE		_discardLeadingZerosAndSpacesLoop
	
	; Input contains a negative sign.
	MOV		signByte, 1		

_skipSignByte:

	; Move past the byte representing the number's sign.
	LODSB
	DEC		EBX

_discardLeadingZerosAndSpacesLoop:		

	; If EBX is zero, then all irrelevant leading characters
	; have been observed and will be ignored.
	CMP		EBX, 0
	JE		_prepareForConversion
	
	; If zero character, move forward in array and go to top of loop.
	CMP		AL, '0'
	JE		_skipCharacter

	; Check for spaces as well.
	CMP		AL, ' '
	JNE		_prepareForConversion
		
_skipCharacter:

	LODSB
	DEC		EBX

	JMP		_discardLeadingZerosAndSpacesLoop

_prepareForConversion:

	MOV		ECX, 0			; could loop to the MAX_DIGITS (10) limit
	MOV		EDX, 0			; EDX will keep running total, to build integer from string
	MOV		EBX, 10			; Part of the conversion process will be multiplying by 10. This is EBX's function in the loop.
	
_charToDigitLoop:

	; If out of range, the character isn't a number 0-9; discard and get another string.
	CMP		AL, BYTE PTR LOWEST_IN_RANGE
	JL		_errorMessageBeforeMoreInput

	CMP		AL, BYTE PTR HIGHEST_IN_RANGE
	JG		_errorMessageBeforeMoreInput
	
	; Subtract 30h to convert character into its numerical equivalaent.
	SUB		AL, BYTE PTR HEX_TO_DIGIT_CONVERSION_VALUE		

	; Presever character; EAX is needed for the multiplication.
	MOV		currentChar, EAX
	MOV		EAX, EDX			; EDX holds the running total of the calculations
	MUL		EBX					; EAX *= 10

	; If multiplication set the overflow flag, the number is invalid. If the state of the flag
	; is not observed at this point, the following the addition could alter the number in strange ways.
	JO		_errorMessageBeforeMoreInput	

	; After multiplication, add current character from the user-input-array to continue building integer.
	; Note: It's possible this addition will take the number past its upper or lower limit; this will be detected
	;		by later conditionals. 
	ADD		EAX, currentChar	

	MOV		EDX, EAX			; EDX is ready for next calculation

	; Clear register and get next character in array.
	MOV		EAX, 0
	LODSB							

	CMP		AL, 0				; is null? End of string
	JE		_stringIsValid

	; If loop goes more than 10 times, the converted number could not fit into a 32-bit register.
	INC		ECX
	CMP		ECX, MAXIMUM_DIGITS
	JA		_errorMessageBeforeMoreInput

	JMP		_charToDigitLoop

_stringIsValid:

	; First check whether the number is intended to be a negative number or not.
	CMP		signByte, 1						
	JNE		_checkUpperLimit

	; After the compare, the jump tests the condition of the zero flag and the carry flag. 
	; If both flags are cleared after the compare, 
	; EDX would be turned into too-small a negative number, and would thus be invalid.
	CMP		EDX, SMALLEST_INTEGER
	JNBE	_errorMessageBeforeMoreInput

	; Subtract value in EDX from zero in order to get the negative version of the number.
	MOV		EAX, EDX
	MOV		EDX, 0
	SUB		EDX, EAX

	JMP		_writeToOutputValue

_checkUpperLimit:

	; If EDX is larger than this constant, it is too large and invalid.	
	CMP		EDX, LARGEST_INTEGER
	JO		_errorMessageBeforeMoreInput

_writeToOutputValue:

	; Place output parameter in register and store converted value.
	MOV		EBX, [EBP + 16]
	MOV		[EBX], EDX

	; The subtotalOfNumbers parameter is passed to each call of readVal.
	; Add the integer value, newly-constructed from user input, to the output subtotal parameter.
	MOV		EAX, 0
	MOV		EAX, [EBP + 12]
	ADD		[EAX], EDX

	MOV		EDX, [EBP + 36]		; subtotal message
	mDisplayString	EDX

	; Pass the subtotal to writeVal for display.	
	PUSH	[EAX]
	Call	writeVal

	MOV		EDX, 0
	MOV		EDX, [EBP + 40]		; new line
	mDisplayString	EDX
	
	; Use to observe current iteration of loop from main.
	MOV		ECX, [EBP + 8]
	MOV		counterFromMain, CL

	POP		EDI
	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	; If this is the last time readVal is being called, deference all parameters in order to maintain stack-alignment.
	CMP		counterFromMain, 11						
	JE		_dereferenceAllParameters

	RET 12		

_dereferenceAllParameters:

	RET 36

readVal ENDP

; ---writeVal---
; Converts an integer into a string of characters, which it then displays.
; Preconditions: Data segment identifiers, mDisplayString macro and constants must exist.
; Postconditions: None
; Receives: An integer value input parameter as an SDWORD.
; Returns: Nothing
writeVal PROC
	LOCAL	tempSource[12]:			BYTE	; byte array to preserve contents of ESI
	LOCAL	tempDestination[12]:	BYTE	; same, but for EDI. They're 12 bytes in order to accommodate a null-terminated byte
	LOCAL	isNegative:				BYTE	; boolean value to determine if writing a minus sign char is necessary
	
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI
	PUSH	EDI

	MOV		isNegative, 0

	; Use local variables to create new, safe addresses for ESI and EDI.
	; Their 4-byte contents must first be cleared (all bytes zero)
	; in order to make room for the correct value to write later. Otherwise,
	; part of the byte array could contain irrelevant data and print some nonsensical value.
	MOV		AL, 0
	MOV		ECX, 11					; longest possible string, including the minus sign
	LEA		EDI, tempDestination
	REP		STOSB
	LEA		EDI, tempDestination	; return starting address to EDI

	MOV		ECX, 11
	LEA		ESI, tempSource
_clearESILoop:	

	MOV		[ESI], AL
	INC		ESI

	DEC		ECX
	CMP		ECX, 0
	JNE		_clearESILoop
	LEA		ESI, tempSource

	MOV		EAX, [EBP + 8]			; value to write	
	MOV		EBX, 10					; loop will use EBX to divide EAX by 10

	CMP		EAX, 0					; if the value to write is less than 0
	JGE		_convertNumberToString

	MOV		isNegative, 1			; it's negative, turn into 2's complement
	NOT		EAX						; invert bits
	INC		EAX						; add 1

_convertNumberToString:

	; Divide EAX by 10. EDX will then contain the right-most digit from the integer.
	MOV		EDX, 0
	DIV		EBX

	; Add 30h to translate the number to its character representation.
	ADD		EDX, HEX_TO_DIGIT_CONVERSION_VALUE
	
	; Add character to array. 
	; When finished, this array will be in reverse-order of user input.
	MOV		[ESI], DL
	INC		ESI
	INC		ECX						; keep track of number of bytes in array
	
	CMP		EAX, 0
	JNE		_convertNumberToString

	; Go back to last byte in ESI from null-terminated byte.
	DEC		ESI
	
	CMP		isNegative, 1				; if negative
	JNE		_reorderLoop

	MOV		AL, BYTE PTR MINUS_SIGN		; store minus-sign character in EDI
	STOSB

_reorderLoop:

	; ECX is number bytes to write, from the first non-null
	; at the end of ESI, into the front of EDI.
	STD
	LODSB
	CLD
	STOSB

	DEC		ECX
	CMP		ECX, 0
	JNE		_reorderLoop

	; Place pointer at beginning of array and display.
	LEA		EDI, tempDestination
	mDisplayString	EDI				

	POP		EDI
	POP		ESI	
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	RET 4
writeVal ENDP

; ---getSum---
; Adds values in array to calculate their sum.
; Preconditions: Array should contain numbers.
; Postconditions: None
; Receives: Input reference to array of numbers, and an output reference for returning the sum.
; Returns: The sum of the numbers in an output reference parameter.
getSum PROC
	PUSH	EBP
	MOV		EBP, ESP

	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	MOV		ESI, [EBP + 8]		; array
	MOV		ECX, 10				; loop 10 times
	MOV		EBX, TYPE ESI		; increment array by this amount
	MOV		EAX, 0				; accumulate sum in EAX
	
_sumLoop:

	; Get number from array and add to EAX.
	ADD		EAX, [ESI]

	ADD		ESI, EBX			; next number
	DEC		ECX
	JNZ		_sumLoop

	MOV		EBX, [EBP + 12]		; output reference
	MOV		[EBX], EAX

	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX	

	POP		EBP

	RET 8
getSum ENDP

; ---getAverage---
; Calculates the average of a sum of numbers. Truncates any remainder from the division.
; Preconditions: Data segment identifiers and constants must exist.
; Postconditions: None
; Receives: Sum of numbers as input parameter, the length of the array the sum was calculated from,
;			and an output reference parameter to return the average.
; Returns: Output reference parameter containing the average of the numbers.
getAverage PROC
	PUSH	EBP
	MOV		EBP, ESP

	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	ESI

	MOV		EAX, [EBP + 12]		; sum of numbers in the array
	MOV		EBX, [EBP + 8]		; length of array
	MOV		EBX, 10				; divide by 10 (amount of numbers)
	CDQ							; sign-extend into EDX 

	IDIV	EBX

	; Save average of numbers into output reference parameter.
	MOV		ECX, [EBP + 16]
	MOV		[ECX], EAX

	POP		ESI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX		

	POP		EBP

	RET 12
getAverage ENDP

END main
