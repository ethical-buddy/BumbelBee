
fs/ln:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 10          	sub    $0x10,%rsp
   8:	89 7d fc             	mov    %edi,-0x4(%rbp)
   b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(argc != 3){
   f:	83 7d fc 03          	cmpl   $0x3,-0x4(%rbp)
  13:	74 1b                	je     30 <main+0x30>
    printf(2, "Usage: ln old new\n");
  15:	48 c7 c6 0c 0b 00 00 	mov    $0xb0c,%rsi
  1c:	bf 02 00 00 00       	mov    $0x2,%edi
  21:	b8 00 00 00 00       	mov    $0x0,%eax
  26:	e8 dd 04 00 00       	callq  508 <printf>
    exit();
  2b:	e8 4f 03 00 00       	callq  37f <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  30:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  34:	48 83 c0 10          	add    $0x10,%rax
  38:	48 8b 10             	mov    (%rax),%rdx
  3b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  3f:	48 83 c0 08          	add    $0x8,%rax
  43:	48 8b 00             	mov    (%rax),%rax
  46:	48 89 d6             	mov    %rdx,%rsi
  49:	48 89 c7             	mov    %rax,%rdi
  4c:	e8 8e 03 00 00       	callq  3df <link>
  51:	85 c0                	test   %eax,%eax
  53:	79 32                	jns    87 <main+0x87>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  55:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  59:	48 83 c0 10          	add    $0x10,%rax
  5d:	48 8b 10             	mov    (%rax),%rdx
  60:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  64:	48 83 c0 08          	add    $0x8,%rax
  68:	48 8b 00             	mov    (%rax),%rax
  6b:	48 89 d1             	mov    %rdx,%rcx
  6e:	48 89 c2             	mov    %rax,%rdx
  71:	48 c7 c6 1f 0b 00 00 	mov    $0xb1f,%rsi
  78:	bf 02 00 00 00       	mov    $0x2,%edi
  7d:	b8 00 00 00 00       	mov    $0x0,%eax
  82:	e8 81 04 00 00       	callq  508 <printf>
  exit();
  87:	e8 f3 02 00 00       	callq  37f <exit>

000000000000008c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  8c:	55                   	push   %rbp
  8d:	48 89 e5             	mov    %rsp,%rbp
  90:	48 83 ec 10          	sub    $0x10,%rsp
  94:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  98:	89 75 f4             	mov    %esi,-0xc(%rbp)
  9b:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  9e:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  a2:	8b 55 f0             	mov    -0x10(%rbp),%edx
  a5:	8b 45 f4             	mov    -0xc(%rbp),%eax
  a8:	48 89 ce             	mov    %rcx,%rsi
  ab:	48 89 f7             	mov    %rsi,%rdi
  ae:	89 d1                	mov    %edx,%ecx
  b0:	fc                   	cld    
  b1:	f3 aa                	rep stos %al,%es:(%rdi)
  b3:	89 ca                	mov    %ecx,%edx
  b5:	48 89 fe             	mov    %rdi,%rsi
  b8:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  bc:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  bf:	90                   	nop
  c0:	c9                   	leaveq 
  c1:	c3                   	retq   

00000000000000c2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c2:	55                   	push   %rbp
  c3:	48 89 e5             	mov    %rsp,%rbp
  c6:	48 83 ec 20          	sub    $0x20,%rsp
  ca:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  ce:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  d6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  da:	90                   	nop
  db:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  df:	48 8d 42 01          	lea    0x1(%rdx),%rax
  e3:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  e7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  eb:	48 8d 48 01          	lea    0x1(%rax),%rcx
  ef:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  f3:	0f b6 12             	movzbl (%rdx),%edx
  f6:	88 10                	mov    %dl,(%rax)
  f8:	0f b6 00             	movzbl (%rax),%eax
  fb:	84 c0                	test   %al,%al
  fd:	75 dc                	jne    db <strcpy+0x19>
    ;
  return os;
  ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 103:	c9                   	leaveq 
 104:	c3                   	retq   

0000000000000105 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 105:	55                   	push   %rbp
 106:	48 89 e5             	mov    %rsp,%rbp
 109:	48 83 ec 10          	sub    $0x10,%rsp
 10d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 111:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 115:	eb 0a                	jmp    121 <strcmp+0x1c>
    p++, q++;
 117:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 11c:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 121:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 125:	0f b6 00             	movzbl (%rax),%eax
 128:	84 c0                	test   %al,%al
 12a:	74 12                	je     13e <strcmp+0x39>
 12c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 130:	0f b6 10             	movzbl (%rax),%edx
 133:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 137:	0f b6 00             	movzbl (%rax),%eax
 13a:	38 c2                	cmp    %al,%dl
 13c:	74 d9                	je     117 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 13e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 142:	0f b6 00             	movzbl (%rax),%eax
 145:	0f b6 d0             	movzbl %al,%edx
 148:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 14c:	0f b6 00             	movzbl (%rax),%eax
 14f:	0f b6 c0             	movzbl %al,%eax
 152:	29 c2                	sub    %eax,%edx
 154:	89 d0                	mov    %edx,%eax
}
 156:	c9                   	leaveq 
 157:	c3                   	retq   

