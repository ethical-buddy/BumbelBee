
fs/grep:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 30          	sub    $0x30,%rsp
   8:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
   c:	89 75 d4             	mov    %esi,-0x2c(%rbp)
  int n, m;
  char *p, *q;
  
  m = 0;
   f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  16:	e9 c8 00 00 00       	jmpq   e3 <grep+0xe3>
    m += n;
  1b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1e:	01 45 fc             	add    %eax,-0x4(%rbp)
    p = buf;
  21:	48 c7 45 f0 60 11 00 	movq   $0x1160,-0x10(%rbp)
  28:	00 
    while((q = strchr(p, '\n')) != 0){
  29:	eb 59                	jmp    84 <grep+0x84>
      *q = 0;
  2b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  2f:	c6 00 00             	movb   $0x0,(%rax)
      if(match(pattern, p)){
  32:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  36:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  3a:	48 89 d6             	mov    %rdx,%rsi
  3d:	48 89 c7             	mov    %rax,%rdi
  40:	e8 cb 01 00 00       	callq  210 <match>
  45:	85 c0                	test   %eax,%eax
  47:	74 2f                	je     78 <grep+0x78>
        *q = '\n';
  49:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  4d:	c6 00 0a             	movb   $0xa,(%rax)
        write(1, p, q+1 - p);
  50:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  54:	48 83 c0 01          	add    $0x1,%rax
  58:	48 89 c2             	mov    %rax,%rdx
  5b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  5f:	48 29 c2             	sub    %rax,%rdx
  62:	48 89 d0             	mov    %rdx,%rax
  65:	89 c2                	mov    %eax,%edx
  67:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  6b:	48 89 c6             	mov    %rax,%rsi
  6e:	bf 01 00 00 00       	mov    $0x1,%edi
  73:	e8 44 06 00 00       	callq  6bc <write>
      }
      p = q+1;
  78:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  7c:	48 83 c0 01          	add    $0x1,%rax
  80:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    while((q = strchr(p, '\n')) != 0){
  84:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  88:	be 0a 00 00 00       	mov    $0xa,%esi
  8d:	48 89 c7             	mov    %rax,%rdi
  90:	e8 3e 04 00 00       	callq  4d3 <strchr>
  95:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  99:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  9e:	75 8b                	jne    2b <grep+0x2b>
    }
    if(p == buf)
  a0:	48 81 7d f0 60 11 00 	cmpq   $0x1160,-0x10(%rbp)
  a7:	00 
  a8:	75 07                	jne    b1 <grep+0xb1>
      m = 0;
  aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    if(m > 0){
  b1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  b5:	7e 2c                	jle    e3 <grep+0xe3>
      m -= p - buf;
  b7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  ba:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  be:	48 c7 c1 60 11 00 00 	mov    $0x1160,%rcx
  c5:	48 29 ca             	sub    %rcx,%rdx
  c8:	29 d0                	sub    %edx,%eax
  ca:	89 45 fc             	mov    %eax,-0x4(%rbp)
      memmove(buf, p, m);
  cd:	8b 55 fc             	mov    -0x4(%rbp),%edx
  d0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  d4:	48 89 c6             	mov    %rax,%rsi
  d7:	48 c7 c7 60 11 00 00 	mov    $0x1160,%rdi
  de:	e8 5c 05 00 00       	callq  63f <memmove>
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  e3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  e6:	ba 00 04 00 00       	mov    $0x400,%edx
  eb:	29 c2                	sub    %eax,%edx
  ed:	89 d0                	mov    %edx,%eax
  ef:	89 c2                	mov    %eax,%edx
  f1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  f4:	48 98                	cltq   
  f6:	48 8d 88 60 11 00 00 	lea    0x1160(%rax),%rcx
  fd:	8b 45 d4             	mov    -0x2c(%rbp),%eax
 100:	48 89 ce             	mov    %rcx,%rsi
 103:	89 c7                	mov    %eax,%edi
 105:	e8 aa 05 00 00       	callq  6b4 <read>
 10a:	89 45 ec             	mov    %eax,-0x14(%rbp)
 10d:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
 111:	0f 8f 04 ff ff ff    	jg     1b <grep+0x1b>
    }
  }
}
 117:	90                   	nop
 118:	c9                   	leaveq 
 119:	c3                   	retq   

000000000000011a <main>:

int
main(int argc, char *argv[])
{
 11a:	55                   	push   %rbp
 11b:	48 89 e5             	mov    %rsp,%rbp
 11e:	48 83 ec 30          	sub    $0x30,%rsp
 122:	89 7d dc             	mov    %edi,-0x24(%rbp)
 125:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 129:	83 7d dc 01          	cmpl   $0x1,-0x24(%rbp)
 12d:	7f 1b                	jg     14a <main+0x30>
    printf(2, "usage: grep pattern [file ...]\n");
 12f:	48 c7 c6 30 0e 00 00 	mov    $0xe30,%rsi
 136:	bf 02 00 00 00       	mov    $0x2,%edi
 13b:	b8 00 00 00 00       	mov    $0x0,%eax
 140:	e8 e0 06 00 00       	callq  825 <printf>
    exit();
 145:	e8 52 05 00 00       	callq  69c <exit>
  }
  pattern = argv[1];
 14a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 14e:	48 8b 40 08          	mov    0x8(%rax),%rax
 152:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  
  if(argc <= 2){
 156:	83 7d dc 02          	cmpl   $0x2,-0x24(%rbp)
 15a:	7f 16                	jg     172 <main+0x58>
    grep(pattern, 0);
 15c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 160:	be 00 00 00 00       	mov    $0x0,%esi
 165:	48 89 c7             	mov    %rax,%rdi
 168:	e8 93 fe ff ff       	callq  0 <grep>
    exit();
 16d:	e8 2a 05 00 00       	callq  69c <exit>
  }

  for(i = 2; i < argc; i++){
 172:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%rbp)
 179:	e9 81 00 00 00       	jmpq   1ff <main+0xe5>
    if((fd = open(argv[i], 0)) < 0){
 17e:	8b 45 fc             	mov    -0x4(%rbp),%eax
 181:	48 98                	cltq   
 183:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 18a:	00 
 18b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 18f:	48 01 d0             	add    %rdx,%rax
 192:	48 8b 00             	mov    (%rax),%rax
 195:	be 00 00 00 00       	mov    $0x0,%esi
 19a:	48 89 c7             	mov    %rax,%rdi
 19d:	e8 3a 05 00 00       	callq  6dc <open>
 1a2:	89 45 ec             	mov    %eax,-0x14(%rbp)
 1a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
 1a9:	79 35                	jns    1e0 <main+0xc6>
      printf(1, "grep: cannot open %s\n", argv[i]);
 1ab:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1ae:	48 98                	cltq   
 1b0:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 1b7:	00 
 1b8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 1bc:	48 01 d0             	add    %rdx,%rax
 1bf:	48 8b 00             	mov    (%rax),%rax
 1c2:	48 89 c2             	mov    %rax,%rdx
 1c5:	48 c7 c6 50 0e 00 00 	mov    $0xe50,%rsi
 1cc:	bf 01 00 00 00       	mov    $0x1,%edi
 1d1:	b8 00 00 00 00       	mov    $0x0,%eax
 1d6:	e8 4a 06 00 00       	callq  825 <printf>
      exit();
 1db:	e8 bc 04 00 00       	callq  69c <exit>
    }
    grep(pattern, fd);
 1e0:	8b 55 ec             	mov    -0x14(%rbp),%edx
 1e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 1e7:	89 d6                	mov    %edx,%esi
 1e9:	48 89 c7             	mov    %rax,%rdi
 1ec:	e8 0f fe ff ff       	callq  0 <grep>
    close(fd);
 1f1:	8b 45 ec             	mov    -0x14(%rbp),%eax
 1f4:	89 c7                	mov    %eax,%edi
 1f6:	e8 c9 04 00 00       	callq  6c4 <close>
  for(i = 2; i < argc; i++){
 1fb:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 1ff:	8b 45 fc             	mov    -0x4(%rbp),%eax
 202:	3b 45 dc             	cmp    -0x24(%rbp),%eax
 205:	0f 8c 73 ff ff ff    	jl     17e <main+0x64>
  }
  exit();
 20b:	e8 8c 04 00 00       	callq  69c <exit>

0000000000000210 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 210:	55                   	push   %rbp
 211:	48 89 e5             	mov    %rsp,%rbp
 214:	48 83 ec 10          	sub    $0x10,%rsp
 218:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 21c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(re[0] == '^')
 220:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 224:	0f b6 00             	movzbl (%rax),%eax
 227:	3c 5e                	cmp    $0x5e,%al
 229:	75 19                	jne    244 <match+0x34>
    return matchhere(re+1, text);
 22b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 22f:	48 8d 50 01          	lea    0x1(%rax),%rdx
 233:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 237:	48 89 c6             	mov    %rax,%rsi
 23a:	48 89 d7             	mov    %rdx,%rdi
 23d:	e8 3a 00 00 00       	callq  27c <matchhere>
 242:	eb 36                	jmp    27a <match+0x6a>
  do{  // must look at empty string
    if(matchhere(re, text))
 244:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 248:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 24c:	48 89 d6             	mov    %rdx,%rsi
 24f:	48 89 c7             	mov    %rax,%rdi
 252:	e8 25 00 00 00       	callq  27c <matchhere>
 257:	85 c0                	test   %eax,%eax
 259:	74 07                	je     262 <match+0x52>
      return 1;
 25b:	b8 01 00 00 00       	mov    $0x1,%eax
 260:	eb 18                	jmp    27a <match+0x6a>
  }while(*text++ != '\0');
 262:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 266:	48 8d 50 01          	lea    0x1(%rax),%rdx
 26a:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
 26e:	0f b6 00             	movzbl (%rax),%eax
 271:	84 c0                	test   %al,%al
 273:	75 cf                	jne    244 <match+0x34>
  return 0;
 275:	b8 00 00 00 00       	mov    $0x0,%eax
}
 27a:	c9                   	leaveq 
 27b:	c3                   	retq   

000000000000027c <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 27c:	55                   	push   %rbp
 27d:	48 89 e5             	mov    %rsp,%rbp
 280:	48 83 ec 10          	sub    $0x10,%rsp
 284:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 288:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  if(re[0] == '\0')
 28c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 290:	0f b6 00             	movzbl (%rax),%eax
 293:	84 c0                	test   %al,%al
 295:	75 0a                	jne    2a1 <matchhere+0x25>
    return 1;
 297:	b8 01 00 00 00       	mov    $0x1,%eax
 29c:	e9 a6 00 00 00       	jmpq   347 <matchhere+0xcb>
  if(re[1] == '*')
 2a1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2a5:	48 83 c0 01          	add    $0x1,%rax
 2a9:	0f b6 00             	movzbl (%rax),%eax
 2ac:	3c 2a                	cmp    $0x2a,%al
 2ae:	75 22                	jne    2d2 <matchhere+0x56>
    return matchstar(re[0], re+2, text);
 2b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2b4:	48 8d 48 02          	lea    0x2(%rax),%rcx
 2b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2bc:	0f b6 00             	movzbl (%rax),%eax
 2bf:	0f be c0             	movsbl %al,%eax
 2c2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 2c6:	48 89 ce             	mov    %rcx,%rsi
 2c9:	89 c7                	mov    %eax,%edi
 2cb:	e8 79 00 00 00       	callq  349 <matchstar>
 2d0:	eb 75                	jmp    347 <matchhere+0xcb>
  if(re[0] == '$' && re[1] == '\0')
 2d2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2d6:	0f b6 00             	movzbl (%rax),%eax
 2d9:	3c 24                	cmp    $0x24,%al
 2db:	75 20                	jne    2fd <matchhere+0x81>
 2dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2e1:	48 83 c0 01          	add    $0x1,%rax
 2e5:	0f b6 00             	movzbl (%rax),%eax
 2e8:	84 c0                	test   %al,%al
 2ea:	75 11                	jne    2fd <matchhere+0x81>
    return *text == '\0';
 2ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 2f0:	0f b6 00             	movzbl (%rax),%eax
 2f3:	84 c0                	test   %al,%al
 2f5:	0f 94 c0             	sete   %al
 2f8:	0f b6 c0             	movzbl %al,%eax
 2fb:	eb 4a                	jmp    347 <matchhere+0xcb>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 301:	0f b6 00             	movzbl (%rax),%eax
 304:	84 c0                	test   %al,%al
 306:	74 3a                	je     342 <matchhere+0xc6>
 308:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 30c:	0f b6 00             	movzbl (%rax),%eax
 30f:	3c 2e                	cmp    $0x2e,%al
 311:	74 12                	je     325 <matchhere+0xa9>
 313:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 317:	0f b6 10             	movzbl (%rax),%edx
 31a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 31e:	0f b6 00             	movzbl (%rax),%eax
 321:	38 c2                	cmp    %al,%dl
 323:	75 1d                	jne    342 <matchhere+0xc6>
    return matchhere(re+1, text+1);
 325:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 329:	48 8d 50 01          	lea    0x1(%rax),%rdx
 32d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 331:	48 83 c0 01          	add    $0x1,%rax
 335:	48 89 d6             	mov    %rdx,%rsi
 338:	48 89 c7             	mov    %rax,%rdi
 33b:	e8 3c ff ff ff       	callq  27c <matchhere>
 340:	eb 05                	jmp    347 <matchhere+0xcb>
  return 0;
 342:	b8 00 00 00 00       	mov    $0x0,%eax
}
 347:	c9                   	leaveq 
 348:	c3                   	retq   

