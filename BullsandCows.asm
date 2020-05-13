.data
wordCount:	.word 403 # Should be number of words in file - easylist = 403, hardlist = 5454
		.align 2
chosenWord:	.asciiz "    " # Will contain the randomly chosen word
filePath:	.asciiz "easylist.txt"
		.align 2
NumberPrompt:	.asciiz	"Please enter a 4 Letter Word: "
AnswerPrompt2:	.asciiz " is "
Welcome1: .asciiz "Cows and Bulls\n"
GiveUpOpt: .asciiz "If you want to give up, enter [2]\n"
GiveUpMsg: .asciiz "You gave up.\n"
WordChosenPrompt: .asciiz "\nA 4 char all capital word has been chosen!\n"
Guess0: .asciiz "Please enter a four-letter Word with no repetitions(Should be Captial):\n"
	.align 2
UserGuess: .space 64
BaseString: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
PReturn: .asciiz "\n"
Answer: .space 64
RepititionErrorMsg: .asciiz "\nYour guess contained repeating characters.\n"
MenuErrorMsg: .asciiz "\nIt appears an invalid option was selected.\n"
InputRangeError: .asciiz "\nIt appears a non-capital character was given.\n"
ScoreOut1: .asciiz "\nYour guess has "
ScoreOut2: .asciiz " has "
header:		.asciiz "Guess   Result"		# 8 spaces apart
		.align 2		# align for accessing next words
eightspaces: 	.asciiz "        "
		.align 2		# align for accessing next words
bull:		.asciiz "Bull and" 
		.align 2		# align for accessing next words
bulls:		.asciiz "Bulls and" 
		.align 2		# align for accessing next words
cow:		.asciiz "Cow.\n"
		.align 2		# align for accessing next words
cows:		.asciiz "Cows.\n"	
		.align 2		# align for accessing next words
newLine:	.asciiz "\n"
		.align 2		# align for accessing next words
guessHeader:	.asciiz "Guess"
		.align 2		# align for accessing next words
sevenspaces: 	.asciiz "       "
		.align 2		# align for accessing next words
singlespace: 	.asciiz " "
		.align 2
giveUpMsg:	.asciiz "The chosen word was: "
		.align 2
congrats:	.asciiz "\nCongratulations! You guessed correctly."
		.align 2		# align for accessing next words
TooShortMsg: 	.asciiz "\nYour guess contains too few characters\n"
		.align 2		# align for accessing next words
TooLongMsg: 	.asciiz "\nYour guess contains too many characters\n"
		.align 2		# align for accessing next words
timeTaken1:	.asciiz "\nYou tosok "
		.align 2		# align for accessing next words
timeTaken2:	.asciiz " seconds trying to guess the word\n"
		.align 2
	.text
#Choose a random word from the file.
chooseWord:
	# Allocate memory
	lw $a0, wordCount
	sll $a0, $a0, 3 # $a0 now contains number of bits needed for array
	li $v0, 9 # Allocate memory syscall
	syscall # $v0 now contains the address of the allocated memory
	move $s0, $v0
	
	# Load file
	la $a0, filePath
	li $a1, 0 # Reading flag
	li $a2, 0 # Ignore mode
	li $v0, 13 # Open file syscall
	syscall # $v0 now contains the file descriptor
	
	blt $v0, 0, end # Stop if error (file descriptor negative)
	
	# Read file
	move $a0, $v0 # Put file descriptor in $a0
	move $a1, $s0 # Put location of array into $a1
	lw $a2, wordCount # Amount of words to read
	sll $a2, $a2, 2 # Amount of letters to read
	li $v0, 14 # Read from file syscall
	syscall
	
	# Close file
	li $v0, 16 # Close file syscall
	syscall
	
	# Get a random number from 0 to (wordCount - 1)
	lw $a1, wordCount
	li $v0, 42 # Random int range syscall
	syscall
	sll $a0, $a0, 2 # Multiply by 4 (can now be used as array offset)
	
	move $t0, $s0 # $t0 now contains the start of the word array
	addu $t0, $t0, $a0 # Add the random offset
	lw $t1, ($t0) # Put the randomly chosen word in $t1
	
 	#turn all the letters in the chosen word capital. extract each char, apply an offset of 32 to get capital eq. and shift to combine later
	#Also, check each character to make sure the chosen word doesn't contain repeating characters.
	andi $t2, $t1, 0x00FF
	subi $t2, $t2, 0x20
	
	srl $t1, $t1, 8
	andi $t3, $t1, 0x00FF
	subi $t3, $t3, 0x20
	beq $t3, $t2, chooseWord
	
	srl $t1, $t1, 8
	andi $t4, $t1, 0x00FF
	subi $t4, $t4, 0x20
	beq $t4, $t2, chooseWord
	beq $t4, $t3, chooseWord
	
	srl $t1, $t1, 8
	andi $t5, $t1, 0x00FF
	subi $t5, $t5, 0x20
	beq $t5, $t2, chooseWord
	beq $t5, $t3, chooseWord
	beq $t5, $t4, chooseWord
	
	#combine each char
	sll $t3, $t3, 8
	add $t1, $t2, $t3
	sll $t4, $t4, 16
	add $t1, $t1, $t4
	sll $t5, $t5, 24
	add $t1, $t1, $t5
	sw $t1, chosenWord
	
	