0000000000000158 <strlen>:

uint
strlen(char *s)
{
 158:	55                   	push   %rbp
 159:	48 89 e5             	mov    %rsp,%rbp
 15c:	48 83 ec 18          	sub    $0x18,%rsp
 160:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 164:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 16b:	eb 04                	jmp    171 <strlen+0x19>
 16d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 171:	8b 45 fc             	mov    -0x4(%rbp),%eax
 174:	48 63 d0             	movslq %eax,%rdx
 177:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 17b:	48 01 d0             	add    %rdx,%rax
 17e:	0f b6 00             	movzbl (%rax),%eax
 181:	84 c0                	test   %al,%al
 183:	75 e8                	jne    16d <strlen+0x15>
    ;
  return n;
 185:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 188:	c9                   	leaveq 
 189:	c3                   	retq   

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	55                   	push   %rbp
 18b:	48 89 e5             	mov    %rsp,%rbp
 18e:	48 83 ec 10          	sub    $0x10,%rsp
 192:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 196:	89 75 f4             	mov    %esi,-0xc(%rbp)
 199:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 19c:	8b 55 f0             	mov    -0x10(%rbp),%edx
 19f:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 1a2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1a6:	89 ce                	mov    %ecx,%esi
 1a8:	48 89 c7             	mov    %rax,%rdi
 1ab:	e8 dc fe ff ff       	callq  8c <stosb>
  return dst;
 1b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 1b4:	c9                   	leaveq 
 1b5:	c3                   	retq   

00000000000001b6 <strchr>:

char*
strchr(const char *s, char c)
{
 1b6:	55                   	push   %rbp
 1b7:	48 89 e5             	mov    %rsp,%rbp
 1ba:	48 83 ec 10          	sub    $0x10,%rsp
 1be:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1c2:	89 f0                	mov    %esi,%eax
 1c4:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 1c7:	eb 17                	jmp    1e0 <strchr+0x2a>
    if(*s == c)
 1c9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1cd:	0f b6 00             	movzbl (%rax),%eax
 1d0:	38 45 f4             	cmp    %al,-0xc(%rbp)
 1d3:	75 06                	jne    1db <strchr+0x25>
      return (char*)s;
 1d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1d9:	eb 15                	jmp    1f0 <strchr+0x3a>
  for(; *s; s++)
 1db:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 1e0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1e4:	0f b6 00             	movzbl (%rax),%eax
 1e7:	84 c0                	test   %al,%al
 1e9:	75 de                	jne    1c9 <strchr+0x13>
  return 0;
 1eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1f0:	c9                   	leaveq 
 1f1:	c3                   	retq   

00000000000001f2 <gets>:

char*
gets(char *buf, int max)
{
 1f2:	55                   	push   %rbp
 1f3:	48 89 e5             	mov    %rsp,%rbp
 1f6:	48 83 ec 20          	sub    $0x20,%rsp
 1fa:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 1fe:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 201:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 208:	eb 48                	jmp    252 <gets+0x60>
    cc = read(0, &c, 1);
 20a:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 20e:	ba 01 00 00 00       	mov    $0x1,%edx
 213:	48 89 c6             	mov    %rax,%rsi
 216:	bf 00 00 00 00       	mov    $0x0,%edi
 21b:	e8 77 01 00 00       	callq  397 <read>
 220:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 223:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 227:	7e 36                	jle    25f <gets+0x6d>
      break;
    buf[i++] = c;
 229:	8b 45 fc             	mov    -0x4(%rbp),%eax
 22c:	8d 50 01             	lea    0x1(%rax),%edx
 22f:	89 55 fc             	mov    %edx,-0x4(%rbp)
 232:	48 63 d0             	movslq %eax,%rdx
 235:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 239:	48 01 c2             	add    %rax,%rdx
 23c:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 240:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 242:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 246:	3c 0a                	cmp    $0xa,%al
 248:	74 16                	je     260 <gets+0x6e>
 24a:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 24e:	3c 0d                	cmp    $0xd,%al
 250:	74 0e                	je     260 <gets+0x6e>
  for(i=0; i+1 < max; ){
 252:	8b 45 fc             	mov    -0x4(%rbp),%eax
 255:	83 c0 01             	add    $0x1,%eax
 258:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 25b:	7f ad                	jg     20a <gets+0x18>
 25d:	eb 01                	jmp    260 <gets+0x6e>
      break;
 25f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 260:	8b 45 fc             	mov    -0x4(%rbp),%eax
 263:	48 63 d0             	movslq %eax,%rdx
 266:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 26a:	48 01 d0             	add    %rdx,%rax
 26d:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 270:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 274:	c9                   	leaveq 
 275:	c3                   	retq   

0000000000000276 <stat>:

int
stat(char *n, struct stat *st)
{
 276:	55                   	push   %rbp
 277:	48 89 e5             	mov    %rsp,%rbp
 27a:	48 83 ec 20          	sub    $0x20,%rsp
 27e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 282:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 28a:	be 00 00 00 00       	mov    $0x0,%esi
 28f:	48 89 c7             	mov    %rax,%rdi
 292:	e8 28 01 00 00       	callq  3bf <open>
 297:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 29a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 29e:	79 07                	jns    2a7 <stat+0x31>
    return -1;
 2a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a5:	eb 21                	jmp    2c8 <stat+0x52>
  r = fstat(fd, st);
 2a7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 2ab:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2ae:	48 89 d6             	mov    %rdx,%rsi
 2b1:	89 c7                	mov    %eax,%edi
 2b3:	e8 1f 01 00 00       	callq  3d7 <fstat>
 2b8:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 2bb:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2be:	89 c7                	mov    %eax,%edi
 2c0:	e8 e2 00 00 00       	callq  3a7 <close>
  return r;
 2c5:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 2c8:	c9                   	leaveq 
 2c9:	c3                   	retq   

00000000000002ca <atoi>:

int
atoi(const char *s)
{
 2ca:	55                   	push   %rbp
 2cb:	48 89 e5             	mov    %rsp,%rbp
 2ce:	48 83 ec 18          	sub    $0x18,%rsp
 2d2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 2d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2dd:	eb 28                	jmp    307 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 2df:	8b 55 fc             	mov    -0x4(%rbp),%edx
 2e2:	89 d0                	mov    %edx,%eax
 2e4:	c1 e0 02             	shl    $0x2,%eax
 2e7:	01 d0                	add    %edx,%eax
 2e9:	01 c0                	add    %eax,%eax
 2eb:	89 c1                	mov    %eax,%ecx
 2ed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2f1:	48 8d 50 01          	lea    0x1(%rax),%rdx
 2f5:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 2f9:	0f b6 00             	movzbl (%rax),%eax
 2fc:	0f be c0             	movsbl %al,%eax
 2ff:	01 c8                	add    %ecx,%eax
 301:	83 e8 30             	sub    $0x30,%eax
 304:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 307:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 30b:	0f b6 00             	movzbl (%rax),%eax
 30e:	3c 2f                	cmp    $0x2f,%al
 310:	7e 0b                	jle    31d <atoi+0x53>
 312:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 316:	0f b6 00             	movzbl (%rax),%eax
 319:	3c 39                	cmp    $0x39,%al
 31b:	7e c2                	jle    2df <atoi+0x15>
  return n;
 31d:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 320:	c9                   	leaveq 
 321:	c3                   	retq   

0000000000000322 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 322:	55                   	push   %rbp
 323:	48 89 e5             	mov    %rsp,%rbp
 326:	48 83 ec 28          	sub    $0x28,%rsp
 32a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 32e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 332:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 335:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 339:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 33d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 341:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 345:	eb 1d                	jmp    364 <memmove+0x42>
    *dst++ = *src++;
 347:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 34b:	48 8d 42 01          	lea    0x1(%rdx),%rax
 34f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 353:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 357:	48 8d 48 01          	lea    0x1(%rax),%rcx
 35b:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 35f:	0f b6 12             	movzbl (%rdx),%edx
 362:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 364:	8b 45 dc             	mov    -0x24(%rbp),%eax
 367:	8d 50 ff             	lea    -0x1(%rax),%edx
 36a:	89 55 dc             	mov    %edx,-0x24(%rbp)
 36d:	85 c0                	test   %eax,%eax
 36f:	7f d6                	jg     347 <memmove+0x25>
  return vdst;
 371:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 375:	c9                   	leaveq 
 376:	c3                   	retq   

0000000000000377 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 377:	b8 01 00 00 00       	mov    $0x1,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	retq   

000000000000037f <exit>:
SYSCALL(exit)
 37f:	b8 02 00 00 00       	mov    $0x2,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	retq   

0000000000000387 <wait>:
SYSCALL(wait)
 387:	b8 03 00 00 00       	mov    $0x3,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	retq   

000000000000038f <pipe>:
SYSCALL(pipe)
 38f:	b8 04 00 00 00       	mov    $0x4,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	retq   

0000000000000397 <read>:
SYSCALL(read)
 397:	b8 05 00 00 00       	mov    $0x5,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	retq   

000000000000039f <write>:
SYSCALL(write)
 39f:	b8 10 00 00 00       	mov    $0x10,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	retq   

00000000000003a7 <close>:
SYSCALL(close)
 3a7:	b8 15 00 00 00       	mov    $0x15,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	retq   

00000000000003af <kill>:
SYSCALL(kill)
 3af:	b8 06 00 00 00       	mov    $0x6,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	retq   

00000000000003b7 <exec>:
SYSCALL(exec)
 3b7:	b8 07 00 00 00       	mov    $0x7,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	retq   

00000000000003bf <open>:
SYSCALL(open)
 3bf:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	retq   

00000000000003c7 <mknod>:
SYSCALL(mknod)
 3c7:	b8 11 00 00 00       	mov    $0x11,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	retq   

00000000000003cf <unlink>:
SYSCALL(unlink)
 3cf:	b8 12 00 00 00       	mov    $0x12,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	retq   

00000000000003d7 <fstat>:
SYSCALL(fstat)
 3d7:	b8 08 00 00 00       	mov    $0x8,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	retq   

00000000000003df <link>:
SYSCALL(link)
 3df:	b8 13 00 00 00       	mov    $0x13,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	retq   

00000000000003e7 <mkdir>:
SYSCALL(mkdir)
 3e7:	b8 14 00 00 00       	mov    $0x14,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	retq   

00000000000003ef <chdir>:
SYSCALL(chdir)
 3ef:	b8 09 00 00 00       	mov    $0x9,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	retq   

00000000000003f7 <dup>:
SYSCALL(dup)
 3f7:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	retq   

00000000000003ff <getpid>:
SYSCALL(getpid)
 3ff:	b8 0b 00 00 00       	mov    $0xb,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	retq   

0000000000000407 <sbrk>:
SYSCALL(sbrk)
 407:	b8 0c 00 00 00       	mov    $0xc,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	retq   

000000000000040f <sleep>:
SYSCALL(sleep)
 40f:	b8 0d 00 00 00       	mov    $0xd,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	retq   

0000000000000417 <uptime>:
SYSCALL(uptime)
 417:	b8 0e 00 00 00       	mov    $0xe,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	retq   

000000000000041f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41f:	55                   	push   %rbp
 420:	48 89 e5             	mov    %rsp,%rbp
 423:	48 83 ec 10          	sub    $0x10,%rsp
 427:	89 7d fc             	mov    %edi,-0x4(%rbp)
 42a:	89 f0                	mov    %esi,%eax
 42c:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 42f:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 433:	8b 45 fc             	mov    -0x4(%rbp),%eax
 436:	ba 01 00 00 00       	mov    $0x1,%edx
 43b:	48 89 ce             	mov    %rcx,%rsi
 43e:	89 c7                	mov    %eax,%edi
 440:	e8 5a ff ff ff       	callq  39f <write>
}
 445:	90                   	nop
 446:	c9                   	leaveq 
 447:	c3                   	retq   

0000000000000448 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 448:	55                   	push   %rbp
 449:	48 89 e5             	mov    %rsp,%rbp
 44c:	48 83 ec 30          	sub    $0x30,%rsp
 450:	89 7d dc             	mov    %edi,-0x24(%rbp)
 453:	89 75 d8             	mov    %esi,-0x28(%rbp)
 456:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 459:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 463:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 467:	74 17                	je     480 <printint+0x38>
 469:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 46d:	79 11                	jns    480 <printint+0x38>
    neg = 1;
 46f:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 476:	8b 45 d8             	mov    -0x28(%rbp),%eax
 479:	f7 d8                	neg    %eax
 47b:	89 45 f4             	mov    %eax,-0xc(%rbp)
 47e:	eb 06                	jmp    486 <printint+0x3e>
  } else {
    x = xx;
 480:	8b 45 d8             	mov    -0x28(%rbp),%eax
 483:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 486:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 48d:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 490:	8b 45 f4             	mov    -0xc(%rbp),%eax
 493:	ba 00 00 00 00       	mov    $0x0,%edx
 498:	f7 f1                	div    %ecx
 49a:	89 d1                	mov    %edx,%ecx
 49c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 49f:	8d 50 01             	lea    0x1(%rax),%edx
 4a2:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4a5:	89 ca                	mov    %ecx,%edx
 4a7:	0f b6 92 80 0d 00 00 	movzbl 0xd80(%rdx),%edx
 4ae:	48 98                	cltq   
 4b0:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 4b4:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 4b7:	8b 45 f4             	mov    -0xc(%rbp),%eax
 4ba:	ba 00 00 00 00       	mov    $0x0,%edx
 4bf:	f7 f6                	div    %esi
 4c1:	89 45 f4             	mov    %eax,-0xc(%rbp)
 4c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 4c8:	75 c3                	jne    48d <printint+0x45>
  if(neg)
 4ca:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 4ce:	74 2b                	je     4fb <printint+0xb3>
    buf[i++] = '-';
 4d0:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4d3:	8d 50 01             	lea    0x1(%rax),%edx
 4d6:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4d9:	48 98                	cltq   
 4db:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 4e0:	eb 19                	jmp    4fb <printint+0xb3>
    putc(fd, buf[i]);
 4e2:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4e5:	48 98                	cltq   
 4e7:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 4ec:	0f be d0             	movsbl %al,%edx
 4ef:	8b 45 dc             	mov    -0x24(%rbp),%eax
 4f2:	89 d6                	mov    %edx,%esi
 4f4:	89 c7                	mov    %eax,%edi
 4f6:	e8 24 ff ff ff       	callq  41f <putc>
  while(--i >= 0)
 4fb:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 4ff:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 503:	79 dd                	jns    4e2 <printint+0x9a>
}
 505:	90                   	nop
 506:	c9                   	leaveq 
 507:	c3                   	retq   

0000000000000508 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 508:	55                   	push   %rbp
 509:	48 89 e5             	mov    %rsp,%rbp
 50c:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 513:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 519:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 520:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 527:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 52e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 535:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 53c:	84 c0                	test   %al,%al
 53e:	74 20                	je     560 <printf+0x58>
 540:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 544:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 548:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 54c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 550:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 554:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 558:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 55c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 560:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 567:	00 00 00 
 56a:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 571:	00 00 00 
 574:	48 8d 45 10          	lea    0x10(%rbp),%rax
 578:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 57f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 586:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 58d:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 594:	00 00 00 
  for(i = 0; fmt[i]; i++){
 597:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 59e:	00 00 00 
 5a1:	e9 a8 02 00 00       	jmpq   84e <printf+0x346>
    c = fmt[i] & 0xff;
 5a6:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 5ac:	48 63 d0             	movslq %eax,%rdx
 5af:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 5b6:	48 01 d0             	add    %rdx,%rax
 5b9:	0f b6 00             	movzbl (%rax),%eax
 5bc:	0f be c0             	movsbl %al,%eax
 5bf:	25 ff 00 00 00       	and    $0xff,%eax
 5c4:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 5ca:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 5d1:	75 35                	jne    608 <printf+0x100>
      if(c == '%'){
 5d3:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 5da:	75 0f                	jne    5eb <printf+0xe3>
        state = '%';
 5dc:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 5e3:	00 00 00 
 5e6:	e9 5c 02 00 00       	jmpq   847 <printf+0x33f>
      } else {
        putc(fd, c);
 5eb:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 5f1:	0f be d0             	movsbl %al,%edx
 5f4:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 5fa:	89 d6                	mov    %edx,%esi
 5fc:	89 c7                	mov    %eax,%edi
 5fe:	e8 1c fe ff ff       	callq  41f <putc>
 603:	e9 3f 02 00 00       	jmpq   847 <printf+0x33f>
      }
    } else if(state == '%'){
 608:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 60f:	0f 85 32 02 00 00    	jne    847 <printf+0x33f>
      if(c == 'd'){
 615:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 61c:	75 5e                	jne    67c <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 61e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 624:	83 f8 2f             	cmp    $0x2f,%eax
 627:	77 23                	ja     64c <printf+0x144>
 629:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 630:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 636:	89 d2                	mov    %edx,%edx
 638:	48 01 d0             	add    %rdx,%rax
 63b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 641:	83 c2 08             	add    $0x8,%edx
 644:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 64a:	eb 12                	jmp    65e <printf+0x156>
 64c:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 653:	48 8d 50 08          	lea    0x8(%rax),%rdx
 657:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 65e:	8b 30                	mov    (%rax),%esi
 660:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 666:	b9 01 00 00 00       	mov    $0x1,%ecx
 66b:	ba 0a 00 00 00       	mov    $0xa,%edx
 670:	89 c7                	mov    %eax,%edi
 672:	e8 d1 fd ff ff       	callq  448 <printint>
 677:	e9 c1 01 00 00       	jmpq   83d <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 67c:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 683:	74 09                	je     68e <printf+0x186>
 685:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 68c:	75 5e                	jne    6ec <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 68e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 694:	83 f8 2f             	cmp    $0x2f,%eax
 697:	77 23                	ja     6bc <printf+0x1b4>
 699:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6a0:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6a6:	89 d2                	mov    %edx,%edx
 6a8:	48 01 d0             	add    %rdx,%rax
 6ab:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6b1:	83 c2 08             	add    $0x8,%edx
 6b4:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6ba:	eb 12                	jmp    6ce <printf+0x1c6>
 6bc:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6c3:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6c7:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6ce:	8b 30                	mov    (%rax),%esi
 6d0:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6d6:	b9 00 00 00 00       	mov    $0x0,%ecx
 6db:	ba 10 00 00 00       	mov    $0x10,%edx
 6e0:	89 c7                	mov    %eax,%edi
 6e2:	e8 61 fd ff ff       	callq  448 <printint>
 6e7:	e9 51 01 00 00       	jmpq   83d <printf+0x335>
      } else if(c == 's'){
 6ec:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 6f3:	0f 85 98 00 00 00    	jne    791 <printf+0x289>
        s = va_arg(ap, char*);
 6f9:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6ff:	83 f8 2f             	cmp    $0x2f,%eax
 702:	77 23                	ja     727 <printf+0x21f>
 704:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 70b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 711:	89 d2                	mov    %edx,%edx
 713:	48 01 d0             	add    %rdx,%rax
 716:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 71c:	83 c2 08             	add    $0x8,%edx
 71f:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 725:	eb 12                	jmp    739 <printf+0x231>
 727:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 72e:	48 8d 50 08          	lea    0x8(%rax),%rdx
 732:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 739:	48 8b 00             	mov    (%rax),%rax
 73c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 743:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 74a:	00 
 74b:	75 31                	jne    77e <printf+0x276>
          s = "(null)";
 74d:	48 c7 85 48 ff ff ff 	movq   $0xb33,-0xb8(%rbp)
 754:	33 0b 00 00 
        while(*s != 0){
 758:	eb 24                	jmp    77e <printf+0x276>
          putc(fd, *s);
 75a:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 761:	0f b6 00             	movzbl (%rax),%eax
 764:	0f be d0             	movsbl %al,%edx
 767:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 76d:	89 d6                	mov    %edx,%esi
 76f:	89 c7                	mov    %eax,%edi
 771:	e8 a9 fc ff ff       	callq  41f <putc>
          s++;
 776:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 77d:	01 
        while(*s != 0){
 77e:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 785:	0f b6 00             	movzbl (%rax),%eax
 788:	84 c0                	test   %al,%al
 78a:	75 ce                	jne    75a <printf+0x252>
 78c:	e9 ac 00 00 00       	jmpq   83d <printf+0x335>
        }
      } else if(c == 'c'){
 791:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 798:	75 56                	jne    7f0 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 79a:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 7a0:	83 f8 2f             	cmp    $0x2f,%eax
 7a3:	77 23                	ja     7c8 <printf+0x2c0>
 7a5:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 7ac:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7b2:	89 d2                	mov    %edx,%edx
 7b4:	48 01 d0             	add    %rdx,%rax
 7b7:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7bd:	83 c2 08             	add    $0x8,%edx
 7c0:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7c6:	eb 12                	jmp    7da <printf+0x2d2>
 7c8:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7cf:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7d3:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7da:	8b 00                	mov    (%rax),%eax
 7dc:	0f be d0             	movsbl %al,%edx
 7df:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7e5:	89 d6                	mov    %edx,%esi
 7e7:	89 c7                	mov    %eax,%edi
 7e9:	e8 31 fc ff ff       	callq  41f <putc>
 7ee:	eb 4d                	jmp    83d <printf+0x335>
      } else if(c == '%'){
 7f0:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 7f7:	75 1a                	jne    813 <printf+0x30b>
        putc(fd, c);
 7f9:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7ff:	0f be d0             	movsbl %al,%edx
 802:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 808:	89 d6                	mov    %edx,%esi
 80a:	89 c7                	mov    %eax,%edi
 80c:	e8 0e fc ff ff       	callq  41f <putc>
 811:	eb 2a                	jmp    83d <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 813:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 819:	be 25 00 00 00       	mov    $0x25,%esi
 81e:	89 c7                	mov    %eax,%edi
 820:	e8 fa fb ff ff       	callq  41f <putc>
        putc(fd, c);
 825:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 82b:	0f be d0             	movsbl %al,%edx
 82e:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 834:	89 d6                	mov    %edx,%esi
 836:	89 c7                	mov    %eax,%edi
 838:	e8 e2 fb ff ff       	callq  41f <putc>
      }
      state = 0;
 83d:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 844:	00 00 00 
  for(i = 0; fmt[i]; i++){
 847:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 84e:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 854:	48 63 d0             	movslq %eax,%rdx
 857:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 85e:	48 01 d0             	add    %rdx,%rax
 861:	0f b6 00             	movzbl (%rax),%eax
 864:	84 c0                	test   %al,%al
 866:	0f 85 3a fd ff ff    	jne    5a6 <printf+0x9e>
    }
  }
}
 86c:	90                   	nop
 86d:	c9                   	leaveq 
 86e:	c3                   	retq   

000000000000086f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86f:	55                   	push   %rbp
 870:	48 89 e5             	mov    %rsp,%rbp
 873:	48 83 ec 18          	sub    $0x18,%rsp
 877:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 87f:	48 83 e8 10          	sub    $0x10,%rax
 883:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 887:	48 8b 05 22 05 00 00 	mov    0x522(%rip),%rax        # db0 <freep>
 88e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 892:	eb 2f                	jmp    8c3 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 894:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 898:	48 8b 00             	mov    (%rax),%rax
 89b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 89f:	72 17                	jb     8b8 <free+0x49>
 8a1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8a5:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8a9:	77 2f                	ja     8da <free+0x6b>
 8ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8af:	48 8b 00             	mov    (%rax),%rax
 8b2:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8b6:	72 22                	jb     8da <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8bc:	48 8b 00             	mov    (%rax),%rax
 8bf:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 8c3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8c7:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8cb:	76 c7                	jbe    894 <free+0x25>
 8cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8d1:	48 8b 00             	mov    (%rax),%rax
 8d4:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8d8:	73 ba                	jae    894 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8da:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8de:	8b 40 08             	mov    0x8(%rax),%eax
 8e1:	89 c0                	mov    %eax,%eax
 8e3:	48 c1 e0 04          	shl    $0x4,%rax
 8e7:	48 89 c2             	mov    %rax,%rdx
 8ea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8ee:	48 01 c2             	add    %rax,%rdx
 8f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8f5:	48 8b 00             	mov    (%rax),%rax
 8f8:	48 39 c2             	cmp    %rax,%rdx
 8fb:	75 2d                	jne    92a <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 8fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 901:	8b 50 08             	mov    0x8(%rax),%edx
 904:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 908:	48 8b 00             	mov    (%rax),%rax
 90b:	8b 40 08             	mov    0x8(%rax),%eax
 90e:	01 c2                	add    %eax,%edx
 910:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 914:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 917:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 91b:	48 8b 00             	mov    (%rax),%rax
 91e:	48 8b 10             	mov    (%rax),%rdx
 921:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 925:	48 89 10             	mov    %rdx,(%rax)
 928:	eb 0e                	jmp    938 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 92a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 92e:	48 8b 10             	mov    (%rax),%rdx
 931:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 935:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 938:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 93c:	8b 40 08             	mov    0x8(%rax),%eax
 93f:	89 c0                	mov    %eax,%eax
 941:	48 c1 e0 04          	shl    $0x4,%rax
 945:	48 89 c2             	mov    %rax,%rdx
 948:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 94c:	48 01 d0             	add    %rdx,%rax
 94f:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 953:	75 27                	jne    97c <free+0x10d>
    p->s.size += bp->s.size;
 955:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 959:	8b 50 08             	mov    0x8(%rax),%edx
 95c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 960:	8b 40 08             	mov    0x8(%rax),%eax
 963:	01 c2                	add    %eax,%edx
 965:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 969:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 96c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 970:	48 8b 10             	mov    (%rax),%rdx
 973:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 977:	48 89 10             	mov    %rdx,(%rax)
 97a:	eb 0b                	jmp    987 <free+0x118>
  } else
    p->s.ptr = bp;
 97c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 980:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 984:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 987:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 98b:	48 89 05 1e 04 00 00 	mov    %rax,0x41e(%rip)        # db0 <freep>
}
 992:	90                   	nop
 993:	c9                   	leaveq 
 994:	c3                   	retq   

0000000000000995 <morecore>:

static Header*
morecore(uint nu)
{
 995:	55                   	push   %rbp
 996:	48 89 e5             	mov    %rsp,%rbp
 999:	48 83 ec 20          	sub    $0x20,%rsp
 99d:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 9a0:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 9a7:	77 07                	ja     9b0 <morecore+0x1b>
    nu = 4096;
 9a9:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 9b0:	8b 45 ec             	mov    -0x14(%rbp),%eax
 9b3:	c1 e0 04             	shl    $0x4,%eax
 9b6:	89 c7                	mov    %eax,%edi
 9b8:	e8 4a fa ff ff       	callq  407 <sbrk>
 9bd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 9c1:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 9c6:	75 07                	jne    9cf <morecore+0x3a>
    return 0;
 9c8:	b8 00 00 00 00       	mov    $0x0,%eax
 9cd:	eb 29                	jmp    9f8 <morecore+0x63>
  hp = (Header*)p;
 9cf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9d3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 9d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9db:	8b 55 ec             	mov    -0x14(%rbp),%edx
 9de:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 9e1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9e5:	48 83 c0 10          	add    $0x10,%rax
 9e9:	48 89 c7             	mov    %rax,%rdi
 9ec:	e8 7e fe ff ff       	callq  86f <free>
  return freep;
 9f1:	48 8b 05 b8 03 00 00 	mov    0x3b8(%rip),%rax        # db0 <freep>
}
 9f8:	c9                   	leaveq 
 9f9:	c3                   	retq   

00000000000009fa <malloc>:

void*
malloc(uint nbytes)
{
 9fa:	55                   	push   %rbp
 9fb:	48 89 e5             	mov    %rsp,%rbp
 9fe:	48 83 ec 30          	sub    $0x30,%rsp
 a02:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a05:	8b 45 dc             	mov    -0x24(%rbp),%eax
 a08:	48 83 c0 0f          	add    $0xf,%rax
 a0c:	48 c1 e8 04          	shr    $0x4,%rax
 a10:	83 c0 01             	add    $0x1,%eax
 a13:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 a16:	48 8b 05 93 03 00 00 	mov    0x393(%rip),%rax        # db0 <freep>
 a1d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a21:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 a26:	75 2b                	jne    a53 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 a28:	48 c7 45 f0 a0 0d 00 	movq   $0xda0,-0x10(%rbp)
 a2f:	00 
 a30:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a34:	48 89 05 75 03 00 00 	mov    %rax,0x375(%rip)        # db0 <freep>
 a3b:	48 8b 05 6e 03 00 00 	mov    0x36e(%rip),%rax        # db0 <freep>
 a42:	48 89 05 57 03 00 00 	mov    %rax,0x357(%rip)        # da0 <base>
    base.s.size = 0;
 a49:	c7 05 55 03 00 00 00 	movl   $0x0,0x355(%rip)        # da8 <base+0x8>
 a50:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a53:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a57:	48 8b 00             	mov    (%rax),%rax
 a5a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a5e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a62:	8b 40 08             	mov    0x8(%rax),%eax
 a65:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a68:	77 5f                	ja     ac9 <malloc+0xcf>
      if(p->s.size == nunits)
 a6a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a6e:	8b 40 08             	mov    0x8(%rax),%eax
 a71:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a74:	75 10                	jne    a86 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a76:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a7a:	48 8b 10             	mov    (%rax),%rdx
 a7d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a81:	48 89 10             	mov    %rdx,(%rax)
 a84:	eb 2e                	jmp    ab4 <malloc+0xba>
      else {
        p->s.size -= nunits;
 a86:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a8a:	8b 40 08             	mov    0x8(%rax),%eax
 a8d:	2b 45 ec             	sub    -0x14(%rbp),%eax
 a90:	89 c2                	mov    %eax,%edx
 a92:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a96:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 a99:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a9d:	8b 40 08             	mov    0x8(%rax),%eax
 aa0:	89 c0                	mov    %eax,%eax
 aa2:	48 c1 e0 04          	shl    $0x4,%rax
 aa6:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 aaa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aae:	8b 55 ec             	mov    -0x14(%rbp),%edx
 ab1:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 ab4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 ab8:	48 89 05 f1 02 00 00 	mov    %rax,0x2f1(%rip)        # db0 <freep>
      return (void*)(p + 1);
 abf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ac3:	48 83 c0 10          	add    $0x10,%rax
 ac7:	eb 41                	jmp    b0a <malloc+0x110>
    }
    if(p == freep)
 ac9:	48 8b 05 e0 02 00 00 	mov    0x2e0(%rip),%rax        # db0 <freep>
 ad0:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 ad4:	75 1c                	jne    af2 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 ad6:	8b 45 ec             	mov    -0x14(%rbp),%eax
 ad9:	89 c7                	mov    %eax,%edi
 adb:	e8 b5 fe ff ff       	callq  995 <morecore>
 ae0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 ae4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 ae9:	75 07                	jne    af2 <malloc+0xf8>
        return 0;
 aeb:	b8 00 00 00 00       	mov    $0x0,%eax
 af0:	eb 18                	jmp    b0a <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 af6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 afa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 afe:	48 8b 00             	mov    (%rax),%rax
 b01:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 b05:	e9 54 ff ff ff       	jmpq   a5e <malloc+0x64>
  }
}
 b0a:	c9                   	leaveq 
 b0b:	c3                   	retq   
