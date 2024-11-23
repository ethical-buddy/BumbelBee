
out/bootblockother.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000007000 <start>:
#   - it uses the address at start-4, start-8, and start-12

.code16           
.globl start
start:
  cli            
    7000:	fa                   	cli    

  xorw    %ax,%ax
    7001:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds
    7003:	8e d8                	mov    %eax,%ds
  movw    %ax,%es
    7005:	8e c0                	mov    %eax,%es
  movw    %ax,%ss
    7007:	8e d0                	mov    %eax,%ss

  lgdt    gdtdesc
    7009:	0f 01 16             	lgdt   (%rsi)
    700c:	6c                   	insb   (%dx),%es:(%rdi)
    700d:	70 0f                	jo     701e <start+0x1e>
  movl    %cr0, %eax
    700f:	20 c0                	and    %al,%al
  orl     $CR0_PE, %eax
    7011:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7015:	0f 22 c0             	mov    %rax,%cr0

//PAGEBREAK!
  ljmpl    $(SEG_KCODE<<3), $(start32)
    7018:	66 ea                	data16 (bad) 
    701a:	20 70 00             	and    %dh,0x0(%rax)
    701d:	00 08                	add    %cl,(%rax)
	...

0000000000007020 <start32>:

.code32
start32:
  movw    $(SEG_KDATA<<3), %ax
    7020:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds
    7024:	8e d8                	mov    %eax,%ds
  movw    %ax, %es
    7026:	8e c0                	mov    %eax,%es
  movw    %ax, %ss
    7028:	8e d0                	mov    %eax,%ss
  movw    $0, %ax
    702a:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs
    702e:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs
    7030:	8e e8                	mov    %eax,%gs

#if X64
  # defer paging until we switch to 64bit mode
  # set ebx=1 so shared boot code knows we're booting a secondary core
  mov     $1, %ebx
    7032:	bb 01 00 00 00       	mov    $0x1,%ebx
  orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
  movl    %eax, %cr0
#endif

  # Switch to the stack allocated by startothers()
  movl    (start-4), %esp
    7037:	8b 25 fc 6f 00 00    	mov    0x6ffc(%rip),%esp        # e039 <_end+0x6fc1>
  # Call mpenter()
  call	 *(start-8)
    703d:	ff 15 f8 6f 00 00    	callq  *0x6ff8(%rip)        # e03b <_end+0x6fc3>

  movw    $0x8a00, %ax
    7043:	66 b8 00 8a          	mov    $0x8a00,%ax
  movw    %ax, %dx
    7047:	66 89 c2             	mov    %ax,%dx
  outw    %ax, %dx
    704a:	66 ef                	out    %ax,(%dx)
  movw    $0x8ae0, %ax
    704c:	66 b8 e0 8a          	mov    $0x8ae0,%ax
  outw    %ax, %dx
    7050:	66 ef                	out    %ax,(%dx)

0000000000007052 <spin>:
spin:
  jmp     spin
    7052:	eb fe                	jmp    7052 <spin>

0000000000007054 <gdt>:
	...
    705c:	ff                   	(bad)  
    705d:	ff 00                	incl   (%rax)
    705f:	00 00                	add    %al,(%rax)
    7061:	9a                   	(bad)  
    7062:	cf                   	iret   
    7063:	00 ff                	add    %bh,%bh
    7065:	ff 00                	incl   (%rax)
    7067:	00 00                	add    %al,(%rax)
    7069:	92                   	xchg   %eax,%edx
    706a:	cf                   	iret   
	...

000000000000706c <gdtdesc>:
    706c:	17                   	(bad)  
    706d:	00 54 70 00          	add    %dl,0x0(%rax,%rsi,2)
	...
