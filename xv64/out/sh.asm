
fs/sh:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %rbp
       1:	48 89 e5             	mov    %rsp,%rbp
       4:	48 83 ec 40          	sub    $0x40,%rsp
       8:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       c:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
      11:	75 05                	jne    18 <runcmd+0x18>
    exit();
      13:	e8 d2 10 00 00       	callq  10ea <exit>
  
  switch(cmd->type){
      18:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      1c:	8b 00                	mov    (%rax),%eax
      1e:	83 f8 05             	cmp    $0x5,%eax
      21:	77 0c                	ja     2f <runcmd+0x2f>
      23:	89 c0                	mov    %eax,%eax
      25:	48 8b 04 c5 a8 18 00 	mov    0x18a8(,%rax,8),%rax
      2c:	00 
      2d:	ff e0                	jmpq   *%rax
  default:
    panic("runcmd");
      2f:	48 c7 c7 78 18 00 00 	mov    $0x1878,%rdi
      36:	e8 3d 03 00 00       	callq  378 <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      3b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      3f:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    if(ecmd->argv[0] == 0)
      43:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
      47:	48 8b 40 08          	mov    0x8(%rax),%rax
      4b:	48 85 c0             	test   %rax,%rax
      4e:	75 05                	jne    55 <runcmd+0x55>
      exit();
      50:	e8 95 10 00 00       	callq  10ea <exit>
    exec(ecmd->argv[0], ecmd->argv);
      55:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
      59:	48 8d 50 08          	lea    0x8(%rax),%rdx
      5d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
      61:	48 8b 40 08          	mov    0x8(%rax),%rax
      65:	48 89 d6             	mov    %rdx,%rsi
      68:	48 89 c7             	mov    %rax,%rdi
      6b:	e8 b2 10 00 00       	callq  1122 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      70:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
      74:	48 8b 40 08          	mov    0x8(%rax),%rax
      78:	48 89 c2             	mov    %rax,%rdx
      7b:	48 c7 c6 7f 18 00 00 	mov    $0x187f,%rsi
      82:	bf 02 00 00 00       	mov    $0x2,%edi
      87:	b8 00 00 00 00       	mov    $0x0,%eax
      8c:	e8 e2 11 00 00       	callq  1273 <printf>
    break;
      91:	e9 91 01 00 00       	jmpq   227 <runcmd+0x227>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      96:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      9a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    close(rcmd->fd);
      9e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
      a2:	8b 40 24             	mov    0x24(%rax),%eax
      a5:	89 c7                	mov    %eax,%edi
      a7:	e8 66 10 00 00       	callq  1112 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      ac:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
      b0:	8b 50 20             	mov    0x20(%rax),%edx
      b3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
      b7:	48 8b 40 10          	mov    0x10(%rax),%rax
      bb:	89 d6                	mov    %edx,%esi
      bd:	48 89 c7             	mov    %rax,%rdi
      c0:	e8 65 10 00 00       	callq  112a <open>
      c5:	85 c0                	test   %eax,%eax
      c7:	79 26                	jns    ef <runcmd+0xef>
      printf(2, "open %s failed\n", rcmd->file);
      c9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
      cd:	48 8b 40 10          	mov    0x10(%rax),%rax
      d1:	48 89 c2             	mov    %rax,%rdx
      d4:	48 c7 c6 8f 18 00 00 	mov    $0x188f,%rsi
      db:	bf 02 00 00 00       	mov    $0x2,%edi
      e0:	b8 00 00 00 00       	mov    $0x0,%eax
      e5:	e8 89 11 00 00       	callq  1273 <printf>
      exit();
      ea:	e8 fb 0f 00 00       	callq  10ea <exit>
    }
    runcmd(rcmd->cmd);
      ef:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
      f3:	48 8b 40 08          	mov    0x8(%rax),%rax
      f7:	48 89 c7             	mov    %rax,%rdi
      fa:	e8 01 ff ff ff       	callq  0 <runcmd>
    break;
      ff:	e9 23 01 00 00       	jmpq   227 <runcmd+0x227>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     104:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     108:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if(fork1() == 0)
     10c:	e8 95 02 00 00       	callq  3a6 <fork1>
     111:	85 c0                	test   %eax,%eax
     113:	75 10                	jne    125 <runcmd+0x125>
      runcmd(lcmd->left);
     115:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     119:	48 8b 40 08          	mov    0x8(%rax),%rax
     11d:	48 89 c7             	mov    %rax,%rdi
     120:	e8 db fe ff ff       	callq  0 <runcmd>
    wait();
     125:	e8 c8 0f 00 00       	callq  10f2 <wait>
    runcmd(lcmd->right);
     12a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     12e:	48 8b 40 10          	mov    0x10(%rax),%rax
     132:	48 89 c7             	mov    %rax,%rdi
     135:	e8 c6 fe ff ff       	callq  0 <runcmd>
    break;
     13a:	e9 e8 00 00 00       	jmpq   227 <runcmd+0x227>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     13f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     143:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    if(pipe(p) < 0)
     147:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
     14b:	48 89 c7             	mov    %rax,%rdi
     14e:	e8 a7 0f 00 00       	callq  10fa <pipe>
     153:	85 c0                	test   %eax,%eax
     155:	79 0c                	jns    163 <runcmd+0x163>
      panic("pipe");
     157:	48 c7 c7 9f 18 00 00 	mov    $0x189f,%rdi
     15e:	e8 15 02 00 00       	callq  378 <panic>
    if(fork1() == 0){
     163:	e8 3e 02 00 00       	callq  3a6 <fork1>
     168:	85 c0                	test   %eax,%eax
     16a:	75 38                	jne    1a4 <runcmd+0x1a4>
      close(1);
     16c:	bf 01 00 00 00       	mov    $0x1,%edi
     171:	e8 9c 0f 00 00       	callq  1112 <close>
      dup(p[1]);
     176:	8b 45 d4             	mov    -0x2c(%rbp),%eax
     179:	89 c7                	mov    %eax,%edi
     17b:	e8 e2 0f 00 00       	callq  1162 <dup>
      close(p[0]);
     180:	8b 45 d0             	mov    -0x30(%rbp),%eax
     183:	89 c7                	mov    %eax,%edi
     185:	e8 88 0f 00 00       	callq  1112 <close>
      close(p[1]);
     18a:	8b 45 d4             	mov    -0x2c(%rbp),%eax
     18d:	89 c7                	mov    %eax,%edi
     18f:	e8 7e 0f 00 00       	callq  1112 <close>
      runcmd(pcmd->left);
     194:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     198:	48 8b 40 08          	mov    0x8(%rax),%rax
     19c:	48 89 c7             	mov    %rax,%rdi
     19f:	e8 5c fe ff ff       	callq  0 <runcmd>
    }
    if(fork1() == 0){
     1a4:	e8 fd 01 00 00       	callq  3a6 <fork1>
     1a9:	85 c0                	test   %eax,%eax
     1ab:	75 38                	jne    1e5 <runcmd+0x1e5>
      close(0);
     1ad:	bf 00 00 00 00       	mov    $0x0,%edi
     1b2:	e8 5b 0f 00 00       	callq  1112 <close>
      dup(p[0]);
     1b7:	8b 45 d0             	mov    -0x30(%rbp),%eax
     1ba:	89 c7                	mov    %eax,%edi
     1bc:	e8 a1 0f 00 00       	callq  1162 <dup>
      close(p[0]);
     1c1:	8b 45 d0             	mov    -0x30(%rbp),%eax
     1c4:	89 c7                	mov    %eax,%edi
     1c6:	e8 47 0f 00 00       	callq  1112 <close>
      close(p[1]);
     1cb:	8b 45 d4             	mov    -0x2c(%rbp),%eax
     1ce:	89 c7                	mov    %eax,%edi
     1d0:	e8 3d 0f 00 00       	callq  1112 <close>
      runcmd(pcmd->right);
     1d5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     1d9:	48 8b 40 10          	mov    0x10(%rax),%rax
     1dd:	48 89 c7             	mov    %rax,%rdi
     1e0:	e8 1b fe ff ff       	callq  0 <runcmd>
    }
    close(p[0]);
     1e5:	8b 45 d0             	mov    -0x30(%rbp),%eax
     1e8:	89 c7                	mov    %eax,%edi
     1ea:	e8 23 0f 00 00       	callq  1112 <close>
    close(p[1]);
     1ef:	8b 45 d4             	mov    -0x2c(%rbp),%eax
     1f2:	89 c7                	mov    %eax,%edi
     1f4:	e8 19 0f 00 00       	callq  1112 <close>
    wait();
     1f9:	e8 f4 0e 00 00       	callq  10f2 <wait>
    wait();
     1fe:	e8 ef 0e 00 00       	callq  10f2 <wait>
    break;
     203:	eb 22                	jmp    227 <runcmd+0x227>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     205:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     209:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(fork1() == 0)
     20d:	e8 94 01 00 00       	callq  3a6 <fork1>
     212:	85 c0                	test   %eax,%eax
     214:	75 10                	jne    226 <runcmd+0x226>
      runcmd(bcmd->cmd);
     216:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     21a:	48 8b 40 08          	mov    0x8(%rax),%rax
     21e:	48 89 c7             	mov    %rax,%rdi
     221:	e8 da fd ff ff       	callq  0 <runcmd>
    break;
     226:	90                   	nop
  }
  exit();
     227:	e8 be 0e 00 00       	callq  10ea <exit>

000000000000022c <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     22c:	55                   	push   %rbp
     22d:	48 89 e5             	mov    %rsp,%rbp
     230:	48 83 ec 10          	sub    $0x10,%rsp
     234:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
     238:	89 75 f4             	mov    %esi,-0xc(%rbp)
  printf(2, "v64-root% ");
     23b:	48 c7 c6 d8 18 00 00 	mov    $0x18d8,%rsi
     242:	bf 02 00 00 00       	mov    $0x2,%edi
     247:	b8 00 00 00 00       	mov    $0x0,%eax
     24c:	e8 22 10 00 00       	callq  1273 <printf>
  memset(buf, 0, nbuf);
     251:	8b 55 f4             	mov    -0xc(%rbp),%edx
     254:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     258:	be 00 00 00 00       	mov    $0x0,%esi
     25d:	48 89 c7             	mov    %rax,%rdi
     260:	e8 90 0c 00 00       	callq  ef5 <memset>
  gets(buf, nbuf);
     265:	8b 55 f4             	mov    -0xc(%rbp),%edx
     268:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     26c:	89 d6                	mov    %edx,%esi
     26e:	48 89 c7             	mov    %rax,%rdi
     271:	e8 e7 0c 00 00       	callq  f5d <gets>
  if(buf[0] == 0) // EOF
     276:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     27a:	0f b6 00             	movzbl (%rax),%eax
     27d:	84 c0                	test   %al,%al
     27f:	75 07                	jne    288 <getcmd+0x5c>
    return -1;
     281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     286:	eb 05                	jmp    28d <getcmd+0x61>
  return 0;
     288:	b8 00 00 00 00       	mov    $0x0,%eax
}
     28d:	c9                   	leaveq 
     28e:	c3                   	retq   

000000000000028f <main>:

int
main(void)
{
     28f:	55                   	push   %rbp
     290:	48 89 e5             	mov    %rsp,%rbp
     293:	48 83 ec 10          	sub    $0x10,%rsp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     297:	eb 12                	jmp    2ab <main+0x1c>
    if(fd >= 3){
     299:	83 7d fc 02          	cmpl   $0x2,-0x4(%rbp)
     29d:	7e 0c                	jle    2ab <main+0x1c>
      close(fd);
     29f:	8b 45 fc             	mov    -0x4(%rbp),%eax
     2a2:	89 c7                	mov    %eax,%edi
     2a4:	e8 69 0e 00 00       	callq  1112 <close>
      break;
     2a9:	eb 1a                	jmp    2c5 <main+0x36>
  while((fd = open("console", O_RDWR)) >= 0){
     2ab:	be 02 00 00 00       	mov    $0x2,%esi
     2b0:	48 c7 c7 e3 18 00 00 	mov    $0x18e3,%rdi
     2b7:	e8 6e 0e 00 00       	callq  112a <open>
     2bc:	89 45 fc             	mov    %eax,-0x4(%rbp)
     2bf:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
     2c3:	79 d4                	jns    299 <main+0xa>
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2c5:	e9 90 00 00 00       	jmpq   35a <main+0xcb>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2ca:	0f b6 05 8f 1b 00 00 	movzbl 0x1b8f(%rip),%eax        # 1e60 <buf.1465>
     2d1:	3c 63                	cmp    $0x63,%al
     2d3:	75 63                	jne    338 <main+0xa9>
     2d5:	0f b6 05 85 1b 00 00 	movzbl 0x1b85(%rip),%eax        # 1e61 <buf.1465+0x1>
     2dc:	3c 64                	cmp    $0x64,%al
     2de:	75 58                	jne    338 <main+0xa9>
     2e0:	0f b6 05 7b 1b 00 00 	movzbl 0x1b7b(%rip),%eax        # 1e62 <buf.1465+0x2>
     2e7:	3c 20                	cmp    $0x20,%al
     2e9:	75 4d                	jne    338 <main+0xa9>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2eb:	48 c7 c7 60 1e 00 00 	mov    $0x1e60,%rdi
     2f2:	e8 cc 0b 00 00       	callq  ec3 <strlen>
     2f7:	83 e8 01             	sub    $0x1,%eax
     2fa:	89 c0                	mov    %eax,%eax
     2fc:	c6 80 60 1e 00 00 00 	movb   $0x0,0x1e60(%rax)
      if(chdir(buf+3) < 0)
     303:	48 c7 c0 63 1e 00 00 	mov    $0x1e63,%rax
     30a:	48 89 c7             	mov    %rax,%rdi
     30d:	e8 48 0e 00 00       	callq  115a <chdir>
     312:	85 c0                	test   %eax,%eax
     314:	79 44                	jns    35a <main+0xcb>
        printf(2, "cannot cd %s\n", buf+3);
     316:	48 c7 c0 63 1e 00 00 	mov    $0x1e63,%rax
     31d:	48 89 c2             	mov    %rax,%rdx
     320:	48 c7 c6 eb 18 00 00 	mov    $0x18eb,%rsi
     327:	bf 02 00 00 00       	mov    $0x2,%edi
     32c:	b8 00 00 00 00       	mov    $0x0,%eax
     331:	e8 3d 0f 00 00       	callq  1273 <printf>
      continue;
     336:	eb 22                	jmp    35a <main+0xcb>
    }
    if(fork1() == 0)
     338:	e8 69 00 00 00       	callq  3a6 <fork1>
     33d:	85 c0                	test   %eax,%eax
     33f:	75 14                	jne    355 <main+0xc6>
      runcmd(parsecmd(buf));
     341:	48 c7 c7 60 1e 00 00 	mov    $0x1e60,%rdi
     348:	e8 51 04 00 00       	callq  79e <parsecmd>
     34d:	48 89 c7             	mov    %rax,%rdi
     350:	e8 ab fc ff ff       	callq  0 <runcmd>
    wait();
     355:	e8 98 0d 00 00       	callq  10f2 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     35a:	be 64 00 00 00       	mov    $0x64,%esi
     35f:	48 c7 c7 60 1e 00 00 	mov    $0x1e60,%rdi
     366:	e8 c1 fe ff ff       	callq  22c <getcmd>
     36b:	85 c0                	test   %eax,%eax
     36d:	0f 89 57 ff ff ff    	jns    2ca <main+0x3b>
  }
  exit();
     373:	e8 72 0d 00 00       	callq  10ea <exit>

0000000000000378 <panic>:
}

void
panic(char *s)
{
     378:	55                   	push   %rbp
     379:	48 89 e5             	mov    %rsp,%rbp
     37c:	48 83 ec 10          	sub    $0x10,%rsp
     380:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  printf(2, "%s\n", s);
     384:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     388:	48 89 c2             	mov    %rax,%rdx
     38b:	48 c7 c6 f9 18 00 00 	mov    $0x18f9,%rsi
     392:	bf 02 00 00 00       	mov    $0x2,%edi
     397:	b8 00 00 00 00       	mov    $0x0,%eax
     39c:	e8 d2 0e 00 00       	callq  1273 <printf>
  exit();
     3a1:	e8 44 0d 00 00       	callq  10ea <exit>

00000000000003a6 <fork1>:
}

int
fork1(void)
{
     3a6:	55                   	push   %rbp
     3a7:	48 89 e5             	mov    %rsp,%rbp
     3aa:	48 83 ec 10          	sub    $0x10,%rsp
  int pid;
  
  pid = fork();
     3ae:	e8 2f 0d 00 00       	callq  10e2 <fork>
     3b3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(pid == -1)
     3b6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%rbp)
     3ba:	75 0c                	jne    3c8 <fork1+0x22>
    panic("fork");
     3bc:	48 c7 c7 fd 18 00 00 	mov    $0x18fd,%rdi
     3c3:	e8 b0 ff ff ff       	callq  378 <panic>
  return pid;
     3c8:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
     3cb:	c9                   	leaveq 
     3cc:	c3                   	retq   

00000000000003cd <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3cd:	55                   	push   %rbp
     3ce:	48 89 e5             	mov    %rsp,%rbp
     3d1:	48 83 ec 10          	sub    $0x10,%rsp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3d5:	bf a8 00 00 00       	mov    $0xa8,%edi
     3da:	e8 86 13 00 00       	callq  1765 <malloc>
     3df:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(cmd, 0, sizeof(*cmd));
     3e3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     3e7:	ba a8 00 00 00       	mov    $0xa8,%edx
     3ec:	be 00 00 00 00       	mov    $0x0,%esi
     3f1:	48 89 c7             	mov    %rax,%rdi
     3f4:	e8 fc 0a 00 00       	callq  ef5 <memset>
  cmd->type = EXEC;
     3f9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     3fd:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
  return (struct cmd*)cmd;
     403:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     407:	c9                   	leaveq 
     408:	c3                   	retq   

0000000000000409 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     409:	55                   	push   %rbp
     40a:	48 89 e5             	mov    %rsp,%rbp
     40d:	48 83 ec 30          	sub    $0x30,%rsp
     411:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     415:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
     419:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
     41d:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
     420:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     424:	bf 28 00 00 00       	mov    $0x28,%edi
     429:	e8 37 13 00 00       	callq  1765 <malloc>
     42e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(cmd, 0, sizeof(*cmd));
     432:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     436:	ba 28 00 00 00       	mov    $0x28,%edx
     43b:	be 00 00 00 00       	mov    $0x0,%esi
     440:	48 89 c7             	mov    %rax,%rdi
     443:	e8 ad 0a 00 00       	callq  ef5 <memset>
  cmd->type = REDIR;
     448:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     44c:	c7 00 02 00 00 00    	movl   $0x2,(%rax)
  cmd->cmd = subcmd;
     452:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     456:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     45a:	48 89 50 08          	mov    %rdx,0x8(%rax)
  cmd->file = file;
     45e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     462:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     466:	48 89 50 10          	mov    %rdx,0x10(%rax)
  cmd->efile = efile;
     46a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     46e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
     472:	48 89 50 18          	mov    %rdx,0x18(%rax)
  cmd->mode = mode;
     476:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     47a:	8b 55 d4             	mov    -0x2c(%rbp),%edx
     47d:	89 50 20             	mov    %edx,0x20(%rax)
  cmd->fd = fd;
     480:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     484:	8b 55 d0             	mov    -0x30(%rbp),%edx
     487:	89 50 24             	mov    %edx,0x24(%rax)
  return (struct cmd*)cmd;
     48a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     48e:	c9                   	leaveq 
     48f:	c3                   	retq   

0000000000000490 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     490:	55                   	push   %rbp
     491:	48 89 e5             	mov    %rsp,%rbp
     494:	48 83 ec 20          	sub    $0x20,%rsp
     498:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     49c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4a0:	bf 18 00 00 00       	mov    $0x18,%edi
     4a5:	e8 bb 12 00 00       	callq  1765 <malloc>
     4aa:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(cmd, 0, sizeof(*cmd));
     4ae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     4b2:	ba 18 00 00 00       	mov    $0x18,%edx
     4b7:	be 00 00 00 00       	mov    $0x0,%esi
     4bc:	48 89 c7             	mov    %rax,%rdi
     4bf:	e8 31 0a 00 00       	callq  ef5 <memset>
  cmd->type = PIPE;
     4c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     4c8:	c7 00 03 00 00 00    	movl   $0x3,(%rax)
  cmd->left = left;
     4ce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     4d2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     4d6:	48 89 50 08          	mov    %rdx,0x8(%rax)
  cmd->right = right;
     4da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     4de:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     4e2:	48 89 50 10          	mov    %rdx,0x10(%rax)
  return (struct cmd*)cmd;
     4e6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     4ea:	c9                   	leaveq 
     4eb:	c3                   	retq   

00000000000004ec <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4ec:	55                   	push   %rbp
     4ed:	48 89 e5             	mov    %rsp,%rbp
     4f0:	48 83 ec 20          	sub    $0x20,%rsp
     4f4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     4f8:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4fc:	bf 18 00 00 00       	mov    $0x18,%edi
     501:	e8 5f 12 00 00       	callq  1765 <malloc>
     506:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(cmd, 0, sizeof(*cmd));
     50a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     50e:	ba 18 00 00 00       	mov    $0x18,%edx
     513:	be 00 00 00 00       	mov    $0x0,%esi
     518:	48 89 c7             	mov    %rax,%rdi
     51b:	e8 d5 09 00 00       	callq  ef5 <memset>
  cmd->type = LIST;
     520:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     524:	c7 00 04 00 00 00    	movl   $0x4,(%rax)
  cmd->left = left;
     52a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     52e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     532:	48 89 50 08          	mov    %rdx,0x8(%rax)
  cmd->right = right;
     536:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     53a:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     53e:	48 89 50 10          	mov    %rdx,0x10(%rax)
  return (struct cmd*)cmd;
     542:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     546:	c9                   	leaveq 
     547:	c3                   	retq   

0000000000000548 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     548:	55                   	push   %rbp
     549:	48 89 e5             	mov    %rsp,%rbp
     54c:	48 83 ec 20          	sub    $0x20,%rsp
     550:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     554:	bf 10 00 00 00       	mov    $0x10,%edi
     559:	e8 07 12 00 00       	callq  1765 <malloc>
     55e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  memset(cmd, 0, sizeof(*cmd));
     562:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     566:	ba 10 00 00 00       	mov    $0x10,%edx
     56b:	be 00 00 00 00       	mov    $0x0,%esi
     570:	48 89 c7             	mov    %rax,%rdi
     573:	e8 7d 09 00 00       	callq  ef5 <memset>
  cmd->type = BACK;
     578:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     57c:	c7 00 05 00 00 00    	movl   $0x5,(%rax)
  cmd->cmd = subcmd;
     582:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     586:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     58a:	48 89 50 08          	mov    %rdx,0x8(%rax)
  return (struct cmd*)cmd;
     58e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     592:	c9                   	leaveq 
     593:	c3                   	retq   