0000000000000349 <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 349:	55                   	push   %rbp
 34a:	48 89 e5             	mov    %rsp,%rbp
 34d:	48 83 ec 20          	sub    $0x20,%rsp
 351:	89 7d fc             	mov    %edi,-0x4(%rbp)
 354:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
 358:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 35c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
 360:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 364:	48 89 d6             	mov    %rdx,%rsi
 367:	48 89 c7             	mov    %rax,%rdi
 36a:	e8 0d ff ff ff       	callq  27c <matchhere>
 36f:	85 c0                	test   %eax,%eax
 371:	74 07                	je     37a <matchstar+0x31>
      return 1;
 373:	b8 01 00 00 00       	mov    $0x1,%eax
 378:	eb 2d                	jmp    3a7 <matchstar+0x5e>
  }while(*text!='\0' && (*text++==c || c=='.'));
 37a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 37e:	0f b6 00             	movzbl (%rax),%eax
 381:	84 c0                	test   %al,%al
 383:	74 1d                	je     3a2 <matchstar+0x59>
 385:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 389:	48 8d 50 01          	lea    0x1(%rax),%rdx
 38d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 391:	0f b6 00             	movzbl (%rax),%eax
 394:	0f be c0             	movsbl %al,%eax
 397:	39 45 fc             	cmp    %eax,-0x4(%rbp)
 39a:	74 c0                	je     35c <matchstar+0x13>
 39c:	83 7d fc 2e          	cmpl   $0x2e,-0x4(%rbp)
 3a0:	74 ba                	je     35c <matchstar+0x13>
  return 0;
 3a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3a7:	c9                   	leaveq 
 3a8:	c3                   	retq   

00000000000003a9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3a9:	55                   	push   %rbp
 3aa:	48 89 e5             	mov    %rsp,%rbp
 3ad:	48 83 ec 10          	sub    $0x10,%rsp
 3b1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 3b5:	89 75 f4             	mov    %esi,-0xc(%rbp)
 3b8:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 3bb:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 3bf:	8b 55 f0             	mov    -0x10(%rbp),%edx
 3c2:	8b 45 f4             	mov    -0xc(%rbp),%eax
 3c5:	48 89 ce             	mov    %rcx,%rsi
 3c8:	48 89 f7             	mov    %rsi,%rdi
 3cb:	89 d1                	mov    %edx,%ecx
 3cd:	fc                   	cld    
 3ce:	f3 aa                	rep stos %al,%es:(%rdi)
 3d0:	89 ca                	mov    %ecx,%edx
 3d2:	48 89 fe             	mov    %rdi,%rsi
 3d5:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 3d9:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3dc:	90                   	nop
 3dd:	c9                   	leaveq 
 3de:	c3                   	retq   

00000000000003df <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3df:	55                   	push   %rbp
 3e0:	48 89 e5             	mov    %rsp,%rbp
 3e3:	48 83 ec 20          	sub    $0x20,%rsp
 3e7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 3eb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 3ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3f3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 3f7:	90                   	nop
 3f8:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 3fc:	48 8d 42 01          	lea    0x1(%rdx),%rax
 400:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 404:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 408:	48 8d 48 01          	lea    0x1(%rax),%rcx
 40c:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 410:	0f b6 12             	movzbl (%rdx),%edx
 413:	88 10                	mov    %dl,(%rax)
 415:	0f b6 00             	movzbl (%rax),%eax
 418:	84 c0                	test   %al,%al
 41a:	75 dc                	jne    3f8 <strcpy+0x19>
    ;
  return os;
 41c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 420:	c9                   	leaveq 
 421:	c3                   	retq   

0000000000000422 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 422:	55                   	push   %rbp
 423:	48 89 e5             	mov    %rsp,%rbp
 426:	48 83 ec 10          	sub    $0x10,%rsp
 42a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 42e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 432:	eb 0a                	jmp    43e <strcmp+0x1c>
    p++, q++;
 434:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 439:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 43e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 442:	0f b6 00             	movzbl (%rax),%eax
 445:	84 c0                	test   %al,%al
 447:	74 12                	je     45b <strcmp+0x39>
 449:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 44d:	0f b6 10             	movzbl (%rax),%edx
 450:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 454:	0f b6 00             	movzbl (%rax),%eax
 457:	38 c2                	cmp    %al,%dl
 459:	74 d9                	je     434 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 45b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 45f:	0f b6 00             	movzbl (%rax),%eax
 462:	0f b6 d0             	movzbl %al,%edx
 465:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 469:	0f b6 00             	movzbl (%rax),%eax
 46c:	0f b6 c0             	movzbl %al,%eax
 46f:	29 c2                	sub    %eax,%edx
 471:	89 d0                	mov    %edx,%eax
}
 473:	c9                   	leaveq 
 474:	c3                   	retq   

0000000000000475 <strlen>:

uint
strlen(char *s)
{
 475:	55                   	push   %rbp
 476:	48 89 e5             	mov    %rsp,%rbp
 479:	48 83 ec 18          	sub    $0x18,%rsp
 47d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 481:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 488:	eb 04                	jmp    48e <strlen+0x19>
 48a:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 48e:	8b 45 fc             	mov    -0x4(%rbp),%eax
 491:	48 63 d0             	movslq %eax,%rdx
 494:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 498:	48 01 d0             	add    %rdx,%rax
 49b:	0f b6 00             	movzbl (%rax),%eax
 49e:	84 c0                	test   %al,%al
 4a0:	75 e8                	jne    48a <strlen+0x15>
    ;
  return n;
 4a2:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 4a5:	c9                   	leaveq 
 4a6:	c3                   	retq   

00000000000004a7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4a7:	55                   	push   %rbp
 4a8:	48 89 e5             	mov    %rsp,%rbp
 4ab:	48 83 ec 10          	sub    $0x10,%rsp
 4af:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 4b3:	89 75 f4             	mov    %esi,-0xc(%rbp)
 4b6:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 4b9:	8b 55 f0             	mov    -0x10(%rbp),%edx
 4bc:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 4bf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4c3:	89 ce                	mov    %ecx,%esi
 4c5:	48 89 c7             	mov    %rax,%rdi
 4c8:	e8 dc fe ff ff       	callq  3a9 <stosb>
  return dst;
 4cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 4d1:	c9                   	leaveq 
 4d2:	c3                   	retq   

00000000000004d3 <strchr>:

char*
strchr(const char *s, char c)
{
 4d3:	55                   	push   %rbp
 4d4:	48 89 e5             	mov    %rsp,%rbp
 4d7:	48 83 ec 10          	sub    $0x10,%rsp
 4db:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 4df:	89 f0                	mov    %esi,%eax
 4e1:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 4e4:	eb 17                	jmp    4fd <strchr+0x2a>
    if(*s == c)
 4e6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4ea:	0f b6 00             	movzbl (%rax),%eax
 4ed:	38 45 f4             	cmp    %al,-0xc(%rbp)
 4f0:	75 06                	jne    4f8 <strchr+0x25>
      return (char*)s;
 4f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4f6:	eb 15                	jmp    50d <strchr+0x3a>
  for(; *s; s++)
 4f8:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 4fd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 501:	0f b6 00             	movzbl (%rax),%eax
 504:	84 c0                	test   %al,%al
 506:	75 de                	jne    4e6 <strchr+0x13>
  return 0;
 508:	b8 00 00 00 00       	mov    $0x0,%eax
}
 50d:	c9                   	leaveq 
 50e:	c3                   	retq   

000000000000050f <gets>:

char*
gets(char *buf, int max)
{
 50f:	55                   	push   %rbp
 510:	48 89 e5             	mov    %rsp,%rbp
 513:	48 83 ec 20          	sub    $0x20,%rsp
 517:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 51b:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 51e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 525:	eb 48                	jmp    56f <gets+0x60>
    cc = read(0, &c, 1);
 527:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 52b:	ba 01 00 00 00       	mov    $0x1,%edx
 530:	48 89 c6             	mov    %rax,%rsi
 533:	bf 00 00 00 00       	mov    $0x0,%edi
 538:	e8 77 01 00 00       	callq  6b4 <read>
 53d:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 540:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 544:	7e 36                	jle    57c <gets+0x6d>
      break;
    buf[i++] = c;
 546:	8b 45 fc             	mov    -0x4(%rbp),%eax
 549:	8d 50 01             	lea    0x1(%rax),%edx
 54c:	89 55 fc             	mov    %edx,-0x4(%rbp)
 54f:	48 63 d0             	movslq %eax,%rdx
 552:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 556:	48 01 c2             	add    %rax,%rdx
 559:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 55d:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 55f:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 563:	3c 0a                	cmp    $0xa,%al
 565:	74 16                	je     57d <gets+0x6e>
 567:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 56b:	3c 0d                	cmp    $0xd,%al
 56d:	74 0e                	je     57d <gets+0x6e>
  for(i=0; i+1 < max; ){
 56f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 572:	83 c0 01             	add    $0x1,%eax
 575:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 578:	7f ad                	jg     527 <gets+0x18>
 57a:	eb 01                	jmp    57d <gets+0x6e>
      break;
 57c:	90                   	nop
      break;
  }
  buf[i] = '\0';
 57d:	8b 45 fc             	mov    -0x4(%rbp),%eax
 580:	48 63 d0             	movslq %eax,%rdx
 583:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 587:	48 01 d0             	add    %rdx,%rax
 58a:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 58d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 591:	c9                   	leaveq 
 592:	c3                   	retq   

0000000000000593 <stat>:

int
stat(char *n, struct stat *st)
{
 593:	55                   	push   %rbp
 594:	48 89 e5             	mov    %rsp,%rbp
 597:	48 83 ec 20          	sub    $0x20,%rsp
 59b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 59f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 5a7:	be 00 00 00 00       	mov    $0x0,%esi
 5ac:	48 89 c7             	mov    %rax,%rdi
 5af:	e8 28 01 00 00       	callq  6dc <open>
 5b4:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 5b7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 5bb:	79 07                	jns    5c4 <stat+0x31>
    return -1;
 5bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5c2:	eb 21                	jmp    5e5 <stat+0x52>
  r = fstat(fd, st);
 5c4:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 5c8:	8b 45 fc             	mov    -0x4(%rbp),%eax
 5cb:	48 89 d6             	mov    %rdx,%rsi
 5ce:	89 c7                	mov    %eax,%edi
 5d0:	e8 1f 01 00 00       	callq  6f4 <fstat>
 5d5:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 5d8:	8b 45 fc             	mov    -0x4(%rbp),%eax
 5db:	89 c7                	mov    %eax,%edi
 5dd:	e8 e2 00 00 00       	callq  6c4 <close>
  return r;
 5e2:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 5e5:	c9                   	leaveq 
 5e6:	c3                   	retq   

00000000000005e7 <atoi>:

int
atoi(const char *s)
{
 5e7:	55                   	push   %rbp
 5e8:	48 89 e5             	mov    %rsp,%rbp
 5eb:	48 83 ec 18          	sub    $0x18,%rsp
 5ef:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 5f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 5fa:	eb 28                	jmp    624 <atoi+0x3d>
    n = n*10 + *s++ - '0';
 5fc:	8b 55 fc             	mov    -0x4(%rbp),%edx
 5ff:	89 d0                	mov    %edx,%eax
 601:	c1 e0 02             	shl    $0x2,%eax
 604:	01 d0                	add    %edx,%eax
 606:	01 c0                	add    %eax,%eax
 608:	89 c1                	mov    %eax,%ecx
 60a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 60e:	48 8d 50 01          	lea    0x1(%rax),%rdx
 612:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 616:	0f b6 00             	movzbl (%rax),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	01 c8                	add    %ecx,%eax
 61e:	83 e8 30             	sub    $0x30,%eax
 621:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 624:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 628:	0f b6 00             	movzbl (%rax),%eax
 62b:	3c 2f                	cmp    $0x2f,%al
 62d:	7e 0b                	jle    63a <atoi+0x53>
 62f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 633:	0f b6 00             	movzbl (%rax),%eax
 636:	3c 39                	cmp    $0x39,%al
 638:	7e c2                	jle    5fc <atoi+0x15>
  return n;
 63a:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 63d:	c9                   	leaveq 
 63e:	c3                   	retq   

000000000000063f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 63f:	55                   	push   %rbp
 640:	48 89 e5             	mov    %rsp,%rbp
 643:	48 83 ec 28          	sub    $0x28,%rsp
 647:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 64b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 64f:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 652:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 656:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 65a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 65e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 662:	eb 1d                	jmp    681 <memmove+0x42>
    *dst++ = *src++;
 664:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 668:	48 8d 42 01          	lea    0x1(%rdx),%rax
 66c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 670:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 674:	48 8d 48 01          	lea    0x1(%rax),%rcx
 678:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 67c:	0f b6 12             	movzbl (%rdx),%edx
 67f:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 681:	8b 45 dc             	mov    -0x24(%rbp),%eax
 684:	8d 50 ff             	lea    -0x1(%rax),%edx
 687:	89 55 dc             	mov    %edx,-0x24(%rbp)
 68a:	85 c0                	test   %eax,%eax
 68c:	7f d6                	jg     664 <memmove+0x25>
  return vdst;
 68e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 692:	c9                   	leaveq 
 693:	c3                   	retq   

0000000000000694 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 694:	b8 01 00 00 00       	mov    $0x1,%eax
 699:	cd 40                	int    $0x40
 69b:	c3                   	retq   

000000000000069c <exit>:
SYSCALL(exit)
 69c:	b8 02 00 00 00       	mov    $0x2,%eax
 6a1:	cd 40                	int    $0x40
 6a3:	c3                   	retq   

00000000000006a4 <wait>:
SYSCALL(wait)
 6a4:	b8 03 00 00 00       	mov    $0x3,%eax
 6a9:	cd 40                	int    $0x40
 6ab:	c3                   	retq   

00000000000006ac <pipe>:
SYSCALL(pipe)
 6ac:	b8 04 00 00 00       	mov    $0x4,%eax
 6b1:	cd 40                	int    $0x40
 6b3:	c3                   	retq   

00000000000006b4 <read>:
SYSCALL(read)
 6b4:	b8 05 00 00 00       	mov    $0x5,%eax
 6b9:	cd 40                	int    $0x40
 6bb:	c3                   	retq   

00000000000006bc <write>:
SYSCALL(write)
 6bc:	b8 10 00 00 00       	mov    $0x10,%eax
 6c1:	cd 40                	int    $0x40
 6c3:	c3                   	retq   

00000000000006c4 <close>:
SYSCALL(close)
 6c4:	b8 15 00 00 00       	mov    $0x15,%eax
 6c9:	cd 40                	int    $0x40
 6cb:	c3                   	retq   

00000000000006cc <kill>:
SYSCALL(kill)
 6cc:	b8 06 00 00 00       	mov    $0x6,%eax
 6d1:	cd 40                	int    $0x40
 6d3:	c3                   	retq   

00000000000006d4 <exec>:
SYSCALL(exec)
 6d4:	b8 07 00 00 00       	mov    $0x7,%eax
 6d9:	cd 40                	int    $0x40
 6db:	c3                   	retq   

00000000000006dc <open>:
SYSCALL(open)
 6dc:	b8 0f 00 00 00       	mov    $0xf,%eax
 6e1:	cd 40                	int    $0x40
 6e3:	c3                   	retq   

00000000000006e4 <mknod>:
SYSCALL(mknod)
 6e4:	b8 11 00 00 00       	mov    $0x11,%eax
 6e9:	cd 40                	int    $0x40
 6eb:	c3                   	retq   

00000000000006ec <unlink>:
SYSCALL(unlink)
 6ec:	b8 12 00 00 00       	mov    $0x12,%eax
 6f1:	cd 40                	int    $0x40
 6f3:	c3                   	retq   

00000000000006f4 <fstat>:
SYSCALL(fstat)
 6f4:	b8 08 00 00 00       	mov    $0x8,%eax
 6f9:	cd 40                	int    $0x40
 6fb:	c3                   	retq   

00000000000006fc <link>:
SYSCALL(link)
 6fc:	b8 13 00 00 00       	mov    $0x13,%eax
 701:	cd 40                	int    $0x40
 703:	c3                   	retq   

0000000000000704 <mkdir>:
SYSCALL(mkdir)
 704:	b8 14 00 00 00       	mov    $0x14,%eax
 709:	cd 40                	int    $0x40
 70b:	c3                   	retq   

000000000000070c <chdir>:
SYSCALL(chdir)
 70c:	b8 09 00 00 00       	mov    $0x9,%eax
 711:	cd 40                	int    $0x40
 713:	c3                   	retq   

0000000000000714 <dup>:
SYSCALL(dup)
 714:	b8 0a 00 00 00       	mov    $0xa,%eax
 719:	cd 40                	int    $0x40
 71b:	c3                   	retq   

000000000000071c <getpid>:
SYSCALL(getpid)
 71c:	b8 0b 00 00 00       	mov    $0xb,%eax
 721:	cd 40                	int    $0x40
 723:	c3                   	retq   

0000000000000724 <sbrk>:
SYSCALL(sbrk)
 724:	b8 0c 00 00 00       	mov    $0xc,%eax
 729:	cd 40                	int    $0x40
 72b:	c3                   	retq   

000000000000072c <sleep>:
SYSCALL(sleep)
 72c:	b8 0d 00 00 00       	mov    $0xd,%eax
 731:	cd 40                	int    $0x40
 733:	c3                   	retq   

0000000000000734 <uptime>:
SYSCALL(uptime)
 734:	b8 0e 00 00 00       	mov    $0xe,%eax
 739:	cd 40                	int    $0x40
 73b:	c3                   	retq   

000000000000073c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 73c:	55                   	push   %rbp
 73d:	48 89 e5             	mov    %rsp,%rbp
 740:	48 83 ec 10          	sub    $0x10,%rsp
 744:	89 7d fc             	mov    %edi,-0x4(%rbp)
 747:	89 f0                	mov    %esi,%eax
 749:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 74c:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 750:	8b 45 fc             	mov    -0x4(%rbp),%eax
 753:	ba 01 00 00 00       	mov    $0x1,%edx
 758:	48 89 ce             	mov    %rcx,%rsi
 75b:	89 c7                	mov    %eax,%edi
 75d:	e8 5a ff ff ff       	callq  6bc <write>
}
 762:	90                   	nop
 763:	c9                   	leaveq 
 764:	c3                   	retq   

0000000000000765 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 765:	55                   	push   %rbp
 766:	48 89 e5             	mov    %rsp,%rbp
 769:	48 83 ec 30          	sub    $0x30,%rsp
 76d:	89 7d dc             	mov    %edi,-0x24(%rbp)
 770:	89 75 d8             	mov    %esi,-0x28(%rbp)
 773:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 776:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 779:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 780:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 784:	74 17                	je     79d <printint+0x38>
 786:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 78a:	79 11                	jns    79d <printint+0x38>
    neg = 1;
 78c:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 793:	8b 45 d8             	mov    -0x28(%rbp),%eax
 796:	f7 d8                	neg    %eax
 798:	89 45 f4             	mov    %eax,-0xc(%rbp)
 79b:	eb 06                	jmp    7a3 <printint+0x3e>
  } else {
    x = xx;
 79d:	8b 45 d8             	mov    -0x28(%rbp),%eax
 7a0:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 7a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 7aa:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 7ad:	8b 45 f4             	mov    -0xc(%rbp),%eax
 7b0:	ba 00 00 00 00       	mov    $0x0,%edx
 7b5:	f7 f1                	div    %ecx
 7b7:	89 d1                	mov    %edx,%ecx
 7b9:	8b 45 fc             	mov    -0x4(%rbp),%eax
 7bc:	8d 50 01             	lea    0x1(%rax),%edx
 7bf:	89 55 fc             	mov    %edx,-0x4(%rbp)
 7c2:	89 ca                	mov    %ecx,%edx
 7c4:	0f b6 92 30 11 00 00 	movzbl 0x1130(%rdx),%edx
 7cb:	48 98                	cltq   
 7cd:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 7d1:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 7d4:	8b 45 f4             	mov    -0xc(%rbp),%eax
 7d7:	ba 00 00 00 00       	mov    $0x0,%edx
 7dc:	f7 f6                	div    %esi
 7de:	89 45 f4             	mov    %eax,-0xc(%rbp)
 7e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 7e5:	75 c3                	jne    7aa <printint+0x45>
  if(neg)
 7e7:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 7eb:	74 2b                	je     818 <printint+0xb3>
    buf[i++] = '-';
 7ed:	8b 45 fc             	mov    -0x4(%rbp),%eax
 7f0:	8d 50 01             	lea    0x1(%rax),%edx
 7f3:	89 55 fc             	mov    %edx,-0x4(%rbp)
 7f6:	48 98                	cltq   
 7f8:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 7fd:	eb 19                	jmp    818 <printint+0xb3>
    putc(fd, buf[i]);
 7ff:	8b 45 fc             	mov    -0x4(%rbp),%eax
 802:	48 98                	cltq   
 804:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 809:	0f be d0             	movsbl %al,%edx
 80c:	8b 45 dc             	mov    -0x24(%rbp),%eax
 80f:	89 d6                	mov    %edx,%esi
 811:	89 c7                	mov    %eax,%edi
 813:	e8 24 ff ff ff       	callq  73c <putc>
  while(--i >= 0)
 818:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 81c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 820:	79 dd                	jns    7ff <printint+0x9a>
}
 822:	90                   	nop
 823:	c9                   	leaveq 
 824:	c3                   	retq   

0000000000000825 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 825:	55                   	push   %rbp
 826:	48 89 e5             	mov    %rsp,%rbp
 829:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 830:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 836:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 83d:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 844:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 84b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 852:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 859:	84 c0                	test   %al,%al
 85b:	74 20                	je     87d <printf+0x58>
 85d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 861:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 865:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 869:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 86d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 871:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 875:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 879:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 87d:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 884:	00 00 00 
 887:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 88e:	00 00 00 
 891:	48 8d 45 10          	lea    0x10(%rbp),%rax
 895:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 89c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 8a3:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 8aa:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 8b1:	00 00 00 
  for(i = 0; fmt[i]; i++){
 8b4:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 8bb:	00 00 00 
 8be:	e9 a8 02 00 00       	jmpq   b6b <printf+0x346>
    c = fmt[i] & 0xff;
 8c3:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 8c9:	48 63 d0             	movslq %eax,%rdx
 8cc:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 8d3:	48 01 d0             	add    %rdx,%rax
 8d6:	0f b6 00             	movzbl (%rax),%eax
 8d9:	0f be c0             	movsbl %al,%eax
 8dc:	25 ff 00 00 00       	and    $0xff,%eax
 8e1:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 8e7:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 8ee:	75 35                	jne    925 <printf+0x100>
      if(c == '%'){
 8f0:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 8f7:	75 0f                	jne    908 <printf+0xe3>
        state = '%';
 8f9:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 900:	00 00 00 
 903:	e9 5c 02 00 00       	jmpq   b64 <printf+0x33f>
      } else {
        putc(fd, c);
 908:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 90e:	0f be d0             	movsbl %al,%edx
 911:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 917:	89 d6                	mov    %edx,%esi
 919:	89 c7                	mov    %eax,%edi
 91b:	e8 1c fe ff ff       	callq  73c <putc>
 920:	e9 3f 02 00 00       	jmpq   b64 <printf+0x33f>
      }
    } else if(state == '%'){
 925:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 92c:	0f 85 32 02 00 00    	jne    b64 <printf+0x33f>
      if(c == 'd'){
 932:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 939:	75 5e                	jne    999 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 93b:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 941:	83 f8 2f             	cmp    $0x2f,%eax
 944:	77 23                	ja     969 <printf+0x144>
 946:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 94d:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 953:	89 d2                	mov    %edx,%edx
 955:	48 01 d0             	add    %rdx,%rax
 958:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 95e:	83 c2 08             	add    $0x8,%edx
 961:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 967:	eb 12                	jmp    97b <printf+0x156>
 969:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 970:	48 8d 50 08          	lea    0x8(%rax),%rdx
 974:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 97b:	8b 30                	mov    (%rax),%esi
 97d:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 983:	b9 01 00 00 00       	mov    $0x1,%ecx
 988:	ba 0a 00 00 00       	mov    $0xa,%edx
 98d:	89 c7                	mov    %eax,%edi
 98f:	e8 d1 fd ff ff       	callq  765 <printint>
 994:	e9 c1 01 00 00       	jmpq   b5a <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 999:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 9a0:	74 09                	je     9ab <printf+0x186>
 9a2:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 9a9:	75 5e                	jne    a09 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 9ab:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 9b1:	83 f8 2f             	cmp    $0x2f,%eax
 9b4:	77 23                	ja     9d9 <printf+0x1b4>
 9b6:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 9bd:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 9c3:	89 d2                	mov    %edx,%edx
 9c5:	48 01 d0             	add    %rdx,%rax
 9c8:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 9ce:	83 c2 08             	add    $0x8,%edx
 9d1:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 9d7:	eb 12                	jmp    9eb <printf+0x1c6>
 9d9:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 9e0:	48 8d 50 08          	lea    0x8(%rax),%rdx
 9e4:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 9eb:	8b 30                	mov    (%rax),%esi
 9ed:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 9f3:	b9 00 00 00 00       	mov    $0x0,%ecx
 9f8:	ba 10 00 00 00       	mov    $0x10,%edx
 9fd:	89 c7                	mov    %eax,%edi
 9ff:	e8 61 fd ff ff       	callq  765 <printint>
 a04:	e9 51 01 00 00       	jmpq   b5a <printf+0x335>
      } else if(c == 's'){
 a09:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 a10:	0f 85 98 00 00 00    	jne    aae <printf+0x289>
        s = va_arg(ap, char*);
 a16:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 a1c:	83 f8 2f             	cmp    $0x2f,%eax
 a1f:	77 23                	ja     a44 <printf+0x21f>
 a21:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 a28:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 a2e:	89 d2                	mov    %edx,%edx
 a30:	48 01 d0             	add    %rdx,%rax
 a33:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 a39:	83 c2 08             	add    $0x8,%edx
 a3c:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 a42:	eb 12                	jmp    a56 <printf+0x231>
 a44:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 a4b:	48 8d 50 08          	lea    0x8(%rax),%rdx
 a4f:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 a56:	48 8b 00             	mov    (%rax),%rax
 a59:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 a60:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 a67:	00 
 a68:	75 31                	jne    a9b <printf+0x276>
          s = "(null)";
 a6a:	48 c7 85 48 ff ff ff 	movq   $0xe66,-0xb8(%rbp)
 a71:	66 0e 00 00 
        while(*s != 0){
 a75:	eb 24                	jmp    a9b <printf+0x276>
          putc(fd, *s);
 a77:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 a7e:	0f b6 00             	movzbl (%rax),%eax
 a81:	0f be d0             	movsbl %al,%edx
 a84:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 a8a:	89 d6                	mov    %edx,%esi
 a8c:	89 c7                	mov    %eax,%edi
 a8e:	e8 a9 fc ff ff       	callq  73c <putc>
          s++;
 a93:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 a9a:	01 
        while(*s != 0){
 a9b:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 aa2:	0f b6 00             	movzbl (%rax),%eax
 aa5:	84 c0                	test   %al,%al
 aa7:	75 ce                	jne    a77 <printf+0x252>
 aa9:	e9 ac 00 00 00       	jmpq   b5a <printf+0x335>
        }
      } else if(c == 'c'){
 aae:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 ab5:	75 56                	jne    b0d <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 ab7:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 abd:	83 f8 2f             	cmp    $0x2f,%eax
 ac0:	77 23                	ja     ae5 <printf+0x2c0>
 ac2:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 ac9:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 acf:	89 d2                	mov    %edx,%edx
 ad1:	48 01 d0             	add    %rdx,%rax
 ad4:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 ada:	83 c2 08             	add    $0x8,%edx
 add:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 ae3:	eb 12                	jmp    af7 <printf+0x2d2>
 ae5:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 aec:	48 8d 50 08          	lea    0x8(%rax),%rdx
 af0:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 af7:	8b 00                	mov    (%rax),%eax
 af9:	0f be d0             	movsbl %al,%edx
 afc:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b02:	89 d6                	mov    %edx,%esi
 b04:	89 c7                	mov    %eax,%edi
 b06:	e8 31 fc ff ff       	callq  73c <putc>
 b0b:	eb 4d                	jmp    b5a <printf+0x335>
      } else if(c == '%'){
 b0d:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 b14:	75 1a                	jne    b30 <printf+0x30b>
        putc(fd, c);
 b16:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 b1c:	0f be d0             	movsbl %al,%edx
 b1f:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b25:	89 d6                	mov    %edx,%esi
 b27:	89 c7                	mov    %eax,%edi
 b29:	e8 0e fc ff ff       	callq  73c <putc>
 b2e:	eb 2a                	jmp    b5a <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b30:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b36:	be 25 00 00 00       	mov    $0x25,%esi
 b3b:	89 c7                	mov    %eax,%edi
 b3d:	e8 fa fb ff ff       	callq  73c <putc>
        putc(fd, c);
 b42:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 b48:	0f be d0             	movsbl %al,%edx
 b4b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b51:	89 d6                	mov    %edx,%esi
 b53:	89 c7                	mov    %eax,%edi
 b55:	e8 e2 fb ff ff       	callq  73c <putc>
      }
      state = 0;
 b5a:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 b61:	00 00 00 
  for(i = 0; fmt[i]; i++){
 b64:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 b6b:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 b71:	48 63 d0             	movslq %eax,%rdx
 b74:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 b7b:	48 01 d0             	add    %rdx,%rax
 b7e:	0f b6 00             	movzbl (%rax),%eax
 b81:	84 c0                	test   %al,%al
 b83:	0f 85 3a fd ff ff    	jne    8c3 <printf+0x9e>
    }
  }
}
 b89:	90                   	nop
 b8a:	c9                   	leaveq 
 b8b:	c3                   	retq   

0000000000000b8c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b8c:	55                   	push   %rbp
 b8d:	48 89 e5             	mov    %rsp,%rbp
 b90:	48 83 ec 18          	sub    $0x18,%rsp
 b94:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 b9c:	48 83 e8 10          	sub    $0x10,%rax
 ba0:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ba4:	48 8b 05 c5 09 00 00 	mov    0x9c5(%rip),%rax        # 1570 <freep>
 bab:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 baf:	eb 2f                	jmp    be0 <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bb1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bb5:	48 8b 00             	mov    (%rax),%rax
 bb8:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 bbc:	72 17                	jb     bd5 <free+0x49>
 bbe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bc2:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 bc6:	77 2f                	ja     bf7 <free+0x6b>
 bc8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bcc:	48 8b 00             	mov    (%rax),%rax
 bcf:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 bd3:	72 22                	jb     bf7 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bd9:	48 8b 00             	mov    (%rax),%rax
 bdc:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 be0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 be4:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 be8:	76 c7                	jbe    bb1 <free+0x25>
 bea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bee:	48 8b 00             	mov    (%rax),%rax
 bf1:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 bf5:	73 ba                	jae    bb1 <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 bf7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bfb:	8b 40 08             	mov    0x8(%rax),%eax
 bfe:	89 c0                	mov    %eax,%eax
 c00:	48 c1 e0 04          	shl    $0x4,%rax
 c04:	48 89 c2             	mov    %rax,%rdx
 c07:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c0b:	48 01 c2             	add    %rax,%rdx
 c0e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c12:	48 8b 00             	mov    (%rax),%rax
 c15:	48 39 c2             	cmp    %rax,%rdx
 c18:	75 2d                	jne    c47 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 c1a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c1e:	8b 50 08             	mov    0x8(%rax),%edx
 c21:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c25:	48 8b 00             	mov    (%rax),%rax
 c28:	8b 40 08             	mov    0x8(%rax),%eax
 c2b:	01 c2                	add    %eax,%edx
 c2d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c31:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c34:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c38:	48 8b 00             	mov    (%rax),%rax
 c3b:	48 8b 10             	mov    (%rax),%rdx
 c3e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c42:	48 89 10             	mov    %rdx,(%rax)
 c45:	eb 0e                	jmp    c55 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 c47:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c4b:	48 8b 10             	mov    (%rax),%rdx
 c4e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c52:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 c55:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c59:	8b 40 08             	mov    0x8(%rax),%eax
 c5c:	89 c0                	mov    %eax,%eax
 c5e:	48 c1 e0 04          	shl    $0x4,%rax
 c62:	48 89 c2             	mov    %rax,%rdx
 c65:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c69:	48 01 d0             	add    %rdx,%rax
 c6c:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 c70:	75 27                	jne    c99 <free+0x10d>
    p->s.size += bp->s.size;
 c72:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c76:	8b 50 08             	mov    0x8(%rax),%edx
 c79:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c7d:	8b 40 08             	mov    0x8(%rax),%eax
 c80:	01 c2                	add    %eax,%edx
 c82:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c86:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 c89:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c8d:	48 8b 10             	mov    (%rax),%rdx
 c90:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c94:	48 89 10             	mov    %rdx,(%rax)
 c97:	eb 0b                	jmp    ca4 <free+0x118>
  } else
    p->s.ptr = bp;
 c99:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c9d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 ca1:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 ca4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ca8:	48 89 05 c1 08 00 00 	mov    %rax,0x8c1(%rip)        # 1570 <freep>
}
 caf:	90                   	nop
 cb0:	c9                   	leaveq 
 cb1:	c3                   	retq   

