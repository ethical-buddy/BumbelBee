
fs/echo:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 20          	sub    $0x20,%rsp
   8:	89 7d ec             	mov    %edi,-0x14(%rbp)
   b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int i;

  for(i = 1; i < argc; i++)
   f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  16:	eb 52                	jmp    6a <main+0x6a>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  18:	8b 45 fc             	mov    -0x4(%rbp),%eax
  1b:	83 c0 01             	add    $0x1,%eax
  1e:	39 45 ec             	cmp    %eax,-0x14(%rbp)
  21:	7e 09                	jle    2c <main+0x2c>
  23:	48 c7 c2 f7 0a 00 00 	mov    $0xaf7,%rdx
  2a:	eb 07                	jmp    33 <main+0x33>
  2c:	48 c7 c2 f9 0a 00 00 	mov    $0xaf9,%rdx
  33:	8b 45 fc             	mov    -0x4(%rbp),%eax
  36:	48 98                	cltq   
  38:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  3f:	00 
  40:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  44:	48 01 c8             	add    %rcx,%rax
  47:	48 8b 00             	mov    (%rax),%rax
  4a:	48 89 d1             	mov    %rdx,%rcx
  4d:	48 89 c2             	mov    %rax,%rdx
  50:	48 c7 c6 fb 0a 00 00 	mov    $0xafb,%rsi
  57:	bf 01 00 00 00       	mov    $0x1,%edi
  5c:	b8 00 00 00 00       	mov    $0x0,%eax
  61:	e8 8d 04 00 00       	callq  4f3 <printf>
  for(i = 1; i < argc; i++)
  66:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  6a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  6d:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  70:	7c a6                	jl     18 <main+0x18>
  exit();
  72:	e8 f3 02 00 00       	callq  36a <exit>

0000000000000077 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  77:	55                   	push   %rbp
  78:	48 89 e5             	mov    %rsp,%rbp
  7b:	48 83 ec 10          	sub    $0x10,%rsp
  7f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  83:	89 75 f4             	mov    %esi,-0xc(%rbp)
  86:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  89:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  8d:	8b 55 f0             	mov    -0x10(%rbp),%edx
  90:	8b 45 f4             	mov    -0xc(%rbp),%eax
  93:	48 89 ce             	mov    %rcx,%rsi
  96:	48 89 f7             	mov    %rsi,%rdi
  99:	89 d1                	mov    %edx,%ecx
  9b:	fc                   	cld    
  9c:	f3 aa                	rep stos %al,%es:(%rdi)
  9e:	89 ca                	mov    %ecx,%edx
  a0:	48 89 fe             	mov    %rdi,%rsi
  a3:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  a7:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  aa:	90                   	nop
  ab:	c9                   	leaveq 
  ac:	c3                   	retq   

00000000000000ad <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ad:	55                   	push   %rbp
  ae:	48 89 e5             	mov    %rsp,%rbp
  b1:	48 83 ec 20          	sub    $0x20,%rsp
  b5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  b9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  bd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  c1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  c5:	90                   	nop
  c6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  ca:	48 8d 42 01          	lea    0x1(%rdx),%rax
  ce:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  d6:	48 8d 48 01          	lea    0x1(%rax),%rcx
  da:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  de:	0f b6 12             	movzbl (%rdx),%edx
  e1:	88 10                	mov    %dl,(%rax)
  e3:	0f b6 00             	movzbl (%rax),%eax
  e6:	84 c0                	test   %al,%al
  e8:	75 dc                	jne    c6 <strcpy+0x19>
    ;
  return os;
  ea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  ee:	c9                   	leaveq 
  ef:	c3                   	retq   

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	55                   	push   %rbp
  f1:	48 89 e5             	mov    %rsp,%rbp
  f4:	48 83 ec 10          	sub    $0x10,%rsp
  f8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  fc:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 100:	eb 0a                	jmp    10c <strcmp+0x1c>
    p++, q++;
 102:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 107:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 10c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 110:	0f b6 00             	movzbl (%rax),%eax
 113:	84 c0                	test   %al,%al
 115:	74 12                	je     129 <strcmp+0x39>
 117:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 11b:	0f b6 10             	movzbl (%rax),%edx
 11e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 122:	0f b6 00             	movzbl (%rax),%eax
 125:	38 c2                	cmp    %al,%dl
 127:	74 d9                	je     102 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 129:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 12d:	0f b6 00             	movzbl (%rax),%eax
 130:	0f b6 d0             	movzbl %al,%edx
 133:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 137:	0f b6 00             	movzbl (%rax),%eax
 13a:	0f b6 c0             	movzbl %al,%eax
 13d:	29 c2                	sub    %eax,%edx
 13f:	89 d0                	mov    %edx,%eax
}
 141:	c9                   	leaveq 
 142:	c3                   	retq   