0000000000000594 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     594:	55                   	push   %rbp
     595:	48 89 e5             	mov    %rsp,%rbp
     598:	48 83 ec 30          	sub    $0x30,%rsp
     59c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     5a0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
     5a4:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
     5a8:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  char *s;
  int ret;
  
  s = *ps;
     5ac:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     5b0:	48 8b 00             	mov    (%rax),%rax
     5b3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(s < es && strchr(whitespace, *s))
     5b7:	eb 05                	jmp    5be <gettoken+0x2a>
    s++;
     5b9:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  while(s < es && strchr(whitespace, *s))
     5be:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     5c2:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
     5c6:	73 1d                	jae    5e5 <gettoken+0x51>
     5c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     5cc:	0f b6 00             	movzbl (%rax),%eax
     5cf:	0f be c0             	movsbl %al,%eax
     5d2:	89 c6                	mov    %eax,%esi
     5d4:	48 c7 c7 20 1e 00 00 	mov    $0x1e20,%rdi
     5db:	e8 41 09 00 00       	callq  f21 <strchr>
     5e0:	48 85 c0             	test   %rax,%rax
     5e3:	75 d4                	jne    5b9 <gettoken+0x25>
  if(q)
     5e5:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
     5ea:	74 0b                	je     5f7 <gettoken+0x63>
    *q = s;
     5ec:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     5f0:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
     5f4:	48 89 10             	mov    %rdx,(%rax)
  ret = *s;
     5f7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     5fb:	0f b6 00             	movzbl (%rax),%eax
     5fe:	0f be c0             	movsbl %al,%eax
     601:	89 45 f4             	mov    %eax,-0xc(%rbp)
  switch(*s){
     604:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     608:	0f b6 00             	movzbl (%rax),%eax
     60b:	0f be c0             	movsbl %al,%eax
     60e:	83 f8 29             	cmp    $0x29,%eax
     611:	7f 14                	jg     627 <gettoken+0x93>
     613:	83 f8 28             	cmp    $0x28,%eax
     616:	7d 28                	jge    640 <gettoken+0xac>
     618:	85 c0                	test   %eax,%eax
     61a:	0f 84 99 00 00 00    	je     6b9 <gettoken+0x125>
     620:	83 f8 26             	cmp    $0x26,%eax
     623:	74 1b                	je     640 <gettoken+0xac>
     625:	eb 3e                	jmp    665 <gettoken+0xd1>
     627:	83 f8 3e             	cmp    $0x3e,%eax
     62a:	74 1b                	je     647 <gettoken+0xb3>
     62c:	83 f8 3e             	cmp    $0x3e,%eax
     62f:	7f 0a                	jg     63b <gettoken+0xa7>
     631:	83 e8 3b             	sub    $0x3b,%eax
     634:	83 f8 01             	cmp    $0x1,%eax
     637:	77 2c                	ja     665 <gettoken+0xd1>
     639:	eb 05                	jmp    640 <gettoken+0xac>
     63b:	83 f8 7c             	cmp    $0x7c,%eax
     63e:	75 25                	jne    665 <gettoken+0xd1>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     640:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    break;
     645:	eb 79                	jmp    6c0 <gettoken+0x12c>
  case '>':
    s++;
     647:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    if(*s == '>'){
     64c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     650:	0f b6 00             	movzbl (%rax),%eax
     653:	3c 3e                	cmp    $0x3e,%al
     655:	75 65                	jne    6bc <gettoken+0x128>
      ret = '+';
     657:	c7 45 f4 2b 00 00 00 	movl   $0x2b,-0xc(%rbp)
      s++;
     65e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    }
    break;
     663:	eb 57                	jmp    6bc <gettoken+0x128>
  default:
    ret = 'a';
     665:	c7 45 f4 61 00 00 00 	movl   $0x61,-0xc(%rbp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     66c:	eb 05                	jmp    673 <gettoken+0xdf>
      s++;
     66e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     673:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     677:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
     67b:	73 42                	jae    6bf <gettoken+0x12b>
     67d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     681:	0f b6 00             	movzbl (%rax),%eax
     684:	0f be c0             	movsbl %al,%eax
     687:	89 c6                	mov    %eax,%esi
     689:	48 c7 c7 20 1e 00 00 	mov    $0x1e20,%rdi
     690:	e8 8c 08 00 00       	callq  f21 <strchr>
     695:	48 85 c0             	test   %rax,%rax
     698:	75 25                	jne    6bf <gettoken+0x12b>
     69a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     69e:	0f b6 00             	movzbl (%rax),%eax
     6a1:	0f be c0             	movsbl %al,%eax
     6a4:	89 c6                	mov    %eax,%esi
     6a6:	48 c7 c7 28 1e 00 00 	mov    $0x1e28,%rdi
     6ad:	e8 6f 08 00 00       	callq  f21 <strchr>
     6b2:	48 85 c0             	test   %rax,%rax
     6b5:	74 b7                	je     66e <gettoken+0xda>
    break;
     6b7:	eb 06                	jmp    6bf <gettoken+0x12b>
    break;
     6b9:	90                   	nop
     6ba:	eb 04                	jmp    6c0 <gettoken+0x12c>
    break;
     6bc:	90                   	nop
     6bd:	eb 01                	jmp    6c0 <gettoken+0x12c>
    break;
     6bf:	90                   	nop
  }
  if(eq)
     6c0:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
     6c5:	74 12                	je     6d9 <gettoken+0x145>
    *eq = s;
     6c7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     6cb:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
     6cf:	48 89 10             	mov    %rdx,(%rax)
  
  while(s < es && strchr(whitespace, *s))
     6d2:	eb 05                	jmp    6d9 <gettoken+0x145>
    s++;
     6d4:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  while(s < es && strchr(whitespace, *s))
     6d9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     6dd:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
     6e1:	73 1d                	jae    700 <gettoken+0x16c>
     6e3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     6e7:	0f b6 00             	movzbl (%rax),%eax
     6ea:	0f be c0             	movsbl %al,%eax
     6ed:	89 c6                	mov    %eax,%esi
     6ef:	48 c7 c7 20 1e 00 00 	mov    $0x1e20,%rdi
     6f6:	e8 26 08 00 00       	callq  f21 <strchr>
     6fb:	48 85 c0             	test   %rax,%rax
     6fe:	75 d4                	jne    6d4 <gettoken+0x140>
  *ps = s;
     700:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     704:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
     708:	48 89 10             	mov    %rdx,(%rax)
  return ret;
     70b:	8b 45 f4             	mov    -0xc(%rbp),%eax
}
     70e:	c9                   	leaveq 
     70f:	c3                   	retq   

0000000000000710 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     710:	55                   	push   %rbp
     711:	48 89 e5             	mov    %rsp,%rbp
     714:	48 83 ec 30          	sub    $0x30,%rsp
     718:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     71c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
     720:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  char *s;
  
  s = *ps;
     724:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     728:	48 8b 00             	mov    (%rax),%rax
     72b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(s < es && strchr(whitespace, *s))
     72f:	eb 05                	jmp    736 <peek+0x26>
    s++;
     731:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  while(s < es && strchr(whitespace, *s))
     736:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     73a:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
     73e:	73 1d                	jae    75d <peek+0x4d>
     740:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     744:	0f b6 00             	movzbl (%rax),%eax
     747:	0f be c0             	movsbl %al,%eax
     74a:	89 c6                	mov    %eax,%esi
     74c:	48 c7 c7 20 1e 00 00 	mov    $0x1e20,%rdi
     753:	e8 c9 07 00 00       	callq  f21 <strchr>
     758:	48 85 c0             	test   %rax,%rax
     75b:	75 d4                	jne    731 <peek+0x21>
  *ps = s;
     75d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     761:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
     765:	48 89 10             	mov    %rdx,(%rax)
  return *s && strchr(toks, *s);
     768:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     76c:	0f b6 00             	movzbl (%rax),%eax
     76f:	84 c0                	test   %al,%al
     771:	74 24                	je     797 <peek+0x87>
     773:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     777:	0f b6 00             	movzbl (%rax),%eax
     77a:	0f be d0             	movsbl %al,%edx
     77d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     781:	89 d6                	mov    %edx,%esi
     783:	48 89 c7             	mov    %rax,%rdi
     786:	e8 96 07 00 00       	callq  f21 <strchr>
     78b:	48 85 c0             	test   %rax,%rax
     78e:	74 07                	je     797 <peek+0x87>
     790:	b8 01 00 00 00       	mov    $0x1,%eax
     795:	eb 05                	jmp    79c <peek+0x8c>
     797:	b8 00 00 00 00       	mov    $0x0,%eax
}
     79c:	c9                   	leaveq 
     79d:	c3                   	retq   

000000000000079e <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     79e:	55                   	push   %rbp
     79f:	48 89 e5             	mov    %rsp,%rbp
     7a2:	53                   	push   %rbx
     7a3:	48 83 ec 28          	sub    $0x28,%rsp
     7a7:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     7ab:	48 8b 5d d8          	mov    -0x28(%rbp),%rbx
     7af:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     7b3:	48 89 c7             	mov    %rax,%rdi
     7b6:	e8 08 07 00 00       	callq  ec3 <strlen>
     7bb:	89 c0                	mov    %eax,%eax
     7bd:	48 01 d8             	add    %rbx,%rax
     7c0:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  cmd = parseline(&s, es);
     7c4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     7c8:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
     7cc:	48 89 d6             	mov    %rdx,%rsi
     7cf:	48 89 c7             	mov    %rax,%rdi
     7d2:	e8 68 00 00 00       	callq  83f <parseline>
     7d7:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  peek(&s, es, "");
     7db:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
     7df:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
     7e3:	48 c7 c2 02 19 00 00 	mov    $0x1902,%rdx
     7ea:	48 89 ce             	mov    %rcx,%rsi
     7ed:	48 89 c7             	mov    %rax,%rdi
     7f0:	e8 1b ff ff ff       	callq  710 <peek>
  if(s != es){
     7f5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     7f9:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
     7fd:	74 29                	je     828 <parsecmd+0x8a>
    printf(2, "leftovers: %s\n", s);
     7ff:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     803:	48 89 c2             	mov    %rax,%rdx
     806:	48 c7 c6 03 19 00 00 	mov    $0x1903,%rsi
     80d:	bf 02 00 00 00       	mov    $0x2,%edi
     812:	b8 00 00 00 00       	mov    $0x0,%eax
     817:	e8 57 0a 00 00       	callq  1273 <printf>
    panic("syntax");
     81c:	48 c7 c7 12 19 00 00 	mov    $0x1912,%rdi
     823:	e8 50 fb ff ff       	callq  378 <panic>
  }
  nulterminate(cmd);
     828:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
     82c:	48 89 c7             	mov    %rax,%rdi
     82f:	e8 af 04 00 00       	callq  ce3 <nulterminate>
  return cmd;
     834:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
}
     838:	48 83 c4 28          	add    $0x28,%rsp
     83c:	5b                   	pop    %rbx
     83d:	5d                   	pop    %rbp
     83e:	c3                   	retq   

