#############################################################################################
#
# Malik Jabati & Montek Singh
# COMP 541 Final Projects
# Apr 25, 2018
#
#
# This program assumes the memory-IO map introduced in class specifically for the final
# projects.  In MARS, please select:  Settings ==> Memory Configuration ==> Default.
#
Top of the stack is set at the word address
# [0x100100fc - 0x100100ff], giving a total of 64 locations for data and stack together.
# If you need larger data memory than 64 words, you will have to move the top of the stack
# to a higher address.
#
#############################################################################################
#
#############################################################################################


.data 0x10010000 			# Start of data memory
speed:	.word 500

.text 0x00400000			# Start of instruction memory
main:
	lui	$sp, 0x1001		# Initialize stack pointer to the 64th location above start of data
	ori 	$sp, $sp, 0x0100	# top of the stack is the word at address [0x100100fc - 0x100100ff]  


## Wait for key press			
key_loop:	
	jal 	get_key			# get a key (if available)
	beq	$v0, $0, key_loop	# 0 means no valid key
	
key1:
	bne	$v0, 1, key2
	j start
	
key2:
	bne	$v0, 2, key3
	j start
	
key3:
	bne	$v0, 3, key_loop
	
	li	$a0, 0x0000		#Reset LEDS
	jal	put_leds		#Display LEDs
	
	addi	$s3, $0, 500
	sw	$s3, speed($0)
	j	key_loop

## Start code	
start:
	li	$s0, 0			# initialize to P1 first screen col (X=0)
	li	$s1, 39			# initialize to P2 first screen col (X=39)
	li	$a2, 15			# initialize to middle screen row (Y=15)
	lw	$s3, speed($0)		#init level speed


animate_loop:
	addi	$a1, $s0, 0		# load P1 location back into $a1	
	li	$a0, 2			# draw character 2 here
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	addi	$a1, $s1, 0		# load P2 location back into $a1	
	li	$a0, 3			# draw character 3 here
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	add	$a0, $0, $s3		# pause for speed of level
	jal	pause
	# nop
	
	
	##can't use more than 4 characters???
	#addi	$a1, $s0, 0		# load P1 location back into $a1
	#li	$a0, 4			# overwrite with character 4 here
	#jal	putChar_atXY
	
	#addi	$a1, $s1, 0		# load P2 location back into $a1
	#li	$a0, 5			# overwrite with character 5 here
	#jal	putChar_atXY	
	
	addi 	$s0, $s0, 1 		# increment col for P1
	addi	$s1, $s1, -1		# decrement col for P1	
	
	slti 	$t0, $s0, 20 		# still on left?  col < 20?
	bne	$t0, $0, animate_loop	# restart loop	

	addi 	$s0, $s0, -1 		# backtrack one step for P1
	addi	$s1, $s1, 1		# backtrack one step for P2

	addi	$a1, $s0, 0		# load P1 location back into $a1
	li	$a0, 0			# overwrite with character 0 here
	jal	putChar_atXY
	
	addi	$a1, $s1, 0		# load P2 location back into $a1
	li	$a0, 0			# overwrite with character 0 here
	jal	putChar_atXY
	
	li	$a0, 382219		#add sound period
	jal	put_sound		#play sound
	
key_detect:
	jal 	get_key			# get a key (if available)
	beq	$v0, $0, key_detect	# 0 means no valid key
	
key_d1:
	bne	$v0, 1, key_d2
	
	jal	sound_off		#sound off
	
	li	$a0, 0xFF00		#LEDS for P1
	jal	put_leds		#Display LEDs
	
	li	$a0, 2			#left player
	li	$a1, 0			#ready cols for win
	li 	$a2, 12			#ready rows for win
	j	win

key_d2:
	bne	$v0, 2, key_detect
	
	jal	sound_off		#sound off
	
	li	$a0, 0x00FF		#LEDS for P2
	jal	put_leds		#Display LEDs
	
	li	$a0, 3			#right player
	li	$a1, 0			#ready cols for win
	li 	$a2, 12			#ready rows for win
	j	win

win:
	j	win_x
	
win_y:
	addi	$a2, $a2, 1
	addi	$s5, $0, 19
	li	$a1, 0			#reset x counter
	bne	$a2, $s5, win_x
	
	li	$a0, 1000		# pause for 10 seconds
	jal	pause
	
	li	$a1, 0			#ready cols for clean
	li 	$a2, 12			#ready rows for clean
	j	clean

win_x:
	jal	putChar_atXY
	addi	$a1, $a1, 1
	addi	$s4, $0, 40
	bne	$a1, $s4, win_x
	j	win_y
	
clean:
	j	clean_x_black
	
clean_y:
	addi	$a2, $a2, 1
	addi	$s5, $0, 19
	li	$a1, 0			#reset x counter
	bne	$a2, $s5, clean_x_black
	
	##add some stuff
	li	$a1, 0			#ready cols for clean
	li 	$a2, 12			#ready rows for clean
	j	restart_logic

clean_x_black:
	li	$a0, 0			#load black
	jal	putChar_atXY
	addi	$a1, $a1, 1
	addi	$s4, $0, 15
	addi	$s6, $0, 40		#once you reach end, go back to program counter
	beq	$a1, $s6, clean_y
	bne	$a1, $s4, clean_x_black
	j	clean_x_white
	
clean_x_white:
	li	$a0, 1
	jal	putChar_atXY
	addi	$a1, $a1, 1
	addi	$s5, $0, 25
	bne	$a1, $s5, clean_x_white
	j	clean_x_black
	

restart_logic:
	sra	$s3, $s3, 1		#increase play speed
	sw	$s3, speed($0)
	slti	$t0, $s3, 10
	bne	$t0, $0, speed_10	#set speed to 10
	j	key_loop

speed_10:
	addi	$s3, $0, 10		#set speed to 100
	sw	$s3, speed($0)
	j	key_loop

	
		
					
	###############################
	# END using infinite loop     #
	###############################
end:
	j	end          	# infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################
	
	
######## END OF CODE #################################################################################

.include "procs_board.asm"