0000000000000143 <strlen>:

uint
strlen(char *s)
{
 143:	55                   	push   %rbp
 144:	48 89 e5             	mov    %rsp,%rbp
 147:	48 83 ec 18          	sub    $0x18,%rsp
 14b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 14f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 156:	eb 04                	jmp    15c <strlen+0x19>
 158:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 15c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 15f:	48 63 d0             	movslq %eax,%rdx
 162:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 166:	48 01 d0             	add    %rdx,%rax
 169:	0f b6 00             	movzbl (%rax),%eax
 16c:	84 c0                	test   %al,%al
 16e:	75 e8                	jne    158 <strlen+0x15>
    ;
  return n;
 170:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 173:	c9                   	leaveq 
 174:	c3                   	retq   

0000000000000175 <memset>:

void*
memset(void *dst, int c, uint n)
{
 175:	55                   	push   %rbp
 176:	48 89 e5             	mov    %rsp,%rbp
 179:	48 83 ec 10          	sub    $0x10,%rsp
 17d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 181:	89 75 f4             	mov    %esi,-0xc(%rbp)
 184:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 187:	8b 55 f0             	mov    -0x10(%rbp),%edx
 18a:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 18d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 191:	89 ce                	mov    %ecx,%esi
 193:	48 89 c7             	mov    %rax,%rdi
 196:	e8 dc fe ff ff       	callq  77 <stosb>
  return dst;
 19b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 19f:	c9                   	leaveq 
 1a0:	c3                   	retq   

00000000000001a1 <strchr>:

char*
strchr(const char *s, char c)
{
 1a1:	55                   	push   %rbp
 1a2:	48 89 e5             	mov    %rsp,%rbp
 1a5:	48 83 ec 10          	sub    $0x10,%rsp
 1a9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1ad:	89 f0                	mov    %esi,%eax
 1af:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 1b2:	eb 17                	jmp    1cb <strchr+0x2a>
    if(*s == c)
 1b4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1b8:	0f b6 00             	movzbl (%rax),%eax
 1bb:	38 45 f4             	cmp    %al,-0xc(%rbp)
 1be:	75 06                	jne    1c6 <strchr+0x25>
      return (char*)s;
 1c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1c4:	eb 15                	jmp    1db <strchr+0x3a>
  for(; *s; s++)
 1c6:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 1cb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1cf:	0f b6 00             	movzbl (%rax),%eax
 1d2:	84 c0                	test   %al,%al
 1d4:	75 de                	jne    1b4 <strchr+0x13>
  return 0;
 1d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1db:	c9                   	leaveq 
 1dc:	c3                   	retq   

00000000000001dd <gets>:

char*
gets(char *buf, int max)
{
 1dd:	55                   	push   %rbp
 1de:	48 89 e5             	mov    %rsp,%rbp
 1e1:	48 83 ec 20          	sub    $0x20,%rsp
 1e5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 1e9:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 1f3:	eb 48                	jmp    23d <gets+0x60>
    cc = read(0, &c, 1);
 1f5:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 1f9:	ba 01 00 00 00       	mov    $0x1,%edx
 1fe:	48 89 c6             	mov    %rax,%rsi
 201:	bf 00 00 00 00       	mov    $0x0,%edi
 206:	e8 77 01 00 00       	callq  382 <read>
 20b:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 20e:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 212:	7e 36                	jle    24a <gets+0x6d>
      break;
    buf[i++] = c;
 214:	8b 45 fc             	mov    -0x4(%rbp),%eax
 217:	8d 50 01             	lea    0x1(%rax),%edx
 21a:	89 55 fc             	mov    %edx,-0x4(%rbp)
 21d:	48 63 d0             	movslq %eax,%rdx
 220:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 224:	48 01 c2             	add    %rax,%rdx
 227:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 22b:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 22d:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 231:	3c 0a                	cmp    $0xa,%al
 233:	74 16                	je     24b <gets+0x6e>
 235:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 239:	3c 0d                	cmp    $0xd,%al
 23b:	74 0e                	je     24b <gets+0x6e>
  for(i=0; i+1 < max; ){
 23d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 240:	83 c0 01             	add    $0x1,%eax
 243:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 246:	7f ad                	jg     1f5 <gets+0x18>
 248:	eb 01                	jmp    24b <gets+0x6e>
      break;
 24a:	90                   	nop
      break;
  }
  buf[i] = '\0';
 24b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 24e:	48 63 d0             	movslq %eax,%rdx
 251:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 255:	48 01 d0             	add    %rdx,%rax
 258:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 25b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 25f:	c9                   	leaveq 
 260:	c3                   	retq   

0000000000000261 <stat>:

int
stat(char *n, struct stat *st)
{
 261:	55                   	push   %rbp
 262:	48 89 e5             	mov    %rsp,%rbp
 265:	48 83 ec 20          	sub    $0x20,%rsp
 269:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 26d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 271:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 275:	be 00 00 00 00       	mov    $0x0,%esi
 27a:	48 89 c7             	mov    %rax,%rdi
 27d:	e8 28 01 00 00       	callq  3aa <open>
 282:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 285:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 289:	79 07                	jns    292 <stat+0x31>
    return -1;
 28b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 290:	eb 21                	jmp    2b3 <stat+0x52>
  r = fstat(fd, st);
 292:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 296:	8b 45 fc             	mov    -0x4(%rbp),%eax
 299:	48 89 d6             	mov    %rdx,%rsi
 29c:	89 c7                	mov    %eax,%edi
 29e:	e8 1f 01 00 00       	callq  3c2 <fstat>
 2a3:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 2a6:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2a9:	89 c7                	mov    %eax,%edi
 2ab:	e8 e2 00 00 00       	callq  392 <close>
  return r;
 2b0:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 2b3:	c9                   	leaveq 
 2b4:	c3                   	retq   

00000000000002b5 <atoi>:

int
atoi(const char *s)
{
 2b5:	55                   	push   %rbp
 2b6:	48 89 e5             	mov    %rsp,%rbp
 2b9:	48 83 ec 18          	sub    $0x18,%rsp
 2bd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 2c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2c8:	eb 28                	jmp    2f2 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 2ca:	8b 55 fc             	mov    -0x4(%rbp),%edx
 2cd:	89 d0                	mov    %edx,%eax
 2cf:	c1 e0 02             	shl    $0x2,%eax
 2d2:	01 d0                	add    %edx,%eax
 2d4:	01 c0                	add    %eax,%eax
 2d6:	89 c1                	mov    %eax,%ecx
 2d8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2dc:	48 8d 50 01          	lea    0x1(%rax),%rdx
 2e0:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 2e4:	0f b6 00             	movzbl (%rax),%eax
 2e7:	0f be c0             	movsbl %al,%eax
 2ea:	01 c8                	add    %ecx,%eax
 2ec:	83 e8 30             	sub    $0x30,%eax
 2ef:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2f2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2f6:	0f b6 00             	movzbl (%rax),%eax
 2f9:	3c 2f                	cmp    $0x2f,%al
 2fb:	7e 0b                	jle    308 <atoi+0x53>
 2fd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 301:	0f b6 00             	movzbl (%rax),%eax
 304:	3c 39                	cmp    $0x39,%al
 306:	7e c2                	jle    2ca <atoi+0x15>
  return n;
 308:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 30b:	c9                   	leaveq 
 30c:	c3                   	retq   

000000000000030d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 30d:	55                   	push   %rbp
 30e:	48 89 e5             	mov    %rsp,%rbp
 311:	48 83 ec 28          	sub    $0x28,%rsp
 315:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 319:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 31d:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 320:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 324:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 328:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 32c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 330:	eb 1d                	jmp    34f <memmove+0x42>
    *dst++ = *src++;
 332:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 336:	48 8d 42 01          	lea    0x1(%rdx),%rax
 33a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 33e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 342:	48 8d 48 01          	lea    0x1(%rax),%rcx
 346:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 34a:	0f b6 12             	movzbl (%rdx),%edx
 34d:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 34f:	8b 45 dc             	mov    -0x24(%rbp),%eax
 352:	8d 50 ff             	lea    -0x1(%rax),%edx
 355:	89 55 dc             	mov    %edx,-0x24(%rbp)
 358:	85 c0                	test   %eax,%eax
 35a:	7f d6                	jg     332 <memmove+0x25>
  return vdst;
 35c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 360:	c9                   	leaveq 
 361:	c3                   	retq   

0000000000000362 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 362:	b8 01 00 00 00       	mov    $0x1,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	retq   

000000000000036a <exit>:
SYSCALL(exit)
 36a:	b8 02 00 00 00       	mov    $0x2,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	retq   

0000000000000372 <wait>:
SYSCALL(wait)
 372:	b8 03 00 00 00       	mov    $0x3,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	retq   

000000000000037a <pipe>:
SYSCALL(pipe)
 37a:	b8 04 00 00 00       	mov    $0x4,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	retq   

0000000000000382 <read>:
SYSCALL(read)
 382:	b8 05 00 00 00       	mov    $0x5,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	retq   

000000000000038a <write>:
SYSCALL(write)
 38a:	b8 10 00 00 00       	mov    $0x10,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	retq   

0000000000000392 <close>:
SYSCALL(close)
 392:	b8 15 00 00 00       	mov    $0x15,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	retq   

000000000000039a <kill>:
SYSCALL(kill)
 39a:	b8 06 00 00 00       	mov    $0x6,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	retq   

00000000000003a2 <exec>:
SYSCALL(exec)
 3a2:	b8 07 00 00 00       	mov    $0x7,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	retq   

00000000000003aa <open>:
SYSCALL(open)
 3aa:	b8 0f 00 00 00       	mov    $0xf,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	retq   

00000000000003b2 <mknod>:
SYSCALL(mknod)
 3b2:	b8 11 00 00 00       	mov    $0x11,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	retq   

00000000000003ba <unlink>:
SYSCALL(unlink)
 3ba:	b8 12 00 00 00       	mov    $0x12,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	retq   

00000000000003c2 <fstat>:
SYSCALL(fstat)
 3c2:	b8 08 00 00 00       	mov    $0x8,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	retq   

00000000000003ca <link>:
SYSCALL(link)
 3ca:	b8 13 00 00 00       	mov    $0x13,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	retq   

00000000000003d2 <mkdir>:
SYSCALL(mkdir)
 3d2:	b8 14 00 00 00       	mov    $0x14,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	retq   

00000000000003da <chdir>:
SYSCALL(chdir)
 3da:	b8 09 00 00 00       	mov    $0x9,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	retq   

00000000000003e2 <dup>:
SYSCALL(dup)
 3e2:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	retq   

00000000000003ea <getpid>:
SYSCALL(getpid)
 3ea:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	retq   

00000000000003f2 <sbrk>:
SYSCALL(sbrk)
 3f2:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	retq   

00000000000003fa <sleep>:
SYSCALL(sleep)
 3fa:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	retq   

0000000000000402 <uptime>:
SYSCALL(uptime)
 402:	b8 0e 00 00 00       	mov    $0xe,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	retq   

000000000000040a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 40a:	55                   	push   %rbp
 40b:	48 89 e5             	mov    %rsp,%rbp
 40e:	48 83 ec 10          	sub    $0x10,%rsp
 412:	89 7d fc             	mov    %edi,-0x4(%rbp)
 415:	89 f0                	mov    %esi,%eax
 417:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 41a:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 41e:	8b 45 fc             	mov    -0x4(%rbp),%eax
 421:	ba 01 00 00 00       	mov    $0x1,%edx
 426:	48 89 ce             	mov    %rcx,%rsi
 429:	89 c7                	mov    %eax,%edi
 42b:	e8 5a ff ff ff       	callq  38a <write>
}
 430:	90                   	nop
 431:	c9                   	leaveq 
 432:	c3                   	retq   

0000000000000433 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 433:	55                   	push   %rbp
 434:	48 89 e5             	mov    %rsp,%rbp
 437:	48 83 ec 30          	sub    $0x30,%rsp
 43b:	89 7d dc             	mov    %edi,-0x24(%rbp)
 43e:	89 75 d8             	mov    %esi,-0x28(%rbp)
 441:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 444:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 447:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 44e:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 452:	74 17                	je     46b <printint+0x38>
 454:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 458:	79 11                	jns    46b <printint+0x38>
    neg = 1;
 45a:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 461:	8b 45 d8             	mov    -0x28(%rbp),%eax
 464:	f7 d8                	neg    %eax
 466:	89 45 f4             	mov    %eax,-0xc(%rbp)
 469:	eb 06                	jmp    471 <printint+0x3e>
  } else {
    x = xx;
 46b:	8b 45 d8             	mov    -0x28(%rbp),%eax
 46e:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 471:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 478:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 47b:	8b 45 f4             	mov    -0xc(%rbp),%eax
 47e:	ba 00 00 00 00       	mov    $0x0,%edx
 483:	f7 f1                	div    %ecx
 485:	89 d1                	mov    %edx,%ecx
 487:	8b 45 fc             	mov    -0x4(%rbp),%eax
 48a:	8d 50 01             	lea    0x1(%rax),%edx
 48d:	89 55 fc             	mov    %edx,-0x4(%rbp)
 490:	89 ca                	mov    %ecx,%edx
 492:	0f b6 92 40 0d 00 00 	movzbl 0xd40(%rdx),%edx
 499:	48 98                	cltq   
 49b:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 49f:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 4a2:	8b 45 f4             	mov    -0xc(%rbp),%eax
 4a5:	ba 00 00 00 00       	mov    $0x0,%edx
 4aa:	f7 f6                	div    %esi
 4ac:	89 45 f4             	mov    %eax,-0xc(%rbp)
 4af:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 4b3:	75 c3                	jne    478 <printint+0x45>
  if(neg)
 4b5:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 4b9:	74 2b                	je     4e6 <printint+0xb3>
    buf[i++] = '-';
 4bb:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4be:	8d 50 01             	lea    0x1(%rax),%edx
 4c1:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4c4:	48 98                	cltq   
 4c6:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 4cb:	eb 19                	jmp    4e6 <printint+0xb3>
    putc(fd, buf[i]);
 4cd:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4d0:	48 98                	cltq   
 4d2:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 4d7:	0f be d0             	movsbl %al,%edx
 4da:	8b 45 dc             	mov    -0x24(%rbp),%eax
 4dd:	89 d6                	mov    %edx,%esi
 4df:	89 c7                	mov    %eax,%edi
 4e1:	e8 24 ff ff ff       	callq  40a <putc>
  while(--i >= 0)
 4e6:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 4ea:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 4ee:	79 dd                	jns    4cd <printint+0x9a>
}
 4f0:	90                   	nop
 4f1:	c9                   	leaveq 
 4f2:	c3                   	retq   

00000000000004f3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f3:	55                   	push   %rbp
 4f4:	48 89 e5             	mov    %rsp,%rbp
 4f7:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 4fe:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 504:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 50b:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 512:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 519:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 520:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 527:	84 c0                	test   %al,%al
 529:	74 20                	je     54b <printf+0x58>
 52b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 52f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 533:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 537:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 53b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 53f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 543:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 547:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 54b:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 552:	00 00 00 
 555:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 55c:	00 00 00 
 55f:	48 8d 45 10          	lea    0x10(%rbp),%rax
 563:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 56a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 571:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 578:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 57f:	00 00 00 
  for(i = 0; fmt[i]; i++){
 582:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 589:	00 00 00 
 58c:	e9 a8 02 00 00       	jmpq   839 <printf+0x346>
    c = fmt[i] & 0xff;
 591:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 597:	48 63 d0             	movslq %eax,%rdx
 59a:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 5a1:	48 01 d0             	add    %rdx,%rax
 5a4:	0f b6 00             	movzbl (%rax),%eax
 5a7:	0f be c0             	movsbl %al,%eax
 5aa:	25 ff 00 00 00       	and    $0xff,%eax
 5af:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 5b5:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 5bc:	75 35                	jne    5f3 <printf+0x100>
      if(c == '%'){
 5be:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 5c5:	75 0f                	jne    5d6 <printf+0xe3>
        state = '%';
 5c7:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 5ce:	00 00 00 
 5d1:	e9 5c 02 00 00       	jmpq   832 <printf+0x33f>
      } else {
        putc(fd, c);
 5d6:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 5dc:	0f be d0             	movsbl %al,%edx
 5df:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 5e5:	89 d6                	mov    %edx,%esi
 5e7:	89 c7                	mov    %eax,%edi
 5e9:	e8 1c fe ff ff       	callq  40a <putc>
 5ee:	e9 3f 02 00 00       	jmpq   832 <printf+0x33f>
      }
    } else if(state == '%'){
 5f3:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 5fa:	0f 85 32 02 00 00    	jne    832 <printf+0x33f>
      if(c == 'd'){
 600:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 607:	75 5e                	jne    667 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 609:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 60f:	83 f8 2f             	cmp    $0x2f,%eax
 612:	77 23                	ja     637 <printf+0x144>
 614:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 61b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 621:	89 d2                	mov    %edx,%edx
 623:	48 01 d0             	add    %rdx,%rax
 626:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 62c:	83 c2 08             	add    $0x8,%edx
 62f:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 635:	eb 12                	jmp    649 <printf+0x156>
 637:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 63e:	48 8d 50 08          	lea    0x8(%rax),%rdx
 642:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 649:	8b 30                	mov    (%rax),%esi
 64b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 651:	b9 01 00 00 00       	mov    $0x1,%ecx
 656:	ba 0a 00 00 00       	mov    $0xa,%edx
 65b:	89 c7                	mov    %eax,%edi
 65d:	e8 d1 fd ff ff       	callq  433 <printint>
 662:	e9 c1 01 00 00       	jmpq   828 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 667:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 66e:	74 09                	je     679 <printf+0x186>
 670:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 677:	75 5e                	jne    6d7 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 679:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 67f:	83 f8 2f             	cmp    $0x2f,%eax
 682:	77 23                	ja     6a7 <printf+0x1b4>
 684:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 68b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 691:	89 d2                	mov    %edx,%edx
 693:	48 01 d0             	add    %rdx,%rax
 696:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 69c:	83 c2 08             	add    $0x8,%edx
 69f:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6a5:	eb 12                	jmp    6b9 <printf+0x1c6>
 6a7:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6ae:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6b2:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6b9:	8b 30                	mov    (%rax),%esi
 6bb:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6c1:	b9 00 00 00 00       	mov    $0x0,%ecx
 6c6:	ba 10 00 00 00       	mov    $0x10,%edx
 6cb:	89 c7                	mov    %eax,%edi
 6cd:	e8 61 fd ff ff       	callq  433 <printint>
 6d2:	e9 51 01 00 00       	jmpq   828 <printf+0x335>
      } else if(c == 's'){
 6d7:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 6de:	0f 85 98 00 00 00    	jne    77c <printf+0x289>
        s = va_arg(ap, char*);
 6e4:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6ea:	83 f8 2f             	cmp    $0x2f,%eax
 6ed:	77 23                	ja     712 <printf+0x21f>
 6ef:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6f6:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6fc:	89 d2                	mov    %edx,%edx
 6fe:	48 01 d0             	add    %rdx,%rax
 701:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 707:	83 c2 08             	add    $0x8,%edx
 70a:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 710:	eb 12                	jmp    724 <printf+0x231>
 712:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 719:	48 8d 50 08          	lea    0x8(%rax),%rdx
 71d:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 724:	48 8b 00             	mov    (%rax),%rax
 727:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 72e:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 735:	00 
 736:	75 31                	jne    769 <printf+0x276>
          s = "(null)";
 738:	48 c7 85 48 ff ff ff 	movq   $0xb00,-0xb8(%rbp)
 73f:	00 0b 00 00 
        while(*s != 0){
 743:	eb 24                	jmp    769 <printf+0x276>
          putc(fd, *s);
 745:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 74c:	0f b6 00             	movzbl (%rax),%eax
 74f:	0f be d0             	movsbl %al,%edx
 752:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 758:	89 d6                	mov    %edx,%esi
 75a:	89 c7                	mov    %eax,%edi
 75c:	e8 a9 fc ff ff       	callq  40a <putc>
          s++;
 761:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 768:	01 
        while(*s != 0){
 769:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 770:	0f b6 00             	movzbl (%rax),%eax
 773:	84 c0                	test   %al,%al
 775:	75 ce                	jne    745 <printf+0x252>
 777:	e9 ac 00 00 00       	jmpq   828 <printf+0x335>
        }
      } else if(c == 'c'){
 77c:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 783:	75 56                	jne    7db <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 785:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 78b:	83 f8 2f             	cmp    $0x2f,%eax
 78e:	77 23                	ja     7b3 <printf+0x2c0>
 790:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 797:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 79d:	89 d2                	mov    %edx,%edx
 79f:	48 01 d0             	add    %rdx,%rax
 7a2:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7a8:	83 c2 08             	add    $0x8,%edx
 7ab:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7b1:	eb 12                	jmp    7c5 <printf+0x2d2>
 7b3:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7ba:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7be:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7c5:	8b 00                	mov    (%rax),%eax
 7c7:	0f be d0             	movsbl %al,%edx
 7ca:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7d0:	89 d6                	mov    %edx,%esi
 7d2:	89 c7                	mov    %eax,%edi
 7d4:	e8 31 fc ff ff       	callq  40a <putc>
 7d9:	eb 4d                	jmp    828 <printf+0x335>
      } else if(c == '%'){
 7db:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 7e2:	75 1a                	jne    7fe <printf+0x30b>
        putc(fd, c);
 7e4:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7ea:	0f be d0             	movsbl %al,%edx
 7ed:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7f3:	89 d6                	mov    %edx,%esi
 7f5:	89 c7                	mov    %eax,%edi
 7f7:	e8 0e fc ff ff       	callq  40a <putc>
 7fc:	eb 2a                	jmp    828 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7fe:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 804:	be 25 00 00 00       	mov    $0x25,%esi
 809:	89 c7                	mov    %eax,%edi
 80b:	e8 fa fb ff ff       	callq  40a <putc>
        putc(fd, c);
 810:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 816:	0f be d0             	movsbl %al,%edx
 819:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 81f:	89 d6                	mov    %edx,%esi
 821:	89 c7                	mov    %eax,%edi
 823:	e8 e2 fb ff ff       	callq  40a <putc>
      }
      state = 0;
 828:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 82f:	00 00 00 
  for(i = 0; fmt[i]; i++){
 832:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 839:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 83f:	48 63 d0             	movslq %eax,%rdx
 842:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 849:	48 01 d0             	add    %rdx,%rax
 84c:	0f b6 00             	movzbl (%rax),%eax
 84f:	84 c0                	test   %al,%al
 851:	0f 85 3a fd ff ff    	jne    591 <printf+0x9e>
    }
  }
}
 857:	90                   	nop
 858:	c9                   	leaveq 
 859:	c3                   	retq   

000000000000085a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85a:	55                   	push   %rbp
 85b:	48 89 e5             	mov    %rsp,%rbp
 85e:	48 83 ec 18          	sub    $0x18,%rsp
 862:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 866:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 86a:	48 83 e8 10          	sub    $0x10,%rax
 86e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	48 8b 05 f7 04 00 00 	mov    0x4f7(%rip),%rax        # d70 <freep>
 879:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 87d:	eb 2f                	jmp    8ae <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 883:	48 8b 00             	mov    (%rax),%rax
 886:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 88a:	72 17                	jb     8a3 <free+0x49>
 88c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 890:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 894:	77 2f                	ja     8c5 <free+0x6b>
 896:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 89a:	48 8b 00             	mov    (%rax),%rax
 89d:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8a1:	72 22                	jb     8c5 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8a7:	48 8b 00             	mov    (%rax),%rax
 8aa:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 8ae:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8b2:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8b6:	76 c7                	jbe    87f <free+0x25>
 8b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8bc:	48 8b 00             	mov    (%rax),%rax
 8bf:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8c3:	73 ba                	jae    87f <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8c9:	8b 40 08             	mov    0x8(%rax),%eax
 8cc:	89 c0                	mov    %eax,%eax
 8ce:	48 c1 e0 04          	shl    $0x4,%rax
 8d2:	48 89 c2             	mov    %rax,%rdx
 8d5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8d9:	48 01 c2             	add    %rax,%rdx
 8dc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8e0:	48 8b 00             	mov    (%rax),%rax
 8e3:	48 39 c2             	cmp    %rax,%rdx
 8e6:	75 2d                	jne    915 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 8e8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8ec:	8b 50 08             	mov    0x8(%rax),%edx
 8ef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8f3:	48 8b 00             	mov    (%rax),%rax
 8f6:	8b 40 08             	mov    0x8(%rax),%eax
 8f9:	01 c2                	add    %eax,%edx
 8fb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8ff:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 902:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 906:	48 8b 00             	mov    (%rax),%rax
 909:	48 8b 10             	mov    (%rax),%rdx
 90c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 910:	48 89 10             	mov    %rdx,(%rax)
 913:	eb 0e                	jmp    923 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 915:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 919:	48 8b 10             	mov    (%rax),%rdx
 91c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 920:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 923:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 927:	8b 40 08             	mov    0x8(%rax),%eax
 92a:	89 c0                	mov    %eax,%eax
 92c:	48 c1 e0 04          	shl    $0x4,%rax
 930:	48 89 c2             	mov    %rax,%rdx
 933:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 937:	48 01 d0             	add    %rdx,%rax
 93a:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 93e:	75 27                	jne    967 <free+0x10d>
    p->s.size += bp->s.size;
 940:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 944:	8b 50 08             	mov    0x8(%rax),%edx
 947:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 94b:	8b 40 08             	mov    0x8(%rax),%eax
 94e:	01 c2                	add    %eax,%edx
 950:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 954:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 957:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 95b:	48 8b 10             	mov    (%rax),%rdx
 95e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 962:	48 89 10             	mov    %rdx,(%rax)
 965:	eb 0b                	jmp    972 <free+0x118>
  } else
    p->s.ptr = bp;
 967:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 96b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 96f:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 972:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 976:	48 89 05 f3 03 00 00 	mov    %rax,0x3f3(%rip)        # d70 <freep>
}
 97d:	90                   	nop
 97e:	c9                   	leaveq 
 97f:	c3                   	retq   

0000000000000980 <morecore>:

static Header*
morecore(uint nu)
{
 980:	55                   	push   %rbp
 981:	48 89 e5             	mov    %rsp,%rbp
 984:	48 83 ec 20          	sub    $0x20,%rsp
 988:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 98b:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 992:	77 07                	ja     99b <morecore+0x1b>
    nu = 4096;
 994:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 99b:	8b 45 ec             	mov    -0x14(%rbp),%eax
 99e:	c1 e0 04             	shl    $0x4,%eax
 9a1:	89 c7                	mov    %eax,%edi
 9a3:	e8 4a fa ff ff       	callq  3f2 <sbrk>
 9a8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 9ac:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 9b1:	75 07                	jne    9ba <morecore+0x3a>
    return 0;
 9b3:	b8 00 00 00 00       	mov    $0x0,%eax
 9b8:	eb 29                	jmp    9e3 <morecore+0x63>
  hp = (Header*)p;
 9ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9be:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 9c2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9c6:	8b 55 ec             	mov    -0x14(%rbp),%edx
 9c9:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 9cc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9d0:	48 83 c0 10          	add    $0x10,%rax
 9d4:	48 89 c7             	mov    %rax,%rdi
 9d7:	e8 7e fe ff ff       	callq  85a <free>
  return freep;
 9dc:	48 8b 05 8d 03 00 00 	mov    0x38d(%rip),%rax        # d70 <freep>
}
 9e3:	c9                   	leaveq 
 9e4:	c3                   	retq   

00000000000009e5 <malloc>:

void*
malloc(uint nbytes)
{
 9e5:	55                   	push   %rbp
 9e6:	48 89 e5             	mov    %rsp,%rbp
 9e9:	48 83 ec 30          	sub    $0x30,%rsp
 9ed:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f0:	8b 45 dc             	mov    -0x24(%rbp),%eax
 9f3:	48 83 c0 0f          	add    $0xf,%rax
 9f7:	48 c1 e8 04          	shr    $0x4,%rax
 9fb:	83 c0 01             	add    $0x1,%eax
 9fe:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 a01:	48 8b 05 68 03 00 00 	mov    0x368(%rip),%rax        # d70 <freep>
 a08:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a0c:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 a11:	75 2b                	jne    a3e <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 a13:	48 c7 45 f0 60 0d 00 	movq   $0xd60,-0x10(%rbp)
 a1a:	00 
 a1b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a1f:	48 89 05 4a 03 00 00 	mov    %rax,0x34a(%rip)        # d70 <freep>
 a26:	48 8b 05 43 03 00 00 	mov    0x343(%rip),%rax        # d70 <freep>
 a2d:	48 89 05 2c 03 00 00 	mov    %rax,0x32c(%rip)        # d60 <base>
    base.s.size = 0;
 a34:	c7 05 2a 03 00 00 00 	movl   $0x0,0x32a(%rip)        # d68 <base+0x8>
 a3b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a42:	48 8b 00             	mov    (%rax),%rax
 a45:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a49:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a4d:	8b 40 08             	mov    0x8(%rax),%eax
 a50:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a53:	77 5f                	ja     ab4 <malloc+0xcf>
      if(p->s.size == nunits)
 a55:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a59:	8b 40 08             	mov    0x8(%rax),%eax
 a5c:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a5f:	75 10                	jne    a71 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a61:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a65:	48 8b 10             	mov    (%rax),%rdx
 a68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a6c:	48 89 10             	mov    %rdx,(%rax)
 a6f:	eb 2e                	jmp    a9f <malloc+0xba>
      else {
        p->s.size -= nunits;
 a71:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a75:	8b 40 08             	mov    0x8(%rax),%eax
 a78:	2b 45 ec             	sub    -0x14(%rbp),%eax
 a7b:	89 c2                	mov    %eax,%edx
 a7d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a81:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 a84:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a88:	8b 40 08             	mov    0x8(%rax),%eax
 a8b:	89 c0                	mov    %eax,%eax
 a8d:	48 c1 e0 04          	shl    $0x4,%rax
 a91:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 a95:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a99:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a9c:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 a9f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 aa3:	48 89 05 c6 02 00 00 	mov    %rax,0x2c6(%rip)        # d70 <freep>
      return (void*)(p + 1);
 aaa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aae:	48 83 c0 10          	add    $0x10,%rax
 ab2:	eb 41                	jmp    af5 <malloc+0x110>
    }
    if(p == freep)
 ab4:	48 8b 05 b5 02 00 00 	mov    0x2b5(%rip),%rax        # d70 <freep>
 abb:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 abf:	75 1c                	jne    add <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 ac1:	8b 45 ec             	mov    -0x14(%rbp),%eax
 ac4:	89 c7                	mov    %eax,%edi
 ac6:	e8 b5 fe ff ff       	callq  980 <morecore>
 acb:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 acf:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 ad4:	75 07                	jne    add <malloc+0xf8>
        return 0;
 ad6:	b8 00 00 00 00       	mov    $0x0,%eax
 adb:	eb 18                	jmp    af5 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 add:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ae1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 ae5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ae9:	48 8b 00             	mov    (%rax),%rax
 aec:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 af0:	e9 54 ff ff ff       	jmpq   a49 <malloc+0x64>
  }
}
 af5:	c9                   	leaveq 
 af6:	c3                   	retq   