000000000000083f <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     83f:	55                   	push   %rbp
     840:	48 89 e5             	mov    %rsp,%rbp
     843:	48 83 ec 20          	sub    $0x20,%rsp
     847:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     84b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     84f:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     853:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     857:	48 89 d6             	mov    %rdx,%rsi
     85a:	48 89 c7             	mov    %rax,%rdi
     85d:	e8 b5 00 00 00       	callq  917 <parsepipe>
     862:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(peek(ps, es, "&")){
     866:	eb 2a                	jmp    892 <parseline+0x53>
    gettoken(ps, es, 0, 0);
     868:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
     86c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     870:	b9 00 00 00 00       	mov    $0x0,%ecx
     875:	ba 00 00 00 00       	mov    $0x0,%edx
     87a:	48 89 c7             	mov    %rax,%rdi
     87d:	e8 12 fd ff ff       	callq  594 <gettoken>
    cmd = backcmd(cmd);
     882:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     886:	48 89 c7             	mov    %rax,%rdi
     889:	e8 ba fc ff ff       	callq  548 <backcmd>
     88e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while(peek(ps, es, "&")){
     892:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
     896:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     89a:	48 c7 c2 19 19 00 00 	mov    $0x1919,%rdx
     8a1:	48 89 ce             	mov    %rcx,%rsi
     8a4:	48 89 c7             	mov    %rax,%rdi
     8a7:	e8 64 fe ff ff       	callq  710 <peek>
     8ac:	85 c0                	test   %eax,%eax
     8ae:	75 b8                	jne    868 <parseline+0x29>
  }
  if(peek(ps, es, ";")){
     8b0:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
     8b4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     8b8:	48 c7 c2 1b 19 00 00 	mov    $0x191b,%rdx
     8bf:	48 89 ce             	mov    %rcx,%rsi
     8c2:	48 89 c7             	mov    %rax,%rdi
     8c5:	e8 46 fe ff ff       	callq  710 <peek>
     8ca:	85 c0                	test   %eax,%eax
     8cc:	74 43                	je     911 <parseline+0xd2>
    gettoken(ps, es, 0, 0);
     8ce:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
     8d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     8d6:	b9 00 00 00 00       	mov    $0x0,%ecx
     8db:	ba 00 00 00 00       	mov    $0x0,%edx
     8e0:	48 89 c7             	mov    %rax,%rdi
     8e3:	e8 ac fc ff ff       	callq  594 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8e8:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     8ec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     8f0:	48 89 d6             	mov    %rdx,%rsi
     8f3:	48 89 c7             	mov    %rax,%rdi
     8f6:	e8 44 ff ff ff       	callq  83f <parseline>
     8fb:	48 89 c2             	mov    %rax,%rdx
     8fe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     902:	48 89 d6             	mov    %rdx,%rsi
     905:	48 89 c7             	mov    %rax,%rdi
     908:	e8 df fb ff ff       	callq  4ec <listcmd>
     90d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  }
  return cmd;
     911:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     915:	c9                   	leaveq 
     916:	c3                   	retq   

0000000000000917 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     917:	55                   	push   %rbp
     918:	48 89 e5             	mov    %rsp,%rbp
     91b:	48 83 ec 20          	sub    $0x20,%rsp
     91f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     923:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     927:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     92b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     92f:	48 89 d6             	mov    %rdx,%rsi
     932:	48 89 c7             	mov    %rax,%rdi
     935:	e8 44 02 00 00       	callq  b7e <parseexec>
     93a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(peek(ps, es, "|")){
     93e:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
     942:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     946:	48 c7 c2 1d 19 00 00 	mov    $0x191d,%rdx
     94d:	48 89 ce             	mov    %rcx,%rsi
     950:	48 89 c7             	mov    %rax,%rdi
     953:	e8 b8 fd ff ff       	callq  710 <peek>
     958:	85 c0                	test   %eax,%eax
     95a:	74 43                	je     99f <parsepipe+0x88>
    gettoken(ps, es, 0, 0);
     95c:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
     960:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     964:	b9 00 00 00 00       	mov    $0x0,%ecx
     969:	ba 00 00 00 00       	mov    $0x0,%edx
     96e:	48 89 c7             	mov    %rax,%rdi
     971:	e8 1e fc ff ff       	callq  594 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     976:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     97a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     97e:	48 89 d6             	mov    %rdx,%rsi
     981:	48 89 c7             	mov    %rax,%rdi
     984:	e8 8e ff ff ff       	callq  917 <parsepipe>
     989:	48 89 c2             	mov    %rax,%rdx
     98c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     990:	48 89 d6             	mov    %rdx,%rsi
     993:	48 89 c7             	mov    %rax,%rdi
     996:	e8 f5 fa ff ff       	callq  490 <pipecmd>
     99b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  }
  return cmd;
     99f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     9a3:	c9                   	leaveq 
     9a4:	c3                   	retq   

00000000000009a5 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     9a5:	55                   	push   %rbp
     9a6:	48 89 e5             	mov    %rsp,%rbp
     9a9:	48 83 ec 40          	sub    $0x40,%rsp
     9ad:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
     9b1:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
     9b5:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9b9:	e9 c8 00 00 00       	jmpq   a86 <parseredirs+0xe1>
    tok = gettoken(ps, es, 0, 0);
     9be:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
     9c2:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     9c6:	b9 00 00 00 00       	mov    $0x0,%ecx
     9cb:	ba 00 00 00 00       	mov    $0x0,%edx
     9d0:	48 89 c7             	mov    %rax,%rdi
     9d3:	e8 bc fb ff ff       	callq  594 <gettoken>
     9d8:	89 45 fc             	mov    %eax,-0x4(%rbp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     9db:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
     9df:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
     9e3:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
     9e7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     9eb:	48 89 c7             	mov    %rax,%rdi
     9ee:	e8 a1 fb ff ff       	callq  594 <gettoken>
     9f3:	83 f8 61             	cmp    $0x61,%eax
     9f6:	74 0c                	je     a04 <parseredirs+0x5f>
      panic("missing file for redirection");
     9f8:	48 c7 c7 1f 19 00 00 	mov    $0x191f,%rdi
     9ff:	e8 74 f9 ff ff       	callq  378 <panic>
    switch(tok){
     a04:	8b 45 fc             	mov    -0x4(%rbp),%eax
     a07:	83 f8 3c             	cmp    $0x3c,%eax
     a0a:	74 0c                	je     a18 <parseredirs+0x73>
     a0c:	83 f8 3e             	cmp    $0x3e,%eax
     a0f:	74 2c                	je     a3d <parseredirs+0x98>
     a11:	83 f8 2b             	cmp    $0x2b,%eax
     a14:	74 4c                	je     a62 <parseredirs+0xbd>
     a16:	eb 6e                	jmp    a86 <parseredirs+0xe1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     a18:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     a1c:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
     a20:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     a24:	41 b8 00 00 00 00    	mov    $0x0,%r8d
     a2a:	b9 00 00 00 00       	mov    $0x0,%ecx
     a2f:	48 89 c7             	mov    %rax,%rdi
     a32:	e8 d2 f9 ff ff       	callq  409 <redircmd>
     a37:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
      break;
     a3b:	eb 49                	jmp    a86 <parseredirs+0xe1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     a3d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     a41:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
     a45:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     a49:	41 b8 01 00 00 00    	mov    $0x1,%r8d
     a4f:	b9 01 02 00 00       	mov    $0x201,%ecx
     a54:	48 89 c7             	mov    %rax,%rdi
     a57:	e8 ad f9 ff ff       	callq  409 <redircmd>
     a5c:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
      break;
     a60:	eb 24                	jmp    a86 <parseredirs+0xe1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     a62:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
     a66:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
     a6a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     a6e:	41 b8 01 00 00 00    	mov    $0x1,%r8d
     a74:	b9 01 02 00 00       	mov    $0x201,%ecx
     a79:	48 89 c7             	mov    %rax,%rdi
     a7c:	e8 88 f9 ff ff       	callq  409 <redircmd>
     a81:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
      break;
     a85:	90                   	nop
  while(peek(ps, es, "<>")){
     a86:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
     a8a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     a8e:	48 c7 c2 3c 19 00 00 	mov    $0x193c,%rdx
     a95:	48 89 ce             	mov    %rcx,%rsi
     a98:	48 89 c7             	mov    %rax,%rdi
     a9b:	e8 70 fc ff ff       	callq  710 <peek>
     aa0:	85 c0                	test   %eax,%eax
     aa2:	0f 85 16 ff ff ff    	jne    9be <parseredirs+0x19>
    }
  }
  return cmd;
     aa8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
}
     aac:	c9                   	leaveq 
     aad:	c3                   	retq   

0000000000000aae <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     aae:	55                   	push   %rbp
     aaf:	48 89 e5             	mov    %rsp,%rbp
     ab2:	48 83 ec 20          	sub    $0x20,%rsp
     ab6:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     aba:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     abe:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
     ac2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     ac6:	48 c7 c2 3f 19 00 00 	mov    $0x193f,%rdx
     acd:	48 89 ce             	mov    %rcx,%rsi
     ad0:	48 89 c7             	mov    %rax,%rdi
     ad3:	e8 38 fc ff ff       	callq  710 <peek>
     ad8:	85 c0                	test   %eax,%eax
     ada:	75 0c                	jne    ae8 <parseblock+0x3a>
    panic("parseblock");
     adc:	48 c7 c7 41 19 00 00 	mov    $0x1941,%rdi
     ae3:	e8 90 f8 ff ff       	callq  378 <panic>
  gettoken(ps, es, 0, 0);
     ae8:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
     aec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     af0:	b9 00 00 00 00       	mov    $0x0,%ecx
     af5:	ba 00 00 00 00       	mov    $0x0,%edx
     afa:	48 89 c7             	mov    %rax,%rdi
     afd:	e8 92 fa ff ff       	callq  594 <gettoken>
  cmd = parseline(ps, es);
     b02:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     b06:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b0a:	48 89 d6             	mov    %rdx,%rsi
     b0d:	48 89 c7             	mov    %rax,%rdi
     b10:	e8 2a fd ff ff       	callq  83f <parseline>
     b15:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(!peek(ps, es, ")"))
     b19:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
     b1d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b21:	48 c7 c2 4c 19 00 00 	mov    $0x194c,%rdx
     b28:	48 89 ce             	mov    %rcx,%rsi
     b2b:	48 89 c7             	mov    %rax,%rdi
     b2e:	e8 dd fb ff ff       	callq  710 <peek>
     b33:	85 c0                	test   %eax,%eax
     b35:	75 0c                	jne    b43 <parseblock+0x95>
    panic("syntax - missing )");
     b37:	48 c7 c7 4e 19 00 00 	mov    $0x194e,%rdi
     b3e:	e8 35 f8 ff ff       	callq  378 <panic>
  gettoken(ps, es, 0, 0);
     b43:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
     b47:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
     b50:	ba 00 00 00 00       	mov    $0x0,%edx
     b55:	48 89 c7             	mov    %rax,%rdi
     b58:	e8 37 fa ff ff       	callq  594 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     b5d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     b61:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
     b65:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     b69:	48 89 ce             	mov    %rcx,%rsi
     b6c:	48 89 c7             	mov    %rax,%rdi
     b6f:	e8 31 fe ff ff       	callq  9a5 <parseredirs>
     b74:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  return cmd;
     b78:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     b7c:	c9                   	leaveq 
     b7d:	c3                   	retq   

0000000000000b7e <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     b7e:	55                   	push   %rbp
     b7f:	48 89 e5             	mov    %rsp,%rbp
     b82:	48 83 ec 40          	sub    $0x40,%rsp
     b86:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
     b8a:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b8e:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
     b92:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     b96:	48 c7 c2 3f 19 00 00 	mov    $0x193f,%rdx
     b9d:	48 89 ce             	mov    %rcx,%rsi
     ba0:	48 89 c7             	mov    %rax,%rdi
     ba3:	e8 68 fb ff ff       	callq  710 <peek>
     ba8:	85 c0                	test   %eax,%eax
     baa:	74 18                	je     bc4 <parseexec+0x46>
    return parseblock(ps, es);
     bac:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
     bb0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     bb4:	48 89 d6             	mov    %rdx,%rsi
     bb7:	48 89 c7             	mov    %rax,%rdi
     bba:	e8 ef fe ff ff       	callq  aae <parseblock>
     bbf:	e9 1d 01 00 00       	jmpq   ce1 <parseexec+0x163>

  ret = execcmd();
     bc4:	e8 04 f8 ff ff       	callq  3cd <execcmd>
     bc9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  cmd = (struct execcmd*)ret;
     bcd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     bd1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

  argc = 0;
     bd5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  ret = parseredirs(ret, ps, es);
     bdc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
     be0:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
     be4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     be8:	48 89 ce             	mov    %rcx,%rsi
     beb:	48 89 c7             	mov    %rax,%rdi
     bee:	e8 b2 fd ff ff       	callq  9a5 <parseredirs>
     bf3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(!peek(ps, es, "|)&;")){
     bf7:	e9 92 00 00 00       	jmpq   c8e <parseexec+0x110>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     bfc:	48 8d 4d d0          	lea    -0x30(%rbp),%rcx
     c00:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
     c04:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
     c08:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     c0c:	48 89 c7             	mov    %rax,%rdi
     c0f:	e8 80 f9 ff ff       	callq  594 <gettoken>
     c14:	89 45 e4             	mov    %eax,-0x1c(%rbp)
     c17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
     c1b:	0f 84 91 00 00 00    	je     cb2 <parseexec+0x134>
      break;
    if(tok != 'a')
     c21:	83 7d e4 61          	cmpl   $0x61,-0x1c(%rbp)
     c25:	74 0c                	je     c33 <parseexec+0xb5>
      panic("syntax");
     c27:	48 c7 c7 12 19 00 00 	mov    $0x1912,%rdi
     c2e:	e8 45 f7 ff ff       	callq  378 <panic>
    cmd->argv[argc] = q;
     c33:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
     c37:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     c3b:	8b 55 fc             	mov    -0x4(%rbp),%edx
     c3e:	48 63 d2             	movslq %edx,%rdx
     c41:	48 89 4c d0 08       	mov    %rcx,0x8(%rax,%rdx,8)
    cmd->eargv[argc] = eq;
     c46:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
     c4a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     c4e:	8b 4d fc             	mov    -0x4(%rbp),%ecx
     c51:	48 63 c9             	movslq %ecx,%rcx
     c54:	48 83 c1 0a          	add    $0xa,%rcx
     c58:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
    argc++;
     c5d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    if(argc >= MAXARGS)
     c61:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
     c65:	7e 0c                	jle    c73 <parseexec+0xf5>
      panic("too many args");
     c67:	48 c7 c7 61 19 00 00 	mov    $0x1961,%rdi
     c6e:	e8 05 f7 ff ff       	callq  378 <panic>
    ret = parseredirs(ret, ps, es);
     c73:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
     c77:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
     c7b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     c7f:	48 89 ce             	mov    %rcx,%rsi
     c82:	48 89 c7             	mov    %rax,%rdi
     c85:	e8 1b fd ff ff       	callq  9a5 <parseredirs>
     c8a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(!peek(ps, es, "|)&;")){
     c8e:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
     c92:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     c96:	48 c7 c2 6f 19 00 00 	mov    $0x196f,%rdx
     c9d:	48 89 ce             	mov    %rcx,%rsi
     ca0:	48 89 c7             	mov    %rax,%rdi
     ca3:	e8 68 fa ff ff       	callq  710 <peek>
     ca8:	85 c0                	test   %eax,%eax
     caa:	0f 84 4c ff ff ff    	je     bfc <parseexec+0x7e>
     cb0:	eb 01                	jmp    cb3 <parseexec+0x135>
      break;
     cb2:	90                   	nop
  }
  cmd->argv[argc] = 0;
     cb3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     cb7:	8b 55 fc             	mov    -0x4(%rbp),%edx
     cba:	48 63 d2             	movslq %edx,%rdx
     cbd:	48 c7 44 d0 08 00 00 	movq   $0x0,0x8(%rax,%rdx,8)
     cc4:	00 00 
  cmd->eargv[argc] = 0;
     cc6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     cca:	8b 55 fc             	mov    -0x4(%rbp),%edx
     ccd:	48 63 d2             	movslq %edx,%rdx
     cd0:	48 83 c2 0a          	add    $0xa,%rdx
     cd4:	48 c7 44 d0 08 00 00 	movq   $0x0,0x8(%rax,%rdx,8)
     cdb:	00 00 
  return ret;
     cdd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
     ce1:	c9                   	leaveq 
     ce2:	c3                   	retq   

0000000000000ce3 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     ce3:	55                   	push   %rbp
     ce4:	48 89 e5             	mov    %rsp,%rbp
     ce7:	48 83 ec 40          	sub    $0x40,%rsp
     ceb:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     cef:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
     cf4:	75 0a                	jne    d00 <nulterminate+0x1d>
    return 0;
     cf6:	b8 00 00 00 00       	mov    $0x0,%eax
     cfb:	e9 f5 00 00 00       	jmpq   df5 <nulterminate+0x112>
  
  switch(cmd->type){
     d00:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     d04:	8b 00                	mov    (%rax),%eax
     d06:	83 f8 05             	cmp    $0x5,%eax
     d09:	0f 87 e2 00 00 00    	ja     df1 <nulterminate+0x10e>
     d0f:	89 c0                	mov    %eax,%eax
     d11:	48 8b 04 c5 78 19 00 	mov    0x1978(,%rax,8),%rax
     d18:	00 
     d19:	ff e0                	jmpq   *%rax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     d1b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     d1f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    for(i=0; ecmd->argv[i]; i++)
     d23:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     d2a:	eb 1a                	jmp    d46 <nulterminate+0x63>
      *ecmd->eargv[i] = 0;
     d2c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     d30:	8b 55 fc             	mov    -0x4(%rbp),%edx
     d33:	48 63 d2             	movslq %edx,%rdx
     d36:	48 83 c2 0a          	add    $0xa,%rdx
     d3a:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
     d3f:	c6 00 00             	movb   $0x0,(%rax)
    for(i=0; ecmd->argv[i]; i++)
     d42:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     d46:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
     d4a:	8b 55 fc             	mov    -0x4(%rbp),%edx
     d4d:	48 63 d2             	movslq %edx,%rdx
     d50:	48 8b 44 d0 08       	mov    0x8(%rax,%rdx,8),%rax
     d55:	48 85 c0             	test   %rax,%rax
     d58:	75 d2                	jne    d2c <nulterminate+0x49>
    break;
     d5a:	e9 92 00 00 00       	jmpq   df1 <nulterminate+0x10e>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     d5f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     d63:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    nulterminate(rcmd->cmd);
     d67:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     d6b:	48 8b 40 08          	mov    0x8(%rax),%rax
     d6f:	48 89 c7             	mov    %rax,%rdi
     d72:	e8 6c ff ff ff       	callq  ce3 <nulterminate>
    *rcmd->efile = 0;
     d77:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
     d7b:	48 8b 40 18          	mov    0x18(%rax),%rax
     d7f:	c6 00 00             	movb   $0x0,(%rax)
    break;
     d82:	eb 6d                	jmp    df1 <nulterminate+0x10e>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     d84:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     d88:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    nulterminate(pcmd->left);
     d8c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
     d90:	48 8b 40 08          	mov    0x8(%rax),%rax
     d94:	48 89 c7             	mov    %rax,%rdi
     d97:	e8 47 ff ff ff       	callq  ce3 <nulterminate>
    nulterminate(pcmd->right);
     d9c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
     da0:	48 8b 40 10          	mov    0x10(%rax),%rax
     da4:	48 89 c7             	mov    %rax,%rdi
     da7:	e8 37 ff ff ff       	callq  ce3 <nulterminate>
    break;
     dac:	eb 43                	jmp    df1 <nulterminate+0x10e>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     dae:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     db2:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    nulterminate(lcmd->left);
     db6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     dba:	48 8b 40 08          	mov    0x8(%rax),%rax
     dbe:	48 89 c7             	mov    %rax,%rdi
     dc1:	e8 1d ff ff ff       	callq  ce3 <nulterminate>
    nulterminate(lcmd->right);
     dc6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     dca:	48 8b 40 10          	mov    0x10(%rax),%rax
     dce:	48 89 c7             	mov    %rax,%rdi
     dd1:	e8 0d ff ff ff       	callq  ce3 <nulterminate>
    break;
     dd6:	eb 19                	jmp    df1 <nulterminate+0x10e>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     dd8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
     ddc:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    nulterminate(bcmd->cmd);
     de0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     de4:	48 8b 40 08          	mov    0x8(%rax),%rax
     de8:	48 89 c7             	mov    %rax,%rdi
     deb:	e8 f3 fe ff ff       	callq  ce3 <nulterminate>
    break;
     df0:	90                   	nop
  }
  return cmd;
     df1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
}
     df5:	c9                   	leaveq 
     df6:	c3                   	retq   

0000000000000df7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     df7:	55                   	push   %rbp
     df8:	48 89 e5             	mov    %rsp,%rbp
     dfb:	48 83 ec 10          	sub    $0x10,%rsp
     dff:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
     e03:	89 75 f4             	mov    %esi,-0xc(%rbp)
     e06:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
     e09:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
     e0d:	8b 55 f0             	mov    -0x10(%rbp),%edx
     e10:	8b 45 f4             	mov    -0xc(%rbp),%eax
     e13:	48 89 ce             	mov    %rcx,%rsi
     e16:	48 89 f7             	mov    %rsi,%rdi
     e19:	89 d1                	mov    %edx,%ecx
     e1b:	fc                   	cld    
     e1c:	f3 aa                	rep stos %al,%es:(%rdi)
     e1e:	89 ca                	mov    %ecx,%edx
     e20:	48 89 fe             	mov    %rdi,%rsi
     e23:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
     e27:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     e2a:	90                   	nop
     e2b:	c9                   	leaveq 
     e2c:	c3                   	retq   

0000000000000e2d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     e2d:	55                   	push   %rbp
     e2e:	48 89 e5             	mov    %rsp,%rbp
     e31:	48 83 ec 20          	sub    $0x20,%rsp
     e35:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     e39:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
     e3d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     e41:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
     e45:	90                   	nop
     e46:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
     e4a:	48 8d 42 01          	lea    0x1(%rdx),%rax
     e4e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
     e52:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     e56:	48 8d 48 01          	lea    0x1(%rax),%rcx
     e5a:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
     e5e:	0f b6 12             	movzbl (%rdx),%edx
     e61:	88 10                	mov    %dl,(%rax)
     e63:	0f b6 00             	movzbl (%rax),%eax
     e66:	84 c0                	test   %al,%al
     e68:	75 dc                	jne    e46 <strcpy+0x19>
    ;
  return os;
     e6a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     e6e:	c9                   	leaveq 
     e6f:	c3                   	retq   

0000000000000e70 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     e70:	55                   	push   %rbp
     e71:	48 89 e5             	mov    %rsp,%rbp
     e74:	48 83 ec 10          	sub    $0x10,%rsp
     e78:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
     e7c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
     e80:	eb 0a                	jmp    e8c <strcmp+0x1c>
    p++, q++;
     e82:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
     e87:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
     e8c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     e90:	0f b6 00             	movzbl (%rax),%eax
     e93:	84 c0                	test   %al,%al
     e95:	74 12                	je     ea9 <strcmp+0x39>
     e97:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     e9b:	0f b6 10             	movzbl (%rax),%edx
     e9e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     ea2:	0f b6 00             	movzbl (%rax),%eax
     ea5:	38 c2                	cmp    %al,%dl
     ea7:	74 d9                	je     e82 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
     ea9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     ead:	0f b6 00             	movzbl (%rax),%eax
     eb0:	0f b6 d0             	movzbl %al,%edx
     eb3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
     eb7:	0f b6 00             	movzbl (%rax),%eax
     eba:	0f b6 c0             	movzbl %al,%eax
     ebd:	29 c2                	sub    %eax,%edx
     ebf:	89 d0                	mov    %edx,%eax
}
     ec1:	c9                   	leaveq 
     ec2:	c3                   	retq   

