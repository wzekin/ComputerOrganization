  .pos 0
  irmovq $200,%rsp
  call main
  halt
main:
  irmovq $1,%r1
  irmovq $2,%r2
  addq %r1,%r2
  ret
  .pos 200
Stack:
