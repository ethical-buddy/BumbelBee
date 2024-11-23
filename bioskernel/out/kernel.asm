
out/kernel.elf:     file format elf64-x86-64


Disassembly of section .text:

ffffffff80100000 <begin>:
ffffffff80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%rax),%dh
ffffffff80100006:	01 00                	add    %eax,(%rax)
ffffffff80100008:	fe 4f 51             	decb   0x51(%rdi)
ffffffff8010000b:	e4 00                	in     $0x0,%al
ffffffff8010000d:	00 10                	add    %dl,(%rax)
ffffffff8010000f:	00 00                	add    %al,(%rax)
ffffffff80100011:	00 10                	add    %dl,(%rax)
ffffffff80100013:	00 00                	add    %al,(%rax)
ffffffff80100015:	b0 10                	mov    $0x10,%al
ffffffff80100017:	00 00                	add    %al,(%rax)
ffffffff80100019:	40 11 00             	rex adc %eax,(%rax)
ffffffff8010001c:	20 00                	and    %al,(%rax)
ffffffff8010001e:	10 00                	adc    %al,(%rax)

ffffffff80100020 <mboot_entry>:
  .long mboot_entry_addr

mboot_entry:

# zero 4 pages for our bootstrap page tables
  xor %eax, %eax
ffffffff80100020:	31 c0                	xor    %eax,%eax
  mov $0x1000, %edi
ffffffff80100022:	bf 00 10 00 00       	mov    $0x1000,%edi
  mov $0x5000, %ecx
ffffffff80100027:	b9 00 50 00 00       	mov    $0x5000,%ecx
  rep stosb
ffffffff8010002c:	f3 aa                	rep stos %al,%es:(%rdi)

# P4ML[0] -> 0x2000 (PDPT-A)
  mov $(0x2000 | 3), %eax
ffffffff8010002e:	b8 03 20 00 00       	mov    $0x2003,%eax
  mov %eax, 0x1000
ffffffff80100033:	a3 00 10 00 00 b8 03 	movabs %eax,0x3003b800001000
ffffffff8010003a:	30 00 

# P4ML[511] -> 0x3000 (PDPT-B)
  mov $(0x3000 | 3), %eax
ffffffff8010003c:	00 a3 f8 1f 00 00    	add    %ah,0x1ff8(%rbx)
  mov %eax, 0x1FF8

# PDPT-A[0] -> 0x4000 (PD)
  mov $(0x4000 | 3), %eax
ffffffff80100042:	b8 03 40 00 00       	mov    $0x4003,%eax
  mov %eax, 0x2000
ffffffff80100047:	a3 00 20 00 00 b8 03 	movabs %eax,0x4003b800002000
ffffffff8010004e:	40 00 

# PDPT-B[510] -> 0x4000 (PD)
  mov $(0x4000 | 3), %eax
ffffffff80100050:	00 a3 f0 3f 00 00    	add    %ah,0x3ff0(%rbx)
  mov %eax, 0x3FF0

# PD[0..511] -> 0..1022MB
  mov $0x83, %eax
ffffffff80100056:	b8 83 00 00 00       	mov    $0x83,%eax
  mov $0x4000, %ebx
ffffffff8010005b:	bb 00 40 00 00       	mov    $0x4000,%ebx
  mov $512, %ecx
ffffffff80100060:	b9 00 02 00 00       	mov    $0x200,%ecx

ffffffff80100065 <ptbl_loop>:
ptbl_loop:
  mov %eax, (%ebx)
ffffffff80100065:	89 03                	mov    %eax,(%rbx)
  add $0x200000, %eax
ffffffff80100067:	05 00 00 20 00       	add    $0x200000,%eax
  add $0x8, %ebx
ffffffff8010006c:	83 c3 08             	add    $0x8,%ebx
  dec %ecx
ffffffff8010006f:	49 75 f3             	rex.WB jne ffffffff80100065 <ptbl_loop>

# Clear ebx for initial processor boot.
# When secondary processors boot, they'll call through
# entry32mp (from entryother), but with a nonzero ebx.
# We'll reuse these bootstrap pagetables and GDT.
  xor %ebx, %ebx
ffffffff80100072:	31 db                	xor    %ebx,%ebx

ffffffff80100074 <entry32mp>:

.global entry32mp
entry32mp:
# CR3 -> 0x1000 (P4ML)
  mov $0x1000, %eax
ffffffff80100074:	b8 00 10 00 00       	mov    $0x1000,%eax
  mov %eax, %cr3
ffffffff80100079:	0f 22 d8             	mov    %rax,%cr3

  lgdt (gdtr64 - mboot_header + mboot_load_addr)
ffffffff8010007c:	0f 01 15 b0 00 10 00 	lgdt   0x1000b0(%rip)        # ffffffff80200133 <end+0xec133>

# Enable PAE - CR4.PAE=1
  mov %cr4, %eax
ffffffff80100083:	0f 20 e0             	mov    %cr4,%rax
  bts $5, %eax
ffffffff80100086:	0f ba e8 05          	bts    $0x5,%eax
  mov %eax, %cr4
ffffffff8010008a:	0f 22 e0             	mov    %rax,%cr4

# enable long mode - EFER.LME=1
  mov $0xc0000080, %ecx
ffffffff8010008d:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
ffffffff80100092:	0f 32                	rdmsr  
  bts $8, %eax
ffffffff80100094:	0f ba e8 08          	bts    $0x8,%eax
  wrmsr
ffffffff80100098:	0f 30                	wrmsr  

# enable paging
  mov %cr0, %eax
ffffffff8010009a:	0f 20 c0             	mov    %cr0,%rax
  bts $31, %eax
ffffffff8010009d:	0f ba e8 1f          	bts    $0x1f,%eax
  mov %eax, %cr0
ffffffff801000a1:	0f 22 c0             	mov    %rax,%cr0

# shift to 64bit segment
  ljmp $8,$(entry64low - mboot_header + mboot_load_addr)
ffffffff801000a4:	ea                   	(bad)  
ffffffff801000a5:	e0 00                	loopne ffffffff801000a7 <entry32mp+0x33>
ffffffff801000a7:	10 00                	adc    %al,(%rax)
ffffffff801000a9:	08 00                	or     %al,(%rax)
ffffffff801000ab:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

ffffffff801000b0 <gdtr64>:
ffffffff801000b0:	17                   	(bad)  
ffffffff801000b1:	00 c0                	add    %al,%al
ffffffff801000b3:	00 10                	add    %dl,(%rax)
ffffffff801000b5:	00 00                	add    %al,(%rax)
ffffffff801000b7:	00 00                	add    %al,(%rax)
ffffffff801000b9:	00 66 0f             	add    %ah,0xf(%rsi)
ffffffff801000bc:	1f                   	(bad)  
ffffffff801000bd:	44 00 00             	add    %r8b,(%rax)

ffffffff801000c0 <gdt64_begin>:
	...
ffffffff801000cc:	00 98 20 00 00 00    	add    %bl,0x20(%rax)
ffffffff801000d2:	00 00                	add    %al,(%rax)
ffffffff801000d4:	00                   	.byte 0x0
ffffffff801000d5:	90                   	nop
	...

ffffffff801000d8 <gdt64_end>:
ffffffff801000d8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
ffffffff801000df:	00 

ffffffff801000e0 <entry64low>:
gdt64_end:

.align 16
.code64
entry64low:
  movq $entry64high, %rax
ffffffff801000e0:	48 c7 c0 e9 00 10 80 	mov    $0xffffffff801000e9,%rax
  jmp *%rax
ffffffff801000e7:	ff e0                	jmpq   *%rax

ffffffff801000e9 <_start>:
.global _start
_start:
entry64high:

# ensure data segment registers are sane
  xor %rax, %rax
ffffffff801000e9:	48 31 c0             	xor    %rax,%rax
  mov %ax, %ss
ffffffff801000ec:	8e d0                	mov    %eax,%ss
  mov %ax, %ds
ffffffff801000ee:	8e d8                	mov    %eax,%ds
  mov %ax, %es
ffffffff801000f0:	8e c0                	mov    %eax,%es
  mov %ax, %fs
ffffffff801000f2:	8e e0                	mov    %eax,%fs
  mov %ax, %gs
ffffffff801000f4:	8e e8                	mov    %eax,%gs

# check to see if we're booting a secondary core
  test %ebx, %ebx
ffffffff801000f6:	85 db                	test   %ebx,%ebx
  jnz entry64mp
ffffffff801000f8:	75 11                	jne    ffffffff8010010b <entry64mp>

# setup initial stack
  mov $0xFFFFFFFF80010000, %rax
ffffffff801000fa:	48 c7 c0 00 00 01 80 	mov    $0xffffffff80010000,%rax
  mov %rax, %rsp
ffffffff80100101:	48 89 c4             	mov    %rax,%rsp

# enter main()
  jmp main
ffffffff80100104:	e9 0d 3b 00 00       	jmpq   ffffffff80103c16 <main>

ffffffff80100109 <__deadloop>:

.global __deadloop
__deadloop:
# we should never return here...
  jmp .
ffffffff80100109:	eb fe                	jmp    ffffffff80100109 <__deadloop>

ffffffff8010010b <entry64mp>:

entry64mp:
# obtain kstack from data block before entryother
  mov $0x7000, %rax
ffffffff8010010b:	48 c7 c0 00 70 00 00 	mov    $0x7000,%rax
  mov -16(%rax), %rsp
ffffffff80100112:	48 8b 60 f0          	mov    -0x10(%rax),%rsp
  jmp mpenter
ffffffff80100116:	e9 a8 3b 00 00       	jmpq   ffffffff80103cc3 <mpenter>

ffffffff8010011b <wrmsr>:

.global wrmsr
wrmsr:
  mov %rdi, %rcx     # arg0 -> msrnum
ffffffff8010011b:	48 89 f9             	mov    %rdi,%rcx
  mov %rsi, %rax     # val.low -> eax
ffffffff8010011e:	48 89 f0             	mov    %rsi,%rax
  shr $32, %rsi
ffffffff80100121:	48 c1 ee 20          	shr    $0x20,%rsi
  mov %rsi, %rdx     # val.high -> edx
ffffffff80100125:	48 89 f2             	mov    %rsi,%rdx
  wrmsr
ffffffff80100128:	0f 30                	wrmsr  
  retq
ffffffff8010012a:	c3                   	retq   

ffffffff8010012b <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
ffffffff8010012b:	55                   	push   %rbp
ffffffff8010012c:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010012f:	48 83 ec 10          	sub    $0x10,%rsp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
ffffffff80100133:	48 c7 c6 e0 95 10 80 	mov    $0xffffffff801095e0,%rsi
ffffffff8010013a:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff80100141:	e8 c7 59 00 00       	callq  ffffffff80105b0d <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
ffffffff80100146:	48 c7 05 b7 c4 00 00 	movq   $0xffffffff8010c5f8,0xc4b7(%rip)        # ffffffff8010c608 <bcache+0x1608>
ffffffff8010014d:	f8 c5 10 80 
  bcache.head.next = &bcache.head;
ffffffff80100151:	48 c7 05 b4 c4 00 00 	movq   $0xffffffff8010c5f8,0xc4b4(%rip)        # ffffffff8010c610 <bcache+0x1610>
ffffffff80100158:	f8 c5 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
ffffffff8010015c:	48 c7 45 f8 68 b0 10 	movq   $0xffffffff8010b068,-0x8(%rbp)
ffffffff80100163:	80 
ffffffff80100164:	eb 48                	jmp    ffffffff801001ae <binit+0x83>
    b->next = bcache.head.next;
ffffffff80100166:	48 8b 15 a3 c4 00 00 	mov    0xc4a3(%rip),%rdx        # ffffffff8010c610 <bcache+0x1610>
ffffffff8010016d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100171:	48 89 50 18          	mov    %rdx,0x18(%rax)
    b->prev = &bcache.head;
ffffffff80100175:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100179:	48 c7 40 10 f8 c5 10 	movq   $0xffffffff8010c5f8,0x10(%rax)
ffffffff80100180:	80 
    b->dev = -1;
ffffffff80100181:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100185:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%rax)
    bcache.head.next->prev = b;
ffffffff8010018c:	48 8b 05 7d c4 00 00 	mov    0xc47d(%rip),%rax        # ffffffff8010c610 <bcache+0x1610>
ffffffff80100193:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80100197:	48 89 50 10          	mov    %rdx,0x10(%rax)
    bcache.head.next = b;
ffffffff8010019b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010019f:	48 89 05 6a c4 00 00 	mov    %rax,0xc46a(%rip)        # ffffffff8010c610 <bcache+0x1610>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
ffffffff801001a6:	48 81 45 f8 28 02 00 	addq   $0x228,-0x8(%rbp)
ffffffff801001ad:	00 
ffffffff801001ae:	48 c7 c0 f8 c5 10 80 	mov    $0xffffffff8010c5f8,%rax
ffffffff801001b5:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff801001b9:	72 ab                	jb     ffffffff80100166 <binit+0x3b>
  }
}
ffffffff801001bb:	90                   	nop
ffffffff801001bc:	c9                   	leaveq 
ffffffff801001bd:	c3                   	retq   

ffffffff801001be <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
ffffffff801001be:	55                   	push   %rbp
ffffffff801001bf:	48 89 e5             	mov    %rsp,%rbp
ffffffff801001c2:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801001c6:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff801001c9:	89 75 e8             	mov    %esi,-0x18(%rbp)
  struct buf *b;

  acquire(&bcache.lock);
ffffffff801001cc:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff801001d3:	e8 6a 59 00 00       	callq  ffffffff80105b42 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
ffffffff801001d8:	48 8b 05 31 c4 00 00 	mov    0xc431(%rip),%rax        # ffffffff8010c610 <bcache+0x1610>
ffffffff801001df:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801001e3:	eb 6c                	jmp    ffffffff80100251 <bget+0x93>
    if(b->dev == dev && b->sector == sector){
ffffffff801001e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801001e9:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff801001ec:	39 45 ec             	cmp    %eax,-0x14(%rbp)
ffffffff801001ef:	75 54                	jne    ffffffff80100245 <bget+0x87>
ffffffff801001f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801001f5:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff801001f8:	39 45 e8             	cmp    %eax,-0x18(%rbp)
ffffffff801001fb:	75 48                	jne    ffffffff80100245 <bget+0x87>
      if(!(b->flags & B_BUSY)){
ffffffff801001fd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100201:	8b 00                	mov    (%rax),%eax
ffffffff80100203:	83 e0 01             	and    $0x1,%eax
ffffffff80100206:	85 c0                	test   %eax,%eax
ffffffff80100208:	75 26                	jne    ffffffff80100230 <bget+0x72>
        b->flags |= B_BUSY;
ffffffff8010020a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010020e:	8b 00                	mov    (%rax),%eax
ffffffff80100210:	83 c8 01             	or     $0x1,%eax
ffffffff80100213:	89 c2                	mov    %eax,%edx
ffffffff80100215:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100219:	89 10                	mov    %edx,(%rax)
        release(&bcache.lock);
ffffffff8010021b:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff80100222:	e8 f2 59 00 00       	callq  ffffffff80105c19 <release>
        return b;
ffffffff80100227:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010022b:	e9 a4 00 00 00       	jmpq   ffffffff801002d4 <bget+0x116>
      }
      sleep(b, &bcache.lock);
ffffffff80100230:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100234:	48 c7 c6 00 b0 10 80 	mov    $0xffffffff8010b000,%rsi
ffffffff8010023b:	48 89 c7             	mov    %rax,%rdi
ffffffff8010023e:	e8 8d 55 00 00       	callq  ffffffff801057d0 <sleep>
      goto loop;
ffffffff80100243:	eb 93                	jmp    ffffffff801001d8 <bget+0x1a>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
ffffffff80100245:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100249:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff8010024d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80100251:	48 81 7d f8 f8 c5 10 	cmpq   $0xffffffff8010c5f8,-0x8(%rbp)
ffffffff80100258:	80 
ffffffff80100259:	75 8a                	jne    ffffffff801001e5 <bget+0x27>
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
ffffffff8010025b:	48 8b 05 a6 c3 00 00 	mov    0xc3a6(%rip),%rax        # ffffffff8010c608 <bcache+0x1608>
ffffffff80100262:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80100266:	eb 56                	jmp    ffffffff801002be <bget+0x100>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
ffffffff80100268:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010026c:	8b 00                	mov    (%rax),%eax
ffffffff8010026e:	83 e0 01             	and    $0x1,%eax
ffffffff80100271:	85 c0                	test   %eax,%eax
ffffffff80100273:	75 3d                	jne    ffffffff801002b2 <bget+0xf4>
ffffffff80100275:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100279:	8b 00                	mov    (%rax),%eax
ffffffff8010027b:	83 e0 04             	and    $0x4,%eax
ffffffff8010027e:	85 c0                	test   %eax,%eax
ffffffff80100280:	75 30                	jne    ffffffff801002b2 <bget+0xf4>
      b->dev = dev;
ffffffff80100282:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100286:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80100289:	89 50 04             	mov    %edx,0x4(%rax)
      b->sector = sector;
ffffffff8010028c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100290:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff80100293:	89 50 08             	mov    %edx,0x8(%rax)
      b->flags = B_BUSY;
ffffffff80100296:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010029a:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
      release(&bcache.lock);
ffffffff801002a0:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff801002a7:	e8 6d 59 00 00       	callq  ffffffff80105c19 <release>
      return b;
ffffffff801002ac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801002b0:	eb 22                	jmp    ffffffff801002d4 <bget+0x116>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
ffffffff801002b2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801002b6:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff801002ba:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801002be:	48 81 7d f8 f8 c5 10 	cmpq   $0xffffffff8010c5f8,-0x8(%rbp)
ffffffff801002c5:	80 
ffffffff801002c6:	75 a0                	jne    ffffffff80100268 <bget+0xaa>
    }
  }
  panic("bget: no buffers");
ffffffff801002c8:	48 c7 c7 e7 95 10 80 	mov    $0xffffffff801095e7,%rdi
ffffffff801002cf:	e8 2a 06 00 00       	callq  ffffffff801008fe <panic>
}
ffffffff801002d4:	c9                   	leaveq 
ffffffff801002d5:	c3                   	retq   

ffffffff801002d6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
ffffffff801002d6:	55                   	push   %rbp
ffffffff801002d7:	48 89 e5             	mov    %rsp,%rbp
ffffffff801002da:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801002de:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff801002e1:	89 75 e8             	mov    %esi,-0x18(%rbp)
  struct buf *b;

  b = bget(dev, sector);
ffffffff801002e4:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff801002e7:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801002ea:	89 d6                	mov    %edx,%esi
ffffffff801002ec:	89 c7                	mov    %eax,%edi
ffffffff801002ee:	e8 cb fe ff ff       	callq  ffffffff801001be <bget>
ffffffff801002f3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(!(b->flags & B_VALID))
ffffffff801002f7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801002fb:	8b 00                	mov    (%rax),%eax
ffffffff801002fd:	83 e0 02             	and    $0x2,%eax
ffffffff80100300:	85 c0                	test   %eax,%eax
ffffffff80100302:	75 0c                	jne    ffffffff80100310 <bread+0x3a>
    iderw(b);
ffffffff80100304:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100308:	48 89 c7             	mov    %rax,%rdi
ffffffff8010030b:	e8 aa 2b 00 00       	callq  ffffffff80102eba <iderw>
  return b;
ffffffff80100310:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80100314:	c9                   	leaveq 
ffffffff80100315:	c3                   	retq   

ffffffff80100316 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
ffffffff80100316:	55                   	push   %rbp
ffffffff80100317:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010031a:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff8010031e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if((b->flags & B_BUSY) == 0)
ffffffff80100322:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100326:	8b 00                	mov    (%rax),%eax
ffffffff80100328:	83 e0 01             	and    $0x1,%eax
ffffffff8010032b:	85 c0                	test   %eax,%eax
ffffffff8010032d:	75 0c                	jne    ffffffff8010033b <bwrite+0x25>
    panic("bwrite");
ffffffff8010032f:	48 c7 c7 f8 95 10 80 	mov    $0xffffffff801095f8,%rdi
ffffffff80100336:	e8 c3 05 00 00       	callq  ffffffff801008fe <panic>
  b->flags |= B_DIRTY;
ffffffff8010033b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010033f:	8b 00                	mov    (%rax),%eax
ffffffff80100341:	83 c8 04             	or     $0x4,%eax
ffffffff80100344:	89 c2                	mov    %eax,%edx
ffffffff80100346:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010034a:	89 10                	mov    %edx,(%rax)
  iderw(b);
ffffffff8010034c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100350:	48 89 c7             	mov    %rax,%rdi
ffffffff80100353:	e8 62 2b 00 00       	callq  ffffffff80102eba <iderw>
}
ffffffff80100358:	90                   	nop
ffffffff80100359:	c9                   	leaveq 
ffffffff8010035a:	c3                   	retq   

ffffffff8010035b <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
ffffffff8010035b:	55                   	push   %rbp
ffffffff8010035c:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010035f:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80100363:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if((b->flags & B_BUSY) == 0)
ffffffff80100367:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010036b:	8b 00                	mov    (%rax),%eax
ffffffff8010036d:	83 e0 01             	and    $0x1,%eax
ffffffff80100370:	85 c0                	test   %eax,%eax
ffffffff80100372:	75 0c                	jne    ffffffff80100380 <brelse+0x25>
    panic("brelse");
ffffffff80100374:	48 c7 c7 ff 95 10 80 	mov    $0xffffffff801095ff,%rdi
ffffffff8010037b:	e8 7e 05 00 00       	callq  ffffffff801008fe <panic>

  acquire(&bcache.lock);
ffffffff80100380:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff80100387:	e8 b6 57 00 00       	callq  ffffffff80105b42 <acquire>

  b->next->prev = b->prev;
ffffffff8010038c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80100390:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff80100394:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80100398:	48 8b 52 10          	mov    0x10(%rdx),%rdx
ffffffff8010039c:	48 89 50 10          	mov    %rdx,0x10(%rax)
  b->prev->next = b->next;
ffffffff801003a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003a4:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff801003a8:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff801003ac:	48 8b 52 18          	mov    0x18(%rdx),%rdx
ffffffff801003b0:	48 89 50 18          	mov    %rdx,0x18(%rax)
  b->next = bcache.head.next;
ffffffff801003b4:	48 8b 15 55 c2 00 00 	mov    0xc255(%rip),%rdx        # ffffffff8010c610 <bcache+0x1610>
ffffffff801003bb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003bf:	48 89 50 18          	mov    %rdx,0x18(%rax)
  b->prev = &bcache.head;
ffffffff801003c3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003c7:	48 c7 40 10 f8 c5 10 	movq   $0xffffffff8010c5f8,0x10(%rax)
ffffffff801003ce:	80 
  bcache.head.next->prev = b;
ffffffff801003cf:	48 8b 05 3a c2 00 00 	mov    0xc23a(%rip),%rax        # ffffffff8010c610 <bcache+0x1610>
ffffffff801003d6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff801003da:	48 89 50 10          	mov    %rdx,0x10(%rax)
  bcache.head.next = b;
ffffffff801003de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003e2:	48 89 05 27 c2 00 00 	mov    %rax,0xc227(%rip)        # ffffffff8010c610 <bcache+0x1610>

  b->flags &= ~B_BUSY;
ffffffff801003e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003ed:	8b 00                	mov    (%rax),%eax
ffffffff801003ef:	83 e0 fe             	and    $0xfffffffe,%eax
ffffffff801003f2:	89 c2                	mov    %eax,%edx
ffffffff801003f4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003f8:	89 10                	mov    %edx,(%rax)
  wakeup(b);
ffffffff801003fa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801003fe:	48 89 c7             	mov    %rax,%rdi
ffffffff80100401:	e8 dd 54 00 00       	callq  ffffffff801058e3 <wakeup>

  release(&bcache.lock);
ffffffff80100406:	48 c7 c7 00 b0 10 80 	mov    $0xffffffff8010b000,%rdi
ffffffff8010040d:	e8 07 58 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80100412:	90                   	nop
ffffffff80100413:	c9                   	leaveq 
ffffffff80100414:	c3                   	retq   

ffffffff80100415 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
ffffffff80100415:	55                   	push   %rbp
ffffffff80100416:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100419:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff8010041d:	89 f8                	mov    %edi,%eax
ffffffff8010041f:	66 89 45 ec          	mov    %ax,-0x14(%rbp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
ffffffff80100423:	0f b7 45 ec          	movzwl -0x14(%rbp),%eax
ffffffff80100427:	89 c2                	mov    %eax,%edx
ffffffff80100429:	ec                   	in     (%dx),%al
ffffffff8010042a:	88 45 ff             	mov    %al,-0x1(%rbp)
  return data;
ffffffff8010042d:	0f b6 45 ff          	movzbl -0x1(%rbp),%eax
}
ffffffff80100431:	c9                   	leaveq 
ffffffff80100432:	c3                   	retq   

ffffffff80100433 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
ffffffff80100433:	55                   	push   %rbp
ffffffff80100434:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100437:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010043b:	89 fa                	mov    %edi,%edx
ffffffff8010043d:	89 f0                	mov    %esi,%eax
ffffffff8010043f:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80100443:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80100446:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff8010044a:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff8010044e:	ee                   	out    %al,(%dx)
}
ffffffff8010044f:	90                   	nop
ffffffff80100450:	c9                   	leaveq 
ffffffff80100451:	c3                   	retq   

ffffffff80100452 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
ffffffff80100452:	55                   	push   %rbp
ffffffff80100453:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100456:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff8010045a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff8010045e:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  volatile ushort pd[5];

  pd[0] = size-1;
ffffffff80100461:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80100464:	83 e8 01             	sub    $0x1,%eax
ffffffff80100467:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
  pd[1] = (uintp)p;
ffffffff8010046b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010046f:	66 89 45 f8          	mov    %ax,-0x8(%rbp)
  pd[2] = (uintp)p >> 16;
ffffffff80100473:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100477:	48 c1 e8 10          	shr    $0x10,%rax
ffffffff8010047b:	66 89 45 fa          	mov    %ax,-0x6(%rbp)
#if X64
  pd[3] = (uintp)p >> 32;
ffffffff8010047f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100483:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80100487:	66 89 45 fc          	mov    %ax,-0x4(%rbp)
  pd[4] = (uintp)p >> 48;
ffffffff8010048b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010048f:	48 c1 e8 30          	shr    $0x30,%rax
ffffffff80100493:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
#endif
  asm volatile("lidt (%0)" : : "r" (pd));
ffffffff80100497:	48 8d 45 f6          	lea    -0xa(%rbp),%rax
ffffffff8010049b:	0f 01 18             	lidt   (%rax)
}
ffffffff8010049e:	90                   	nop
ffffffff8010049f:	c9                   	leaveq 
ffffffff801004a0:	c3                   	retq   

ffffffff801004a1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
ffffffff801004a1:	55                   	push   %rbp
ffffffff801004a2:	48 89 e5             	mov    %rsp,%rbp
  asm volatile("cli");
ffffffff801004a5:	fa                   	cli    
}
ffffffff801004a6:	90                   	nop
ffffffff801004a7:	5d                   	pop    %rbp
ffffffff801004a8:	c3                   	retq   

ffffffff801004a9 <printptr>:
} cons;

static char digits[] = "0123456789abcdef";

static void
printptr(uintp x) {
ffffffff801004a9:	55                   	push   %rbp
ffffffff801004aa:	48 89 e5             	mov    %rsp,%rbp
ffffffff801004ad:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801004b1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int i;
  for (i = 0; i < (sizeof(uintp) * 2); i++, x <<= 4)
ffffffff801004b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff801004bc:	eb 22                	jmp    ffffffff801004e0 <printptr+0x37>
    consputc(digits[x >> (sizeof(uintp) * 8 - 4)]);
ffffffff801004be:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801004c2:	48 c1 e8 3c          	shr    $0x3c,%rax
ffffffff801004c6:	0f b6 80 00 a0 10 80 	movzbl -0x7fef6000(%rax),%eax
ffffffff801004cd:	0f be c0             	movsbl %al,%eax
ffffffff801004d0:	89 c7                	mov    %eax,%edi
ffffffff801004d2:	e8 56 06 00 00       	callq  ffffffff80100b2d <consputc>
  for (i = 0; i < (sizeof(uintp) * 2); i++, x <<= 4)
ffffffff801004d7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801004db:	48 c1 65 e8 04       	shlq   $0x4,-0x18(%rbp)
ffffffff801004e0:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801004e3:	83 f8 0f             	cmp    $0xf,%eax
ffffffff801004e6:	76 d6                	jbe    ffffffff801004be <printptr+0x15>
}
ffffffff801004e8:	90                   	nop
ffffffff801004e9:	c9                   	leaveq 
ffffffff801004ea:	c3                   	retq   

ffffffff801004eb <printint>:

static void
printint(int xx, int base, int sign)
{
ffffffff801004eb:	55                   	push   %rbp
ffffffff801004ec:	48 89 e5             	mov    %rsp,%rbp
ffffffff801004ef:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff801004f3:	89 7d dc             	mov    %edi,-0x24(%rbp)
ffffffff801004f6:	89 75 d8             	mov    %esi,-0x28(%rbp)
ffffffff801004f9:	89 55 d4             	mov    %edx,-0x2c(%rbp)
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
ffffffff801004fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
ffffffff80100500:	74 1c                	je     ffffffff8010051e <printint+0x33>
ffffffff80100502:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100505:	c1 e8 1f             	shr    $0x1f,%eax
ffffffff80100508:	0f b6 c0             	movzbl %al,%eax
ffffffff8010050b:	89 45 d4             	mov    %eax,-0x2c(%rbp)
ffffffff8010050e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
ffffffff80100512:	74 0a                	je     ffffffff8010051e <printint+0x33>
    x = -xx;
ffffffff80100514:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100517:	f7 d8                	neg    %eax
ffffffff80100519:	89 45 f8             	mov    %eax,-0x8(%rbp)
ffffffff8010051c:	eb 06                	jmp    ffffffff80100524 <printint+0x39>
  else
    x = xx;
ffffffff8010051e:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100521:	89 45 f8             	mov    %eax,-0x8(%rbp)

  i = 0;
ffffffff80100524:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
ffffffff8010052b:	8b 4d d8             	mov    -0x28(%rbp),%ecx
ffffffff8010052e:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80100531:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80100536:	f7 f1                	div    %ecx
ffffffff80100538:	89 d1                	mov    %edx,%ecx
ffffffff8010053a:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010053d:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80100540:	89 55 fc             	mov    %edx,-0x4(%rbp)
ffffffff80100543:	89 ca                	mov    %ecx,%edx
ffffffff80100545:	0f b6 92 00 a0 10 80 	movzbl -0x7fef6000(%rdx),%edx
ffffffff8010054c:	48 98                	cltq   
ffffffff8010054e:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
ffffffff80100552:	8b 75 d8             	mov    -0x28(%rbp),%esi
ffffffff80100555:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80100558:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff8010055d:	f7 f6                	div    %esi
ffffffff8010055f:	89 45 f8             	mov    %eax,-0x8(%rbp)
ffffffff80100562:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
ffffffff80100566:	75 c3                	jne    ffffffff8010052b <printint+0x40>

  if(sign)
ffffffff80100568:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
ffffffff8010056c:	74 26                	je     ffffffff80100594 <printint+0xa9>
    buf[i++] = '-';
ffffffff8010056e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100571:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80100574:	89 55 fc             	mov    %edx,-0x4(%rbp)
ffffffff80100577:	48 98                	cltq   
ffffffff80100579:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
ffffffff8010057e:	eb 14                	jmp    ffffffff80100594 <printint+0xa9>
    consputc(buf[i]);
ffffffff80100580:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100583:	48 98                	cltq   
ffffffff80100585:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
ffffffff8010058a:	0f be c0             	movsbl %al,%eax
ffffffff8010058d:	89 c7                	mov    %eax,%edi
ffffffff8010058f:	e8 99 05 00 00       	callq  ffffffff80100b2d <consputc>
  while(--i >= 0)
ffffffff80100594:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
ffffffff80100598:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff8010059c:	79 e2                	jns    ffffffff80100580 <printint+0x95>
}
ffffffff8010059e:	90                   	nop
ffffffff8010059f:	c9                   	leaveq 
ffffffff801005a0:	c3                   	retq   

ffffffff801005a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
ffffffff801005a1:	55                   	push   %rbp
ffffffff801005a2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801005a5:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
ffffffff801005ac:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
ffffffff801005b3:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
ffffffff801005ba:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
ffffffff801005c1:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
ffffffff801005c8:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
ffffffff801005cf:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
ffffffff801005d6:	84 c0                	test   %al,%al
ffffffff801005d8:	74 20                	je     ffffffff801005fa <cprintf+0x59>
ffffffff801005da:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
ffffffff801005de:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
ffffffff801005e2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
ffffffff801005e6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
ffffffff801005ea:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
ffffffff801005ee:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
ffffffff801005f2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
ffffffff801005f6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int i, c, locking;
  char *s;

  va_start(ap, fmt);
ffffffff801005fa:	c7 85 20 ff ff ff 08 	movl   $0x8,-0xe0(%rbp)
ffffffff80100601:	00 00 00 
ffffffff80100604:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
ffffffff8010060b:	00 00 00 
ffffffff8010060e:	48 8d 45 10          	lea    0x10(%rbp),%rax
ffffffff80100612:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
ffffffff80100619:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
ffffffff80100620:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  locking = cons.locking;
ffffffff80100627:	8b 05 5b c3 00 00    	mov    0xc35b(%rip),%eax        # ffffffff8010c988 <cons+0x68>
ffffffff8010062d:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
  if(locking)
ffffffff80100633:	83 bd 3c ff ff ff 00 	cmpl   $0x0,-0xc4(%rbp)
ffffffff8010063a:	74 0c                	je     ffffffff80100648 <cprintf+0xa7>
    acquire(&cons.lock);
ffffffff8010063c:	48 c7 c7 20 c9 10 80 	mov    $0xffffffff8010c920,%rdi
ffffffff80100643:	e8 fa 54 00 00       	callq  ffffffff80105b42 <acquire>

  if (fmt == 0)
ffffffff80100648:	48 83 bd 18 ff ff ff 	cmpq   $0x0,-0xe8(%rbp)
ffffffff8010064f:	00 
ffffffff80100650:	75 0c                	jne    ffffffff8010065e <cprintf+0xbd>
    panic("null fmt");
ffffffff80100652:	48 c7 c7 06 96 10 80 	mov    $0xffffffff80109606,%rdi
ffffffff80100659:	e8 a0 02 00 00       	callq  ffffffff801008fe <panic>

  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
ffffffff8010065e:	c7 85 4c ff ff ff 00 	movl   $0x0,-0xb4(%rbp)
ffffffff80100665:	00 00 00 
ffffffff80100668:	e9 45 02 00 00       	jmpq   ffffffff801008b2 <cprintf+0x311>
    if(c != '%'){
ffffffff8010066d:	83 bd 38 ff ff ff 25 	cmpl   $0x25,-0xc8(%rbp)
ffffffff80100674:	74 12                	je     ffffffff80100688 <cprintf+0xe7>
      consputc(c);
ffffffff80100676:	8b 85 38 ff ff ff    	mov    -0xc8(%rbp),%eax
ffffffff8010067c:	89 c7                	mov    %eax,%edi
ffffffff8010067e:	e8 aa 04 00 00       	callq  ffffffff80100b2d <consputc>
      continue;
ffffffff80100683:	e9 23 02 00 00       	jmpq   ffffffff801008ab <cprintf+0x30a>
    }
    c = fmt[++i] & 0xff;
ffffffff80100688:	83 85 4c ff ff ff 01 	addl   $0x1,-0xb4(%rbp)
ffffffff8010068f:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
ffffffff80100695:	48 63 d0             	movslq %eax,%rdx
ffffffff80100698:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
ffffffff8010069f:	48 01 d0             	add    %rdx,%rax
ffffffff801006a2:	0f b6 00             	movzbl (%rax),%eax
ffffffff801006a5:	0f be c0             	movsbl %al,%eax
ffffffff801006a8:	25 ff 00 00 00       	and    $0xff,%eax
ffffffff801006ad:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%rbp)
    if(c == 0)
ffffffff801006b3:	83 bd 38 ff ff ff 00 	cmpl   $0x0,-0xc8(%rbp)
ffffffff801006ba:	0f 84 25 02 00 00    	je     ffffffff801008e5 <cprintf+0x344>
      break;
    switch(c){
ffffffff801006c0:	8b 85 38 ff ff ff    	mov    -0xc8(%rbp),%eax
ffffffff801006c6:	83 f8 70             	cmp    $0x70,%eax
ffffffff801006c9:	0f 84 db 00 00 00    	je     ffffffff801007aa <cprintf+0x209>
ffffffff801006cf:	83 f8 70             	cmp    $0x70,%eax
ffffffff801006d2:	7f 13                	jg     ffffffff801006e7 <cprintf+0x146>
ffffffff801006d4:	83 f8 25             	cmp    $0x25,%eax
ffffffff801006d7:	0f 84 aa 01 00 00    	je     ffffffff80100887 <cprintf+0x2e6>
ffffffff801006dd:	83 f8 64             	cmp    $0x64,%eax
ffffffff801006e0:	74 18                	je     ffffffff801006fa <cprintf+0x159>
ffffffff801006e2:	e9 ac 01 00 00       	jmpq   ffffffff80100893 <cprintf+0x2f2>
ffffffff801006e7:	83 f8 73             	cmp    $0x73,%eax
ffffffff801006ea:	0f 84 0a 01 00 00    	je     ffffffff801007fa <cprintf+0x259>
ffffffff801006f0:	83 f8 78             	cmp    $0x78,%eax
ffffffff801006f3:	74 5d                	je     ffffffff80100752 <cprintf+0x1b1>
ffffffff801006f5:	e9 99 01 00 00       	jmpq   ffffffff80100893 <cprintf+0x2f2>
    case 'd':
      printint(va_arg(ap, int), 10, 1);
ffffffff801006fa:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
ffffffff80100700:	83 f8 2f             	cmp    $0x2f,%eax
ffffffff80100703:	77 23                	ja     ffffffff80100728 <cprintf+0x187>
ffffffff80100705:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
ffffffff8010070c:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff80100712:	89 d2                	mov    %edx,%edx
ffffffff80100714:	48 01 d0             	add    %rdx,%rax
ffffffff80100717:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff8010071d:	83 c2 08             	add    $0x8,%edx
ffffffff80100720:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
ffffffff80100726:	eb 12                	jmp    ffffffff8010073a <cprintf+0x199>
ffffffff80100728:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
ffffffff8010072f:	48 8d 50 08          	lea    0x8(%rax),%rdx
ffffffff80100733:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
ffffffff8010073a:	8b 00                	mov    (%rax),%eax
ffffffff8010073c:	ba 01 00 00 00       	mov    $0x1,%edx
ffffffff80100741:	be 0a 00 00 00       	mov    $0xa,%esi
ffffffff80100746:	89 c7                	mov    %eax,%edi
ffffffff80100748:	e8 9e fd ff ff       	callq  ffffffff801004eb <printint>
      break;
ffffffff8010074d:	e9 59 01 00 00       	jmpq   ffffffff801008ab <cprintf+0x30a>
    case 'x':
      printint(va_arg(ap, int), 16, 0);
ffffffff80100752:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
ffffffff80100758:	83 f8 2f             	cmp    $0x2f,%eax
ffffffff8010075b:	77 23                	ja     ffffffff80100780 <cprintf+0x1df>
ffffffff8010075d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
ffffffff80100764:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff8010076a:	89 d2                	mov    %edx,%edx
ffffffff8010076c:	48 01 d0             	add    %rdx,%rax
ffffffff8010076f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff80100775:	83 c2 08             	add    $0x8,%edx
ffffffff80100778:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
ffffffff8010077e:	eb 12                	jmp    ffffffff80100792 <cprintf+0x1f1>
ffffffff80100780:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
ffffffff80100787:	48 8d 50 08          	lea    0x8(%rax),%rdx
ffffffff8010078b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
ffffffff80100792:	8b 00                	mov    (%rax),%eax
ffffffff80100794:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80100799:	be 10 00 00 00       	mov    $0x10,%esi
ffffffff8010079e:	89 c7                	mov    %eax,%edi
ffffffff801007a0:	e8 46 fd ff ff       	callq  ffffffff801004eb <printint>
      break;
ffffffff801007a5:	e9 01 01 00 00       	jmpq   ffffffff801008ab <cprintf+0x30a>
    case 'p':
      printptr(va_arg(ap, uintp));
ffffffff801007aa:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
ffffffff801007b0:	83 f8 2f             	cmp    $0x2f,%eax
ffffffff801007b3:	77 23                	ja     ffffffff801007d8 <cprintf+0x237>
ffffffff801007b5:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
ffffffff801007bc:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff801007c2:	89 d2                	mov    %edx,%edx
ffffffff801007c4:	48 01 d0             	add    %rdx,%rax
ffffffff801007c7:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff801007cd:	83 c2 08             	add    $0x8,%edx
ffffffff801007d0:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
ffffffff801007d6:	eb 12                	jmp    ffffffff801007ea <cprintf+0x249>
ffffffff801007d8:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
ffffffff801007df:	48 8d 50 08          	lea    0x8(%rax),%rdx
ffffffff801007e3:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
ffffffff801007ea:	48 8b 00             	mov    (%rax),%rax
ffffffff801007ed:	48 89 c7             	mov    %rax,%rdi
ffffffff801007f0:	e8 b4 fc ff ff       	callq  ffffffff801004a9 <printptr>
      break;
ffffffff801007f5:	e9 b1 00 00 00       	jmpq   ffffffff801008ab <cprintf+0x30a>
    case 's':
      if((s = va_arg(ap, char*)) == 0)
ffffffff801007fa:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
ffffffff80100800:	83 f8 2f             	cmp    $0x2f,%eax
ffffffff80100803:	77 23                	ja     ffffffff80100828 <cprintf+0x287>
ffffffff80100805:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
ffffffff8010080c:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff80100812:	89 d2                	mov    %edx,%edx
ffffffff80100814:	48 01 d0             	add    %rdx,%rax
ffffffff80100817:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
ffffffff8010081d:	83 c2 08             	add    $0x8,%edx
ffffffff80100820:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
ffffffff80100826:	eb 12                	jmp    ffffffff8010083a <cprintf+0x299>
ffffffff80100828:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
ffffffff8010082f:	48 8d 50 08          	lea    0x8(%rax),%rdx
ffffffff80100833:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
ffffffff8010083a:	48 8b 00             	mov    (%rax),%rax
ffffffff8010083d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
ffffffff80100844:	48 83 bd 40 ff ff ff 	cmpq   $0x0,-0xc0(%rbp)
ffffffff8010084b:	00 
ffffffff8010084c:	75 29                	jne    ffffffff80100877 <cprintf+0x2d6>
        s = "(null)";
ffffffff8010084e:	48 c7 85 40 ff ff ff 	movq   $0xffffffff8010960f,-0xc0(%rbp)
ffffffff80100855:	0f 96 10 80 
      for(; *s; s++)
ffffffff80100859:	eb 1c                	jmp    ffffffff80100877 <cprintf+0x2d6>
        consputc(*s);
ffffffff8010085b:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
ffffffff80100862:	0f b6 00             	movzbl (%rax),%eax
ffffffff80100865:	0f be c0             	movsbl %al,%eax
ffffffff80100868:	89 c7                	mov    %eax,%edi
ffffffff8010086a:	e8 be 02 00 00       	callq  ffffffff80100b2d <consputc>
      for(; *s; s++)
ffffffff8010086f:	48 83 85 40 ff ff ff 	addq   $0x1,-0xc0(%rbp)
ffffffff80100876:	01 
ffffffff80100877:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
ffffffff8010087e:	0f b6 00             	movzbl (%rax),%eax
ffffffff80100881:	84 c0                	test   %al,%al
ffffffff80100883:	75 d6                	jne    ffffffff8010085b <cprintf+0x2ba>
      break;
ffffffff80100885:	eb 24                	jmp    ffffffff801008ab <cprintf+0x30a>
    case '%':
      consputc('%');
ffffffff80100887:	bf 25 00 00 00       	mov    $0x25,%edi
ffffffff8010088c:	e8 9c 02 00 00       	callq  ffffffff80100b2d <consputc>
      break;
ffffffff80100891:	eb 18                	jmp    ffffffff801008ab <cprintf+0x30a>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
ffffffff80100893:	bf 25 00 00 00       	mov    $0x25,%edi
ffffffff80100898:	e8 90 02 00 00       	callq  ffffffff80100b2d <consputc>
      consputc(c);
ffffffff8010089d:	8b 85 38 ff ff ff    	mov    -0xc8(%rbp),%eax
ffffffff801008a3:	89 c7                	mov    %eax,%edi
ffffffff801008a5:	e8 83 02 00 00       	callq  ffffffff80100b2d <consputc>
      break;
ffffffff801008aa:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
ffffffff801008ab:	83 85 4c ff ff ff 01 	addl   $0x1,-0xb4(%rbp)
ffffffff801008b2:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
ffffffff801008b8:	48 63 d0             	movslq %eax,%rdx
ffffffff801008bb:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
ffffffff801008c2:	48 01 d0             	add    %rdx,%rax
ffffffff801008c5:	0f b6 00             	movzbl (%rax),%eax
ffffffff801008c8:	0f be c0             	movsbl %al,%eax
ffffffff801008cb:	25 ff 00 00 00       	and    $0xff,%eax
ffffffff801008d0:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%rbp)
ffffffff801008d6:	83 bd 38 ff ff ff 00 	cmpl   $0x0,-0xc8(%rbp)
ffffffff801008dd:	0f 85 8a fd ff ff    	jne    ffffffff8010066d <cprintf+0xcc>
ffffffff801008e3:	eb 01                	jmp    ffffffff801008e6 <cprintf+0x345>
      break;
ffffffff801008e5:	90                   	nop
    }
  }

  if(locking)
ffffffff801008e6:	83 bd 3c ff ff ff 00 	cmpl   $0x0,-0xc4(%rbp)
ffffffff801008ed:	74 0c                	je     ffffffff801008fb <cprintf+0x35a>
    release(&cons.lock);
ffffffff801008ef:	48 c7 c7 20 c9 10 80 	mov    $0xffffffff8010c920,%rdi
ffffffff801008f6:	e8 1e 53 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff801008fb:	90                   	nop
ffffffff801008fc:	c9                   	leaveq 
ffffffff801008fd:	c3                   	retq   

ffffffff801008fe <panic>:

void
panic(char *s)
{
ffffffff801008fe:	55                   	push   %rbp
ffffffff801008ff:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100902:	48 83 ec 70          	sub    $0x70,%rsp
ffffffff80100906:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  int i;
  uintp pcs[10];
  
  cli();
ffffffff8010090a:	e8 92 fb ff ff       	callq  ffffffff801004a1 <cli>
  cons.locking = 0;
ffffffff8010090f:	c7 05 6f c0 00 00 00 	movl   $0x0,0xc06f(%rip)        # ffffffff8010c988 <cons+0x68>
ffffffff80100916:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
ffffffff80100919:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80100920:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80100924:	0f b6 00             	movzbl (%rax),%eax
ffffffff80100927:	0f b6 c0             	movzbl %al,%eax
ffffffff8010092a:	89 c6                	mov    %eax,%esi
ffffffff8010092c:	48 c7 c7 16 96 10 80 	mov    $0xffffffff80109616,%rdi
ffffffff80100933:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80100938:	e8 64 fc ff ff       	callq  ffffffff801005a1 <cprintf>
  cprintf(s);
ffffffff8010093d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
ffffffff80100941:	48 89 c7             	mov    %rax,%rdi
ffffffff80100944:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80100949:	e8 53 fc ff ff       	callq  ffffffff801005a1 <cprintf>
  cprintf("\n");
ffffffff8010094e:	48 c7 c7 25 96 10 80 	mov    $0xffffffff80109625,%rdi
ffffffff80100955:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010095a:	e8 42 fc ff ff       	callq  ffffffff801005a1 <cprintf>
  getcallerpcs(&s, pcs);
ffffffff8010095f:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
ffffffff80100963:	48 8d 45 98          	lea    -0x68(%rbp),%rax
ffffffff80100967:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010096a:	48 89 c7             	mov    %rax,%rdi
ffffffff8010096d:	e8 00 53 00 00       	callq  ffffffff80105c72 <getcallerpcs>
  for(i=0; i<10; i++)
ffffffff80100972:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80100979:	eb 22                	jmp    ffffffff8010099d <panic+0x9f>
    cprintf(" %p", pcs[i]);
ffffffff8010097b:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010097e:	48 98                	cltq   
ffffffff80100980:	48 8b 44 c5 a0       	mov    -0x60(%rbp,%rax,8),%rax
ffffffff80100985:	48 89 c6             	mov    %rax,%rsi
ffffffff80100988:	48 c7 c7 27 96 10 80 	mov    $0xffffffff80109627,%rdi
ffffffff8010098f:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80100994:	e8 08 fc ff ff       	callq  ffffffff801005a1 <cprintf>
  for(i=0; i<10; i++)
ffffffff80100999:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff8010099d:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
ffffffff801009a1:	7e d8                	jle    ffffffff8010097b <panic+0x7d>
  panicked = 1; // freeze other CPU
ffffffff801009a3:	c7 05 6b bf 00 00 01 	movl   $0x1,0xbf6b(%rip)        # ffffffff8010c918 <panicked>
ffffffff801009aa:	00 00 00 
  for(;;)
ffffffff801009ad:	eb fe                	jmp    ffffffff801009ad <panic+0xaf>

ffffffff801009af <cgaputc>:
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory


static void
cgaputc(int c)
{
ffffffff801009af:	55                   	push   %rbp
ffffffff801009b0:	48 89 e5             	mov    %rsp,%rbp
ffffffff801009b3:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801009b7:	89 7d ec             	mov    %edi,-0x14(%rbp)
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
ffffffff801009ba:	be 0e 00 00 00       	mov    $0xe,%esi
ffffffff801009bf:	bf d4 03 00 00       	mov    $0x3d4,%edi
ffffffff801009c4:	e8 6a fa ff ff       	callq  ffffffff80100433 <outb>
  pos = inb(CRTPORT+1) << 8;
ffffffff801009c9:	bf d5 03 00 00       	mov    $0x3d5,%edi
ffffffff801009ce:	e8 42 fa ff ff       	callq  ffffffff80100415 <inb>
ffffffff801009d3:	0f b6 c0             	movzbl %al,%eax
ffffffff801009d6:	c1 e0 08             	shl    $0x8,%eax
ffffffff801009d9:	89 45 fc             	mov    %eax,-0x4(%rbp)
  outb(CRTPORT, 15);
ffffffff801009dc:	be 0f 00 00 00       	mov    $0xf,%esi
ffffffff801009e1:	bf d4 03 00 00       	mov    $0x3d4,%edi
ffffffff801009e6:	e8 48 fa ff ff       	callq  ffffffff80100433 <outb>
  pos |= inb(CRTPORT+1);
ffffffff801009eb:	bf d5 03 00 00       	mov    $0x3d5,%edi
ffffffff801009f0:	e8 20 fa ff ff       	callq  ffffffff80100415 <inb>
ffffffff801009f5:	0f b6 c0             	movzbl %al,%eax
ffffffff801009f8:	09 45 fc             	or     %eax,-0x4(%rbp)

  if(c == '\n')
ffffffff801009fb:	83 7d ec 0a          	cmpl   $0xa,-0x14(%rbp)
ffffffff801009ff:	75 30                	jne    ffffffff80100a31 <cgaputc+0x82>
    pos += 80 - pos%80;
ffffffff80100a01:	8b 4d fc             	mov    -0x4(%rbp),%ecx
ffffffff80100a04:	ba 67 66 66 66       	mov    $0x66666667,%edx
ffffffff80100a09:	89 c8                	mov    %ecx,%eax
ffffffff80100a0b:	f7 ea                	imul   %edx
ffffffff80100a0d:	c1 fa 05             	sar    $0x5,%edx
ffffffff80100a10:	89 c8                	mov    %ecx,%eax
ffffffff80100a12:	c1 f8 1f             	sar    $0x1f,%eax
ffffffff80100a15:	29 c2                	sub    %eax,%edx
ffffffff80100a17:	89 d0                	mov    %edx,%eax
ffffffff80100a19:	c1 e0 02             	shl    $0x2,%eax
ffffffff80100a1c:	01 d0                	add    %edx,%eax
ffffffff80100a1e:	c1 e0 04             	shl    $0x4,%eax
ffffffff80100a21:	29 c1                	sub    %eax,%ecx
ffffffff80100a23:	89 ca                	mov    %ecx,%edx
ffffffff80100a25:	b8 50 00 00 00       	mov    $0x50,%eax
ffffffff80100a2a:	29 d0                	sub    %edx,%eax
ffffffff80100a2c:	01 45 fc             	add    %eax,-0x4(%rbp)
ffffffff80100a2f:	eb 3d                	jmp    ffffffff80100a6e <cgaputc+0xbf>
  else if(c == BACKSPACE){
ffffffff80100a31:	81 7d ec 00 01 00 00 	cmpl   $0x100,-0x14(%rbp)
ffffffff80100a38:	75 0c                	jne    ffffffff80100a46 <cgaputc+0x97>
    if(pos > 0) --pos;
ffffffff80100a3a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80100a3e:	7e 2e                	jle    ffffffff80100a6e <cgaputc+0xbf>
ffffffff80100a40:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
ffffffff80100a44:	eb 28                	jmp    ffffffff80100a6e <cgaputc+0xbf>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
ffffffff80100a46:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80100a49:	0f b6 c0             	movzbl %al,%eax
ffffffff80100a4c:	80 cc 07             	or     $0x7,%ah
ffffffff80100a4f:	89 c6                	mov    %eax,%esi
ffffffff80100a51:	48 8b 0d c0 95 00 00 	mov    0x95c0(%rip),%rcx        # ffffffff8010a018 <crt>
ffffffff80100a58:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100a5b:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80100a5e:	89 55 fc             	mov    %edx,-0x4(%rbp)
ffffffff80100a61:	48 98                	cltq   
ffffffff80100a63:	48 01 c0             	add    %rax,%rax
ffffffff80100a66:	48 01 c8             	add    %rcx,%rax
ffffffff80100a69:	89 f2                	mov    %esi,%edx
ffffffff80100a6b:	66 89 10             	mov    %dx,(%rax)
  
  if((pos/80) >= 24){  // Scroll up.
ffffffff80100a6e:	81 7d fc 7f 07 00 00 	cmpl   $0x77f,-0x4(%rbp)
ffffffff80100a75:	7e 56                	jle    ffffffff80100acd <cgaputc+0x11e>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
ffffffff80100a77:	48 8b 05 9a 95 00 00 	mov    0x959a(%rip),%rax        # ffffffff8010a018 <crt>
ffffffff80100a7e:	48 8d 88 a0 00 00 00 	lea    0xa0(%rax),%rcx
ffffffff80100a85:	48 8b 05 8c 95 00 00 	mov    0x958c(%rip),%rax        # ffffffff8010a018 <crt>
ffffffff80100a8c:	ba 60 0e 00 00       	mov    $0xe60,%edx
ffffffff80100a91:	48 89 ce             	mov    %rcx,%rsi
ffffffff80100a94:	48 89 c7             	mov    %rax,%rdi
ffffffff80100a97:	e8 04 55 00 00       	callq  ffffffff80105fa0 <memmove>
    pos -= 80;
ffffffff80100a9c:	83 6d fc 50          	subl   $0x50,-0x4(%rbp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
ffffffff80100aa0:	b8 80 07 00 00       	mov    $0x780,%eax
ffffffff80100aa5:	2b 45 fc             	sub    -0x4(%rbp),%eax
ffffffff80100aa8:	48 98                	cltq   
ffffffff80100aaa:	8d 14 00             	lea    (%rax,%rax,1),%edx
ffffffff80100aad:	48 8b 05 64 95 00 00 	mov    0x9564(%rip),%rax        # ffffffff8010a018 <crt>
ffffffff80100ab4:	8b 4d fc             	mov    -0x4(%rbp),%ecx
ffffffff80100ab7:	48 63 c9             	movslq %ecx,%rcx
ffffffff80100aba:	48 01 c9             	add    %rcx,%rcx
ffffffff80100abd:	48 01 c8             	add    %rcx,%rax
ffffffff80100ac0:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80100ac5:	48 89 c7             	mov    %rax,%rdi
ffffffff80100ac8:	e8 e4 53 00 00       	callq  ffffffff80105eb1 <memset>
  }
  
  outb(CRTPORT, 14);
ffffffff80100acd:	be 0e 00 00 00       	mov    $0xe,%esi
ffffffff80100ad2:	bf d4 03 00 00       	mov    $0x3d4,%edi
ffffffff80100ad7:	e8 57 f9 ff ff       	callq  ffffffff80100433 <outb>
  outb(CRTPORT+1, pos>>8);
ffffffff80100adc:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100adf:	c1 f8 08             	sar    $0x8,%eax
ffffffff80100ae2:	0f b6 c0             	movzbl %al,%eax
ffffffff80100ae5:	89 c6                	mov    %eax,%esi
ffffffff80100ae7:	bf d5 03 00 00       	mov    $0x3d5,%edi
ffffffff80100aec:	e8 42 f9 ff ff       	callq  ffffffff80100433 <outb>
  outb(CRTPORT, 15);
ffffffff80100af1:	be 0f 00 00 00       	mov    $0xf,%esi
ffffffff80100af6:	bf d4 03 00 00       	mov    $0x3d4,%edi
ffffffff80100afb:	e8 33 f9 ff ff       	callq  ffffffff80100433 <outb>
  outb(CRTPORT+1, pos);
ffffffff80100b00:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100b03:	0f b6 c0             	movzbl %al,%eax
ffffffff80100b06:	89 c6                	mov    %eax,%esi
ffffffff80100b08:	bf d5 03 00 00       	mov    $0x3d5,%edi
ffffffff80100b0d:	e8 21 f9 ff ff       	callq  ffffffff80100433 <outb>
  crt[pos] = ' ' | 0x0700;
ffffffff80100b12:	48 8b 05 ff 94 00 00 	mov    0x94ff(%rip),%rax        # ffffffff8010a018 <crt>
ffffffff80100b19:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80100b1c:	48 63 d2             	movslq %edx,%rdx
ffffffff80100b1f:	48 01 d2             	add    %rdx,%rdx
ffffffff80100b22:	48 01 d0             	add    %rdx,%rax
ffffffff80100b25:	66 c7 00 20 07       	movw   $0x720,(%rax)
}
ffffffff80100b2a:	90                   	nop
ffffffff80100b2b:	c9                   	leaveq 
ffffffff80100b2c:	c3                   	retq   

ffffffff80100b2d <consputc>:

void
consputc(int c)
{
ffffffff80100b2d:	55                   	push   %rbp
ffffffff80100b2e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100b31:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80100b35:	89 7d fc             	mov    %edi,-0x4(%rbp)
  if(panicked){
ffffffff80100b38:	8b 05 da bd 00 00    	mov    0xbdda(%rip),%eax        # ffffffff8010c918 <panicked>
ffffffff80100b3e:	85 c0                	test   %eax,%eax
ffffffff80100b40:	74 07                	je     ffffffff80100b49 <consputc+0x1c>
    cli();
ffffffff80100b42:	e8 5a f9 ff ff       	callq  ffffffff801004a1 <cli>
    for(;;)
ffffffff80100b47:	eb fe                	jmp    ffffffff80100b47 <consputc+0x1a>
      ;
  }

  if(c == BACKSPACE){
ffffffff80100b49:	81 7d fc 00 01 00 00 	cmpl   $0x100,-0x4(%rbp)
ffffffff80100b50:	75 20                	jne    ffffffff80100b72 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
ffffffff80100b52:	bf 08 00 00 00       	mov    $0x8,%edi
ffffffff80100b57:	e8 cb 6e 00 00       	callq  ffffffff80107a27 <uartputc>
ffffffff80100b5c:	bf 20 00 00 00       	mov    $0x20,%edi
ffffffff80100b61:	e8 c1 6e 00 00       	callq  ffffffff80107a27 <uartputc>
ffffffff80100b66:	bf 08 00 00 00       	mov    $0x8,%edi
ffffffff80100b6b:	e8 b7 6e 00 00       	callq  ffffffff80107a27 <uartputc>
ffffffff80100b70:	eb 0a                	jmp    ffffffff80100b7c <consputc+0x4f>
  } else
    uartputc(c);
ffffffff80100b72:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100b75:	89 c7                	mov    %eax,%edi
ffffffff80100b77:	e8 ab 6e 00 00       	callq  ffffffff80107a27 <uartputc>
  cgaputc(c);
ffffffff80100b7c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100b7f:	89 c7                	mov    %eax,%edi
ffffffff80100b81:	e8 29 fe ff ff       	callq  ffffffff801009af <cgaputc>
}
ffffffff80100b86:	90                   	nop
ffffffff80100b87:	c9                   	leaveq 
ffffffff80100b88:	c3                   	retq   

ffffffff80100b89 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
ffffffff80100b89:	55                   	push   %rbp
ffffffff80100b8a:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100b8d:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80100b91:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int c;

  acquire(&input.lock);
ffffffff80100b95:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100b9c:	e8 a1 4f 00 00       	callq  ffffffff80105b42 <acquire>
  while((c = getc()) >= 0){
ffffffff80100ba1:	e9 5f 01 00 00       	jmpq   ffffffff80100d05 <consoleintr+0x17c>
    switch(c){
ffffffff80100ba6:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100ba9:	83 f8 15             	cmp    $0x15,%eax
ffffffff80100bac:	74 5e                	je     ffffffff80100c0c <consoleintr+0x83>
ffffffff80100bae:	83 f8 15             	cmp    $0x15,%eax
ffffffff80100bb1:	7f 13                	jg     ffffffff80100bc6 <consoleintr+0x3d>
ffffffff80100bb3:	83 f8 08             	cmp    $0x8,%eax
ffffffff80100bb6:	0f 84 82 00 00 00    	je     ffffffff80100c3e <consoleintr+0xb5>
ffffffff80100bbc:	83 f8 10             	cmp    $0x10,%eax
ffffffff80100bbf:	74 28                	je     ffffffff80100be9 <consoleintr+0x60>
ffffffff80100bc1:	e9 aa 00 00 00       	jmpq   ffffffff80100c70 <consoleintr+0xe7>
ffffffff80100bc6:	83 f8 1a             	cmp    $0x1a,%eax
ffffffff80100bc9:	74 0a                	je     ffffffff80100bd5 <consoleintr+0x4c>
ffffffff80100bcb:	83 f8 7f             	cmp    $0x7f,%eax
ffffffff80100bce:	74 6e                	je     ffffffff80100c3e <consoleintr+0xb5>
ffffffff80100bd0:	e9 9b 00 00 00       	jmpq   ffffffff80100c70 <consoleintr+0xe7>
    case C('Z'): // reboot
      lidt(0,0);
ffffffff80100bd5:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80100bda:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80100bdf:	e8 6e f8 ff ff       	callq  ffffffff80100452 <lidt>
      break;
ffffffff80100be4:	e9 1c 01 00 00       	jmpq   ffffffff80100d05 <consoleintr+0x17c>
    case C('P'):  // Process listing.
      procdump();
ffffffff80100be9:	e8 af 4d 00 00       	callq  ffffffff8010599d <procdump>
      break;
ffffffff80100bee:	e9 12 01 00 00       	jmpq   ffffffff80100d05 <consoleintr+0x17c>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
ffffffff80100bf3:	8b 05 17 bd 00 00    	mov    0xbd17(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100bf9:	83 e8 01             	sub    $0x1,%eax
ffffffff80100bfc:	89 05 0e bd 00 00    	mov    %eax,0xbd0e(%rip)        # ffffffff8010c910 <input+0xf0>
        consputc(BACKSPACE);
ffffffff80100c02:	bf 00 01 00 00       	mov    $0x100,%edi
ffffffff80100c07:	e8 21 ff ff ff       	callq  ffffffff80100b2d <consputc>
      while(input.e != input.w &&
ffffffff80100c0c:	8b 15 fe bc 00 00    	mov    0xbcfe(%rip),%edx        # ffffffff8010c910 <input+0xf0>
ffffffff80100c12:	8b 05 f4 bc 00 00    	mov    0xbcf4(%rip),%eax        # ffffffff8010c90c <input+0xec>
ffffffff80100c18:	39 c2                	cmp    %eax,%edx
ffffffff80100c1a:	0f 84 e5 00 00 00    	je     ffffffff80100d05 <consoleintr+0x17c>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
ffffffff80100c20:	8b 05 ea bc 00 00    	mov    0xbcea(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100c26:	83 e8 01             	sub    $0x1,%eax
ffffffff80100c29:	83 e0 7f             	and    $0x7f,%eax
ffffffff80100c2c:	89 c0                	mov    %eax,%eax
ffffffff80100c2e:	0f b6 80 88 c8 10 80 	movzbl -0x7fef3778(%rax),%eax
      while(input.e != input.w &&
ffffffff80100c35:	3c 0a                	cmp    $0xa,%al
ffffffff80100c37:	75 ba                	jne    ffffffff80100bf3 <consoleintr+0x6a>
      }
      break;
ffffffff80100c39:	e9 c7 00 00 00       	jmpq   ffffffff80100d05 <consoleintr+0x17c>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
ffffffff80100c3e:	8b 15 cc bc 00 00    	mov    0xbccc(%rip),%edx        # ffffffff8010c910 <input+0xf0>
ffffffff80100c44:	8b 05 c2 bc 00 00    	mov    0xbcc2(%rip),%eax        # ffffffff8010c90c <input+0xec>
ffffffff80100c4a:	39 c2                	cmp    %eax,%edx
ffffffff80100c4c:	0f 84 b3 00 00 00    	je     ffffffff80100d05 <consoleintr+0x17c>
        input.e--;
ffffffff80100c52:	8b 05 b8 bc 00 00    	mov    0xbcb8(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100c58:	83 e8 01             	sub    $0x1,%eax
ffffffff80100c5b:	89 05 af bc 00 00    	mov    %eax,0xbcaf(%rip)        # ffffffff8010c910 <input+0xf0>
        consputc(BACKSPACE);
ffffffff80100c61:	bf 00 01 00 00       	mov    $0x100,%edi
ffffffff80100c66:	e8 c2 fe ff ff       	callq  ffffffff80100b2d <consputc>
      }
      break;
ffffffff80100c6b:	e9 95 00 00 00       	jmpq   ffffffff80100d05 <consoleintr+0x17c>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
ffffffff80100c70:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80100c74:	0f 84 8a 00 00 00    	je     ffffffff80100d04 <consoleintr+0x17b>
ffffffff80100c7a:	8b 15 90 bc 00 00    	mov    0xbc90(%rip),%edx        # ffffffff8010c910 <input+0xf0>
ffffffff80100c80:	8b 05 82 bc 00 00    	mov    0xbc82(%rip),%eax        # ffffffff8010c908 <input+0xe8>
ffffffff80100c86:	29 c2                	sub    %eax,%edx
ffffffff80100c88:	89 d0                	mov    %edx,%eax
ffffffff80100c8a:	83 f8 7f             	cmp    $0x7f,%eax
ffffffff80100c8d:	77 75                	ja     ffffffff80100d04 <consoleintr+0x17b>
        c = (c == '\r') ? '\n' : c;
ffffffff80100c8f:	83 7d fc 0d          	cmpl   $0xd,-0x4(%rbp)
ffffffff80100c93:	74 05                	je     ffffffff80100c9a <consoleintr+0x111>
ffffffff80100c95:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100c98:	eb 05                	jmp    ffffffff80100c9f <consoleintr+0x116>
ffffffff80100c9a:	b8 0a 00 00 00       	mov    $0xa,%eax
ffffffff80100c9f:	89 45 fc             	mov    %eax,-0x4(%rbp)
        input.buf[input.e++ % INPUT_BUF] = c;
ffffffff80100ca2:	8b 05 68 bc 00 00    	mov    0xbc68(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100ca8:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80100cab:	89 15 5f bc 00 00    	mov    %edx,0xbc5f(%rip)        # ffffffff8010c910 <input+0xf0>
ffffffff80100cb1:	83 e0 7f             	and    $0x7f,%eax
ffffffff80100cb4:	89 c1                	mov    %eax,%ecx
ffffffff80100cb6:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100cb9:	89 c2                	mov    %eax,%edx
ffffffff80100cbb:	89 c8                	mov    %ecx,%eax
ffffffff80100cbd:	88 90 88 c8 10 80    	mov    %dl,-0x7fef3778(%rax)
        consputc(c);
ffffffff80100cc3:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100cc6:	89 c7                	mov    %eax,%edi
ffffffff80100cc8:	e8 60 fe ff ff       	callq  ffffffff80100b2d <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
ffffffff80100ccd:	83 7d fc 0a          	cmpl   $0xa,-0x4(%rbp)
ffffffff80100cd1:	74 19                	je     ffffffff80100cec <consoleintr+0x163>
ffffffff80100cd3:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
ffffffff80100cd7:	74 13                	je     ffffffff80100cec <consoleintr+0x163>
ffffffff80100cd9:	8b 05 31 bc 00 00    	mov    0xbc31(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100cdf:	8b 15 23 bc 00 00    	mov    0xbc23(%rip),%edx        # ffffffff8010c908 <input+0xe8>
ffffffff80100ce5:	83 ea 80             	sub    $0xffffff80,%edx
ffffffff80100ce8:	39 d0                	cmp    %edx,%eax
ffffffff80100cea:	75 18                	jne    ffffffff80100d04 <consoleintr+0x17b>
          input.w = input.e;
ffffffff80100cec:	8b 05 1e bc 00 00    	mov    0xbc1e(%rip),%eax        # ffffffff8010c910 <input+0xf0>
ffffffff80100cf2:	89 05 14 bc 00 00    	mov    %eax,0xbc14(%rip)        # ffffffff8010c90c <input+0xec>
          wakeup(&input.r);
ffffffff80100cf8:	48 c7 c7 08 c9 10 80 	mov    $0xffffffff8010c908,%rdi
ffffffff80100cff:	e8 df 4b 00 00       	callq  ffffffff801058e3 <wakeup>
        }
      }
      break;
ffffffff80100d04:	90                   	nop
  while((c = getc()) >= 0){
ffffffff80100d05:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100d09:	ff d0                	callq  *%rax
ffffffff80100d0b:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80100d0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80100d12:	0f 89 8e fe ff ff    	jns    ffffffff80100ba6 <consoleintr+0x1d>
    }
  }
  release(&input.lock);
ffffffff80100d18:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100d1f:	e8 f5 4e 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80100d24:	90                   	nop
ffffffff80100d25:	c9                   	leaveq 
ffffffff80100d26:	c3                   	retq   

ffffffff80100d27 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
ffffffff80100d27:	55                   	push   %rbp
ffffffff80100d28:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100d2b:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80100d2f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80100d33:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80100d37:	89 55 dc             	mov    %edx,-0x24(%rbp)
  uint target;
  int c;

  iunlock(ip);
ffffffff80100d3a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100d3e:	48 89 c7             	mov    %rax,%rdi
ffffffff80100d41:	e8 78 12 00 00       	callq  ffffffff80101fbe <iunlock>
  target = n;
ffffffff80100d46:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100d49:	89 45 fc             	mov    %eax,-0x4(%rbp)
  acquire(&input.lock);
ffffffff80100d4c:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100d53:	e8 ea 4d 00 00       	callq  ffffffff80105b42 <acquire>
  while(n > 0){
ffffffff80100d58:	e9 b2 00 00 00       	jmpq   ffffffff80100e0f <consoleread+0xe8>
    while(input.r == input.w){
      if(proc->killed){
ffffffff80100d5d:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80100d64:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80100d68:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff80100d6b:	85 c0                	test   %eax,%eax
ffffffff80100d6d:	74 22                	je     ffffffff80100d91 <consoleread+0x6a>
        release(&input.lock);
ffffffff80100d6f:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100d76:	e8 9e 4e 00 00       	callq  ffffffff80105c19 <release>
        ilock(ip);
ffffffff80100d7b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100d7f:	48 89 c7             	mov    %rax,%rdi
ffffffff80100d82:	e8 c6 10 00 00       	callq  ffffffff80101e4d <ilock>
        return -1;
ffffffff80100d87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80100d8c:	e9 ac 00 00 00       	jmpq   ffffffff80100e3d <consoleread+0x116>
      }
      sleep(&input.r, &input.lock);
ffffffff80100d91:	48 c7 c6 20 c8 10 80 	mov    $0xffffffff8010c820,%rsi
ffffffff80100d98:	48 c7 c7 08 c9 10 80 	mov    $0xffffffff8010c908,%rdi
ffffffff80100d9f:	e8 2c 4a 00 00       	callq  ffffffff801057d0 <sleep>
    while(input.r == input.w){
ffffffff80100da4:	8b 15 5e bb 00 00    	mov    0xbb5e(%rip),%edx        # ffffffff8010c908 <input+0xe8>
ffffffff80100daa:	8b 05 5c bb 00 00    	mov    0xbb5c(%rip),%eax        # ffffffff8010c90c <input+0xec>
ffffffff80100db0:	39 c2                	cmp    %eax,%edx
ffffffff80100db2:	74 a9                	je     ffffffff80100d5d <consoleread+0x36>
    }
    c = input.buf[input.r++ % INPUT_BUF];
ffffffff80100db4:	8b 05 4e bb 00 00    	mov    0xbb4e(%rip),%eax        # ffffffff8010c908 <input+0xe8>
ffffffff80100dba:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80100dbd:	89 15 45 bb 00 00    	mov    %edx,0xbb45(%rip)        # ffffffff8010c908 <input+0xe8>
ffffffff80100dc3:	83 e0 7f             	and    $0x7f,%eax
ffffffff80100dc6:	89 c0                	mov    %eax,%eax
ffffffff80100dc8:	0f b6 80 88 c8 10 80 	movzbl -0x7fef3778(%rax),%eax
ffffffff80100dcf:	0f be c0             	movsbl %al,%eax
ffffffff80100dd2:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(c == C('D')){  // EOF
ffffffff80100dd5:	83 7d f8 04          	cmpl   $0x4,-0x8(%rbp)
ffffffff80100dd9:	75 19                	jne    ffffffff80100df4 <consoleread+0xcd>
      if(n < target){
ffffffff80100ddb:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100dde:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff80100de1:	76 34                	jbe    ffffffff80100e17 <consoleread+0xf0>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
ffffffff80100de3:	8b 05 1f bb 00 00    	mov    0xbb1f(%rip),%eax        # ffffffff8010c908 <input+0xe8>
ffffffff80100de9:	83 e8 01             	sub    $0x1,%eax
ffffffff80100dec:	89 05 16 bb 00 00    	mov    %eax,0xbb16(%rip)        # ffffffff8010c908 <input+0xe8>
      }
      break;
ffffffff80100df2:	eb 23                	jmp    ffffffff80100e17 <consoleread+0xf0>
    }
    *dst++ = c;
ffffffff80100df4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80100df8:	48 8d 50 01          	lea    0x1(%rax),%rdx
ffffffff80100dfc:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
ffffffff80100e00:	8b 55 f8             	mov    -0x8(%rbp),%edx
ffffffff80100e03:	88 10                	mov    %dl,(%rax)
    --n;
ffffffff80100e05:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
    if(c == '\n')
ffffffff80100e09:	83 7d f8 0a          	cmpl   $0xa,-0x8(%rbp)
ffffffff80100e0d:	74 0b                	je     ffffffff80100e1a <consoleread+0xf3>
  while(n > 0){
ffffffff80100e0f:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
ffffffff80100e13:	7f 8f                	jg     ffffffff80100da4 <consoleread+0x7d>
ffffffff80100e15:	eb 04                	jmp    ffffffff80100e1b <consoleread+0xf4>
      break;
ffffffff80100e17:	90                   	nop
ffffffff80100e18:	eb 01                	jmp    ffffffff80100e1b <consoleread+0xf4>
      break;
ffffffff80100e1a:	90                   	nop
  }
  release(&input.lock);
ffffffff80100e1b:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100e22:	e8 f2 4d 00 00       	callq  ffffffff80105c19 <release>
  ilock(ip);
ffffffff80100e27:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100e2b:	48 89 c7             	mov    %rax,%rdi
ffffffff80100e2e:	e8 1a 10 00 00       	callq  ffffffff80101e4d <ilock>

  return target - n;
ffffffff80100e33:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80100e36:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80100e39:	29 c2                	sub    %eax,%edx
ffffffff80100e3b:	89 d0                	mov    %edx,%eax
}
ffffffff80100e3d:	c9                   	leaveq 
ffffffff80100e3e:	c3                   	retq   

ffffffff80100e3f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
ffffffff80100e3f:	55                   	push   %rbp
ffffffff80100e40:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100e43:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80100e47:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80100e4b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80100e4f:	89 55 dc             	mov    %edx,-0x24(%rbp)
  int i;

  iunlock(ip);
ffffffff80100e52:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100e56:	48 89 c7             	mov    %rax,%rdi
ffffffff80100e59:	e8 60 11 00 00       	callq  ffffffff80101fbe <iunlock>
  acquire(&cons.lock);
ffffffff80100e5e:	48 c7 c7 20 c9 10 80 	mov    $0xffffffff8010c920,%rdi
ffffffff80100e65:	e8 d8 4c 00 00       	callq  ffffffff80105b42 <acquire>
  for(i = 0; i < n; i++)
ffffffff80100e6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80100e71:	eb 21                	jmp    ffffffff80100e94 <consolewrite+0x55>
    consputc(buf[i] & 0xff);
ffffffff80100e73:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100e76:	48 63 d0             	movslq %eax,%rdx
ffffffff80100e79:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80100e7d:	48 01 d0             	add    %rdx,%rax
ffffffff80100e80:	0f b6 00             	movzbl (%rax),%eax
ffffffff80100e83:	0f be c0             	movsbl %al,%eax
ffffffff80100e86:	0f b6 c0             	movzbl %al,%eax
ffffffff80100e89:	89 c7                	mov    %eax,%edi
ffffffff80100e8b:	e8 9d fc ff ff       	callq  ffffffff80100b2d <consputc>
  for(i = 0; i < n; i++)
ffffffff80100e90:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80100e94:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80100e97:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80100e9a:	7c d7                	jl     ffffffff80100e73 <consolewrite+0x34>
  release(&cons.lock);
ffffffff80100e9c:	48 c7 c7 20 c9 10 80 	mov    $0xffffffff8010c920,%rdi
ffffffff80100ea3:	e8 71 4d 00 00       	callq  ffffffff80105c19 <release>
  ilock(ip);
ffffffff80100ea8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80100eac:	48 89 c7             	mov    %rax,%rdi
ffffffff80100eaf:	e8 99 0f 00 00       	callq  ffffffff80101e4d <ilock>

  return n;
ffffffff80100eb4:	8b 45 dc             	mov    -0x24(%rbp),%eax
}
ffffffff80100eb7:	c9                   	leaveq 
ffffffff80100eb8:	c3                   	retq   

ffffffff80100eb9 <consoleinit>:

void
consoleinit(void)
{
ffffffff80100eb9:	55                   	push   %rbp
ffffffff80100eba:	48 89 e5             	mov    %rsp,%rbp
  initlock(&cons.lock, "console");
ffffffff80100ebd:	48 c7 c6 2b 96 10 80 	mov    $0xffffffff8010962b,%rsi
ffffffff80100ec4:	48 c7 c7 20 c9 10 80 	mov    $0xffffffff8010c920,%rdi
ffffffff80100ecb:	e8 3d 4c 00 00       	callq  ffffffff80105b0d <initlock>
  initlock(&input.lock, "input");
ffffffff80100ed0:	48 c7 c6 33 96 10 80 	mov    $0xffffffff80109633,%rsi
ffffffff80100ed7:	48 c7 c7 20 c8 10 80 	mov    $0xffffffff8010c820,%rdi
ffffffff80100ede:	e8 2a 4c 00 00       	callq  ffffffff80105b0d <initlock>

  devsw[CONSOLE].write = consolewrite;
ffffffff80100ee3:	48 c7 05 ca ba 00 00 	movq   $0xffffffff80100e3f,0xbaca(%rip)        # ffffffff8010c9b8 <devsw+0x18>
ffffffff80100eea:	3f 0e 10 80 
  devsw[CONSOLE].read = consoleread;
ffffffff80100eee:	48 c7 05 b7 ba 00 00 	movq   $0xffffffff80100d27,0xbab7(%rip)        # ffffffff8010c9b0 <devsw+0x10>
ffffffff80100ef5:	27 0d 10 80 
  cons.locking = 1;
ffffffff80100ef9:	c7 05 85 ba 00 00 01 	movl   $0x1,0xba85(%rip)        # ffffffff8010c988 <cons+0x68>
ffffffff80100f00:	00 00 00 

  picenable(IRQ_KBD);
ffffffff80100f03:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80100f08:	e8 9f 38 00 00       	callq  ffffffff801047ac <picenable>
  ioapicenable(IRQ_KBD, 0);
ffffffff80100f0d:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80100f12:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80100f17:	e8 99 21 00 00       	callq  ffffffff801030b5 <ioapicenable>
}
ffffffff80100f1c:	90                   	nop
ffffffff80100f1d:	5d                   	pop    %rbp
ffffffff80100f1e:	c3                   	retq   

ffffffff80100f1f <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
ffffffff80100f1f:	55                   	push   %rbp
ffffffff80100f20:	48 89 e5             	mov    %rsp,%rbp
ffffffff80100f23:	48 81 ec 00 02 00 00 	sub    $0x200,%rsp
ffffffff80100f2a:	48 89 bd 08 fe ff ff 	mov    %rdi,-0x1f8(%rbp)
ffffffff80100f31:	48 89 b5 00 fe ff ff 	mov    %rsi,-0x200(%rbp)
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
ffffffff80100f38:	48 8b 85 08 fe ff ff 	mov    -0x1f8(%rbp),%rax
ffffffff80100f3f:	48 89 c7             	mov    %rax,%rdi
ffffffff80100f42:	e8 cf 1b 00 00       	callq  ffffffff80102b16 <namei>
ffffffff80100f47:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
ffffffff80100f4b:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
ffffffff80100f50:	75 0a                	jne    ffffffff80100f5c <exec+0x3d>
    return -1;
ffffffff80100f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80100f57:	e9 c2 04 00 00       	jmpq   ffffffff8010141e <exec+0x4ff>
  ilock(ip);
ffffffff80100f5c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80100f60:	48 89 c7             	mov    %rax,%rdi
ffffffff80100f63:	e8 e5 0e 00 00       	callq  ffffffff80101e4d <ilock>
  pgdir = 0;
ffffffff80100f68:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
ffffffff80100f6f:	00 

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
ffffffff80100f70:	48 8d b5 50 fe ff ff 	lea    -0x1b0(%rbp),%rsi
ffffffff80100f77:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80100f7b:	b9 40 00 00 00       	mov    $0x40,%ecx
ffffffff80100f80:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80100f85:	48 89 c7             	mov    %rax,%rdi
ffffffff80100f88:	e8 68 14 00 00       	callq  ffffffff801023f5 <readi>
ffffffff80100f8d:	83 f8 3f             	cmp    $0x3f,%eax
ffffffff80100f90:	0f 86 3e 04 00 00    	jbe    ffffffff801013d4 <exec+0x4b5>
    goto bad;
  if(elf.magic != ELF_MAGIC)
ffffffff80100f96:	8b 85 50 fe ff ff    	mov    -0x1b0(%rbp),%eax
ffffffff80100f9c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
ffffffff80100fa1:	0f 85 30 04 00 00    	jne    ffffffff801013d7 <exec+0x4b8>
    goto bad;

  if((pgdir = setupkvm()) == 0)
ffffffff80100fa7:	e8 bc 82 00 00       	callq  ffffffff80109268 <setupkvm>
ffffffff80100fac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
ffffffff80100fb0:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
ffffffff80100fb5:	0f 84 1f 04 00 00    	je     ffffffff801013da <exec+0x4bb>
    goto bad;

  // Load program into memory.
  sz = 0;
ffffffff80100fbb:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
ffffffff80100fc2:	00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
ffffffff80100fc3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
ffffffff80100fca:	48 8b 85 70 fe ff ff 	mov    -0x190(%rbp),%rax
ffffffff80100fd1:	89 45 e8             	mov    %eax,-0x18(%rbp)
ffffffff80100fd4:	e9 c8 00 00 00       	jmpq   ffffffff801010a1 <exec+0x182>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
ffffffff80100fd9:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff80100fdc:	48 8d b5 10 fe ff ff 	lea    -0x1f0(%rbp),%rsi
ffffffff80100fe3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80100fe7:	b9 38 00 00 00       	mov    $0x38,%ecx
ffffffff80100fec:	48 89 c7             	mov    %rax,%rdi
ffffffff80100fef:	e8 01 14 00 00       	callq  ffffffff801023f5 <readi>
ffffffff80100ff4:	83 f8 38             	cmp    $0x38,%eax
ffffffff80100ff7:	0f 85 e0 03 00 00    	jne    ffffffff801013dd <exec+0x4be>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
ffffffff80100ffd:	8b 85 10 fe ff ff    	mov    -0x1f0(%rbp),%eax
ffffffff80101003:	83 f8 01             	cmp    $0x1,%eax
ffffffff80101006:	0f 85 87 00 00 00    	jne    ffffffff80101093 <exec+0x174>
      continue;
    if(ph.memsz < ph.filesz)
ffffffff8010100c:	48 8b 95 38 fe ff ff 	mov    -0x1c8(%rbp),%rdx
ffffffff80101013:	48 8b 85 30 fe ff ff 	mov    -0x1d0(%rbp),%rax
ffffffff8010101a:	48 39 c2             	cmp    %rax,%rdx
ffffffff8010101d:	0f 82 bd 03 00 00    	jb     ffffffff801013e0 <exec+0x4c1>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
ffffffff80101023:	48 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%rax
ffffffff8010102a:	89 c2                	mov    %eax,%edx
ffffffff8010102c:	48 8b 85 38 fe ff ff 	mov    -0x1c8(%rbp),%rax
ffffffff80101033:	01 c2                	add    %eax,%edx
ffffffff80101035:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80101039:	89 c1                	mov    %eax,%ecx
ffffffff8010103b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff8010103f:	89 ce                	mov    %ecx,%esi
ffffffff80101041:	48 89 c7             	mov    %rax,%rdi
ffffffff80101044:	e8 45 78 00 00       	callq  ffffffff8010888e <allocuvm>
ffffffff80101049:	48 98                	cltq   
ffffffff8010104b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
ffffffff8010104f:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
ffffffff80101054:	0f 84 89 03 00 00    	je     ffffffff801013e3 <exec+0x4c4>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
ffffffff8010105a:	48 8b 85 30 fe ff ff 	mov    -0x1d0(%rbp),%rax
ffffffff80101061:	89 c7                	mov    %eax,%edi
ffffffff80101063:	48 8b 85 18 fe ff ff 	mov    -0x1e8(%rbp),%rax
ffffffff8010106a:	89 c1                	mov    %eax,%ecx
ffffffff8010106c:	48 8b 85 20 fe ff ff 	mov    -0x1e0(%rbp),%rax
ffffffff80101073:	48 89 c6             	mov    %rax,%rsi
ffffffff80101076:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
ffffffff8010107a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff8010107e:	41 89 f8             	mov    %edi,%r8d
ffffffff80101081:	48 89 c7             	mov    %rax,%rdi
ffffffff80101084:	e8 0a 77 00 00       	callq  ffffffff80108793 <loaduvm>
ffffffff80101089:	85 c0                	test   %eax,%eax
ffffffff8010108b:	0f 88 55 03 00 00    	js     ffffffff801013e6 <exec+0x4c7>
ffffffff80101091:	eb 01                	jmp    ffffffff80101094 <exec+0x175>
      continue;
ffffffff80101093:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
ffffffff80101094:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
ffffffff80101098:	8b 45 e8             	mov    -0x18(%rbp),%eax
ffffffff8010109b:	83 c0 38             	add    $0x38,%eax
ffffffff8010109e:	89 45 e8             	mov    %eax,-0x18(%rbp)
ffffffff801010a1:	0f b7 85 88 fe ff ff 	movzwl -0x178(%rbp),%eax
ffffffff801010a8:	0f b7 c0             	movzwl %ax,%eax
ffffffff801010ab:	39 45 ec             	cmp    %eax,-0x14(%rbp)
ffffffff801010ae:	0f 8c 25 ff ff ff    	jl     ffffffff80100fd9 <exec+0xba>
      goto bad;
  }
  iunlockput(ip);
ffffffff801010b4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff801010b8:	48 89 c7             	mov    %rax,%rdi
ffffffff801010bb:	e8 55 10 00 00       	callq  ffffffff80102115 <iunlockput>
  ip = 0;
ffffffff801010c0:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
ffffffff801010c7:	00 

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
ffffffff801010c8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801010cc:	48 05 ff 0f 00 00    	add    $0xfff,%rax
ffffffff801010d2:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801010d8:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
ffffffff801010dc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801010e0:	8d 90 00 20 00 00    	lea    0x2000(%rax),%edx
ffffffff801010e6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801010ea:	89 c1                	mov    %eax,%ecx
ffffffff801010ec:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801010f0:	89 ce                	mov    %ecx,%esi
ffffffff801010f2:	48 89 c7             	mov    %rax,%rdi
ffffffff801010f5:	e8 94 77 00 00       	callq  ffffffff8010888e <allocuvm>
ffffffff801010fa:	48 98                	cltq   
ffffffff801010fc:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
ffffffff80101100:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
ffffffff80101105:	0f 84 de 02 00 00    	je     ffffffff801013e9 <exec+0x4ca>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
ffffffff8010110b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010110f:	48 2d 00 20 00 00    	sub    $0x2000,%rax
ffffffff80101115:	48 89 c2             	mov    %rax,%rdx
ffffffff80101118:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff8010111c:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010111f:	48 89 c7             	mov    %rax,%rdi
ffffffff80101122:	e8 c8 79 00 00       	callq  ffffffff80108aef <clearpteu>
  sp = sz;
ffffffff80101127:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010112b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
ffffffff8010112f:	48 c7 45 e0 00 00 00 	movq   $0x0,-0x20(%rbp)
ffffffff80101136:	00 
ffffffff80101137:	e9 b5 00 00 00       	jmpq   ffffffff801011f1 <exec+0x2d2>
    if(argc >= MAXARG)
ffffffff8010113c:	48 83 7d e0 1f       	cmpq   $0x1f,-0x20(%rbp)
ffffffff80101141:	0f 87 a5 02 00 00    	ja     ffffffff801013ec <exec+0x4cd>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~(sizeof(uintp)-1);
ffffffff80101147:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010114b:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80101152:	00 
ffffffff80101153:	48 8b 85 00 fe ff ff 	mov    -0x200(%rbp),%rax
ffffffff8010115a:	48 01 d0             	add    %rdx,%rax
ffffffff8010115d:	48 8b 00             	mov    (%rax),%rax
ffffffff80101160:	48 89 c7             	mov    %rax,%rdi
ffffffff80101163:	e8 46 50 00 00       	callq  ffffffff801061ae <strlen>
ffffffff80101168:	83 c0 01             	add    $0x1,%eax
ffffffff8010116b:	48 98                	cltq   
ffffffff8010116d:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
ffffffff80101171:	48 29 c2             	sub    %rax,%rdx
ffffffff80101174:	48 89 d0             	mov    %rdx,%rax
ffffffff80101177:	48 83 e0 f8          	and    $0xfffffffffffffff8,%rax
ffffffff8010117b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
ffffffff8010117f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101183:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff8010118a:	00 
ffffffff8010118b:	48 8b 85 00 fe ff ff 	mov    -0x200(%rbp),%rax
ffffffff80101192:	48 01 d0             	add    %rdx,%rax
ffffffff80101195:	48 8b 00             	mov    (%rax),%rax
ffffffff80101198:	48 89 c7             	mov    %rax,%rdi
ffffffff8010119b:	e8 0e 50 00 00       	callq  ffffffff801061ae <strlen>
ffffffff801011a0:	83 c0 01             	add    $0x1,%eax
ffffffff801011a3:	89 c1                	mov    %eax,%ecx
ffffffff801011a5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801011a9:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff801011b0:	00 
ffffffff801011b1:	48 8b 85 00 fe ff ff 	mov    -0x200(%rbp),%rax
ffffffff801011b8:	48 01 d0             	add    %rdx,%rax
ffffffff801011bb:	48 8b 10             	mov    (%rax),%rdx
ffffffff801011be:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801011c2:	89 c6                	mov    %eax,%esi
ffffffff801011c4:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801011c8:	48 89 c7             	mov    %rax,%rdi
ffffffff801011cb:	e8 25 7b 00 00       	callq  ffffffff80108cf5 <copyout>
ffffffff801011d0:	85 c0                	test   %eax,%eax
ffffffff801011d2:	0f 88 17 02 00 00    	js     ffffffff801013ef <exec+0x4d0>
      goto bad;
    ustack[3+argc] = sp;
ffffffff801011d8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801011dc:	48 8d 50 03          	lea    0x3(%rax),%rdx
ffffffff801011e0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801011e4:	48 89 84 d5 90 fe ff 	mov    %rax,-0x170(%rbp,%rdx,8)
ffffffff801011eb:	ff 
  for(argc = 0; argv[argc]; argc++) {
ffffffff801011ec:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
ffffffff801011f1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801011f5:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff801011fc:	00 
ffffffff801011fd:	48 8b 85 00 fe ff ff 	mov    -0x200(%rbp),%rax
ffffffff80101204:	48 01 d0             	add    %rdx,%rax
ffffffff80101207:	48 8b 00             	mov    (%rax),%rax
ffffffff8010120a:	48 85 c0             	test   %rax,%rax
ffffffff8010120d:	0f 85 29 ff ff ff    	jne    ffffffff8010113c <exec+0x21d>
  }
  ustack[3+argc] = 0;
ffffffff80101213:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101217:	48 83 c0 03          	add    $0x3,%rax
ffffffff8010121b:	48 c7 84 c5 90 fe ff 	movq   $0x0,-0x170(%rbp,%rax,8)
ffffffff80101222:	ff 00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
ffffffff80101227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010122c:	48 89 85 90 fe ff ff 	mov    %rax,-0x170(%rbp)
  ustack[1] = argc;
ffffffff80101233:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101237:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  ustack[2] = sp - (argc+1)*sizeof(uintp);  // argv pointer
ffffffff8010123e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101242:	48 83 c0 01          	add    $0x1,%rax
ffffffff80101246:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff8010124d:	00 
ffffffff8010124e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80101252:	48 29 d0             	sub    %rdx,%rax
ffffffff80101255:	48 89 85 a0 fe ff ff 	mov    %rax,-0x160(%rbp)

#if X64
  proc->tf->rdi = argc;
ffffffff8010125c:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80101263:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80101267:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff8010126b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff8010126f:	48 89 50 30          	mov    %rdx,0x30(%rax)
  proc->tf->rsi = sp - (argc+1)*sizeof(uintp);
ffffffff80101273:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101277:	48 83 c0 01          	add    $0x1,%rax
ffffffff8010127b:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
ffffffff80101282:	00 
ffffffff80101283:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010128a:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010128e:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80101292:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
ffffffff80101296:	48 29 ca             	sub    %rcx,%rdx
ffffffff80101299:	48 89 50 28          	mov    %rdx,0x28(%rax)
#endif

  sp -= (3+argc+1) * sizeof(uintp);
ffffffff8010129d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801012a1:	48 83 c0 04          	add    $0x4,%rax
ffffffff801012a5:	48 c1 e0 03          	shl    $0x3,%rax
ffffffff801012a9:	48 29 45 d0          	sub    %rax,-0x30(%rbp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*sizeof(uintp)) < 0)
ffffffff801012ad:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801012b1:	48 83 c0 04          	add    $0x4,%rax
ffffffff801012b5:	8d 0c c5 00 00 00 00 	lea    0x0(,%rax,8),%ecx
ffffffff801012bc:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801012c0:	89 c6                	mov    %eax,%esi
ffffffff801012c2:	48 8d 95 90 fe ff ff 	lea    -0x170(%rbp),%rdx
ffffffff801012c9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801012cd:	48 89 c7             	mov    %rax,%rdi
ffffffff801012d0:	e8 20 7a 00 00       	callq  ffffffff80108cf5 <copyout>
ffffffff801012d5:	85 c0                	test   %eax,%eax
ffffffff801012d7:	0f 88 15 01 00 00    	js     ffffffff801013f2 <exec+0x4d3>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
ffffffff801012dd:	48 8b 85 08 fe ff ff 	mov    -0x1f8(%rbp),%rax
ffffffff801012e4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801012e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801012ec:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff801012f0:	eb 1c                	jmp    ffffffff8010130e <exec+0x3ef>
    if(*s == '/')
ffffffff801012f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801012f6:	0f b6 00             	movzbl (%rax),%eax
ffffffff801012f9:	3c 2f                	cmp    $0x2f,%al
ffffffff801012fb:	75 0c                	jne    ffffffff80101309 <exec+0x3ea>
      last = s+1;
ffffffff801012fd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101301:	48 83 c0 01          	add    $0x1,%rax
ffffffff80101305:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(last=s=path; *s; s++)
ffffffff80101309:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
ffffffff8010130e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101312:	0f b6 00             	movzbl (%rax),%eax
ffffffff80101315:	84 c0                	test   %al,%al
ffffffff80101317:	75 d9                	jne    ffffffff801012f2 <exec+0x3d3>
  safestrcpy(proc->name, last, sizeof(proc->name));
ffffffff80101319:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80101320:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80101324:	48 8d 88 d0 00 00 00 	lea    0xd0(%rax),%rcx
ffffffff8010132b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010132f:	ba 10 00 00 00       	mov    $0x10,%edx
ffffffff80101334:	48 89 c6             	mov    %rax,%rsi
ffffffff80101337:	48 89 cf             	mov    %rcx,%rdi
ffffffff8010133a:	e8 0d 4e 00 00       	callq  ffffffff8010614c <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
ffffffff8010133f:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80101346:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010134a:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff8010134e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  proc->pgdir = pgdir;
ffffffff80101352:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80101359:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010135d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
ffffffff80101361:	48 89 50 08          	mov    %rdx,0x8(%rax)
  proc->sz = sz;
ffffffff80101365:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010136c:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80101370:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
ffffffff80101374:	48 89 10             	mov    %rdx,(%rax)
  proc->tf->eip = elf.entry;  // main
ffffffff80101377:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010137e:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80101382:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80101386:	48 8b 95 68 fe ff ff 	mov    -0x198(%rbp),%rdx
ffffffff8010138d:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
  proc->tf->esp = sp;
ffffffff80101394:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010139b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010139f:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff801013a3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
ffffffff801013a7:	48 89 90 a0 00 00 00 	mov    %rdx,0xa0(%rax)
  switchuvm(proc);
ffffffff801013ae:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801013b5:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801013b9:	48 89 c7             	mov    %rax,%rdi
ffffffff801013bc:	e8 7e 81 00 00       	callq  ffffffff8010953f <switchuvm>
  freevm(oldpgdir);
ffffffff801013c1:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff801013c5:	48 89 c7             	mov    %rax,%rdi
ffffffff801013c8:	e8 78 76 00 00       	callq  ffffffff80108a45 <freevm>
  return 0;
ffffffff801013cd:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801013d2:	eb 4a                	jmp    ffffffff8010141e <exec+0x4ff>
    goto bad;
ffffffff801013d4:	90                   	nop
ffffffff801013d5:	eb 1c                	jmp    ffffffff801013f3 <exec+0x4d4>
    goto bad;
ffffffff801013d7:	90                   	nop
ffffffff801013d8:	eb 19                	jmp    ffffffff801013f3 <exec+0x4d4>
    goto bad;
ffffffff801013da:	90                   	nop
ffffffff801013db:	eb 16                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013dd:	90                   	nop
ffffffff801013de:	eb 13                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013e0:	90                   	nop
ffffffff801013e1:	eb 10                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013e3:	90                   	nop
ffffffff801013e4:	eb 0d                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013e6:	90                   	nop
ffffffff801013e7:	eb 0a                	jmp    ffffffff801013f3 <exec+0x4d4>
    goto bad;
ffffffff801013e9:	90                   	nop
ffffffff801013ea:	eb 07                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013ec:	90                   	nop
ffffffff801013ed:	eb 04                	jmp    ffffffff801013f3 <exec+0x4d4>
      goto bad;
ffffffff801013ef:	90                   	nop
ffffffff801013f0:	eb 01                	jmp    ffffffff801013f3 <exec+0x4d4>
    goto bad;
ffffffff801013f2:	90                   	nop

 bad:
  if(pgdir)
ffffffff801013f3:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
ffffffff801013f8:	74 0c                	je     ffffffff80101406 <exec+0x4e7>
    freevm(pgdir);
ffffffff801013fa:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801013fe:	48 89 c7             	mov    %rax,%rdi
ffffffff80101401:	e8 3f 76 00 00       	callq  ffffffff80108a45 <freevm>
  if(ip)
ffffffff80101406:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
ffffffff8010140b:	74 0c                	je     ffffffff80101419 <exec+0x4fa>
    iunlockput(ip);
ffffffff8010140d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80101411:	48 89 c7             	mov    %rax,%rdi
ffffffff80101414:	e8 fc 0c 00 00       	callq  ffffffff80102115 <iunlockput>
  return -1;
ffffffff80101419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff8010141e:	c9                   	leaveq 
ffffffff8010141f:	c3                   	retq   

ffffffff80101420 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
ffffffff80101420:	55                   	push   %rbp
ffffffff80101421:	48 89 e5             	mov    %rsp,%rbp
  initlock(&ftable.lock, "ftable");
ffffffff80101424:	48 c7 c6 39 96 10 80 	mov    $0xffffffff80109639,%rsi
ffffffff8010142b:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff80101432:	e8 d6 46 00 00       	callq  ffffffff80105b0d <initlock>
}
ffffffff80101437:	90                   	nop
ffffffff80101438:	5d                   	pop    %rbp
ffffffff80101439:	c3                   	retq   

ffffffff8010143a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
ffffffff8010143a:	55                   	push   %rbp
ffffffff8010143b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010143e:	48 83 ec 10          	sub    $0x10,%rsp
  struct file *f;

  acquire(&ftable.lock);
ffffffff80101442:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff80101449:	e8 f4 46 00 00       	callq  ffffffff80105b42 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
ffffffff8010144e:	48 c7 45 f8 a8 ca 10 	movq   $0xffffffff8010caa8,-0x8(%rbp)
ffffffff80101455:	80 
ffffffff80101456:	eb 2d                	jmp    ffffffff80101485 <filealloc+0x4b>
    if(f->ref == 0){
ffffffff80101458:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010145c:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010145f:	85 c0                	test   %eax,%eax
ffffffff80101461:	75 1d                	jne    ffffffff80101480 <filealloc+0x46>
      f->ref = 1;
ffffffff80101463:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101467:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%rax)
      release(&ftable.lock);
ffffffff8010146e:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff80101475:	e8 9f 47 00 00       	callq  ffffffff80105c19 <release>
      return f;
ffffffff8010147a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010147e:	eb 23                	jmp    ffffffff801014a3 <filealloc+0x69>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
ffffffff80101480:	48 83 45 f8 28       	addq   $0x28,-0x8(%rbp)
ffffffff80101485:	48 c7 c0 48 da 10 80 	mov    $0xffffffff8010da48,%rax
ffffffff8010148c:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff80101490:	72 c6                	jb     ffffffff80101458 <filealloc+0x1e>
    }
  }
  release(&ftable.lock);
ffffffff80101492:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff80101499:	e8 7b 47 00 00       	callq  ffffffff80105c19 <release>
  return 0;
ffffffff8010149e:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801014a3:	c9                   	leaveq 
ffffffff801014a4:	c3                   	retq   

ffffffff801014a5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
ffffffff801014a5:	55                   	push   %rbp
ffffffff801014a6:	48 89 e5             	mov    %rsp,%rbp
ffffffff801014a9:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801014ad:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  acquire(&ftable.lock);
ffffffff801014b1:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff801014b8:	e8 85 46 00 00       	callq  ffffffff80105b42 <acquire>
  if(f->ref < 1)
ffffffff801014bd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801014c1:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff801014c4:	85 c0                	test   %eax,%eax
ffffffff801014c6:	7f 0c                	jg     ffffffff801014d4 <filedup+0x2f>
    panic("filedup");
ffffffff801014c8:	48 c7 c7 40 96 10 80 	mov    $0xffffffff80109640,%rdi
ffffffff801014cf:	e8 2a f4 ff ff       	callq  ffffffff801008fe <panic>
  f->ref++;
ffffffff801014d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801014d8:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff801014db:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff801014de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801014e2:	89 50 04             	mov    %edx,0x4(%rax)
  release(&ftable.lock);
ffffffff801014e5:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff801014ec:	e8 28 47 00 00       	callq  ffffffff80105c19 <release>
  return f;
ffffffff801014f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff801014f5:	c9                   	leaveq 
ffffffff801014f6:	c3                   	retq   

ffffffff801014f7 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
ffffffff801014f7:	55                   	push   %rbp
ffffffff801014f8:	48 89 e5             	mov    %rsp,%rbp
ffffffff801014fb:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff801014ff:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  struct file ff;

  acquire(&ftable.lock);
ffffffff80101503:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff8010150a:	e8 33 46 00 00       	callq  ffffffff80105b42 <acquire>
  if(f->ref < 1)
ffffffff8010150f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80101513:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101516:	85 c0                	test   %eax,%eax
ffffffff80101518:	7f 0c                	jg     ffffffff80101526 <fileclose+0x2f>
    panic("fileclose");
ffffffff8010151a:	48 c7 c7 48 96 10 80 	mov    $0xffffffff80109648,%rdi
ffffffff80101521:	e8 d8 f3 ff ff       	callq  ffffffff801008fe <panic>
  if(--f->ref > 0){
ffffffff80101526:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff8010152a:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010152d:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff80101530:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80101534:	89 50 04             	mov    %edx,0x4(%rax)
ffffffff80101537:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff8010153b:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010153e:	85 c0                	test   %eax,%eax
ffffffff80101540:	7e 11                	jle    ffffffff80101553 <fileclose+0x5c>
    release(&ftable.lock);
ffffffff80101542:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff80101549:	e8 cb 46 00 00       	callq  ffffffff80105c19 <release>
ffffffff8010154e:	e9 93 00 00 00       	jmpq   ffffffff801015e6 <fileclose+0xef>
    return;
  }
  ff = *f;
ffffffff80101553:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
ffffffff80101557:	48 8b 01             	mov    (%rcx),%rax
ffffffff8010155a:	48 8b 51 08          	mov    0x8(%rcx),%rdx
ffffffff8010155e:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
ffffffff80101562:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
ffffffff80101566:	48 8b 41 10          	mov    0x10(%rcx),%rax
ffffffff8010156a:	48 8b 51 18          	mov    0x18(%rcx),%rdx
ffffffff8010156e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff80101572:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
ffffffff80101576:	48 8b 41 20          	mov    0x20(%rcx),%rax
ffffffff8010157a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  f->ref = 0;
ffffffff8010157e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80101582:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%rax)
  f->type = FD_NONE;
ffffffff80101589:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff8010158d:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  release(&ftable.lock);
ffffffff80101593:	48 c7 c7 40 ca 10 80 	mov    $0xffffffff8010ca40,%rdi
ffffffff8010159a:	e8 7a 46 00 00       	callq  ffffffff80105c19 <release>
  
  if(ff.type == FD_PIPE)
ffffffff8010159f:	8b 45 d0             	mov    -0x30(%rbp),%eax
ffffffff801015a2:	83 f8 01             	cmp    $0x1,%eax
ffffffff801015a5:	75 17                	jne    ffffffff801015be <fileclose+0xc7>
    pipeclose(ff.pipe, ff.writable);
ffffffff801015a7:	0f b6 45 d9          	movzbl -0x27(%rbp),%eax
ffffffff801015ab:	0f be d0             	movsbl %al,%edx
ffffffff801015ae:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801015b2:	89 d6                	mov    %edx,%esi
ffffffff801015b4:	48 89 c7             	mov    %rax,%rdi
ffffffff801015b7:	e8 a7 34 00 00       	callq  ffffffff80104a63 <pipeclose>
ffffffff801015bc:	eb 28                	jmp    ffffffff801015e6 <fileclose+0xef>
  else if(ff.type == FD_INODE){
ffffffff801015be:	8b 45 d0             	mov    -0x30(%rbp),%eax
ffffffff801015c1:	83 f8 02             	cmp    $0x2,%eax
ffffffff801015c4:	75 20                	jne    ffffffff801015e6 <fileclose+0xef>
    begin_trans();
ffffffff801015c6:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801015cb:	e8 26 24 00 00       	callq  ffffffff801039f6 <begin_trans>
    iput(ff.ip);
ffffffff801015d0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801015d4:	48 89 c7             	mov    %rax,%rdi
ffffffff801015d7:	e8 54 0a 00 00       	callq  ffffffff80102030 <iput>
    commit_trans();
ffffffff801015dc:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801015e1:	e8 58 24 00 00       	callq  ffffffff80103a3e <commit_trans>
  }
}
ffffffff801015e6:	c9                   	leaveq 
ffffffff801015e7:	c3                   	retq   

ffffffff801015e8 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
ffffffff801015e8:	55                   	push   %rbp
ffffffff801015e9:	48 89 e5             	mov    %rsp,%rbp
ffffffff801015ec:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801015f0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff801015f4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(f->type == FD_INODE){
ffffffff801015f8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801015fc:	8b 00                	mov    (%rax),%eax
ffffffff801015fe:	83 f8 02             	cmp    $0x2,%eax
ffffffff80101601:	75 3e                	jne    ffffffff80101641 <filestat+0x59>
    ilock(f->ip);
ffffffff80101603:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101607:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff8010160b:	48 89 c7             	mov    %rax,%rdi
ffffffff8010160e:	e8 3a 08 00 00       	callq  ffffffff80101e4d <ilock>
    stati(f->ip, st);
ffffffff80101613:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101617:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff8010161b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff8010161f:	48 89 d6             	mov    %rdx,%rsi
ffffffff80101622:	48 89 c7             	mov    %rax,%rdi
ffffffff80101625:	e8 6e 0d 00 00       	callq  ffffffff80102398 <stati>
    iunlock(f->ip);
ffffffff8010162a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010162e:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff80101632:	48 89 c7             	mov    %rax,%rdi
ffffffff80101635:	e8 84 09 00 00       	callq  ffffffff80101fbe <iunlock>
    return 0;
ffffffff8010163a:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010163f:	eb 05                	jmp    ffffffff80101646 <filestat+0x5e>
  }
  return -1;
ffffffff80101641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80101646:	c9                   	leaveq 
ffffffff80101647:	c3                   	retq   

ffffffff80101648 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
ffffffff80101648:	55                   	push   %rbp
ffffffff80101649:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010164c:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80101650:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80101654:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80101658:	89 55 dc             	mov    %edx,-0x24(%rbp)
  int r;

  if(f->readable == 0)
ffffffff8010165b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010165f:	0f b6 40 08          	movzbl 0x8(%rax),%eax
ffffffff80101663:	84 c0                	test   %al,%al
ffffffff80101665:	75 0a                	jne    ffffffff80101671 <fileread+0x29>
    return -1;
ffffffff80101667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010166c:	e9 9d 00 00 00       	jmpq   ffffffff8010170e <fileread+0xc6>
  if(f->type == FD_PIPE)
ffffffff80101671:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101675:	8b 00                	mov    (%rax),%eax
ffffffff80101677:	83 f8 01             	cmp    $0x1,%eax
ffffffff8010167a:	75 1c                	jne    ffffffff80101698 <fileread+0x50>
    return piperead(f->pipe, addr, n);
ffffffff8010167c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101680:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff80101684:	8b 55 dc             	mov    -0x24(%rbp),%edx
ffffffff80101687:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
ffffffff8010168b:	48 89 ce             	mov    %rcx,%rsi
ffffffff8010168e:	48 89 c7             	mov    %rax,%rdi
ffffffff80101691:	e8 87 35 00 00       	callq  ffffffff80104c1d <piperead>
ffffffff80101696:	eb 76                	jmp    ffffffff8010170e <fileread+0xc6>
  if(f->type == FD_INODE){
ffffffff80101698:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010169c:	8b 00                	mov    (%rax),%eax
ffffffff8010169e:	83 f8 02             	cmp    $0x2,%eax
ffffffff801016a1:	75 5f                	jne    ffffffff80101702 <fileread+0xba>
    ilock(f->ip);
ffffffff801016a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016a7:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff801016ab:	48 89 c7             	mov    %rax,%rdi
ffffffff801016ae:	e8 9a 07 00 00       	callq  ffffffff80101e4d <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
ffffffff801016b3:	8b 4d dc             	mov    -0x24(%rbp),%ecx
ffffffff801016b6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016ba:	8b 50 20             	mov    0x20(%rax),%edx
ffffffff801016bd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016c1:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff801016c5:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
ffffffff801016c9:	48 89 c7             	mov    %rax,%rdi
ffffffff801016cc:	e8 24 0d 00 00       	callq  ffffffff801023f5 <readi>
ffffffff801016d1:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff801016d4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff801016d8:	7e 13                	jle    ffffffff801016ed <fileread+0xa5>
      f->off += r;
ffffffff801016da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016de:	8b 50 20             	mov    0x20(%rax),%edx
ffffffff801016e1:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801016e4:	01 c2                	add    %eax,%edx
ffffffff801016e6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016ea:	89 50 20             	mov    %edx,0x20(%rax)
    iunlock(f->ip);
ffffffff801016ed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801016f1:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff801016f5:	48 89 c7             	mov    %rax,%rdi
ffffffff801016f8:	e8 c1 08 00 00       	callq  ffffffff80101fbe <iunlock>
    return r;
ffffffff801016fd:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101700:	eb 0c                	jmp    ffffffff8010170e <fileread+0xc6>
  }
  panic("fileread");
ffffffff80101702:	48 c7 c7 52 96 10 80 	mov    $0xffffffff80109652,%rdi
ffffffff80101709:	e8 f0 f1 ff ff       	callq  ffffffff801008fe <panic>
}
ffffffff8010170e:	c9                   	leaveq 
ffffffff8010170f:	c3                   	retq   

ffffffff80101710 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
ffffffff80101710:	55                   	push   %rbp
ffffffff80101711:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101714:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80101718:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff8010171c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80101720:	89 55 dc             	mov    %edx,-0x24(%rbp)
  int r;

  if(f->writable == 0)
ffffffff80101723:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101727:	0f b6 40 09          	movzbl 0x9(%rax),%eax
ffffffff8010172b:	84 c0                	test   %al,%al
ffffffff8010172d:	75 0a                	jne    ffffffff80101739 <filewrite+0x29>
    return -1;
ffffffff8010172f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80101734:	e9 29 01 00 00       	jmpq   ffffffff80101862 <filewrite+0x152>
  if(f->type == FD_PIPE)
ffffffff80101739:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010173d:	8b 00                	mov    (%rax),%eax
ffffffff8010173f:	83 f8 01             	cmp    $0x1,%eax
ffffffff80101742:	75 1f                	jne    ffffffff80101763 <filewrite+0x53>
    return pipewrite(f->pipe, addr, n);
ffffffff80101744:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101748:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff8010174c:	8b 55 dc             	mov    -0x24(%rbp),%edx
ffffffff8010174f:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
ffffffff80101753:	48 89 ce             	mov    %rcx,%rsi
ffffffff80101756:	48 89 c7             	mov    %rax,%rdi
ffffffff80101759:	e8 ad 33 00 00       	callq  ffffffff80104b0b <pipewrite>
ffffffff8010175e:	e9 ff 00 00 00       	jmpq   ffffffff80101862 <filewrite+0x152>
  if(f->type == FD_INODE){
ffffffff80101763:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101767:	8b 00                	mov    (%rax),%eax
ffffffff80101769:	83 f8 02             	cmp    $0x2,%eax
ffffffff8010176c:	0f 85 e4 00 00 00    	jne    ffffffff80101856 <filewrite+0x146>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
ffffffff80101772:	c7 45 f4 00 06 00 00 	movl   $0x600,-0xc(%rbp)
    int i = 0;
ffffffff80101779:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    while(i < n){
ffffffff80101780:	e9 ae 00 00 00       	jmpq   ffffffff80101833 <filewrite+0x123>
      int n1 = n - i;
ffffffff80101785:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80101788:	2b 45 fc             	sub    -0x4(%rbp),%eax
ffffffff8010178b:	89 45 f8             	mov    %eax,-0x8(%rbp)
      if(n1 > max)
ffffffff8010178e:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80101791:	3b 45 f4             	cmp    -0xc(%rbp),%eax
ffffffff80101794:	7e 06                	jle    ffffffff8010179c <filewrite+0x8c>
        n1 = max;
ffffffff80101796:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80101799:	89 45 f8             	mov    %eax,-0x8(%rbp)

      begin_trans();
ffffffff8010179c:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801017a1:	e8 50 22 00 00       	callq  ffffffff801039f6 <begin_trans>
      ilock(f->ip);
ffffffff801017a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017aa:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff801017ae:	48 89 c7             	mov    %rax,%rdi
ffffffff801017b1:	e8 97 06 00 00       	callq  ffffffff80101e4d <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
ffffffff801017b6:	8b 4d f8             	mov    -0x8(%rbp),%ecx
ffffffff801017b9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017bd:	8b 50 20             	mov    0x20(%rax),%edx
ffffffff801017c0:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801017c3:	48 63 f0             	movslq %eax,%rsi
ffffffff801017c6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801017ca:	48 01 c6             	add    %rax,%rsi
ffffffff801017cd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017d1:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff801017d5:	48 89 c7             	mov    %rax,%rdi
ffffffff801017d8:	e8 98 0d 00 00       	callq  ffffffff80102575 <writei>
ffffffff801017dd:	89 45 f0             	mov    %eax,-0x10(%rbp)
ffffffff801017e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
ffffffff801017e4:	7e 13                	jle    ffffffff801017f9 <filewrite+0xe9>
        f->off += r;
ffffffff801017e6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017ea:	8b 50 20             	mov    0x20(%rax),%edx
ffffffff801017ed:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff801017f0:	01 c2                	add    %eax,%edx
ffffffff801017f2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017f6:	89 50 20             	mov    %edx,0x20(%rax)
      iunlock(f->ip);
ffffffff801017f9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801017fd:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff80101801:	48 89 c7             	mov    %rax,%rdi
ffffffff80101804:	e8 b5 07 00 00       	callq  ffffffff80101fbe <iunlock>
      commit_trans();
ffffffff80101809:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010180e:	e8 2b 22 00 00       	callq  ffffffff80103a3e <commit_trans>

      if(r < 0)
ffffffff80101813:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
ffffffff80101817:	78 28                	js     ffffffff80101841 <filewrite+0x131>
        break;
      if(r != n1)
ffffffff80101819:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff8010181c:	3b 45 f8             	cmp    -0x8(%rbp),%eax
ffffffff8010181f:	74 0c                	je     ffffffff8010182d <filewrite+0x11d>
        panic("short filewrite");
ffffffff80101821:	48 c7 c7 5b 96 10 80 	mov    $0xffffffff8010965b,%rdi
ffffffff80101828:	e8 d1 f0 ff ff       	callq  ffffffff801008fe <panic>
      i += r;
ffffffff8010182d:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff80101830:	01 45 fc             	add    %eax,-0x4(%rbp)
    while(i < n){
ffffffff80101833:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101836:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80101839:	0f 8c 46 ff ff ff    	jl     ffffffff80101785 <filewrite+0x75>
ffffffff8010183f:	eb 01                	jmp    ffffffff80101842 <filewrite+0x132>
        break;
ffffffff80101841:	90                   	nop
    }
    return i == n ? n : -1;
ffffffff80101842:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101845:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80101848:	75 05                	jne    ffffffff8010184f <filewrite+0x13f>
ffffffff8010184a:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff8010184d:	eb 13                	jmp    ffffffff80101862 <filewrite+0x152>
ffffffff8010184f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80101854:	eb 0c                	jmp    ffffffff80101862 <filewrite+0x152>
  }
  panic("filewrite");
ffffffff80101856:	48 c7 c7 6b 96 10 80 	mov    $0xffffffff8010966b,%rdi
ffffffff8010185d:	e8 9c f0 ff ff       	callq  ffffffff801008fe <panic>
}
ffffffff80101862:	c9                   	leaveq 
ffffffff80101863:	c3                   	retq   

ffffffff80101864 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
ffffffff80101864:	55                   	push   %rbp
ffffffff80101865:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101868:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff8010186c:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff8010186f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct buf *bp;
  
  bp = bread(dev, 1);
ffffffff80101873:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80101876:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff8010187b:	89 c7                	mov    %eax,%edi
ffffffff8010187d:	e8 54 ea ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101882:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memmove(sb, bp->data, sizeof(*sb));
ffffffff80101886:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010188a:	48 8d 48 28          	lea    0x28(%rax),%rcx
ffffffff8010188e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80101892:	ba 10 00 00 00       	mov    $0x10,%edx
ffffffff80101897:	48 89 ce             	mov    %rcx,%rsi
ffffffff8010189a:	48 89 c7             	mov    %rax,%rdi
ffffffff8010189d:	e8 fe 46 00 00       	callq  ffffffff80105fa0 <memmove>
  brelse(bp);
ffffffff801018a2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801018a6:	48 89 c7             	mov    %rax,%rdi
ffffffff801018a9:	e8 ad ea ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff801018ae:	90                   	nop
ffffffff801018af:	c9                   	leaveq 
ffffffff801018b0:	c3                   	retq   

ffffffff801018b1 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
ffffffff801018b1:	55                   	push   %rbp
ffffffff801018b2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801018b5:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801018b9:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff801018bc:	89 75 e8             	mov    %esi,-0x18(%rbp)
  struct buf *bp;
  
  bp = bread(dev, bno);
ffffffff801018bf:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff801018c2:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801018c5:	89 d6                	mov    %edx,%esi
ffffffff801018c7:	89 c7                	mov    %eax,%edi
ffffffff801018c9:	e8 08 ea ff ff       	callq  ffffffff801002d6 <bread>
ffffffff801018ce:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(bp->data, 0, BSIZE);
ffffffff801018d2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801018d6:	48 83 c0 28          	add    $0x28,%rax
ffffffff801018da:	ba 00 02 00 00       	mov    $0x200,%edx
ffffffff801018df:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801018e4:	48 89 c7             	mov    %rax,%rdi
ffffffff801018e7:	e8 c5 45 00 00       	callq  ffffffff80105eb1 <memset>
  log_write(bp);
ffffffff801018ec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801018f0:	48 89 c7             	mov    %rax,%rdi
ffffffff801018f3:	e8 9e 21 00 00       	callq  ffffffff80103a96 <log_write>
  brelse(bp);
ffffffff801018f8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801018fc:	48 89 c7             	mov    %rax,%rdi
ffffffff801018ff:	e8 57 ea ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff80101904:	90                   	nop
ffffffff80101905:	c9                   	leaveq 
ffffffff80101906:	c3                   	retq   

ffffffff80101907 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
ffffffff80101907:	55                   	push   %rbp
ffffffff80101908:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010190b:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff8010190f:	89 7d cc             	mov    %edi,-0x34(%rbp)
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
ffffffff80101912:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
ffffffff80101919:	00 
  readsb(dev, &sb);
ffffffff8010191a:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff8010191d:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
ffffffff80101921:	48 89 d6             	mov    %rdx,%rsi
ffffffff80101924:	89 c7                	mov    %eax,%edi
ffffffff80101926:	e8 39 ff ff ff       	callq  ffffffff80101864 <readsb>
  for(b = 0; b < sb.size; b += BPB){
ffffffff8010192b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80101932:	e9 15 01 00 00       	jmpq   ffffffff80101a4c <balloc+0x145>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
ffffffff80101937:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010193a:	8d 90 ff 0f 00 00    	lea    0xfff(%rax),%edx
ffffffff80101940:	85 c0                	test   %eax,%eax
ffffffff80101942:	0f 48 c2             	cmovs  %edx,%eax
ffffffff80101945:	c1 f8 0c             	sar    $0xc,%eax
ffffffff80101948:	89 c2                	mov    %eax,%edx
ffffffff8010194a:	8b 45 d8             	mov    -0x28(%rbp),%eax
ffffffff8010194d:	c1 e8 03             	shr    $0x3,%eax
ffffffff80101950:	01 d0                	add    %edx,%eax
ffffffff80101952:	8d 50 03             	lea    0x3(%rax),%edx
ffffffff80101955:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80101958:	89 d6                	mov    %edx,%esi
ffffffff8010195a:	89 c7                	mov    %eax,%edi
ffffffff8010195c:	e8 75 e9 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101961:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
ffffffff80101965:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
ffffffff8010196c:	e9 aa 00 00 00       	jmpq   ffffffff80101a1b <balloc+0x114>
      m = 1 << (bi % 8);
ffffffff80101971:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80101974:	99                   	cltd   
ffffffff80101975:	c1 ea 1d             	shr    $0x1d,%edx
ffffffff80101978:	01 d0                	add    %edx,%eax
ffffffff8010197a:	83 e0 07             	and    $0x7,%eax
ffffffff8010197d:	29 d0                	sub    %edx,%eax
ffffffff8010197f:	ba 01 00 00 00       	mov    $0x1,%edx
ffffffff80101984:	89 c1                	mov    %eax,%ecx
ffffffff80101986:	d3 e2                	shl    %cl,%edx
ffffffff80101988:	89 d0                	mov    %edx,%eax
ffffffff8010198a:	89 45 ec             	mov    %eax,-0x14(%rbp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
ffffffff8010198d:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80101990:	8d 50 07             	lea    0x7(%rax),%edx
ffffffff80101993:	85 c0                	test   %eax,%eax
ffffffff80101995:	0f 48 c2             	cmovs  %edx,%eax
ffffffff80101998:	c1 f8 03             	sar    $0x3,%eax
ffffffff8010199b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff8010199f:	48 98                	cltq   
ffffffff801019a1:	0f b6 44 02 28       	movzbl 0x28(%rdx,%rax,1),%eax
ffffffff801019a6:	0f b6 c0             	movzbl %al,%eax
ffffffff801019a9:	23 45 ec             	and    -0x14(%rbp),%eax
ffffffff801019ac:	85 c0                	test   %eax,%eax
ffffffff801019ae:	75 67                	jne    ffffffff80101a17 <balloc+0x110>
        bp->data[bi/8] |= m;  // Mark block in use.
ffffffff801019b0:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff801019b3:	8d 50 07             	lea    0x7(%rax),%edx
ffffffff801019b6:	85 c0                	test   %eax,%eax
ffffffff801019b8:	0f 48 c2             	cmovs  %edx,%eax
ffffffff801019bb:	c1 f8 03             	sar    $0x3,%eax
ffffffff801019be:	89 c1                	mov    %eax,%ecx
ffffffff801019c0:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff801019c4:	48 63 c1             	movslq %ecx,%rax
ffffffff801019c7:	0f b6 44 02 28       	movzbl 0x28(%rdx,%rax,1),%eax
ffffffff801019cc:	89 c2                	mov    %eax,%edx
ffffffff801019ce:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801019d1:	09 d0                	or     %edx,%eax
ffffffff801019d3:	89 c6                	mov    %eax,%esi
ffffffff801019d5:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff801019d9:	48 63 c1             	movslq %ecx,%rax
ffffffff801019dc:	40 88 74 02 28       	mov    %sil,0x28(%rdx,%rax,1)
        log_write(bp);
ffffffff801019e1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801019e5:	48 89 c7             	mov    %rax,%rdi
ffffffff801019e8:	e8 a9 20 00 00       	callq  ffffffff80103a96 <log_write>
        brelse(bp);
ffffffff801019ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801019f1:	48 89 c7             	mov    %rax,%rdi
ffffffff801019f4:	e8 62 e9 ff ff       	callq  ffffffff8010035b <brelse>
        bzero(dev, b + bi);
ffffffff801019f9:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801019fc:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff801019ff:	01 c2                	add    %eax,%edx
ffffffff80101a01:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80101a04:	89 d6                	mov    %edx,%esi
ffffffff80101a06:	89 c7                	mov    %eax,%edi
ffffffff80101a08:	e8 a4 fe ff ff       	callq  ffffffff801018b1 <bzero>
        return b + bi;
ffffffff80101a0d:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80101a10:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80101a13:	01 d0                	add    %edx,%eax
ffffffff80101a15:	eb 4f                	jmp    ffffffff80101a66 <balloc+0x15f>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
ffffffff80101a17:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
ffffffff80101a1b:	81 7d f8 ff 0f 00 00 	cmpl   $0xfff,-0x8(%rbp)
ffffffff80101a22:	7f 15                	jg     ffffffff80101a39 <balloc+0x132>
ffffffff80101a24:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80101a27:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80101a2a:	01 d0                	add    %edx,%eax
ffffffff80101a2c:	89 c2                	mov    %eax,%edx
ffffffff80101a2e:	8b 45 d0             	mov    -0x30(%rbp),%eax
ffffffff80101a31:	39 c2                	cmp    %eax,%edx
ffffffff80101a33:	0f 82 38 ff ff ff    	jb     ffffffff80101971 <balloc+0x6a>
      }
    }
    brelse(bp);
ffffffff80101a39:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101a3d:	48 89 c7             	mov    %rax,%rdi
ffffffff80101a40:	e8 16 e9 ff ff       	callq  ffffffff8010035b <brelse>
  for(b = 0; b < sb.size; b += BPB){
ffffffff80101a45:	81 45 fc 00 10 00 00 	addl   $0x1000,-0x4(%rbp)
ffffffff80101a4c:	8b 55 d0             	mov    -0x30(%rbp),%edx
ffffffff80101a4f:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101a52:	39 c2                	cmp    %eax,%edx
ffffffff80101a54:	0f 87 dd fe ff ff    	ja     ffffffff80101937 <balloc+0x30>
  }
  panic("balloc: out of blocks");
ffffffff80101a5a:	48 c7 c7 75 96 10 80 	mov    $0xffffffff80109675,%rdi
ffffffff80101a61:	e8 98 ee ff ff       	callq  ffffffff801008fe <panic>
}
ffffffff80101a66:	c9                   	leaveq 
ffffffff80101a67:	c3                   	retq   

ffffffff80101a68 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
ffffffff80101a68:	55                   	push   %rbp
ffffffff80101a69:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101a6c:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80101a70:	89 7d dc             	mov    %edi,-0x24(%rbp)
ffffffff80101a73:	89 75 d8             	mov    %esi,-0x28(%rbp)
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
ffffffff80101a76:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
ffffffff80101a7a:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80101a7d:	48 89 d6             	mov    %rdx,%rsi
ffffffff80101a80:	89 c7                	mov    %eax,%edi
ffffffff80101a82:	e8 dd fd ff ff       	callq  ffffffff80101864 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
ffffffff80101a87:	8b 45 d8             	mov    -0x28(%rbp),%eax
ffffffff80101a8a:	c1 e8 0c             	shr    $0xc,%eax
ffffffff80101a8d:	89 c2                	mov    %eax,%edx
ffffffff80101a8f:	8b 45 e8             	mov    -0x18(%rbp),%eax
ffffffff80101a92:	c1 e8 03             	shr    $0x3,%eax
ffffffff80101a95:	01 d0                	add    %edx,%eax
ffffffff80101a97:	8d 50 03             	lea    0x3(%rax),%edx
ffffffff80101a9a:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80101a9d:	89 d6                	mov    %edx,%esi
ffffffff80101a9f:	89 c7                	mov    %eax,%edi
ffffffff80101aa1:	e8 30 e8 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101aa6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  bi = b % BPB;
ffffffff80101aaa:	8b 45 d8             	mov    -0x28(%rbp),%eax
ffffffff80101aad:	25 ff 0f 00 00       	and    $0xfff,%eax
ffffffff80101ab2:	89 45 f4             	mov    %eax,-0xc(%rbp)
  m = 1 << (bi % 8);
ffffffff80101ab5:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80101ab8:	99                   	cltd   
ffffffff80101ab9:	c1 ea 1d             	shr    $0x1d,%edx
ffffffff80101abc:	01 d0                	add    %edx,%eax
ffffffff80101abe:	83 e0 07             	and    $0x7,%eax
ffffffff80101ac1:	29 d0                	sub    %edx,%eax
ffffffff80101ac3:	ba 01 00 00 00       	mov    $0x1,%edx
ffffffff80101ac8:	89 c1                	mov    %eax,%ecx
ffffffff80101aca:	d3 e2                	shl    %cl,%edx
ffffffff80101acc:	89 d0                	mov    %edx,%eax
ffffffff80101ace:	89 45 f0             	mov    %eax,-0x10(%rbp)
  if((bp->data[bi/8] & m) == 0)
ffffffff80101ad1:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80101ad4:	8d 50 07             	lea    0x7(%rax),%edx
ffffffff80101ad7:	85 c0                	test   %eax,%eax
ffffffff80101ad9:	0f 48 c2             	cmovs  %edx,%eax
ffffffff80101adc:	c1 f8 03             	sar    $0x3,%eax
ffffffff80101adf:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80101ae3:	48 98                	cltq   
ffffffff80101ae5:	0f b6 44 02 28       	movzbl 0x28(%rdx,%rax,1),%eax
ffffffff80101aea:	0f b6 c0             	movzbl %al,%eax
ffffffff80101aed:	23 45 f0             	and    -0x10(%rbp),%eax
ffffffff80101af0:	85 c0                	test   %eax,%eax
ffffffff80101af2:	75 0c                	jne    ffffffff80101b00 <bfree+0x98>
    panic("freeing free block");
ffffffff80101af4:	48 c7 c7 8b 96 10 80 	mov    $0xffffffff8010968b,%rdi
ffffffff80101afb:	e8 fe ed ff ff       	callq  ffffffff801008fe <panic>
  bp->data[bi/8] &= ~m;
ffffffff80101b00:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80101b03:	8d 50 07             	lea    0x7(%rax),%edx
ffffffff80101b06:	85 c0                	test   %eax,%eax
ffffffff80101b08:	0f 48 c2             	cmovs  %edx,%eax
ffffffff80101b0b:	c1 f8 03             	sar    $0x3,%eax
ffffffff80101b0e:	89 c1                	mov    %eax,%ecx
ffffffff80101b10:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80101b14:	48 63 c1             	movslq %ecx,%rax
ffffffff80101b17:	0f b6 44 02 28       	movzbl 0x28(%rdx,%rax,1),%eax
ffffffff80101b1c:	89 c2                	mov    %eax,%edx
ffffffff80101b1e:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff80101b21:	f7 d0                	not    %eax
ffffffff80101b23:	21 d0                	and    %edx,%eax
ffffffff80101b25:	89 c6                	mov    %eax,%esi
ffffffff80101b27:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80101b2b:	48 63 c1             	movslq %ecx,%rax
ffffffff80101b2e:	40 88 74 02 28       	mov    %sil,0x28(%rdx,%rax,1)
  log_write(bp);
ffffffff80101b33:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101b37:	48 89 c7             	mov    %rax,%rdi
ffffffff80101b3a:	e8 57 1f 00 00       	callq  ffffffff80103a96 <log_write>
  brelse(bp);
ffffffff80101b3f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101b43:	48 89 c7             	mov    %rax,%rdi
ffffffff80101b46:	e8 10 e8 ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff80101b4b:	90                   	nop
ffffffff80101b4c:	c9                   	leaveq 
ffffffff80101b4d:	c3                   	retq   

ffffffff80101b4e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
ffffffff80101b4e:	55                   	push   %rbp
ffffffff80101b4f:	48 89 e5             	mov    %rsp,%rbp
  initlock(&icache.lock, "icache");
ffffffff80101b52:	48 c7 c6 9e 96 10 80 	mov    $0xffffffff8010969e,%rsi
ffffffff80101b59:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101b60:	e8 a8 3f 00 00       	callq  ffffffff80105b0d <initlock>
}
ffffffff80101b65:	90                   	nop
ffffffff80101b66:	5d                   	pop    %rbp
ffffffff80101b67:	c3                   	retq   

ffffffff80101b68 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
ffffffff80101b68:	55                   	push   %rbp
ffffffff80101b69:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101b6c:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff80101b70:	89 7d cc             	mov    %edi,-0x34(%rbp)
ffffffff80101b73:	89 f0                	mov    %esi,%eax
ffffffff80101b75:	66 89 45 c8          	mov    %ax,-0x38(%rbp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
ffffffff80101b79:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80101b7c:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
ffffffff80101b80:	48 89 d6             	mov    %rdx,%rsi
ffffffff80101b83:	89 c7                	mov    %eax,%edi
ffffffff80101b85:	e8 da fc ff ff       	callq  ffffffff80101864 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
ffffffff80101b8a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
ffffffff80101b91:	e9 9d 00 00 00       	jmpq   ffffffff80101c33 <ialloc+0xcb>
    bp = bread(dev, IBLOCK(inum));
ffffffff80101b96:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101b99:	48 98                	cltq   
ffffffff80101b9b:	48 c1 e8 03          	shr    $0x3,%rax
ffffffff80101b9f:	8d 50 02             	lea    0x2(%rax),%edx
ffffffff80101ba2:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80101ba5:	89 d6                	mov    %edx,%esi
ffffffff80101ba7:	89 c7                	mov    %eax,%edi
ffffffff80101ba9:	e8 28 e7 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101bae:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    dip = (struct dinode*)bp->data + inum%IPB;
ffffffff80101bb2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101bb6:	48 8d 50 28          	lea    0x28(%rax),%rdx
ffffffff80101bba:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101bbd:	48 98                	cltq   
ffffffff80101bbf:	83 e0 07             	and    $0x7,%eax
ffffffff80101bc2:	48 c1 e0 06          	shl    $0x6,%rax
ffffffff80101bc6:	48 01 d0             	add    %rdx,%rax
ffffffff80101bc9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    if(dip->type == 0){  // a free inode
ffffffff80101bcd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101bd1:	0f b7 00             	movzwl (%rax),%eax
ffffffff80101bd4:	66 85 c0             	test   %ax,%ax
ffffffff80101bd7:	75 4a                	jne    ffffffff80101c23 <ialloc+0xbb>
      memset(dip, 0, sizeof(*dip));
ffffffff80101bd9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101bdd:	ba 40 00 00 00       	mov    $0x40,%edx
ffffffff80101be2:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80101be7:	48 89 c7             	mov    %rax,%rdi
ffffffff80101bea:	e8 c2 42 00 00       	callq  ffffffff80105eb1 <memset>
      dip->type = type;
ffffffff80101bef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101bf3:	0f b7 55 c8          	movzwl -0x38(%rbp),%edx
ffffffff80101bf7:	66 89 10             	mov    %dx,(%rax)
      log_write(bp);   // mark it allocated on the disk
ffffffff80101bfa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101bfe:	48 89 c7             	mov    %rax,%rdi
ffffffff80101c01:	e8 90 1e 00 00       	callq  ffffffff80103a96 <log_write>
      brelse(bp);
ffffffff80101c06:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101c0a:	48 89 c7             	mov    %rax,%rdi
ffffffff80101c0d:	e8 49 e7 ff ff       	callq  ffffffff8010035b <brelse>
      return iget(dev, inum);
ffffffff80101c12:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80101c15:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80101c18:	89 d6                	mov    %edx,%esi
ffffffff80101c1a:	89 c7                	mov    %eax,%edi
ffffffff80101c1c:	e8 01 01 00 00       	callq  ffffffff80101d22 <iget>
ffffffff80101c21:	eb 2a                	jmp    ffffffff80101c4d <ialloc+0xe5>
    }
    brelse(bp);
ffffffff80101c23:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101c27:	48 89 c7             	mov    %rax,%rdi
ffffffff80101c2a:	e8 2c e7 ff ff       	callq  ffffffff8010035b <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
ffffffff80101c2f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80101c33:	8b 55 d8             	mov    -0x28(%rbp),%edx
ffffffff80101c36:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80101c39:	39 c2                	cmp    %eax,%edx
ffffffff80101c3b:	0f 87 55 ff ff ff    	ja     ffffffff80101b96 <ialloc+0x2e>
  }
  panic("ialloc: no inodes");
ffffffff80101c41:	48 c7 c7 a5 96 10 80 	mov    $0xffffffff801096a5,%rdi
ffffffff80101c48:	e8 b1 ec ff ff       	callq  ffffffff801008fe <panic>
}
ffffffff80101c4d:	c9                   	leaveq 
ffffffff80101c4e:	c3                   	retq   

ffffffff80101c4f <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
ffffffff80101c4f:	55                   	push   %rbp
ffffffff80101c50:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101c53:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80101c57:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
ffffffff80101c5b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101c5f:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101c62:	c1 e8 03             	shr    $0x3,%eax
ffffffff80101c65:	8d 50 02             	lea    0x2(%rax),%edx
ffffffff80101c68:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101c6c:	8b 00                	mov    (%rax),%eax
ffffffff80101c6e:	89 d6                	mov    %edx,%esi
ffffffff80101c70:	89 c7                	mov    %eax,%edi
ffffffff80101c72:	e8 5f e6 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101c77:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
ffffffff80101c7b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101c7f:	48 8d 50 28          	lea    0x28(%rax),%rdx
ffffffff80101c83:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101c87:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101c8a:	89 c0                	mov    %eax,%eax
ffffffff80101c8c:	83 e0 07             	and    $0x7,%eax
ffffffff80101c8f:	48 c1 e0 06          	shl    $0x6,%rax
ffffffff80101c93:	48 01 d0             	add    %rdx,%rax
ffffffff80101c96:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  dip->type = ip->type;
ffffffff80101c9a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101c9e:	0f b7 50 10          	movzwl 0x10(%rax),%edx
ffffffff80101ca2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101ca6:	66 89 10             	mov    %dx,(%rax)
  dip->major = ip->major;
ffffffff80101ca9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101cad:	0f b7 50 12          	movzwl 0x12(%rax),%edx
ffffffff80101cb1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101cb5:	66 89 50 02          	mov    %dx,0x2(%rax)
  dip->minor = ip->minor;
ffffffff80101cb9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101cbd:	0f b7 50 14          	movzwl 0x14(%rax),%edx
ffffffff80101cc1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101cc5:	66 89 50 04          	mov    %dx,0x4(%rax)
  dip->nlink = ip->nlink;
ffffffff80101cc9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101ccd:	0f b7 50 16          	movzwl 0x16(%rax),%edx
ffffffff80101cd1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101cd5:	66 89 50 06          	mov    %dx,0x6(%rax)
  dip->size = ip->size;
ffffffff80101cd9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101cdd:	8b 50 18             	mov    0x18(%rax),%edx
ffffffff80101ce0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101ce4:	89 50 08             	mov    %edx,0x8(%rax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
ffffffff80101ce7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101ceb:	48 8d 48 1c          	lea    0x1c(%rax),%rcx
ffffffff80101cef:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101cf3:	48 83 c0 0c          	add    $0xc,%rax
ffffffff80101cf7:	ba 34 00 00 00       	mov    $0x34,%edx
ffffffff80101cfc:	48 89 ce             	mov    %rcx,%rsi
ffffffff80101cff:	48 89 c7             	mov    %rax,%rdi
ffffffff80101d02:	e8 99 42 00 00       	callq  ffffffff80105fa0 <memmove>
  log_write(bp);
ffffffff80101d07:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d0b:	48 89 c7             	mov    %rax,%rdi
ffffffff80101d0e:	e8 83 1d 00 00       	callq  ffffffff80103a96 <log_write>
  brelse(bp);
ffffffff80101d13:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d17:	48 89 c7             	mov    %rax,%rdi
ffffffff80101d1a:	e8 3c e6 ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff80101d1f:	90                   	nop
ffffffff80101d20:	c9                   	leaveq 
ffffffff80101d21:	c3                   	retq   

ffffffff80101d22 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
ffffffff80101d22:	55                   	push   %rbp
ffffffff80101d23:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101d26:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80101d2a:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff80101d2d:	89 75 e8             	mov    %esi,-0x18(%rbp)
  struct inode *ip, *empty;

  acquire(&icache.lock);
ffffffff80101d30:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101d37:	e8 06 3e 00 00       	callq  ffffffff80105b42 <acquire>

  // Is the inode already cached?
  empty = 0;
ffffffff80101d3c:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
ffffffff80101d43:	00 
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
ffffffff80101d44:	48 c7 45 f8 c8 da 10 	movq   $0xffffffff8010dac8,-0x8(%rbp)
ffffffff80101d4b:	80 
ffffffff80101d4c:	eb 64                	jmp    ffffffff80101db2 <iget+0x90>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
ffffffff80101d4e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d52:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101d55:	85 c0                	test   %eax,%eax
ffffffff80101d57:	7e 3a                	jle    ffffffff80101d93 <iget+0x71>
ffffffff80101d59:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d5d:	8b 00                	mov    (%rax),%eax
ffffffff80101d5f:	39 45 ec             	cmp    %eax,-0x14(%rbp)
ffffffff80101d62:	75 2f                	jne    ffffffff80101d93 <iget+0x71>
ffffffff80101d64:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d68:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101d6b:	39 45 e8             	cmp    %eax,-0x18(%rbp)
ffffffff80101d6e:	75 23                	jne    ffffffff80101d93 <iget+0x71>
      ip->ref++;
ffffffff80101d70:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d74:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101d77:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80101d7a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d7e:	89 50 08             	mov    %edx,0x8(%rax)
      release(&icache.lock);
ffffffff80101d81:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101d88:	e8 8c 3e 00 00       	callq  ffffffff80105c19 <release>
      return ip;
ffffffff80101d8d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d91:	eb 7d                	jmp    ffffffff80101e10 <iget+0xee>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
ffffffff80101d93:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80101d98:	75 13                	jne    ffffffff80101dad <iget+0x8b>
ffffffff80101d9a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101d9e:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101da1:	85 c0                	test   %eax,%eax
ffffffff80101da3:	75 08                	jne    ffffffff80101dad <iget+0x8b>
      empty = ip;
ffffffff80101da5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101da9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
ffffffff80101dad:	48 83 45 f8 50       	addq   $0x50,-0x8(%rbp)
ffffffff80101db2:	48 81 7d f8 68 ea 10 	cmpq   $0xffffffff8010ea68,-0x8(%rbp)
ffffffff80101db9:	80 
ffffffff80101dba:	72 92                	jb     ffffffff80101d4e <iget+0x2c>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
ffffffff80101dbc:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80101dc1:	75 0c                	jne    ffffffff80101dcf <iget+0xad>
    panic("iget: no inodes");
ffffffff80101dc3:	48 c7 c7 b7 96 10 80 	mov    $0xffffffff801096b7,%rdi
ffffffff80101dca:	e8 2f eb ff ff       	callq  ffffffff801008fe <panic>

  ip = empty;
ffffffff80101dcf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101dd3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  ip->dev = dev;
ffffffff80101dd7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101ddb:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80101dde:	89 10                	mov    %edx,(%rax)
  ip->inum = inum;
ffffffff80101de0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101de4:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff80101de7:	89 50 04             	mov    %edx,0x4(%rax)
  ip->ref = 1;
ffffffff80101dea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101dee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%rax)
  ip->flags = 0;
ffffffff80101df5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101df9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%rax)
  release(&icache.lock);
ffffffff80101e00:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101e07:	e8 0d 3e 00 00       	callq  ffffffff80105c19 <release>

  return ip;
ffffffff80101e0c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80101e10:	c9                   	leaveq 
ffffffff80101e11:	c3                   	retq   

ffffffff80101e12 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
ffffffff80101e12:	55                   	push   %rbp
ffffffff80101e13:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101e16:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80101e1a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  acquire(&icache.lock);
ffffffff80101e1e:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101e25:	e8 18 3d 00 00       	callq  ffffffff80105b42 <acquire>
  ip->ref++;
ffffffff80101e2a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101e2e:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101e31:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80101e34:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101e38:	89 50 08             	mov    %edx,0x8(%rax)
  release(&icache.lock);
ffffffff80101e3b:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101e42:	e8 d2 3d 00 00       	callq  ffffffff80105c19 <release>
  return ip;
ffffffff80101e47:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80101e4b:	c9                   	leaveq 
ffffffff80101e4c:	c3                   	retq   

ffffffff80101e4d <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
ffffffff80101e4d:	55                   	push   %rbp
ffffffff80101e4e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101e51:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80101e55:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
ffffffff80101e59:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff80101e5e:	74 0b                	je     ffffffff80101e6b <ilock+0x1e>
ffffffff80101e60:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101e64:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101e67:	85 c0                	test   %eax,%eax
ffffffff80101e69:	7f 0c                	jg     ffffffff80101e77 <ilock+0x2a>
    panic("ilock");
ffffffff80101e6b:	48 c7 c7 c7 96 10 80 	mov    $0xffffffff801096c7,%rdi
ffffffff80101e72:	e8 87 ea ff ff       	callq  ffffffff801008fe <panic>

  acquire(&icache.lock);
ffffffff80101e77:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101e7e:	e8 bf 3c 00 00       	callq  ffffffff80105b42 <acquire>
  while(ip->flags & I_BUSY)
ffffffff80101e83:	eb 13                	jmp    ffffffff80101e98 <ilock+0x4b>
    sleep(ip, &icache.lock);
ffffffff80101e85:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101e89:	48 c7 c6 60 da 10 80 	mov    $0xffffffff8010da60,%rsi
ffffffff80101e90:	48 89 c7             	mov    %rax,%rdi
ffffffff80101e93:	e8 38 39 00 00       	callq  ffffffff801057d0 <sleep>
  while(ip->flags & I_BUSY)
ffffffff80101e98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101e9c:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80101e9f:	83 e0 01             	and    $0x1,%eax
ffffffff80101ea2:	85 c0                	test   %eax,%eax
ffffffff80101ea4:	75 df                	jne    ffffffff80101e85 <ilock+0x38>
  ip->flags |= I_BUSY;
ffffffff80101ea6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101eaa:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80101ead:	83 c8 01             	or     $0x1,%eax
ffffffff80101eb0:	89 c2                	mov    %eax,%edx
ffffffff80101eb2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101eb6:	89 50 0c             	mov    %edx,0xc(%rax)
  release(&icache.lock);
ffffffff80101eb9:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101ec0:	e8 54 3d 00 00       	callq  ffffffff80105c19 <release>

  if(!(ip->flags & I_VALID)){
ffffffff80101ec5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101ec9:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80101ecc:	83 e0 02             	and    $0x2,%eax
ffffffff80101ecf:	85 c0                	test   %eax,%eax
ffffffff80101ed1:	0f 85 e4 00 00 00    	jne    ffffffff80101fbb <ilock+0x16e>
    bp = bread(ip->dev, IBLOCK(ip->inum));
ffffffff80101ed7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101edb:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101ede:	c1 e8 03             	shr    $0x3,%eax
ffffffff80101ee1:	8d 50 02             	lea    0x2(%rax),%edx
ffffffff80101ee4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101ee8:	8b 00                	mov    (%rax),%eax
ffffffff80101eea:	89 d6                	mov    %edx,%esi
ffffffff80101eec:	89 c7                	mov    %eax,%edi
ffffffff80101eee:	e8 e3 e3 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80101ef3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
ffffffff80101ef7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101efb:	48 8d 50 28          	lea    0x28(%rax),%rdx
ffffffff80101eff:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f03:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80101f06:	89 c0                	mov    %eax,%eax
ffffffff80101f08:	83 e0 07             	and    $0x7,%eax
ffffffff80101f0b:	48 c1 e0 06          	shl    $0x6,%rax
ffffffff80101f0f:	48 01 d0             	add    %rdx,%rax
ffffffff80101f12:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    ip->type = dip->type;
ffffffff80101f16:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f1a:	0f b7 10             	movzwl (%rax),%edx
ffffffff80101f1d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f21:	66 89 50 10          	mov    %dx,0x10(%rax)
    ip->major = dip->major;
ffffffff80101f25:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f29:	0f b7 50 02          	movzwl 0x2(%rax),%edx
ffffffff80101f2d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f31:	66 89 50 12          	mov    %dx,0x12(%rax)
    ip->minor = dip->minor;
ffffffff80101f35:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f39:	0f b7 50 04          	movzwl 0x4(%rax),%edx
ffffffff80101f3d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f41:	66 89 50 14          	mov    %dx,0x14(%rax)
    ip->nlink = dip->nlink;
ffffffff80101f45:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f49:	0f b7 50 06          	movzwl 0x6(%rax),%edx
ffffffff80101f4d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f51:	66 89 50 16          	mov    %dx,0x16(%rax)
    ip->size = dip->size;
ffffffff80101f55:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f59:	8b 50 08             	mov    0x8(%rax),%edx
ffffffff80101f5c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f60:	89 50 18             	mov    %edx,0x18(%rax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
ffffffff80101f63:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80101f67:	48 8d 48 0c          	lea    0xc(%rax),%rcx
ffffffff80101f6b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f6f:	48 83 c0 1c          	add    $0x1c,%rax
ffffffff80101f73:	ba 34 00 00 00       	mov    $0x34,%edx
ffffffff80101f78:	48 89 ce             	mov    %rcx,%rsi
ffffffff80101f7b:	48 89 c7             	mov    %rax,%rdi
ffffffff80101f7e:	e8 1d 40 00 00       	callq  ffffffff80105fa0 <memmove>
    brelse(bp);
ffffffff80101f83:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101f87:	48 89 c7             	mov    %rax,%rdi
ffffffff80101f8a:	e8 cc e3 ff ff       	callq  ffffffff8010035b <brelse>
    ip->flags |= I_VALID;
ffffffff80101f8f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f93:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80101f96:	83 c8 02             	or     $0x2,%eax
ffffffff80101f99:	89 c2                	mov    %eax,%edx
ffffffff80101f9b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101f9f:	89 50 0c             	mov    %edx,0xc(%rax)
    if(ip->type == 0)
ffffffff80101fa2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80101fa6:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80101faa:	66 85 c0             	test   %ax,%ax
ffffffff80101fad:	75 0c                	jne    ffffffff80101fbb <ilock+0x16e>
      panic("ilock: no type");
ffffffff80101faf:	48 c7 c7 cd 96 10 80 	mov    $0xffffffff801096cd,%rdi
ffffffff80101fb6:	e8 43 e9 ff ff       	callq  ffffffff801008fe <panic>
  }
}
ffffffff80101fbb:	90                   	nop
ffffffff80101fbc:	c9                   	leaveq 
ffffffff80101fbd:	c3                   	retq   

ffffffff80101fbe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
ffffffff80101fbe:	55                   	push   %rbp
ffffffff80101fbf:	48 89 e5             	mov    %rsp,%rbp
ffffffff80101fc2:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80101fc6:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
ffffffff80101fca:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80101fcf:	74 19                	je     ffffffff80101fea <iunlock+0x2c>
ffffffff80101fd1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101fd5:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80101fd8:	83 e0 01             	and    $0x1,%eax
ffffffff80101fdb:	85 c0                	test   %eax,%eax
ffffffff80101fdd:	74 0b                	je     ffffffff80101fea <iunlock+0x2c>
ffffffff80101fdf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80101fe3:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80101fe6:	85 c0                	test   %eax,%eax
ffffffff80101fe8:	7f 0c                	jg     ffffffff80101ff6 <iunlock+0x38>
    panic("iunlock");
ffffffff80101fea:	48 c7 c7 dc 96 10 80 	mov    $0xffffffff801096dc,%rdi
ffffffff80101ff1:	e8 08 e9 ff ff       	callq  ffffffff801008fe <panic>

  acquire(&icache.lock);
ffffffff80101ff6:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80101ffd:	e8 40 3b 00 00       	callq  ffffffff80105b42 <acquire>
  ip->flags &= ~I_BUSY;
ffffffff80102002:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102006:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80102009:	83 e0 fe             	and    $0xfffffffe,%eax
ffffffff8010200c:	89 c2                	mov    %eax,%edx
ffffffff8010200e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102012:	89 50 0c             	mov    %edx,0xc(%rax)
  wakeup(ip);
ffffffff80102015:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102019:	48 89 c7             	mov    %rax,%rdi
ffffffff8010201c:	e8 c2 38 00 00       	callq  ffffffff801058e3 <wakeup>
  release(&icache.lock);
ffffffff80102021:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80102028:	e8 ec 3b 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff8010202d:	90                   	nop
ffffffff8010202e:	c9                   	leaveq 
ffffffff8010202f:	c3                   	retq   

ffffffff80102030 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
ffffffff80102030:	55                   	push   %rbp
ffffffff80102031:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102034:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80102038:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  acquire(&icache.lock);
ffffffff8010203c:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff80102043:	e8 fa 3a 00 00       	callq  ffffffff80105b42 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
ffffffff80102048:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010204c:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff8010204f:	83 f8 01             	cmp    $0x1,%eax
ffffffff80102052:	0f 85 9d 00 00 00    	jne    ffffffff801020f5 <iput+0xc5>
ffffffff80102058:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010205c:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff8010205f:	83 e0 02             	and    $0x2,%eax
ffffffff80102062:	85 c0                	test   %eax,%eax
ffffffff80102064:	0f 84 8b 00 00 00    	je     ffffffff801020f5 <iput+0xc5>
ffffffff8010206a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010206e:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80102072:	66 85 c0             	test   %ax,%ax
ffffffff80102075:	75 7e                	jne    ffffffff801020f5 <iput+0xc5>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
ffffffff80102077:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010207b:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff8010207e:	83 e0 01             	and    $0x1,%eax
ffffffff80102081:	85 c0                	test   %eax,%eax
ffffffff80102083:	74 0c                	je     ffffffff80102091 <iput+0x61>
      panic("iput busy");
ffffffff80102085:	48 c7 c7 e4 96 10 80 	mov    $0xffffffff801096e4,%rdi
ffffffff8010208c:	e8 6d e8 ff ff       	callq  ffffffff801008fe <panic>
    ip->flags |= I_BUSY;
ffffffff80102091:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102095:	8b 40 0c             	mov    0xc(%rax),%eax
ffffffff80102098:	83 c8 01             	or     $0x1,%eax
ffffffff8010209b:	89 c2                	mov    %eax,%edx
ffffffff8010209d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020a1:	89 50 0c             	mov    %edx,0xc(%rax)
    release(&icache.lock);
ffffffff801020a4:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff801020ab:	e8 69 3b 00 00       	callq  ffffffff80105c19 <release>
    itrunc(ip);
ffffffff801020b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020b4:	48 89 c7             	mov    %rax,%rdi
ffffffff801020b7:	e8 a0 01 00 00       	callq  ffffffff8010225c <itrunc>
    ip->type = 0;
ffffffff801020bc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020c0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%rax)
    iupdate(ip);
ffffffff801020c6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020ca:	48 89 c7             	mov    %rax,%rdi
ffffffff801020cd:	e8 7d fb ff ff       	callq  ffffffff80101c4f <iupdate>
    acquire(&icache.lock);
ffffffff801020d2:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff801020d9:	e8 64 3a 00 00       	callq  ffffffff80105b42 <acquire>
    ip->flags = 0;
ffffffff801020de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020e2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%rax)
    wakeup(ip);
ffffffff801020e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020ed:	48 89 c7             	mov    %rax,%rdi
ffffffff801020f0:	e8 ee 37 00 00       	callq  ffffffff801058e3 <wakeup>
  }
  ip->ref--;
ffffffff801020f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801020f9:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff801020fc:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff801020ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102103:	89 50 08             	mov    %edx,0x8(%rax)
  release(&icache.lock);
ffffffff80102106:	48 c7 c7 60 da 10 80 	mov    $0xffffffff8010da60,%rdi
ffffffff8010210d:	e8 07 3b 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80102112:	90                   	nop
ffffffff80102113:	c9                   	leaveq 
ffffffff80102114:	c3                   	retq   

ffffffff80102115 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
ffffffff80102115:	55                   	push   %rbp
ffffffff80102116:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102119:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff8010211d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  iunlock(ip);
ffffffff80102121:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102125:	48 89 c7             	mov    %rax,%rdi
ffffffff80102128:	e8 91 fe ff ff       	callq  ffffffff80101fbe <iunlock>
  iput(ip);
ffffffff8010212d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102131:	48 89 c7             	mov    %rax,%rdi
ffffffff80102134:	e8 f7 fe ff ff       	callq  ffffffff80102030 <iput>
}
ffffffff80102139:	90                   	nop
ffffffff8010213a:	c9                   	leaveq 
ffffffff8010213b:	c3                   	retq   

ffffffff8010213c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
ffffffff8010213c:	55                   	push   %rbp
ffffffff8010213d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102140:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80102144:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80102148:	89 75 d4             	mov    %esi,-0x2c(%rbp)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
ffffffff8010214b:	83 7d d4 0b          	cmpl   $0xb,-0x2c(%rbp)
ffffffff8010214f:	77 42                	ja     ffffffff80102193 <bmap+0x57>
    if((addr = ip->addrs[bn]) == 0)
ffffffff80102151:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102155:	8b 55 d4             	mov    -0x2c(%rbp),%edx
ffffffff80102158:	48 83 c2 04          	add    $0x4,%rdx
ffffffff8010215c:	8b 44 90 0c          	mov    0xc(%rax,%rdx,4),%eax
ffffffff80102160:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80102163:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80102167:	75 22                	jne    ffffffff8010218b <bmap+0x4f>
      ip->addrs[bn] = addr = balloc(ip->dev);
ffffffff80102169:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010216d:	8b 00                	mov    (%rax),%eax
ffffffff8010216f:	89 c7                	mov    %eax,%edi
ffffffff80102171:	e8 91 f7 ff ff       	callq  ffffffff80101907 <balloc>
ffffffff80102176:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80102179:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010217d:	8b 55 d4             	mov    -0x2c(%rbp),%edx
ffffffff80102180:	48 8d 4a 04          	lea    0x4(%rdx),%rcx
ffffffff80102184:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102187:	89 54 88 0c          	mov    %edx,0xc(%rax,%rcx,4)
    return addr;
ffffffff8010218b:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010218e:	e9 c7 00 00 00       	jmpq   ffffffff8010225a <bmap+0x11e>
  }
  bn -= NDIRECT;
ffffffff80102193:	83 6d d4 0c          	subl   $0xc,-0x2c(%rbp)

  if(bn < NINDIRECT){
ffffffff80102197:	83 7d d4 7f          	cmpl   $0x7f,-0x2c(%rbp)
ffffffff8010219b:	0f 87 ad 00 00 00    	ja     ffffffff8010224e <bmap+0x112>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
ffffffff801021a1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801021a5:	8b 40 4c             	mov    0x4c(%rax),%eax
ffffffff801021a8:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff801021ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff801021af:	75 1a                	jne    ffffffff801021cb <bmap+0x8f>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
ffffffff801021b1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801021b5:	8b 00                	mov    (%rax),%eax
ffffffff801021b7:	89 c7                	mov    %eax,%edi
ffffffff801021b9:	e8 49 f7 ff ff       	callq  ffffffff80101907 <balloc>
ffffffff801021be:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff801021c1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801021c5:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801021c8:	89 50 4c             	mov    %edx,0x4c(%rax)
    bp = bread(ip->dev, addr);
ffffffff801021cb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801021cf:	8b 00                	mov    (%rax),%eax
ffffffff801021d1:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801021d4:	89 d6                	mov    %edx,%esi
ffffffff801021d6:	89 c7                	mov    %eax,%edi
ffffffff801021d8:	e8 f9 e0 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff801021dd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    a = (uint*)bp->data;
ffffffff801021e1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801021e5:	48 83 c0 28          	add    $0x28,%rax
ffffffff801021e9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    if((addr = a[bn]) == 0){
ffffffff801021ed:	8b 45 d4             	mov    -0x2c(%rbp),%eax
ffffffff801021f0:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff801021f7:	00 
ffffffff801021f8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801021fc:	48 01 d0             	add    %rdx,%rax
ffffffff801021ff:	8b 00                	mov    (%rax),%eax
ffffffff80102201:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80102204:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80102208:	75 33                	jne    ffffffff8010223d <bmap+0x101>
      a[bn] = addr = balloc(ip->dev);
ffffffff8010220a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010220e:	8b 00                	mov    (%rax),%eax
ffffffff80102210:	89 c7                	mov    %eax,%edi
ffffffff80102212:	e8 f0 f6 ff ff       	callq  ffffffff80101907 <balloc>
ffffffff80102217:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff8010221a:	8b 45 d4             	mov    -0x2c(%rbp),%eax
ffffffff8010221d:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff80102224:	00 
ffffffff80102225:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102229:	48 01 c2             	add    %rax,%rdx
ffffffff8010222c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010222f:	89 02                	mov    %eax,(%rdx)
      log_write(bp);
ffffffff80102231:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102235:	48 89 c7             	mov    %rax,%rdi
ffffffff80102238:	e8 59 18 00 00       	callq  ffffffff80103a96 <log_write>
    }
    brelse(bp);
ffffffff8010223d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102241:	48 89 c7             	mov    %rax,%rdi
ffffffff80102244:	e8 12 e1 ff ff       	callq  ffffffff8010035b <brelse>
    return addr;
ffffffff80102249:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010224c:	eb 0c                	jmp    ffffffff8010225a <bmap+0x11e>
  }

  panic("bmap: out of range");
ffffffff8010224e:	48 c7 c7 ee 96 10 80 	mov    $0xffffffff801096ee,%rdi
ffffffff80102255:	e8 a4 e6 ff ff       	callq  ffffffff801008fe <panic>
}
ffffffff8010225a:	c9                   	leaveq 
ffffffff8010225b:	c3                   	retq   

ffffffff8010225c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
ffffffff8010225c:	55                   	push   %rbp
ffffffff8010225d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102260:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80102264:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
ffffffff80102268:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010226f:	eb 51                	jmp    ffffffff801022c2 <itrunc+0x66>
    if(ip->addrs[i]){
ffffffff80102271:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102275:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102278:	48 63 d2             	movslq %edx,%rdx
ffffffff8010227b:	48 83 c2 04          	add    $0x4,%rdx
ffffffff8010227f:	8b 44 90 0c          	mov    0xc(%rax,%rdx,4),%eax
ffffffff80102283:	85 c0                	test   %eax,%eax
ffffffff80102285:	74 37                	je     ffffffff801022be <itrunc+0x62>
      bfree(ip->dev, ip->addrs[i]);
ffffffff80102287:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010228b:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff8010228e:	48 63 d2             	movslq %edx,%rdx
ffffffff80102291:	48 83 c2 04          	add    $0x4,%rdx
ffffffff80102295:	8b 44 90 0c          	mov    0xc(%rax,%rdx,4),%eax
ffffffff80102299:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
ffffffff8010229d:	8b 12                	mov    (%rdx),%edx
ffffffff8010229f:	89 c6                	mov    %eax,%esi
ffffffff801022a1:	89 d7                	mov    %edx,%edi
ffffffff801022a3:	e8 c0 f7 ff ff       	callq  ffffffff80101a68 <bfree>
      ip->addrs[i] = 0;
ffffffff801022a8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801022ac:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801022af:	48 63 d2             	movslq %edx,%rdx
ffffffff801022b2:	48 83 c2 04          	add    $0x4,%rdx
ffffffff801022b6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%rax,%rdx,4)
ffffffff801022bd:	00 
  for(i = 0; i < NDIRECT; i++){
ffffffff801022be:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801022c2:	83 7d fc 0b          	cmpl   $0xb,-0x4(%rbp)
ffffffff801022c6:	7e a9                	jle    ffffffff80102271 <itrunc+0x15>
    }
  }
  
  if(ip->addrs[NDIRECT]){
ffffffff801022c8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801022cc:	8b 40 4c             	mov    0x4c(%rax),%eax
ffffffff801022cf:	85 c0                	test   %eax,%eax
ffffffff801022d1:	0f 84 a7 00 00 00    	je     ffffffff8010237e <itrunc+0x122>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
ffffffff801022d7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801022db:	8b 50 4c             	mov    0x4c(%rax),%edx
ffffffff801022de:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801022e2:	8b 00                	mov    (%rax),%eax
ffffffff801022e4:	89 d6                	mov    %edx,%esi
ffffffff801022e6:	89 c7                	mov    %eax,%edi
ffffffff801022e8:	e8 e9 df ff ff       	callq  ffffffff801002d6 <bread>
ffffffff801022ed:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    a = (uint*)bp->data;
ffffffff801022f1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801022f5:	48 83 c0 28          	add    $0x28,%rax
ffffffff801022f9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    for(j = 0; j < NINDIRECT; j++){
ffffffff801022fd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
ffffffff80102304:	eb 43                	jmp    ffffffff80102349 <itrunc+0xed>
      if(a[j])
ffffffff80102306:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80102309:	48 98                	cltq   
ffffffff8010230b:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff80102312:	00 
ffffffff80102313:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102317:	48 01 d0             	add    %rdx,%rax
ffffffff8010231a:	8b 00                	mov    (%rax),%eax
ffffffff8010231c:	85 c0                	test   %eax,%eax
ffffffff8010231e:	74 25                	je     ffffffff80102345 <itrunc+0xe9>
        bfree(ip->dev, a[j]);
ffffffff80102320:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80102323:	48 98                	cltq   
ffffffff80102325:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff8010232c:	00 
ffffffff8010232d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102331:	48 01 d0             	add    %rdx,%rax
ffffffff80102334:	8b 00                	mov    (%rax),%eax
ffffffff80102336:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
ffffffff8010233a:	8b 12                	mov    (%rdx),%edx
ffffffff8010233c:	89 c6                	mov    %eax,%esi
ffffffff8010233e:	89 d7                	mov    %edx,%edi
ffffffff80102340:	e8 23 f7 ff ff       	callq  ffffffff80101a68 <bfree>
    for(j = 0; j < NINDIRECT; j++){
ffffffff80102345:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
ffffffff80102349:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff8010234c:	83 f8 7f             	cmp    $0x7f,%eax
ffffffff8010234f:	76 b5                	jbe    ffffffff80102306 <itrunc+0xaa>
    }
    brelse(bp);
ffffffff80102351:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102355:	48 89 c7             	mov    %rax,%rdi
ffffffff80102358:	e8 fe df ff ff       	callq  ffffffff8010035b <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
ffffffff8010235d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102361:	8b 40 4c             	mov    0x4c(%rax),%eax
ffffffff80102364:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
ffffffff80102368:	8b 12                	mov    (%rdx),%edx
ffffffff8010236a:	89 c6                	mov    %eax,%esi
ffffffff8010236c:	89 d7                	mov    %edx,%edi
ffffffff8010236e:	e8 f5 f6 ff ff       	callq  ffffffff80101a68 <bfree>
    ip->addrs[NDIRECT] = 0;
ffffffff80102373:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102377:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%rax)
  }

  ip->size = 0;
ffffffff8010237e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102382:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%rax)
  iupdate(ip);
ffffffff80102389:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010238d:	48 89 c7             	mov    %rax,%rdi
ffffffff80102390:	e8 ba f8 ff ff       	callq  ffffffff80101c4f <iupdate>
}
ffffffff80102395:	90                   	nop
ffffffff80102396:	c9                   	leaveq 
ffffffff80102397:	c3                   	retq   

ffffffff80102398 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
ffffffff80102398:	55                   	push   %rbp
ffffffff80102399:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010239c:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801023a0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff801023a4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  st->dev = ip->dev;
ffffffff801023a8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801023ac:	8b 00                	mov    (%rax),%eax
ffffffff801023ae:	89 c2                	mov    %eax,%edx
ffffffff801023b0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801023b4:	89 50 04             	mov    %edx,0x4(%rax)
  st->ino = ip->inum;
ffffffff801023b7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801023bb:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff801023be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801023c2:	89 50 08             	mov    %edx,0x8(%rax)
  st->type = ip->type;
ffffffff801023c5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801023c9:	0f b7 50 10          	movzwl 0x10(%rax),%edx
ffffffff801023cd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801023d1:	66 89 10             	mov    %dx,(%rax)
  st->nlink = ip->nlink;
ffffffff801023d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801023d8:	0f b7 50 16          	movzwl 0x16(%rax),%edx
ffffffff801023dc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801023e0:	66 89 50 0c          	mov    %dx,0xc(%rax)
  st->size = ip->size;
ffffffff801023e4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801023e8:	8b 50 18             	mov    0x18(%rax),%edx
ffffffff801023eb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801023ef:	89 50 10             	mov    %edx,0x10(%rax)
}
ffffffff801023f2:	90                   	nop
ffffffff801023f3:	c9                   	leaveq 
ffffffff801023f4:	c3                   	retq   

ffffffff801023f5 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
ffffffff801023f5:	55                   	push   %rbp
ffffffff801023f6:	48 89 e5             	mov    %rsp,%rbp
ffffffff801023f9:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff801023fd:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80102401:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff80102405:	89 55 cc             	mov    %edx,-0x34(%rbp)
ffffffff80102408:	89 4d c8             	mov    %ecx,-0x38(%rbp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
ffffffff8010240b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010240f:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80102413:	66 83 f8 03          	cmp    $0x3,%ax
ffffffff80102417:	75 6f                	jne    ffffffff80102488 <readi+0x93>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
ffffffff80102419:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010241d:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff80102421:	66 85 c0             	test   %ax,%ax
ffffffff80102424:	78 2b                	js     ffffffff80102451 <readi+0x5c>
ffffffff80102426:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010242a:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff8010242e:	66 83 f8 09          	cmp    $0x9,%ax
ffffffff80102432:	7f 1d                	jg     ffffffff80102451 <readi+0x5c>
ffffffff80102434:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102438:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff8010243c:	98                   	cwtl   
ffffffff8010243d:	48 98                	cltq   
ffffffff8010243f:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80102443:	48 05 a0 c9 10 80    	add    $0xffffffff8010c9a0,%rax
ffffffff80102449:	48 8b 00             	mov    (%rax),%rax
ffffffff8010244c:	48 85 c0             	test   %rax,%rax
ffffffff8010244f:	75 0a                	jne    ffffffff8010245b <readi+0x66>
      return -1;
ffffffff80102451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80102456:	e9 18 01 00 00       	jmpq   ffffffff80102573 <readi+0x17e>
    return devsw[ip->major].read(ip, dst, n);
ffffffff8010245b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010245f:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff80102463:	98                   	cwtl   
ffffffff80102464:	48 98                	cltq   
ffffffff80102466:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff8010246a:	48 05 a0 c9 10 80    	add    $0xffffffff8010c9a0,%rax
ffffffff80102470:	48 8b 00             	mov    (%rax),%rax
ffffffff80102473:	8b 55 c8             	mov    -0x38(%rbp),%edx
ffffffff80102476:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
ffffffff8010247a:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
ffffffff8010247e:	48 89 cf             	mov    %rcx,%rdi
ffffffff80102481:	ff d0                	callq  *%rax
ffffffff80102483:	e9 eb 00 00 00       	jmpq   ffffffff80102573 <readi+0x17e>
  }

  if(off > ip->size || off + n < off)
ffffffff80102488:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010248c:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff8010248f:	39 45 cc             	cmp    %eax,-0x34(%rbp)
ffffffff80102492:	77 0d                	ja     ffffffff801024a1 <readi+0xac>
ffffffff80102494:	8b 55 cc             	mov    -0x34(%rbp),%edx
ffffffff80102497:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff8010249a:	01 d0                	add    %edx,%eax
ffffffff8010249c:	39 45 cc             	cmp    %eax,-0x34(%rbp)
ffffffff8010249f:	76 0a                	jbe    ffffffff801024ab <readi+0xb6>
    return -1;
ffffffff801024a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801024a6:	e9 c8 00 00 00       	jmpq   ffffffff80102573 <readi+0x17e>
  if(off + n > ip->size)
ffffffff801024ab:	8b 55 cc             	mov    -0x34(%rbp),%edx
ffffffff801024ae:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff801024b1:	01 c2                	add    %eax,%edx
ffffffff801024b3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801024b7:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801024ba:	39 c2                	cmp    %eax,%edx
ffffffff801024bc:	76 0d                	jbe    ffffffff801024cb <readi+0xd6>
    n = ip->size - off;
ffffffff801024be:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801024c2:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801024c5:	2b 45 cc             	sub    -0x34(%rbp),%eax
ffffffff801024c8:	89 45 c8             	mov    %eax,-0x38(%rbp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
ffffffff801024cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff801024d2:	e9 8d 00 00 00       	jmpq   ffffffff80102564 <readi+0x16f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
ffffffff801024d7:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff801024da:	c1 e8 09             	shr    $0x9,%eax
ffffffff801024dd:	89 c2                	mov    %eax,%edx
ffffffff801024df:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801024e3:	89 d6                	mov    %edx,%esi
ffffffff801024e5:	48 89 c7             	mov    %rax,%rdi
ffffffff801024e8:	e8 4f fc ff ff       	callq  ffffffff8010213c <bmap>
ffffffff801024ed:	89 c2                	mov    %eax,%edx
ffffffff801024ef:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801024f3:	8b 00                	mov    (%rax),%eax
ffffffff801024f5:	89 d6                	mov    %edx,%esi
ffffffff801024f7:	89 c7                	mov    %eax,%edi
ffffffff801024f9:	e8 d8 dd ff ff       	callq  ffffffff801002d6 <bread>
ffffffff801024fe:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    m = min(n - tot, BSIZE - off%BSIZE);
ffffffff80102502:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80102505:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff8010250a:	ba 00 02 00 00       	mov    $0x200,%edx
ffffffff8010250f:	29 c2                	sub    %eax,%edx
ffffffff80102511:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff80102514:	2b 45 fc             	sub    -0x4(%rbp),%eax
ffffffff80102517:	39 c2                	cmp    %eax,%edx
ffffffff80102519:	0f 46 c2             	cmovbe %edx,%eax
ffffffff8010251c:	89 45 ec             	mov    %eax,-0x14(%rbp)
    memmove(dst, bp->data + off%BSIZE, m);
ffffffff8010251f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102523:	48 8d 50 28          	lea    0x28(%rax),%rdx
ffffffff80102527:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff8010252a:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff8010252f:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
ffffffff80102533:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80102536:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff8010253a:	48 89 ce             	mov    %rcx,%rsi
ffffffff8010253d:	48 89 c7             	mov    %rax,%rdi
ffffffff80102540:	e8 5b 3a 00 00       	callq  ffffffff80105fa0 <memmove>
    brelse(bp);
ffffffff80102545:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102549:	48 89 c7             	mov    %rax,%rdi
ffffffff8010254c:	e8 0a de ff ff       	callq  ffffffff8010035b <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
ffffffff80102551:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80102554:	01 45 fc             	add    %eax,-0x4(%rbp)
ffffffff80102557:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff8010255a:	01 45 cc             	add    %eax,-0x34(%rbp)
ffffffff8010255d:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80102560:	48 01 45 d0          	add    %rax,-0x30(%rbp)
ffffffff80102564:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80102567:	3b 45 c8             	cmp    -0x38(%rbp),%eax
ffffffff8010256a:	0f 82 67 ff ff ff    	jb     ffffffff801024d7 <readi+0xe2>
  }
  return n;
ffffffff80102570:	8b 45 c8             	mov    -0x38(%rbp),%eax
}
ffffffff80102573:	c9                   	leaveq 
ffffffff80102574:	c3                   	retq   

ffffffff80102575 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
ffffffff80102575:	55                   	push   %rbp
ffffffff80102576:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102579:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff8010257d:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80102581:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff80102585:	89 55 cc             	mov    %edx,-0x34(%rbp)
ffffffff80102588:	89 4d c8             	mov    %ecx,-0x38(%rbp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
ffffffff8010258b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010258f:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80102593:	66 83 f8 03          	cmp    $0x3,%ax
ffffffff80102597:	75 6f                	jne    ffffffff80102608 <writei+0x93>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
ffffffff80102599:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010259d:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff801025a1:	66 85 c0             	test   %ax,%ax
ffffffff801025a4:	78 2b                	js     ffffffff801025d1 <writei+0x5c>
ffffffff801025a6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801025aa:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff801025ae:	66 83 f8 09          	cmp    $0x9,%ax
ffffffff801025b2:	7f 1d                	jg     ffffffff801025d1 <writei+0x5c>
ffffffff801025b4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801025b8:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff801025bc:	98                   	cwtl   
ffffffff801025bd:	48 98                	cltq   
ffffffff801025bf:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff801025c3:	48 05 a8 c9 10 80    	add    $0xffffffff8010c9a8,%rax
ffffffff801025c9:	48 8b 00             	mov    (%rax),%rax
ffffffff801025cc:	48 85 c0             	test   %rax,%rax
ffffffff801025cf:	75 0a                	jne    ffffffff801025db <writei+0x66>
      return -1;
ffffffff801025d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801025d6:	e9 45 01 00 00       	jmpq   ffffffff80102720 <writei+0x1ab>
    return devsw[ip->major].write(ip, src, n);
ffffffff801025db:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801025df:	0f b7 40 12          	movzwl 0x12(%rax),%eax
ffffffff801025e3:	98                   	cwtl   
ffffffff801025e4:	48 98                	cltq   
ffffffff801025e6:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff801025ea:	48 05 a8 c9 10 80    	add    $0xffffffff8010c9a8,%rax
ffffffff801025f0:	48 8b 00             	mov    (%rax),%rax
ffffffff801025f3:	8b 55 c8             	mov    -0x38(%rbp),%edx
ffffffff801025f6:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
ffffffff801025fa:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
ffffffff801025fe:	48 89 cf             	mov    %rcx,%rdi
ffffffff80102601:	ff d0                	callq  *%rax
ffffffff80102603:	e9 18 01 00 00       	jmpq   ffffffff80102720 <writei+0x1ab>
  }

  if(off > ip->size || off + n < off)
ffffffff80102608:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010260c:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff8010260f:	39 45 cc             	cmp    %eax,-0x34(%rbp)
ffffffff80102612:	77 0d                	ja     ffffffff80102621 <writei+0xac>
ffffffff80102614:	8b 55 cc             	mov    -0x34(%rbp),%edx
ffffffff80102617:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff8010261a:	01 d0                	add    %edx,%eax
ffffffff8010261c:	39 45 cc             	cmp    %eax,-0x34(%rbp)
ffffffff8010261f:	76 0a                	jbe    ffffffff8010262b <writei+0xb6>
    return -1;
ffffffff80102621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80102626:	e9 f5 00 00 00       	jmpq   ffffffff80102720 <writei+0x1ab>
  if(off + n > MAXFILE*BSIZE)
ffffffff8010262b:	8b 55 cc             	mov    -0x34(%rbp),%edx
ffffffff8010262e:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff80102631:	01 d0                	add    %edx,%eax
ffffffff80102633:	3d 00 18 01 00       	cmp    $0x11800,%eax
ffffffff80102638:	76 0a                	jbe    ffffffff80102644 <writei+0xcf>
    return -1;
ffffffff8010263a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010263f:	e9 dc 00 00 00       	jmpq   ffffffff80102720 <writei+0x1ab>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
ffffffff80102644:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010264b:	e9 99 00 00 00       	jmpq   ffffffff801026e9 <writei+0x174>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
ffffffff80102650:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff80102653:	c1 e8 09             	shr    $0x9,%eax
ffffffff80102656:	89 c2                	mov    %eax,%edx
ffffffff80102658:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010265c:	89 d6                	mov    %edx,%esi
ffffffff8010265e:	48 89 c7             	mov    %rax,%rdi
ffffffff80102661:	e8 d6 fa ff ff       	callq  ffffffff8010213c <bmap>
ffffffff80102666:	89 c2                	mov    %eax,%edx
ffffffff80102668:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010266c:	8b 00                	mov    (%rax),%eax
ffffffff8010266e:	89 d6                	mov    %edx,%esi
ffffffff80102670:	89 c7                	mov    %eax,%edi
ffffffff80102672:	e8 5f dc ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80102677:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    m = min(n - tot, BSIZE - off%BSIZE);
ffffffff8010267b:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff8010267e:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff80102683:	ba 00 02 00 00       	mov    $0x200,%edx
ffffffff80102688:	29 c2                	sub    %eax,%edx
ffffffff8010268a:	8b 45 c8             	mov    -0x38(%rbp),%eax
ffffffff8010268d:	2b 45 fc             	sub    -0x4(%rbp),%eax
ffffffff80102690:	39 c2                	cmp    %eax,%edx
ffffffff80102692:	0f 46 c2             	cmovbe %edx,%eax
ffffffff80102695:	89 45 ec             	mov    %eax,-0x14(%rbp)
    memmove(bp->data + off%BSIZE, src, m);
ffffffff80102698:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010269c:	48 8d 50 28          	lea    0x28(%rax),%rdx
ffffffff801026a0:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff801026a3:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff801026a8:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
ffffffff801026ac:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff801026af:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801026b3:	48 89 c6             	mov    %rax,%rsi
ffffffff801026b6:	48 89 cf             	mov    %rcx,%rdi
ffffffff801026b9:	e8 e2 38 00 00       	callq  ffffffff80105fa0 <memmove>
    log_write(bp);
ffffffff801026be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801026c2:	48 89 c7             	mov    %rax,%rdi
ffffffff801026c5:	e8 cc 13 00 00       	callq  ffffffff80103a96 <log_write>
    brelse(bp);
ffffffff801026ca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801026ce:	48 89 c7             	mov    %rax,%rdi
ffffffff801026d1:	e8 85 dc ff ff       	callq  ffffffff8010035b <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
ffffffff801026d6:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801026d9:	01 45 fc             	add    %eax,-0x4(%rbp)
ffffffff801026dc:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801026df:	01 45 cc             	add    %eax,-0x34(%rbp)
ffffffff801026e2:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801026e5:	48 01 45 d0          	add    %rax,-0x30(%rbp)
ffffffff801026e9:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801026ec:	3b 45 c8             	cmp    -0x38(%rbp),%eax
ffffffff801026ef:	0f 82 5b ff ff ff    	jb     ffffffff80102650 <writei+0xdb>
  }

  if(n > 0 && off > ip->size){
ffffffff801026f5:	83 7d c8 00          	cmpl   $0x0,-0x38(%rbp)
ffffffff801026f9:	74 22                	je     ffffffff8010271d <writei+0x1a8>
ffffffff801026fb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801026ff:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80102702:	39 45 cc             	cmp    %eax,-0x34(%rbp)
ffffffff80102705:	76 16                	jbe    ffffffff8010271d <writei+0x1a8>
    ip->size = off;
ffffffff80102707:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010270b:	8b 55 cc             	mov    -0x34(%rbp),%edx
ffffffff8010270e:	89 50 18             	mov    %edx,0x18(%rax)
    iupdate(ip);
ffffffff80102711:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102715:	48 89 c7             	mov    %rax,%rdi
ffffffff80102718:	e8 32 f5 ff ff       	callq  ffffffff80101c4f <iupdate>
  }
  return n;
ffffffff8010271d:	8b 45 c8             	mov    -0x38(%rbp),%eax
}
ffffffff80102720:	c9                   	leaveq 
ffffffff80102721:	c3                   	retq   

ffffffff80102722 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
ffffffff80102722:	55                   	push   %rbp
ffffffff80102723:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102726:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff8010272a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010272e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  return strncmp(s, t, DIRSIZ);
ffffffff80102732:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
ffffffff80102736:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010273a:	ba 0e 00 00 00       	mov    $0xe,%edx
ffffffff8010273f:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102742:	48 89 c7             	mov    %rax,%rdi
ffffffff80102745:	e8 24 39 00 00       	callq  ffffffff8010606e <strncmp>
}
ffffffff8010274a:	c9                   	leaveq 
ffffffff8010274b:	c3                   	retq   

ffffffff8010274c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
ffffffff8010274c:	55                   	push   %rbp
ffffffff8010274d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102750:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff80102754:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80102758:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff8010275c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
ffffffff80102760:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102764:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80102768:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff8010276c:	74 0c                	je     ffffffff8010277a <dirlookup+0x2e>
    panic("dirlookup not DIR");
ffffffff8010276e:	48 c7 c7 01 97 10 80 	mov    $0xffffffff80109701,%rdi
ffffffff80102775:	e8 84 e1 ff ff       	callq  ffffffff801008fe <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
ffffffff8010277a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80102781:	e9 80 00 00 00       	jmpq   ffffffff80102806 <dirlookup+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
ffffffff80102786:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102789:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
ffffffff8010278d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102791:	b9 10 00 00 00       	mov    $0x10,%ecx
ffffffff80102796:	48 89 c7             	mov    %rax,%rdi
ffffffff80102799:	e8 57 fc ff ff       	callq  ffffffff801023f5 <readi>
ffffffff8010279e:	83 f8 10             	cmp    $0x10,%eax
ffffffff801027a1:	74 0c                	je     ffffffff801027af <dirlookup+0x63>
      panic("dirlink read");
ffffffff801027a3:	48 c7 c7 13 97 10 80 	mov    $0xffffffff80109713,%rdi
ffffffff801027aa:	e8 4f e1 ff ff       	callq  ffffffff801008fe <panic>
    if(de.inum == 0)
ffffffff801027af:	0f b7 45 e0          	movzwl -0x20(%rbp),%eax
ffffffff801027b3:	66 85 c0             	test   %ax,%ax
ffffffff801027b6:	74 49                	je     ffffffff80102801 <dirlookup+0xb5>
      continue;
    if(namecmp(name, de.name) == 0){
ffffffff801027b8:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
ffffffff801027bc:	48 8d 50 02          	lea    0x2(%rax),%rdx
ffffffff801027c0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801027c4:	48 89 d6             	mov    %rdx,%rsi
ffffffff801027c7:	48 89 c7             	mov    %rax,%rdi
ffffffff801027ca:	e8 53 ff ff ff       	callq  ffffffff80102722 <namecmp>
ffffffff801027cf:	85 c0                	test   %eax,%eax
ffffffff801027d1:	75 2f                	jne    ffffffff80102802 <dirlookup+0xb6>
      // entry matches path element
      if(poff)
ffffffff801027d3:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
ffffffff801027d8:	74 09                	je     ffffffff801027e3 <dirlookup+0x97>
        *poff = off;
ffffffff801027da:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff801027de:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801027e1:	89 10                	mov    %edx,(%rax)
      inum = de.inum;
ffffffff801027e3:	0f b7 45 e0          	movzwl -0x20(%rbp),%eax
ffffffff801027e7:	0f b7 c0             	movzwl %ax,%eax
ffffffff801027ea:	89 45 f8             	mov    %eax,-0x8(%rbp)
      return iget(dp->dev, inum);
ffffffff801027ed:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801027f1:	8b 00                	mov    (%rax),%eax
ffffffff801027f3:	8b 55 f8             	mov    -0x8(%rbp),%edx
ffffffff801027f6:	89 d6                	mov    %edx,%esi
ffffffff801027f8:	89 c7                	mov    %eax,%edi
ffffffff801027fa:	e8 23 f5 ff ff       	callq  ffffffff80101d22 <iget>
ffffffff801027ff:	eb 1a                	jmp    ffffffff8010281b <dirlookup+0xcf>
      continue;
ffffffff80102801:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
ffffffff80102802:	83 45 fc 10          	addl   $0x10,-0x4(%rbp)
ffffffff80102806:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010280a:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff8010280d:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff80102810:	0f 82 70 ff ff ff    	jb     ffffffff80102786 <dirlookup+0x3a>
    }
  }

  return 0;
ffffffff80102816:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010281b:	c9                   	leaveq 
ffffffff8010281c:	c3                   	retq   

ffffffff8010281d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
ffffffff8010281d:	55                   	push   %rbp
ffffffff8010281e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102821:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff80102825:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80102829:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff8010282d:	89 55 cc             	mov    %edx,-0x34(%rbp)
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
ffffffff80102830:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
ffffffff80102834:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80102838:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff8010283d:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102840:	48 89 c7             	mov    %rax,%rdi
ffffffff80102843:	e8 04 ff ff ff       	callq  ffffffff8010274c <dirlookup>
ffffffff80102848:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff8010284c:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80102851:	74 16                	je     ffffffff80102869 <dirlink+0x4c>
    iput(ip);
ffffffff80102853:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102857:	48 89 c7             	mov    %rax,%rdi
ffffffff8010285a:	e8 d1 f7 ff ff       	callq  ffffffff80102030 <iput>
    return -1;
ffffffff8010285f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80102864:	e9 a6 00 00 00       	jmpq   ffffffff8010290f <dirlink+0xf2>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
ffffffff80102869:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80102870:	eb 3b                	jmp    ffffffff801028ad <dirlink+0x90>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
ffffffff80102872:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102875:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
ffffffff80102879:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010287d:	b9 10 00 00 00       	mov    $0x10,%ecx
ffffffff80102882:	48 89 c7             	mov    %rax,%rdi
ffffffff80102885:	e8 6b fb ff ff       	callq  ffffffff801023f5 <readi>
ffffffff8010288a:	83 f8 10             	cmp    $0x10,%eax
ffffffff8010288d:	74 0c                	je     ffffffff8010289b <dirlink+0x7e>
      panic("dirlink read");
ffffffff8010288f:	48 c7 c7 13 97 10 80 	mov    $0xffffffff80109713,%rdi
ffffffff80102896:	e8 63 e0 ff ff       	callq  ffffffff801008fe <panic>
    if(de.inum == 0)
ffffffff8010289b:	0f b7 45 e0          	movzwl -0x20(%rbp),%eax
ffffffff8010289f:	66 85 c0             	test   %ax,%ax
ffffffff801028a2:	74 19                	je     ffffffff801028bd <dirlink+0xa0>
  for(off = 0; off < dp->size; off += sizeof(de)){
ffffffff801028a4:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801028a7:	83 c0 10             	add    $0x10,%eax
ffffffff801028aa:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff801028ad:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801028b1:	8b 50 18             	mov    0x18(%rax),%edx
ffffffff801028b4:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801028b7:	39 c2                	cmp    %eax,%edx
ffffffff801028b9:	77 b7                	ja     ffffffff80102872 <dirlink+0x55>
ffffffff801028bb:	eb 01                	jmp    ffffffff801028be <dirlink+0xa1>
      break;
ffffffff801028bd:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
ffffffff801028be:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801028c2:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
ffffffff801028c6:	48 8d 4a 02          	lea    0x2(%rdx),%rcx
ffffffff801028ca:	ba 0e 00 00 00       	mov    $0xe,%edx
ffffffff801028cf:	48 89 c6             	mov    %rax,%rsi
ffffffff801028d2:	48 89 cf             	mov    %rcx,%rdi
ffffffff801028d5:	e8 01 38 00 00       	callq  ffffffff801060db <strncpy>
  de.inum = inum;
ffffffff801028da:	8b 45 cc             	mov    -0x34(%rbp),%eax
ffffffff801028dd:	66 89 45 e0          	mov    %ax,-0x20(%rbp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
ffffffff801028e1:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801028e4:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
ffffffff801028e8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801028ec:	b9 10 00 00 00       	mov    $0x10,%ecx
ffffffff801028f1:	48 89 c7             	mov    %rax,%rdi
ffffffff801028f4:	e8 7c fc ff ff       	callq  ffffffff80102575 <writei>
ffffffff801028f9:	83 f8 10             	cmp    $0x10,%eax
ffffffff801028fc:	74 0c                	je     ffffffff8010290a <dirlink+0xed>
    panic("dirlink");
ffffffff801028fe:	48 c7 c7 20 97 10 80 	mov    $0xffffffff80109720,%rdi
ffffffff80102905:	e8 f4 df ff ff       	callq  ffffffff801008fe <panic>
  
  return 0;
ffffffff8010290a:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010290f:	c9                   	leaveq 
ffffffff80102910:	c3                   	retq   

ffffffff80102911 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
ffffffff80102911:	55                   	push   %rbp
ffffffff80102912:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102915:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80102919:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff8010291d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *s;
  int len;

  while(*path == '/')
ffffffff80102921:	eb 05                	jmp    ffffffff80102928 <skipelem+0x17>
    path++;
ffffffff80102923:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  while(*path == '/')
ffffffff80102928:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010292c:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010292f:	3c 2f                	cmp    $0x2f,%al
ffffffff80102931:	74 f0                	je     ffffffff80102923 <skipelem+0x12>
  if(*path == 0)
ffffffff80102933:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102937:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010293a:	84 c0                	test   %al,%al
ffffffff8010293c:	75 0a                	jne    ffffffff80102948 <skipelem+0x37>
    return 0;
ffffffff8010293e:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80102943:	e9 92 00 00 00       	jmpq   ffffffff801029da <skipelem+0xc9>
  s = path;
ffffffff80102948:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010294c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(*path != '/' && *path != 0)
ffffffff80102950:	eb 05                	jmp    ffffffff80102957 <skipelem+0x46>
    path++;
ffffffff80102952:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  while(*path != '/' && *path != 0)
ffffffff80102957:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010295b:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010295e:	3c 2f                	cmp    $0x2f,%al
ffffffff80102960:	74 0b                	je     ffffffff8010296d <skipelem+0x5c>
ffffffff80102962:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102966:	0f b6 00             	movzbl (%rax),%eax
ffffffff80102969:	84 c0                	test   %al,%al
ffffffff8010296b:	75 e5                	jne    ffffffff80102952 <skipelem+0x41>
  len = path - s;
ffffffff8010296d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80102971:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102975:	48 29 c2             	sub    %rax,%rdx
ffffffff80102978:	48 89 d0             	mov    %rdx,%rax
ffffffff8010297b:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(len >= DIRSIZ)
ffffffff8010297e:	83 7d f4 0d          	cmpl   $0xd,-0xc(%rbp)
ffffffff80102982:	7e 1a                	jle    ffffffff8010299e <skipelem+0x8d>
    memmove(name, s, DIRSIZ);
ffffffff80102984:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff80102988:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010298c:	ba 0e 00 00 00       	mov    $0xe,%edx
ffffffff80102991:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102994:	48 89 c7             	mov    %rax,%rdi
ffffffff80102997:	e8 04 36 00 00       	callq  ffffffff80105fa0 <memmove>
ffffffff8010299c:	eb 2d                	jmp    ffffffff801029cb <skipelem+0xba>
  else {
    memmove(name, s, len);
ffffffff8010299e:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff801029a1:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff801029a5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801029a9:	48 89 ce             	mov    %rcx,%rsi
ffffffff801029ac:	48 89 c7             	mov    %rax,%rdi
ffffffff801029af:	e8 ec 35 00 00       	callq  ffffffff80105fa0 <memmove>
    name[len] = 0;
ffffffff801029b4:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff801029b7:	48 63 d0             	movslq %eax,%rdx
ffffffff801029ba:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801029be:	48 01 d0             	add    %rdx,%rax
ffffffff801029c1:	c6 00 00             	movb   $0x0,(%rax)
  }
  while(*path == '/')
ffffffff801029c4:	eb 05                	jmp    ffffffff801029cb <skipelem+0xba>
    path++;
ffffffff801029c6:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  while(*path == '/')
ffffffff801029cb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801029cf:	0f b6 00             	movzbl (%rax),%eax
ffffffff801029d2:	3c 2f                	cmp    $0x2f,%al
ffffffff801029d4:	74 f0                	je     ffffffff801029c6 <skipelem+0xb5>
  return path;
ffffffff801029d6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
ffffffff801029da:	c9                   	leaveq 
ffffffff801029db:	c3                   	retq   

ffffffff801029dc <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
ffffffff801029dc:	55                   	push   %rbp
ffffffff801029dd:	48 89 e5             	mov    %rsp,%rbp
ffffffff801029e0:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff801029e4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff801029e8:	89 75 e4             	mov    %esi,-0x1c(%rbp)
ffffffff801029eb:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  struct inode *ip, *next;

  if(*path == '/')
ffffffff801029ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801029f3:	0f b6 00             	movzbl (%rax),%eax
ffffffff801029f6:	3c 2f                	cmp    $0x2f,%al
ffffffff801029f8:	75 18                	jne    ffffffff80102a12 <namex+0x36>
    ip = iget(ROOTDEV, ROOTINO);
ffffffff801029fa:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff801029ff:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80102a04:	e8 19 f3 ff ff       	callq  ffffffff80101d22 <iget>
ffffffff80102a09:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80102a0d:	e9 c3 00 00 00       	jmpq   ffffffff80102ad5 <namex+0xf9>
  else
    ip = idup(proc->cwd);
ffffffff80102a12:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80102a19:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80102a1d:	48 8b 80 c8 00 00 00 	mov    0xc8(%rax),%rax
ffffffff80102a24:	48 89 c7             	mov    %rax,%rdi
ffffffff80102a27:	e8 e6 f3 ff ff       	callq  ffffffff80101e12 <idup>
ffffffff80102a2c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

  while((path = skipelem(path, name)) != 0){
ffffffff80102a30:	e9 a0 00 00 00       	jmpq   ffffffff80102ad5 <namex+0xf9>
    ilock(ip);
ffffffff80102a35:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a39:	48 89 c7             	mov    %rax,%rdi
ffffffff80102a3c:	e8 0c f4 ff ff       	callq  ffffffff80101e4d <ilock>
    if(ip->type != T_DIR){
ffffffff80102a41:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a45:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80102a49:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80102a4d:	74 16                	je     ffffffff80102a65 <namex+0x89>
      iunlockput(ip);
ffffffff80102a4f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a53:	48 89 c7             	mov    %rax,%rdi
ffffffff80102a56:	e8 ba f6 ff ff       	callq  ffffffff80102115 <iunlockput>
      return 0;
ffffffff80102a5b:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80102a60:	e9 af 00 00 00       	jmpq   ffffffff80102b14 <namex+0x138>
    }
    if(nameiparent && *path == '\0'){
ffffffff80102a65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
ffffffff80102a69:	74 20                	je     ffffffff80102a8b <namex+0xaf>
ffffffff80102a6b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102a6f:	0f b6 00             	movzbl (%rax),%eax
ffffffff80102a72:	84 c0                	test   %al,%al
ffffffff80102a74:	75 15                	jne    ffffffff80102a8b <namex+0xaf>
      // Stop one level early.
      iunlock(ip);
ffffffff80102a76:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a7a:	48 89 c7             	mov    %rax,%rdi
ffffffff80102a7d:	e8 3c f5 ff ff       	callq  ffffffff80101fbe <iunlock>
      return ip;
ffffffff80102a82:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a86:	e9 89 00 00 00       	jmpq   ffffffff80102b14 <namex+0x138>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
ffffffff80102a8b:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
ffffffff80102a8f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102a93:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80102a98:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102a9b:	48 89 c7             	mov    %rax,%rdi
ffffffff80102a9e:	e8 a9 fc ff ff       	callq  ffffffff8010274c <dirlookup>
ffffffff80102aa3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80102aa7:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80102aac:	75 13                	jne    ffffffff80102ac1 <namex+0xe5>
      iunlockput(ip);
ffffffff80102aae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102ab2:	48 89 c7             	mov    %rax,%rdi
ffffffff80102ab5:	e8 5b f6 ff ff       	callq  ffffffff80102115 <iunlockput>
      return 0;
ffffffff80102aba:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80102abf:	eb 53                	jmp    ffffffff80102b14 <namex+0x138>
    }
    iunlockput(ip);
ffffffff80102ac1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102ac5:	48 89 c7             	mov    %rax,%rdi
ffffffff80102ac8:	e8 48 f6 ff ff       	callq  ffffffff80102115 <iunlockput>
    ip = next;
ffffffff80102acd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80102ad1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((path = skipelem(path, name)) != 0){
ffffffff80102ad5:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
ffffffff80102ad9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102add:	48 89 d6             	mov    %rdx,%rsi
ffffffff80102ae0:	48 89 c7             	mov    %rax,%rdi
ffffffff80102ae3:	e8 29 fe ff ff       	callq  ffffffff80102911 <skipelem>
ffffffff80102ae8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff80102aec:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff80102af1:	0f 85 3e ff ff ff    	jne    ffffffff80102a35 <namex+0x59>
  }
  if(nameiparent){
ffffffff80102af7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
ffffffff80102afb:	74 13                	je     ffffffff80102b10 <namex+0x134>
    iput(ip);
ffffffff80102afd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102b01:	48 89 c7             	mov    %rax,%rdi
ffffffff80102b04:	e8 27 f5 ff ff       	callq  ffffffff80102030 <iput>
    return 0;
ffffffff80102b09:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80102b0e:	eb 04                	jmp    ffffffff80102b14 <namex+0x138>
  }
  return ip;
ffffffff80102b10:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80102b14:	c9                   	leaveq 
ffffffff80102b15:	c3                   	retq   

ffffffff80102b16 <namei>:

struct inode*
namei(char *path)
{
ffffffff80102b16:	55                   	push   %rbp
ffffffff80102b17:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102b1a:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80102b1e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  char name[DIRSIZ];
  return namex(path, 0, name);
ffffffff80102b22:	48 8d 55 f2          	lea    -0xe(%rbp),%rdx
ffffffff80102b26:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102b2a:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80102b2f:	48 89 c7             	mov    %rax,%rdi
ffffffff80102b32:	e8 a5 fe ff ff       	callq  ffffffff801029dc <namex>
}
ffffffff80102b37:	c9                   	leaveq 
ffffffff80102b38:	c3                   	retq   

ffffffff80102b39 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
ffffffff80102b39:	55                   	push   %rbp
ffffffff80102b3a:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102b3d:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80102b41:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80102b45:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  return namex(path, 1, name);
ffffffff80102b49:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80102b4d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102b51:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80102b56:	48 89 c7             	mov    %rax,%rdi
ffffffff80102b59:	e8 7e fe ff ff       	callq  ffffffff801029dc <namex>
}
ffffffff80102b5e:	c9                   	leaveq 
ffffffff80102b5f:	c3                   	retq   

ffffffff80102b60 <inb>:
{
ffffffff80102b60:	55                   	push   %rbp
ffffffff80102b61:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102b64:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80102b68:	89 f8                	mov    %edi,%eax
ffffffff80102b6a:	66 89 45 ec          	mov    %ax,-0x14(%rbp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
ffffffff80102b6e:	0f b7 45 ec          	movzwl -0x14(%rbp),%eax
ffffffff80102b72:	89 c2                	mov    %eax,%edx
ffffffff80102b74:	ec                   	in     (%dx),%al
ffffffff80102b75:	88 45 ff             	mov    %al,-0x1(%rbp)
  return data;
ffffffff80102b78:	0f b6 45 ff          	movzbl -0x1(%rbp),%eax
}
ffffffff80102b7c:	c9                   	leaveq 
ffffffff80102b7d:	c3                   	retq   

ffffffff80102b7e <insl>:
{
ffffffff80102b7e:	55                   	push   %rbp
ffffffff80102b7f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102b82:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80102b86:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff80102b89:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff80102b8d:	89 55 f8             	mov    %edx,-0x8(%rbp)
  asm volatile("cld; rep insl" :
ffffffff80102b90:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102b93:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
ffffffff80102b97:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80102b9a:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102b9d:	48 89 f7             	mov    %rsi,%rdi
ffffffff80102ba0:	89 c1                	mov    %eax,%ecx
ffffffff80102ba2:	fc                   	cld    
ffffffff80102ba3:	f3 6d                	rep insl (%dx),%es:(%rdi)
ffffffff80102ba5:	89 c8                	mov    %ecx,%eax
ffffffff80102ba7:	48 89 fe             	mov    %rdi,%rsi
ffffffff80102baa:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff80102bae:	89 45 f8             	mov    %eax,-0x8(%rbp)
}
ffffffff80102bb1:	90                   	nop
ffffffff80102bb2:	c9                   	leaveq 
ffffffff80102bb3:	c3                   	retq   

ffffffff80102bb4 <outb>:
{
ffffffff80102bb4:	55                   	push   %rbp
ffffffff80102bb5:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102bb8:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80102bbc:	89 fa                	mov    %edi,%edx
ffffffff80102bbe:	89 f0                	mov    %esi,%eax
ffffffff80102bc0:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80102bc4:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80102bc7:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff80102bcb:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff80102bcf:	ee                   	out    %al,(%dx)
}
ffffffff80102bd0:	90                   	nop
ffffffff80102bd1:	c9                   	leaveq 
ffffffff80102bd2:	c3                   	retq   

ffffffff80102bd3 <outsl>:
{
ffffffff80102bd3:	55                   	push   %rbp
ffffffff80102bd4:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102bd7:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80102bdb:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff80102bde:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff80102be2:	89 55 f8             	mov    %edx,-0x8(%rbp)
  asm volatile("cld; rep outsl" :
ffffffff80102be5:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102be8:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
ffffffff80102bec:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff80102bef:	48 89 ce             	mov    %rcx,%rsi
ffffffff80102bf2:	89 c1                	mov    %eax,%ecx
ffffffff80102bf4:	fc                   	cld    
ffffffff80102bf5:	f3 6f                	rep outsl %ds:(%rsi),(%dx)
ffffffff80102bf7:	89 c8                	mov    %ecx,%eax
ffffffff80102bf9:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff80102bfd:	89 45 f8             	mov    %eax,-0x8(%rbp)
}
ffffffff80102c00:	90                   	nop
ffffffff80102c01:	c9                   	leaveq 
ffffffff80102c02:	c3                   	retq   

ffffffff80102c03 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
ffffffff80102c03:	55                   	push   %rbp
ffffffff80102c04:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102c07:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80102c0b:	89 7d ec             	mov    %edi,-0x14(%rbp)
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
ffffffff80102c0e:	90                   	nop
ffffffff80102c0f:	bf f7 01 00 00       	mov    $0x1f7,%edi
ffffffff80102c14:	e8 47 ff ff ff       	callq  ffffffff80102b60 <inb>
ffffffff80102c19:	0f b6 c0             	movzbl %al,%eax
ffffffff80102c1c:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80102c1f:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80102c22:	25 c0 00 00 00       	and    $0xc0,%eax
ffffffff80102c27:	83 f8 40             	cmp    $0x40,%eax
ffffffff80102c2a:	75 e3                	jne    ffffffff80102c0f <idewait+0xc>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
ffffffff80102c2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff80102c30:	74 11                	je     ffffffff80102c43 <idewait+0x40>
ffffffff80102c32:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80102c35:	83 e0 21             	and    $0x21,%eax
ffffffff80102c38:	85 c0                	test   %eax,%eax
ffffffff80102c3a:	74 07                	je     ffffffff80102c43 <idewait+0x40>
    return -1;
ffffffff80102c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80102c41:	eb 05                	jmp    ffffffff80102c48 <idewait+0x45>
  return 0;
ffffffff80102c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80102c48:	c9                   	leaveq 
ffffffff80102c49:	c3                   	retq   

ffffffff80102c4a <ideinit>:

void
ideinit(void)
{
ffffffff80102c4a:	55                   	push   %rbp
ffffffff80102c4b:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102c4e:	48 83 ec 10          	sub    $0x10,%rsp
  int i;

  initlock(&idelock, "ide");
ffffffff80102c52:	48 c7 c6 28 97 10 80 	mov    $0xffffffff80109728,%rsi
ffffffff80102c59:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102c60:	e8 a8 2e 00 00       	callq  ffffffff80105b0d <initlock>
  picenable(IRQ_IDE);
ffffffff80102c65:	bf 0e 00 00 00       	mov    $0xe,%edi
ffffffff80102c6a:	e8 3d 1b 00 00       	callq  ffffffff801047ac <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
ffffffff80102c6f:	8b 05 6f c7 00 00    	mov    0xc76f(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff80102c75:	83 e8 01             	sub    $0x1,%eax
ffffffff80102c78:	89 c6                	mov    %eax,%esi
ffffffff80102c7a:	bf 0e 00 00 00       	mov    $0xe,%edi
ffffffff80102c7f:	e8 31 04 00 00       	callq  ffffffff801030b5 <ioapicenable>
  idewait(0);
ffffffff80102c84:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80102c89:	e8 75 ff ff ff       	callq  ffffffff80102c03 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
ffffffff80102c8e:	be f0 00 00 00       	mov    $0xf0,%esi
ffffffff80102c93:	bf f6 01 00 00       	mov    $0x1f6,%edi
ffffffff80102c98:	e8 17 ff ff ff       	callq  ffffffff80102bb4 <outb>
  for(i=0; i<1000; i++){
ffffffff80102c9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80102ca4:	eb 1e                	jmp    ffffffff80102cc4 <ideinit+0x7a>
    if(inb(0x1f7) != 0){
ffffffff80102ca6:	bf f7 01 00 00       	mov    $0x1f7,%edi
ffffffff80102cab:	e8 b0 fe ff ff       	callq  ffffffff80102b60 <inb>
ffffffff80102cb0:	84 c0                	test   %al,%al
ffffffff80102cb2:	74 0c                	je     ffffffff80102cc0 <ideinit+0x76>
      havedisk1 = 1;
ffffffff80102cb4:	c7 05 32 be 00 00 01 	movl   $0x1,0xbe32(%rip)        # ffffffff8010eaf0 <havedisk1>
ffffffff80102cbb:	00 00 00 
      break;
ffffffff80102cbe:	eb 0d                	jmp    ffffffff80102ccd <ideinit+0x83>
  for(i=0; i<1000; i++){
ffffffff80102cc0:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80102cc4:	81 7d fc e7 03 00 00 	cmpl   $0x3e7,-0x4(%rbp)
ffffffff80102ccb:	7e d9                	jle    ffffffff80102ca6 <ideinit+0x5c>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
ffffffff80102ccd:	be e0 00 00 00       	mov    $0xe0,%esi
ffffffff80102cd2:	bf f6 01 00 00       	mov    $0x1f6,%edi
ffffffff80102cd7:	e8 d8 fe ff ff       	callq  ffffffff80102bb4 <outb>
}
ffffffff80102cdc:	90                   	nop
ffffffff80102cdd:	c9                   	leaveq 
ffffffff80102cde:	c3                   	retq   

ffffffff80102cdf <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
ffffffff80102cdf:	55                   	push   %rbp
ffffffff80102ce0:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102ce3:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80102ce7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if(b == 0)
ffffffff80102ceb:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80102cf0:	75 0c                	jne    ffffffff80102cfe <idestart+0x1f>
    panic("idestart");
ffffffff80102cf2:	48 c7 c7 2c 97 10 80 	mov    $0xffffffff8010972c,%rdi
ffffffff80102cf9:	e8 00 dc ff ff       	callq  ffffffff801008fe <panic>

  idewait(0);
ffffffff80102cfe:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80102d03:	e8 fb fe ff ff       	callq  ffffffff80102c03 <idewait>
  outb(0x3f6, 0);  // generate interrupt
ffffffff80102d08:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80102d0d:	bf f6 03 00 00       	mov    $0x3f6,%edi
ffffffff80102d12:	e8 9d fe ff ff       	callq  ffffffff80102bb4 <outb>
  outb(0x1f2, 1);  // number of sectors
ffffffff80102d17:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80102d1c:	bf f2 01 00 00       	mov    $0x1f2,%edi
ffffffff80102d21:	e8 8e fe ff ff       	callq  ffffffff80102bb4 <outb>
  outb(0x1f3, b->sector & 0xff);
ffffffff80102d26:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102d2a:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80102d2d:	0f b6 c0             	movzbl %al,%eax
ffffffff80102d30:	89 c6                	mov    %eax,%esi
ffffffff80102d32:	bf f3 01 00 00       	mov    $0x1f3,%edi
ffffffff80102d37:	e8 78 fe ff ff       	callq  ffffffff80102bb4 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
ffffffff80102d3c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102d40:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80102d43:	c1 e8 08             	shr    $0x8,%eax
ffffffff80102d46:	0f b6 c0             	movzbl %al,%eax
ffffffff80102d49:	89 c6                	mov    %eax,%esi
ffffffff80102d4b:	bf f4 01 00 00       	mov    $0x1f4,%edi
ffffffff80102d50:	e8 5f fe ff ff       	callq  ffffffff80102bb4 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
ffffffff80102d55:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102d59:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80102d5c:	c1 e8 10             	shr    $0x10,%eax
ffffffff80102d5f:	0f b6 c0             	movzbl %al,%eax
ffffffff80102d62:	89 c6                	mov    %eax,%esi
ffffffff80102d64:	bf f5 01 00 00       	mov    $0x1f5,%edi
ffffffff80102d69:	e8 46 fe ff ff       	callq  ffffffff80102bb4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
ffffffff80102d6e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102d72:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80102d75:	c1 e0 04             	shl    $0x4,%eax
ffffffff80102d78:	83 e0 10             	and    $0x10,%eax
ffffffff80102d7b:	89 c2                	mov    %eax,%edx
ffffffff80102d7d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102d81:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80102d84:	c1 e8 18             	shr    $0x18,%eax
ffffffff80102d87:	83 e0 0f             	and    $0xf,%eax
ffffffff80102d8a:	09 d0                	or     %edx,%eax
ffffffff80102d8c:	83 c8 e0             	or     $0xffffffe0,%eax
ffffffff80102d8f:	0f b6 c0             	movzbl %al,%eax
ffffffff80102d92:	89 c6                	mov    %eax,%esi
ffffffff80102d94:	bf f6 01 00 00       	mov    $0x1f6,%edi
ffffffff80102d99:	e8 16 fe ff ff       	callq  ffffffff80102bb4 <outb>
  if(b->flags & B_DIRTY){
ffffffff80102d9e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102da2:	8b 00                	mov    (%rax),%eax
ffffffff80102da4:	83 e0 04             	and    $0x4,%eax
ffffffff80102da7:	85 c0                	test   %eax,%eax
ffffffff80102da9:	74 2b                	je     ffffffff80102dd6 <idestart+0xf7>
    outb(0x1f7, IDE_CMD_WRITE);
ffffffff80102dab:	be 30 00 00 00       	mov    $0x30,%esi
ffffffff80102db0:	bf f7 01 00 00       	mov    $0x1f7,%edi
ffffffff80102db5:	e8 fa fd ff ff       	callq  ffffffff80102bb4 <outb>
    outsl(0x1f0, b->data, 512/4);
ffffffff80102dba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102dbe:	48 83 c0 28          	add    $0x28,%rax
ffffffff80102dc2:	ba 80 00 00 00       	mov    $0x80,%edx
ffffffff80102dc7:	48 89 c6             	mov    %rax,%rsi
ffffffff80102dca:	bf f0 01 00 00       	mov    $0x1f0,%edi
ffffffff80102dcf:	e8 ff fd ff ff       	callq  ffffffff80102bd3 <outsl>
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
ffffffff80102dd4:	eb 0f                	jmp    ffffffff80102de5 <idestart+0x106>
    outb(0x1f7, IDE_CMD_READ);
ffffffff80102dd6:	be 20 00 00 00       	mov    $0x20,%esi
ffffffff80102ddb:	bf f7 01 00 00       	mov    $0x1f7,%edi
ffffffff80102de0:	e8 cf fd ff ff       	callq  ffffffff80102bb4 <outb>
}
ffffffff80102de5:	90                   	nop
ffffffff80102de6:	c9                   	leaveq 
ffffffff80102de7:	c3                   	retq   

ffffffff80102de8 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
ffffffff80102de8:	55                   	push   %rbp
ffffffff80102de9:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102dec:	48 83 ec 10          	sub    $0x10,%rsp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
ffffffff80102df0:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102df7:	e8 46 2d 00 00       	callq  ffffffff80105b42 <acquire>
  if((b = idequeue) == 0){
ffffffff80102dfc:	48 8b 05 e5 bc 00 00 	mov    0xbce5(%rip),%rax        # ffffffff8010eae8 <idequeue>
ffffffff80102e03:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80102e07:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80102e0c:	75 11                	jne    ffffffff80102e1f <ideintr+0x37>
    release(&idelock);
ffffffff80102e0e:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102e15:	e8 ff 2d 00 00       	callq  ffffffff80105c19 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
ffffffff80102e1a:	e9 99 00 00 00       	jmpq   ffffffff80102eb8 <ideintr+0xd0>
  }
  idequeue = b->qnext;
ffffffff80102e1f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e23:	48 8b 40 20          	mov    0x20(%rax),%rax
ffffffff80102e27:	48 89 05 ba bc 00 00 	mov    %rax,0xbcba(%rip)        # ffffffff8010eae8 <idequeue>

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
ffffffff80102e2e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e32:	8b 00                	mov    (%rax),%eax
ffffffff80102e34:	83 e0 04             	and    $0x4,%eax
ffffffff80102e37:	85 c0                	test   %eax,%eax
ffffffff80102e39:	75 28                	jne    ffffffff80102e63 <ideintr+0x7b>
ffffffff80102e3b:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80102e40:	e8 be fd ff ff       	callq  ffffffff80102c03 <idewait>
ffffffff80102e45:	85 c0                	test   %eax,%eax
ffffffff80102e47:	78 1a                	js     ffffffff80102e63 <ideintr+0x7b>
    insl(0x1f0, b->data, 512/4);
ffffffff80102e49:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e4d:	48 83 c0 28          	add    $0x28,%rax
ffffffff80102e51:	ba 80 00 00 00       	mov    $0x80,%edx
ffffffff80102e56:	48 89 c6             	mov    %rax,%rsi
ffffffff80102e59:	bf f0 01 00 00       	mov    $0x1f0,%edi
ffffffff80102e5e:	e8 1b fd ff ff       	callq  ffffffff80102b7e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
ffffffff80102e63:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e67:	8b 00                	mov    (%rax),%eax
ffffffff80102e69:	83 c8 02             	or     $0x2,%eax
ffffffff80102e6c:	89 c2                	mov    %eax,%edx
ffffffff80102e6e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e72:	89 10                	mov    %edx,(%rax)
  b->flags &= ~B_DIRTY;
ffffffff80102e74:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e78:	8b 00                	mov    (%rax),%eax
ffffffff80102e7a:	83 e0 fb             	and    $0xfffffffb,%eax
ffffffff80102e7d:	89 c2                	mov    %eax,%edx
ffffffff80102e7f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e83:	89 10                	mov    %edx,(%rax)
  wakeup(b);
ffffffff80102e85:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102e89:	48 89 c7             	mov    %rax,%rdi
ffffffff80102e8c:	e8 52 2a 00 00       	callq  ffffffff801058e3 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
ffffffff80102e91:	48 8b 05 50 bc 00 00 	mov    0xbc50(%rip),%rax        # ffffffff8010eae8 <idequeue>
ffffffff80102e98:	48 85 c0             	test   %rax,%rax
ffffffff80102e9b:	74 0f                	je     ffffffff80102eac <ideintr+0xc4>
    idestart(idequeue);
ffffffff80102e9d:	48 8b 05 44 bc 00 00 	mov    0xbc44(%rip),%rax        # ffffffff8010eae8 <idequeue>
ffffffff80102ea4:	48 89 c7             	mov    %rax,%rdi
ffffffff80102ea7:	e8 33 fe ff ff       	callq  ffffffff80102cdf <idestart>

  release(&idelock);
ffffffff80102eac:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102eb3:	e8 61 2d 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80102eb8:	c9                   	leaveq 
ffffffff80102eb9:	c3                   	retq   

ffffffff80102eba <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
ffffffff80102eba:	55                   	push   %rbp
ffffffff80102ebb:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102ebe:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80102ec2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct buf **pp;

  if(!(b->flags & B_BUSY))
ffffffff80102ec6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102eca:	8b 00                	mov    (%rax),%eax
ffffffff80102ecc:	83 e0 01             	and    $0x1,%eax
ffffffff80102ecf:	85 c0                	test   %eax,%eax
ffffffff80102ed1:	75 0c                	jne    ffffffff80102edf <iderw+0x25>
    panic("iderw: buf not busy");
ffffffff80102ed3:	48 c7 c7 35 97 10 80 	mov    $0xffffffff80109735,%rdi
ffffffff80102eda:	e8 1f da ff ff       	callq  ffffffff801008fe <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
ffffffff80102edf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102ee3:	8b 00                	mov    (%rax),%eax
ffffffff80102ee5:	83 e0 06             	and    $0x6,%eax
ffffffff80102ee8:	83 f8 02             	cmp    $0x2,%eax
ffffffff80102eeb:	75 0c                	jne    ffffffff80102ef9 <iderw+0x3f>
    panic("iderw: nothing to do");
ffffffff80102eed:	48 c7 c7 49 97 10 80 	mov    $0xffffffff80109749,%rdi
ffffffff80102ef4:	e8 05 da ff ff       	callq  ffffffff801008fe <panic>
  if(b->dev != 0 && !havedisk1)
ffffffff80102ef9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102efd:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80102f00:	85 c0                	test   %eax,%eax
ffffffff80102f02:	74 16                	je     ffffffff80102f1a <iderw+0x60>
ffffffff80102f04:	8b 05 e6 bb 00 00    	mov    0xbbe6(%rip),%eax        # ffffffff8010eaf0 <havedisk1>
ffffffff80102f0a:	85 c0                	test   %eax,%eax
ffffffff80102f0c:	75 0c                	jne    ffffffff80102f1a <iderw+0x60>
    panic("iderw: ide disk 1 not present");
ffffffff80102f0e:	48 c7 c7 5e 97 10 80 	mov    $0xffffffff8010975e,%rdi
ffffffff80102f15:	e8 e4 d9 ff ff       	callq  ffffffff801008fe <panic>

  acquire(&idelock);  //DOC:acquire-lock
ffffffff80102f1a:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102f21:	e8 1c 2c 00 00       	callq  ffffffff80105b42 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
ffffffff80102f26:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102f2a:	48 c7 40 20 00 00 00 	movq   $0x0,0x20(%rax)
ffffffff80102f31:	00 
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
ffffffff80102f32:	48 c7 45 f8 e8 ea 10 	movq   $0xffffffff8010eae8,-0x8(%rbp)
ffffffff80102f39:	80 
ffffffff80102f3a:	eb 0f                	jmp    ffffffff80102f4b <iderw+0x91>
ffffffff80102f3c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102f40:	48 8b 00             	mov    (%rax),%rax
ffffffff80102f43:	48 83 c0 20          	add    $0x20,%rax
ffffffff80102f47:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80102f4b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102f4f:	48 8b 00             	mov    (%rax),%rax
ffffffff80102f52:	48 85 c0             	test   %rax,%rax
ffffffff80102f55:	75 e5                	jne    ffffffff80102f3c <iderw+0x82>
    ;
  *pp = b;
ffffffff80102f57:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80102f5b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80102f5f:	48 89 10             	mov    %rdx,(%rax)
  
  // Start disk if necessary.
  if(idequeue == b)
ffffffff80102f62:	48 8b 05 7f bb 00 00 	mov    0xbb7f(%rip),%rax        # ffffffff8010eae8 <idequeue>
ffffffff80102f69:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff80102f6d:	75 21                	jne    ffffffff80102f90 <iderw+0xd6>
    idestart(b);
ffffffff80102f6f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102f73:	48 89 c7             	mov    %rax,%rdi
ffffffff80102f76:	e8 64 fd ff ff       	callq  ffffffff80102cdf <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
ffffffff80102f7b:	eb 13                	jmp    ffffffff80102f90 <iderw+0xd6>
    sleep(b, &idelock);
ffffffff80102f7d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102f81:	48 c7 c6 80 ea 10 80 	mov    $0xffffffff8010ea80,%rsi
ffffffff80102f88:	48 89 c7             	mov    %rax,%rdi
ffffffff80102f8b:	e8 40 28 00 00       	callq  ffffffff801057d0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
ffffffff80102f90:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80102f94:	8b 00                	mov    (%rax),%eax
ffffffff80102f96:	83 e0 06             	and    $0x6,%eax
ffffffff80102f99:	83 f8 02             	cmp    $0x2,%eax
ffffffff80102f9c:	75 df                	jne    ffffffff80102f7d <iderw+0xc3>
  }

  release(&idelock);
ffffffff80102f9e:	48 c7 c7 80 ea 10 80 	mov    $0xffffffff8010ea80,%rdi
ffffffff80102fa5:	e8 6f 2c 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80102faa:	90                   	nop
ffffffff80102fab:	c9                   	leaveq 
ffffffff80102fac:	c3                   	retq   

ffffffff80102fad <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
ffffffff80102fad:	55                   	push   %rbp
ffffffff80102fae:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102fb1:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80102fb5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  ioapic->reg = reg;
ffffffff80102fb8:	48 8b 05 39 bb 00 00 	mov    0xbb39(%rip),%rax        # ffffffff8010eaf8 <ioapic>
ffffffff80102fbf:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102fc2:	89 10                	mov    %edx,(%rax)
  return ioapic->data;
ffffffff80102fc4:	48 8b 05 2d bb 00 00 	mov    0xbb2d(%rip),%rax        # ffffffff8010eaf8 <ioapic>
ffffffff80102fcb:	8b 40 10             	mov    0x10(%rax),%eax
}
ffffffff80102fce:	c9                   	leaveq 
ffffffff80102fcf:	c3                   	retq   

ffffffff80102fd0 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
ffffffff80102fd0:	55                   	push   %rbp
ffffffff80102fd1:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102fd4:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80102fd8:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff80102fdb:	89 75 f8             	mov    %esi,-0x8(%rbp)
  ioapic->reg = reg;
ffffffff80102fde:	48 8b 05 13 bb 00 00 	mov    0xbb13(%rip),%rax        # ffffffff8010eaf8 <ioapic>
ffffffff80102fe5:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80102fe8:	89 10                	mov    %edx,(%rax)
  ioapic->data = data;
ffffffff80102fea:	48 8b 05 07 bb 00 00 	mov    0xbb07(%rip),%rax        # ffffffff8010eaf8 <ioapic>
ffffffff80102ff1:	8b 55 f8             	mov    -0x8(%rbp),%edx
ffffffff80102ff4:	89 50 10             	mov    %edx,0x10(%rax)
}
ffffffff80102ff7:	90                   	nop
ffffffff80102ff8:	c9                   	leaveq 
ffffffff80102ff9:	c3                   	retq   

ffffffff80102ffa <ioapicinit>:

void
ioapicinit(void)
{
ffffffff80102ffa:	55                   	push   %rbp
ffffffff80102ffb:	48 89 e5             	mov    %rsp,%rbp
ffffffff80102ffe:	48 83 ec 10          	sub    $0x10,%rsp
  int i, id, maxintr;

  if(!ismp)
ffffffff80103002:	8b 05 d8 c3 00 00    	mov    0xc3d8(%rip),%eax        # ffffffff8010f3e0 <ismp>
ffffffff80103008:	85 c0                	test   %eax,%eax
ffffffff8010300a:	0f 84 a2 00 00 00    	je     ffffffff801030b2 <ioapicinit+0xb8>
    return;

  ioapic = (volatile struct ioapic*) IO2V(IOAPIC);
ffffffff80103010:	48 b8 00 00 c0 40 ff 	movabs $0xffffffff40c00000,%rax
ffffffff80103017:	ff ff ff 
ffffffff8010301a:	48 89 05 d7 ba 00 00 	mov    %rax,0xbad7(%rip)        # ffffffff8010eaf8 <ioapic>
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
ffffffff80103021:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80103026:	e8 82 ff ff ff       	callq  ffffffff80102fad <ioapicread>
ffffffff8010302b:	c1 e8 10             	shr    $0x10,%eax
ffffffff8010302e:	25 ff 00 00 00       	and    $0xff,%eax
ffffffff80103033:	89 45 f8             	mov    %eax,-0x8(%rbp)
  id = ioapicread(REG_ID) >> 24;
ffffffff80103036:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff8010303b:	e8 6d ff ff ff       	callq  ffffffff80102fad <ioapicread>
ffffffff80103040:	c1 e8 18             	shr    $0x18,%eax
ffffffff80103043:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(id != ioapicid)
ffffffff80103046:	0f b6 05 9b c3 00 00 	movzbl 0xc39b(%rip),%eax        # ffffffff8010f3e8 <ioapicid>
ffffffff8010304d:	0f b6 c0             	movzbl %al,%eax
ffffffff80103050:	39 45 f4             	cmp    %eax,-0xc(%rbp)
ffffffff80103053:	74 11                	je     ffffffff80103066 <ioapicinit+0x6c>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
ffffffff80103055:	48 c7 c7 80 97 10 80 	mov    $0xffffffff80109780,%rdi
ffffffff8010305c:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80103061:	e8 3b d5 ff ff       	callq  ffffffff801005a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
ffffffff80103066:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010306d:	eb 39                	jmp    ffffffff801030a8 <ioapicinit+0xae>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
ffffffff8010306f:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103072:	83 c0 20             	add    $0x20,%eax
ffffffff80103075:	0d 00 00 01 00       	or     $0x10000,%eax
ffffffff8010307a:	89 c2                	mov    %eax,%edx
ffffffff8010307c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010307f:	83 c0 08             	add    $0x8,%eax
ffffffff80103082:	01 c0                	add    %eax,%eax
ffffffff80103084:	89 d6                	mov    %edx,%esi
ffffffff80103086:	89 c7                	mov    %eax,%edi
ffffffff80103088:	e8 43 ff ff ff       	callq  ffffffff80102fd0 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
ffffffff8010308d:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103090:	83 c0 08             	add    $0x8,%eax
ffffffff80103093:	01 c0                	add    %eax,%eax
ffffffff80103095:	83 c0 01             	add    $0x1,%eax
ffffffff80103098:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff8010309d:	89 c7                	mov    %eax,%edi
ffffffff8010309f:	e8 2c ff ff ff       	callq  ffffffff80102fd0 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
ffffffff801030a4:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801030a8:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801030ab:	3b 45 f8             	cmp    -0x8(%rbp),%eax
ffffffff801030ae:	7e bf                	jle    ffffffff8010306f <ioapicinit+0x75>
ffffffff801030b0:	eb 01                	jmp    ffffffff801030b3 <ioapicinit+0xb9>
    return;
ffffffff801030b2:	90                   	nop
  }
}
ffffffff801030b3:	c9                   	leaveq 
ffffffff801030b4:	c3                   	retq   

ffffffff801030b5 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
ffffffff801030b5:	55                   	push   %rbp
ffffffff801030b6:	48 89 e5             	mov    %rsp,%rbp
ffffffff801030b9:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff801030bd:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff801030c0:	89 75 f8             	mov    %esi,-0x8(%rbp)
  if(!ismp)
ffffffff801030c3:	8b 05 17 c3 00 00    	mov    0xc317(%rip),%eax        # ffffffff8010f3e0 <ismp>
ffffffff801030c9:	85 c0                	test   %eax,%eax
ffffffff801030cb:	74 37                	je     ffffffff80103104 <ioapicenable+0x4f>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
ffffffff801030cd:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801030d0:	83 c0 20             	add    $0x20,%eax
ffffffff801030d3:	89 c2                	mov    %eax,%edx
ffffffff801030d5:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801030d8:	83 c0 08             	add    $0x8,%eax
ffffffff801030db:	01 c0                	add    %eax,%eax
ffffffff801030dd:	89 d6                	mov    %edx,%esi
ffffffff801030df:	89 c7                	mov    %eax,%edi
ffffffff801030e1:	e8 ea fe ff ff       	callq  ffffffff80102fd0 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
ffffffff801030e6:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff801030e9:	c1 e0 18             	shl    $0x18,%eax
ffffffff801030ec:	89 c2                	mov    %eax,%edx
ffffffff801030ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801030f1:	83 c0 08             	add    $0x8,%eax
ffffffff801030f4:	01 c0                	add    %eax,%eax
ffffffff801030f6:	83 c0 01             	add    $0x1,%eax
ffffffff801030f9:	89 d6                	mov    %edx,%esi
ffffffff801030fb:	89 c7                	mov    %eax,%edi
ffffffff801030fd:	e8 ce fe ff ff       	callq  ffffffff80102fd0 <ioapicwrite>
ffffffff80103102:	eb 01                	jmp    ffffffff80103105 <ioapicenable+0x50>
    return;
ffffffff80103104:	90                   	nop
}
ffffffff80103105:	c9                   	leaveq 
ffffffff80103106:	c3                   	retq   

ffffffff80103107 <v2p>:
#endif
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uintp v2p(void *a) { return ((uintp) (a)) - ((uintp)KERNBASE); }
ffffffff80103107:	55                   	push   %rbp
ffffffff80103108:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010310b:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010310f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80103113:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80103117:	b8 00 00 00 80       	mov    $0x80000000,%eax
ffffffff8010311c:	48 01 d0             	add    %rdx,%rax
ffffffff8010311f:	c9                   	leaveq 
ffffffff80103120:	c3                   	retq   

ffffffff80103121 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
ffffffff80103121:	55                   	push   %rbp
ffffffff80103122:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103125:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80103129:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010312d:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  initlock(&kmem.lock, "kmem");
ffffffff80103131:	48 c7 c6 b2 97 10 80 	mov    $0xffffffff801097b2,%rsi
ffffffff80103138:	48 c7 c7 00 eb 10 80 	mov    $0xffffffff8010eb00,%rdi
ffffffff8010313f:	e8 c9 29 00 00       	callq  ffffffff80105b0d <initlock>
  kmem.use_lock = 0;
ffffffff80103144:	c7 05 1a ba 00 00 00 	movl   $0x0,0xba1a(%rip)        # ffffffff8010eb68 <kmem+0x68>
ffffffff8010314b:	00 00 00 
  freerange(vstart, vend);
ffffffff8010314e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80103152:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103156:	48 89 d6             	mov    %rdx,%rsi
ffffffff80103159:	48 89 c7             	mov    %rax,%rdi
ffffffff8010315c:	e8 33 00 00 00       	callq  ffffffff80103194 <freerange>
}
ffffffff80103161:	90                   	nop
ffffffff80103162:	c9                   	leaveq 
ffffffff80103163:	c3                   	retq   

ffffffff80103164 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
ffffffff80103164:	55                   	push   %rbp
ffffffff80103165:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103168:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff8010316c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80103170:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  freerange(vstart, vend);
ffffffff80103174:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80103178:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010317c:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010317f:	48 89 c7             	mov    %rax,%rdi
ffffffff80103182:	e8 0d 00 00 00       	callq  ffffffff80103194 <freerange>
  kmem.use_lock = 1;
ffffffff80103187:	c7 05 d7 b9 00 00 01 	movl   $0x1,0xb9d7(%rip)        # ffffffff8010eb68 <kmem+0x68>
ffffffff8010318e:	00 00 00 
}
ffffffff80103191:	90                   	nop
ffffffff80103192:	c9                   	leaveq 
ffffffff80103193:	c3                   	retq   

ffffffff80103194 <freerange>:

void
freerange(void *vstart, void *vend)
{
ffffffff80103194:	55                   	push   %rbp
ffffffff80103195:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103198:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff8010319c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff801031a0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *p;
  p = (char*)PGROUNDUP((uintp)vstart);
ffffffff801031a4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801031a8:	48 05 ff 0f 00 00    	add    $0xfff,%rax
ffffffff801031ae:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801031b4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
ffffffff801031b8:	eb 14                	jmp    ffffffff801031ce <freerange+0x3a>
    kfree(p);
ffffffff801031ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801031be:	48 89 c7             	mov    %rax,%rdi
ffffffff801031c1:	e8 1b 00 00 00       	callq  ffffffff801031e1 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
ffffffff801031c6:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
ffffffff801031cd:	00 
ffffffff801031ce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801031d2:	48 05 00 10 00 00    	add    $0x1000,%rax
ffffffff801031d8:	48 39 45 e0          	cmp    %rax,-0x20(%rbp)
ffffffff801031dc:	73 dc                	jae    ffffffff801031ba <freerange+0x26>
}
ffffffff801031de:	90                   	nop
ffffffff801031df:	c9                   	leaveq 
ffffffff801031e0:	c3                   	retq   

ffffffff801031e1 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
ffffffff801031e1:	55                   	push   %rbp
ffffffff801031e2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801031e5:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801031e9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct run *r;

  if((uintp)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
ffffffff801031ed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801031f1:	25 ff 0f 00 00       	and    $0xfff,%eax
ffffffff801031f6:	48 85 c0             	test   %rax,%rax
ffffffff801031f9:	75 1e                	jne    ffffffff80103219 <kfree+0x38>
ffffffff801031fb:	48 81 7d e8 00 40 11 	cmpq   $0xffffffff80114000,-0x18(%rbp)
ffffffff80103202:	80 
ffffffff80103203:	72 14                	jb     ffffffff80103219 <kfree+0x38>
ffffffff80103205:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103209:	48 89 c7             	mov    %rax,%rdi
ffffffff8010320c:	e8 f6 fe ff ff       	callq  ffffffff80103107 <v2p>
ffffffff80103211:	48 3d ff ff ff 0d    	cmp    $0xdffffff,%rax
ffffffff80103217:	76 0c                	jbe    ffffffff80103225 <kfree+0x44>
    panic("kfree");
ffffffff80103219:	48 c7 c7 b7 97 10 80 	mov    $0xffffffff801097b7,%rdi
ffffffff80103220:	e8 d9 d6 ff ff       	callq  ffffffff801008fe <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
ffffffff80103225:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103229:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff8010322e:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80103233:	48 89 c7             	mov    %rax,%rdi
ffffffff80103236:	e8 76 2c 00 00       	callq  ffffffff80105eb1 <memset>

  if(kmem.use_lock)
ffffffff8010323b:	8b 05 27 b9 00 00    	mov    0xb927(%rip),%eax        # ffffffff8010eb68 <kmem+0x68>
ffffffff80103241:	85 c0                	test   %eax,%eax
ffffffff80103243:	74 0c                	je     ffffffff80103251 <kfree+0x70>
    acquire(&kmem.lock);
ffffffff80103245:	48 c7 c7 00 eb 10 80 	mov    $0xffffffff8010eb00,%rdi
ffffffff8010324c:	e8 f1 28 00 00       	callq  ffffffff80105b42 <acquire>
  r = (struct run*)v;
ffffffff80103251:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103255:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  r->next = kmem.freelist;
ffffffff80103259:	48 8b 15 10 b9 00 00 	mov    0xb910(%rip),%rdx        # ffffffff8010eb70 <kmem+0x70>
ffffffff80103260:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103264:	48 89 10             	mov    %rdx,(%rax)
  kmem.freelist = r;
ffffffff80103267:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010326b:	48 89 05 fe b8 00 00 	mov    %rax,0xb8fe(%rip)        # ffffffff8010eb70 <kmem+0x70>
  if(kmem.use_lock)
ffffffff80103272:	8b 05 f0 b8 00 00    	mov    0xb8f0(%rip),%eax        # ffffffff8010eb68 <kmem+0x68>
ffffffff80103278:	85 c0                	test   %eax,%eax
ffffffff8010327a:	74 0c                	je     ffffffff80103288 <kfree+0xa7>
    release(&kmem.lock);
ffffffff8010327c:	48 c7 c7 00 eb 10 80 	mov    $0xffffffff8010eb00,%rdi
ffffffff80103283:	e8 91 29 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80103288:	90                   	nop
ffffffff80103289:	c9                   	leaveq 
ffffffff8010328a:	c3                   	retq   

ffffffff8010328b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
ffffffff8010328b:	55                   	push   %rbp
ffffffff8010328c:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010328f:	48 83 ec 10          	sub    $0x10,%rsp
  struct run *r;

  if(kmem.use_lock)
ffffffff80103293:	8b 05 cf b8 00 00    	mov    0xb8cf(%rip),%eax        # ffffffff8010eb68 <kmem+0x68>
ffffffff80103299:	85 c0                	test   %eax,%eax
ffffffff8010329b:	74 0c                	je     ffffffff801032a9 <kalloc+0x1e>
    acquire(&kmem.lock);
ffffffff8010329d:	48 c7 c7 00 eb 10 80 	mov    $0xffffffff8010eb00,%rdi
ffffffff801032a4:	e8 99 28 00 00       	callq  ffffffff80105b42 <acquire>
  r = kmem.freelist;
ffffffff801032a9:	48 8b 05 c0 b8 00 00 	mov    0xb8c0(%rip),%rax        # ffffffff8010eb70 <kmem+0x70>
ffffffff801032b0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(r)
ffffffff801032b4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff801032b9:	74 0e                	je     ffffffff801032c9 <kalloc+0x3e>
    kmem.freelist = r->next;
ffffffff801032bb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801032bf:	48 8b 00             	mov    (%rax),%rax
ffffffff801032c2:	48 89 05 a7 b8 00 00 	mov    %rax,0xb8a7(%rip)        # ffffffff8010eb70 <kmem+0x70>
  if(kmem.use_lock)
ffffffff801032c9:	8b 05 99 b8 00 00    	mov    0xb899(%rip),%eax        # ffffffff8010eb68 <kmem+0x68>
ffffffff801032cf:	85 c0                	test   %eax,%eax
ffffffff801032d1:	74 0c                	je     ffffffff801032df <kalloc+0x54>
    release(&kmem.lock);
ffffffff801032d3:	48 c7 c7 00 eb 10 80 	mov    $0xffffffff8010eb00,%rdi
ffffffff801032da:	e8 3a 29 00 00       	callq  ffffffff80105c19 <release>
  return (char*)r;
ffffffff801032df:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff801032e3:	c9                   	leaveq 
ffffffff801032e4:	c3                   	retq   

ffffffff801032e5 <inb>:
{
ffffffff801032e5:	55                   	push   %rbp
ffffffff801032e6:	48 89 e5             	mov    %rsp,%rbp
ffffffff801032e9:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff801032ed:	89 f8                	mov    %edi,%eax
ffffffff801032ef:	66 89 45 ec          	mov    %ax,-0x14(%rbp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
ffffffff801032f3:	0f b7 45 ec          	movzwl -0x14(%rbp),%eax
ffffffff801032f7:	89 c2                	mov    %eax,%edx
ffffffff801032f9:	ec                   	in     (%dx),%al
ffffffff801032fa:	88 45 ff             	mov    %al,-0x1(%rbp)
  return data;
ffffffff801032fd:	0f b6 45 ff          	movzbl -0x1(%rbp),%eax
}
ffffffff80103301:	c9                   	leaveq 
ffffffff80103302:	c3                   	retq   

ffffffff80103303 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
ffffffff80103303:	55                   	push   %rbp
ffffffff80103304:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103307:	48 83 ec 10          	sub    $0x10,%rsp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
ffffffff8010330b:	bf 64 00 00 00       	mov    $0x64,%edi
ffffffff80103310:	e8 d0 ff ff ff       	callq  ffffffff801032e5 <inb>
ffffffff80103315:	0f b6 c0             	movzbl %al,%eax
ffffffff80103318:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if((st & KBS_DIB) == 0)
ffffffff8010331b:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff8010331e:	83 e0 01             	and    $0x1,%eax
ffffffff80103321:	85 c0                	test   %eax,%eax
ffffffff80103323:	75 0a                	jne    ffffffff8010332f <kbdgetc+0x2c>
    return -1;
ffffffff80103325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010332a:	e9 32 01 00 00       	jmpq   ffffffff80103461 <kbdgetc+0x15e>
  data = inb(KBDATAP);
ffffffff8010332f:	bf 60 00 00 00       	mov    $0x60,%edi
ffffffff80103334:	e8 ac ff ff ff       	callq  ffffffff801032e5 <inb>
ffffffff80103339:	0f b6 c0             	movzbl %al,%eax
ffffffff8010333c:	89 45 fc             	mov    %eax,-0x4(%rbp)

  if(data == 0xE0){
ffffffff8010333f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%rbp)
ffffffff80103346:	75 19                	jne    ffffffff80103361 <kbdgetc+0x5e>
    shift |= E0ESC;
ffffffff80103348:	8b 05 2a b8 00 00    	mov    0xb82a(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff8010334e:	83 c8 40             	or     $0x40,%eax
ffffffff80103351:	89 05 21 b8 00 00    	mov    %eax,0xb821(%rip)        # ffffffff8010eb78 <shift.1751>
    return 0;
ffffffff80103357:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010335c:	e9 00 01 00 00       	jmpq   ffffffff80103461 <kbdgetc+0x15e>
  } else if(data & 0x80){
ffffffff80103361:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103364:	25 80 00 00 00       	and    $0x80,%eax
ffffffff80103369:	85 c0                	test   %eax,%eax
ffffffff8010336b:	74 47                	je     ffffffff801033b4 <kbdgetc+0xb1>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
ffffffff8010336d:	8b 05 05 b8 00 00    	mov    0xb805(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff80103373:	83 e0 40             	and    $0x40,%eax
ffffffff80103376:	85 c0                	test   %eax,%eax
ffffffff80103378:	75 08                	jne    ffffffff80103382 <kbdgetc+0x7f>
ffffffff8010337a:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010337d:	83 e0 7f             	and    $0x7f,%eax
ffffffff80103380:	eb 03                	jmp    ffffffff80103385 <kbdgetc+0x82>
ffffffff80103382:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103385:	89 45 fc             	mov    %eax,-0x4(%rbp)
    shift &= ~(shiftcode[data] | E0ESC);
ffffffff80103388:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010338b:	0f b6 80 20 a0 10 80 	movzbl -0x7fef5fe0(%rax),%eax
ffffffff80103392:	83 c8 40             	or     $0x40,%eax
ffffffff80103395:	0f b6 c0             	movzbl %al,%eax
ffffffff80103398:	f7 d0                	not    %eax
ffffffff8010339a:	89 c2                	mov    %eax,%edx
ffffffff8010339c:	8b 05 d6 b7 00 00    	mov    0xb7d6(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff801033a2:	21 d0                	and    %edx,%eax
ffffffff801033a4:	89 05 ce b7 00 00    	mov    %eax,0xb7ce(%rip)        # ffffffff8010eb78 <shift.1751>
    return 0;
ffffffff801033aa:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801033af:	e9 ad 00 00 00       	jmpq   ffffffff80103461 <kbdgetc+0x15e>
  } else if(shift & E0ESC){
ffffffff801033b4:	8b 05 be b7 00 00    	mov    0xb7be(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff801033ba:	83 e0 40             	and    $0x40,%eax
ffffffff801033bd:	85 c0                	test   %eax,%eax
ffffffff801033bf:	74 16                	je     ffffffff801033d7 <kbdgetc+0xd4>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
ffffffff801033c1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%rbp)
    shift &= ~E0ESC;
ffffffff801033c8:	8b 05 aa b7 00 00    	mov    0xb7aa(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff801033ce:	83 e0 bf             	and    $0xffffffbf,%eax
ffffffff801033d1:	89 05 a1 b7 00 00    	mov    %eax,0xb7a1(%rip)        # ffffffff8010eb78 <shift.1751>
  }

  shift |= shiftcode[data];
ffffffff801033d7:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801033da:	0f b6 80 20 a0 10 80 	movzbl -0x7fef5fe0(%rax),%eax
ffffffff801033e1:	0f b6 d0             	movzbl %al,%edx
ffffffff801033e4:	8b 05 8e b7 00 00    	mov    0xb78e(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff801033ea:	09 d0                	or     %edx,%eax
ffffffff801033ec:	89 05 86 b7 00 00    	mov    %eax,0xb786(%rip)        # ffffffff8010eb78 <shift.1751>
  shift ^= togglecode[data];
ffffffff801033f2:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801033f5:	0f b6 80 20 a1 10 80 	movzbl -0x7fef5ee0(%rax),%eax
ffffffff801033fc:	0f b6 d0             	movzbl %al,%edx
ffffffff801033ff:	8b 05 73 b7 00 00    	mov    0xb773(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff80103405:	31 d0                	xor    %edx,%eax
ffffffff80103407:	89 05 6b b7 00 00    	mov    %eax,0xb76b(%rip)        # ffffffff8010eb78 <shift.1751>
  c = charcode[shift & (CTL | SHIFT)][data];
ffffffff8010340d:	8b 05 65 b7 00 00    	mov    0xb765(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff80103413:	83 e0 03             	and    $0x3,%eax
ffffffff80103416:	89 c0                	mov    %eax,%eax
ffffffff80103418:	48 8b 14 c5 20 a5 10 	mov    -0x7fef5ae0(,%rax,8),%rdx
ffffffff8010341f:	80 
ffffffff80103420:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103423:	48 01 d0             	add    %rdx,%rax
ffffffff80103426:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103429:	0f b6 c0             	movzbl %al,%eax
ffffffff8010342c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(shift & CAPSLOCK){
ffffffff8010342f:	8b 05 43 b7 00 00    	mov    0xb743(%rip),%eax        # ffffffff8010eb78 <shift.1751>
ffffffff80103435:	83 e0 08             	and    $0x8,%eax
ffffffff80103438:	85 c0                	test   %eax,%eax
ffffffff8010343a:	74 22                	je     ffffffff8010345e <kbdgetc+0x15b>
    if('a' <= c && c <= 'z')
ffffffff8010343c:	83 7d f8 60          	cmpl   $0x60,-0x8(%rbp)
ffffffff80103440:	76 0c                	jbe    ffffffff8010344e <kbdgetc+0x14b>
ffffffff80103442:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%rbp)
ffffffff80103446:	77 06                	ja     ffffffff8010344e <kbdgetc+0x14b>
      c += 'A' - 'a';
ffffffff80103448:	83 6d f8 20          	subl   $0x20,-0x8(%rbp)
ffffffff8010344c:	eb 10                	jmp    ffffffff8010345e <kbdgetc+0x15b>
    else if('A' <= c && c <= 'Z')
ffffffff8010344e:	83 7d f8 40          	cmpl   $0x40,-0x8(%rbp)
ffffffff80103452:	76 0a                	jbe    ffffffff8010345e <kbdgetc+0x15b>
ffffffff80103454:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%rbp)
ffffffff80103458:	77 04                	ja     ffffffff8010345e <kbdgetc+0x15b>
      c += 'a' - 'A';
ffffffff8010345a:	83 45 f8 20          	addl   $0x20,-0x8(%rbp)
  }
  return c;
ffffffff8010345e:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
ffffffff80103461:	c9                   	leaveq 
ffffffff80103462:	c3                   	retq   

ffffffff80103463 <kbdintr>:

void
kbdintr(void)
{
ffffffff80103463:	55                   	push   %rbp
ffffffff80103464:	48 89 e5             	mov    %rsp,%rbp
  consoleintr(kbdgetc);
ffffffff80103467:	48 c7 c7 03 33 10 80 	mov    $0xffffffff80103303,%rdi
ffffffff8010346e:	e8 16 d7 ff ff       	callq  ffffffff80100b89 <consoleintr>
}
ffffffff80103473:	90                   	nop
ffffffff80103474:	5d                   	pop    %rbp
ffffffff80103475:	c3                   	retq   

ffffffff80103476 <outb>:
{
ffffffff80103476:	55                   	push   %rbp
ffffffff80103477:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010347a:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010347e:	89 fa                	mov    %edi,%edx
ffffffff80103480:	89 f0                	mov    %esi,%eax
ffffffff80103482:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80103486:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80103489:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff8010348d:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff80103491:	ee                   	out    %al,(%dx)
}
ffffffff80103492:	90                   	nop
ffffffff80103493:	c9                   	leaveq 
ffffffff80103494:	c3                   	retq   

ffffffff80103495 <readeflags>:
{
ffffffff80103495:	55                   	push   %rbp
ffffffff80103496:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103499:	48 83 ec 10          	sub    $0x10,%rsp
  asm volatile("pushf; pop %0" : "=r" (eflags));
ffffffff8010349d:	9c                   	pushfq 
ffffffff8010349e:	58                   	pop    %rax
ffffffff8010349f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  return eflags;
ffffffff801034a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff801034a7:	c9                   	leaveq 
ffffffff801034a8:	c3                   	retq   

ffffffff801034a9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
ffffffff801034a9:	55                   	push   %rbp
ffffffff801034aa:	48 89 e5             	mov    %rsp,%rbp
ffffffff801034ad:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff801034b1:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff801034b4:	89 75 f8             	mov    %esi,-0x8(%rbp)
  lapic[index] = value;
ffffffff801034b7:	48 8b 05 c2 b6 00 00 	mov    0xb6c2(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff801034be:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801034c1:	48 63 d2             	movslq %edx,%rdx
ffffffff801034c4:	48 c1 e2 02          	shl    $0x2,%rdx
ffffffff801034c8:	48 01 c2             	add    %rax,%rdx
ffffffff801034cb:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff801034ce:	89 02                	mov    %eax,(%rdx)
  lapic[ID];  // wait for write to finish, by reading
ffffffff801034d0:	48 8b 05 a9 b6 00 00 	mov    0xb6a9(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff801034d7:	48 83 c0 20          	add    $0x20,%rax
ffffffff801034db:	8b 00                	mov    (%rax),%eax
}
ffffffff801034dd:	90                   	nop
ffffffff801034de:	c9                   	leaveq 
ffffffff801034df:	c3                   	retq   

ffffffff801034e0 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
ffffffff801034e0:	55                   	push   %rbp
ffffffff801034e1:	48 89 e5             	mov    %rsp,%rbp
  if(!lapic) 
ffffffff801034e4:	48 8b 05 95 b6 00 00 	mov    0xb695(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff801034eb:	48 85 c0             	test   %rax,%rax
ffffffff801034ee:	0f 84 05 01 00 00    	je     ffffffff801035f9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
ffffffff801034f4:	be 3f 01 00 00       	mov    $0x13f,%esi
ffffffff801034f9:	bf 3c 00 00 00       	mov    $0x3c,%edi
ffffffff801034fe:	e8 a6 ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
ffffffff80103503:	be 0b 00 00 00       	mov    $0xb,%esi
ffffffff80103508:	bf f8 00 00 00       	mov    $0xf8,%edi
ffffffff8010350d:	e8 97 ff ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
ffffffff80103512:	be 20 00 02 00       	mov    $0x20020,%esi
ffffffff80103517:	bf c8 00 00 00       	mov    $0xc8,%edi
ffffffff8010351c:	e8 88 ff ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(TICR, 10000000); 
ffffffff80103521:	be 80 96 98 00       	mov    $0x989680,%esi
ffffffff80103526:	bf e0 00 00 00       	mov    $0xe0,%edi
ffffffff8010352b:	e8 79 ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
ffffffff80103530:	be 00 00 01 00       	mov    $0x10000,%esi
ffffffff80103535:	bf d4 00 00 00       	mov    $0xd4,%edi
ffffffff8010353a:	e8 6a ff ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(LINT1, MASKED);
ffffffff8010353f:	be 00 00 01 00       	mov    $0x10000,%esi
ffffffff80103544:	bf d8 00 00 00       	mov    $0xd8,%edi
ffffffff80103549:	e8 5b ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
ffffffff8010354e:	48 8b 05 2b b6 00 00 	mov    0xb62b(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff80103555:	48 83 c0 30          	add    $0x30,%rax
ffffffff80103559:	8b 00                	mov    (%rax),%eax
ffffffff8010355b:	c1 e8 10             	shr    $0x10,%eax
ffffffff8010355e:	0f b6 c0             	movzbl %al,%eax
ffffffff80103561:	83 f8 03             	cmp    $0x3,%eax
ffffffff80103564:	76 0f                	jbe    ffffffff80103575 <lapicinit+0x95>
    lapicw(PCINT, MASKED);
ffffffff80103566:	be 00 00 01 00       	mov    $0x10000,%esi
ffffffff8010356b:	bf d0 00 00 00       	mov    $0xd0,%edi
ffffffff80103570:	e8 34 ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
ffffffff80103575:	be 33 00 00 00       	mov    $0x33,%esi
ffffffff8010357a:	bf dc 00 00 00       	mov    $0xdc,%edi
ffffffff8010357f:	e8 25 ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
ffffffff80103584:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80103589:	bf a0 00 00 00       	mov    $0xa0,%edi
ffffffff8010358e:	e8 16 ff ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(ESR, 0);
ffffffff80103593:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80103598:	bf a0 00 00 00       	mov    $0xa0,%edi
ffffffff8010359d:	e8 07 ff ff ff       	callq  ffffffff801034a9 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
ffffffff801035a2:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801035a7:	bf 2c 00 00 00       	mov    $0x2c,%edi
ffffffff801035ac:	e8 f8 fe ff ff       	callq  ffffffff801034a9 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
ffffffff801035b1:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801035b6:	bf c4 00 00 00       	mov    $0xc4,%edi
ffffffff801035bb:	e8 e9 fe ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
ffffffff801035c0:	be 00 85 08 00       	mov    $0x88500,%esi
ffffffff801035c5:	bf c0 00 00 00       	mov    $0xc0,%edi
ffffffff801035ca:	e8 da fe ff ff       	callq  ffffffff801034a9 <lapicw>
  while(lapic[ICRLO] & DELIVS)
ffffffff801035cf:	90                   	nop
ffffffff801035d0:	48 8b 05 a9 b5 00 00 	mov    0xb5a9(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff801035d7:	48 05 00 03 00 00    	add    $0x300,%rax
ffffffff801035dd:	8b 00                	mov    (%rax),%eax
ffffffff801035df:	25 00 10 00 00       	and    $0x1000,%eax
ffffffff801035e4:	85 c0                	test   %eax,%eax
ffffffff801035e6:	75 e8                	jne    ffffffff801035d0 <lapicinit+0xf0>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
ffffffff801035e8:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801035ed:	bf 20 00 00 00       	mov    $0x20,%edi
ffffffff801035f2:	e8 b2 fe ff ff       	callq  ffffffff801034a9 <lapicw>
ffffffff801035f7:	eb 01                	jmp    ffffffff801035fa <lapicinit+0x11a>
    return;
ffffffff801035f9:	90                   	nop
}
ffffffff801035fa:	5d                   	pop    %rbp
ffffffff801035fb:	c3                   	retq   

ffffffff801035fc <cpunum>:
// This is only used during secondary processor startup.
// cpu->id is the fast way to get the cpu number, once the
// processor is fully started.
int
cpunum(void)
{
ffffffff801035fc:	55                   	push   %rbp
ffffffff801035fd:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103600:	48 83 ec 10          	sub    $0x10,%rsp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
ffffffff80103604:	e8 8c fe ff ff       	callq  ffffffff80103495 <readeflags>
ffffffff80103609:	25 00 02 00 00       	and    $0x200,%eax
ffffffff8010360e:	48 85 c0             	test   %rax,%rax
ffffffff80103611:	74 2b                	je     ffffffff8010363e <cpunum+0x42>
    static int n;
    if(n++ == 0)
ffffffff80103613:	8b 05 6f b5 00 00    	mov    0xb56f(%rip),%eax        # ffffffff8010eb88 <n.1870>
ffffffff80103619:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff8010361c:	89 15 66 b5 00 00    	mov    %edx,0xb566(%rip)        # ffffffff8010eb88 <n.1870>
ffffffff80103622:	85 c0                	test   %eax,%eax
ffffffff80103624:	75 18                	jne    ffffffff8010363e <cpunum+0x42>
      cprintf("cpu called from %x with interrupts enabled\n",
ffffffff80103626:	48 8b 45 08          	mov    0x8(%rbp),%rax
ffffffff8010362a:	48 89 c6             	mov    %rax,%rsi
ffffffff8010362d:	48 c7 c7 c0 97 10 80 	mov    $0xffffffff801097c0,%rdi
ffffffff80103634:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80103639:	e8 63 cf ff ff       	callq  ffffffff801005a1 <cprintf>
        __builtin_return_address(0));
  }

  if(!lapic)
ffffffff8010363e:	48 8b 05 3b b5 00 00 	mov    0xb53b(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff80103645:	48 85 c0             	test   %rax,%rax
ffffffff80103648:	75 07                	jne    ffffffff80103651 <cpunum+0x55>
    return 0;
ffffffff8010364a:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010364f:	eb 5a                	jmp    ffffffff801036ab <cpunum+0xaf>

  id = lapic[ID]>>24;
ffffffff80103651:	48 8b 05 28 b5 00 00 	mov    0xb528(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff80103658:	48 83 c0 20          	add    $0x20,%rax
ffffffff8010365c:	8b 00                	mov    (%rax),%eax
ffffffff8010365e:	c1 e8 18             	shr    $0x18,%eax
ffffffff80103661:	89 45 f8             	mov    %eax,-0x8(%rbp)
  for (n = 0; n < ncpu; n++)
ffffffff80103664:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010366b:	eb 2e                	jmp    ffffffff8010369b <cpunum+0x9f>
    if (id == cpus[n].apicid)
ffffffff8010366d:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103670:	48 63 d0             	movslq %eax,%rdx
ffffffff80103673:	48 89 d0             	mov    %rdx,%rax
ffffffff80103676:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff8010367a:	48 29 d0             	sub    %rdx,%rax
ffffffff8010367d:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80103681:	48 05 61 ec 10 80    	add    $0xffffffff8010ec61,%rax
ffffffff80103687:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010368a:	0f b6 c0             	movzbl %al,%eax
ffffffff8010368d:	39 45 f8             	cmp    %eax,-0x8(%rbp)
ffffffff80103690:	75 05                	jne    ffffffff80103697 <cpunum+0x9b>
      return n;
ffffffff80103692:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103695:	eb 14                	jmp    ffffffff801036ab <cpunum+0xaf>
  for (n = 0; n < ncpu; n++)
ffffffff80103697:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff8010369b:	8b 05 43 bd 00 00    	mov    0xbd43(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff801036a1:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff801036a4:	7c c7                	jl     ffffffff8010366d <cpunum+0x71>

  return 0;
ffffffff801036a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801036ab:	c9                   	leaveq 
ffffffff801036ac:	c3                   	retq   

ffffffff801036ad <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
ffffffff801036ad:	55                   	push   %rbp
ffffffff801036ae:	48 89 e5             	mov    %rsp,%rbp
  if(lapic)
ffffffff801036b1:	48 8b 05 c8 b4 00 00 	mov    0xb4c8(%rip),%rax        # ffffffff8010eb80 <lapic>
ffffffff801036b8:	48 85 c0             	test   %rax,%rax
ffffffff801036bb:	74 0f                	je     ffffffff801036cc <lapiceoi+0x1f>
    lapicw(EOI, 0);
ffffffff801036bd:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801036c2:	bf 2c 00 00 00       	mov    $0x2c,%edi
ffffffff801036c7:	e8 dd fd ff ff       	callq  ffffffff801034a9 <lapicw>
}
ffffffff801036cc:	90                   	nop
ffffffff801036cd:	5d                   	pop    %rbp
ffffffff801036ce:	c3                   	retq   

ffffffff801036cf <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
ffffffff801036cf:	55                   	push   %rbp
ffffffff801036d0:	48 89 e5             	mov    %rsp,%rbp
ffffffff801036d3:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff801036d7:	89 7d fc             	mov    %edi,-0x4(%rbp)
}
ffffffff801036da:	90                   	nop
ffffffff801036db:	c9                   	leaveq 
ffffffff801036dc:	c3                   	retq   

ffffffff801036dd <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
ffffffff801036dd:	55                   	push   %rbp
ffffffff801036de:	48 89 e5             	mov    %rsp,%rbp
ffffffff801036e1:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff801036e5:	89 f8                	mov    %edi,%eax
ffffffff801036e7:	89 75 e8             	mov    %esi,-0x18(%rbp)
ffffffff801036ea:	88 45 ec             	mov    %al,-0x14(%rbp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
ffffffff801036ed:	be 0f 00 00 00       	mov    $0xf,%esi
ffffffff801036f2:	bf 70 00 00 00       	mov    $0x70,%edi
ffffffff801036f7:	e8 7a fd ff ff       	callq  ffffffff80103476 <outb>
  outb(IO_RTC+1, 0x0A);
ffffffff801036fc:	be 0a 00 00 00       	mov    $0xa,%esi
ffffffff80103701:	bf 71 00 00 00       	mov    $0x71,%edi
ffffffff80103706:	e8 6b fd ff ff       	callq  ffffffff80103476 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
ffffffff8010370b:	48 c7 45 f0 67 04 00 	movq   $0xffffffff80000467,-0x10(%rbp)
ffffffff80103712:	80 
  wrv[0] = 0;
ffffffff80103713:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103717:	66 c7 00 00 00       	movw   $0x0,(%rax)
  wrv[1] = addr >> 4;
ffffffff8010371c:	8b 45 e8             	mov    -0x18(%rbp),%eax
ffffffff8010371f:	c1 e8 04             	shr    $0x4,%eax
ffffffff80103722:	89 c2                	mov    %eax,%edx
ffffffff80103724:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103728:	48 83 c0 02          	add    $0x2,%rax
ffffffff8010372c:	66 89 10             	mov    %dx,(%rax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
ffffffff8010372f:	0f b6 45 ec          	movzbl -0x14(%rbp),%eax
ffffffff80103733:	c1 e0 18             	shl    $0x18,%eax
ffffffff80103736:	89 c6                	mov    %eax,%esi
ffffffff80103738:	bf c4 00 00 00       	mov    $0xc4,%edi
ffffffff8010373d:	e8 67 fd ff ff       	callq  ffffffff801034a9 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
ffffffff80103742:	be 00 c5 00 00       	mov    $0xc500,%esi
ffffffff80103747:	bf c0 00 00 00       	mov    $0xc0,%edi
ffffffff8010374c:	e8 58 fd ff ff       	callq  ffffffff801034a9 <lapicw>
  microdelay(200);
ffffffff80103751:	bf c8 00 00 00       	mov    $0xc8,%edi
ffffffff80103756:	e8 74 ff ff ff       	callq  ffffffff801036cf <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
ffffffff8010375b:	be 00 85 00 00       	mov    $0x8500,%esi
ffffffff80103760:	bf c0 00 00 00       	mov    $0xc0,%edi
ffffffff80103765:	e8 3f fd ff ff       	callq  ffffffff801034a9 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
ffffffff8010376a:	bf 64 00 00 00       	mov    $0x64,%edi
ffffffff8010376f:	e8 5b ff ff ff       	callq  ffffffff801036cf <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
ffffffff80103774:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010377b:	eb 36                	jmp    ffffffff801037b3 <lapicstartap+0xd6>
    lapicw(ICRHI, apicid<<24);
ffffffff8010377d:	0f b6 45 ec          	movzbl -0x14(%rbp),%eax
ffffffff80103781:	c1 e0 18             	shl    $0x18,%eax
ffffffff80103784:	89 c6                	mov    %eax,%esi
ffffffff80103786:	bf c4 00 00 00       	mov    $0xc4,%edi
ffffffff8010378b:	e8 19 fd ff ff       	callq  ffffffff801034a9 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
ffffffff80103790:	8b 45 e8             	mov    -0x18(%rbp),%eax
ffffffff80103793:	c1 e8 0c             	shr    $0xc,%eax
ffffffff80103796:	80 cc 06             	or     $0x6,%ah
ffffffff80103799:	89 c6                	mov    %eax,%esi
ffffffff8010379b:	bf c0 00 00 00       	mov    $0xc0,%edi
ffffffff801037a0:	e8 04 fd ff ff       	callq  ffffffff801034a9 <lapicw>
    microdelay(200);
ffffffff801037a5:	bf c8 00 00 00       	mov    $0xc8,%edi
ffffffff801037aa:	e8 20 ff ff ff       	callq  ffffffff801036cf <microdelay>
  for(i = 0; i < 2; i++){
ffffffff801037af:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801037b3:	83 7d fc 01          	cmpl   $0x1,-0x4(%rbp)
ffffffff801037b7:	7e c4                	jle    ffffffff8010377d <lapicstartap+0xa0>
  }
}
ffffffff801037b9:	90                   	nop
ffffffff801037ba:	c9                   	leaveq 
ffffffff801037bb:	c3                   	retq   

ffffffff801037bc <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
ffffffff801037bc:	55                   	push   %rbp
ffffffff801037bd:	48 89 e5             	mov    %rsp,%rbp
ffffffff801037c0:	48 83 ec 10          	sub    $0x10,%rsp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
ffffffff801037c4:	48 c7 c6 ec 97 10 80 	mov    $0xffffffff801097ec,%rsi
ffffffff801037cb:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff801037d2:	e8 36 23 00 00       	callq  ffffffff80105b0d <initlock>
  readsb(ROOTDEV, &sb);
ffffffff801037d7:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff801037db:	48 89 c6             	mov    %rax,%rsi
ffffffff801037de:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff801037e3:	e8 7c e0 ff ff       	callq  ffffffff80101864 <readsb>
  log.start = sb.size - sb.nlog;
ffffffff801037e8:	8b 55 f0             	mov    -0x10(%rbp),%edx
ffffffff801037eb:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801037ee:	29 c2                	sub    %eax,%edx
ffffffff801037f0:	89 d0                	mov    %edx,%eax
ffffffff801037f2:	89 05 10 b4 00 00    	mov    %eax,0xb410(%rip)        # ffffffff8010ec08 <log+0x68>
  log.size = sb.nlog;
ffffffff801037f8:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801037fb:	89 05 0b b4 00 00    	mov    %eax,0xb40b(%rip)        # ffffffff8010ec0c <log+0x6c>
  log.dev = ROOTDEV;
ffffffff80103801:	c7 05 09 b4 00 00 01 	movl   $0x1,0xb409(%rip)        # ffffffff8010ec14 <log+0x74>
ffffffff80103808:	00 00 00 
  recover_from_log();
ffffffff8010380b:	e8 c6 01 00 00       	callq  ffffffff801039d6 <recover_from_log>
}
ffffffff80103810:	90                   	nop
ffffffff80103811:	c9                   	leaveq 
ffffffff80103812:	c3                   	retq   

ffffffff80103813 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
ffffffff80103813:	55                   	push   %rbp
ffffffff80103814:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103817:	48 83 ec 20          	sub    $0x20,%rsp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
ffffffff8010381b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80103822:	e9 90 00 00 00       	jmpq   ffffffff801038b7 <install_trans+0xa4>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
ffffffff80103827:	8b 15 db b3 00 00    	mov    0xb3db(%rip),%edx        # ffffffff8010ec08 <log+0x68>
ffffffff8010382d:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103830:	01 d0                	add    %edx,%eax
ffffffff80103832:	83 c0 01             	add    $0x1,%eax
ffffffff80103835:	89 c2                	mov    %eax,%edx
ffffffff80103837:	8b 05 d7 b3 00 00    	mov    0xb3d7(%rip),%eax        # ffffffff8010ec14 <log+0x74>
ffffffff8010383d:	89 d6                	mov    %edx,%esi
ffffffff8010383f:	89 c7                	mov    %eax,%edi
ffffffff80103841:	e8 90 ca ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80103846:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
ffffffff8010384a:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010384d:	48 98                	cltq   
ffffffff8010384f:	48 83 c0 1c          	add    $0x1c,%rax
ffffffff80103853:	8b 04 85 ac eb 10 80 	mov    -0x7fef1454(,%rax,4),%eax
ffffffff8010385a:	89 c2                	mov    %eax,%edx
ffffffff8010385c:	8b 05 b2 b3 00 00    	mov    0xb3b2(%rip),%eax        # ffffffff8010ec14 <log+0x74>
ffffffff80103862:	89 d6                	mov    %edx,%esi
ffffffff80103864:	89 c7                	mov    %eax,%edi
ffffffff80103866:	e8 6b ca ff ff       	callq  ffffffff801002d6 <bread>
ffffffff8010386b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
ffffffff8010386f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103873:	48 8d 48 28          	lea    0x28(%rax),%rcx
ffffffff80103877:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010387b:	48 83 c0 28          	add    $0x28,%rax
ffffffff8010387f:	ba 00 02 00 00       	mov    $0x200,%edx
ffffffff80103884:	48 89 ce             	mov    %rcx,%rsi
ffffffff80103887:	48 89 c7             	mov    %rax,%rdi
ffffffff8010388a:	e8 11 27 00 00       	callq  ffffffff80105fa0 <memmove>
    bwrite(dbuf);  // write dst to disk
ffffffff8010388f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103893:	48 89 c7             	mov    %rax,%rdi
ffffffff80103896:	e8 7b ca ff ff       	callq  ffffffff80100316 <bwrite>
    brelse(lbuf); 
ffffffff8010389b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010389f:	48 89 c7             	mov    %rax,%rdi
ffffffff801038a2:	e8 b4 ca ff ff       	callq  ffffffff8010035b <brelse>
    brelse(dbuf);
ffffffff801038a7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801038ab:	48 89 c7             	mov    %rax,%rdi
ffffffff801038ae:	e8 a8 ca ff ff       	callq  ffffffff8010035b <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
ffffffff801038b3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801038b7:	8b 05 5b b3 00 00    	mov    0xb35b(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff801038bd:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff801038c0:	0f 8c 61 ff ff ff    	jl     ffffffff80103827 <install_trans+0x14>
  }
}
ffffffff801038c6:	90                   	nop
ffffffff801038c7:	c9                   	leaveq 
ffffffff801038c8:	c3                   	retq   

ffffffff801038c9 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
ffffffff801038c9:	55                   	push   %rbp
ffffffff801038ca:	48 89 e5             	mov    %rsp,%rbp
ffffffff801038cd:	48 83 ec 20          	sub    $0x20,%rsp
  struct buf *buf = bread(log.dev, log.start);
ffffffff801038d1:	8b 05 31 b3 00 00    	mov    0xb331(%rip),%eax        # ffffffff8010ec08 <log+0x68>
ffffffff801038d7:	89 c2                	mov    %eax,%edx
ffffffff801038d9:	8b 05 35 b3 00 00    	mov    0xb335(%rip),%eax        # ffffffff8010ec14 <log+0x74>
ffffffff801038df:	89 d6                	mov    %edx,%esi
ffffffff801038e1:	89 c7                	mov    %eax,%edi
ffffffff801038e3:	e8 ee c9 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff801038e8:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  struct logheader *lh = (struct logheader *) (buf->data);
ffffffff801038ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801038f0:	48 83 c0 28          	add    $0x28,%rax
ffffffff801038f4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  int i;
  log.lh.n = lh->n;
ffffffff801038f8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801038fc:	8b 00                	mov    (%rax),%eax
ffffffff801038fe:	89 05 14 b3 00 00    	mov    %eax,0xb314(%rip)        # ffffffff8010ec18 <log+0x78>
  for (i = 0; i < log.lh.n; i++) {
ffffffff80103904:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010390b:	eb 23                	jmp    ffffffff80103930 <read_head+0x67>
    log.lh.sector[i] = lh->sector[i];
ffffffff8010390d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103911:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80103914:	48 63 d2             	movslq %edx,%rdx
ffffffff80103917:	8b 44 90 04          	mov    0x4(%rax,%rdx,4),%eax
ffffffff8010391b:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff8010391e:	48 63 d2             	movslq %edx,%rdx
ffffffff80103921:	48 83 c2 1c          	add    $0x1c,%rdx
ffffffff80103925:	89 04 95 ac eb 10 80 	mov    %eax,-0x7fef1454(,%rdx,4)
  for (i = 0; i < log.lh.n; i++) {
ffffffff8010392c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80103930:	8b 05 e2 b2 00 00    	mov    0xb2e2(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103936:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff80103939:	7c d2                	jl     ffffffff8010390d <read_head+0x44>
  }
  brelse(buf);
ffffffff8010393b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010393f:	48 89 c7             	mov    %rax,%rdi
ffffffff80103942:	e8 14 ca ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff80103947:	90                   	nop
ffffffff80103948:	c9                   	leaveq 
ffffffff80103949:	c3                   	retq   

ffffffff8010394a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
ffffffff8010394a:	55                   	push   %rbp
ffffffff8010394b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010394e:	48 83 ec 20          	sub    $0x20,%rsp
  struct buf *buf = bread(log.dev, log.start);
ffffffff80103952:	8b 05 b0 b2 00 00    	mov    0xb2b0(%rip),%eax        # ffffffff8010ec08 <log+0x68>
ffffffff80103958:	89 c2                	mov    %eax,%edx
ffffffff8010395a:	8b 05 b4 b2 00 00    	mov    0xb2b4(%rip),%eax        # ffffffff8010ec14 <log+0x74>
ffffffff80103960:	89 d6                	mov    %edx,%esi
ffffffff80103962:	89 c7                	mov    %eax,%edi
ffffffff80103964:	e8 6d c9 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80103969:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  struct logheader *hb = (struct logheader *) (buf->data);
ffffffff8010396d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103971:	48 83 c0 28          	add    $0x28,%rax
ffffffff80103975:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  int i;
  hb->n = log.lh.n;
ffffffff80103979:	8b 15 99 b2 00 00    	mov    0xb299(%rip),%edx        # ffffffff8010ec18 <log+0x78>
ffffffff8010397f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103983:	89 10                	mov    %edx,(%rax)
  for (i = 0; i < log.lh.n; i++) {
ffffffff80103985:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff8010398c:	eb 22                	jmp    ffffffff801039b0 <write_head+0x66>
    hb->sector[i] = log.lh.sector[i];
ffffffff8010398e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103991:	48 98                	cltq   
ffffffff80103993:	48 83 c0 1c          	add    $0x1c,%rax
ffffffff80103997:	8b 0c 85 ac eb 10 80 	mov    -0x7fef1454(,%rax,4),%ecx
ffffffff8010399e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801039a2:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801039a5:	48 63 d2             	movslq %edx,%rdx
ffffffff801039a8:	89 4c 90 04          	mov    %ecx,0x4(%rax,%rdx,4)
  for (i = 0; i < log.lh.n; i++) {
ffffffff801039ac:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801039b0:	8b 05 62 b2 00 00    	mov    0xb262(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff801039b6:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff801039b9:	7c d3                	jl     ffffffff8010398e <write_head+0x44>
  }
  bwrite(buf);
ffffffff801039bb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801039bf:	48 89 c7             	mov    %rax,%rdi
ffffffff801039c2:	e8 4f c9 ff ff       	callq  ffffffff80100316 <bwrite>
  brelse(buf);
ffffffff801039c7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801039cb:	48 89 c7             	mov    %rax,%rdi
ffffffff801039ce:	e8 88 c9 ff ff       	callq  ffffffff8010035b <brelse>
}
ffffffff801039d3:	90                   	nop
ffffffff801039d4:	c9                   	leaveq 
ffffffff801039d5:	c3                   	retq   

ffffffff801039d6 <recover_from_log>:

static void
recover_from_log(void)
{
ffffffff801039d6:	55                   	push   %rbp
ffffffff801039d7:	48 89 e5             	mov    %rsp,%rbp
  read_head();      
ffffffff801039da:	e8 ea fe ff ff       	callq  ffffffff801038c9 <read_head>
  install_trans(); // if committed, copy from log to disk
ffffffff801039df:	e8 2f fe ff ff       	callq  ffffffff80103813 <install_trans>
  log.lh.n = 0;
ffffffff801039e4:	c7 05 2a b2 00 00 00 	movl   $0x0,0xb22a(%rip)        # ffffffff8010ec18 <log+0x78>
ffffffff801039eb:	00 00 00 
  write_head(); // clear the log
ffffffff801039ee:	e8 57 ff ff ff       	callq  ffffffff8010394a <write_head>
}
ffffffff801039f3:	90                   	nop
ffffffff801039f4:	5d                   	pop    %rbp
ffffffff801039f5:	c3                   	retq   

ffffffff801039f6 <begin_trans>:

void
begin_trans(void)
{
ffffffff801039f6:	55                   	push   %rbp
ffffffff801039f7:	48 89 e5             	mov    %rsp,%rbp
  acquire(&log.lock);
ffffffff801039fa:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a01:	e8 3c 21 00 00       	callq  ffffffff80105b42 <acquire>
  while (log.busy) {
ffffffff80103a06:	eb 13                	jmp    ffffffff80103a1b <begin_trans+0x25>
    sleep(&log, &log.lock);
ffffffff80103a08:	48 c7 c6 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rsi
ffffffff80103a0f:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a16:	e8 b5 1d 00 00       	callq  ffffffff801057d0 <sleep>
  while (log.busy) {
ffffffff80103a1b:	8b 05 ef b1 00 00    	mov    0xb1ef(%rip),%eax        # ffffffff8010ec10 <log+0x70>
ffffffff80103a21:	85 c0                	test   %eax,%eax
ffffffff80103a23:	75 e3                	jne    ffffffff80103a08 <begin_trans+0x12>
  }
  log.busy = 1;
ffffffff80103a25:	c7 05 e1 b1 00 00 01 	movl   $0x1,0xb1e1(%rip)        # ffffffff8010ec10 <log+0x70>
ffffffff80103a2c:	00 00 00 
  release(&log.lock);
ffffffff80103a2f:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a36:	e8 de 21 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80103a3b:	90                   	nop
ffffffff80103a3c:	5d                   	pop    %rbp
ffffffff80103a3d:	c3                   	retq   

ffffffff80103a3e <commit_trans>:

void
commit_trans(void)
{
ffffffff80103a3e:	55                   	push   %rbp
ffffffff80103a3f:	48 89 e5             	mov    %rsp,%rbp
  if (log.lh.n > 0) {
ffffffff80103a42:	8b 05 d0 b1 00 00    	mov    0xb1d0(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103a48:	85 c0                	test   %eax,%eax
ffffffff80103a4a:	7e 19                	jle    ffffffff80103a65 <commit_trans+0x27>
    write_head();    // Write header to disk -- the real commit
ffffffff80103a4c:	e8 f9 fe ff ff       	callq  ffffffff8010394a <write_head>
    install_trans(); // Now install writes to home locations
ffffffff80103a51:	e8 bd fd ff ff       	callq  ffffffff80103813 <install_trans>
    log.lh.n = 0; 
ffffffff80103a56:	c7 05 b8 b1 00 00 00 	movl   $0x0,0xb1b8(%rip)        # ffffffff8010ec18 <log+0x78>
ffffffff80103a5d:	00 00 00 
    write_head();    // Erase the transaction from the log
ffffffff80103a60:	e8 e5 fe ff ff       	callq  ffffffff8010394a <write_head>
  }
  
  acquire(&log.lock);
ffffffff80103a65:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a6c:	e8 d1 20 00 00       	callq  ffffffff80105b42 <acquire>
  log.busy = 0;
ffffffff80103a71:	c7 05 95 b1 00 00 00 	movl   $0x0,0xb195(%rip)        # ffffffff8010ec10 <log+0x70>
ffffffff80103a78:	00 00 00 
  wakeup(&log);
ffffffff80103a7b:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a82:	e8 5c 1e 00 00       	callq  ffffffff801058e3 <wakeup>
  release(&log.lock);
ffffffff80103a87:	48 c7 c7 a0 eb 10 80 	mov    $0xffffffff8010eba0,%rdi
ffffffff80103a8e:	e8 86 21 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80103a93:	90                   	nop
ffffffff80103a94:	5d                   	pop    %rbp
ffffffff80103a95:	c3                   	retq   

ffffffff80103a96 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
ffffffff80103a96:	55                   	push   %rbp
ffffffff80103a97:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103a9a:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80103a9e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
ffffffff80103aa2:	8b 05 70 b1 00 00    	mov    0xb170(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103aa8:	83 f8 09             	cmp    $0x9,%eax
ffffffff80103aab:	7f 13                	jg     ffffffff80103ac0 <log_write+0x2a>
ffffffff80103aad:	8b 05 65 b1 00 00    	mov    0xb165(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103ab3:	8b 15 53 b1 00 00    	mov    0xb153(%rip),%edx        # ffffffff8010ec0c <log+0x6c>
ffffffff80103ab9:	83 ea 01             	sub    $0x1,%edx
ffffffff80103abc:	39 d0                	cmp    %edx,%eax
ffffffff80103abe:	7c 0c                	jl     ffffffff80103acc <log_write+0x36>
    panic("too big a transaction");
ffffffff80103ac0:	48 c7 c7 f0 97 10 80 	mov    $0xffffffff801097f0,%rdi
ffffffff80103ac7:	e8 32 ce ff ff       	callq  ffffffff801008fe <panic>
  if (!log.busy)
ffffffff80103acc:	8b 05 3e b1 00 00    	mov    0xb13e(%rip),%eax        # ffffffff8010ec10 <log+0x70>
ffffffff80103ad2:	85 c0                	test   %eax,%eax
ffffffff80103ad4:	75 0c                	jne    ffffffff80103ae2 <log_write+0x4c>
    panic("write outside of trans");
ffffffff80103ad6:	48 c7 c7 06 98 10 80 	mov    $0xffffffff80109806,%rdi
ffffffff80103add:	e8 1c ce ff ff       	callq  ffffffff801008fe <panic>

  for (i = 0; i < log.lh.n; i++) {
ffffffff80103ae2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80103ae9:	eb 21                	jmp    ffffffff80103b0c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
ffffffff80103aeb:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103aee:	48 98                	cltq   
ffffffff80103af0:	48 83 c0 1c          	add    $0x1c,%rax
ffffffff80103af4:	8b 04 85 ac eb 10 80 	mov    -0x7fef1454(,%rax,4),%eax
ffffffff80103afb:	89 c2                	mov    %eax,%edx
ffffffff80103afd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103b01:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80103b04:	39 c2                	cmp    %eax,%edx
ffffffff80103b06:	74 11                	je     ffffffff80103b19 <log_write+0x83>
  for (i = 0; i < log.lh.n; i++) {
ffffffff80103b08:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80103b0c:	8b 05 06 b1 00 00    	mov    0xb106(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103b12:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff80103b15:	7c d4                	jl     ffffffff80103aeb <log_write+0x55>
ffffffff80103b17:	eb 01                	jmp    ffffffff80103b1a <log_write+0x84>
      break;
ffffffff80103b19:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
ffffffff80103b1a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103b1e:	8b 40 08             	mov    0x8(%rax),%eax
ffffffff80103b21:	89 c2                	mov    %eax,%edx
ffffffff80103b23:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103b26:	48 98                	cltq   
ffffffff80103b28:	48 83 c0 1c          	add    $0x1c,%rax
ffffffff80103b2c:	89 14 85 ac eb 10 80 	mov    %edx,-0x7fef1454(,%rax,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
ffffffff80103b33:	8b 15 cf b0 00 00    	mov    0xb0cf(%rip),%edx        # ffffffff8010ec08 <log+0x68>
ffffffff80103b39:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103b3c:	01 d0                	add    %edx,%eax
ffffffff80103b3e:	83 c0 01             	add    $0x1,%eax
ffffffff80103b41:	89 c2                	mov    %eax,%edx
ffffffff80103b43:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103b47:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80103b4a:	89 d6                	mov    %edx,%esi
ffffffff80103b4c:	89 c7                	mov    %eax,%edi
ffffffff80103b4e:	e8 83 c7 ff ff       	callq  ffffffff801002d6 <bread>
ffffffff80103b53:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  memmove(lbuf->data, b->data, BSIZE);
ffffffff80103b57:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103b5b:	48 8d 48 28          	lea    0x28(%rax),%rcx
ffffffff80103b5f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103b63:	48 83 c0 28          	add    $0x28,%rax
ffffffff80103b67:	ba 00 02 00 00       	mov    $0x200,%edx
ffffffff80103b6c:	48 89 ce             	mov    %rcx,%rsi
ffffffff80103b6f:	48 89 c7             	mov    %rax,%rdi
ffffffff80103b72:	e8 29 24 00 00       	callq  ffffffff80105fa0 <memmove>
  bwrite(lbuf);
ffffffff80103b77:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103b7b:	48 89 c7             	mov    %rax,%rdi
ffffffff80103b7e:	e8 93 c7 ff ff       	callq  ffffffff80100316 <bwrite>
  brelse(lbuf);
ffffffff80103b83:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103b87:	48 89 c7             	mov    %rax,%rdi
ffffffff80103b8a:	e8 cc c7 ff ff       	callq  ffffffff8010035b <brelse>
  if (i == log.lh.n)
ffffffff80103b8f:	8b 05 83 b0 00 00    	mov    0xb083(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103b95:	39 45 fc             	cmp    %eax,-0x4(%rbp)
ffffffff80103b98:	75 0f                	jne    ffffffff80103ba9 <log_write+0x113>
    log.lh.n++;
ffffffff80103b9a:	8b 05 78 b0 00 00    	mov    0xb078(%rip),%eax        # ffffffff8010ec18 <log+0x78>
ffffffff80103ba0:	83 c0 01             	add    $0x1,%eax
ffffffff80103ba3:	89 05 6f b0 00 00    	mov    %eax,0xb06f(%rip)        # ffffffff8010ec18 <log+0x78>
  b->flags |= B_DIRTY; // XXX prevent eviction
ffffffff80103ba9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103bad:	8b 00                	mov    (%rax),%eax
ffffffff80103baf:	83 c8 04             	or     $0x4,%eax
ffffffff80103bb2:	89 c2                	mov    %eax,%edx
ffffffff80103bb4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103bb8:	89 10                	mov    %edx,(%rax)
}
ffffffff80103bba:	90                   	nop
ffffffff80103bbb:	c9                   	leaveq 
ffffffff80103bbc:	c3                   	retq   

ffffffff80103bbd <v2p>:
ffffffff80103bbd:	55                   	push   %rbp
ffffffff80103bbe:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103bc1:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80103bc5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80103bc9:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80103bcd:	b8 00 00 00 80       	mov    $0x80000000,%eax
ffffffff80103bd2:	48 01 d0             	add    %rdx,%rax
ffffffff80103bd5:	c9                   	leaveq 
ffffffff80103bd6:	c3                   	retq   

ffffffff80103bd7 <p2v>:
static inline void *p2v(uintp a) { return (void *) ((a) + ((uintp)KERNBASE)); }
ffffffff80103bd7:	55                   	push   %rbp
ffffffff80103bd8:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103bdb:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80103bdf:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80103be3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103be7:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
ffffffff80103bed:	c9                   	leaveq 
ffffffff80103bee:	c3                   	retq   

ffffffff80103bef <xchg>:
  asm volatile("hlt");
}

static inline uint
xchg(volatile uint *addr, uintp newval)
{
ffffffff80103bef:	55                   	push   %rbp
ffffffff80103bf0:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103bf3:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80103bf7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80103bfb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
ffffffff80103bff:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80103c03:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80103c07:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
ffffffff80103c0b:	f0 87 02             	lock xchg %eax,(%rdx)
ffffffff80103c0e:	89 45 fc             	mov    %eax,-0x4(%rbp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
ffffffff80103c11:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff80103c14:	c9                   	leaveq 
ffffffff80103c15:	c3                   	retq   

ffffffff80103c16 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
ffffffff80103c16:	55                   	push   %rbp
ffffffff80103c17:	48 89 e5             	mov    %rsp,%rbp
  uartearlyinit();
ffffffff80103c1a:	e8 0f 3d 00 00       	callq  ffffffff8010792e <uartearlyinit>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
ffffffff80103c1f:	48 c7 c6 00 00 40 80 	mov    $0xffffffff80400000,%rsi
ffffffff80103c26:	48 c7 c7 00 40 11 80 	mov    $0xffffffff80114000,%rdi
ffffffff80103c2d:	e8 ef f4 ff ff       	callq  ffffffff80103121 <kinit1>
  kvmalloc();      // kernel page table
ffffffff80103c32:	e8 1d 57 00 00       	callq  ffffffff80109354 <kvmalloc>
  if (acpiinit()) // try to use acpi for machine info
ffffffff80103c37:	e8 1c 0a 00 00       	callq  ffffffff80104658 <acpiinit>
ffffffff80103c3c:	85 c0                	test   %eax,%eax
ffffffff80103c3e:	74 05                	je     ffffffff80103c45 <main+0x2f>
    mpinit();      // otherwise use bios MP tables
ffffffff80103c40:	e8 c0 04 00 00       	callq  ffffffff80104105 <mpinit>
  lapicinit();
ffffffff80103c45:	e8 96 f8 ff ff       	callq  ffffffff801034e0 <lapicinit>
  seginit();       // set up segments
ffffffff80103c4a:	e8 f5 53 00 00       	callq  ffffffff80109044 <seginit>
  cprintf("\nBooting xv6\n\n");
ffffffff80103c4f:	48 c7 c7 1d 98 10 80 	mov    $0xffffffff8010981d,%rdi
ffffffff80103c56:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80103c5b:	e8 41 c9 ff ff       	callq  ffffffff801005a1 <cprintf>
  picinit();       // interrupt controller
ffffffff80103c60:	e8 7a 0b 00 00       	callq  ffffffff801047df <picinit>
  ioapicinit();    // another interrupt controller
ffffffff80103c65:	e8 90 f3 ff ff       	callq  ffffffff80102ffa <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
ffffffff80103c6a:	e8 4a d2 ff ff       	callq  ffffffff80100eb9 <consoleinit>
  uartinit();      // serial port
ffffffff80103c6f:	e8 73 3d 00 00       	callq  ffffffff801079e7 <uartinit>
  pinit();         // process table
ffffffff80103c74:	e8 dc 10 00 00       	callq  ffffffff80104d55 <pinit>
  tvinit();        // trap vectors
ffffffff80103c79:	e8 2d 52 00 00       	callq  ffffffff80108eab <tvinit>
  binit();         // buffer cache
ffffffff80103c7e:	e8 a8 c4 ff ff       	callq  ffffffff8010012b <binit>
  fileinit();      // file table
ffffffff80103c83:	e8 98 d7 ff ff       	callq  ffffffff80101420 <fileinit>
  iinit();         // inode cache
ffffffff80103c88:	e8 c1 de ff ff       	callq  ffffffff80101b4e <iinit>
  ideinit();       // disk
ffffffff80103c8d:	e8 b8 ef ff ff       	callq  ffffffff80102c4a <ideinit>
  if(!ismp)
ffffffff80103c92:	8b 05 48 b7 00 00    	mov    0xb748(%rip),%eax        # ffffffff8010f3e0 <ismp>
ffffffff80103c98:	85 c0                	test   %eax,%eax
ffffffff80103c9a:	75 05                	jne    ffffffff80103ca1 <main+0x8b>
    timerinit();   // uniprocessor timer
ffffffff80103c9c:	e8 c2 38 00 00       	callq  ffffffff80107563 <timerinit>
  startothers();   // start other processors
ffffffff80103ca1:	e8 85 00 00 00       	callq  ffffffff80103d2b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
ffffffff80103ca6:	48 c7 c6 00 00 00 8e 	mov    $0xffffffff8e000000,%rsi
ffffffff80103cad:	48 c7 c7 00 00 40 80 	mov    $0xffffffff80400000,%rdi
ffffffff80103cb4:	e8 ab f4 ff ff       	callq  ffffffff80103164 <kinit2>
  userinit();      // first user process
ffffffff80103cb9:	e8 dc 11 00 00       	callq  ffffffff80104e9a <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
ffffffff80103cbe:	e8 18 00 00 00       	callq  ffffffff80103cdb <mpmain>

ffffffff80103cc3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
void
mpenter(void)
{
ffffffff80103cc3:	55                   	push   %rbp
ffffffff80103cc4:	48 89 e5             	mov    %rsp,%rbp
  switchkvm(); 
ffffffff80103cc7:	e8 55 58 00 00       	callq  ffffffff80109521 <switchkvm>
  seginit();
ffffffff80103ccc:	e8 73 53 00 00       	callq  ffffffff80109044 <seginit>
  lapicinit();
ffffffff80103cd1:	e8 0a f8 ff ff       	callq  ffffffff801034e0 <lapicinit>
  mpmain();
ffffffff80103cd6:	e8 00 00 00 00       	callq  ffffffff80103cdb <mpmain>

ffffffff80103cdb <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
ffffffff80103cdb:	55                   	push   %rbp
ffffffff80103cdc:	48 89 e5             	mov    %rsp,%rbp
  cprintf("cpu%d: starting\n", cpu->id);
ffffffff80103cdf:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80103ce6:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80103cea:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103ced:	0f b6 c0             	movzbl %al,%eax
ffffffff80103cf0:	89 c6                	mov    %eax,%esi
ffffffff80103cf2:	48 c7 c7 2c 98 10 80 	mov    $0xffffffff8010982c,%rdi
ffffffff80103cf9:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80103cfe:	e8 9e c8 ff ff       	callq  ffffffff801005a1 <cprintf>
  idtinit();       // load idt register
ffffffff80103d03:	e8 aa 51 00 00       	callq  ffffffff80108eb2 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
ffffffff80103d08:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80103d0f:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80103d13:	48 05 d8 00 00 00    	add    $0xd8,%rax
ffffffff80103d19:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80103d1e:	48 89 c7             	mov    %rax,%rdi
ffffffff80103d21:	e8 c9 fe ff ff       	callq  ffffffff80103bef <xchg>
  scheduler();     // start running processes
ffffffff80103d26:	e8 9c 18 00 00       	callq  ffffffff801055c7 <scheduler>

ffffffff80103d2b <startothers>:
void entry32mp(void);

// Start the non-boot (AP) processors.
static void
startothers(void)
{
ffffffff80103d2b:	55                   	push   %rbp
ffffffff80103d2c:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103d2f:	48 83 ec 20          	sub    $0x20,%rsp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
ffffffff80103d33:	bf 00 70 00 00       	mov    $0x7000,%edi
ffffffff80103d38:	e8 9a fe ff ff       	callq  ffffffff80103bd7 <p2v>
ffffffff80103d3d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  memmove(code, _binary_out_entryother_start, (uintp)_binary_out_entryother_size);
ffffffff80103d41:	48 c7 c0 72 00 00 00 	mov    $0x72,%rax
ffffffff80103d48:	89 c2                	mov    %eax,%edx
ffffffff80103d4a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103d4e:	48 c7 c6 ac ae 10 80 	mov    $0xffffffff8010aeac,%rsi
ffffffff80103d55:	48 89 c7             	mov    %rax,%rdi
ffffffff80103d58:	e8 43 22 00 00       	callq  ffffffff80105fa0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
ffffffff80103d5d:	48 c7 45 f8 60 ec 10 	movq   $0xffffffff8010ec60,-0x8(%rbp)
ffffffff80103d64:	80 
ffffffff80103d65:	e9 a4 00 00 00       	jmpq   ffffffff80103e0e <startothers+0xe3>
    if(c == cpus+cpunum())  // We've started already.
ffffffff80103d6a:	e8 8d f8 ff ff       	callq  ffffffff801035fc <cpunum>
ffffffff80103d6f:	48 63 d0             	movslq %eax,%rdx
ffffffff80103d72:	48 89 d0             	mov    %rdx,%rax
ffffffff80103d75:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80103d79:	48 29 d0             	sub    %rdx,%rax
ffffffff80103d7c:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80103d80:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff80103d86:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff80103d8a:	74 79                	je     ffffffff80103e05 <startothers+0xda>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
ffffffff80103d8c:	e8 fa f4 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80103d91:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
#if X64
    *(uint32*)(code-4) = 0x8000; // just enough stack to get us to entry64mp
ffffffff80103d95:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103d99:	48 83 e8 04          	sub    $0x4,%rax
ffffffff80103d9d:	c7 00 00 80 00 00    	movl   $0x8000,(%rax)
    *(uint32*)(code-8) = v2p(entry32mp);
ffffffff80103da3:	48 c7 c7 74 00 10 80 	mov    $0xffffffff80100074,%rdi
ffffffff80103daa:	e8 0e fe ff ff       	callq  ffffffff80103bbd <v2p>
ffffffff80103daf:	48 89 c2             	mov    %rax,%rdx
ffffffff80103db2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103db6:	48 83 e8 08          	sub    $0x8,%rax
ffffffff80103dba:	89 10                	mov    %edx,(%rax)
    *(uint64*)(code-16) = (uint64) (stack + KSTACKSIZE);
ffffffff80103dbc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103dc0:	48 8d 90 00 10 00 00 	lea    0x1000(%rax),%rdx
ffffffff80103dc7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103dcb:	48 83 e8 10          	sub    $0x10,%rax
ffffffff80103dcf:	48 89 10             	mov    %rdx,(%rax)
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void**)(code-8) = mpenter;
    *(int**)(code-12) = (void *) v2p(entrypgdir);
#endif

    lapicstartap(c->apicid, v2p(code));
ffffffff80103dd2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103dd6:	48 89 c7             	mov    %rax,%rdi
ffffffff80103dd9:	e8 df fd ff ff       	callq  ffffffff80103bbd <v2p>
ffffffff80103dde:	89 c2                	mov    %eax,%edx
ffffffff80103de0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103de4:	0f b6 40 01          	movzbl 0x1(%rax),%eax
ffffffff80103de8:	0f b6 c0             	movzbl %al,%eax
ffffffff80103deb:	89 d6                	mov    %edx,%esi
ffffffff80103ded:	89 c7                	mov    %eax,%edi
ffffffff80103def:	e8 e9 f8 ff ff       	callq  ffffffff801036dd <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
ffffffff80103df4:	90                   	nop
ffffffff80103df5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103df9:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
ffffffff80103dff:	85 c0                	test   %eax,%eax
ffffffff80103e01:	74 f2                	je     ffffffff80103df5 <startothers+0xca>
ffffffff80103e03:	eb 01                	jmp    ffffffff80103e06 <startothers+0xdb>
      continue;
ffffffff80103e05:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
ffffffff80103e06:	48 81 45 f8 f0 00 00 	addq   $0xf0,-0x8(%rbp)
ffffffff80103e0d:	00 
ffffffff80103e0e:	8b 05 d0 b5 00 00    	mov    0xb5d0(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff80103e14:	48 63 d0             	movslq %eax,%rdx
ffffffff80103e17:	48 89 d0             	mov    %rdx,%rax
ffffffff80103e1a:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80103e1e:	48 29 d0             	sub    %rdx,%rax
ffffffff80103e21:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80103e25:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff80103e2b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff80103e2f:	0f 82 35 ff ff ff    	jb     ffffffff80103d6a <startothers+0x3f>
      ;
  }
}
ffffffff80103e35:	90                   	nop
ffffffff80103e36:	c9                   	leaveq 
ffffffff80103e37:	c3                   	retq   

ffffffff80103e38 <p2v>:
ffffffff80103e38:	55                   	push   %rbp
ffffffff80103e39:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103e3c:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80103e40:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80103e44:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103e48:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
ffffffff80103e4e:	c9                   	leaveq 
ffffffff80103e4f:	c3                   	retq   

ffffffff80103e50 <inb>:
{
ffffffff80103e50:	55                   	push   %rbp
ffffffff80103e51:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103e54:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80103e58:	89 f8                	mov    %edi,%eax
ffffffff80103e5a:	66 89 45 ec          	mov    %ax,-0x14(%rbp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
ffffffff80103e5e:	0f b7 45 ec          	movzwl -0x14(%rbp),%eax
ffffffff80103e62:	89 c2                	mov    %eax,%edx
ffffffff80103e64:	ec                   	in     (%dx),%al
ffffffff80103e65:	88 45 ff             	mov    %al,-0x1(%rbp)
  return data;
ffffffff80103e68:	0f b6 45 ff          	movzbl -0x1(%rbp),%eax
}
ffffffff80103e6c:	c9                   	leaveq 
ffffffff80103e6d:	c3                   	retq   

ffffffff80103e6e <outb>:
{
ffffffff80103e6e:	55                   	push   %rbp
ffffffff80103e6f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103e72:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80103e76:	89 fa                	mov    %edi,%edx
ffffffff80103e78:	89 f0                	mov    %esi,%eax
ffffffff80103e7a:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80103e7e:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80103e81:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff80103e85:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff80103e89:	ee                   	out    %al,(%dx)
}
ffffffff80103e8a:	90                   	nop
ffffffff80103e8b:	c9                   	leaveq 
ffffffff80103e8c:	c3                   	retq   

ffffffff80103e8d <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
ffffffff80103e8d:	55                   	push   %rbp
ffffffff80103e8e:	48 89 e5             	mov    %rsp,%rbp
  return bcpu-cpus;
ffffffff80103e91:	48 8b 05 58 b5 00 00 	mov    0xb558(%rip),%rax        # ffffffff8010f3f0 <bcpu>
ffffffff80103e98:	48 89 c2             	mov    %rax,%rdx
ffffffff80103e9b:	48 c7 c0 60 ec 10 80 	mov    $0xffffffff8010ec60,%rax
ffffffff80103ea2:	48 29 c2             	sub    %rax,%rdx
ffffffff80103ea5:	48 89 d0             	mov    %rdx,%rax
ffffffff80103ea8:	48 c1 f8 04          	sar    $0x4,%rax
ffffffff80103eac:	48 89 c2             	mov    %rax,%rdx
ffffffff80103eaf:	48 b8 ef ee ee ee ee 	movabs $0xeeeeeeeeeeeeeeef,%rax
ffffffff80103eb6:	ee ee ee 
ffffffff80103eb9:	48 0f af c2          	imul   %rdx,%rax
}
ffffffff80103ebd:	5d                   	pop    %rbp
ffffffff80103ebe:	c3                   	retq   

ffffffff80103ebf <sum>:

static uchar
sum(uchar *addr, int len)
{
ffffffff80103ebf:	55                   	push   %rbp
ffffffff80103ec0:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103ec3:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80103ec7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80103ecb:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, sum;
  
  sum = 0;
ffffffff80103ece:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  for(i=0; i<len; i++)
ffffffff80103ed5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80103edc:	eb 1a                	jmp    ffffffff80103ef8 <sum+0x39>
    sum += addr[i];
ffffffff80103ede:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103ee1:	48 63 d0             	movslq %eax,%rdx
ffffffff80103ee4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103ee8:	48 01 d0             	add    %rdx,%rax
ffffffff80103eeb:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103eee:	0f b6 c0             	movzbl %al,%eax
ffffffff80103ef1:	01 45 f8             	add    %eax,-0x8(%rbp)
  for(i=0; i<len; i++)
ffffffff80103ef4:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80103ef8:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80103efb:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
ffffffff80103efe:	7c de                	jl     ffffffff80103ede <sum+0x1f>
  return sum;
ffffffff80103f00:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
ffffffff80103f03:	c9                   	leaveq 
ffffffff80103f04:	c3                   	retq   

ffffffff80103f05 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
ffffffff80103f05:	55                   	push   %rbp
ffffffff80103f06:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103f09:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80103f0d:	89 7d dc             	mov    %edi,-0x24(%rbp)
ffffffff80103f10:	89 75 d8             	mov    %esi,-0x28(%rbp)
  uchar *e, *p, *addr;

  addr = p2v(a);
ffffffff80103f13:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80103f16:	48 89 c7             	mov    %rax,%rdi
ffffffff80103f19:	e8 1a ff ff ff       	callq  ffffffff80103e38 <p2v>
ffffffff80103f1e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  e = addr+len;
ffffffff80103f22:	8b 45 d8             	mov    -0x28(%rbp),%eax
ffffffff80103f25:	48 63 d0             	movslq %eax,%rdx
ffffffff80103f28:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103f2c:	48 01 d0             	add    %rdx,%rax
ffffffff80103f2f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  for(p = addr; p < e; p += sizeof(struct mp))
ffffffff80103f33:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80103f37:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80103f3b:	eb 3c                	jmp    ffffffff80103f79 <mpsearch1+0x74>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
ffffffff80103f3d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103f41:	ba 04 00 00 00       	mov    $0x4,%edx
ffffffff80103f46:	48 c7 c6 40 98 10 80 	mov    $0xffffffff80109840,%rsi
ffffffff80103f4d:	48 89 c7             	mov    %rax,%rdi
ffffffff80103f50:	e8 dc 1f 00 00       	callq  ffffffff80105f31 <memcmp>
ffffffff80103f55:	85 c0                	test   %eax,%eax
ffffffff80103f57:	75 1b                	jne    ffffffff80103f74 <mpsearch1+0x6f>
ffffffff80103f59:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103f5d:	be 10 00 00 00       	mov    $0x10,%esi
ffffffff80103f62:	48 89 c7             	mov    %rax,%rdi
ffffffff80103f65:	e8 55 ff ff ff       	callq  ffffffff80103ebf <sum>
ffffffff80103f6a:	84 c0                	test   %al,%al
ffffffff80103f6c:	75 06                	jne    ffffffff80103f74 <mpsearch1+0x6f>
      return (struct mp*)p;
ffffffff80103f6e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103f72:	eb 14                	jmp    ffffffff80103f88 <mpsearch1+0x83>
  for(p = addr; p < e; p += sizeof(struct mp))
ffffffff80103f74:	48 83 45 f8 10       	addq   $0x10,-0x8(%rbp)
ffffffff80103f79:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103f7d:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
ffffffff80103f81:	72 ba                	jb     ffffffff80103f3d <mpsearch1+0x38>
  return 0;
ffffffff80103f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80103f88:	c9                   	leaveq 
ffffffff80103f89:	c3                   	retq   

ffffffff80103f8a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
ffffffff80103f8a:	55                   	push   %rbp
ffffffff80103f8b:	48 89 e5             	mov    %rsp,%rbp
ffffffff80103f8e:	48 83 ec 20          	sub    $0x20,%rsp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
ffffffff80103f92:	48 c7 45 f8 00 04 00 	movq   $0xffffffff80000400,-0x8(%rbp)
ffffffff80103f99:	80 
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
ffffffff80103f9a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103f9e:	48 83 c0 0f          	add    $0xf,%rax
ffffffff80103fa2:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103fa5:	0f b6 c0             	movzbl %al,%eax
ffffffff80103fa8:	c1 e0 08             	shl    $0x8,%eax
ffffffff80103fab:	89 c2                	mov    %eax,%edx
ffffffff80103fad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103fb1:	48 83 c0 0e          	add    $0xe,%rax
ffffffff80103fb5:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103fb8:	0f b6 c0             	movzbl %al,%eax
ffffffff80103fbb:	09 d0                	or     %edx,%eax
ffffffff80103fbd:	c1 e0 04             	shl    $0x4,%eax
ffffffff80103fc0:	89 45 f4             	mov    %eax,-0xc(%rbp)
ffffffff80103fc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
ffffffff80103fc7:	74 20                	je     ffffffff80103fe9 <mpsearch+0x5f>
    if((mp = mpsearch1(p, 1024)))
ffffffff80103fc9:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80103fcc:	be 00 04 00 00       	mov    $0x400,%esi
ffffffff80103fd1:	89 c7                	mov    %eax,%edi
ffffffff80103fd3:	e8 2d ff ff ff       	callq  ffffffff80103f05 <mpsearch1>
ffffffff80103fd8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff80103fdc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff80103fe1:	74 54                	je     ffffffff80104037 <mpsearch+0xad>
      return mp;
ffffffff80103fe3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80103fe7:	eb 5d                	jmp    ffffffff80104046 <mpsearch+0xbc>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
ffffffff80103fe9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80103fed:	48 83 c0 14          	add    $0x14,%rax
ffffffff80103ff1:	0f b6 00             	movzbl (%rax),%eax
ffffffff80103ff4:	0f b6 c0             	movzbl %al,%eax
ffffffff80103ff7:	c1 e0 08             	shl    $0x8,%eax
ffffffff80103ffa:	89 c2                	mov    %eax,%edx
ffffffff80103ffc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104000:	48 83 c0 13          	add    $0x13,%rax
ffffffff80104004:	0f b6 00             	movzbl (%rax),%eax
ffffffff80104007:	0f b6 c0             	movzbl %al,%eax
ffffffff8010400a:	09 d0                	or     %edx,%eax
ffffffff8010400c:	c1 e0 0a             	shl    $0xa,%eax
ffffffff8010400f:	89 45 f4             	mov    %eax,-0xc(%rbp)
    if((mp = mpsearch1(p-1024, 1024)))
ffffffff80104012:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80104015:	2d 00 04 00 00       	sub    $0x400,%eax
ffffffff8010401a:	be 00 04 00 00       	mov    $0x400,%esi
ffffffff8010401f:	89 c7                	mov    %eax,%edi
ffffffff80104021:	e8 df fe ff ff       	callq  ffffffff80103f05 <mpsearch1>
ffffffff80104026:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff8010402a:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff8010402f:	74 06                	je     ffffffff80104037 <mpsearch+0xad>
      return mp;
ffffffff80104031:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104035:	eb 0f                	jmp    ffffffff80104046 <mpsearch+0xbc>
  }
  return mpsearch1(0xF0000, 0x10000);
ffffffff80104037:	be 00 00 01 00       	mov    $0x10000,%esi
ffffffff8010403c:	bf 00 00 0f 00       	mov    $0xf0000,%edi
ffffffff80104041:	e8 bf fe ff ff       	callq  ffffffff80103f05 <mpsearch1>
}
ffffffff80104046:	c9                   	leaveq 
ffffffff80104047:	c3                   	retq   

ffffffff80104048 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
ffffffff80104048:	55                   	push   %rbp
ffffffff80104049:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010404c:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80104050:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
ffffffff80104054:	e8 31 ff ff ff       	callq  ffffffff80103f8a <mpsearch>
ffffffff80104059:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff8010405d:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80104062:	74 0b                	je     ffffffff8010406f <mpconfig+0x27>
ffffffff80104064:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104068:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010406b:	85 c0                	test   %eax,%eax
ffffffff8010406d:	75 0a                	jne    ffffffff80104079 <mpconfig+0x31>
    return 0;
ffffffff8010406f:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80104074:	e9 8a 00 00 00       	jmpq   ffffffff80104103 <mpconfig+0xbb>
  conf = (struct mpconf*) p2v((uintp) mp->physaddr);
ffffffff80104079:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010407d:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80104080:	89 c0                	mov    %eax,%eax
ffffffff80104082:	48 89 c7             	mov    %rax,%rdi
ffffffff80104085:	e8 ae fd ff ff       	callq  ffffffff80103e38 <p2v>
ffffffff8010408a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  if(memcmp(conf, "PCMP", 4) != 0)
ffffffff8010408e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104092:	ba 04 00 00 00       	mov    $0x4,%edx
ffffffff80104097:	48 c7 c6 45 98 10 80 	mov    $0xffffffff80109845,%rsi
ffffffff8010409e:	48 89 c7             	mov    %rax,%rdi
ffffffff801040a1:	e8 8b 1e 00 00       	callq  ffffffff80105f31 <memcmp>
ffffffff801040a6:	85 c0                	test   %eax,%eax
ffffffff801040a8:	74 07                	je     ffffffff801040b1 <mpconfig+0x69>
    return 0;
ffffffff801040aa:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801040af:	eb 52                	jmp    ffffffff80104103 <mpconfig+0xbb>
  if(conf->version != 1 && conf->version != 4)
ffffffff801040b1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801040b5:	0f b6 40 06          	movzbl 0x6(%rax),%eax
ffffffff801040b9:	3c 01                	cmp    $0x1,%al
ffffffff801040bb:	74 13                	je     ffffffff801040d0 <mpconfig+0x88>
ffffffff801040bd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801040c1:	0f b6 40 06          	movzbl 0x6(%rax),%eax
ffffffff801040c5:	3c 04                	cmp    $0x4,%al
ffffffff801040c7:	74 07                	je     ffffffff801040d0 <mpconfig+0x88>
    return 0;
ffffffff801040c9:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801040ce:	eb 33                	jmp    ffffffff80104103 <mpconfig+0xbb>
  if(sum((uchar*)conf, conf->length) != 0)
ffffffff801040d0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801040d4:	0f b7 40 04          	movzwl 0x4(%rax),%eax
ffffffff801040d8:	0f b7 d0             	movzwl %ax,%edx
ffffffff801040db:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801040df:	89 d6                	mov    %edx,%esi
ffffffff801040e1:	48 89 c7             	mov    %rax,%rdi
ffffffff801040e4:	e8 d6 fd ff ff       	callq  ffffffff80103ebf <sum>
ffffffff801040e9:	84 c0                	test   %al,%al
ffffffff801040eb:	74 07                	je     ffffffff801040f4 <mpconfig+0xac>
    return 0;
ffffffff801040ed:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801040f2:	eb 0f                	jmp    ffffffff80104103 <mpconfig+0xbb>
  *pmp = mp;
ffffffff801040f4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801040f8:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff801040fc:	48 89 10             	mov    %rdx,(%rax)
  return conf;
ffffffff801040ff:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
ffffffff80104103:	c9                   	leaveq 
ffffffff80104104:	c3                   	retq   

ffffffff80104105 <mpinit>:

void
mpinit(void)
{
ffffffff80104105:	55                   	push   %rbp
ffffffff80104106:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104109:	48 83 ec 30          	sub    $0x30,%rsp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
ffffffff8010410d:	48 c7 05 d8 b2 00 00 	movq   $0xffffffff8010ec60,0xb2d8(%rip)        # ffffffff8010f3f0 <bcpu>
ffffffff80104114:	60 ec 10 80 
  if((conf = mpconfig(&mp)) == 0)
ffffffff80104118:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
ffffffff8010411c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010411f:	e8 24 ff ff ff       	callq  ffffffff80104048 <mpconfig>
ffffffff80104124:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80104128:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff8010412d:	0f 84 ed 01 00 00    	je     ffffffff80104320 <mpinit+0x21b>
    return;
  ismp = 1;
ffffffff80104133:	c7 05 a3 b2 00 00 01 	movl   $0x1,0xb2a3(%rip)        # ffffffff8010f3e0 <ismp>
ffffffff8010413a:	00 00 00 
  lapic = IO2V((uintp)conf->lapicaddr);
ffffffff8010413d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104141:	8b 40 24             	mov    0x24(%rax),%eax
ffffffff80104144:	89 c2                	mov    %eax,%edx
ffffffff80104146:	48 b8 00 00 00 42 fe 	movabs $0xfffffffe42000000,%rax
ffffffff8010414d:	ff ff ff 
ffffffff80104150:	48 01 d0             	add    %rdx,%rax
ffffffff80104153:	48 89 05 26 aa 00 00 	mov    %rax,0xaa26(%rip)        # ffffffff8010eb80 <lapic>
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
ffffffff8010415a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010415e:	48 83 c0 2c          	add    $0x2c,%rax
ffffffff80104162:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80104166:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010416a:	0f b7 40 04          	movzwl 0x4(%rax),%eax
ffffffff8010416e:	0f b7 d0             	movzwl %ax,%edx
ffffffff80104171:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104175:	48 01 d0             	add    %rdx,%rax
ffffffff80104178:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff8010417c:	e9 30 01 00 00       	jmpq   ffffffff801042b1 <mpinit+0x1ac>
    switch(*p){
ffffffff80104181:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104185:	0f b6 00             	movzbl (%rax),%eax
ffffffff80104188:	0f b6 c0             	movzbl %al,%eax
ffffffff8010418b:	83 f8 04             	cmp    $0x4,%eax
ffffffff8010418e:	0f 87 f6 00 00 00    	ja     ffffffff8010428a <mpinit+0x185>
ffffffff80104194:	89 c0                	mov    %eax,%eax
ffffffff80104196:	48 8b 04 c5 88 98 10 	mov    -0x7fef6778(,%rax,8),%rax
ffffffff8010419d:	80 
ffffffff8010419e:	ff e0                	jmpq   *%rax
    case MPPROC:
      proc = (struct mpproc*)p;
ffffffff801041a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801041a4:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
      cprintf("mpinit ncpu=%d apicid=%d\n", ncpu, proc->apicid);
ffffffff801041a8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801041ac:	0f b6 40 01          	movzbl 0x1(%rax),%eax
ffffffff801041b0:	0f b6 d0             	movzbl %al,%edx
ffffffff801041b3:	8b 05 2b b2 00 00    	mov    0xb22b(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff801041b9:	89 c6                	mov    %eax,%esi
ffffffff801041bb:	48 c7 c7 4a 98 10 80 	mov    $0xffffffff8010984a,%rdi
ffffffff801041c2:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801041c7:	e8 d5 c3 ff ff       	callq  ffffffff801005a1 <cprintf>
      if(proc->flags & MPBOOT)
ffffffff801041cc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801041d0:	0f b6 40 03          	movzbl 0x3(%rax),%eax
ffffffff801041d4:	0f b6 c0             	movzbl %al,%eax
ffffffff801041d7:	83 e0 02             	and    $0x2,%eax
ffffffff801041da:	85 c0                	test   %eax,%eax
ffffffff801041dc:	74 24                	je     ffffffff80104202 <mpinit+0xfd>
        bcpu = &cpus[ncpu];
ffffffff801041de:	8b 05 00 b2 00 00    	mov    0xb200(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff801041e4:	48 63 d0             	movslq %eax,%rdx
ffffffff801041e7:	48 89 d0             	mov    %rdx,%rax
ffffffff801041ea:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff801041ee:	48 29 d0             	sub    %rdx,%rax
ffffffff801041f1:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff801041f5:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff801041fb:	48 89 05 ee b1 00 00 	mov    %rax,0xb1ee(%rip)        # ffffffff8010f3f0 <bcpu>
      cpus[ncpu].id = ncpu;
ffffffff80104202:	8b 15 dc b1 00 00    	mov    0xb1dc(%rip),%edx        # ffffffff8010f3e4 <ncpu>
ffffffff80104208:	8b 05 d6 b1 00 00    	mov    0xb1d6(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff8010420e:	89 d1                	mov    %edx,%ecx
ffffffff80104210:	48 63 d0             	movslq %eax,%rdx
ffffffff80104213:	48 89 d0             	mov    %rdx,%rax
ffffffff80104216:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff8010421a:	48 29 d0             	sub    %rdx,%rax
ffffffff8010421d:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104221:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff80104227:	88 08                	mov    %cl,(%rax)
      cpus[ncpu].apicid = proc->apicid;
ffffffff80104229:	8b 15 b5 b1 00 00    	mov    0xb1b5(%rip),%edx        # ffffffff8010f3e4 <ncpu>
ffffffff8010422f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80104233:	0f b6 48 01          	movzbl 0x1(%rax),%ecx
ffffffff80104237:	48 63 d2             	movslq %edx,%rdx
ffffffff8010423a:	48 89 d0             	mov    %rdx,%rax
ffffffff8010423d:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104241:	48 29 d0             	sub    %rdx,%rax
ffffffff80104244:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104248:	48 05 61 ec 10 80    	add    $0xffffffff8010ec61,%rax
ffffffff8010424e:	88 08                	mov    %cl,(%rax)
      ncpu++;
ffffffff80104250:	8b 05 8e b1 00 00    	mov    0xb18e(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff80104256:	83 c0 01             	add    $0x1,%eax
ffffffff80104259:	89 05 85 b1 00 00    	mov    %eax,0xb185(%rip)        # ffffffff8010f3e4 <ncpu>
      p += sizeof(struct mpproc);
ffffffff8010425f:	48 83 45 f8 14       	addq   $0x14,-0x8(%rbp)
      continue;
ffffffff80104264:	eb 4b                	jmp    ffffffff801042b1 <mpinit+0x1ac>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
ffffffff80104266:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010426a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
      ioapicid = ioapic->apicno;
ffffffff8010426e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104272:	0f b6 40 01          	movzbl 0x1(%rax),%eax
ffffffff80104276:	88 05 6c b1 00 00    	mov    %al,0xb16c(%rip)        # ffffffff8010f3e8 <ioapicid>
      p += sizeof(struct mpioapic);
ffffffff8010427c:	48 83 45 f8 08       	addq   $0x8,-0x8(%rbp)
      continue;
ffffffff80104281:	eb 2e                	jmp    ffffffff801042b1 <mpinit+0x1ac>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
ffffffff80104283:	48 83 45 f8 08       	addq   $0x8,-0x8(%rbp)
      continue;
ffffffff80104288:	eb 27                	jmp    ffffffff801042b1 <mpinit+0x1ac>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
ffffffff8010428a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010428e:	0f b6 00             	movzbl (%rax),%eax
ffffffff80104291:	0f b6 c0             	movzbl %al,%eax
ffffffff80104294:	89 c6                	mov    %eax,%esi
ffffffff80104296:	48 c7 c7 68 98 10 80 	mov    $0xffffffff80109868,%rdi
ffffffff8010429d:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801042a2:	e8 fa c2 ff ff       	callq  ffffffff801005a1 <cprintf>
      ismp = 0;
ffffffff801042a7:	c7 05 2f b1 00 00 00 	movl   $0x0,0xb12f(%rip)        # ffffffff8010f3e0 <ismp>
ffffffff801042ae:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
ffffffff801042b1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801042b5:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
ffffffff801042b9:	0f 82 c2 fe ff ff    	jb     ffffffff80104181 <mpinit+0x7c>
    }
  }
  if(!ismp){
ffffffff801042bf:	8b 05 1b b1 00 00    	mov    0xb11b(%rip),%eax        # ffffffff8010f3e0 <ismp>
ffffffff801042c5:	85 c0                	test   %eax,%eax
ffffffff801042c7:	75 1e                	jne    ffffffff801042e7 <mpinit+0x1e2>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
ffffffff801042c9:	c7 05 11 b1 00 00 01 	movl   $0x1,0xb111(%rip)        # ffffffff8010f3e4 <ncpu>
ffffffff801042d0:	00 00 00 
    lapic = 0;
ffffffff801042d3:	48 c7 05 a2 a8 00 00 	movq   $0x0,0xa8a2(%rip)        # ffffffff8010eb80 <lapic>
ffffffff801042da:	00 00 00 00 
    ioapicid = 0;
ffffffff801042de:	c6 05 03 b1 00 00 00 	movb   $0x0,0xb103(%rip)        # ffffffff8010f3e8 <ioapicid>
    return;
ffffffff801042e5:	eb 3a                	jmp    ffffffff80104321 <mpinit+0x21c>
  }

  if(mp->imcrp){
ffffffff801042e7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801042eb:	0f b6 40 0c          	movzbl 0xc(%rax),%eax
ffffffff801042ef:	84 c0                	test   %al,%al
ffffffff801042f1:	74 2e                	je     ffffffff80104321 <mpinit+0x21c>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
ffffffff801042f3:	be 70 00 00 00       	mov    $0x70,%esi
ffffffff801042f8:	bf 22 00 00 00       	mov    $0x22,%edi
ffffffff801042fd:	e8 6c fb ff ff       	callq  ffffffff80103e6e <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
ffffffff80104302:	bf 23 00 00 00       	mov    $0x23,%edi
ffffffff80104307:	e8 44 fb ff ff       	callq  ffffffff80103e50 <inb>
ffffffff8010430c:	83 c8 01             	or     $0x1,%eax
ffffffff8010430f:	0f b6 c0             	movzbl %al,%eax
ffffffff80104312:	89 c6                	mov    %eax,%esi
ffffffff80104314:	bf 23 00 00 00       	mov    $0x23,%edi
ffffffff80104319:	e8 50 fb ff ff       	callq  ffffffff80103e6e <outb>
ffffffff8010431e:	eb 01                	jmp    ffffffff80104321 <mpinit+0x21c>
    return;
ffffffff80104320:	90                   	nop
  }
}
ffffffff80104321:	c9                   	leaveq 
ffffffff80104322:	c3                   	retq   

ffffffff80104323 <p2v>:
ffffffff80104323:	55                   	push   %rbp
ffffffff80104324:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104327:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010432b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010432f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104333:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
ffffffff80104339:	c9                   	leaveq 
ffffffff8010433a:	c3                   	retq   

ffffffff8010433b <scan_rdsp>:
extern struct cpu cpus[NCPU];
extern int ismp;
extern int ncpu;
extern uchar ioapicid;

static struct acpi_rdsp *scan_rdsp(uint base, uint len) {
ffffffff8010433b:	55                   	push   %rbp
ffffffff8010433c:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010433f:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80104343:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff80104346:	89 75 e8             	mov    %esi,-0x18(%rbp)
  uchar *p;
  for (p = p2v(base); len >= sizeof(struct acpi_rdsp); len -= 4, p += 4) {
ffffffff80104349:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff8010434c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010434f:	e8 cf ff ff ff       	callq  ffffffff80104323 <p2v>
ffffffff80104354:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80104358:	eb 62                	jmp    ffffffff801043bc <scan_rdsp+0x81>
    if (memcmp(p, SIG_RDSP, 8) == 0) {
ffffffff8010435a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010435e:	ba 08 00 00 00       	mov    $0x8,%edx
ffffffff80104363:	48 c7 c6 b0 98 10 80 	mov    $0xffffffff801098b0,%rsi
ffffffff8010436a:	48 89 c7             	mov    %rax,%rdi
ffffffff8010436d:	e8 bf 1b 00 00       	callq  ffffffff80105f31 <memcmp>
ffffffff80104372:	85 c0                	test   %eax,%eax
ffffffff80104374:	75 3d                	jne    ffffffff801043b3 <scan_rdsp+0x78>
      uint sum, n;
      for (sum = 0, n = 0; n < 20; n++)
ffffffff80104376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
ffffffff8010437d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
ffffffff80104384:	eb 17                	jmp    ffffffff8010439d <scan_rdsp+0x62>
        sum += p[n];
ffffffff80104386:	8b 55 f0             	mov    -0x10(%rbp),%edx
ffffffff80104389:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010438d:	48 01 d0             	add    %rdx,%rax
ffffffff80104390:	0f b6 00             	movzbl (%rax),%eax
ffffffff80104393:	0f b6 c0             	movzbl %al,%eax
ffffffff80104396:	01 45 f4             	add    %eax,-0xc(%rbp)
      for (sum = 0, n = 0; n < 20; n++)
ffffffff80104399:	83 45 f0 01          	addl   $0x1,-0x10(%rbp)
ffffffff8010439d:	83 7d f0 13          	cmpl   $0x13,-0x10(%rbp)
ffffffff801043a1:	76 e3                	jbe    ffffffff80104386 <scan_rdsp+0x4b>
      if ((sum & 0xff) == 0)
ffffffff801043a3:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff801043a6:	0f b6 c0             	movzbl %al,%eax
ffffffff801043a9:	85 c0                	test   %eax,%eax
ffffffff801043ab:	75 06                	jne    ffffffff801043b3 <scan_rdsp+0x78>
        return (struct acpi_rdsp *) p;
ffffffff801043ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801043b1:	eb 14                	jmp    ffffffff801043c7 <scan_rdsp+0x8c>
  for (p = p2v(base); len >= sizeof(struct acpi_rdsp); len -= 4, p += 4) {
ffffffff801043b3:	83 6d e8 04          	subl   $0x4,-0x18(%rbp)
ffffffff801043b7:	48 83 45 f8 04       	addq   $0x4,-0x8(%rbp)
ffffffff801043bc:	83 7d e8 23          	cmpl   $0x23,-0x18(%rbp)
ffffffff801043c0:	77 98                	ja     ffffffff8010435a <scan_rdsp+0x1f>
    }
  }
  return (struct acpi_rdsp *) 0;  
ffffffff801043c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801043c7:	c9                   	leaveq 
ffffffff801043c8:	c3                   	retq   

ffffffff801043c9 <find_rdsp>:

static struct acpi_rdsp *find_rdsp(void) {
ffffffff801043c9:	55                   	push   %rbp
ffffffff801043ca:	48 89 e5             	mov    %rsp,%rbp
ffffffff801043cd:	48 83 ec 10          	sub    $0x10,%rsp
  struct acpi_rdsp *rdsp;
  uintp pa;
  pa = *((ushort*) P2V(0x40E)) << 4; // EBDA
ffffffff801043d1:	48 c7 c0 0e 04 00 80 	mov    $0xffffffff8000040e,%rax
ffffffff801043d8:	0f b7 00             	movzwl (%rax),%eax
ffffffff801043db:	0f b7 c0             	movzwl %ax,%eax
ffffffff801043de:	c1 e0 04             	shl    $0x4,%eax
ffffffff801043e1:	48 98                	cltq   
ffffffff801043e3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if (pa && (rdsp = scan_rdsp(pa, 1024)))
ffffffff801043e7:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff801043ec:	74 21                	je     ffffffff8010440f <find_rdsp+0x46>
ffffffff801043ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801043f2:	be 00 04 00 00       	mov    $0x400,%esi
ffffffff801043f7:	89 c7                	mov    %eax,%edi
ffffffff801043f9:	e8 3d ff ff ff       	callq  ffffffff8010433b <scan_rdsp>
ffffffff801043fe:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80104402:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80104407:	74 06                	je     ffffffff8010440f <find_rdsp+0x46>
    return rdsp;
ffffffff80104409:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010440d:	eb 0f                	jmp    ffffffff8010441e <find_rdsp+0x55>
  return scan_rdsp(0xE0000, 0x20000);
ffffffff8010440f:	be 00 00 02 00       	mov    $0x20000,%esi
ffffffff80104414:	bf 00 00 0e 00       	mov    $0xe0000,%edi
ffffffff80104419:	e8 1d ff ff ff       	callq  ffffffff8010433b <scan_rdsp>
} 
ffffffff8010441e:	c9                   	leaveq 
ffffffff8010441f:	c3                   	retq   

ffffffff80104420 <acpi_config_smp>:

static int acpi_config_smp(struct acpi_madt *madt) {
ffffffff80104420:	55                   	push   %rbp
ffffffff80104421:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104424:	48 83 ec 50          	sub    $0x50,%rsp
ffffffff80104428:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  uint32 lapic_addr;
  uint nioapic = 0;
ffffffff8010442c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  uchar *p, *e;

  if (!madt)
ffffffff80104433:	48 83 7d b8 00       	cmpq   $0x0,-0x48(%rbp)
ffffffff80104438:	75 0a                	jne    ffffffff80104444 <acpi_config_smp+0x24>
    return -1;
ffffffff8010443a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010443f:	e9 12 02 00 00       	jmpq   ffffffff80104656 <acpi_config_smp+0x236>
  if (madt->header.length < sizeof(struct acpi_madt))
ffffffff80104444:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff80104448:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010444b:	83 f8 2b             	cmp    $0x2b,%eax
ffffffff8010444e:	77 0a                	ja     ffffffff8010445a <acpi_config_smp+0x3a>
    return -1;
ffffffff80104450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80104455:	e9 fc 01 00 00       	jmpq   ffffffff80104656 <acpi_config_smp+0x236>

  lapic_addr = madt->lapic_addr_phys;
ffffffff8010445a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff8010445e:	8b 40 24             	mov    0x24(%rax),%eax
ffffffff80104461:	89 45 ec             	mov    %eax,-0x14(%rbp)

  p = madt->table;
ffffffff80104464:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff80104468:	48 83 c0 2c          	add    $0x2c,%rax
ffffffff8010446c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  e = p + madt->header.length - sizeof(struct acpi_madt);
ffffffff80104470:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff80104474:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80104477:	89 c0                	mov    %eax,%eax
ffffffff80104479:	48 8d 50 d4          	lea    -0x2c(%rax),%rdx
ffffffff8010447d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104481:	48 01 d0             	add    %rdx,%rax
ffffffff80104484:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

  while (p < e) {
ffffffff80104488:	e9 7e 01 00 00       	jmpq   ffffffff8010460b <acpi_config_smp+0x1eb>
    uint len;
    if ((e - p) < 2)
ffffffff8010448d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff80104491:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104495:	48 29 c2             	sub    %rax,%rdx
ffffffff80104498:	48 89 d0             	mov    %rdx,%rax
ffffffff8010449b:	48 83 f8 01          	cmp    $0x1,%rax
ffffffff8010449f:	0f 8e 76 01 00 00    	jle    ffffffff8010461b <acpi_config_smp+0x1fb>
      break;
    len = p[1];
ffffffff801044a5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801044a9:	48 83 c0 01          	add    $0x1,%rax
ffffffff801044ad:	0f b6 00             	movzbl (%rax),%eax
ffffffff801044b0:	0f b6 c0             	movzbl %al,%eax
ffffffff801044b3:	89 45 dc             	mov    %eax,-0x24(%rbp)
    if ((e - p) < len)
ffffffff801044b6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff801044ba:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801044be:	48 29 c2             	sub    %rax,%rdx
ffffffff801044c1:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff801044c4:	48 39 c2             	cmp    %rax,%rdx
ffffffff801044c7:	0f 8c 51 01 00 00    	jl     ffffffff8010461e <acpi_config_smp+0x1fe>
      break;
    switch (p[0]) {
ffffffff801044cd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801044d1:	0f b6 00             	movzbl (%rax),%eax
ffffffff801044d4:	0f b6 c0             	movzbl %al,%eax
ffffffff801044d7:	85 c0                	test   %eax,%eax
ffffffff801044d9:	74 0e                	je     ffffffff801044e9 <acpi_config_smp+0xc9>
ffffffff801044db:	83 f8 01             	cmp    $0x1,%eax
ffffffff801044de:	0f 84 ac 00 00 00    	je     ffffffff80104590 <acpi_config_smp+0x170>
ffffffff801044e4:	e9 1b 01 00 00       	jmpq   ffffffff80104604 <acpi_config_smp+0x1e4>
    case TYPE_LAPIC: {
      struct madt_lapic *lapic = (void*) p;
ffffffff801044e9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801044ed:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      if (len < sizeof(*lapic))
ffffffff801044f1:	83 7d dc 07          	cmpl   $0x7,-0x24(%rbp)
ffffffff801044f5:	0f 86 02 01 00 00    	jbe    ffffffff801045fd <acpi_config_smp+0x1dd>
        break;
      if (!(lapic->flags & APIC_LAPIC_ENABLED))
ffffffff801044fb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff801044ff:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff80104502:	83 e0 01             	and    $0x1,%eax
ffffffff80104505:	85 c0                	test   %eax,%eax
ffffffff80104507:	0f 84 f3 00 00 00    	je     ffffffff80104600 <acpi_config_smp+0x1e0>
        break;
      cprintf("acpi: cpu#%d apicid %d\n", ncpu, lapic->apic_id);
ffffffff8010450d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80104511:	0f b6 40 03          	movzbl 0x3(%rax),%eax
ffffffff80104515:	0f b6 d0             	movzbl %al,%edx
ffffffff80104518:	8b 05 c6 ae 00 00    	mov    0xaec6(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff8010451e:	89 c6                	mov    %eax,%esi
ffffffff80104520:	48 c7 c7 b9 98 10 80 	mov    $0xffffffff801098b9,%rdi
ffffffff80104527:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010452c:	e8 70 c0 ff ff       	callq  ffffffff801005a1 <cprintf>
      cpus[ncpu].id = ncpu;
ffffffff80104531:	8b 15 ad ae 00 00    	mov    0xaead(%rip),%edx        # ffffffff8010f3e4 <ncpu>
ffffffff80104537:	8b 05 a7 ae 00 00    	mov    0xaea7(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff8010453d:	89 d1                	mov    %edx,%ecx
ffffffff8010453f:	48 63 d0             	movslq %eax,%rdx
ffffffff80104542:	48 89 d0             	mov    %rdx,%rax
ffffffff80104545:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104549:	48 29 d0             	sub    %rdx,%rax
ffffffff8010454c:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104550:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff80104556:	88 08                	mov    %cl,(%rax)
      cpus[ncpu].apicid = lapic->apic_id;
ffffffff80104558:	8b 15 86 ae 00 00    	mov    0xae86(%rip),%edx        # ffffffff8010f3e4 <ncpu>
ffffffff8010455e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80104562:	0f b6 48 03          	movzbl 0x3(%rax),%ecx
ffffffff80104566:	48 63 d2             	movslq %edx,%rdx
ffffffff80104569:	48 89 d0             	mov    %rdx,%rax
ffffffff8010456c:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104570:	48 29 d0             	sub    %rdx,%rax
ffffffff80104573:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80104577:	48 05 61 ec 10 80    	add    $0xffffffff8010ec61,%rax
ffffffff8010457d:	88 08                	mov    %cl,(%rax)
      ncpu++;
ffffffff8010457f:	8b 05 5f ae 00 00    	mov    0xae5f(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff80104585:	83 c0 01             	add    $0x1,%eax
ffffffff80104588:	89 05 56 ae 00 00    	mov    %eax,0xae56(%rip)        # ffffffff8010f3e4 <ncpu>
      break;
ffffffff8010458e:	eb 74                	jmp    ffffffff80104604 <acpi_config_smp+0x1e4>
    }
    case TYPE_IOAPIC: {
      struct madt_ioapic *ioapic = (void*) p;
ffffffff80104590:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104594:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
      if (len < sizeof(*ioapic))
ffffffff80104598:	83 7d dc 0b          	cmpl   $0xb,-0x24(%rbp)
ffffffff8010459c:	76 65                	jbe    ffffffff80104603 <acpi_config_smp+0x1e3>
        break;
      cprintf("acpi: ioapic#%d @%x id=%d base=%d\n",
ffffffff8010459e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801045a2:	8b 70 08             	mov    0x8(%rax),%esi
        nioapic, ioapic->addr, ioapic->id, ioapic->interrupt_base);
ffffffff801045a5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801045a9:	0f b6 40 02          	movzbl 0x2(%rax),%eax
      cprintf("acpi: ioapic#%d @%x id=%d base=%d\n",
ffffffff801045ad:	0f b6 c8             	movzbl %al,%ecx
ffffffff801045b0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801045b4:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff801045b7:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801045ba:	41 89 f0             	mov    %esi,%r8d
ffffffff801045bd:	89 c6                	mov    %eax,%esi
ffffffff801045bf:	48 c7 c7 d8 98 10 80 	mov    $0xffffffff801098d8,%rdi
ffffffff801045c6:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801045cb:	e8 d1 bf ff ff       	callq  ffffffff801005a1 <cprintf>
      if (nioapic) {
ffffffff801045d0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff801045d4:	74 13                	je     ffffffff801045e9 <acpi_config_smp+0x1c9>
        cprintf("warning: multiple ioapics are not supported");
ffffffff801045d6:	48 c7 c7 00 99 10 80 	mov    $0xffffffff80109900,%rdi
ffffffff801045dd:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801045e2:	e8 ba bf ff ff       	callq  ffffffff801005a1 <cprintf>
ffffffff801045e7:	eb 0e                	jmp    ffffffff801045f7 <acpi_config_smp+0x1d7>
      } else {
        ioapicid = ioapic->id;
ffffffff801045e9:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801045ed:	0f b6 40 02          	movzbl 0x2(%rax),%eax
ffffffff801045f1:	88 05 f1 ad 00 00    	mov    %al,0xadf1(%rip)        # ffffffff8010f3e8 <ioapicid>
      }
      nioapic++;
ffffffff801045f7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
      break;
ffffffff801045fb:	eb 07                	jmp    ffffffff80104604 <acpi_config_smp+0x1e4>
        break;
ffffffff801045fd:	90                   	nop
ffffffff801045fe:	eb 04                	jmp    ffffffff80104604 <acpi_config_smp+0x1e4>
        break;
ffffffff80104600:	90                   	nop
ffffffff80104601:	eb 01                	jmp    ffffffff80104604 <acpi_config_smp+0x1e4>
        break;
ffffffff80104603:	90                   	nop
    }
    }
    p += len;
ffffffff80104604:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80104607:	48 01 45 f0          	add    %rax,-0x10(%rbp)
  while (p < e) {
ffffffff8010460b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010460f:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
ffffffff80104613:	0f 82 74 fe ff ff    	jb     ffffffff8010448d <acpi_config_smp+0x6d>
ffffffff80104619:	eb 04                	jmp    ffffffff8010461f <acpi_config_smp+0x1ff>
      break;
ffffffff8010461b:	90                   	nop
ffffffff8010461c:	eb 01                	jmp    ffffffff8010461f <acpi_config_smp+0x1ff>
      break;
ffffffff8010461e:	90                   	nop
  }

  if (ncpu) {
ffffffff8010461f:	8b 05 bf ad 00 00    	mov    0xadbf(%rip),%eax        # ffffffff8010f3e4 <ncpu>
ffffffff80104625:	85 c0                	test   %eax,%eax
ffffffff80104627:	74 28                	je     ffffffff80104651 <acpi_config_smp+0x231>
    ismp = 1;
ffffffff80104629:	c7 05 ad ad 00 00 01 	movl   $0x1,0xadad(%rip)        # ffffffff8010f3e0 <ismp>
ffffffff80104630:	00 00 00 
    lapic = IO2V(((uintp)lapic_addr));
ffffffff80104633:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80104636:	48 b8 00 00 00 42 fe 	movabs $0xfffffffe42000000,%rax
ffffffff8010463d:	ff ff ff 
ffffffff80104640:	48 01 d0             	add    %rdx,%rax
ffffffff80104643:	48 89 05 36 a5 00 00 	mov    %rax,0xa536(%rip)        # ffffffff8010eb80 <lapic>
    return 0;
ffffffff8010464a:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010464f:	eb 05                	jmp    ffffffff80104656 <acpi_config_smp+0x236>
  }

  return -1;
ffffffff80104651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80104656:	c9                   	leaveq 
ffffffff80104657:	c3                   	retq   

ffffffff80104658 <acpiinit>:
#define PHYSLIMIT 0x80000000
#else
#define PHYSLIMIT 0x0E000000
#endif

int acpiinit(void) {
ffffffff80104658:	55                   	push   %rbp
ffffffff80104659:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010465c:	48 83 ec 30          	sub    $0x30,%rsp
  unsigned n, count;
  struct acpi_rdsp *rdsp;
  struct acpi_rsdt *rsdt;
  struct acpi_madt *madt = 0;
ffffffff80104660:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
ffffffff80104667:	00 

  rdsp = find_rdsp();
ffffffff80104668:	e8 5c fd ff ff       	callq  ffffffff801043c9 <find_rdsp>
ffffffff8010466d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  if (rdsp->rsdt_addr_phys > PHYSLIMIT)
ffffffff80104671:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104675:	8b 40 10             	mov    0x10(%rax),%eax
ffffffff80104678:	3d 00 00 00 80       	cmp    $0x80000000,%eax
ffffffff8010467d:	0f 87 a3 00 00 00    	ja     ffffffff80104726 <acpiinit+0xce>
    goto notmapped;
  rsdt = p2v(rdsp->rsdt_addr_phys);
ffffffff80104683:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104687:	8b 40 10             	mov    0x10(%rax),%eax
ffffffff8010468a:	89 c0                	mov    %eax,%eax
ffffffff8010468c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010468f:	e8 8f fc ff ff       	callq  ffffffff80104323 <p2v>
ffffffff80104694:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  count = (rsdt->header.length - sizeof(*rsdt)) / 4;
ffffffff80104698:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010469c:	8b 40 04             	mov    0x4(%rax),%eax
ffffffff8010469f:	89 c0                	mov    %eax,%eax
ffffffff801046a1:	48 83 e8 24          	sub    $0x24,%rax
ffffffff801046a5:	48 c1 e8 02          	shr    $0x2,%rax
ffffffff801046a9:	89 45 dc             	mov    %eax,-0x24(%rbp)
  for (n = 0; n < count; n++) {
ffffffff801046ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff801046b3:	eb 5b                	jmp    ffffffff80104710 <acpiinit+0xb8>
    struct acpi_desc_header *hdr = p2v(rsdt->entry[n]);
ffffffff801046b5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801046b9:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801046bc:	48 83 c2 08          	add    $0x8,%rdx
ffffffff801046c0:	8b 44 90 04          	mov    0x4(%rax,%rdx,4),%eax
ffffffff801046c4:	89 c0                	mov    %eax,%eax
ffffffff801046c6:	48 89 c7             	mov    %rax,%rdi
ffffffff801046c9:	e8 55 fc ff ff       	callq  ffffffff80104323 <p2v>
ffffffff801046ce:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    if (rsdt->entry[n] > PHYSLIMIT)
ffffffff801046d2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801046d6:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801046d9:	48 83 c2 08          	add    $0x8,%rdx
ffffffff801046dd:	8b 44 90 04          	mov    0x4(%rax,%rdx,4),%eax
ffffffff801046e1:	3d 00 00 00 80       	cmp    $0x80000000,%eax
ffffffff801046e6:	77 41                	ja     ffffffff80104729 <acpiinit+0xd1>
    memmove(creator, hdr->creator_id, 4); creator[4] = 0;
    cprintf("acpi: %s %s %s %x %s %x\n",
      sig, id, tableid, hdr->oem_revision,
      creator, hdr->creator_revision);
#endif
    if (!memcmp(hdr->signature, SIG_MADT, 4))
ffffffff801046e8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801046ec:	ba 04 00 00 00       	mov    $0x4,%edx
ffffffff801046f1:	48 c7 c6 2c 99 10 80 	mov    $0xffffffff8010992c,%rsi
ffffffff801046f8:	48 89 c7             	mov    %rax,%rdi
ffffffff801046fb:	e8 31 18 00 00       	callq  ffffffff80105f31 <memcmp>
ffffffff80104700:	85 c0                	test   %eax,%eax
ffffffff80104702:	75 08                	jne    ffffffff8010470c <acpiinit+0xb4>
      madt = (void*) hdr;
ffffffff80104704:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80104708:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for (n = 0; n < count; n++) {
ffffffff8010470c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80104710:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104713:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80104716:	72 9d                	jb     ffffffff801046b5 <acpiinit+0x5d>
  }

  return acpi_config_smp(madt);
ffffffff80104718:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010471c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010471f:	e8 fc fc ff ff       	callq  ffffffff80104420 <acpi_config_smp>
ffffffff80104724:	eb 1f                	jmp    ffffffff80104745 <acpiinit+0xed>
    goto notmapped;
ffffffff80104726:	90                   	nop
ffffffff80104727:	eb 01                	jmp    ffffffff8010472a <acpiinit+0xd2>
      goto notmapped;
ffffffff80104729:	90                   	nop

notmapped:
  cprintf("acpi: tables above 0x%x not mapped.\n", PHYSLIMIT);
ffffffff8010472a:	be 00 00 00 80       	mov    $0x80000000,%esi
ffffffff8010472f:	48 c7 c7 38 99 10 80 	mov    $0xffffffff80109938,%rdi
ffffffff80104736:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010473b:	e8 61 be ff ff       	callq  ffffffff801005a1 <cprintf>
  return -1;
ffffffff80104740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80104745:	c9                   	leaveq 
ffffffff80104746:	c3                   	retq   

ffffffff80104747 <outb>:
{
ffffffff80104747:	55                   	push   %rbp
ffffffff80104748:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010474b:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010474f:	89 fa                	mov    %edi,%edx
ffffffff80104751:	89 f0                	mov    %esi,%eax
ffffffff80104753:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80104757:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff8010475a:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff8010475e:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff80104762:	ee                   	out    %al,(%dx)
}
ffffffff80104763:	90                   	nop
ffffffff80104764:	c9                   	leaveq 
ffffffff80104765:	c3                   	retq   

ffffffff80104766 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
ffffffff80104766:	55                   	push   %rbp
ffffffff80104767:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010476a:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010476e:	89 f8                	mov    %edi,%eax
ffffffff80104770:	66 89 45 fc          	mov    %ax,-0x4(%rbp)
  irqmask = mask;
ffffffff80104774:	0f b7 45 fc          	movzwl -0x4(%rbp),%eax
ffffffff80104778:	66 89 05 c1 5d 00 00 	mov    %ax,0x5dc1(%rip)        # ffffffff8010a540 <irqmask>
  outb(IO_PIC1+1, mask);
ffffffff8010477f:	0f b7 45 fc          	movzwl -0x4(%rbp),%eax
ffffffff80104783:	0f b6 c0             	movzbl %al,%eax
ffffffff80104786:	89 c6                	mov    %eax,%esi
ffffffff80104788:	bf 21 00 00 00       	mov    $0x21,%edi
ffffffff8010478d:	e8 b5 ff ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC2+1, mask >> 8);
ffffffff80104792:	0f b7 45 fc          	movzwl -0x4(%rbp),%eax
ffffffff80104796:	66 c1 e8 08          	shr    $0x8,%ax
ffffffff8010479a:	0f b6 c0             	movzbl %al,%eax
ffffffff8010479d:	89 c6                	mov    %eax,%esi
ffffffff8010479f:	bf a1 00 00 00       	mov    $0xa1,%edi
ffffffff801047a4:	e8 9e ff ff ff       	callq  ffffffff80104747 <outb>
}
ffffffff801047a9:	90                   	nop
ffffffff801047aa:	c9                   	leaveq 
ffffffff801047ab:	c3                   	retq   

ffffffff801047ac <picenable>:

void
picenable(int irq)
{
ffffffff801047ac:	55                   	push   %rbp
ffffffff801047ad:	48 89 e5             	mov    %rsp,%rbp
ffffffff801047b0:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff801047b4:	89 7d fc             	mov    %edi,-0x4(%rbp)
  picsetmask(irqmask & ~(1<<irq));
ffffffff801047b7:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801047ba:	ba 01 00 00 00       	mov    $0x1,%edx
ffffffff801047bf:	89 c1                	mov    %eax,%ecx
ffffffff801047c1:	d3 e2                	shl    %cl,%edx
ffffffff801047c3:	89 d0                	mov    %edx,%eax
ffffffff801047c5:	f7 d0                	not    %eax
ffffffff801047c7:	89 c2                	mov    %eax,%edx
ffffffff801047c9:	0f b7 05 70 5d 00 00 	movzwl 0x5d70(%rip),%eax        # ffffffff8010a540 <irqmask>
ffffffff801047d0:	21 d0                	and    %edx,%eax
ffffffff801047d2:	0f b7 c0             	movzwl %ax,%eax
ffffffff801047d5:	89 c7                	mov    %eax,%edi
ffffffff801047d7:	e8 8a ff ff ff       	callq  ffffffff80104766 <picsetmask>
}
ffffffff801047dc:	90                   	nop
ffffffff801047dd:	c9                   	leaveq 
ffffffff801047de:	c3                   	retq   

ffffffff801047df <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
ffffffff801047df:	55                   	push   %rbp
ffffffff801047e0:	48 89 e5             	mov    %rsp,%rbp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
ffffffff801047e3:	be ff 00 00 00       	mov    $0xff,%esi
ffffffff801047e8:	bf 21 00 00 00       	mov    $0x21,%edi
ffffffff801047ed:	e8 55 ff ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC2+1, 0xFF);
ffffffff801047f2:	be ff 00 00 00       	mov    $0xff,%esi
ffffffff801047f7:	bf a1 00 00 00       	mov    $0xa1,%edi
ffffffff801047fc:	e8 46 ff ff ff       	callq  ffffffff80104747 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
ffffffff80104801:	be 11 00 00 00       	mov    $0x11,%esi
ffffffff80104806:	bf 20 00 00 00       	mov    $0x20,%edi
ffffffff8010480b:	e8 37 ff ff ff       	callq  ffffffff80104747 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
ffffffff80104810:	be 20 00 00 00       	mov    $0x20,%esi
ffffffff80104815:	bf 21 00 00 00       	mov    $0x21,%edi
ffffffff8010481a:	e8 28 ff ff ff       	callq  ffffffff80104747 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
ffffffff8010481f:	be 04 00 00 00       	mov    $0x4,%esi
ffffffff80104824:	bf 21 00 00 00       	mov    $0x21,%edi
ffffffff80104829:	e8 19 ff ff ff       	callq  ffffffff80104747 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
ffffffff8010482e:	be 03 00 00 00       	mov    $0x3,%esi
ffffffff80104833:	bf 21 00 00 00       	mov    $0x21,%edi
ffffffff80104838:	e8 0a ff ff ff       	callq  ffffffff80104747 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
ffffffff8010483d:	be 11 00 00 00       	mov    $0x11,%esi
ffffffff80104842:	bf a0 00 00 00       	mov    $0xa0,%edi
ffffffff80104847:	e8 fb fe ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
ffffffff8010484c:	be 28 00 00 00       	mov    $0x28,%esi
ffffffff80104851:	bf a1 00 00 00       	mov    $0xa1,%edi
ffffffff80104856:	e8 ec fe ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
ffffffff8010485b:	be 02 00 00 00       	mov    $0x2,%esi
ffffffff80104860:	bf a1 00 00 00       	mov    $0xa1,%edi
ffffffff80104865:	e8 dd fe ff ff       	callq  ffffffff80104747 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
ffffffff8010486a:	be 03 00 00 00       	mov    $0x3,%esi
ffffffff8010486f:	bf a1 00 00 00       	mov    $0xa1,%edi
ffffffff80104874:	e8 ce fe ff ff       	callq  ffffffff80104747 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
ffffffff80104879:	be 68 00 00 00       	mov    $0x68,%esi
ffffffff8010487e:	bf 20 00 00 00       	mov    $0x20,%edi
ffffffff80104883:	e8 bf fe ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
ffffffff80104888:	be 0a 00 00 00       	mov    $0xa,%esi
ffffffff8010488d:	bf 20 00 00 00       	mov    $0x20,%edi
ffffffff80104892:	e8 b0 fe ff ff       	callq  ffffffff80104747 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
ffffffff80104897:	be 68 00 00 00       	mov    $0x68,%esi
ffffffff8010489c:	bf a0 00 00 00       	mov    $0xa0,%edi
ffffffff801048a1:	e8 a1 fe ff ff       	callq  ffffffff80104747 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
ffffffff801048a6:	be 0a 00 00 00       	mov    $0xa,%esi
ffffffff801048ab:	bf a0 00 00 00       	mov    $0xa0,%edi
ffffffff801048b0:	e8 92 fe ff ff       	callq  ffffffff80104747 <outb>

  if(irqmask != 0xFFFF)
ffffffff801048b5:	0f b7 05 84 5c 00 00 	movzwl 0x5c84(%rip),%eax        # ffffffff8010a540 <irqmask>
ffffffff801048bc:	66 83 f8 ff          	cmp    $0xffff,%ax
ffffffff801048c0:	74 11                	je     ffffffff801048d3 <picinit+0xf4>
    picsetmask(irqmask);
ffffffff801048c2:	0f b7 05 77 5c 00 00 	movzwl 0x5c77(%rip),%eax        # ffffffff8010a540 <irqmask>
ffffffff801048c9:	0f b7 c0             	movzwl %ax,%eax
ffffffff801048cc:	89 c7                	mov    %eax,%edi
ffffffff801048ce:	e8 93 fe ff ff       	callq  ffffffff80104766 <picsetmask>
}
ffffffff801048d3:	90                   	nop
ffffffff801048d4:	5d                   	pop    %rbp
ffffffff801048d5:	c3                   	retq   

ffffffff801048d6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
ffffffff801048d6:	55                   	push   %rbp
ffffffff801048d7:	48 89 e5             	mov    %rsp,%rbp
ffffffff801048da:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801048de:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff801048e2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct pipe *p;

  p = 0;
ffffffff801048e6:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
ffffffff801048ed:	00 
  *f0 = *f1 = 0;
ffffffff801048ee:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801048f2:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
ffffffff801048f9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801048fd:	48 8b 10             	mov    (%rax),%rdx
ffffffff80104900:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104904:	48 89 10             	mov    %rdx,(%rax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
ffffffff80104907:	e8 2e cb ff ff       	callq  ffffffff8010143a <filealloc>
ffffffff8010490c:	48 89 c2             	mov    %rax,%rdx
ffffffff8010490f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104913:	48 89 10             	mov    %rdx,(%rax)
ffffffff80104916:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010491a:	48 8b 00             	mov    (%rax),%rax
ffffffff8010491d:	48 85 c0             	test   %rax,%rax
ffffffff80104920:	0f 84 e9 00 00 00    	je     ffffffff80104a0f <pipealloc+0x139>
ffffffff80104926:	e8 0f cb ff ff       	callq  ffffffff8010143a <filealloc>
ffffffff8010492b:	48 89 c2             	mov    %rax,%rdx
ffffffff8010492e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104932:	48 89 10             	mov    %rdx,(%rax)
ffffffff80104935:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104939:	48 8b 00             	mov    (%rax),%rax
ffffffff8010493c:	48 85 c0             	test   %rax,%rax
ffffffff8010493f:	0f 84 ca 00 00 00    	je     ffffffff80104a0f <pipealloc+0x139>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
ffffffff80104945:	e8 41 e9 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff8010494a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff8010494e:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80104953:	0f 84 b9 00 00 00    	je     ffffffff80104a12 <pipealloc+0x13c>
    goto bad;
  p->readopen = 1;
ffffffff80104959:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010495d:	c7 80 70 02 00 00 01 	movl   $0x1,0x270(%rax)
ffffffff80104964:	00 00 00 
  p->writeopen = 1;
ffffffff80104967:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010496b:	c7 80 74 02 00 00 01 	movl   $0x1,0x274(%rax)
ffffffff80104972:	00 00 00 
  p->nwrite = 0;
ffffffff80104975:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104979:	c7 80 6c 02 00 00 00 	movl   $0x0,0x26c(%rax)
ffffffff80104980:	00 00 00 
  p->nread = 0;
ffffffff80104983:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104987:	c7 80 68 02 00 00 00 	movl   $0x0,0x268(%rax)
ffffffff8010498e:	00 00 00 
  initlock(&p->lock, "pipe");
ffffffff80104991:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104995:	48 c7 c6 5d 99 10 80 	mov    $0xffffffff8010995d,%rsi
ffffffff8010499c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010499f:	e8 69 11 00 00       	callq  ffffffff80105b0d <initlock>
  (*f0)->type = FD_PIPE;
ffffffff801049a4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801049a8:	48 8b 00             	mov    (%rax),%rax
ffffffff801049ab:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
  (*f0)->readable = 1;
ffffffff801049b1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801049b5:	48 8b 00             	mov    (%rax),%rax
ffffffff801049b8:	c6 40 08 01          	movb   $0x1,0x8(%rax)
  (*f0)->writable = 0;
ffffffff801049bc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801049c0:	48 8b 00             	mov    (%rax),%rax
ffffffff801049c3:	c6 40 09 00          	movb   $0x0,0x9(%rax)
  (*f0)->pipe = p;
ffffffff801049c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801049cb:	48 8b 00             	mov    (%rax),%rax
ffffffff801049ce:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff801049d2:	48 89 50 10          	mov    %rdx,0x10(%rax)
  (*f1)->type = FD_PIPE;
ffffffff801049d6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801049da:	48 8b 00             	mov    (%rax),%rax
ffffffff801049dd:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
  (*f1)->readable = 0;
ffffffff801049e3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801049e7:	48 8b 00             	mov    (%rax),%rax
ffffffff801049ea:	c6 40 08 00          	movb   $0x0,0x8(%rax)
  (*f1)->writable = 1;
ffffffff801049ee:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801049f2:	48 8b 00             	mov    (%rax),%rax
ffffffff801049f5:	c6 40 09 01          	movb   $0x1,0x9(%rax)
  (*f1)->pipe = p;
ffffffff801049f9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801049fd:	48 8b 00             	mov    (%rax),%rax
ffffffff80104a00:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80104a04:	48 89 50 10          	mov    %rdx,0x10(%rax)
  return 0;
ffffffff80104a08:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80104a0d:	eb 52                	jmp    ffffffff80104a61 <pipealloc+0x18b>

//PAGEBREAK: 20
 bad:
ffffffff80104a0f:	90                   	nop
ffffffff80104a10:	eb 01                	jmp    ffffffff80104a13 <pipealloc+0x13d>
    goto bad;
ffffffff80104a12:	90                   	nop
  if(p)
ffffffff80104a13:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80104a18:	74 0c                	je     ffffffff80104a26 <pipealloc+0x150>
    kfree((char*)p);
ffffffff80104a1a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104a1e:	48 89 c7             	mov    %rax,%rdi
ffffffff80104a21:	e8 bb e7 ff ff       	callq  ffffffff801031e1 <kfree>
  if(*f0)
ffffffff80104a26:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104a2a:	48 8b 00             	mov    (%rax),%rax
ffffffff80104a2d:	48 85 c0             	test   %rax,%rax
ffffffff80104a30:	74 0f                	je     ffffffff80104a41 <pipealloc+0x16b>
    fileclose(*f0);
ffffffff80104a32:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104a36:	48 8b 00             	mov    (%rax),%rax
ffffffff80104a39:	48 89 c7             	mov    %rax,%rdi
ffffffff80104a3c:	e8 b6 ca ff ff       	callq  ffffffff801014f7 <fileclose>
  if(*f1)
ffffffff80104a41:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104a45:	48 8b 00             	mov    (%rax),%rax
ffffffff80104a48:	48 85 c0             	test   %rax,%rax
ffffffff80104a4b:	74 0f                	je     ffffffff80104a5c <pipealloc+0x186>
    fileclose(*f1);
ffffffff80104a4d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104a51:	48 8b 00             	mov    (%rax),%rax
ffffffff80104a54:	48 89 c7             	mov    %rax,%rdi
ffffffff80104a57:	e8 9b ca ff ff       	callq  ffffffff801014f7 <fileclose>
  return -1;
ffffffff80104a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80104a61:	c9                   	leaveq 
ffffffff80104a62:	c3                   	retq   

ffffffff80104a63 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
ffffffff80104a63:	55                   	push   %rbp
ffffffff80104a64:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104a67:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80104a6b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80104a6f:	89 75 f4             	mov    %esi,-0xc(%rbp)
  acquire(&p->lock);
ffffffff80104a72:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104a76:	48 89 c7             	mov    %rax,%rdi
ffffffff80104a79:	e8 c4 10 00 00       	callq  ffffffff80105b42 <acquire>
  if(writable){
ffffffff80104a7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
ffffffff80104a82:	74 22                	je     ffffffff80104aa6 <pipeclose+0x43>
    p->writeopen = 0;
ffffffff80104a84:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104a88:	c7 80 74 02 00 00 00 	movl   $0x0,0x274(%rax)
ffffffff80104a8f:	00 00 00 
    wakeup(&p->nread);
ffffffff80104a92:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104a96:	48 05 68 02 00 00    	add    $0x268,%rax
ffffffff80104a9c:	48 89 c7             	mov    %rax,%rdi
ffffffff80104a9f:	e8 3f 0e 00 00       	callq  ffffffff801058e3 <wakeup>
ffffffff80104aa4:	eb 20                	jmp    ffffffff80104ac6 <pipeclose+0x63>
  } else {
    p->readopen = 0;
ffffffff80104aa6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104aaa:	c7 80 70 02 00 00 00 	movl   $0x0,0x270(%rax)
ffffffff80104ab1:	00 00 00 
    wakeup(&p->nwrite);
ffffffff80104ab4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104ab8:	48 05 6c 02 00 00    	add    $0x26c,%rax
ffffffff80104abe:	48 89 c7             	mov    %rax,%rdi
ffffffff80104ac1:	e8 1d 0e 00 00       	callq  ffffffff801058e3 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
ffffffff80104ac6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104aca:	8b 80 70 02 00 00    	mov    0x270(%rax),%eax
ffffffff80104ad0:	85 c0                	test   %eax,%eax
ffffffff80104ad2:	75 28                	jne    ffffffff80104afc <pipeclose+0x99>
ffffffff80104ad4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104ad8:	8b 80 74 02 00 00    	mov    0x274(%rax),%eax
ffffffff80104ade:	85 c0                	test   %eax,%eax
ffffffff80104ae0:	75 1a                	jne    ffffffff80104afc <pipeclose+0x99>
    release(&p->lock);
ffffffff80104ae2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104ae6:	48 89 c7             	mov    %rax,%rdi
ffffffff80104ae9:	e8 2b 11 00 00       	callq  ffffffff80105c19 <release>
    kfree((char*)p);
ffffffff80104aee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104af2:	48 89 c7             	mov    %rax,%rdi
ffffffff80104af5:	e8 e7 e6 ff ff       	callq  ffffffff801031e1 <kfree>
ffffffff80104afa:	eb 0c                	jmp    ffffffff80104b08 <pipeclose+0xa5>
  } else
    release(&p->lock);
ffffffff80104afc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104b00:	48 89 c7             	mov    %rax,%rdi
ffffffff80104b03:	e8 11 11 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80104b08:	90                   	nop
ffffffff80104b09:	c9                   	leaveq 
ffffffff80104b0a:	c3                   	retq   

ffffffff80104b0b <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
ffffffff80104b0b:	55                   	push   %rbp
ffffffff80104b0c:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104b0f:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80104b13:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80104b17:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80104b1b:	89 55 dc             	mov    %edx,-0x24(%rbp)
  int i;

  acquire(&p->lock);
ffffffff80104b1e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b22:	48 89 c7             	mov    %rax,%rdi
ffffffff80104b25:	e8 18 10 00 00       	callq  ffffffff80105b42 <acquire>
  for(i = 0; i < n; i++){
ffffffff80104b2a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80104b31:	e9 bc 00 00 00       	jmpq   ffffffff80104bf2 <pipewrite+0xe7>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
ffffffff80104b36:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b3a:	8b 80 70 02 00 00    	mov    0x270(%rax),%eax
ffffffff80104b40:	85 c0                	test   %eax,%eax
ffffffff80104b42:	74 12                	je     ffffffff80104b56 <pipewrite+0x4b>
ffffffff80104b44:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80104b4b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80104b4f:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff80104b52:	85 c0                	test   %eax,%eax
ffffffff80104b54:	74 16                	je     ffffffff80104b6c <pipewrite+0x61>
        release(&p->lock);
ffffffff80104b56:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b5a:	48 89 c7             	mov    %rax,%rdi
ffffffff80104b5d:	e8 b7 10 00 00       	callq  ffffffff80105c19 <release>
        return -1;
ffffffff80104b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80104b67:	e9 af 00 00 00       	jmpq   ffffffff80104c1b <pipewrite+0x110>
      }
      wakeup(&p->nread);
ffffffff80104b6c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b70:	48 05 68 02 00 00    	add    $0x268,%rax
ffffffff80104b76:	48 89 c7             	mov    %rax,%rdi
ffffffff80104b79:	e8 65 0d 00 00       	callq  ffffffff801058e3 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
ffffffff80104b7e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b82:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80104b86:	48 81 c2 6c 02 00 00 	add    $0x26c,%rdx
ffffffff80104b8d:	48 89 c6             	mov    %rax,%rsi
ffffffff80104b90:	48 89 d7             	mov    %rdx,%rdi
ffffffff80104b93:	e8 38 0c 00 00       	callq  ffffffff801057d0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
ffffffff80104b98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104b9c:	8b 90 6c 02 00 00    	mov    0x26c(%rax),%edx
ffffffff80104ba2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104ba6:	8b 80 68 02 00 00    	mov    0x268(%rax),%eax
ffffffff80104bac:	05 00 02 00 00       	add    $0x200,%eax
ffffffff80104bb1:	39 c2                	cmp    %eax,%edx
ffffffff80104bb3:	74 81                	je     ffffffff80104b36 <pipewrite+0x2b>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
ffffffff80104bb5:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104bb8:	48 63 d0             	movslq %eax,%rdx
ffffffff80104bbb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104bbf:	48 8d 34 02          	lea    (%rdx,%rax,1),%rsi
ffffffff80104bc3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104bc7:	8b 80 6c 02 00 00    	mov    0x26c(%rax),%eax
ffffffff80104bcd:	8d 48 01             	lea    0x1(%rax),%ecx
ffffffff80104bd0:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80104bd4:	89 8a 6c 02 00 00    	mov    %ecx,0x26c(%rdx)
ffffffff80104bda:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff80104bdf:	89 c1                	mov    %eax,%ecx
ffffffff80104be1:	0f b6 16             	movzbl (%rsi),%edx
ffffffff80104be4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104be8:	89 c9                	mov    %ecx,%ecx
ffffffff80104bea:	88 54 08 68          	mov    %dl,0x68(%rax,%rcx,1)
  for(i = 0; i < n; i++){
ffffffff80104bee:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80104bf2:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104bf5:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80104bf8:	7c 9e                	jl     ffffffff80104b98 <pipewrite+0x8d>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
ffffffff80104bfa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104bfe:	48 05 68 02 00 00    	add    $0x268,%rax
ffffffff80104c04:	48 89 c7             	mov    %rax,%rdi
ffffffff80104c07:	e8 d7 0c 00 00       	callq  ffffffff801058e3 <wakeup>
  release(&p->lock);
ffffffff80104c0c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c10:	48 89 c7             	mov    %rax,%rdi
ffffffff80104c13:	e8 01 10 00 00       	callq  ffffffff80105c19 <release>
  return n;
ffffffff80104c18:	8b 45 dc             	mov    -0x24(%rbp),%eax
}
ffffffff80104c1b:	c9                   	leaveq 
ffffffff80104c1c:	c3                   	retq   

ffffffff80104c1d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
ffffffff80104c1d:	55                   	push   %rbp
ffffffff80104c1e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104c21:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80104c25:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80104c29:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80104c2d:	89 55 dc             	mov    %edx,-0x24(%rbp)
  int i;

  acquire(&p->lock);
ffffffff80104c30:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c34:	48 89 c7             	mov    %rax,%rdi
ffffffff80104c37:	e8 06 0f 00 00       	callq  ffffffff80105b42 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
ffffffff80104c3c:	eb 42                	jmp    ffffffff80104c80 <piperead+0x63>
    if(proc->killed){
ffffffff80104c3e:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80104c45:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80104c49:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff80104c4c:	85 c0                	test   %eax,%eax
ffffffff80104c4e:	74 16                	je     ffffffff80104c66 <piperead+0x49>
      release(&p->lock);
ffffffff80104c50:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c54:	48 89 c7             	mov    %rax,%rdi
ffffffff80104c57:	e8 bd 0f 00 00       	callq  ffffffff80105c19 <release>
      return -1;
ffffffff80104c5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80104c61:	e9 c9 00 00 00       	jmpq   ffffffff80104d2f <piperead+0x112>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
ffffffff80104c66:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c6a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80104c6e:	48 81 c2 68 02 00 00 	add    $0x268,%rdx
ffffffff80104c75:	48 89 c6             	mov    %rax,%rsi
ffffffff80104c78:	48 89 d7             	mov    %rdx,%rdi
ffffffff80104c7b:	e8 50 0b 00 00       	callq  ffffffff801057d0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
ffffffff80104c80:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c84:	8b 90 68 02 00 00    	mov    0x268(%rax),%edx
ffffffff80104c8a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c8e:	8b 80 6c 02 00 00    	mov    0x26c(%rax),%eax
ffffffff80104c94:	39 c2                	cmp    %eax,%edx
ffffffff80104c96:	75 0e                	jne    ffffffff80104ca6 <piperead+0x89>
ffffffff80104c98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104c9c:	8b 80 74 02 00 00    	mov    0x274(%rax),%eax
ffffffff80104ca2:	85 c0                	test   %eax,%eax
ffffffff80104ca4:	75 98                	jne    ffffffff80104c3e <piperead+0x21>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
ffffffff80104ca6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80104cad:	eb 54                	jmp    ffffffff80104d03 <piperead+0xe6>
    if(p->nread == p->nwrite)
ffffffff80104caf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104cb3:	8b 90 68 02 00 00    	mov    0x268(%rax),%edx
ffffffff80104cb9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104cbd:	8b 80 6c 02 00 00    	mov    0x26c(%rax),%eax
ffffffff80104cc3:	39 c2                	cmp    %eax,%edx
ffffffff80104cc5:	74 46                	je     ffffffff80104d0d <piperead+0xf0>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
ffffffff80104cc7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104ccb:	8b 80 68 02 00 00    	mov    0x268(%rax),%eax
ffffffff80104cd1:	8d 48 01             	lea    0x1(%rax),%ecx
ffffffff80104cd4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80104cd8:	89 8a 68 02 00 00    	mov    %ecx,0x268(%rdx)
ffffffff80104cde:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff80104ce3:	89 c1                	mov    %eax,%ecx
ffffffff80104ce5:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104ce8:	48 63 d0             	movslq %eax,%rdx
ffffffff80104ceb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80104cef:	48 01 c2             	add    %rax,%rdx
ffffffff80104cf2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104cf6:	89 c9                	mov    %ecx,%ecx
ffffffff80104cf8:	0f b6 44 08 68       	movzbl 0x68(%rax,%rcx,1),%eax
ffffffff80104cfd:	88 02                	mov    %al,(%rdx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
ffffffff80104cff:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80104d03:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104d06:	3b 45 dc             	cmp    -0x24(%rbp),%eax
ffffffff80104d09:	7c a4                	jl     ffffffff80104caf <piperead+0x92>
ffffffff80104d0b:	eb 01                	jmp    ffffffff80104d0e <piperead+0xf1>
      break;
ffffffff80104d0d:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
ffffffff80104d0e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104d12:	48 05 6c 02 00 00    	add    $0x26c,%rax
ffffffff80104d18:	48 89 c7             	mov    %rax,%rdi
ffffffff80104d1b:	e8 c3 0b 00 00       	callq  ffffffff801058e3 <wakeup>
  release(&p->lock);
ffffffff80104d20:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80104d24:	48 89 c7             	mov    %rax,%rdi
ffffffff80104d27:	e8 ed 0e 00 00       	callq  ffffffff80105c19 <release>
  return i;
ffffffff80104d2c:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff80104d2f:	c9                   	leaveq 
ffffffff80104d30:	c3                   	retq   

ffffffff80104d31 <readeflags>:
{
ffffffff80104d31:	55                   	push   %rbp
ffffffff80104d32:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104d35:	48 83 ec 10          	sub    $0x10,%rsp
  asm volatile("pushf; pop %0" : "=r" (eflags));
ffffffff80104d39:	9c                   	pushfq 
ffffffff80104d3a:	58                   	pop    %rax
ffffffff80104d3b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  return eflags;
ffffffff80104d3f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80104d43:	c9                   	leaveq 
ffffffff80104d44:	c3                   	retq   

ffffffff80104d45 <sti>:
{
ffffffff80104d45:	55                   	push   %rbp
ffffffff80104d46:	48 89 e5             	mov    %rsp,%rbp
  asm volatile("sti");
ffffffff80104d49:	fb                   	sti    
}
ffffffff80104d4a:	90                   	nop
ffffffff80104d4b:	5d                   	pop    %rbp
ffffffff80104d4c:	c3                   	retq   

ffffffff80104d4d <hlt>:
{
ffffffff80104d4d:	55                   	push   %rbp
ffffffff80104d4e:	48 89 e5             	mov    %rsp,%rbp
  asm volatile("hlt");
ffffffff80104d51:	f4                   	hlt    
}
ffffffff80104d52:	90                   	nop
ffffffff80104d53:	5d                   	pop    %rbp
ffffffff80104d54:	c3                   	retq   

ffffffff80104d55 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
ffffffff80104d55:	55                   	push   %rbp
ffffffff80104d56:	48 89 e5             	mov    %rsp,%rbp
  initlock(&ptable.lock, "ptable");
ffffffff80104d59:	48 c7 c6 62 99 10 80 	mov    $0xffffffff80109962,%rsi
ffffffff80104d60:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80104d67:	e8 a1 0d 00 00       	callq  ffffffff80105b0d <initlock>
}
ffffffff80104d6c:	90                   	nop
ffffffff80104d6d:	5d                   	pop    %rbp
ffffffff80104d6e:	c3                   	retq   

ffffffff80104d6f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
ffffffff80104d6f:	55                   	push   %rbp
ffffffff80104d70:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104d73:	48 83 ec 10          	sub    $0x10,%rsp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
ffffffff80104d77:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80104d7e:	e8 bf 0d 00 00       	callq  ffffffff80105b42 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
ffffffff80104d83:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff80104d8a:	80 
ffffffff80104d8b:	eb 13                	jmp    ffffffff80104da0 <allocproc+0x31>
    if(p->state == UNUSED)
ffffffff80104d8d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104d91:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80104d94:	85 c0                	test   %eax,%eax
ffffffff80104d96:	74 28                	je     ffffffff80104dc0 <allocproc+0x51>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
ffffffff80104d98:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff80104d9f:	00 
ffffffff80104da0:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff80104da7:	80 
ffffffff80104da8:	72 e3                	jb     ffffffff80104d8d <allocproc+0x1e>
      goto found;
  release(&ptable.lock);
ffffffff80104daa:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80104db1:	e8 63 0e 00 00       	callq  ffffffff80105c19 <release>
  return 0;
ffffffff80104db6:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80104dbb:	e9 d8 00 00 00       	jmpq   ffffffff80104e98 <allocproc+0x129>
      goto found;
ffffffff80104dc0:	90                   	nop

found:
  p->state = EMBRYO;
ffffffff80104dc1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104dc5:	c7 40 18 01 00 00 00 	movl   $0x1,0x18(%rax)
  p->pid = nextpid++;
ffffffff80104dcc:	8b 05 8e 57 00 00    	mov    0x578e(%rip),%eax        # ffffffff8010a560 <nextpid>
ffffffff80104dd2:	8d 50 01             	lea    0x1(%rax),%edx
ffffffff80104dd5:	89 15 85 57 00 00    	mov    %edx,0x5785(%rip)        # ffffffff8010a560 <nextpid>
ffffffff80104ddb:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80104ddf:	89 42 1c             	mov    %eax,0x1c(%rdx)
  release(&ptable.lock);
ffffffff80104de2:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80104de9:	e8 2b 0e 00 00       	callq  ffffffff80105c19 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
ffffffff80104dee:	e8 98 e4 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80104df3:	48 89 c2             	mov    %rax,%rdx
ffffffff80104df6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104dfa:	48 89 50 10          	mov    %rdx,0x10(%rax)
ffffffff80104dfe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e02:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff80104e06:	48 85 c0             	test   %rax,%rax
ffffffff80104e09:	75 12                	jne    ffffffff80104e1d <allocproc+0xae>
    p->state = UNUSED;
ffffffff80104e0b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e0f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%rax)
    return 0;
ffffffff80104e16:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80104e1b:	eb 7b                	jmp    ffffffff80104e98 <allocproc+0x129>
  }
  sp = p->kstack + KSTACKSIZE;
ffffffff80104e1d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e21:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff80104e25:	48 05 00 10 00 00    	add    $0x1000,%rax
ffffffff80104e2b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
ffffffff80104e2f:	48 81 6d f0 b0 00 00 	subq   $0xb0,-0x10(%rbp)
ffffffff80104e36:	00 
  p->tf = (struct trapframe*)sp;
ffffffff80104e37:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e3b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80104e3f:	48 89 50 28          	mov    %rdx,0x28(%rax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= sizeof(uintp);
ffffffff80104e43:	48 83 6d f0 08       	subq   $0x8,-0x10(%rbp)
  *(uintp*)sp = (uintp)trapret;
ffffffff80104e48:	48 c7 c2 c0 75 10 80 	mov    $0xffffffff801075c0,%rdx
ffffffff80104e4f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80104e53:	48 89 10             	mov    %rdx,(%rax)

  sp -= sizeof *p->context;
ffffffff80104e56:	48 83 6d f0 40       	subq   $0x40,-0x10(%rbp)
  p->context = (struct context*)sp;
ffffffff80104e5b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e5f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80104e63:	48 89 50 30          	mov    %rdx,0x30(%rax)
  memset(p->context, 0, sizeof *p->context);
ffffffff80104e67:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e6b:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80104e6f:	ba 40 00 00 00       	mov    $0x40,%edx
ffffffff80104e74:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80104e79:	48 89 c7             	mov    %rax,%rdi
ffffffff80104e7c:	e8 30 10 00 00       	callq  ffffffff80105eb1 <memset>
  p->context->eip = (uintp)forkret;
ffffffff80104e81:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104e85:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80104e89:	48 c7 c2 a4 57 10 80 	mov    $0xffffffff801057a4,%rdx
ffffffff80104e90:	48 89 50 38          	mov    %rdx,0x38(%rax)

  return p;
ffffffff80104e94:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80104e98:	c9                   	leaveq 
ffffffff80104e99:	c3                   	retq   

ffffffff80104e9a <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
ffffffff80104e9a:	55                   	push   %rbp
ffffffff80104e9b:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104e9e:	48 83 ec 10          	sub    $0x10,%rsp
  struct proc *p;
  extern char _binary_out_initcode_start[], _binary_out_initcode_size[];
  
  p = allocproc();
ffffffff80104ea2:	e8 c8 fe ff ff       	callq  ffffffff80104d6f <allocproc>
ffffffff80104ea7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  initproc = p;
ffffffff80104eab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104eaf:	48 89 05 b2 dd 00 00 	mov    %rax,0xddb2(%rip)        # ffffffff80112c68 <initproc>
  if((p->pgdir = setupkvm()) == 0)
ffffffff80104eb6:	e8 ad 43 00 00       	callq  ffffffff80109268 <setupkvm>
ffffffff80104ebb:	48 89 c2             	mov    %rax,%rdx
ffffffff80104ebe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104ec2:	48 89 50 08          	mov    %rdx,0x8(%rax)
ffffffff80104ec6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104eca:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80104ece:	48 85 c0             	test   %rax,%rax
ffffffff80104ed1:	75 0c                	jne    ffffffff80104edf <userinit+0x45>
    panic("userinit: out of memory?");
ffffffff80104ed3:	48 c7 c7 69 99 10 80 	mov    $0xffffffff80109969,%rdi
ffffffff80104eda:	e8 1f ba ff ff       	callq  ffffffff801008fe <panic>
  inituvm(p->pgdir, _binary_out_initcode_start, (uintp)_binary_out_initcode_size);
ffffffff80104edf:	48 c7 c0 3c 00 00 00 	mov    $0x3c,%rax
ffffffff80104ee6:	89 c2                	mov    %eax,%edx
ffffffff80104ee8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104eec:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80104ef0:	48 c7 c6 70 ae 10 80 	mov    $0xffffffff8010ae70,%rsi
ffffffff80104ef7:	48 89 c7             	mov    %rax,%rdi
ffffffff80104efa:	e8 06 38 00 00       	callq  ffffffff80108705 <inituvm>
  p->sz = PGSIZE;
ffffffff80104eff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f03:	48 c7 00 00 10 00 00 	movq   $0x1000,(%rax)
  memset(p->tf, 0, sizeof(*p->tf));
ffffffff80104f0a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f0e:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f12:	ba b0 00 00 00       	mov    $0xb0,%edx
ffffffff80104f17:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80104f1c:	48 89 c7             	mov    %rax,%rdi
ffffffff80104f1f:	e8 8d 0f 00 00       	callq  ffffffff80105eb1 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
ffffffff80104f24:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f28:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f2c:	48 c7 80 90 00 00 00 	movq   $0x23,0x90(%rax)
ffffffff80104f33:	23 00 00 00 
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
ffffffff80104f37:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f3b:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f3f:	48 c7 80 a8 00 00 00 	movq   $0x2b,0xa8(%rax)
ffffffff80104f46:	2b 00 00 00 
#ifndef X64
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
#endif
  p->tf->eflags = FL_IF;
ffffffff80104f4a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f4e:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f52:	48 c7 80 98 00 00 00 	movq   $0x200,0x98(%rax)
ffffffff80104f59:	00 02 00 00 
  p->tf->esp = PGSIZE;
ffffffff80104f5d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f61:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f65:	48 c7 80 a0 00 00 00 	movq   $0x1000,0xa0(%rax)
ffffffff80104f6c:	00 10 00 00 
  p->tf->eip = 0;  // beginning of initcode.S
ffffffff80104f70:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f74:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80104f78:	48 c7 80 88 00 00 00 	movq   $0x0,0x88(%rax)
ffffffff80104f7f:	00 00 00 00 

  safestrcpy(p->name, "initcode", sizeof(p->name));
ffffffff80104f83:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104f87:	48 05 d0 00 00 00    	add    $0xd0,%rax
ffffffff80104f8d:	ba 10 00 00 00       	mov    $0x10,%edx
ffffffff80104f92:	48 c7 c6 82 99 10 80 	mov    $0xffffffff80109982,%rsi
ffffffff80104f99:	48 89 c7             	mov    %rax,%rdi
ffffffff80104f9c:	e8 ab 11 00 00       	callq  ffffffff8010614c <safestrcpy>
  p->cwd = namei("/");
ffffffff80104fa1:	48 c7 c7 8b 99 10 80 	mov    $0xffffffff8010998b,%rdi
ffffffff80104fa8:	e8 69 db ff ff       	callq  ffffffff80102b16 <namei>
ffffffff80104fad:	48 89 c2             	mov    %rax,%rdx
ffffffff80104fb0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104fb4:	48 89 90 c8 00 00 00 	mov    %rdx,0xc8(%rax)

  p->state = RUNNABLE;
ffffffff80104fbb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80104fbf:	c7 40 18 03 00 00 00 	movl   $0x3,0x18(%rax)
}
ffffffff80104fc6:	90                   	nop
ffffffff80104fc7:	c9                   	leaveq 
ffffffff80104fc8:	c3                   	retq   

ffffffff80104fc9 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
ffffffff80104fc9:	55                   	push   %rbp
ffffffff80104fca:	48 89 e5             	mov    %rsp,%rbp
ffffffff80104fcd:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80104fd1:	89 7d ec             	mov    %edi,-0x14(%rbp)
  uint sz;
  
  sz = proc->sz;
ffffffff80104fd4:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80104fdb:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80104fdf:	48 8b 00             	mov    (%rax),%rax
ffffffff80104fe2:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(n > 0){
ffffffff80104fe5:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff80104fe9:	7e 34                	jle    ffffffff8010501f <growproc+0x56>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
ffffffff80104feb:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80104fee:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80104ff1:	01 c2                	add    %eax,%edx
ffffffff80104ff3:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80104ffa:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80104ffe:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80105002:	8b 4d fc             	mov    -0x4(%rbp),%ecx
ffffffff80105005:	89 ce                	mov    %ecx,%esi
ffffffff80105007:	48 89 c7             	mov    %rax,%rdi
ffffffff8010500a:	e8 7f 38 00 00       	callq  ffffffff8010888e <allocuvm>
ffffffff8010500f:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80105012:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80105016:	75 44                	jne    ffffffff8010505c <growproc+0x93>
      return -1;
ffffffff80105018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010501d:	eb 66                	jmp    ffffffff80105085 <growproc+0xbc>
  } else if(n < 0){
ffffffff8010501f:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff80105023:	79 37                	jns    ffffffff8010505c <growproc+0x93>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
ffffffff80105025:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80105028:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010502b:	01 d0                	add    %edx,%eax
ffffffff8010502d:	89 c2                	mov    %eax,%edx
ffffffff8010502f:	8b 4d fc             	mov    -0x4(%rbp),%ecx
ffffffff80105032:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105039:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010503d:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80105041:	48 89 ce             	mov    %rcx,%rsi
ffffffff80105044:	48 89 c7             	mov    %rax,%rdi
ffffffff80105047:	e8 16 39 00 00       	callq  ffffffff80108962 <deallocuvm>
ffffffff8010504c:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff8010504f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80105053:	75 07                	jne    ffffffff8010505c <growproc+0x93>
      return -1;
ffffffff80105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010505a:	eb 29                	jmp    ffffffff80105085 <growproc+0xbc>
  }
  proc->sz = sz;
ffffffff8010505c:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105063:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105067:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff8010506a:	48 89 10             	mov    %rdx,(%rax)
  switchuvm(proc);
ffffffff8010506d:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105074:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105078:	48 89 c7             	mov    %rax,%rdi
ffffffff8010507b:	e8 bf 44 00 00       	callq  ffffffff8010953f <switchuvm>
  return 0;
ffffffff80105080:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80105085:	c9                   	leaveq 
ffffffff80105086:	c3                   	retq   

ffffffff80105087 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
ffffffff80105087:	55                   	push   %rbp
ffffffff80105088:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010508b:	53                   	push   %rbx
ffffffff8010508c:	48 83 ec 28          	sub    $0x28,%rsp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
ffffffff80105090:	e8 da fc ff ff       	callq  ffffffff80104d6f <allocproc>
ffffffff80105095:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff80105099:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
ffffffff8010509e:	75 0a                	jne    ffffffff801050aa <fork+0x23>
    return -1;
ffffffff801050a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801050a5:	e9 68 02 00 00       	jmpq   ffffffff80105312 <fork+0x28b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
ffffffff801050aa:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801050b1:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801050b5:	48 8b 00             	mov    (%rax),%rax
ffffffff801050b8:	89 c2                	mov    %eax,%edx
ffffffff801050ba:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801050c1:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801050c5:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff801050c9:	89 d6                	mov    %edx,%esi
ffffffff801050cb:	48 89 c7             	mov    %rax,%rdi
ffffffff801050ce:	e8 73 3a 00 00       	callq  ffffffff80108b46 <copyuvm>
ffffffff801050d3:	48 89 c2             	mov    %rax,%rdx
ffffffff801050d6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801050da:	48 89 50 08          	mov    %rdx,0x8(%rax)
ffffffff801050de:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801050e2:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff801050e6:	48 85 c0             	test   %rax,%rax
ffffffff801050e9:	75 31                	jne    ffffffff8010511c <fork+0x95>
    kfree(np->kstack);
ffffffff801050eb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801050ef:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff801050f3:	48 89 c7             	mov    %rax,%rdi
ffffffff801050f6:	e8 e6 e0 ff ff       	callq  ffffffff801031e1 <kfree>
    np->kstack = 0;
ffffffff801050fb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801050ff:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
ffffffff80105106:	00 
    np->state = UNUSED;
ffffffff80105107:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010510b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%rax)
    return -1;
ffffffff80105112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80105117:	e9 f6 01 00 00       	jmpq   ffffffff80105312 <fork+0x28b>
  }
  np->sz = proc->sz;
ffffffff8010511c:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105123:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105127:	48 8b 10             	mov    (%rax),%rdx
ffffffff8010512a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010512e:	48 89 10             	mov    %rdx,(%rax)
  np->parent = proc;
ffffffff80105131:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105138:	64 48 8b 10          	mov    %fs:(%rax),%rdx
ffffffff8010513c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105140:	48 89 50 20          	mov    %rdx,0x20(%rax)
  *np->tf = *proc->tf;
ffffffff80105144:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010514b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010514f:	48 8b 50 28          	mov    0x28(%rax),%rdx
ffffffff80105153:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105157:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff8010515b:	48 8b 0a             	mov    (%rdx),%rcx
ffffffff8010515e:	48 8b 5a 08          	mov    0x8(%rdx),%rbx
ffffffff80105162:	48 89 08             	mov    %rcx,(%rax)
ffffffff80105165:	48 89 58 08          	mov    %rbx,0x8(%rax)
ffffffff80105169:	48 8b 4a 10          	mov    0x10(%rdx),%rcx
ffffffff8010516d:	48 8b 5a 18          	mov    0x18(%rdx),%rbx
ffffffff80105171:	48 89 48 10          	mov    %rcx,0x10(%rax)
ffffffff80105175:	48 89 58 18          	mov    %rbx,0x18(%rax)
ffffffff80105179:	48 8b 4a 20          	mov    0x20(%rdx),%rcx
ffffffff8010517d:	48 8b 5a 28          	mov    0x28(%rdx),%rbx
ffffffff80105181:	48 89 48 20          	mov    %rcx,0x20(%rax)
ffffffff80105185:	48 89 58 28          	mov    %rbx,0x28(%rax)
ffffffff80105189:	48 8b 4a 30          	mov    0x30(%rdx),%rcx
ffffffff8010518d:	48 8b 5a 38          	mov    0x38(%rdx),%rbx
ffffffff80105191:	48 89 48 30          	mov    %rcx,0x30(%rax)
ffffffff80105195:	48 89 58 38          	mov    %rbx,0x38(%rax)
ffffffff80105199:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
ffffffff8010519d:	48 8b 5a 48          	mov    0x48(%rdx),%rbx
ffffffff801051a1:	48 89 48 40          	mov    %rcx,0x40(%rax)
ffffffff801051a5:	48 89 58 48          	mov    %rbx,0x48(%rax)
ffffffff801051a9:	48 8b 4a 50          	mov    0x50(%rdx),%rcx
ffffffff801051ad:	48 8b 5a 58          	mov    0x58(%rdx),%rbx
ffffffff801051b1:	48 89 48 50          	mov    %rcx,0x50(%rax)
ffffffff801051b5:	48 89 58 58          	mov    %rbx,0x58(%rax)
ffffffff801051b9:	48 8b 4a 60          	mov    0x60(%rdx),%rcx
ffffffff801051bd:	48 8b 5a 68          	mov    0x68(%rdx),%rbx
ffffffff801051c1:	48 89 48 60          	mov    %rcx,0x60(%rax)
ffffffff801051c5:	48 89 58 68          	mov    %rbx,0x68(%rax)
ffffffff801051c9:	48 8b 4a 70          	mov    0x70(%rdx),%rcx
ffffffff801051cd:	48 8b 5a 78          	mov    0x78(%rdx),%rbx
ffffffff801051d1:	48 89 48 70          	mov    %rcx,0x70(%rax)
ffffffff801051d5:	48 89 58 78          	mov    %rbx,0x78(%rax)
ffffffff801051d9:	48 8b 8a 80 00 00 00 	mov    0x80(%rdx),%rcx
ffffffff801051e0:	48 8b 9a 88 00 00 00 	mov    0x88(%rdx),%rbx
ffffffff801051e7:	48 89 88 80 00 00 00 	mov    %rcx,0x80(%rax)
ffffffff801051ee:	48 89 98 88 00 00 00 	mov    %rbx,0x88(%rax)
ffffffff801051f5:	48 8b 8a 90 00 00 00 	mov    0x90(%rdx),%rcx
ffffffff801051fc:	48 8b 9a 98 00 00 00 	mov    0x98(%rdx),%rbx
ffffffff80105203:	48 89 88 90 00 00 00 	mov    %rcx,0x90(%rax)
ffffffff8010520a:	48 89 98 98 00 00 00 	mov    %rbx,0x98(%rax)
ffffffff80105211:	48 8b 8a a8 00 00 00 	mov    0xa8(%rdx),%rcx
ffffffff80105218:	48 8b 92 a0 00 00 00 	mov    0xa0(%rdx),%rdx
ffffffff8010521f:	48 89 90 a0 00 00 00 	mov    %rdx,0xa0(%rax)
ffffffff80105226:	48 89 88 a8 00 00 00 	mov    %rcx,0xa8(%rax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
ffffffff8010522d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105231:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80105235:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  for(i = 0; i < NOFILE; i++)
ffffffff8010523c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
ffffffff80105243:	eb 5b                	jmp    ffffffff801052a0 <fork+0x219>
    if(proc->ofile[i])
ffffffff80105245:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010524c:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105250:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80105253:	48 63 d2             	movslq %edx,%rdx
ffffffff80105256:	48 83 c2 08          	add    $0x8,%rdx
ffffffff8010525a:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff8010525f:	48 85 c0             	test   %rax,%rax
ffffffff80105262:	74 38                	je     ffffffff8010529c <fork+0x215>
      np->ofile[i] = filedup(proc->ofile[i]);
ffffffff80105264:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010526b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010526f:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80105272:	48 63 d2             	movslq %edx,%rdx
ffffffff80105275:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80105279:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff8010527e:	48 89 c7             	mov    %rax,%rdi
ffffffff80105281:	e8 1f c2 ff ff       	callq  ffffffff801014a5 <filedup>
ffffffff80105286:	48 89 c1             	mov    %rax,%rcx
ffffffff80105289:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010528d:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80105290:	48 63 d2             	movslq %edx,%rdx
ffffffff80105293:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80105297:	48 89 4c d0 08       	mov    %rcx,0x8(%rax,%rdx,8)
  for(i = 0; i < NOFILE; i++)
ffffffff8010529c:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
ffffffff801052a0:	83 7d ec 0f          	cmpl   $0xf,-0x14(%rbp)
ffffffff801052a4:	7e 9f                	jle    ffffffff80105245 <fork+0x1be>
  np->cwd = idup(proc->cwd);
ffffffff801052a6:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801052ad:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801052b1:	48 8b 80 c8 00 00 00 	mov    0xc8(%rax),%rax
ffffffff801052b8:	48 89 c7             	mov    %rax,%rdi
ffffffff801052bb:	e8 52 cb ff ff       	callq  ffffffff80101e12 <idup>
ffffffff801052c0:	48 89 c2             	mov    %rax,%rdx
ffffffff801052c3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801052c7:	48 89 90 c8 00 00 00 	mov    %rdx,0xc8(%rax)
 
  pid = np->pid;
ffffffff801052ce:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801052d2:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff801052d5:	89 45 dc             	mov    %eax,-0x24(%rbp)
  np->state = RUNNABLE;
ffffffff801052d8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801052dc:	c7 40 18 03 00 00 00 	movl   $0x3,0x18(%rax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
ffffffff801052e3:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801052ea:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801052ee:	48 8d 88 d0 00 00 00 	lea    0xd0(%rax),%rcx
ffffffff801052f5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801052f9:	48 05 d0 00 00 00    	add    $0xd0,%rax
ffffffff801052ff:	ba 10 00 00 00       	mov    $0x10,%edx
ffffffff80105304:	48 89 ce             	mov    %rcx,%rsi
ffffffff80105307:	48 89 c7             	mov    %rax,%rdi
ffffffff8010530a:	e8 3d 0e 00 00       	callq  ffffffff8010614c <safestrcpy>
  return pid;
ffffffff8010530f:	8b 45 dc             	mov    -0x24(%rbp),%eax
}
ffffffff80105312:	48 83 c4 28          	add    $0x28,%rsp
ffffffff80105316:	5b                   	pop    %rbx
ffffffff80105317:	5d                   	pop    %rbp
ffffffff80105318:	c3                   	retq   

ffffffff80105319 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
ffffffff80105319:	55                   	push   %rbp
ffffffff8010531a:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010531d:	48 83 ec 10          	sub    $0x10,%rsp
  struct proc *p;
  int fd;

  if(proc == initproc)
ffffffff80105321:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105328:	64 48 8b 10          	mov    %fs:(%rax),%rdx
ffffffff8010532c:	48 8b 05 35 d9 00 00 	mov    0xd935(%rip),%rax        # ffffffff80112c68 <initproc>
ffffffff80105333:	48 39 c2             	cmp    %rax,%rdx
ffffffff80105336:	75 0c                	jne    ffffffff80105344 <exit+0x2b>
    panic("init exiting");
ffffffff80105338:	48 c7 c7 8d 99 10 80 	mov    $0xffffffff8010998d,%rdi
ffffffff8010533f:	e8 ba b5 ff ff       	callq  ffffffff801008fe <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
ffffffff80105344:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
ffffffff8010534b:	eb 63                	jmp    ffffffff801053b0 <exit+0x97>
    if(proc->ofile[fd]){
ffffffff8010534d:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105354:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105358:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff8010535b:	48 63 d2             	movslq %edx,%rdx
ffffffff8010535e:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80105362:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff80105367:	48 85 c0             	test   %rax,%rax
ffffffff8010536a:	74 40                	je     ffffffff801053ac <exit+0x93>
      fileclose(proc->ofile[fd]);
ffffffff8010536c:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105373:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105377:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff8010537a:	48 63 d2             	movslq %edx,%rdx
ffffffff8010537d:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80105381:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff80105386:	48 89 c7             	mov    %rax,%rdi
ffffffff80105389:	e8 69 c1 ff ff       	callq  ffffffff801014f7 <fileclose>
      proc->ofile[fd] = 0;
ffffffff8010538e:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105395:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105399:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff8010539c:	48 63 d2             	movslq %edx,%rdx
ffffffff8010539f:	48 83 c2 08          	add    $0x8,%rdx
ffffffff801053a3:	48 c7 44 d0 08 00 00 	movq   $0x0,0x8(%rax,%rdx,8)
ffffffff801053aa:	00 00 
  for(fd = 0; fd < NOFILE; fd++){
ffffffff801053ac:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
ffffffff801053b0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%rbp)
ffffffff801053b4:	7e 97                	jle    ffffffff8010534d <exit+0x34>
    }
  }

  iput(proc->cwd);
ffffffff801053b6:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801053bd:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801053c1:	48 8b 80 c8 00 00 00 	mov    0xc8(%rax),%rax
ffffffff801053c8:	48 89 c7             	mov    %rax,%rdi
ffffffff801053cb:	e8 60 cc ff ff       	callq  ffffffff80102030 <iput>
  proc->cwd = 0;
ffffffff801053d0:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801053d7:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801053db:	48 c7 80 c8 00 00 00 	movq   $0x0,0xc8(%rax)
ffffffff801053e2:	00 00 00 00 

  acquire(&ptable.lock);
ffffffff801053e6:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff801053ed:	e8 50 07 00 00       	callq  ffffffff80105b42 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
ffffffff801053f2:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801053f9:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801053fd:	48 8b 40 20          	mov    0x20(%rax),%rax
ffffffff80105401:	48 89 c7             	mov    %rax,%rdi
ffffffff80105404:	e8 8a 04 00 00       	callq  ffffffff80105893 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105409:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff80105410:	80 
ffffffff80105411:	eb 4a                	jmp    ffffffff8010545d <exit+0x144>
    if(p->parent == proc){
ffffffff80105413:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105417:	48 8b 50 20          	mov    0x20(%rax),%rdx
ffffffff8010541b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105422:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105426:	48 39 c2             	cmp    %rax,%rdx
ffffffff80105429:	75 2a                	jne    ffffffff80105455 <exit+0x13c>
      p->parent = initproc;
ffffffff8010542b:	48 8b 15 36 d8 00 00 	mov    0xd836(%rip),%rdx        # ffffffff80112c68 <initproc>
ffffffff80105432:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105436:	48 89 50 20          	mov    %rdx,0x20(%rax)
      if(p->state == ZOMBIE)
ffffffff8010543a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010543e:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80105441:	83 f8 05             	cmp    $0x5,%eax
ffffffff80105444:	75 0f                	jne    ffffffff80105455 <exit+0x13c>
        wakeup1(initproc);
ffffffff80105446:	48 8b 05 1b d8 00 00 	mov    0xd81b(%rip),%rax        # ffffffff80112c68 <initproc>
ffffffff8010544d:	48 89 c7             	mov    %rax,%rdi
ffffffff80105450:	e8 3e 04 00 00       	callq  ffffffff80105893 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105455:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff8010545c:	00 
ffffffff8010545d:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff80105464:	80 
ffffffff80105465:	72 ac                	jb     ffffffff80105413 <exit+0xfa>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
ffffffff80105467:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010546e:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105472:	c7 40 18 05 00 00 00 	movl   $0x5,0x18(%rax)
  sched();
ffffffff80105479:	e8 1c 02 00 00       	callq  ffffffff8010569a <sched>
  panic("zombie exit");
ffffffff8010547e:	48 c7 c7 9a 99 10 80 	mov    $0xffffffff8010999a,%rdi
ffffffff80105485:	e8 74 b4 ff ff       	callq  ffffffff801008fe <panic>

ffffffff8010548a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
ffffffff8010548a:	55                   	push   %rbp
ffffffff8010548b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010548e:	48 83 ec 10          	sub    $0x10,%rsp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
ffffffff80105492:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105499:	e8 a4 06 00 00       	callq  ffffffff80105b42 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
ffffffff8010549e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff801054a5:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff801054ac:	80 
ffffffff801054ad:	e9 bb 00 00 00       	jmpq   ffffffff8010556d <wait+0xe3>
      if(p->parent != proc)
ffffffff801054b2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801054b6:	48 8b 50 20          	mov    0x20(%rax),%rdx
ffffffff801054ba:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801054c1:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801054c5:	48 39 c2             	cmp    %rax,%rdx
ffffffff801054c8:	0f 85 96 00 00 00    	jne    ffffffff80105564 <wait+0xda>
        continue;
      havekids = 1;
ffffffff801054ce:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%rbp)
      if(p->state == ZOMBIE){
ffffffff801054d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801054d9:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801054dc:	83 f8 05             	cmp    $0x5,%eax
ffffffff801054df:	0f 85 80 00 00 00    	jne    ffffffff80105565 <wait+0xdb>
        // Found one.
        pid = p->pid;
ffffffff801054e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801054e9:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff801054ec:	89 45 f0             	mov    %eax,-0x10(%rbp)
        kfree(p->kstack);
ffffffff801054ef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801054f3:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff801054f7:	48 89 c7             	mov    %rax,%rdi
ffffffff801054fa:	e8 e2 dc ff ff       	callq  ffffffff801031e1 <kfree>
        p->kstack = 0;
ffffffff801054ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105503:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
ffffffff8010550a:	00 
        freevm(p->pgdir);
ffffffff8010550b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010550f:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80105513:	48 89 c7             	mov    %rax,%rdi
ffffffff80105516:	e8 2a 35 00 00       	callq  ffffffff80108a45 <freevm>
        p->state = UNUSED;
ffffffff8010551b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010551f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%rax)
        p->pid = 0;
ffffffff80105526:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010552a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%rax)
        p->parent = 0;
ffffffff80105531:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105535:	48 c7 40 20 00 00 00 	movq   $0x0,0x20(%rax)
ffffffff8010553c:	00 
        p->name[0] = 0;
ffffffff8010553d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105541:	c6 80 d0 00 00 00 00 	movb   $0x0,0xd0(%rax)
        p->killed = 0;
ffffffff80105548:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010554c:	c7 40 40 00 00 00 00 	movl   $0x0,0x40(%rax)
        release(&ptable.lock);
ffffffff80105553:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010555a:	e8 ba 06 00 00       	callq  ffffffff80105c19 <release>
        return pid;
ffffffff8010555f:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff80105562:	eb 61                	jmp    ffffffff801055c5 <wait+0x13b>
        continue;
ffffffff80105564:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105565:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff8010556c:	00 
ffffffff8010556d:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff80105574:	80 
ffffffff80105575:	0f 82 37 ff ff ff    	jb     ffffffff801054b2 <wait+0x28>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
ffffffff8010557b:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
ffffffff8010557f:	74 12                	je     ffffffff80105593 <wait+0x109>
ffffffff80105581:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105588:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010558c:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff8010558f:	85 c0                	test   %eax,%eax
ffffffff80105591:	74 13                	je     ffffffff801055a6 <wait+0x11c>
      release(&ptable.lock);
ffffffff80105593:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010559a:	e8 7a 06 00 00       	callq  ffffffff80105c19 <release>
      return -1;
ffffffff8010559f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801055a4:	eb 1f                	jmp    ffffffff801055c5 <wait+0x13b>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
ffffffff801055a6:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801055ad:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801055b1:	48 c7 c6 00 f4 10 80 	mov    $0xffffffff8010f400,%rsi
ffffffff801055b8:	48 89 c7             	mov    %rax,%rdi
ffffffff801055bb:	e8 10 02 00 00       	callq  ffffffff801057d0 <sleep>
    havekids = 0;
ffffffff801055c0:	e9 d9 fe ff ff       	jmpq   ffffffff8010549e <wait+0x14>
  }
}
ffffffff801055c5:	c9                   	leaveq 
ffffffff801055c6:	c3                   	retq   

ffffffff801055c7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
ffffffff801055c7:	55                   	push   %rbp
ffffffff801055c8:	48 89 e5             	mov    %rsp,%rbp
ffffffff801055cb:	48 83 ec 10          	sub    $0x10,%rsp
  struct proc *p = 0;
ffffffff801055cf:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
ffffffff801055d6:	00 

  for(;;){
    // Enable interrupts on this processor.
    sti();
ffffffff801055d7:	e8 69 f7 ff ff       	callq  ffffffff80104d45 <sti>

    // no runnable processes? (did we hit the end of the table last time?)
    // if so, wait for irq before trying again.
    if (p == &ptable.proc[NPROC])
ffffffff801055dc:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff801055e3:	80 
ffffffff801055e4:	75 05                	jne    ffffffff801055eb <scheduler+0x24>
      hlt();
ffffffff801055e6:	e8 62 f7 ff ff       	callq  ffffffff80104d4d <hlt>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
ffffffff801055eb:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff801055f2:	e8 4b 05 00 00       	callq  ffffffff80105b42 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff801055f7:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff801055fe:	80 
ffffffff801055ff:	eb 7a                	jmp    ffffffff8010567b <scheduler+0xb4>
      if(p->state != RUNNABLE)
ffffffff80105601:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105605:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80105608:	83 f8 03             	cmp    $0x3,%eax
ffffffff8010560b:	75 65                	jne    ffffffff80105672 <scheduler+0xab>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
ffffffff8010560d:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105614:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80105618:	64 48 89 10          	mov    %rdx,%fs:(%rax)
      switchuvm(p);
ffffffff8010561c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105620:	48 89 c7             	mov    %rax,%rdi
ffffffff80105623:	e8 17 3f 00 00       	callq  ffffffff8010953f <switchuvm>
      p->state = RUNNING;
ffffffff80105628:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010562c:	c7 40 18 04 00 00 00 	movl   $0x4,0x18(%rax)
      swtch(&cpu->scheduler, proc->context);
ffffffff80105633:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010563a:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010563e:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80105642:	48 c7 c2 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rdx
ffffffff80105649:	64 48 8b 12          	mov    %fs:(%rdx),%rdx
ffffffff8010564d:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80105651:	48 89 c6             	mov    %rax,%rsi
ffffffff80105654:	48 89 d7             	mov    %rdx,%rdi
ffffffff80105657:	e8 84 0b 00 00       	callq  ffffffff801061e0 <swtch>
      switchkvm();
ffffffff8010565c:	e8 c0 3e 00 00       	callq  ffffffff80109521 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
ffffffff80105661:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105668:	64 48 c7 00 00 00 00 	movq   $0x0,%fs:(%rax)
ffffffff8010566f:	00 
ffffffff80105670:	eb 01                	jmp    ffffffff80105673 <scheduler+0xac>
        continue;
ffffffff80105672:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105673:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff8010567a:	00 
ffffffff8010567b:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff80105682:	80 
ffffffff80105683:	0f 82 78 ff ff ff    	jb     ffffffff80105601 <scheduler+0x3a>
    }
    release(&ptable.lock);
ffffffff80105689:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105690:	e8 84 05 00 00       	callq  ffffffff80105c19 <release>
    sti();
ffffffff80105695:	e9 3d ff ff ff       	jmpq   ffffffff801055d7 <scheduler+0x10>

ffffffff8010569a <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
ffffffff8010569a:	55                   	push   %rbp
ffffffff8010569b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010569e:	48 83 ec 10          	sub    $0x10,%rsp
  int intena;

  if(!holding(&ptable.lock))
ffffffff801056a2:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff801056a9:	e8 8a 06 00 00       	callq  ffffffff80105d38 <holding>
ffffffff801056ae:	85 c0                	test   %eax,%eax
ffffffff801056b0:	75 0c                	jne    ffffffff801056be <sched+0x24>
    panic("sched ptable.lock");
ffffffff801056b2:	48 c7 c7 a6 99 10 80 	mov    $0xffffffff801099a6,%rdi
ffffffff801056b9:	e8 40 b2 ff ff       	callq  ffffffff801008fe <panic>
  if(cpu->ncli != 1)
ffffffff801056be:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff801056c5:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801056c9:	8b 80 dc 00 00 00    	mov    0xdc(%rax),%eax
ffffffff801056cf:	83 f8 01             	cmp    $0x1,%eax
ffffffff801056d2:	74 0c                	je     ffffffff801056e0 <sched+0x46>
    panic("sched locks");
ffffffff801056d4:	48 c7 c7 b8 99 10 80 	mov    $0xffffffff801099b8,%rdi
ffffffff801056db:	e8 1e b2 ff ff       	callq  ffffffff801008fe <panic>
  if(proc->state == RUNNING)
ffffffff801056e0:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801056e7:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801056eb:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801056ee:	83 f8 04             	cmp    $0x4,%eax
ffffffff801056f1:	75 0c                	jne    ffffffff801056ff <sched+0x65>
    panic("sched running");
ffffffff801056f3:	48 c7 c7 c4 99 10 80 	mov    $0xffffffff801099c4,%rdi
ffffffff801056fa:	e8 ff b1 ff ff       	callq  ffffffff801008fe <panic>
  if(readeflags()&FL_IF)
ffffffff801056ff:	e8 2d f6 ff ff       	callq  ffffffff80104d31 <readeflags>
ffffffff80105704:	25 00 02 00 00       	and    $0x200,%eax
ffffffff80105709:	48 85 c0             	test   %rax,%rax
ffffffff8010570c:	74 0c                	je     ffffffff8010571a <sched+0x80>
    panic("sched interruptible");
ffffffff8010570e:	48 c7 c7 d2 99 10 80 	mov    $0xffffffff801099d2,%rdi
ffffffff80105715:	e8 e4 b1 ff ff       	callq  ffffffff801008fe <panic>
  intena = cpu->intena;
ffffffff8010571a:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105721:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105725:	8b 80 e0 00 00 00    	mov    0xe0(%rax),%eax
ffffffff8010572b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  swtch(&proc->context, cpu->scheduler);
ffffffff8010572e:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105735:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105739:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff8010573d:	48 c7 c2 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rdx
ffffffff80105744:	64 48 8b 12          	mov    %fs:(%rdx),%rdx
ffffffff80105748:	48 83 c2 30          	add    $0x30,%rdx
ffffffff8010574c:	48 89 c6             	mov    %rax,%rsi
ffffffff8010574f:	48 89 d7             	mov    %rdx,%rdi
ffffffff80105752:	e8 89 0a 00 00       	callq  ffffffff801061e0 <swtch>
  cpu->intena = intena;
ffffffff80105757:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff8010575e:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105762:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80105765:	89 90 e0 00 00 00    	mov    %edx,0xe0(%rax)
}
ffffffff8010576b:	90                   	nop
ffffffff8010576c:	c9                   	leaveq 
ffffffff8010576d:	c3                   	retq   

ffffffff8010576e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
ffffffff8010576e:	55                   	push   %rbp
ffffffff8010576f:	48 89 e5             	mov    %rsp,%rbp
  acquire(&ptable.lock);  //DOC: yieldlock
ffffffff80105772:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105779:	e8 c4 03 00 00       	callq  ffffffff80105b42 <acquire>
  proc->state = RUNNABLE;
ffffffff8010577e:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105785:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105789:	c7 40 18 03 00 00 00 	movl   $0x3,0x18(%rax)
  sched();
ffffffff80105790:	e8 05 ff ff ff       	callq  ffffffff8010569a <sched>
  release(&ptable.lock);
ffffffff80105795:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010579c:	e8 78 04 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff801057a1:	90                   	nop
ffffffff801057a2:	5d                   	pop    %rbp
ffffffff801057a3:	c3                   	retq   

ffffffff801057a4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
ffffffff801057a4:	55                   	push   %rbp
ffffffff801057a5:	48 89 e5             	mov    %rsp,%rbp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
ffffffff801057a8:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff801057af:	e8 65 04 00 00       	callq  ffffffff80105c19 <release>

  if (first) {
ffffffff801057b4:	8b 05 aa 4d 00 00    	mov    0x4daa(%rip),%eax        # ffffffff8010a564 <first.1944>
ffffffff801057ba:	85 c0                	test   %eax,%eax
ffffffff801057bc:	74 0f                	je     ffffffff801057cd <forkret+0x29>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
ffffffff801057be:	c7 05 9c 4d 00 00 00 	movl   $0x0,0x4d9c(%rip)        # ffffffff8010a564 <first.1944>
ffffffff801057c5:	00 00 00 
    initlog();
ffffffff801057c8:	e8 ef df ff ff       	callq  ffffffff801037bc <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
ffffffff801057cd:	90                   	nop
ffffffff801057ce:	5d                   	pop    %rbp
ffffffff801057cf:	c3                   	retq   

ffffffff801057d0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
ffffffff801057d0:	55                   	push   %rbp
ffffffff801057d1:	48 89 e5             	mov    %rsp,%rbp
ffffffff801057d4:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801057d8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff801057dc:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(proc == 0)
ffffffff801057e0:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801057e7:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801057eb:	48 85 c0             	test   %rax,%rax
ffffffff801057ee:	75 0c                	jne    ffffffff801057fc <sleep+0x2c>
    panic("sleep");
ffffffff801057f0:	48 c7 c7 e6 99 10 80 	mov    $0xffffffff801099e6,%rdi
ffffffff801057f7:	e8 02 b1 ff ff       	callq  ffffffff801008fe <panic>

  if(lk == 0)
ffffffff801057fc:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80105801:	75 0c                	jne    ffffffff8010580f <sleep+0x3f>
    panic("sleep without lk");
ffffffff80105803:	48 c7 c7 ec 99 10 80 	mov    $0xffffffff801099ec,%rdi
ffffffff8010580a:	e8 ef b0 ff ff       	callq  ffffffff801008fe <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
ffffffff8010580f:	48 81 7d f0 00 f4 10 	cmpq   $0xffffffff8010f400,-0x10(%rbp)
ffffffff80105816:	80 
ffffffff80105817:	74 18                	je     ffffffff80105831 <sleep+0x61>
    acquire(&ptable.lock);  //DOC: sleeplock1
ffffffff80105819:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105820:	e8 1d 03 00 00       	callq  ffffffff80105b42 <acquire>
    release(lk);
ffffffff80105825:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105829:	48 89 c7             	mov    %rax,%rdi
ffffffff8010582c:	e8 e8 03 00 00       	callq  ffffffff80105c19 <release>
  }

  // Go to sleep.
  proc->chan = chan;
ffffffff80105831:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105838:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010583c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80105840:	48 89 50 38          	mov    %rdx,0x38(%rax)
  proc->state = SLEEPING;
ffffffff80105844:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010584b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010584f:	c7 40 18 02 00 00 00 	movl   $0x2,0x18(%rax)
  sched();
ffffffff80105856:	e8 3f fe ff ff       	callq  ffffffff8010569a <sched>

  // Tidy up.
  proc->chan = 0;
ffffffff8010585b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80105862:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105866:	48 c7 40 38 00 00 00 	movq   $0x0,0x38(%rax)
ffffffff8010586d:	00 

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
ffffffff8010586e:	48 81 7d f0 00 f4 10 	cmpq   $0xffffffff8010f400,-0x10(%rbp)
ffffffff80105875:	80 
ffffffff80105876:	74 18                	je     ffffffff80105890 <sleep+0xc0>
    release(&ptable.lock);
ffffffff80105878:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010587f:	e8 95 03 00 00       	callq  ffffffff80105c19 <release>
    acquire(lk);
ffffffff80105884:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105888:	48 89 c7             	mov    %rax,%rdi
ffffffff8010588b:	e8 b2 02 00 00       	callq  ffffffff80105b42 <acquire>
  }
}
ffffffff80105890:	90                   	nop
ffffffff80105891:	c9                   	leaveq 
ffffffff80105892:	c3                   	retq   

ffffffff80105893 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
ffffffff80105893:	55                   	push   %rbp
ffffffff80105894:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105897:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff8010589b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
ffffffff8010589f:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff801058a6:	80 
ffffffff801058a7:	eb 2d                	jmp    ffffffff801058d6 <wakeup1+0x43>
    if(p->state == SLEEPING && p->chan == chan)
ffffffff801058a9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801058ad:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801058b0:	83 f8 02             	cmp    $0x2,%eax
ffffffff801058b3:	75 19                	jne    ffffffff801058ce <wakeup1+0x3b>
ffffffff801058b5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801058b9:	48 8b 40 38          	mov    0x38(%rax),%rax
ffffffff801058bd:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff801058c1:	75 0b                	jne    ffffffff801058ce <wakeup1+0x3b>
      p->state = RUNNABLE;
ffffffff801058c3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801058c7:	c7 40 18 03 00 00 00 	movl   $0x3,0x18(%rax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
ffffffff801058ce:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff801058d5:	00 
ffffffff801058d6:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff801058dd:	80 
ffffffff801058de:	72 c9                	jb     ffffffff801058a9 <wakeup1+0x16>
}
ffffffff801058e0:	90                   	nop
ffffffff801058e1:	c9                   	leaveq 
ffffffff801058e2:	c3                   	retq   

ffffffff801058e3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
ffffffff801058e3:	55                   	push   %rbp
ffffffff801058e4:	48 89 e5             	mov    %rsp,%rbp
ffffffff801058e7:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801058eb:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  acquire(&ptable.lock);
ffffffff801058ef:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff801058f6:	e8 47 02 00 00       	callq  ffffffff80105b42 <acquire>
  wakeup1(chan);
ffffffff801058fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801058ff:	48 89 c7             	mov    %rax,%rdi
ffffffff80105902:	e8 8c ff ff ff       	callq  ffffffff80105893 <wakeup1>
  release(&ptable.lock);
ffffffff80105907:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010590e:	e8 06 03 00 00       	callq  ffffffff80105c19 <release>
}
ffffffff80105913:	90                   	nop
ffffffff80105914:	c9                   	leaveq 
ffffffff80105915:	c3                   	retq   

ffffffff80105916 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
ffffffff80105916:	55                   	push   %rbp
ffffffff80105917:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010591a:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff8010591e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  struct proc *p;

  acquire(&ptable.lock);
ffffffff80105921:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105928:	e8 15 02 00 00       	callq  ffffffff80105b42 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff8010592d:	48 c7 45 f8 68 f4 10 	movq   $0xffffffff8010f468,-0x8(%rbp)
ffffffff80105934:	80 
ffffffff80105935:	eb 49                	jmp    ffffffff80105980 <kill+0x6a>
    if(p->pid == pid){
ffffffff80105937:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010593b:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff8010593e:	39 45 ec             	cmp    %eax,-0x14(%rbp)
ffffffff80105941:	75 35                	jne    ffffffff80105978 <kill+0x62>
      p->killed = 1;
ffffffff80105943:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105947:	c7 40 40 01 00 00 00 	movl   $0x1,0x40(%rax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
ffffffff8010594e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105952:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80105955:	83 f8 02             	cmp    $0x2,%eax
ffffffff80105958:	75 0b                	jne    ffffffff80105965 <kill+0x4f>
        p->state = RUNNABLE;
ffffffff8010595a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010595e:	c7 40 18 03 00 00 00 	movl   $0x3,0x18(%rax)
      release(&ptable.lock);
ffffffff80105965:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff8010596c:	e8 a8 02 00 00       	callq  ffffffff80105c19 <release>
      return 0;
ffffffff80105971:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105976:	eb 23                	jmp    ffffffff8010599b <kill+0x85>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105978:	48 81 45 f8 e0 00 00 	addq   $0xe0,-0x8(%rbp)
ffffffff8010597f:	00 
ffffffff80105980:	48 81 7d f8 68 2c 11 	cmpq   $0xffffffff80112c68,-0x8(%rbp)
ffffffff80105987:	80 
ffffffff80105988:	72 ad                	jb     ffffffff80105937 <kill+0x21>
    }
  }
  release(&ptable.lock);
ffffffff8010598a:	48 c7 c7 00 f4 10 80 	mov    $0xffffffff8010f400,%rdi
ffffffff80105991:	e8 83 02 00 00       	callq  ffffffff80105c19 <release>
  return -1;
ffffffff80105996:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff8010599b:	c9                   	leaveq 
ffffffff8010599c:	c3                   	retq   

ffffffff8010599d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
ffffffff8010599d:	55                   	push   %rbp
ffffffff8010599e:	48 89 e5             	mov    %rsp,%rbp
ffffffff801059a1:	48 83 ec 70          	sub    $0x70,%rsp
  int i;
  struct proc *p;
  char *state;
  uintp pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff801059a5:	48 c7 45 f0 68 f4 10 	movq   $0xffffffff8010f468,-0x10(%rbp)
ffffffff801059ac:	80 
ffffffff801059ad:	e9 ff 00 00 00       	jmpq   ffffffff80105ab1 <procdump+0x114>
    if(p->state == UNUSED)
ffffffff801059b2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801059b6:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801059b9:	85 c0                	test   %eax,%eax
ffffffff801059bb:	0f 84 e7 00 00 00    	je     ffffffff80105aa8 <procdump+0x10b>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
ffffffff801059c1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801059c5:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801059c8:	83 f8 05             	cmp    $0x5,%eax
ffffffff801059cb:	77 2d                	ja     ffffffff801059fa <procdump+0x5d>
ffffffff801059cd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801059d1:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801059d4:	89 c0                	mov    %eax,%eax
ffffffff801059d6:	48 8b 04 c5 80 a5 10 	mov    -0x7fef5a80(,%rax,8),%rax
ffffffff801059dd:	80 
ffffffff801059de:	48 85 c0             	test   %rax,%rax
ffffffff801059e1:	74 17                	je     ffffffff801059fa <procdump+0x5d>
      state = states[p->state];
ffffffff801059e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801059e7:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff801059ea:	89 c0                	mov    %eax,%eax
ffffffff801059ec:	48 8b 04 c5 80 a5 10 	mov    -0x7fef5a80(,%rax,8),%rax
ffffffff801059f3:	80 
ffffffff801059f4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff801059f8:	eb 08                	jmp    ffffffff80105a02 <procdump+0x65>
    else
      state = "???";
ffffffff801059fa:	48 c7 45 e8 fd 99 10 	movq   $0xffffffff801099fd,-0x18(%rbp)
ffffffff80105a01:	80 
    cprintf("%d %s %s", p->pid, state, p->name);
ffffffff80105a02:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105a06:	48 8d 88 d0 00 00 00 	lea    0xd0(%rax),%rcx
ffffffff80105a0d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105a11:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff80105a14:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80105a18:	89 c6                	mov    %eax,%esi
ffffffff80105a1a:	48 c7 c7 01 9a 10 80 	mov    $0xffffffff80109a01,%rdi
ffffffff80105a21:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105a26:	e8 76 ab ff ff       	callq  ffffffff801005a1 <cprintf>
    if(p->state == SLEEPING){
ffffffff80105a2b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105a2f:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80105a32:	83 f8 02             	cmp    $0x2,%eax
ffffffff80105a35:	75 5e                	jne    ffffffff80105a95 <procdump+0xf8>
      getstackpcs((uintp*)p->context->ebp, pc);
ffffffff80105a37:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105a3b:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80105a3f:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80105a43:	48 89 c2             	mov    %rax,%rdx
ffffffff80105a46:	48 8d 45 90          	lea    -0x70(%rbp),%rax
ffffffff80105a4a:	48 89 c6             	mov    %rax,%rsi
ffffffff80105a4d:	48 89 d7             	mov    %rdx,%rdi
ffffffff80105a50:	e8 4a 02 00 00       	callq  ffffffff80105c9f <getstackpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
ffffffff80105a55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80105a5c:	eb 22                	jmp    ffffffff80105a80 <procdump+0xe3>
        cprintf(" %p", pc[i]);
ffffffff80105a5e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80105a61:	48 98                	cltq   
ffffffff80105a63:	48 8b 44 c5 90       	mov    -0x70(%rbp,%rax,8),%rax
ffffffff80105a68:	48 89 c6             	mov    %rax,%rsi
ffffffff80105a6b:	48 c7 c7 0a 9a 10 80 	mov    $0xffffffff80109a0a,%rdi
ffffffff80105a72:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105a77:	e8 25 ab ff ff       	callq  ffffffff801005a1 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
ffffffff80105a7c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80105a80:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
ffffffff80105a84:	7f 0f                	jg     ffffffff80105a95 <procdump+0xf8>
ffffffff80105a86:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80105a89:	48 98                	cltq   
ffffffff80105a8b:	48 8b 44 c5 90       	mov    -0x70(%rbp,%rax,8),%rax
ffffffff80105a90:	48 85 c0             	test   %rax,%rax
ffffffff80105a93:	75 c9                	jne    ffffffff80105a5e <procdump+0xc1>
    }
    cprintf("\n");
ffffffff80105a95:	48 c7 c7 0e 9a 10 80 	mov    $0xffffffff80109a0e,%rdi
ffffffff80105a9c:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105aa1:	e8 fb aa ff ff       	callq  ffffffff801005a1 <cprintf>
ffffffff80105aa6:	eb 01                	jmp    ffffffff80105aa9 <procdump+0x10c>
      continue;
ffffffff80105aa8:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
ffffffff80105aa9:	48 81 45 f0 e0 00 00 	addq   $0xe0,-0x10(%rbp)
ffffffff80105ab0:	00 
ffffffff80105ab1:	48 81 7d f0 68 2c 11 	cmpq   $0xffffffff80112c68,-0x10(%rbp)
ffffffff80105ab8:	80 
ffffffff80105ab9:	0f 82 f3 fe ff ff    	jb     ffffffff801059b2 <procdump+0x15>
  }
}
ffffffff80105abf:	90                   	nop
ffffffff80105ac0:	c9                   	leaveq 
ffffffff80105ac1:	c3                   	retq   

ffffffff80105ac2 <readeflags>:
{
ffffffff80105ac2:	55                   	push   %rbp
ffffffff80105ac3:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105ac6:	48 83 ec 10          	sub    $0x10,%rsp
  asm volatile("pushf; pop %0" : "=r" (eflags));
ffffffff80105aca:	9c                   	pushfq 
ffffffff80105acb:	58                   	pop    %rax
ffffffff80105acc:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  return eflags;
ffffffff80105ad0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80105ad4:	c9                   	leaveq 
ffffffff80105ad5:	c3                   	retq   

ffffffff80105ad6 <cli>:
{
ffffffff80105ad6:	55                   	push   %rbp
ffffffff80105ad7:	48 89 e5             	mov    %rsp,%rbp
  asm volatile("cli");
ffffffff80105ada:	fa                   	cli    
}
ffffffff80105adb:	90                   	nop
ffffffff80105adc:	5d                   	pop    %rbp
ffffffff80105add:	c3                   	retq   

ffffffff80105ade <sti>:
{
ffffffff80105ade:	55                   	push   %rbp
ffffffff80105adf:	48 89 e5             	mov    %rsp,%rbp
  asm volatile("sti");
ffffffff80105ae2:	fb                   	sti    
}
ffffffff80105ae3:	90                   	nop
ffffffff80105ae4:	5d                   	pop    %rbp
ffffffff80105ae5:	c3                   	retq   

ffffffff80105ae6 <xchg>:
{
ffffffff80105ae6:	55                   	push   %rbp
ffffffff80105ae7:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105aea:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80105aee:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80105af2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  asm volatile("lock; xchgl %0, %1" :
ffffffff80105af6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80105afa:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105afe:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
ffffffff80105b02:	f0 87 02             	lock xchg %eax,(%rdx)
ffffffff80105b05:	89 45 fc             	mov    %eax,-0x4(%rbp)
  return result;
ffffffff80105b08:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff80105b0b:	c9                   	leaveq 
ffffffff80105b0c:	c3                   	retq   

ffffffff80105b0d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
ffffffff80105b0d:	55                   	push   %rbp
ffffffff80105b0e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105b11:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80105b15:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80105b19:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  lk->name = name;
ffffffff80105b1d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105b21:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80105b25:	48 89 50 08          	mov    %rdx,0x8(%rax)
  lk->locked = 0;
ffffffff80105b29:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105b2d:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  lk->cpu = 0;
ffffffff80105b33:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105b37:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
ffffffff80105b3e:	00 
}
ffffffff80105b3f:	90                   	nop
ffffffff80105b40:	c9                   	leaveq 
ffffffff80105b41:	c3                   	retq   

ffffffff80105b42 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
ffffffff80105b42:	55                   	push   %rbp
ffffffff80105b43:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105b46:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80105b4a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  pushcli(); // disable interrupts to avoid deadlock.
ffffffff80105b4e:	e8 21 02 00 00       	callq  ffffffff80105d74 <pushcli>
  if(holding(lk)) {
ffffffff80105b53:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105b57:	48 89 c7             	mov    %rax,%rdi
ffffffff80105b5a:	e8 d9 01 00 00       	callq  ffffffff80105d38 <holding>
ffffffff80105b5f:	85 c0                	test   %eax,%eax
ffffffff80105b61:	74 73                	je     ffffffff80105bd6 <acquire+0x94>
    int i;
    cprintf("lock '%s':\n", lk->name);
ffffffff80105b63:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105b67:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80105b6b:	48 89 c6             	mov    %rax,%rsi
ffffffff80105b6e:	48 c7 c7 3a 9a 10 80 	mov    $0xffffffff80109a3a,%rdi
ffffffff80105b75:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105b7a:	e8 22 aa ff ff       	callq  ffffffff801005a1 <cprintf>
    for (i = 0; i < 10; i++)
ffffffff80105b7f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80105b86:	eb 2b                	jmp    ffffffff80105bb3 <acquire+0x71>
      cprintf(" %p", lk->pcs[i]);
ffffffff80105b88:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105b8c:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80105b8f:	48 63 d2             	movslq %edx,%rdx
ffffffff80105b92:	48 83 c2 02          	add    $0x2,%rdx
ffffffff80105b96:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff80105b9b:	48 89 c6             	mov    %rax,%rsi
ffffffff80105b9e:	48 c7 c7 46 9a 10 80 	mov    $0xffffffff80109a46,%rdi
ffffffff80105ba5:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105baa:	e8 f2 a9 ff ff       	callq  ffffffff801005a1 <cprintf>
    for (i = 0; i < 10; i++)
ffffffff80105baf:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80105bb3:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
ffffffff80105bb7:	7e cf                	jle    ffffffff80105b88 <acquire+0x46>
    cprintf("\n");
ffffffff80105bb9:	48 c7 c7 4a 9a 10 80 	mov    $0xffffffff80109a4a,%rdi
ffffffff80105bc0:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80105bc5:	e8 d7 a9 ff ff       	callq  ffffffff801005a1 <cprintf>
    panic("acquire");
ffffffff80105bca:	48 c7 c7 4c 9a 10 80 	mov    $0xffffffff80109a4c,%rdi
ffffffff80105bd1:	e8 28 ad ff ff       	callq  ffffffff801008fe <panic>
  }

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
ffffffff80105bd6:	90                   	nop
ffffffff80105bd7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105bdb:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80105be0:	48 89 c7             	mov    %rax,%rdi
ffffffff80105be3:	e8 fe fe ff ff       	callq  ffffffff80105ae6 <xchg>
ffffffff80105be8:	85 c0                	test   %eax,%eax
ffffffff80105bea:	75 eb                	jne    ffffffff80105bd7 <acquire+0x95>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
ffffffff80105bec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105bf0:	48 c7 c2 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rdx
ffffffff80105bf7:	64 48 8b 12          	mov    %fs:(%rdx),%rdx
ffffffff80105bfb:	48 89 50 10          	mov    %rdx,0x10(%rax)
  getcallerpcs(&lk, lk->pcs);
ffffffff80105bff:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105c03:	48 8d 50 18          	lea    0x18(%rax),%rdx
ffffffff80105c07:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
ffffffff80105c0b:	48 89 d6             	mov    %rdx,%rsi
ffffffff80105c0e:	48 89 c7             	mov    %rax,%rdi
ffffffff80105c11:	e8 5c 00 00 00       	callq  ffffffff80105c72 <getcallerpcs>
}
ffffffff80105c16:	90                   	nop
ffffffff80105c17:	c9                   	leaveq 
ffffffff80105c18:	c3                   	retq   

ffffffff80105c19 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
ffffffff80105c19:	55                   	push   %rbp
ffffffff80105c1a:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105c1d:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80105c21:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if(!holding(lk))
ffffffff80105c25:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105c29:	48 89 c7             	mov    %rax,%rdi
ffffffff80105c2c:	e8 07 01 00 00       	callq  ffffffff80105d38 <holding>
ffffffff80105c31:	85 c0                	test   %eax,%eax
ffffffff80105c33:	75 0c                	jne    ffffffff80105c41 <release+0x28>
    panic("release");
ffffffff80105c35:	48 c7 c7 54 9a 10 80 	mov    $0xffffffff80109a54,%rdi
ffffffff80105c3c:	e8 bd ac ff ff       	callq  ffffffff801008fe <panic>

  lk->pcs[0] = 0;
ffffffff80105c41:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105c45:	48 c7 40 18 00 00 00 	movq   $0x0,0x18(%rax)
ffffffff80105c4c:	00 
  lk->cpu = 0;
ffffffff80105c4d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105c51:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
ffffffff80105c58:	00 
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
ffffffff80105c59:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105c5d:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80105c62:	48 89 c7             	mov    %rax,%rdi
ffffffff80105c65:	e8 7c fe ff ff       	callq  ffffffff80105ae6 <xchg>

  popcli();
ffffffff80105c6a:	e8 55 01 00 00       	callq  ffffffff80105dc4 <popcli>
}
ffffffff80105c6f:	90                   	nop
ffffffff80105c70:	c9                   	leaveq 
ffffffff80105c71:	c3                   	retq   

ffffffff80105c72 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uintp pcs[])
{
ffffffff80105c72:	55                   	push   %rbp
ffffffff80105c73:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105c76:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80105c7a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80105c7e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  uintp *ebp;
#if X64
  asm volatile("mov %%rbp, %0" : "=r" (ebp));  
ffffffff80105c82:	48 89 e8             	mov    %rbp,%rax
ffffffff80105c85:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
#else
  ebp = (uintp*)v - 2;
#endif
  getstackpcs(ebp, pcs);
ffffffff80105c89:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff80105c8d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105c91:	48 89 d6             	mov    %rdx,%rsi
ffffffff80105c94:	48 89 c7             	mov    %rax,%rdi
ffffffff80105c97:	e8 03 00 00 00       	callq  ffffffff80105c9f <getstackpcs>
}
ffffffff80105c9c:	90                   	nop
ffffffff80105c9d:	c9                   	leaveq 
ffffffff80105c9e:	c3                   	retq   

ffffffff80105c9f <getstackpcs>:

void
getstackpcs(uintp *ebp, uintp pcs[])
{
ffffffff80105c9f:	55                   	push   %rbp
ffffffff80105ca0:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105ca3:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80105ca7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80105cab:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int i;
  
  for(i = 0; i < 10; i++){
ffffffff80105caf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80105cb6:	eb 50                	jmp    ffffffff80105d08 <getstackpcs+0x69>
    if(ebp == 0 || ebp < (uintp*)KERNBASE || ebp == (uintp*)0xffffffff)
ffffffff80105cb8:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff80105cbd:	74 70                	je     ffffffff80105d2f <getstackpcs+0x90>
ffffffff80105cbf:	48 b8 ff ff ff 7f ff 	movabs $0xffffffff7fffffff,%rax
ffffffff80105cc6:	ff ff ff 
ffffffff80105cc9:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff80105ccd:	76 60                	jbe    ffffffff80105d2f <getstackpcs+0x90>
ffffffff80105ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80105cd4:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff80105cd8:	74 55                	je     ffffffff80105d2f <getstackpcs+0x90>
      break;
    pcs[i] = ebp[1];     // saved %eip
ffffffff80105cda:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80105cdd:	48 98                	cltq   
ffffffff80105cdf:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80105ce6:	00 
ffffffff80105ce7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105ceb:	48 01 c2             	add    %rax,%rdx
ffffffff80105cee:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105cf2:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80105cf6:	48 89 02             	mov    %rax,(%rdx)
    ebp = (uintp*)ebp[0]; // saved %ebp
ffffffff80105cf9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105cfd:	48 8b 00             	mov    (%rax),%rax
ffffffff80105d00:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  for(i = 0; i < 10; i++){
ffffffff80105d04:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80105d08:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
ffffffff80105d0c:	7e aa                	jle    ffffffff80105cb8 <getstackpcs+0x19>
  }
  for(; i < 10; i++)
ffffffff80105d0e:	eb 1f                	jmp    ffffffff80105d2f <getstackpcs+0x90>
    pcs[i] = 0;
ffffffff80105d10:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80105d13:	48 98                	cltq   
ffffffff80105d15:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80105d1c:	00 
ffffffff80105d1d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105d21:	48 01 d0             	add    %rdx,%rax
ffffffff80105d24:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for(; i < 10; i++)
ffffffff80105d2b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80105d2f:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
ffffffff80105d33:	7e db                	jle    ffffffff80105d10 <getstackpcs+0x71>
}
ffffffff80105d35:	90                   	nop
ffffffff80105d36:	c9                   	leaveq 
ffffffff80105d37:	c3                   	retq   

ffffffff80105d38 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
ffffffff80105d38:	55                   	push   %rbp
ffffffff80105d39:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105d3c:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80105d40:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  return lock->locked && lock->cpu == cpu;
ffffffff80105d44:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105d48:	8b 00                	mov    (%rax),%eax
ffffffff80105d4a:	85 c0                	test   %eax,%eax
ffffffff80105d4c:	74 1f                	je     ffffffff80105d6d <holding+0x35>
ffffffff80105d4e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105d52:	48 8b 50 10          	mov    0x10(%rax),%rdx
ffffffff80105d56:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105d5d:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105d61:	48 39 c2             	cmp    %rax,%rdx
ffffffff80105d64:	75 07                	jne    ffffffff80105d6d <holding+0x35>
ffffffff80105d66:	b8 01 00 00 00       	mov    $0x1,%eax
ffffffff80105d6b:	eb 05                	jmp    ffffffff80105d72 <holding+0x3a>
ffffffff80105d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80105d72:	c9                   	leaveq 
ffffffff80105d73:	c3                   	retq   

ffffffff80105d74 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
ffffffff80105d74:	55                   	push   %rbp
ffffffff80105d75:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105d78:	48 83 ec 10          	sub    $0x10,%rsp
  int eflags;
  
  eflags = readeflags();
ffffffff80105d7c:	e8 41 fd ff ff       	callq  ffffffff80105ac2 <readeflags>
ffffffff80105d81:	89 45 fc             	mov    %eax,-0x4(%rbp)
  cli();
ffffffff80105d84:	e8 4d fd ff ff       	callq  ffffffff80105ad6 <cli>
  if(cpu->ncli++ == 0)
ffffffff80105d89:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105d90:	64 48 8b 10          	mov    %fs:(%rax),%rdx
ffffffff80105d94:	8b 82 dc 00 00 00    	mov    0xdc(%rdx),%eax
ffffffff80105d9a:	8d 48 01             	lea    0x1(%rax),%ecx
ffffffff80105d9d:	89 8a dc 00 00 00    	mov    %ecx,0xdc(%rdx)
ffffffff80105da3:	85 c0                	test   %eax,%eax
ffffffff80105da5:	75 1a                	jne    ffffffff80105dc1 <pushcli+0x4d>
    cpu->intena = eflags & FL_IF;
ffffffff80105da7:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105dae:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105db2:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80105db5:	81 e2 00 02 00 00    	and    $0x200,%edx
ffffffff80105dbb:	89 90 e0 00 00 00    	mov    %edx,0xe0(%rax)
}
ffffffff80105dc1:	90                   	nop
ffffffff80105dc2:	c9                   	leaveq 
ffffffff80105dc3:	c3                   	retq   

ffffffff80105dc4 <popcli>:

void
popcli(void)
{
ffffffff80105dc4:	55                   	push   %rbp
ffffffff80105dc5:	48 89 e5             	mov    %rsp,%rbp
  if(readeflags()&FL_IF)
ffffffff80105dc8:	e8 f5 fc ff ff       	callq  ffffffff80105ac2 <readeflags>
ffffffff80105dcd:	25 00 02 00 00       	and    $0x200,%eax
ffffffff80105dd2:	48 85 c0             	test   %rax,%rax
ffffffff80105dd5:	74 0c                	je     ffffffff80105de3 <popcli+0x1f>
    panic("popcli - interruptible");
ffffffff80105dd7:	48 c7 c7 5c 9a 10 80 	mov    $0xffffffff80109a5c,%rdi
ffffffff80105dde:	e8 1b ab ff ff       	callq  ffffffff801008fe <panic>
  if(--cpu->ncli < 0)
ffffffff80105de3:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105dea:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105dee:	8b 90 dc 00 00 00    	mov    0xdc(%rax),%edx
ffffffff80105df4:	83 ea 01             	sub    $0x1,%edx
ffffffff80105df7:	89 90 dc 00 00 00    	mov    %edx,0xdc(%rax)
ffffffff80105dfd:	8b 80 dc 00 00 00    	mov    0xdc(%rax),%eax
ffffffff80105e03:	85 c0                	test   %eax,%eax
ffffffff80105e05:	79 0c                	jns    ffffffff80105e13 <popcli+0x4f>
    panic("popcli");
ffffffff80105e07:	48 c7 c7 73 9a 10 80 	mov    $0xffffffff80109a73,%rdi
ffffffff80105e0e:	e8 eb aa ff ff       	callq  ffffffff801008fe <panic>
  if(cpu->ncli == 0 && cpu->intena)
ffffffff80105e13:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105e1a:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105e1e:	8b 80 dc 00 00 00    	mov    0xdc(%rax),%eax
ffffffff80105e24:	85 c0                	test   %eax,%eax
ffffffff80105e26:	75 1a                	jne    ffffffff80105e42 <popcli+0x7e>
ffffffff80105e28:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80105e2f:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80105e33:	8b 80 e0 00 00 00    	mov    0xe0(%rax),%eax
ffffffff80105e39:	85 c0                	test   %eax,%eax
ffffffff80105e3b:	74 05                	je     ffffffff80105e42 <popcli+0x7e>
    sti();
ffffffff80105e3d:	e8 9c fc ff ff       	callq  ffffffff80105ade <sti>
}
ffffffff80105e42:	90                   	nop
ffffffff80105e43:	5d                   	pop    %rbp
ffffffff80105e44:	c3                   	retq   

ffffffff80105e45 <stosb>:
{
ffffffff80105e45:	55                   	push   %rbp
ffffffff80105e46:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105e49:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80105e4d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80105e51:	89 75 f4             	mov    %esi,-0xc(%rbp)
ffffffff80105e54:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
ffffffff80105e57:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff80105e5b:	8b 55 f0             	mov    -0x10(%rbp),%edx
ffffffff80105e5e:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80105e61:	48 89 ce             	mov    %rcx,%rsi
ffffffff80105e64:	48 89 f7             	mov    %rsi,%rdi
ffffffff80105e67:	89 d1                	mov    %edx,%ecx
ffffffff80105e69:	fc                   	cld    
ffffffff80105e6a:	f3 aa                	rep stos %al,%es:(%rdi)
ffffffff80105e6c:	89 ca                	mov    %ecx,%edx
ffffffff80105e6e:	48 89 fe             	mov    %rdi,%rsi
ffffffff80105e71:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
ffffffff80105e75:	89 55 f0             	mov    %edx,-0x10(%rbp)
}
ffffffff80105e78:	90                   	nop
ffffffff80105e79:	c9                   	leaveq 
ffffffff80105e7a:	c3                   	retq   

ffffffff80105e7b <stosl>:
{
ffffffff80105e7b:	55                   	push   %rbp
ffffffff80105e7c:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105e7f:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80105e83:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80105e87:	89 75 f4             	mov    %esi,-0xc(%rbp)
ffffffff80105e8a:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosl" :
ffffffff80105e8d:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff80105e91:	8b 55 f0             	mov    -0x10(%rbp),%edx
ffffffff80105e94:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80105e97:	48 89 ce             	mov    %rcx,%rsi
ffffffff80105e9a:	48 89 f7             	mov    %rsi,%rdi
ffffffff80105e9d:	89 d1                	mov    %edx,%ecx
ffffffff80105e9f:	fc                   	cld    
ffffffff80105ea0:	f3 ab                	rep stos %eax,%es:(%rdi)
ffffffff80105ea2:	89 ca                	mov    %ecx,%edx
ffffffff80105ea4:	48 89 fe             	mov    %rdi,%rsi
ffffffff80105ea7:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
ffffffff80105eab:	89 55 f0             	mov    %edx,-0x10(%rbp)
}
ffffffff80105eae:	90                   	nop
ffffffff80105eaf:	c9                   	leaveq 
ffffffff80105eb0:	c3                   	retq   

ffffffff80105eb1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
ffffffff80105eb1:	55                   	push   %rbp
ffffffff80105eb2:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105eb5:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80105eb9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80105ebd:	89 75 f4             	mov    %esi,-0xc(%rbp)
ffffffff80105ec0:	89 55 f0             	mov    %edx,-0x10(%rbp)
  if ((uintp)dst%4 == 0 && n%4 == 0){
ffffffff80105ec3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105ec7:	83 e0 03             	and    $0x3,%eax
ffffffff80105eca:	48 85 c0             	test   %rax,%rax
ffffffff80105ecd:	75 48                	jne    ffffffff80105f17 <memset+0x66>
ffffffff80105ecf:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff80105ed2:	83 e0 03             	and    $0x3,%eax
ffffffff80105ed5:	85 c0                	test   %eax,%eax
ffffffff80105ed7:	75 3e                	jne    ffffffff80105f17 <memset+0x66>
    c &= 0xFF;
ffffffff80105ed9:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
ffffffff80105ee0:	8b 45 f0             	mov    -0x10(%rbp),%eax
ffffffff80105ee3:	c1 e8 02             	shr    $0x2,%eax
ffffffff80105ee6:	89 c6                	mov    %eax,%esi
ffffffff80105ee8:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80105eeb:	c1 e0 18             	shl    $0x18,%eax
ffffffff80105eee:	89 c2                	mov    %eax,%edx
ffffffff80105ef0:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80105ef3:	c1 e0 10             	shl    $0x10,%eax
ffffffff80105ef6:	09 c2                	or     %eax,%edx
ffffffff80105ef8:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80105efb:	c1 e0 08             	shl    $0x8,%eax
ffffffff80105efe:	09 d0                	or     %edx,%eax
ffffffff80105f00:	0b 45 f4             	or     -0xc(%rbp),%eax
ffffffff80105f03:	89 c1                	mov    %eax,%ecx
ffffffff80105f05:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105f09:	89 f2                	mov    %esi,%edx
ffffffff80105f0b:	89 ce                	mov    %ecx,%esi
ffffffff80105f0d:	48 89 c7             	mov    %rax,%rdi
ffffffff80105f10:	e8 66 ff ff ff       	callq  ffffffff80105e7b <stosl>
ffffffff80105f15:	eb 14                	jmp    ffffffff80105f2b <memset+0x7a>
  } else
    stosb(dst, c, n);
ffffffff80105f17:	8b 55 f0             	mov    -0x10(%rbp),%edx
ffffffff80105f1a:	8b 4d f4             	mov    -0xc(%rbp),%ecx
ffffffff80105f1d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105f21:	89 ce                	mov    %ecx,%esi
ffffffff80105f23:	48 89 c7             	mov    %rax,%rdi
ffffffff80105f26:	e8 1a ff ff ff       	callq  ffffffff80105e45 <stosb>
  return dst;
ffffffff80105f2b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff80105f2f:	c9                   	leaveq 
ffffffff80105f30:	c3                   	retq   

ffffffff80105f31 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
ffffffff80105f31:	55                   	push   %rbp
ffffffff80105f32:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105f35:	48 83 ec 28          	sub    $0x28,%rsp
ffffffff80105f39:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80105f3d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80105f41:	89 55 dc             	mov    %edx,-0x24(%rbp)
  const uchar *s1, *s2;
  
  s1 = v1;
ffffffff80105f44:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105f48:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  s2 = v2;
ffffffff80105f4c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105f50:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0){
ffffffff80105f54:	eb 36                	jmp    ffffffff80105f8c <memcmp+0x5b>
    if(*s1 != *s2)
ffffffff80105f56:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105f5a:	0f b6 10             	movzbl (%rax),%edx
ffffffff80105f5d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105f61:	0f b6 00             	movzbl (%rax),%eax
ffffffff80105f64:	38 c2                	cmp    %al,%dl
ffffffff80105f66:	74 1a                	je     ffffffff80105f82 <memcmp+0x51>
      return *s1 - *s2;
ffffffff80105f68:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105f6c:	0f b6 00             	movzbl (%rax),%eax
ffffffff80105f6f:	0f b6 d0             	movzbl %al,%edx
ffffffff80105f72:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80105f76:	0f b6 00             	movzbl (%rax),%eax
ffffffff80105f79:	0f b6 c0             	movzbl %al,%eax
ffffffff80105f7c:	29 c2                	sub    %eax,%edx
ffffffff80105f7e:	89 d0                	mov    %edx,%eax
ffffffff80105f80:	eb 1c                	jmp    ffffffff80105f9e <memcmp+0x6d>
    s1++, s2++;
ffffffff80105f82:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
ffffffff80105f87:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(n-- > 0){
ffffffff80105f8c:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80105f8f:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff80105f92:	89 55 dc             	mov    %edx,-0x24(%rbp)
ffffffff80105f95:	85 c0                	test   %eax,%eax
ffffffff80105f97:	75 bd                	jne    ffffffff80105f56 <memcmp+0x25>
  }

  return 0;
ffffffff80105f99:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80105f9e:	c9                   	leaveq 
ffffffff80105f9f:	c3                   	retq   

ffffffff80105fa0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
ffffffff80105fa0:	55                   	push   %rbp
ffffffff80105fa1:	48 89 e5             	mov    %rsp,%rbp
ffffffff80105fa4:	48 83 ec 28          	sub    $0x28,%rsp
ffffffff80105fa8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80105fac:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80105fb0:	89 55 dc             	mov    %edx,-0x24(%rbp)
  const char *s;
  char *d;

  s = src;
ffffffff80105fb3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80105fb7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  d = dst;
ffffffff80105fbb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80105fbf:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  if(s < d && s + n > d){
ffffffff80105fc3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105fc7:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
ffffffff80105fcb:	73 63                	jae    ffffffff80106030 <memmove+0x90>
ffffffff80105fcd:	8b 55 dc             	mov    -0x24(%rbp),%edx
ffffffff80105fd0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105fd4:	48 01 d0             	add    %rdx,%rax
ffffffff80105fd7:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
ffffffff80105fdb:	73 53                	jae    ffffffff80106030 <memmove+0x90>
    s += n;
ffffffff80105fdd:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80105fe0:	48 01 45 f8          	add    %rax,-0x8(%rbp)
    d += n;
ffffffff80105fe4:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80105fe7:	48 01 45 f0          	add    %rax,-0x10(%rbp)
    while(n-- > 0)
ffffffff80105feb:	eb 17                	jmp    ffffffff80106004 <memmove+0x64>
      *--d = *--s;
ffffffff80105fed:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
ffffffff80105ff2:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
ffffffff80105ff7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80105ffb:	0f b6 10             	movzbl (%rax),%edx
ffffffff80105ffe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106002:	88 10                	mov    %dl,(%rax)
    while(n-- > 0)
ffffffff80106004:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106007:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff8010600a:	89 55 dc             	mov    %edx,-0x24(%rbp)
ffffffff8010600d:	85 c0                	test   %eax,%eax
ffffffff8010600f:	75 dc                	jne    ffffffff80105fed <memmove+0x4d>
  if(s < d && s + n > d){
ffffffff80106011:	eb 2a                	jmp    ffffffff8010603d <memmove+0x9d>
  } else
    while(n-- > 0)
      *d++ = *s++;
ffffffff80106013:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80106017:	48 8d 42 01          	lea    0x1(%rdx),%rax
ffffffff8010601b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff8010601f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106023:	48 8d 48 01          	lea    0x1(%rax),%rcx
ffffffff80106027:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
ffffffff8010602b:	0f b6 12             	movzbl (%rdx),%edx
ffffffff8010602e:	88 10                	mov    %dl,(%rax)
    while(n-- > 0)
ffffffff80106030:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106033:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff80106036:	89 55 dc             	mov    %edx,-0x24(%rbp)
ffffffff80106039:	85 c0                	test   %eax,%eax
ffffffff8010603b:	75 d6                	jne    ffffffff80106013 <memmove+0x73>

  return dst;
ffffffff8010603d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
ffffffff80106041:	c9                   	leaveq 
ffffffff80106042:	c3                   	retq   

ffffffff80106043 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
ffffffff80106043:	55                   	push   %rbp
ffffffff80106044:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106047:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff8010604b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010604f:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff80106053:	89 55 ec             	mov    %edx,-0x14(%rbp)
  return memmove(dst, src, n);
ffffffff80106056:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff80106059:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
ffffffff8010605d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106061:	48 89 ce             	mov    %rcx,%rsi
ffffffff80106064:	48 89 c7             	mov    %rax,%rdi
ffffffff80106067:	e8 34 ff ff ff       	callq  ffffffff80105fa0 <memmove>
}
ffffffff8010606c:	c9                   	leaveq 
ffffffff8010606d:	c3                   	retq   

ffffffff8010606e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
ffffffff8010606e:	55                   	push   %rbp
ffffffff8010606f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106072:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80106076:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010607a:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
ffffffff8010607e:	89 55 ec             	mov    %edx,-0x14(%rbp)
  while(n > 0 && *p && *p == *q)
ffffffff80106081:	eb 0e                	jmp    ffffffff80106091 <strncmp+0x23>
    n--, p++, q++;
ffffffff80106083:	83 6d ec 01          	subl   $0x1,-0x14(%rbp)
ffffffff80106087:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
ffffffff8010608c:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(n > 0 && *p && *p == *q)
ffffffff80106091:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff80106095:	74 1d                	je     ffffffff801060b4 <strncmp+0x46>
ffffffff80106097:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010609b:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010609e:	84 c0                	test   %al,%al
ffffffff801060a0:	74 12                	je     ffffffff801060b4 <strncmp+0x46>
ffffffff801060a2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801060a6:	0f b6 10             	movzbl (%rax),%edx
ffffffff801060a9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801060ad:	0f b6 00             	movzbl (%rax),%eax
ffffffff801060b0:	38 c2                	cmp    %al,%dl
ffffffff801060b2:	74 cf                	je     ffffffff80106083 <strncmp+0x15>
  if(n == 0)
ffffffff801060b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff801060b8:	75 07                	jne    ffffffff801060c1 <strncmp+0x53>
    return 0;
ffffffff801060ba:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801060bf:	eb 18                	jmp    ffffffff801060d9 <strncmp+0x6b>
  return (uchar)*p - (uchar)*q;
ffffffff801060c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801060c5:	0f b6 00             	movzbl (%rax),%eax
ffffffff801060c8:	0f b6 d0             	movzbl %al,%edx
ffffffff801060cb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801060cf:	0f b6 00             	movzbl (%rax),%eax
ffffffff801060d2:	0f b6 c0             	movzbl %al,%eax
ffffffff801060d5:	29 c2                	sub    %eax,%edx
ffffffff801060d7:	89 d0                	mov    %edx,%eax
}
ffffffff801060d9:	c9                   	leaveq 
ffffffff801060da:	c3                   	retq   

ffffffff801060db <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
ffffffff801060db:	55                   	push   %rbp
ffffffff801060dc:	48 89 e5             	mov    %rsp,%rbp
ffffffff801060df:	48 83 ec 28          	sub    $0x28,%rsp
ffffffff801060e3:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff801060e7:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff801060eb:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *os;
  
  os = s;
ffffffff801060ee:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801060f2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(n-- > 0 && (*s++ = *t++) != 0)
ffffffff801060f6:	90                   	nop
ffffffff801060f7:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff801060fa:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff801060fd:	89 55 dc             	mov    %edx,-0x24(%rbp)
ffffffff80106100:	85 c0                	test   %eax,%eax
ffffffff80106102:	7e 35                	jle    ffffffff80106139 <strncpy+0x5e>
ffffffff80106104:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff80106108:	48 8d 42 01          	lea    0x1(%rdx),%rax
ffffffff8010610c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff80106110:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80106114:	48 8d 48 01          	lea    0x1(%rax),%rcx
ffffffff80106118:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
ffffffff8010611c:	0f b6 12             	movzbl (%rdx),%edx
ffffffff8010611f:	88 10                	mov    %dl,(%rax)
ffffffff80106121:	0f b6 00             	movzbl (%rax),%eax
ffffffff80106124:	84 c0                	test   %al,%al
ffffffff80106126:	75 cf                	jne    ffffffff801060f7 <strncpy+0x1c>
    ;
  while(n-- > 0)
ffffffff80106128:	eb 0f                	jmp    ffffffff80106139 <strncpy+0x5e>
    *s++ = 0;
ffffffff8010612a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010612e:	48 8d 50 01          	lea    0x1(%rax),%rdx
ffffffff80106132:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
ffffffff80106136:	c6 00 00             	movb   $0x0,(%rax)
  while(n-- > 0)
ffffffff80106139:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff8010613c:	8d 50 ff             	lea    -0x1(%rax),%edx
ffffffff8010613f:	89 55 dc             	mov    %edx,-0x24(%rbp)
ffffffff80106142:	85 c0                	test   %eax,%eax
ffffffff80106144:	7f e4                	jg     ffffffff8010612a <strncpy+0x4f>
  return os;
ffffffff80106146:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff8010614a:	c9                   	leaveq 
ffffffff8010614b:	c3                   	retq   

ffffffff8010614c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
ffffffff8010614c:	55                   	push   %rbp
ffffffff8010614d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106150:	48 83 ec 28          	sub    $0x28,%rsp
ffffffff80106154:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80106158:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff8010615c:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *os;
  
  os = s;
ffffffff8010615f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80106163:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(n <= 0)
ffffffff80106167:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
ffffffff8010616b:	7f 06                	jg     ffffffff80106173 <safestrcpy+0x27>
    return os;
ffffffff8010616d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106171:	eb 39                	jmp    ffffffff801061ac <safestrcpy+0x60>
  while(--n > 0 && (*s++ = *t++) != 0)
ffffffff80106173:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
ffffffff80106177:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
ffffffff8010617b:	7e 24                	jle    ffffffff801061a1 <safestrcpy+0x55>
ffffffff8010617d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff80106181:	48 8d 42 01          	lea    0x1(%rdx),%rax
ffffffff80106185:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff80106189:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010618d:	48 8d 48 01          	lea    0x1(%rax),%rcx
ffffffff80106191:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
ffffffff80106195:	0f b6 12             	movzbl (%rdx),%edx
ffffffff80106198:	88 10                	mov    %dl,(%rax)
ffffffff8010619a:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010619d:	84 c0                	test   %al,%al
ffffffff8010619f:	75 d2                	jne    ffffffff80106173 <safestrcpy+0x27>
    ;
  *s = 0;
ffffffff801061a1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801061a5:	c6 00 00             	movb   $0x0,(%rax)
  return os;
ffffffff801061a8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff801061ac:	c9                   	leaveq 
ffffffff801061ad:	c3                   	retq   

ffffffff801061ae <strlen>:

int
strlen(const char *s)
{
ffffffff801061ae:	55                   	push   %rbp
ffffffff801061af:	48 89 e5             	mov    %rsp,%rbp
ffffffff801061b2:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff801061b6:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
ffffffff801061ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff801061c1:	eb 04                	jmp    ffffffff801061c7 <strlen+0x19>
ffffffff801061c3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801061c7:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801061ca:	48 63 d0             	movslq %eax,%rdx
ffffffff801061cd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801061d1:	48 01 d0             	add    %rdx,%rax
ffffffff801061d4:	0f b6 00             	movzbl (%rax),%eax
ffffffff801061d7:	84 c0                	test   %al,%al
ffffffff801061d9:	75 e8                	jne    ffffffff801061c3 <strlen+0x15>
    ;
  return n;
ffffffff801061db:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff801061de:	c9                   	leaveq 
ffffffff801061df:	c3                   	retq   

ffffffff801061e0 <swtch>:
# and then load register context from new.

.globl swtch
swtch:
  # Save old callee-save registers
  push %rbp
ffffffff801061e0:	55                   	push   %rbp
  push %rbx
ffffffff801061e1:	53                   	push   %rbx
  push %r11
ffffffff801061e2:	41 53                	push   %r11
  push %r12
ffffffff801061e4:	41 54                	push   %r12
  push %r13
ffffffff801061e6:	41 55                	push   %r13
  push %r14
ffffffff801061e8:	41 56                	push   %r14
  push %r15
ffffffff801061ea:	41 57                	push   %r15

  # Switch stacks
  mov %rsp, (%rdi)
ffffffff801061ec:	48 89 27             	mov    %rsp,(%rdi)
  mov %rsi, %rsp
ffffffff801061ef:	48 89 f4             	mov    %rsi,%rsp

  # Load new callee-save registers
  pop %r15
ffffffff801061f2:	41 5f                	pop    %r15
  pop %r14
ffffffff801061f4:	41 5e                	pop    %r14
  pop %r13
ffffffff801061f6:	41 5d                	pop    %r13
  pop %r12
ffffffff801061f8:	41 5c                	pop    %r12
  pop %r11
ffffffff801061fa:	41 5b                	pop    %r11
  pop %rbx
ffffffff801061fc:	5b                   	pop    %rbx
  pop %rbp
ffffffff801061fd:	5d                   	pop    %rbp

  ret #??
ffffffff801061fe:	c3                   	retq   

ffffffff801061ff <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uintp addr, int *ip)
{
ffffffff801061ff:	55                   	push   %rbp
ffffffff80106200:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106203:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80106207:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010620b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(addr >= proc->sz || addr+sizeof(int) > proc->sz)
ffffffff8010620f:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106216:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010621a:	48 8b 00             	mov    (%rax),%rax
ffffffff8010621d:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff80106221:	73 1b                	jae    ffffffff8010623e <fetchint+0x3f>
ffffffff80106223:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106227:	48 8d 50 04          	lea    0x4(%rax),%rdx
ffffffff8010622b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106232:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106236:	48 8b 00             	mov    (%rax),%rax
ffffffff80106239:	48 39 c2             	cmp    %rax,%rdx
ffffffff8010623c:	76 07                	jbe    ffffffff80106245 <fetchint+0x46>
    return -1;
ffffffff8010623e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106243:	eb 11                	jmp    ffffffff80106256 <fetchint+0x57>
  *ip = *(int*)(addr);
ffffffff80106245:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106249:	8b 10                	mov    (%rax),%edx
ffffffff8010624b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010624f:	89 10                	mov    %edx,(%rax)
  return 0;
ffffffff80106251:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80106256:	c9                   	leaveq 
ffffffff80106257:	c3                   	retq   

ffffffff80106258 <fetchuintp>:

int
fetchuintp(uintp addr, uintp *ip)
{
ffffffff80106258:	55                   	push   %rbp
ffffffff80106259:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010625c:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff80106260:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80106264:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(addr >= proc->sz || addr+sizeof(uintp) > proc->sz)
ffffffff80106268:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010626f:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106273:	48 8b 00             	mov    (%rax),%rax
ffffffff80106276:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff8010627a:	73 1b                	jae    ffffffff80106297 <fetchuintp+0x3f>
ffffffff8010627c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106280:	48 8d 50 08          	lea    0x8(%rax),%rdx
ffffffff80106284:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010628b:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010628f:	48 8b 00             	mov    (%rax),%rax
ffffffff80106292:	48 39 c2             	cmp    %rax,%rdx
ffffffff80106295:	76 07                	jbe    ffffffff8010629e <fetchuintp+0x46>
    return -1;
ffffffff80106297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010629c:	eb 13                	jmp    ffffffff801062b1 <fetchuintp+0x59>
  *ip = *(uintp*)(addr);
ffffffff8010629e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801062a2:	48 8b 10             	mov    (%rax),%rdx
ffffffff801062a5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801062a9:	48 89 10             	mov    %rdx,(%rax)
  return 0;
ffffffff801062ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801062b1:	c9                   	leaveq 
ffffffff801062b2:	c3                   	retq   

ffffffff801062b3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uintp addr, char **pp)
{
ffffffff801062b3:	55                   	push   %rbp
ffffffff801062b4:	48 89 e5             	mov    %rsp,%rbp
ffffffff801062b7:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801062bb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff801062bf:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *s, *ep;

  if(addr >= proc->sz)
ffffffff801062c3:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801062ca:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801062ce:	48 8b 00             	mov    (%rax),%rax
ffffffff801062d1:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff801062d5:	72 07                	jb     ffffffff801062de <fetchstr+0x2b>
    return -1;
ffffffff801062d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801062dc:	eb 5c                	jmp    ffffffff8010633a <fetchstr+0x87>
  *pp = (char*)addr;
ffffffff801062de:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff801062e2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801062e6:	48 89 10             	mov    %rdx,(%rax)
  ep = (char*)proc->sz;
ffffffff801062e9:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801062f0:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801062f4:	48 8b 00             	mov    (%rax),%rax
ffffffff801062f7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(s = *pp; s < ep; s++)
ffffffff801062fb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801062ff:	48 8b 00             	mov    (%rax),%rax
ffffffff80106302:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80106306:	eb 23                	jmp    ffffffff8010632b <fetchstr+0x78>
    if(*s == 0)
ffffffff80106308:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010630c:	0f b6 00             	movzbl (%rax),%eax
ffffffff8010630f:	84 c0                	test   %al,%al
ffffffff80106311:	75 13                	jne    ffffffff80106326 <fetchstr+0x73>
      return s - *pp;
ffffffff80106313:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80106317:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010631b:	48 8b 00             	mov    (%rax),%rax
ffffffff8010631e:	48 29 c2             	sub    %rax,%rdx
ffffffff80106321:	48 89 d0             	mov    %rdx,%rax
ffffffff80106324:	eb 14                	jmp    ffffffff8010633a <fetchstr+0x87>
  for(s = *pp; s < ep; s++)
ffffffff80106326:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
ffffffff8010632b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010632f:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
ffffffff80106333:	72 d3                	jb     ffffffff80106308 <fetchstr+0x55>
  return -1;
ffffffff80106335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff8010633a:	c9                   	leaveq 
ffffffff8010633b:	c3                   	retq   

ffffffff8010633c <fetcharg>:

#if X64
// arguments passed in registers on x64
static uintp
fetcharg(int n)
{
ffffffff8010633c:	55                   	push   %rbp
ffffffff8010633d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106340:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80106344:	89 7d fc             	mov    %edi,-0x4(%rbp)
  switch (n) {
ffffffff80106347:	83 7d fc 05          	cmpl   $0x5,-0x4(%rbp)
ffffffff8010634b:	0f 87 8b 00 00 00    	ja     ffffffff801063dc <fetcharg+0xa0>
ffffffff80106351:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106354:	48 8b 04 c5 80 9a 10 	mov    -0x7fef6580(,%rax,8),%rax
ffffffff8010635b:	80 
ffffffff8010635c:	ff e0                	jmpq   *%rax
  case 0: return proc->tf->rdi;
ffffffff8010635e:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106365:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106369:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff8010636d:	48 8b 40 30          	mov    0x30(%rax),%rax
ffffffff80106371:	eb 69                	jmp    ffffffff801063dc <fetcharg+0xa0>
  case 1: return proc->tf->rsi;
ffffffff80106373:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010637a:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010637e:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80106382:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80106386:	eb 54                	jmp    ffffffff801063dc <fetcharg+0xa0>
  case 2: return proc->tf->rdx;
ffffffff80106388:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010638f:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106393:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80106397:	48 8b 40 18          	mov    0x18(%rax),%rax
ffffffff8010639b:	eb 3f                	jmp    ffffffff801063dc <fetcharg+0xa0>
  case 3: return proc->tf->rcx;
ffffffff8010639d:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801063a4:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801063a8:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff801063ac:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff801063b0:	eb 2a                	jmp    ffffffff801063dc <fetcharg+0xa0>
  case 4: return proc->tf->r8;
ffffffff801063b2:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801063b9:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801063bd:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff801063c1:	48 8b 40 38          	mov    0x38(%rax),%rax
ffffffff801063c5:	eb 15                	jmp    ffffffff801063dc <fetcharg+0xa0>
  case 5: return proc->tf->r9;
ffffffff801063c7:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801063ce:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801063d2:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff801063d6:	48 8b 40 40          	mov    0x40(%rax),%rax
ffffffff801063da:	eb 00                	jmp    ffffffff801063dc <fetcharg+0xa0>
  }
}
ffffffff801063dc:	c9                   	leaveq 
ffffffff801063dd:	c3                   	retq   

ffffffff801063de <argint>:

int
argint(int n, int *ip)
{
ffffffff801063de:	55                   	push   %rbp
ffffffff801063df:	48 89 e5             	mov    %rsp,%rbp
ffffffff801063e2:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801063e6:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff801063e9:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  *ip = fetcharg(n);
ffffffff801063ed:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801063f0:	89 c7                	mov    %eax,%edi
ffffffff801063f2:	e8 45 ff ff ff       	callq  ffffffff8010633c <fetcharg>
ffffffff801063f7:	89 c2                	mov    %eax,%edx
ffffffff801063f9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801063fd:	89 10                	mov    %edx,(%rax)
  return 0;
ffffffff801063ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80106404:	c9                   	leaveq 
ffffffff80106405:	c3                   	retq   

ffffffff80106406 <arguintp>:

int
arguintp(int n, uintp *ip)
{
ffffffff80106406:	55                   	push   %rbp
ffffffff80106407:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010640a:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff8010640e:	89 7d fc             	mov    %edi,-0x4(%rbp)
ffffffff80106411:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  *ip = fetcharg(n);
ffffffff80106415:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106418:	89 c7                	mov    %eax,%edi
ffffffff8010641a:	e8 1d ff ff ff       	callq  ffffffff8010633c <fetcharg>
ffffffff8010641f:	48 89 c2             	mov    %rax,%rdx
ffffffff80106422:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106426:	48 89 10             	mov    %rdx,(%rax)
  return 0;
ffffffff80106429:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010642e:	c9                   	leaveq 
ffffffff8010642f:	c3                   	retq   

ffffffff80106430 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
ffffffff80106430:	55                   	push   %rbp
ffffffff80106431:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106434:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80106438:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff8010643b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff8010643f:	89 55 e8             	mov    %edx,-0x18(%rbp)
  uintp i;

  if(arguintp(n, &i) < 0)
ffffffff80106442:	48 8d 55 f8          	lea    -0x8(%rbp),%rdx
ffffffff80106446:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80106449:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010644c:	89 c7                	mov    %eax,%edi
ffffffff8010644e:	e8 b3 ff ff ff       	callq  ffffffff80106406 <arguintp>
ffffffff80106453:	85 c0                	test   %eax,%eax
ffffffff80106455:	79 07                	jns    ffffffff8010645e <argptr+0x2e>
    return -1;
ffffffff80106457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010645c:	eb 51                	jmp    ffffffff801064af <argptr+0x7f>
  if(i >= proc->sz || i+size > proc->sz)
ffffffff8010645e:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106465:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106469:	48 8b 10             	mov    (%rax),%rdx
ffffffff8010646c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106470:	48 39 c2             	cmp    %rax,%rdx
ffffffff80106473:	76 20                	jbe    ffffffff80106495 <argptr+0x65>
ffffffff80106475:	8b 45 e8             	mov    -0x18(%rbp),%eax
ffffffff80106478:	48 63 d0             	movslq %eax,%rdx
ffffffff8010647b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010647f:	48 01 c2             	add    %rax,%rdx
ffffffff80106482:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106489:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010648d:	48 8b 00             	mov    (%rax),%rax
ffffffff80106490:	48 39 c2             	cmp    %rax,%rdx
ffffffff80106493:	76 07                	jbe    ffffffff8010649c <argptr+0x6c>
    return -1;
ffffffff80106495:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010649a:	eb 13                	jmp    ffffffff801064af <argptr+0x7f>
  *pp = (char*)i;
ffffffff8010649c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801064a0:	48 89 c2             	mov    %rax,%rdx
ffffffff801064a3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801064a7:	48 89 10             	mov    %rdx,(%rax)
  return 0;
ffffffff801064aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801064af:	c9                   	leaveq 
ffffffff801064b0:	c3                   	retq   

ffffffff801064b1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
ffffffff801064b1:	55                   	push   %rbp
ffffffff801064b2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801064b5:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff801064b9:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff801064bc:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  uintp addr;
  if(arguintp(n, &addr) < 0)
ffffffff801064c0:	48 8d 55 f8          	lea    -0x8(%rbp),%rdx
ffffffff801064c4:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801064c7:	48 89 d6             	mov    %rdx,%rsi
ffffffff801064ca:	89 c7                	mov    %eax,%edi
ffffffff801064cc:	e8 35 ff ff ff       	callq  ffffffff80106406 <arguintp>
ffffffff801064d1:	85 c0                	test   %eax,%eax
ffffffff801064d3:	79 07                	jns    ffffffff801064dc <argstr+0x2b>
    return -1;
ffffffff801064d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801064da:	eb 13                	jmp    ffffffff801064ef <argstr+0x3e>
  return fetchstr(addr, pp);
ffffffff801064dc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801064e0:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
ffffffff801064e4:	48 89 d6             	mov    %rdx,%rsi
ffffffff801064e7:	48 89 c7             	mov    %rax,%rdi
ffffffff801064ea:	e8 c4 fd ff ff       	callq  ffffffff801062b3 <fetchstr>
}
ffffffff801064ef:	c9                   	leaveq 
ffffffff801064f0:	c3                   	retq   

ffffffff801064f1 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
ffffffff801064f1:	55                   	push   %rbp
ffffffff801064f2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801064f5:	48 83 ec 10          	sub    $0x10,%rsp
  int num;

  num = proc->tf->eax;
ffffffff801064f9:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106500:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106504:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff80106508:	48 8b 00             	mov    (%rax),%rax
ffffffff8010650b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
ffffffff8010650e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80106512:	7e 42                	jle    ffffffff80106556 <syscall+0x65>
ffffffff80106514:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106517:	83 f8 15             	cmp    $0x15,%eax
ffffffff8010651a:	77 3a                	ja     ffffffff80106556 <syscall+0x65>
ffffffff8010651c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010651f:	48 98                	cltq   
ffffffff80106521:	48 8b 04 c5 c0 a5 10 	mov    -0x7fef5a40(,%rax,8),%rax
ffffffff80106528:	80 
ffffffff80106529:	48 85 c0             	test   %rax,%rax
ffffffff8010652c:	74 28                	je     ffffffff80106556 <syscall+0x65>
    proc->tf->eax = syscalls[num]();
ffffffff8010652e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106531:	48 98                	cltq   
ffffffff80106533:	48 8b 04 c5 c0 a5 10 	mov    -0x7fef5a40(,%rax,8),%rax
ffffffff8010653a:	80 
ffffffff8010653b:	ff d0                	callq  *%rax
ffffffff8010653d:	89 c2                	mov    %eax,%edx
ffffffff8010653f:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106546:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010654a:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff8010654e:	48 63 d2             	movslq %edx,%rdx
ffffffff80106551:	48 89 10             	mov    %rdx,(%rax)
ffffffff80106554:	eb 51                	jmp    ffffffff801065a7 <syscall+0xb6>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
ffffffff80106556:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010655d:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80106561:	48 8d b0 d0 00 00 00 	lea    0xd0(%rax),%rsi
ffffffff80106568:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010656f:	64 48 8b 00          	mov    %fs:(%rax),%rax
    cprintf("%d %s: unknown sys call %d\n",
ffffffff80106573:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff80106576:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80106579:	89 d1                	mov    %edx,%ecx
ffffffff8010657b:	48 89 f2             	mov    %rsi,%rdx
ffffffff8010657e:	89 c6                	mov    %eax,%esi
ffffffff80106580:	48 c7 c7 b0 9a 10 80 	mov    $0xffffffff80109ab0,%rdi
ffffffff80106587:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010658c:	e8 10 a0 ff ff       	callq  ffffffff801005a1 <cprintf>
    proc->tf->eax = -1;
ffffffff80106591:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106598:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010659c:	48 8b 40 28          	mov    0x28(%rax),%rax
ffffffff801065a0:	48 c7 00 ff ff ff ff 	movq   $0xffffffffffffffff,(%rax)
  }
}
ffffffff801065a7:	90                   	nop
ffffffff801065a8:	c9                   	leaveq 
ffffffff801065a9:	c3                   	retq   

ffffffff801065aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
ffffffff801065aa:	55                   	push   %rbp
ffffffff801065ab:	48 89 e5             	mov    %rsp,%rbp
ffffffff801065ae:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff801065b2:	89 7d ec             	mov    %edi,-0x14(%rbp)
ffffffff801065b5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff801065b9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
ffffffff801065bd:	48 8d 55 f4          	lea    -0xc(%rbp),%rdx
ffffffff801065c1:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff801065c4:	48 89 d6             	mov    %rdx,%rsi
ffffffff801065c7:	89 c7                	mov    %eax,%edi
ffffffff801065c9:	e8 10 fe ff ff       	callq  ffffffff801063de <argint>
ffffffff801065ce:	85 c0                	test   %eax,%eax
ffffffff801065d0:	79 07                	jns    ffffffff801065d9 <argfd+0x2f>
    return -1;
ffffffff801065d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801065d7:	eb 62                	jmp    ffffffff8010663b <argfd+0x91>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
ffffffff801065d9:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff801065dc:	85 c0                	test   %eax,%eax
ffffffff801065de:	78 2d                	js     ffffffff8010660d <argfd+0x63>
ffffffff801065e0:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff801065e3:	83 f8 0f             	cmp    $0xf,%eax
ffffffff801065e6:	7f 25                	jg     ffffffff8010660d <argfd+0x63>
ffffffff801065e8:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801065ef:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801065f3:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff801065f6:	48 63 d2             	movslq %edx,%rdx
ffffffff801065f9:	48 83 c2 08          	add    $0x8,%rdx
ffffffff801065fd:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff80106602:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80106606:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff8010660b:	75 07                	jne    ffffffff80106614 <argfd+0x6a>
    return -1;
ffffffff8010660d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106612:	eb 27                	jmp    ffffffff8010663b <argfd+0x91>
  if(pfd)
ffffffff80106614:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
ffffffff80106619:	74 09                	je     ffffffff80106624 <argfd+0x7a>
    *pfd = fd;
ffffffff8010661b:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff8010661e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80106622:	89 10                	mov    %edx,(%rax)
  if(pf)
ffffffff80106624:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
ffffffff80106629:	74 0b                	je     ffffffff80106636 <argfd+0x8c>
    *pf = f;
ffffffff8010662b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010662f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80106633:	48 89 10             	mov    %rdx,(%rax)
  return 0;
ffffffff80106636:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010663b:	c9                   	leaveq 
ffffffff8010663c:	c3                   	retq   

ffffffff8010663d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
ffffffff8010663d:	55                   	push   %rbp
ffffffff8010663e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106641:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80106645:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
ffffffff80106649:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80106650:	eb 46                	jmp    ffffffff80106698 <fdalloc+0x5b>
    if(proc->ofile[fd] == 0){
ffffffff80106652:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106659:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010665d:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80106660:	48 63 d2             	movslq %edx,%rdx
ffffffff80106663:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80106667:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
ffffffff8010666c:	48 85 c0             	test   %rax,%rax
ffffffff8010666f:	75 23                	jne    ffffffff80106694 <fdalloc+0x57>
      proc->ofile[fd] = f;
ffffffff80106671:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106678:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010667c:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff8010667f:	48 63 d2             	movslq %edx,%rdx
ffffffff80106682:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
ffffffff80106686:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff8010668a:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
      return fd;
ffffffff8010668f:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106692:	eb 0f                	jmp    ffffffff801066a3 <fdalloc+0x66>
  for(fd = 0; fd < NOFILE; fd++){
ffffffff80106694:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80106698:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
ffffffff8010669c:	7e b4                	jle    ffffffff80106652 <fdalloc+0x15>
    }
  }
  return -1;
ffffffff8010669e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff801066a3:	c9                   	leaveq 
ffffffff801066a4:	c3                   	retq   

ffffffff801066a5 <sys_dup>:

int
sys_dup(void)
{
ffffffff801066a5:	55                   	push   %rbp
ffffffff801066a6:	48 89 e5             	mov    %rsp,%rbp
ffffffff801066a9:	48 83 ec 10          	sub    $0x10,%rsp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
ffffffff801066ad:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff801066b1:	48 89 c2             	mov    %rax,%rdx
ffffffff801066b4:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801066b9:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff801066be:	e8 e7 fe ff ff       	callq  ffffffff801065aa <argfd>
ffffffff801066c3:	85 c0                	test   %eax,%eax
ffffffff801066c5:	79 07                	jns    ffffffff801066ce <sys_dup+0x29>
    return -1;
ffffffff801066c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801066cc:	eb 2b                	jmp    ffffffff801066f9 <sys_dup+0x54>
  if((fd=fdalloc(f)) < 0)
ffffffff801066ce:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801066d2:	48 89 c7             	mov    %rax,%rdi
ffffffff801066d5:	e8 63 ff ff ff       	callq  ffffffff8010663d <fdalloc>
ffffffff801066da:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff801066dd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff801066e1:	79 07                	jns    ffffffff801066ea <sys_dup+0x45>
    return -1;
ffffffff801066e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801066e8:	eb 0f                	jmp    ffffffff801066f9 <sys_dup+0x54>
  filedup(f);
ffffffff801066ea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801066ee:	48 89 c7             	mov    %rax,%rdi
ffffffff801066f1:	e8 af ad ff ff       	callq  ffffffff801014a5 <filedup>
  return fd;
ffffffff801066f6:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff801066f9:	c9                   	leaveq 
ffffffff801066fa:	c3                   	retq   

ffffffff801066fb <sys_read>:

int
sys_read(void)
{
ffffffff801066fb:	55                   	push   %rbp
ffffffff801066fc:	48 89 e5             	mov    %rsp,%rbp
ffffffff801066ff:	48 83 ec 20          	sub    $0x20,%rsp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
ffffffff80106703:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
ffffffff80106707:	48 89 c2             	mov    %rax,%rdx
ffffffff8010670a:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff8010670f:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80106714:	e8 91 fe ff ff       	callq  ffffffff801065aa <argfd>
ffffffff80106719:	85 c0                	test   %eax,%eax
ffffffff8010671b:	78 2d                	js     ffffffff8010674a <sys_read+0x4f>
ffffffff8010671d:	48 8d 45 f4          	lea    -0xc(%rbp),%rax
ffffffff80106721:	48 89 c6             	mov    %rax,%rsi
ffffffff80106724:	bf 02 00 00 00       	mov    $0x2,%edi
ffffffff80106729:	e8 b0 fc ff ff       	callq  ffffffff801063de <argint>
ffffffff8010672e:	85 c0                	test   %eax,%eax
ffffffff80106730:	78 18                	js     ffffffff8010674a <sys_read+0x4f>
ffffffff80106732:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff80106735:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
ffffffff80106739:	48 89 c6             	mov    %rax,%rsi
ffffffff8010673c:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80106741:	e8 ea fc ff ff       	callq  ffffffff80106430 <argptr>
ffffffff80106746:	85 c0                	test   %eax,%eax
ffffffff80106748:	79 07                	jns    ffffffff80106751 <sys_read+0x56>
    return -1;
ffffffff8010674a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010674f:	eb 16                	jmp    ffffffff80106767 <sys_read+0x6c>
  return fileread(f, p, n);
ffffffff80106751:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff80106754:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
ffffffff80106758:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010675c:	48 89 ce             	mov    %rcx,%rsi
ffffffff8010675f:	48 89 c7             	mov    %rax,%rdi
ffffffff80106762:	e8 e1 ae ff ff       	callq  ffffffff80101648 <fileread>
}
ffffffff80106767:	c9                   	leaveq 
ffffffff80106768:	c3                   	retq   

ffffffff80106769 <sys_write>:

int
sys_write(void)
{
ffffffff80106769:	55                   	push   %rbp
ffffffff8010676a:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010676d:	48 83 ec 20          	sub    $0x20,%rsp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
ffffffff80106771:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
ffffffff80106775:	48 89 c2             	mov    %rax,%rdx
ffffffff80106778:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff8010677d:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80106782:	e8 23 fe ff ff       	callq  ffffffff801065aa <argfd>
ffffffff80106787:	85 c0                	test   %eax,%eax
ffffffff80106789:	78 2d                	js     ffffffff801067b8 <sys_write+0x4f>
ffffffff8010678b:	48 8d 45 f4          	lea    -0xc(%rbp),%rax
ffffffff8010678f:	48 89 c6             	mov    %rax,%rsi
ffffffff80106792:	bf 02 00 00 00       	mov    $0x2,%edi
ffffffff80106797:	e8 42 fc ff ff       	callq  ffffffff801063de <argint>
ffffffff8010679c:	85 c0                	test   %eax,%eax
ffffffff8010679e:	78 18                	js     ffffffff801067b8 <sys_write+0x4f>
ffffffff801067a0:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff801067a3:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
ffffffff801067a7:	48 89 c6             	mov    %rax,%rsi
ffffffff801067aa:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff801067af:	e8 7c fc ff ff       	callq  ffffffff80106430 <argptr>
ffffffff801067b4:	85 c0                	test   %eax,%eax
ffffffff801067b6:	79 07                	jns    ffffffff801067bf <sys_write+0x56>
    return -1;
ffffffff801067b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801067bd:	eb 16                	jmp    ffffffff801067d5 <sys_write+0x6c>
  return filewrite(f, p, n);
ffffffff801067bf:	8b 55 f4             	mov    -0xc(%rbp),%edx
ffffffff801067c2:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
ffffffff801067c6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801067ca:	48 89 ce             	mov    %rcx,%rsi
ffffffff801067cd:	48 89 c7             	mov    %rax,%rdi
ffffffff801067d0:	e8 3b af ff ff       	callq  ffffffff80101710 <filewrite>
}
ffffffff801067d5:	c9                   	leaveq 
ffffffff801067d6:	c3                   	retq   

ffffffff801067d7 <sys_close>:

int
sys_close(void)
{
ffffffff801067d7:	55                   	push   %rbp
ffffffff801067d8:	48 89 e5             	mov    %rsp,%rbp
ffffffff801067db:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
ffffffff801067df:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
ffffffff801067e3:	48 8d 45 fc          	lea    -0x4(%rbp),%rax
ffffffff801067e7:	48 89 c6             	mov    %rax,%rsi
ffffffff801067ea:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff801067ef:	e8 b6 fd ff ff       	callq  ffffffff801065aa <argfd>
ffffffff801067f4:	85 c0                	test   %eax,%eax
ffffffff801067f6:	79 07                	jns    ffffffff801067ff <sys_close+0x28>
    return -1;
ffffffff801067f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801067fd:	eb 2f                	jmp    ffffffff8010682e <sys_close+0x57>
  proc->ofile[fd] = 0;
ffffffff801067ff:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80106806:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010680a:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff8010680d:	48 63 d2             	movslq %edx,%rdx
ffffffff80106810:	48 83 c2 08          	add    $0x8,%rdx
ffffffff80106814:	48 c7 44 d0 08 00 00 	movq   $0x0,0x8(%rax,%rdx,8)
ffffffff8010681b:	00 00 
  fileclose(f);
ffffffff8010681d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106821:	48 89 c7             	mov    %rax,%rdi
ffffffff80106824:	e8 ce ac ff ff       	callq  ffffffff801014f7 <fileclose>
  return 0;
ffffffff80106829:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010682e:	c9                   	leaveq 
ffffffff8010682f:	c3                   	retq   

ffffffff80106830 <sys_fstat>:

int
sys_fstat(void)
{
ffffffff80106830:	55                   	push   %rbp
ffffffff80106831:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106834:	48 83 ec 10          	sub    $0x10,%rsp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
ffffffff80106838:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
ffffffff8010683c:	48 89 c2             	mov    %rax,%rdx
ffffffff8010683f:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80106844:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80106849:	e8 5c fd ff ff       	callq  ffffffff801065aa <argfd>
ffffffff8010684e:	85 c0                	test   %eax,%eax
ffffffff80106850:	78 1a                	js     ffffffff8010686c <sys_fstat+0x3c>
ffffffff80106852:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff80106856:	ba 14 00 00 00       	mov    $0x14,%edx
ffffffff8010685b:	48 89 c6             	mov    %rax,%rsi
ffffffff8010685e:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80106863:	e8 c8 fb ff ff       	callq  ffffffff80106430 <argptr>
ffffffff80106868:	85 c0                	test   %eax,%eax
ffffffff8010686a:	79 07                	jns    ffffffff80106873 <sys_fstat+0x43>
    return -1;
ffffffff8010686c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106871:	eb 13                	jmp    ffffffff80106886 <sys_fstat+0x56>
  return filestat(f, st);
ffffffff80106873:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff80106877:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010687b:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010687e:	48 89 c7             	mov    %rax,%rdi
ffffffff80106881:	e8 62 ad ff ff       	callq  ffffffff801015e8 <filestat>
}
ffffffff80106886:	c9                   	leaveq 
ffffffff80106887:	c3                   	retq   

ffffffff80106888 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
ffffffff80106888:	55                   	push   %rbp
ffffffff80106889:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010688c:	48 83 ec 30          	sub    $0x30,%rsp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
ffffffff80106890:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
ffffffff80106894:	48 89 c6             	mov    %rax,%rsi
ffffffff80106897:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff8010689c:	e8 10 fc ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff801068a1:	85 c0                	test   %eax,%eax
ffffffff801068a3:	78 15                	js     ffffffff801068ba <sys_link+0x32>
ffffffff801068a5:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
ffffffff801068a9:	48 89 c6             	mov    %rax,%rsi
ffffffff801068ac:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff801068b1:	e8 fb fb ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff801068b6:	85 c0                	test   %eax,%eax
ffffffff801068b8:	79 0a                	jns    ffffffff801068c4 <sys_link+0x3c>
    return -1;
ffffffff801068ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801068bf:	e9 6a 01 00 00       	jmpq   ffffffff80106a2e <sys_link+0x1a6>
  if((ip = namei(old)) == 0)
ffffffff801068c4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff801068c8:	48 89 c7             	mov    %rax,%rdi
ffffffff801068cb:	e8 46 c2 ff ff       	callq  ffffffff80102b16 <namei>
ffffffff801068d0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801068d4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff801068d9:	75 0a                	jne    ffffffff801068e5 <sys_link+0x5d>
    return -1;
ffffffff801068db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801068e0:	e9 49 01 00 00       	jmpq   ffffffff80106a2e <sys_link+0x1a6>

  begin_trans();
ffffffff801068e5:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801068ea:	e8 07 d1 ff ff       	callq  ffffffff801039f6 <begin_trans>

  ilock(ip);
ffffffff801068ef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801068f3:	48 89 c7             	mov    %rax,%rdi
ffffffff801068f6:	e8 52 b5 ff ff       	callq  ffffffff80101e4d <ilock>
  if(ip->type == T_DIR){
ffffffff801068fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801068ff:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80106903:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80106907:	75 20                	jne    ffffffff80106929 <sys_link+0xa1>
    iunlockput(ip);
ffffffff80106909:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010690d:	48 89 c7             	mov    %rax,%rdi
ffffffff80106910:	e8 00 b8 ff ff       	callq  ffffffff80102115 <iunlockput>
    commit_trans();
ffffffff80106915:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010691a:	e8 1f d1 ff ff       	callq  ffffffff80103a3e <commit_trans>
    return -1;
ffffffff8010691f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106924:	e9 05 01 00 00       	jmpq   ffffffff80106a2e <sys_link+0x1a6>
  }

  ip->nlink++;
ffffffff80106929:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010692d:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80106931:	83 c0 01             	add    $0x1,%eax
ffffffff80106934:	89 c2                	mov    %eax,%edx
ffffffff80106936:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010693a:	66 89 50 16          	mov    %dx,0x16(%rax)
  iupdate(ip);
ffffffff8010693e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106942:	48 89 c7             	mov    %rax,%rdi
ffffffff80106945:	e8 05 b3 ff ff       	callq  ffffffff80101c4f <iupdate>
  iunlock(ip);
ffffffff8010694a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010694e:	48 89 c7             	mov    %rax,%rdi
ffffffff80106951:	e8 68 b6 ff ff       	callq  ffffffff80101fbe <iunlock>

  if((dp = nameiparent(new, name)) == 0)
ffffffff80106956:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010695a:	48 8d 55 e2          	lea    -0x1e(%rbp),%rdx
ffffffff8010695e:	48 89 d6             	mov    %rdx,%rsi
ffffffff80106961:	48 89 c7             	mov    %rax,%rdi
ffffffff80106964:	e8 d0 c1 ff ff       	callq  ffffffff80102b39 <nameiparent>
ffffffff80106969:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff8010696d:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106972:	74 71                	je     ffffffff801069e5 <sys_link+0x15d>
    goto bad;
  ilock(dp);
ffffffff80106974:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106978:	48 89 c7             	mov    %rax,%rdi
ffffffff8010697b:	e8 cd b4 ff ff       	callq  ffffffff80101e4d <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
ffffffff80106980:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106984:	8b 10                	mov    (%rax),%edx
ffffffff80106986:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010698a:	8b 00                	mov    (%rax),%eax
ffffffff8010698c:	39 c2                	cmp    %eax,%edx
ffffffff8010698e:	75 1e                	jne    ffffffff801069ae <sys_link+0x126>
ffffffff80106990:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106994:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff80106997:	48 8d 4d e2          	lea    -0x1e(%rbp),%rcx
ffffffff8010699b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010699f:	48 89 ce             	mov    %rcx,%rsi
ffffffff801069a2:	48 89 c7             	mov    %rax,%rdi
ffffffff801069a5:	e8 73 be ff ff       	callq  ffffffff8010281d <dirlink>
ffffffff801069aa:	85 c0                	test   %eax,%eax
ffffffff801069ac:	79 0e                	jns    ffffffff801069bc <sys_link+0x134>
    iunlockput(dp);
ffffffff801069ae:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801069b2:	48 89 c7             	mov    %rax,%rdi
ffffffff801069b5:	e8 5b b7 ff ff       	callq  ffffffff80102115 <iunlockput>
    goto bad;
ffffffff801069ba:	eb 2a                	jmp    ffffffff801069e6 <sys_link+0x15e>
  }
  iunlockput(dp);
ffffffff801069bc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801069c0:	48 89 c7             	mov    %rax,%rdi
ffffffff801069c3:	e8 4d b7 ff ff       	callq  ffffffff80102115 <iunlockput>
  iput(ip);
ffffffff801069c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801069cc:	48 89 c7             	mov    %rax,%rdi
ffffffff801069cf:	e8 5c b6 ff ff       	callq  ffffffff80102030 <iput>

  commit_trans();
ffffffff801069d4:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801069d9:	e8 60 d0 ff ff       	callq  ffffffff80103a3e <commit_trans>

  return 0;
ffffffff801069de:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801069e3:	eb 49                	jmp    ffffffff80106a2e <sys_link+0x1a6>
    goto bad;
ffffffff801069e5:	90                   	nop

bad:
  ilock(ip);
ffffffff801069e6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801069ea:	48 89 c7             	mov    %rax,%rdi
ffffffff801069ed:	e8 5b b4 ff ff       	callq  ffffffff80101e4d <ilock>
  ip->nlink--;
ffffffff801069f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801069f6:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff801069fa:	83 e8 01             	sub    $0x1,%eax
ffffffff801069fd:	89 c2                	mov    %eax,%edx
ffffffff801069ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106a03:	66 89 50 16          	mov    %dx,0x16(%rax)
  iupdate(ip);
ffffffff80106a07:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106a0b:	48 89 c7             	mov    %rax,%rdi
ffffffff80106a0e:	e8 3c b2 ff ff       	callq  ffffffff80101c4f <iupdate>
  iunlockput(ip);
ffffffff80106a13:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106a17:	48 89 c7             	mov    %rax,%rdi
ffffffff80106a1a:	e8 f6 b6 ff ff       	callq  ffffffff80102115 <iunlockput>
  commit_trans();
ffffffff80106a1f:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106a24:	e8 15 d0 ff ff       	callq  ffffffff80103a3e <commit_trans>
  return -1;
ffffffff80106a29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80106a2e:	c9                   	leaveq 
ffffffff80106a2f:	c3                   	retq   

ffffffff80106a30 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
ffffffff80106a30:	55                   	push   %rbp
ffffffff80106a31:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106a34:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80106a38:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
ffffffff80106a3c:	c7 45 fc 20 00 00 00 	movl   $0x20,-0x4(%rbp)
ffffffff80106a43:	eb 42                	jmp    ffffffff80106a87 <isdirempty+0x57>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
ffffffff80106a45:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80106a48:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
ffffffff80106a4c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80106a50:	b9 10 00 00 00       	mov    $0x10,%ecx
ffffffff80106a55:	48 89 c7             	mov    %rax,%rdi
ffffffff80106a58:	e8 98 b9 ff ff       	callq  ffffffff801023f5 <readi>
ffffffff80106a5d:	83 f8 10             	cmp    $0x10,%eax
ffffffff80106a60:	74 0c                	je     ffffffff80106a6e <isdirempty+0x3e>
      panic("isdirempty: readi");
ffffffff80106a62:	48 c7 c7 cc 9a 10 80 	mov    $0xffffffff80109acc,%rdi
ffffffff80106a69:	e8 90 9e ff ff       	callq  ffffffff801008fe <panic>
    if(de.inum != 0)
ffffffff80106a6e:	0f b7 45 e0          	movzwl -0x20(%rbp),%eax
ffffffff80106a72:	66 85 c0             	test   %ax,%ax
ffffffff80106a75:	74 07                	je     ffffffff80106a7e <isdirempty+0x4e>
      return 0;
ffffffff80106a77:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106a7c:	eb 1c                	jmp    ffffffff80106a9a <isdirempty+0x6a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
ffffffff80106a7e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106a81:	83 c0 10             	add    $0x10,%eax
ffffffff80106a84:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80106a87:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80106a8b:	8b 50 18             	mov    0x18(%rax),%edx
ffffffff80106a8e:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80106a91:	39 c2                	cmp    %eax,%edx
ffffffff80106a93:	77 b0                	ja     ffffffff80106a45 <isdirempty+0x15>
  }
  return 1;
ffffffff80106a95:	b8 01 00 00 00       	mov    $0x1,%eax
}
ffffffff80106a9a:	c9                   	leaveq 
ffffffff80106a9b:	c3                   	retq   

ffffffff80106a9c <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
ffffffff80106a9c:	55                   	push   %rbp
ffffffff80106a9d:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106aa0:	48 83 ec 40          	sub    $0x40,%rsp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
ffffffff80106aa4:	48 8d 45 c8          	lea    -0x38(%rbp),%rax
ffffffff80106aa8:	48 89 c6             	mov    %rax,%rsi
ffffffff80106aab:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80106ab0:	e8 fc f9 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff80106ab5:	85 c0                	test   %eax,%eax
ffffffff80106ab7:	79 0a                	jns    ffffffff80106ac3 <sys_unlink+0x27>
    return -1;
ffffffff80106ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106abe:	e9 c5 01 00 00       	jmpq   ffffffff80106c88 <sys_unlink+0x1ec>
  if((dp = nameiparent(path, name)) == 0)
ffffffff80106ac3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80106ac7:	48 8d 55 d2          	lea    -0x2e(%rbp),%rdx
ffffffff80106acb:	48 89 d6             	mov    %rdx,%rsi
ffffffff80106ace:	48 89 c7             	mov    %rax,%rdi
ffffffff80106ad1:	e8 63 c0 ff ff       	callq  ffffffff80102b39 <nameiparent>
ffffffff80106ad6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80106ada:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80106adf:	75 0a                	jne    ffffffff80106aeb <sys_unlink+0x4f>
    return -1;
ffffffff80106ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106ae6:	e9 9d 01 00 00       	jmpq   ffffffff80106c88 <sys_unlink+0x1ec>

  begin_trans();
ffffffff80106aeb:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106af0:	e8 01 cf ff ff       	callq  ffffffff801039f6 <begin_trans>

  ilock(dp);
ffffffff80106af5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106af9:	48 89 c7             	mov    %rax,%rdi
ffffffff80106afc:	e8 4c b3 ff ff       	callq  ffffffff80101e4d <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
ffffffff80106b01:	48 8d 45 d2          	lea    -0x2e(%rbp),%rax
ffffffff80106b05:	48 c7 c6 de 9a 10 80 	mov    $0xffffffff80109ade,%rsi
ffffffff80106b0c:	48 89 c7             	mov    %rax,%rdi
ffffffff80106b0f:	e8 0e bc ff ff       	callq  ffffffff80102722 <namecmp>
ffffffff80106b14:	85 c0                	test   %eax,%eax
ffffffff80106b16:	0f 84 4d 01 00 00    	je     ffffffff80106c69 <sys_unlink+0x1cd>
ffffffff80106b1c:	48 8d 45 d2          	lea    -0x2e(%rbp),%rax
ffffffff80106b20:	48 c7 c6 e0 9a 10 80 	mov    $0xffffffff80109ae0,%rsi
ffffffff80106b27:	48 89 c7             	mov    %rax,%rdi
ffffffff80106b2a:	e8 f3 bb ff ff       	callq  ffffffff80102722 <namecmp>
ffffffff80106b2f:	85 c0                	test   %eax,%eax
ffffffff80106b31:	0f 84 32 01 00 00    	je     ffffffff80106c69 <sys_unlink+0x1cd>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
ffffffff80106b37:	48 8d 55 c4          	lea    -0x3c(%rbp),%rdx
ffffffff80106b3b:	48 8d 4d d2          	lea    -0x2e(%rbp),%rcx
ffffffff80106b3f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106b43:	48 89 ce             	mov    %rcx,%rsi
ffffffff80106b46:	48 89 c7             	mov    %rax,%rdi
ffffffff80106b49:	e8 fe bb ff ff       	callq  ffffffff8010274c <dirlookup>
ffffffff80106b4e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80106b52:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106b57:	0f 84 0f 01 00 00    	je     ffffffff80106c6c <sys_unlink+0x1d0>
    goto bad;
  ilock(ip);
ffffffff80106b5d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106b61:	48 89 c7             	mov    %rax,%rdi
ffffffff80106b64:	e8 e4 b2 ff ff       	callq  ffffffff80101e4d <ilock>

  if(ip->nlink < 1)
ffffffff80106b69:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106b6d:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80106b71:	66 85 c0             	test   %ax,%ax
ffffffff80106b74:	7f 0c                	jg     ffffffff80106b82 <sys_unlink+0xe6>
    panic("unlink: nlink < 1");
ffffffff80106b76:	48 c7 c7 e3 9a 10 80 	mov    $0xffffffff80109ae3,%rdi
ffffffff80106b7d:	e8 7c 9d ff ff       	callq  ffffffff801008fe <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
ffffffff80106b82:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106b86:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80106b8a:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80106b8e:	75 21                	jne    ffffffff80106bb1 <sys_unlink+0x115>
ffffffff80106b90:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106b94:	48 89 c7             	mov    %rax,%rdi
ffffffff80106b97:	e8 94 fe ff ff       	callq  ffffffff80106a30 <isdirempty>
ffffffff80106b9c:	85 c0                	test   %eax,%eax
ffffffff80106b9e:	75 11                	jne    ffffffff80106bb1 <sys_unlink+0x115>
    iunlockput(ip);
ffffffff80106ba0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106ba4:	48 89 c7             	mov    %rax,%rdi
ffffffff80106ba7:	e8 69 b5 ff ff       	callq  ffffffff80102115 <iunlockput>
    goto bad;
ffffffff80106bac:	e9 bc 00 00 00       	jmpq   ffffffff80106c6d <sys_unlink+0x1d1>
  }

  memset(&de, 0, sizeof(de));
ffffffff80106bb1:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
ffffffff80106bb5:	ba 10 00 00 00       	mov    $0x10,%edx
ffffffff80106bba:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80106bbf:	48 89 c7             	mov    %rax,%rdi
ffffffff80106bc2:	e8 ea f2 ff ff       	callq  ffffffff80105eb1 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
ffffffff80106bc7:	8b 55 c4             	mov    -0x3c(%rbp),%edx
ffffffff80106bca:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
ffffffff80106bce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106bd2:	b9 10 00 00 00       	mov    $0x10,%ecx
ffffffff80106bd7:	48 89 c7             	mov    %rax,%rdi
ffffffff80106bda:	e8 96 b9 ff ff       	callq  ffffffff80102575 <writei>
ffffffff80106bdf:	83 f8 10             	cmp    $0x10,%eax
ffffffff80106be2:	74 0c                	je     ffffffff80106bf0 <sys_unlink+0x154>
    panic("unlink: writei");
ffffffff80106be4:	48 c7 c7 f5 9a 10 80 	mov    $0xffffffff80109af5,%rdi
ffffffff80106beb:	e8 0e 9d ff ff       	callq  ffffffff801008fe <panic>
  if(ip->type == T_DIR){
ffffffff80106bf0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106bf4:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80106bf8:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80106bfc:	75 21                	jne    ffffffff80106c1f <sys_unlink+0x183>
    dp->nlink--;
ffffffff80106bfe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106c02:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80106c06:	83 e8 01             	sub    $0x1,%eax
ffffffff80106c09:	89 c2                	mov    %eax,%edx
ffffffff80106c0b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106c0f:	66 89 50 16          	mov    %dx,0x16(%rax)
    iupdate(dp);
ffffffff80106c13:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106c17:	48 89 c7             	mov    %rax,%rdi
ffffffff80106c1a:	e8 30 b0 ff ff       	callq  ffffffff80101c4f <iupdate>
  }
  iunlockput(dp);
ffffffff80106c1f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106c23:	48 89 c7             	mov    %rax,%rdi
ffffffff80106c26:	e8 ea b4 ff ff       	callq  ffffffff80102115 <iunlockput>

  ip->nlink--;
ffffffff80106c2b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106c2f:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80106c33:	83 e8 01             	sub    $0x1,%eax
ffffffff80106c36:	89 c2                	mov    %eax,%edx
ffffffff80106c38:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106c3c:	66 89 50 16          	mov    %dx,0x16(%rax)
  iupdate(ip);
ffffffff80106c40:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106c44:	48 89 c7             	mov    %rax,%rdi
ffffffff80106c47:	e8 03 b0 ff ff       	callq  ffffffff80101c4f <iupdate>
  iunlockput(ip);
ffffffff80106c4c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106c50:	48 89 c7             	mov    %rax,%rdi
ffffffff80106c53:	e8 bd b4 ff ff       	callq  ffffffff80102115 <iunlockput>

  commit_trans();
ffffffff80106c58:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106c5d:	e8 dc cd ff ff       	callq  ffffffff80103a3e <commit_trans>

  return 0;
ffffffff80106c62:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106c67:	eb 1f                	jmp    ffffffff80106c88 <sys_unlink+0x1ec>

bad:
ffffffff80106c69:	90                   	nop
ffffffff80106c6a:	eb 01                	jmp    ffffffff80106c6d <sys_unlink+0x1d1>
    goto bad;
ffffffff80106c6c:	90                   	nop
  iunlockput(dp);
ffffffff80106c6d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106c71:	48 89 c7             	mov    %rax,%rdi
ffffffff80106c74:	e8 9c b4 ff ff       	callq  ffffffff80102115 <iunlockput>
  commit_trans();
ffffffff80106c79:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106c7e:	e8 bb cd ff ff       	callq  ffffffff80103a3e <commit_trans>
  return -1;
ffffffff80106c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
ffffffff80106c88:	c9                   	leaveq 
ffffffff80106c89:	c3                   	retq   

ffffffff80106c8a <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
ffffffff80106c8a:	55                   	push   %rbp
ffffffff80106c8b:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106c8e:	48 83 ec 50          	sub    $0x50,%rsp
ffffffff80106c92:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
ffffffff80106c96:	89 c8                	mov    %ecx,%eax
ffffffff80106c98:	89 f1                	mov    %esi,%ecx
ffffffff80106c9a:	66 89 4d c4          	mov    %cx,-0x3c(%rbp)
ffffffff80106c9e:	66 89 55 c0          	mov    %dx,-0x40(%rbp)
ffffffff80106ca2:	66 89 45 bc          	mov    %ax,-0x44(%rbp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
ffffffff80106ca6:	48 8d 55 de          	lea    -0x22(%rbp),%rdx
ffffffff80106caa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80106cae:	48 89 d6             	mov    %rdx,%rsi
ffffffff80106cb1:	48 89 c7             	mov    %rax,%rdi
ffffffff80106cb4:	e8 80 be ff ff       	callq  ffffffff80102b39 <nameiparent>
ffffffff80106cb9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80106cbd:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80106cc2:	75 0a                	jne    ffffffff80106cce <create+0x44>
    return 0;
ffffffff80106cc4:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106cc9:	e9 88 01 00 00       	jmpq   ffffffff80106e56 <create+0x1cc>
  ilock(dp);
ffffffff80106cce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106cd2:	48 89 c7             	mov    %rax,%rdi
ffffffff80106cd5:	e8 73 b1 ff ff       	callq  ffffffff80101e4d <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
ffffffff80106cda:	48 8d 55 ec          	lea    -0x14(%rbp),%rdx
ffffffff80106cde:	48 8d 4d de          	lea    -0x22(%rbp),%rcx
ffffffff80106ce2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106ce6:	48 89 ce             	mov    %rcx,%rsi
ffffffff80106ce9:	48 89 c7             	mov    %rax,%rdi
ffffffff80106cec:	e8 5b ba ff ff       	callq  ffffffff8010274c <dirlookup>
ffffffff80106cf1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80106cf5:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106cfa:	74 4c                	je     ffffffff80106d48 <create+0xbe>
    iunlockput(dp);
ffffffff80106cfc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106d00:	48 89 c7             	mov    %rax,%rdi
ffffffff80106d03:	e8 0d b4 ff ff       	callq  ffffffff80102115 <iunlockput>
    ilock(ip);
ffffffff80106d08:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d0c:	48 89 c7             	mov    %rax,%rdi
ffffffff80106d0f:	e8 39 b1 ff ff       	callq  ffffffff80101e4d <ilock>
    if(type == T_FILE && ip->type == T_FILE)
ffffffff80106d14:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%rbp)
ffffffff80106d19:	75 17                	jne    ffffffff80106d32 <create+0xa8>
ffffffff80106d1b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d1f:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80106d23:	66 83 f8 02          	cmp    $0x2,%ax
ffffffff80106d27:	75 09                	jne    ffffffff80106d32 <create+0xa8>
      return ip;
ffffffff80106d29:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d2d:	e9 24 01 00 00       	jmpq   ffffffff80106e56 <create+0x1cc>
    iunlockput(ip);
ffffffff80106d32:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d36:	48 89 c7             	mov    %rax,%rdi
ffffffff80106d39:	e8 d7 b3 ff ff       	callq  ffffffff80102115 <iunlockput>
    return 0;
ffffffff80106d3e:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106d43:	e9 0e 01 00 00       	jmpq   ffffffff80106e56 <create+0x1cc>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
ffffffff80106d48:	0f bf 55 c4          	movswl -0x3c(%rbp),%edx
ffffffff80106d4c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106d50:	8b 00                	mov    (%rax),%eax
ffffffff80106d52:	89 d6                	mov    %edx,%esi
ffffffff80106d54:	89 c7                	mov    %eax,%edi
ffffffff80106d56:	e8 0d ae ff ff       	callq  ffffffff80101b68 <ialloc>
ffffffff80106d5b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80106d5f:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106d64:	75 0c                	jne    ffffffff80106d72 <create+0xe8>
    panic("create: ialloc");
ffffffff80106d66:	48 c7 c7 04 9b 10 80 	mov    $0xffffffff80109b04,%rdi
ffffffff80106d6d:	e8 8c 9b ff ff       	callq  ffffffff801008fe <panic>

  ilock(ip);
ffffffff80106d72:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d76:	48 89 c7             	mov    %rax,%rdi
ffffffff80106d79:	e8 cf b0 ff ff       	callq  ffffffff80101e4d <ilock>
  ip->major = major;
ffffffff80106d7e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d82:	0f b7 55 c0          	movzwl -0x40(%rbp),%edx
ffffffff80106d86:	66 89 50 12          	mov    %dx,0x12(%rax)
  ip->minor = minor;
ffffffff80106d8a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d8e:	0f b7 55 bc          	movzwl -0x44(%rbp),%edx
ffffffff80106d92:	66 89 50 14          	mov    %dx,0x14(%rax)
  ip->nlink = 1;
ffffffff80106d96:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106d9a:	66 c7 40 16 01 00    	movw   $0x1,0x16(%rax)
  iupdate(ip);
ffffffff80106da0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106da4:	48 89 c7             	mov    %rax,%rdi
ffffffff80106da7:	e8 a3 ae ff ff       	callq  ffffffff80101c4f <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
ffffffff80106dac:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%rbp)
ffffffff80106db1:	75 69                	jne    ffffffff80106e1c <create+0x192>
    dp->nlink++;  // for ".."
ffffffff80106db3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106db7:	0f b7 40 16          	movzwl 0x16(%rax),%eax
ffffffff80106dbb:	83 c0 01             	add    $0x1,%eax
ffffffff80106dbe:	89 c2                	mov    %eax,%edx
ffffffff80106dc0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106dc4:	66 89 50 16          	mov    %dx,0x16(%rax)
    iupdate(dp);
ffffffff80106dc8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106dcc:	48 89 c7             	mov    %rax,%rdi
ffffffff80106dcf:	e8 7b ae ff ff       	callq  ffffffff80101c4f <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
ffffffff80106dd4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106dd8:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff80106ddb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106ddf:	48 c7 c6 de 9a 10 80 	mov    $0xffffffff80109ade,%rsi
ffffffff80106de6:	48 89 c7             	mov    %rax,%rdi
ffffffff80106de9:	e8 2f ba ff ff       	callq  ffffffff8010281d <dirlink>
ffffffff80106dee:	85 c0                	test   %eax,%eax
ffffffff80106df0:	78 1e                	js     ffffffff80106e10 <create+0x186>
ffffffff80106df2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106df6:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff80106df9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106dfd:	48 c7 c6 e0 9a 10 80 	mov    $0xffffffff80109ae0,%rsi
ffffffff80106e04:	48 89 c7             	mov    %rax,%rdi
ffffffff80106e07:	e8 11 ba ff ff       	callq  ffffffff8010281d <dirlink>
ffffffff80106e0c:	85 c0                	test   %eax,%eax
ffffffff80106e0e:	79 0c                	jns    ffffffff80106e1c <create+0x192>
      panic("create dots");
ffffffff80106e10:	48 c7 c7 13 9b 10 80 	mov    $0xffffffff80109b13,%rdi
ffffffff80106e17:	e8 e2 9a ff ff       	callq  ffffffff801008fe <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
ffffffff80106e1c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106e20:	8b 50 04             	mov    0x4(%rax),%edx
ffffffff80106e23:	48 8d 4d de          	lea    -0x22(%rbp),%rcx
ffffffff80106e27:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106e2b:	48 89 ce             	mov    %rcx,%rsi
ffffffff80106e2e:	48 89 c7             	mov    %rax,%rdi
ffffffff80106e31:	e8 e7 b9 ff ff       	callq  ffffffff8010281d <dirlink>
ffffffff80106e36:	85 c0                	test   %eax,%eax
ffffffff80106e38:	79 0c                	jns    ffffffff80106e46 <create+0x1bc>
    panic("create: dirlink");
ffffffff80106e3a:	48 c7 c7 1f 9b 10 80 	mov    $0xffffffff80109b1f,%rdi
ffffffff80106e41:	e8 b8 9a ff ff       	callq  ffffffff801008fe <panic>

  iunlockput(dp);
ffffffff80106e46:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106e4a:	48 89 c7             	mov    %rax,%rdi
ffffffff80106e4d:	e8 c3 b2 ff ff       	callq  ffffffff80102115 <iunlockput>

  return ip;
ffffffff80106e52:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
ffffffff80106e56:	c9                   	leaveq 
ffffffff80106e57:	c3                   	retq   

ffffffff80106e58 <sys_open>:

int
sys_open(void)
{
ffffffff80106e58:	55                   	push   %rbp
ffffffff80106e59:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106e5c:	48 83 ec 30          	sub    $0x30,%rsp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
ffffffff80106e60:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
ffffffff80106e64:	48 89 c6             	mov    %rax,%rsi
ffffffff80106e67:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80106e6c:	e8 40 f6 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff80106e71:	85 c0                	test   %eax,%eax
ffffffff80106e73:	78 15                	js     ffffffff80106e8a <sys_open+0x32>
ffffffff80106e75:	48 8d 45 dc          	lea    -0x24(%rbp),%rax
ffffffff80106e79:	48 89 c6             	mov    %rax,%rsi
ffffffff80106e7c:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff80106e81:	e8 58 f5 ff ff       	callq  ffffffff801063de <argint>
ffffffff80106e86:	85 c0                	test   %eax,%eax
ffffffff80106e88:	79 0a                	jns    ffffffff80106e94 <sys_open+0x3c>
    return -1;
ffffffff80106e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106e8f:	e9 60 01 00 00       	jmpq   ffffffff80106ff4 <sys_open+0x19c>
  if(omode & O_CREATE){
ffffffff80106e94:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106e97:	25 00 02 00 00       	and    $0x200,%eax
ffffffff80106e9c:	85 c0                	test   %eax,%eax
ffffffff80106e9e:	74 44                	je     ffffffff80106ee4 <sys_open+0x8c>
    begin_trans();
ffffffff80106ea0:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106ea5:	e8 4c cb ff ff       	callq  ffffffff801039f6 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
ffffffff80106eaa:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80106eae:	b9 00 00 00 00       	mov    $0x0,%ecx
ffffffff80106eb3:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80106eb8:	be 02 00 00 00       	mov    $0x2,%esi
ffffffff80106ebd:	48 89 c7             	mov    %rax,%rdi
ffffffff80106ec0:	e8 c5 fd ff ff       	callq  ffffffff80106c8a <create>
ffffffff80106ec5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    commit_trans();
ffffffff80106ec9:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106ece:	e8 6b cb ff ff       	callq  ffffffff80103a3e <commit_trans>
    if(ip == 0)
ffffffff80106ed3:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80106ed8:	75 62                	jne    ffffffff80106f3c <sys_open+0xe4>
      return -1;
ffffffff80106eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106edf:	e9 10 01 00 00       	jmpq   ffffffff80106ff4 <sys_open+0x19c>
  } else {
    if((ip = namei(path)) == 0)
ffffffff80106ee4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80106ee8:	48 89 c7             	mov    %rax,%rdi
ffffffff80106eeb:	e8 26 bc ff ff       	callq  ffffffff80102b16 <namei>
ffffffff80106ef0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff80106ef4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80106ef9:	75 0a                	jne    ffffffff80106f05 <sys_open+0xad>
      return -1;
ffffffff80106efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106f00:	e9 ef 00 00 00       	jmpq   ffffffff80106ff4 <sys_open+0x19c>
    ilock(ip);
ffffffff80106f05:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106f09:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f0c:	e8 3c af ff ff       	callq  ffffffff80101e4d <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
ffffffff80106f11:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106f15:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff80106f19:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80106f1d:	75 1d                	jne    ffffffff80106f3c <sys_open+0xe4>
ffffffff80106f1f:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106f22:	85 c0                	test   %eax,%eax
ffffffff80106f24:	74 16                	je     ffffffff80106f3c <sys_open+0xe4>
      iunlockput(ip);
ffffffff80106f26:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106f2a:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f2d:	e8 e3 b1 ff ff       	callq  ffffffff80102115 <iunlockput>
      return -1;
ffffffff80106f32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106f37:	e9 b8 00 00 00       	jmpq   ffffffff80106ff4 <sys_open+0x19c>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
ffffffff80106f3c:	e8 f9 a4 ff ff       	callq  ffffffff8010143a <filealloc>
ffffffff80106f41:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff80106f45:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106f4a:	74 15                	je     ffffffff80106f61 <sys_open+0x109>
ffffffff80106f4c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106f50:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f53:	e8 e5 f6 ff ff       	callq  ffffffff8010663d <fdalloc>
ffffffff80106f58:	89 45 ec             	mov    %eax,-0x14(%rbp)
ffffffff80106f5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
ffffffff80106f5f:	79 26                	jns    ffffffff80106f87 <sys_open+0x12f>
    if(f)
ffffffff80106f61:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff80106f66:	74 0c                	je     ffffffff80106f74 <sys_open+0x11c>
      fileclose(f);
ffffffff80106f68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106f6c:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f6f:	e8 83 a5 ff ff       	callq  ffffffff801014f7 <fileclose>
    iunlockput(ip);
ffffffff80106f74:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106f78:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f7b:	e8 95 b1 ff ff       	callq  ffffffff80102115 <iunlockput>
    return -1;
ffffffff80106f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80106f85:	eb 6d                	jmp    ffffffff80106ff4 <sys_open+0x19c>
  }
  iunlock(ip);
ffffffff80106f87:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80106f8b:	48 89 c7             	mov    %rax,%rdi
ffffffff80106f8e:	e8 2b b0 ff ff       	callq  ffffffff80101fbe <iunlock>

  f->type = FD_INODE;
ffffffff80106f93:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106f97:	c7 00 02 00 00 00    	movl   $0x2,(%rax)
  f->ip = ip;
ffffffff80106f9d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106fa1:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80106fa5:	48 89 50 18          	mov    %rdx,0x18(%rax)
  f->off = 0;
ffffffff80106fa9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106fad:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%rax)
  f->readable = !(omode & O_WRONLY);
ffffffff80106fb4:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106fb7:	83 e0 01             	and    $0x1,%eax
ffffffff80106fba:	85 c0                	test   %eax,%eax
ffffffff80106fbc:	0f 94 c0             	sete   %al
ffffffff80106fbf:	89 c2                	mov    %eax,%edx
ffffffff80106fc1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106fc5:	88 50 08             	mov    %dl,0x8(%rax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
ffffffff80106fc8:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106fcb:	83 e0 01             	and    $0x1,%eax
ffffffff80106fce:	85 c0                	test   %eax,%eax
ffffffff80106fd0:	75 0a                	jne    ffffffff80106fdc <sys_open+0x184>
ffffffff80106fd2:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80106fd5:	83 e0 02             	and    $0x2,%eax
ffffffff80106fd8:	85 c0                	test   %eax,%eax
ffffffff80106fda:	74 07                	je     ffffffff80106fe3 <sys_open+0x18b>
ffffffff80106fdc:	b8 01 00 00 00       	mov    $0x1,%eax
ffffffff80106fe1:	eb 05                	jmp    ffffffff80106fe8 <sys_open+0x190>
ffffffff80106fe3:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80106fe8:	89 c2                	mov    %eax,%edx
ffffffff80106fea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80106fee:	88 50 09             	mov    %dl,0x9(%rax)
  return fd;
ffffffff80106ff1:	8b 45 ec             	mov    -0x14(%rbp),%eax
}
ffffffff80106ff4:	c9                   	leaveq 
ffffffff80106ff5:	c3                   	retq   

ffffffff80106ff6 <sys_mkdir>:

int
sys_mkdir(void)
{
ffffffff80106ff6:	55                   	push   %rbp
ffffffff80106ff7:	48 89 e5             	mov    %rsp,%rbp
ffffffff80106ffa:	48 83 ec 10          	sub    $0x10,%rsp
  char *path;
  struct inode *ip;

  begin_trans();
ffffffff80106ffe:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80107003:	e8 ee c9 ff ff       	callq  ffffffff801039f6 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
ffffffff80107008:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff8010700c:	48 89 c6             	mov    %rax,%rsi
ffffffff8010700f:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80107014:	e8 98 f4 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff80107019:	85 c0                	test   %eax,%eax
ffffffff8010701b:	78 26                	js     ffffffff80107043 <sys_mkdir+0x4d>
ffffffff8010701d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80107021:	b9 00 00 00 00       	mov    $0x0,%ecx
ffffffff80107026:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff8010702b:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80107030:	48 89 c7             	mov    %rax,%rdi
ffffffff80107033:	e8 52 fc ff ff       	callq  ffffffff80106c8a <create>
ffffffff80107038:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff8010703c:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80107041:	75 11                	jne    ffffffff80107054 <sys_mkdir+0x5e>
    commit_trans();
ffffffff80107043:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80107048:	e8 f1 c9 ff ff       	callq  ffffffff80103a3e <commit_trans>
    return -1;
ffffffff8010704d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107052:	eb 1b                	jmp    ffffffff8010706f <sys_mkdir+0x79>
  }
  iunlockput(ip);
ffffffff80107054:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107058:	48 89 c7             	mov    %rax,%rdi
ffffffff8010705b:	e8 b5 b0 ff ff       	callq  ffffffff80102115 <iunlockput>
  commit_trans();
ffffffff80107060:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80107065:	e8 d4 c9 ff ff       	callq  ffffffff80103a3e <commit_trans>
  return 0;
ffffffff8010706a:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010706f:	c9                   	leaveq 
ffffffff80107070:	c3                   	retq   

ffffffff80107071 <sys_mknod>:

int
sys_mknod(void)
{
ffffffff80107071:	55                   	push   %rbp
ffffffff80107072:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107075:	48 83 ec 20          	sub    $0x20,%rsp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
ffffffff80107079:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010707e:	e8 73 c9 ff ff       	callq  ffffffff801039f6 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
ffffffff80107083:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
ffffffff80107087:	48 89 c6             	mov    %rax,%rsi
ffffffff8010708a:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff8010708f:	e8 1d f4 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff80107094:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80107097:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff8010709b:	78 52                	js     ffffffff801070ef <sys_mknod+0x7e>
     argint(1, &major) < 0 ||
ffffffff8010709d:	48 8d 45 e4          	lea    -0x1c(%rbp),%rax
ffffffff801070a1:	48 89 c6             	mov    %rax,%rsi
ffffffff801070a4:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff801070a9:	e8 30 f3 ff ff       	callq  ffffffff801063de <argint>
  if((len=argstr(0, &path)) < 0 ||
ffffffff801070ae:	85 c0                	test   %eax,%eax
ffffffff801070b0:	78 3d                	js     ffffffff801070ef <sys_mknod+0x7e>
     argint(2, &minor) < 0 ||
ffffffff801070b2:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
ffffffff801070b6:	48 89 c6             	mov    %rax,%rsi
ffffffff801070b9:	bf 02 00 00 00       	mov    $0x2,%edi
ffffffff801070be:	e8 1b f3 ff ff       	callq  ffffffff801063de <argint>
     argint(1, &major) < 0 ||
ffffffff801070c3:	85 c0                	test   %eax,%eax
ffffffff801070c5:	78 28                	js     ffffffff801070ef <sys_mknod+0x7e>
     (ip = create(path, T_DEV, major, minor)) == 0){
ffffffff801070c7:	8b 45 e0             	mov    -0x20(%rbp),%eax
ffffffff801070ca:	0f bf c8             	movswl %ax,%ecx
ffffffff801070cd:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff801070d0:	0f bf d0             	movswl %ax,%edx
ffffffff801070d3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     argint(2, &minor) < 0 ||
ffffffff801070d7:	be 03 00 00 00       	mov    $0x3,%esi
ffffffff801070dc:	48 89 c7             	mov    %rax,%rdi
ffffffff801070df:	e8 a6 fb ff ff       	callq  ffffffff80106c8a <create>
ffffffff801070e4:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
ffffffff801070e8:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff801070ed:	75 11                	jne    ffffffff80107100 <sys_mknod+0x8f>
    commit_trans();
ffffffff801070ef:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801070f4:	e8 45 c9 ff ff       	callq  ffffffff80103a3e <commit_trans>
    return -1;
ffffffff801070f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801070fe:	eb 1b                	jmp    ffffffff8010711b <sys_mknod+0xaa>
  }
  iunlockput(ip);
ffffffff80107100:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80107104:	48 89 c7             	mov    %rax,%rdi
ffffffff80107107:	e8 09 b0 ff ff       	callq  ffffffff80102115 <iunlockput>
  commit_trans();
ffffffff8010710c:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80107111:	e8 28 c9 ff ff       	callq  ffffffff80103a3e <commit_trans>
  return 0;
ffffffff80107116:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff8010711b:	c9                   	leaveq 
ffffffff8010711c:	c3                   	retq   

ffffffff8010711d <sys_chdir>:

int
sys_chdir(void)
{
ffffffff8010711d:	55                   	push   %rbp
ffffffff8010711e:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107121:	48 83 ec 10          	sub    $0x10,%rsp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
ffffffff80107125:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff80107129:	48 89 c6             	mov    %rax,%rsi
ffffffff8010712c:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80107131:	e8 7b f3 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff80107136:	85 c0                	test   %eax,%eax
ffffffff80107138:	78 17                	js     ffffffff80107151 <sys_chdir+0x34>
ffffffff8010713a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010713e:	48 89 c7             	mov    %rax,%rdi
ffffffff80107141:	e8 d0 b9 ff ff       	callq  ffffffff80102b16 <namei>
ffffffff80107146:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff8010714a:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff8010714f:	75 07                	jne    ffffffff80107158 <sys_chdir+0x3b>
    return -1;
ffffffff80107151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107156:	eb 6e                	jmp    ffffffff801071c6 <sys_chdir+0xa9>
  ilock(ip);
ffffffff80107158:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010715c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010715f:	e8 e9 ac ff ff       	callq  ffffffff80101e4d <ilock>
  if(ip->type != T_DIR){
ffffffff80107164:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107168:	0f b7 40 10          	movzwl 0x10(%rax),%eax
ffffffff8010716c:	66 83 f8 01          	cmp    $0x1,%ax
ffffffff80107170:	74 13                	je     ffffffff80107185 <sys_chdir+0x68>
    iunlockput(ip);
ffffffff80107172:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107176:	48 89 c7             	mov    %rax,%rdi
ffffffff80107179:	e8 97 af ff ff       	callq  ffffffff80102115 <iunlockput>
    return -1;
ffffffff8010717e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107183:	eb 41                	jmp    ffffffff801071c6 <sys_chdir+0xa9>
  }
  iunlock(ip);
ffffffff80107185:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107189:	48 89 c7             	mov    %rax,%rdi
ffffffff8010718c:	e8 2d ae ff ff       	callq  ffffffff80101fbe <iunlock>
  iput(proc->cwd);
ffffffff80107191:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107198:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010719c:	48 8b 80 c8 00 00 00 	mov    0xc8(%rax),%rax
ffffffff801071a3:	48 89 c7             	mov    %rax,%rdi
ffffffff801071a6:	e8 85 ae ff ff       	callq  ffffffff80102030 <iput>
  proc->cwd = ip;
ffffffff801071ab:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801071b2:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801071b6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff801071ba:	48 89 90 c8 00 00 00 	mov    %rdx,0xc8(%rax)
  return 0;
ffffffff801071c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801071c6:	c9                   	leaveq 
ffffffff801071c7:	c3                   	retq   

ffffffff801071c8 <sys_exec>:

int
sys_exec(void)
{
ffffffff801071c8:	55                   	push   %rbp
ffffffff801071c9:	48 89 e5             	mov    %rsp,%rbp
ffffffff801071cc:	48 81 ec 20 01 00 00 	sub    $0x120,%rsp
  char *path, *argv[MAXARG];
  int i;
  uintp uargv, uarg;

  if(argstr(0, &path) < 0 || arguintp(1, &uargv) < 0){
ffffffff801071d3:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff801071d7:	48 89 c6             	mov    %rax,%rsi
ffffffff801071da:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff801071df:	e8 cd f2 ff ff       	callq  ffffffff801064b1 <argstr>
ffffffff801071e4:	85 c0                	test   %eax,%eax
ffffffff801071e6:	78 18                	js     ffffffff80107200 <sys_exec+0x38>
ffffffff801071e8:	48 8d 85 e8 fe ff ff 	lea    -0x118(%rbp),%rax
ffffffff801071ef:	48 89 c6             	mov    %rax,%rsi
ffffffff801071f2:	bf 01 00 00 00       	mov    $0x1,%edi
ffffffff801071f7:	e8 0a f2 ff ff       	callq  ffffffff80106406 <arguintp>
ffffffff801071fc:	85 c0                	test   %eax,%eax
ffffffff801071fe:	79 0a                	jns    ffffffff8010720a <sys_exec+0x42>
    return -1;
ffffffff80107200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107205:	e9 d6 00 00 00       	jmpq   ffffffff801072e0 <sys_exec+0x118>
  }
  memset(argv, 0, sizeof(argv));
ffffffff8010720a:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
ffffffff80107211:	ba 00 01 00 00       	mov    $0x100,%edx
ffffffff80107216:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff8010721b:	48 89 c7             	mov    %rax,%rdi
ffffffff8010721e:	e8 8e ec ff ff       	callq  ffffffff80105eb1 <memset>
  for(i=0;; i++){
ffffffff80107223:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    if(i >= NELEM(argv))
ffffffff8010722a:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010722d:	83 f8 1f             	cmp    $0x1f,%eax
ffffffff80107230:	76 0a                	jbe    ffffffff8010723c <sys_exec+0x74>
      return -1;
ffffffff80107232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107237:	e9 a4 00 00 00       	jmpq   ffffffff801072e0 <sys_exec+0x118>
    if(fetchuintp(uargv+sizeof(uintp)*i, &uarg) < 0)
ffffffff8010723c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010723f:	48 98                	cltq   
ffffffff80107241:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80107248:	00 
ffffffff80107249:	48 8b 85 e8 fe ff ff 	mov    -0x118(%rbp),%rax
ffffffff80107250:	48 01 c2             	add    %rax,%rdx
ffffffff80107253:	48 8d 85 e0 fe ff ff 	lea    -0x120(%rbp),%rax
ffffffff8010725a:	48 89 c6             	mov    %rax,%rsi
ffffffff8010725d:	48 89 d7             	mov    %rdx,%rdi
ffffffff80107260:	e8 f3 ef ff ff       	callq  ffffffff80106258 <fetchuintp>
ffffffff80107265:	85 c0                	test   %eax,%eax
ffffffff80107267:	79 07                	jns    ffffffff80107270 <sys_exec+0xa8>
      return -1;
ffffffff80107269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010726e:	eb 70                	jmp    ffffffff801072e0 <sys_exec+0x118>
    if(uarg == 0){
ffffffff80107270:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
ffffffff80107277:	48 85 c0             	test   %rax,%rax
ffffffff8010727a:	75 2a                	jne    ffffffff801072a6 <sys_exec+0xde>
      argv[i] = 0;
ffffffff8010727c:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010727f:	48 98                	cltq   
ffffffff80107281:	48 c7 84 c5 f0 fe ff 	movq   $0x0,-0x110(%rbp,%rax,8)
ffffffff80107288:	ff 00 00 00 00 
      break;
ffffffff8010728d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
ffffffff8010728e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80107292:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
ffffffff80107299:	48 89 d6             	mov    %rdx,%rsi
ffffffff8010729c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010729f:	e8 7b 9c ff ff       	callq  ffffffff80100f1f <exec>
ffffffff801072a4:	eb 3a                	jmp    ffffffff801072e0 <sys_exec+0x118>
    if(fetchstr(uarg, &argv[i]) < 0)
ffffffff801072a6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
ffffffff801072ad:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801072b0:	48 63 d2             	movslq %edx,%rdx
ffffffff801072b3:	48 c1 e2 03          	shl    $0x3,%rdx
ffffffff801072b7:	48 01 c2             	add    %rax,%rdx
ffffffff801072ba:	48 8b 85 e0 fe ff ff 	mov    -0x120(%rbp),%rax
ffffffff801072c1:	48 89 d6             	mov    %rdx,%rsi
ffffffff801072c4:	48 89 c7             	mov    %rax,%rdi
ffffffff801072c7:	e8 e7 ef ff ff       	callq  ffffffff801062b3 <fetchstr>
ffffffff801072cc:	85 c0                	test   %eax,%eax
ffffffff801072ce:	79 07                	jns    ffffffff801072d7 <sys_exec+0x10f>
      return -1;
ffffffff801072d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801072d5:	eb 09                	jmp    ffffffff801072e0 <sys_exec+0x118>
  for(i=0;; i++){
ffffffff801072d7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    if(i >= NELEM(argv))
ffffffff801072db:	e9 4a ff ff ff       	jmpq   ffffffff8010722a <sys_exec+0x62>
}
ffffffff801072e0:	c9                   	leaveq 
ffffffff801072e1:	c3                   	retq   

ffffffff801072e2 <sys_pipe>:

int
sys_pipe(void)
{
ffffffff801072e2:	55                   	push   %rbp
ffffffff801072e3:	48 89 e5             	mov    %rsp,%rbp
ffffffff801072e6:	48 83 ec 20          	sub    $0x20,%rsp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
ffffffff801072ea:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff801072ee:	ba 08 00 00 00       	mov    $0x8,%edx
ffffffff801072f3:	48 89 c6             	mov    %rax,%rsi
ffffffff801072f6:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff801072fb:	e8 30 f1 ff ff       	callq  ffffffff80106430 <argptr>
ffffffff80107300:	85 c0                	test   %eax,%eax
ffffffff80107302:	79 0a                	jns    ffffffff8010730e <sys_pipe+0x2c>
    return -1;
ffffffff80107304:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107309:	e9 b0 00 00 00       	jmpq   ffffffff801073be <sys_pipe+0xdc>
  if(pipealloc(&rf, &wf) < 0)
ffffffff8010730e:	48 8d 55 e0          	lea    -0x20(%rbp),%rdx
ffffffff80107312:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
ffffffff80107316:	48 89 d6             	mov    %rdx,%rsi
ffffffff80107319:	48 89 c7             	mov    %rax,%rdi
ffffffff8010731c:	e8 b5 d5 ff ff       	callq  ffffffff801048d6 <pipealloc>
ffffffff80107321:	85 c0                	test   %eax,%eax
ffffffff80107323:	79 0a                	jns    ffffffff8010732f <sys_pipe+0x4d>
    return -1;
ffffffff80107325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010732a:	e9 8f 00 00 00       	jmpq   ffffffff801073be <sys_pipe+0xdc>
  fd0 = -1;
ffffffff8010732f:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%rbp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
ffffffff80107336:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010733a:	48 89 c7             	mov    %rax,%rdi
ffffffff8010733d:	e8 fb f2 ff ff       	callq  ffffffff8010663d <fdalloc>
ffffffff80107342:	89 45 fc             	mov    %eax,-0x4(%rbp)
ffffffff80107345:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80107349:	78 15                	js     ffffffff80107360 <sys_pipe+0x7e>
ffffffff8010734b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010734f:	48 89 c7             	mov    %rax,%rdi
ffffffff80107352:	e8 e6 f2 ff ff       	callq  ffffffff8010663d <fdalloc>
ffffffff80107357:	89 45 f8             	mov    %eax,-0x8(%rbp)
ffffffff8010735a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
ffffffff8010735e:	79 43                	jns    ffffffff801073a3 <sys_pipe+0xc1>
    if(fd0 >= 0)
ffffffff80107360:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
ffffffff80107364:	78 1e                	js     ffffffff80107384 <sys_pipe+0xa2>
      proc->ofile[fd0] = 0;
ffffffff80107366:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010736d:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107371:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80107374:	48 63 d2             	movslq %edx,%rdx
ffffffff80107377:	48 83 c2 08          	add    $0x8,%rdx
ffffffff8010737b:	48 c7 44 d0 08 00 00 	movq   $0x0,0x8(%rax,%rdx,8)
ffffffff80107382:	00 00 
    fileclose(rf);
ffffffff80107384:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80107388:	48 89 c7             	mov    %rax,%rdi
ffffffff8010738b:	e8 67 a1 ff ff       	callq  ffffffff801014f7 <fileclose>
    fileclose(wf);
ffffffff80107390:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80107394:	48 89 c7             	mov    %rax,%rdi
ffffffff80107397:	e8 5b a1 ff ff       	callq  ffffffff801014f7 <fileclose>
    return -1;
ffffffff8010739c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801073a1:	eb 1b                	jmp    ffffffff801073be <sys_pipe+0xdc>
  }
  fd[0] = fd0;
ffffffff801073a3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801073a7:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801073aa:	89 10                	mov    %edx,(%rax)
  fd[1] = fd1;
ffffffff801073ac:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801073b0:	48 8d 50 04          	lea    0x4(%rax),%rdx
ffffffff801073b4:	8b 45 f8             	mov    -0x8(%rbp),%eax
ffffffff801073b7:	89 02                	mov    %eax,(%rdx)
  return 0;
ffffffff801073b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801073be:	c9                   	leaveq 
ffffffff801073bf:	c3                   	retq   

ffffffff801073c0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
ffffffff801073c0:	55                   	push   %rbp
ffffffff801073c1:	48 89 e5             	mov    %rsp,%rbp
  return fork();
ffffffff801073c4:	e8 be dc ff ff       	callq  ffffffff80105087 <fork>
}
ffffffff801073c9:	5d                   	pop    %rbp
ffffffff801073ca:	c3                   	retq   

ffffffff801073cb <sys_exit>:

int
sys_exit(void)
{
ffffffff801073cb:	55                   	push   %rbp
ffffffff801073cc:	48 89 e5             	mov    %rsp,%rbp
  exit();
ffffffff801073cf:	e8 45 df ff ff       	callq  ffffffff80105319 <exit>
  return 0;  // not reached
ffffffff801073d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff801073d9:	5d                   	pop    %rbp
ffffffff801073da:	c3                   	retq   

ffffffff801073db <sys_wait>:

int
sys_wait(void)
{
ffffffff801073db:	55                   	push   %rbp
ffffffff801073dc:	48 89 e5             	mov    %rsp,%rbp
  return wait();
ffffffff801073df:	e8 a6 e0 ff ff       	callq  ffffffff8010548a <wait>
}
ffffffff801073e4:	5d                   	pop    %rbp
ffffffff801073e5:	c3                   	retq   

ffffffff801073e6 <sys_kill>:

int
sys_kill(void)
{
ffffffff801073e6:	55                   	push   %rbp
ffffffff801073e7:	48 89 e5             	mov    %rsp,%rbp
ffffffff801073ea:	48 83 ec 10          	sub    $0x10,%rsp
  int pid;

  if(argint(0, &pid) < 0)
ffffffff801073ee:	48 8d 45 fc          	lea    -0x4(%rbp),%rax
ffffffff801073f2:	48 89 c6             	mov    %rax,%rsi
ffffffff801073f5:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff801073fa:	e8 df ef ff ff       	callq  ffffffff801063de <argint>
ffffffff801073ff:	85 c0                	test   %eax,%eax
ffffffff80107401:	79 07                	jns    ffffffff8010740a <sys_kill+0x24>
    return -1;
ffffffff80107403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107408:	eb 0a                	jmp    ffffffff80107414 <sys_kill+0x2e>
  return kill(pid);
ffffffff8010740a:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff8010740d:	89 c7                	mov    %eax,%edi
ffffffff8010740f:	e8 02 e5 ff ff       	callq  ffffffff80105916 <kill>
}
ffffffff80107414:	c9                   	leaveq 
ffffffff80107415:	c3                   	retq   

ffffffff80107416 <sys_getpid>:

int
sys_getpid(void)
{
ffffffff80107416:	55                   	push   %rbp
ffffffff80107417:	48 89 e5             	mov    %rsp,%rbp
  return proc->pid;
ffffffff8010741a:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107421:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107425:	8b 40 1c             	mov    0x1c(%rax),%eax
}
ffffffff80107428:	5d                   	pop    %rbp
ffffffff80107429:	c3                   	retq   

ffffffff8010742a <sys_sbrk>:

uintp
sys_sbrk(void)
{
ffffffff8010742a:	55                   	push   %rbp
ffffffff8010742b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010742e:	48 83 ec 10          	sub    $0x10,%rsp
  uintp addr;
  uintp n;

  if(arguintp(0, &n) < 0)
ffffffff80107432:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
ffffffff80107436:	48 89 c6             	mov    %rax,%rsi
ffffffff80107439:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff8010743e:	e8 c3 ef ff ff       	callq  ffffffff80106406 <arguintp>
ffffffff80107443:	85 c0                	test   %eax,%eax
ffffffff80107445:	79 09                	jns    ffffffff80107450 <sys_sbrk+0x26>
    return -1;
ffffffff80107447:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
ffffffff8010744e:	eb 2e                	jmp    ffffffff8010747e <sys_sbrk+0x54>
  addr = proc->sz;
ffffffff80107450:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107457:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010745b:	48 8b 00             	mov    (%rax),%rax
ffffffff8010745e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(growproc(n) < 0)
ffffffff80107462:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80107466:	89 c7                	mov    %eax,%edi
ffffffff80107468:	e8 5c db ff ff       	callq  ffffffff80104fc9 <growproc>
ffffffff8010746d:	85 c0                	test   %eax,%eax
ffffffff8010746f:	79 09                	jns    ffffffff8010747a <sys_sbrk+0x50>
    return -1;
ffffffff80107471:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
ffffffff80107478:	eb 04                	jmp    ffffffff8010747e <sys_sbrk+0x54>
  return addr;
ffffffff8010747a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff8010747e:	c9                   	leaveq 
ffffffff8010747f:	c3                   	retq   

ffffffff80107480 <sys_sleep>:

int
sys_sleep(void)
{
ffffffff80107480:	55                   	push   %rbp
ffffffff80107481:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107484:	48 83 ec 10          	sub    $0x10,%rsp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
ffffffff80107488:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
ffffffff8010748c:	48 89 c6             	mov    %rax,%rsi
ffffffff8010748f:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80107494:	e8 45 ef ff ff       	callq  ffffffff801063de <argint>
ffffffff80107499:	85 c0                	test   %eax,%eax
ffffffff8010749b:	79 07                	jns    ffffffff801074a4 <sys_sleep+0x24>
    return -1;
ffffffff8010749d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801074a2:	eb 70                	jmp    ffffffff80107514 <sys_sleep+0x94>
  acquire(&tickslock);
ffffffff801074a4:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff801074ab:	e8 92 e6 ff ff       	callq  ffffffff80105b42 <acquire>
  ticks0 = ticks;
ffffffff801074b0:	8b 05 32 c0 00 00    	mov    0xc032(%rip),%eax        # ffffffff801134e8 <ticks>
ffffffff801074b6:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while(ticks - ticks0 < n){
ffffffff801074b9:	eb 38                	jmp    ffffffff801074f3 <sys_sleep+0x73>
    if(proc->killed){
ffffffff801074bb:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801074c2:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801074c6:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff801074c9:	85 c0                	test   %eax,%eax
ffffffff801074cb:	74 13                	je     ffffffff801074e0 <sys_sleep+0x60>
      release(&tickslock);
ffffffff801074cd:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff801074d4:	e8 40 e7 ff ff       	callq  ffffffff80105c19 <release>
      return -1;
ffffffff801074d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801074de:	eb 34                	jmp    ffffffff80107514 <sys_sleep+0x94>
    }
    sleep(&ticks, &tickslock);
ffffffff801074e0:	48 c7 c6 80 34 11 80 	mov    $0xffffffff80113480,%rsi
ffffffff801074e7:	48 c7 c7 e8 34 11 80 	mov    $0xffffffff801134e8,%rdi
ffffffff801074ee:	e8 dd e2 ff ff       	callq  ffffffff801057d0 <sleep>
  while(ticks - ticks0 < n){
ffffffff801074f3:	8b 05 ef bf 00 00    	mov    0xbfef(%rip),%eax        # ffffffff801134e8 <ticks>
ffffffff801074f9:	2b 45 fc             	sub    -0x4(%rbp),%eax
ffffffff801074fc:	8b 55 f8             	mov    -0x8(%rbp),%edx
ffffffff801074ff:	39 d0                	cmp    %edx,%eax
ffffffff80107501:	72 b8                	jb     ffffffff801074bb <sys_sleep+0x3b>
  }
  release(&tickslock);
ffffffff80107503:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff8010750a:	e8 0a e7 ff ff       	callq  ffffffff80105c19 <release>
  return 0;
ffffffff8010750f:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80107514:	c9                   	leaveq 
ffffffff80107515:	c3                   	retq   

ffffffff80107516 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
ffffffff80107516:	55                   	push   %rbp
ffffffff80107517:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010751a:	48 83 ec 10          	sub    $0x10,%rsp
  uint xticks;
  
  acquire(&tickslock);
ffffffff8010751e:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff80107525:	e8 18 e6 ff ff       	callq  ffffffff80105b42 <acquire>
  xticks = ticks;
ffffffff8010752a:	8b 05 b8 bf 00 00    	mov    0xbfb8(%rip),%eax        # ffffffff801134e8 <ticks>
ffffffff80107530:	89 45 fc             	mov    %eax,-0x4(%rbp)
  release(&tickslock);
ffffffff80107533:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff8010753a:	e8 da e6 ff ff       	callq  ffffffff80105c19 <release>
  return xticks;
ffffffff8010753f:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
ffffffff80107542:	c9                   	leaveq 
ffffffff80107543:	c3                   	retq   

ffffffff80107544 <outb>:
{
ffffffff80107544:	55                   	push   %rbp
ffffffff80107545:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107548:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010754c:	89 fa                	mov    %edi,%edx
ffffffff8010754e:	89 f0                	mov    %esi,%eax
ffffffff80107550:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff80107554:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80107557:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff8010755b:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff8010755f:	ee                   	out    %al,(%dx)
}
ffffffff80107560:	90                   	nop
ffffffff80107561:	c9                   	leaveq 
ffffffff80107562:	c3                   	retq   

ffffffff80107563 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
ffffffff80107563:	55                   	push   %rbp
ffffffff80107564:	48 89 e5             	mov    %rsp,%rbp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
ffffffff80107567:	be 34 00 00 00       	mov    $0x34,%esi
ffffffff8010756c:	bf 43 00 00 00       	mov    $0x43,%edi
ffffffff80107571:	e8 ce ff ff ff       	callq  ffffffff80107544 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
ffffffff80107576:	be 9c 00 00 00       	mov    $0x9c,%esi
ffffffff8010757b:	bf 40 00 00 00       	mov    $0x40,%edi
ffffffff80107580:	e8 bf ff ff ff       	callq  ffffffff80107544 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
ffffffff80107585:	be 2e 00 00 00       	mov    $0x2e,%esi
ffffffff8010758a:	bf 40 00 00 00       	mov    $0x40,%edi
ffffffff8010758f:	e8 b0 ff ff ff       	callq  ffffffff80107544 <outb>
  picenable(IRQ_TIMER);
ffffffff80107594:	bf 00 00 00 00       	mov    $0x0,%edi
ffffffff80107599:	e8 0e d2 ff ff       	callq  ffffffff801047ac <picenable>
}
ffffffff8010759e:	90                   	nop
ffffffff8010759f:	5d                   	pop    %rbp
ffffffff801075a0:	c3                   	retq   

ffffffff801075a1 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  push %r15
ffffffff801075a1:	41 57                	push   %r15
  push %r14
ffffffff801075a3:	41 56                	push   %r14
  push %r13
ffffffff801075a5:	41 55                	push   %r13
  push %r12
ffffffff801075a7:	41 54                	push   %r12
  push %r11
ffffffff801075a9:	41 53                	push   %r11
  push %r10
ffffffff801075ab:	41 52                	push   %r10
  push %r9
ffffffff801075ad:	41 51                	push   %r9
  push %r8
ffffffff801075af:	41 50                	push   %r8
  push %rdi
ffffffff801075b1:	57                   	push   %rdi
  push %rsi
ffffffff801075b2:	56                   	push   %rsi
  push %rbp
ffffffff801075b3:	55                   	push   %rbp
  push %rdx
ffffffff801075b4:	52                   	push   %rdx
  push %rcx
ffffffff801075b5:	51                   	push   %rcx
  push %rbx
ffffffff801075b6:	53                   	push   %rbx
  push %rax
ffffffff801075b7:	50                   	push   %rax

  mov  %rsp, %rdi  # frame in arg1
ffffffff801075b8:	48 89 e7             	mov    %rsp,%rdi
  call trap
ffffffff801075bb:	e8 32 00 00 00       	callq  ffffffff801075f2 <trap>

ffffffff801075c0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  pop %rax
ffffffff801075c0:	58                   	pop    %rax
  pop %rbx
ffffffff801075c1:	5b                   	pop    %rbx
  pop %rcx
ffffffff801075c2:	59                   	pop    %rcx
  pop %rdx
ffffffff801075c3:	5a                   	pop    %rdx
  pop %rbp
ffffffff801075c4:	5d                   	pop    %rbp
  pop %rsi
ffffffff801075c5:	5e                   	pop    %rsi
  pop %rdi
ffffffff801075c6:	5f                   	pop    %rdi
  pop %r8
ffffffff801075c7:	41 58                	pop    %r8
  pop %r9
ffffffff801075c9:	41 59                	pop    %r9
  pop %r10
ffffffff801075cb:	41 5a                	pop    %r10
  pop %r11
ffffffff801075cd:	41 5b                	pop    %r11
  pop %r12
ffffffff801075cf:	41 5c                	pop    %r12
  pop %r13
ffffffff801075d1:	41 5d                	pop    %r13
  pop %r14
ffffffff801075d3:	41 5e                	pop    %r14
  pop %r15
ffffffff801075d5:	41 5f                	pop    %r15

  # discard trapnum and errorcode
  add $16, %rsp
ffffffff801075d7:	48 83 c4 10          	add    $0x10,%rsp
  iretq
ffffffff801075db:	48 cf                	iretq  

ffffffff801075dd <rcr2>:

static inline uintp
rcr2(void)
{
ffffffff801075dd:	55                   	push   %rbp
ffffffff801075de:	48 89 e5             	mov    %rsp,%rbp
ffffffff801075e1:	48 83 ec 10          	sub    $0x10,%rsp
  uintp val;
  asm volatile("mov %%cr2,%0" : "=r" (val));
ffffffff801075e5:	0f 20 d0             	mov    %cr2,%rax
ffffffff801075e8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  return val;
ffffffff801075ec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
ffffffff801075f0:	c9                   	leaveq 
ffffffff801075f1:	c3                   	retq   

ffffffff801075f2 <trap>:
#endif

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
ffffffff801075f2:	55                   	push   %rbp
ffffffff801075f3:	48 89 e5             	mov    %rsp,%rbp
ffffffff801075f6:	48 83 ec 10          	sub    $0x10,%rsp
ffffffff801075fa:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  if(tf->trapno == T_SYSCALL){
ffffffff801075fe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107602:	48 8b 40 78          	mov    0x78(%rax),%rax
ffffffff80107606:	48 83 f8 40          	cmp    $0x40,%rax
ffffffff8010760a:	75 4f                	jne    ffffffff8010765b <trap+0x69>
    if(proc->killed)
ffffffff8010760c:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107613:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107617:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff8010761a:	85 c0                	test   %eax,%eax
ffffffff8010761c:	74 05                	je     ffffffff80107623 <trap+0x31>
      exit();
ffffffff8010761e:	e8 f6 dc ff ff       	callq  ffffffff80105319 <exit>
    proc->tf = tf;
ffffffff80107623:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff8010762a:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010762e:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80107632:	48 89 50 28          	mov    %rdx,0x28(%rax)
    syscall();
ffffffff80107636:	e8 b6 ee ff ff       	callq  ffffffff801064f1 <syscall>
    if(proc->killed)
ffffffff8010763b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107642:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107646:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff80107649:	85 c0                	test   %eax,%eax
ffffffff8010764b:	0f 84 9d 02 00 00    	je     ffffffff801078ee <trap+0x2fc>
      exit();
ffffffff80107651:	e8 c3 dc ff ff       	callq  ffffffff80105319 <exit>
    return;
ffffffff80107656:	e9 93 02 00 00       	jmpq   ffffffff801078ee <trap+0x2fc>
  }

  switch(tf->trapno){
ffffffff8010765b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010765f:	48 8b 40 78          	mov    0x78(%rax),%rax
ffffffff80107663:	48 83 e8 20          	sub    $0x20,%rax
ffffffff80107667:	48 83 f8 1f          	cmp    $0x1f,%rax
ffffffff8010766b:	0f 87 ca 00 00 00    	ja     ffffffff8010773b <trap+0x149>
ffffffff80107671:	48 8b 04 c5 d8 9b 10 	mov    -0x7fef6428(,%rax,8),%rax
ffffffff80107678:	80 
ffffffff80107679:	ff e0                	jmpq   *%rax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
ffffffff8010767b:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80107682:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107686:	0f b6 00             	movzbl (%rax),%eax
ffffffff80107689:	84 c0                	test   %al,%al
ffffffff8010768b:	75 33                	jne    ffffffff801076c0 <trap+0xce>
      acquire(&tickslock);
ffffffff8010768d:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff80107694:	e8 a9 e4 ff ff       	callq  ffffffff80105b42 <acquire>
      ticks++;
ffffffff80107699:	8b 05 49 be 00 00    	mov    0xbe49(%rip),%eax        # ffffffff801134e8 <ticks>
ffffffff8010769f:	83 c0 01             	add    $0x1,%eax
ffffffff801076a2:	89 05 40 be 00 00    	mov    %eax,0xbe40(%rip)        # ffffffff801134e8 <ticks>
      wakeup(&ticks);
ffffffff801076a8:	48 c7 c7 e8 34 11 80 	mov    $0xffffffff801134e8,%rdi
ffffffff801076af:	e8 2f e2 ff ff       	callq  ffffffff801058e3 <wakeup>
      release(&tickslock);
ffffffff801076b4:	48 c7 c7 80 34 11 80 	mov    $0xffffffff80113480,%rdi
ffffffff801076bb:	e8 59 e5 ff ff       	callq  ffffffff80105c19 <release>
    }
    lapiceoi();
ffffffff801076c0:	e8 e8 bf ff ff       	callq  ffffffff801036ad <lapiceoi>
    break;
ffffffff801076c5:	e9 76 01 00 00       	jmpq   ffffffff80107840 <trap+0x24e>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
ffffffff801076ca:	e8 19 b7 ff ff       	callq  ffffffff80102de8 <ideintr>
    lapiceoi();
ffffffff801076cf:	e8 d9 bf ff ff       	callq  ffffffff801036ad <lapiceoi>
    break;
ffffffff801076d4:	e9 67 01 00 00       	jmpq   ffffffff80107840 <trap+0x24e>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
ffffffff801076d9:	e8 85 bd ff ff       	callq  ffffffff80103463 <kbdintr>
    lapiceoi();
ffffffff801076de:	e8 ca bf ff ff       	callq  ffffffff801036ad <lapiceoi>
    break;
ffffffff801076e3:	e9 58 01 00 00       	jmpq   ffffffff80107840 <trap+0x24e>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
ffffffff801076e8:	e8 d6 03 00 00       	callq  ffffffff80107ac3 <uartintr>
    lapiceoi();
ffffffff801076ed:	e8 bb bf ff ff       	callq  ffffffff801036ad <lapiceoi>
    break;
ffffffff801076f2:	e9 49 01 00 00       	jmpq   ffffffff80107840 <trap+0x24e>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
ffffffff801076f7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801076fb:	48 8b 88 88 00 00 00 	mov    0x88(%rax),%rcx
ffffffff80107702:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107706:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
            cpu->id, tf->cs, tf->eip);
ffffffff8010770d:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80107714:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107718:	0f b6 00             	movzbl (%rax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
ffffffff8010771b:	0f b6 c0             	movzbl %al,%eax
ffffffff8010771e:	89 c6                	mov    %eax,%esi
ffffffff80107720:	48 c7 c7 30 9b 10 80 	mov    $0xffffffff80109b30,%rdi
ffffffff80107727:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010772c:	e8 70 8e ff ff       	callq  ffffffff801005a1 <cprintf>
    lapiceoi();
ffffffff80107731:	e8 77 bf ff ff       	callq  ffffffff801036ad <lapiceoi>
    break;
ffffffff80107736:	e9 05 01 00 00       	jmpq   ffffffff80107840 <trap+0x24e>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
ffffffff8010773b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107742:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107746:	48 85 c0             	test   %rax,%rax
ffffffff80107749:	74 13                	je     ffffffff8010775e <trap+0x16c>
ffffffff8010774b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010774f:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
ffffffff80107756:	83 e0 03             	and    $0x3,%eax
ffffffff80107759:	48 85 c0             	test   %rax,%rax
ffffffff8010775c:	75 4f                	jne    ffffffff801077ad <trap+0x1bb>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
ffffffff8010775e:	e8 7a fe ff ff       	callq  ffffffff801075dd <rcr2>
ffffffff80107763:	48 89 c6             	mov    %rax,%rsi
ffffffff80107766:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010776a:	48 8b 88 88 00 00 00 	mov    0x88(%rax),%rcx
              tf->trapno, cpu->id, tf->eip, rcr2());
ffffffff80107771:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff80107778:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010777c:	0f b6 00             	movzbl (%rax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
ffffffff8010777f:	0f b6 d0             	movzbl %al,%edx
ffffffff80107782:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107786:	48 8b 40 78          	mov    0x78(%rax),%rax
ffffffff8010778a:	49 89 f0             	mov    %rsi,%r8
ffffffff8010778d:	48 89 c6             	mov    %rax,%rsi
ffffffff80107790:	48 c7 c7 58 9b 10 80 	mov    $0xffffffff80109b58,%rdi
ffffffff80107797:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff8010779c:	e8 00 8e ff ff       	callq  ffffffff801005a1 <cprintf>
      panic("trap");
ffffffff801077a1:	48 c7 c7 8a 9b 10 80 	mov    $0xffffffff80109b8a,%rdi
ffffffff801077a8:	e8 51 91 ff ff       	callq  ffffffff801008fe <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
ffffffff801077ad:	e8 2b fe ff ff       	callq  ffffffff801075dd <rcr2>
ffffffff801077b2:	49 89 c1             	mov    %rax,%r9
ffffffff801077b5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801077b9:	48 8b 88 88 00 00 00 	mov    0x88(%rax),%rcx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
ffffffff801077c0:	48 c7 c0 f0 ff ff ff 	mov    $0xfffffffffffffff0,%rax
ffffffff801077c7:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801077cb:	0f b6 00             	movzbl (%rax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
ffffffff801077ce:	44 0f b6 c0          	movzbl %al,%r8d
ffffffff801077d2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801077d6:	48 8b b8 80 00 00 00 	mov    0x80(%rax),%rdi
ffffffff801077dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801077e1:	48 8b 50 78          	mov    0x78(%rax),%rdx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
ffffffff801077e5:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801077ec:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801077f0:	48 8d b0 d0 00 00 00 	lea    0xd0(%rax),%rsi
ffffffff801077f7:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801077fe:	64 48 8b 00          	mov    %fs:(%rax),%rax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
ffffffff80107802:	8b 40 1c             	mov    0x1c(%rax),%eax
ffffffff80107805:	41 51                	push   %r9
ffffffff80107807:	51                   	push   %rcx
ffffffff80107808:	45 89 c1             	mov    %r8d,%r9d
ffffffff8010780b:	49 89 f8             	mov    %rdi,%r8
ffffffff8010780e:	48 89 d1             	mov    %rdx,%rcx
ffffffff80107811:	48 89 f2             	mov    %rsi,%rdx
ffffffff80107814:	89 c6                	mov    %eax,%esi
ffffffff80107816:	48 c7 c7 90 9b 10 80 	mov    $0xffffffff80109b90,%rdi
ffffffff8010781d:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80107822:	e8 7a 8d ff ff       	callq  ffffffff801005a1 <cprintf>
ffffffff80107827:	48 83 c4 10          	add    $0x10,%rsp
            rcr2());
    proc->killed = 1;
ffffffff8010782b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107832:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107836:	c7 40 40 01 00 00 00 	movl   $0x1,0x40(%rax)
ffffffff8010783d:	eb 01                	jmp    ffffffff80107840 <trap+0x24e>
    break;
ffffffff8010783f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
ffffffff80107840:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107847:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010784b:	48 85 c0             	test   %rax,%rax
ffffffff8010784e:	74 2b                	je     ffffffff8010787b <trap+0x289>
ffffffff80107850:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107857:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff8010785b:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff8010785e:	85 c0                	test   %eax,%eax
ffffffff80107860:	74 19                	je     ffffffff8010787b <trap+0x289>
ffffffff80107862:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80107866:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
ffffffff8010786d:	83 e0 03             	and    $0x3,%eax
ffffffff80107870:	48 83 f8 03          	cmp    $0x3,%rax
ffffffff80107874:	75 05                	jne    ffffffff8010787b <trap+0x289>
    exit();
ffffffff80107876:	e8 9e da ff ff       	callq  ffffffff80105319 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
ffffffff8010787b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107882:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107886:	48 85 c0             	test   %rax,%rax
ffffffff80107889:	74 26                	je     ffffffff801078b1 <trap+0x2bf>
ffffffff8010788b:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff80107892:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff80107896:	8b 40 18             	mov    0x18(%rax),%eax
ffffffff80107899:	83 f8 04             	cmp    $0x4,%eax
ffffffff8010789c:	75 13                	jne    ffffffff801078b1 <trap+0x2bf>
ffffffff8010789e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801078a2:	48 8b 40 78          	mov    0x78(%rax),%rax
ffffffff801078a6:	48 83 f8 20          	cmp    $0x20,%rax
ffffffff801078aa:	75 05                	jne    ffffffff801078b1 <trap+0x2bf>
    yield();
ffffffff801078ac:	e8 bd de ff ff       	callq  ffffffff8010576e <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
ffffffff801078b1:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801078b8:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801078bc:	48 85 c0             	test   %rax,%rax
ffffffff801078bf:	74 2e                	je     ffffffff801078ef <trap+0x2fd>
ffffffff801078c1:	48 c7 c0 f8 ff ff ff 	mov    $0xfffffffffffffff8,%rax
ffffffff801078c8:	64 48 8b 00          	mov    %fs:(%rax),%rax
ffffffff801078cc:	8b 40 40             	mov    0x40(%rax),%eax
ffffffff801078cf:	85 c0                	test   %eax,%eax
ffffffff801078d1:	74 1c                	je     ffffffff801078ef <trap+0x2fd>
ffffffff801078d3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801078d7:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
ffffffff801078de:	83 e0 03             	and    $0x3,%eax
ffffffff801078e1:	48 83 f8 03          	cmp    $0x3,%rax
ffffffff801078e5:	75 08                	jne    ffffffff801078ef <trap+0x2fd>
    exit();
ffffffff801078e7:	e8 2d da ff ff       	callq  ffffffff80105319 <exit>
ffffffff801078ec:	eb 01                	jmp    ffffffff801078ef <trap+0x2fd>
    return;
ffffffff801078ee:	90                   	nop
}
ffffffff801078ef:	c9                   	leaveq 
ffffffff801078f0:	c3                   	retq   

ffffffff801078f1 <inb>:
{
ffffffff801078f1:	55                   	push   %rbp
ffffffff801078f2:	48 89 e5             	mov    %rsp,%rbp
ffffffff801078f5:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff801078f9:	89 f8                	mov    %edi,%eax
ffffffff801078fb:	66 89 45 ec          	mov    %ax,-0x14(%rbp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
ffffffff801078ff:	0f b7 45 ec          	movzwl -0x14(%rbp),%eax
ffffffff80107903:	89 c2                	mov    %eax,%edx
ffffffff80107905:	ec                   	in     (%dx),%al
ffffffff80107906:	88 45 ff             	mov    %al,-0x1(%rbp)
  return data;
ffffffff80107909:	0f b6 45 ff          	movzbl -0x1(%rbp),%eax
}
ffffffff8010790d:	c9                   	leaveq 
ffffffff8010790e:	c3                   	retq   

ffffffff8010790f <outb>:
{
ffffffff8010790f:	55                   	push   %rbp
ffffffff80107910:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107913:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80107917:	89 fa                	mov    %edi,%edx
ffffffff80107919:	89 f0                	mov    %esi,%eax
ffffffff8010791b:	66 89 55 fc          	mov    %dx,-0x4(%rbp)
ffffffff8010791f:	88 45 f8             	mov    %al,-0x8(%rbp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
ffffffff80107922:	0f b6 45 f8          	movzbl -0x8(%rbp),%eax
ffffffff80107926:	0f b7 55 fc          	movzwl -0x4(%rbp),%edx
ffffffff8010792a:	ee                   	out    %al,(%dx)
}
ffffffff8010792b:	90                   	nop
ffffffff8010792c:	c9                   	leaveq 
ffffffff8010792d:	c3                   	retq   

ffffffff8010792e <uartearlyinit>:

static int uart;    // is there a uart?

void
uartearlyinit(void)
{
ffffffff8010792e:	55                   	push   %rbp
ffffffff8010792f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107932:	48 83 ec 10          	sub    $0x10,%rsp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
ffffffff80107936:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff8010793b:	bf fa 03 00 00       	mov    $0x3fa,%edi
ffffffff80107940:	e8 ca ff ff ff       	callq  ffffffff8010790f <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
ffffffff80107945:	be 80 00 00 00       	mov    $0x80,%esi
ffffffff8010794a:	bf fb 03 00 00       	mov    $0x3fb,%edi
ffffffff8010794f:	e8 bb ff ff ff       	callq  ffffffff8010790f <outb>
  outb(COM1+0, 115200/9600);
ffffffff80107954:	be 0c 00 00 00       	mov    $0xc,%esi
ffffffff80107959:	bf f8 03 00 00       	mov    $0x3f8,%edi
ffffffff8010795e:	e8 ac ff ff ff       	callq  ffffffff8010790f <outb>
  outb(COM1+1, 0);
ffffffff80107963:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80107968:	bf f9 03 00 00       	mov    $0x3f9,%edi
ffffffff8010796d:	e8 9d ff ff ff       	callq  ffffffff8010790f <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
ffffffff80107972:	be 03 00 00 00       	mov    $0x3,%esi
ffffffff80107977:	bf fb 03 00 00       	mov    $0x3fb,%edi
ffffffff8010797c:	e8 8e ff ff ff       	callq  ffffffff8010790f <outb>
  outb(COM1+4, 0);
ffffffff80107981:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80107986:	bf fc 03 00 00       	mov    $0x3fc,%edi
ffffffff8010798b:	e8 7f ff ff ff       	callq  ffffffff8010790f <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
ffffffff80107990:	be 01 00 00 00       	mov    $0x1,%esi
ffffffff80107995:	bf f9 03 00 00       	mov    $0x3f9,%edi
ffffffff8010799a:	e8 70 ff ff ff       	callq  ffffffff8010790f <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
ffffffff8010799f:	bf fd 03 00 00       	mov    $0x3fd,%edi
ffffffff801079a4:	e8 48 ff ff ff       	callq  ffffffff801078f1 <inb>
ffffffff801079a9:	3c ff                	cmp    $0xff,%al
ffffffff801079ab:	74 37                	je     ffffffff801079e4 <uartearlyinit+0xb6>
    return;
  uart = 1;
ffffffff801079ad:	c7 05 35 bb 00 00 01 	movl   $0x1,0xbb35(%rip)        # ffffffff801134ec <uart>
ffffffff801079b4:	00 00 00 

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
ffffffff801079b7:	48 c7 45 f8 d8 9c 10 	movq   $0xffffffff80109cd8,-0x8(%rbp)
ffffffff801079be:	80 
ffffffff801079bf:	eb 16                	jmp    ffffffff801079d7 <uartearlyinit+0xa9>
    uartputc(*p);
ffffffff801079c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801079c5:	0f b6 00             	movzbl (%rax),%eax
ffffffff801079c8:	0f be c0             	movsbl %al,%eax
ffffffff801079cb:	89 c7                	mov    %eax,%edi
ffffffff801079cd:	e8 55 00 00 00       	callq  ffffffff80107a27 <uartputc>
  for(p="xv6...\n"; *p; p++)
ffffffff801079d2:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
ffffffff801079d7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801079db:	0f b6 00             	movzbl (%rax),%eax
ffffffff801079de:	84 c0                	test   %al,%al
ffffffff801079e0:	75 df                	jne    ffffffff801079c1 <uartearlyinit+0x93>
ffffffff801079e2:	eb 01                	jmp    ffffffff801079e5 <uartearlyinit+0xb7>
    return;
ffffffff801079e4:	90                   	nop
}
ffffffff801079e5:	c9                   	leaveq 
ffffffff801079e6:	c3                   	retq   

ffffffff801079e7 <uartinit>:

void
uartinit(void)
{
ffffffff801079e7:	55                   	push   %rbp
ffffffff801079e8:	48 89 e5             	mov    %rsp,%rbp
  if (!uart)
ffffffff801079eb:	8b 05 fb ba 00 00    	mov    0xbafb(%rip),%eax        # ffffffff801134ec <uart>
ffffffff801079f1:	85 c0                	test   %eax,%eax
ffffffff801079f3:	74 2f                	je     ffffffff80107a24 <uartinit+0x3d>
    return;

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
ffffffff801079f5:	bf fa 03 00 00       	mov    $0x3fa,%edi
ffffffff801079fa:	e8 f2 fe ff ff       	callq  ffffffff801078f1 <inb>
  inb(COM1+0);
ffffffff801079ff:	bf f8 03 00 00       	mov    $0x3f8,%edi
ffffffff80107a04:	e8 e8 fe ff ff       	callq  ffffffff801078f1 <inb>
  picenable(IRQ_COM1);
ffffffff80107a09:	bf 04 00 00 00       	mov    $0x4,%edi
ffffffff80107a0e:	e8 99 cd ff ff       	callq  ffffffff801047ac <picenable>
  ioapicenable(IRQ_COM1, 0);
ffffffff80107a13:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80107a18:	bf 04 00 00 00       	mov    $0x4,%edi
ffffffff80107a1d:	e8 93 b6 ff ff       	callq  ffffffff801030b5 <ioapicenable>
ffffffff80107a22:	eb 01                	jmp    ffffffff80107a25 <uartinit+0x3e>
    return;
ffffffff80107a24:	90                   	nop
}
ffffffff80107a25:	5d                   	pop    %rbp
ffffffff80107a26:	c3                   	retq   

ffffffff80107a27 <uartputc>:

void
uartputc(int c)
{
ffffffff80107a27:	55                   	push   %rbp
ffffffff80107a28:	48 89 e5             	mov    %rsp,%rbp
ffffffff80107a2b:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80107a2f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  int i;

  if(!uart)
ffffffff80107a32:	8b 05 b4 ba 00 00    	mov    0xbab4(%rip),%eax        # ffffffff801134ec <uart>
ffffffff80107a38:	85 c0                	test   %eax,%eax
ffffffff80107a3a:	74 45                	je     ffffffff80107a81 <uartputc+0x5a>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
ffffffff80107a3c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80107a43:	eb 0e                	jmp    ffffffff80107a53 <uartputc+0x2c>
    microdelay(10);
ffffffff80107a45:	bf 0a 00 00 00       	mov    $0xa,%edi
ffffffff80107a4a:	e8 80 bc ff ff       	callq  ffffffff801036cf <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
ffffffff80107a4f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80107a53:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%rbp)
ffffffff80107a57:	7f 14                	jg     ffffffff80107a6d <uartputc+0x46>
ffffffff80107a59:	bf fd 03 00 00       	mov    $0x3fd,%edi
ffffffff80107a5e:	e8 8e fe ff ff       	callq  ffffffff801078f1 <inb>
ffffffff80107a63:	0f b6 c0             	movzbl %al,%eax
ffffffff80107a66:	83 e0 20             	and    $0x20,%eax
ffffffff80107a69:	85 c0                	test   %eax,%eax
ffffffff80107a6b:	74 d8                	je     ffffffff80107a45 <uartputc+0x1e>
  outb(COM1+0, c);
ffffffff80107a6d:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80107a70:	0f b6 c0             	movzbl %al,%eax
ffffffff80107a73:	89 c6                	mov    %eax,%esi
ffffffff80107a75:	bf f8 03 00 00       	mov    $0x3f8,%edi
ffffffff80107a7a:	e8 90 fe ff ff       	callq  ffffffff8010790f <outb>
ffffffff80107a7f:	eb 01                	jmp    ffffffff80107a82 <uartputc+0x5b>
    return;
ffffffff80107a81:	90                   	nop
}
ffffffff80107a82:	c9                   	leaveq 
ffffffff80107a83:	c3                   	retq   

ffffffff80107a84 <uartgetc>:

static int
uartgetc(void)
{
ffffffff80107a84:	55                   	push   %rbp
ffffffff80107a85:	48 89 e5             	mov    %rsp,%rbp
  if(!uart)
ffffffff80107a88:	8b 05 5e ba 00 00    	mov    0xba5e(%rip),%eax        # ffffffff801134ec <uart>
ffffffff80107a8e:	85 c0                	test   %eax,%eax
ffffffff80107a90:	75 07                	jne    ffffffff80107a99 <uartgetc+0x15>
    return -1;
ffffffff80107a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107a97:	eb 28                	jmp    ffffffff80107ac1 <uartgetc+0x3d>
  if(!(inb(COM1+5) & 0x01))
ffffffff80107a99:	bf fd 03 00 00       	mov    $0x3fd,%edi
ffffffff80107a9e:	e8 4e fe ff ff       	callq  ffffffff801078f1 <inb>
ffffffff80107aa3:	0f b6 c0             	movzbl %al,%eax
ffffffff80107aa6:	83 e0 01             	and    $0x1,%eax
ffffffff80107aa9:	85 c0                	test   %eax,%eax
ffffffff80107aab:	75 07                	jne    ffffffff80107ab4 <uartgetc+0x30>
    return -1;
ffffffff80107aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80107ab2:	eb 0d                	jmp    ffffffff80107ac1 <uartgetc+0x3d>
  return inb(COM1+0);
ffffffff80107ab4:	bf f8 03 00 00       	mov    $0x3f8,%edi
ffffffff80107ab9:	e8 33 fe ff ff       	callq  ffffffff801078f1 <inb>
ffffffff80107abe:	0f b6 c0             	movzbl %al,%eax
}
ffffffff80107ac1:	5d                   	pop    %rbp
ffffffff80107ac2:	c3                   	retq   

ffffffff80107ac3 <uartintr>:

void
uartintr(void)
{
ffffffff80107ac3:	55                   	push   %rbp
ffffffff80107ac4:	48 89 e5             	mov    %rsp,%rbp
  consoleintr(uartgetc);
ffffffff80107ac7:	48 c7 c7 84 7a 10 80 	mov    $0xffffffff80107a84,%rdi
ffffffff80107ace:	e8 b6 90 ff ff       	callq  ffffffff80100b89 <consoleintr>
}
ffffffff80107ad3:	90                   	nop
ffffffff80107ad4:	5d                   	pop    %rbp
ffffffff80107ad5:	c3                   	retq   

ffffffff80107ad6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  push $0
ffffffff80107ad6:	6a 00                	pushq  $0x0
  push $0
ffffffff80107ad8:	6a 00                	pushq  $0x0
  jmp alltraps
ffffffff80107ada:	e9 c2 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107adf <vector1>:
.globl vector1
vector1:
  push $0
ffffffff80107adf:	6a 00                	pushq  $0x0
  push $1
ffffffff80107ae1:	6a 01                	pushq  $0x1
  jmp alltraps
ffffffff80107ae3:	e9 b9 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ae8 <vector2>:
.globl vector2
vector2:
  push $0
ffffffff80107ae8:	6a 00                	pushq  $0x0
  push $2
ffffffff80107aea:	6a 02                	pushq  $0x2
  jmp alltraps
ffffffff80107aec:	e9 b0 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107af1 <vector3>:
.globl vector3
vector3:
  push $0
ffffffff80107af1:	6a 00                	pushq  $0x0
  push $3
ffffffff80107af3:	6a 03                	pushq  $0x3
  jmp alltraps
ffffffff80107af5:	e9 a7 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107afa <vector4>:
.globl vector4
vector4:
  push $0
ffffffff80107afa:	6a 00                	pushq  $0x0
  push $4
ffffffff80107afc:	6a 04                	pushq  $0x4
  jmp alltraps
ffffffff80107afe:	e9 9e fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b03 <vector5>:
.globl vector5
vector5:
  push $0
ffffffff80107b03:	6a 00                	pushq  $0x0
  push $5
ffffffff80107b05:	6a 05                	pushq  $0x5
  jmp alltraps
ffffffff80107b07:	e9 95 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b0c <vector6>:
.globl vector6
vector6:
  push $0
ffffffff80107b0c:	6a 00                	pushq  $0x0
  push $6
ffffffff80107b0e:	6a 06                	pushq  $0x6
  jmp alltraps
ffffffff80107b10:	e9 8c fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b15 <vector7>:
.globl vector7
vector7:
  push $0
ffffffff80107b15:	6a 00                	pushq  $0x0
  push $7
ffffffff80107b17:	6a 07                	pushq  $0x7
  jmp alltraps
ffffffff80107b19:	e9 83 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b1e <vector8>:
.globl vector8
vector8:
  push $8
ffffffff80107b1e:	6a 08                	pushq  $0x8
  jmp alltraps
ffffffff80107b20:	e9 7c fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b25 <vector9>:
.globl vector9
vector9:
  push $0
ffffffff80107b25:	6a 00                	pushq  $0x0
  push $9
ffffffff80107b27:	6a 09                	pushq  $0x9
  jmp alltraps
ffffffff80107b29:	e9 73 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b2e <vector10>:
.globl vector10
vector10:
  push $10
ffffffff80107b2e:	6a 0a                	pushq  $0xa
  jmp alltraps
ffffffff80107b30:	e9 6c fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b35 <vector11>:
.globl vector11
vector11:
  push $11
ffffffff80107b35:	6a 0b                	pushq  $0xb
  jmp alltraps
ffffffff80107b37:	e9 65 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b3c <vector12>:
.globl vector12
vector12:
  push $12
ffffffff80107b3c:	6a 0c                	pushq  $0xc
  jmp alltraps
ffffffff80107b3e:	e9 5e fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b43 <vector13>:
.globl vector13
vector13:
  push $13
ffffffff80107b43:	6a 0d                	pushq  $0xd
  jmp alltraps
ffffffff80107b45:	e9 57 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b4a <vector14>:
.globl vector14
vector14:
  push $14
ffffffff80107b4a:	6a 0e                	pushq  $0xe
  jmp alltraps
ffffffff80107b4c:	e9 50 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b51 <vector15>:
.globl vector15
vector15:
  push $0
ffffffff80107b51:	6a 00                	pushq  $0x0
  push $15
ffffffff80107b53:	6a 0f                	pushq  $0xf
  jmp alltraps
ffffffff80107b55:	e9 47 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b5a <vector16>:
.globl vector16
vector16:
  push $0
ffffffff80107b5a:	6a 00                	pushq  $0x0
  push $16
ffffffff80107b5c:	6a 10                	pushq  $0x10
  jmp alltraps
ffffffff80107b5e:	e9 3e fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b63 <vector17>:
.globl vector17
vector17:
  push $17
ffffffff80107b63:	6a 11                	pushq  $0x11
  jmp alltraps
ffffffff80107b65:	e9 37 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b6a <vector18>:
.globl vector18
vector18:
  push $0
ffffffff80107b6a:	6a 00                	pushq  $0x0
  push $18
ffffffff80107b6c:	6a 12                	pushq  $0x12
  jmp alltraps
ffffffff80107b6e:	e9 2e fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b73 <vector19>:
.globl vector19
vector19:
  push $0
ffffffff80107b73:	6a 00                	pushq  $0x0
  push $19
ffffffff80107b75:	6a 13                	pushq  $0x13
  jmp alltraps
ffffffff80107b77:	e9 25 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b7c <vector20>:
.globl vector20
vector20:
  push $0
ffffffff80107b7c:	6a 00                	pushq  $0x0
  push $20
ffffffff80107b7e:	6a 14                	pushq  $0x14
  jmp alltraps
ffffffff80107b80:	e9 1c fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b85 <vector21>:
.globl vector21
vector21:
  push $0
ffffffff80107b85:	6a 00                	pushq  $0x0
  push $21
ffffffff80107b87:	6a 15                	pushq  $0x15
  jmp alltraps
ffffffff80107b89:	e9 13 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b8e <vector22>:
.globl vector22
vector22:
  push $0
ffffffff80107b8e:	6a 00                	pushq  $0x0
  push $22
ffffffff80107b90:	6a 16                	pushq  $0x16
  jmp alltraps
ffffffff80107b92:	e9 0a fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107b97 <vector23>:
.globl vector23
vector23:
  push $0
ffffffff80107b97:	6a 00                	pushq  $0x0
  push $23
ffffffff80107b99:	6a 17                	pushq  $0x17
  jmp alltraps
ffffffff80107b9b:	e9 01 fa ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ba0 <vector24>:
.globl vector24
vector24:
  push $0
ffffffff80107ba0:	6a 00                	pushq  $0x0
  push $24
ffffffff80107ba2:	6a 18                	pushq  $0x18
  jmp alltraps
ffffffff80107ba4:	e9 f8 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ba9 <vector25>:
.globl vector25
vector25:
  push $0
ffffffff80107ba9:	6a 00                	pushq  $0x0
  push $25
ffffffff80107bab:	6a 19                	pushq  $0x19
  jmp alltraps
ffffffff80107bad:	e9 ef f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bb2 <vector26>:
.globl vector26
vector26:
  push $0
ffffffff80107bb2:	6a 00                	pushq  $0x0
  push $26
ffffffff80107bb4:	6a 1a                	pushq  $0x1a
  jmp alltraps
ffffffff80107bb6:	e9 e6 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bbb <vector27>:
.globl vector27
vector27:
  push $0
ffffffff80107bbb:	6a 00                	pushq  $0x0
  push $27
ffffffff80107bbd:	6a 1b                	pushq  $0x1b
  jmp alltraps
ffffffff80107bbf:	e9 dd f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bc4 <vector28>:
.globl vector28
vector28:
  push $0
ffffffff80107bc4:	6a 00                	pushq  $0x0
  push $28
ffffffff80107bc6:	6a 1c                	pushq  $0x1c
  jmp alltraps
ffffffff80107bc8:	e9 d4 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bcd <vector29>:
.globl vector29
vector29:
  push $0
ffffffff80107bcd:	6a 00                	pushq  $0x0
  push $29
ffffffff80107bcf:	6a 1d                	pushq  $0x1d
  jmp alltraps
ffffffff80107bd1:	e9 cb f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bd6 <vector30>:
.globl vector30
vector30:
  push $0
ffffffff80107bd6:	6a 00                	pushq  $0x0
  push $30
ffffffff80107bd8:	6a 1e                	pushq  $0x1e
  jmp alltraps
ffffffff80107bda:	e9 c2 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bdf <vector31>:
.globl vector31
vector31:
  push $0
ffffffff80107bdf:	6a 00                	pushq  $0x0
  push $31
ffffffff80107be1:	6a 1f                	pushq  $0x1f
  jmp alltraps
ffffffff80107be3:	e9 b9 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107be8 <vector32>:
.globl vector32
vector32:
  push $0
ffffffff80107be8:	6a 00                	pushq  $0x0
  push $32
ffffffff80107bea:	6a 20                	pushq  $0x20
  jmp alltraps
ffffffff80107bec:	e9 b0 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bf1 <vector33>:
.globl vector33
vector33:
  push $0
ffffffff80107bf1:	6a 00                	pushq  $0x0
  push $33
ffffffff80107bf3:	6a 21                	pushq  $0x21
  jmp alltraps
ffffffff80107bf5:	e9 a7 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107bfa <vector34>:
.globl vector34
vector34:
  push $0
ffffffff80107bfa:	6a 00                	pushq  $0x0
  push $34
ffffffff80107bfc:	6a 22                	pushq  $0x22
  jmp alltraps
ffffffff80107bfe:	e9 9e f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c03 <vector35>:
.globl vector35
vector35:
  push $0
ffffffff80107c03:	6a 00                	pushq  $0x0
  push $35
ffffffff80107c05:	6a 23                	pushq  $0x23
  jmp alltraps
ffffffff80107c07:	e9 95 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c0c <vector36>:
.globl vector36
vector36:
  push $0
ffffffff80107c0c:	6a 00                	pushq  $0x0
  push $36
ffffffff80107c0e:	6a 24                	pushq  $0x24
  jmp alltraps
ffffffff80107c10:	e9 8c f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c15 <vector37>:
.globl vector37
vector37:
  push $0
ffffffff80107c15:	6a 00                	pushq  $0x0
  push $37
ffffffff80107c17:	6a 25                	pushq  $0x25
  jmp alltraps
ffffffff80107c19:	e9 83 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c1e <vector38>:
.globl vector38
vector38:
  push $0
ffffffff80107c1e:	6a 00                	pushq  $0x0
  push $38
ffffffff80107c20:	6a 26                	pushq  $0x26
  jmp alltraps
ffffffff80107c22:	e9 7a f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c27 <vector39>:
.globl vector39
vector39:
  push $0
ffffffff80107c27:	6a 00                	pushq  $0x0
  push $39
ffffffff80107c29:	6a 27                	pushq  $0x27
  jmp alltraps
ffffffff80107c2b:	e9 71 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c30 <vector40>:
.globl vector40
vector40:
  push $0
ffffffff80107c30:	6a 00                	pushq  $0x0
  push $40
ffffffff80107c32:	6a 28                	pushq  $0x28
  jmp alltraps
ffffffff80107c34:	e9 68 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c39 <vector41>:
.globl vector41
vector41:
  push $0
ffffffff80107c39:	6a 00                	pushq  $0x0
  push $41
ffffffff80107c3b:	6a 29                	pushq  $0x29
  jmp alltraps
ffffffff80107c3d:	e9 5f f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c42 <vector42>:
.globl vector42
vector42:
  push $0
ffffffff80107c42:	6a 00                	pushq  $0x0
  push $42
ffffffff80107c44:	6a 2a                	pushq  $0x2a
  jmp alltraps
ffffffff80107c46:	e9 56 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c4b <vector43>:
.globl vector43
vector43:
  push $0
ffffffff80107c4b:	6a 00                	pushq  $0x0
  push $43
ffffffff80107c4d:	6a 2b                	pushq  $0x2b
  jmp alltraps
ffffffff80107c4f:	e9 4d f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c54 <vector44>:
.globl vector44
vector44:
  push $0
ffffffff80107c54:	6a 00                	pushq  $0x0
  push $44
ffffffff80107c56:	6a 2c                	pushq  $0x2c
  jmp alltraps
ffffffff80107c58:	e9 44 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c5d <vector45>:
.globl vector45
vector45:
  push $0
ffffffff80107c5d:	6a 00                	pushq  $0x0
  push $45
ffffffff80107c5f:	6a 2d                	pushq  $0x2d
  jmp alltraps
ffffffff80107c61:	e9 3b f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c66 <vector46>:
.globl vector46
vector46:
  push $0
ffffffff80107c66:	6a 00                	pushq  $0x0
  push $46
ffffffff80107c68:	6a 2e                	pushq  $0x2e
  jmp alltraps
ffffffff80107c6a:	e9 32 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c6f <vector47>:
.globl vector47
vector47:
  push $0
ffffffff80107c6f:	6a 00                	pushq  $0x0
  push $47
ffffffff80107c71:	6a 2f                	pushq  $0x2f
  jmp alltraps
ffffffff80107c73:	e9 29 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c78 <vector48>:
.globl vector48
vector48:
  push $0
ffffffff80107c78:	6a 00                	pushq  $0x0
  push $48
ffffffff80107c7a:	6a 30                	pushq  $0x30
  jmp alltraps
ffffffff80107c7c:	e9 20 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c81 <vector49>:
.globl vector49
vector49:
  push $0
ffffffff80107c81:	6a 00                	pushq  $0x0
  push $49
ffffffff80107c83:	6a 31                	pushq  $0x31
  jmp alltraps
ffffffff80107c85:	e9 17 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c8a <vector50>:
.globl vector50
vector50:
  push $0
ffffffff80107c8a:	6a 00                	pushq  $0x0
  push $50
ffffffff80107c8c:	6a 32                	pushq  $0x32
  jmp alltraps
ffffffff80107c8e:	e9 0e f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c93 <vector51>:
.globl vector51
vector51:
  push $0
ffffffff80107c93:	6a 00                	pushq  $0x0
  push $51
ffffffff80107c95:	6a 33                	pushq  $0x33
  jmp alltraps
ffffffff80107c97:	e9 05 f9 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107c9c <vector52>:
.globl vector52
vector52:
  push $0
ffffffff80107c9c:	6a 00                	pushq  $0x0
  push $52
ffffffff80107c9e:	6a 34                	pushq  $0x34
  jmp alltraps
ffffffff80107ca0:	e9 fc f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ca5 <vector53>:
.globl vector53
vector53:
  push $0
ffffffff80107ca5:	6a 00                	pushq  $0x0
  push $53
ffffffff80107ca7:	6a 35                	pushq  $0x35
  jmp alltraps
ffffffff80107ca9:	e9 f3 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cae <vector54>:
.globl vector54
vector54:
  push $0
ffffffff80107cae:	6a 00                	pushq  $0x0
  push $54
ffffffff80107cb0:	6a 36                	pushq  $0x36
  jmp alltraps
ffffffff80107cb2:	e9 ea f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cb7 <vector55>:
.globl vector55
vector55:
  push $0
ffffffff80107cb7:	6a 00                	pushq  $0x0
  push $55
ffffffff80107cb9:	6a 37                	pushq  $0x37
  jmp alltraps
ffffffff80107cbb:	e9 e1 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cc0 <vector56>:
.globl vector56
vector56:
  push $0
ffffffff80107cc0:	6a 00                	pushq  $0x0
  push $56
ffffffff80107cc2:	6a 38                	pushq  $0x38
  jmp alltraps
ffffffff80107cc4:	e9 d8 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cc9 <vector57>:
.globl vector57
vector57:
  push $0
ffffffff80107cc9:	6a 00                	pushq  $0x0
  push $57
ffffffff80107ccb:	6a 39                	pushq  $0x39
  jmp alltraps
ffffffff80107ccd:	e9 cf f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cd2 <vector58>:
.globl vector58
vector58:
  push $0
ffffffff80107cd2:	6a 00                	pushq  $0x0
  push $58
ffffffff80107cd4:	6a 3a                	pushq  $0x3a
  jmp alltraps
ffffffff80107cd6:	e9 c6 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cdb <vector59>:
.globl vector59
vector59:
  push $0
ffffffff80107cdb:	6a 00                	pushq  $0x0
  push $59
ffffffff80107cdd:	6a 3b                	pushq  $0x3b
  jmp alltraps
ffffffff80107cdf:	e9 bd f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ce4 <vector60>:
.globl vector60
vector60:
  push $0
ffffffff80107ce4:	6a 00                	pushq  $0x0
  push $60
ffffffff80107ce6:	6a 3c                	pushq  $0x3c
  jmp alltraps
ffffffff80107ce8:	e9 b4 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ced <vector61>:
.globl vector61
vector61:
  push $0
ffffffff80107ced:	6a 00                	pushq  $0x0
  push $61
ffffffff80107cef:	6a 3d                	pushq  $0x3d
  jmp alltraps
ffffffff80107cf1:	e9 ab f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cf6 <vector62>:
.globl vector62
vector62:
  push $0
ffffffff80107cf6:	6a 00                	pushq  $0x0
  push $62
ffffffff80107cf8:	6a 3e                	pushq  $0x3e
  jmp alltraps
ffffffff80107cfa:	e9 a2 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107cff <vector63>:
.globl vector63
vector63:
  push $0
ffffffff80107cff:	6a 00                	pushq  $0x0
  push $63
ffffffff80107d01:	6a 3f                	pushq  $0x3f
  jmp alltraps
ffffffff80107d03:	e9 99 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d08 <vector64>:
.globl vector64
vector64:
  push $0
ffffffff80107d08:	6a 00                	pushq  $0x0
  push $64
ffffffff80107d0a:	6a 40                	pushq  $0x40
  jmp alltraps
ffffffff80107d0c:	e9 90 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d11 <vector65>:
.globl vector65
vector65:
  push $0
ffffffff80107d11:	6a 00                	pushq  $0x0
  push $65
ffffffff80107d13:	6a 41                	pushq  $0x41
  jmp alltraps
ffffffff80107d15:	e9 87 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d1a <vector66>:
.globl vector66
vector66:
  push $0
ffffffff80107d1a:	6a 00                	pushq  $0x0
  push $66
ffffffff80107d1c:	6a 42                	pushq  $0x42
  jmp alltraps
ffffffff80107d1e:	e9 7e f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d23 <vector67>:
.globl vector67
vector67:
  push $0
ffffffff80107d23:	6a 00                	pushq  $0x0
  push $67
ffffffff80107d25:	6a 43                	pushq  $0x43
  jmp alltraps
ffffffff80107d27:	e9 75 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d2c <vector68>:
.globl vector68
vector68:
  push $0
ffffffff80107d2c:	6a 00                	pushq  $0x0
  push $68
ffffffff80107d2e:	6a 44                	pushq  $0x44
  jmp alltraps
ffffffff80107d30:	e9 6c f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d35 <vector69>:
.globl vector69
vector69:
  push $0
ffffffff80107d35:	6a 00                	pushq  $0x0
  push $69
ffffffff80107d37:	6a 45                	pushq  $0x45
  jmp alltraps
ffffffff80107d39:	e9 63 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d3e <vector70>:
.globl vector70
vector70:
  push $0
ffffffff80107d3e:	6a 00                	pushq  $0x0
  push $70
ffffffff80107d40:	6a 46                	pushq  $0x46
  jmp alltraps
ffffffff80107d42:	e9 5a f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d47 <vector71>:
.globl vector71
vector71:
  push $0
ffffffff80107d47:	6a 00                	pushq  $0x0
  push $71
ffffffff80107d49:	6a 47                	pushq  $0x47
  jmp alltraps
ffffffff80107d4b:	e9 51 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d50 <vector72>:
.globl vector72
vector72:
  push $0
ffffffff80107d50:	6a 00                	pushq  $0x0
  push $72
ffffffff80107d52:	6a 48                	pushq  $0x48
  jmp alltraps
ffffffff80107d54:	e9 48 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d59 <vector73>:
.globl vector73
vector73:
  push $0
ffffffff80107d59:	6a 00                	pushq  $0x0
  push $73
ffffffff80107d5b:	6a 49                	pushq  $0x49
  jmp alltraps
ffffffff80107d5d:	e9 3f f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d62 <vector74>:
.globl vector74
vector74:
  push $0
ffffffff80107d62:	6a 00                	pushq  $0x0
  push $74
ffffffff80107d64:	6a 4a                	pushq  $0x4a
  jmp alltraps
ffffffff80107d66:	e9 36 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d6b <vector75>:
.globl vector75
vector75:
  push $0
ffffffff80107d6b:	6a 00                	pushq  $0x0
  push $75
ffffffff80107d6d:	6a 4b                	pushq  $0x4b
  jmp alltraps
ffffffff80107d6f:	e9 2d f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d74 <vector76>:
.globl vector76
vector76:
  push $0
ffffffff80107d74:	6a 00                	pushq  $0x0
  push $76
ffffffff80107d76:	6a 4c                	pushq  $0x4c
  jmp alltraps
ffffffff80107d78:	e9 24 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d7d <vector77>:
.globl vector77
vector77:
  push $0
ffffffff80107d7d:	6a 00                	pushq  $0x0
  push $77
ffffffff80107d7f:	6a 4d                	pushq  $0x4d
  jmp alltraps
ffffffff80107d81:	e9 1b f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d86 <vector78>:
.globl vector78
vector78:
  push $0
ffffffff80107d86:	6a 00                	pushq  $0x0
  push $78
ffffffff80107d88:	6a 4e                	pushq  $0x4e
  jmp alltraps
ffffffff80107d8a:	e9 12 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d8f <vector79>:
.globl vector79
vector79:
  push $0
ffffffff80107d8f:	6a 00                	pushq  $0x0
  push $79
ffffffff80107d91:	6a 4f                	pushq  $0x4f
  jmp alltraps
ffffffff80107d93:	e9 09 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107d98 <vector80>:
.globl vector80
vector80:
  push $0
ffffffff80107d98:	6a 00                	pushq  $0x0
  push $80
ffffffff80107d9a:	6a 50                	pushq  $0x50
  jmp alltraps
ffffffff80107d9c:	e9 00 f8 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107da1 <vector81>:
.globl vector81
vector81:
  push $0
ffffffff80107da1:	6a 00                	pushq  $0x0
  push $81
ffffffff80107da3:	6a 51                	pushq  $0x51
  jmp alltraps
ffffffff80107da5:	e9 f7 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107daa <vector82>:
.globl vector82
vector82:
  push $0
ffffffff80107daa:	6a 00                	pushq  $0x0
  push $82
ffffffff80107dac:	6a 52                	pushq  $0x52
  jmp alltraps
ffffffff80107dae:	e9 ee f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107db3 <vector83>:
.globl vector83
vector83:
  push $0
ffffffff80107db3:	6a 00                	pushq  $0x0
  push $83
ffffffff80107db5:	6a 53                	pushq  $0x53
  jmp alltraps
ffffffff80107db7:	e9 e5 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107dbc <vector84>:
.globl vector84
vector84:
  push $0
ffffffff80107dbc:	6a 00                	pushq  $0x0
  push $84
ffffffff80107dbe:	6a 54                	pushq  $0x54
  jmp alltraps
ffffffff80107dc0:	e9 dc f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107dc5 <vector85>:
.globl vector85
vector85:
  push $0
ffffffff80107dc5:	6a 00                	pushq  $0x0
  push $85
ffffffff80107dc7:	6a 55                	pushq  $0x55
  jmp alltraps
ffffffff80107dc9:	e9 d3 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107dce <vector86>:
.globl vector86
vector86:
  push $0
ffffffff80107dce:	6a 00                	pushq  $0x0
  push $86
ffffffff80107dd0:	6a 56                	pushq  $0x56
  jmp alltraps
ffffffff80107dd2:	e9 ca f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107dd7 <vector87>:
.globl vector87
vector87:
  push $0
ffffffff80107dd7:	6a 00                	pushq  $0x0
  push $87
ffffffff80107dd9:	6a 57                	pushq  $0x57
  jmp alltraps
ffffffff80107ddb:	e9 c1 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107de0 <vector88>:
.globl vector88
vector88:
  push $0
ffffffff80107de0:	6a 00                	pushq  $0x0
  push $88
ffffffff80107de2:	6a 58                	pushq  $0x58
  jmp alltraps
ffffffff80107de4:	e9 b8 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107de9 <vector89>:
.globl vector89
vector89:
  push $0
ffffffff80107de9:	6a 00                	pushq  $0x0
  push $89
ffffffff80107deb:	6a 59                	pushq  $0x59
  jmp alltraps
ffffffff80107ded:	e9 af f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107df2 <vector90>:
.globl vector90
vector90:
  push $0
ffffffff80107df2:	6a 00                	pushq  $0x0
  push $90
ffffffff80107df4:	6a 5a                	pushq  $0x5a
  jmp alltraps
ffffffff80107df6:	e9 a6 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107dfb <vector91>:
.globl vector91
vector91:
  push $0
ffffffff80107dfb:	6a 00                	pushq  $0x0
  push $91
ffffffff80107dfd:	6a 5b                	pushq  $0x5b
  jmp alltraps
ffffffff80107dff:	e9 9d f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e04 <vector92>:
.globl vector92
vector92:
  push $0
ffffffff80107e04:	6a 00                	pushq  $0x0
  push $92
ffffffff80107e06:	6a 5c                	pushq  $0x5c
  jmp alltraps
ffffffff80107e08:	e9 94 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e0d <vector93>:
.globl vector93
vector93:
  push $0
ffffffff80107e0d:	6a 00                	pushq  $0x0
  push $93
ffffffff80107e0f:	6a 5d                	pushq  $0x5d
  jmp alltraps
ffffffff80107e11:	e9 8b f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e16 <vector94>:
.globl vector94
vector94:
  push $0
ffffffff80107e16:	6a 00                	pushq  $0x0
  push $94
ffffffff80107e18:	6a 5e                	pushq  $0x5e
  jmp alltraps
ffffffff80107e1a:	e9 82 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e1f <vector95>:
.globl vector95
vector95:
  push $0
ffffffff80107e1f:	6a 00                	pushq  $0x0
  push $95
ffffffff80107e21:	6a 5f                	pushq  $0x5f
  jmp alltraps
ffffffff80107e23:	e9 79 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e28 <vector96>:
.globl vector96
vector96:
  push $0
ffffffff80107e28:	6a 00                	pushq  $0x0
  push $96
ffffffff80107e2a:	6a 60                	pushq  $0x60
  jmp alltraps
ffffffff80107e2c:	e9 70 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e31 <vector97>:
.globl vector97
vector97:
  push $0
ffffffff80107e31:	6a 00                	pushq  $0x0
  push $97
ffffffff80107e33:	6a 61                	pushq  $0x61
  jmp alltraps
ffffffff80107e35:	e9 67 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e3a <vector98>:
.globl vector98
vector98:
  push $0
ffffffff80107e3a:	6a 00                	pushq  $0x0
  push $98
ffffffff80107e3c:	6a 62                	pushq  $0x62
  jmp alltraps
ffffffff80107e3e:	e9 5e f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e43 <vector99>:
.globl vector99
vector99:
  push $0
ffffffff80107e43:	6a 00                	pushq  $0x0
  push $99
ffffffff80107e45:	6a 63                	pushq  $0x63
  jmp alltraps
ffffffff80107e47:	e9 55 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e4c <vector100>:
.globl vector100
vector100:
  push $0
ffffffff80107e4c:	6a 00                	pushq  $0x0
  push $100
ffffffff80107e4e:	6a 64                	pushq  $0x64
  jmp alltraps
ffffffff80107e50:	e9 4c f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e55 <vector101>:
.globl vector101
vector101:
  push $0
ffffffff80107e55:	6a 00                	pushq  $0x0
  push $101
ffffffff80107e57:	6a 65                	pushq  $0x65
  jmp alltraps
ffffffff80107e59:	e9 43 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e5e <vector102>:
.globl vector102
vector102:
  push $0
ffffffff80107e5e:	6a 00                	pushq  $0x0
  push $102
ffffffff80107e60:	6a 66                	pushq  $0x66
  jmp alltraps
ffffffff80107e62:	e9 3a f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e67 <vector103>:
.globl vector103
vector103:
  push $0
ffffffff80107e67:	6a 00                	pushq  $0x0
  push $103
ffffffff80107e69:	6a 67                	pushq  $0x67
  jmp alltraps
ffffffff80107e6b:	e9 31 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e70 <vector104>:
.globl vector104
vector104:
  push $0
ffffffff80107e70:	6a 00                	pushq  $0x0
  push $104
ffffffff80107e72:	6a 68                	pushq  $0x68
  jmp alltraps
ffffffff80107e74:	e9 28 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e79 <vector105>:
.globl vector105
vector105:
  push $0
ffffffff80107e79:	6a 00                	pushq  $0x0
  push $105
ffffffff80107e7b:	6a 69                	pushq  $0x69
  jmp alltraps
ffffffff80107e7d:	e9 1f f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e82 <vector106>:
.globl vector106
vector106:
  push $0
ffffffff80107e82:	6a 00                	pushq  $0x0
  push $106
ffffffff80107e84:	6a 6a                	pushq  $0x6a
  jmp alltraps
ffffffff80107e86:	e9 16 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e8b <vector107>:
.globl vector107
vector107:
  push $0
ffffffff80107e8b:	6a 00                	pushq  $0x0
  push $107
ffffffff80107e8d:	6a 6b                	pushq  $0x6b
  jmp alltraps
ffffffff80107e8f:	e9 0d f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e94 <vector108>:
.globl vector108
vector108:
  push $0
ffffffff80107e94:	6a 00                	pushq  $0x0
  push $108
ffffffff80107e96:	6a 6c                	pushq  $0x6c
  jmp alltraps
ffffffff80107e98:	e9 04 f7 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107e9d <vector109>:
.globl vector109
vector109:
  push $0
ffffffff80107e9d:	6a 00                	pushq  $0x0
  push $109
ffffffff80107e9f:	6a 6d                	pushq  $0x6d
  jmp alltraps
ffffffff80107ea1:	e9 fb f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ea6 <vector110>:
.globl vector110
vector110:
  push $0
ffffffff80107ea6:	6a 00                	pushq  $0x0
  push $110
ffffffff80107ea8:	6a 6e                	pushq  $0x6e
  jmp alltraps
ffffffff80107eaa:	e9 f2 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107eaf <vector111>:
.globl vector111
vector111:
  push $0
ffffffff80107eaf:	6a 00                	pushq  $0x0
  push $111
ffffffff80107eb1:	6a 6f                	pushq  $0x6f
  jmp alltraps
ffffffff80107eb3:	e9 e9 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107eb8 <vector112>:
.globl vector112
vector112:
  push $0
ffffffff80107eb8:	6a 00                	pushq  $0x0
  push $112
ffffffff80107eba:	6a 70                	pushq  $0x70
  jmp alltraps
ffffffff80107ebc:	e9 e0 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ec1 <vector113>:
.globl vector113
vector113:
  push $0
ffffffff80107ec1:	6a 00                	pushq  $0x0
  push $113
ffffffff80107ec3:	6a 71                	pushq  $0x71
  jmp alltraps
ffffffff80107ec5:	e9 d7 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107eca <vector114>:
.globl vector114
vector114:
  push $0
ffffffff80107eca:	6a 00                	pushq  $0x0
  push $114
ffffffff80107ecc:	6a 72                	pushq  $0x72
  jmp alltraps
ffffffff80107ece:	e9 ce f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ed3 <vector115>:
.globl vector115
vector115:
  push $0
ffffffff80107ed3:	6a 00                	pushq  $0x0
  push $115
ffffffff80107ed5:	6a 73                	pushq  $0x73
  jmp alltraps
ffffffff80107ed7:	e9 c5 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107edc <vector116>:
.globl vector116
vector116:
  push $0
ffffffff80107edc:	6a 00                	pushq  $0x0
  push $116
ffffffff80107ede:	6a 74                	pushq  $0x74
  jmp alltraps
ffffffff80107ee0:	e9 bc f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ee5 <vector117>:
.globl vector117
vector117:
  push $0
ffffffff80107ee5:	6a 00                	pushq  $0x0
  push $117
ffffffff80107ee7:	6a 75                	pushq  $0x75
  jmp alltraps
ffffffff80107ee9:	e9 b3 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107eee <vector118>:
.globl vector118
vector118:
  push $0
ffffffff80107eee:	6a 00                	pushq  $0x0
  push $118
ffffffff80107ef0:	6a 76                	pushq  $0x76
  jmp alltraps
ffffffff80107ef2:	e9 aa f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ef7 <vector119>:
.globl vector119
vector119:
  push $0
ffffffff80107ef7:	6a 00                	pushq  $0x0
  push $119
ffffffff80107ef9:	6a 77                	pushq  $0x77
  jmp alltraps
ffffffff80107efb:	e9 a1 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f00 <vector120>:
.globl vector120
vector120:
  push $0
ffffffff80107f00:	6a 00                	pushq  $0x0
  push $120
ffffffff80107f02:	6a 78                	pushq  $0x78
  jmp alltraps
ffffffff80107f04:	e9 98 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f09 <vector121>:
.globl vector121
vector121:
  push $0
ffffffff80107f09:	6a 00                	pushq  $0x0
  push $121
ffffffff80107f0b:	6a 79                	pushq  $0x79
  jmp alltraps
ffffffff80107f0d:	e9 8f f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f12 <vector122>:
.globl vector122
vector122:
  push $0
ffffffff80107f12:	6a 00                	pushq  $0x0
  push $122
ffffffff80107f14:	6a 7a                	pushq  $0x7a
  jmp alltraps
ffffffff80107f16:	e9 86 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f1b <vector123>:
.globl vector123
vector123:
  push $0
ffffffff80107f1b:	6a 00                	pushq  $0x0
  push $123
ffffffff80107f1d:	6a 7b                	pushq  $0x7b
  jmp alltraps
ffffffff80107f1f:	e9 7d f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f24 <vector124>:
.globl vector124
vector124:
  push $0
ffffffff80107f24:	6a 00                	pushq  $0x0
  push $124
ffffffff80107f26:	6a 7c                	pushq  $0x7c
  jmp alltraps
ffffffff80107f28:	e9 74 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f2d <vector125>:
.globl vector125
vector125:
  push $0
ffffffff80107f2d:	6a 00                	pushq  $0x0
  push $125
ffffffff80107f2f:	6a 7d                	pushq  $0x7d
  jmp alltraps
ffffffff80107f31:	e9 6b f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f36 <vector126>:
.globl vector126
vector126:
  push $0
ffffffff80107f36:	6a 00                	pushq  $0x0
  push $126
ffffffff80107f38:	6a 7e                	pushq  $0x7e
  jmp alltraps
ffffffff80107f3a:	e9 62 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f3f <vector127>:
.globl vector127
vector127:
  push $0
ffffffff80107f3f:	6a 00                	pushq  $0x0
  push $127
ffffffff80107f41:	6a 7f                	pushq  $0x7f
  jmp alltraps
ffffffff80107f43:	e9 59 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f48 <vector128>:
.globl vector128
vector128:
  push $0
ffffffff80107f48:	6a 00                	pushq  $0x0
  push $128
ffffffff80107f4a:	68 80 00 00 00       	pushq  $0x80
  jmp alltraps
ffffffff80107f4f:	e9 4d f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f54 <vector129>:
.globl vector129
vector129:
  push $0
ffffffff80107f54:	6a 00                	pushq  $0x0
  push $129
ffffffff80107f56:	68 81 00 00 00       	pushq  $0x81
  jmp alltraps
ffffffff80107f5b:	e9 41 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f60 <vector130>:
.globl vector130
vector130:
  push $0
ffffffff80107f60:	6a 00                	pushq  $0x0
  push $130
ffffffff80107f62:	68 82 00 00 00       	pushq  $0x82
  jmp alltraps
ffffffff80107f67:	e9 35 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f6c <vector131>:
.globl vector131
vector131:
  push $0
ffffffff80107f6c:	6a 00                	pushq  $0x0
  push $131
ffffffff80107f6e:	68 83 00 00 00       	pushq  $0x83
  jmp alltraps
ffffffff80107f73:	e9 29 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f78 <vector132>:
.globl vector132
vector132:
  push $0
ffffffff80107f78:	6a 00                	pushq  $0x0
  push $132
ffffffff80107f7a:	68 84 00 00 00       	pushq  $0x84
  jmp alltraps
ffffffff80107f7f:	e9 1d f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f84 <vector133>:
.globl vector133
vector133:
  push $0
ffffffff80107f84:	6a 00                	pushq  $0x0
  push $133
ffffffff80107f86:	68 85 00 00 00       	pushq  $0x85
  jmp alltraps
ffffffff80107f8b:	e9 11 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f90 <vector134>:
.globl vector134
vector134:
  push $0
ffffffff80107f90:	6a 00                	pushq  $0x0
  push $134
ffffffff80107f92:	68 86 00 00 00       	pushq  $0x86
  jmp alltraps
ffffffff80107f97:	e9 05 f6 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107f9c <vector135>:
.globl vector135
vector135:
  push $0
ffffffff80107f9c:	6a 00                	pushq  $0x0
  push $135
ffffffff80107f9e:	68 87 00 00 00       	pushq  $0x87
  jmp alltraps
ffffffff80107fa3:	e9 f9 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fa8 <vector136>:
.globl vector136
vector136:
  push $0
ffffffff80107fa8:	6a 00                	pushq  $0x0
  push $136
ffffffff80107faa:	68 88 00 00 00       	pushq  $0x88
  jmp alltraps
ffffffff80107faf:	e9 ed f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fb4 <vector137>:
.globl vector137
vector137:
  push $0
ffffffff80107fb4:	6a 00                	pushq  $0x0
  push $137
ffffffff80107fb6:	68 89 00 00 00       	pushq  $0x89
  jmp alltraps
ffffffff80107fbb:	e9 e1 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fc0 <vector138>:
.globl vector138
vector138:
  push $0
ffffffff80107fc0:	6a 00                	pushq  $0x0
  push $138
ffffffff80107fc2:	68 8a 00 00 00       	pushq  $0x8a
  jmp alltraps
ffffffff80107fc7:	e9 d5 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fcc <vector139>:
.globl vector139
vector139:
  push $0
ffffffff80107fcc:	6a 00                	pushq  $0x0
  push $139
ffffffff80107fce:	68 8b 00 00 00       	pushq  $0x8b
  jmp alltraps
ffffffff80107fd3:	e9 c9 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fd8 <vector140>:
.globl vector140
vector140:
  push $0
ffffffff80107fd8:	6a 00                	pushq  $0x0
  push $140
ffffffff80107fda:	68 8c 00 00 00       	pushq  $0x8c
  jmp alltraps
ffffffff80107fdf:	e9 bd f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107fe4 <vector141>:
.globl vector141
vector141:
  push $0
ffffffff80107fe4:	6a 00                	pushq  $0x0
  push $141
ffffffff80107fe6:	68 8d 00 00 00       	pushq  $0x8d
  jmp alltraps
ffffffff80107feb:	e9 b1 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ff0 <vector142>:
.globl vector142
vector142:
  push $0
ffffffff80107ff0:	6a 00                	pushq  $0x0
  push $142
ffffffff80107ff2:	68 8e 00 00 00       	pushq  $0x8e
  jmp alltraps
ffffffff80107ff7:	e9 a5 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80107ffc <vector143>:
.globl vector143
vector143:
  push $0
ffffffff80107ffc:	6a 00                	pushq  $0x0
  push $143
ffffffff80107ffe:	68 8f 00 00 00       	pushq  $0x8f
  jmp alltraps
ffffffff80108003:	e9 99 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108008 <vector144>:
.globl vector144
vector144:
  push $0
ffffffff80108008:	6a 00                	pushq  $0x0
  push $144
ffffffff8010800a:	68 90 00 00 00       	pushq  $0x90
  jmp alltraps
ffffffff8010800f:	e9 8d f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108014 <vector145>:
.globl vector145
vector145:
  push $0
ffffffff80108014:	6a 00                	pushq  $0x0
  push $145
ffffffff80108016:	68 91 00 00 00       	pushq  $0x91
  jmp alltraps
ffffffff8010801b:	e9 81 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108020 <vector146>:
.globl vector146
vector146:
  push $0
ffffffff80108020:	6a 00                	pushq  $0x0
  push $146
ffffffff80108022:	68 92 00 00 00       	pushq  $0x92
  jmp alltraps
ffffffff80108027:	e9 75 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010802c <vector147>:
.globl vector147
vector147:
  push $0
ffffffff8010802c:	6a 00                	pushq  $0x0
  push $147
ffffffff8010802e:	68 93 00 00 00       	pushq  $0x93
  jmp alltraps
ffffffff80108033:	e9 69 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108038 <vector148>:
.globl vector148
vector148:
  push $0
ffffffff80108038:	6a 00                	pushq  $0x0
  push $148
ffffffff8010803a:	68 94 00 00 00       	pushq  $0x94
  jmp alltraps
ffffffff8010803f:	e9 5d f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108044 <vector149>:
.globl vector149
vector149:
  push $0
ffffffff80108044:	6a 00                	pushq  $0x0
  push $149
ffffffff80108046:	68 95 00 00 00       	pushq  $0x95
  jmp alltraps
ffffffff8010804b:	e9 51 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108050 <vector150>:
.globl vector150
vector150:
  push $0
ffffffff80108050:	6a 00                	pushq  $0x0
  push $150
ffffffff80108052:	68 96 00 00 00       	pushq  $0x96
  jmp alltraps
ffffffff80108057:	e9 45 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010805c <vector151>:
.globl vector151
vector151:
  push $0
ffffffff8010805c:	6a 00                	pushq  $0x0
  push $151
ffffffff8010805e:	68 97 00 00 00       	pushq  $0x97
  jmp alltraps
ffffffff80108063:	e9 39 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108068 <vector152>:
.globl vector152
vector152:
  push $0
ffffffff80108068:	6a 00                	pushq  $0x0
  push $152
ffffffff8010806a:	68 98 00 00 00       	pushq  $0x98
  jmp alltraps
ffffffff8010806f:	e9 2d f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108074 <vector153>:
.globl vector153
vector153:
  push $0
ffffffff80108074:	6a 00                	pushq  $0x0
  push $153
ffffffff80108076:	68 99 00 00 00       	pushq  $0x99
  jmp alltraps
ffffffff8010807b:	e9 21 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108080 <vector154>:
.globl vector154
vector154:
  push $0
ffffffff80108080:	6a 00                	pushq  $0x0
  push $154
ffffffff80108082:	68 9a 00 00 00       	pushq  $0x9a
  jmp alltraps
ffffffff80108087:	e9 15 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010808c <vector155>:
.globl vector155
vector155:
  push $0
ffffffff8010808c:	6a 00                	pushq  $0x0
  push $155
ffffffff8010808e:	68 9b 00 00 00       	pushq  $0x9b
  jmp alltraps
ffffffff80108093:	e9 09 f5 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108098 <vector156>:
.globl vector156
vector156:
  push $0
ffffffff80108098:	6a 00                	pushq  $0x0
  push $156
ffffffff8010809a:	68 9c 00 00 00       	pushq  $0x9c
  jmp alltraps
ffffffff8010809f:	e9 fd f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080a4 <vector157>:
.globl vector157
vector157:
  push $0
ffffffff801080a4:	6a 00                	pushq  $0x0
  push $157
ffffffff801080a6:	68 9d 00 00 00       	pushq  $0x9d
  jmp alltraps
ffffffff801080ab:	e9 f1 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080b0 <vector158>:
.globl vector158
vector158:
  push $0
ffffffff801080b0:	6a 00                	pushq  $0x0
  push $158
ffffffff801080b2:	68 9e 00 00 00       	pushq  $0x9e
  jmp alltraps
ffffffff801080b7:	e9 e5 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080bc <vector159>:
.globl vector159
vector159:
  push $0
ffffffff801080bc:	6a 00                	pushq  $0x0
  push $159
ffffffff801080be:	68 9f 00 00 00       	pushq  $0x9f
  jmp alltraps
ffffffff801080c3:	e9 d9 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080c8 <vector160>:
.globl vector160
vector160:
  push $0
ffffffff801080c8:	6a 00                	pushq  $0x0
  push $160
ffffffff801080ca:	68 a0 00 00 00       	pushq  $0xa0
  jmp alltraps
ffffffff801080cf:	e9 cd f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080d4 <vector161>:
.globl vector161
vector161:
  push $0
ffffffff801080d4:	6a 00                	pushq  $0x0
  push $161
ffffffff801080d6:	68 a1 00 00 00       	pushq  $0xa1
  jmp alltraps
ffffffff801080db:	e9 c1 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080e0 <vector162>:
.globl vector162
vector162:
  push $0
ffffffff801080e0:	6a 00                	pushq  $0x0
  push $162
ffffffff801080e2:	68 a2 00 00 00       	pushq  $0xa2
  jmp alltraps
ffffffff801080e7:	e9 b5 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080ec <vector163>:
.globl vector163
vector163:
  push $0
ffffffff801080ec:	6a 00                	pushq  $0x0
  push $163
ffffffff801080ee:	68 a3 00 00 00       	pushq  $0xa3
  jmp alltraps
ffffffff801080f3:	e9 a9 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801080f8 <vector164>:
.globl vector164
vector164:
  push $0
ffffffff801080f8:	6a 00                	pushq  $0x0
  push $164
ffffffff801080fa:	68 a4 00 00 00       	pushq  $0xa4
  jmp alltraps
ffffffff801080ff:	e9 9d f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108104 <vector165>:
.globl vector165
vector165:
  push $0
ffffffff80108104:	6a 00                	pushq  $0x0
  push $165
ffffffff80108106:	68 a5 00 00 00       	pushq  $0xa5
  jmp alltraps
ffffffff8010810b:	e9 91 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108110 <vector166>:
.globl vector166
vector166:
  push $0
ffffffff80108110:	6a 00                	pushq  $0x0
  push $166
ffffffff80108112:	68 a6 00 00 00       	pushq  $0xa6
  jmp alltraps
ffffffff80108117:	e9 85 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010811c <vector167>:
.globl vector167
vector167:
  push $0
ffffffff8010811c:	6a 00                	pushq  $0x0
  push $167
ffffffff8010811e:	68 a7 00 00 00       	pushq  $0xa7
  jmp alltraps
ffffffff80108123:	e9 79 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108128 <vector168>:
.globl vector168
vector168:
  push $0
ffffffff80108128:	6a 00                	pushq  $0x0
  push $168
ffffffff8010812a:	68 a8 00 00 00       	pushq  $0xa8
  jmp alltraps
ffffffff8010812f:	e9 6d f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108134 <vector169>:
.globl vector169
vector169:
  push $0
ffffffff80108134:	6a 00                	pushq  $0x0
  push $169
ffffffff80108136:	68 a9 00 00 00       	pushq  $0xa9
  jmp alltraps
ffffffff8010813b:	e9 61 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108140 <vector170>:
.globl vector170
vector170:
  push $0
ffffffff80108140:	6a 00                	pushq  $0x0
  push $170
ffffffff80108142:	68 aa 00 00 00       	pushq  $0xaa
  jmp alltraps
ffffffff80108147:	e9 55 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010814c <vector171>:
.globl vector171
vector171:
  push $0
ffffffff8010814c:	6a 00                	pushq  $0x0
  push $171
ffffffff8010814e:	68 ab 00 00 00       	pushq  $0xab
  jmp alltraps
ffffffff80108153:	e9 49 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108158 <vector172>:
.globl vector172
vector172:
  push $0
ffffffff80108158:	6a 00                	pushq  $0x0
  push $172
ffffffff8010815a:	68 ac 00 00 00       	pushq  $0xac
  jmp alltraps
ffffffff8010815f:	e9 3d f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108164 <vector173>:
.globl vector173
vector173:
  push $0
ffffffff80108164:	6a 00                	pushq  $0x0
  push $173
ffffffff80108166:	68 ad 00 00 00       	pushq  $0xad
  jmp alltraps
ffffffff8010816b:	e9 31 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108170 <vector174>:
.globl vector174
vector174:
  push $0
ffffffff80108170:	6a 00                	pushq  $0x0
  push $174
ffffffff80108172:	68 ae 00 00 00       	pushq  $0xae
  jmp alltraps
ffffffff80108177:	e9 25 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010817c <vector175>:
.globl vector175
vector175:
  push $0
ffffffff8010817c:	6a 00                	pushq  $0x0
  push $175
ffffffff8010817e:	68 af 00 00 00       	pushq  $0xaf
  jmp alltraps
ffffffff80108183:	e9 19 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108188 <vector176>:
.globl vector176
vector176:
  push $0
ffffffff80108188:	6a 00                	pushq  $0x0
  push $176
ffffffff8010818a:	68 b0 00 00 00       	pushq  $0xb0
  jmp alltraps
ffffffff8010818f:	e9 0d f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108194 <vector177>:
.globl vector177
vector177:
  push $0
ffffffff80108194:	6a 00                	pushq  $0x0
  push $177
ffffffff80108196:	68 b1 00 00 00       	pushq  $0xb1
  jmp alltraps
ffffffff8010819b:	e9 01 f4 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081a0 <vector178>:
.globl vector178
vector178:
  push $0
ffffffff801081a0:	6a 00                	pushq  $0x0
  push $178
ffffffff801081a2:	68 b2 00 00 00       	pushq  $0xb2
  jmp alltraps
ffffffff801081a7:	e9 f5 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081ac <vector179>:
.globl vector179
vector179:
  push $0
ffffffff801081ac:	6a 00                	pushq  $0x0
  push $179
ffffffff801081ae:	68 b3 00 00 00       	pushq  $0xb3
  jmp alltraps
ffffffff801081b3:	e9 e9 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081b8 <vector180>:
.globl vector180
vector180:
  push $0
ffffffff801081b8:	6a 00                	pushq  $0x0
  push $180
ffffffff801081ba:	68 b4 00 00 00       	pushq  $0xb4
  jmp alltraps
ffffffff801081bf:	e9 dd f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081c4 <vector181>:
.globl vector181
vector181:
  push $0
ffffffff801081c4:	6a 00                	pushq  $0x0
  push $181
ffffffff801081c6:	68 b5 00 00 00       	pushq  $0xb5
  jmp alltraps
ffffffff801081cb:	e9 d1 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081d0 <vector182>:
.globl vector182
vector182:
  push $0
ffffffff801081d0:	6a 00                	pushq  $0x0
  push $182
ffffffff801081d2:	68 b6 00 00 00       	pushq  $0xb6
  jmp alltraps
ffffffff801081d7:	e9 c5 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081dc <vector183>:
.globl vector183
vector183:
  push $0
ffffffff801081dc:	6a 00                	pushq  $0x0
  push $183
ffffffff801081de:	68 b7 00 00 00       	pushq  $0xb7
  jmp alltraps
ffffffff801081e3:	e9 b9 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081e8 <vector184>:
.globl vector184
vector184:
  push $0
ffffffff801081e8:	6a 00                	pushq  $0x0
  push $184
ffffffff801081ea:	68 b8 00 00 00       	pushq  $0xb8
  jmp alltraps
ffffffff801081ef:	e9 ad f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801081f4 <vector185>:
.globl vector185
vector185:
  push $0
ffffffff801081f4:	6a 00                	pushq  $0x0
  push $185
ffffffff801081f6:	68 b9 00 00 00       	pushq  $0xb9
  jmp alltraps
ffffffff801081fb:	e9 a1 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108200 <vector186>:
.globl vector186
vector186:
  push $0
ffffffff80108200:	6a 00                	pushq  $0x0
  push $186
ffffffff80108202:	68 ba 00 00 00       	pushq  $0xba
  jmp alltraps
ffffffff80108207:	e9 95 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010820c <vector187>:
.globl vector187
vector187:
  push $0
ffffffff8010820c:	6a 00                	pushq  $0x0
  push $187
ffffffff8010820e:	68 bb 00 00 00       	pushq  $0xbb
  jmp alltraps
ffffffff80108213:	e9 89 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108218 <vector188>:
.globl vector188
vector188:
  push $0
ffffffff80108218:	6a 00                	pushq  $0x0
  push $188
ffffffff8010821a:	68 bc 00 00 00       	pushq  $0xbc
  jmp alltraps
ffffffff8010821f:	e9 7d f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108224 <vector189>:
.globl vector189
vector189:
  push $0
ffffffff80108224:	6a 00                	pushq  $0x0
  push $189
ffffffff80108226:	68 bd 00 00 00       	pushq  $0xbd
  jmp alltraps
ffffffff8010822b:	e9 71 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108230 <vector190>:
.globl vector190
vector190:
  push $0
ffffffff80108230:	6a 00                	pushq  $0x0
  push $190
ffffffff80108232:	68 be 00 00 00       	pushq  $0xbe
  jmp alltraps
ffffffff80108237:	e9 65 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010823c <vector191>:
.globl vector191
vector191:
  push $0
ffffffff8010823c:	6a 00                	pushq  $0x0
  push $191
ffffffff8010823e:	68 bf 00 00 00       	pushq  $0xbf
  jmp alltraps
ffffffff80108243:	e9 59 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108248 <vector192>:
.globl vector192
vector192:
  push $0
ffffffff80108248:	6a 00                	pushq  $0x0
  push $192
ffffffff8010824a:	68 c0 00 00 00       	pushq  $0xc0
  jmp alltraps
ffffffff8010824f:	e9 4d f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108254 <vector193>:
.globl vector193
vector193:
  push $0
ffffffff80108254:	6a 00                	pushq  $0x0
  push $193
ffffffff80108256:	68 c1 00 00 00       	pushq  $0xc1
  jmp alltraps
ffffffff8010825b:	e9 41 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108260 <vector194>:
.globl vector194
vector194:
  push $0
ffffffff80108260:	6a 00                	pushq  $0x0
  push $194
ffffffff80108262:	68 c2 00 00 00       	pushq  $0xc2
  jmp alltraps
ffffffff80108267:	e9 35 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010826c <vector195>:
.globl vector195
vector195:
  push $0
ffffffff8010826c:	6a 00                	pushq  $0x0
  push $195
ffffffff8010826e:	68 c3 00 00 00       	pushq  $0xc3
  jmp alltraps
ffffffff80108273:	e9 29 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108278 <vector196>:
.globl vector196
vector196:
  push $0
ffffffff80108278:	6a 00                	pushq  $0x0
  push $196
ffffffff8010827a:	68 c4 00 00 00       	pushq  $0xc4
  jmp alltraps
ffffffff8010827f:	e9 1d f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108284 <vector197>:
.globl vector197
vector197:
  push $0
ffffffff80108284:	6a 00                	pushq  $0x0
  push $197
ffffffff80108286:	68 c5 00 00 00       	pushq  $0xc5
  jmp alltraps
ffffffff8010828b:	e9 11 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108290 <vector198>:
.globl vector198
vector198:
  push $0
ffffffff80108290:	6a 00                	pushq  $0x0
  push $198
ffffffff80108292:	68 c6 00 00 00       	pushq  $0xc6
  jmp alltraps
ffffffff80108297:	e9 05 f3 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010829c <vector199>:
.globl vector199
vector199:
  push $0
ffffffff8010829c:	6a 00                	pushq  $0x0
  push $199
ffffffff8010829e:	68 c7 00 00 00       	pushq  $0xc7
  jmp alltraps
ffffffff801082a3:	e9 f9 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082a8 <vector200>:
.globl vector200
vector200:
  push $0
ffffffff801082a8:	6a 00                	pushq  $0x0
  push $200
ffffffff801082aa:	68 c8 00 00 00       	pushq  $0xc8
  jmp alltraps
ffffffff801082af:	e9 ed f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082b4 <vector201>:
.globl vector201
vector201:
  push $0
ffffffff801082b4:	6a 00                	pushq  $0x0
  push $201
ffffffff801082b6:	68 c9 00 00 00       	pushq  $0xc9
  jmp alltraps
ffffffff801082bb:	e9 e1 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082c0 <vector202>:
.globl vector202
vector202:
  push $0
ffffffff801082c0:	6a 00                	pushq  $0x0
  push $202
ffffffff801082c2:	68 ca 00 00 00       	pushq  $0xca
  jmp alltraps
ffffffff801082c7:	e9 d5 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082cc <vector203>:
.globl vector203
vector203:
  push $0
ffffffff801082cc:	6a 00                	pushq  $0x0
  push $203
ffffffff801082ce:	68 cb 00 00 00       	pushq  $0xcb
  jmp alltraps
ffffffff801082d3:	e9 c9 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082d8 <vector204>:
.globl vector204
vector204:
  push $0
ffffffff801082d8:	6a 00                	pushq  $0x0
  push $204
ffffffff801082da:	68 cc 00 00 00       	pushq  $0xcc
  jmp alltraps
ffffffff801082df:	e9 bd f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082e4 <vector205>:
.globl vector205
vector205:
  push $0
ffffffff801082e4:	6a 00                	pushq  $0x0
  push $205
ffffffff801082e6:	68 cd 00 00 00       	pushq  $0xcd
  jmp alltraps
ffffffff801082eb:	e9 b1 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082f0 <vector206>:
.globl vector206
vector206:
  push $0
ffffffff801082f0:	6a 00                	pushq  $0x0
  push $206
ffffffff801082f2:	68 ce 00 00 00       	pushq  $0xce
  jmp alltraps
ffffffff801082f7:	e9 a5 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801082fc <vector207>:
.globl vector207
vector207:
  push $0
ffffffff801082fc:	6a 00                	pushq  $0x0
  push $207
ffffffff801082fe:	68 cf 00 00 00       	pushq  $0xcf
  jmp alltraps
ffffffff80108303:	e9 99 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108308 <vector208>:
.globl vector208
vector208:
  push $0
ffffffff80108308:	6a 00                	pushq  $0x0
  push $208
ffffffff8010830a:	68 d0 00 00 00       	pushq  $0xd0
  jmp alltraps
ffffffff8010830f:	e9 8d f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108314 <vector209>:
.globl vector209
vector209:
  push $0
ffffffff80108314:	6a 00                	pushq  $0x0
  push $209
ffffffff80108316:	68 d1 00 00 00       	pushq  $0xd1
  jmp alltraps
ffffffff8010831b:	e9 81 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108320 <vector210>:
.globl vector210
vector210:
  push $0
ffffffff80108320:	6a 00                	pushq  $0x0
  push $210
ffffffff80108322:	68 d2 00 00 00       	pushq  $0xd2
  jmp alltraps
ffffffff80108327:	e9 75 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010832c <vector211>:
.globl vector211
vector211:
  push $0
ffffffff8010832c:	6a 00                	pushq  $0x0
  push $211
ffffffff8010832e:	68 d3 00 00 00       	pushq  $0xd3
  jmp alltraps
ffffffff80108333:	e9 69 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108338 <vector212>:
.globl vector212
vector212:
  push $0
ffffffff80108338:	6a 00                	pushq  $0x0
  push $212
ffffffff8010833a:	68 d4 00 00 00       	pushq  $0xd4
  jmp alltraps
ffffffff8010833f:	e9 5d f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108344 <vector213>:
.globl vector213
vector213:
  push $0
ffffffff80108344:	6a 00                	pushq  $0x0
  push $213
ffffffff80108346:	68 d5 00 00 00       	pushq  $0xd5
  jmp alltraps
ffffffff8010834b:	e9 51 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108350 <vector214>:
.globl vector214
vector214:
  push $0
ffffffff80108350:	6a 00                	pushq  $0x0
  push $214
ffffffff80108352:	68 d6 00 00 00       	pushq  $0xd6
  jmp alltraps
ffffffff80108357:	e9 45 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010835c <vector215>:
.globl vector215
vector215:
  push $0
ffffffff8010835c:	6a 00                	pushq  $0x0
  push $215
ffffffff8010835e:	68 d7 00 00 00       	pushq  $0xd7
  jmp alltraps
ffffffff80108363:	e9 39 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108368 <vector216>:
.globl vector216
vector216:
  push $0
ffffffff80108368:	6a 00                	pushq  $0x0
  push $216
ffffffff8010836a:	68 d8 00 00 00       	pushq  $0xd8
  jmp alltraps
ffffffff8010836f:	e9 2d f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108374 <vector217>:
.globl vector217
vector217:
  push $0
ffffffff80108374:	6a 00                	pushq  $0x0
  push $217
ffffffff80108376:	68 d9 00 00 00       	pushq  $0xd9
  jmp alltraps
ffffffff8010837b:	e9 21 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108380 <vector218>:
.globl vector218
vector218:
  push $0
ffffffff80108380:	6a 00                	pushq  $0x0
  push $218
ffffffff80108382:	68 da 00 00 00       	pushq  $0xda
  jmp alltraps
ffffffff80108387:	e9 15 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010838c <vector219>:
.globl vector219
vector219:
  push $0
ffffffff8010838c:	6a 00                	pushq  $0x0
  push $219
ffffffff8010838e:	68 db 00 00 00       	pushq  $0xdb
  jmp alltraps
ffffffff80108393:	e9 09 f2 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108398 <vector220>:
.globl vector220
vector220:
  push $0
ffffffff80108398:	6a 00                	pushq  $0x0
  push $220
ffffffff8010839a:	68 dc 00 00 00       	pushq  $0xdc
  jmp alltraps
ffffffff8010839f:	e9 fd f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083a4 <vector221>:
.globl vector221
vector221:
  push $0
ffffffff801083a4:	6a 00                	pushq  $0x0
  push $221
ffffffff801083a6:	68 dd 00 00 00       	pushq  $0xdd
  jmp alltraps
ffffffff801083ab:	e9 f1 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083b0 <vector222>:
.globl vector222
vector222:
  push $0
ffffffff801083b0:	6a 00                	pushq  $0x0
  push $222
ffffffff801083b2:	68 de 00 00 00       	pushq  $0xde
  jmp alltraps
ffffffff801083b7:	e9 e5 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083bc <vector223>:
.globl vector223
vector223:
  push $0
ffffffff801083bc:	6a 00                	pushq  $0x0
  push $223
ffffffff801083be:	68 df 00 00 00       	pushq  $0xdf
  jmp alltraps
ffffffff801083c3:	e9 d9 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083c8 <vector224>:
.globl vector224
vector224:
  push $0
ffffffff801083c8:	6a 00                	pushq  $0x0
  push $224
ffffffff801083ca:	68 e0 00 00 00       	pushq  $0xe0
  jmp alltraps
ffffffff801083cf:	e9 cd f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083d4 <vector225>:
.globl vector225
vector225:
  push $0
ffffffff801083d4:	6a 00                	pushq  $0x0
  push $225
ffffffff801083d6:	68 e1 00 00 00       	pushq  $0xe1
  jmp alltraps
ffffffff801083db:	e9 c1 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083e0 <vector226>:
.globl vector226
vector226:
  push $0
ffffffff801083e0:	6a 00                	pushq  $0x0
  push $226
ffffffff801083e2:	68 e2 00 00 00       	pushq  $0xe2
  jmp alltraps
ffffffff801083e7:	e9 b5 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083ec <vector227>:
.globl vector227
vector227:
  push $0
ffffffff801083ec:	6a 00                	pushq  $0x0
  push $227
ffffffff801083ee:	68 e3 00 00 00       	pushq  $0xe3
  jmp alltraps
ffffffff801083f3:	e9 a9 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801083f8 <vector228>:
.globl vector228
vector228:
  push $0
ffffffff801083f8:	6a 00                	pushq  $0x0
  push $228
ffffffff801083fa:	68 e4 00 00 00       	pushq  $0xe4
  jmp alltraps
ffffffff801083ff:	e9 9d f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108404 <vector229>:
.globl vector229
vector229:
  push $0
ffffffff80108404:	6a 00                	pushq  $0x0
  push $229
ffffffff80108406:	68 e5 00 00 00       	pushq  $0xe5
  jmp alltraps
ffffffff8010840b:	e9 91 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108410 <vector230>:
.globl vector230
vector230:
  push $0
ffffffff80108410:	6a 00                	pushq  $0x0
  push $230
ffffffff80108412:	68 e6 00 00 00       	pushq  $0xe6
  jmp alltraps
ffffffff80108417:	e9 85 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010841c <vector231>:
.globl vector231
vector231:
  push $0
ffffffff8010841c:	6a 00                	pushq  $0x0
  push $231
ffffffff8010841e:	68 e7 00 00 00       	pushq  $0xe7
  jmp alltraps
ffffffff80108423:	e9 79 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108428 <vector232>:
.globl vector232
vector232:
  push $0
ffffffff80108428:	6a 00                	pushq  $0x0
  push $232
ffffffff8010842a:	68 e8 00 00 00       	pushq  $0xe8
  jmp alltraps
ffffffff8010842f:	e9 6d f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108434 <vector233>:
.globl vector233
vector233:
  push $0
ffffffff80108434:	6a 00                	pushq  $0x0
  push $233
ffffffff80108436:	68 e9 00 00 00       	pushq  $0xe9
  jmp alltraps
ffffffff8010843b:	e9 61 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108440 <vector234>:
.globl vector234
vector234:
  push $0
ffffffff80108440:	6a 00                	pushq  $0x0
  push $234
ffffffff80108442:	68 ea 00 00 00       	pushq  $0xea
  jmp alltraps
ffffffff80108447:	e9 55 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010844c <vector235>:
.globl vector235
vector235:
  push $0
ffffffff8010844c:	6a 00                	pushq  $0x0
  push $235
ffffffff8010844e:	68 eb 00 00 00       	pushq  $0xeb
  jmp alltraps
ffffffff80108453:	e9 49 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108458 <vector236>:
.globl vector236
vector236:
  push $0
ffffffff80108458:	6a 00                	pushq  $0x0
  push $236
ffffffff8010845a:	68 ec 00 00 00       	pushq  $0xec
  jmp alltraps
ffffffff8010845f:	e9 3d f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108464 <vector237>:
.globl vector237
vector237:
  push $0
ffffffff80108464:	6a 00                	pushq  $0x0
  push $237
ffffffff80108466:	68 ed 00 00 00       	pushq  $0xed
  jmp alltraps
ffffffff8010846b:	e9 31 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108470 <vector238>:
.globl vector238
vector238:
  push $0
ffffffff80108470:	6a 00                	pushq  $0x0
  push $238
ffffffff80108472:	68 ee 00 00 00       	pushq  $0xee
  jmp alltraps
ffffffff80108477:	e9 25 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010847c <vector239>:
.globl vector239
vector239:
  push $0
ffffffff8010847c:	6a 00                	pushq  $0x0
  push $239
ffffffff8010847e:	68 ef 00 00 00       	pushq  $0xef
  jmp alltraps
ffffffff80108483:	e9 19 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108488 <vector240>:
.globl vector240
vector240:
  push $0
ffffffff80108488:	6a 00                	pushq  $0x0
  push $240
ffffffff8010848a:	68 f0 00 00 00       	pushq  $0xf0
  jmp alltraps
ffffffff8010848f:	e9 0d f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108494 <vector241>:
.globl vector241
vector241:
  push $0
ffffffff80108494:	6a 00                	pushq  $0x0
  push $241
ffffffff80108496:	68 f1 00 00 00       	pushq  $0xf1
  jmp alltraps
ffffffff8010849b:	e9 01 f1 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084a0 <vector242>:
.globl vector242
vector242:
  push $0
ffffffff801084a0:	6a 00                	pushq  $0x0
  push $242
ffffffff801084a2:	68 f2 00 00 00       	pushq  $0xf2
  jmp alltraps
ffffffff801084a7:	e9 f5 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084ac <vector243>:
.globl vector243
vector243:
  push $0
ffffffff801084ac:	6a 00                	pushq  $0x0
  push $243
ffffffff801084ae:	68 f3 00 00 00       	pushq  $0xf3
  jmp alltraps
ffffffff801084b3:	e9 e9 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084b8 <vector244>:
.globl vector244
vector244:
  push $0
ffffffff801084b8:	6a 00                	pushq  $0x0
  push $244
ffffffff801084ba:	68 f4 00 00 00       	pushq  $0xf4
  jmp alltraps
ffffffff801084bf:	e9 dd f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084c4 <vector245>:
.globl vector245
vector245:
  push $0
ffffffff801084c4:	6a 00                	pushq  $0x0
  push $245
ffffffff801084c6:	68 f5 00 00 00       	pushq  $0xf5
  jmp alltraps
ffffffff801084cb:	e9 d1 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084d0 <vector246>:
.globl vector246
vector246:
  push $0
ffffffff801084d0:	6a 00                	pushq  $0x0
  push $246
ffffffff801084d2:	68 f6 00 00 00       	pushq  $0xf6
  jmp alltraps
ffffffff801084d7:	e9 c5 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084dc <vector247>:
.globl vector247
vector247:
  push $0
ffffffff801084dc:	6a 00                	pushq  $0x0
  push $247
ffffffff801084de:	68 f7 00 00 00       	pushq  $0xf7
  jmp alltraps
ffffffff801084e3:	e9 b9 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084e8 <vector248>:
.globl vector248
vector248:
  push $0
ffffffff801084e8:	6a 00                	pushq  $0x0
  push $248
ffffffff801084ea:	68 f8 00 00 00       	pushq  $0xf8
  jmp alltraps
ffffffff801084ef:	e9 ad f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff801084f4 <vector249>:
.globl vector249
vector249:
  push $0
ffffffff801084f4:	6a 00                	pushq  $0x0
  push $249
ffffffff801084f6:	68 f9 00 00 00       	pushq  $0xf9
  jmp alltraps
ffffffff801084fb:	e9 a1 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108500 <vector250>:
.globl vector250
vector250:
  push $0
ffffffff80108500:	6a 00                	pushq  $0x0
  push $250
ffffffff80108502:	68 fa 00 00 00       	pushq  $0xfa
  jmp alltraps
ffffffff80108507:	e9 95 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010850c <vector251>:
.globl vector251
vector251:
  push $0
ffffffff8010850c:	6a 00                	pushq  $0x0
  push $251
ffffffff8010850e:	68 fb 00 00 00       	pushq  $0xfb
  jmp alltraps
ffffffff80108513:	e9 89 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108518 <vector252>:
.globl vector252
vector252:
  push $0
ffffffff80108518:	6a 00                	pushq  $0x0
  push $252
ffffffff8010851a:	68 fc 00 00 00       	pushq  $0xfc
  jmp alltraps
ffffffff8010851f:	e9 7d f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108524 <vector253>:
.globl vector253
vector253:
  push $0
ffffffff80108524:	6a 00                	pushq  $0x0
  push $253
ffffffff80108526:	68 fd 00 00 00       	pushq  $0xfd
  jmp alltraps
ffffffff8010852b:	e9 71 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108530 <vector254>:
.globl vector254
vector254:
  push $0
ffffffff80108530:	6a 00                	pushq  $0x0
  push $254
ffffffff80108532:	68 fe 00 00 00       	pushq  $0xfe
  jmp alltraps
ffffffff80108537:	e9 65 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff8010853c <vector255>:
.globl vector255
vector255:
  push $0
ffffffff8010853c:	6a 00                	pushq  $0x0
  push $255
ffffffff8010853e:	68 ff 00 00 00       	pushq  $0xff
  jmp alltraps
ffffffff80108543:	e9 59 f0 ff ff       	jmpq   ffffffff801075a1 <alltraps>

ffffffff80108548 <v2p>:
static inline uintp v2p(void *a) { return ((uintp) (a)) - ((uintp)KERNBASE); }
ffffffff80108548:	55                   	push   %rbp
ffffffff80108549:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010854c:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80108550:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80108554:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80108558:	b8 00 00 00 80       	mov    $0x80000000,%eax
ffffffff8010855d:	48 01 d0             	add    %rdx,%rax
ffffffff80108560:	c9                   	leaveq 
ffffffff80108561:	c3                   	retq   

ffffffff80108562 <p2v>:
static inline void *p2v(uintp a) { return (void *) ((a) + ((uintp)KERNBASE)); }
ffffffff80108562:	55                   	push   %rbp
ffffffff80108563:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108566:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff8010856a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff8010856e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108572:	48 05 00 00 00 80    	add    $0xffffffff80000000,%rax
ffffffff80108578:	c9                   	leaveq 
ffffffff80108579:	c3                   	retq   

ffffffff8010857a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
ffffffff8010857a:	55                   	push   %rbp
ffffffff8010857b:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010857e:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80108582:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108586:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff8010858a:	89 55 dc             	mov    %edx,-0x24(%rbp)
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
ffffffff8010858d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108591:	48 c1 e8 15          	shr    $0x15,%rax
ffffffff80108595:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff8010859a:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff801085a1:	00 
ffffffff801085a2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801085a6:	48 01 d0             	add    %rdx,%rax
ffffffff801085a9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  if(*pde & PTE_P){
ffffffff801085ad:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801085b1:	48 8b 00             	mov    (%rax),%rax
ffffffff801085b4:	83 e0 01             	and    $0x1,%eax
ffffffff801085b7:	48 85 c0             	test   %rax,%rax
ffffffff801085ba:	74 1b                	je     ffffffff801085d7 <walkpgdir+0x5d>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
ffffffff801085bc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801085c0:	48 8b 00             	mov    (%rax),%rax
ffffffff801085c3:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801085c9:	48 89 c7             	mov    %rax,%rdi
ffffffff801085cc:	e8 91 ff ff ff       	callq  ffffffff80108562 <p2v>
ffffffff801085d1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801085d5:	eb 4d                	jmp    ffffffff80108624 <walkpgdir+0xaa>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
ffffffff801085d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
ffffffff801085db:	74 10                	je     ffffffff801085ed <walkpgdir+0x73>
ffffffff801085dd:	e8 a9 ac ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff801085e2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
ffffffff801085e6:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff801085eb:	75 07                	jne    ffffffff801085f4 <walkpgdir+0x7a>
      return 0;
ffffffff801085ed:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801085f2:	eb 4c                	jmp    ffffffff80108640 <walkpgdir+0xc6>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
ffffffff801085f4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801085f8:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801085fd:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80108602:	48 89 c7             	mov    %rax,%rdi
ffffffff80108605:	e8 a7 d8 ff ff       	callq  ffffffff80105eb1 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
ffffffff8010860a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010860e:	48 89 c7             	mov    %rax,%rdi
ffffffff80108611:	e8 32 ff ff ff       	callq  ffffffff80108548 <v2p>
ffffffff80108616:	48 83 c8 07          	or     $0x7,%rax
ffffffff8010861a:	48 89 c2             	mov    %rax,%rdx
ffffffff8010861d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108621:	48 89 10             	mov    %rdx,(%rax)
  }
  return &pgtab[PTX(va)];
ffffffff80108624:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108628:	48 c1 e8 0c          	shr    $0xc,%rax
ffffffff8010862c:	25 ff 01 00 00       	and    $0x1ff,%eax
ffffffff80108631:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80108638:	00 
ffffffff80108639:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010863d:	48 01 d0             	add    %rdx,%rax
}
ffffffff80108640:	c9                   	leaveq 
ffffffff80108641:	c3                   	retq   

ffffffff80108642 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uintp size, uintp pa, int perm)
{
ffffffff80108642:	55                   	push   %rbp
ffffffff80108643:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108646:	48 83 ec 50          	sub    $0x50,%rsp
ffffffff8010864a:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff8010864e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff80108652:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
ffffffff80108656:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
ffffffff8010865a:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uintp)va);
ffffffff8010865e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80108662:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108668:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  last = (char*)PGROUNDDOWN(((uintp)va) + size - 1);
ffffffff8010866c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
ffffffff80108670:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80108674:	48 01 d0             	add    %rdx,%rax
ffffffff80108677:	48 83 e8 01          	sub    $0x1,%rax
ffffffff8010867b:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108681:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
ffffffff80108685:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff80108689:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff8010868d:	ba 01 00 00 00       	mov    $0x1,%edx
ffffffff80108692:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108695:	48 89 c7             	mov    %rax,%rdi
ffffffff80108698:	e8 dd fe ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff8010869d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
ffffffff801086a1:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff801086a6:	75 07                	jne    ffffffff801086af <mappages+0x6d>
      return -1;
ffffffff801086a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff801086ad:	eb 54                	jmp    ffffffff80108703 <mappages+0xc1>
    if(*pte & PTE_P)
ffffffff801086af:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801086b3:	48 8b 00             	mov    (%rax),%rax
ffffffff801086b6:	83 e0 01             	and    $0x1,%eax
ffffffff801086b9:	48 85 c0             	test   %rax,%rax
ffffffff801086bc:	74 0c                	je     ffffffff801086ca <mappages+0x88>
      panic("remap");
ffffffff801086be:	48 c7 c7 e0 9c 10 80 	mov    $0xffffffff80109ce0,%rdi
ffffffff801086c5:	e8 34 82 ff ff       	callq  ffffffff801008fe <panic>
    *pte = pa | perm | PTE_P;
ffffffff801086ca:	8b 45 bc             	mov    -0x44(%rbp),%eax
ffffffff801086cd:	48 98                	cltq   
ffffffff801086cf:	48 0b 45 c0          	or     -0x40(%rbp),%rax
ffffffff801086d3:	48 83 c8 01          	or     $0x1,%rax
ffffffff801086d7:	48 89 c2             	mov    %rax,%rdx
ffffffff801086da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801086de:	48 89 10             	mov    %rdx,(%rax)
    if(a == last)
ffffffff801086e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801086e5:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
ffffffff801086e9:	74 12                	je     ffffffff801086fd <mappages+0xbb>
      break;
    a += PGSIZE;
ffffffff801086eb:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
ffffffff801086f2:	00 
    pa += PGSIZE;
ffffffff801086f3:	48 81 45 c0 00 10 00 	addq   $0x1000,-0x40(%rbp)
ffffffff801086fa:	00 
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
ffffffff801086fb:	eb 88                	jmp    ffffffff80108685 <mappages+0x43>
      break;
ffffffff801086fd:	90                   	nop
  }
  return 0;
ffffffff801086fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80108703:	c9                   	leaveq 
ffffffff80108704:	c3                   	retq   

ffffffff80108705 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
ffffffff80108705:	55                   	push   %rbp
ffffffff80108706:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108709:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff8010870d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108711:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
ffffffff80108715:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *mem;
  
  if(sz >= PGSIZE)
ffffffff80108718:	81 7d dc ff 0f 00 00 	cmpl   $0xfff,-0x24(%rbp)
ffffffff8010871f:	76 0c                	jbe    ffffffff8010872d <inituvm+0x28>
    panic("inituvm: more than a page");
ffffffff80108721:	48 c7 c7 e6 9c 10 80 	mov    $0xffffffff80109ce6,%rdi
ffffffff80108728:	e8 d1 81 ff ff       	callq  ffffffff801008fe <panic>
  mem = kalloc();
ffffffff8010872d:	e8 59 ab ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80108732:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(mem, 0, PGSIZE);
ffffffff80108736:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010873a:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff8010873f:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80108744:	48 89 c7             	mov    %rax,%rdi
ffffffff80108747:	e8 65 d7 ff ff       	callq  ffffffff80105eb1 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
ffffffff8010874c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108750:	48 89 c7             	mov    %rax,%rdi
ffffffff80108753:	e8 f0 fd ff ff       	callq  ffffffff80108548 <v2p>
ffffffff80108758:	48 89 c2             	mov    %rax,%rdx
ffffffff8010875b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010875f:	41 b8 06 00 00 00    	mov    $0x6,%r8d
ffffffff80108765:	48 89 d1             	mov    %rdx,%rcx
ffffffff80108768:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff8010876d:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80108772:	48 89 c7             	mov    %rax,%rdi
ffffffff80108775:	e8 c8 fe ff ff       	callq  ffffffff80108642 <mappages>
  memmove(mem, init, sz);
ffffffff8010877a:	8b 55 dc             	mov    -0x24(%rbp),%edx
ffffffff8010877d:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
ffffffff80108781:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108785:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108788:	48 89 c7             	mov    %rax,%rdi
ffffffff8010878b:	e8 10 d8 ff ff       	callq  ffffffff80105fa0 <memmove>
}
ffffffff80108790:	90                   	nop
ffffffff80108791:	c9                   	leaveq 
ffffffff80108792:	c3                   	retq   

ffffffff80108793 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
ffffffff80108793:	55                   	push   %rbp
ffffffff80108794:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108797:	53                   	push   %rbx
ffffffff80108798:	48 83 ec 48          	sub    $0x48,%rsp
ffffffff8010879c:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
ffffffff801087a0:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
ffffffff801087a4:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
ffffffff801087a8:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
ffffffff801087ab:	44 89 45 b0          	mov    %r8d,-0x50(%rbp)
  uint i, pa, n;
  pte_t *pte;

  if((uintp) addr % PGSIZE != 0)
ffffffff801087af:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801087b3:	25 ff 0f 00 00       	and    $0xfff,%eax
ffffffff801087b8:	48 85 c0             	test   %rax,%rax
ffffffff801087bb:	74 0c                	je     ffffffff801087c9 <loaduvm+0x36>
    panic("loaduvm: addr must be page aligned");
ffffffff801087bd:	48 c7 c7 00 9d 10 80 	mov    $0xffffffff80109d00,%rdi
ffffffff801087c4:	e8 35 81 ff ff       	callq  ffffffff801008fe <panic>
  for(i = 0; i < sz; i += PGSIZE){
ffffffff801087c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
ffffffff801087d0:	e9 a1 00 00 00       	jmpq   ffffffff80108876 <loaduvm+0xe3>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
ffffffff801087d5:	8b 55 ec             	mov    -0x14(%rbp),%edx
ffffffff801087d8:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff801087dc:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
ffffffff801087e0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff801087e4:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff801087e9:	48 89 ce             	mov    %rcx,%rsi
ffffffff801087ec:	48 89 c7             	mov    %rax,%rdi
ffffffff801087ef:	e8 86 fd ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff801087f4:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff801087f8:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
ffffffff801087fd:	75 0c                	jne    ffffffff8010880b <loaduvm+0x78>
      panic("loaduvm: address should exist");
ffffffff801087ff:	48 c7 c7 23 9d 10 80 	mov    $0xffffffff80109d23,%rdi
ffffffff80108806:	e8 f3 80 ff ff       	callq  ffffffff801008fe <panic>
    pa = PTE_ADDR(*pte);
ffffffff8010880b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010880f:	48 8b 00             	mov    (%rax),%rax
ffffffff80108812:	25 00 f0 ff ff       	and    $0xfffff000,%eax
ffffffff80108817:	89 45 dc             	mov    %eax,-0x24(%rbp)
    if(sz - i < PGSIZE)
ffffffff8010881a:	8b 45 b0             	mov    -0x50(%rbp),%eax
ffffffff8010881d:	2b 45 ec             	sub    -0x14(%rbp),%eax
ffffffff80108820:	3d ff 0f 00 00       	cmp    $0xfff,%eax
ffffffff80108825:	77 0b                	ja     ffffffff80108832 <loaduvm+0x9f>
      n = sz - i;
ffffffff80108827:	8b 45 b0             	mov    -0x50(%rbp),%eax
ffffffff8010882a:	2b 45 ec             	sub    -0x14(%rbp),%eax
ffffffff8010882d:	89 45 e8             	mov    %eax,-0x18(%rbp)
ffffffff80108830:	eb 07                	jmp    ffffffff80108839 <loaduvm+0xa6>
    else
      n = PGSIZE;
ffffffff80108832:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%rbp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
ffffffff80108839:	8b 55 b4             	mov    -0x4c(%rbp),%edx
ffffffff8010883c:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff8010883f:	8d 1c 02             	lea    (%rdx,%rax,1),%ebx
ffffffff80108842:	8b 45 dc             	mov    -0x24(%rbp),%eax
ffffffff80108845:	48 89 c7             	mov    %rax,%rdi
ffffffff80108848:	e8 15 fd ff ff       	callq  ffffffff80108562 <p2v>
ffffffff8010884d:	48 89 c6             	mov    %rax,%rsi
ffffffff80108850:	8b 55 e8             	mov    -0x18(%rbp),%edx
ffffffff80108853:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff80108857:	89 d1                	mov    %edx,%ecx
ffffffff80108859:	89 da                	mov    %ebx,%edx
ffffffff8010885b:	48 89 c7             	mov    %rax,%rdi
ffffffff8010885e:	e8 92 9b ff ff       	callq  ffffffff801023f5 <readi>
ffffffff80108863:	39 45 e8             	cmp    %eax,-0x18(%rbp)
ffffffff80108866:	74 07                	je     ffffffff8010886f <loaduvm+0xdc>
      return -1;
ffffffff80108868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff8010886d:	eb 18                	jmp    ffffffff80108887 <loaduvm+0xf4>
  for(i = 0; i < sz; i += PGSIZE){
ffffffff8010886f:	81 45 ec 00 10 00 00 	addl   $0x1000,-0x14(%rbp)
ffffffff80108876:	8b 45 ec             	mov    -0x14(%rbp),%eax
ffffffff80108879:	3b 45 b0             	cmp    -0x50(%rbp),%eax
ffffffff8010887c:	0f 82 53 ff ff ff    	jb     ffffffff801087d5 <loaduvm+0x42>
  }
  return 0;
ffffffff80108882:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80108887:	48 83 c4 48          	add    $0x48,%rsp
ffffffff8010888b:	5b                   	pop    %rbx
ffffffff8010888c:	5d                   	pop    %rbp
ffffffff8010888d:	c3                   	retq   

ffffffff8010888e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
ffffffff8010888e:	55                   	push   %rbp
ffffffff8010888f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108892:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108896:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff8010889a:	89 75 e4             	mov    %esi,-0x1c(%rbp)
ffffffff8010889d:	89 55 e0             	mov    %edx,-0x20(%rbp)
  char *mem;
  uintp a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
ffffffff801088a0:	8b 45 e0             	mov    -0x20(%rbp),%eax
ffffffff801088a3:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
ffffffff801088a6:	73 08                	jae    ffffffff801088b0 <allocuvm+0x22>
    return oldsz;
ffffffff801088a8:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff801088ab:	e9 b0 00 00 00       	jmpq   ffffffff80108960 <allocuvm+0xd2>

  a = PGROUNDUP(oldsz);
ffffffff801088b0:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff801088b3:	48 05 ff 0f 00 00    	add    $0xfff,%rax
ffffffff801088b9:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801088bf:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  for(; a < newsz; a += PGSIZE){
ffffffff801088c3:	e9 88 00 00 00       	jmpq   ffffffff80108950 <allocuvm+0xc2>
    mem = kalloc();
ffffffff801088c8:	e8 be a9 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff801088cd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if(mem == 0){
ffffffff801088d1:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff801088d6:	75 2d                	jne    ffffffff80108905 <allocuvm+0x77>
      cprintf("allocuvm out of memory\n");
ffffffff801088d8:	48 c7 c7 41 9d 10 80 	mov    $0xffffffff80109d41,%rdi
ffffffff801088df:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff801088e4:	e8 b8 7c ff ff       	callq  ffffffff801005a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
ffffffff801088e9:	8b 55 e4             	mov    -0x1c(%rbp),%edx
ffffffff801088ec:	8b 4d e0             	mov    -0x20(%rbp),%ecx
ffffffff801088ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801088f3:	48 89 ce             	mov    %rcx,%rsi
ffffffff801088f6:	48 89 c7             	mov    %rax,%rdi
ffffffff801088f9:	e8 64 00 00 00       	callq  ffffffff80108962 <deallocuvm>
      return 0;
ffffffff801088fe:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80108903:	eb 5b                	jmp    ffffffff80108960 <allocuvm+0xd2>
    }
    memset(mem, 0, PGSIZE);
ffffffff80108905:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108909:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff8010890e:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80108913:	48 89 c7             	mov    %rax,%rdi
ffffffff80108916:	e8 96 d5 ff ff       	callq  ffffffff80105eb1 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
ffffffff8010891b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff8010891f:	48 89 c7             	mov    %rax,%rdi
ffffffff80108922:	e8 21 fc ff ff       	callq  ffffffff80108548 <v2p>
ffffffff80108927:	48 89 c2             	mov    %rax,%rdx
ffffffff8010892a:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
ffffffff8010892e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108932:	41 b8 06 00 00 00    	mov    $0x6,%r8d
ffffffff80108938:	48 89 d1             	mov    %rdx,%rcx
ffffffff8010893b:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff80108940:	48 89 c7             	mov    %rax,%rdi
ffffffff80108943:	e8 fa fc ff ff       	callq  ffffffff80108642 <mappages>
  for(; a < newsz; a += PGSIZE){
ffffffff80108948:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
ffffffff8010894f:	00 
ffffffff80108950:	8b 45 e0             	mov    -0x20(%rbp),%eax
ffffffff80108953:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
ffffffff80108957:	0f 82 6b ff ff ff    	jb     ffffffff801088c8 <allocuvm+0x3a>
  }
  return newsz;
ffffffff8010895d:	8b 45 e0             	mov    -0x20(%rbp),%eax
}
ffffffff80108960:	c9                   	leaveq 
ffffffff80108961:	c3                   	retq   

ffffffff80108962 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uintp oldsz, uintp newsz)
{
ffffffff80108962:	55                   	push   %rbp
ffffffff80108963:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108966:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff8010896a:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff8010896e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
ffffffff80108972:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  pte_t *pte;
  uintp a, pa;

  if(newsz >= oldsz)
ffffffff80108976:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff8010897a:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
ffffffff8010897e:	72 09                	jb     ffffffff80108989 <deallocuvm+0x27>
    return oldsz;
ffffffff80108980:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80108984:	e9 ba 00 00 00       	jmpq   ffffffff80108a43 <deallocuvm+0xe1>

  a = PGROUNDUP(newsz);
ffffffff80108989:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff8010898d:	48 05 ff 0f 00 00    	add    $0xfff,%rax
ffffffff80108993:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108999:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  for(; a  < oldsz; a += PGSIZE){
ffffffff8010899d:	e9 8f 00 00 00       	jmpq   ffffffff80108a31 <deallocuvm+0xcf>
    pte = walkpgdir(pgdir, (char*)a, 0);
ffffffff801089a2:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
ffffffff801089a6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff801089aa:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff801089af:	48 89 ce             	mov    %rcx,%rsi
ffffffff801089b2:	48 89 c7             	mov    %rax,%rdi
ffffffff801089b5:	e8 c0 fb ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff801089ba:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if(!pte)
ffffffff801089be:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
ffffffff801089c3:	75 0a                	jne    ffffffff801089cf <deallocuvm+0x6d>
      a += (NPTENTRIES - 1) * PGSIZE;
ffffffff801089c5:	48 81 45 f8 00 f0 1f 	addq   $0x1ff000,-0x8(%rbp)
ffffffff801089cc:	00 
ffffffff801089cd:	eb 5a                	jmp    ffffffff80108a29 <deallocuvm+0xc7>
    else if((*pte & PTE_P) != 0){
ffffffff801089cf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801089d3:	48 8b 00             	mov    (%rax),%rax
ffffffff801089d6:	83 e0 01             	and    $0x1,%eax
ffffffff801089d9:	48 85 c0             	test   %rax,%rax
ffffffff801089dc:	74 4b                	je     ffffffff80108a29 <deallocuvm+0xc7>
      pa = PTE_ADDR(*pte);
ffffffff801089de:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801089e2:	48 8b 00             	mov    (%rax),%rax
ffffffff801089e5:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801089eb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
      if(pa == 0)
ffffffff801089ef:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff801089f4:	75 0c                	jne    ffffffff80108a02 <deallocuvm+0xa0>
        panic("kfree");
ffffffff801089f6:	48 c7 c7 59 9d 10 80 	mov    $0xffffffff80109d59,%rdi
ffffffff801089fd:	e8 fc 7e ff ff       	callq  ffffffff801008fe <panic>
      char *v = p2v(pa);
ffffffff80108a02:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108a06:	48 89 c7             	mov    %rax,%rdi
ffffffff80108a09:	e8 54 fb ff ff       	callq  ffffffff80108562 <p2v>
ffffffff80108a0e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
      kfree(v);
ffffffff80108a12:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108a16:	48 89 c7             	mov    %rax,%rdi
ffffffff80108a19:	e8 c3 a7 ff ff       	callq  ffffffff801031e1 <kfree>
      *pte = 0;
ffffffff80108a1e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108a22:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for(; a  < oldsz; a += PGSIZE){
ffffffff80108a29:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
ffffffff80108a30:	00 
ffffffff80108a31:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108a35:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
ffffffff80108a39:	0f 82 63 ff ff ff    	jb     ffffffff801089a2 <deallocuvm+0x40>
    }
  }
  return newsz;
ffffffff80108a3f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
}
ffffffff80108a43:	c9                   	leaveq 
ffffffff80108a44:	c3                   	retq   

ffffffff80108a45 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
ffffffff80108a45:	55                   	push   %rbp
ffffffff80108a46:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108a49:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108a4d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  uint i;
  if(pgdir == 0)
ffffffff80108a51:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
ffffffff80108a56:	75 0c                	jne    ffffffff80108a64 <freevm+0x1f>
    panic("freevm: no pgdir");
ffffffff80108a58:	48 c7 c7 5f 9d 10 80 	mov    $0xffffffff80109d5f,%rdi
ffffffff80108a5f:	e8 9a 7e ff ff       	callq  ffffffff801008fe <panic>
  deallocuvm(pgdir, 0x3fa00000, 0);
ffffffff80108a64:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108a68:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80108a6d:	be 00 00 a0 3f       	mov    $0x3fa00000,%esi
ffffffff80108a72:	48 89 c7             	mov    %rax,%rdi
ffffffff80108a75:	e8 e8 fe ff ff       	callq  ffffffff80108962 <deallocuvm>
  for(i = 0; i < NPDENTRIES-2; i++){
ffffffff80108a7a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80108a81:	eb 54                	jmp    ffffffff80108ad7 <freevm+0x92>
    if(pgdir[i] & PTE_P){
ffffffff80108a83:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80108a86:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80108a8d:	00 
ffffffff80108a8e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108a92:	48 01 d0             	add    %rdx,%rax
ffffffff80108a95:	48 8b 00             	mov    (%rax),%rax
ffffffff80108a98:	83 e0 01             	and    $0x1,%eax
ffffffff80108a9b:	48 85 c0             	test   %rax,%rax
ffffffff80108a9e:	74 33                	je     ffffffff80108ad3 <freevm+0x8e>
      char * v = p2v(PTE_ADDR(pgdir[i]));
ffffffff80108aa0:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80108aa3:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
ffffffff80108aaa:	00 
ffffffff80108aab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108aaf:	48 01 d0             	add    %rdx,%rax
ffffffff80108ab2:	48 8b 00             	mov    (%rax),%rax
ffffffff80108ab5:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108abb:	48 89 c7             	mov    %rax,%rdi
ffffffff80108abe:	e8 9f fa ff ff       	callq  ffffffff80108562 <p2v>
ffffffff80108ac3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
      kfree(v);
ffffffff80108ac7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108acb:	48 89 c7             	mov    %rax,%rdi
ffffffff80108ace:	e8 0e a7 ff ff       	callq  ffffffff801031e1 <kfree>
  for(i = 0; i < NPDENTRIES-2; i++){
ffffffff80108ad3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80108ad7:	81 7d fc fd 01 00 00 	cmpl   $0x1fd,-0x4(%rbp)
ffffffff80108ade:	76 a3                	jbe    ffffffff80108a83 <freevm+0x3e>
    }
  }
  kfree((char*)pgdir);
ffffffff80108ae0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108ae4:	48 89 c7             	mov    %rax,%rdi
ffffffff80108ae7:	e8 f5 a6 ff ff       	callq  ffffffff801031e1 <kfree>
}
ffffffff80108aec:	90                   	nop
ffffffff80108aed:	c9                   	leaveq 
ffffffff80108aee:	c3                   	retq   

ffffffff80108aef <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
ffffffff80108aef:	55                   	push   %rbp
ffffffff80108af0:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108af3:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108af7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108afb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
ffffffff80108aff:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
ffffffff80108b03:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108b07:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80108b0c:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108b0f:	48 89 c7             	mov    %rax,%rdi
ffffffff80108b12:	e8 63 fa ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff80108b17:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(pte == 0)
ffffffff80108b1b:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
ffffffff80108b20:	75 0c                	jne    ffffffff80108b2e <clearpteu+0x3f>
    panic("clearpteu");
ffffffff80108b22:	48 c7 c7 70 9d 10 80 	mov    $0xffffffff80109d70,%rdi
ffffffff80108b29:	e8 d0 7d ff ff       	callq  ffffffff801008fe <panic>
  *pte &= ~PTE_U;
ffffffff80108b2e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108b32:	48 8b 00             	mov    (%rax),%rax
ffffffff80108b35:	48 83 e0 fb          	and    $0xfffffffffffffffb,%rax
ffffffff80108b39:	48 89 c2             	mov    %rax,%rdx
ffffffff80108b3c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108b40:	48 89 10             	mov    %rdx,(%rax)
}
ffffffff80108b43:	90                   	nop
ffffffff80108b44:	c9                   	leaveq 
ffffffff80108b45:	c3                   	retq   

ffffffff80108b46 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
ffffffff80108b46:	55                   	push   %rbp
ffffffff80108b47:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108b4a:	53                   	push   %rbx
ffffffff80108b4b:	48 83 ec 48          	sub    $0x48,%rsp
ffffffff80108b4f:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
ffffffff80108b53:	89 75 b4             	mov    %esi,-0x4c(%rbp)
  pde_t *d;
  pte_t *pte;
  uintp pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
ffffffff80108b56:	e8 0d 07 00 00       	callq  ffffffff80109268 <setupkvm>
ffffffff80108b5b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
ffffffff80108b5f:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
ffffffff80108b64:	75 0a                	jne    ffffffff80108b70 <copyuvm+0x2a>
    return 0;
ffffffff80108b66:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80108b6b:	e9 0f 01 00 00       	jmpq   ffffffff80108c7f <copyuvm+0x139>
  for(i = 0; i < sz; i += PGSIZE){
ffffffff80108b70:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
ffffffff80108b77:	00 
ffffffff80108b78:	e9 da 00 00 00       	jmpq   ffffffff80108c57 <copyuvm+0x111>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
ffffffff80108b7d:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
ffffffff80108b81:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
ffffffff80108b85:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80108b8a:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108b8d:	48 89 c7             	mov    %rax,%rdi
ffffffff80108b90:	e8 e5 f9 ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff80108b95:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
ffffffff80108b99:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
ffffffff80108b9e:	75 0c                	jne    ffffffff80108bac <copyuvm+0x66>
      panic("copyuvm: pte should exist");
ffffffff80108ba0:	48 c7 c7 7a 9d 10 80 	mov    $0xffffffff80109d7a,%rdi
ffffffff80108ba7:	e8 52 7d ff ff       	callq  ffffffff801008fe <panic>
    if(!(*pte & PTE_P))
ffffffff80108bac:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80108bb0:	48 8b 00             	mov    (%rax),%rax
ffffffff80108bb3:	83 e0 01             	and    $0x1,%eax
ffffffff80108bb6:	48 85 c0             	test   %rax,%rax
ffffffff80108bb9:	75 0c                	jne    ffffffff80108bc7 <copyuvm+0x81>
      panic("copyuvm: page not present");
ffffffff80108bbb:	48 c7 c7 94 9d 10 80 	mov    $0xffffffff80109d94,%rdi
ffffffff80108bc2:	e8 37 7d ff ff       	callq  ffffffff801008fe <panic>
    pa = PTE_ADDR(*pte);
ffffffff80108bc7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80108bcb:	48 8b 00             	mov    (%rax),%rax
ffffffff80108bce:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108bd4:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    flags = PTE_FLAGS(*pte);
ffffffff80108bd8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80108bdc:	48 8b 00             	mov    (%rax),%rax
ffffffff80108bdf:	25 ff 0f 00 00       	and    $0xfff,%eax
ffffffff80108be4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    if((mem = kalloc()) == 0)
ffffffff80108be8:	e8 9e a6 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80108bed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
ffffffff80108bf1:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
ffffffff80108bf6:	74 72                	je     ffffffff80108c6a <copyuvm+0x124>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
ffffffff80108bf8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80108bfc:	48 89 c7             	mov    %rax,%rdi
ffffffff80108bff:	e8 5e f9 ff ff       	callq  ffffffff80108562 <p2v>
ffffffff80108c04:	48 89 c1             	mov    %rax,%rcx
ffffffff80108c07:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff80108c0b:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff80108c10:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108c13:	48 89 c7             	mov    %rax,%rdi
ffffffff80108c16:	e8 85 d3 ff ff       	callq  ffffffff80105fa0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
ffffffff80108c1b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80108c1f:	89 c3                	mov    %eax,%ebx
ffffffff80108c21:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
ffffffff80108c25:	48 89 c7             	mov    %rax,%rdi
ffffffff80108c28:	e8 1b f9 ff ff       	callq  ffffffff80108548 <v2p>
ffffffff80108c2d:	48 89 c2             	mov    %rax,%rdx
ffffffff80108c30:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
ffffffff80108c34:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108c38:	41 89 d8             	mov    %ebx,%r8d
ffffffff80108c3b:	48 89 d1             	mov    %rdx,%rcx
ffffffff80108c3e:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff80108c43:	48 89 c7             	mov    %rax,%rdi
ffffffff80108c46:	e8 f7 f9 ff ff       	callq  ffffffff80108642 <mappages>
ffffffff80108c4b:	85 c0                	test   %eax,%eax
ffffffff80108c4d:	78 1e                	js     ffffffff80108c6d <copyuvm+0x127>
  for(i = 0; i < sz; i += PGSIZE){
ffffffff80108c4f:	48 81 45 e8 00 10 00 	addq   $0x1000,-0x18(%rbp)
ffffffff80108c56:	00 
ffffffff80108c57:	8b 45 b4             	mov    -0x4c(%rbp),%eax
ffffffff80108c5a:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
ffffffff80108c5e:	0f 82 19 ff ff ff    	jb     ffffffff80108b7d <copyuvm+0x37>
      goto bad;
  }
  return d;
ffffffff80108c64:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108c68:	eb 15                	jmp    ffffffff80108c7f <copyuvm+0x139>
      goto bad;
ffffffff80108c6a:	90                   	nop
ffffffff80108c6b:	eb 01                	jmp    ffffffff80108c6e <copyuvm+0x128>
      goto bad;
ffffffff80108c6d:	90                   	nop

bad:
  freevm(d);
ffffffff80108c6e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108c72:	48 89 c7             	mov    %rax,%rdi
ffffffff80108c75:	e8 cb fd ff ff       	callq  ffffffff80108a45 <freevm>
  return 0;
ffffffff80108c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80108c7f:	48 83 c4 48          	add    $0x48,%rsp
ffffffff80108c83:	5b                   	pop    %rbx
ffffffff80108c84:	5d                   	pop    %rbp
ffffffff80108c85:	c3                   	retq   

ffffffff80108c86 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
ffffffff80108c86:	55                   	push   %rbp
ffffffff80108c87:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108c8a:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108c8e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108c92:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
ffffffff80108c96:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
ffffffff80108c9a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108c9e:	ba 00 00 00 00       	mov    $0x0,%edx
ffffffff80108ca3:	48 89 ce             	mov    %rcx,%rsi
ffffffff80108ca6:	48 89 c7             	mov    %rax,%rdi
ffffffff80108ca9:	e8 cc f8 ff ff       	callq  ffffffff8010857a <walkpgdir>
ffffffff80108cae:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if((*pte & PTE_P) == 0)
ffffffff80108cb2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108cb6:	48 8b 00             	mov    (%rax),%rax
ffffffff80108cb9:	83 e0 01             	and    $0x1,%eax
ffffffff80108cbc:	48 85 c0             	test   %rax,%rax
ffffffff80108cbf:	75 07                	jne    ffffffff80108cc8 <uva2ka+0x42>
    return 0;
ffffffff80108cc1:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80108cc6:	eb 2b                	jmp    ffffffff80108cf3 <uva2ka+0x6d>
  if((*pte & PTE_U) == 0)
ffffffff80108cc8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108ccc:	48 8b 00             	mov    (%rax),%rax
ffffffff80108ccf:	83 e0 04             	and    $0x4,%eax
ffffffff80108cd2:	48 85 c0             	test   %rax,%rax
ffffffff80108cd5:	75 07                	jne    ffffffff80108cde <uva2ka+0x58>
    return 0;
ffffffff80108cd7:	b8 00 00 00 00       	mov    $0x0,%eax
ffffffff80108cdc:	eb 15                	jmp    ffffffff80108cf3 <uva2ka+0x6d>
  return (char*)p2v(PTE_ADDR(*pte));
ffffffff80108cde:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108ce2:	48 8b 00             	mov    (%rax),%rax
ffffffff80108ce5:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff80108ceb:	48 89 c7             	mov    %rax,%rdi
ffffffff80108cee:	e8 6f f8 ff ff       	callq  ffffffff80108562 <p2v>
}
ffffffff80108cf3:	c9                   	leaveq 
ffffffff80108cf4:	c3                   	retq   

ffffffff80108cf5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
ffffffff80108cf5:	55                   	push   %rbp
ffffffff80108cf6:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108cf9:	48 83 ec 40          	sub    $0x40,%rsp
ffffffff80108cfd:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
ffffffff80108d01:	89 75 d4             	mov    %esi,-0x2c(%rbp)
ffffffff80108d04:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
ffffffff80108d08:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  char *buf, *pa0;
  uintp n, va0;

  buf = (char*)p;
ffffffff80108d0b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80108d0f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(len > 0){
ffffffff80108d13:	e9 9c 00 00 00       	jmpq   ffffffff80108db4 <copyout+0xbf>
    va0 = (uint)PGROUNDDOWN(va);
ffffffff80108d18:	8b 45 d4             	mov    -0x2c(%rbp),%eax
ffffffff80108d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
ffffffff80108d20:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    pa0 = uva2ka(pgdir, (char*)va0);
ffffffff80108d24:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80108d28:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80108d2c:	48 89 d6             	mov    %rdx,%rsi
ffffffff80108d2f:	48 89 c7             	mov    %rax,%rdi
ffffffff80108d32:	e8 4f ff ff ff       	callq  ffffffff80108c86 <uva2ka>
ffffffff80108d37:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    if(pa0 == 0)
ffffffff80108d3b:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
ffffffff80108d40:	75 07                	jne    ffffffff80108d49 <copyout+0x54>
      return -1;
ffffffff80108d42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
ffffffff80108d47:	eb 7a                	jmp    ffffffff80108dc3 <copyout+0xce>
    n = PGSIZE - (va - va0);
ffffffff80108d49:	8b 45 d4             	mov    -0x2c(%rbp),%eax
ffffffff80108d4c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80108d50:	48 29 c2             	sub    %rax,%rdx
ffffffff80108d53:	48 89 d0             	mov    %rdx,%rax
ffffffff80108d56:	48 05 00 10 00 00    	add    $0x1000,%rax
ffffffff80108d5c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if(n > len)
ffffffff80108d60:	8b 45 d0             	mov    -0x30(%rbp),%eax
ffffffff80108d63:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
ffffffff80108d67:	76 07                	jbe    ffffffff80108d70 <copyout+0x7b>
      n = len;
ffffffff80108d69:	8b 45 d0             	mov    -0x30(%rbp),%eax
ffffffff80108d6c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    memmove(pa0 + (va - va0), buf, n);
ffffffff80108d70:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108d74:	89 c6                	mov    %eax,%esi
ffffffff80108d76:	8b 45 d4             	mov    -0x2c(%rbp),%eax
ffffffff80108d79:	48 2b 45 e8          	sub    -0x18(%rbp),%rax
ffffffff80108d7d:	48 89 c2             	mov    %rax,%rdx
ffffffff80108d80:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80108d84:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
ffffffff80108d88:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108d8c:	89 f2                	mov    %esi,%edx
ffffffff80108d8e:	48 89 c6             	mov    %rax,%rsi
ffffffff80108d91:	48 89 cf             	mov    %rcx,%rdi
ffffffff80108d94:	e8 07 d2 ff ff       	callq  ffffffff80105fa0 <memmove>
    len -= n;
ffffffff80108d99:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108d9d:	29 45 d0             	sub    %eax,-0x30(%rbp)
    buf += n;
ffffffff80108da0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80108da4:	48 01 45 f8          	add    %rax,-0x8(%rbp)
    va = va0 + PGSIZE;
ffffffff80108da8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108dac:	05 00 10 00 00       	add    $0x1000,%eax
ffffffff80108db1:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  while(len > 0){
ffffffff80108db4:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
ffffffff80108db8:	0f 85 5a ff ff ff    	jne    ffffffff80108d18 <copyout+0x23>
  }
  return 0;
ffffffff80108dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
ffffffff80108dc3:	c9                   	leaveq 
ffffffff80108dc4:	c3                   	retq   

ffffffff80108dc5 <lgdt>:
{
ffffffff80108dc5:	55                   	push   %rbp
ffffffff80108dc6:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108dc9:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108dcd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108dd1:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  pd[0] = size-1;
ffffffff80108dd4:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108dd7:	83 e8 01             	sub    $0x1,%eax
ffffffff80108dda:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
  pd[1] = (uintp)p;
ffffffff80108dde:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108de2:	66 89 45 f8          	mov    %ax,-0x8(%rbp)
  pd[2] = (uintp)p >> 16;
ffffffff80108de6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108dea:	48 c1 e8 10          	shr    $0x10,%rax
ffffffff80108dee:	66 89 45 fa          	mov    %ax,-0x6(%rbp)
  pd[3] = (uintp)p >> 32;
ffffffff80108df2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108df6:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80108dfa:	66 89 45 fc          	mov    %ax,-0x4(%rbp)
  pd[4] = (uintp)p >> 48;
ffffffff80108dfe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108e02:	48 c1 e8 30          	shr    $0x30,%rax
ffffffff80108e06:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
  asm volatile("lgdt (%0)" : : "r" (pd));
ffffffff80108e0a:	48 8d 45 f6          	lea    -0xa(%rbp),%rax
ffffffff80108e0e:	0f 01 10             	lgdt   (%rax)
}
ffffffff80108e11:	90                   	nop
ffffffff80108e12:	c9                   	leaveq 
ffffffff80108e13:	c3                   	retq   

ffffffff80108e14 <lidt>:
{
ffffffff80108e14:	55                   	push   %rbp
ffffffff80108e15:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108e18:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80108e1c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108e20:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  pd[0] = size-1;
ffffffff80108e23:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108e26:	83 e8 01             	sub    $0x1,%eax
ffffffff80108e29:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
  pd[1] = (uintp)p;
ffffffff80108e2d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108e31:	66 89 45 f8          	mov    %ax,-0x8(%rbp)
  pd[2] = (uintp)p >> 16;
ffffffff80108e35:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108e39:	48 c1 e8 10          	shr    $0x10,%rax
ffffffff80108e3d:	66 89 45 fa          	mov    %ax,-0x6(%rbp)
  pd[3] = (uintp)p >> 32;
ffffffff80108e41:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108e45:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80108e49:	66 89 45 fc          	mov    %ax,-0x4(%rbp)
  pd[4] = (uintp)p >> 48;
ffffffff80108e4d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108e51:	48 c1 e8 30          	shr    $0x30,%rax
ffffffff80108e55:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
  asm volatile("lidt (%0)" : : "r" (pd));
ffffffff80108e59:	48 8d 45 f6          	lea    -0xa(%rbp),%rax
ffffffff80108e5d:	0f 01 18             	lidt   (%rax)
}
ffffffff80108e60:	90                   	nop
ffffffff80108e61:	c9                   	leaveq 
ffffffff80108e62:	c3                   	retq   

ffffffff80108e63 <ltr>:
{
ffffffff80108e63:	55                   	push   %rbp
ffffffff80108e64:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108e67:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80108e6b:	89 f8                	mov    %edi,%eax
ffffffff80108e6d:	66 89 45 fc          	mov    %ax,-0x4(%rbp)
  asm volatile("ltr %0" : : "r" (sel));
ffffffff80108e71:	0f b7 45 fc          	movzwl -0x4(%rbp),%eax
ffffffff80108e75:	0f 00 d8             	ltr    %ax
}
ffffffff80108e78:	90                   	nop
ffffffff80108e79:	c9                   	leaveq 
ffffffff80108e7a:	c3                   	retq   

ffffffff80108e7b <lcr3>:

static inline void
lcr3(uintp val) 
{
ffffffff80108e7b:	55                   	push   %rbp
ffffffff80108e7c:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108e7f:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80108e83:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  asm volatile("mov %0,%%cr3" : : "r" (val));
ffffffff80108e87:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108e8b:	0f 22 d8             	mov    %rax,%cr3
}
ffffffff80108e8e:	90                   	nop
ffffffff80108e8f:	c9                   	leaveq 
ffffffff80108e90:	c3                   	retq   

ffffffff80108e91 <v2p>:
static inline uintp v2p(void *a) { return ((uintp) (a)) - ((uintp)KERNBASE); }
ffffffff80108e91:	55                   	push   %rbp
ffffffff80108e92:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108e95:	48 83 ec 08          	sub    $0x8,%rsp
ffffffff80108e99:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80108e9d:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80108ea1:	b8 00 00 00 80       	mov    $0x80000000,%eax
ffffffff80108ea6:	48 01 d0             	add    %rdx,%rax
ffffffff80108ea9:	c9                   	leaveq 
ffffffff80108eaa:	c3                   	retq   

ffffffff80108eab <tvinit>:
static pde_t *kpgdir0;
static pde_t *kpgdir1;

void wrmsr(uint msr, uint64 val);

void tvinit(void) {}
ffffffff80108eab:	55                   	push   %rbp
ffffffff80108eac:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108eaf:	90                   	nop
ffffffff80108eb0:	5d                   	pop    %rbp
ffffffff80108eb1:	c3                   	retq   

ffffffff80108eb2 <idtinit>:
void idtinit(void) {}
ffffffff80108eb2:	55                   	push   %rbp
ffffffff80108eb3:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108eb6:	90                   	nop
ffffffff80108eb7:	5d                   	pop    %rbp
ffffffff80108eb8:	c3                   	retq   

ffffffff80108eb9 <mkgate>:

static void mkgate(uint *idt, uint n, void *kva, uint pl, uint trap) {
ffffffff80108eb9:	55                   	push   %rbp
ffffffff80108eba:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108ebd:	48 83 ec 30          	sub    $0x30,%rsp
ffffffff80108ec1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
ffffffff80108ec5:	89 75 e4             	mov    %esi,-0x1c(%rbp)
ffffffff80108ec8:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
ffffffff80108ecc:	89 4d e0             	mov    %ecx,-0x20(%rbp)
ffffffff80108ecf:	44 89 45 d4          	mov    %r8d,-0x2c(%rbp)
  uint64 addr = (uint64) kva;
ffffffff80108ed3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80108ed7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  n *= 4;
ffffffff80108edb:	c1 65 e4 02          	shll   $0x2,-0x1c(%rbp)
  trap = trap ? 0x8F00 : 0x8E00; // TRAP vs INTERRUPT gate;
ffffffff80108edf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
ffffffff80108ee3:	74 07                	je     ffffffff80108eec <mkgate+0x33>
ffffffff80108ee5:	b8 00 8f 00 00       	mov    $0x8f00,%eax
ffffffff80108eea:	eb 05                	jmp    ffffffff80108ef1 <mkgate+0x38>
ffffffff80108eec:	b8 00 8e 00 00       	mov    $0x8e00,%eax
ffffffff80108ef1:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  idt[n+0] = (addr & 0xFFFF) | ((SEG_KCODE << 3) << 16);
ffffffff80108ef4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108ef8:	0f b7 d0             	movzwl %ax,%edx
ffffffff80108efb:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108efe:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
ffffffff80108f05:	00 
ffffffff80108f06:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108f0a:	48 01 c8             	add    %rcx,%rax
ffffffff80108f0d:	81 ca 00 00 08 00    	or     $0x80000,%edx
ffffffff80108f13:	89 10                	mov    %edx,(%rax)
  idt[n+1] = (addr & 0xFFFF0000) | trap | ((pl & 3) << 13); // P=1 DPL=pl
ffffffff80108f15:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108f19:	66 b8 00 00          	mov    $0x0,%ax
ffffffff80108f1d:	0b 45 d4             	or     -0x2c(%rbp),%eax
ffffffff80108f20:	89 c2                	mov    %eax,%edx
ffffffff80108f22:	8b 45 e0             	mov    -0x20(%rbp),%eax
ffffffff80108f25:	c1 e0 0d             	shl    $0xd,%eax
ffffffff80108f28:	25 00 60 00 00       	and    $0x6000,%eax
ffffffff80108f2d:	89 c1                	mov    %eax,%ecx
ffffffff80108f2f:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108f32:	83 c0 01             	add    $0x1,%eax
ffffffff80108f35:	89 c0                	mov    %eax,%eax
ffffffff80108f37:	48 8d 34 85 00 00 00 	lea    0x0(,%rax,4),%rsi
ffffffff80108f3e:	00 
ffffffff80108f3f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108f43:	48 01 f0             	add    %rsi,%rax
ffffffff80108f46:	09 ca                	or     %ecx,%edx
ffffffff80108f48:	89 10                	mov    %edx,(%rax)
  idt[n+2] = addr >> 32;
ffffffff80108f4a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108f4e:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80108f52:	48 89 c2             	mov    %rax,%rdx
ffffffff80108f55:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108f58:	83 c0 02             	add    $0x2,%eax
ffffffff80108f5b:	89 c0                	mov    %eax,%eax
ffffffff80108f5d:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
ffffffff80108f64:	00 
ffffffff80108f65:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108f69:	48 01 c8             	add    %rcx,%rax
ffffffff80108f6c:	89 10                	mov    %edx,(%rax)
  idt[n+3] = 0;
ffffffff80108f6e:	8b 45 e4             	mov    -0x1c(%rbp),%eax
ffffffff80108f71:	83 c0 03             	add    $0x3,%eax
ffffffff80108f74:	89 c0                	mov    %eax,%eax
ffffffff80108f76:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff80108f7d:	00 
ffffffff80108f7e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108f82:	48 01 d0             	add    %rdx,%rax
ffffffff80108f85:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
}
ffffffff80108f8b:	90                   	nop
ffffffff80108f8c:	c9                   	leaveq 
ffffffff80108f8d:	c3                   	retq   

ffffffff80108f8e <tss_set_rsp>:

static void tss_set_rsp(uint *tss, uint n, uint64 rsp) {
ffffffff80108f8e:	55                   	push   %rbp
ffffffff80108f8f:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108f92:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80108f96:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80108f9a:	89 75 f4             	mov    %esi,-0xc(%rbp)
ffffffff80108f9d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  tss[n*2 + 1] = rsp;
ffffffff80108fa1:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80108fa4:	01 c0                	add    %eax,%eax
ffffffff80108fa6:	83 c0 01             	add    $0x1,%eax
ffffffff80108fa9:	89 c0                	mov    %eax,%eax
ffffffff80108fab:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff80108fb2:	00 
ffffffff80108fb3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108fb7:	48 01 d0             	add    %rdx,%rax
ffffffff80108fba:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80108fbe:	89 10                	mov    %edx,(%rax)
  tss[n*2 + 2] = rsp >> 32;
ffffffff80108fc0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80108fc4:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80108fc8:	48 89 c2             	mov    %rax,%rdx
ffffffff80108fcb:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80108fce:	83 c0 01             	add    $0x1,%eax
ffffffff80108fd1:	01 c0                	add    %eax,%eax
ffffffff80108fd3:	89 c0                	mov    %eax,%eax
ffffffff80108fd5:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
ffffffff80108fdc:	00 
ffffffff80108fdd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80108fe1:	48 01 c8             	add    %rcx,%rax
ffffffff80108fe4:	89 10                	mov    %edx,(%rax)
}
ffffffff80108fe6:	90                   	nop
ffffffff80108fe7:	c9                   	leaveq 
ffffffff80108fe8:	c3                   	retq   

ffffffff80108fe9 <tss_set_ist>:

static void tss_set_ist(uint *tss, uint n, uint64 ist) {
ffffffff80108fe9:	55                   	push   %rbp
ffffffff80108fea:	48 89 e5             	mov    %rsp,%rbp
ffffffff80108fed:	48 83 ec 18          	sub    $0x18,%rsp
ffffffff80108ff1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
ffffffff80108ff5:	89 75 f4             	mov    %esi,-0xc(%rbp)
ffffffff80108ff8:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  tss[n*2 + 7] = ist;
ffffffff80108ffc:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80108fff:	01 c0                	add    %eax,%eax
ffffffff80109001:	83 c0 07             	add    $0x7,%eax
ffffffff80109004:	89 c0                	mov    %eax,%eax
ffffffff80109006:	48 8d 14 85 00 00 00 	lea    0x0(,%rax,4),%rdx
ffffffff8010900d:	00 
ffffffff8010900e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80109012:	48 01 d0             	add    %rdx,%rax
ffffffff80109015:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff80109019:	89 10                	mov    %edx,(%rax)
  tss[n*2 + 8] = ist >> 32;
ffffffff8010901b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010901f:	48 c1 e8 20          	shr    $0x20,%rax
ffffffff80109023:	48 89 c2             	mov    %rax,%rdx
ffffffff80109026:	8b 45 f4             	mov    -0xc(%rbp),%eax
ffffffff80109029:	83 c0 04             	add    $0x4,%eax
ffffffff8010902c:	01 c0                	add    %eax,%eax
ffffffff8010902e:	89 c0                	mov    %eax,%eax
ffffffff80109030:	48 8d 0c 85 00 00 00 	lea    0x0(,%rax,4),%rcx
ffffffff80109037:	00 
ffffffff80109038:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010903c:	48 01 c8             	add    %rcx,%rax
ffffffff8010903f:	89 10                	mov    %edx,(%rax)
}
ffffffff80109041:	90                   	nop
ffffffff80109042:	c9                   	leaveq 
ffffffff80109043:	c3                   	retq   

ffffffff80109044 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
ffffffff80109044:	55                   	push   %rbp
ffffffff80109045:	48 89 e5             	mov    %rsp,%rbp
ffffffff80109048:	48 83 ec 40          	sub    $0x40,%rsp
  uint64 *gdt;
  uint *tss;
  uint64 addr;
  void *local;
  struct cpu *c;
  uint *idt = (uint*) kalloc();
ffffffff8010904c:	e8 3a a2 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109051:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  int n;
  memset(idt, 0, PGSIZE);
ffffffff80109055:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80109059:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff8010905e:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80109063:	48 89 c7             	mov    %rax,%rdi
ffffffff80109066:	e8 46 ce ff ff       	callq  ffffffff80105eb1 <memset>

  for (n = 0; n < 256; n++)
ffffffff8010906b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80109072:	eb 2b                	jmp    ffffffff8010909f <seginit+0x5b>
    mkgate(idt, n, vectors[n], 0, 0);
ffffffff80109074:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80109077:	48 98                	cltq   
ffffffff80109079:	48 8b 14 c5 70 a6 10 	mov    -0x7fef5990(,%rax,8),%rdx
ffffffff80109080:	80 
ffffffff80109081:	8b 75 fc             	mov    -0x4(%rbp),%esi
ffffffff80109084:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80109088:	41 b8 00 00 00 00    	mov    $0x0,%r8d
ffffffff8010908e:	b9 00 00 00 00       	mov    $0x0,%ecx
ffffffff80109093:	48 89 c7             	mov    %rax,%rdi
ffffffff80109096:	e8 1e fe ff ff       	callq  ffffffff80108eb9 <mkgate>
  for (n = 0; n < 256; n++)
ffffffff8010909b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff8010909f:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%rbp)
ffffffff801090a6:	7e cc                	jle    ffffffff80109074 <seginit+0x30>
  mkgate(idt, 64, vectors[64], 3, 1);
ffffffff801090a8:	48 8b 15 c1 17 00 00 	mov    0x17c1(%rip),%rdx        # ffffffff8010a870 <vectors+0x200>
ffffffff801090af:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801090b3:	41 b8 01 00 00 00    	mov    $0x1,%r8d
ffffffff801090b9:	b9 03 00 00 00       	mov    $0x3,%ecx
ffffffff801090be:	be 40 00 00 00       	mov    $0x40,%esi
ffffffff801090c3:	48 89 c7             	mov    %rax,%rdi
ffffffff801090c6:	e8 ee fd ff ff       	callq  ffffffff80108eb9 <mkgate>

  lidt((void*) idt, PGSIZE);
ffffffff801090cb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801090cf:	be 00 10 00 00       	mov    $0x1000,%esi
ffffffff801090d4:	48 89 c7             	mov    %rax,%rdi
ffffffff801090d7:	e8 38 fd ff ff       	callq  ffffffff80108e14 <lidt>

  // create a page for cpu local storage 
  local = kalloc();
ffffffff801090dc:	e8 aa a1 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff801090e1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  memset(local, 0, PGSIZE);
ffffffff801090e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801090e9:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801090ee:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801090f3:	48 89 c7             	mov    %rax,%rdi
ffffffff801090f6:	e8 b6 cd ff ff       	callq  ffffffff80105eb1 <memset>

  gdt = (uint64*) local;
ffffffff801090fb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801090ff:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  tss = (uint*) (((char*) local) + 1024);
ffffffff80109103:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80109107:	48 05 00 04 00 00    	add    $0x400,%rax
ffffffff8010910d:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  tss[16] = 0x00680000; // IO Map Base = End of TSS
ffffffff80109111:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80109115:	48 83 c0 40          	add    $0x40,%rax
ffffffff80109119:	c7 00 00 00 68 00    	movl   $0x680000,(%rax)

  // point FS smack in the middle of our local storage page
  wrmsr(0xC0000100, ((uint64) local) + (PGSIZE / 2));
ffffffff8010911f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80109123:	48 05 00 08 00 00    	add    $0x800,%rax
ffffffff80109129:	48 89 c6             	mov    %rax,%rsi
ffffffff8010912c:	bf 00 01 00 c0       	mov    $0xc0000100,%edi
ffffffff80109131:	e8 e5 6f ff ff       	callq  ffffffff8010011b <wrmsr>

  c = &cpus[cpunum()];
ffffffff80109136:	e8 c1 a4 ff ff       	callq  ffffffff801035fc <cpunum>
ffffffff8010913b:	48 63 d0             	movslq %eax,%rdx
ffffffff8010913e:	48 89 d0             	mov    %rdx,%rax
ffffffff80109141:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff80109145:	48 29 d0             	sub    %rdx,%rax
ffffffff80109148:	48 c1 e0 04          	shl    $0x4,%rax
ffffffff8010914c:	48 05 60 ec 10 80    	add    $0xffffffff8010ec60,%rax
ffffffff80109152:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  c->local = local;
ffffffff80109156:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff8010915a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
ffffffff8010915e:	48 89 90 e8 00 00 00 	mov    %rdx,0xe8(%rax)

  cpu = c;
ffffffff80109165:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
ffffffff80109169:	64 48 89 04 25 f0 ff 	mov    %rax,%fs:0xfffffffffffffff0
ffffffff80109170:	ff ff 
  proc = 0;
ffffffff80109172:	64 48 c7 04 25 f8 ff 	movq   $0x0,%fs:0xfffffffffffffff8
ffffffff80109179:	ff ff 00 00 00 00 

  addr = (uint64) tss;
ffffffff8010917f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
ffffffff80109183:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  gdt[0] =         0x0000000000000000;
ffffffff80109187:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010918b:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  gdt[SEG_KCODE] = 0x0020980000000000;  // Code, DPL=0, R/X
ffffffff80109192:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80109196:	48 83 c0 08          	add    $0x8,%rax
ffffffff8010919a:	48 b9 00 00 00 00 00 	movabs $0x20980000000000,%rcx
ffffffff801091a1:	98 20 00 
ffffffff801091a4:	48 89 08             	mov    %rcx,(%rax)
  gdt[SEG_UCODE] = 0x0020F80000000000;  // Code, DPL=3, R/X
ffffffff801091a7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801091ab:	48 83 c0 20          	add    $0x20,%rax
ffffffff801091af:	48 bf 00 00 00 00 00 	movabs $0x20f80000000000,%rdi
ffffffff801091b6:	f8 20 00 
ffffffff801091b9:	48 89 38             	mov    %rdi,(%rax)
  gdt[SEG_KDATA] = 0x0000920000000000;  // Data, DPL=0, W
ffffffff801091bc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801091c0:	48 83 c0 10          	add    $0x10,%rax
ffffffff801091c4:	48 b9 00 00 00 00 00 	movabs $0x920000000000,%rcx
ffffffff801091cb:	92 00 00 
ffffffff801091ce:	48 89 08             	mov    %rcx,(%rax)
  gdt[SEG_KCPU]  = 0x0000000000000000;  // unused
ffffffff801091d1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801091d5:	48 83 c0 18          	add    $0x18,%rax
ffffffff801091d9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  gdt[SEG_UDATA] = 0x0000F20000000000;  // Data, DPL=3, W
ffffffff801091e0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff801091e4:	48 83 c0 28          	add    $0x28,%rax
ffffffff801091e8:	48 be 00 00 00 00 00 	movabs $0xf20000000000,%rsi
ffffffff801091ef:	f2 00 00 
ffffffff801091f2:	48 89 30             	mov    %rsi,(%rax)
  gdt[SEG_TSS+0] = (0x0067) | ((addr & 0xFFFFFF) << 16) |
ffffffff801091f5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff801091f9:	48 c1 e0 10          	shl    $0x10,%rax
ffffffff801091fd:	48 89 c2             	mov    %rax,%rdx
ffffffff80109200:	48 b8 00 00 ff ff ff 	movabs $0xffffff0000,%rax
ffffffff80109207:	00 00 00 
ffffffff8010920a:	48 21 c2             	and    %rax,%rdx
                   (0x00E9LL << 40) | (((addr >> 24) & 0xFF) << 56);
ffffffff8010920d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
ffffffff80109211:	48 c1 e8 18          	shr    $0x18,%rax
ffffffff80109215:	48 c1 e0 38          	shl    $0x38,%rax
ffffffff80109219:	48 89 d1             	mov    %rdx,%rcx
ffffffff8010921c:	48 09 c1             	or     %rax,%rcx
  gdt[SEG_TSS+0] = (0x0067) | ((addr & 0xFFFFFF) << 16) |
ffffffff8010921f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff80109223:	48 83 c0 30          	add    $0x30,%rax
                   (0x00E9LL << 40) | (((addr >> 24) & 0xFF) << 56);
ffffffff80109227:	48 ba 67 00 00 00 00 	movabs $0xe90000000067,%rdx
ffffffff8010922e:	e9 00 00 
ffffffff80109231:	48 09 ca             	or     %rcx,%rdx
  gdt[SEG_TSS+0] = (0x0067) | ((addr & 0xFFFFFF) << 16) |
ffffffff80109234:	48 89 10             	mov    %rdx,(%rax)
  gdt[SEG_TSS+1] = (addr >> 32);
ffffffff80109237:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010923b:	48 83 c0 38          	add    $0x38,%rax
ffffffff8010923f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
ffffffff80109243:	48 c1 ea 20          	shr    $0x20,%rdx
ffffffff80109247:	48 89 10             	mov    %rdx,(%rax)

  lgdt((void*) gdt, 8 * sizeof(uint64));
ffffffff8010924a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
ffffffff8010924e:	be 40 00 00 00       	mov    $0x40,%esi
ffffffff80109253:	48 89 c7             	mov    %rax,%rdi
ffffffff80109256:	e8 6a fb ff ff       	callq  ffffffff80108dc5 <lgdt>

  ltr(SEG_TSS << 3);
ffffffff8010925b:	bf 30 00 00 00       	mov    $0x30,%edi
ffffffff80109260:	e8 fe fb ff ff       	callq  ffffffff80108e63 <ltr>
};
ffffffff80109265:	90                   	nop
ffffffff80109266:	c9                   	leaveq 
ffffffff80109267:	c3                   	retq   

ffffffff80109268 <setupkvm>:
// because we need to find the other levels later, we'll stash
// backpointers to them in the top two entries of the level two
// table.
pde_t*
setupkvm(void)
{
ffffffff80109268:	55                   	push   %rbp
ffffffff80109269:	48 89 e5             	mov    %rsp,%rbp
ffffffff8010926c:	48 83 ec 20          	sub    $0x20,%rsp
  pde_t *pml4 = (pde_t*) kalloc();
ffffffff80109270:	e8 16 a0 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109275:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  pde_t *pdpt = (pde_t*) kalloc();
ffffffff80109279:	e8 0d a0 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff8010927e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  pde_t *pgdir = (pde_t*) kalloc();
ffffffff80109282:	e8 04 a0 ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109287:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

  memset(pml4, 0, PGSIZE);
ffffffff8010928b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010928f:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff80109294:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff80109299:	48 89 c7             	mov    %rax,%rdi
ffffffff8010929c:	e8 10 cc ff ff       	callq  ffffffff80105eb1 <memset>
  memset(pdpt, 0, PGSIZE);
ffffffff801092a1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801092a5:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801092aa:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801092af:	48 89 c7             	mov    %rax,%rdi
ffffffff801092b2:	e8 fa cb ff ff       	callq  ffffffff80105eb1 <memset>
  memset(pgdir, 0, PGSIZE);
ffffffff801092b7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801092bb:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801092c0:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801092c5:	48 89 c7             	mov    %rax,%rdi
ffffffff801092c8:	e8 e4 cb ff ff       	callq  ffffffff80105eb1 <memset>
  pml4[511] = v2p(kpdpt) | PTE_P | PTE_W | PTE_U;
ffffffff801092cd:	48 8b 05 8c a2 00 00 	mov    0xa28c(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff801092d4:	48 89 c7             	mov    %rax,%rdi
ffffffff801092d7:	e8 b5 fb ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff801092dc:	48 89 c2             	mov    %rax,%rdx
ffffffff801092df:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff801092e3:	48 05 f8 0f 00 00    	add    $0xff8,%rax
ffffffff801092e9:	48 83 ca 07          	or     $0x7,%rdx
ffffffff801092ed:	48 89 10             	mov    %rdx,(%rax)
  pml4[0] = v2p(pdpt) | PTE_P | PTE_W | PTE_U;
ffffffff801092f0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801092f4:	48 89 c7             	mov    %rax,%rdi
ffffffff801092f7:	e8 95 fb ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff801092fc:	48 83 c8 07          	or     $0x7,%rax
ffffffff80109300:	48 89 c2             	mov    %rax,%rdx
ffffffff80109303:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff80109307:	48 89 10             	mov    %rdx,(%rax)
  pdpt[0] = v2p(pgdir) | PTE_P | PTE_W | PTE_U; 
ffffffff8010930a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010930e:	48 89 c7             	mov    %rax,%rdi
ffffffff80109311:	e8 7b fb ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff80109316:	48 83 c8 07          	or     $0x7,%rax
ffffffff8010931a:	48 89 c2             	mov    %rax,%rdx
ffffffff8010931d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff80109321:	48 89 10             	mov    %rdx,(%rax)

  // virtual backpointers
  pgdir[511] = ((uintp) pml4) | PTE_P;
ffffffff80109324:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
ffffffff80109328:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff8010932c:	48 05 f8 0f 00 00    	add    $0xff8,%rax
ffffffff80109332:	48 83 ca 01          	or     $0x1,%rdx
ffffffff80109336:	48 89 10             	mov    %rdx,(%rax)
  pgdir[510] = ((uintp) pdpt) | PTE_P;
ffffffff80109339:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
ffffffff8010933d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80109341:	48 05 f0 0f 00 00    	add    $0xff0,%rax
ffffffff80109347:	48 83 ca 01          	or     $0x1,%rdx
ffffffff8010934b:	48 89 10             	mov    %rdx,(%rax)

  return pgdir;
ffffffff8010934e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
};
ffffffff80109352:	c9                   	leaveq 
ffffffff80109353:	c3                   	retq   

ffffffff80109354 <kvmalloc>:
// space for scheduler processes.
//
// linear map the first 4GB of physical memory starting at 0xFFFFFFFF80000000
void
kvmalloc(void)
{
ffffffff80109354:	55                   	push   %rbp
ffffffff80109355:	48 89 e5             	mov    %rsp,%rbp
ffffffff80109358:	48 83 ec 10          	sub    $0x10,%rsp
  int n;
  kpml4 = (pde_t*) kalloc();
ffffffff8010935c:	e8 2a 9f ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109361:	48 89 05 f0 a1 00 00 	mov    %rax,0xa1f0(%rip)        # ffffffff80113558 <kpml4>
  kpdpt = (pde_t*) kalloc();
ffffffff80109368:	e8 1e 9f ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff8010936d:	48 89 05 ec a1 00 00 	mov    %rax,0xa1ec(%rip)        # ffffffff80113560 <kpdpt>
  kpgdir0 = (pde_t*) kalloc();
ffffffff80109374:	e8 12 9f ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109379:	48 89 05 f0 a1 00 00 	mov    %rax,0xa1f0(%rip)        # ffffffff80113570 <kpgdir0>
  kpgdir1 = (pde_t*) kalloc();
ffffffff80109380:	e8 06 9f ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109385:	48 89 05 ec a1 00 00 	mov    %rax,0xa1ec(%rip)        # ffffffff80113578 <kpgdir1>
  iopgdir = (pde_t*) kalloc();
ffffffff8010938c:	e8 fa 9e ff ff       	callq  ffffffff8010328b <kalloc>
ffffffff80109391:	48 89 05 d0 a1 00 00 	mov    %rax,0xa1d0(%rip)        # ffffffff80113568 <iopgdir>
  memset(kpml4, 0, PGSIZE);
ffffffff80109398:	48 8b 05 b9 a1 00 00 	mov    0xa1b9(%rip),%rax        # ffffffff80113558 <kpml4>
ffffffff8010939f:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801093a4:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801093a9:	48 89 c7             	mov    %rax,%rdi
ffffffff801093ac:	e8 00 cb ff ff       	callq  ffffffff80105eb1 <memset>
  memset(kpdpt, 0, PGSIZE);
ffffffff801093b1:	48 8b 05 a8 a1 00 00 	mov    0xa1a8(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff801093b8:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801093bd:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801093c2:	48 89 c7             	mov    %rax,%rdi
ffffffff801093c5:	e8 e7 ca ff ff       	callq  ffffffff80105eb1 <memset>
  memset(iopgdir, 0, PGSIZE);
ffffffff801093ca:	48 8b 05 97 a1 00 00 	mov    0xa197(%rip),%rax        # ffffffff80113568 <iopgdir>
ffffffff801093d1:	ba 00 10 00 00       	mov    $0x1000,%edx
ffffffff801093d6:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801093db:	48 89 c7             	mov    %rax,%rdi
ffffffff801093de:	e8 ce ca ff ff       	callq  ffffffff80105eb1 <memset>
  kpml4[511] = v2p(kpdpt) | PTE_P | PTE_W;
ffffffff801093e3:	48 8b 05 76 a1 00 00 	mov    0xa176(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff801093ea:	48 89 c7             	mov    %rax,%rdi
ffffffff801093ed:	e8 9f fa ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff801093f2:	48 89 c2             	mov    %rax,%rdx
ffffffff801093f5:	48 8b 05 5c a1 00 00 	mov    0xa15c(%rip),%rax        # ffffffff80113558 <kpml4>
ffffffff801093fc:	48 05 f8 0f 00 00    	add    $0xff8,%rax
ffffffff80109402:	48 83 ca 03          	or     $0x3,%rdx
ffffffff80109406:	48 89 10             	mov    %rdx,(%rax)
  kpdpt[511] = v2p(kpgdir1) | PTE_P | PTE_W;
ffffffff80109409:	48 8b 05 68 a1 00 00 	mov    0xa168(%rip),%rax        # ffffffff80113578 <kpgdir1>
ffffffff80109410:	48 89 c7             	mov    %rax,%rdi
ffffffff80109413:	e8 79 fa ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff80109418:	48 89 c2             	mov    %rax,%rdx
ffffffff8010941b:	48 8b 05 3e a1 00 00 	mov    0xa13e(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff80109422:	48 05 f8 0f 00 00    	add    $0xff8,%rax
ffffffff80109428:	48 83 ca 03          	or     $0x3,%rdx
ffffffff8010942c:	48 89 10             	mov    %rdx,(%rax)
  kpdpt[510] = v2p(kpgdir0) | PTE_P | PTE_W;
ffffffff8010942f:	48 8b 05 3a a1 00 00 	mov    0xa13a(%rip),%rax        # ffffffff80113570 <kpgdir0>
ffffffff80109436:	48 89 c7             	mov    %rax,%rdi
ffffffff80109439:	e8 53 fa ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff8010943e:	48 89 c2             	mov    %rax,%rdx
ffffffff80109441:	48 8b 05 18 a1 00 00 	mov    0xa118(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff80109448:	48 05 f0 0f 00 00    	add    $0xff0,%rax
ffffffff8010944e:	48 83 ca 03          	or     $0x3,%rdx
ffffffff80109452:	48 89 10             	mov    %rdx,(%rax)
  kpdpt[509] = v2p(iopgdir) | PTE_P | PTE_W;
ffffffff80109455:	48 8b 05 0c a1 00 00 	mov    0xa10c(%rip),%rax        # ffffffff80113568 <iopgdir>
ffffffff8010945c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010945f:	e8 2d fa ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff80109464:	48 89 c2             	mov    %rax,%rdx
ffffffff80109467:	48 8b 05 f2 a0 00 00 	mov    0xa0f2(%rip),%rax        # ffffffff80113560 <kpdpt>
ffffffff8010946e:	48 05 e8 0f 00 00    	add    $0xfe8,%rax
ffffffff80109474:	48 83 ca 03          	or     $0x3,%rdx
ffffffff80109478:	48 89 10             	mov    %rdx,(%rax)
  for (n = 0; n < NPDENTRIES; n++) {
ffffffff8010947b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff80109482:	eb 51                	jmp    ffffffff801094d5 <kvmalloc+0x181>
    kpgdir0[n] = (n << PDXSHIFT) | PTE_PS | PTE_P | PTE_W;
ffffffff80109484:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff80109487:	c1 e0 15             	shl    $0x15,%eax
ffffffff8010948a:	0c 83                	or     $0x83,%al
ffffffff8010948c:	89 c1                	mov    %eax,%ecx
ffffffff8010948e:	48 8b 05 db a0 00 00 	mov    0xa0db(%rip),%rax        # ffffffff80113570 <kpgdir0>
ffffffff80109495:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80109498:	48 63 d2             	movslq %edx,%rdx
ffffffff8010949b:	48 c1 e2 03          	shl    $0x3,%rdx
ffffffff8010949f:	48 01 c2             	add    %rax,%rdx
ffffffff801094a2:	48 63 c1             	movslq %ecx,%rax
ffffffff801094a5:	48 89 02             	mov    %rax,(%rdx)
    kpgdir1[n] = ((n + 512) << PDXSHIFT) | PTE_PS | PTE_P | PTE_W;
ffffffff801094a8:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801094ab:	05 00 02 00 00       	add    $0x200,%eax
ffffffff801094b0:	c1 e0 15             	shl    $0x15,%eax
ffffffff801094b3:	0c 83                	or     $0x83,%al
ffffffff801094b5:	89 c1                	mov    %eax,%ecx
ffffffff801094b7:	48 8b 05 ba a0 00 00 	mov    0xa0ba(%rip),%rax        # ffffffff80113578 <kpgdir1>
ffffffff801094be:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff801094c1:	48 63 d2             	movslq %edx,%rdx
ffffffff801094c4:	48 c1 e2 03          	shl    $0x3,%rdx
ffffffff801094c8:	48 01 c2             	add    %rax,%rdx
ffffffff801094cb:	48 63 c1             	movslq %ecx,%rax
ffffffff801094ce:	48 89 02             	mov    %rax,(%rdx)
  for (n = 0; n < NPDENTRIES; n++) {
ffffffff801094d1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff801094d5:	81 7d fc ff 01 00 00 	cmpl   $0x1ff,-0x4(%rbp)
ffffffff801094dc:	7e a6                	jle    ffffffff80109484 <kvmalloc+0x130>
  }
  for (n = 0; n < 16; n++)
ffffffff801094de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
ffffffff801094e5:	eb 2c                	jmp    ffffffff80109513 <kvmalloc+0x1bf>
    iopgdir[n] = (DEVSPACE + (n << PDXSHIFT)) | PTE_PS | PTE_P | PTE_W | PTE_PWT | PTE_PCD;
ffffffff801094e7:	8b 45 fc             	mov    -0x4(%rbp),%eax
ffffffff801094ea:	c1 e0 15             	shl    $0x15,%eax
ffffffff801094ed:	2d 00 00 00 02       	sub    $0x2000000,%eax
ffffffff801094f2:	0c 9b                	or     $0x9b,%al
ffffffff801094f4:	89 c1                	mov    %eax,%ecx
ffffffff801094f6:	48 8b 05 6b a0 00 00 	mov    0xa06b(%rip),%rax        # ffffffff80113568 <iopgdir>
ffffffff801094fd:	8b 55 fc             	mov    -0x4(%rbp),%edx
ffffffff80109500:	48 63 d2             	movslq %edx,%rdx
ffffffff80109503:	48 c1 e2 03          	shl    $0x3,%rdx
ffffffff80109507:	48 01 d0             	add    %rdx,%rax
ffffffff8010950a:	89 ca                	mov    %ecx,%edx
ffffffff8010950c:	48 89 10             	mov    %rdx,(%rax)
  for (n = 0; n < 16; n++)
ffffffff8010950f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
ffffffff80109513:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
ffffffff80109517:	7e ce                	jle    ffffffff801094e7 <kvmalloc+0x193>
  switchkvm();
ffffffff80109519:	e8 03 00 00 00       	callq  ffffffff80109521 <switchkvm>
}
ffffffff8010951e:	90                   	nop
ffffffff8010951f:	c9                   	leaveq 
ffffffff80109520:	c3                   	retq   

ffffffff80109521 <switchkvm>:

void
switchkvm(void)
{
ffffffff80109521:	55                   	push   %rbp
ffffffff80109522:	48 89 e5             	mov    %rsp,%rbp
  lcr3(v2p(kpml4));
ffffffff80109525:	48 8b 05 2c a0 00 00 	mov    0xa02c(%rip),%rax        # ffffffff80113558 <kpml4>
ffffffff8010952c:	48 89 c7             	mov    %rax,%rdi
ffffffff8010952f:	e8 5d f9 ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff80109534:	48 89 c7             	mov    %rax,%rdi
ffffffff80109537:	e8 3f f9 ff ff       	callq  ffffffff80108e7b <lcr3>
}
ffffffff8010953c:	90                   	nop
ffffffff8010953d:	5d                   	pop    %rbp
ffffffff8010953e:	c3                   	retq   

ffffffff8010953f <switchuvm>:

void
switchuvm(struct proc *p)
{
ffffffff8010953f:	55                   	push   %rbp
ffffffff80109540:	48 89 e5             	mov    %rsp,%rbp
ffffffff80109543:	48 83 ec 20          	sub    $0x20,%rsp
ffffffff80109547:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  void *pml4;
  uint *tss;
  pushcli();
ffffffff8010954b:	e8 24 c8 ff ff       	callq  ffffffff80105d74 <pushcli>
  if(p->pgdir == 0)
ffffffff80109550:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff80109554:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff80109558:	48 85 c0             	test   %rax,%rax
ffffffff8010955b:	75 0c                	jne    ffffffff80109569 <switchuvm+0x2a>
    panic("switchuvm: no pgdir");
ffffffff8010955d:	48 c7 c7 ae 9d 10 80 	mov    $0xffffffff80109dae,%rdi
ffffffff80109564:	e8 95 73 ff ff       	callq  ffffffff801008fe <panic>
  tss = (uint*) (((char*) cpu->local) + 1024);
ffffffff80109569:	64 48 8b 04 25 f0 ff 	mov    %fs:0xfffffffffffffff0,%rax
ffffffff80109570:	ff ff 
ffffffff80109572:	48 8b 80 e8 00 00 00 	mov    0xe8(%rax),%rax
ffffffff80109579:	48 05 00 04 00 00    	add    $0x400,%rax
ffffffff8010957f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  tss_set_rsp(tss, 0, (uintp)proc->kstack + KSTACKSIZE);
ffffffff80109583:	64 48 8b 04 25 f8 ff 	mov    %fs:0xfffffffffffffff8,%rax
ffffffff8010958a:	ff ff 
ffffffff8010958c:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff80109590:	48 8d 90 00 10 00 00 	lea    0x1000(%rax),%rdx
ffffffff80109597:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
ffffffff8010959b:	be 00 00 00 00       	mov    $0x0,%esi
ffffffff801095a0:	48 89 c7             	mov    %rax,%rdi
ffffffff801095a3:	e8 e6 f9 ff ff       	callq  ffffffff80108f8e <tss_set_rsp>
  pml4 = (void*) PTE_ADDR(p->pgdir[511]);
ffffffff801095a8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
ffffffff801095ac:	48 8b 40 08          	mov    0x8(%rax),%rax
ffffffff801095b0:	48 05 f8 0f 00 00    	add    $0xff8,%rax
ffffffff801095b6:	48 8b 00             	mov    (%rax),%rax
ffffffff801095b9:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
ffffffff801095bf:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  lcr3(v2p(pml4));
ffffffff801095c3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
ffffffff801095c7:	48 89 c7             	mov    %rax,%rdi
ffffffff801095ca:	e8 c2 f8 ff ff       	callq  ffffffff80108e91 <v2p>
ffffffff801095cf:	48 89 c7             	mov    %rax,%rdi
ffffffff801095d2:	e8 a4 f8 ff ff       	callq  ffffffff80108e7b <lcr3>
  popcli();
ffffffff801095d7:	e8 e8 c7 ff ff       	callq  ffffffff80105dc4 <popcli>
}
ffffffff801095dc:	90                   	nop
ffffffff801095dd:	c9                   	leaveq 
ffffffff801095de:	c3                   	retq   
