
fs/ls:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	53                   	push   %rbx
   5:	48 83 ec 28          	sub    $0x28,%rsp
   9:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  11:	48 89 c7             	mov    %rax,%rdi
  14:	e8 57 04 00 00       	callq  470 <strlen>
  19:	89 c2                	mov    %eax,%edx
  1b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1f:	48 01 d0             	add    %rdx,%rax
  22:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  26:	eb 05                	jmp    2d <fmtname+0x2d>
  28:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  2d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  31:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  35:	72 0b                	jb     42 <fmtname+0x42>
  37:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  3b:	0f b6 00             	movzbl (%rax),%eax
  3e:	3c 2f                	cmp    $0x2f,%al
  40:	75 e6                	jne    28 <fmtname+0x28>
    ;
  p++;
  42:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  47:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  4b:	48 89 c7             	mov    %rax,%rdi
  4e:	e8 1d 04 00 00       	callq  470 <strlen>
  53:	83 f8 0d             	cmp    $0xd,%eax
  56:	76 06                	jbe    5e <fmtname+0x5e>
    return p;
  58:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  5c:	eb 60                	jmp    be <fmtname+0xbe>
  memmove(buf, p, strlen(p));
  5e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  62:	48 89 c7             	mov    %rax,%rdi
  65:	e8 06 04 00 00       	callq  470 <strlen>
  6a:	89 c2                	mov    %eax,%edx
  6c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  70:	48 89 c6             	mov    %rax,%rsi
  73:	48 c7 c7 20 11 00 00 	mov    $0x1120,%rdi
  7a:	e8 bb 05 00 00       	callq  63a <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  83:	48 89 c7             	mov    %rax,%rdi
  86:	e8 e5 03 00 00       	callq  470 <strlen>
  8b:	ba 0e 00 00 00       	mov    $0xe,%edx
  90:	89 d3                	mov    %edx,%ebx
  92:	29 c3                	sub    %eax,%ebx
  94:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  98:	48 89 c7             	mov    %rax,%rdi
  9b:	e8 d0 03 00 00       	callq  470 <strlen>
  a0:	89 c0                	mov    %eax,%eax
  a2:	48 05 20 11 00 00    	add    $0x1120,%rax
  a8:	89 da                	mov    %ebx,%edx
  aa:	be 20 00 00 00       	mov    $0x20,%esi
  af:	48 89 c7             	mov    %rax,%rdi
  b2:	e8 eb 03 00 00       	callq  4a2 <memset>
  return buf;
  b7:	48 c7 c0 20 11 00 00 	mov    $0x1120,%rax
}
  be:	48 83 c4 28          	add    $0x28,%rsp
  c2:	5b                   	pop    %rbx
  c3:	5d                   	pop    %rbp
  c4:	c3                   	retq   

00000000000000c5 <ls>:

void
ls(char *path)
{
  c5:	55                   	push   %rbp
  c6:	48 89 e5             	mov    %rsp,%rbp
  c9:	41 55                	push   %r13
  cb:	41 54                	push   %r12
  cd:	53                   	push   %rbx
  ce:	48 81 ec 58 02 00 00 	sub    $0x258,%rsp
  d5:	48 89 bd 98 fd ff ff 	mov    %rdi,-0x268(%rbp)
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  dc:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
  e3:	be 00 00 00 00       	mov    $0x0,%esi
  e8:	48 89 c7             	mov    %rax,%rdi
  eb:	e8 e7 05 00 00       	callq  6d7 <open>
  f0:	89 45 dc             	mov    %eax,-0x24(%rbp)
  f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  f7:	79 25                	jns    11e <ls+0x59>
    printf(2, "ls: cannot open %s\n", path);
  f9:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
 100:	48 89 c2             	mov    %rax,%rdx
 103:	48 c7 c6 24 0e 00 00 	mov    $0xe24,%rsi
 10a:	bf 02 00 00 00       	mov    $0x2,%edi
 10f:	b8 00 00 00 00       	mov    $0x0,%eax
 114:	e8 07 07 00 00       	callq  820 <printf>
    return;
 119:	e9 19 02 00 00       	jmpq   337 <ls+0x272>
  }
  
  if(fstat(fd, &st) < 0){
 11e:	48 8d 95 a0 fd ff ff 	lea    -0x260(%rbp),%rdx
 125:	8b 45 dc             	mov    -0x24(%rbp),%eax
 128:	48 89 d6             	mov    %rdx,%rsi
 12b:	89 c7                	mov    %eax,%edi
 12d:	e8 bd 05 00 00       	callq  6ef <fstat>
 132:	85 c0                	test   %eax,%eax
 134:	79 2f                	jns    165 <ls+0xa0>
    printf(2, "ls: cannot stat %s\n", path);
 136:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
 13d:	48 89 c2             	mov    %rax,%rdx
 140:	48 c7 c6 38 0e 00 00 	mov    $0xe38,%rsi
 147:	bf 02 00 00 00       	mov    $0x2,%edi
 14c:	b8 00 00 00 00       	mov    $0x0,%eax
 151:	e8 ca 06 00 00       	callq  820 <printf>
    close(fd);
 156:	8b 45 dc             	mov    -0x24(%rbp),%eax
 159:	89 c7                	mov    %eax,%edi
 15b:	e8 5f 05 00 00       	callq  6bf <close>
    return;
 160:	e9 d2 01 00 00       	jmpq   337 <ls+0x272>
  }
  
  switch(st.type){
 165:	0f b7 85 a0 fd ff ff 	movzwl -0x260(%rbp),%eax
 16c:	98                   	cwtl   
 16d:	83 f8 01             	cmp    $0x1,%eax
 170:	74 56                	je     1c8 <ls+0x103>
 172:	83 f8 02             	cmp    $0x2,%eax
 175:	0f 85 b2 01 00 00    	jne    32d <ls+0x268>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 17b:	44 8b ad b0 fd ff ff 	mov    -0x250(%rbp),%r13d
 182:	44 8b a5 a8 fd ff ff 	mov    -0x258(%rbp),%r12d
 189:	0f b7 85 a0 fd ff ff 	movzwl -0x260(%rbp),%eax
 190:	0f bf d8             	movswl %ax,%ebx
 193:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
 19a:	48 89 c7             	mov    %rax,%rdi
 19d:	e8 5e fe ff ff       	callq  0 <fmtname>
 1a2:	45 89 e9             	mov    %r13d,%r9d
 1a5:	45 89 e0             	mov    %r12d,%r8d
 1a8:	89 d9                	mov    %ebx,%ecx
 1aa:	48 89 c2             	mov    %rax,%rdx
 1ad:	48 c7 c6 4c 0e 00 00 	mov    $0xe4c,%rsi
 1b4:	bf 01 00 00 00       	mov    $0x1,%edi
 1b9:	b8 00 00 00 00       	mov    $0x0,%eax
 1be:	e8 5d 06 00 00       	callq  820 <printf>
    break;
 1c3:	e9 65 01 00 00       	jmpq   32d <ls+0x268>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1c8:	48 8b 85 98 fd ff ff 	mov    -0x268(%rbp),%rax
 1cf:	48 89 c7             	mov    %rax,%rdi
 1d2:	e8 99 02 00 00       	callq  470 <strlen>
 1d7:	83 c0 10             	add    $0x10,%eax
 1da:	3d 00 02 00 00       	cmp    $0x200,%eax
 1df:	76 1b                	jbe    1fc <ls+0x137>
      printf(1, "ls: path too long\n");
 1e1:	48 c7 c6 59 0e 00 00 	mov    $0xe59,%rsi
 1e8:	bf 01 00 00 00       	mov    $0x1,%edi
 1ed:	b8 00 00 00 00       	mov    $0x0,%eax
 1f2:	e8 29 06 00 00       	callq  820 <printf>
      break;
 1f7:	e9 31 01 00 00       	jmpq   32d <ls+0x268>
    }
    strcpy(buf, path);
 1fc:	48 8b 95 98 fd ff ff 	mov    -0x268(%rbp),%rdx
 203:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 20a:	48 89 d6             	mov    %rdx,%rsi
 20d:	48 89 c7             	mov    %rax,%rdi
 210:	e8 c5 01 00 00       	callq  3da <strcpy>
    p = buf+strlen(buf);
 215:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 21c:	48 89 c7             	mov    %rax,%rdi
 21f:	e8 4c 02 00 00       	callq  470 <strlen>
 224:	89 c2                	mov    %eax,%edx
 226:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 22d:	48 01 d0             	add    %rdx,%rax
 230:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    *p++ = '/';
 234:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 238:	48 8d 50 01          	lea    0x1(%rax),%rdx
 23c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
 240:	c6 00 2f             	movb   $0x2f,(%rax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 243:	e9 c2 00 00 00       	jmpq   30a <ls+0x245>
      if(de.inum == 0)
 248:	0f b7 85 c0 fd ff ff 	movzwl -0x240(%rbp),%eax
 24f:	66 85 c0             	test   %ax,%ax
 252:	75 05                	jne    259 <ls+0x194>
        continue;
 254:	e9 b1 00 00 00       	jmpq   30a <ls+0x245>
      memmove(p, de.name, DIRSIZ);
 259:	48 8d 85 c0 fd ff ff 	lea    -0x240(%rbp),%rax
 260:	48 8d 48 02          	lea    0x2(%rax),%rcx
 264:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 268:	ba 0e 00 00 00       	mov    $0xe,%edx
 26d:	48 89 ce             	mov    %rcx,%rsi
 270:	48 89 c7             	mov    %rax,%rdi
 273:	e8 c2 03 00 00       	callq  63a <memmove>
      p[DIRSIZ] = 0;
 278:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
 27c:	48 83 c0 0e          	add    $0xe,%rax
 280:	c6 00 00             	movb   $0x0,(%rax)
      if(stat(buf, &st) < 0){
 283:	48 8d 95 a0 fd ff ff 	lea    -0x260(%rbp),%rdx
 28a:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 291:	48 89 d6             	mov    %rdx,%rsi
 294:	48 89 c7             	mov    %rax,%rdi
 297:	e8 f2 02 00 00       	callq  58e <stat>
 29c:	85 c0                	test   %eax,%eax
 29e:	79 22                	jns    2c2 <ls+0x1fd>
        printf(1, "ls: cannot stat %s\n", buf);
 2a0:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 2a7:	48 89 c2             	mov    %rax,%rdx
 2aa:	48 c7 c6 38 0e 00 00 	mov    $0xe38,%rsi
 2b1:	bf 01 00 00 00       	mov    $0x1,%edi
 2b6:	b8 00 00 00 00       	mov    $0x0,%eax
 2bb:	e8 60 05 00 00       	callq  820 <printf>
        continue;
 2c0:	eb 48                	jmp    30a <ls+0x245>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 2c2:	44 8b ad b0 fd ff ff 	mov    -0x250(%rbp),%r13d
 2c9:	44 8b a5 a8 fd ff ff 	mov    -0x258(%rbp),%r12d
 2d0:	0f b7 85 a0 fd ff ff 	movzwl -0x260(%rbp),%eax
 2d7:	0f bf d8             	movswl %ax,%ebx
 2da:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
 2e1:	48 89 c7             	mov    %rax,%rdi
 2e4:	e8 17 fd ff ff       	callq  0 <fmtname>
 2e9:	45 89 e9             	mov    %r13d,%r9d
 2ec:	45 89 e0             	mov    %r12d,%r8d
 2ef:	89 d9                	mov    %ebx,%ecx
 2f1:	48 89 c2             	mov    %rax,%rdx
 2f4:	48 c7 c6 4c 0e 00 00 	mov    $0xe4c,%rsi
 2fb:	bf 01 00 00 00       	mov    $0x1,%edi
 300:	b8 00 00 00 00       	mov    $0x0,%eax
 305:	e8 16 05 00 00       	callq  820 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 30a:	48 8d 8d c0 fd ff ff 	lea    -0x240(%rbp),%rcx
 311:	8b 45 dc             	mov    -0x24(%rbp),%eax
 314:	ba 10 00 00 00       	mov    $0x10,%edx
 319:	48 89 ce             	mov    %rcx,%rsi
 31c:	89 c7                	mov    %eax,%edi
 31e:	e8 8c 03 00 00       	callq  6af <read>
 323:	83 f8 10             	cmp    $0x10,%eax
 326:	0f 84 1c ff ff ff    	je     248 <ls+0x183>
    }
    break;
 32c:	90                   	nop
  }
  close(fd);
 32d:	8b 45 dc             	mov    -0x24(%rbp),%eax
 330:	89 c7                	mov    %eax,%edi
 332:	e8 88 03 00 00       	callq  6bf <close>
}
 337:	48 81 c4 58 02 00 00 	add    $0x258,%rsp
 33e:	5b                   	pop    %rbx
 33f:	41 5c                	pop    %r12
 341:	41 5d                	pop    %r13
 343:	5d                   	pop    %rbp
 344:	c3                   	retq   

0000000000000345 <main>:

int
main(int argc, char *argv[])
{
 345:	55                   	push   %rbp
 346:	48 89 e5             	mov    %rsp,%rbp
 349:	48 83 ec 20          	sub    $0x20,%rsp
 34d:	89 7d ec             	mov    %edi,-0x14(%rbp)
 350:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int i;

  if(argc < 2){
 354:	83 7d ec 01          	cmpl   $0x1,-0x14(%rbp)
 358:	7f 11                	jg     36b <main+0x26>
    ls(".");
 35a:	48 c7 c7 6c 0e 00 00 	mov    $0xe6c,%rdi
 361:	e8 5f fd ff ff       	callq  c5 <ls>
    exit();
 366:	e8 2c 03 00 00       	callq  697 <exit>
  }
  for(i=1; i<argc; i++)
 36b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
 372:	eb 23                	jmp    397 <main+0x52>
    ls(argv[i]);
 374:	8b 45 fc             	mov    -0x4(%rbp),%eax
 377:	48 98                	cltq   
 379:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
 380:	00 
 381:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 385:	48 01 d0             	add    %rdx,%rax
 388:	48 8b 00             	mov    (%rax),%rax
 38b:	48 89 c7             	mov    %rax,%rdi
 38e:	e8 32 fd ff ff       	callq  c5 <ls>
  for(i=1; i<argc; i++)
 393:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 397:	8b 45 fc             	mov    -0x4(%rbp),%eax
 39a:	3b 45 ec             	cmp    -0x14(%rbp),%eax
 39d:	7c d5                	jl     374 <main+0x2f>
  exit();
 39f:	e8 f3 02 00 00       	callq  697 <exit>

00000000000003a4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3a4:	55                   	push   %rbp
 3a5:	48 89 e5             	mov    %rsp,%rbp
 3a8:	48 83 ec 10          	sub    $0x10,%rsp
 3ac:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 3b0:	89 75 f4             	mov    %esi,-0xc(%rbp)
 3b3:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
 3b6:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
 3ba:	8b 55 f0             	mov    -0x10(%rbp),%edx
 3bd:	8b 45 f4             	mov    -0xc(%rbp),%eax
 3c0:	48 89 ce             	mov    %rcx,%rsi
 3c3:	48 89 f7             	mov    %rsi,%rdi
 3c6:	89 d1                	mov    %edx,%ecx
 3c8:	fc                   	cld    
 3c9:	f3 aa                	rep stos %al,%es:(%rdi)
 3cb:	89 ca                	mov    %ecx,%edx
 3cd:	48 89 fe             	mov    %rdi,%rsi
 3d0:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
 3d4:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3d7:	90                   	nop
 3d8:	c9                   	leaveq 
 3d9:	c3                   	retq   

00000000000003da <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3da:	55                   	push   %rbp
 3db:	48 89 e5             	mov    %rsp,%rbp
 3de:	48 83 ec 20          	sub    $0x20,%rsp
 3e2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 3e6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
 3ea:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 3ee:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
 3f2:	90                   	nop
 3f3:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 3f7:	48 8d 42 01          	lea    0x1(%rdx),%rax
 3fb:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
 3ff:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 403:	48 8d 48 01          	lea    0x1(%rax),%rcx
 407:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
 40b:	0f b6 12             	movzbl (%rdx),%edx
 40e:	88 10                	mov    %dl,(%rax)
 410:	0f b6 00             	movzbl (%rax),%eax
 413:	84 c0                	test   %al,%al
 415:	75 dc                	jne    3f3 <strcpy+0x19>
    ;
  return os;
 417:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 41b:	c9                   	leaveq 
 41c:	c3                   	retq   

000000000000041d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 41d:	55                   	push   %rbp
 41e:	48 89 e5             	mov    %rsp,%rbp
 421:	48 83 ec 10          	sub    $0x10,%rsp
 425:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 429:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
 42d:	eb 0a                	jmp    439 <strcmp+0x1c>
    p++, q++;
 42f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 434:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
 439:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 43d:	0f b6 00             	movzbl (%rax),%eax
 440:	84 c0                	test   %al,%al
 442:	74 12                	je     456 <strcmp+0x39>
 444:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 448:	0f b6 10             	movzbl (%rax),%edx
 44b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 44f:	0f b6 00             	movzbl (%rax),%eax
 452:	38 c2                	cmp    %al,%dl
 454:	74 d9                	je     42f <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
 456:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 45a:	0f b6 00             	movzbl (%rax),%eax
 45d:	0f b6 d0             	movzbl %al,%edx
 460:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 464:	0f b6 00             	movzbl (%rax),%eax
 467:	0f b6 c0             	movzbl %al,%eax
 46a:	29 c2                	sub    %eax,%edx
 46c:	89 d0                	mov    %edx,%eax
}
 46e:	c9                   	leaveq 
 46f:	c3                   	retq   

0000000000000470 <strlen>:

uint
strlen(char *s)
{
 470:	55                   	push   %rbp
 471:	48 89 e5             	mov    %rsp,%rbp
 474:	48 83 ec 18          	sub    $0x18,%rsp
 478:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
 47c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 483:	eb 04                	jmp    489 <strlen+0x19>
 485:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
 489:	8b 45 fc             	mov    -0x4(%rbp),%eax
 48c:	48 63 d0             	movslq %eax,%rdx
 48f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 493:	48 01 d0             	add    %rdx,%rax
 496:	0f b6 00             	movzbl (%rax),%eax
 499:	84 c0                	test   %al,%al
 49b:	75 e8                	jne    485 <strlen+0x15>
    ;
  return n;
 49d:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 4a0:	c9                   	leaveq 
 4a1:	c3                   	retq   

00000000000004a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4a2:	55                   	push   %rbp
 4a3:	48 89 e5             	mov    %rsp,%rbp
 4a6:	48 83 ec 10          	sub    $0x10,%rsp
 4aa:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 4ae:	89 75 f4             	mov    %esi,-0xc(%rbp)
 4b1:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
 4b4:	8b 55 f0             	mov    -0x10(%rbp),%edx
 4b7:	8b 4d f4             	mov    -0xc(%rbp),%ecx
 4ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4be:	89 ce                	mov    %ecx,%esi
 4c0:	48 89 c7             	mov    %rax,%rdi
 4c3:	e8 dc fe ff ff       	callq  3a4 <stosb>
  return dst;
 4c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
 4cc:	c9                   	leaveq 
 4cd:	c3                   	retq   

00000000000004ce <strchr>:

char*
strchr(const char *s, char c)
{
 4ce:	55                   	push   %rbp
 4cf:	48 89 e5             	mov    %rsp,%rbp
 4d2:	48 83 ec 10          	sub    $0x10,%rsp
 4d6:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 4da:	89 f0                	mov    %esi,%eax
 4dc:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
 4df:	eb 17                	jmp    4f8 <strchr+0x2a>
    if(*s == c)
 4e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4e5:	0f b6 00             	movzbl (%rax),%eax
 4e8:	38 45 f4             	cmp    %al,-0xc(%rbp)
 4eb:	75 06                	jne    4f3 <strchr+0x25>
      return (char*)s;
 4ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4f1:	eb 15                	jmp    508 <strchr+0x3a>
  for(; *s; s++)
 4f3:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
 4f8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 4fc:	0f b6 00             	movzbl (%rax),%eax
 4ff:	84 c0                	test   %al,%al
 501:	75 de                	jne    4e1 <strchr+0x13>
  return 0;
 503:	b8 00 00 00 00       	mov    $0x0,%eax
}
 508:	c9                   	leaveq 
 509:	c3                   	retq   

000000000000050a <gets>:

char*
gets(char *buf, int max)
{
 50a:	55                   	push   %rbp
 50b:	48 89 e5             	mov    %rsp,%rbp
 50e:	48 83 ec 20          	sub    $0x20,%rsp
 512:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 516:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 519:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
 520:	eb 48                	jmp    56a <gets+0x60>
    cc = read(0, &c, 1);
 522:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
 526:	ba 01 00 00 00       	mov    $0x1,%edx
 52b:	48 89 c6             	mov    %rax,%rsi
 52e:	bf 00 00 00 00       	mov    $0x0,%edi
 533:	e8 77 01 00 00       	callq  6af <read>
 538:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
 53b:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 53f:	7e 36                	jle    577 <gets+0x6d>
      break;
    buf[i++] = c;
 541:	8b 45 fc             	mov    -0x4(%rbp),%eax
 544:	8d 50 01             	lea    0x1(%rax),%edx
 547:	89 55 fc             	mov    %edx,-0x4(%rbp)
 54a:	48 63 d0             	movslq %eax,%rdx
 54d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 551:	48 01 c2             	add    %rax,%rdx
 554:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 558:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
 55a:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 55e:	3c 0a                	cmp    $0xa,%al
 560:	74 16                	je     578 <gets+0x6e>
 562:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
 566:	3c 0d                	cmp    $0xd,%al
 568:	74 0e                	je     578 <gets+0x6e>
  for(i=0; i+1 < max; ){
 56a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 56d:	83 c0 01             	add    $0x1,%eax
 570:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
 573:	7f ad                	jg     522 <gets+0x18>
 575:	eb 01                	jmp    578 <gets+0x6e>
      break;
 577:	90                   	nop
      break;
  }
  buf[i] = '\0';
 578:	8b 45 fc             	mov    -0x4(%rbp),%eax
 57b:	48 63 d0             	movslq %eax,%rdx
 57e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 582:	48 01 d0             	add    %rdx,%rax
 585:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
 588:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 58c:	c9                   	leaveq 
 58d:	c3                   	retq   

000000000000058e <stat>:

int
stat(char *n, struct stat *st)
{
 58e:	55                   	push   %rbp
 58f:	48 89 e5             	mov    %rsp,%rbp
 592:	48 83 ec 20          	sub    $0x20,%rsp
 596:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 59a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 59e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 5a2:	be 00 00 00 00       	mov    $0x0,%esi
 5a7:	48 89 c7             	mov    %rax,%rdi
 5aa:	e8 28 01 00 00       	callq  6d7 <open>
 5af:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
 5b2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 5b6:	79 07                	jns    5bf <stat+0x31>
    return -1;
 5b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5bd:	eb 21                	jmp    5e0 <stat+0x52>
  r = fstat(fd, st);
 5bf:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
 5c3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 5c6:	48 89 d6             	mov    %rdx,%rsi
 5c9:	89 c7                	mov    %eax,%edi
 5cb:	e8 1f 01 00 00       	callq  6ef <fstat>
 5d0:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
 5d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 5d6:	89 c7                	mov    %eax,%edi
 5d8:	e8 e2 00 00 00       	callq  6bf <close>
  return r;
 5dd:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
 5e0:	c9                   	leaveq 
 5e1:	c3                   	retq   

00000000000005e2 <atoi>:

int
atoi(const char *s)
{
 5e2:	55                   	push   %rbp
 5e3:	48 89 e5             	mov    %rsp,%rbp
 5e6:	48 83 ec 18          	sub    $0x18,%rsp
 5ea:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
 5ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 5f5:	eb 28                	jmp    61f <atoi+0x3d>
    n = n*10 + *s++ - '0';
 5f7:	8b 55 fc             	mov    -0x4(%rbp),%edx
 5fa:	89 d0                	mov    %edx,%eax
 5fc:	c1 e0 02             	shl    $0x2,%eax
 5ff:	01 d0                	add    %edx,%eax
 601:	01 c0                	add    %eax,%eax
 603:	89 c1                	mov    %eax,%ecx
 605:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 609:	48 8d 50 01          	lea    0x1(%rax),%rdx
 60d:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
 611:	0f b6 00             	movzbl (%rax),%eax
 614:	0f be c0             	movsbl %al,%eax
 617:	01 c8                	add    %ecx,%eax
 619:	83 e8 30             	sub    $0x30,%eax
 61c:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
 61f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 623:	0f b6 00             	movzbl (%rax),%eax
 626:	3c 2f                	cmp    $0x2f,%al
 628:	7e 0b                	jle    635 <atoi+0x53>
 62a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 62e:	0f b6 00             	movzbl (%rax),%eax
 631:	3c 39                	cmp    $0x39,%al
 633:	7e c2                	jle    5f7 <atoi+0x15>
  return n;
 635:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
 638:	c9                   	leaveq 
 639:	c3                   	retq   

000000000000063a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 63a:	55                   	push   %rbp
 63b:	48 89 e5             	mov    %rsp,%rbp
 63e:	48 83 ec 28          	sub    $0x28,%rsp
 642:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
 646:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
 64a:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
 64d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 651:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
 655:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
 659:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
 65d:	eb 1d                	jmp    67c <memmove+0x42>
    *dst++ = *src++;
 65f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 663:	48 8d 42 01          	lea    0x1(%rdx),%rax
 667:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 66b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 66f:	48 8d 48 01          	lea    0x1(%rax),%rcx
 673:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
 677:	0f b6 12             	movzbl (%rdx),%edx
 67a:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
 67c:	8b 45 dc             	mov    -0x24(%rbp),%eax
 67f:	8d 50 ff             	lea    -0x1(%rax),%edx
 682:	89 55 dc             	mov    %edx,-0x24(%rbp)
 685:	85 c0                	test   %eax,%eax
 687:	7f d6                	jg     65f <memmove+0x25>
  return vdst;
 689:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
 68d:	c9                   	leaveq 
 68e:	c3                   	retq   

000000000000068f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 68f:	b8 01 00 00 00       	mov    $0x1,%eax
 694:	cd 40                	int    $0x40
 696:	c3                   	retq   

0000000000000697 <exit>:
SYSCALL(exit)
 697:	b8 02 00 00 00       	mov    $0x2,%eax
 69c:	cd 40                	int    $0x40
 69e:	c3                   	retq   

000000000000069f <wait>:
SYSCALL(wait)
 69f:	b8 03 00 00 00       	mov    $0x3,%eax
 6a4:	cd 40                	int    $0x40
 6a6:	c3                   	retq   

00000000000006a7 <pipe>:
SYSCALL(pipe)
 6a7:	b8 04 00 00 00       	mov    $0x4,%eax
 6ac:	cd 40                	int    $0x40
 6ae:	c3                   	retq   

00000000000006af <read>:
SYSCALL(read)
 6af:	b8 05 00 00 00       	mov    $0x5,%eax
 6b4:	cd 40                	int    $0x40
 6b6:	c3                   	retq   

00000000000006b7 <write>:
SYSCALL(write)
 6b7:	b8 10 00 00 00       	mov    $0x10,%eax
 6bc:	cd 40                	int    $0x40
 6be:	c3                   	retq   

00000000000006bf <close>:
SYSCALL(close)
 6bf:	b8 15 00 00 00       	mov    $0x15,%eax
 6c4:	cd 40                	int    $0x40
 6c6:	c3                   	retq   

00000000000006c7 <kill>:
SYSCALL(kill)
 6c7:	b8 06 00 00 00       	mov    $0x6,%eax
 6cc:	cd 40                	int    $0x40
 6ce:	c3                   	retq   

00000000000006cf <exec>:
SYSCALL(exec)
 6cf:	b8 07 00 00 00       	mov    $0x7,%eax
 6d4:	cd 40                	int    $0x40
 6d6:	c3                   	retq   

00000000000006d7 <open>:
SYSCALL(open)
 6d7:	b8 0f 00 00 00       	mov    $0xf,%eax
 6dc:	cd 40                	int    $0x40
 6de:	c3                   	retq   

00000000000006df <mknod>:
SYSCALL(mknod)
 6df:	b8 11 00 00 00       	mov    $0x11,%eax
 6e4:	cd 40                	int    $0x40
 6e6:	c3                   	retq   

00000000000006e7 <unlink>:
SYSCALL(unlink)
 6e7:	b8 12 00 00 00       	mov    $0x12,%eax
 6ec:	cd 40                	int    $0x40
 6ee:	c3                   	retq   

00000000000006ef <fstat>:
SYSCALL(fstat)
 6ef:	b8 08 00 00 00       	mov    $0x8,%eax
 6f4:	cd 40                	int    $0x40
 6f6:	c3                   	retq   

00000000000006f7 <link>:
SYSCALL(link)
 6f7:	b8 13 00 00 00       	mov    $0x13,%eax
 6fc:	cd 40                	int    $0x40
 6fe:	c3                   	retq   

00000000000006ff <mkdir>:
SYSCALL(mkdir)
 6ff:	b8 14 00 00 00       	mov    $0x14,%eax
 704:	cd 40                	int    $0x40
 706:	c3                   	retq   

0000000000000707 <chdir>:
SYSCALL(chdir)
 707:	b8 09 00 00 00       	mov    $0x9,%eax
 70c:	cd 40                	int    $0x40
 70e:	c3                   	retq   

000000000000070f <dup>:
SYSCALL(dup)
 70f:	b8 0a 00 00 00       	mov    $0xa,%eax
 714:	cd 40                	int    $0x40
 716:	c3                   	retq   

0000000000000717 <getpid>:
SYSCALL(getpid)
 717:	b8 0b 00 00 00       	mov    $0xb,%eax
 71c:	cd 40                	int    $0x40
 71e:	c3                   	retq   

000000000000071f <sbrk>:
SYSCALL(sbrk)
 71f:	b8 0c 00 00 00       	mov    $0xc,%eax
 724:	cd 40                	int    $0x40
 726:	c3                   	retq   

0000000000000727 <sleep>:
SYSCALL(sleep)
 727:	b8 0d 00 00 00       	mov    $0xd,%eax
 72c:	cd 40                	int    $0x40
 72e:	c3                   	retq   

000000000000072f <uptime>:
SYSCALL(uptime)
 72f:	b8 0e 00 00 00       	mov    $0xe,%eax
 734:	cd 40                	int    $0x40
 736:	c3                   	retq   

0000000000000737 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 737:	55                   	push   %rbp
 738:	48 89 e5             	mov    %rsp,%rbp
 73b:	48 83 ec 10          	sub    $0x10,%rsp
 73f:	89 7d fc             	mov    %edi,-0x4(%rbp)
 742:	89 f0                	mov    %esi,%eax
 744:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
 747:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
 74b:	8b 45 fc             	mov    -0x4(%rbp),%eax
 74e:	ba 01 00 00 00       	mov    $0x1,%edx
 753:	48 89 ce             	mov    %rcx,%rsi
 756:	89 c7                	mov    %eax,%edi
 758:	e8 5a ff ff ff       	callq  6b7 <write>
}
 75d:	90                   	nop
 75e:	c9                   	leaveq 
 75f:	c3                   	retq   

0000000000000760 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 760:	55                   	push   %rbp
 761:	48 89 e5             	mov    %rsp,%rbp
 764:	48 83 ec 30          	sub    $0x30,%rsp
 768:	89 7d dc             	mov    %edi,-0x24(%rbp)
 76b:	89 75 d8             	mov    %esi,-0x28(%rbp)
 76e:	89 55 d4             	mov    %edx,-0x2c(%rbp)
 771:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 774:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
 77b:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
 77f:	74 17                	je     798 <printint+0x38>
 781:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
 785:	79 11                	jns    798 <printint+0x38>
    neg = 1;
 787:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
 78e:	8b 45 d8             	mov    -0x28(%rbp),%eax
 791:	f7 d8                	neg    %eax
 793:	89 45 f4             	mov    %eax,-0xc(%rbp)
 796:	eb 06                	jmp    79e <printint+0x3e>
  } else {
    x = xx;
 798:	8b 45 d8             	mov    -0x28(%rbp),%eax
 79b:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
 79e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
 7a5:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
 7a8:	8b 45 f4             	mov    -0xc(%rbp),%eax
 7ab:	ba 00 00 00 00       	mov    $0x0,%edx
 7b0:	f7 f1                	div    %ecx
 7b2:	89 d1                	mov    %edx,%ecx
 7b4:	8b 45 fc             	mov    -0x4(%rbp),%eax
 7b7:	8d 50 01             	lea    0x1(%rax),%edx
 7ba:	89 55 fc             	mov    %edx,-0x4(%rbp)
 7bd:	89 ca                	mov    %ecx,%edx
 7bf:	0f b6 92 00 11 00 00 	movzbl 0x1100(%rdx),%edx
 7c6:	48 98                	cltq   
 7c8:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
 7cc:	8b 75 d4             	mov    -0x2c(%rbp),%esi
 7cf:	8b 45 f4             	mov    -0xc(%rbp),%eax
 7d2:	ba 00 00 00 00       	mov    $0x0,%edx
 7d7:	f7 f6                	div    %esi
 7d9:	89 45 f4             	mov    %eax,-0xc(%rbp)
 7dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
 7e0:	75 c3                	jne    7a5 <printint+0x45>
  if(neg)
 7e2:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
 7e6:	74 2b                	je     813 <printint+0xb3>
    buf[i++] = '-';
 7e8:	8b 45 fc             	mov    -0x4(%rbp),%eax
 7eb:	8d 50 01             	lea    0x1(%rax),%edx
 7ee:	89 55 fc             	mov    %edx,-0x4(%rbp)
 7f1:	48 98                	cltq   
 7f3:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
 7f8:	eb 19                	jmp    813 <printint+0xb3>
    putc(fd, buf[i]);
 7fa:	8b 45 fc             	mov    -0x4(%rbp),%eax
 7fd:	48 98                	cltq   
 7ff:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
 804:	0f be d0             	movsbl %al,%edx
 807:	8b 45 dc             	mov    -0x24(%rbp),%eax
 80a:	89 d6                	mov    %edx,%esi
 80c:	89 c7                	mov    %eax,%edi
 80e:	e8 24 ff ff ff       	callq  737 <putc>
  while(--i >= 0)
 813:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
 817:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
 81b:	79 dd                	jns    7fa <printint+0x9a>
}
 81d:	90                   	nop
 81e:	c9                   	leaveq 
 81f:	c3                   	retq   

0000000000000820 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 820:	55                   	push   %rbp
 821:	48 89 e5             	mov    %rsp,%rbp
 824:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
 82b:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
 831:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
 838:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
 83f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
 846:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
 84d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
 854:	84 c0                	test   %al,%al
 856:	74 20                	je     878 <printf+0x58>
 858:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
 85c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
 860:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
 864:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
 868:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
 86c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
 870:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
 874:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
 878:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
 87f:	00 00 00 
 882:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
 889:	00 00 00 
 88c:	48 8d 45 10          	lea    0x10(%rbp),%rax
 890:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
 897:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
 89e:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
 8a5:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 8ac:	00 00 00 
  for(i = 0; fmt[i]; i++){
 8af:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
 8b6:	00 00 00 
 8b9:	e9 a8 02 00 00       	jmpq   b66 <printf+0x346>
    c = fmt[i] & 0xff;
 8be:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 8c4:	48 63 d0             	movslq %eax,%rdx
 8c7:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 8ce:	48 01 d0             	add    %rdx,%rax
 8d1:	0f b6 00             	movzbl (%rax),%eax
 8d4:	0f be c0             	movsbl %al,%eax
 8d7:	25 ff 00 00 00       	and    $0xff,%eax
 8dc:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
 8e2:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
 8e9:	75 35                	jne    920 <printf+0x100>
      if(c == '%'){
 8eb:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 8f2:	75 0f                	jne    903 <printf+0xe3>
        state = '%';
 8f4:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
 8fb:	00 00 00 
 8fe:	e9 5c 02 00 00       	jmpq   b5f <printf+0x33f>
      } else {
        putc(fd, c);
 903:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 909:	0f be d0             	movsbl %al,%edx
 90c:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 912:	89 d6                	mov    %edx,%esi
 914:	89 c7                	mov    %eax,%edi
 916:	e8 1c fe ff ff       	callq  737 <putc>
 91b:	e9 3f 02 00 00       	jmpq   b5f <printf+0x33f>
      }
    } else if(state == '%'){
 920:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
 927:	0f 85 32 02 00 00    	jne    b5f <printf+0x33f>
      if(c == 'd'){
 92d:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
 934:	75 5e                	jne    994 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
 936:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 93c:	83 f8 2f             	cmp    $0x2f,%eax
 93f:	77 23                	ja     964 <printf+0x144>
 941:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 948:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 94e:	89 d2                	mov    %edx,%edx
 950:	48 01 d0             	add    %rdx,%rax
 953:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 959:	83 c2 08             	add    $0x8,%edx
 95c:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 962:	eb 12                	jmp    976 <printf+0x156>
 964:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 96b:	48 8d 50 08          	lea    0x8(%rax),%rdx
 96f:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 976:	8b 30                	mov    (%rax),%esi
 978:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 97e:	b9 01 00 00 00       	mov    $0x1,%ecx
 983:	ba 0a 00 00 00       	mov    $0xa,%edx
 988:	89 c7                	mov    %eax,%edi
 98a:	e8 d1 fd ff ff       	callq  760 <printint>
 98f:	e9 c1 01 00 00       	jmpq   b55 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
 994:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
 99b:	74 09                	je     9a6 <printf+0x186>
 99d:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
 9a4:	75 5e                	jne    a04 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
 9a6:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 9ac:	83 f8 2f             	cmp    $0x2f,%eax
 9af:	77 23                	ja     9d4 <printf+0x1b4>
 9b1:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 9b8:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 9be:	89 d2                	mov    %edx,%edx
 9c0:	48 01 d0             	add    %rdx,%rax
 9c3:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 9c9:	83 c2 08             	add    $0x8,%edx
 9cc:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 9d2:	eb 12                	jmp    9e6 <printf+0x1c6>
 9d4:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 9db:	48 8d 50 08          	lea    0x8(%rax),%rdx
 9df:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 9e6:	8b 30                	mov    (%rax),%esi
 9e8:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 9ee:	b9 00 00 00 00       	mov    $0x0,%ecx
 9f3:	ba 10 00 00 00       	mov    $0x10,%edx
 9f8:	89 c7                	mov    %eax,%edi
 9fa:	e8 61 fd ff ff       	callq  760 <printint>
 9ff:	e9 51 01 00 00       	jmpq   b55 <printf+0x335>
      } else if(c == 's'){
 a04:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
 a0b:	0f 85 98 00 00 00    	jne    aa9 <printf+0x289>
        s = va_arg(ap, char*);
 a11:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 a17:	83 f8 2f             	cmp    $0x2f,%eax
 a1a:	77 23                	ja     a3f <printf+0x21f>
 a1c:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 a23:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 a29:	89 d2                	mov    %edx,%edx
 a2b:	48 01 d0             	add    %rdx,%rax
 a2e:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 a34:	83 c2 08             	add    $0x8,%edx
 a37:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 a3d:	eb 12                	jmp    a51 <printf+0x231>
 a3f:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 a46:	48 8d 50 08          	lea    0x8(%rax),%rdx
 a4a:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 a51:	48 8b 00             	mov    (%rax),%rax
 a54:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
 a5b:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
 a62:	00 
 a63:	75 31                	jne    a96 <printf+0x276>
          s = "(null)";
 a65:	48 c7 85 48 ff ff ff 	movq   $0xe6e,-0xb8(%rbp)
 a6c:	6e 0e 00 00 
        while(*s != 0){
 a70:	eb 24                	jmp    a96 <printf+0x276>
          putc(fd, *s);
 a72:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 a79:	0f b6 00             	movzbl (%rax),%eax
 a7c:	0f be d0             	movsbl %al,%edx
 a7f:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 a85:	89 d6                	mov    %edx,%esi
 a87:	89 c7                	mov    %eax,%edi
 a89:	e8 a9 fc ff ff       	callq  737 <putc>
          s++;
 a8e:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
 a95:	01 
        while(*s != 0){
 a96:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
 a9d:	0f b6 00             	movzbl (%rax),%eax
 aa0:	84 c0                	test   %al,%al
 aa2:	75 ce                	jne    a72 <printf+0x252>
 aa4:	e9 ac 00 00 00       	jmpq   b55 <printf+0x335>
        }
      } else if(c == 'c'){
 aa9:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
 ab0:	75 56                	jne    b08 <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
 ab2:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
 ab8:	83 f8 2f             	cmp    $0x2f,%eax
 abb:	77 23                	ja     ae0 <printf+0x2c0>
 abd:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
 ac4:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 aca:	89 d2                	mov    %edx,%edx
 acc:	48 01 d0             	add    %rdx,%rax
 acf:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
 ad5:	83 c2 08             	add    $0x8,%edx
 ad8:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
 ade:	eb 12                	jmp    af2 <printf+0x2d2>
 ae0:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
 ae7:	48 8d 50 08          	lea    0x8(%rax),%rdx
 aeb:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
 af2:	8b 00                	mov    (%rax),%eax
 af4:	0f be d0             	movsbl %al,%edx
 af7:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 afd:	89 d6                	mov    %edx,%esi
 aff:	89 c7                	mov    %eax,%edi
 b01:	e8 31 fc ff ff       	callq  737 <putc>
 b06:	eb 4d                	jmp    b55 <printf+0x335>
      } else if(c == '%'){
 b08:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
 b0f:	75 1a                	jne    b2b <printf+0x30b>
        putc(fd, c);
 b11:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 b17:	0f be d0             	movsbl %al,%edx
 b1a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b20:	89 d6                	mov    %edx,%esi
 b22:	89 c7                	mov    %eax,%edi
 b24:	e8 0e fc ff ff       	callq  737 <putc>
 b29:	eb 2a                	jmp    b55 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b2b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b31:	be 25 00 00 00       	mov    $0x25,%esi
 b36:	89 c7                	mov    %eax,%edi
 b38:	e8 fa fb ff ff       	callq  737 <putc>
        putc(fd, c);
 b3d:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
 b43:	0f be d0             	movsbl %al,%edx
 b46:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
 b4c:	89 d6                	mov    %edx,%esi
 b4e:	89 c7                	mov    %eax,%edi
 b50:	e8 e2 fb ff ff       	callq  737 <putc>
      }
      state = 0;
 b55:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
 b5c:	00 00 00 
  for(i = 0; fmt[i]; i++){
 b5f:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
 b66:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
 b6c:	48 63 d0             	movslq %eax,%rdx
 b6f:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
 b76:	48 01 d0             	add    %rdx,%rax
 b79:	0f b6 00             	movzbl (%rax),%eax
 b7c:	84 c0                	test   %al,%al
 b7e:	0f 85 3a fd ff ff    	jne    8be <printf+0x9e>
    }
  }
}
 b84:	90                   	nop
 b85:	c9                   	leaveq 
 b86:	c3                   	retq   

0000000000000b87 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b87:	55                   	push   %rbp
 b88:	48 89 e5             	mov    %rsp,%rbp
 b8b:	48 83 ec 18          	sub    $0x18,%rsp
 b8f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b93:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
 b97:	48 83 e8 10          	sub    $0x10,%rax
 b9b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b9f:	48 8b 05 9a 05 00 00 	mov    0x59a(%rip),%rax        # 1140 <freep>
 ba6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 baa:	eb 2f                	jmp    bdb <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bb0:	48 8b 00             	mov    (%rax),%rax
 bb3:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 bb7:	72 17                	jb     bd0 <free+0x49>
 bb9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bbd:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 bc1:	77 2f                	ja     bf2 <free+0x6b>
 bc3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bc7:	48 8b 00             	mov    (%rax),%rax
 bca:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 bce:	72 22                	jb     bf2 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 bd4:	48 8b 00             	mov    (%rax),%rax
 bd7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 bdb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bdf:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
 be3:	76 c7                	jbe    bac <free+0x25>
 be5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 be9:	48 8b 00             	mov    (%rax),%rax
 bec:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 bf0:	73 ba                	jae    bac <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
 bf2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 bf6:	8b 40 08             	mov    0x8(%rax),%eax
 bf9:	89 c0                	mov    %eax,%eax
 bfb:	48 c1 e0 04          	shl    $0x4,%rax
 bff:	48 89 c2             	mov    %rax,%rdx
 c02:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c06:	48 01 c2             	add    %rax,%rdx
 c09:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c0d:	48 8b 00             	mov    (%rax),%rax
 c10:	48 39 c2             	cmp    %rax,%rdx
 c13:	75 2d                	jne    c42 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
 c15:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c19:	8b 50 08             	mov    0x8(%rax),%edx
 c1c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c20:	48 8b 00             	mov    (%rax),%rax
 c23:	8b 40 08             	mov    0x8(%rax),%eax
 c26:	01 c2                	add    %eax,%edx
 c28:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c2c:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c2f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c33:	48 8b 00             	mov    (%rax),%rax
 c36:	48 8b 10             	mov    (%rax),%rdx
 c39:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c3d:	48 89 10             	mov    %rdx,(%rax)
 c40:	eb 0e                	jmp    c50 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
 c42:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c46:	48 8b 10             	mov    (%rax),%rdx
 c49:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c4d:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
 c50:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c54:	8b 40 08             	mov    0x8(%rax),%eax
 c57:	89 c0                	mov    %eax,%eax
 c59:	48 c1 e0 04          	shl    $0x4,%rax
 c5d:	48 89 c2             	mov    %rax,%rdx
 c60:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c64:	48 01 d0             	add    %rdx,%rax
 c67:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
 c6b:	75 27                	jne    c94 <free+0x10d>
    p->s.size += bp->s.size;
 c6d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c71:	8b 50 08             	mov    0x8(%rax),%edx
 c74:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c78:	8b 40 08             	mov    0x8(%rax),%eax
 c7b:	01 c2                	add    %eax,%edx
 c7d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c81:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
 c84:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 c88:	48 8b 10             	mov    (%rax),%rdx
 c8b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c8f:	48 89 10             	mov    %rdx,(%rax)
 c92:	eb 0b                	jmp    c9f <free+0x118>
  } else
    p->s.ptr = bp;
 c94:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 c98:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
 c9c:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
 c9f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ca3:	48 89 05 96 04 00 00 	mov    %rax,0x496(%rip)        # 1140 <freep>
}
 caa:	90                   	nop
 cab:	c9                   	leaveq 
 cac:	c3                   	retq   

