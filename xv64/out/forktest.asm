
fs/forktest:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 81 ec c0 00 00 00 	sub    $0xc0,%rsp
   b:	89 bd 4c ff ff ff    	mov    %edi,-0xb4(%rbp)
  11:	48 89 b5 40 ff ff ff 	mov    %rsi,-0xc0(%rbp)
  18:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  1f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  26:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  2d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  34:	84 c0                	test   %al,%al
  36:	74 20                	je     58 <printf+0x58>
  38:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  3c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  40:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  44:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  48:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  4c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  50:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  54:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  write(fd, s, strlen(s));
  58:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  5f:	48 89 c7             	mov    %rax,%rdi
  62:	e8 db 01 00 00       	callq  242 <strlen>
  67:	89 c2                	mov    %eax,%edx
  69:	48 8b 8d 40 ff ff ff 	mov    -0xc0(%rbp),%rcx
  70:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  76:	48 89 ce             	mov    %rcx,%rsi
  79:	89 c7                	mov    %eax,%edi
  7b:	e8 09 04 00 00       	callq  489 <write>
}
  80:	90                   	nop
  81:	c9                   	leaveq 
  82:	c3                   	retq   

0000000000000083 <forktest>:

void
forktest(void)
{
  83:	55                   	push   %rbp
  84:	48 89 e5             	mov    %rsp,%rbp
  87:	48 83 ec 10          	sub    $0x10,%rsp
  int n, pid;

  printf(1, "fork test\n");
  8b:	48 c7 c6 10 05 00 00 	mov    $0x510,%rsi
  92:	bf 01 00 00 00       	mov    $0x1,%edi
  97:	b8 00 00 00 00       	mov    $0x0,%eax
  9c:	e8 5f ff ff ff       	callq  0 <printf>

  for(n=0; n<N; n++){
  a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  a8:	eb 1d                	jmp    c7 <forktest+0x44>
    pid = fork();
  aa:	e8 b2 03 00 00       	callq  461 <fork>
  af:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(pid < 0)
  b2:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  b6:	78 1a                	js     d2 <forktest+0x4f>
      break;
    if(pid == 0)
  b8:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  bc:	75 05                	jne    c3 <forktest+0x40>
      exit();
  be:	e8 a6 03 00 00       	callq  469 <exit>
  for(n=0; n<N; n++){
  c3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  c7:	81 7d fc e7 03 00 00 	cmpl   $0x3e7,-0x4(%rbp)
  ce:	7e da                	jle    aa <forktest+0x27>
  d0:	eb 01                	jmp    d3 <forktest+0x50>
      break;
  d2:	90                   	nop
  }
  
  if(n == N){
  d3:	81 7d fc e8 03 00 00 	cmpl   $0x3e8,-0x4(%rbp)
  da:	75 48                	jne    124 <forktest+0xa1>
    printf(1, "fork claimed to work N times!\n", N);
  dc:	ba e8 03 00 00       	mov    $0x3e8,%edx
  e1:	48 c7 c6 20 05 00 00 	mov    $0x520,%rsi
  e8:	bf 01 00 00 00       	mov    $0x1,%edi
  ed:	b8 00 00 00 00       	mov    $0x0,%eax
  f2:	e8 09 ff ff ff       	callq  0 <printf>
    exit();
  f7:	e8 6d 03 00 00       	callq  469 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
  fc:	e8 70 03 00 00       	callq  471 <wait>
 101:	85 c0                	test   %eax,%eax
 103:	79 1b                	jns    120 <forktest+0x9d>
      printf(1, "wait stopped early\n");
 105:	48 c7 c6 3f 05 00 00 	mov    $0x53f,%rsi
 10c:	bf 01 00 00 00       	mov    $0x1,%edi
 111:	b8 00 00 00 00       	mov    $0x0,%eax
 116:	e8 e5 fe ff ff       	callq  0 <printf>
      exit();
 11b:	e8 49 03 00 00       	callq  469 <exit>
  for(; n > 0; n--){
 120:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 124:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 128:	7f d2                	jg     fc <forktest+0x79>
    }
  }
  
  if(wait() != -1){
 12a:	e8 42 03 00 00       	callq  471 <wait>
 12f:	83 f8 ff             	cmp    $0xffffffff,%eax
 132:	74 1b                	je     14f <forktest+0xcc>
    printf(1, "wait got too many\n");
 134:	48 c7 c6 53 05 00 00 	mov    $0x553,%rsi
 13b:	bf 01 00 00 00       	mov    $0x1,%edi
 140:	b8 00 00 00 00       	mov    $0x0,%eax
 145:	e8 b6 fe ff ff       	callq  0 <printf>
    exit();
 14a:	e8 1a 03 00 00       	callq  469 <exit>
  }
  
  printf(1, "fork test OK\n");
 14f:	48 c7 c6 66 05 00 00 	mov    $0x566,%rsi
 156:	bf 01 00 00 00       	mov    $0x1,%edi
 15b:	b8 00 00 00 00       	mov    $0x0,%eax
 160:	e8 9b fe ff ff       	callq  0 <printf>
}
 165:	90                   	nop
 166:	c9                   	leaveq 
 167:	c3                   	retq   

0000000000000168 <main>:

int
main(void)
{
 168:	55                   	push   %rbp
 169:	48 89 e5             	mov    %rsp,%rbp
  forktest();
 16c:	e8 12 ff ff ff       	callq  83 <forktest>
  exit();
 171:	e8 f3 02 00 00       	callq  469 <exit>

0000000000000176 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 176:	55                   	push   %rbp
 177:	48 89 e5             	mov    %rsp,%rbp
 17a:	48 83 ec 10          	sub    $0x10,%rsp
 17e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 182:	89 75 f4             	mov    %esi,-0xc(%rbp)
 185:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 188:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 18c:	8b 55 f0             	mov    -0x10(%rbp),%edx
 18f:	8b 45 f4             	mov    -0xc(%rbp),%eax
 192:	48 89 ce             	mov    %rcx,%rsi
 195:	48 89 f7             	mov    %rsi,%rdi
 198:	89 d1                	mov    %edx,%ecx
 19a:	fc                   	cld    
 19b:	f3 aa                	rep stos %al,%es:(%rdi)
 19d:	89 ca                	mov    %ecx,%edx
 19f:	48 89 fe             	mov    %rdi,%rsi
 1a2:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 1a6:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1a9:	90                   	nop
 1aa:	c9                   	leaveq 
 1ab:	c3                   	retq   

00000000000001ac <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1ac:	55                   	push   %rbp
 1ad:	48 89 e5             	mov    %rsp,%rbp
 1b0:	48 83 ec 20          	sub    $0x20,%rsp
 1b4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 1b8:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 1bc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1c0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 1c4:	90                   	nop
 1c5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 1c9:	48 8d 42 01          	lea    0x1(%rdx),%rax
 1cd:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 1d1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1d5:	48 8d 48 01          	lea    0x1(%rax),%rcx
 1d9:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 1dd:	0f b6 12             	movzbl (%rdx),%edx
 1e0:	88 10                	mov    %dl,(%rax)
 1e2:	0f b6 00             	movzbl (%rax),%eax
 1e5:	84 c0                	test   %al,%al
 1e7:	75 dc                	jne    1c5 <strcpy+0x19>
    ;
  return os;
 1e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 1ed:	c9                   	leaveq 
 1ee:	c3                   	retq   

00000000000001ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ef:	55                   	push   %rbp
 1f0:	48 89 e5             	mov    %rsp,%rbp
 1f3:	48 83 ec 10          	sub    $0x10,%rsp
 1f7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1fb:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 1ff:	eb 0a                	jmp    20b <strcmp+0x1c>
    p++, q++;
 201:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 206:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 20b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 20f:	0f b6 00             	movzbl (%rax),%eax
 212:	84 c0                	test   %al,%al
 214:	74 12                	je     228 <strcmp+0x39>
 216:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 21a:	0f b6 10             	movzbl (%rax),%edx
 21d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 221:	0f b6 00             	movzbl (%rax),%eax
 224:	38 c2                	cmp    %al,%dl
 226:	74 d9                	je     201 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 228:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 22c:	0f b6 00             	movzbl (%rax),%eax
 22f:	0f b6 d0             	movzbl %al,%edx
 232:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 236:	0f b6 00             	movzbl (%rax),%eax
 239:	0f b6 c0             	movzbl %al,%eax
 23c:	29 c2                	sub    %eax,%edx
 23e:	89 d0                	mov    %edx,%eax
}
 240:	c9                   	leaveq 
 241:	c3                   	retq   

0000000000000242 <strlen>:

uint
strlen(char *s)
{
 242:	55                   	push   %rbp
 243:	48 89 e5             	mov    %rsp,%rbp
 246:	48 83 ec 18          	sub    $0x18,%rsp
 24a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 24e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 255:	eb 04                	jmp    25b <strlen+0x19>
 257:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 25b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 25e:	48 63 d0             	movslq %eax,%rdx
 261:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 265:	48 01 d0             	add    %rdx,%rax
 268:	0f b6 00             	movzbl (%rax),%eax
 26b:	84 c0                	test   %al,%al
 26d:	75 e8                	jne    257 <strlen+0x15>
    ;
  return n;
 26f:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 272:	c9                   	leaveq 
 273:	c3                   	retq   

0000000000000274 <memset>:

void*
memset(void *dst, int c, uint n)
{
 274:	55                   	push   %rbp
 275:	48 89 e5             	mov    %rsp,%rbp
 278:	48 83 ec 10          	sub    $0x10,%rsp
 27c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 280:	89 75 f4             	mov    %esi,-0xc(%rbp)
 283:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 286:	8b 55 f0             	mov    -0x10(%rbp),%edx
 289:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 28c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 290:	89 ce                	mov    %ecx,%esi
 292:	48 89 c7             	mov    %rax,%rdi
 295:	e8 dc fe ff ff       	callq  176 <stosb>
  return dst;
 29a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 29e:	c9                   	leaveq 
 29f:	c3                   	retq   

00000000000002a0 <strchr>:

char*
strchr(const char *s, char c)
{
 2a0:	55                   	push   %rbp
 2a1:	48 89 e5             	mov    %rsp,%rbp
 2a4:	48 83 ec 10          	sub    $0x10,%rsp
 2a8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 2ac:	89 f0                	mov    %esi,%eax
 2ae:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 2b1:	eb 17                	jmp    2ca <strchr+0x2a>
    if(*s == c)
 2b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2b7:	0f b6 00             	movzbl (%rax),%eax
 2ba:	38 45 f4             	cmp    %al,-0xc(%rbp)
 2bd:	75 06                	jne    2c5 <strchr+0x25>
      return (char*)s;
 2bf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2c3:	eb 15                	jmp    2da <strchr+0x3a>
  for(; *s; s++)
 2c5:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 2ca:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2ce:	0f b6 00             	movzbl (%rax),%eax
 2d1:	84 c0                	test   %al,%al
 2d3:	75 de                	jne    2b3 <strchr+0x13>
  return 0;
 2d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2da:	c9                   	leaveq 
 2db:	c3                   	retq   

00000000000002dc <gets>:

char*
gets(char *buf, int max)
{
 2dc:	55                   	push   %rbp
 2dd:	48 89 e5             	mov    %rsp,%rbp
 2e0:	48 83 ec 20          	sub    $0x20,%rsp
 2e4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 2e8:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 2f2:	eb 48                	jmp    33c <gets+0x60>
    cc = read(0, &c, 1);
 2f4:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 2f8:	ba 01 00 00 00       	mov    $0x1,%edx
 2fd:	48 89 c6             	mov    %rax,%rsi
 300:	bf 00 00 00 00       	mov    $0x0,%edi
 305:	e8 77 01 00 00       	callq  481 <read>
 30a:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 30d:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 311:	7e 36                	jle    349 <gets+0x6d>
      break;
    buf[i++] = c;
 313:	8b 45 fc             	mov    -0x4(%rbp),%eax
 316:	8d 50 01             	lea    0x1(%rax),%edx
 319:	89 55 fc             	mov    %edx,-0x4(%rbp)
 31c:	48 63 d0             	movslq %eax,%rdx
 31f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 323:	48 01 c2             	add    %rax,%rdx
 326:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 32a:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 32c:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 330:	3c 0a                	cmp    $0xa,%al
 332:	74 16                	je     34a <gets+0x6e>
 334:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 338:	3c 0d                	cmp    $0xd,%al
 33a:	74 0e                	je     34a <gets+0x6e>
  for(i=0; i+1 < max; ){
 33c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 33f:	83 c0 01             	add    $0x1,%eax
 342:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 345:	7f ad                	jg     2f4 <gets+0x18>
 347:	eb 01                	jmp    34a <gets+0x6e>
      break;
 349:	90                   	nop
      break;
  }
  buf[i] = '\0';
 34a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 34d:	48 63 d0             	movslq %eax,%rdx
 350:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 354:	48 01 d0             	add    %rdx,%rax
 357:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 35a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 35e:	c9                   	leaveq 
 35f:	c3                   	retq   

0000000000000360 <stat>:

int
stat(char *n, struct stat *st)
{
 360:	55                   	push   %rbp
 361:	48 89 e5             	mov    %rsp,%rbp
 364:	48 83 ec 20          	sub    $0x20,%rsp
 368:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 36c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 370:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 374:	be 00 00 00 00       	mov    $0x0,%esi
 379:	48 89 c7             	mov    %rax,%rdi
 37c:	e8 28 01 00 00       	callq  4a9 <open>
 381:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 384:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 388:	79 07                	jns    391 <stat+0x31>
    return -1;
 38a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 38f:	eb 21                	jmp    3b2 <stat+0x52>
  r = fstat(fd, st);
 391:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 395:	8b 45 fc             	mov    -0x4(%rbp),%eax
 398:	48 89 d6             	mov    %rdx,%rsi
 39b:	89 c7                	mov    %eax,%edi
 39d:	e8 1f 01 00 00       	callq  4c1 <fstat>
 3a2:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 3a5:	8b 45 fc             	mov    -0x4(%rbp),%eax
 3a8:	89 c7                	mov    %eax,%edi
 3aa:	e8 e2 00 00 00       	callq  491 <close>
  return r;
 3af:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 3b2:	c9                   	leaveq 
 3b3:	c3                   	retq   

00000000000003b4 <atoi>:

int
atoi(const char *s)
{
 3b4:	55                   	push   %rbp
 3b5:	48 89 e5             	mov    %rsp,%rbp
 3b8:	48 83 ec 18          	sub    $0x18,%rsp
 3bc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 3c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 3c7:	eb 28                	jmp    3f1 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 3c9:	8b 55 fc             	mov    -0x4(%rbp),%edx
 3cc:	89 d0                	mov    %edx,%eax
 3ce:	c1 e0 02             	shl    $0x2,%eax
 3d1:	01 d0                	add    %edx,%eax
 3d3:	01 c0                	add    %eax,%eax
 3d5:	89 c1                	mov    %eax,%ecx
 3d7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3db:	48 8d 50 01          	lea    0x1(%rax),%rdx
 3df:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 3e3:	0f b6 00             	movzbl (%rax),%eax
 3e6:	0f be c0             	movsbl %al,%eax
 3e9:	01 c8                	add    %ecx,%eax
 3eb:	83 e8 30             	sub    $0x30,%eax
 3ee:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 3f1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3f5:	0f b6 00             	movzbl (%rax),%eax
 3f8:	3c 2f                	cmp    $0x2f,%al
 3fa:	7e 0b                	jle    407 <atoi+0x53>
 3fc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 400:	0f b6 00             	movzbl (%rax),%eax
 403:	3c 39                	cmp    $0x39,%al
 405:	7e c2                	jle    3c9 <atoi+0x15>
  return n;
 407:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 40a:	c9                   	leaveq 
 40b:	c3                   	retq   

000000000000040c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 40c:	55                   	push   %rbp
 40d:	48 89 e5             	mov    %rsp,%rbp
 410:	48 83 ec 28          	sub    $0x28,%rsp
 414:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 418:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 41c:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 41f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 423:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 427:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 42b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 42f:	eb 1d                	jmp    44e <memmove+0x42>
    *dst++ = *src++;
 431:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 435:	48 8d 42 01          	lea    0x1(%rdx),%rax
 439:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 43d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 441:	48 8d 48 01          	lea    0x1(%rax),%rcx
 445:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 449:	0f b6 12             	movzbl (%rdx),%edx
 44c:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 44e:	8b 45 dc             	mov    -0x24(%rbp),%eax
 451:	8d 50 ff             	lea    -0x1(%rax),%edx
 454:	89 55 dc             	mov    %edx,-0x24(%rbp)
 457:	85 c0                	test   %eax,%eax
 459:	7f d6                	jg     431 <memmove+0x25>
  return vdst;
 45b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 45f:	c9                   	leaveq 
 460:	c3                   	retq   

0000000000000461 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 461:	b8 01 00 00 00       	mov    $0x1,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	retq   

0000000000000469 <exit>:
SYSCALL(exit)
 469:	b8 02 00 00 00       	mov    $0x2,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	retq   

0000000000000471 <wait>:
SYSCALL(wait)
 471:	b8 03 00 00 00       	mov    $0x3,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	retq   

0000000000000479 <pipe>:
SYSCALL(pipe)
 479:	b8 04 00 00 00       	mov    $0x4,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	retq   

0000000000000481 <read>:
SYSCALL(read)
 481:	b8 05 00 00 00       	mov    $0x5,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	retq   

0000000000000489 <write>:
SYSCALL(write)
 489:	b8 10 00 00 00       	mov    $0x10,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	retq   

0000000000000491 <close>:
SYSCALL(close)
 491:	b8 15 00 00 00       	mov    $0x15,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	retq   

0000000000000499 <kill>:
SYSCALL(kill)
 499:	b8 06 00 00 00       	mov    $0x6,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	retq   

00000000000004a1 <exec>:
SYSCALL(exec)
 4a1:	b8 07 00 00 00       	mov    $0x7,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	retq   

00000000000004a9 <open>:
SYSCALL(open)
 4a9:	b8 0f 00 00 00       	mov    $0xf,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	retq   

00000000000004b1 <mknod>:
SYSCALL(mknod)
 4b1:	b8 11 00 00 00       	mov    $0x11,%eax
 4b6:	cd 40                	int    $0x40
 4b8:	c3                   	retq   

00000000000004b9 <unlink>:
SYSCALL(unlink)
 4b9:	b8 12 00 00 00       	mov    $0x12,%eax
 4be:	cd 40                	int    $0x40
 4c0:	c3                   	retq   

00000000000004c1 <fstat>:
SYSCALL(fstat)
 4c1:	b8 08 00 00 00       	mov    $0x8,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	retq   

00000000000004c9 <link>:
SYSCALL(link)
 4c9:	b8 13 00 00 00       	mov    $0x13,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	retq   

00000000000004d1 <mkdir>:
SYSCALL(mkdir)
 4d1:	b8 14 00 00 00       	mov    $0x14,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	retq   

00000000000004d9 <chdir>:
SYSCALL(chdir)
 4d9:	b8 09 00 00 00       	mov    $0x9,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	retq   

00000000000004e1 <dup>:
SYSCALL(dup)
 4e1:	b8 0a 00 00 00       	mov    $0xa,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	retq   

00000000000004e9 <getpid>:
SYSCALL(getpid)
 4e9:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	retq   

00000000000004f1 <sbrk>:
SYSCALL(sbrk)
 4f1:	b8 0c 00 00 00       	mov    $0xc,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	retq   

00000000000004f9 <sleep>:
SYSCALL(sleep)
 4f9:	b8 0d 00 00 00       	mov    $0xd,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	retq   

0000000000000501 <uptime>:
SYSCALL(uptime)
 501:	b8 0e 00 00 00       	mov    $0xe,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	retq   
