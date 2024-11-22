
fs/cat:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 20          	sub    $0x20,%rsp
   8:	89 7d ec             	mov    %edi,-0x14(%rbp)
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   b:	eb 16                	jmp    23 <cat+0x23>
    write(1, buf, n);
   d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  10:	89 c2                	mov    %eax,%edx
  12:	48 c7 c6 60 0e 00 00 	mov    $0xe60,%rsi
  19:	bf 01 00 00 00       	mov    $0x1,%edi
  1e:	e8 0e 04 00 00       	callq  431 <write>
  while((n = read(fd, buf, sizeof(buf))) > 0)
  23:	8b 45 ec             	mov    -0x14(%rbp),%eax
  26:	ba 00 02 00 00       	mov    $0x200,%edx
  2b:	48 c7 c6 60 0e 00 00 	mov    $0xe60,%rsi
  32:	89 c7                	mov    %eax,%edi
  34:	e8 f0 03 00 00       	callq  429 <read>
  39:	89 45 fc             	mov    %eax,-0x4(%rbp)
  3c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  40:	7f cb                	jg     d <cat+0xd>
  if(n < 0){
  42:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  46:	79 1b                	jns    63 <cat+0x63>
    printf(1, "cat: read error\n");
  48:	48 c7 c6 9e 0b 00 00 	mov    $0xb9e,%rsi
  4f:	bf 01 00 00 00       	mov    $0x1,%edi
  54:	b8 00 00 00 00       	mov    $0x0,%eax
  59:	e8 3c 05 00 00       	callq  59a <printf>
    exit();
  5e:	e8 ae 03 00 00       	callq  411 <exit>
  }
}
  63:	90                   	nop
  64:	c9                   	leaveq 
  65:	c3                   	retq   

0000000000000066 <main>:

int
main(int argc, char *argv[])
{
  66:	55                   	push   %rbp
  67:	48 89 e5             	mov    %rsp,%rbp
  6a:	48 83 ec 20          	sub    $0x20,%rsp
  6e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  71:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd, i;

  if(argc <= 1){
  75:	83 7d ec 01          	cmpl   $0x1,-0x14(%rbp)
  79:	7f 0f                	jg     8a <main+0x24>
    cat(0);
  7b:	bf 00 00 00 00       	mov    $0x0,%edi
  80:	e8 7b ff ff ff       	callq  0 <cat>
    exit();
  85:	e8 87 03 00 00       	callq  411 <exit>
  }

  for(i = 1; i < argc; i++){
  8a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  91:	eb 7a                	jmp    10d <main+0xa7>
    if((fd = open(argv[i], 0)) < 0){
  93:	8b 45 fc             	mov    -0x4(%rbp),%eax
  96:	48 98                	cltq   
  98:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  9f:	00 
  a0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  a4:	48 01 d0             	add    %rdx,%rax
  a7:	48 8b 00             	mov    (%rax),%rax
  aa:	be 00 00 00 00       	mov    $0x0,%esi
  af:	48 89 c7             	mov    %rax,%rdi
  b2:	e8 9a 03 00 00       	callq  451 <open>
  b7:	89 45 f8             	mov    %eax,-0x8(%rbp)
  ba:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  be:	79 35                	jns    f5 <main+0x8f>
      printf(1, "cat: cannot open %s\n", argv[i]);
  c0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  c3:	48 98                	cltq   
  c5:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  cc:	00 
  cd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  d1:	48 01 d0             	add    %rdx,%rax
  d4:	48 8b 00             	mov    (%rax),%rax
  d7:	48 89 c2             	mov    %rax,%rdx
  da:	48 c7 c6 af 0b 00 00 	mov    $0xbaf,%rsi
  e1:	bf 01 00 00 00       	mov    $0x1,%edi
  e6:	b8 00 00 00 00       	mov    $0x0,%eax
  eb:	e8 aa 04 00 00       	callq  59a <printf>
      exit();
  f0:	e8 1c 03 00 00       	callq  411 <exit>
    }
    cat(fd);
  f5:	8b 45 f8             	mov    -0x8(%rbp),%eax
  f8:	89 c7                	mov    %eax,%edi
  fa:	e8 01 ff ff ff       	callq  0 <cat>
    close(fd);
  ff:	8b 45 f8             	mov    -0x8(%rbp),%eax
 102:	89 c7                	mov    %eax,%edi
 104:	e8 30 03 00 00       	callq  439 <close>
  for(i = 1; i < argc; i++){
 109:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 10d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 110:	3b 45 ec             	cmp    -0x14(%rbp),%eax
 113:	0f 8c 7a ff ff ff    	jl     93 <main+0x2d>
  }
  exit();
 119:	e8 f3 02 00 00       	callq  411 <exit>

000000000000011e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 11e:	55                   	push   %rbp
 11f:	48 89 e5             	mov    %rsp,%rbp
 122:	48 83 ec 10          	sub    $0x10,%rsp
 126:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 12a:	89 75 f4             	mov    %esi,-0xc(%rbp)
 12d:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 130:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 134:	8b 55 f0             	mov    -0x10(%rbp),%edx
 137:	8b 45 f4             	mov    -0xc(%rbp),%eax
 13a:	48 89 ce             	mov    %rcx,%rsi
 13d:	48 89 f7             	mov    %rsi,%rdi
 140:	89 d1                	mov    %edx,%ecx
 142:	fc                   	cld    
 143:	f3 aa                	rep stos %al,%es:(%rdi)
 145:	89 ca                	mov    %ecx,%edx
 147:	48 89 fe             	mov    %rdi,%rsi
 14a:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 14e:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 151:	90                   	nop
 152:	c9                   	leaveq 
 153:	c3                   	retq   

0000000000000154 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 154:	55                   	push   %rbp
 155:	48 89 e5             	mov    %rsp,%rbp
 158:	48 83 ec 20          	sub    $0x20,%rsp
 15c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 160:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 164:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 168:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 16c:	90                   	nop
 16d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 171:	48 8d 42 01          	lea    0x1(%rdx),%rax
 175:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 179:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 17d:	48 8d 48 01          	lea    0x1(%rax),%rcx
 181:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 185:	0f b6 12             	movzbl (%rdx),%edx
 188:	88 10                	mov    %dl,(%rax)
 18a:	0f b6 00             	movzbl (%rax),%eax
 18d:	84 c0                	test   %al,%al
 18f:	75 dc                	jne    16d <strcpy+0x19>
    ;
  return os;
 191:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 195:	c9                   	leaveq 
 196:	c3                   	retq   

0000000000000197 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 197:	55                   	push   %rbp
 198:	48 89 e5             	mov    %rsp,%rbp
 19b:	48 83 ec 10          	sub    $0x10,%rsp
 19f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1a3:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 1a7:	eb 0a                	jmp    1b3 <strcmp+0x1c>
    p++, q++;
 1a9:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 1ae:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 1b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1b7:	0f b6 00             	movzbl (%rax),%eax
 1ba:	84 c0                	test   %al,%al
 1bc:	74 12                	je     1d0 <strcmp+0x39>
 1be:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1c2:	0f b6 10             	movzbl (%rax),%edx
 1c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 1c9:	0f b6 00             	movzbl (%rax),%eax
 1cc:	38 c2                	cmp    %al,%dl
 1ce:	74 d9                	je     1a9 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 1d0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1d4:	0f b6 00             	movzbl (%rax),%eax
 1d7:	0f b6 d0             	movzbl %al,%edx
 1da:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 1de:	0f b6 00             	movzbl (%rax),%eax
 1e1:	0f b6 c0             	movzbl %al,%eax
 1e4:	29 c2                	sub    %eax,%edx
 1e6:	89 d0                	mov    %edx,%eax
}
 1e8:	c9                   	leaveq 
 1e9:	c3                   	retq   

00000000000001ea <strlen>:

uint
strlen(char *s)
{
 1ea:	55                   	push   %rbp
 1eb:	48 89 e5             	mov    %rsp,%rbp
 1ee:	48 83 ec 18          	sub    $0x18,%rsp
 1f2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 1f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 1fd:	eb 04                	jmp    203 <strlen+0x19>
 1ff:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 203:	8b 45 fc             	mov    -0x4(%rbp),%eax
 206:	48 63 d0             	movslq %eax,%rdx
 209:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 20d:	48 01 d0             	add    %rdx,%rax
 210:	0f b6 00             	movzbl (%rax),%eax
 213:	84 c0                	test   %al,%al
 215:	75 e8                	jne    1ff <strlen+0x15>
    ;
  return n;
 217:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 21a:	c9                   	leaveq 
 21b:	c3                   	retq   

000000000000021c <memset>:

void*
memset(void *dst, int c, uint n)
{
 21c:	55                   	push   %rbp
 21d:	48 89 e5             	mov    %rsp,%rbp
 220:	48 83 ec 10          	sub    $0x10,%rsp
 224:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 228:	89 75 f4             	mov    %esi,-0xc(%rbp)
 22b:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 22e:	8b 55 f0             	mov    -0x10(%rbp),%edx
 231:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 234:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 238:	89 ce                	mov    %ecx,%esi
 23a:	48 89 c7             	mov    %rax,%rdi
 23d:	e8 dc fe ff ff       	callq  11e <stosb>
  return dst;
 242:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 246:	c9                   	leaveq 
 247:	c3                   	retq   

0000000000000248 <strchr>:

char*
strchr(const char *s, char c)
{
 248:	55                   	push   %rbp
 249:	48 89 e5             	mov    %rsp,%rbp
 24c:	48 83 ec 10          	sub    $0x10,%rsp
 250:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 254:	89 f0                	mov    %esi,%eax
 256:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 259:	eb 17                	jmp    272 <strchr+0x2a>
    if(*s == c)
 25b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 25f:	0f b6 00             	movzbl (%rax),%eax
 262:	38 45 f4             	cmp    %al,-0xc(%rbp)
 265:	75 06                	jne    26d <strchr+0x25>
      return (char*)s;
 267:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 26b:	eb 15                	jmp    282 <strchr+0x3a>
  for(; *s; s++)
 26d:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 272:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 276:	0f b6 00             	movzbl (%rax),%eax
 279:	84 c0                	test   %al,%al
 27b:	75 de                	jne    25b <strchr+0x13>
  return 0;
 27d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 282:	c9                   	leaveq 
 283:	c3                   	retq   

0000000000000284 <gets>:

char*
gets(char *buf, int max)
{
 284:	55                   	push   %rbp
 285:	48 89 e5             	mov    %rsp,%rbp
 288:	48 83 ec 20          	sub    $0x20,%rsp
 28c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 290:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 293:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 29a:	eb 48                	jmp    2e4 <gets+0x60>
    cc = read(0, &c, 1);
 29c:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 2a0:	ba 01 00 00 00       	mov    $0x1,%edx
 2a5:	48 89 c6             	mov    %rax,%rsi
 2a8:	bf 00 00 00 00       	mov    $0x0,%edi
 2ad:	e8 77 01 00 00       	callq  429 <read>
 2b2:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 2b5:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 2b9:	7e 36                	jle    2f1 <gets+0x6d>
      break;
    buf[i++] = c;
 2bb:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2be:	8d 50 01             	lea    0x1(%rax),%edx
 2c1:	89 55 fc             	mov    %edx,-0x4(%rbp)
 2c4:	48 63 d0             	movslq %eax,%rdx
 2c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2cb:	48 01 c2             	add    %rax,%rdx
 2ce:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2d2:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 2d4:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2d8:	3c 0a                	cmp    $0xa,%al
 2da:	74 16                	je     2f2 <gets+0x6e>
 2dc:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 2e0:	3c 0d                	cmp    $0xd,%al
 2e2:	74 0e                	je     2f2 <gets+0x6e>
  for(i=0; i+1 < max; ){
 2e4:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2e7:	83 c0 01             	add    $0x1,%eax
 2ea:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 2ed:	7f ad                	jg     29c <gets+0x18>
 2ef:	eb 01                	jmp    2f2 <gets+0x6e>
      break;
 2f1:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2f2:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2f5:	48 63 d0             	movslq %eax,%rdx
 2f8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 2fc:	48 01 d0             	add    %rdx,%rax
 2ff:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 302:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 306:	c9                   	leaveq 
 307:	c3                   	retq   

0000000000000308 <stat>:

int
stat(char *n, struct stat *st)
{
 308:	55                   	push   %rbp
 309:	48 89 e5             	mov    %rsp,%rbp
 30c:	48 83 ec 20          	sub    $0x20,%rsp
 310:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 314:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 318:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 31c:	be 00 00 00 00       	mov    $0x0,%esi
 321:	48 89 c7             	mov    %rax,%rdi
 324:	e8 28 01 00 00       	callq  451 <open>
 329:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 32c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 330:	79 07                	jns    339 <stat+0x31>
    return -1;
 332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 337:	eb 21                	jmp    35a <stat+0x52>
  r = fstat(fd, st);
 339:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 33d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 340:	48 89 d6             	mov    %rdx,%rsi
 343:	89 c7                	mov    %eax,%edi
 345:	e8 1f 01 00 00       	callq  469 <fstat>
 34a:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 34d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 350:	89 c7                	mov    %eax,%edi
 352:	e8 e2 00 00 00       	callq  439 <close>
  return r;
 357:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 35a:	c9                   	leaveq 
 35b:	c3                   	retq   

000000000000035c <atoi>:

int
atoi(const char *s)
{
 35c:	55                   	push   %rbp
 35d:	48 89 e5             	mov    %rsp,%rbp
 360:	48 83 ec 18          	sub    $0x18,%rsp
 364:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 368:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 36f:	eb 28                	jmp    399 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 371:	8b 55 fc             	mov    -0x4(%rbp),%edx
 374:	89 d0                	mov    %edx,%eax
 376:	c1 e0 02             	shl    $0x2,%eax
 379:	01 d0                	add    %edx,%eax
 37b:	01 c0                	add    %eax,%eax
 37d:	89 c1                	mov    %eax,%ecx
 37f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 383:	48 8d 50 01          	lea    0x1(%rax),%rdx
 387:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 38b:	0f b6 00             	movzbl (%rax),%eax
 38e:	0f be c0             	movsbl %al,%eax
 391:	01 c8                	add    %ecx,%eax
 393:	83 e8 30             	sub    $0x30,%eax
 396:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 399:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 39d:	0f b6 00             	movzbl (%rax),%eax
 3a0:	3c 2f                	cmp    $0x2f,%al
 3a2:	7e 0b                	jle    3af <atoi+0x53>
 3a4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3a8:	0f b6 00             	movzbl (%rax),%eax
 3ab:	3c 39                	cmp    $0x39,%al
 3ad:	7e c2                	jle    371 <atoi+0x15>
  return n;
 3af:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 3b2:	c9                   	leaveq 
 3b3:	c3                   	retq   

00000000000003b4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3b4:	55                   	push   %rbp
 3b5:	48 89 e5             	mov    %rsp,%rbp
 3b8:	48 83 ec 28          	sub    $0x28,%rsp
 3bc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 3c0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 3c4:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 3c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3cb:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 3cf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 3d3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 3d7:	eb 1d                	jmp    3f6 <memmove+0x42>
    *dst++ = *src++;
 3d9:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 3dd:	48 8d 42 01          	lea    0x1(%rdx),%rax
 3e1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 3e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 3e9:	48 8d 48 01          	lea    0x1(%rax),%rcx
 3ed:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 3f1:	0f b6 12             	movzbl (%rdx),%edx
 3f4:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 3f6:	8b 45 dc             	mov    -0x24(%rbp),%eax
 3f9:	8d 50 ff             	lea    -0x1(%rax),%edx
 3fc:	89 55 dc             	mov    %edx,-0x24(%rbp)
 3ff:	85 c0                	test   %eax,%eax
 401:	7f d6                	jg     3d9 <memmove+0x25>
  return vdst;
 403:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 407:	c9                   	leaveq 
 408:	c3                   	retq   

0000000000000409 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 409:	b8 01 00 00 00       	mov    $0x1,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	retq   

0000000000000411 <exit>:
SYSCALL(exit)
 411:	b8 02 00 00 00       	mov    $0x2,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	retq   

0000000000000419 <wait>:
SYSCALL(wait)
 419:	b8 03 00 00 00       	mov    $0x3,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	retq   

0000000000000421 <pipe>:
SYSCALL(pipe)
 421:	b8 04 00 00 00       	mov    $0x4,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	retq   

0000000000000429 <read>:
SYSCALL(read)
 429:	b8 05 00 00 00       	mov    $0x5,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	retq   

0000000000000431 <write>:
SYSCALL(write)
 431:	b8 10 00 00 00       	mov    $0x10,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	retq   

0000000000000439 <close>:
SYSCALL(close)
 439:	b8 15 00 00 00       	mov    $0x15,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	retq   

0000000000000441 <kill>:
SYSCALL(kill)
 441:	b8 06 00 00 00       	mov    $0x6,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	retq   

0000000000000449 <exec>:
SYSCALL(exec)
 449:	b8 07 00 00 00       	mov    $0x7,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	retq   

0000000000000451 <open>:
SYSCALL(open)
 451:	b8 0f 00 00 00       	mov    $0xf,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	retq   

0000000000000459 <mknod>:
SYSCALL(mknod)
 459:	b8 11 00 00 00       	mov    $0x11,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	retq   

0000000000000461 <unlink>:
SYSCALL(unlink)
 461:	b8 12 00 00 00       	mov    $0x12,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	retq   

0000000000000469 <fstat>:
SYSCALL(fstat)
 469:	b8 08 00 00 00       	mov    $0x8,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	retq   

0000000000000471 <link>:
SYSCALL(link)
 471:	b8 13 00 00 00       	mov    $0x13,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	retq   

0000000000000479 <mkdir>:
SYSCALL(mkdir)
 479:	b8 14 00 00 00       	mov    $0x14,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	retq   

0000000000000481 <chdir>:
SYSCALL(chdir)
 481:	b8 09 00 00 00       	mov    $0x9,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	retq   

0000000000000489 <dup>:
SYSCALL(dup)
 489:	b8 0a 00 00 00       	mov    $0xa,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	retq   

0000000000000491 <getpid>:
SYSCALL(getpid)
 491:	b8 0b 00 00 00       	mov    $0xb,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	retq   

0000000000000499 <sbrk>:
SYSCALL(sbrk)
 499:	b8 0c 00 00 00       	mov    $0xc,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	retq   

00000000000004a1 <sleep>:
SYSCALL(sleep)
 4a1:	b8 0d 00 00 00       	mov    $0xd,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	retq   

00000000000004a9 <uptime>:
SYSCALL(uptime)
 4a9:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	retq   

00000000000004b1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4b1:	55                   	push   %rbp
 4b2:	48 89 e5             	mov    %rsp,%rbp
 4b5:	48 83 ec 10          	sub    $0x10,%rsp
 4b9:	89 7d fc             	mov    %edi,-0x4(%rbp)
 4bc:	89 f0                	mov    %esi,%eax
 4be:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 4c1:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 4c5:	8b 45 fc             	mov    -0x4(%rbp),%eax
 4c8:	ba 01 00 00 00       	mov    $0x1,%edx
 4cd:	48 89 ce             	mov    %rcx,%rsi
 4d0:	89 c7                	mov    %eax,%edi
 4d2:	e8 5a ff ff ff       	callq  431 <write>
}
 4d7:	90                   	nop
 4d8:	c9                   	leaveq 
 4d9:	c3                   	retq   

00000000000004da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4da:	55                   	push   %rbp
 4db:	48 89 e5             	mov    %rsp,%rbp
 4de:	48 83 ec 30          	sub    $0x30,%rsp
 4e2:	89 7d dc             	mov    %edi,-0x24(%rbp)
 4e5:	89 75 d8             	mov    %esi,-0x28(%rbp)
 4e8:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 4eb:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4ee:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 4f5:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 4f9:	74 17                	je     512 <printint+0x38>
 4fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 4ff:	79 11                	jns    512 <printint+0x38>
    neg = 1;
 501:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 508:	8b 45 d8             	mov    -0x28(%rbp),%eax
 50b:	f7 d8                	neg    %eax
 50d:	89 45 f4             	mov    %eax,-0xc(%rbp)
 510:	eb 06                	jmp    518 <printint+0x3e>
  } else {
    x = xx;
 512:	8b 45 d8             	mov    -0x28(%rbp),%eax
 515:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 518:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 51f:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 522:	8b 45 f4             	mov    -0xc(%rbp),%eax
 525:	ba 00 00 00 00       	mov    $0x0,%edx
 52a:	f7 f1                	div    %ecx
 52c:	89 d1                	mov    %edx,%ecx
 52e:	8b 45 fc             	mov    -0x4(%rbp),%eax
 531:	8d 50 01             	lea    0x1(%rax),%edx
 534:	89 55 fc             	mov    %edx,-0x4(%rbp)
 537:	89 ca                	mov    %ecx,%edx
 539:	0f b6 92 30 0e 00 00 	movzbl 0xe30(%rdx),%edx
 540:	48 98                	cltq   
 542:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 546:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 549:	8b 45 f4             	mov    -0xc(%rbp),%eax
 54c:	ba 00 00 00 00       	mov    $0x0,%edx
 551:	f7 f6                	div    %esi
 553:	89 45 f4             	mov    %eax,-0xc(%rbp)
 556:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 55a:	75 c3                	jne    51f <printint+0x45>
  if(neg)
 55c:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 560:	74 2b                	je     58d <printint+0xb3>
    buf[i++] = '-';
 562:	8b 45 fc             	mov    -0x4(%rbp),%eax
 565:	8d 50 01             	lea    0x1(%rax),%edx
 568:	89 55 fc             	mov    %edx,-0x4(%rbp)
 56b:	48 98                	cltq   
 56d:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 572:	eb 19                	jmp    58d <printint+0xb3>
    putc(fd, buf[i]);
 574:	8b 45 fc             	mov    -0x4(%rbp),%eax
 577:	48 98                	cltq   
 579:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 57e:	0f be d0             	movsbl %al,%edx
 581:	8b 45 dc             	mov    -0x24(%rbp),%eax
 584:	89 d6                	mov    %edx,%esi
 586:	89 c7                	mov    %eax,%edi
 588:	e8 24 ff ff ff       	callq  4b1 <putc>
  while(--i >= 0)
 58d:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 591:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 595:	79 dd                	jns    574 <printint+0x9a>
}
 597:	90                   	nop
 598:	c9                   	leaveq 
 599:	c3                   	retq   

000000000000059a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 59a:	55                   	push   %rbp
 59b:	48 89 e5             	mov    %rsp,%rbp
 59e:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 5a5:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 5ab:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 5b2:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 5b9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 5c0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 5c7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 5ce:	84 c0                	test   %al,%al
 5d0:	74 20                	je     5f2 <printf+0x58>
 5d2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 5d6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 5da:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 5de:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 5e2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 5e6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 5ea:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 5ee:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 5f2:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 5f9:	00 00 00 
 5fc:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 603:	00 00 00 
 606:	48 8d 45 10          	lea    0x10(%rbp),%rax
 60a:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 611:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 618:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 61f:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 626:	00 00 00 
  for(i = 0; fmt[i]; i++){
 629:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 630:	00 00 00 
 633:	e9 a8 02 00 00       	jmpq   8e0 <printf+0x346>
    c = fmt[i] & 0xff;
 638:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 63e:	48 63 d0             	movslq %eax,%rdx
 641:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 648:	48 01 d0             	add    %rdx,%rax
 64b:	0f b6 00             	movzbl (%rax),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	25 ff 00 00 00       	and    $0xff,%eax
 656:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 65c:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 663:	75 35                	jne    69a <printf+0x100>
      if(c == '%'){
 665:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 66c:	75 0f                	jne    67d <printf+0xe3>
        state = '%';
 66e:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 675:	00 00 00 
 678:	e9 5c 02 00 00       	jmpq   8d9 <printf+0x33f>
      } else {
        putc(fd, c);
 67d:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 683:	0f be d0             	movsbl %al,%edx
 686:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 68c:	89 d6                	mov    %edx,%esi
 68e:	89 c7                	mov    %eax,%edi
 690:	e8 1c fe ff ff       	callq  4b1 <putc>
 695:	e9 3f 02 00 00       	jmpq   8d9 <printf+0x33f>
      }
    } else if(state == '%'){
 69a:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 6a1:	0f 85 32 02 00 00    	jne    8d9 <printf+0x33f>
      if(c == 'd'){
 6a7:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 6ae:	75 5e                	jne    70e <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 6b0:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 6b6:	83 f8 2f             	cmp    $0x2f,%eax
 6b9:	77 23                	ja     6de <printf+0x144>
 6bb:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 6c2:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6c8:	89 d2                	mov    %edx,%edx
 6ca:	48 01 d0             	add    %rdx,%rax
 6cd:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 6d3:	83 c2 08             	add    $0x8,%edx
 6d6:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 6dc:	eb 12                	jmp    6f0 <printf+0x156>
 6de:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 6e5:	48 8d 50 08          	lea    0x8(%rax),%rdx
 6e9:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 6f0:	8b 30                	mov    (%rax),%esi
 6f2:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 6f8:	b9 01 00 00 00       	mov    $0x1,%ecx
 6fd:	ba 0a 00 00 00       	mov    $0xa,%edx
 702:	89 c7                	mov    %eax,%edi
 704:	e8 d1 fd ff ff       	callq  4da <printint>
 709:	e9 c1 01 00 00       	jmpq   8cf <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 70e:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 715:	74 09                	je     720 <printf+0x186>
 717:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 71e:	75 5e                	jne    77e <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 720:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 726:	83 f8 2f             	cmp    $0x2f,%eax
 729:	77 23                	ja     74e <printf+0x1b4>
 72b:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 732:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 738:	89 d2                	mov    %edx,%edx
 73a:	48 01 d0             	add    %rdx,%rax
 73d:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 743:	83 c2 08             	add    $0x8,%edx
 746:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 74c:	eb 12                	jmp    760 <printf+0x1c6>
 74e:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 755:	48 8d 50 08          	lea    0x8(%rax),%rdx
 759:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 760:	8b 30                	mov    (%rax),%esi
 762:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 768:	b9 00 00 00 00       	mov    $0x0,%ecx
 76d:	ba 10 00 00 00       	mov    $0x10,%edx
 772:	89 c7                	mov    %eax,%edi
 774:	e8 61 fd ff ff       	callq  4da <printint>
 779:	e9 51 01 00 00       	jmpq   8cf <printf+0x335>
      } else if(c == 's'){
 77e:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 785:	0f 85 98 00 00 00    	jne    823 <printf+0x289>
        s = va_arg(ap, char*);
 78b:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 791:	83 f8 2f             	cmp    $0x2f,%eax
 794:	77 23                	ja     7b9 <printf+0x21f>
 796:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 79d:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7a3:	89 d2                	mov    %edx,%edx
 7a5:	48 01 d0             	add    %rdx,%rax
 7a8:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 7ae:	83 c2 08             	add    $0x8,%edx
 7b1:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 7b7:	eb 12                	jmp    7cb <printf+0x231>
 7b9:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 7c0:	48 8d 50 08          	lea    0x8(%rax),%rdx
 7c4:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 7cb:	48 8b 00             	mov    (%rax),%rax
 7ce:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 7d5:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 7dc:	00 
 7dd:	75 31                	jne    810 <printf+0x276>
          s = "(null)";
 7df:	48 c7 85 48 ff ff ff 	movq   $0xbc4,-0xb8(%rbp)
 7e6:	c4 0b 00 00 
        while(*s != 0){
 7ea:	eb 24                	jmp    810 <printf+0x276>
          putc(fd, *s);
 7ec:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 7f3:	0f b6 00             	movzbl (%rax),%eax
 7f6:	0f be d0             	movsbl %al,%edx
 7f9:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 7ff:	89 d6                	mov    %edx,%esi
 801:	89 c7                	mov    %eax,%edi
 803:	e8 a9 fc ff ff       	callq  4b1 <putc>
          s++;
 808:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 80f:	01 
        while(*s != 0){
 810:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 817:	0f b6 00             	movzbl (%rax),%eax
 81a:	84 c0                	test   %al,%al
 81c:	75 ce                	jne    7ec <printf+0x252>
 81e:	e9 ac 00 00 00       	jmpq   8cf <printf+0x335>
        }
      } else if(c == 'c'){
 823:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 82a:	75 56                	jne    882 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 82c:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 832:	83 f8 2f             	cmp    $0x2f,%eax
 835:	77 23                	ja     85a <printf+0x2c0>
 837:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 83e:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 844:	89 d2                	mov    %edx,%edx
 846:	48 01 d0             	add    %rdx,%rax
 849:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 84f:	83 c2 08             	add    $0x8,%edx
 852:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 858:	eb 12                	jmp    86c <printf+0x2d2>
 85a:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 861:	48 8d 50 08          	lea    0x8(%rax),%rdx
 865:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 86c:	8b 00                	mov    (%rax),%eax
 86e:	0f be d0             	movsbl %al,%edx
 871:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 877:	89 d6                	mov    %edx,%esi
 879:	89 c7                	mov    %eax,%edi
 87b:	e8 31 fc ff ff       	callq  4b1 <putc>
 880:	eb 4d                	jmp    8cf <printf+0x335>
      } else if(c == '%'){
 882:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 889:	75 1a                	jne    8a5 <printf+0x30b>
        putc(fd, c);
 88b:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 891:	0f be d0             	movsbl %al,%edx
 894:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 89a:	89 d6                	mov    %edx,%esi
 89c:	89 c7                	mov    %eax,%edi
 89e:	e8 0e fc ff ff       	callq  4b1 <putc>
 8a3:	eb 2a                	jmp    8cf <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a5:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 8ab:	be 25 00 00 00       	mov    $0x25,%esi
 8b0:	89 c7                	mov    %eax,%edi
 8b2:	e8 fa fb ff ff       	callq  4b1 <putc>
        putc(fd, c);
 8b7:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 8bd:	0f be d0             	movsbl %al,%edx
 8c0:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 8c6:	89 d6                	mov    %edx,%esi
 8c8:	89 c7                	mov    %eax,%edi
 8ca:	e8 e2 fb ff ff       	callq  4b1 <putc>
      }
      state = 0;
 8cf:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 8d6:	00 00 00 
  for(i = 0; fmt[i]; i++){
 8d9:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 8e0:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 8e6:	48 63 d0             	movslq %eax,%rdx
 8e9:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 8f0:	48 01 d0             	add    %rdx,%rax
 8f3:	0f b6 00             	movzbl (%rax),%eax
 8f6:	84 c0                	test   %al,%al
 8f8:	0f 85 3a fd ff ff    	jne    638 <printf+0x9e>
    }
  }
}
 8fe:	90                   	nop
 8ff:	c9                   	leaveq 
 900:	c3                   	retq   

0000000000000901 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 901:	55                   	push   %rbp
 902:	48 89 e5             	mov    %rsp,%rbp
 905:	48 83 ec 18          	sub    $0x18,%rsp
 909:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 911:	48 83 e8 10          	sub    $0x10,%rax
 915:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 919:	48 8b 05 50 07 00 00 	mov    0x750(%rip),%rax        # 1070 <freep>
 920:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 924:	eb 2f                	jmp    955 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 926:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 92a:	48 8b 00             	mov    (%rax),%rax
 92d:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 931:	72 17                	jb     94a <free+0x49>
 933:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 937:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 93b:	77 2f                	ja     96c <free+0x6b>
 93d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 941:	48 8b 00             	mov    (%rax),%rax
 944:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 948:	72 22                	jb     96c <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 94e:	48 8b 00             	mov    (%rax),%rax
 951:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 955:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 959:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 95d:	76 c7                	jbe    926 <free+0x25>
 95f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 963:	48 8b 00             	mov    (%rax),%rax
 966:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 96a:	73 ba                	jae    926 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 96c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 970:	8b 40 08             	mov    0x8(%rax),%eax
 973:	89 c0                	mov    %eax,%eax
 975:	48 c1 e0 04          	shl    $0x4,%rax
 979:	48 89 c2             	mov    %rax,%rdx
 97c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 980:	48 01 c2             	add    %rax,%rdx
 983:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 987:	48 8b 00             	mov    (%rax),%rax
 98a:	48 39 c2             	cmp    %rax,%rdx
 98d:	75 2d                	jne    9bc <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 98f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 993:	8b 50 08             	mov    0x8(%rax),%edx
 996:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 99a:	48 8b 00             	mov    (%rax),%rax
 99d:	8b 40 08             	mov    0x8(%rax),%eax
 9a0:	01 c2                	add    %eax,%edx
 9a2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9a6:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9ad:	48 8b 00             	mov    (%rax),%rax
 9b0:	48 8b 10             	mov    (%rax),%rdx
 9b3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9b7:	48 89 10             	mov    %rdx,(%rax)
 9ba:	eb 0e                	jmp    9ca <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 9bc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9c0:	48 8b 10             	mov    (%rax),%rdx
 9c3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9c7:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 9ca:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9ce:	8b 40 08             	mov    0x8(%rax),%eax
 9d1:	89 c0                	mov    %eax,%eax
 9d3:	48 c1 e0 04          	shl    $0x4,%rax
 9d7:	48 89 c2             	mov    %rax,%rdx
 9da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9de:	48 01 d0             	add    %rdx,%rax
 9e1:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 9e5:	75 27                	jne    a0e <free+0x10d>
    p->s.size += bp->s.size;
 9e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9eb:	8b 50 08             	mov    0x8(%rax),%edx
 9ee:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 9f2:	8b 40 08             	mov    0x8(%rax),%eax
 9f5:	01 c2                	add    %eax,%edx
 9f7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 9fb:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 9fe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a02:	48 8b 10             	mov    (%rax),%rdx
 a05:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a09:	48 89 10             	mov    %rdx,(%rax)
 a0c:	eb 0b                	jmp    a19 <free+0x118>
  } else
    p->s.ptr = bp;
 a0e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a12:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 a16:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 a19:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a1d:	48 89 05 4c 06 00 00 	mov    %rax,0x64c(%rip)        # 1070 <freep>
}
 a24:	90                   	nop
 a25:	c9                   	leaveq 
 a26:	c3                   	retq   

0000000000000a27 <morecore>:

static Header*
morecore(uint nu)
{
 a27:	55                   	push   %rbp
 a28:	48 89 e5             	mov    %rsp,%rbp
 a2b:	48 83 ec 20          	sub    $0x20,%rsp
 a2f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 a32:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 a39:	77 07                	ja     a42 <morecore+0x1b>
    nu = 4096;
 a3b:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 a42:	8b 45 ec             	mov    -0x14(%rbp),%eax
 a45:	c1 e0 04             	shl    $0x4,%eax
 a48:	89 c7                	mov    %eax,%edi
 a4a:	e8 4a fa ff ff       	callq  499 <sbrk>
 a4f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 a53:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 a58:	75 07                	jne    a61 <morecore+0x3a>
    return 0;
 a5a:	b8 00 00 00 00       	mov    $0x0,%eax
 a5f:	eb 29                	jmp    a8a <morecore+0x63>
  hp = (Header*)p;
 a61:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 a65:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 a69:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a6d:	8b 55 ec             	mov    -0x14(%rbp),%edx
 a70:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 a73:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 a77:	48 83 c0 10          	add    $0x10,%rax
 a7b:	48 89 c7             	mov    %rax,%rdi
 a7e:	e8 7e fe ff ff       	callq  901 <free>
  return freep;
 a83:	48 8b 05 e6 05 00 00 	mov    0x5e6(%rip),%rax        # 1070 <freep>
}
 a8a:	c9                   	leaveq 
 a8b:	c3                   	retq   

0000000000000a8c <malloc>:

void*
malloc(uint nbytes)
{
 a8c:	55                   	push   %rbp
 a8d:	48 89 e5             	mov    %rsp,%rbp
 a90:	48 83 ec 30          	sub    $0x30,%rsp
 a94:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a97:	8b 45 dc             	mov    -0x24(%rbp),%eax
 a9a:	48 83 c0 0f          	add    $0xf,%rax
 a9e:	48 c1 e8 04          	shr    $0x4,%rax
 aa2:	83 c0 01             	add    $0x1,%eax
 aa5:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 aa8:	48 8b 05 c1 05 00 00 	mov    0x5c1(%rip),%rax        # 1070 <freep>
 aaf:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 ab3:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 ab8:	75 2b                	jne    ae5 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 aba:	48 c7 45 f0 60 10 00 	movq   $0x1060,-0x10(%rbp)
 ac1:	00 
 ac2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 ac6:	48 89 05 a3 05 00 00 	mov    %rax,0x5a3(%rip)        # 1070 <freep>
 acd:	48 8b 05 9c 05 00 00 	mov    0x59c(%rip),%rax        # 1070 <freep>
 ad4:	48 89 05 85 05 00 00 	mov    %rax,0x585(%rip)        # 1060 <base>
    base.s.size = 0;
 adb:	c7 05 83 05 00 00 00 	movl   $0x0,0x583(%rip)        # 1068 <base+0x8>
 ae2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 ae9:	48 8b 00             	mov    (%rax),%rax
 aec:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 af0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 af4:	8b 40 08             	mov    0x8(%rax),%eax
 af7:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 afa:	77 5f                	ja     b5b <malloc+0xcf>
      if(p->s.size == nunits)
 afc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b00:	8b 40 08             	mov    0x8(%rax),%eax
 b03:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 b06:	75 10                	jne    b18 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 b08:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b0c:	48 8b 10             	mov    (%rax),%rdx
 b0f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b13:	48 89 10             	mov    %rdx,(%rax)
 b16:	eb 2e                	jmp    b46 <malloc+0xba>
      else {
        p->s.size -= nunits;
 b18:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b1c:	8b 40 08             	mov    0x8(%rax),%eax
 b1f:	2b 45 ec             	sub    -0x14(%rbp),%eax
 b22:	89 c2                	mov    %eax,%edx
 b24:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b28:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 b2b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b2f:	8b 40 08             	mov    0x8(%rax),%eax
 b32:	89 c0                	mov    %eax,%eax
 b34:	48 c1 e0 04          	shl    $0x4,%rax
 b38:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 b3c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b40:	8b 55 ec             	mov    -0x14(%rbp),%edx
 b43:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 b46:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 b4a:	48 89 05 1f 05 00 00 	mov    %rax,0x51f(%rip)        # 1070 <freep>
      return (void*)(p + 1);
 b51:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b55:	48 83 c0 10          	add    $0x10,%rax
 b59:	eb 41                	jmp    b9c <malloc+0x110>
    }
    if(p == freep)
 b5b:	48 8b 05 0e 05 00 00 	mov    0x50e(%rip),%rax        # 1070 <freep>
 b62:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 b66:	75 1c                	jne    b84 <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 b68:	8b 45 ec             	mov    -0x14(%rbp),%eax
 b6b:	89 c7                	mov    %eax,%edi
 b6d:	e8 b5 fe ff ff       	callq  a27 <morecore>
 b72:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 b76:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 b7b:	75 07                	jne    b84 <malloc+0xf8>
        return 0;
 b7d:	b8 00 00 00 00       	mov    $0x0,%eax
 b82:	eb 18                	jmp    b9c <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b84:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b88:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 b8c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 b90:	48 8b 00             	mov    (%rax),%rax
 b93:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 b97:	e9 54 ff ff ff       	jmpq   af0 <malloc+0x64>
  }
}
 b9c:	c9                   	leaveq 
 b9d:	c3                   	retq   
