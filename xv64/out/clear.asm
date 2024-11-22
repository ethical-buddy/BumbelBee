
fs/clear:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"
#include "types.h"

int 
main(int argc, char** argv) {
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 10          	sub    $0x10,%rsp
   8:	89 7d fc             	mov    %edi,-0x4(%rbp)
   b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    // Use printf to output ANSI escape codes for clearing the screen
    printf(1, "\033[2J"); // Clear the screen
   f:	48 c7 c6 c0 0a 00 00 	mov    $0xac0,%rsi
  16:	bf 01 00 00 00       	mov    $0x1,%edi
  1b:	b8 00 00 00 00       	mov    $0x0,%eax
  20:	e8 97 04 00 00       	callq  4bc <printf>
    printf(1, "\033[H");  // Move the cursor to the top-left corner
  25:	48 c7 c6 c5 0a 00 00 	mov    $0xac5,%rsi
  2c:	bf 01 00 00 00       	mov    $0x1,%edi
  31:	b8 00 00 00 00       	mov    $0x0,%eax
  36:	e8 81 04 00 00       	callq  4bc <printf>
    exit();
  3b:	e8 f3 02 00 00       	callq  333 <exit>

0000000000000040 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  40:	55                   	push   %rbp
  41:	48 89 e5             	mov    %rsp,%rbp
  44:	48 83 ec 10          	sub    $0x10,%rsp
  48:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  4c:	89 75 f4             	mov    %esi,-0xc(%rbp)
  4f:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  52:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  56:	8b 55 f0             	mov    -0x10(%rbp),%edx
  59:	8b 45 f4             	mov    -0xc(%rbp),%eax
  5c:	48 89 ce             	mov    %rcx,%rsi
  5f:	48 89 f7             	mov    %rsi,%rdi
  62:	89 d1                	mov    %edx,%ecx
  64:	fc                   	cld    
  65:	f3 aa                	rep stos %al,%es:(%rdi)
  67:	89 ca                	mov    %ecx,%edx
  69:	48 89 fe             	mov    %rdi,%rsi
  6c:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  70:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  73:	90                   	nop
  74:	c9                   	leaveq 
  75:	c3                   	retq   

0000000000000076 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  76:	55                   	push   %rbp
  77:	48 89 e5             	mov    %rsp,%rbp
  7a:	48 83 ec 20          	sub    $0x20,%rsp
  7e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  82:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  86:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  8e:	90                   	nop
  8f:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  93:	48 8d 42 01          	lea    0x1(%rdx),%rax
  97:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  9b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  9f:	48 8d 48 01          	lea    0x1(%rax),%rcx
  a3:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  a7:	0f b6 12             	movzbl (%rdx),%edx
  aa:	88 10                	mov    %dl,(%rax)
  ac:	0f b6 00             	movzbl (%rax),%eax
  af:	84 c0                	test   %al,%al
  b1:	75 dc                	jne    8f <strcpy+0x19>
    ;
  return os;
  b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  b7:	c9                   	leaveq 
  b8:	c3                   	retq   

00000000000000b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b9:	55                   	push   %rbp
  ba:	48 89 e5             	mov    %rsp,%rbp
  bd:	48 83 ec 10          	sub    $0x10,%rsp
  c1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  c5:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
  c9:	eb 0a                	jmp    d5 <strcmp+0x1c>
    p++, q++;
  cb:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  d0:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
  d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  d9:	0f b6 00             	movzbl (%rax),%eax
  dc:	84 c0                	test   %al,%al
  de:	74 12                	je     f2 <strcmp+0x39>
  e0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  e4:	0f b6 10             	movzbl (%rax),%edx
  e7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  eb:	0f b6 00             	movzbl (%rax),%eax
  ee:	38 c2                	cmp    %al,%dl
  f0:	74 d9                	je     cb <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
  f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  f6:	0f b6 00             	movzbl (%rax),%eax
  f9:	0f b6 d0             	movzbl %al,%edx
  fc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 100:	0f b6 00             	movzbl (%rax),%eax
 103:	0f b6 c0             	movzbl %al,%eax
 106:	29 c2                	sub    %eax,%edx
 108:	89 d0                	mov    %edx,%eax
}
 10a:	c9                   	leaveq 
 10b:	c3                   	retq   

000000000000010c <strlen>:

