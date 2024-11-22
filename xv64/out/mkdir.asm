
fs/mkdir:     file format elf64-x86-64


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

  if(argc < 2){
   f:	83 7d ec 01          	cmpl   $0x1,-0x14(%rbp)
  13:	7f 1b                	jg     30 <main+0x30>
    printf(2, "Usage: mkdir files...\n");
  15:	48 c7 c6 1f 0b 00 00 	mov    $0xb1f,%rsi
  1c:	bf 02 00 00 00       	mov    $0x2,%edi
  21:	b8 00 00 00 00       	mov    $0x0,%eax
  26:	e8 f0 04 00 00       	callq  51b <printf>
    exit();
  2b:	e8 62 03 00 00       	callq  392 <exit>
  }

  for(i = 1; i < argc; i++){
  30:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  37:	eb 59                	jmp    92 <main+0x92>
    if(mkdir(argv[i]) < 0){
  39:	8b 45 fc             	mov    -0x4(%rbp),%eax
  3c:	48 98                	cltq   
  3e:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  45:	00 
  46:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4a:	48 01 d0             	add    %rdx,%rax
  4d:	48 8b 00             	mov    (%rax),%rax
  50:	48 89 c7             	mov    %rax,%rdi
  53:	e8 a2 03 00 00       	callq  3fa <mkdir>
  58:	85 c0                	test   %eax,%eax
  5a:	79 32                	jns    8e <main+0x8e>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  5c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  5f:	48 98                	cltq   
  61:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  68:	00 
  69:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  6d:	48 01 d0             	add    %rdx,%rax
  70:	48 8b 00             	mov    (%rax),%rax
  73:	48 89 c2             	mov    %rax,%rdx
  76:	48 c7 c6 36 0b 00 00 	mov    $0xb36,%rsi
  7d:	bf 02 00 00 00       	mov    $0x2,%edi
  82:	b8 00 00 00 00       	mov    $0x0,%eax
  87:	e8 8f 04 00 00       	callq  51b <printf>
      break;
  8c:	eb 0c                	jmp    9a <main+0x9a>
  for(i = 1; i < argc; i++){
  8e:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  92:	8b 45 fc             	mov    -0x4(%rbp),%eax
  95:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  98:	7c 9f                	jl     39 <main+0x39>
    }
  }

  exit();
  9a:	e8 f3 02 00 00       	callq  392 <exit>

000000000000009f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  9f:	55                   	push   %rbp
  a0:	48 89 e5             	mov    %rsp,%rbp
  a3:	48 83 ec 10          	sub    $0x10,%rsp
  a7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  ab:	89 75 f4             	mov    %esi,-0xc(%rbp)
  ae:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
  b1:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  b5:	8b 55 f0             	mov    -0x10(%rbp),%edx
  b8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  bb:	48 89 ce             	mov    %rcx,%rsi
  be:	48 89 f7             	mov    %rsi,%rdi
  c1:	89 d1                	mov    %edx,%ecx
  c3:	fc                   	cld    
  c4:	f3 aa                	rep stos %al,%es:(%rdi)
  c6:	89 ca                	mov    %ecx,%edx
  c8:	48 89 fe             	mov    %rdi,%rsi
  cb:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
  cf:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  d2:	90                   	nop
  d3:	c9                   	leaveq 
  d4:	c3                   	retq   

00000000000000d5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d5:	55                   	push   %rbp
  d6:	48 89 e5             	mov    %rsp,%rbp
  d9:	48 83 ec 20          	sub    $0x20,%rsp
  dd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  e1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
  e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  e9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
  ed:	90                   	nop
  ee:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  f2:	48 8d 42 01          	lea    0x1(%rdx),%rax
  f6:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  fa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  fe:	48 8d 48 01          	lea    0x1(%rax),%rcx
 102:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 106:	0f b6 12             	movzbl (%rdx),%edx
 109:	88 10                	mov    %dl,(%rax)
 10b:	0f b6 00             	movzbl (%rax),%eax
 10e:	84 c0                	test   %al,%al
 110:	75 dc                	jne    ee <strcpy+0x19>
    ;
  return os;
 112:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 116:	c9                   	leaveq 
 117:	c3                   	retq   

0000000000000118 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 118:	55                   	push   %rbp
 119:	48 89 e5             	mov    %rsp,%rbp
 11c:	48 83 ec 10          	sub    $0x10,%rsp
 120:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 124:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 128:	eb 0a                	jmp    134 <strcmp+0x1c>
    p++, q++;
 12a:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 12f:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 134:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 138:	0f b6 00             	movzbl (%rax),%eax
 13b:	84 c0                	test   %al,%al
 13d:	74 12                	je     151 <strcmp+0x39>
 13f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 143:	0f b6 10             	movzbl (%rax),%edx
 146:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 14a:	0f b6 00             	movzbl (%rax),%eax
 14d:	38 c2                	cmp    %al,%dl
 14f:	74 d9                	je     12a <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 151:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 155:	0f b6 00             	movzbl (%rax),%eax
 158:	0f b6 d0             	movzbl %al,%edx
 15b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 15f:	0f b6 00             	movzbl (%rax),%eax
 162:	0f b6 c0             	movzbl %al,%eax
 165:	29 c2                	sub    %eax,%edx
 167:	89 d0                	mov    %edx,%eax
}
 169:	c9                   	leaveq 
 16a:	c3                   	retq   