main:
	la $t0, Welcome1	#Loading address of prompt to display
	la $t9, PReturn		#Loading this in $t9 for quick carriage return printing
	li $v0, 4		#Syscall value for print string
	add $a0, $t0, $zero	#loading address of $t0 to $a0
	syscall			#Syscall to print spring
	
	
	jal checkTime		#get the time before starting the game
	add $s0, $a0, $zero 	#save the initial results
	add $s1, $a1, $zero
	jal ShowMenu		#Show the menu options
	
GameLoop:
	li $v0, 4
	la $t0, Guess0
	add $a0, $t0, $zero
	syscall
	la $t0, GiveUpOpt
	add $a0, $t0, $zero
	syscall
	li $v0, 8
	la $a0, UserGuess
	li $a1, 64
	syscall			#storing string in UserGuess
#	and $t0, $t0, 0xFFFF	#take off the LR/CR from the UserGuess
	la $t0, UserGuess	
	
	#error checking
	la $t0, UserGuess
	
	lb $t1, ($t0)		#setting 0th bit to t1
	lb $t2, 1($t0)		#setting 1st bit to t2
	lb $t3, 2($t0)		#setting 2nd bit to t3
	lb $t4, 3($t0)		#setting 3rd bit to t4
	
	li $t6, 0x0A		#set to ascii val. of LF
	
	
	#First, check for option 2 --> means the user is giving up
GiveUpCheck:
	beq $t1, 0x32, GiveUp
	# if (A>=65)&&(Z<=90)
FirstCheck:
	beq $t1, $t6, TooShort
	addi $t5, $zero, 65
	blt $t1, $t5, UserInputError
	addi $t5, $zero, 90
	ble $t1, $t5, SecondCheck
	j UserInputError
FirstFix:
	sub $t1, $t1, 32
	
SecondCheck:
	beq $t2, $t6, TooShort
	addi $t5, $zero, 65
	blt $t2, $t5, UserInputError
	addi $t5, $zero, 90
	ble $t2, $t5, ThirdCheck
	j UserInputError
SecondFix:
	sub $t2, $t2, 32
	
ThirdCheck:
	beq $t3, $t6, TooShort
	addi $t5, $zero, 65
	blt $t3, $t5, UserInputError
	addi $t5, $zero, 90
	ble $t3, $t5, FourthCheck
	j UserInputError
ThirdFix:
	sub $t3, $t3, 32
	
FourthCheck:
	beq $t4, $t6, TooShort
	addi $t5, $zero, 65
	blt $t4, $t5, UserInputError
	addi $t5, $zero, 90
	ble $t4, $t5, FifthCheck
	j UserInputError
FourthFix:
	sub $t4, $t4, 32
	
FifthCheck:
	lb $t5, 4($t0)		#setting 4th bit to t5
#	addi $t5, $zero, 0
#	blt $t5, $t5, UserInputError
#	addi $t5, $zero, 0
	beq $t5, $t6, RepititionCheck
	bne $t5, $zero, TooLong
	j UserInputError

RepititionCheck:
	beq $t1, $t2, RepititionError
	beq $t1, $t3, RepititionError
	beq $t1, $t4, RepititionError
	beq $t2, $t3, RepititionError
	beq $t2, $t4, RepititionError
	beq $t3, $t4, RepititionError
	j AfterCheck
	
TooShort:
	li $v0, 4
	la $a0, TooShortMsg
	syscall
	j GameLoop
TooLong:
	li $v0, 4
	la $a0, TooLongMsg
	syscall
	j GameLoop
RepititionError:
	li $v0, 4
	la $a0, RepititionErrorMsg
	syscall	
	j GameLoop



#AfterCheck: the stirng can now be passed on for evaluation of bulls and cows
AfterCheck:
		
	#la $t0, UserGuess
	#sb $t1, ($t0)		#setting 0th bit to t1
	#sb $t2, 1($t0)		#setting 1st bit to t2
	#sb $t3, 2($t0)		#setting 2nd bit to t3
	#sb $t4, 3($t0)		#setting 3rd bit to t4
	#lb $t5, 4($t0)
	
	lw $a0, UserGuess
	lw $a1, chosenWord
	jal computeBullsAndCows		#compute the number of bulls and cows.
	addi $a2, $v0, 0  		#print the results of the guess
	addi $a3, $v1, 0
	jal printCompResult
	j GameLoop			#repeat!!!
#	li $v0, 4		#print string
#	add $a0, $t0, $zero
#	syscall
	


	
UserInputError:
	li $v0, 4
	la $t0, InputRangeError
	add $a0, $t0, $zero
	syscall
	j GameLoop



