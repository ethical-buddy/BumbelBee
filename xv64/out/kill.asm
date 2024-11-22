
fs/kill:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 20          	sub    $0x20,%rsp
   8:	89 7d ec             	mov    %edi,-0x14(%rbp)
   b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int i;

  if(argc < 1){
   f:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  13:	7f 1b                	jg     30 <main+0x30>
    printf(2, "usage: kill pid...\n");
  15:	48 c7 c6 f0 0a 00 00 	mov    $0xaf0,%rsi
  1c:	bf 02 00 00 00       	mov    $0x2,%edi
  21:	b8 00 00 00 00       	mov    $0x0,%eax
  26:	e8 c1 04 00 00       	callq  4ec <printf>
    exit();
  2b:	e8 33 03 00 00       	callq  363 <exit>
  }
  for(i=1; i<argc; i++)
  30:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  37:	eb 2a                	jmp    63 <main+0x63>
    kill(atoi(argv[i]));
  39:	8b 45 fc             	mov    -0x4(%rbp),%eax
  3c:	48 98                	cltq   
  3e:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  45:	00 
  46:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4a:	48 01 d0             	add    %rdx,%rax
  4d:	48 8b 00             	mov    (%rax),%rax
  50:	48 89 c7             	mov    %rax,%rdi
  53:	e8 56 02 00 00       	callq  2ae <atoi>
  58:	89 c7                	mov    %eax,%edi
  5a:	e8 34 03 00 00       	callq  393 <kill>
  for(i=1; i<argc; i++)
  5f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  63:	8b 45 fc             	mov    -0x4(%rbp),%eax
  66:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  69:	7c ce                	jl     39 <main+0x39>
  exit();
  6b:	e8 f3 02 00 00       	callq  363 <exit>

0000000000000070 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  70:	55                   	push   %rbp
  71:	48 89 e5             	mov    %rsp,%rbp
  74:	48 83 ec 10          	sub    $0x10,%rsp
  78:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  7c:	89 75 f4             	mov    %esi,-0xc(%rbp)
  7f:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  82:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  86:	8b 55 f0             	mov    -0x10(%rbp),%edx
  89:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8c:	48 89 ce             	mov    %rcx,%rsi
  8f:	48 89 f7             	mov    %rsi,%rdi
  92:	89 d1                	mov    %edx,%ecx
  94:	fc                   	cld    
  95:	f3 aa                	rep stos %al,%es:(%rdi)
  97:	89 ca                	mov    %ecx,%edx
  99:	48 89 fe             	mov    %rdi,%rsi
  9c:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  a0:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  a3:	90                   	nop
  a4:	c9                   	leaveq 
  a5:	c3                   	retq   

00000000000000a6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  a6:	55                   	push   %rbp
  a7:	48 89 e5             	mov    %rsp,%rbp
  aa:	48 83 ec 20          	sub    $0x20,%rsp
  ae:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  b2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  b6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  ba:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  be:	90                   	nop
  bf:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  c3:	48 8d 42 01          	lea    0x1(%rdx),%rax
  c7:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  cb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  cf:	48 8d 48 01          	lea    0x1(%rax),%rcx
  d3:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  d7:	0f b6 12             	movzbl (%rdx),%edx
  da:	88 10                	mov    %dl,(%rax)
  dc:	0f b6 00             	movzbl (%rax),%eax
  df:	84 c0                	test   %al,%al
  e1:	75 dc                	jne    bf <strcpy+0x19>
    ;
  return os;
  e3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  e7:	c9                   	leaveq 
  e8:	c3                   	retq   

00000000000000e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e9:	55                   	push   %rbp
  ea:	48 89 e5             	mov    %rsp,%rbp
  ed:	48 83 ec 10          	sub    $0x10,%rsp
  f1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  f5:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
  f9:	eb 0a                	jmp    105 <strcmp+0x1c>
    p++, q++;
  fb:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 100:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 105:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 109:	0f b6 00             	movzbl (%rax),%eax
 10c:	84 c0                	test   %al,%al
 10e:	74 12                	je     122 <strcmp+0x39>
 110:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 114:	0f b6 10             	movzbl (%rax),%edx
 117:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 11b:	0f b6 00             	movzbl (%rax),%eax
 11e:	38 c2                	cmp    %al,%dl
 120:	74 d9                	je     fb <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 122:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 126:	0f b6 00             	movzbl (%rax),%eax
 129:	0f b6 d0             	movzbl %al,%edx
 12c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 130:	0f b6 00             	movzbl (%rax),%eax
 133:	0f b6 c0             	movzbl %al,%eax
 136:	29 c2                	sub    %eax,%edx
 138:	89 d0                	mov    %edx,%eax
}
 13a:	c9                   	leaveq 
 13b:	c3                   	retq   