uint
strlen(char *s)
{
 10c:	55                   	push   %rbp
 10d:	48 89 e5             	mov    %rsp,%rbp
 110:	48 83 ec 18          	sub    $0x18,%rsp
 114:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 118:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 11f:	eb 04                	jmp    125 <strlen+0x19>
 121:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 125:	8b 45 fc             	mov    -0x4(%rbp),%eax
 128:	48 63 d0             	movslq %eax,%rdx
 12b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 12f:	48 01 d0             	add    %rdx,%rax
 132:	0f b6 00             	movzbl (%rax),%eax
 135:	84 c0                	test   %al,%al
 137:	75 e8                	jne    121 <strlen+0x15>
    ;
  return n;
 139:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 13c:	c9                   	leaveq 
 13d:	c3                   	retq   

000000000000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	55                   	push   %rbp
 13f:	48 89 e5             	mov    %rsp,%rbp
 142:	48 83 ec 10          	sub    $0x10,%rsp
 146:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 14a:	89 75 f4             	mov    %esi,-0xc(%rbp)
 14d:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 150:	8b 55 f0             	mov    -0x10(%rbp),%edx
 153:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 156:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 15a:	89 ce                	mov    %ecx,%esi
 15c:	48 89 c7             	mov    %rax,%rdi
 15f:	e8 dc fe ff ff       	callq  40 <stosb>
  return dst;
 164:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 168:	c9                   	leaveq 
 169:	c3                   	retq   

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	55                   	push   %rbp
 16b:	48 89 e5             	mov    %rsp,%rbp
 16e:	48 83 ec 10          	sub    $0x10,%rsp
 172:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 176:	89 f0                	mov    %esi,%eax
 178:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 17b:	eb 17                	jmp    194 <strchr+0x2a>
    if(*s == c)
 17d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 181:	0f b6 00             	movzbl (%rax),%eax
 184:	38 45 f4             	cmp    %al,-0xc(%rbp)
 187:	75 06                	jne    18f <strchr+0x25>
      return (char*)s;
 189:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 18d:	eb 15                	jmp    1a4 <strchr+0x3a>
  for(; *s; s++)
 18f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 194:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 198:	0f b6 00             	movzbl (%rax),%eax
 19b:	84 c0                	test   %al,%al
 19d:	75 de                	jne    17d <strchr+0x13>
  return 0;
 19f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a4:	c9                   	leaveq 
 1a5:	c3                   	retq   

00000000000001a6 <gets>:

char*
gets(char *buf, int max)
{
 1a6:	55                   	push   %rbp
 1a7:	48 89 e5             	mov    %rsp,%rbp
 1aa:	48 83 ec 20          	sub    $0x20,%rsp
 1ae:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 1b2:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 1bc:	eb 48                	jmp    206 <gets+0x60>
    cc = read(0, &c, 1);
 1be:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 1c2:	ba 01 00 00 00       	mov    $0x1,%edx
 1c7:	48 89 c6             	mov    %rax,%rsi
 1ca:	bf 00 00 00 00       	mov    $0x0,%edi
 1cf:	e8 77 01 00 00       	callq  34b <read>
 1d4:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 1d7:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 1db:	7e 36                	jle    213 <gets+0x6d>
      break;
    buf[i++] = c;
 1dd:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1e0:	8d 50 01             	lea    0x1(%rax),%edx
 1e3:	89 55 fc             	mov    %edx,-0x4(%rbp)
 1e6:	48 63 d0             	movslq %eax,%rdx
 1e9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1ed:	48 01 c2             	add    %rax,%rdx
 1f0:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 1f4:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 1f6:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 1fa:	3c 0a                	cmp    $0xa,%al
 1fc:	74 16                	je     214 <gets+0x6e>
 1fe:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 202:	3c 0d                	cmp    $0xd,%al
 204:	74 0e                	je     214 <gets+0x6e>
  for(i=0; i+1 < max; ){
 206:	8b 45 fc             	mov    -0x4(%rbp),%eax
 209:	83 c0 01             	add    $0x1,%eax
 20c:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 20f:	7f ad                	jg     1be <gets+0x18>
 211:	eb 01                	jmp    214 <gets+0x6e>
      break;
 213:	90                   	nop
      break;
  }
  buf[i] = '\0';
 214:	8b 45 fc             	mov    -0x4(%rbp),%eax
 217:	48 63 d0             	movslq %eax,%rdx
 21a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 21e:	48 01 d0             	add    %rdx,%rax
 221:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 224:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 228:	c9                   	leaveq 
 229:	c3                   	retq   

000000000000022a <stat>:

int
stat(char *n, struct stat *st)
{
 22a:	55                   	push   %rbp
 22b:	48 89 e5             	mov    %rsp,%rbp
 22e:	48 83 ec 20          	sub    $0x20,%rsp
 232:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 236:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 23e:	be 00 00 00 00       	mov    $0x0,%esi
 243:	48 89 c7             	mov    %rax,%rdi
 246:	e8 28 01 00 00       	callq  373 <open>
 24b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 24e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 252:	79 07                	jns    25b <stat+0x31>
    return -1;
 254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 259:	eb 21                	jmp    27c <stat+0x52>
  r = fstat(fd, st);
 25b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 25f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 262:	48 89 d6             	mov    %rdx,%rsi
 265:	89 c7                	mov    %eax,%edi
 267:	e8 1f 01 00 00       	callq  38b <fstat>
 26c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 26f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 272:	89 c7                	mov    %eax,%edi
 274:	e8 e2 00 00 00       	callq  35b <close>
  return r;
 279:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 27c:	c9                   	leaveq 
 27d:	c3                   	retq   

000000000000027e <atoi>:

int
atoi(const char *s)
{
 27e:	55                   	push   %rbp
 27f:	48 89 e5             	mov    %rsp,%rbp
 282:	48 83 ec 18          	sub    $0x18,%rsp
 286:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 28a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 291:	eb 28                	jmp    2bb <atoi+0x3d>
    n = n*10 + *s++ - '0';
 293:	8b 55 fc             	mov    -0x4(%rbp),%edx
 296:	89 d0                	mov    %edx,%eax
 298:	c1 e0 02             	shl    $0x2,%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	01 c0                	add    %eax,%eax
 29f:	89 c1                	mov    %eax,%ecx
 2a1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2a5:	48 8d 50 01          	lea    0x1(%rax),%rdx
 2a9:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 2ad:	0f b6 00             	movzbl (%rax),%eax
 2b0:	0f be c0             	movsbl %al,%eax
 2b3:	01 c8                	add    %ecx,%eax
 2b5:	83 e8 30             	sub    $0x30,%eax
 2b8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2bb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2bf:	0f b6 00             	movzbl (%rax),%eax
 2c2:	3c 2f                	cmp    $0x2f,%al
 2c4:	7e 0b                	jle    2d1 <atoi+0x53>
 2c6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2ca:	0f b6 00             	movzbl (%rax),%eax
 2cd:	3c 39                	cmp    $0x39,%al
 2cf:	7e c2                	jle    293 <atoi+0x15>
  return n;
 2d1:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 2d4:	c9                   	leaveq 
 2d5:	c3                   	retq   

00000000000002d6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2d6:	55                   	push   %rbp
 2d7:	48 89 e5             	mov    %rsp,%rbp
 2da:	48 83 ec 28          	sub    $0x28,%rsp
 2de:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 2e2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 2e6:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 2e9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2ed:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 2f1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 2f5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 2f9:	eb 1d                	jmp    318 <memmove+0x42>
    *dst++ = *src++;
 2fb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 2ff:	48 8d 42 01          	lea    0x1(%rdx),%rax
 303:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 307:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 30b:	48 8d 48 01          	lea    0x1(%rax),%rcx
 30f:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 313:	0f b6 12             	movzbl (%rdx),%edx
 316:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 318:	8b 45 dc             	mov    -0x24(%rbp),%eax
 31b:	8d 50 ff             	lea    -0x1(%rax),%edx
 31e:	89 55 dc             	mov    %edx,-0x24(%rbp)
 321:	85 c0                	test   %eax,%eax
 323:	7f d6                	jg     2fb <memmove+0x25>
  return vdst;
 325:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 329:	c9                   	leaveq 
 32a:	c3                   	retq   

000000000000032b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 32b:	b8 01 00 00 00       	mov    $0x1,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	retq   

0000000000000333 <exit>:
SYSCALL(exit)
 333:	b8 02 00 00 00       	mov    $0x2,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	retq   

000000000000033b <wait>:
SYSCALL(wait)
 33b:	b8 03 00 00 00       	mov    $0x3,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	retq   

0000000000000343 <pipe>:
SYSCALL(pipe)
 343:	b8 04 00 00 00       	mov    $0x4,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	retq   

000000000000034b <read>:
SYSCALL(read)
 34b:	b8 05 00 00 00       	mov    $0x5,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	retq   

0000000000000353 <write>:
SYSCALL(write)
 353:	b8 10 00 00 00       	mov    $0x10,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	retq   

000000000000035b <close>:
SYSCALL(close)
 35b:	b8 15 00 00 00       	mov    $0x15,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	retq   

0000000000000363 <kill>:
SYSCALL(kill)
 363:	b8 06 00 00 00       	mov    $0x6,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	retq   

000000000000036b <exec>:
SYSCALL(exec)
 36b:	b8 07 00 00 00       	mov    $0x7,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	retq   

0000000000000373 <open>:
SYSCALL(open)
 373:	b8 0f 00 00 00       	mov    $0xf,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	retq   

000000000000037b <mknod>:
SYSCALL(mknod)
 37b:	b8 11 00 00 00       	mov    $0x11,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	retq   

0000000000000383 <unlink>:
SYSCALL(unlink)
 383:	b8 12 00 00 00       	mov    $0x12,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	retq   

000000000000038b <fstat>:
SYSCALL(fstat)
 38b:	b8 08 00 00 00       	mov    $0x8,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	retq   

0000000000000393 <link>:
SYSCALL(link)
 393:	b8 13 00 00 00       	mov    $0x13,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	retq   

000000000000039b <mkdir>:
SYSCALL(mkdir)
 39b:	b8 14 00 00 00       	mov    $0x14,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	retq   

00000000000003a3 <chdir>:
SYSCALL(chdir)
 3a3:	b8 09 00 00 00       	mov    $0x9,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	retq   

00000000000003ab <dup>:
SYSCALL(dup)
 3ab:	b8 0a 00 00 00       	mov    $0xa,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	retq   

00000000000003b3 <getpid>:
SYSCALL(getpid)
 3b3:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	retq   

00000000000003bb <sbrk>:
SYSCALL(sbrk)
 3bb:	b8 0c 00 00 00       	mov    $0xc,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	retq   

00000000000003c3 <sleep>:
SYSCALL(sleep)
 3c3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	retq   

00000000000003cb <uptime>:
SYSCALL(uptime)
 3cb:	b8 0e 00 00 00       	mov    $0xe,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	retq   

00000000000003d3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3d3:	55                   	push   %rbp
 3d4:	48 89 e5             	mov    %rsp,%rbp
 3d7:	48 83 ec 10          	sub    $0x10,%rsp
 3db:	89 7d fc             	mov    %edi,-0x4(%rbp)
 3de:	89 f0                	mov    %esi,%eax
 3e0:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 3e3:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 3e7:	8b 45 fc             	mov    -0x4(%rbp),%eax
 3ea:	ba 01 00 00 00       	mov    $0x1,%edx
 3ef:	48 89 ce             	mov    %rcx,%rsi
 3f2:	89 c7                	mov    %eax,%edi
 3f4:	e8 5a ff ff ff       	callq  353 <write>
}
 3f9:	90                   	nop
 3fa:	c9                   	leaveq 
 3fb:	c3                   	retq   

00000000000003fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fc:	55                   	push   %rbp
 3fd:	48 89 e5             	mov    %rsp,%rbp
 400:	48 83 ec 30          	sub    $0x30,%rsp
 404:	89 7d dc             	mov    %edi,-0x24(%rbp)
 407:	89 75 d8             	mov    %esi,-0x28(%rbp)
 40a:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 40d:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 410:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 417:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 41b:	74 17                	je     434 <printint+0x38>
 41d:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 421:	79 11                	jns    434 <printint+0x38>
    neg = 1;
 423:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 42a:	8b 45 d8             	mov    -0x28(%rbp),%eax
 42d:	f7 d8                	neg    %eax
 42f:	89 45 f4             	mov    %eax,-0xc(%rbp)
 432:	eb 06                	jmp    43a <printint+0x3e>
  } else {
    x = xx;
 434:	8b 45 d8             	mov    -0x28(%rbp),%eax
 437:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 43a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 441:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 444:	8b 45 f4             	mov    -0xc(%rbp),%eax
 447:	ba 00 00 00 00       	mov    $0x0,%edx
 44c:	f7 f1                	div    %ecx
 44e:	89 d1                	mov    %edx,%ecx
 450:	8b 45 fc             	mov    -0x4(%rbp),%eax
 453:	8d 50 01             	lea    0x1(%rax),%edx
 456:	89 55 fc             	mov    %edx,-0x4(%rbp)
 459:	89 ca                	mov    %ecx,%edx
 45b:	0f b6 92 10 0d 00 00 	movzbl 0xd10(%rdx),%edx
 462:	48 98                	cltq   
 464:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 468:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 46b:	8b 45 f4             	mov    -0xc(%rbp),%eax
 46e:	ba 00 00 00 00       	mov    $0x0,%edx
 473:	f7 f6                	div    %esi
 475:	89 45 f4             	mov    %eax,-0xc(%rbp)
 478:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 47c:	75 c3                	jne    441 <printint+0x45>
  if(neg)
 47e:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 482:	74 2b                	je     4af <printint+0xb3>
    buf[i++] = '-';
 484:	8b 45 fc             	mov    -0x4(%rbp),%eax
 487:	8d 50 01             	lea    0x1(%rax),%edx
 48a:	89 55 fc             	mov    %edx,-0x4(%rbp)
 48d:	48 98                	cltq   
 48f:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 494:	eb 19                	jmp    4af <printint+0xb3>
    putc(fd, buf[i]);
 496:	8b 45 fc             	mov    -0x4(%rbp),%eax
 499:	48 98                	cltq   
 49b:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 4a0:	0f be d0             	movsbl %al,%edx
 4a3:	8b 45 dc             	mov    -0x24(%rbp),%eax
 4a6:	89 d6                	mov    %edx,%esi
 4a8:	89 c7                	mov    %eax,%edi
 4aa:	e8 24 ff ff ff       	callq  3d3 <putc>
  while(--i >= 0)
 4af:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 4b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 4b7:	79 dd                	jns    496 <printint+0x9a>
}
 4b9:	90                   	nop
 4ba:	c9                   	leaveq 
 4bb:	c3                   	retq   

00000000000004bc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4bc:	55                   	push   %rbp
 4bd:	48 89 e5             	mov    %rsp,%rbp
 4c0:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 4c7:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 4cd:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 4d4:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 4db:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 4e2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 4e9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 4f0:	84 c0                	test   %al,%al
 4f2:	74 20                	je     514 <printf+0x58>
 4f4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 4f8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 4fc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 500:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 504:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 508:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 50c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 510:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 514:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 51b:	00 00 00 
 51e:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 525:	00 00 00 
 528:	48 8d 45 10          	lea    0x10(%rbp),%rax
 52c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 533:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 53a:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 541:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 548:	00 00 00 
  for(i = 0; fmt[i]; i++){
 54b:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 552:	00 00 00 
 555:	e9 a8 02 00 00       	jmpq   802 <printf+0x346>
    c = fmt[i] & 0xff;
 55a:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 560:	48 63 d0             	movslq %eax,%rdx
 563:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 56a:	48 01 d0             	add    %rdx,%rax
 56d:	0f b6 00             	movzbl (%rax),%eax
 570:	0f be c0             	movsbl %al,%eax
 573:	25 ff 00 00 00       	and    $0xff,%eax
 578:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 57e:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 585:	75 35                	jne    5bc <printf+0x100>
      if(c == '%'){
 587:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 58e:	75 0f                	jne    59f <printf+0xe3>
        state = '%';
 590:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 597:	00 00 00 
 59a:	e9 5c 02 00 00       	jmpq   7fb <printf+0x33f>
      } else {
        putc(fd, c);
 59f:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 5a5:	0f be d0             	movsbl %al,%edx
 5a8:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 5ae:	89 d6                	mov    %edx,%esi
 5b0:	89 c7                	mov    %eax,%edi
 5b2:	e8 1c fe ff ff       	callq  3d3 <putc>
 5b7:	e9 3f 02 00 00       	jmpq   7fb <printf+0x33f>
      }
    } else if(state == '%'){
 5bc:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 5c3:	0f 85 32 02 00 00    	jne    7fb <printf+0x33f>
      if(c == 'd'){
 5c9:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 5d0:	75 5e                	jne    630 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 5d2:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 5d8:	83 f8 2f             	cmp    $0x2f,%eax
 5db:	77 23                	ja     600 <printf+0x144>
 5dd:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 5e4:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 5ea:	89 d2                	mov    %edx,%edx
 5ec:	48 01 d0             	add    %rdx,%rax
 5ef:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 5f5:	83 c2 08             	add    $0x8,%edx
 5f8:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 5fe:	eb 12                	jmp    612 <printf+0x156>
 600:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 607:	48 8d 50 08          	lea    0x8(%rax),%rdx
 60b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 612:	8b 30                	mov    (%rax),%esi
 614:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 61a:	b9 01 00 00 00       	mov    $0x1,%ecx
 61f:	ba 0a 00 00 00       	mov    $0xa,%edx
 624:	89 c7                	mov    %eax,%edi
 626:	e8 d1 fd ff ff       	callq  3fc <printint>
 62b:	e9 c1 01 00 00       	jmpq   7f1 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 630:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 637:	74 09                	je     642 <printf+0x186>
 639:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 640:	75 5e                	jne    6a0 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 642:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 648:	83 f8 2f             	cmp    $0x2f,%eax
 64b:	77 23                	ja     670 <printf+0x1b4>
 64d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 654:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 65a:	89 d2                	mov    %edx,%edx
 65c:	48 01 d0             	add    %rdx,%rax
 65f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 665:	83 c2 08             	add    $0x8,%edx
 668:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 66e:	eb 12                	jmp    682 <printf+0x1c6>
 670:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 677:	48 8d 50 08          	lea    0x8(%rax),%rdx
 67b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 682:	8b 30                	mov    (%rax),%esi
 684:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 68a:	b9 00 00 00 00       	mov    $0x0,%ecx
 68f:	ba 10 00 00 00       	mov    $0x10,%edx
 694:	89 c7                	mov    %eax,%edi
 696:	e8 61 fd ff ff       	callq  3fc <printint>
 69b:	e9 51 01 00 00       	jmpq   7f1 <printf+0x335>
      } else if(c == 's'){
 6a0:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 6a7:	0f 85 98 00 00 00    	jne    745 <printf+0x289>
        s = va_arg(ap, char*);
 6ad:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6b3:	83 f8 2f             	cmp    $0x2f,%eax
 6b6:	77 23                	ja     6db <printf+0x21f>
 6b8:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6bf:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6c5:	89 d2                	mov    %edx,%edx
 6c7:	48 01 d0             	add    %rdx,%rax
 6ca:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6d0:	83 c2 08             	add    $0x8,%edx
 6d3:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6d9:	eb 12                	jmp    6ed <printf+0x231>
 6db:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6e2:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6e6:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6ed:	48 8b 00             	mov    (%rax),%rax
 6f0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 6f7:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 6fe:	00 
 6ff:	75 31                	jne    732 <printf+0x276>
          s = "(null)";
 701:	48 c7 85 48 ff ff ff 	movq   $0xac9,-0xb8(%rbp)
 708:	c9 0a 00 00 
        while(*s != 0){
 70c:	eb 24                	jmp    732 <printf+0x276>
          putc(fd, *s);
 70e:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 715:	0f b6 00             	movzbl (%rax),%eax
 718:	0f be d0             	movsbl %al,%edx
 71b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 721:	89 d6                	mov    %edx,%esi
 723:	89 c7                	mov    %eax,%edi
 725:	e8 a9 fc ff ff       	callq  3d3 <putc>
          s++;
 72a:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 731:	01 
        while(*s != 0){
 732:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 739:	0f b6 00             	movzbl (%rax),%eax
 73c:	84 c0                	test   %al,%al
 73e:	75 ce                	jne    70e <printf+0x252>
 740:	e9 ac 00 00 00       	jmpq   7f1 <printf+0x335>
        }
      } else if(c == 'c'){
 745:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 74c:	75 56                	jne    7a4 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 74e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 754:	83 f8 2f             	cmp    $0x2f,%eax
 757:	77 23                	ja     77c <printf+0x2c0>
 759:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 760:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 766:	89 d2                	mov    %edx,%edx
 768:	48 01 d0             	add    %rdx,%rax
 76b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 771:	83 c2 08             	add    $0x8,%edx
 774:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 77a:	eb 12                	jmp    78e <printf+0x2d2>
 77c:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 783:	48 8d 50 08          	lea    0x8(%rax),%rdx
 787:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 78e:	8b 00                	mov    (%rax),%eax
 790:	0f be d0             	movsbl %al,%edx
 793:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 799:	89 d6                	mov    %edx,%esi
 79b:	89 c7                	mov    %eax,%edi
 79d:	e8 31 fc ff ff       	callq  3d3 <putc>
 7a2:	eb 4d                	jmp    7f1 <printf+0x335>
      } else if(c == '%'){
 7a4:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 7ab:	75 1a                	jne    7c7 <printf+0x30b>
        putc(fd, c);
 7ad:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7b3:	0f be d0             	movsbl %al,%edx
 7b6:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7bc:	89 d6                	mov    %edx,%esi
 7be:	89 c7                	mov    %eax,%edi
 7c0:	e8 0e fc ff ff       	callq  3d3 <putc>
 7c5:	eb 2a                	jmp    7f1 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c7:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7cd:	be 25 00 00 00       	mov    $0x25,%esi
 7d2:	89 c7                	mov    %eax,%edi
 7d4:	e8 fa fb ff ff       	callq  3d3 <putc>
        putc(fd, c);
 7d9:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 7df:	0f be d0             	movsbl %al,%edx
 7e2:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7e8:	89 d6                	mov    %edx,%esi
 7ea:	89 c7                	mov    %eax,%edi
 7ec:	e8 e2 fb ff ff       	callq  3d3 <putc>
      }
      state = 0;
 7f1:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 7f8:	00 00 00 
  for(i = 0; fmt[i]; i++){
 7fb:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 802:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 808:	48 63 d0             	movslq %eax,%rdx
 80b:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 812:	48 01 d0             	add    %rdx,%rax
 815:	0f b6 00             	movzbl (%rax),%eax
 818:	84 c0                	test   %al,%al
 81a:	0f 85 3a fd ff ff    	jne    55a <printf+0x9e>
    }
  }
}
 820:	90                   	nop
 821:	c9                   	leaveq 
 822:	c3                   	retq   

0000000000000823 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 823:	55                   	push   %rbp
 824:	48 89 e5             	mov    %rsp,%rbp
 827:	48 83 ec 18          	sub    $0x18,%rsp
 82b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 833:	48 83 e8 10          	sub    $0x10,%rax
 837:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83b:	48 8b 05 fe 04 00 00 	mov    0x4fe(%rip),%rax        # d40 <freep>
 842:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 846:	eb 2f                	jmp    877 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 84c:	48 8b 00             	mov    (%rax),%rax
 84f:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 853:	72 17                	jb     86c <free+0x49>
 855:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 859:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 85d:	77 2f                	ja     88e <free+0x6b>
 85f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 863:	48 8b 00             	mov    (%rax),%rax
 866:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 86a:	72 22                	jb     88e <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 870:	48 8b 00             	mov    (%rax),%rax
 873:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 877:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 87b:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 87f:	76 c7                	jbe    848 <free+0x25>
 881:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 885:	48 8b 00             	mov    (%rax),%rax
 888:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 88c:	73 ba                	jae    848 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 88e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 892:	8b 40 08             	mov    0x8(%rax),%eax
 895:	89 c0                	mov    %eax,%eax
 897:	48 c1 e0 04          	shl    $0x4,%rax
 89b:	48 89 c2             	mov    %rax,%rdx
 89e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8a2:	48 01 c2             	add    %rax,%rdx
 8a5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8a9:	48 8b 00             	mov    (%rax),%rax
 8ac:	48 39 c2             	cmp    %rax,%rdx
 8af:	75 2d                	jne    8de <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 8b1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8b5:	8b 50 08             	mov    0x8(%rax),%edx
 8b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8bc:	48 8b 00             	mov    (%rax),%rax
 8bf:	8b 40 08             	mov    0x8(%rax),%eax
 8c2:	01 c2                	add    %eax,%edx
 8c4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8c8:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8cb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8cf:	48 8b 00             	mov    (%rax),%rax
 8d2:	48 8b 10             	mov    (%rax),%rdx
 8d5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8d9:	48 89 10             	mov    %rdx,(%rax)
 8dc:	eb 0e                	jmp    8ec <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 8de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8e2:	48 8b 10             	mov    (%rax),%rdx
 8e5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8e9:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 8ec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8f0:	8b 40 08             	mov    0x8(%rax),%eax
 8f3:	89 c0                	mov    %eax,%eax
 8f5:	48 c1 e0 04          	shl    $0x4,%rax
 8f9:	48 89 c2             	mov    %rax,%rdx
 8fc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 900:	48 01 d0             	add    %rdx,%rax
 903:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 907:	75 27                	jne    930 <free+0x10d>
    p->s.size += bp->s.size;
 909:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 90d:	8b 50 08             	mov    0x8(%rax),%edx
 910:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 914:	8b 40 08             	mov    0x8(%rax),%eax
 917:	01 c2                	add    %eax,%edx
 919:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 91d:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 920:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 924:	48 8b 10             	mov    (%rax),%rdx
 927:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 92b:	48 89 10             	mov    %rdx,(%rax)
 92e:	eb 0b                	jmp    93b <free+0x118>
  } else
    p->s.ptr = bp;
 930:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 934:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 938:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 93b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 93f:	48 89 05 fa 03 00 00 	mov    %rax,0x3fa(%rip)        # d40 <freep>
}
 946:	90                   	nop
 947:	c9                   	leaveq 
 948:	c3                   	retq   

