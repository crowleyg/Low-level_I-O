TITLE Project 6- String Primitives and Macros     (Proj6_crowleyg.asm)

; Author: Garrett Crowley
; Last Modified: 12/03/2021
; OSU email address: crowleyg@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:    6             Due Date: 12/5/2021
; Description: The program will prompt user to enter 10 signed decimal numbers returning an error message if outside range.
; Program will then store the values in an array as strings. It will then display the list of strings to console.
; After, it will convert the strings back to ints and use these ints to calculate sum and average and convert them back
; to strings before displaying.

INCLUDE Irvine32.inc

; (insert macro definitions here)

;-----------------------------------------------------------------------------------------------------------
; Name: mGetString
; Displays a prompt for user input. Gets input and stores both input and input count in memory locations.
; Preconditions: Required arguments must be present
; Postconditions: None
; Receives: 
;	param_1 = prompt to be displayed by reference
;	param_2 = inString by reference
;	param_3 = MAXSIZE by value
;	param_4 = lengthInput by reference
; Returns: lengthInput and userInput changed
;-----------------------------------------------------------------------------------------------------------
	mGetString		MACRO	param_1:REQ, param_2:REQ, param_3:REQ, param_4:REQ
		push	EDX
		push	ECX
		push	EAX

		mDisplayString	[param_1]
		mov		EDX, param_2
		mov		ECX, param_3
		call	ReadString
		mov		param_4, EAX

		pop		EAX
		pop		ECX
		pop		EDX
	ENDM

;-----------------------------------------------------------------------------------------------------------
; Name: mDisplayString
; Displays string provided by reference to console.
; Preconditions: Required arguments must be present
; Postconditions: None
; Receives: 
;	param_1 = string to be displayed by reference
; Returns: None
;-----------------------------------------------------------------------------------------------------------
	mDisplayString	MACRO	param_1:REQ
		push	EDX
		mov		EDX, param_1
		call	WriteString
		pop		EDX
	ENDM

; (insert constant definitions here)

	MAXSIZE	 =	13

.data
; (insert variable definitions here)
	header1			BYTE	"Project 6- String Primitives and Macros     By:Garrett Crowley",13,10,0
	rules1			BYTE	"Please provide 10 signed decimal integers. I will then display the list of integers with their sum and average.",13,10,0
	prompt1			BYTE	"Please enter a signed number:  ",0
	inString		BYTE	MAXSIZE DUP(?)
	lengthInput		DWORD	?
	numArray		SDWORD	10 DUP(?)
	convertedNum	SDWORD	0
	errorMsg1		BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10
	errorMsg2		BYTE	"Please try again:  ",0
	negNum			SDWORD	0		; 0 indicates positive, 1 indicates negative
	firstRound		SDWORD	0		; helps load array for writing
	newString		BYTE	MAXSIZE DUP(?)
	listTitle		BYTE	"You entered the following numbers:  ",13,10,0
	sumTitle		BYTE	"The sum of these numbers is:  ",0
	avgTitle		BYTE	"The average of these numbers is:  ",0
	commaSpace		BYTE	", ",0
	listSum			SDWORD	0
	listAvg			SDWORD	?


.code
main PROC

; introduce program and instructions
	push	offset rules1
	push	offset header1
	call	introduction	

; get 10 valid integers from user
	mov		ECX, 10
_GetData:
	push	offset negNum
	push	offset prompt1
	push	offset inString
	push	offset lengthInput
	push	offset errorMsg1
	push	offset convertedNum
	call	ReadVal	
		
	cmp		firstRound, 0
	jne		_BuildArray

; store first value in array
	mov		EAX, offset numArray
	mov		EBX, convertedNum
	mov		[EAX], EBX
	add		EAX, 4
	inc		firstRound
	jmp		_ClearConv

; store subsequent values in array 
_BuildArray:
	mov		EBX, convertedNum
	mov		[EAX], EBX
	add		EAX, 4

; clear convertedNum
_ClearConv:
	push	EAX
	mov		EAX, offset convertedNum
	mov		EBX, 0
	mov		[EAX], EBX
	pop		EAX

	loop	_GetData

; display list of integer title
	push	offset listTitle
	call	TitleDisplay

; display list of integers
	mov		ESI, offset numArray
	mov		ECX, 10
