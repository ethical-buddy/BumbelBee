
fs/init:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 10          	sub    $0x10,%rsp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   8:	be 02 00 00 00       	mov    $0x2,%esi
   d:	48 c7 c7 83 0b 00 00 	mov    $0xb83,%rdi
  14:	e8 1a 04 00 00       	callq  433 <open>
  19:	85 c0                	test   %eax,%eax
  1b:	79 27                	jns    44 <main+0x44>
    mknod("console", 1, 1);
  1d:	ba 01 00 00 00       	mov    $0x1,%edx
  22:	be 01 00 00 00       	mov    $0x1,%esi
  27:	48 c7 c7 83 0b 00 00 	mov    $0xb83,%rdi
  2e:	e8 08 04 00 00       	callq  43b <mknod>
    open("console", O_RDWR);
  33:	be 02 00 00 00       	mov    $0x2,%esi
  38:	48 c7 c7 83 0b 00 00 	mov    $0xb83,%rdi
  3f:	e8 ef 03 00 00       	callq  433 <open>
  }
  dup(0);  // stdout
  44:	bf 00 00 00 00       	mov    $0x0,%edi
  49:	e8 1d 04 00 00       	callq  46b <dup>
  dup(0);  // stderr
  4e:	bf 00 00 00 00       	mov    $0x0,%edi
  53:	e8 13 04 00 00       	callq  46b <dup>

  for(;;){
    printf(1, "init: executing sh\n");
  58:	48 c7 c6 8b 0b 00 00 	mov    $0xb8b,%rsi
  5f:	bf 01 00 00 00       	mov    $0x1,%edi
  64:	b8 00 00 00 00       	mov    $0x0,%eax
  69:	e8 0e 05 00 00       	callq  57c <printf>
    pid = fork();
  6e:	e8 78 03 00 00       	callq  3eb <fork>
  73:	89 45 fc             	mov    %eax,-0x4(%rbp)
    if(pid < 0){
  76:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  7a:	79 1b                	jns    97 <main+0x97>
      printf(1, "init: fork failed\n");
  7c:	48 c7 c6 9f 0b 00 00 	mov    $0xb9f,%rsi
  83:	bf 01 00 00 00       	mov    $0x1,%edi
  88:	b8 00 00 00 00       	mov    $0x0,%eax
  8d:	e8 ea 04 00 00       	callq  57c <printf>
      exit();
  92:	e8 5c 03 00 00       	callq  3f3 <exit>
    }
    if(pid == 0){
  97:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  9b:	75 44                	jne    e1 <main+0xe1>
      exec("sh", argv);
  9d:	48 c7 c6 10 0e 00 00 	mov    $0xe10,%rsi
  a4:	48 c7 c7 80 0b 00 00 	mov    $0xb80,%rdi
  ab:	e8 7b 03 00 00       	callq  42b <exec>
      printf(1, "init: exec sh failed\n");
  b0:	48 c7 c6 b2 0b 00 00 	mov    $0xbb2,%rsi
  b7:	bf 01 00 00 00       	mov    $0x1,%edi
  bc:	b8 00 00 00 00       	mov    $0x0,%eax
  c1:	e8 b6 04 00 00       	callq  57c <printf>
      exit();
  c6:	e8 28 03 00 00       	callq  3f3 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  cb:	48 c7 c6 c8 0b 00 00 	mov    $0xbc8,%rsi
  d2:	bf 01 00 00 00       	mov    $0x1,%edi
  d7:	b8 00 00 00 00       	mov    $0x0,%eax
  dc:	e8 9b 04 00 00       	callq  57c <printf>
    while((wpid=wait()) >= 0 && wpid != pid)
  e1:	e8 15 03 00 00       	callq  3fb <wait>
  e6:	89 45 f8             	mov    %eax,-0x8(%rbp)
  e9:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  ed:	0f 88 65 ff ff ff    	js     58 <main+0x58>
  f3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  f6:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  f9:	75 d0                	jne    cb <main+0xcb>
    printf(1, "init: executing sh\n");
  fb:	e9 58 ff ff ff       	jmpq   58 <main+0x58>

0000000000000100 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 100:	55                   	push   %rbp
 101:	48 89 e5             	mov    %rsp,%rbp
 104:	48 83 ec 10          	sub    $0x10,%rsp
 108:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 10c:	89 75 f4             	mov    %esi,-0xc(%rbp)
 10f:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 112:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 116:	8b 55 f0             	mov    -0x10(%rbp),%edx
 119:	8b 45 f4             	mov    -0xc(%rbp),%eax
 11c:	48 89 ce             	mov    %rcx,%rsi
 11f:	48 89 f7             	mov    %rsi,%rdi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%rdi)
 127:	89 ca                	mov    %ecx,%edx
 129:	48 89 fe             	mov    %rdi,%rsi
 12c:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 130:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 133:	90                   	nop
 134:	c9                   	leaveq 
 135:	c3                   	retq   

0000000000000136 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 136:	55                   	push   %rbp
 137:	48 89 e5             	mov    %rsp,%rbp
 13a:	48 83 ec 20          	sub    $0x20,%rsp
 13e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 142:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 146:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 14a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 14e:	90                   	nop
 14f:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 153:	48 8d 42 01          	lea    0x1(%rdx),%rax
 157:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 15b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 15f:	48 8d 48 01          	lea    0x1(%rax),%rcx
 163:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 167:	0f b6 12             	movzbl (%rdx),%edx
 16a:	88 10                	mov    %dl,(%rax)
 16c:	0f b6 00             	movzbl (%rax),%eax
 16f:	84 c0                	test   %al,%al
 171:	75 dc                	jne    14f <strcpy+0x19>
    ;
  return os;
 173:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 177:	c9                   	leaveq 
 178:	c3                   	retq   

0000000000000179 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 179:	55                   	push   %rbp
 17a:	48 89 e5             	mov    %rsp,%rbp
 17d:	48 83 ec 10          	sub    $0x10,%rsp
 181:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 185:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 189:	eb 0a                	jmp    195 <strcmp+0x1c>
    p++, q++;
 18b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 190:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 195:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 199:	0f b6 00             	movzbl (%rax),%eax
 19c:	84 c0                	test   %al,%al
 19e:	74 12                	je     1b2 <strcmp+0x39>
 1a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1a4:	0f b6 10             	movzbl (%rax),%edx
 1a7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 1ab:	0f b6 00             	movzbl (%rax),%eax
 1ae:	38 c2                	cmp    %al,%dl
 1b0:	74 d9                	je     18b <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 1b2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1b6:	0f b6 00             	movzbl (%rax),%eax
 1b9:	0f b6 d0             	movzbl %al,%edx
 1bc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 1c0:	0f b6 00             	movzbl (%rax),%eax
 1c3:	0f b6 c0             	movzbl %al,%eax
 1c6:	29 c2                	sub    %eax,%edx
 1c8:	89 d0                	mov    %edx,%eax
}
 1ca:	c9                   	leaveq 
 1cb:	c3                   	retq   