0000000000000949 <morecore>:

static Header*
morecore(uint nu)
{
 949:	55                   	push   %rbp
 94a:	48 89 e5             	mov    %rsp,%rbp
 94d:	48 83 ec 20          	sub    $0x20,%rsp
 951:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 954:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 95b:	77 07                	ja     964 <morecore+0x1b>
    nu = 4096;
 95d:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 964:	8b 45 ec             	mov    -0x14(%rbp),%eax
 967:	c1 e0 04             	shl    $0x4,%eax
 96a:	89 c7                	mov    %eax,%edi
 96c:	e8 4a fa ff ff       	callq  3bb <sbrk>
 971:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 975:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 97a:	75 07                	jne    983 <morecore+0x3a>
    return 0;
 97c:	b8 00 00 00 00       	mov    $0x0,%eax
 981:	eb 29                	jmp    9ac <morecore+0x63>
  hp = (Header*)p;
 983:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 987:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 98b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 98f:	8b 55 ec             	mov    -0x14(%rbp),%edx
 992:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 995:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 999:	48 83 c0 10          	add    $0x10,%rax
 99d:	48 89 c7             	mov    %rax,%rdi
 9a0:	e8 7e fe ff ff       	callq  823 <free>
  return freep;
 9a5:	48 8b 05 94 03 00 00 	mov    0x394(%rip),%rax        # d40 <freep>
}
 9ac:	c9                   	leaveq 
 9ad:	c3                   	retq   

