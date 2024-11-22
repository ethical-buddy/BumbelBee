
fs/zombie:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
  if(fork() > 0)
   4:	e8 fe 02 00 00       	callq  307 <fork>
   9:	85 c0                	test   %eax,%eax
   b:	7e 0a                	jle    17 <main+0x17>
    sleep(5);  // Let child exit before parent.
   d:	bf 05 00 00 00       	mov    $0x5,%edi
  12:	e8 88 03 00 00       	callq  39f <sleep>
  exit();
  17:	e8 f3 02 00 00       	callq  30f <exit>

000000000000001c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  1c:	55                   	push   %rbp
  1d:	48 89 e5             	mov    %rsp,%rbp
  20:	48 83 ec 10          	sub    $0x10,%rsp
  24:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  28:	89 75 f4             	mov    %esi,-0xc(%rbp)
  2b:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  2e:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  32:	8b 55 f0             	mov    -0x10(%rbp),%edx
  35:	8b 45 f4             	mov    -0xc(%rbp),%eax
  38:	48 89 ce             	mov    %rcx,%rsi
  3b:	48 89 f7             	mov    %rsi,%rdi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%rdi)
  43:	89 ca                	mov    %ecx,%edx
  45:	48 89 fe             	mov    %rdi,%rsi
  48:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  4c:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4f:	90                   	nop
  50:	c9                   	leaveq 
  51:	c3                   	retq   

0000000000000052 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  52:	55                   	push   %rbp
  53:	48 89 e5             	mov    %rsp,%rbp
  56:	48 83 ec 20          	sub    $0x20,%rsp
  5a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  5e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  62:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  66:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  6a:	90                   	nop
  6b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  6f:	48 8d 42 01          	lea    0x1(%rdx),%rax
  73:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  77:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  7b:	48 8d 48 01          	lea    0x1(%rax),%rcx
  7f:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  83:	0f b6 12             	movzbl (%rdx),%edx
  86:	88 10                	mov    %dl,(%rax)
  88:	0f b6 00             	movzbl (%rax),%eax
  8b:	84 c0                	test   %al,%al
  8d:	75 dc                	jne    6b <strcpy+0x19>
    ;
  return os;
  8f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  93:	c9                   	leaveq 
  94:	c3                   	retq   

0000000000000095 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  95:	55                   	push   %rbp
  96:	48 89 e5             	mov    %rsp,%rbp
  99:	48 83 ec 10          	sub    $0x10,%rsp
  9d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  a1:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
  a5:	eb 0a                	jmp    b1 <strcmp+0x1c>
    p++, q++;
  a7:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  ac:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
  b1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  b5:	0f b6 00             	movzbl (%rax),%eax
  b8:	84 c0                	test   %al,%al
  ba:	74 12                	je     ce <strcmp+0x39>
  bc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  c0:	0f b6 10             	movzbl (%rax),%edx
  c3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  c7:	0f b6 00             	movzbl (%rax),%eax
  ca:	38 c2                	cmp    %al,%dl
  cc:	74 d9                	je     a7 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
  ce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  d2:	0f b6 00             	movzbl (%rax),%eax
  d5:	0f b6 d0             	movzbl %al,%edx
  d8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  dc:	0f b6 00             	movzbl (%rax),%eax
  df:	0f b6 c0             	movzbl %al,%eax
  e2:	29 c2                	sub    %eax,%edx
  e4:	89 d0                	mov    %edx,%eax
}
  e6:	c9                   	leaveq 
  e7:	c3                   	retq   

00000000000000e8 <strlen>:

uint
strlen(char *s)
{
  e8:	55                   	push   %rbp
  e9:	48 89 e5             	mov    %rsp,%rbp
  ec:	48 83 ec 18          	sub    $0x18,%rsp
  f0:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
  f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  fb:	eb 04                	jmp    101 <strlen+0x19>
  fd:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 101:	8b 45 fc             	mov    -0x4(%rbp),%eax
 104:	48 63 d0             	movslq %eax,%rdx
 107:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 10b:	48 01 d0             	add    %rdx,%rax
 10e:	0f b6 00             	movzbl (%rax),%eax
 111:	84 c0                	test   %al,%al
 113:	75 e8                	jne    fd <strlen+0x15>
    ;
  return n;
 115:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 118:	c9                   	leaveq 
 119:	c3                   	retq   

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	55                   	push   %rbp
 11b:	48 89 e5             	mov    %rsp,%rbp
 11e:	48 83 ec 10          	sub    $0x10,%rsp
 122:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 126:	89 75 f4             	mov    %esi,-0xc(%rbp)
 129:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 12c:	8b 55 f0             	mov    -0x10(%rbp),%edx
 12f:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 132:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 136:	89 ce                	mov    %ecx,%esi
 138:	48 89 c7             	mov    %rax,%rdi
 13b:	e8 dc fe ff ff       	callq  1c <stosb>
  return dst;
 140:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 144:	c9                   	leaveq 
 145:	c3                   	retq   

0000000000000146 <strchr>:

char*
strchr(const char *s, char c)
{
 146:	55                   	push   %rbp
 147:	48 89 e5             	mov    %rsp,%rbp
 14a:	48 83 ec 10          	sub    $0x10,%rsp
 14e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 152:	89 f0                	mov    %esi,%eax
 154:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 157:	eb 17                	jmp    170 <strchr+0x2a>
    if(*s == c)
 159:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 15d:	0f b6 00             	movzbl (%rax),%eax
 160:	38 45 f4             	cmp    %al,-0xc(%rbp)
 163:	75 06                	jne    16b <strchr+0x25>
      return (char*)s;
 165:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 169:	eb 15                	jmp    180 <strchr+0x3a>
  for(; *s; s++)
 16b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 170:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 174:	0f b6 00             	movzbl (%rax),%eax
 177:	84 c0                	test   %al,%al
 179:	75 de                	jne    159 <strchr+0x13>
  return 0;
 17b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 180:	c9                   	leaveq 
 181:	c3                   	retq   

0000000000000182 <gets>:

char*
gets(char *buf, int max)
{
 182:	55                   	push   %rbp
 183:	48 89 e5             	mov    %rsp,%rbp
 186:	48 83 ec 20          	sub    $0x20,%rsp
 18a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 18e:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 191:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 198:	eb 48                	jmp    1e2 <gets+0x60>
    cc = read(0, &c, 1);
 19a:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 19e:	ba 01 00 00 00       	mov    $0x1,%edx
 1a3:	48 89 c6             	mov    %rax,%rsi
 1a6:	bf 00 00 00 00       	mov    $0x0,%edi
 1ab:	e8 77 01 00 00       	callq  327 <read>
 1b0:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 1b3:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 1b7:	7e 36                	jle    1ef <gets+0x6d>
      break;
    buf[i++] = c;
 1b9:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1bc:	8d 50 01             	lea    0x1(%rax),%edx
 1bf:	89 55 fc             	mov    %edx,-0x4(%rbp)
 1c2:	48 63 d0             	movslq %eax,%rdx
 1c5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1c9:	48 01 c2             	add    %rax,%rdx
 1cc:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 1d0:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 1d2:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 1d6:	3c 0a                	cmp    $0xa,%al
 1d8:	74 16                	je     1f0 <gets+0x6e>
 1da:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 1de:	3c 0d                	cmp    $0xd,%al
 1e0:	74 0e                	je     1f0 <gets+0x6e>
  for(i=0; i+1 < max; ){
 1e2:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1e5:	83 c0 01             	add    $0x1,%eax
 1e8:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 1eb:	7f ad                	jg     19a <gets+0x18>
 1ed:	eb 01                	jmp    1f0 <gets+0x6e>
      break;
 1ef:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f0:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1f3:	48 63 d0             	movslq %eax,%rdx
 1f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1fa:	48 01 d0             	add    %rdx,%rax
 1fd:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 200:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 204:	c9                   	leaveq 
 205:	c3                   	retq   

0000000000000206 <stat>:

int
stat(char *n, struct stat *st)
{
 206:	55                   	push   %rbp
 207:	48 89 e5             	mov    %rsp,%rbp
 20a:	48 83 ec 20          	sub    $0x20,%rsp
 20e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 212:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 216:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 21a:	be 00 00 00 00       	mov    $0x0,%esi
 21f:	48 89 c7             	mov    %rax,%rdi
 222:	e8 28 01 00 00       	callq  34f <open>
 227:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 22a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 22e:	79 07                	jns    237 <stat+0x31>
    return -1;
 230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 235:	eb 21                	jmp    258 <stat+0x52>
  r = fstat(fd, st);
 237:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 23b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 23e:	48 89 d6             	mov    %rdx,%rsi
 241:	89 c7                	mov    %eax,%edi
 243:	e8 1f 01 00 00       	callq  367 <fstat>
 248:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 24b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 24e:	89 c7                	mov    %eax,%edi
 250:	e8 e2 00 00 00       	callq  337 <close>
  return r;
 255:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 258:	c9                   	leaveq 
 259:	c3                   	retq   

000000000000025a <atoi>:

int
atoi(const char *s)
{
 25a:	55                   	push   %rbp
 25b:	48 89 e5             	mov    %rsp,%rbp
 25e:	48 83 ec 18          	sub    $0x18,%rsp
 262:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 266:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 26d:	eb 28                	jmp    297 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 26f:	8b 55 fc             	mov    -0x4(%rbp),%edx
 272:	89 d0                	mov    %edx,%eax
 274:	c1 e0 02             	shl    $0x2,%eax
 277:	01 d0                	add    %edx,%eax
 279:	01 c0                	add    %eax,%eax
 27b:	89 c1                	mov    %eax,%ecx
 27d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 281:	48 8d 50 01          	lea    0x1(%rax),%rdx
 285:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 289:	0f b6 00             	movzbl (%rax),%eax
 28c:	0f be c0             	movsbl %al,%eax
 28f:	01 c8                	add    %ecx,%eax
 291:	83 e8 30             	sub    $0x30,%eax
 294:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 297:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 29b:	0f b6 00             	movzbl (%rax),%eax
 29e:	3c 2f                	cmp    $0x2f,%al
 2a0:	7e 0b                	jle    2ad <atoi+0x53>
 2a2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2a6:	0f b6 00             	movzbl (%rax),%eax
 2a9:	3c 39                	cmp    $0x39,%al
 2ab:	7e c2                	jle    26f <atoi+0x15>
  return n;
 2ad:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 2b0:	c9                   	leaveq 
 2b1:	c3                   	retq   

00000000000002b2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b2:	55                   	push   %rbp
 2b3:	48 89 e5             	mov    %rsp,%rbp
 2b6:	48 83 ec 28          	sub    $0x28,%rsp
 2ba:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 2be:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 2c2:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 2c5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2c9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 2cd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 2d1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 2d5:	eb 1d                	jmp    2f4 <memmove+0x42>
    *dst++ = *src++;
 2d7:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 2db:	48 8d 42 01          	lea    0x1(%rdx),%rax
 2df:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 2e3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2e7:	48 8d 48 01          	lea    0x1(%rax),%rcx
 2eb:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 2ef:	0f b6 12             	movzbl (%rdx),%edx
 2f2:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 2f4:	8b 45 dc             	mov    -0x24(%rbp),%eax
 2f7:	8d 50 ff             	lea    -0x1(%rax),%edx
 2fa:	89 55 dc             	mov    %edx,-0x24(%rbp)
 2fd:	85 c0                	test   %eax,%eax
 2ff:	7f d6                	jg     2d7 <memmove+0x25>
  return vdst;
 301:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 305:	c9                   	leaveq 
 306:	c3                   	retq   

0000000000000307 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 307:	b8 01 00 00 00       	mov    $0x1,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	retq   

000000000000030f <exit>:
SYSCALL(exit)
 30f:	b8 02 00 00 00       	mov    $0x2,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	retq   

0000000000000317 <wait>:
SYSCALL(wait)
 317:	b8 03 00 00 00       	mov    $0x3,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	retq   

000000000000031f <pipe>:
SYSCALL(pipe)
 31f:	b8 04 00 00 00       	mov    $0x4,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	retq   

0000000000000327 <read>:
SYSCALL(read)
 327:	b8 05 00 00 00       	mov    $0x5,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	retq   

000000000000032f <write>:
SYSCALL(write)
 32f:	b8 10 00 00 00       	mov    $0x10,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	retq   

0000000000000337 <close>:
SYSCALL(close)
 337:	b8 15 00 00 00       	mov    $0x15,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	retq   

000000000000033f <kill>:
SYSCALL(kill)
 33f:	b8 06 00 00 00       	mov    $0x6,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	retq   

0000000000000347 <exec>:
SYSCALL(exec)
 347:	b8 07 00 00 00       	mov    $0x7,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	retq   

000000000000034f <open>:
SYSCALL(open)
 34f:	b8 0f 00 00 00       	mov    $0xf,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	retq   

0000000000000357 <mknod>:
SYSCALL(mknod)
 357:	b8 11 00 00 00       	mov    $0x11,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	retq   

000000000000035f <unlink>:
SYSCALL(unlink)
 35f:	b8 12 00 00 00       	mov    $0x12,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	retq   

0000000000000367 <fstat>:
SYSCALL(fstat)
 367:	b8 08 00 00 00       	mov    $0x8,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	retq   

000000000000036f <link>:
SYSCALL(link)
 36f:	b8 13 00 00 00       	mov    $0x13,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	retq   

0000000000000377 <mkdir>:
SYSCALL(mkdir)
 377:	b8 14 00 00 00       	mov    $0x14,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	retq   

000000000000037f <chdir>:
SYSCALL(chdir)
 37f:	b8 09 00 00 00       	mov    $0x9,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	retq   

0000000000000387 <dup>:
SYSCALL(dup)
 387:	b8 0a 00 00 00       	mov    $0xa,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	retq   

000000000000038f <getpid>:
SYSCALL(getpid)
 38f:	b8 0b 00 00 00       	mov    $0xb,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	retq   

0000000000000397 <sbrk>:
SYSCALL(sbrk)
 397:	b8 0c 00 00 00       	mov    $0xc,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	retq   

000000000000039f <sleep>:
SYSCALL(sleep)
 39f:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	retq   

00000000000003a7 <uptime>:
SYSCALL(uptime)
 3a7:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	retq   

00000000000003af <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3af:	55                   	push   %rbp
 3b0:	48 89 e5             	mov    %rsp,%rbp
 3b3:	48 83 ec 10          	sub    $0x10,%rsp
 3b7:	89 7d fc             	mov    %edi,-0x4(%rbp)
 3ba:	89 f0                	mov    %esi,%eax
 3bc:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 3bf:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 3c3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 3c6:	ba 01 00 00 00       	mov    $0x1,%edx
 3cb:	48 89 ce             	mov    %rcx,%rsi
 3ce:	89 c7                	mov    %eax,%edi
 3d0:	e8 5a ff ff ff       	callq  32f <write>
}
 3d5:	90                   	nop
 3d6:	c9                   	leaveq 
 3d7:	c3                   	retq   

00000000000003d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d8:	55                   	push   %rbp
 3d9:	48 89 e5             	mov    %rsp,%rbp
 3dc:	48 83 ec 30          	sub    $0x30,%rsp
 3e0:	89 7d dc             	mov    %edi,-0x24(%rbp)
 3e3:	89 75 d8             	mov    %esi,-0x28(%rbp)
 3e6:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 3e9:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3ec:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 3f3:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 3f7:	74 17                	je     410 <printint+0x38>
 3f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 3fd:	79 11                	jns    410 <printint+0x38>
    neg = 1;
 3ff:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 406:	8b 45 d8             	mov    -0x28(%rbp),%eax
 409:	f7 d8                	neg    %eax
 40b:	89 45 f4             	mov    %eax,-0xc(%rbp)
 40e:	eb 06                	jmp    416 <printint+0x3e>
  } else {
    x = xx;
 410:	8b 45 d8             	mov    -0x28(%rbp),%eax
 413:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 416:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 41d:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 420:	8b 45 f4             	mov    -0xc(%rbp),%eax
 423:	ba 00 00 00 00       	mov    $0x0,%edx
 428:	f7 f1                	div    %ecx
 42a:	89 d1                	mov    %edx,%ecx
 42c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 42f:	8d 50 01             	lea    0x1(%rax),%edx
 432:	89 55 fc             	mov    %edx,-0x4(%rbp)
 435:	89 ca                	mov    %ecx,%edx
 437:	0f b6 92 e0 0c 00 00 	movzbl 0xce0(%rdx),%edx
 43e:	48 98                	cltq   
 440:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 444:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 447:	8b 45 f4             	mov    -0xc(%rbp),%eax
 44a:	ba 00 00 00 00       	mov    $0x0,%edx
 44f:	f7 f6                	div    %esi
 451:	89 45 f4             	mov    %eax,-0xc(%rbp)
 454:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 458:	75 c3                	jne    41d <printint+0x45>
  if(neg)
 45a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 45e:	74 2b                	je     48b <printint+0xb3>
    buf[i++] = '-';
 460:	8b 45 fc             	mov    -0x4(%rbp),%eax
 463:	8d 50 01             	lea    0x1(%rax),%edx
 466:	89 55 fc             	mov    %edx,-0x4(%rbp)
 469:	48 98                	cltq   
 46b:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 470:	eb 19                	jmp    48b <printint+0xb3>
    putc(fd, buf[i]);
 472:	8b 45 fc             	mov    -0x4(%rbp),%eax
 475:	48 98                	cltq   
 477:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 47c:	0f be d0             	movsbl %al,%edx
 47f:	8b 45 dc             	mov    -0x24(%rbp),%eax
 482:	89 d6                	mov    %edx,%esi
 484:	89 c7                	mov    %eax,%edi
 486:	e8 24 ff ff ff       	callq  3af <putc>
  while(--i >= 0)
 48b:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 48f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 493:	79 dd                	jns    472 <printint+0x9a>
}
 495:	90                   	nop
 496:	c9                   	leaveq 
 497:	c3                   	retq   

0000000000000498 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 498:	55                   	push   %rbp
 499:	48 89 e5             	mov    %rsp,%rbp
 49c:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 4a3:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 4a9:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 4b0:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 4b7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 4be:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 4c5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 4cc:	84 c0                	test   %al,%al
 4ce:	74 20                	je     4f0 <printf+0x58>
 4d0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 4d4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 4d8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 4dc:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 4e0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 4e4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 4e8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 4ec:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 4f0:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 4f7:	00 00 00 
 4fa:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 501:	00 00 00 
 504:	48 8d 45 10          	lea    0x10(%rbp),%rax
 508:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 50f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 516:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 51d:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 524:	00 00 00 
  for(i = 0; fmt[i]; i++){
 527:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 52e:	00 00 00 
 531:	e9 a8 02 00 00       	jmpq   7de <printf+0x346>
    c = fmt[i] & 0xff;
 536:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 53c:	48 63 d0             	movslq %eax,%rdx
 53f:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 546:	48 01 d0             	add    %rdx,%rax
 549:	0f b6 00             	movzbl (%rax),%eax
 54c:	0f be c0             	movsbl %al,%eax
 54f:	25 ff 00 00 00       	and    $0xff,%eax
 554:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 55a:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 561:	75 35                	jne    598 <printf+0x100>
      if(c == '%'){
 563:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 56a:	75 0f                	jne    57b <printf+0xe3>
        state = '%';
 56c:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 573:	00 00 00 
 576:	e9 5c 02 00 00       	jmpq   7d7 <printf+0x33f>
      } else {
        putc(fd, c);
 57b:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 581:	0f be d0             	movsbl %al,%edx
 584:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 58a:	89 d6                	mov    %edx,%esi
 58c:	89 c7                	mov    %eax,%edi
 58e:	e8 1c fe ff ff       	callq  3af <putc>
 593:	e9 3f 02 00 00       	jmpq   7d7 <printf+0x33f>
      }
    } else if(state == '%'){
 598:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 59f:	0f 85 32 02 00 00    	jne    7d7 <printf+0x33f>
      if(c == 'd'){
 5a5:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 5ac:	75 5e                	jne    60c <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 5ae:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 5b4:	83 f8 2f             	cmp    $0x2f,%eax
 5b7:	77 23                	ja     5dc <printf+0x144>
 5b9:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 5c0:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 5c6:	89 d2                	mov    %edx,%edx
 5c8:	48 01 d0             	add    %rdx,%rax
 5cb:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 5d1:	83 c2 08             	add    $0x8,%edx
 5d4:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 5da:	eb 12                	jmp    5ee <printf+0x156>
 5dc:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 5e3:	48 8d 50 08          	lea    0x8(%rax),%rdx
 5e7:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 5ee:	8b 30                	mov    (%rax),%esi
 5f0:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 5f6:	b9 01 00 00 00       	mov    $0x1,%ecx
 5fb:	ba 0a 00 00 00       	mov    $0xa,%edx
 600:	89 c7                	mov    %eax,%edi
 602:	e8 d1 fd ff ff       	callq  3d8 <printint>
 607:	e9 c1 01 00 00       	jmpq   7cd <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 60c:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 613:	74 09                	je     61e <printf+0x186>
 615:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 61c:	75 5e                	jne    67c <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 61e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 624:	83 f8 2f             	cmp    $0x2f,%eax
 627:	77 23                	ja     64c <printf+0x1b4>
 629:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 630:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 636:	89 d2                	mov    %edx,%edx
 638:	48 01 d0             	add    %rdx,%rax
 63b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 641:	83 c2 08             	add    $0x8,%edx
 644:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 64a:	eb 12                	jmp    65e <printf+0x1c6>
 64c:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 653:	48 8d 50 08          	lea    0x8(%rax),%rdx
 657:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 65e:	8b 30                	mov    (%rax),%esi
 660:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 666:	b9 00 00 00 00       	mov    $0x0,%ecx
 66b:	ba 10 00 00 00       	mov    $0x10,%edx
 670:	89 c7                	mov    %eax,%edi
 672:	e8 61 fd ff ff       	callq  3d8 <printint>
 677:	e9 51 01 00 00       	jmpq   7cd <printf+0x335>
      } else if(c == 's'){
 67c:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 683:	0f 85 98 00 00 00    	jne    721 <printf+0x289>
        s = va_arg(ap, char*);
 689:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 68f:	83 f8 2f             	cmp    $0x2f,%eax
 692:	77 23                	ja     6b7 <printf+0x21f>
 694:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 69b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6a1:	89 d2                	mov    %edx,%edx
 6a3:	48 01 d0             	add    %rdx,%rax
 6a6:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6ac:	83 c2 08             	add    $0x8,%edx
 6af:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6b5:	eb 12                	jmp    6c9 <printf+0x231>
 6b7:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6be:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6c2:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6c9:	48 8b 00             	mov    (%rax),%rax
 6cc:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 6d3:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 6da:	00 
 6db:	75 31                	jne    70e <printf+0x276>
          s = "(null)";
 6dd:	48 c7 85 48 ff ff ff 	movq   $0xa9c,-0xb8(%rbp)
 6e4:	9c 0a 00 00 
        while(*s != 0){
 6e8:	eb 24                	jmp    70e <printf+0x276>
          putc(fd, *s);
 6ea:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 6f1:	0f b6 00             	movzbl (%rax),%eax
 6f4:	0f be d0             	movsbl %al,%edx
 6f7:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6fd:	89 d6                	mov    %edx,%esi
 6ff:	89 c7                	mov    %eax,%edi
 701:	e8 a9 fc ff ff       	callq  3af <putc>
          s++;
 706:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 70d:	01 
        while(*s != 0){
 70e:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 715:	0f b6 00             	movzbl (%rax),%eax
 718:	84 c0                	test   %al,%al
 71a:	75 ce                	jne    6ea <printf+0x252>
 71c:	e9 ac 00 00 00       	jmpq   7cd <printf+0x335>
        }
      } else if(c == 'c'){
 721:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 728:	75 56                	jne    780 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 72a:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 730:	83 f8 2f             	cmp    $0x2f,%eax
 733:	77 23                	ja     758 <printf+0x2c0>
 735:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 73c:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 742:	89 d2                	mov    %edx,%edx
 744:	48 01 d0             	add    %rdx,%rax
 747:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 74d:	83 c2 08             	add    $0x8,%edx
 750:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 756:	eb 12                	jmp    76a <printf+0x2d2>
 758:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 75f:	48 8d 50 08          	lea    0x8(%rax),%rdx
 763:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 76a:	8b 00                	mov    (%rax),%eax
 76c:	0f be d0             	movsbl %al,%edx
 76f:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 775:	89 d6                	mov    %edx,%esi
 777:	89 c7                	mov    %eax,%edi
 779:	e8 31 fc ff ff       	callq  3af <putc>
 77e:	eb 4d                	jmp    7cd <printf+0x335>
      } else if(c == '%'){
 780:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 787:	75 1a                	jne    7a3 <printf+0x30b>
        putc(fd, c);
 789:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 78f:	0f be d0             	movsbl %al,%edx
 792:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 798:	89 d6                	mov    %edx,%esi
 79a:	89 c7                	mov    %eax,%edi
 79c:	e8 0e fc ff ff       	callq  3af <putc>
 7a1:	eb 2a                	jmp    7cd <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a3:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7a9:	be 25 00 00 00       	mov    $0x25,%esi
 7ae:	89 c7                	mov    %eax,%edi
 7b0:	e8 fa fb ff ff       	callq  3af <putc>
        putc(fd, c);
 7b5:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7bb:	0f be d0             	movsbl %al,%edx
 7be:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7c4:	89 d6                	mov    %edx,%esi
 7c6:	89 c7                	mov    %eax,%edi
 7c8:	e8 e2 fb ff ff       	callq  3af <putc>
      }
      state = 0;
 7cd:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 7d4:	00 00 00 
  for(i = 0; fmt[i]; i++){
 7d7:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 7de:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 7e4:	48 63 d0             	movslq %eax,%rdx
 7e7:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 7ee:	48 01 d0             	add    %rdx,%rax
 7f1:	0f b6 00             	movzbl (%rax),%eax
 7f4:	84 c0                	test   %al,%al
 7f6:	0f 85 3a fd ff ff    	jne    536 <printf+0x9e>
    }
  }
}
 7fc:	90                   	nop
 7fd:	c9                   	leaveq 
 7fe:	c3                   	retq   

00000000000007ff <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ff:	55                   	push   %rbp
 800:	48 89 e5             	mov    %rsp,%rbp
 803:	48 83 ec 18          	sub    $0x18,%rsp
 807:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 80f:	48 83 e8 10          	sub    $0x10,%rax
 813:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 817:	48 8b 05 f2 04 00 00 	mov    0x4f2(%rip),%rax        # d10 <freep>
 81e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 822:	eb 2f                	jmp    853 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 828:	48 8b 00             	mov    (%rax),%rax
 82b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 82f:	72 17                	jb     848 <free+0x49>
 831:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 835:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 839:	77 2f                	ja     86a <free+0x6b>
 83b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 83f:	48 8b 00             	mov    (%rax),%rax
 842:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 846:	72 22                	jb     86a <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 84c:	48 8b 00             	mov    (%rax),%rax
 84f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 853:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 857:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 85b:	76 c7                	jbe    824 <free+0x25>
 85d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 861:	48 8b 00             	mov    (%rax),%rax
 864:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 868:	73 ba                	jae    824 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 86e:	8b 40 08             	mov    0x8(%rax),%eax
 871:	89 c0                	mov    %eax,%eax
 873:	48 c1 e0 04          	shl    $0x4,%rax
 877:	48 89 c2             	mov    %rax,%rdx
 87a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 87e:	48 01 c2             	add    %rax,%rdx
 881:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 885:	48 8b 00             	mov    (%rax),%rax
 888:	48 39 c2             	cmp    %rax,%rdx
 88b:	75 2d                	jne    8ba <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 88d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 891:	8b 50 08             	mov    0x8(%rax),%edx
 894:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 898:	48 8b 00             	mov    (%rax),%rax
 89b:	8b 40 08             	mov    0x8(%rax),%eax
 89e:	01 c2                	add    %eax,%edx
 8a0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8a4:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8ab:	48 8b 00             	mov    (%rax),%rax
 8ae:	48 8b 10             	mov    (%rax),%rdx
 8b1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8b5:	48 89 10             	mov    %rdx,(%rax)
 8b8:	eb 0e                	jmp    8c8 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 8ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8be:	48 8b 10             	mov    (%rax),%rdx
 8c1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8c5:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 8c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8cc:	8b 40 08             	mov    0x8(%rax),%eax
 8cf:	89 c0                	mov    %eax,%eax
 8d1:	48 c1 e0 04          	shl    $0x4,%rax
 8d5:	48 89 c2             	mov    %rax,%rdx
 8d8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8dc:	48 01 d0             	add    %rdx,%rax
 8df:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8e3:	75 27                	jne    90c <free+0x10d>
    p->s.size += bp->s.size;
 8e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8e9:	8b 50 08             	mov    0x8(%rax),%edx
 8ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8f0:	8b 40 08             	mov    0x8(%rax),%eax
 8f3:	01 c2                	add    %eax,%edx
 8f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8f9:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 8fc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 900:	48 8b 10             	mov    (%rax),%rdx
 903:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 907:	48 89 10             	mov    %rdx,(%rax)
 90a:	eb 0b                	jmp    917 <free+0x118>
  } else
    p->s.ptr = bp;
 90c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 910:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 914:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 917:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 91b:	48 89 05 ee 03 00 00 	mov    %rax,0x3ee(%rip)        # d10 <freep>
}
 922:	90                   	nop
 923:	c9                   	leaveq 
 924:	c3                   	retq   

0000000000000925 <morecore>:

static Header*
morecore(uint nu)
{
 925:	55                   	push   %rbp
 926:	48 89 e5             	mov    %rsp,%rbp
 929:	48 83 ec 20          	sub    $0x20,%rsp
 92d:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 930:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 937:	77 07                	ja     940 <morecore+0x1b>
    nu = 4096;
 939:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 940:	8b 45 ec             	mov    -0x14(%rbp),%eax
 943:	c1 e0 04             	shl    $0x4,%eax
 946:	89 c7                	mov    %eax,%edi
 948:	e8 4a fa ff ff       	callq  397 <sbrk>
 94d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 951:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 956:	75 07                	jne    95f <morecore+0x3a>
    return 0;
 958:	b8 00 00 00 00       	mov    $0x0,%eax
 95d:	eb 29                	jmp    988 <morecore+0x63>
  hp = (Header*)p;
 95f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 963:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 967:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 96b:	8b 55 ec             	mov    -0x14(%rbp),%edx
 96e:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 971:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 975:	48 83 c0 10          	add    $0x10,%rax
 979:	48 89 c7             	mov    %rax,%rdi
 97c:	e8 7e fe ff ff       	callq  7ff <free>
  return freep;
 981:	48 8b 05 88 03 00 00 	mov    0x388(%rip),%rax        # d10 <freep>
}
 988:	c9                   	leaveq 
 989:	c3                   	retq   

000000000000098a <malloc>:

void*
malloc(uint nbytes)
{
 98a:	55                   	push   %rbp
 98b:	48 89 e5             	mov    %rsp,%rbp
 98e:	48 83 ec 30          	sub    $0x30,%rsp
 992:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 995:	8b 45 dc             	mov    -0x24(%rbp),%eax
 998:	48 83 c0 0f          	add    $0xf,%rax
 99c:	48 c1 e8 04          	shr    $0x4,%rax
 9a0:	83 c0 01             	add    $0x1,%eax
 9a3:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 9a6:	48 8b 05 63 03 00 00 	mov    0x363(%rip),%rax        # d10 <freep>
 9ad:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 9b1:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 9b6:	75 2b                	jne    9e3 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 9b8:	48 c7 45 f0 00 0d 00 	movq   $0xd00,-0x10(%rbp)
 9bf:	00 
 9c0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9c4:	48 89 05 45 03 00 00 	mov    %rax,0x345(%rip)        # d10 <freep>
 9cb:	48 8b 05 3e 03 00 00 	mov    0x33e(%rip),%rax        # d10 <freep>
 9d2:	48 89 05 27 03 00 00 	mov    %rax,0x327(%rip)        # d00 <base>
    base.s.size = 0;
 9d9:	c7 05 25 03 00 00 00 	movl   $0x0,0x325(%rip)        # d08 <base+0x8>
 9e0:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9e7:	48 8b 00             	mov    (%rax),%rax
 9ea:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 9ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9f2:	8b 40 08             	mov    0x8(%rax),%eax
 9f5:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 9f8:	77 5f                	ja     a59 <malloc+0xcf>
      if(p->s.size == nunits)
 9fa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9fe:	8b 40 08             	mov    0x8(%rax),%eax
 a01:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a04:	75 10                	jne    a16 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a06:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a0a:	48 8b 10             	mov    (%rax),%rdx
 a0d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a11:	48 89 10             	mov    %rdx,(%rax)
 a14:	eb 2e                	jmp    a44 <malloc+0xba>
      else {
        p->s.size -= nunits;
 a16:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a1a:	8b 40 08             	mov    0x8(%rax),%eax
 a1d:	2b 45 ec             	sub    -0x14(%rbp),%eax
 a20:	89 c2                	mov    %eax,%edx
 a22:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a26:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 a29:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a2d:	8b 40 08             	mov    0x8(%rax),%eax
 a30:	89 c0                	mov    %eax,%eax
 a32:	48 c1 e0 04          	shl    $0x4,%rax
 a36:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 a3a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a3e:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a41:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 a44:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a48:	48 89 05 c1 02 00 00 	mov    %rax,0x2c1(%rip)        # d10 <freep>
      return (void*)(p + 1);
 a4f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a53:	48 83 c0 10          	add    $0x10,%rax
 a57:	eb 41                	jmp    a9a <malloc+0x110>
    }
    if(p == freep)
 a59:	48 8b 05 b0 02 00 00 	mov    0x2b0(%rip),%rax        # d10 <freep>
 a60:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 a64:	75 1c                	jne    a82 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 a66:	8b 45 ec             	mov    -0x14(%rbp),%eax
 a69:	89 c7                	mov    %eax,%edi
 a6b:	e8 b5 fe ff ff       	callq  925 <morecore>
 a70:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 a74:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 a79:	75 07                	jne    a82 <malloc+0xf8>
        return 0;
 a7b:	b8 00 00 00 00       	mov    $0x0,%eax
 a80:	eb 18                	jmp    a9a <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a82:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a86:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a8a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a8e:	48 8b 00             	mov    (%rax),%rax
 a91:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a95:	e9 54 ff ff ff       	jmpq   9ee <malloc+0x64>
  }
}
 a9a:	c9                   	leaveq 
 a9b:	c3                   	retq   