0000000000000ec3 <strlen>:

uint
strlen(char *s)
{
     ec3:	55                   	push   %rbp
     ec4:	48 89 e5             	mov    %rsp,%rbp
     ec7:	48 83 ec 18          	sub    $0x18,%rsp
     ecb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
     ecf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     ed6:	eb 04                	jmp    edc <strlen+0x19>
     ed8:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     edc:	8b 45 fc             	mov    -0x4(%rbp),%eax
     edf:	48 63 d0             	movslq %eax,%rdx
     ee2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     ee6:	48 01 d0             	add    %rdx,%rax
     ee9:	0f b6 00             	movzbl (%rax),%eax
     eec:	84 c0                	test   %al,%al
     eee:	75 e8                	jne    ed8 <strlen+0x15>
    ;
  return n;
     ef0:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
     ef3:	c9                   	leaveq 
     ef4:	c3                   	retq   

0000000000000ef5 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ef5:	55                   	push   %rbp
     ef6:	48 89 e5             	mov    %rsp,%rbp
     ef9:	48 83 ec 10          	sub    $0x10,%rsp
     efd:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
     f01:	89 75 f4             	mov    %esi,-0xc(%rbp)
     f04:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
     f07:	8b 55 f0             	mov    -0x10(%rbp),%edx
     f0a:	8b 4d f4             	mov    -0xc(%rbp),%ecx
     f0d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     f11:	89 ce                	mov    %ecx,%esi
     f13:	48 89 c7             	mov    %rax,%rdi
     f16:	e8 dc fe ff ff       	callq  df7 <stosb>
  return dst;
     f1b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
     f1f:	c9                   	leaveq 
     f20:	c3                   	retq   

0000000000000f21 <strchr>:

char*
strchr(const char *s, char c)
{
     f21:	55                   	push   %rbp
     f22:	48 89 e5             	mov    %rsp,%rbp
     f25:	48 83 ec 10          	sub    $0x10,%rsp
     f29:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
     f2d:	89 f0                	mov    %esi,%eax
     f2f:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
     f32:	eb 17                	jmp    f4b <strchr+0x2a>
    if(*s == c)
     f34:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     f38:	0f b6 00             	movzbl (%rax),%eax
     f3b:	38 45 f4             	cmp    %al,-0xc(%rbp)
     f3e:	75 06                	jne    f46 <strchr+0x25>
      return (char*)s;
     f40:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     f44:	eb 15                	jmp    f5b <strchr+0x3a>
  for(; *s; s++)
     f46:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
     f4b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     f4f:	0f b6 00             	movzbl (%rax),%eax
     f52:	84 c0                	test   %al,%al
     f54:	75 de                	jne    f34 <strchr+0x13>
  return 0;
     f56:	b8 00 00 00 00       	mov    $0x0,%eax
}
     f5b:	c9                   	leaveq 
     f5c:	c3                   	retq   

0000000000000f5d <gets>:

char*
gets(char *buf, int max)
{
     f5d:	55                   	push   %rbp
     f5e:	48 89 e5             	mov    %rsp,%rbp
     f61:	48 83 ec 20          	sub    $0x20,%rsp
     f65:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     f69:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f6c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     f73:	eb 48                	jmp    fbd <gets+0x60>
    cc = read(0, &c, 1);
     f75:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
     f79:	ba 01 00 00 00       	mov    $0x1,%edx
     f7e:	48 89 c6             	mov    %rax,%rsi
     f81:	bf 00 00 00 00       	mov    $0x0,%edi
     f86:	e8 77 01 00 00       	callq  1102 <read>
     f8b:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
     f8e:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
     f92:	7e 36                	jle    fca <gets+0x6d>
      break;
    buf[i++] = c;
     f94:	8b 45 fc             	mov    -0x4(%rbp),%eax
     f97:	8d 50 01             	lea    0x1(%rax),%edx
     f9a:	89 55 fc             	mov    %edx,-0x4(%rbp)
     f9d:	48 63 d0             	movslq %eax,%rdx
     fa0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     fa4:	48 01 c2             	add    %rax,%rdx
     fa7:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
     fab:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
     fad:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
     fb1:	3c 0a                	cmp    $0xa,%al
     fb3:	74 16                	je     fcb <gets+0x6e>
     fb5:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
     fb9:	3c 0d                	cmp    $0xd,%al
     fbb:	74 0e                	je     fcb <gets+0x6e>
  for(i=0; i+1 < max; ){
     fbd:	8b 45 fc             	mov    -0x4(%rbp),%eax
     fc0:	83 c0 01             	add    $0x1,%eax
     fc3:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
     fc6:	7f ad                	jg     f75 <gets+0x18>
     fc8:	eb 01                	jmp    fcb <gets+0x6e>
      break;
     fca:	90                   	nop
      break;
  }
  buf[i] = '\0';
     fcb:	8b 45 fc             	mov    -0x4(%rbp),%eax
     fce:	48 63 d0             	movslq %eax,%rdx
     fd1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     fd5:	48 01 d0             	add    %rdx,%rax
     fd8:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
     fdb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
     fdf:	c9                   	leaveq 
     fe0:	c3                   	retq   

0000000000000fe1 <stat>:

int
stat(char *n, struct stat *st)
{
     fe1:	55                   	push   %rbp
     fe2:	48 89 e5             	mov    %rsp,%rbp
     fe5:	48 83 ec 20          	sub    $0x20,%rsp
     fe9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
     fed:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ff1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     ff5:	be 00 00 00 00       	mov    $0x0,%esi
     ffa:	48 89 c7             	mov    %rax,%rdi
     ffd:	e8 28 01 00 00       	callq  112a <open>
    1002:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
    1005:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1009:	79 07                	jns    1012 <stat+0x31>
    return -1;
    100b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1010:	eb 21                	jmp    1033 <stat+0x52>
  r = fstat(fd, st);
    1012:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
    1016:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1019:	48 89 d6             	mov    %rdx,%rsi
    101c:	89 c7                	mov    %eax,%edi
    101e:	e8 1f 01 00 00       	callq  1142 <fstat>
    1023:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
    1026:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1029:	89 c7                	mov    %eax,%edi
    102b:	e8 e2 00 00 00       	callq  1112 <close>
  return r;
    1030:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
    1033:	c9                   	leaveq 
    1034:	c3                   	retq   

0000000000001035 <atoi>:

int
atoi(const char *s)
{
    1035:	55                   	push   %rbp
    1036:	48 89 e5             	mov    %rsp,%rbp
    1039:	48 83 ec 18          	sub    $0x18,%rsp
    103d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
    1041:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
    1048:	eb 28                	jmp    1072 <atoi+0x3d>
    n = n*10 + *s++ - '0';
    104a:	8b 55 fc             	mov    -0x4(%rbp),%edx
    104d:	89 d0                	mov    %edx,%eax
    104f:	c1 e0 02             	shl    $0x2,%eax
    1052:	01 d0                	add    %edx,%eax
    1054:	01 c0                	add    %eax,%eax
    1056:	89 c1                	mov    %eax,%ecx
    1058:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    105c:	48 8d 50 01          	lea    0x1(%rax),%rdx
    1060:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
    1064:	0f b6 00             	movzbl (%rax),%eax
    1067:	0f be c0             	movsbl %al,%eax
    106a:	01 c8                	add    %ecx,%eax
    106c:	83 e8 30             	sub    $0x30,%eax
    106f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
    1072:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    1076:	0f b6 00             	movzbl (%rax),%eax
    1079:	3c 2f                	cmp    $0x2f,%al
    107b:	7e 0b                	jle    1088 <atoi+0x53>
    107d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    1081:	0f b6 00             	movzbl (%rax),%eax
    1084:	3c 39                	cmp    $0x39,%al
    1086:	7e c2                	jle    104a <atoi+0x15>
  return n;
    1088:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
    108b:	c9                   	leaveq 
    108c:	c3                   	retq   

000000000000108d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    108d:	55                   	push   %rbp
    108e:	48 89 e5             	mov    %rsp,%rbp
    1091:	48 83 ec 28          	sub    $0x28,%rsp
    1095:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    1099:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    109d:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
    10a0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    10a4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
    10a8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    10ac:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
    10b0:	eb 1d                	jmp    10cf <memmove+0x42>
    *dst++ = *src++;
    10b2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
    10b6:	48 8d 42 01          	lea    0x1(%rdx),%rax
    10ba:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    10be:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    10c2:	48 8d 48 01          	lea    0x1(%rax),%rcx
    10c6:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
    10ca:	0f b6 12             	movzbl (%rdx),%edx
    10cd:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
    10cf:	8b 45 dc             	mov    -0x24(%rbp),%eax
    10d2:	8d 50 ff             	lea    -0x1(%rax),%edx
    10d5:	89 55 dc             	mov    %edx,-0x24(%rbp)
    10d8:	85 c0                	test   %eax,%eax
    10da:	7f d6                	jg     10b2 <memmove+0x25>
  return vdst;
    10dc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
    10e0:	c9                   	leaveq 
    10e1:	c3                   	retq   

00000000000010e2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    10e2:	b8 01 00 00 00       	mov    $0x1,%eax
    10e7:	cd 40                	int    $0x40
    10e9:	c3                   	retq   

00000000000010ea <exit>:
SYSCALL(exit)
    10ea:	b8 02 00 00 00       	mov    $0x2,%eax
    10ef:	cd 40                	int    $0x40
    10f1:	c3                   	retq   

00000000000010f2 <wait>:
SYSCALL(wait)
    10f2:	b8 03 00 00 00       	mov    $0x3,%eax
    10f7:	cd 40                	int    $0x40
    10f9:	c3                   	retq   

00000000000010fa <pipe>:
SYSCALL(pipe)
    10fa:	b8 04 00 00 00       	mov    $0x4,%eax
    10ff:	cd 40                	int    $0x40
    1101:	c3                   	retq   

0000000000001102 <read>:
SYSCALL(read)
    1102:	b8 05 00 00 00       	mov    $0x5,%eax
    1107:	cd 40                	int    $0x40
    1109:	c3                   	retq   

000000000000110a <write>:
SYSCALL(write)
    110a:	b8 10 00 00 00       	mov    $0x10,%eax
    110f:	cd 40                	int    $0x40
    1111:	c3                   	retq   

0000000000001112 <close>:
SYSCALL(close)
    1112:	b8 15 00 00 00       	mov    $0x15,%eax
    1117:	cd 40                	int    $0x40
    1119:	c3                   	retq   

000000000000111a <kill>:
SYSCALL(kill)
    111a:	b8 06 00 00 00       	mov    $0x6,%eax
    111f:	cd 40                	int    $0x40
    1121:	c3                   	retq   

0000000000001122 <exec>:
SYSCALL(exec)
    1122:	b8 07 00 00 00       	mov    $0x7,%eax
    1127:	cd 40                	int    $0x40
    1129:	c3                   	retq   

000000000000112a <open>:
SYSCALL(open)
    112a:	b8 0f 00 00 00       	mov    $0xf,%eax
    112f:	cd 40                	int    $0x40
    1131:	c3                   	retq   

0000000000001132 <mknod>:
SYSCALL(mknod)
    1132:	b8 11 00 00 00       	mov    $0x11,%eax
    1137:	cd 40                	int    $0x40
    1139:	c3                   	retq   

000000000000113a <unlink>:
SYSCALL(unlink)
    113a:	b8 12 00 00 00       	mov    $0x12,%eax
    113f:	cd 40                	int    $0x40
    1141:	c3                   	retq   

0000000000001142 <fstat>:
SYSCALL(fstat)
    1142:	b8 08 00 00 00       	mov    $0x8,%eax
    1147:	cd 40                	int    $0x40
    1149:	c3                   	retq   

000000000000114a <link>:
SYSCALL(link)
    114a:	b8 13 00 00 00       	mov    $0x13,%eax
    114f:	cd 40                	int    $0x40
    1151:	c3                   	retq   

0000000000001152 <mkdir>:
SYSCALL(mkdir)
    1152:	b8 14 00 00 00       	mov    $0x14,%eax
    1157:	cd 40                	int    $0x40
    1159:	c3                   	retq   

000000000000115a <chdir>:
SYSCALL(chdir)
    115a:	b8 09 00 00 00       	mov    $0x9,%eax
    115f:	cd 40                	int    $0x40
    1161:	c3                   	retq   

0000000000001162 <dup>:
SYSCALL(dup)
    1162:	b8 0a 00 00 00       	mov    $0xa,%eax
    1167:	cd 40                	int    $0x40
    1169:	c3                   	retq   

000000000000116a <getpid>:
SYSCALL(getpid)
    116a:	b8 0b 00 00 00       	mov    $0xb,%eax
    116f:	cd 40                	int    $0x40
    1171:	c3                   	retq   

0000000000001172 <sbrk>:
SYSCALL(sbrk)
    1172:	b8 0c 00 00 00       	mov    $0xc,%eax
    1177:	cd 40                	int    $0x40
    1179:	c3                   	retq   

000000000000117a <sleep>:
SYSCALL(sleep)
    117a:	b8 0d 00 00 00       	mov    $0xd,%eax
    117f:	cd 40                	int    $0x40
    1181:	c3                   	retq   

0000000000001182 <uptime>:
SYSCALL(uptime)
    1182:	b8 0e 00 00 00       	mov    $0xe,%eax
    1187:	cd 40                	int    $0x40
    1189:	c3                   	retq   

000000000000118a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    118a:	55                   	push   %rbp
    118b:	48 89 e5             	mov    %rsp,%rbp
    118e:	48 83 ec 10          	sub    $0x10,%rsp
    1192:	89 7d fc             	mov    %edi,-0x4(%rbp)
    1195:	89 f0                	mov    %esi,%eax
    1197:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
    119a:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
    119e:	8b 45 fc             	mov    -0x4(%rbp),%eax
    11a1:	ba 01 00 00 00       	mov    $0x1,%edx
    11a6:	48 89 ce             	mov    %rcx,%rsi
    11a9:	89 c7                	mov    %eax,%edi
    11ab:	e8 5a ff ff ff       	callq  110a <write>
}
    11b0:	90                   	nop
    11b1:	c9                   	leaveq 
    11b2:	c3                   	retq   

00000000000011b3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    11b3:	55                   	push   %rbp
    11b4:	48 89 e5             	mov    %rsp,%rbp
    11b7:	48 83 ec 30          	sub    $0x30,%rsp
    11bb:	89 7d dc             	mov    %edi,-0x24(%rbp)
    11be:	89 75 d8             	mov    %esi,-0x28(%rbp)
    11c1:	89 55 d4             	mov    %edx,-0x2c(%rbp)
    11c4:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    11c7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
    11ce:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
    11d2:	74 17                	je     11eb <printint+0x38>
    11d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
    11d8:	79 11                	jns    11eb <printint+0x38>
    neg = 1;
    11da:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
    11e1:	8b 45 d8             	mov    -0x28(%rbp),%eax
    11e4:	f7 d8                	neg    %eax
    11e6:	89 45 f4             	mov    %eax,-0xc(%rbp)
    11e9:	eb 06                	jmp    11f1 <printint+0x3e>
  } else {
    x = xx;
    11eb:	8b 45 d8             	mov    -0x28(%rbp),%eax
    11ee:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
    11f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
    11f8:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
    11fb:	8b 45 f4             	mov    -0xc(%rbp),%eax
    11fe:	ba 00 00 00 00       	mov    $0x0,%edx
    1203:	f7 f1                	div    %ecx
    1205:	89 d1                	mov    %edx,%ecx
    1207:	8b 45 fc             	mov    -0x4(%rbp),%eax
    120a:	8d 50 01             	lea    0x1(%rax),%edx
    120d:	89 55 fc             	mov    %edx,-0x4(%rbp)
    1210:	89 ca                	mov    %ecx,%edx
    1212:	0f b6 92 30 1e 00 00 	movzbl 0x1e30(%rdx),%edx
    1219:	48 98                	cltq   
    121b:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
    121f:	8b 75 d4             	mov    -0x2c(%rbp),%esi
    1222:	8b 45 f4             	mov    -0xc(%rbp),%eax
    1225:	ba 00 00 00 00       	mov    $0x0,%edx
    122a:	f7 f6                	div    %esi
    122c:	89 45 f4             	mov    %eax,-0xc(%rbp)
    122f:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1233:	75 c3                	jne    11f8 <printint+0x45>
  if(neg)
    1235:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    1239:	74 2b                	je     1266 <printint+0xb3>
    buf[i++] = '-';
    123b:	8b 45 fc             	mov    -0x4(%rbp),%eax
    123e:	8d 50 01             	lea    0x1(%rax),%edx
    1241:	89 55 fc             	mov    %edx,-0x4(%rbp)
    1244:	48 98                	cltq   
    1246:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
    124b:	eb 19                	jmp    1266 <printint+0xb3>
    putc(fd, buf[i]);
    124d:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1250:	48 98                	cltq   
    1252:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
    1257:	0f be d0             	movsbl %al,%edx
    125a:	8b 45 dc             	mov    -0x24(%rbp),%eax
    125d:	89 d6                	mov    %edx,%esi
    125f:	89 c7                	mov    %eax,%edi
    1261:	e8 24 ff ff ff       	callq  118a <putc>
  while(--i >= 0)
    1266:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
    126a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    126e:	79 dd                	jns    124d <printint+0x9a>
}
    1270:	90                   	nop
    1271:	c9                   	leaveq 
    1272:	c3                   	retq   

0000000000001273 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1273:	55                   	push   %rbp
    1274:	48 89 e5             	mov    %rsp,%rbp
    1277:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
    127e:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
    1284:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
    128b:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
    1292:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
    1299:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
    12a0:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
    12a7:	84 c0                	test   %al,%al
    12a9:	74 20                	je     12cb <printf+0x58>
    12ab:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
    12af:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
    12b3:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
    12b7:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
    12bb:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
    12bf:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
    12c3:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
    12c7:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
    12cb:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
    12d2:	00 00 00 
    12d5:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
    12dc:	00 00 00 
    12df:	48 8d 45 10          	lea    0x10(%rbp),%rax
    12e3:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
    12ea:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
    12f1:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
    12f8:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
    12ff:	00 00 00 
  for(i = 0; fmt[i]; i++){
    1302:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
    1309:	00 00 00 
    130c:	e9 a8 02 00 00       	jmpq   15b9 <printf+0x346>
    c = fmt[i] & 0xff;
    1311:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
    1317:	48 63 d0             	movslq %eax,%rdx
    131a:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
    1321:	48 01 d0             	add    %rdx,%rax
    1324:	0f b6 00             	movzbl (%rax),%eax
    1327:	0f be c0             	movsbl %al,%eax
    132a:	25 ff 00 00 00       	and    $0xff,%eax
    132f:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
    1335:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
    133c:	75 35                	jne    1373 <printf+0x100>
      if(c == '%'){
    133e:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
    1345:	75 0f                	jne    1356 <printf+0xe3>
        state = '%';
    1347:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
    134e:	00 00 00 
    1351:	e9 5c 02 00 00       	jmpq   15b2 <printf+0x33f>
      } else {
        putc(fd, c);
    1356:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    135c:	0f be d0             	movsbl %al,%edx
    135f:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    1365:	89 d6                	mov    %edx,%esi
    1367:	89 c7                	mov    %eax,%edi
    1369:	e8 1c fe ff ff       	callq  118a <putc>
    136e:	e9 3f 02 00 00       	jmpq   15b2 <printf+0x33f>
      }
    } else if(state == '%'){
    1373:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
    137a:	0f 85 32 02 00 00    	jne    15b2 <printf+0x33f>
      if(c == 'd'){
    1380:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
    1387:	75 5e                	jne    13e7 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
    1389:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    138f:	83 f8 2f             	cmp    $0x2f,%eax
    1392:	77 23                	ja     13b7 <printf+0x144>
    1394:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    139b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    13a1:	89 d2                	mov    %edx,%edx
    13a3:	48 01 d0             	add    %rdx,%rax
    13a6:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    13ac:	83 c2 08             	add    $0x8,%edx
    13af:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    13b5:	eb 12                	jmp    13c9 <printf+0x156>
    13b7:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    13be:	48 8d 50 08          	lea    0x8(%rax),%rdx
    13c2:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    13c9:	8b 30                	mov    (%rax),%esi
    13cb:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    13d1:	b9 01 00 00 00       	mov    $0x1,%ecx
    13d6:	ba 0a 00 00 00       	mov    $0xa,%edx
    13db:	89 c7                	mov    %eax,%edi
    13dd:	e8 d1 fd ff ff       	callq  11b3 <printint>
    13e2:	e9 c1 01 00 00       	jmpq   15a8 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
    13e7:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
    13ee:	74 09                	je     13f9 <printf+0x186>
    13f0:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
    13f7:	75 5e                	jne    1457 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
    13f9:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    13ff:	83 f8 2f             	cmp    $0x2f,%eax
    1402:	77 23                	ja     1427 <printf+0x1b4>
    1404:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    140b:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    1411:	89 d2                	mov    %edx,%edx
    1413:	48 01 d0             	add    %rdx,%rax
    1416:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    141c:	83 c2 08             	add    $0x8,%edx
    141f:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    1425:	eb 12                	jmp    1439 <printf+0x1c6>
    1427:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    142e:	48 8d 50 08          	lea    0x8(%rax),%rdx
    1432:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    1439:	8b 30                	mov    (%rax),%esi
    143b:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    1441:	b9 00 00 00 00       	mov    $0x0,%ecx
    1446:	ba 10 00 00 00       	mov    $0x10,%edx
    144b:	89 c7                	mov    %eax,%edi
    144d:	e8 61 fd ff ff       	callq  11b3 <printint>
    1452:	e9 51 01 00 00       	jmpq   15a8 <printf+0x335>
      } else if(c == 's'){
    1457:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
    145e:	0f 85 98 00 00 00    	jne    14fc <printf+0x289>
        s = va_arg(ap, char*);
    1464:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    146a:	83 f8 2f             	cmp    $0x2f,%eax
    146d:	77 23                	ja     1492 <printf+0x21f>
    146f:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    1476:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    147c:	89 d2                	mov    %edx,%edx
    147e:	48 01 d0             	add    %rdx,%rax
    1481:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    1487:	83 c2 08             	add    $0x8,%edx
    148a:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    1490:	eb 12                	jmp    14a4 <printf+0x231>
    1492:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    1499:	48 8d 50 08          	lea    0x8(%rax),%rdx
    149d:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    14a4:	48 8b 00             	mov    (%rax),%rax
    14a7:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
    14ae:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
    14b5:	00 
    14b6:	75 31                	jne    14e9 <printf+0x276>
          s = "(null)";
    14b8:	48 c7 85 48 ff ff ff 	movq   $0x19a8,-0xb8(%rbp)
    14bf:	a8 19 00 00 
        while(*s != 0){
    14c3:	eb 24                	jmp    14e9 <printf+0x276>
          putc(fd, *s);
    14c5:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
    14cc:	0f b6 00             	movzbl (%rax),%eax
    14cf:	0f be d0             	movsbl %al,%edx
    14d2:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    14d8:	89 d6                	mov    %edx,%esi
    14da:	89 c7                	mov    %eax,%edi
    14dc:	e8 a9 fc ff ff       	callq  118a <putc>
          s++;
    14e1:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
    14e8:	01 
        while(*s != 0){
    14e9:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
    14f0:	0f b6 00             	movzbl (%rax),%eax
    14f3:	84 c0                	test   %al,%al
    14f5:	75 ce                	jne    14c5 <printf+0x252>
    14f7:	e9 ac 00 00 00       	jmpq   15a8 <printf+0x335>
        }
      } else if(c == 'c'){
    14fc:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
    1503:	75 56                	jne    155b <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
    1505:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    150b:	83 f8 2f             	cmp    $0x2f,%eax
    150e:	77 23                	ja     1533 <printf+0x2c0>
    1510:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    1517:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    151d:	89 d2                	mov    %edx,%edx
    151f:	48 01 d0             	add    %rdx,%rax
    1522:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    1528:	83 c2 08             	add    $0x8,%edx
    152b:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    1531:	eb 12                	jmp    1545 <printf+0x2d2>
    1533:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    153a:	48 8d 50 08          	lea    0x8(%rax),%rdx
    153e:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    1545:	8b 00                	mov    (%rax),%eax
    1547:	0f be d0             	movsbl %al,%edx
    154a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    1550:	89 d6                	mov    %edx,%esi
    1552:	89 c7                	mov    %eax,%edi
    1554:	e8 31 fc ff ff       	callq  118a <putc>
    1559:	eb 4d                	jmp    15a8 <printf+0x335>
      } else if(c == '%'){
    155b:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
    1562:	75 1a                	jne    157e <printf+0x30b>
        putc(fd, c);
    1564:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    156a:	0f be d0             	movsbl %al,%edx
    156d:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    1573:	89 d6                	mov    %edx,%esi
    1575:	89 c7                	mov    %eax,%edi
    1577:	e8 0e fc ff ff       	callq  118a <putc>
    157c:	eb 2a                	jmp    15a8 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    157e:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    1584:	be 25 00 00 00       	mov    $0x25,%esi
    1589:	89 c7                	mov    %eax,%edi
    158b:	e8 fa fb ff ff       	callq  118a <putc>
        putc(fd, c);
    1590:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    1596:	0f be d0             	movsbl %al,%edx
    1599:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    159f:	89 d6                	mov    %edx,%esi
    15a1:	89 c7                	mov    %eax,%edi
    15a3:	e8 e2 fb ff ff       	callq  118a <putc>
      }
      state = 0;
    15a8:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
    15af:	00 00 00 
  for(i = 0; fmt[i]; i++){
    15b2:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
    15b9:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
    15bf:	48 63 d0             	movslq %eax,%rdx
    15c2:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
    15c9:	48 01 d0             	add    %rdx,%rax
    15cc:	0f b6 00             	movzbl (%rax),%eax
    15cf:	84 c0                	test   %al,%al
    15d1:	0f 85 3a fd ff ff    	jne    1311 <printf+0x9e>
    }
  }
}
    15d7:	90                   	nop
    15d8:	c9                   	leaveq 
    15d9:	c3                   	retq   

00000000000015da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15da:	55                   	push   %rbp
    15db:	48 89 e5             	mov    %rsp,%rbp
    15de:	48 83 ec 18          	sub    $0x18,%rsp
    15e2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15e6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    15ea:	48 83 e8 10          	sub    $0x10,%rax
    15ee:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15f2:	48 8b 05 e7 08 00 00 	mov    0x8e7(%rip),%rax        # 1ee0 <freep>
    15f9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    15fd:	eb 2f                	jmp    162e <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15ff:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1603:	48 8b 00             	mov    (%rax),%rax
    1606:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    160a:	72 17                	jb     1623 <free+0x49>
    160c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1610:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
    1614:	77 2f                	ja     1645 <free+0x6b>
    1616:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    161a:	48 8b 00             	mov    (%rax),%rax
    161d:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    1621:	72 22                	jb     1645 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1623:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1627:	48 8b 00             	mov    (%rax),%rax
    162a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    162e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1632:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
    1636:	76 c7                	jbe    15ff <free+0x25>
    1638:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    163c:	48 8b 00             	mov    (%rax),%rax
    163f:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    1643:	73 ba                	jae    15ff <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
    1645:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1649:	8b 40 08             	mov    0x8(%rax),%eax
    164c:	89 c0                	mov    %eax,%eax
    164e:	48 c1 e0 04          	shl    $0x4,%rax
    1652:	48 89 c2             	mov    %rax,%rdx
    1655:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1659:	48 01 c2             	add    %rax,%rdx
    165c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1660:	48 8b 00             	mov    (%rax),%rax
    1663:	48 39 c2             	cmp    %rax,%rdx
    1666:	75 2d                	jne    1695 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
    1668:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    166c:	8b 50 08             	mov    0x8(%rax),%edx
    166f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1673:	48 8b 00             	mov    (%rax),%rax
    1676:	8b 40 08             	mov    0x8(%rax),%eax
    1679:	01 c2                	add    %eax,%edx
    167b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    167f:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1682:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1686:	48 8b 00             	mov    (%rax),%rax
    1689:	48 8b 10             	mov    (%rax),%rdx
    168c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1690:	48 89 10             	mov    %rdx,(%rax)
    1693:	eb 0e                	jmp    16a3 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
    1695:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1699:	48 8b 10             	mov    (%rax),%rdx
    169c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    16a0:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
    16a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16a7:	8b 40 08             	mov    0x8(%rax),%eax
    16aa:	89 c0                	mov    %eax,%eax
    16ac:	48 c1 e0 04          	shl    $0x4,%rax
    16b0:	48 89 c2             	mov    %rax,%rdx
    16b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16b7:	48 01 d0             	add    %rdx,%rax
    16ba:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    16be:	75 27                	jne    16e7 <free+0x10d>
    p->s.size += bp->s.size;
    16c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16c4:	8b 50 08             	mov    0x8(%rax),%edx
    16c7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    16cb:	8b 40 08             	mov    0x8(%rax),%eax
    16ce:	01 c2                	add    %eax,%edx
    16d0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16d4:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
    16d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    16db:	48 8b 10             	mov    (%rax),%rdx
    16de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16e2:	48 89 10             	mov    %rdx,(%rax)
    16e5:	eb 0b                	jmp    16f2 <free+0x118>
  } else
    p->s.ptr = bp;
    16e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16eb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
    16ef:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
    16f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    16f6:	48 89 05 e3 07 00 00 	mov    %rax,0x7e3(%rip)        # 1ee0 <freep>
}
    16fd:	90                   	nop
    16fe:	c9                   	leaveq 
    16ff:	c3                   	retq   