00000000000009ae <malloc>:

void*
malloc(uint nbytes)
{
 9ae:	55                   	push   %rbp
 9af:	48 89 e5             	mov    %rsp,%rbp
 9b2:	48 83 ec 30          	sub    $0x30,%rsp
 9b6:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b9:	8b 45 dc             	mov    -0x24(%rbp),%eax
 9bc:	48 83 c0 0f          	add    $0xf,%rax
 9c0:	48 c1 e8 04          	shr    $0x4,%rax
 9c4:	83 c0 01             	add    $0x1,%eax
 9c7:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 9ca:	48 8b 05 6f 03 00 00 	mov    0x36f(%rip),%rax        # d40 <freep>
 9d1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 9d5:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 9da:	75 2b                	jne    a07 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 9dc:	48 c7 45 f0 30 0d 00 	movq   $0xd30,-0x10(%rbp)
 9e3:	00 
 9e4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9e8:	48 89 05 51 03 00 00 	mov    %rax,0x351(%rip)        # d40 <freep>
 9ef:	48 8b 05 4a 03 00 00 	mov    0x34a(%rip),%rax        # d40 <freep>
 9f6:	48 89 05 33 03 00 00 	mov    %rax,0x333(%rip)        # d30 <base>
    base.s.size = 0;
 9fd:	c7 05 31 03 00 00 00 	movl   $0x0,0x331(%rip)        # d38 <base+0x8>
 a04:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a07:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a0b:	48 8b 00             	mov    (%rax),%rax
 a0e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a12:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a16:	8b 40 08             	mov    0x8(%rax),%eax
 a19:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a1c:	77 5f                	ja     a7d <malloc+0xcf>
      if(p->s.size == nunits)
 a1e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a22:	8b 40 08             	mov    0x8(%rax),%eax
 a25:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a28:	75 10                	jne    a3a <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a2a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a2e:	48 8b 10             	mov    (%rax),%rdx
 a31:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a35:	48 89 10             	mov    %rdx,(%rax)
 a38:	eb 2e                	jmp    a68 <malloc+0xba>
      else {
        p->s.size -= nunits;
 a3a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a3e:	8b 40 08             	mov    0x8(%rax),%eax
 a41:	2b 45 ec             	sub    -0x14(%rbp),%eax
 a44:	89 c2                	mov    %eax,%edx
 a46:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a4a:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 a4d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a51:	8b 40 08             	mov    0x8(%rax),%eax
 a54:	89 c0                	mov    %eax,%eax
 a56:	48 c1 e0 04          	shl    $0x4,%rax
 a5a:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 a5e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a62:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a65:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 a68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a6c:	48 89 05 cd 02 00 00 	mov    %rax,0x2cd(%rip)        # d40 <freep>
      return (void*)(p + 1);
 a73:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a77:	48 83 c0 10          	add    $0x10,%rax
 a7b:	eb 41                	jmp    abe <malloc+0x110>
    }
    if(p == freep)
 a7d:	48 8b 05 bc 02 00 00 	mov    0x2bc(%rip),%rax        # d40 <freep>
 a84:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 a88:	75 1c                	jne    aa6 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 a8a:	8b 45 ec             	mov    -0x14(%rbp),%eax
 a8d:	89 c7                	mov    %eax,%edi
 a8f:	e8 b5 fe ff ff       	callq  949 <morecore>
 a94:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 a98:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 a9d:	75 07                	jne    aa6 <malloc+0xf8>
        return 0;
 a9f:	b8 00 00 00 00       	mov    $0x0,%eax
 aa4:	eb 18                	jmp    abe <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aaa:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 aae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ab2:	48 8b 00             	mov    (%rax),%rax
 ab5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 ab9:	e9 54 ff ff ff       	jmpq   a12 <malloc+0x64>
  }
}
 abe:	c9                   	leaveq 
 abf:	c3                   	retq   
