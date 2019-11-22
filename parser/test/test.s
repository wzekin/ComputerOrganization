  .pos 0
  irmovq Stack,%rsp
  call main
  halt
main:
  irmovq Char,%r1
  irmovq NewChar,%r2
  irmovq $8,%r3
  irmovq $1,%r4
  irmovq $11,%r5
  orq %r5,%r5
  jmp test
loop:
  mrmovq 0(%r1),%r6
  rmmovq %r6,0(%r2)
  addq %r3,%r1
  addq %r3,%r2
  subq %r4,%r5
test:
  jne loop
  ret
  .pos 400
Stack:
  .pos 600
NewChar:
  .pos 800
Char:
  .quad 104
  .quad 101
  .quad 108
  .quad 108
  .quad 111
  .quad 32
  .quad 119
  .quad 111
  .quad 114
  .quad 108
  .quad 100
