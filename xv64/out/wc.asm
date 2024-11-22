
fs/wc:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 30          	sub    $0x30,%rsp
   8:	89 7d dc             	mov    %edi,-0x24(%rbp)
   b:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
  16:	8b 45 f0             	mov    -0x10(%rbp),%eax
  19:	89 45 f4             	mov    %eax,-0xc(%rbp)
  1c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  1f:	89 45 f8             	mov    %eax,-0x8(%rbp)
  inword = 0;
  22:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  29:	eb 69                	jmp    94 <wc+0x94>
    for(i=0; i<n; i++){
  2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  32:	eb 58                	jmp    8c <wc+0x8c>
      c++;
  34:	83 45 f0 01          	addl   $0x1,-0x10(%rbp)
      if(buf[i] == '\n')
  38:	8b 45 fc             	mov    -0x4(%rbp),%eax
  3b:	48 98                	cltq   
  3d:	0f b6 80 20 0f 00 00 	movzbl 0xf20(%rax),%eax
  44:	3c 0a                	cmp    $0xa,%al
  46:	75 04                	jne    4c <wc+0x4c>
        l++;
  48:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
      if(strchr(" \r\t\n\v", buf[i]))
  4c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  4f:	48 98                	cltq   
  51:	0f b6 80 20 0f 00 00 	movzbl 0xf20(%rax),%eax
  58:	0f be c0             	movsbl %al,%eax
  5b:	89 c6                	mov    %eax,%esi
  5d:	48 c7 c7 64 0c 00 00 	mov    $0xc64,%rdi
  64:	e8 a5 02 00 00       	callq  30e <strchr>
  69:	48 85 c0             	test   %rax,%rax
  6c:	74 09                	je     77 <wc+0x77>
        inword = 0;
  6e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  75:	eb 11                	jmp    88 <wc+0x88>
      else if(!inword){
  77:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  7b:	75 0b                	jne    88 <wc+0x88>
        w++;
  7d:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
        inword = 1;
  81:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%rbp)
    for(i=0; i<n; i++){
  88:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8f:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  92:	7c a0                	jl     34 <wc+0x34>
  while((n = read(fd, buf, sizeof(buf))) > 0){
  94:	8b 45 dc             	mov    -0x24(%rbp),%eax
  97:	ba 00 02 00 00       	mov    $0x200,%edx
  9c:	48 c7 c6 20 0f 00 00 	mov    $0xf20,%rsi
  a3:	89 c7                	mov    %eax,%edi
  a5:	e8 45 04 00 00       	callq  4ef <read>
  aa:	89 45 e8             	mov    %eax,-0x18(%rbp)
  ad:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  b1:	0f 8f 74 ff ff ff    	jg     2b <wc+0x2b>
      }
    }
  }
  if(n < 0){
  b7:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  bb:	79 1b                	jns    d8 <wc+0xd8>
    printf(1, "wc: read error\n");
  bd:	48 c7 c6 6a 0c 00 00 	mov    $0xc6a,%rsi
  c4:	bf 01 00 00 00       	mov    $0x1,%edi
  c9:	b8 00 00 00 00       	mov    $0x0,%eax
  ce:	e8 8d 05 00 00       	callq  660 <printf>
    exit();
  d3:	e8 ff 03 00 00       	callq  4d7 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  d8:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  dc:	8b 4d f0             	mov    -0x10(%rbp),%ecx
  df:	8b 55 f4             	mov    -0xc(%rbp),%edx
  e2:	8b 45 f8             	mov    -0x8(%rbp),%eax
  e5:	49 89 f1             	mov    %rsi,%r9
  e8:	41 89 c8             	mov    %ecx,%r8d
  eb:	89 d1                	mov    %edx,%ecx
  ed:	89 c2                	mov    %eax,%edx
  ef:	48 c7 c6 7a 0c 00 00 	mov    $0xc7a,%rsi
  f6:	bf 01 00 00 00       	mov    $0x1,%edi
  fb:	b8 00 00 00 00       	mov    $0x0,%eax
 100:	e8 5b 05 00 00       	callq  660 <printf>
}
 105:	90                   	nop
 106:	c9                   	leaveq 
 107:	c3                   	retq   

0000000000000108 <main>:

int
main(int argc, char *argv[])
{
 108:	55                   	push   %rbp
 109:	48 89 e5             	mov    %rsp,%rbp
 10c:	48 83 ec 20          	sub    $0x20,%rsp
 110:	89 7d ec             	mov    %edi,-0x14(%rbp)
 113:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd, i;

  if(argc <= 1){
 117:	83 7d ec 01          	cmpl   $0x1,-0x14(%rbp)
 11b:	7f 16                	jg     133 <main+0x2b>
    wc(0, "");
 11d:	48 c7 c6 87 0c 00 00 	mov    $0xc87,%rsi
 124:	bf 00 00 00 00       	mov    $0x0,%edi
 129:	e8 d2 fe ff ff       	callq  0 <wc>
    exit();
 12e:	e8 a4 03 00 00       	callq  4d7 <exit>
  }

  for(i = 1; i < argc; i++){
 133:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
 13a:	e9 94 00 00 00       	jmpq   1d3 <main+0xcb>
    if((fd = open(argv[i], 0)) < 0){
 13f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 142:	48 98                	cltq   
 144:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 14b:	00 
 14c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 150:	48 01 d0             	add    %rdx,%rax
 153:	48 8b 00             	mov    (%rax),%rax
 156:	be 00 00 00 00       	mov    $0x0,%esi
 15b:	48 89 c7             	mov    %rax,%rdi
 15e:	e8 b4 03 00 00       	callq  517 <open>
 163:	89 45 f8             	mov    %eax,-0x8(%rbp)
 166:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 16a:	79 35                	jns    1a1 <main+0x99>
      printf(1, "wc: cannot open %s\n", argv[i]);
 16c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 16f:	48 98                	cltq   
 171:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 178:	00 
 179:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 17d:	48 01 d0             	add    %rdx,%rax
 180:	48 8b 00             	mov    (%rax),%rax
 183:	48 89 c2             	mov    %rax,%rdx
 186:	48 c7 c6 88 0c 00 00 	mov    $0xc88,%rsi
 18d:	bf 01 00 00 00       	mov    $0x1,%edi
 192:	b8 00 00 00 00       	mov    $0x0,%eax
 197:	e8 c4 04 00 00       	callq  660 <printf>
      exit();
 19c:	e8 36 03 00 00       	callq  4d7 <exit>
    }
    wc(fd, argv[i]);
 1a1:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1a4:	48 98                	cltq   
 1a6:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 1ad:	00 
 1ae:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 1b2:	48 01 d0             	add    %rdx,%rax
 1b5:	48 8b 10             	mov    (%rax),%rdx
 1b8:	8b 45 f8             	mov    -0x8(%rbp),%eax
 1bb:	48 89 d6             	mov    %rdx,%rsi
 1be:	89 c7                	mov    %eax,%edi
 1c0:	e8 3b fe ff ff       	callq  0 <wc>
    close(fd);
 1c5:	8b 45 f8             	mov    -0x8(%rbp),%eax
 1c8:	89 c7                	mov    %eax,%edi
 1ca:	e8 30 03 00 00       	callq  4ff <close>
  for(i = 1; i < argc; i++){
 1cf:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 1d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1d6:	3b 45 ec             	cmp    -0x14(%rbp),%eax
 1d9:	0f 8c 60 ff ff ff    	jl     13f <main+0x37>
  }
  exit();
 1df:	e8 f3 02 00 00       	callq  4d7 <exit>

00000000000001e4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1e4:	55                   	push   %rbp
 1e5:	48 89 e5             	mov    %rsp,%rbp
 1e8:	48 83 ec 10          	sub    $0x10,%rsp
 1ec:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1f0:	89 75 f4             	mov    %esi,-0xc(%rbp)
 1f3:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 1f6:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 1fa:	8b 55 f0             	mov    -0x10(%rbp),%edx
 1fd:	8b 45 f4             	mov    -0xc(%rbp),%eax
 200:	48 89 ce             	mov    %rcx,%rsi
 203:	48 89 f7             	mov    %rsi,%rdi
 206:	89 d1                	mov    %edx,%ecx
 208:	fc                   	cld    
 209:	f3 aa                	rep stos %al,%es:(%rdi)
 20b:	89 ca                	mov    %ecx,%edx
 20d:	48 89 fe             	mov    %rdi,%rsi
 210:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 214:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 217:	90                   	nop
 218:	c9                   	leaveq 
 219:	c3                   	retq   

000000000000021a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 21a:	55                   	push   %rbp
 21b:	48 89 e5             	mov    %rsp,%rbp
 21e:	48 83 ec 20          	sub    $0x20,%rsp
 222:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 226:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 22a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 22e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 232:	90                   	nop
 233:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 237:	48 8d 42 01          	lea    0x1(%rdx),%rax
 23b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 23f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 243:	48 8d 48 01          	lea    0x1(%rax),%rcx
 247:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 24b:	0f b6 12             	movzbl (%rdx),%edx
 24e:	88 10                	mov    %dl,(%rax)
 250:	0f b6 00             	movzbl (%rax),%eax
 253:	84 c0                	test   %al,%al
 255:	75 dc                	jne    233 <strcpy+0x19>
    ;
  return os;
 257:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 25b:	c9                   	leaveq 
 25c:	c3                   	retq   

000000000000025d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 25d:	55                   	push   %rbp
 25e:	48 89 e5             	mov    %rsp,%rbp
 261:	48 83 ec 10          	sub    $0x10,%rsp
 265:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 269:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 26d:	eb 0a                	jmp    279 <strcmp+0x1c>
    p++, q++;
 26f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 274:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 279:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 27d:	0f b6 00             	movzbl (%rax),%eax
 280:	84 c0                	test   %al,%al
 282:	74 12                	je     296 <strcmp+0x39>
 284:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 288:	0f b6 10             	movzbl (%rax),%edx
 28b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 28f:	0f b6 00             	movzbl (%rax),%eax
 292:	38 c2                	cmp    %al,%dl
 294:	74 d9                	je     26f <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 296:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 29a:	0f b6 00             	movzbl (%rax),%eax
 29d:	0f b6 d0             	movzbl %al,%edx
 2a0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 2a4:	0f b6 00             	movzbl (%rax),%eax
 2a7:	0f b6 c0             	movzbl %al,%eax
 2aa:	29 c2                	sub    %eax,%edx
 2ac:	89 d0                	mov    %edx,%eax
}
 2ae:	c9                   	leaveq 
 2af:	c3                   	retq   

00000000000002b0 <strlen>:

uint
strlen(char *s)
{
 2b0:	55                   	push   %rbp
 2b1:	48 89 e5             	mov    %rsp,%rbp
 2b4:	48 83 ec 18          	sub    $0x18,%rsp
 2b8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 2bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 2c3:	eb 04                	jmp    2c9 <strlen+0x19>
 2c5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 2c9:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2cc:	48 63 d0             	movslq %eax,%rdx
 2cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2d3:	48 01 d0             	add    %rdx,%rax
 2d6:	0f b6 00             	movzbl (%rax),%eax
 2d9:	84 c0                	test   %al,%al
 2db:	75 e8                	jne    2c5 <strlen+0x15>
    ;
  return n;
 2dd:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 2e0:	c9                   	leaveq 
 2e1:	c3                   	retq   

00000000000002e2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e2:	55                   	push   %rbp
 2e3:	48 89 e5             	mov    %rsp,%rbp
 2e6:	48 83 ec 10          	sub    $0x10,%rsp
 2ea:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 2ee:	89 75 f4             	mov    %esi,-0xc(%rbp)
 2f1:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 2f4:	8b 55 f0             	mov    -0x10(%rbp),%edx
 2f7:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 2fa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2fe:	89 ce                	mov    %ecx,%esi
 300:	48 89 c7             	mov    %rax,%rdi
 303:	e8 dc fe ff ff       	callq  1e4 <stosb>
  return dst;
 308:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 30c:	c9                   	leaveq 
 30d:	c3                   	retq   

000000000000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	55                   	push   %rbp
 30f:	48 89 e5             	mov    %rsp,%rbp
 312:	48 83 ec 10          	sub    $0x10,%rsp
 316:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 31a:	89 f0                	mov    %esi,%eax
 31c:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 31f:	eb 17                	jmp    338 <strchr+0x2a>
    if(*s == c)
 321:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 325:	0f b6 00             	movzbl (%rax),%eax
 328:	38 45 f4             	cmp    %al,-0xc(%rbp)
 32b:	75 06                	jne    333 <strchr+0x25>
      return (char*)s;
 32d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 331:	eb 15                	jmp    348 <strchr+0x3a>
  for(; *s; s++)
 333:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 338:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 33c:	0f b6 00             	movzbl (%rax),%eax
 33f:	84 c0                	test   %al,%al
 341:	75 de                	jne    321 <strchr+0x13>
  return 0;
 343:	b8 00 00 00 00       	mov    $0x0,%eax
}
 348:	c9                   	leaveq 
 349:	c3                   	retq   

000000000000034a <gets>:

char*
gets(char *buf, int max)
{
 34a:	55                   	push   %rbp
 34b:	48 89 e5             	mov    %rsp,%rbp
 34e:	48 83 ec 20          	sub    $0x20,%rsp
 352:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 356:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 359:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 360:	eb 48                	jmp    3aa <gets+0x60>
    cc = read(0, &c, 1);
 362:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 366:	ba 01 00 00 00       	mov    $0x1,%edx
 36b:	48 89 c6             	mov    %rax,%rsi
 36e:	bf 00 00 00 00       	mov    $0x0,%edi
 373:	e8 77 01 00 00       	callq  4ef <read>
 378:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 37b:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 37f:	7e 36                	jle    3b7 <gets+0x6d>
      break;
    buf[i++] = c;
 381:	8b 45 fc             	mov    -0x4(%rbp),%eax
 384:	8d 50 01             	lea    0x1(%rax),%edx
 387:	89 55 fc             	mov    %edx,-0x4(%rbp)
 38a:	48 63 d0             	movslq %eax,%rdx
 38d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 391:	48 01 c2             	add    %rax,%rdx
 394:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 398:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 39a:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 39e:	3c 0a                	cmp    $0xa,%al
 3a0:	74 16                	je     3b8 <gets+0x6e>
 3a2:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 3a6:	3c 0d                	cmp    $0xd,%al
 3a8:	74 0e                	je     3b8 <gets+0x6e>
  for(i=0; i+1 < max; ){
 3aa:	8b 45 fc             	mov    -0x4(%rbp),%eax
 3ad:	83 c0 01             	add    $0x1,%eax
 3b0:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 3b3:	7f ad                	jg     362 <gets+0x18>
 3b5:	eb 01                	jmp    3b8 <gets+0x6e>
      break;
 3b7:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3b8:	8b 45 fc             	mov    -0x4(%rbp),%eax
 3bb:	48 63 d0             	movslq %eax,%rdx
 3be:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3c2:	48 01 d0             	add    %rdx,%rax
 3c5:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 3c8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 3cc:	c9                   	leaveq 
 3cd:	c3                   	retq   

00000000000003ce <stat>:

int
stat(char *n, struct stat *st)
{
 3ce:	55                   	push   %rbp
 3cf:	48 89 e5             	mov    %rsp,%rbp
 3d2:	48 83 ec 20          	sub    $0x20,%rsp
 3d6:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 3da:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3de:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3e2:	be 00 00 00 00       	mov    $0x0,%esi
 3e7:	48 89 c7             	mov    %rax,%rdi
 3ea:	e8 28 01 00 00       	callq  517 <open>
 3ef:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 3f2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 3f6:	79 07                	jns    3ff <stat+0x31>
    return -1;
 3f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3fd:	eb 21                	jmp    420 <stat+0x52>
  r = fstat(fd, st);
 3ff:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 403:	8b 45 fc             	mov    -0x4(%rbp),%eax
 406:	48 89 d6             	mov    %rdx,%rsi
 409:	89 c7                	mov    %eax,%edi
 40b:	e8 1f 01 00 00       	callq  52f <fstat>
 410:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 413:	8b 45 fc             	mov    -0x4(%rbp),%eax
 416:	89 c7                	mov    %eax,%edi
 418:	e8 e2 00 00 00       	callq  4ff <close>
  return r;
 41d:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 420:	c9                   	leaveq 
 421:	c3                   	retq   

0000000000000422 <atoi>:

int
atoi(const char *s)
{
 422:	55                   	push   %rbp
 423:	48 89 e5             	mov    %rsp,%rbp
 426:	48 83 ec 18          	sub    $0x18,%rsp
 42a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 42e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 435:	eb 28                	jmp    45f <atoi+0x3d>
    n = n*10 + *s++ - '0';
 437:	8b 55 fc             	mov    -0x4(%rbp),%edx
 43a:	89 d0                	mov    %edx,%eax
 43c:	c1 e0 02             	shl    $0x2,%eax
 43f:	01 d0                	add    %edx,%eax
 441:	01 c0                	add    %eax,%eax
 443:	89 c1                	mov    %eax,%ecx
 445:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 449:	48 8d 50 01          	lea    0x1(%rax),%rdx
 44d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 451:	0f b6 00             	movzbl (%rax),%eax
 454:	0f be c0             	movsbl %al,%eax
 457:	01 c8                	add    %ecx,%eax
 459:	83 e8 30             	sub    $0x30,%eax
 45c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 45f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 463:	0f b6 00             	movzbl (%rax),%eax
 466:	3c 2f                	cmp    $0x2f,%al
 468:	7e 0b                	jle    475 <atoi+0x53>
 46a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 46e:	0f b6 00             	movzbl (%rax),%eax
 471:	3c 39                	cmp    $0x39,%al
 473:	7e c2                	jle    437 <atoi+0x15>
  return n;
 475:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 478:	c9                   	leaveq 
 479:	c3                   	retq   

000000000000047a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 47a:	55                   	push   %rbp
 47b:	48 89 e5             	mov    %rsp,%rbp
 47e:	48 83 ec 28          	sub    $0x28,%rsp
 482:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 486:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 48a:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 48d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 491:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 495:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 499:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 49d:	eb 1d                	jmp    4bc <memmove+0x42>
    *dst++ = *src++;
 49f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 4a3:	48 8d 42 01          	lea    0x1(%rdx),%rax
 4a7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 4ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4af:	48 8d 48 01          	lea    0x1(%rax),%rcx
 4b3:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 4b7:	0f b6 12             	movzbl (%rdx),%edx
 4ba:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 4bc:	8b 45 dc             	mov    -0x24(%rbp),%eax
 4bf:	8d 50 ff             	lea    -0x1(%rax),%edx
 4c2:	89 55 dc             	mov    %edx,-0x24(%rbp)
 4c5:	85 c0                	test   %eax,%eax
 4c7:	7f d6                	jg     49f <memmove+0x25>
  return vdst;
 4c9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 4cd:	c9                   	leaveq 
 4ce:	c3                   	retq   

00000000000004cf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4cf:	b8 01 00 00 00       	mov    $0x1,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	retq   

00000000000004d7 <exit>:
SYSCALL(exit)
 4d7:	b8 02 00 00 00       	mov    $0x2,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	retq   

00000000000004df <wait>:
SYSCALL(wait)
 4df:	b8 03 00 00 00       	mov    $0x3,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	retq   

00000000000004e7 <pipe>:
SYSCALL(pipe)
 4e7:	b8 04 00 00 00       	mov    $0x4,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	retq   

00000000000004ef <read>:
SYSCALL(read)
 4ef:	b8 05 00 00 00       	mov    $0x5,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	retq   

00000000000004f7 <write>:
SYSCALL(write)
 4f7:	b8 10 00 00 00       	mov    $0x10,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	retq   

00000000000004ff <close>:
SYSCALL(close)
 4ff:	b8 15 00 00 00       	mov    $0x15,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	retq   

0000000000000507 <kill>:
SYSCALL(kill)
 507:	b8 06 00 00 00       	mov    $0x6,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	retq   

000000000000050f <exec>:
SYSCALL(exec)
 50f:	b8 07 00 00 00       	mov    $0x7,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	retq   

0000000000000517 <open>:
SYSCALL(open)
 517:	b8 0f 00 00 00       	mov    $0xf,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	retq   

000000000000051f <mknod>:
SYSCALL(mknod)
 51f:	b8 11 00 00 00       	mov    $0x11,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	retq   

0000000000000527 <unlink>:
SYSCALL(unlink)
 527:	b8 12 00 00 00       	mov    $0x12,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	retq   

000000000000052f <fstat>:
SYSCALL(fstat)
 52f:	b8 08 00 00 00       	mov    $0x8,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	retq   

0000000000000537 <link>:
SYSCALL(link)
 537:	b8 13 00 00 00       	mov    $0x13,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	retq   

000000000000053f <mkdir>:
SYSCALL(mkdir)
 53f:	b8 14 00 00 00       	mov    $0x14,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	retq   

0000000000000547 <chdir>:
SYSCALL(chdir)
 547:	b8 09 00 00 00       	mov    $0x9,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	retq   

000000000000054f <dup>:
SYSCALL(dup)
 54f:	b8 0a 00 00 00       	mov    $0xa,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	retq   

0000000000000557 <getpid>:
SYSCALL(getpid)
 557:	b8 0b 00 00 00       	mov    $0xb,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	retq   

000000000000055f <sbrk>:
SYSCALL(sbrk)
 55f:	b8 0c 00 00 00       	mov    $0xc,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	retq   

0000000000000567 <sleep>:
SYSCALL(sleep)
 567:	b8 0d 00 00 00       	mov    $0xd,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	retq   

000000000000056f <uptime>:
SYSCALL(uptime)
 56f:	b8 0e 00 00 00       	mov    $0xe,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	retq   

0000000000000577 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 577:	55                   	push   %rbp
 578:	48 89 e5             	mov    %rsp,%rbp
 57b:	48 83 ec 10          	sub    $0x10,%rsp
 57f:	89 7d fc             	mov    %edi,-0x4(%rbp)
 582:	89 f0                	mov    %esi,%eax
 584:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 587:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 58b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 58e:	ba 01 00 00 00       	mov    $0x1,%edx
 593:	48 89 ce             	mov    %rcx,%rsi
 596:	89 c7                	mov    %eax,%edi
 598:	e8 5a ff ff ff       	callq  4f7 <write>
}
 59d:	90                   	nop
 59e:	c9                   	leaveq 
 59f:	c3                   	retq   

00000000000005a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a0:	55                   	push   %rbp
 5a1:	48 89 e5             	mov    %rsp,%rbp
 5a4:	48 83 ec 30          	sub    $0x30,%rsp
 5a8:	89 7d dc             	mov    %edi,-0x24(%rbp)
 5ab:	89 75 d8             	mov    %esi,-0x28(%rbp)
 5ae:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 5b1:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 5bb:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 5bf:	74 17                	je     5d8 <printint+0x38>
 5c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 5c5:	79 11                	jns    5d8 <printint+0x38>
    neg = 1;
 5c7:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 5ce:	8b 45 d8             	mov    -0x28(%rbp),%eax
 5d1:	f7 d8                	neg    %eax
 5d3:	89 45 f4             	mov    %eax,-0xc(%rbp)
 5d6:	eb 06                	jmp    5de <printint+0x3e>
  } else {
    x = xx;
 5d8:	8b 45 d8             	mov    -0x28(%rbp),%eax
 5db:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 5de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 5e5:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 5e8:	8b 45 f4             	mov    -0xc(%rbp),%eax
 5eb:	ba 00 00 00 00       	mov    $0x0,%edx
 5f0:	f7 f1                	div    %ecx
 5f2:	89 d1                	mov    %edx,%ecx
 5f4:	8b 45 fc             	mov    -0x4(%rbp),%eax
 5f7:	8d 50 01             	lea    0x1(%rax),%edx
 5fa:	89 55 fc             	mov    %edx,-0x4(%rbp)
 5fd:	89 ca                	mov    %ecx,%edx
 5ff:	0f b6 92 00 0f 00 00 	movzbl 0xf00(%rdx),%edx
 606:	48 98                	cltq   
 608:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 60c:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 60f:	8b 45 f4             	mov    -0xc(%rbp),%eax
 612:	ba 00 00 00 00       	mov    $0x0,%edx
 617:	f7 f6                	div    %esi
 619:	89 45 f4             	mov    %eax,-0xc(%rbp)
 61c:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 620:	75 c3                	jne    5e5 <printint+0x45>
  if(neg)
 622:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 626:	74 2b                	je     653 <printint+0xb3>
    buf[i++] = '-';
 628:	8b 45 fc             	mov    -0x4(%rbp),%eax
 62b:	8d 50 01             	lea    0x1(%rax),%edx
 62e:	89 55 fc             	mov    %edx,-0x4(%rbp)
 631:	48 98                	cltq   
 633:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 638:	eb 19                	jmp    653 <printint+0xb3>
    putc(fd, buf[i]);
 63a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 63d:	48 98                	cltq   
 63f:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 644:	0f be d0             	movsbl %al,%edx
 647:	8b 45 dc             	mov    -0x24(%rbp),%eax
 64a:	89 d6                	mov    %edx,%esi
 64c:	89 c7                	mov    %eax,%edi
 64e:	e8 24 ff ff ff       	callq  577 <putc>
  while(--i >= 0)
 653:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 657:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 65b:	79 dd                	jns    63a <printint+0x9a>
}
 65d:	90                   	nop
 65e:	c9                   	leaveq 
 65f:	c3                   	retq   

0000000000000660 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 660:	55                   	push   %rbp
 661:	48 89 e5             	mov    %rsp,%rbp
 664:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 66b:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 671:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 678:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 67f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 686:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 68d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 694:	84 c0                	test   %al,%al
 696:	74 20                	je     6b8 <printf+0x58>
 698:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 69c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 6a0:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 6a4:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 6a8:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 6ac:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 6b0:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 6b4:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 6b8:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 6bf:	00 00 00 
 6c2:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 6c9:	00 00 00 
 6cc:	48 8d 45 10          	lea    0x10(%rbp),%rax
 6d0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 6d7:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 6de:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 6e5:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 6ec:	00 00 00 
  for(i = 0; fmt[i]; i++){
 6ef:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 6f6:	00 00 00 
 6f9:	e9 a8 02 00 00       	jmpq   9a6 <printf+0x346>
    c = fmt[i] & 0xff;
 6fe:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 704:	48 63 d0             	movslq %eax,%rdx
 707:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 70e:	48 01 d0             	add    %rdx,%rax
 711:	0f b6 00             	movzbl (%rax),%eax
 714:	0f be c0             	movsbl %al,%eax
 717:	25 ff 00 00 00       	and    $0xff,%eax
 71c:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 722:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 729:	75 35                	jne    760 <printf+0x100>
      if(c == '%'){
 72b:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 732:	75 0f                	jne    743 <printf+0xe3>
        state = '%';
 734:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 73b:	00 00 00 
 73e:	e9 5c 02 00 00       	jmpq   99f <printf+0x33f>
      } else {
        putc(fd, c);
 743:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 749:	0f be d0             	movsbl %al,%edx
 74c:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 752:	89 d6                	mov    %edx,%esi
 754:	89 c7                	mov    %eax,%edi
 756:	e8 1c fe ff ff       	callq  577 <putc>
 75b:	e9 3f 02 00 00       	jmpq   99f <printf+0x33f>
      }
    } else if(state == '%'){
 760:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 767:	0f 85 32 02 00 00    	jne    99f <printf+0x33f>
      if(c == 'd'){
 76d:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 774:	75 5e                	jne    7d4 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 776:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 77c:	83 f8 2f             	cmp    $0x2f,%eax
 77f:	77 23                	ja     7a4 <printf+0x144>
 781:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 788:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 78e:	89 d2                	mov    %edx,%edx
 790:	48 01 d0             	add    %rdx,%rax
 793:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 799:	83 c2 08             	add    $0x8,%edx
 79c:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7a2:	eb 12                	jmp    7b6 <printf+0x156>
 7a4:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7ab:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7af:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7b6:	8b 30                	mov    (%rax),%esi
 7b8:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7be:	b9 01 00 00 00       	mov    $0x1,%ecx
 7c3:	ba 0a 00 00 00       	mov    $0xa,%edx
 7c8:	89 c7                	mov    %eax,%edi
 7ca:	e8 d1 fd ff ff       	callq  5a0 <printint>
 7cf:	e9 c1 01 00 00       	jmpq   995 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 7d4:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 7db:	74 09                	je     7e6 <printf+0x186>
 7dd:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 7e4:	75 5e                	jne    844 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 7e6:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 7ec:	83 f8 2f             	cmp    $0x2f,%eax
 7ef:	77 23                	ja     814 <printf+0x1b4>
 7f1:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 7f8:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7fe:	89 d2                	mov    %edx,%edx
 800:	48 01 d0             	add    %rdx,%rax
 803:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 809:	83 c2 08             	add    $0x8,%edx
 80c:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 812:	eb 12                	jmp    826 <printf+0x1c6>
 814:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 81b:	48 8d 50 08          	lea    0x8(%rax),%rdx
 81f:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 826:	8b 30                	mov    (%rax),%esi
 828:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 82e:	b9 00 00 00 00       	mov    $0x0,%ecx
 833:	ba 10 00 00 00       	mov    $0x10,%edx
 838:	89 c7                	mov    %eax,%edi
 83a:	e8 61 fd ff ff       	callq  5a0 <printint>
 83f:	e9 51 01 00 00       	jmpq   995 <printf+0x335>
      } else if(c == 's'){
 844:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 84b:	0f 85 98 00 00 00    	jne    8e9 <printf+0x289>
        s = va_arg(ap, char*);
 851:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 857:	83 f8 2f             	cmp    $0x2f,%eax
 85a:	77 23                	ja     87f <printf+0x21f>
 85c:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 863:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 869:	89 d2                	mov    %edx,%edx
 86b:	48 01 d0             	add    %rdx,%rax
 86e:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 874:	83 c2 08             	add    $0x8,%edx
 877:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 87d:	eb 12                	jmp    891 <printf+0x231>
 87f:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 886:	48 8d 50 08          	lea    0x8(%rax),%rdx
 88a:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 891:	48 8b 00             	mov    (%rax),%rax
 894:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 89b:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 8a2:	00 
 8a3:	75 31                	jne    8d6 <printf+0x276>
          s = "(null)";
 8a5:	48 c7 85 48 ff ff ff 	movq   $0xc9c,-0xb8(%rbp)
 8ac:	9c 0c 00 00 
        while(*s != 0){
 8b0:	eb 24                	jmp    8d6 <printf+0x276>
          putc(fd, *s);
 8b2:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 8b9:	0f b6 00             	movzbl (%rax),%eax
 8bc:	0f be d0             	movsbl %al,%edx
 8bf:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 8c5:	89 d6                	mov    %edx,%esi
 8c7:	89 c7                	mov    %eax,%edi
 8c9:	e8 a9 fc ff ff       	callq  577 <putc>
          s++;
 8ce:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 8d5:	01 
        while(*s != 0){
 8d6:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 8dd:	0f b6 00             	movzbl (%rax),%eax
 8e0:	84 c0                	test   %al,%al
 8e2:	75 ce                	jne    8b2 <printf+0x252>
 8e4:	e9 ac 00 00 00       	jmpq   995 <printf+0x335>
        }
      } else if(c == 'c'){
 8e9:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 8f0:	75 56                	jne    948 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 8f2:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 8f8:	83 f8 2f             	cmp    $0x2f,%eax
 8fb:	77 23                	ja     920 <printf+0x2c0>
 8fd:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 904:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 90a:	89 d2                	mov    %edx,%edx
 90c:	48 01 d0             	add    %rdx,%rax
 90f:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 915:	83 c2 08             	add    $0x8,%edx
 918:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 91e:	eb 12                	jmp    932 <printf+0x2d2>
 920:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 927:	48 8d 50 08          	lea    0x8(%rax),%rdx
 92b:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 932:	8b 00                	mov    (%rax),%eax
 934:	0f be d0             	movsbl %al,%edx
 937:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 93d:	89 d6                	mov    %edx,%esi
 93f:	89 c7                	mov    %eax,%edi
 941:	e8 31 fc ff ff       	callq  577 <putc>
 946:	eb 4d                	jmp    995 <printf+0x335>
      } else if(c == '%'){
 948:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 94f:	75 1a                	jne    96b <printf+0x30b>
        putc(fd, c);
 951:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 957:	0f be d0             	movsbl %al,%edx
 95a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 960:	89 d6                	mov    %edx,%esi
 962:	89 c7                	mov    %eax,%edi
 964:	e8 0e fc ff ff       	callq  577 <putc>
 969:	eb 2a                	jmp    995 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 96b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 971:	be 25 00 00 00       	mov    $0x25,%esi
 976:	89 c7                	mov    %eax,%edi
 978:	e8 fa fb ff ff       	callq  577 <putc>
        putc(fd, c);
 97d:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 983:	0f be d0             	movsbl %al,%edx
 986:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 98c:	89 d6                	mov    %edx,%esi
 98e:	89 c7                	mov    %eax,%edi
 990:	e8 e2 fb ff ff       	callq  577 <putc>
      }
      state = 0;
 995:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 99c:	00 00 00 
  for(i = 0; fmt[i]; i++){
 99f:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 9a6:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 9ac:	48 63 d0             	movslq %eax,%rdx
 9af:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 9b6:	48 01 d0             	add    %rdx,%rax
 9b9:	0f b6 00             	movzbl (%rax),%eax
 9bc:	84 c0                	test   %al,%al
 9be:	0f 85 3a fd ff ff    	jne    6fe <printf+0x9e>
    }
  }
}
 9c4:	90                   	nop
 9c5:	c9                   	leaveq 
 9c6:	c3                   	retq   

00000000000009c7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9c7:	55                   	push   %rbp
 9c8:	48 89 e5             	mov    %rsp,%rbp
 9cb:	48 83 ec 18          	sub    $0x18,%rsp
 9cf:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 9d7:	48 83 e8 10          	sub    $0x10,%rax
 9db:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9df:	48 8b 05 4a 07 00 00 	mov    0x74a(%rip),%rax        # 1130 <freep>
 9e6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 9ea:	eb 2f                	jmp    a1b <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9f0:	48 8b 00             	mov    (%rax),%rax
 9f3:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 9f7:	72 17                	jb     a10 <free+0x49>
 9f9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9fd:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 a01:	77 2f                	ja     a32 <free+0x6b>
 a03:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a07:	48 8b 00             	mov    (%rax),%rax
 a0a:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 a0e:	72 22                	jb     a32 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a10:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a14:	48 8b 00             	mov    (%rax),%rax
 a17:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 a1b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a1f:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 a23:	76 c7                	jbe    9ec <free+0x25>
 a25:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a29:	48 8b 00             	mov    (%rax),%rax
 a2c:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 a30:	73 ba                	jae    9ec <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a32:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a36:	8b 40 08             	mov    0x8(%rax),%eax
 a39:	89 c0                	mov    %eax,%eax
 a3b:	48 c1 e0 04          	shl    $0x4,%rax
 a3f:	48 89 c2             	mov    %rax,%rdx
 a42:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a46:	48 01 c2             	add    %rax,%rdx
 a49:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a4d:	48 8b 00             	mov    (%rax),%rax
 a50:	48 39 c2             	cmp    %rax,%rdx
 a53:	75 2d                	jne    a82 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 a55:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a59:	8b 50 08             	mov    0x8(%rax),%edx
 a5c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a60:	48 8b 00             	mov    (%rax),%rax
 a63:	8b 40 08             	mov    0x8(%rax),%eax
 a66:	01 c2                	add    %eax,%edx
 a68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a6c:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a6f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a73:	48 8b 00             	mov    (%rax),%rax
 a76:	48 8b 10             	mov    (%rax),%rdx
 a79:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a7d:	48 89 10             	mov    %rdx,(%rax)
 a80:	eb 0e                	jmp    a90 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 a82:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a86:	48 8b 10             	mov    (%rax),%rdx
 a89:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a8d:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 a90:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a94:	8b 40 08             	mov    0x8(%rax),%eax
 a97:	89 c0                	mov    %eax,%eax
 a99:	48 c1 e0 04          	shl    $0x4,%rax
 a9d:	48 89 c2             	mov    %rax,%rdx
 aa0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 aa4:	48 01 d0             	add    %rdx,%rax
 aa7:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 aab:	75 27                	jne    ad4 <free+0x10d>
    p->s.size += bp->s.size;
 aad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ab1:	8b 50 08             	mov    0x8(%rax),%edx
 ab4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 ab8:	8b 40 08             	mov    0x8(%rax),%eax
 abb:	01 c2                	add    %eax,%edx
 abd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ac1:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 ac4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 ac8:	48 8b 10             	mov    (%rax),%rdx
 acb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 acf:	48 89 10             	mov    %rdx,(%rax)
 ad2:	eb 0b                	jmp    adf <free+0x118>
  } else
    p->s.ptr = bp;
 ad4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ad8:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 adc:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 adf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ae3:	48 89 05 46 06 00 00 	mov    %rax,0x646(%rip)        # 1130 <freep>
}
 aea:	90                   	nop
 aeb:	c9                   	leaveq 
 aec:	c3                   	retq   

0000000000000aed <morecore>:

static Header*
morecore(uint nu)
{
 aed:	55                   	push   %rbp
 aee:	48 89 e5             	mov    %rsp,%rbp
 af1:	48 83 ec 20          	sub    $0x20,%rsp
 af5:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 af8:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 aff:	77 07                	ja     b08 <morecore+0x1b>
    nu = 4096;
 b01:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 b08:	8b 45 ec             	mov    -0x14(%rbp),%eax
 b0b:	c1 e0 04             	shl    $0x4,%eax
 b0e:	89 c7                	mov    %eax,%edi
 b10:	e8 4a fa ff ff       	callq  55f <sbrk>
 b15:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 b19:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 b1e:	75 07                	jne    b27 <morecore+0x3a>
    return 0;
 b20:	b8 00 00 00 00       	mov    $0x0,%eax
 b25:	eb 29                	jmp    b50 <morecore+0x63>
  hp = (Header*)p;
 b27:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b2b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 b2f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b33:	8b 55 ec             	mov    -0x14(%rbp),%edx
 b36:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 b39:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b3d:	48 83 c0 10          	add    $0x10,%rax
 b41:	48 89 c7             	mov    %rax,%rdi
 b44:	e8 7e fe ff ff       	callq  9c7 <free>
  return freep;
 b49:	48 8b 05 e0 05 00 00 	mov    0x5e0(%rip),%rax        # 1130 <freep>
}
 b50:	c9                   	leaveq 
 b51:	c3                   	retq   

0000000000000b52 <malloc>:

void*
malloc(uint nbytes)
{
 b52:	55                   	push   %rbp
 b53:	48 89 e5             	mov    %rsp,%rbp
 b56:	48 83 ec 30          	sub    $0x30,%rsp
 b5a:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b5d:	8b 45 dc             	mov    -0x24(%rbp),%eax
 b60:	48 83 c0 0f          	add    $0xf,%rax
 b64:	48 c1 e8 04          	shr    $0x4,%rax
 b68:	83 c0 01             	add    $0x1,%eax
 b6b:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 b6e:	48 8b 05 bb 05 00 00 	mov    0x5bb(%rip),%rax        # 1130 <freep>
 b75:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 b79:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 b7e:	75 2b                	jne    bab <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 b80:	48 c7 45 f0 20 11 00 	movq   $0x1120,-0x10(%rbp)
 b87:	00 
 b88:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b8c:	48 89 05 9d 05 00 00 	mov    %rax,0x59d(%rip)        # 1130 <freep>
 b93:	48 8b 05 96 05 00 00 	mov    0x596(%rip),%rax        # 1130 <freep>
 b9a:	48 89 05 7f 05 00 00 	mov    %rax,0x57f(%rip)        # 1120 <base>
    base.s.size = 0;
 ba1:	c7 05 7d 05 00 00 00 	movl   $0x0,0x57d(%rip)        # 1128 <base+0x8>
 ba8:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bab:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 baf:	48 8b 00             	mov    (%rax),%rax
 bb2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 bb6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bba:	8b 40 08             	mov    0x8(%rax),%eax
 bbd:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 bc0:	77 5f                	ja     c21 <malloc+0xcf>
      if(p->s.size == nunits)
 bc2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bc6:	8b 40 08             	mov    0x8(%rax),%eax
 bc9:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 bcc:	75 10                	jne    bde <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 bce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bd2:	48 8b 10             	mov    (%rax),%rdx
 bd5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bd9:	48 89 10             	mov    %rdx,(%rax)
 bdc:	eb 2e                	jmp    c0c <malloc+0xba>
      else {
        p->s.size -= nunits;
 bde:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 be2:	8b 40 08             	mov    0x8(%rax),%eax
 be5:	2b 45 ec             	sub    -0x14(%rbp),%eax
 be8:	89 c2                	mov    %eax,%edx
 bea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bee:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 bf1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bf5:	8b 40 08             	mov    0x8(%rax),%eax
 bf8:	89 c0                	mov    %eax,%eax
 bfa:	48 c1 e0 04          	shl    $0x4,%rax
 bfe:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 c02:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c06:	8b 55 ec             	mov    -0x14(%rbp),%edx
 c09:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 c0c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c10:	48 89 05 19 05 00 00 	mov    %rax,0x519(%rip)        # 1130 <freep>
      return (void*)(p + 1);
 c17:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c1b:	48 83 c0 10          	add    $0x10,%rax
 c1f:	eb 41                	jmp    c62 <malloc+0x110>
    }
    if(p == freep)
 c21:	48 8b 05 08 05 00 00 	mov    0x508(%rip),%rax        # 1130 <freep>
 c28:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 c2c:	75 1c                	jne    c4a <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 c2e:	8b 45 ec             	mov    -0x14(%rbp),%eax
 c31:	89 c7                	mov    %eax,%edi
 c33:	e8 b5 fe ff ff       	callq  aed <morecore>
 c38:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 c3c:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 c41:	75 07                	jne    c4a <malloc+0xf8>
        return 0;
 c43:	b8 00 00 00 00       	mov    $0x0,%eax
 c48:	eb 18                	jmp    c62 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c4a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c4e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 c52:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c56:	48 8b 00             	mov    (%rax),%rax
 c59:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 c5d:	e9 54 ff ff ff       	jmpq   bb6 <malloc+0x64>
  }
}
 c62:	c9                   	leaveq 
 c63:	c3                   	retq   