0000000000000cb2 <morecore>:

static Header*
morecore(uint nu)
{
 cb2:	55                   	push   %rbp
 cb3:	48 89 e5             	mov    %rsp,%rbp
 cb6:	48 83 ec 20          	sub    $0x20,%rsp
 cba:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 cbd:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 cc4:	77 07                	ja     ccd <morecore+0x1b>
    nu = 4096;
 cc6:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 ccd:	8b 45 ec             	mov    -0x14(%rbp),%eax
 cd0:	c1 e0 04             	shl    $0x4,%eax
 cd3:	89 c7                	mov    %eax,%edi
 cd5:	e8 4a fa ff ff       	callq  724 <sbrk>
 cda:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 cde:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 ce3:	75 07                	jne    cec <morecore+0x3a>
    return 0;
 ce5:	b8 00 00 00 00       	mov    $0x0,%eax
 cea:	eb 29                	jmp    d15 <morecore+0x63>
  hp = (Header*)p;
 cec:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 cf0:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 cf4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 cf8:	8b 55 ec             	mov    -0x14(%rbp),%edx
 cfb:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 cfe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d02:	48 83 c0 10          	add    $0x10,%rax
 d06:	48 89 c7             	mov    %rax,%rdi
 d09:	e8 7e fe ff ff       	callq  b8c <free>
  return freep;
 d0e:	48 8b 05 5b 08 00 00 	mov    0x85b(%rip),%rax        # 1570 <freep>
}
 d15:	c9                   	leaveq 
 d16:	c3                   	retq   