0000000000000cad <morecore>:

static Header*
morecore(uint nu)
{
 cad:	55                   	push   %rbp
 cae:	48 89 e5             	mov    %rsp,%rbp
 cb1:	48 83 ec 20          	sub    $0x20,%rsp
 cb5:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
 cb8:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
 cbf:	77 07                	ja     cc8 <morecore+0x1b>
    nu = 4096;
 cc1:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
 cc8:	8b 45 ec             	mov    -0x14(%rbp),%eax
 ccb:	c1 e0 04             	shl    $0x4,%eax
 cce:	89 c7                	mov    %eax,%edi
 cd0:	e8 4a fa ff ff       	callq  71f <sbrk>
 cd5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
 cd9:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
 cde:	75 07                	jne    ce7 <morecore+0x3a>
    return 0;
 ce0:	b8 00 00 00 00       	mov    $0x0,%eax
 ce5:	eb 29                	jmp    d10 <morecore+0x63>
  hp = (Header*)p;
 ce7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ceb:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
 cef:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 cf3:	8b 55 ec             	mov    -0x14(%rbp),%edx
 cf6:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
 cf9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 cfd:	48 83 c0 10          	add    $0x10,%rax
 d01:	48 89 c7             	mov    %rax,%rdi
 d04:	e8 7e fe ff ff       	callq  b87 <free>
  return freep;
 d09:	48 8b 05 30 04 00 00 	mov    0x430(%rip),%rax        # 1140 <freep>
}
 d10:	c9                   	leaveq 
 d11:	c3                   	retq   