_DisplayLoop:
	push	offset negNum
	push	offset newString
	mov		EAX, [ESI]
	push	EAX
	call	WriteVal
;---------------------------------------------------------------
;	new string is cleared in this manner in order to prevent
;	remaining bits from being attatched to output before running
;	WriteVal again
;----------------------------------------------------------------
; clear newString	
	push	ECX
	mov		EDI, offset newString
	mov		ECX, MAXSIZE
	mov		al, 0
	rep		stosb
	pop		ECX

	push	offset commaSpace
	call	TitleDisplay			;add a comma and space between nums
	add		ESI, 4
	loop	_DisplayLoop
	call	CrLf
; display sum of integers
	push	offset sumTitle
	call	TitleDisplay	

	push	offset negNum
	push	offset newString
	push	offset listSum
	push	offset numArray
	call	SumList
	call	CrLf

; clear newString	
	push	ECX
	mov		EDI, offset newString
	mov		ECX, MAXSIZE
	mov		al, 0
	rep		stosb
	pop		ECX

; display average of integers
	push	offset avgTitle
	call	TitleDisplay 

	push	offset negNum
	push	offset newString
	push	offset listAvg
	push	offset listSum
	call	AvgList	
	call	CrLf
	

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

;----------------------------------------------------------------------------
; name: introduction
; introduces the program with title, name and rules
; receives: [EBP+8] = offset header1, [EBP+12] = offset rules1
;-----------------------------------------------------------------------------
introduction PROC
	push	EBP
	mov		EBP, ESP

; display name and program title 
	mDisplayString	[EBP+8]
	call	CrLf

; display program rules
	mDisplayString	[EBP+12]
	call	CrLf
	
	pop		EBP
	ret		8
introduction ENDP

;-----------------------------------------------------------------------------------------
; name: ReadVal
; Gets user input via mGetString. Converts string of ascii to numeric value representation
; and validates. Stores converted value in memory.
; receives: MAXSIZE, [EBP+24]=prompt1, [EBP+20]=inString, [EBP+16] = lengthInput, 
;	[EBP+12] = errorMsg1, [EBP+8] = convertedNum, [EBP+28]= negNum
; returns: numeric value in convertedNum
;-----------------------------------------------------------------------------------------
ReadVal PROC
	push	EBP
	mov		EBP, ESP
	pushad	

; reset negNum 
	mov		ECX, [EBP+28]
	mov		EAX, 0
	mov		[ECX], EAX


; get user input in form of string
	mGetString [EBP+24], [EBP+20], MAXSIZE, [EBP +16]
	jmp		_LengthChk

; decrement ECX in event of sign present
_decCounter:
	mov		ECX, [EBP+16]
	dec		ECX
	jmp		_Sign

; string not valid. Trigger Error and reprompt
_Error:
	mGetString [EBP+12], [EBP+20], MAXSIZE, [EBP +16]		;prompt changed to error message

; check for length
_LengthChk:
	mov		EBX, [EBP+16]
	mov		EAX, 0
	cmp		EBX, EAX
	je		_Error
	mov		EAX, 11
	cmp		EBX, EAX
	ja		_Error				;greater than 10 vals

; check for sign
_SignChk:
	mov		ESI, [EBP+20]
	mov		bl, "+"
	LODSB
	cmp		AL, bl			
	je		_decCounter
	mov		bl, "-"
	cmp		AL, bl
	jne		_Setup			;when no sign present, ESI must be reset 
	mov		EAX, 1
	mov		[ECX], EAX		
	jmp		_decCounter


; setup counter and source/destination
_Setup:	
	mov		ESI, [EBP+20]
	mov		ECX, [EBP+16]
_Sign:
	mov		EDI, [EBP+8]

; convert and validate user input
_Convert:
	LODSB
	mov		BL,	48
	cmp		AL, BL
	jl		_Error
	mov		BL, 57
	cmp		AL, BL
	jg		_Error
	mov		EDX, [EBP+8]
	mov		EBX, [EDX]
	IMUL	EBX, 10
	mov		EDX, EBX
	sub		AL, 48
	movzx	EBX, AL
	ADD		EDX, EBX
	mov		[EDI], EDX
	loop	_Convert

; two's compliment negation for negative value
	mov		EBX, 1
	mov		EAX, [EBP+28]
	cmp		[EAX], EBX
	jne		_Finished
	neg		EDX
	mov		[EDI], EDX

