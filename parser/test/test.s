  .pos 0
  irmovq Stack,%rsp
  call main
  halt
main:
  irmovq Char,%r1
  irmovq $680,%r2
  irmovq $8,%r3
  irmovq $1,%r4
  irmovq $5,%r5
  orq %r5,%r5
  jmp test
loop:
  mrmovq 0(%r1),%r6
  mrmovq 0(%r2),%r7
  rmmovq %r6,0(%r2)
  rmmovq %r7,0(%r1)
  addq %r3,%r1
  subq %r3,%r2
  subq %r4,%r5
test:
  jne loop
  ret
  .pos 400
Stack:
  .pos 600
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