ShowMenu:
	li $v0, 4
	la $t0, WordChosenPrompt
	add $a0, $t0, $zero
	syscall
	#la $a0, UserGuess
	
	j GameLoop  		#starting the game
	addi $t0,$zero,50	#For exit
	bne $t1, $t0, MenuError	#if they didn't choose any valid menu options print error message and go back to the menu
	
GiveUp:
	li $v0, 4
	la $a0, GiveUpMsg
	syscall			
end:	jal checkTime		#get the time before ending the program
	add $s2, $a0, $zero 	#save the final results
	add $s3, $a1, $zero
	
	sub $a0, $s2, $s0	#display how much time was taken. Subtract off the parts and then take sum. This gives you the mseconds. convert to seconds
	li $t8, 1000
	div $a0, $t8
	li $v0, 4
	la $a0, timeTaken1
	syscall
	mflo $a0
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, timeTaken2
	syscall
	li $v0, 10		#exits the program
	syscall
	
MenuError:
	li $v0, 4
	la $t0, MenuErrorMsg
	add $a0, $t0, $zero
	syscall
	
	j ShowMenu



#------------------------------------------------------------------------------------------------Evaluating bulls and cows part.

# a0--> guess, a1 --> chosen word, a2 --> # bulls, a3 --> # cows
printCompResult:	
		li $v0, 4				# print the headers	
		la $a0, header
		syscall	
		li $v0, 4		
		la $a0, newLine
		syscall
		li $v0, 4				# print the guess	
		la $a0, UserGuess
		syscall		
		li $v0, 4				
		la $a0, eightspaces
		syscall			
		addi $a0, $a2, 0  			# print # of bulls
		li $v0, 1 				
		syscall		
		la $a0, singlespace			# print a space
		li $v0, 4 				
		syscall	
		beq $a2, 1, loadBull			# print 'Bull and' or 'Bulls and'
		bne $a2, 1, loadBulls
printBull:	li $v0, 4 				
		syscall	
		la $a0, singlespace			# print a space
		li $v0, 4 				
		syscall		
		addi $a0, $a3, 0			# print # of cows
		li $v0, 1 				
		syscall
		la $a0, singlespace			# print a space
		li $v0, 4 				
		syscall
		beq $a3, 1, loadCow			# print 'Cows.' or 'Cow.'
		bne $a3, 1, loadCows
printCow:	li $v0, 4 				
		syscall
		#if 4 bulls, the guess was correct --> display congratulatory message																
		beq $a2, 4, correctGuess 
		jr $ra					#return to wherever the procedure was called
		
loadBull:	la $a0, bull
		j printBull
loadBulls:	la $a0, bulls
		j printBull
loadCow:	la $a0, cow
		j printCow
loadCows:	la $a0, cows
		j printCow
correctGuess:	la $a0, congrats
		li $v0, 4 				
		syscall
		j end
		

# approaches for bulls and cows computing algorithhm
# approach 1: build a map of character positions and chars at those positions.
# a0 contains guess, a1 contains chosen word.
# iterative subroutine that uses lb to get a single char from the guess, and checks it with all of the characters in the chosen word
# use sll or srl to get trim off a character you looked at.

# a0 --> guess, a1 --> chosen word  
#return: v0 --> # bulls, v1 --> # cows
computeBullsAndCows:
		li $v0, 0 					#reset return values
		li $v1, 0
		#t0 and t1 represent the substrings of guess and chosen word, respectively
		#t2 and #t3 represent the positions of guess and chosen word where the char's being compared are --> used to bound the outer and inner loop
		#t4 and t5 represent the chars of guess and chosen word being compared
		addi $t0, $a0, 0 				# set subsrtings to a0 and a1 --> original values
		addi $t1, $a1, 0
		li $t2, 0 					#init counters with zero
		li $t3, 0
guessLoop:	addi $t2, $t2, 1
		andi $t4, $t0, 0x00FF				#extract first char (8 bits) from t0 by performing an AND mask
		add $t5, $t5, $t1				#reset chosen word before entering the loop
	chosenWordLoop:	addi $t3, $t3, 1
			andi $t5, $t1, 0x00FF 		#extract first char from t1
			beq $t4, $t5, charMatch		#increment cow or bull if a char match is found
			srl $t1, $t1, 8			#trim off the portion
			bne $t3, 4, chosenWordLoop	
incReturn:	li $t3, 0				#reset counter in inner loop
		addi $t1, $a1, 0
		srl $t0, $t0, 8
		bne $t2, 4, guessLoop 
		li $t2, 0				#reset counter in outer loop
		jr $ra
#redirect to increment bull if a match. Otherwise increment cow
charMatch:	beq $t2, $t3, bullInc
		addi $v1, $v1, 1
		j incReturn
bullInc:	addi $v0, $v0, 1
		j incReturn
	
	

#---------------------------------------------------------------------------------------------return the time in 
checkTime:
	li $v0, 30		#a0 --> low-order, a1 --> high-order
	syscall
	jr $ra
	
	
exit:
	


	
	