0000000000000d12 <malloc>:

void*
malloc(uint nbytes)
{
 d12:	55                   	push   %rbp
 d13:	48 89 e5             	mov    %rsp,%rbp
 d16:	48 83 ec 30          	sub    $0x30,%rsp
 d1a:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d1d:	8b 45 dc             	mov    -0x24(%rbp),%eax
 d20:	48 83 c0 0f          	add    $0xf,%rax
 d24:	48 c1 e8 04          	shr    $0x4,%rax
 d28:	83 c0 01             	add    $0x1,%eax
 d2b:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
 d2e:	48 8b 05 0b 04 00 00 	mov    0x40b(%rip),%rax        # 1140 <freep>
 d35:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 d39:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
 d3e:	75 2b                	jne    d6b <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
 d40:	48 c7 45 f0 30 11 00 	movq   $0x1130,-0x10(%rbp)
 d47:	00 
 d48:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d4c:	48 89 05 ed 03 00 00 	mov    %rax,0x3ed(%rip)        # 1140 <freep>
 d53:	48 8b 05 e6 03 00 00 	mov    0x3e6(%rip),%rax        # 1140 <freep>
 d5a:	48 89 05 cf 03 00 00 	mov    %rax,0x3cf(%rip)        # 1130 <base>
    base.s.size = 0;
 d61:	c7 05 cd 03 00 00 00 	movl   $0x0,0x3cd(%rip)        # 1138 <base+0x8>
 d68:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d6b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d6f:	48 8b 00             	mov    (%rax),%rax
 d72:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 d76:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d7a:	8b 40 08             	mov    0x8(%rax),%eax
 d7d:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 d80:	77 5f                	ja     de1 <malloc+0xcf>
      if(p->s.size == nunits)
 d82:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d86:	8b 40 08             	mov    0x8(%rax),%eax
 d89:	39 45 ec             	cmp    %eax,-0x14(%rbp)
 d8c:	75 10                	jne    d9e <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
 d8e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 d92:	48 8b 10             	mov    (%rax),%rdx
 d95:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 d99:	48 89 10             	mov    %rdx,(%rax)
 d9c:	eb 2e                	jmp    dcc <malloc+0xba>
      else {
        p->s.size -= nunits;
 d9e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 da2:	8b 40 08             	mov    0x8(%rax),%eax
 da5:	2b 45 ec             	sub    -0x14(%rbp),%eax
 da8:	89 c2                	mov    %eax,%edx
 daa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 dae:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
 db1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 db5:	8b 40 08             	mov    0x8(%rax),%eax
 db8:	89 c0                	mov    %eax,%eax
 dba:	48 c1 e0 04          	shl    $0x4,%rax
 dbe:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
 dc2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 dc6:	8b 55 ec             	mov    -0x14(%rbp),%edx
 dc9:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
 dcc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
 dd0:	48 89 05 69 03 00 00 	mov    %rax,0x369(%rip)        # 1140 <freep>
      return (void*)(p + 1);
 dd7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 ddb:	48 83 c0 10          	add    $0x10,%rax
 ddf:	eb 41                	jmp    e22 <malloc+0x110>
    }
    if(p == freep)
 de1:	48 8b 05 58 03 00 00 	mov    0x358(%rip),%rax        # 1140 <freep>
 de8:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
 dec:	75 1c                	jne    e0a <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
 dee:	8b 45 ec             	mov    -0x14(%rbp),%eax
 df1:	89 c7                	mov    %eax,%edi
 df3:	e8 b5 fe ff ff       	callq  cad <morecore>
 df8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
 dfc:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
 e01:	75 07                	jne    e0a <malloc+0xf8>
        return 0;
 e03:	b8 00 00 00 00       	mov    $0x0,%eax
 e08:	eb 18                	jmp    e22 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e0a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 e0e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
 e12:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 e16:	48 8b 00             	mov    (%rax),%rax
 e19:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
 e1d:	e9 54 ff ff ff       	jmpq   d76 <malloc+0x64>
  }
}
 e22:	c9                   	leaveq 
 e23:	c3                   	retq   
