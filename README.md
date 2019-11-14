# 做一个自己的CPU--计组

用来记录计组的作业思路

## 系统综述

* 指令架构采取边长指令集

* 系统指针长度为64位

* 用1byte寻址

* 有15个寄存器，分别为 $ r_1 - r_{14} $ 以及 $ rsp$ ，用4bit寻址

* 指令格式

  * A: [op] 占1字节
  * B: [op]:[ra]:[rb] 占2字节

  * C: [op]:[ra]:[rb]:[val] 占10字节
  * D: [op]:[val] 占9字节

## 1. 指令系统



| 类型         | 格式 | 指令   | OP   | 语法            | 意义               |
| ------------ | ---- | ------ | ---- | --------------- | ------------------ |
| 停机指令     | A    | halt   | 00   | halt            | 停机               |
| 空指令       | A    | nop    | 10   | nop             | 空                 |
| 数据移动指令 | C    | irmovq | 20   | irmovq $x,Rb    | 立即数移动到寄存器 |
|              | B    | rrmovq | 30   | rrmovq Ra,Rb    | 寄存器移动到寄存器 |
|              | C    | mrmovq | 40   | mrmovq x(Rb),Ra | 存储器移动到寄存器 |
|              | C    | rmmovq | 50   | rmmovq Ra,x(Rb) | 寄存器移动到存储器 |
| 整数操作指令 | B    | addq   | 61   | addq Ra,Rb      | 加法               |
|              | B    | subq   | 62   | subq Ra,Rb      | 减法               |
|              | B    | mulq   | 63   | mulq Ra,Rb      | 乘法               |
|              | B    | divq   | 64   | divq Ra,Rb      | 除法               |
|              | B    | andq   | 65   | andq Ra,Rb      | 与                 |
|              | B    | orq    | 66   | orq Ra,Rb       | 或                 |
|              | B    | xorq   | 67   | xorq Ra,Rb      | 异或               |
| 地址跳转指令 | D    | jmp    | 80   | jmp Dest        | 直接跳转           |
|              | D    | je     | 81   | ...             | 相等跳转           |
|              | D    | jne    | 82   | ...             | 不相等跳转         |
|              | D    | js     | 83   | ...             | 负数               |
|              | D    | jns    | 84   | ...             | 非负数             |
| 函数调用指令 | D    | call   | A0   | call Dest       |                    |
|              | A    | ret    | B0   | ret             |                    |

## 2. 数据通路图
![数据通路图](README.assets/%E5%8D%95%E6%80%BB%E7%BA%BF%E6%95%B0%E6%8D%AE%E9%80%9A%E8%B7%AF%E5%9B%BE.png)
## 3. 指令流程图

```mermaid
graph TD
a1["icode <- M[PC]"] --> a2{指令译码}

a2 --> g[整数操作指令]
g --> g1["Ra,Rb <- icode<br/>valP <- PC + 2"]
g1 --> g2["valA <- R[Ra]<br/>valB <- R[Rb]"]
g2 --> g3["ValE <- 结果<br/>Set CC"]
g3 --> g4[" "]
g4 --> g5["R[rB] <- valE"]
g5 --> g6["PC <- ValP"]

a2 --> b[mrmovq]
b --> b1["Ra,Rb <- icode<br/>valC <- icode<br/>valP <- PC + 10"]
b1 --> b2["valB <- R[rB]"]
b2 --> b3["ValE <- valB + valC"]
b3 --> b4["valM <- M[valE]"]
b4 --> b5["R[rA] <- valM"]
b5 --> b6["PC <- ValP"]

a2 --> c[irmovq]
c --> c1["Ra,Rb <- icode<br/>valC <- icode<br/>valP <- PC + 10"]
c1 --> c2[" "]
c2 --> c3["ValE <- 0 + valC"]
c3 --> c4[" "]
c4 --> c5["R[rB] <- valE"]
c5 --> c6["PC <- ValP"]

a2 --> d[rrmovq]
d --> d1["Ra,Rb <- icode<br/>valP <- PC + 2"]
d1 --> d2["valA <- R[Ra]"]
d2 --> d3["ValE <- 0 + valA"]
d3 --> d4[" "]
d4 --> d5["R[rB] <- valE"]
d5 --> d6["PC <- ValP"]

a2 --> e[rmmovq]
e --> e1["Ra,Rb <- icode<br/>valC <- icode<br/>valP <- PC + 10"]
e1 --> e2["valA <- R[Ra]<br/>valB <- R[Rb]"]
e2 --> e3["ValE <- valB + valC"]
e3 --> e4["M[valE] <- valA"]
e4 --> e5[" "]
e5 --> e6["PC <- ValP"]
```
``` mermaid
graph TD
a1["icode <- M[PC]"] --> a2{指令译码}



a2 --> c["地址跳转指令（JXX）"]
c --> c1["ValC <- icode<br/>ValP <- PC + 9"]
c1 --> c2[" "]
c2 --> c3["Cnd <- Cond(CC,icode)"]
c3 --> c4[" "]
c4 --> c5[" "]
c5 --> c6["PC <- Cnd?ValC,ValP"]

a2 --> d["地址跳转指令（call)"]
d --> d1["ValC <- icode<br/>ValP <- PC + 9"]
d1 --> d2["valB <- R[%rsp]"]
d2 --> d3["valE <- valB-8"]
d3 --> d4["M[valE] <- valP"]
d4 --> d5["R[%rsp] <- valE"]
d5 --> d6["PC <-valC"]

a2 --> e["地址跳转指令（ret)"]
e --> e1["ValP <- PC + 1"]
e1 --> e2["valA <- R[%rsp]<br/>valB <- R[%rsp]"]
e2 --> e3["valE <- valB+8"]
e3 --> e4["valM <- M[valA]"]
e4 --> e5["R[%rsp] <- valE"]
e5 --> e6["PC <-valM"]

a2 --> f["空指令（nop）"]
f --> f1["valP <- PC + 1"]
f1 --> f2[" "]
f2 --> f3[" "]
f3 --> f4[" "]
f4 --> f5[" "]
f5 --> f6["PC <- ValP"]

a2 --> g["停机指令（halt）"]
g --> g1{停机}

```

## 汇编器

* 用于将汇编语言转化成二进制代码，供verilog读写
* 使用rust的nom库编写