00000000000001cc <strlen>:

uint
strlen(char *s)
{
 1cc:	55                   	push   %rbp
 1cd:	48 89 e5             	mov    %rsp,%rbp
 1d0:	48 83 ec 18          	sub    $0x18,%rsp
 1d4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 1d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 1df:	eb 04                	jmp    1e5 <strlen+0x19>
 1e1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 1e5:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1e8:	48 63 d0             	movslq %eax,%rdx
 1eb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 1ef:	48 01 d0             	add    %rdx,%rax
 1f2:	0f b6 00             	movzbl (%rax),%eax
 1f5:	84 c0                	test   %al,%al
 1f7:	75 e8                	jne    1e1 <strlen+0x15>
    ;
  return n;
 1f9:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 1fc:	c9                   	leaveq 
 1fd:	c3                   	retq   

00000000000001fe <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fe:	55                   	push   %rbp
 1ff:	48 89 e5             	mov    %rsp,%rbp
 202:	48 83 ec 10          	sub    $0x10,%rsp
 206:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 20a:	89 75 f4             	mov    %esi,-0xc(%rbp)
 20d:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 210:	8b 55 f0             	mov    -0x10(%rbp),%edx
 213:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 216:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 21a:	89 ce                	mov    %ecx,%esi
 21c:	48 89 c7             	mov    %rax,%rdi
 21f:	e8 dc fe ff ff       	callq  100 <stosb>
  return dst;
 224:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 228:	c9                   	leaveq 
 229:	c3                   	retq   

000000000000022a <strchr>:

char*
strchr(const char *s, char c)
{
 22a:	55                   	push   %rbp
 22b:	48 89 e5             	mov    %rsp,%rbp
 22e:	48 83 ec 10          	sub    $0x10,%rsp
 232:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 236:	89 f0                	mov    %esi,%eax
 238:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 23b:	eb 17                	jmp    254 <strchr+0x2a>
    if(*s == c)
 23d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 241:	0f b6 00             	movzbl (%rax),%eax
 244:	38 45 f4             	cmp    %al,-0xc(%rbp)
 247:	75 06                	jne    24f <strchr+0x25>
      return (char*)s;
 249:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 24d:	eb 15                	jmp    264 <strchr+0x3a>
  for(; *s; s++)
 24f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 254:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 258:	0f b6 00             	movzbl (%rax),%eax
 25b:	84 c0                	test   %al,%al
 25d:	75 de                	jne    23d <strchr+0x13>
  return 0;
 25f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 264:	c9                   	leaveq 
 265:	c3                   	retq   

0000000000000266 <gets>:

char*
gets(char *buf, int max)
{
 266:	55                   	push   %rbp
 267:	48 89 e5             	mov    %rsp,%rbp
 26a:	48 83 ec 20          	sub    $0x20,%rsp
 26e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 272:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 275:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 27c:	eb 48                	jmp    2c6 <gets+0x60>
    cc = read(0, &c, 1);
 27e:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 282:	ba 01 00 00 00       	mov    $0x1,%edx
 287:	48 89 c6             	mov    %rax,%rsi
 28a:	bf 00 00 00 00       	mov    $0x0,%edi
 28f:	e8 77 01 00 00       	callq  40b <read>
 294:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 297:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 29b:	7e 36                	jle    2d3 <gets+0x6d>
      break;
    buf[i++] = c;
 29d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2a0:	8d 50 01             	lea    0x1(%rax),%edx
 2a3:	89 55 fc             	mov    %edx,-0x4(%rbp)
 2a6:	48 63 d0             	movslq %eax,%rdx
 2a9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2ad:	48 01 c2             	add    %rax,%rdx
 2b0:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2b4:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 2b6:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2ba:	3c 0a                	cmp    $0xa,%al
 2bc:	74 16                	je     2d4 <gets+0x6e>
 2be:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2c2:	3c 0d                	cmp    $0xd,%al
 2c4:	74 0e                	je     2d4 <gets+0x6e>
  for(i=0; i+1 < max; ){
 2c6:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2c9:	83 c0 01             	add    $0x1,%eax
 2cc:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 2cf:	7f ad                	jg     27e <gets+0x18>
 2d1:	eb 01                	jmp    2d4 <gets+0x6e>
      break;
 2d3:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2d4:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2d7:	48 63 d0             	movslq %eax,%rdx
 2da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2de:	48 01 d0             	add    %rdx,%rax
 2e1:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 2e4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 2e8:	c9                   	leaveq 
 2e9:	c3                   	retq   

00000000000002ea <stat>:

int
stat(char *n, struct stat *st)
{
 2ea:	55                   	push   %rbp
 2eb:	48 89 e5             	mov    %rsp,%rbp
 2ee:	48 83 ec 20          	sub    $0x20,%rsp
 2f2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 2f6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2fa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2fe:	be 00 00 00 00       	mov    $0x0,%esi
 303:	48 89 c7             	mov    %rax,%rdi
 306:	e8 28 01 00 00       	callq  433 <open>
 30b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 30e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 312:	79 07                	jns    31b <stat+0x31>
    return -1;
 314:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 319:	eb 21                	jmp    33c <stat+0x52>
  r = fstat(fd, st);
 31b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 31f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 322:	48 89 d6             	mov    %rdx,%rsi
 325:	89 c7                	mov    %eax,%edi
 327:	e8 1f 01 00 00       	callq  44b <fstat>
 32c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 32f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 332:	89 c7                	mov    %eax,%edi
 334:	e8 e2 00 00 00       	callq  41b <close>
  return r;
 339:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 33c:	c9                   	leaveq 
 33d:	c3                   	retq   

000000000000033e <atoi>:

int
atoi(const char *s)
{
 33e:	55                   	push   %rbp
 33f:	48 89 e5             	mov    %rsp,%rbp
 342:	48 83 ec 18          	sub    $0x18,%rsp
 346:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 34a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 351:	eb 28                	jmp    37b <atoi+0x3d>
    n = n*10 + *s++ - '0';
 353:	8b 55 fc             	mov    -0x4(%rbp),%edx
 356:	89 d0                	mov    %edx,%eax
 358:	c1 e0 02             	shl    $0x2,%eax
 35b:	01 d0                	add    %edx,%eax
 35d:	01 c0                	add    %eax,%eax
 35f:	89 c1                	mov    %eax,%ecx
 361:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 365:	48 8d 50 01          	lea    0x1(%rax),%rdx
 369:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 36d:	0f b6 00             	movzbl (%rax),%eax
 370:	0f be c0             	movsbl %al,%eax
 373:	01 c8                	add    %ecx,%eax
 375:	83 e8 30             	sub    $0x30,%eax
 378:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 37b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 37f:	0f b6 00             	movzbl (%rax),%eax
 382:	3c 2f                	cmp    $0x2f,%al
 384:	7e 0b                	jle    391 <atoi+0x53>
 386:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 38a:	0f b6 00             	movzbl (%rax),%eax
 38d:	3c 39                	cmp    $0x39,%al
 38f:	7e c2                	jle    353 <atoi+0x15>
  return n;
 391:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 394:	c9                   	leaveq 
 395:	c3                   	retq   

0000000000000396 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 396:	55                   	push   %rbp
 397:	48 89 e5             	mov    %rsp,%rbp
 39a:	48 83 ec 28          	sub    $0x28,%rsp
 39e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 3a2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 3a6:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 3a9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3ad:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 3b1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 3b5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 3b9:	eb 1d                	jmp    3d8 <memmove+0x42>
    *dst++ = *src++;
 3bb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 3bf:	48 8d 42 01          	lea    0x1(%rdx),%rax
 3c3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 3c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 3cb:	48 8d 48 01          	lea    0x1(%rax),%rcx
 3cf:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 3d3:	0f b6 12             	movzbl (%rdx),%edx
 3d6:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 3d8:	8b 45 dc             	mov    -0x24(%rbp),%eax
 3db:	8d 50 ff             	lea    -0x1(%rax),%edx
 3de:	89 55 dc             	mov    %edx,-0x24(%rbp)
 3e1:	85 c0                	test   %eax,%eax
 3e3:	7f d6                	jg     3bb <memmove+0x25>
  return vdst;
 3e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 3e9:	c9                   	leaveq 
 3ea:	c3                   	retq   

00000000000003eb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3eb:	b8 01 00 00 00       	mov    $0x1,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	retq   

00000000000003f3 <exit>:
SYSCALL(exit)
 3f3:	b8 02 00 00 00       	mov    $0x2,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	retq   

00000000000003fb <wait>:
SYSCALL(wait)
 3fb:	b8 03 00 00 00       	mov    $0x3,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	retq   

0000000000000403 <pipe>:
SYSCALL(pipe)
 403:	b8 04 00 00 00       	mov    $0x4,%eax
 408:	cd 40                	int    $0x40
 40a:	c3                   	retq   

000000000000040b <read>:
SYSCALL(read)
 40b:	b8 05 00 00 00       	mov    $0x5,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	retq   

0000000000000413 <write>:
SYSCALL(write)
 413:	b8 10 00 00 00       	mov    $0x10,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	retq   

000000000000041b <close>:
SYSCALL(close)
 41b:	b8 15 00 00 00       	mov    $0x15,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	retq   

0000000000000423 <kill>:
SYSCALL(kill)
 423:	b8 06 00 00 00       	mov    $0x6,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	retq   

000000000000042b <exec>:
SYSCALL(exec)
 42b:	b8 07 00 00 00       	mov    $0x7,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	retq   

0000000000000433 <open>:
SYSCALL(open)
 433:	b8 0f 00 00 00       	mov    $0xf,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	retq   

000000000000043b <mknod>:
SYSCALL(mknod)
 43b:	b8 11 00 00 00       	mov    $0x11,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	retq   

0000000000000443 <unlink>:
SYSCALL(unlink)
 443:	b8 12 00 00 00       	mov    $0x12,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	retq   

000000000000044b <fstat>:
SYSCALL(fstat)
 44b:	b8 08 00 00 00       	mov    $0x8,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	retq   

0000000000000453 <link>:
SYSCALL(link)
 453:	b8 13 00 00 00       	mov    $0x13,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	retq   

000000000000045b <mkdir>:
SYSCALL(mkdir)
 45b:	b8 14 00 00 00       	mov    $0x14,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	retq   

0000000000000463 <chdir>:
SYSCALL(chdir)
 463:	b8 09 00 00 00       	mov    $0x9,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	retq   

000000000000046b <dup>:
SYSCALL(dup)
 46b:	b8 0a 00 00 00       	mov    $0xa,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	retq   

0000000000000473 <getpid>:
SYSCALL(getpid)
 473:	b8 0b 00 00 00       	mov    $0xb,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	retq   

000000000000047b <sbrk>:
SYSCALL(sbrk)
 47b:	b8 0c 00 00 00       	mov    $0xc,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	retq   

0000000000000483 <sleep>:
SYSCALL(sleep)
 483:	b8 0d 00 00 00       	mov    $0xd,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	retq   

000000000000048b <uptime>:
SYSCALL(uptime)
 48b:	b8 0e 00 00 00       	mov    $0xe,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	retq   

0000000000000493 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 493:	55                   	push   %rbp
 494:	48 89 e5             	mov    %rsp,%rbp
 497:	48 83 ec 10          	sub    $0x10,%rsp
 49b:	89 7d fc             	mov    %edi,-0x4(%rbp)
 49e:	89 f0                	mov    %esi,%eax
 4a0:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 4a3:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 4a7:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4aa:	ba 01 00 00 00       	mov    $0x1,%edx
 4af:	48 89 ce             	mov    %rcx,%rsi
 4b2:	89 c7                	mov    %eax,%edi
 4b4:	e8 5a ff ff ff       	callq  413 <write>
}
 4b9:	90                   	nop
 4ba:	c9                   	leaveq 
 4bb:	c3                   	retq   

00000000000004bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4bc:	55                   	push   %rbp
 4bd:	48 89 e5             	mov    %rsp,%rbp
 4c0:	48 83 ec 30          	sub    $0x30,%rsp
 4c4:	89 7d dc             	mov    %edi,-0x24(%rbp)
 4c7:	89 75 d8             	mov    %esi,-0x28(%rbp)
 4ca:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 4cd:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4d0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 4d7:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 4db:	74 17                	je     4f4 <printint+0x38>
 4dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 4e1:	79 11                	jns    4f4 <printint+0x38>
    neg = 1;
 4e3:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 4ea:	8b 45 d8             	mov    -0x28(%rbp),%eax
 4ed:	f7 d8                	neg    %eax
 4ef:	89 45 f4             	mov    %eax,-0xc(%rbp)
 4f2:	eb 06                	jmp    4fa <printint+0x3e>
  } else {
    x = xx;
 4f4:	8b 45 d8             	mov    -0x28(%rbp),%eax
 4f7:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 4fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 501:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 504:	8b 45 f4             	mov    -0xc(%rbp),%eax
 507:	ba 00 00 00 00       	mov    $0x0,%edx
 50c:	f7 f1                	div    %ecx
 50e:	89 d1                	mov    %edx,%ecx
 510:	8b 45 fc             	mov    -0x4(%rbp),%eax
 513:	8d 50 01             	lea    0x1(%rax),%edx
 516:	89 55 fc             	mov    %edx,-0x4(%rbp)
 519:	89 ca                	mov    %ecx,%edx
 51b:	0f b6 92 20 0e 00 00 	movzbl 0xe20(%rdx),%edx
 522:	48 98                	cltq   
 524:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 528:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 52b:	8b 45 f4             	mov    -0xc(%rbp),%eax
 52e:	ba 00 00 00 00       	mov    $0x0,%edx
 533:	f7 f6                	div    %esi
 535:	89 45 f4             	mov    %eax,-0xc(%rbp)
 538:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 53c:	75 c3                	jne    501 <printint+0x45>
  if(neg)
 53e:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 542:	74 2b                	je     56f <printint+0xb3>
    buf[i++] = '-';
 544:	8b 45 fc             	mov    -0x4(%rbp),%eax
 547:	8d 50 01             	lea    0x1(%rax),%edx
 54a:	89 55 fc             	mov    %edx,-0x4(%rbp)
 54d:	48 98                	cltq   
 54f:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 554:	eb 19                	jmp    56f <printint+0xb3>
    putc(fd, buf[i]);
 556:	8b 45 fc             	mov    -0x4(%rbp),%eax
 559:	48 98                	cltq   
 55b:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 560:	0f be d0             	movsbl %al,%edx
 563:	8b 45 dc             	mov    -0x24(%rbp),%eax
 566:	89 d6                	mov    %edx,%esi
 568:	89 c7                	mov    %eax,%edi
 56a:	e8 24 ff ff ff       	callq  493 <putc>
  while(--i >= 0)
 56f:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 573:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 577:	79 dd                	jns    556 <printint+0x9a>
}
 579:	90                   	nop
 57a:	c9                   	leaveq 
 57b:	c3                   	retq   

000000000000057c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 57c:	55                   	push   %rbp
 57d:	48 89 e5             	mov    %rsp,%rbp
 580:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 587:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 58d:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 594:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 59b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 5a2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 5a9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 5b0:	84 c0                	test   %al,%al
 5b2:	74 20                	je     5d4 <printf+0x58>
 5b4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 5b8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 5bc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 5c0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 5c4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 5c8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 5cc:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 5d0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 5d4:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 5db:	00 00 00 
 5de:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 5e5:	00 00 00 
 5e8:	48 8d 45 10          	lea    0x10(%rbp),%rax
 5ec:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 5f3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 5fa:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 601:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 608:	00 00 00 
  for(i = 0; fmt[i]; i++){
 60b:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 612:	00 00 00 
 615:	e9 a8 02 00 00       	jmpq   8c2 <printf+0x346>
    c = fmt[i] & 0xff;
 61a:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 620:	48 63 d0             	movslq %eax,%rdx
 623:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 62a:	48 01 d0             	add    %rdx,%rax
 62d:	0f b6 00             	movzbl (%rax),%eax
 630:	0f be c0             	movsbl %al,%eax
 633:	25 ff 00 00 00       	and    $0xff,%eax
 638:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 63e:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 645:	75 35                	jne    67c <printf+0x100>
      if(c == '%'){
 647:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 64e:	75 0f                	jne    65f <printf+0xe3>
        state = '%';
 650:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 657:	00 00 00 
 65a:	e9 5c 02 00 00       	jmpq   8bb <printf+0x33f>
      } else {
        putc(fd, c);
 65f:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 665:	0f be d0             	movsbl %al,%edx
 668:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 66e:	89 d6                	mov    %edx,%esi
 670:	89 c7                	mov    %eax,%edi
 672:	e8 1c fe ff ff       	callq  493 <putc>
 677:	e9 3f 02 00 00       	jmpq   8bb <printf+0x33f>
      }
    } else if(state == '%'){
 67c:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 683:	0f 85 32 02 00 00    	jne    8bb <printf+0x33f>
      if(c == 'd'){
 689:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 690:	75 5e                	jne    6f0 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 692:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 698:	83 f8 2f             	cmp    $0x2f,%eax
 69b:	77 23                	ja     6c0 <printf+0x144>
 69d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6a4:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6aa:	89 d2                	mov    %edx,%edx
 6ac:	48 01 d0             	add    %rdx,%rax
 6af:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6b5:	83 c2 08             	add    $0x8,%edx
 6b8:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6be:	eb 12                	jmp    6d2 <printf+0x156>
 6c0:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6c7:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6cb:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6d2:	8b 30                	mov    (%rax),%esi
 6d4:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6da:	b9 01 00 00 00       	mov    $0x1,%ecx
 6df:	ba 0a 00 00 00       	mov    $0xa,%edx
 6e4:	89 c7                	mov    %eax,%edi
 6e6:	e8 d1 fd ff ff       	callq  4bc <printint>
 6eb:	e9 c1 01 00 00       	jmpq   8b1 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 6f0:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 6f7:	74 09                	je     702 <printf+0x186>
 6f9:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 700:	75 5e                	jne    760 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 702:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 708:	83 f8 2f             	cmp    $0x2f,%eax
 70b:	77 23                	ja     730 <printf+0x1b4>
 70d:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 714:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 71a:	89 d2                	mov    %edx,%edx
 71c:	48 01 d0             	add    %rdx,%rax
 71f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 725:	83 c2 08             	add    $0x8,%edx
 728:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 72e:	eb 12                	jmp    742 <printf+0x1c6>
 730:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 737:	48 8d 50 08          	lea    0x8(%rax),%rdx
 73b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 742:	8b 30                	mov    (%rax),%esi
 744:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 74a:	b9 00 00 00 00       	mov    $0x0,%ecx
 74f:	ba 10 00 00 00       	mov    $0x10,%edx
 754:	89 c7                	mov    %eax,%edi
 756:	e8 61 fd ff ff       	callq  4bc <printint>
 75b:	e9 51 01 00 00       	jmpq   8b1 <printf+0x335>
      } else if(c == 's'){
 760:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 767:	0f 85 98 00 00 00    	jne    805 <printf+0x289>
        s = va_arg(ap, char*);
 76d:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 773:	83 f8 2f             	cmp    $0x2f,%eax
 776:	77 23                	ja     79b <printf+0x21f>
 778:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 77f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 785:	89 d2                	mov    %edx,%edx
 787:	48 01 d0             	add    %rdx,%rax
 78a:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 790:	83 c2 08             	add    $0x8,%edx
 793:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 799:	eb 12                	jmp    7ad <printf+0x231>
 79b:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7a2:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7a6:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7ad:	48 8b 00             	mov    (%rax),%rax
 7b0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 7b7:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 7be:	00 
 7bf:	75 31                	jne    7f2 <printf+0x276>
          s = "(null)";
 7c1:	48 c7 85 48 ff ff ff 	movq   $0xbd1,-0xb8(%rbp)
 7c8:	d1 0b 00 00 
        while(*s != 0){
 7cc:	eb 24                	jmp    7f2 <printf+0x276>
          putc(fd, *s);
 7ce:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 7d5:	0f b6 00             	movzbl (%rax),%eax
 7d8:	0f be d0             	movsbl %al,%edx
 7db:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7e1:	89 d6                	mov    %edx,%esi
 7e3:	89 c7                	mov    %eax,%edi
 7e5:	e8 a9 fc ff ff       	callq  493 <putc>
          s++;
 7ea:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 7f1:	01 
        while(*s != 0){
 7f2:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 7f9:	0f b6 00             	movzbl (%rax),%eax
 7fc:	84 c0                	test   %al,%al
 7fe:	75 ce                	jne    7ce <printf+0x252>
 800:	e9 ac 00 00 00       	jmpq   8b1 <printf+0x335>
        }
      } else if(c == 'c'){
 805:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 80c:	75 56                	jne    864 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 80e:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 814:	83 f8 2f             	cmp    $0x2f,%eax
 817:	77 23                	ja     83c <printf+0x2c0>
 819:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 820:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 826:	89 d2                	mov    %edx,%edx
 828:	48 01 d0             	add    %rdx,%rax
 82b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 831:	83 c2 08             	add    $0x8,%edx
 834:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 83a:	eb 12                	jmp    84e <printf+0x2d2>
 83c:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 843:	48 8d 50 08          	lea    0x8(%rax),%rdx
 847:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 84e:	8b 00                	mov    (%rax),%eax
 850:	0f be d0             	movsbl %al,%edx
 853:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 859:	89 d6                	mov    %edx,%esi
 85b:	89 c7                	mov    %eax,%edi
 85d:	e8 31 fc ff ff       	callq  493 <putc>
 862:	eb 4d                	jmp    8b1 <printf+0x335>
      } else if(c == '%'){
 864:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 86b:	75 1a                	jne    887 <printf+0x30b>
        putc(fd, c);
 86d:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 873:	0f be d0             	movsbl %al,%edx
 876:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 87c:	89 d6                	mov    %edx,%esi
 87e:	89 c7                	mov    %eax,%edi
 880:	e8 0e fc ff ff       	callq  493 <putc>
 885:	eb 2a                	jmp    8b1 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 887:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 88d:	be 25 00 00 00       	mov    $0x25,%esi
 892:	89 c7                	mov    %eax,%edi
 894:	e8 fa fb ff ff       	callq  493 <putc>
        putc(fd, c);
 899:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 89f:	0f be d0             	movsbl %al,%edx
 8a2:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 8a8:	89 d6                	mov    %edx,%esi
 8aa:	89 c7                	mov    %eax,%edi
 8ac:	e8 e2 fb ff ff       	callq  493 <putc>
      }
      state = 0;
 8b1:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 8b8:	00 00 00 
  for(i = 0; fmt[i]; i++){
 8bb:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 8c2:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 8c8:	48 63 d0             	movslq %eax,%rdx
 8cb:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 8d2:	48 01 d0             	add    %rdx,%rax
 8d5:	0f b6 00             	movzbl (%rax),%eax
 8d8:	84 c0                	test   %al,%al
 8da:	0f 85 3a fd ff ff    	jne    61a <printf+0x9e>
    }
  }
}
 8e0:	90                   	nop
 8e1:	c9                   	leaveq 
 8e2:	c3                   	retq   

00000000000008e3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e3:	55                   	push   %rbp
 8e4:	48 89 e5             	mov    %rsp,%rbp
 8e7:	48 83 ec 18          	sub    $0x18,%rsp
 8eb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 8f3:	48 83 e8 10          	sub    $0x10,%rax
 8f7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fb:	48 8b 05 4e 05 00 00 	mov    0x54e(%rip),%rax        # e50 <freep>
 902:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 906:	eb 2f                	jmp    937 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 908:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 90c:	48 8b 00             	mov    (%rax),%rax
 90f:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 913:	72 17                	jb     92c <free+0x49>
 915:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 919:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 91d:	77 2f                	ja     94e <free+0x6b>
 91f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 923:	48 8b 00             	mov    (%rax),%rax
 926:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 92a:	72 22                	jb     94e <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 930:	48 8b 00             	mov    (%rax),%rax
 933:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 937:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 93b:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 93f:	76 c7                	jbe    908 <free+0x25>
 941:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 945:	48 8b 00             	mov    (%rax),%rax
 948:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 94c:	73 ba                	jae    908 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 94e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 952:	8b 40 08             	mov    0x8(%rax),%eax
 955:	89 c0                	mov    %eax,%eax
 957:	48 c1 e0 04          	shl    $0x4,%rax
 95b:	48 89 c2             	mov    %rax,%rdx
 95e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 962:	48 01 c2             	add    %rax,%rdx
 965:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 969:	48 8b 00             	mov    (%rax),%rax
 96c:	48 39 c2             	cmp    %rax,%rdx
 96f:	75 2d                	jne    99e <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 971:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 975:	8b 50 08             	mov    0x8(%rax),%edx
 978:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 97c:	48 8b 00             	mov    (%rax),%rax
 97f:	8b 40 08             	mov    0x8(%rax),%eax
 982:	01 c2                	add    %eax,%edx
 984:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 988:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 98b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 98f:	48 8b 00             	mov    (%rax),%rax
 992:	48 8b 10             	mov    (%rax),%rdx
 995:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 999:	48 89 10             	mov    %rdx,(%rax)
 99c:	eb 0e                	jmp    9ac <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 99e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9a2:	48 8b 10             	mov    (%rax),%rdx
 9a5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9a9:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 9ac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9b0:	8b 40 08             	mov    0x8(%rax),%eax
 9b3:	89 c0                	mov    %eax,%eax
 9b5:	48 c1 e0 04          	shl    $0x4,%rax
 9b9:	48 89 c2             	mov    %rax,%rdx
 9bc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9c0:	48 01 d0             	add    %rdx,%rax
 9c3:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 9c7:	75 27                	jne    9f0 <free+0x10d>
    p->s.size += bp->s.size;
 9c9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9cd:	8b 50 08             	mov    0x8(%rax),%edx
 9d0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9d4:	8b 40 08             	mov    0x8(%rax),%eax
 9d7:	01 c2                	add    %eax,%edx
 9d9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9dd:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 9e0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9e4:	48 8b 10             	mov    (%rax),%rdx
 9e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9eb:	48 89 10             	mov    %rdx,(%rax)
 9ee:	eb 0b                	jmp    9fb <free+0x118>
  } else
    p->s.ptr = bp;
 9f0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9f4:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 9f8:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 9fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9ff:	48 89 05 4a 04 00 00 	mov    %rax,0x44a(%rip)        # e50 <freep>
}
 a06:	90                   	nop
 a07:	c9                   	leaveq 
 a08:	c3                   	retq   

0000000000000a09 <morecore>:

static Header*
morecore(uint nu)
{
 a09:	55                   	push   %rbp
 a0a:	48 89 e5             	mov    %rsp,%rbp
 a0d:	48 83 ec 20          	sub    $0x20,%rsp
 a11:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 a14:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 a1b:	77 07                	ja     a24 <morecore+0x1b>
    nu = 4096;
 a1d:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 a24:	8b 45 ec             	mov    -0x14(%rbp),%eax
 a27:	c1 e0 04             	shl    $0x4,%eax
 a2a:	89 c7                	mov    %eax,%edi
 a2c:	e8 4a fa ff ff       	callq  47b <sbrk>
 a31:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 a35:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 a3a:	75 07                	jne    a43 <morecore+0x3a>
    return 0;
 a3c:	b8 00 00 00 00       	mov    $0x0,%eax
 a41:	eb 29                	jmp    a6c <morecore+0x63>
  hp = (Header*)p;
 a43:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a47:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 a4b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a4f:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a52:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 a55:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a59:	48 83 c0 10          	add    $0x10,%rax
 a5d:	48 89 c7             	mov    %rax,%rdi
 a60:	e8 7e fe ff ff       	callq  8e3 <free>
  return freep;
 a65:	48 8b 05 e4 03 00 00 	mov    0x3e4(%rip),%rax        # e50 <freep>
}
 a6c:	c9                   	leaveq 
 a6d:	c3                   	retq   

0000000000000a6e <malloc>:

void*
malloc(uint nbytes)
{
 a6e:	55                   	push   %rbp
 a6f:	48 89 e5             	mov    %rsp,%rbp
 a72:	48 83 ec 30          	sub    $0x30,%rsp
 a76:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a79:	8b 45 dc             	mov    -0x24(%rbp),%eax
 a7c:	48 83 c0 0f          	add    $0xf,%rax
 a80:	48 c1 e8 04          	shr    $0x4,%rax
 a84:	83 c0 01             	add    $0x1,%eax
 a87:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 a8a:	48 8b 05 bf 03 00 00 	mov    0x3bf(%rip),%rax        # e50 <freep>
 a91:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a95:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 a9a:	75 2b                	jne    ac7 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 a9c:	48 c7 45 f0 40 0e 00 	movq   $0xe40,-0x10(%rbp)
 aa3:	00 
 aa4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 aa8:	48 89 05 a1 03 00 00 	mov    %rax,0x3a1(%rip)        # e50 <freep>
 aaf:	48 8b 05 9a 03 00 00 	mov    0x39a(%rip),%rax        # e50 <freep>
 ab6:	48 89 05 83 03 00 00 	mov    %rax,0x383(%rip)        # e40 <base>
    base.s.size = 0;
 abd:	c7 05 81 03 00 00 00 	movl   $0x0,0x381(%rip)        # e48 <base+0x8>
 ac4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 acb:	48 8b 00             	mov    (%rax),%rax
 ace:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 ad2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ad6:	8b 40 08             	mov    0x8(%rax),%eax
 ad9:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 adc:	77 5f                	ja     b3d <malloc+0xcf>
      if(p->s.size == nunits)
 ade:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ae2:	8b 40 08             	mov    0x8(%rax),%eax
 ae5:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 ae8:	75 10                	jne    afa <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 aea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aee:	48 8b 10             	mov    (%rax),%rdx
 af1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 af5:	48 89 10             	mov    %rdx,(%rax)
 af8:	eb 2e                	jmp    b28 <malloc+0xba>
      else {
        p->s.size -= nunits;
 afa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 afe:	8b 40 08             	mov    0x8(%rax),%eax
 b01:	2b 45 ec             	sub    -0x14(%rbp),%eax
 b04:	89 c2                	mov    %eax,%edx
 b06:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b0a:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 b0d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b11:	8b 40 08             	mov    0x8(%rax),%eax
 b14:	89 c0                	mov    %eax,%eax
 b16:	48 c1 e0 04          	shl    $0x4,%rax
 b1a:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 b1e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b22:	8b 55 ec             	mov    -0x14(%rbp),%edx
 b25:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 b28:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b2c:	48 89 05 1d 03 00 00 	mov    %rax,0x31d(%rip)        # e50 <freep>
      return (void*)(p + 1);
 b33:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b37:	48 83 c0 10          	add    $0x10,%rax
 b3b:	eb 41                	jmp    b7e <malloc+0x110>
    }
    if(p == freep)
 b3d:	48 8b 05 0c 03 00 00 	mov    0x30c(%rip),%rax        # e50 <freep>
 b44:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 b48:	75 1c                	jne    b66 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 b4a:	8b 45 ec             	mov    -0x14(%rbp),%eax
 b4d:	89 c7                	mov    %eax,%edi
 b4f:	e8 b5 fe ff ff       	callq  a09 <morecore>
 b54:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 b58:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 b5d:	75 07                	jne    b66 <malloc+0xf8>
        return 0;
 b5f:	b8 00 00 00 00       	mov    $0x0,%eax
 b64:	eb 18                	jmp    b7e <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b66:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b6a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 b6e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b72:	48 8b 00             	mov    (%rax),%rax
 b75:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 b79:	e9 54 ff ff ff       	jmpq   ad2 <malloc+0x64>
  }
}
 b7e:	c9                   	leaveq 
 b7f:	c3                   	retq   