000000000000016b <strlen>:

uint
strlen(char *s)
{
 16b:	55                   	push   %rbp
 16c:	48 89 e5             	mov    %rsp,%rbp
 16f:	48 83 ec 18          	sub    $0x18,%rsp
 173:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 177:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 17e:	eb 04                	jmp    184 <strlen+0x19>
 180:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 184:	8b 45 fc             	mov    -0x4(%rbp),%eax
 187:	48 63 d0             	movslq %eax,%rdx
 18a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 18e:	48 01 d0             	add    %rdx,%rax
 191:	0f b6 00             	movzbl (%rax),%eax
 194:	84 c0                	test   %al,%al
 196:	75 e8                	jne    180 <strlen+0x15>
    ;
  return n;
 198:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 19b:	c9                   	leaveq 
 19c:	c3                   	retq   

000000000000019d <memset>:

void*
memset(void *dst, int c, uint n)
{
 19d:	55                   	push   %rbp
 19e:	48 89 e5             	mov    %rsp,%rbp
 1a1:	48 83 ec 10          	sub    $0x10,%rsp
 1a5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1a9:	89 75 f4             	mov    %esi,-0xc(%rbp)
 1ac:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 1af:	8b 55 f0             	mov    -0x10(%rbp),%edx
 1b2:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 1b5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1b9:	89 ce                	mov    %ecx,%esi
 1bb:	48 89 c7             	mov    %rax,%rdi
 1be:	e8 dc fe ff ff       	callq  9f <stosb>
  return dst;
 1c3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 1c7:	c9                   	leaveq 
 1c8:	c3                   	retq   

00000000000001c9 <strchr>:

char*
strchr(const char *s, char c)
{
 1c9:	55                   	push   %rbp
 1ca:	48 89 e5             	mov    %rsp,%rbp
 1cd:	48 83 ec 10          	sub    $0x10,%rsp
 1d1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1d5:	89 f0                	mov    %esi,%eax
 1d7:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 1da:	eb 17                	jmp    1f3 <strchr+0x2a>
    if(*s == c)
 1dc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1e0:	0f b6 00             	movzbl (%rax),%eax
 1e3:	38 45 f4             	cmp    %al,-0xc(%rbp)
 1e6:	75 06                	jne    1ee <strchr+0x25>
      return (char*)s;
 1e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1ec:	eb 15                	jmp    203 <strchr+0x3a>
  for(; *s; s++)
 1ee:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 1f3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1f7:	0f b6 00             	movzbl (%rax),%eax
 1fa:	84 c0                	test   %al,%al
 1fc:	75 de                	jne    1dc <strchr+0x13>
  return 0;
 1fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
 203:	c9                   	leaveq 
 204:	c3                   	retq   

0000000000000205 <gets>:

char*
gets(char *buf, int max)
{
 205:	55                   	push   %rbp
 206:	48 89 e5             	mov    %rsp,%rbp
 209:	48 83 ec 20          	sub    $0x20,%rsp
 20d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 211:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 214:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 21b:	eb 48                	jmp    265 <gets+0x60>
    cc = read(0, &c, 1);
 21d:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 221:	ba 01 00 00 00       	mov    $0x1,%edx
 226:	48 89 c6             	mov    %rax,%rsi
 229:	bf 00 00 00 00       	mov    $0x0,%edi
 22e:	e8 77 01 00 00       	callq  3aa <read>
 233:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 236:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 23a:	7e 36                	jle    272 <gets+0x6d>
      break;
    buf[i++] = c;
 23c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 23f:	8d 50 01             	lea    0x1(%rax),%edx
 242:	89 55 fc             	mov    %edx,-0x4(%rbp)
 245:	48 63 d0             	movslq %eax,%rdx
 248:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 24c:	48 01 c2             	add    %rax,%rdx
 24f:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 253:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 255:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 259:	3c 0a                	cmp    $0xa,%al
 25b:	74 16                	je     273 <gets+0x6e>
 25d:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 261:	3c 0d                	cmp    $0xd,%al
 263:	74 0e                	je     273 <gets+0x6e>
  for(i=0; i+1 < max; ){
 265:	8b 45 fc             	mov    -0x4(%rbp),%eax
 268:	83 c0 01             	add    $0x1,%eax
 26b:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 26e:	7f ad                	jg     21d <gets+0x18>
 270:	eb 01                	jmp    273 <gets+0x6e>
      break;
 272:	90                   	nop
      break;
  }
  buf[i] = '\0';
 273:	8b 45 fc             	mov    -0x4(%rbp),%eax
 276:	48 63 d0             	movslq %eax,%rdx
 279:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 27d:	48 01 d0             	add    %rdx,%rax
 280:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 283:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 287:	c9                   	leaveq 
 288:	c3                   	retq   

0000000000000289 <stat>:

int
stat(char *n, struct stat *st)
{
 289:	55                   	push   %rbp
 28a:	48 89 e5             	mov    %rsp,%rbp
 28d:	48 83 ec 20          	sub    $0x20,%rsp
 291:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 295:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 299:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 29d:	be 00 00 00 00       	mov    $0x0,%esi
 2a2:	48 89 c7             	mov    %rax,%rdi
 2a5:	e8 28 01 00 00       	callq  3d2 <open>
 2aa:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 2ad:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 2b1:	79 07                	jns    2ba <stat+0x31>
    return -1;
 2b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b8:	eb 21                	jmp    2db <stat+0x52>
  r = fstat(fd, st);
 2ba:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 2be:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2c1:	48 89 d6             	mov    %rdx,%rsi
 2c4:	89 c7                	mov    %eax,%edi
 2c6:	e8 1f 01 00 00       	callq  3ea <fstat>
 2cb:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 2ce:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2d1:	89 c7                	mov    %eax,%edi
 2d3:	e8 e2 00 00 00       	callq  3ba <close>
  return r;
 2d8:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 2db:	c9                   	leaveq 
 2dc:	c3                   	retq   

00000000000002dd <atoi>:

int
atoi(const char *s)
{
 2dd:	55                   	push   %rbp
 2de:	48 89 e5             	mov    %rsp,%rbp
 2e1:	48 83 ec 18          	sub    $0x18,%rsp
 2e5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 2e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 2f0:	eb 28                	jmp    31a <atoi+0x3d>
    n = n*10 + *s++ - '0';
 2f2:	8b 55 fc             	mov    -0x4(%rbp),%edx
 2f5:	89 d0                	mov    %edx,%eax
 2f7:	c1 e0 02             	shl    $0x2,%eax
 2fa:	01 d0                	add    %edx,%eax
 2fc:	01 c0                	add    %eax,%eax
 2fe:	89 c1                	mov    %eax,%ecx
 300:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 304:	48 8d 50 01          	lea    0x1(%rax),%rdx
 308:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 30c:	0f b6 00             	movzbl (%rax),%eax
 30f:	0f be c0             	movsbl %al,%eax
 312:	01 c8                	add    %ecx,%eax
 314:	83 e8 30             	sub    $0x30,%eax
 317:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 31a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 31e:	0f b6 00             	movzbl (%rax),%eax
 321:	3c 2f                	cmp    $0x2f,%al
 323:	7e 0b                	jle    330 <atoi+0x53>
 325:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 329:	0f b6 00             	movzbl (%rax),%eax
 32c:	3c 39                	cmp    $0x39,%al
 32e:	7e c2                	jle    2f2 <atoi+0x15>
  return n;
 330:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 333:	c9                   	leaveq 
 334:	c3                   	retq   

0000000000000335 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 335:	55                   	push   %rbp
 336:	48 89 e5             	mov    %rsp,%rbp
 339:	48 83 ec 28          	sub    $0x28,%rsp
 33d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 341:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 345:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 348:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 34c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 350:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 354:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 358:	eb 1d                	jmp    377 <memmove+0x42>
    *dst++ = *src++;
 35a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 35e:	48 8d 42 01          	lea    0x1(%rdx),%rax
 362:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 366:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 36a:	48 8d 48 01          	lea    0x1(%rax),%rcx
 36e:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 372:	0f b6 12             	movzbl (%rdx),%edx
 375:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 377:	8b 45 dc             	mov    -0x24(%rbp),%eax
 37a:	8d 50 ff             	lea    -0x1(%rax),%edx
 37d:	89 55 dc             	mov    %edx,-0x24(%rbp)
 380:	85 c0                	test   %eax,%eax
 382:	7f d6                	jg     35a <memmove+0x25>
  return vdst;
 384:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 388:	c9                   	leaveq 
 389:	c3                   	retq   

000000000000038a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 38a:	b8 01 00 00 00       	mov    $0x1,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	retq   

0000000000000392 <exit>:
SYSCALL(exit)
 392:	b8 02 00 00 00       	mov    $0x2,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	retq   

000000000000039a <wait>:
SYSCALL(wait)
 39a:	b8 03 00 00 00       	mov    $0x3,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	retq   

00000000000003a2 <pipe>:
SYSCALL(pipe)
 3a2:	b8 04 00 00 00       	mov    $0x4,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	retq   

00000000000003aa <read>:
SYSCALL(read)
 3aa:	b8 05 00 00 00       	mov    $0x5,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	retq   

00000000000003b2 <write>:
SYSCALL(write)
 3b2:	b8 10 00 00 00       	mov    $0x10,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	retq   

00000000000003ba <close>:
SYSCALL(close)
 3ba:	b8 15 00 00 00       	mov    $0x15,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	retq   

00000000000003c2 <kill>:
SYSCALL(kill)
 3c2:	b8 06 00 00 00       	mov    $0x6,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	retq   

00000000000003ca <exec>:
SYSCALL(exec)
 3ca:	b8 07 00 00 00       	mov    $0x7,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	retq   

00000000000003d2 <open>:
SYSCALL(open)
 3d2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	retq   

00000000000003da <mknod>:
SYSCALL(mknod)
 3da:	b8 11 00 00 00       	mov    $0x11,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	retq   

00000000000003e2 <unlink>:
SYSCALL(unlink)
 3e2:	b8 12 00 00 00       	mov    $0x12,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	retq   

00000000000003ea <fstat>:
SYSCALL(fstat)
 3ea:	b8 08 00 00 00       	mov    $0x8,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	retq   

00000000000003f2 <link>:
SYSCALL(link)
 3f2:	b8 13 00 00 00       	mov    $0x13,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	retq   

00000000000003fa <mkdir>:
SYSCALL(mkdir)
 3fa:	b8 14 00 00 00       	mov    $0x14,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	retq   

0000000000000402 <chdir>:
SYSCALL(chdir)
 402:	b8 09 00 00 00       	mov    $0x9,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	retq   

000000000000040a <dup>:
SYSCALL(dup)
 40a:	b8 0a 00 00 00       	mov    $0xa,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	retq   

0000000000000412 <getpid>:
SYSCALL(getpid)
 412:	b8 0b 00 00 00       	mov    $0xb,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	retq   

000000000000041a <sbrk>:
SYSCALL(sbrk)
 41a:	b8 0c 00 00 00       	mov    $0xc,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	retq   

0000000000000422 <sleep>:
SYSCALL(sleep)
 422:	b8 0d 00 00 00       	mov    $0xd,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	retq   

000000000000042a <uptime>:
SYSCALL(uptime)
 42a:	b8 0e 00 00 00       	mov    $0xe,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	retq   

0000000000000432 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 432:	55                   	push   %rbp
 433:	48 89 e5             	mov    %rsp,%rbp
 436:	48 83 ec 10          	sub    $0x10,%rsp
 43a:	89 7d fc             	mov    %edi,-0x4(%rbp)
 43d:	89 f0                	mov    %esi,%eax
 43f:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 442:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 446:	8b 45 fc             	mov    -0x4(%rbp),%eax
 449:	ba 01 00 00 00       	mov    $0x1,%edx
 44e:	48 89 ce             	mov    %rcx,%rsi
 451:	89 c7                	mov    %eax,%edi
 453:	e8 5a ff ff ff       	callq  3b2 <write>
}
 458:	90                   	nop
 459:	c9                   	leaveq 
 45a:	c3                   	retq   

000000000000045b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45b:	55                   	push   %rbp
 45c:	48 89 e5             	mov    %rsp,%rbp
 45f:	48 83 ec 30          	sub    $0x30,%rsp
 463:	89 7d dc             	mov    %edi,-0x24(%rbp)
 466:	89 75 d8             	mov    %esi,-0x28(%rbp)
 469:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 46c:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 46f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 476:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 47a:	74 17                	je     493 <printint+0x38>
 47c:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 480:	79 11                	jns    493 <printint+0x38>
    neg = 1;
 482:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 489:	8b 45 d8             	mov    -0x28(%rbp),%eax
 48c:	f7 d8                	neg    %eax
 48e:	89 45 f4             	mov    %eax,-0xc(%rbp)
 491:	eb 06                	jmp    499 <printint+0x3e>
  } else {
    x = xx;
 493:	8b 45 d8             	mov    -0x28(%rbp),%eax
 496:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 499:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 4a0:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 4a3:	8b 45 f4             	mov    -0xc(%rbp),%eax
 4a6:	ba 00 00 00 00       	mov    $0x0,%edx
 4ab:	f7 f1                	div    %ecx
 4ad:	89 d1                	mov    %edx,%ecx
 4af:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4b2:	8d 50 01             	lea    0x1(%rax),%edx
 4b5:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4b8:	89 ca                	mov    %ecx,%edx
 4ba:	0f b6 92 a0 0d 00 00 	movzbl 0xda0(%rdx),%edx
 4c1:	48 98                	cltq   
 4c3:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 4c7:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 4ca:	8b 45 f4             	mov    -0xc(%rbp),%eax
 4cd:	ba 00 00 00 00       	mov    $0x0,%edx
 4d2:	f7 f6                	div    %esi
 4d4:	89 45 f4             	mov    %eax,-0xc(%rbp)
 4d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 4db:	75 c3                	jne    4a0 <printint+0x45>
  if(neg)
 4dd:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 4e1:	74 2b                	je     50e <printint+0xb3>
    buf[i++] = '-';
 4e3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4e6:	8d 50 01             	lea    0x1(%rax),%edx
 4e9:	89 55 fc             	mov    %edx,-0x4(%rbp)
 4ec:	48 98                	cltq   
 4ee:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 4f3:	eb 19                	jmp    50e <printint+0xb3>
    putc(fd, buf[i]);
 4f5:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4f8:	48 98                	cltq   
 4fa:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 4ff:	0f be d0             	movsbl %al,%edx
 502:	8b 45 dc             	mov    -0x24(%rbp),%eax
 505:	89 d6                	mov    %edx,%esi
 507:	89 c7                	mov    %eax,%edi
 509:	e8 24 ff ff ff       	callq  432 <putc>
  while(--i >= 0)
 50e:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 512:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 516:	79 dd                	jns    4f5 <printint+0x9a>
}
 518:	90                   	nop
 519:	c9                   	leaveq 
 51a:	c3                   	retq   

000000000000051b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 51b:	55                   	push   %rbp
 51c:	48 89 e5             	mov    %rsp,%rbp
 51f:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 526:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 52c:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 533:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 53a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 541:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 548:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 54f:	84 c0                	test   %al,%al
 551:	74 20                	je     573 <printf+0x58>
 553:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 557:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 55b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 55f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 563:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 567:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 56b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 56f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 573:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 57a:	00 00 00 
 57d:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 584:	00 00 00 
 587:	48 8d 45 10          	lea    0x10(%rbp),%rax
 58b:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 592:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 599:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 5a0:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 5a7:	00 00 00 
  for(i = 0; fmt[i]; i++){
 5aa:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 5b1:	00 00 00 
 5b4:	e9 a8 02 00 00       	jmpq   861 <printf+0x346>
    c = fmt[i] & 0xff;
 5b9:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 5bf:	48 63 d0             	movslq %eax,%rdx
 5c2:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 5c9:	48 01 d0             	add    %rdx,%rax
 5cc:	0f b6 00             	movzbl (%rax),%eax
 5cf:	0f be c0             	movsbl %al,%eax
 5d2:	25 ff 00 00 00       	and    $0xff,%eax
 5d7:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 5dd:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 5e4:	75 35                	jne    61b <printf+0x100>
      if(c == '%'){
 5e6:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 5ed:	75 0f                	jne    5fe <printf+0xe3>
        state = '%';
 5ef:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 5f6:	00 00 00 
 5f9:	e9 5c 02 00 00       	jmpq   85a <printf+0x33f>
      } else {
        putc(fd, c);
 5fe:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 604:	0f be d0             	movsbl %al,%edx
 607:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 60d:	89 d6                	mov    %edx,%esi
 60f:	89 c7                	mov    %eax,%edi
 611:	e8 1c fe ff ff       	callq  432 <putc>
 616:	e9 3f 02 00 00       	jmpq   85a <printf+0x33f>
      }
    } else if(state == '%'){
 61b:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 622:	0f 85 32 02 00 00    	jne    85a <printf+0x33f>
      if(c == 'd'){
 628:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 62f:	75 5e                	jne    68f <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 631:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 637:	83 f8 2f             	cmp    $0x2f,%eax
 63a:	77 23                	ja     65f <printf+0x144>
 63c:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 643:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 649:	89 d2                	mov    %edx,%edx
 64b:	48 01 d0             	add    %rdx,%rax
 64e:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 654:	83 c2 08             	add    $0x8,%edx
 657:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 65d:	eb 12                	jmp    671 <printf+0x156>
 65f:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 666:	48 8d 50 08          	lea    0x8(%rax),%rdx
 66a:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 671:	8b 30                	mov    (%rax),%esi
 673:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 679:	b9 01 00 00 00       	mov    $0x1,%ecx
 67e:	ba 0a 00 00 00       	mov    $0xa,%edx
 683:	89 c7                	mov    %eax,%edi
 685:	e8 d1 fd ff ff       	callq  45b <printint>
 68a:	e9 c1 01 00 00       	jmpq   850 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 68f:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 696:	74 09                	je     6a1 <printf+0x186>
 698:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 69f:	75 5e                	jne    6ff <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 6a1:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6a7:	83 f8 2f             	cmp    $0x2f,%eax
 6aa:	77 23                	ja     6cf <printf+0x1b4>
 6ac:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6b3:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6b9:	89 d2                	mov    %edx,%edx
 6bb:	48 01 d0             	add    %rdx,%rax
 6be:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6c4:	83 c2 08             	add    $0x8,%edx
 6c7:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6cd:	eb 12                	jmp    6e1 <printf+0x1c6>
 6cf:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6d6:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6da:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6e1:	8b 30                	mov    (%rax),%esi
 6e3:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6e9:	b9 00 00 00 00       	mov    $0x0,%ecx
 6ee:	ba 10 00 00 00       	mov    $0x10,%edx
 6f3:	89 c7                	mov    %eax,%edi
 6f5:	e8 61 fd ff ff       	callq  45b <printint>
 6fa:	e9 51 01 00 00       	jmpq   850 <printf+0x335>
      } else if(c == 's'){
 6ff:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 706:	0f 85 98 00 00 00    	jne    7a4 <printf+0x289>
        s = va_arg(ap, char*);
 70c:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 712:	83 f8 2f             	cmp    $0x2f,%eax
 715:	77 23                	ja     73a <printf+0x21f>
 717:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 71e:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 724:	89 d2                	mov    %edx,%edx
 726:	48 01 d0             	add    %rdx,%rax
 729:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 72f:	83 c2 08             	add    $0x8,%edx
 732:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 738:	eb 12                	jmp    74c <printf+0x231>
 73a:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 741:	48 8d 50 08          	lea    0x8(%rax),%rdx
 745:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 74c:	48 8b 00             	mov    (%rax),%rax
 74f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 756:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 75d:	00 
 75e:	75 31                	jne    791 <printf+0x276>
          s = "(null)";
 760:	48 c7 85 48 ff ff ff 	movq   $0xb52,-0xb8(%rbp)
 767:	52 0b 00 00 
        while(*s != 0){
 76b:	eb 24                	jmp    791 <printf+0x276>
          putc(fd, *s);
 76d:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 774:	0f b6 00             	movzbl (%rax),%eax
 777:	0f be d0             	movsbl %al,%edx
 77a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 780:	89 d6                	mov    %edx,%esi
 782:	89 c7                	mov    %eax,%edi
 784:	e8 a9 fc ff ff       	callq  432 <putc>
          s++;
 789:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 790:	01 
        while(*s != 0){
 791:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 798:	0f b6 00             	movzbl (%rax),%eax
 79b:	84 c0                	test   %al,%al
 79d:	75 ce                	jne    76d <printf+0x252>
 79f:	e9 ac 00 00 00       	jmpq   850 <printf+0x335>
        }
      } else if(c == 'c'){
 7a4:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 7ab:	75 56                	jne    803 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 7ad:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 7b3:	83 f8 2f             	cmp    $0x2f,%eax
 7b6:	77 23                	ja     7db <printf+0x2c0>
 7b8:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 7bf:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7c5:	89 d2                	mov    %edx,%edx
 7c7:	48 01 d0             	add    %rdx,%rax
 7ca:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7d0:	83 c2 08             	add    $0x8,%edx
 7d3:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7d9:	eb 12                	jmp    7ed <printf+0x2d2>
 7db:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7e2:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7e6:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7ed:	8b 00                	mov    (%rax),%eax
 7ef:	0f be d0             	movsbl %al,%edx
 7f2:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7f8:	89 d6                	mov    %edx,%esi
 7fa:	89 c7                	mov    %eax,%edi
 7fc:	e8 31 fc ff ff       	callq  432 <putc>
 801:	eb 4d                	jmp    850 <printf+0x335>
      } else if(c == '%'){
 803:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 80a:	75 1a                	jne    826 <printf+0x30b>
        putc(fd, c);
 80c:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 812:	0f be d0             	movsbl %al,%edx
 815:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 81b:	89 d6                	mov    %edx,%esi
 81d:	89 c7                	mov    %eax,%edi
 81f:	e8 0e fc ff ff       	callq  432 <putc>
 824:	eb 2a                	jmp    850 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 826:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 82c:	be 25 00 00 00       	mov    $0x25,%esi
 831:	89 c7                	mov    %eax,%edi
 833:	e8 fa fb ff ff       	callq  432 <putc>
        putc(fd, c);
 838:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 83e:	0f be d0             	movsbl %al,%edx
 841:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 847:	89 d6                	mov    %edx,%esi
 849:	89 c7                	mov    %eax,%edi
 84b:	e8 e2 fb ff ff       	callq  432 <putc>
      }
      state = 0;
 850:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 857:	00 00 00 
  for(i = 0; fmt[i]; i++){
 85a:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 861:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 867:	48 63 d0             	movslq %eax,%rdx
 86a:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 871:	48 01 d0             	add    %rdx,%rax
 874:	0f b6 00             	movzbl (%rax),%eax
 877:	84 c0                	test   %al,%al
 879:	0f 85 3a fd ff ff    	jne    5b9 <printf+0x9e>
    }
  }
}
 87f:	90                   	nop
 880:	c9                   	leaveq 
 881:	c3                   	retq   

0000000000000882 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 882:	55                   	push   %rbp
 883:	48 89 e5             	mov    %rsp,%rbp
 886:	48 83 ec 18          	sub    $0x18,%rsp
 88a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 892:	48 83 e8 10          	sub    $0x10,%rax
 896:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89a:	48 8b 05 2f 05 00 00 	mov    0x52f(%rip),%rax        # dd0 <freep>
 8a1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 8a5:	eb 2f                	jmp    8d6 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8ab:	48 8b 00             	mov    (%rax),%rax
 8ae:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 8b2:	72 17                	jb     8cb <free+0x49>
 8b4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8b8:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8bc:	77 2f                	ja     8ed <free+0x6b>
 8be:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8c2:	48 8b 00             	mov    (%rax),%rax
 8c5:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8c9:	72 22                	jb     8ed <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8cf:	48 8b 00             	mov    (%rax),%rax
 8d2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 8d6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8da:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 8de:	76 c7                	jbe    8a7 <free+0x25>
 8e0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 8e4:	48 8b 00             	mov    (%rax),%rax
 8e7:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 8eb:	73 ba                	jae    8a7 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 8f1:	8b 40 08             	mov    0x8(%rax),%eax
 8f4:	89 c0                	mov    %eax,%eax
 8f6:	48 c1 e0 04          	shl    $0x4,%rax
 8fa:	48 89 c2             	mov    %rax,%rdx
 8fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 901:	48 01 c2             	add    %rax,%rdx
 904:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 908:	48 8b 00             	mov    (%rax),%rax
 90b:	48 39 c2             	cmp    %rax,%rdx
 90e:	75 2d                	jne    93d <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 910:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 914:	8b 50 08             	mov    0x8(%rax),%edx
 917:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 91b:	48 8b 00             	mov    (%rax),%rax
 91e:	8b 40 08             	mov    0x8(%rax),%eax
 921:	01 c2                	add    %eax,%edx
 923:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 927:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 92a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 92e:	48 8b 00             	mov    (%rax),%rax
 931:	48 8b 10             	mov    (%rax),%rdx
 934:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 938:	48 89 10             	mov    %rdx,(%rax)
 93b:	eb 0e                	jmp    94b <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 93d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 941:	48 8b 10             	mov    (%rax),%rdx
 944:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 948:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 94b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 94f:	8b 40 08             	mov    0x8(%rax),%eax
 952:	89 c0                	mov    %eax,%eax
 954:	48 c1 e0 04          	shl    $0x4,%rax
 958:	48 89 c2             	mov    %rax,%rdx
 95b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 95f:	48 01 d0             	add    %rdx,%rax
 962:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 966:	75 27                	jne    98f <free+0x10d>
    p->s.size += bp->s.size;
 968:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 96c:	8b 50 08             	mov    0x8(%rax),%edx
 96f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 973:	8b 40 08             	mov    0x8(%rax),%eax
 976:	01 c2                	add    %eax,%edx
 978:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 97c:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 97f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 983:	48 8b 10             	mov    (%rax),%rdx
 986:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 98a:	48 89 10             	mov    %rdx,(%rax)
 98d:	eb 0b                	jmp    99a <free+0x118>
  } else
    p->s.ptr = bp;
 98f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 993:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 997:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 99a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 99e:	48 89 05 2b 04 00 00 	mov    %rax,0x42b(%rip)        # dd0 <freep>
}
 9a5:	90                   	nop
 9a6:	c9                   	leaveq 
 9a7:	c3                   	retq   

00000000000009a8 <morecore>:

static Header*
morecore(uint nu)
{
 9a8:	55                   	push   %rbp
 9a9:	48 89 e5             	mov    %rsp,%rbp
 9ac:	48 83 ec 20          	sub    $0x20,%rsp
 9b0:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 9b3:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 9ba:	77 07                	ja     9c3 <morecore+0x1b>
    nu = 4096;
 9bc:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 9c3:	8b 45 ec             	mov    -0x14(%rbp),%eax
 9c6:	c1 e0 04             	shl    $0x4,%eax
 9c9:	89 c7                	mov    %eax,%edi
 9cb:	e8 4a fa ff ff       	callq  41a <sbrk>
 9d0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 9d4:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 9d9:	75 07                	jne    9e2 <morecore+0x3a>
    return 0;
 9db:	b8 00 00 00 00       	mov    $0x0,%eax
 9e0:	eb 29                	jmp    a0b <morecore+0x63>
  hp = (Header*)p;
 9e2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9e6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 9ea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9ee:	8b 55 ec             	mov    -0x14(%rbp),%edx
 9f1:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 9f4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9f8:	48 83 c0 10          	add    $0x10,%rax
 9fc:	48 89 c7             	mov    %rax,%rdi
 9ff:	e8 7e fe ff ff       	callq  882 <free>
  return freep;
 a04:	48 8b 05 c5 03 00 00 	mov    0x3c5(%rip),%rax        # dd0 <freep>
}
 a0b:	c9                   	leaveq 
 a0c:	c3                   	retq   

0000000000000a0d <malloc>:

void*
malloc(uint nbytes)
{
 a0d:	55                   	push   %rbp
 a0e:	48 89 e5             	mov    %rsp,%rbp
 a11:	48 83 ec 30          	sub    $0x30,%rsp
 a15:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a18:	8b 45 dc             	mov    -0x24(%rbp),%eax
 a1b:	48 83 c0 0f          	add    $0xf,%rax
 a1f:	48 c1 e8 04          	shr    $0x4,%rax
 a23:	83 c0 01             	add    $0x1,%eax
 a26:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 a29:	48 8b 05 a0 03 00 00 	mov    0x3a0(%rip),%rax        # dd0 <freep>
 a30:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 a34:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 a39:	75 2b                	jne    a66 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 a3b:	48 c7 45 f0 c0 0d 00 	movq   $0xdc0,-0x10(%rbp)
 a42:	00 
 a43:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a47:	48 89 05 82 03 00 00 	mov    %rax,0x382(%rip)        # dd0 <freep>
 a4e:	48 8b 05 7b 03 00 00 	mov    0x37b(%rip),%rax        # dd0 <freep>
 a55:	48 89 05 64 03 00 00 	mov    %rax,0x364(%rip)        # dc0 <base>
    base.s.size = 0;
 a5c:	c7 05 62 03 00 00 00 	movl   $0x0,0x362(%rip)        # dc8 <base+0x8>
 a63:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a66:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a6a:	48 8b 00             	mov    (%rax),%rax
 a6d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 a71:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a75:	8b 40 08             	mov    0x8(%rax),%eax
 a78:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a7b:	77 5f                	ja     adc <malloc+0xcf>
      if(p->s.size == nunits)
 a7d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a81:	8b 40 08             	mov    0x8(%rax),%eax
 a84:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 a87:	75 10                	jne    a99 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 a89:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a8d:	48 8b 10             	mov    (%rax),%rdx
 a90:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a94:	48 89 10             	mov    %rdx,(%rax)
 a97:	eb 2e                	jmp    ac7 <malloc+0xba>
      else {
        p->s.size -= nunits;
 a99:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a9d:	8b 40 08             	mov    0x8(%rax),%eax
 aa0:	2b 45 ec             	sub    -0x14(%rbp),%eax
 aa3:	89 c2                	mov    %eax,%edx
 aa5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aa9:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 aac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ab0:	8b 40 08             	mov    0x8(%rax),%eax
 ab3:	89 c0                	mov    %eax,%eax
 ab5:	48 c1 e0 04          	shl    $0x4,%rax
 ab9:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 abd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ac1:	8b 55 ec             	mov    -0x14(%rbp),%edx
 ac4:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 ac7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 acb:	48 89 05 fe 02 00 00 	mov    %rax,0x2fe(%rip)        # dd0 <freep>
      return (void*)(p + 1);
 ad2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ad6:	48 83 c0 10          	add    $0x10,%rax
 ada:	eb 41                	jmp    b1d <malloc+0x110>
    }
    if(p == freep)
 adc:	48 8b 05 ed 02 00 00 	mov    0x2ed(%rip),%rax        # dd0 <freep>
 ae3:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 ae7:	75 1c                	jne    b05 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 ae9:	8b 45 ec             	mov    -0x14(%rbp),%eax
 aec:	89 c7                	mov    %eax,%edi
 aee:	e8 b5 fe ff ff       	callq  9a8 <morecore>
 af3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 af7:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 afc:	75 07                	jne    b05 <malloc+0xf8>
        return 0;
 afe:	b8 00 00 00 00       	mov    $0x0,%eax
 b03:	eb 18                	jmp    b1d <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b05:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b09:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 b0d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b11:	48 8b 00             	mov    (%rax),%rax
 b14:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 b18:	e9 54 ff ff ff       	jmpq   a71 <malloc+0x64>
  }
}
 b1d:	c9                   	leaveq 
 b1e:	c3                   	retq   