000000000000013c <strlen>:

uint
strlen(char *s)
{
 13c:	55                   	push   %rbp
 13d:	48 89 e5             	mov    %rsp,%rbp
 140:	48 83 ec 18          	sub    $0x18,%rsp
 144:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 148:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 14f:	eb 04                	jmp    155 <strlen+0x19>
 151:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 155:	8b 45 fc             	mov    -0x4(%rbp),%eax
 158:	48 63 d0             	movslq %eax,%rdx
 15b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 15f:	48 01 d0             	add    %rdx,%rax
 162:	0f b6 00             	movzbl (%rax),%eax
 165:	84 c0                	test   %al,%al
 167:	75 e8                	jne    151 <strlen+0x15>
    ;
  return n;
 169:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 16c:	c9                   	leaveq 
 16d:	c3                   	retq   

000000000000016e <memset>:

void*
memset(void *dst, int c, uint n)
{
 16e:	55                   	push   %rbp
 16f:	48 89 e5             	mov    %rsp,%rbp
 172:	48 83 ec 10          	sub    $0x10,%rsp
 176:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 17a:	89 75 f4             	mov    %esi,-0xc(%rbp)
 17d:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 180:	8b 55 f0             	mov    -0x10(%rbp),%edx
 183:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 186:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 18a:	89 ce                	mov    %ecx,%esi
 18c:	48 89 c7             	mov    %rax,%rdi
 18f:	e8 dc fe ff ff       	callq  70 <stosb>
  return dst;
 194:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 198:	c9                   	leaveq 
 199:	c3                   	retq   

000000000000019a <strchr>:

char*
strchr(const char *s, char c)
{
 19a:	55                   	push   %rbp
 19b:	48 89 e5             	mov    %rsp,%rbp
 19e:	48 83 ec 10          	sub    $0x10,%rsp
 1a2:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1a6:	89 f0                	mov    %esi,%eax
 1a8:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 1ab:	eb 17                	jmp    1c4 <strchr+0x2a>
    if(*s == c)
 1ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1b1:	0f b6 00             	movzbl (%rax),%eax
 1b4:	38 45 f4             	cmp    %al,-0xc(%rbp)
 1b7:	75 06                	jne    1bf <strchr+0x25>
      return (char*)s;
 1b9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1bd:	eb 15                	jmp    1d4 <strchr+0x3a>
  for(; *s; s++)
 1bf:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 1c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1c8:	0f b6 00             	movzbl (%rax),%eax
 1cb:	84 c0                	test   %al,%al
 1cd:	75 de                	jne    1ad <strchr+0x13>
  return 0;
 1cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d4:	c9                   	leaveq 
 1d5:	c3                   	retq   

00000000000001d6 <gets>:

char*
gets(char *buf, int max)
{
 1d6:	55                   	push   %rbp
 1d7:	48 89 e5             	mov    %rsp,%rbp
 1da:	48 83 ec 20          	sub    $0x20,%rsp
 1de:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 1e2:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 1ec:	eb 48                	jmp    236 <gets+0x60>
    cc = read(0, &c, 1);
 1ee:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 1f2:	ba 01 00 00 00       	mov    $0x1,%edx
 1f7:	48 89 c6             	mov    %rax,%rsi
 1fa:	bf 00 00 00 00       	mov    $0x0,%edi
 1ff:	e8 77 01 00 00       	callq  37b <read>
 204:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 207:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 20b:	7e 36                	jle    243 <gets+0x6d>
      break;
    buf[i++] = c;
 20d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 210:	8d 50 01             	lea    0x1(%rax),%edx
 213:	89 55 fc             	mov    %edx,-0x4(%rbp)
 216:	48 63 d0             	movslq %eax,%rdx
 219:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 21d:	48 01 c2             	add    %rax,%rdx
 220:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 224:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 226:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 22a:	3c 0a                	cmp    $0xa,%al
 22c:	74 16                	je     244 <gets+0x6e>
 22e:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 232:	3c 0d                	cmp    $0xd,%al
 234:	74 0e                	je     244 <gets+0x6e>
  for(i=0; i+1 < max; ){
 236:	8b 45 fc             	mov    -0x4(%rbp),%eax
 239:	83 c0 01             	add    $0x1,%eax
 23c:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 23f:	7f ad                	jg     1ee <gets+0x18>
 241:	eb 01                	jmp    244 <gets+0x6e>
      break;
 243:	90                   	nop
      break;
  }
  buf[i] = '\0';
 244:	8b 45 fc             	mov    -0x4(%rbp),%eax
 247:	48 63 d0             	movslq %eax,%rdx
 24a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 24e:	48 01 d0             	add    %rdx,%rax
 251:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 254:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 258:	c9                   	leaveq 
 259:	c3                   	retq   

000000000000025a <stat>:

int
stat(char *n, struct stat *st)
{
 25a:	55                   	push   %rbp
 25b:	48 89 e5             	mov    %rsp,%rbp
 25e:	48 83 ec 20          	sub    $0x20,%rsp
 262:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 266:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 26a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 26e:	be 00 00 00 00       	mov    $0x0,%esi
 273:	48 89 c7             	mov    %rax,%rdi
 276:	e8 28 01 00 00       	callq  3a3 <open>
 27b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 27e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 282:	79 07                	jns    28b <stat+0x31>
    return -1;
 284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 289:	eb 21                	jmp    2ac <stat+0x52>
  r = fstat(fd, st);
 28b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 28f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 292:	48 89 d6             	mov    %rdx,%rsi
 295:	89 c7                	mov    %eax,%edi
 297:	e8 1f 01 00 00       	callq  3bb <fstat>
 29c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 29f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2a2:	89 c7                	mov    %eax,%edi
 2a4:	e8 e2 00 00 00       	callq  38b <close>
  return r;
 2a9:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 2ac:	c9                   	leaveq 
 2ad:	c3                   	retq   

00000000000002ae <atoi>:

int
atoi(const char *s)
{
 2ae:	55                   	push   %rbp
 2af:	48 89 e5             	mov    %rsp,%rbp
 2b2:	48 83 ec 18          	sub    $0x18,%rsp
 2b6:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 2ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2c1:	eb 28                	jmp    2eb <atoi+0x3d>
    n = n*10 + *s++ - '0';
 2c3:	8b 55 fc             	mov    -0x4(%rbp),%edx
 2c6:	89 d0                	mov    %edx,%eax
 2c8:	c1 e0 02             	shl    $0x2,%eax
 2cb:	01 d0                	add    %edx,%eax
 2cd:	01 c0                	add    %eax,%eax
 2cf:	89 c1                	mov    %eax,%ecx
 2d1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2d5:	48 8d 50 01          	lea    0x1(%rax),%rdx
 2d9:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 2dd:	0f b6 00             	movzbl (%rax),%eax
 2e0:	0f be c0             	movsbl %al,%eax
 2e3:	01 c8                	add    %ecx,%eax
 2e5:	83 e8 30             	sub    $0x30,%eax
 2e8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2eb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2ef:	0f b6 00             	movzbl (%rax),%eax
 2f2:	3c 2f                	cmp    $0x2f,%al
 2f4:	7e 0b                	jle    301 <atoi+0x53>
 2f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2fa:	0f b6 00             	movzbl (%rax),%eax
 2fd:	3c 39                	cmp    $0x39,%al
 2ff:	7e c2                	jle    2c3 <atoi+0x15>
  return n;
 301:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 304:	c9                   	leaveq 
 305:	c3                   	retq   

0000000000000306 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 306:	55                   	push   %rbp
 307:	48 89 e5             	mov    %rsp,%rbp
 30a:	48 83 ec 28          	sub    $0x28,%rsp
 30e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 312:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 316:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 319:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 31d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 321:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 325:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 329:	eb 1d                	jmp    348 <memmove+0x42>
    *dst++ = *src++;
 32b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 32f:	48 8d 42 01          	lea    0x1(%rdx),%rax
 333:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 337:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 33b:	48 8d 48 01          	lea    0x1(%rax),%rcx
 33f:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 343:	0f b6 12             	movzbl (%rdx),%edx
 346:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 348:	8b 45 dc             	mov    -0x24(%rbp),%eax
 34b:	8d 50 ff             	lea    -0x1(%rax),%edx
 34e:	89 55 dc             	mov    %edx,-0x24(%rbp)
 351:	85 c0                	test   %eax,%eax
 353:	7f d6                	jg     32b <memmove+0x25>
  return vdst;
 355:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 359:	c9                   	leaveq 
 35a:	c3                   	retq   

000000000000035b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 35b:	b8 01 00 00 00       	mov    $0x1,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	retq   

0000000000000363 <exit>:
SYSCALL(exit)
 363:	b8 02 00 00 00       	mov    $0x2,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	retq   

000000000000036b <wait>:
SYSCALL(wait)
 36b:	b8 03 00 00 00       	mov    $0x3,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	retq   

0000000000000373 <pipe>:
SYSCALL(pipe)
 373:	b8 04 00 00 00       	mov    $0x4,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	retq   

000000000000037b <read>:
SYSCALL(read)
 37b:	b8 05 00 00 00       	mov    $0x5,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	retq   

0000000000000383 <write>:
SYSCALL(write)
 383:	b8 10 00 00 00       	mov    $0x10,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	retq   

000000000000038b <close>:
SYSCALL(close)
 38b:	b8 15 00 00 00       	mov    $0x15,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	retq   

0000000000000393 <kill>:
SYSCALL(kill)
 393:	b8 06 00 00 00       	mov    $0x6,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	retq   

000000000000039b <exec>:
SYSCALL(exec)
 39b:	b8 07 00 00 00       	mov    $0x7,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	retq   

00000000000003a3 <open>:
SYSCALL(open)
 3a3:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	retq   

00000000000003ab <mknod>:
SYSCALL(mknod)
 3ab:	b8 11 00 00 00       	mov    $0x11,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	retq   

00000000000003b3 <unlink>:
SYSCALL(unlink)
 3b3:	b8 12 00 00 00       	mov    $0x12,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	retq   

00000000000003bb <fstat>:
SYSCALL(fstat)
 3bb:	b8 08 00 00 00       	mov    $0x8,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	retq   

00000000000003c3 <link>:
SYSCALL(link)
 3c3:	b8 13 00 00 00       	mov    $0x13,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	retq   

00000000000003cb <mkdir>:
SYSCALL(mkdir)
 3cb:	b8 14 00 00 00       	mov    $0x14,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	retq   

00000000000003d3 <chdir>:
SYSCALL(chdir)
 3d3:	b8 09 00 00 00       	mov    $0x9,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	retq   

00000000000003db <dup>:
SYSCALL(dup)
 3db:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	retq   

00000000000003e3 <getpid>:
SYSCALL(getpid)
 3e3:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	retq   

00000000000003eb <sbrk>:
SYSCALL(sbrk)
 3eb:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	retq   

00000000000003f3 <sleep>:
SYSCALL(sleep)
 3f3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	retq   

00000000000003fb <uptime>:
SYSCALL(uptime)
 3fb:	b8 0e 00 00 00       	mov    $0xe,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	retq   

0000000000000403 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 403:	55                   	push   %rbp
 404:	48 89 e5             	mov    %rsp,%rbp
 407:	48 83 ec 10          	sub    $0x10,%rsp
 40b:	89 7d fc             	mov    %edi,-0x4(%rbp)
 40e:	89 f0                	mov    %esi,%eax
 410:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 413:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 417:	8b 45 fc             	mov    -0x4(%rbp),%eax
 41a:	ba 01 00 00 00       	mov    $0x1,%edx
 41f:	48 89 ce             	mov    %rcx,%rsi
 422:	89 c7                	mov    %eax,%edi
 424:	e8 5a ff ff ff       	callq  383 <write>
}
 429:	90                   	nop
 42a:	c9                   	leaveq 
 42b:	c3                   	retq   

000000000000042c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42c:	55                   	push   %rbp
 42d:	48 89 e5             	mov    %rsp,%rbp
 430:	48 83 ec 30          	sub    $0x30,%rsp
 434:	89 7d dc             	mov    %edi,-0x24(%rbp)
 437:	89 75 d8             	mov    %esi,-0x28(%rbp)
 43a:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 43d:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 440:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 447:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 44b:	74 17                	je     464 <printint+0x38>
 44d:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 451:	79 11                	jns    464 <printint+0x38>
    neg = 1;
 453:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 45a:	8b 45 d8             	mov    -0x28(%rbp),%eax
 45d:	f7 d8                	neg    %eax
 45f:	89 45 f4             	mov    %eax,-0xc(%rbp)
 462:	eb 06                	jmp    46a <printint+0x3e>
  } else {
    x = xx;
 464:	8b 45 d8             	mov    -0x28(%rbp),%eax
 467:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 46a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 471:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 474:	8b 45 f4             	mov    -0xc(%rbp),%eax
 477:	ba 00 00 00 00       	mov    $0x0,%edx
 47c:	f7 f1                	div    %ecx
 47e:	89 d1                	mov    %edx,%ecx
 480:	8b 45 fc             	mov    -0x4(%rbp),%eax
 483:	8d 50 01             	lea    0x1(%rax),%edx
 486:	89 55 fc             	mov    %edx,-0x4(%rbp)
 489:	89 ca                	mov    %ecx,%edx
 48b:	0f b6 92 50 0d 00 00 	movzbl 0xd50(%rdx),%edx
 492:	48 98                	cltq   
 494:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 498:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 49b:	8b 45 f4             	mov    -0xc(%rbp),%eax
 49e:	ba 00 00 00 00       	mov    $0x0,%edx
 4a3:	f7 f6                	div    %esi
 4a5:	89 45 f4             	mov    %eax,-0xc(%rbp)
 4a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 4ac:	75 c3                	jne    471 <printint+0x45>
  if(neg)
 4ae:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 4b2:	74 2b                	je     4df <printint+0xb3>
    buf[i++] = '-';
 4b4:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4b7:	8d 50 01             	lea    0x1(%rax),%edx
 4ba:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4bd:	48 98                	cltq   
 4bf:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 4c4:	eb 19                	jmp    4df <printint+0xb3>
    putc(fd, buf[i]);
 4c6:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4c9:	48 98                	cltq   
 4cb:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 4d0:	0f be d0             	movsbl %al,%edx
 4d3:	8b 45 dc             	mov    -0x24(%rbp),%eax
 4d6:	89 d6                	mov    %edx,%esi
 4d8:	89 c7                	mov    %eax,%edi
 4da:	e8 24 ff ff ff       	callq  403 <putc>
  while(--i >= 0)
 4df:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 4e3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 4e7:	79 dd                	jns    4c6 <printint+0x9a>
}
 4e9:	90                   	nop
 4ea:	c9                   	leaveq 
 4eb:	c3                   	retq   

00000000000004ec <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ec:	55                   	push   %rbp
 4ed:	48 89 e5             	mov    %rsp,%rbp
 4f0:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 4f7:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 4fd:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 504:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 50b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 512:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 519:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 520:	84 c0                	test   %al,%al
 522:	74 20                	je     544 <printf+0x58>
 524:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 528:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 52c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 530:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 534:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 538:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 53c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 540:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 544:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 54b:	00 00 00 
 54e:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 555:	00 00 00 
 558:	48 8d 45 10          	lea    0x10(%rbp),%rax
 55c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 563:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 56a:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 571:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 578:	00 00 00 
  for(i = 0; fmt[i]; i++){
 57b:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 582:	00 00 00 
 585:	e9 a8 02 00 00       	jmpq   832 <printf+0x346>
    c = fmt[i] & 0xff;
 58a:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 590:	48 63 d0             	movslq %eax,%rdx
 593:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 59a:	48 01 d0             	add    %rdx,%rax
 59d:	0f b6 00             	movzbl (%rax),%eax
 5a0:	0f be c0             	movsbl %al,%eax
 5a3:	25 ff 00 00 00       	and    $0xff,%eax
 5a8:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 5ae:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 5b5:	75 35                	jne    5ec <printf+0x100>
      if(c == '%'){
 5b7:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 5be:	75 0f                	jne    5cf <printf+0xe3>
        state = '%';
 5c0:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 5c7:	00 00 00 
 5ca:	e9 5c 02 00 00       	jmpq   82b <printf+0x33f>
      } else {
        putc(fd, c);
 5cf:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 5d5:	0f be d0             	movsbl %al,%edx
 5d8:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 5de:	89 d6                	mov    %edx,%esi
 5e0:	89 c7                	mov    %eax,%edi
 5e2:	e8 1c fe ff ff       	callq  403 <putc>
 5e7:	e9 3f 02 00 00       	jmpq   82b <printf+0x33f>
      }
    } else if(state == '%'){
 5ec:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 5f3:	0f 85 32 02 00 00    	jne    82b <printf+0x33f>
      if(c == 'd'){
 5f9:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 600:	75 5e                	jne    660 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 602:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 608:	83 f8 2f             	cmp    $0x2f,%eax
 60b:	77 23                	ja     630 <printf+0x144>
 60d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 614:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 61a:	89 d2                	mov    %edx,%edx
 61c:	48 01 d0             	add    %rdx,%rax
 61f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 625:	83 c2 08             	add    $0x8,%edx
 628:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 62e:	eb 12                	jmp    642 <printf+0x156>
 630:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 637:	48 8d 50 08          	lea    0x8(%rax),%rdx
 63b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 642:	8b 30                	mov    (%rax),%esi
 644:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 64a:	b9 01 00 00 00       	mov    $0x1,%ecx
 64f:	ba 0a 00 00 00       	mov    $0xa,%edx
 654:	89 c7                	mov    %eax,%edi
 656:	e8 d1 fd ff ff       	callq  42c <printint>
 65b:	e9 c1 01 00 00       	jmpq   821 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 660:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 667:	74 09                	je     672 <printf+0x186>
 669:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 670:	75 5e                	jne    6d0 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 672:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 678:	83 f8 2f             	cmp    $0x2f,%eax
 67b:	77 23                	ja     6a0 <printf+0x1b4>
 67d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 684:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 68a:	89 d2                	mov    %edx,%edx
 68c:	48 01 d0             	add    %rdx,%rax
 68f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 695:	83 c2 08             	add    $0x8,%edx
 698:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 69e:	eb 12                	jmp    6b2 <printf+0x1c6>
 6a0:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6a7:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6ab:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6b2:	8b 30                	mov    (%rax),%esi
 6b4:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6ba:	b9 00 00 00 00       	mov    $0x0,%ecx
 6bf:	ba 10 00 00 00       	mov    $0x10,%edx
 6c4:	89 c7                	mov    %eax,%edi
 6c6:	e8 61 fd ff ff       	callq  42c <printint>
 6cb:	e9 51 01 00 00       	jmpq   821 <printf+0x335>
      } else if(c == 's'){
 6d0:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 6d7:	0f 85 98 00 00 00    	jne    775 <printf+0x289>
        s = va_arg(ap, char*);
 6dd:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6e3:	83 f8 2f             	cmp    $0x2f,%eax
 6e6:	77 23                	ja     70b <printf+0x21f>
 6e8:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6ef:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6f5:	89 d2                	mov    %edx,%edx
 6f7:	48 01 d0             	add    %rdx,%rax
 6fa:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 700:	83 c2 08             	add    $0x8,%edx
 703:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 709:	eb 12                	jmp    71d <printf+0x231>
 70b:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 712:	48 8d 50 08          	lea    0x8(%rax),%rdx
 716:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 71d:	48 8b 00             	mov    (%rax),%rax
 720:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 727:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 72e:	00 
 72f:	75 31                	jne    762 <printf+0x276>
          s = "(null)";
 731:	48 c7 85 48 ff ff ff 	movq   $0xb04,-0xb8(%rbp)
 738:	04 0b 00 00 
        while(*s != 0){
 73c:	eb 24                	jmp    762 <printf+0x276>
          putc(fd, *s);
 73e:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 745:	0f b6 00             	movzbl (%rax),%eax
 748:	0f be d0             	movsbl %al,%edx
 74b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 751:	89 d6                	mov    %edx,%esi
 753:	89 c7                	mov    %eax,%edi
 755:	e8 a9 fc ff ff       	callq  403 <putc>
          s++;
 75a:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 761:	01 
        while(*s != 0){
 762:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 769:	0f b6 00             	movzbl (%rax),%eax
 76c:	84 c0                	test   %al,%al
 76e:	75 ce                	jne    73e <printf+0x252>
 770:	e9 ac 00 00 00       	jmpq   821 <printf+0x335>
        }
      } else if(c == 'c'){
 775:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 77c:	75 56                	jne    7d4 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 77e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 784:	83 f8 2f             	cmp    $0x2f,%eax
 787:	77 23                	ja     7ac <printf+0x2c0>
 789:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 790:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 796:	89 d2                	mov    %edx,%edx
 798:	48 01 d0             	add    %rdx,%rax
 79b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7a1:	83 c2 08             	add    $0x8,%edx
 7a4:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7aa:	eb 12                	jmp    7be <printf+0x2d2>
 7ac:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7b3:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7b7:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7be:	8b 00                	mov    (%rax),%eax
 7c0:	0f be d0             	movsbl %al,%edx
 7c3:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7c9:	89 d6                	mov    %edx,%esi
 7cb:	89 c7                	mov    %eax,%edi
 7cd:	e8 31 fc ff ff       	callq  403 <putc>
 7d2:	eb 4d                	jmp    821 <printf+0x335>
      } else if(c == '%'){
 7d4:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 7db:	75 1a                	jne    7f7 <printf+0x30b>
        putc(fd, c);
 7dd:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7e3:	0f be d0             	movsbl %al,%edx
 7e6:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7ec:	89 d6                	mov    %edx,%esi
 7ee:	89 c7                	mov    %eax,%edi
 7f0:	e8 0e fc ff ff       	callq  403 <putc>
 7f5:	eb 2a                	jmp    821 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f7:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7fd:	be 25 00 00 00       	mov    $0x25,%esi
 802:	89 c7                	mov    %eax,%edi
 804:	e8 fa fb ff ff       	callq  403 <putc>
        putc(fd, c);
 809:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 80f:	0f be d0             	movsbl %al,%edx
 812:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 818:	89 d6                	mov    %edx,%esi
 81a:	89 c7                	mov    %eax,%edi
 81c:	e8 e2 fb ff ff       	callq  403 <putc>
      }
      state = 0;
 821:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 828:	00 00 00 
  for(i = 0; fmt[i]; i++){
 82b:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 832:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 838:	48 63 d0             	movslq %eax,%rdx
 83b:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 842:	48 01 d0             	add    %rdx,%rax
 845:	0f b6 00             	movzbl (%rax),%eax
 848:	84 c0                	test   %al,%al
 84a:	0f 85 3a fd ff ff    	jne    58a <printf+0x9e>
    }
  }
}
 850:	90                   	nop
 851:	c9                   	leaveq 
 852:	c3                   	retq   

0000000000000853 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 853:	55                   	push   %rbp
 854:	48 89 e5             	mov    %rsp,%rbp
 857:	48 83 ec 18          	sub    $0x18,%rsp
 85b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 863:	48 83 e8 10          	sub    $0x10,%rax
 867:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86b:	48 8b 05 0e 05 00 00 	mov    0x50e(%rip),%rax        # d80 <freep>
 872:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 876:	eb 2f                	jmp    8a7 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 878:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 87c:	48 8b 00             	mov    (%rax),%rax
 87f:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 883:	72 17                	jb     89c <free+0x49>
 885:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 889:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 88d:	77 2f                	ja     8be <free+0x6b>
 88f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 893:	48 8b 00             	mov    (%rax),%rax
 896:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 89a:	72 22                	jb     8be <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8a0:	48 8b 00             	mov    (%rax),%rax
 8a3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 8a7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8ab:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8af:	76 c7                	jbe    878 <free+0x25>
 8b1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8b5:	48 8b 00             	mov    (%rax),%rax
 8b8:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8bc:	73 ba                	jae    878 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8c2:	8b 40 08             	mov    0x8(%rax),%eax
 8c5:	89 c0                	mov    %eax,%eax
 8c7:	48 c1 e0 04          	shl    $0x4,%rax
 8cb:	48 89 c2             	mov    %rax,%rdx
 8ce:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8d2:	48 01 c2             	add    %rax,%rdx
 8d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8d9:	48 8b 00             	mov    (%rax),%rax
 8dc:	48 39 c2             	cmp    %rax,%rdx
 8df:	75 2d                	jne    90e <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 8e1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8e5:	8b 50 08             	mov    0x8(%rax),%edx
 8e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8ec:	48 8b 00             	mov    (%rax),%rax
 8ef:	8b 40 08             	mov    0x8(%rax),%eax
 8f2:	01 c2                	add    %eax,%edx
 8f4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8f8:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8ff:	48 8b 00             	mov    (%rax),%rax
 902:	48 8b 10             	mov    (%rax),%rdx
 905:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 909:	48 89 10             	mov    %rdx,(%rax)
 90c:	eb 0e                	jmp    91c <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 90e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 912:	48 8b 10             	mov    (%rax),%rdx
 915:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 919:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 91c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 920:	8b 40 08             	mov    0x8(%rax),%eax
 923:	89 c0                	mov    %eax,%eax
 925:	48 c1 e0 04          	shl    $0x4,%rax
 929:	48 89 c2             	mov    %rax,%rdx
 92c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 930:	48 01 d0             	add    %rdx,%rax
 933:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 937:	75 27                	jne    960 <free+0x10d>
    p->s.size += bp->s.size;
 939:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 93d:	8b 50 08             	mov    0x8(%rax),%edx
 940:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 944:	8b 40 08             	mov    0x8(%rax),%eax
 947:	01 c2                	add    %eax,%edx
 949:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 94d:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 950:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 954:	48 8b 10             	mov    (%rax),%rdx
 957:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 95b:	48 89 10             	mov    %rdx,(%rax)
 95e:	eb 0b                	jmp    96b <free+0x118>
  } else
    p->s.ptr = bp;
 960:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 964:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 968:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 96b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 96f:	48 89 05 0a 04 00 00 	mov    %rax,0x40a(%rip)        # d80 <freep>
}
 976:	90                   	nop
 977:	c9                   	leaveq 
 978:	c3                   	retq   

0000000000000979 <morecore>:

static Header*
morecore(uint nu)
{
 979:	55                   	push   %rbp
 97a:	48 89 e5             	mov    %rsp,%rbp
 97d:	48 83 ec 20          	sub    $0x20,%rsp
 981:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 984:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 98b:	77 07                	ja     994 <morecore+0x1b>
    nu = 4096;
 98d:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 994:	8b 45 ec             	mov    -0x14(%rbp),%eax
 997:	c1 e0 04             	shl    $0x4,%eax
 99a:	89 c7                	mov    %eax,%edi
 99c:	e8 4a fa ff ff       	callq  3eb <sbrk>
 9a1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 9a5:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 9aa:	75 07                	jne    9b3 <morecore+0x3a>
    return 0;
 9ac:	b8 00 00 00 00       	mov    $0x0,%eax
 9b1:	eb 29                	jmp    9dc <morecore+0x63>
  hp = (Header*)p;
 9b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9b7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 9bb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9bf:	8b 55 ec             	mov    -0x14(%rbp),%edx
 9c2:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 9c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9c9:	48 83 c0 10          	add    $0x10,%rax
 9cd:	48 89 c7             	mov    %rax,%rdi
 9d0:	e8 7e fe ff ff       	callq  853 <free>
  return freep;
 9d5:	48 8b 05 a4 03 00 00 	mov    0x3a4(%rip),%rax        # d80 <freep>
}
 9dc:	c9                   	leaveq 
 9dd:	c3                   	retq   

00000000000009de <malloc>:

void*
malloc(uint nbytes)
{
 9de:	55                   	push   %rbp
 9df:	48 89 e5             	mov    %rsp,%rbp
 9e2:	48 83 ec 30          	sub    $0x30,%rsp
 9e6:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e9:	8b 45 dc             	mov    -0x24(%rbp),%eax
 9ec:	48 83 c0 0f          	add    $0xf,%rax
 9f0:	48 c1 e8 04          	shr    $0x4,%rax
 9f4:	83 c0 01             	add    $0x1,%eax
 9f7:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 9fa:	48 8b 05 7f 03 00 00 	mov    0x37f(%rip),%rax        # d80 <freep>
 a01:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a05:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 a0a:	75 2b                	jne    a37 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 a0c:	48 c7 45 f0 70 0d 00 	movq   $0xd70,-0x10(%rbp)
 a13:	00 
 a14:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a18:	48 89 05 61 03 00 00 	mov    %rax,0x361(%rip)        # d80 <freep>
 a1f:	48 8b 05 5a 03 00 00 	mov    0x35a(%rip),%rax        # d80 <freep>
 a26:	48 89 05 43 03 00 00 	mov    %rax,0x343(%rip)        # d70 <base>
    base.s.size = 0;
 a2d:	c7 05 41 03 00 00 00 	movl   $0x0,0x341(%rip)        # d78 <base+0x8>
 a34:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a37:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a3b:	48 8b 00             	mov    (%rax),%rax
 a3e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a42:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a46:	8b 40 08             	mov    0x8(%rax),%eax
 a49:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a4c:	77 5f                	ja     aad <malloc+0xcf>
      if(p->s.size == nunits)
 a4e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a52:	8b 40 08             	mov    0x8(%rax),%eax
 a55:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a58:	75 10                	jne    a6a <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a5a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a5e:	48 8b 10             	mov    (%rax),%rdx
 a61:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a65:	48 89 10             	mov    %rdx,(%rax)
 a68:	eb 2e                	jmp    a98 <malloc+0xba>
      else {
        p->s.size -= nunits;
 a6a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a6e:	8b 40 08             	mov    0x8(%rax),%eax
 a71:	2b 45 ec             	sub    -0x14(%rbp),%eax
 a74:	89 c2                	mov    %eax,%edx
 a76:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a7a:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 a7d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a81:	8b 40 08             	mov    0x8(%rax),%eax
 a84:	89 c0                	mov    %eax,%eax
 a86:	48 c1 e0 04          	shl    $0x4,%rax
 a8a:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 a8e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a92:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a95:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 a98:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a9c:	48 89 05 dd 02 00 00 	mov    %rax,0x2dd(%rip)        # d80 <freep>
      return (void*)(p + 1);
 aa3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aa7:	48 83 c0 10          	add    $0x10,%rax
 aab:	eb 41                	jmp    aee <malloc+0x110>
    }
    if(p == freep)
 aad:	48 8b 05 cc 02 00 00 	mov    0x2cc(%rip),%rax        # d80 <freep>
 ab4:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 ab8:	75 1c                	jne    ad6 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 aba:	8b 45 ec             	mov    -0x14(%rbp),%eax
 abd:	89 c7                	mov    %eax,%edi
 abf:	e8 b5 fe ff ff       	callq  979 <morecore>
 ac4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 ac8:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 acd:	75 07                	jne    ad6 <malloc+0xf8>
        return 0;
 acf:	b8 00 00 00 00       	mov    $0x0,%eax
 ad4:	eb 18                	jmp    aee <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ada:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 ade:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ae2:	48 8b 00             	mov    (%rax),%rax
 ae5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 ae9:	e9 54 ff ff ff       	jmpq   a42 <malloc+0x64>
  }
}
 aee:	c9                   	leaveq 
 aef:	c3                   	retq   
