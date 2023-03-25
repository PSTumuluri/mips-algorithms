.data
A: .word 1, 3
length: .word 2

.text
main:
la $s0, A
li $s1, 0
lw $s2, length

move $a0, $s0
move $a1, $s1
addi $a2, $s2, -1
jal merge_sort

move $a1, $s2
jal print_array

li $v0, 10
syscall

merge_sort:
# Sorts a subarray in monotonic increasing order
# $a0 is the pointer to the array
# $a1 is the start index, p
# $a2 is the end index, r

# If start >= end, we have no more than 1 element to sort and are therefore done
slt $t0, $a1, $a2
beq $t0, $zero, return_merge_sort

addi $sp, $sp, -16
sw $a1, 0($sp)
sw $a2, 4($sp)
sw $a3, 8($sp)
sw $ra, 12($sp)

# $a3 is the index of the partition q = floor((p + r) / 2)
add $a3, $a1, $a2
srl $a3, $a3, 1

# merge_sort(A, p, q)
move $a2, $a3
jal merge_sort
lw $a2, 4($sp)

# merge_sort(A, q+1, r)
addi $a1, $a3, 1
jal merge_sort
lw $a1, 0($sp)

# merge(A, p, r, q)
jal merge

cleanup_merge_sort:
# Restore argument and address registers, and pop the stack
lw $a1, 0($sp)
lw $a2, 4($sp)
lw $a3, 8($sp)
lw $ra, 12($sp)
addi $sp, $sp, 16

return_merge_sort: jr $ra



merge:
# Merges two sorted subarrays into a larger sorted subarray.
# $a0 is the pointer to the array
# $a1 is the start index, p
# $a2 is the end index, r
# $a3 is the "middle" index, q, so that A[p:q] is the lower partition,
#     and A[q+1:r] is the upper partition

# Allocate two new arrays L and R on the stack to store the left-
# and right-hand sides of the partition, respectively.
# L has size q-p+1 and R has size r-q

# $t0 stores the size of L
# $t1 stores the size of R
sub $t0, $a3, $a1
addi $t0, $t0, 1
sub $t1, $a2, $a3

# $t2 stores L.length + R.length (i.e. the length of A[p:r], r-p+1)
add $t2, $t0, $t1

# $t4 stores the address of R on the stack
sll $t6, $t1, 2
sub $sp, $sp, $t6
move $t4, $sp
# t3 stores the address of L on the stack
sll $t6, $t0, 2
sub $sp, $sp, $t6
move $t3, $sp

# Copy the elements from A[p:r] in to L and R.
# Since these halves are obviously contiguous in the original array,
# and since I made them contiguous in the stack, we can do all of it in
# one loop. Terminate when we have processed all r-p+1 elements.

# $t5 points to the location of current item in the original array, originally A + p
sll $t5, $a1, 2
add $t5, $t5, $a0
move $t6, $t3 # $t6 points to the place to insert the item in the stack
li $t7, 0     # $t7 counts the number of elements we have copied
copy_loop: beq $t7, $t2, copy_done
lw $t8, 0($t5)
sw $t8, 0($t6)
addi $t5, $t5, 4
addi $t6, $t6, 4
addi $t7, $t7, 1
j copy_loop

copy_done:

# Compare the front elements of L and R and push the smaller one to A.
# Once we have exhausted one pile, simply burn through the other one.

# $t3 and $t4 already point to L and R in the stack, respectively
# $t5 points to the insertion point in A, originally A + p
sll $t5, $a1, 2
add $t5, $t5, $a0
merge_loop:
    # Keep track of how many elements from L and R remain to be merged by removing
    # elements from L and R as we merge them
    # If either pile becomes 0, we have exhausted that one and have to burn the other
    beq $t0, $zero, burn_right  # Remember that $t0 is the number of elements in L
    beq $t1, $zero, burn_left   # ... and $t1 is the number of elements in R

    lw $t6, 0($t3)  # $t6 is L[i]
    lw $t7, 0($t4)  # $t7 is R[j]

    # If L[i] <= R[j], take from L. Else, take from R.
    slt $t8, $t7, $t6
    bne $t8, $zero, take_right

    # take_left:
    sw $t6 0($t5)
    addi $t3, $t3, 4   # L = L + 1
    addi $t0, $t0, -1  # One less element in L
    j continue_merge
    take_right:
    sw $t7, 0($t5)
    addi $t4, $t4, 4   # R = R + 1
    addi $t1, $t1, -1  # One less element in R

    continue_merge:
    addi $t5, $t5, 4   # Move to next available slot in A
    j merge_loop

burn_left:
    # Keep going until we have exhausted L
    burn_left_loop: beq $t0, 0, merge_done
        lw $t6, 0($t3)
        sw $t6, 0($t5)
        addi $t3, $t3, 4
        addi $t0, $t0, -1
        addi $t5, $t5, 4
        j burn_left_loop
burn_right:
    # Keep going until we have exhausted R
    burn_right_loop: beq $t1, 0, merge_done
        lw $t7, 0($t4)
        sw $t7, 0($t5)
        addi $t4, $t4, 4
        addi $t1, $t1, -1
        addi $t5, $t5, 4
        j burn_right_loop

merge_done:
# Deallocate the stack memory we used for L and R
sll $t2, $t2, 2
add $sp, $sp, $t2

jr $ra



print_array:
# Prints the contents of an array
# $a0 is the pointer to the array
# $a1 is the length of the array

# Copy $a0 and push its contents onto the stack 
# because we need register $a0 for printing.
# $t0 is the array pointer
move $t0, $a0
addi $sp, $sp, -4
sw $a0, 0($sp)

# $t1 is the index of the current element
li $t1, 0
print_loop: beq $t1, $a1, cleanup_print_array
    # $t2 is the current element being printed
    lw $t2, 0($t0)
    move $a0, $t2
    li $v0, 1
    syscall

    # Increment pointer and counter
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j print_loop

cleanup_print_array:
# Restore $a0 and pop the stack.
lw $a0, 0($sp)
addi $sp, $sp, 4

return_print_array: jr $ra
