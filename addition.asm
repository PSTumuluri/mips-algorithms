# This program adds two numbers.

.data
a: .word 5
x: .word 10
sum: .space 4

.text
main:
la $s0, a
la $s1, x
la $s2, sum

lw $t0,0($s0)
lw $t1,0($s1)

add $s4, $t0, $t1
sw $s4,0($s2)

# Print the sum after storing it
li $v0, 1
move $a0, $s4
syscall

li $v0, 10
syscall