_Finished:
	popad
	pop		EBP
	ret		24
ReadVal ENDP

;------------------------------------------------------------------------------------------
; name: WriteVal
; Converts SDWORD value to string of ascii digits. Invokes mDisplayString to print ascii 
; representation of value to the output.
; preconditions: numeric SDWORD values are provided
; receives: [EBP+8] = numeric value to be converted and displayed, [EBP+12] = newString, [EBP+16] = negNum
;------------------------------------------------------------------------------------------
WriteVal PROC
	push	EBP
	mov		EBP, ESP
	pushad

; reset negNum and newString
	mov		ECX, [EBP+16]
	mov		EAX, 0
	mov		[ECX], EAX

	mov		ECX, [EBP+12]
	mov		EAX, 0
	mov		[ECX], EAX

; Setup for IDIV and load counter
	mov		ECX, 0
	mov		EDI, [EBP+12]
	mov		EBX, [EBP+8]
	mov		EAX, EBX
	mov		EBX, 10
	cmp		EAX, 0
	jl		_NegSign
	jmp		_DivLoop

; convert negative to positive and save sign
_NegSign:
	neg		EAX
	mov		EDX, [EBP+16]
	mov		ESI, 1
	mov		[EDX], ESI

; convert numeric val to string of ascii by dividing by 10 repeatedly
_DivLoop:
	mov		EDX, 0
	CDQ
	idiv	EBX
	push	EDX
	inc		ECX
	cmp		EAX, 0
	jne		_DivLoop

_AddNeg:
	mov		EDX, [EBP+16]
	mov		ESI, [EDX]
	mov		EDX, 0
	cmp		ESI,EDX 
	je		_PopLoop
	mov		AL, 45
	STOSB

; pop all values into string
_PopLoop:						;ECX holds counter already
	pop		EAX
	ADD		EAX, 48
	STOSB		
	loop	_PopLoop

; display to console
	mDisplayString [EBP+12]
	


	popad
	pop		EBP
	ret		12
WriteVal ENDP

;----------------------------------------------------------------------------
; name: TitleDisplay
; displays title
; receives: [EBP+8] = title to be displayed
;-----------------------------------------------------------------------------
TitleDisplay PROC
	push	EBP
	mov		EBP, ESP
	pushad

; display title
	mDisplayString	[EBP+8]

	popad
	pop		EBP
	ret		4
TitleDisplay ENDP

;----------------------------------------------------------------------------
; name: SumList
; sums the values in the provided list
; receives: [EBP+8] = list containing values, [EBP+12] = listSum, [EBP+16] = newString, [EBP+20] = negNum
; returns: sum in listSum
;-----------------------------------------------------------------------------
SumList PROC
	push	EBP
	mov		EBP, ESP
	pushad

; assign loop counter and input/output
	mov		ECX, 10
	mov		ESI, [EBP+8]
	mov		EDI, [EBP+12]
	mov		EBX, [EDI]

; add numbers continuously and increment ESI
_SumLoop:
	mov		EAX, [ESI]
	add		EBX, EAX
	add		ESI, 4
	loop	_SumLoop

; preserve sum in listSum
	mov		[EDI], EBX 

; display sum
	push	[EBP+20]		;offset negNum
	push	[EBP+16]		;offset newString
	push	EBX
	call	WriteVal


	popad
	pop		EBP
	ret		16
SumList ENDP

;----------------------------------------------------------------------------
; name: AvgList
; averages the values in the provided list
; receives: [EBP+8] = listSum, [EBP+12] = listAvg, [EBP+16] = newString, [EBP+20] = negNum
; returns: avg in listAvg
;-----------------------------------------------------------------------------
AvgList PROC
	push	EBP
	mov		EBP, ESP
	pushad

; assign input/output
	mov		ESI, [EBP+8]
	mov		EDI, [EBP+12]

; calculate avg
	mov		EAX, [ESI]
	mov		EDX, 0
	mov		ECX, 10
	CDQ
	IDIV	ECX

; preserve avg
	mov		[EDI], EAX 

; display avg
	push	[EBP+20]		;offset negNum
	push	[EBP+16]		;offset newString
	push	EAX
	call	WriteVal


	popad
	pop		EBP
	ret		16
AvgList ENDP

END main