0000000000001700 <morecore>:

static Header*
morecore(uint nu)
{
    1700:	55                   	push   %rbp
    1701:	48 89 e5             	mov    %rsp,%rbp
    1704:	48 83 ec 20          	sub    $0x20,%rsp
    1708:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
    170b:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
    1712:	77 07                	ja     171b <morecore+0x1b>
    nu = 4096;
    1714:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
    171b:	8b 45 ec             	mov    -0x14(%rbp),%eax
    171e:	c1 e0 04             	shl    $0x4,%eax
    1721:	89 c7                	mov    %eax,%edi
    1723:	e8 4a fa ff ff       	callq  1172 <sbrk>
    1728:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
    172c:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
    1731:	75 07                	jne    173a <morecore+0x3a>
    return 0;
    1733:	b8 00 00 00 00       	mov    $0x0,%eax
    1738:	eb 29                	jmp    1763 <morecore+0x63>
  hp = (Header*)p;
    173a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    173e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
    1742:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1746:	8b 55 ec             	mov    -0x14(%rbp),%edx
    1749:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
    174c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1750:	48 83 c0 10          	add    $0x10,%rax
    1754:	48 89 c7             	mov    %rax,%rdi
    1757:	e8 7e fe ff ff       	callq  15da <free>
  return freep;
    175c:	48 8b 05 7d 07 00 00 	mov    0x77d(%rip),%rax        # 1ee0 <freep>
}
    1763:	c9                   	leaveq 
    1764:	c3                   	retq   

