
out/initcode.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <start>:


# exec(init, argv)
.globl start
start:
  mov $init, %rdi
   0:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
  mov $argv, %rsi
   7:	48 c7 c6 00 00 00 00 	mov    $0x0,%rsi
  mov $SYS_exec, %rax
   e:	48 c7 c0 07 00 00 00 	mov    $0x7,%rax
  int $T_SYSCALL
  15:	cd 40                	int    $0x40

0000000000000017 <exit>:

# for(;;) exit();
exit:
  mov $SYS_exit, %rax
  17:	48 c7 c0 02 00 00 00 	mov    $0x2,%rax
  int $T_SYSCALL
  1e:	cd 40                	int    $0x40
  jmp exit
  20:	eb f5                	jmp    17 <exit>

0000000000000022 <init>:
  22:	2f                   	(bad)  
  23:	69 6e 69 74 00 00 0f 	imul   $0xf000074,0x69(%rsi),%ebp
  2a:	1f                   	(bad)  
	...

000000000000002c <argv>:
	...