0000000000000d17 <malloc>:

void*
malloc(uint nbytes)
{
 d17:	55                   	push   %rbp
 d18:	48 89 e5             	mov    %rsp,%rbp
 d1b:	48 83 ec 30          	sub    $0x30,%rsp
 d1f:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d22:	8b 45 dc             	mov    -0x24(%rbp),%eax
 d25:	48 83 c0 0f          	add    $0xf,%rax
 d29:	48 c1 e8 04          	shr    $0x4,%rax
 d2d:	83 c0 01             	add    $0x1,%eax
 d30:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 d33:	48 8b 05 36 08 00 00 	mov    0x836(%rip),%rax        # 1570 <freep>
 d3a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 d3e:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 d43:	75 2b                	jne    d70 <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 d45:	48 c7 45 f0 60 15 00 	movq   $0x1560,-0x10(%rbp)
 d4c:	00 
 d4d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d51:	48 89 05 18 08 00 00 	mov    %rax,0x818(%rip)        # 1570 <freep>
 d58:	48 8b 05 11 08 00 00 	mov    0x811(%rip),%rax        # 1570 <freep>
 d5f:	48 89 05 fa 07 00 00 	mov    %rax,0x7fa(%rip)        # 1560 <base>
    base.s.size = 0;
 d66:	c7 05 f8 07 00 00 00 	movl   $0x0,0x7f8(%rip)        # 1568 <base+0x8>
 d6d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d70:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d74:	48 8b 00             	mov    (%rax),%rax
 d77:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 d7b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d7f:	8b 40 08             	mov    0x8(%rax),%eax
 d82:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 d85:	77 5f                	ja     de6 <malloc+0xcf>
      if(p->s.size == nunits)
 d87:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d8b:	8b 40 08             	mov    0x8(%rax),%eax
 d8e:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 d91:	75 10                	jne    da3 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 d93:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d97:	48 8b 10             	mov    (%rax),%rdx
 d9a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d9e:	48 89 10             	mov    %rdx,(%rax)
 da1:	eb 2e                	jmp    dd1 <malloc+0xba>
      else {
        p->s.size -= nunits;
 da3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 da7:	8b 40 08             	mov    0x8(%rax),%eax
 daa:	2b 45 ec             	sub    -0x14(%rbp),%eax
 dad:	89 c2                	mov    %eax,%edx
 daf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 db3:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 db6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 dba:	8b 40 08             	mov    0x8(%rax),%eax
 dbd:	89 c0                	mov    %eax,%eax
 dbf:	48 c1 e0 04          	shl    $0x4,%rax
 dc3:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 dc7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 dcb:	8b 55 ec             	mov    -0x14(%rbp),%edx
 dce:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 dd1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 dd5:	48 89 05 94 07 00 00 	mov    %rax,0x794(%rip)        # 1570 <freep>
      return (void*)(p + 1);
 ddc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 de0:	48 83 c0 10          	add    $0x10,%rax
 de4:	eb 41                	jmp    e27 <malloc+0x110>
    }
    if(p == freep)
 de6:	48 8b 05 83 07 00 00 	mov    0x783(%rip),%rax        # 1570 <freep>
 ded:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 df1:	75 1c                	jne    e0f <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 df3:	8b 45 ec             	mov    -0x14(%rbp),%eax
 df6:	89 c7                	mov    %eax,%edi
 df8:	e8 b5 fe ff ff       	callq  cb2 <morecore>
 dfd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 e01:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 e06:	75 07                	jne    e0f <malloc+0xf8>
        return 0;
 e08:	b8 00 00 00 00       	mov    $0x0,%eax
 e0d:	eb 18                	jmp    e27 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e0f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 e13:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 e17:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 e1b:	48 8b 00             	mov    (%rax),%rax
 e1e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 e22:	e9 54 ff ff ff       	jmpq   d7b <malloc+0x64>
  }
}
 e27:	c9                   	leaveq 
 e28:	c3                   	retq   
