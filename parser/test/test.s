.pos 0
  irmovq Stack,%rsp
  out %rsp
  call main
  halt
main:
  irmovq $1,%r1
  irmovq $1,%r2
loopa:
  addq %r2,%r1
  jmp loopa
  ret
.pos 200
Stack:
.pos 300
interupt:
  irmovq $400,%r1
  mrmovq 0(%r1),%r2
  irmovq $0,%r5
  subq %r5,%r2
  irmovq $2,%r5
  jmp testb
loopb:
  mrmovq 400(%r2),%r6
  subq %r5,%r2
  out %r6
testb:
  jne loopb
  iret
.pos 350
interupt1:
  irmovq $400,%r1
  irmovq $1024,%r5
  mrmovq 0(%r1),%r2
  mrmovq 0(%r5),%r4
  irmovq $2,%r3
  addq %r3,%r2
  rmmovq %r2,0(%r1)
  addq %r2,%r1
  rmmovq %r4,0(%r1)
  out %r4
  iret