0000000000001765 <malloc>:

void*
malloc(uint nbytes)
{
    1765:	55                   	push   %rbp
    1766:	48 89 e5             	mov    %rsp,%rbp
    1769:	48 83 ec 30          	sub    $0x30,%rsp
    176d:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1770:	8b 45 dc             	mov    -0x24(%rbp),%eax
    1773:	48 83 c0 0f          	add    $0xf,%rax
    1777:	48 c1 e8 04          	shr    $0x4,%rax
    177b:	83 c0 01             	add    $0x1,%eax
    177e:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
    1781:	48 8b 05 58 07 00 00 	mov    0x758(%rip),%rax        # 1ee0 <freep>
    1788:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    178c:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
    1791:	75 2b                	jne    17be <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
    1793:	48 c7 45 f0 d0 1e 00 	movq   $0x1ed0,-0x10(%rbp)
    179a:	00 
    179b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    179f:	48 89 05 3a 07 00 00 	mov    %rax,0x73a(%rip)        # 1ee0 <freep>
    17a6:	48 8b 05 33 07 00 00 	mov    0x733(%rip),%rax        # 1ee0 <freep>
    17ad:	48 89 05 1c 07 00 00 	mov    %rax,0x71c(%rip)        # 1ed0 <base>
    base.s.size = 0;
    17b4:	c7 05 1a 07 00 00 00 	movl   $0x0,0x71a(%rip)        # 1ed8 <base+0x8>
    17bb:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    17c2:	48 8b 00             	mov    (%rax),%rax
    17c5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
    17c9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    17cd:	8b 40 08             	mov    0x8(%rax),%eax
    17d0:	39 45 ec             	cmp    %eax,-0x14(%rbp)
    17d3:	77 5f                	ja     1834 <malloc+0xcf>
      if(p->s.size == nunits)
    17d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    17d9:	8b 40 08             	mov    0x8(%rax),%eax
    17dc:	39 45 ec             	cmp    %eax,-0x14(%rbp)
    17df:	75 10                	jne    17f1 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
    17e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    17e5:	48 8b 10             	mov    (%rax),%rdx
    17e8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    17ec:	48 89 10             	mov    %rdx,(%rax)
    17ef:	eb 2e                	jmp    181f <malloc+0xba>
      else {
        p->s.size -= nunits;
    17f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    17f5:	8b 40 08             	mov    0x8(%rax),%eax
    17f8:	2b 45 ec             	sub    -0x14(%rbp),%eax
    17fb:	89 c2                	mov    %eax,%edx
    17fd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1801:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
    1804:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1808:	8b 40 08             	mov    0x8(%rax),%eax
    180b:	89 c0                	mov    %eax,%eax
    180d:	48 c1 e0 04          	shl    $0x4,%rax
    1811:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
    1815:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1819:	8b 55 ec             	mov    -0x14(%rbp),%edx
    181c:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
    181f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    1823:	48 89 05 b6 06 00 00 	mov    %rax,0x6b6(%rip)        # 1ee0 <freep>
      return (void*)(p + 1);
    182a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    182e:	48 83 c0 10          	add    $0x10,%rax
    1832:	eb 41                	jmp    1875 <malloc+0x110>
    }
    if(p == freep)
    1834:	48 8b 05 a5 06 00 00 	mov    0x6a5(%rip),%rax        # 1ee0 <freep>
    183b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    183f:	75 1c                	jne    185d <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
    1841:	8b 45 ec             	mov    -0x14(%rbp),%eax
    1844:	89 c7                	mov    %eax,%edi
    1846:	e8 b5 fe ff ff       	callq  1700 <morecore>
    184b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    184f:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
    1854:	75 07                	jne    185d <malloc+0xf8>
        return 0;
    1856:	b8 00 00 00 00       	mov    $0x0,%eax
    185b:	eb 18                	jmp    1875 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    185d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1861:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    1865:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    1869:	48 8b 00             	mov    (%rax),%rax
    186c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
    1870:	e9 54 ff ff ff       	jmpq   17c9 <malloc+0x64>
  }
}
    1875:	c9                   	leaveq 
    1876:	c3                   	retq   
