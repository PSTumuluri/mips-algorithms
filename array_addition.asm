.data
A: .word 1, 2, 3, 4
B: .word 2, 4, 6, 8
C: .space 16 # 4 integers
length: .word 4

.text
main:

# Load all memory addresses
la $s0, A
la $s1, B
la $s2, C
la $s3, length

lw $t0, 0($s3) # Array length
li $t1, 0      # Loop counter

loop: beq $t1, $t0, exitloop
	lw $t2, 0($s0)
	lw $t3, 0($s1)
	add $t4, $t2, $t3
	sw $t4, 0($s2)

	# Print result
	li $v0, 1
	move $a0, $t4
	syscall
	
	# Increment pointers and loop counter
	addi $t1, $t1, 1
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	addi $s2, $s2, 4

	j loop

exitloop:
li $v0, 10
syscall
