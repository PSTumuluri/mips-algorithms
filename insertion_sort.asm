# Sort a list of 5 integers.

.data
A: .word 3, 4, 5, 2, 1
size: .word 5

.text
main:

la $s0, A
la $s1, size

# $s2 points to the original location of the element being inserted.
# $t0 contains its index (offset).
# $t1 contains the number of elements in A.
addi $s2, $s0, 4
li $t0, 1
lw $t1, 0($s1)
outerloop: beq $t0, $t1, endouter
    # $t2 stores the value of the current element.
    lw $t2, 0($s2)

    # Loop backward to find the right insertion point.
    move $t3, $s2
    addi $t3, $t3, -4
    # Break if we fall out of the array.
    innerloop: blt $t3, $s0, endinner
	# t4 stores the value of the comparison element.
	lw $t4, 0($t3)

	# Break if we found the correct spot.
	bge $t2, $t4, endinner

        # Otherwise, shift the current element to the right.
	sw $t4, 4($t3)

        # Move pointer backward to prepare the next comparison.
	addi $t3, $t3, -4

        j innerloop
    endinner:

    # Insert the element after the cursor.
    sw $t2, 4($t3)

    addi $t0, $t0, 1
    addi $s2, $s2, 4
    j outerloop
endouter:

# Print the sorted array
la $t6, A
li $t7, 0
loop: beq $t7, $t1 exitloop
    lw $t8, 0($t6)
    li $v0, 1
    move $a0, $t8
    syscall

    addi $t7, $t7, 1
    addi $t6, $t6, 4
    j loop
exitloop:

li $v0, 10
syscall
