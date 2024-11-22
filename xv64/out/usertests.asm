
fs/usertests:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <opentest>:

// simple file system tests

void
opentest(void)
{
       0:	55                   	push   %rbp
       1:	48 89 e5             	mov    %rsp,%rbp
       4:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;

  printf(stdout, "open test\n");
       8:	8b 05 da 62 00 00    	mov    0x62da(%rip),%eax        # 62e8 <stdout>
       e:	48 c7 c6 5e 45 00 00 	mov    $0x455e,%rsi
      15:	89 c7                	mov    %eax,%edi
      17:	b8 00 00 00 00       	mov    $0x0,%eax
      1c:	e8 21 3f 00 00       	callq  3f42 <printf>
  fd = open("echo", 0);
      21:	be 00 00 00 00       	mov    $0x0,%esi
      26:	48 c7 c7 48 45 00 00 	mov    $0x4548,%rdi
      2d:	e8 c7 3d 00 00       	callq  3df9 <open>
      32:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
      35:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
      39:	79 1e                	jns    59 <opentest+0x59>
    printf(stdout, "open echo failed!\n");
      3b:	8b 05 a7 62 00 00    	mov    0x62a7(%rip),%eax        # 62e8 <stdout>
      41:	48 c7 c6 69 45 00 00 	mov    $0x4569,%rsi
      48:	89 c7                	mov    %eax,%edi
      4a:	b8 00 00 00 00       	mov    $0x0,%eax
      4f:	e8 ee 3e 00 00       	callq  3f42 <printf>
    exit();
      54:	e8 60 3d 00 00       	callq  3db9 <exit>
  }
  close(fd);
      59:	8b 45 fc             	mov    -0x4(%rbp),%eax
      5c:	89 c7                	mov    %eax,%edi
      5e:	e8 7e 3d 00 00       	callq  3de1 <close>
  fd = open("doesnotexist", 0);
      63:	be 00 00 00 00       	mov    $0x0,%esi
      68:	48 c7 c7 7c 45 00 00 	mov    $0x457c,%rdi
      6f:	e8 85 3d 00 00       	callq  3df9 <open>
      74:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd >= 0){
      77:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
      7b:	78 1e                	js     9b <opentest+0x9b>
    printf(stdout, "open doesnotexist succeeded!\n");
      7d:	8b 05 65 62 00 00    	mov    0x6265(%rip),%eax        # 62e8 <stdout>
      83:	48 c7 c6 89 45 00 00 	mov    $0x4589,%rsi
      8a:	89 c7                	mov    %eax,%edi
      8c:	b8 00 00 00 00       	mov    $0x0,%eax
      91:	e8 ac 3e 00 00       	callq  3f42 <printf>
    exit();
      96:	e8 1e 3d 00 00       	callq  3db9 <exit>
  }
  printf(stdout, "open test ok\n");
      9b:	8b 05 47 62 00 00    	mov    0x6247(%rip),%eax        # 62e8 <stdout>
      a1:	48 c7 c6 a7 45 00 00 	mov    $0x45a7,%rsi
      a8:	89 c7                	mov    %eax,%edi
      aa:	b8 00 00 00 00       	mov    $0x0,%eax
      af:	e8 8e 3e 00 00       	callq  3f42 <printf>
}
      b4:	90                   	nop
      b5:	c9                   	leaveq 
      b6:	c3                   	retq   

00000000000000b7 <writetest>:

void
writetest(void)
{
      b7:	55                   	push   %rbp
      b8:	48 89 e5             	mov    %rsp,%rbp
      bb:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;
  int i;

  printf(stdout, "small file test\n");
      bf:	8b 05 23 62 00 00    	mov    0x6223(%rip),%eax        # 62e8 <stdout>
      c5:	48 c7 c6 b5 45 00 00 	mov    $0x45b5,%rsi
      cc:	89 c7                	mov    %eax,%edi
      ce:	b8 00 00 00 00       	mov    $0x0,%eax
      d3:	e8 6a 3e 00 00       	callq  3f42 <printf>
  fd = open("small", O_CREATE|O_RDWR);
      d8:	be 02 02 00 00       	mov    $0x202,%esi
      dd:	48 c7 c7 c6 45 00 00 	mov    $0x45c6,%rdi
      e4:	e8 10 3d 00 00       	callq  3df9 <open>
      e9:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(fd >= 0){
      ec:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
      f0:	78 25                	js     117 <writetest+0x60>
    printf(stdout, "creat small succeeded; ok\n");
      f2:	8b 05 f0 61 00 00    	mov    0x61f0(%rip),%eax        # 62e8 <stdout>
      f8:	48 c7 c6 cc 45 00 00 	mov    $0x45cc,%rsi
      ff:	89 c7                	mov    %eax,%edi
     101:	b8 00 00 00 00       	mov    $0x0,%eax
     106:	e8 37 3e 00 00       	callq  3f42 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     10b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     112:	e9 9a 00 00 00       	jmpq   1b1 <writetest+0xfa>
    printf(stdout, "error: creat small failed!\n");
     117:	8b 05 cb 61 00 00    	mov    0x61cb(%rip),%eax        # 62e8 <stdout>
     11d:	48 c7 c6 e7 45 00 00 	mov    $0x45e7,%rsi
     124:	89 c7                	mov    %eax,%edi
     126:	b8 00 00 00 00       	mov    $0x0,%eax
     12b:	e8 12 3e 00 00       	callq  3f42 <printf>
    exit();
     130:	e8 84 3c 00 00       	callq  3db9 <exit>
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     135:	8b 45 f8             	mov    -0x8(%rbp),%eax
     138:	ba 0a 00 00 00       	mov    $0xa,%edx
     13d:	48 c7 c6 03 46 00 00 	mov    $0x4603,%rsi
     144:	89 c7                	mov    %eax,%edi
     146:	e8 8e 3c 00 00       	callq  3dd9 <write>
     14b:	83 f8 0a             	cmp    $0xa,%eax
     14e:	74 21                	je     171 <writetest+0xba>
      printf(stdout, "error: write aa %d new file failed\n", i);
     150:	8b 05 92 61 00 00    	mov    0x6192(%rip),%eax        # 62e8 <stdout>
     156:	8b 55 fc             	mov    -0x4(%rbp),%edx
     159:	48 c7 c6 10 46 00 00 	mov    $0x4610,%rsi
     160:	89 c7                	mov    %eax,%edi
     162:	b8 00 00 00 00       	mov    $0x0,%eax
     167:	e8 d6 3d 00 00       	callq  3f42 <printf>
      exit();
     16c:	e8 48 3c 00 00       	callq  3db9 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     171:	8b 45 f8             	mov    -0x8(%rbp),%eax
     174:	ba 0a 00 00 00       	mov    $0xa,%edx
     179:	48 c7 c6 34 46 00 00 	mov    $0x4634,%rsi
     180:	89 c7                	mov    %eax,%edi
     182:	e8 52 3c 00 00       	callq  3dd9 <write>
     187:	83 f8 0a             	cmp    $0xa,%eax
     18a:	74 21                	je     1ad <writetest+0xf6>
      printf(stdout, "error: write bb %d new file failed\n", i);
     18c:	8b 05 56 61 00 00    	mov    0x6156(%rip),%eax        # 62e8 <stdout>
     192:	8b 55 fc             	mov    -0x4(%rbp),%edx
     195:	48 c7 c6 40 46 00 00 	mov    $0x4640,%rsi
     19c:	89 c7                	mov    %eax,%edi
     19e:	b8 00 00 00 00       	mov    $0x0,%eax
     1a3:	e8 9a 3d 00 00       	callq  3f42 <printf>
      exit();
     1a8:	e8 0c 3c 00 00       	callq  3db9 <exit>
  for(i = 0; i < 100; i++){
     1ad:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     1b1:	83 7d fc 63          	cmpl   $0x63,-0x4(%rbp)
     1b5:	0f 8e 7a ff ff ff    	jle    135 <writetest+0x7e>
    }
  }
  printf(stdout, "writes ok\n");
     1bb:	8b 05 27 61 00 00    	mov    0x6127(%rip),%eax        # 62e8 <stdout>
     1c1:	48 c7 c6 64 46 00 00 	mov    $0x4664,%rsi
     1c8:	89 c7                	mov    %eax,%edi
     1ca:	b8 00 00 00 00       	mov    $0x0,%eax
     1cf:	e8 6e 3d 00 00       	callq  3f42 <printf>
  close(fd);
     1d4:	8b 45 f8             	mov    -0x8(%rbp),%eax
     1d7:	89 c7                	mov    %eax,%edi
     1d9:	e8 03 3c 00 00       	callq  3de1 <close>
  fd = open("small", O_RDONLY);
     1de:	be 00 00 00 00       	mov    $0x0,%esi
     1e3:	48 c7 c7 c6 45 00 00 	mov    $0x45c6,%rdi
     1ea:	e8 0a 3c 00 00       	callq  3df9 <open>
     1ef:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(fd >= 0){
     1f2:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
     1f6:	78 3d                	js     235 <writetest+0x17e>
    printf(stdout, "open small succeeded ok\n");
     1f8:	8b 05 ea 60 00 00    	mov    0x60ea(%rip),%eax        # 62e8 <stdout>
     1fe:	48 c7 c6 6f 46 00 00 	mov    $0x466f,%rsi
     205:	89 c7                	mov    %eax,%edi
     207:	b8 00 00 00 00       	mov    $0x0,%eax
     20c:	e8 31 3d 00 00       	callq  3f42 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     211:	8b 45 f8             	mov    -0x8(%rbp),%eax
     214:	ba d0 07 00 00       	mov    $0x7d0,%edx
     219:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     220:	89 c7                	mov    %eax,%edi
     222:	e8 aa 3b 00 00       	callq  3dd1 <read>
     227:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(i == 2000){
     22a:	81 7d fc d0 07 00 00 	cmpl   $0x7d0,-0x4(%rbp)
     231:	75 55                	jne    288 <writetest+0x1d1>
     233:	eb 1e                	jmp    253 <writetest+0x19c>
    printf(stdout, "error: open small failed!\n");
     235:	8b 05 ad 60 00 00    	mov    0x60ad(%rip),%eax        # 62e8 <stdout>
     23b:	48 c7 c6 88 46 00 00 	mov    $0x4688,%rsi
     242:	89 c7                	mov    %eax,%edi
     244:	b8 00 00 00 00       	mov    $0x0,%eax
     249:	e8 f4 3c 00 00       	callq  3f42 <printf>
    exit();
     24e:	e8 66 3b 00 00       	callq  3db9 <exit>
    printf(stdout, "read succeeded ok\n");
     253:	8b 05 8f 60 00 00    	mov    0x608f(%rip),%eax        # 62e8 <stdout>
     259:	48 c7 c6 a3 46 00 00 	mov    $0x46a3,%rsi
     260:	89 c7                	mov    %eax,%edi
     262:	b8 00 00 00 00       	mov    $0x0,%eax
     267:	e8 d6 3c 00 00       	callq  3f42 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     26c:	8b 45 f8             	mov    -0x8(%rbp),%eax
     26f:	89 c7                	mov    %eax,%edi
     271:	e8 6b 3b 00 00       	callq  3de1 <close>

  if(unlink("small") < 0){
     276:	48 c7 c7 c6 45 00 00 	mov    $0x45c6,%rdi
     27d:	e8 87 3b 00 00       	callq  3e09 <unlink>
     282:	85 c0                	test   %eax,%eax
     284:	79 3e                	jns    2c4 <writetest+0x20d>
     286:	eb 1e                	jmp    2a6 <writetest+0x1ef>
    printf(stdout, "read failed\n");
     288:	8b 05 5a 60 00 00    	mov    0x605a(%rip),%eax        # 62e8 <stdout>
     28e:	48 c7 c6 b6 46 00 00 	mov    $0x46b6,%rsi
     295:	89 c7                	mov    %eax,%edi
     297:	b8 00 00 00 00       	mov    $0x0,%eax
     29c:	e8 a1 3c 00 00       	callq  3f42 <printf>
    exit();
     2a1:	e8 13 3b 00 00       	callq  3db9 <exit>
    printf(stdout, "unlink small failed\n");
     2a6:	8b 05 3c 60 00 00    	mov    0x603c(%rip),%eax        # 62e8 <stdout>
     2ac:	48 c7 c6 c3 46 00 00 	mov    $0x46c3,%rsi
     2b3:	89 c7                	mov    %eax,%edi
     2b5:	b8 00 00 00 00       	mov    $0x0,%eax
     2ba:	e8 83 3c 00 00       	callq  3f42 <printf>
    exit();
     2bf:	e8 f5 3a 00 00       	callq  3db9 <exit>
  }
  printf(stdout, "small file test ok\n");
     2c4:	8b 05 1e 60 00 00    	mov    0x601e(%rip),%eax        # 62e8 <stdout>
     2ca:	48 c7 c6 d8 46 00 00 	mov    $0x46d8,%rsi
     2d1:	89 c7                	mov    %eax,%edi
     2d3:	b8 00 00 00 00       	mov    $0x0,%eax
     2d8:	e8 65 3c 00 00       	callq  3f42 <printf>
}
     2dd:	90                   	nop
     2de:	c9                   	leaveq 
     2df:	c3                   	retq   

00000000000002e0 <writetest1>:

void
writetest1(void)
{
     2e0:	55                   	push   %rbp
     2e1:	48 89 e5             	mov    %rsp,%rbp
     2e4:	48 83 ec 10          	sub    $0x10,%rsp
  int i, fd, n;

  printf(stdout, "big files test\n");
     2e8:	8b 05 fa 5f 00 00    	mov    0x5ffa(%rip),%eax        # 62e8 <stdout>
     2ee:	48 c7 c6 ec 46 00 00 	mov    $0x46ec,%rsi
     2f5:	89 c7                	mov    %eax,%edi
     2f7:	b8 00 00 00 00       	mov    $0x0,%eax
     2fc:	e8 41 3c 00 00       	callq  3f42 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     301:	be 02 02 00 00       	mov    $0x202,%esi
     306:	48 c7 c7 fc 46 00 00 	mov    $0x46fc,%rdi
     30d:	e8 e7 3a 00 00       	callq  3df9 <open>
     312:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(fd < 0){
     315:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
     319:	79 1e                	jns    339 <writetest1+0x59>
    printf(stdout, "error: creat big failed!\n");
     31b:	8b 05 c7 5f 00 00    	mov    0x5fc7(%rip),%eax        # 62e8 <stdout>
     321:	48 c7 c6 00 47 00 00 	mov    $0x4700,%rsi
     328:	89 c7                	mov    %eax,%edi
     32a:	b8 00 00 00 00       	mov    $0x0,%eax
     32f:	e8 0e 3c 00 00       	callq  3f42 <printf>
    exit();
     334:	e8 80 3a 00 00       	callq  3db9 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     339:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     340:	eb 4e                	jmp    390 <writetest1+0xb0>
    ((int*)buf)[0] = i;
     342:	48 c7 c2 20 63 00 00 	mov    $0x6320,%rdx
     349:	8b 45 fc             	mov    -0x4(%rbp),%eax
     34c:	89 02                	mov    %eax,(%rdx)
    if(write(fd, buf, 512) != 512){
     34e:	8b 45 f4             	mov    -0xc(%rbp),%eax
     351:	ba 00 02 00 00       	mov    $0x200,%edx
     356:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     35d:	89 c7                	mov    %eax,%edi
     35f:	e8 75 3a 00 00       	callq  3dd9 <write>
     364:	3d 00 02 00 00       	cmp    $0x200,%eax
     369:	74 21                	je     38c <writetest1+0xac>
      printf(stdout, "error: write big file failed\n", i);
     36b:	8b 05 77 5f 00 00    	mov    0x5f77(%rip),%eax        # 62e8 <stdout>
     371:	8b 55 fc             	mov    -0x4(%rbp),%edx
     374:	48 c7 c6 1a 47 00 00 	mov    $0x471a,%rsi
     37b:	89 c7                	mov    %eax,%edi
     37d:	b8 00 00 00 00       	mov    $0x0,%eax
     382:	e8 bb 3b 00 00       	callq  3f42 <printf>
      exit();
     387:	e8 2d 3a 00 00       	callq  3db9 <exit>
  for(i = 0; i < MAXFILE; i++){
     38c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     390:	8b 45 fc             	mov    -0x4(%rbp),%eax
     393:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     398:	76 a8                	jbe    342 <writetest1+0x62>
    }
  }

  close(fd);
     39a:	8b 45 f4             	mov    -0xc(%rbp),%eax
     39d:	89 c7                	mov    %eax,%edi
     39f:	e8 3d 3a 00 00       	callq  3de1 <close>

  fd = open("big", O_RDONLY);
     3a4:	be 00 00 00 00       	mov    $0x0,%esi
     3a9:	48 c7 c7 fc 46 00 00 	mov    $0x46fc,%rdi
     3b0:	e8 44 3a 00 00       	callq  3df9 <open>
     3b5:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(fd < 0){
     3b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
     3bc:	79 1e                	jns    3dc <writetest1+0xfc>
    printf(stdout, "error: open big failed!\n");
     3be:	8b 05 24 5f 00 00    	mov    0x5f24(%rip),%eax        # 62e8 <stdout>
     3c4:	48 c7 c6 38 47 00 00 	mov    $0x4738,%rsi
     3cb:	89 c7                	mov    %eax,%edi
     3cd:	b8 00 00 00 00       	mov    $0x0,%eax
     3d2:	e8 6b 3b 00 00       	callq  3f42 <printf>
    exit();
     3d7:	e8 dd 39 00 00       	callq  3db9 <exit>
  }

  n = 0;
     3dc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  for(;;){
    i = read(fd, buf, 512);
     3e3:	8b 45 f4             	mov    -0xc(%rbp),%eax
     3e6:	ba 00 02 00 00       	mov    $0x200,%edx
     3eb:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     3f2:	89 c7                	mov    %eax,%edi
     3f4:	e8 d8 39 00 00       	callq  3dd1 <read>
     3f9:	89 45 fc             	mov    %eax,-0x4(%rbp)
    if(i == 0){
     3fc:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
     400:	75 2e                	jne    430 <writetest1+0x150>
      if(n == MAXFILE - 1){
     402:	81 7d f8 8b 00 00 00 	cmpl   $0x8b,-0x8(%rbp)
     409:	0f 85 8c 00 00 00    	jne    49b <writetest1+0x1bb>
        printf(stdout, "read only %d blocks from big", n);
     40f:	8b 05 d3 5e 00 00    	mov    0x5ed3(%rip),%eax        # 62e8 <stdout>
     415:	8b 55 f8             	mov    -0x8(%rbp),%edx
     418:	48 c7 c6 51 47 00 00 	mov    $0x4751,%rsi
     41f:	89 c7                	mov    %eax,%edi
     421:	b8 00 00 00 00       	mov    $0x0,%eax
     426:	e8 17 3b 00 00       	callq  3f42 <printf>
        exit();
     42b:	e8 89 39 00 00       	callq  3db9 <exit>
      }
      break;
    } else if(i != 512){
     430:	81 7d fc 00 02 00 00 	cmpl   $0x200,-0x4(%rbp)
     437:	74 21                	je     45a <writetest1+0x17a>
      printf(stdout, "read failed %d\n", i);
     439:	8b 05 a9 5e 00 00    	mov    0x5ea9(%rip),%eax        # 62e8 <stdout>
     43f:	8b 55 fc             	mov    -0x4(%rbp),%edx
     442:	48 c7 c6 6e 47 00 00 	mov    $0x476e,%rsi
     449:	89 c7                	mov    %eax,%edi
     44b:	b8 00 00 00 00       	mov    $0x0,%eax
     450:	e8 ed 3a 00 00       	callq  3f42 <printf>
      exit();
     455:	e8 5f 39 00 00       	callq  3db9 <exit>
    }
    if(((int*)buf)[0] != n){
     45a:	48 c7 c0 20 63 00 00 	mov    $0x6320,%rax
     461:	8b 00                	mov    (%rax),%eax
     463:	39 45 f8             	cmp    %eax,-0x8(%rbp)
     466:	74 2a                	je     492 <writetest1+0x1b2>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     468:	48 c7 c0 20 63 00 00 	mov    $0x6320,%rax
      printf(stdout, "read content of block %d is %d\n",
     46f:	8b 08                	mov    (%rax),%ecx
     471:	8b 05 71 5e 00 00    	mov    0x5e71(%rip),%eax        # 62e8 <stdout>
     477:	8b 55 f8             	mov    -0x8(%rbp),%edx
     47a:	48 c7 c6 80 47 00 00 	mov    $0x4780,%rsi
     481:	89 c7                	mov    %eax,%edi
     483:	b8 00 00 00 00       	mov    $0x0,%eax
     488:	e8 b5 3a 00 00       	callq  3f42 <printf>
      exit();
     48d:	e8 27 39 00 00       	callq  3db9 <exit>
    }
    n++;
     492:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
    i = read(fd, buf, 512);
     496:	e9 48 ff ff ff       	jmpq   3e3 <writetest1+0x103>
      break;
     49b:	90                   	nop
  }
  close(fd);
     49c:	8b 45 f4             	mov    -0xc(%rbp),%eax
     49f:	89 c7                	mov    %eax,%edi
     4a1:	e8 3b 39 00 00       	callq  3de1 <close>
  if(unlink("big") < 0){
     4a6:	48 c7 c7 fc 46 00 00 	mov    $0x46fc,%rdi
     4ad:	e8 57 39 00 00       	callq  3e09 <unlink>
     4b2:	85 c0                	test   %eax,%eax
     4b4:	79 1e                	jns    4d4 <writetest1+0x1f4>
    printf(stdout, "unlink big failed\n");
     4b6:	8b 05 2c 5e 00 00    	mov    0x5e2c(%rip),%eax        # 62e8 <stdout>
     4bc:	48 c7 c6 a0 47 00 00 	mov    $0x47a0,%rsi
     4c3:	89 c7                	mov    %eax,%edi
     4c5:	b8 00 00 00 00       	mov    $0x0,%eax
     4ca:	e8 73 3a 00 00       	callq  3f42 <printf>
    exit();
     4cf:	e8 e5 38 00 00       	callq  3db9 <exit>
  }
  printf(stdout, "big files ok\n");
     4d4:	8b 05 0e 5e 00 00    	mov    0x5e0e(%rip),%eax        # 62e8 <stdout>
     4da:	48 c7 c6 b3 47 00 00 	mov    $0x47b3,%rsi
     4e1:	89 c7                	mov    %eax,%edi
     4e3:	b8 00 00 00 00       	mov    $0x0,%eax
     4e8:	e8 55 3a 00 00       	callq  3f42 <printf>
}
     4ed:	90                   	nop
     4ee:	c9                   	leaveq 
     4ef:	c3                   	retq   

00000000000004f0 <createtest>:

void
createtest(void)
{
     4f0:	55                   	push   %rbp
     4f1:	48 89 e5             	mov    %rsp,%rbp
     4f4:	48 83 ec 10          	sub    $0x10,%rsp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     4f8:	8b 05 ea 5d 00 00    	mov    0x5dea(%rip),%eax        # 62e8 <stdout>
     4fe:	48 c7 c6 c8 47 00 00 	mov    $0x47c8,%rsi
     505:	89 c7                	mov    %eax,%edi
     507:	b8 00 00 00 00       	mov    $0x0,%eax
     50c:	e8 31 3a 00 00       	callq  3f42 <printf>

  name[0] = 'a';
     511:	c6 05 08 7e 00 00 61 	movb   $0x61,0x7e08(%rip)        # 8320 <name>
  name[2] = '\0';
     518:	c6 05 03 7e 00 00 00 	movb   $0x0,0x7e03(%rip)        # 8322 <name+0x2>
  for(i = 0; i < 52; i++){
     51f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     526:	eb 2e                	jmp    556 <createtest+0x66>
    name[1] = '0' + i;
     528:	8b 45 fc             	mov    -0x4(%rbp),%eax
     52b:	83 c0 30             	add    $0x30,%eax
     52e:	88 05 ed 7d 00 00    	mov    %al,0x7ded(%rip)        # 8321 <name+0x1>
    fd = open(name, O_CREATE|O_RDWR);
     534:	be 02 02 00 00       	mov    $0x202,%esi
     539:	48 c7 c7 20 83 00 00 	mov    $0x8320,%rdi
     540:	e8 b4 38 00 00       	callq  3df9 <open>
     545:	89 45 f8             	mov    %eax,-0x8(%rbp)
    close(fd);
     548:	8b 45 f8             	mov    -0x8(%rbp),%eax
     54b:	89 c7                	mov    %eax,%edi
     54d:	e8 8f 38 00 00       	callq  3de1 <close>
  for(i = 0; i < 52; i++){
     552:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     556:	83 7d fc 33          	cmpl   $0x33,-0x4(%rbp)
     55a:	7e cc                	jle    528 <createtest+0x38>
  }
  name[0] = 'a';
     55c:	c6 05 bd 7d 00 00 61 	movb   $0x61,0x7dbd(%rip)        # 8320 <name>
  name[2] = '\0';
     563:	c6 05 b8 7d 00 00 00 	movb   $0x0,0x7db8(%rip)        # 8322 <name+0x2>
  for(i = 0; i < 52; i++){
     56a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     571:	eb 1c                	jmp    58f <createtest+0x9f>
    name[1] = '0' + i;
     573:	8b 45 fc             	mov    -0x4(%rbp),%eax
     576:	83 c0 30             	add    $0x30,%eax
     579:	88 05 a2 7d 00 00    	mov    %al,0x7da2(%rip)        # 8321 <name+0x1>
    unlink(name);
     57f:	48 c7 c7 20 83 00 00 	mov    $0x8320,%rdi
     586:	e8 7e 38 00 00       	callq  3e09 <unlink>
  for(i = 0; i < 52; i++){
     58b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     58f:	83 7d fc 33          	cmpl   $0x33,-0x4(%rbp)
     593:	7e de                	jle    573 <createtest+0x83>
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     595:	8b 05 4d 5d 00 00    	mov    0x5d4d(%rip),%eax        # 62e8 <stdout>
     59b:	48 c7 c6 f0 47 00 00 	mov    $0x47f0,%rsi
     5a2:	89 c7                	mov    %eax,%edi
     5a4:	b8 00 00 00 00       	mov    $0x0,%eax
     5a9:	e8 94 39 00 00       	callq  3f42 <printf>
}
     5ae:	90                   	nop
     5af:	c9                   	leaveq 
     5b0:	c3                   	retq   

00000000000005b1 <dirtest>:

void dirtest(void)
{
     5b1:	55                   	push   %rbp
     5b2:	48 89 e5             	mov    %rsp,%rbp
  printf(stdout, "mkdir test\n");
     5b5:	8b 05 2d 5d 00 00    	mov    0x5d2d(%rip),%eax        # 62e8 <stdout>
     5bb:	48 c7 c6 16 48 00 00 	mov    $0x4816,%rsi
     5c2:	89 c7                	mov    %eax,%edi
     5c4:	b8 00 00 00 00       	mov    $0x0,%eax
     5c9:	e8 74 39 00 00       	callq  3f42 <printf>

  if(mkdir("dir0") < 0){
     5ce:	48 c7 c7 22 48 00 00 	mov    $0x4822,%rdi
     5d5:	e8 47 38 00 00       	callq  3e21 <mkdir>
     5da:	85 c0                	test   %eax,%eax
     5dc:	79 1e                	jns    5fc <dirtest+0x4b>
    printf(stdout, "mkdir failed\n");
     5de:	8b 05 04 5d 00 00    	mov    0x5d04(%rip),%eax        # 62e8 <stdout>
     5e4:	48 c7 c6 27 48 00 00 	mov    $0x4827,%rsi
     5eb:	89 c7                	mov    %eax,%edi
     5ed:	b8 00 00 00 00       	mov    $0x0,%eax
     5f2:	e8 4b 39 00 00       	callq  3f42 <printf>
    exit();
     5f7:	e8 bd 37 00 00       	callq  3db9 <exit>
  }

  if(chdir("dir0") < 0){
     5fc:	48 c7 c7 22 48 00 00 	mov    $0x4822,%rdi
     603:	e8 21 38 00 00       	callq  3e29 <chdir>
     608:	85 c0                	test   %eax,%eax
     60a:	79 1e                	jns    62a <dirtest+0x79>
    printf(stdout, "chdir dir0 failed\n");
     60c:	8b 05 d6 5c 00 00    	mov    0x5cd6(%rip),%eax        # 62e8 <stdout>
     612:	48 c7 c6 35 48 00 00 	mov    $0x4835,%rsi
     619:	89 c7                	mov    %eax,%edi
     61b:	b8 00 00 00 00       	mov    $0x0,%eax
     620:	e8 1d 39 00 00       	callq  3f42 <printf>
    exit();
     625:	e8 8f 37 00 00       	callq  3db9 <exit>
  }

  if(chdir("..") < 0){
     62a:	48 c7 c7 48 48 00 00 	mov    $0x4848,%rdi
     631:	e8 f3 37 00 00       	callq  3e29 <chdir>
     636:	85 c0                	test   %eax,%eax
     638:	79 1e                	jns    658 <dirtest+0xa7>
    printf(stdout, "chdir .. failed\n");
     63a:	8b 05 a8 5c 00 00    	mov    0x5ca8(%rip),%eax        # 62e8 <stdout>
     640:	48 c7 c6 4b 48 00 00 	mov    $0x484b,%rsi
     647:	89 c7                	mov    %eax,%edi
     649:	b8 00 00 00 00       	mov    $0x0,%eax
     64e:	e8 ef 38 00 00       	callq  3f42 <printf>
    exit();
     653:	e8 61 37 00 00       	callq  3db9 <exit>
  }

  if(unlink("dir0") < 0){
     658:	48 c7 c7 22 48 00 00 	mov    $0x4822,%rdi
     65f:	e8 a5 37 00 00       	callq  3e09 <unlink>
     664:	85 c0                	test   %eax,%eax
     666:	79 1e                	jns    686 <dirtest+0xd5>
    printf(stdout, "unlink dir0 failed\n");
     668:	8b 05 7a 5c 00 00    	mov    0x5c7a(%rip),%eax        # 62e8 <stdout>
     66e:	48 c7 c6 5c 48 00 00 	mov    $0x485c,%rsi
     675:	89 c7                	mov    %eax,%edi
     677:	b8 00 00 00 00       	mov    $0x0,%eax
     67c:	e8 c1 38 00 00       	callq  3f42 <printf>
    exit();
     681:	e8 33 37 00 00       	callq  3db9 <exit>
  }
  printf(stdout, "mkdir test\n");
     686:	8b 05 5c 5c 00 00    	mov    0x5c5c(%rip),%eax        # 62e8 <stdout>
     68c:	48 c7 c6 16 48 00 00 	mov    $0x4816,%rsi
     693:	89 c7                	mov    %eax,%edi
     695:	b8 00 00 00 00       	mov    $0x0,%eax
     69a:	e8 a3 38 00 00       	callq  3f42 <printf>
}
     69f:	90                   	nop
     6a0:	5d                   	pop    %rbp
     6a1:	c3                   	retq   

00000000000006a2 <exectest>:

void
exectest(void)
{
     6a2:	55                   	push   %rbp
     6a3:	48 89 e5             	mov    %rsp,%rbp
  printf(stdout, "exec test\n");
     6a6:	8b 05 3c 5c 00 00    	mov    0x5c3c(%rip),%eax        # 62e8 <stdout>
     6ac:	48 c7 c6 70 48 00 00 	mov    $0x4870,%rsi
     6b3:	89 c7                	mov    %eax,%edi
     6b5:	b8 00 00 00 00       	mov    $0x0,%eax
     6ba:	e8 83 38 00 00       	callq  3f42 <printf>
  if(exec("echo", echoargv) < 0){
     6bf:	48 c7 c6 c0 62 00 00 	mov    $0x62c0,%rsi
     6c6:	48 c7 c7 48 45 00 00 	mov    $0x4548,%rdi
     6cd:	e8 1f 37 00 00       	callq  3df1 <exec>
     6d2:	85 c0                	test   %eax,%eax
     6d4:	79 1e                	jns    6f4 <exectest+0x52>
    printf(stdout, "exec echo failed\n");
     6d6:	8b 05 0c 5c 00 00    	mov    0x5c0c(%rip),%eax        # 62e8 <stdout>
     6dc:	48 c7 c6 7b 48 00 00 	mov    $0x487b,%rsi
     6e3:	89 c7                	mov    %eax,%edi
     6e5:	b8 00 00 00 00       	mov    $0x0,%eax
     6ea:	e8 53 38 00 00       	callq  3f42 <printf>
    exit();
     6ef:	e8 c5 36 00 00       	callq  3db9 <exit>
  }
}
     6f4:	90                   	nop
     6f5:	5d                   	pop    %rbp
     6f6:	c3                   	retq   

00000000000006f7 <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     6f7:	55                   	push   %rbp
     6f8:	48 89 e5             	mov    %rsp,%rbp
     6fb:	48 83 ec 20          	sub    $0x20,%rsp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     6ff:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
     703:	48 89 c7             	mov    %rax,%rdi
     706:	e8 be 36 00 00       	callq  3dc9 <pipe>
     70b:	85 c0                	test   %eax,%eax
     70d:	74 1b                	je     72a <pipe1+0x33>
    printf(1, "pipe() failed\n");
     70f:	48 c7 c6 8d 48 00 00 	mov    $0x488d,%rsi
     716:	bf 01 00 00 00       	mov    $0x1,%edi
     71b:	b8 00 00 00 00       	mov    $0x0,%eax
     720:	e8 1d 38 00 00       	callq  3f42 <printf>
    exit();
     725:	e8 8f 36 00 00       	callq  3db9 <exit>
  }
  pid = fork();
     72a:	e8 82 36 00 00       	callq  3db1 <fork>
     72f:	89 45 e8             	mov    %eax,-0x18(%rbp)
  seq = 0;
     732:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  if(pid == 0){
     739:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
     73d:	0f 85 86 00 00 00    	jne    7c9 <pipe1+0xd2>
    close(fds[0]);
     743:	8b 45 e0             	mov    -0x20(%rbp),%eax
     746:	89 c7                	mov    %eax,%edi
     748:	e8 94 36 00 00       	callq  3de1 <close>
    for(n = 0; n < 5; n++){
     74d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
     754:	eb 68                	jmp    7be <pipe1+0xc7>
      for(i = 0; i < 1033; i++)
     756:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
     75d:	eb 1a                	jmp    779 <pipe1+0x82>
        buf[i] = seq++;
     75f:	8b 45 fc             	mov    -0x4(%rbp),%eax
     762:	8d 50 01             	lea    0x1(%rax),%edx
     765:	89 55 fc             	mov    %edx,-0x4(%rbp)
     768:	89 c2                	mov    %eax,%edx
     76a:	8b 45 f8             	mov    -0x8(%rbp),%eax
     76d:	48 98                	cltq   
     76f:	88 90 20 63 00 00    	mov    %dl,0x6320(%rax)
      for(i = 0; i < 1033; i++)
     775:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
     779:	81 7d f8 08 04 00 00 	cmpl   $0x408,-0x8(%rbp)
     780:	7e dd                	jle    75f <pipe1+0x68>
      if(write(fds[1], buf, 1033) != 1033){
     782:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     785:	ba 09 04 00 00       	mov    $0x409,%edx
     78a:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     791:	89 c7                	mov    %eax,%edi
     793:	e8 41 36 00 00       	callq  3dd9 <write>
     798:	3d 09 04 00 00       	cmp    $0x409,%eax
     79d:	74 1b                	je     7ba <pipe1+0xc3>
        printf(1, "pipe1 oops 1\n");
     79f:	48 c7 c6 9c 48 00 00 	mov    $0x489c,%rsi
     7a6:	bf 01 00 00 00       	mov    $0x1,%edi
     7ab:	b8 00 00 00 00       	mov    $0x0,%eax
     7b0:	e8 8d 37 00 00       	callq  3f42 <printf>
        exit();
     7b5:	e8 ff 35 00 00       	callq  3db9 <exit>
    for(n = 0; n < 5; n++){
     7ba:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
     7be:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
     7c2:	7e 92                	jle    756 <pipe1+0x5f>
      }
    }
    exit();
     7c4:	e8 f0 35 00 00       	callq  3db9 <exit>
  } else if(pid > 0){
     7c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
     7cd:	0f 8e f6 00 00 00    	jle    8c9 <pipe1+0x1d2>
    close(fds[1]);
     7d3:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     7d6:	89 c7                	mov    %eax,%edi
     7d8:	e8 04 36 00 00       	callq  3de1 <close>
    total = 0;
     7dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    cc = 1;
     7e4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%rbp)
    while((n = read(fds[0], buf, cc)) > 0){
     7eb:	eb 6b                	jmp    858 <pipe1+0x161>
      for(i = 0; i < n; i++){
     7ed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
     7f4:	eb 40                	jmp    836 <pipe1+0x13f>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     7f6:	8b 45 f8             	mov    -0x8(%rbp),%eax
     7f9:	48 98                	cltq   
     7fb:	0f b6 80 20 63 00 00 	movzbl 0x6320(%rax),%eax
     802:	0f be c8             	movsbl %al,%ecx
     805:	8b 45 fc             	mov    -0x4(%rbp),%eax
     808:	8d 50 01             	lea    0x1(%rax),%edx
     80b:	89 55 fc             	mov    %edx,-0x4(%rbp)
     80e:	31 c8                	xor    %ecx,%eax
     810:	0f b6 c0             	movzbl %al,%eax
     813:	85 c0                	test   %eax,%eax
     815:	74 1b                	je     832 <pipe1+0x13b>
          printf(1, "pipe1 oops 2\n");
     817:	48 c7 c6 aa 48 00 00 	mov    $0x48aa,%rsi
     81e:	bf 01 00 00 00       	mov    $0x1,%edi
     823:	b8 00 00 00 00       	mov    $0x0,%eax
     828:	e8 15 37 00 00       	callq  3f42 <printf>
     82d:	e9 b2 00 00 00       	jmpq   8e4 <pipe1+0x1ed>
      for(i = 0; i < n; i++){
     832:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
     836:	8b 45 f8             	mov    -0x8(%rbp),%eax
     839:	3b 45 f4             	cmp    -0xc(%rbp),%eax
     83c:	7c b8                	jl     7f6 <pipe1+0xff>
          return;
        }
      }
      total += n;
     83e:	8b 45 f4             	mov    -0xc(%rbp),%eax
     841:	01 45 ec             	add    %eax,-0x14(%rbp)
      cc = cc * 2;
     844:	d1 65 f0             	shll   -0x10(%rbp)
      if(cc > sizeof(buf))
     847:	8b 45 f0             	mov    -0x10(%rbp),%eax
     84a:	3d 00 20 00 00       	cmp    $0x2000,%eax
     84f:	76 07                	jbe    858 <pipe1+0x161>
        cc = sizeof(buf);
     851:	c7 45 f0 00 20 00 00 	movl   $0x2000,-0x10(%rbp)
    while((n = read(fds[0], buf, cc)) > 0){
     858:	8b 45 e0             	mov    -0x20(%rbp),%eax
     85b:	8b 55 f0             	mov    -0x10(%rbp),%edx
     85e:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     865:	89 c7                	mov    %eax,%edi
     867:	e8 65 35 00 00       	callq  3dd1 <read>
     86c:	89 45 f4             	mov    %eax,-0xc(%rbp)
     86f:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
     873:	0f 8f 74 ff ff ff    	jg     7ed <pipe1+0xf6>
    }
    if(total != 5 * 1033){
     879:	81 7d ec 2d 14 00 00 	cmpl   $0x142d,-0x14(%rbp)
     880:	74 20                	je     8a2 <pipe1+0x1ab>
      printf(1, "pipe1 oops 3 total %d\n", total);
     882:	8b 45 ec             	mov    -0x14(%rbp),%eax
     885:	89 c2                	mov    %eax,%edx
     887:	48 c7 c6 b8 48 00 00 	mov    $0x48b8,%rsi
     88e:	bf 01 00 00 00       	mov    $0x1,%edi
     893:	b8 00 00 00 00       	mov    $0x0,%eax
     898:	e8 a5 36 00 00       	callq  3f42 <printf>
      exit();
     89d:	e8 17 35 00 00       	callq  3db9 <exit>
    }
    close(fds[0]);
     8a2:	8b 45 e0             	mov    -0x20(%rbp),%eax
     8a5:	89 c7                	mov    %eax,%edi
     8a7:	e8 35 35 00 00       	callq  3de1 <close>
    wait();
     8ac:	e8 10 35 00 00       	callq  3dc1 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     8b1:	48 c7 c6 de 48 00 00 	mov    $0x48de,%rsi
     8b8:	bf 01 00 00 00       	mov    $0x1,%edi
     8bd:	b8 00 00 00 00       	mov    $0x0,%eax
     8c2:	e8 7b 36 00 00       	callq  3f42 <printf>
     8c7:	eb 1b                	jmp    8e4 <pipe1+0x1ed>
    printf(1, "fork() failed\n");
     8c9:	48 c7 c6 cf 48 00 00 	mov    $0x48cf,%rsi
     8d0:	bf 01 00 00 00       	mov    $0x1,%edi
     8d5:	b8 00 00 00 00       	mov    $0x0,%eax
     8da:	e8 63 36 00 00       	callq  3f42 <printf>
    exit();
     8df:	e8 d5 34 00 00       	callq  3db9 <exit>
}
     8e4:	c9                   	leaveq 
     8e5:	c3                   	retq   

00000000000008e6 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     8e6:	55                   	push   %rbp
     8e7:	48 89 e5             	mov    %rsp,%rbp
     8ea:	48 83 ec 20          	sub    $0x20,%rsp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     8ee:	48 c7 c6 e8 48 00 00 	mov    $0x48e8,%rsi
     8f5:	bf 01 00 00 00       	mov    $0x1,%edi
     8fa:	b8 00 00 00 00       	mov    $0x0,%eax
     8ff:	e8 3e 36 00 00       	callq  3f42 <printf>
  pid1 = fork();
     904:	e8 a8 34 00 00       	callq  3db1 <fork>
     909:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(pid1 == 0)
     90c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
     910:	75 02                	jne    914 <preempt+0x2e>
    for(;;)
     912:	eb fe                	jmp    912 <preempt+0x2c>
      ;

  pid2 = fork();
     914:	e8 98 34 00 00       	callq  3db1 <fork>
     919:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(pid2 == 0)
     91c:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
     920:	75 02                	jne    924 <preempt+0x3e>
    for(;;)
     922:	eb fe                	jmp    922 <preempt+0x3c>
      ;

  pipe(pfds);
     924:	48 8d 45 ec          	lea    -0x14(%rbp),%rax
     928:	48 89 c7             	mov    %rax,%rdi
     92b:	e8 99 34 00 00       	callq  3dc9 <pipe>
  pid3 = fork();
     930:	e8 7c 34 00 00       	callq  3db1 <fork>
     935:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(pid3 == 0){
     938:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
     93c:	75 47                	jne    985 <preempt+0x9f>
    close(pfds[0]);
     93e:	8b 45 ec             	mov    -0x14(%rbp),%eax
     941:	89 c7                	mov    %eax,%edi
     943:	e8 99 34 00 00       	callq  3de1 <close>
    if(write(pfds[1], "x", 1) != 1)
     948:	8b 45 f0             	mov    -0x10(%rbp),%eax
     94b:	ba 01 00 00 00       	mov    $0x1,%edx
     950:	48 c7 c6 f2 48 00 00 	mov    $0x48f2,%rsi
     957:	89 c7                	mov    %eax,%edi
     959:	e8 7b 34 00 00       	callq  3dd9 <write>
     95e:	83 f8 01             	cmp    $0x1,%eax
     961:	74 16                	je     979 <preempt+0x93>
      printf(1, "preempt write error");
     963:	48 c7 c6 f4 48 00 00 	mov    $0x48f4,%rsi
     96a:	bf 01 00 00 00       	mov    $0x1,%edi
     96f:	b8 00 00 00 00       	mov    $0x0,%eax
     974:	e8 c9 35 00 00       	callq  3f42 <printf>
    close(pfds[1]);
     979:	8b 45 f0             	mov    -0x10(%rbp),%eax
     97c:	89 c7                	mov    %eax,%edi
     97e:	e8 5e 34 00 00       	callq  3de1 <close>
    for(;;)
     983:	eb fe                	jmp    983 <preempt+0x9d>
      ;
  }

  close(pfds[1]);
     985:	8b 45 f0             	mov    -0x10(%rbp),%eax
     988:	89 c7                	mov    %eax,%edi
     98a:	e8 52 34 00 00       	callq  3de1 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     98f:	8b 45 ec             	mov    -0x14(%rbp),%eax
     992:	ba 00 20 00 00       	mov    $0x2000,%edx
     997:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     99e:	89 c7                	mov    %eax,%edi
     9a0:	e8 2c 34 00 00       	callq  3dd1 <read>
     9a5:	83 f8 01             	cmp    $0x1,%eax
     9a8:	74 18                	je     9c2 <preempt+0xdc>
    printf(1, "preempt read error");
     9aa:	48 c7 c6 08 49 00 00 	mov    $0x4908,%rsi
     9b1:	bf 01 00 00 00       	mov    $0x1,%edi
     9b6:	b8 00 00 00 00       	mov    $0x0,%eax
     9bb:	e8 82 35 00 00       	callq  3f42 <printf>
     9c0:	eb 79                	jmp    a3b <preempt+0x155>
    return;
  }
  close(pfds[0]);
     9c2:	8b 45 ec             	mov    -0x14(%rbp),%eax
     9c5:	89 c7                	mov    %eax,%edi
     9c7:	e8 15 34 00 00       	callq  3de1 <close>
  printf(1, "kill... ");
     9cc:	48 c7 c6 1b 49 00 00 	mov    $0x491b,%rsi
     9d3:	bf 01 00 00 00       	mov    $0x1,%edi
     9d8:	b8 00 00 00 00       	mov    $0x0,%eax
     9dd:	e8 60 35 00 00       	callq  3f42 <printf>
  kill(pid1);
     9e2:	8b 45 fc             	mov    -0x4(%rbp),%eax
     9e5:	89 c7                	mov    %eax,%edi
     9e7:	e8 fd 33 00 00       	callq  3de9 <kill>
  kill(pid2);
     9ec:	8b 45 f8             	mov    -0x8(%rbp),%eax
     9ef:	89 c7                	mov    %eax,%edi
     9f1:	e8 f3 33 00 00       	callq  3de9 <kill>
  kill(pid3);
     9f6:	8b 45 f4             	mov    -0xc(%rbp),%eax
     9f9:	89 c7                	mov    %eax,%edi
     9fb:	e8 e9 33 00 00       	callq  3de9 <kill>
  printf(1, "wait... ");
     a00:	48 c7 c6 24 49 00 00 	mov    $0x4924,%rsi
     a07:	bf 01 00 00 00       	mov    $0x1,%edi
     a0c:	b8 00 00 00 00       	mov    $0x0,%eax
     a11:	e8 2c 35 00 00       	callq  3f42 <printf>
  wait();
     a16:	e8 a6 33 00 00       	callq  3dc1 <wait>
  wait();
     a1b:	e8 a1 33 00 00       	callq  3dc1 <wait>
  wait();
     a20:	e8 9c 33 00 00       	callq  3dc1 <wait>
  printf(1, "preempt ok\n");
     a25:	48 c7 c6 2d 49 00 00 	mov    $0x492d,%rsi
     a2c:	bf 01 00 00 00       	mov    $0x1,%edi
     a31:	b8 00 00 00 00       	mov    $0x0,%eax
     a36:	e8 07 35 00 00       	callq  3f42 <printf>
}
     a3b:	c9                   	leaveq 
     a3c:	c3                   	retq   

0000000000000a3d <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     a3d:	55                   	push   %rbp
     a3e:	48 89 e5             	mov    %rsp,%rbp
     a41:	48 83 ec 10          	sub    $0x10,%rsp
  int i, pid;

  for(i = 0; i < 100; i++){
     a45:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     a4c:	eb 57                	jmp    aa5 <exitwait+0x68>
    pid = fork();
     a4e:	e8 5e 33 00 00       	callq  3db1 <fork>
     a53:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(pid < 0){
     a56:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
     a5a:	79 18                	jns    a74 <exitwait+0x37>
      printf(1, "fork failed\n");
     a5c:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
     a63:	bf 01 00 00 00       	mov    $0x1,%edi
     a68:	b8 00 00 00 00       	mov    $0x0,%eax
     a6d:	e8 d0 34 00 00       	callq  3f42 <printf>
      return;
     a72:	eb 4d                	jmp    ac1 <exitwait+0x84>
    }
    if(pid){
     a74:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
     a78:	74 22                	je     a9c <exitwait+0x5f>
      if(wait() != pid){
     a7a:	e8 42 33 00 00       	callq  3dc1 <wait>
     a7f:	39 45 f8             	cmp    %eax,-0x8(%rbp)
     a82:	74 1d                	je     aa1 <exitwait+0x64>
        printf(1, "wait wrong pid\n");
     a84:	48 c7 c6 46 49 00 00 	mov    $0x4946,%rsi
     a8b:	bf 01 00 00 00       	mov    $0x1,%edi
     a90:	b8 00 00 00 00       	mov    $0x0,%eax
     a95:	e8 a8 34 00 00       	callq  3f42 <printf>
        return;
     a9a:	eb 25                	jmp    ac1 <exitwait+0x84>
      }
    } else {
      exit();
     a9c:	e8 18 33 00 00       	callq  3db9 <exit>
  for(i = 0; i < 100; i++){
     aa1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     aa5:	83 7d fc 63          	cmpl   $0x63,-0x4(%rbp)
     aa9:	7e a3                	jle    a4e <exitwait+0x11>
    }
  }
  printf(1, "exitwait ok\n");
     aab:	48 c7 c6 56 49 00 00 	mov    $0x4956,%rsi
     ab2:	bf 01 00 00 00       	mov    $0x1,%edi
     ab7:	b8 00 00 00 00       	mov    $0x0,%eax
     abc:	e8 81 34 00 00       	callq  3f42 <printf>
}
     ac1:	c9                   	leaveq 
     ac2:	c3                   	retq   

0000000000000ac3 <mem>:

void
mem(void)
{
     ac3:	55                   	push   %rbp
     ac4:	48 89 e5             	mov    %rsp,%rbp
     ac7:	48 83 ec 20          	sub    $0x20,%rsp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     acb:	48 c7 c6 63 49 00 00 	mov    $0x4963,%rsi
     ad2:	bf 01 00 00 00       	mov    $0x1,%edi
     ad7:	b8 00 00 00 00       	mov    $0x0,%eax
     adc:	e8 61 34 00 00       	callq  3f42 <printf>
  ppid = getpid();
     ae1:	e8 53 33 00 00       	callq  3e39 <getpid>
     ae6:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if((pid = fork()) == 0){
     ae9:	e8 c3 32 00 00       	callq  3db1 <fork>
     aee:	89 45 f0             	mov    %eax,-0x10(%rbp)
     af1:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     af5:	0f 85 bb 00 00 00    	jne    bb6 <mem+0xf3>
    m1 = 0;
     afb:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
     b02:	00 
    while((m2 = malloc(10001)) != 0){
     b03:	eb 13                	jmp    b18 <mem+0x55>
      *(char**)m2 = m1;
     b05:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b09:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
     b0d:	48 89 10             	mov    %rdx,(%rax)
      m1 = m2;
     b10:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b14:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    while((m2 = malloc(10001)) != 0){
     b18:	bf 11 27 00 00       	mov    $0x2711,%edi
     b1d:	e8 12 39 00 00       	callq  4434 <malloc>
     b22:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
     b26:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
     b2b:	75 d8                	jne    b05 <mem+0x42>
    }
    while(m1){
     b2d:	eb 1f                	jmp    b4e <mem+0x8b>
      m2 = *(char**)m1;
     b2f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     b33:	48 8b 00             	mov    (%rax),%rax
     b36:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
      free(m1);
     b3a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     b3e:	48 89 c7             	mov    %rax,%rdi
     b41:	e8 63 37 00 00       	callq  42a9 <free>
      m1 = m2;
     b46:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     b4a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    while(m1){
     b4e:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
     b53:	75 da                	jne    b2f <mem+0x6c>
    }
    m1 = malloc(1024*20);
     b55:	bf 00 50 00 00       	mov    $0x5000,%edi
     b5a:	e8 d5 38 00 00       	callq  4434 <malloc>
     b5f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(m1 == 0){
     b63:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
     b68:	75 25                	jne    b8f <mem+0xcc>
      printf(1, "couldn't allocate mem?!!\n");
     b6a:	48 c7 c6 6d 49 00 00 	mov    $0x496d,%rsi
     b71:	bf 01 00 00 00       	mov    $0x1,%edi
     b76:	b8 00 00 00 00       	mov    $0x0,%eax
     b7b:	e8 c2 33 00 00       	callq  3f42 <printf>
      kill(ppid);
     b80:	8b 45 f4             	mov    -0xc(%rbp),%eax
     b83:	89 c7                	mov    %eax,%edi
     b85:	e8 5f 32 00 00       	callq  3de9 <kill>
      exit();
     b8a:	e8 2a 32 00 00       	callq  3db9 <exit>
    }
    free(m1);
     b8f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
     b93:	48 89 c7             	mov    %rax,%rdi
     b96:	e8 0e 37 00 00       	callq  42a9 <free>
    printf(1, "mem ok\n");
     b9b:	48 c7 c6 87 49 00 00 	mov    $0x4987,%rsi
     ba2:	bf 01 00 00 00       	mov    $0x1,%edi
     ba7:	b8 00 00 00 00       	mov    $0x0,%eax
     bac:	e8 91 33 00 00       	callq  3f42 <printf>
    exit();
     bb1:	e8 03 32 00 00       	callq  3db9 <exit>
  } else {
    wait();
     bb6:	e8 06 32 00 00       	callq  3dc1 <wait>
  }
}
     bbb:	90                   	nop
     bbc:	c9                   	leaveq 
     bbd:	c3                   	retq   

0000000000000bbe <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     bbe:	55                   	push   %rbp
     bbf:	48 89 e5             	mov    %rsp,%rbp
     bc2:	48 83 ec 30          	sub    $0x30,%rsp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     bc6:	48 c7 c6 8f 49 00 00 	mov    $0x498f,%rsi
     bcd:	bf 01 00 00 00       	mov    $0x1,%edi
     bd2:	b8 00 00 00 00       	mov    $0x0,%eax
     bd7:	e8 66 33 00 00       	callq  3f42 <printf>

  unlink("sharedfd");
     bdc:	48 c7 c7 9e 49 00 00 	mov    $0x499e,%rdi
     be3:	e8 21 32 00 00       	callq  3e09 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     be8:	be 02 02 00 00       	mov    $0x202,%esi
     bed:	48 c7 c7 9e 49 00 00 	mov    $0x499e,%rdi
     bf4:	e8 00 32 00 00       	callq  3df9 <open>
     bf9:	89 45 f0             	mov    %eax,-0x10(%rbp)
  if(fd < 0){
     bfc:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     c00:	79 1b                	jns    c1d <sharedfd+0x5f>
    printf(1, "fstests: cannot open sharedfd for writing");
     c02:	48 c7 c6 a8 49 00 00 	mov    $0x49a8,%rsi
     c09:	bf 01 00 00 00       	mov    $0x1,%edi
     c0e:	b8 00 00 00 00       	mov    $0x0,%eax
     c13:	e8 2a 33 00 00       	callq  3f42 <printf>
    return;
     c18:	e9 91 01 00 00       	jmpq   dae <sharedfd+0x1f0>
  }
  pid = fork();
     c1d:	e8 8f 31 00 00       	callq  3db1 <fork>
     c22:	89 45 ec             	mov    %eax,-0x14(%rbp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     c25:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
     c29:	75 07                	jne    c32 <sharedfd+0x74>
     c2b:	b9 63 00 00 00       	mov    $0x63,%ecx
     c30:	eb 05                	jmp    c37 <sharedfd+0x79>
     c32:	b9 70 00 00 00       	mov    $0x70,%ecx
     c37:	48 8d 45 de          	lea    -0x22(%rbp),%rax
     c3b:	ba 0a 00 00 00       	mov    $0xa,%edx
     c40:	89 ce                	mov    %ecx,%esi
     c42:	48 89 c7             	mov    %rax,%rdi
     c45:	e8 7a 2f 00 00       	callq  3bc4 <memset>
  for(i = 0; i < 1000; i++){
     c4a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     c51:	eb 37                	jmp    c8a <sharedfd+0xcc>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     c53:	48 8d 4d de          	lea    -0x22(%rbp),%rcx
     c57:	8b 45 f0             	mov    -0x10(%rbp),%eax
     c5a:	ba 0a 00 00 00       	mov    $0xa,%edx
     c5f:	48 89 ce             	mov    %rcx,%rsi
     c62:	89 c7                	mov    %eax,%edi
     c64:	e8 70 31 00 00       	callq  3dd9 <write>
     c69:	83 f8 0a             	cmp    $0xa,%eax
     c6c:	74 18                	je     c86 <sharedfd+0xc8>
      printf(1, "fstests: write sharedfd failed\n");
     c6e:	48 c7 c6 d8 49 00 00 	mov    $0x49d8,%rsi
     c75:	bf 01 00 00 00       	mov    $0x1,%edi
     c7a:	b8 00 00 00 00       	mov    $0x0,%eax
     c7f:	e8 be 32 00 00       	callq  3f42 <printf>
      break;
     c84:	eb 0d                	jmp    c93 <sharedfd+0xd5>
  for(i = 0; i < 1000; i++){
     c86:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     c8a:	81 7d fc e7 03 00 00 	cmpl   $0x3e7,-0x4(%rbp)
     c91:	7e c0                	jle    c53 <sharedfd+0x95>
    }
  }
  if(pid == 0)
     c93:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
     c97:	75 05                	jne    c9e <sharedfd+0xe0>
    exit();
     c99:	e8 1b 31 00 00       	callq  3db9 <exit>
  else
    wait();
     c9e:	e8 1e 31 00 00       	callq  3dc1 <wait>
  close(fd);
     ca3:	8b 45 f0             	mov    -0x10(%rbp),%eax
     ca6:	89 c7                	mov    %eax,%edi
     ca8:	e8 34 31 00 00       	callq  3de1 <close>
  fd = open("sharedfd", 0);
     cad:	be 00 00 00 00       	mov    $0x0,%esi
     cb2:	48 c7 c7 9e 49 00 00 	mov    $0x499e,%rdi
     cb9:	e8 3b 31 00 00       	callq  3df9 <open>
     cbe:	89 45 f0             	mov    %eax,-0x10(%rbp)
  if(fd < 0){
     cc1:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     cc5:	79 1b                	jns    ce2 <sharedfd+0x124>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     cc7:	48 c7 c6 f8 49 00 00 	mov    $0x49f8,%rsi
     cce:	bf 01 00 00 00       	mov    $0x1,%edi
     cd3:	b8 00 00 00 00       	mov    $0x0,%eax
     cd8:	e8 65 32 00 00       	callq  3f42 <printf>
    return;
     cdd:	e9 cc 00 00 00       	jmpq   dae <sharedfd+0x1f0>
  }
  nc = np = 0;
     ce2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
     ce9:	8b 45 f4             	mov    -0xc(%rbp),%eax
     cec:	89 45 f8             	mov    %eax,-0x8(%rbp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     cef:	eb 39                	jmp    d2a <sharedfd+0x16c>
    for(i = 0; i < sizeof(buf); i++){
     cf1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     cf8:	eb 28                	jmp    d22 <sharedfd+0x164>
      if(buf[i] == 'c')
     cfa:	8b 45 fc             	mov    -0x4(%rbp),%eax
     cfd:	48 98                	cltq   
     cff:	0f b6 44 05 de       	movzbl -0x22(%rbp,%rax,1),%eax
     d04:	3c 63                	cmp    $0x63,%al
     d06:	75 04                	jne    d0c <sharedfd+0x14e>
        nc++;
     d08:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
      if(buf[i] == 'p')
     d0c:	8b 45 fc             	mov    -0x4(%rbp),%eax
     d0f:	48 98                	cltq   
     d11:	0f b6 44 05 de       	movzbl -0x22(%rbp,%rax,1),%eax
     d16:	3c 70                	cmp    $0x70,%al
     d18:	75 04                	jne    d1e <sharedfd+0x160>
        np++;
     d1a:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
    for(i = 0; i < sizeof(buf); i++){
     d1e:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     d22:	8b 45 fc             	mov    -0x4(%rbp),%eax
     d25:	83 f8 09             	cmp    $0x9,%eax
     d28:	76 d0                	jbe    cfa <sharedfd+0x13c>
  while((n = read(fd, buf, sizeof(buf))) > 0){
     d2a:	48 8d 4d de          	lea    -0x22(%rbp),%rcx
     d2e:	8b 45 f0             	mov    -0x10(%rbp),%eax
     d31:	ba 0a 00 00 00       	mov    $0xa,%edx
     d36:	48 89 ce             	mov    %rcx,%rsi
     d39:	89 c7                	mov    %eax,%edi
     d3b:	e8 91 30 00 00       	callq  3dd1 <read>
     d40:	89 45 e8             	mov    %eax,-0x18(%rbp)
     d43:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
     d47:	7f a8                	jg     cf1 <sharedfd+0x133>
    }
  }
  close(fd);
     d49:	8b 45 f0             	mov    -0x10(%rbp),%eax
     d4c:	89 c7                	mov    %eax,%edi
     d4e:	e8 8e 30 00 00       	callq  3de1 <close>
  unlink("sharedfd");
     d53:	48 c7 c7 9e 49 00 00 	mov    $0x499e,%rdi
     d5a:	e8 aa 30 00 00       	callq  3e09 <unlink>
  if(nc == 10000 && np == 10000){
     d5f:	81 7d f8 10 27 00 00 	cmpl   $0x2710,-0x8(%rbp)
     d66:	75 21                	jne    d89 <sharedfd+0x1cb>
     d68:	81 7d f4 10 27 00 00 	cmpl   $0x2710,-0xc(%rbp)
     d6f:	75 18                	jne    d89 <sharedfd+0x1cb>
    printf(1, "sharedfd ok\n");
     d71:	48 c7 c6 23 4a 00 00 	mov    $0x4a23,%rsi
     d78:	bf 01 00 00 00       	mov    $0x1,%edi
     d7d:	b8 00 00 00 00       	mov    $0x0,%eax
     d82:	e8 bb 31 00 00       	callq  3f42 <printf>
     d87:	eb 25                	jmp    dae <sharedfd+0x1f0>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     d89:	8b 55 f4             	mov    -0xc(%rbp),%edx
     d8c:	8b 45 f8             	mov    -0x8(%rbp),%eax
     d8f:	89 d1                	mov    %edx,%ecx
     d91:	89 c2                	mov    %eax,%edx
     d93:	48 c7 c6 30 4a 00 00 	mov    $0x4a30,%rsi
     d9a:	bf 01 00 00 00       	mov    $0x1,%edi
     d9f:	b8 00 00 00 00       	mov    $0x0,%eax
     da4:	e8 99 31 00 00       	callq  3f42 <printf>
    exit();
     da9:	e8 0b 30 00 00       	callq  3db9 <exit>
  }
}
     dae:	c9                   	leaveq 
     daf:	c3                   	retq   

0000000000000db0 <twofiles>:

// two processes write two different files at the same
// time, to test block allocation.
void
twofiles(void)
{
     db0:	55                   	push   %rbp
     db1:	48 89 e5             	mov    %rsp,%rbp
     db4:	48 83 ec 20          	sub    $0x20,%rsp
  int fd, pid, i, j, n, total;
  char *fname;

  printf(1, "twofiles test\n");
     db8:	48 c7 c6 45 4a 00 00 	mov    $0x4a45,%rsi
     dbf:	bf 01 00 00 00       	mov    $0x1,%edi
     dc4:	b8 00 00 00 00       	mov    $0x0,%eax
     dc9:	e8 74 31 00 00       	callq  3f42 <printf>

  unlink("f1");
     dce:	48 c7 c7 54 4a 00 00 	mov    $0x4a54,%rdi
     dd5:	e8 2f 30 00 00       	callq  3e09 <unlink>
  unlink("f2");
     dda:	48 c7 c7 57 4a 00 00 	mov    $0x4a57,%rdi
     de1:	e8 23 30 00 00       	callq  3e09 <unlink>

  pid = fork();
     de6:	e8 c6 2f 00 00       	callq  3db1 <fork>
     deb:	89 45 f0             	mov    %eax,-0x10(%rbp)
  if(pid < 0){
     dee:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     df2:	79 1b                	jns    e0f <twofiles+0x5f>
    printf(1, "fork failed\n");
     df4:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
     dfb:	bf 01 00 00 00       	mov    $0x1,%edi
     e00:	b8 00 00 00 00       	mov    $0x0,%eax
     e05:	e8 38 31 00 00       	callq  3f42 <printf>
    exit();
     e0a:	e8 aa 2f 00 00       	callq  3db9 <exit>
  }

  fname = pid ? "f1" : "f2";
     e0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     e13:	74 09                	je     e1e <twofiles+0x6e>
     e15:	48 c7 c0 54 4a 00 00 	mov    $0x4a54,%rax
     e1c:	eb 07                	jmp    e25 <twofiles+0x75>
     e1e:	48 c7 c0 57 4a 00 00 	mov    $0x4a57,%rax
     e25:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  fd = open(fname, O_CREATE | O_RDWR);
     e29:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
     e2d:	be 02 02 00 00       	mov    $0x202,%esi
     e32:	48 89 c7             	mov    %rax,%rdi
     e35:	e8 bf 2f 00 00       	callq  3df9 <open>
     e3a:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  if(fd < 0){
     e3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
     e41:	79 1b                	jns    e5e <twofiles+0xae>
    printf(1, "create failed\n");
     e43:	48 c7 c6 5a 4a 00 00 	mov    $0x4a5a,%rsi
     e4a:	bf 01 00 00 00       	mov    $0x1,%edi
     e4f:	b8 00 00 00 00       	mov    $0x0,%eax
     e54:	e8 e9 30 00 00       	callq  3f42 <printf>
    exit();
     e59:	e8 5b 2f 00 00       	callq  3db9 <exit>
  }

  memset(buf, pid?'p':'c', 512);
     e5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     e62:	74 07                	je     e6b <twofiles+0xbb>
     e64:	b8 70 00 00 00       	mov    $0x70,%eax
     e69:	eb 05                	jmp    e70 <twofiles+0xc0>
     e6b:	b8 63 00 00 00       	mov    $0x63,%eax
     e70:	ba 00 02 00 00       	mov    $0x200,%edx
     e75:	89 c6                	mov    %eax,%esi
     e77:	48 c7 c7 20 63 00 00 	mov    $0x6320,%rdi
     e7e:	e8 41 2d 00 00       	callq  3bc4 <memset>
  for(i = 0; i < 12; i++){
     e83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     e8a:	eb 46                	jmp    ed2 <twofiles+0x122>
    if((n = write(fd, buf, 500)) != 500){
     e8c:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     e8f:	ba f4 01 00 00       	mov    $0x1f4,%edx
     e94:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     e9b:	89 c7                	mov    %eax,%edi
     e9d:	e8 37 2f 00 00       	callq  3dd9 <write>
     ea2:	89 45 e0             	mov    %eax,-0x20(%rbp)
     ea5:	81 7d e0 f4 01 00 00 	cmpl   $0x1f4,-0x20(%rbp)
     eac:	74 20                	je     ece <twofiles+0x11e>
      printf(1, "write failed %d\n", n);
     eae:	8b 45 e0             	mov    -0x20(%rbp),%eax
     eb1:	89 c2                	mov    %eax,%edx
     eb3:	48 c7 c6 69 4a 00 00 	mov    $0x4a69,%rsi
     eba:	bf 01 00 00 00       	mov    $0x1,%edi
     ebf:	b8 00 00 00 00       	mov    $0x0,%eax
     ec4:	e8 79 30 00 00       	callq  3f42 <printf>
      exit();
     ec9:	e8 eb 2e 00 00       	callq  3db9 <exit>
  for(i = 0; i < 12; i++){
     ece:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     ed2:	83 7d fc 0b          	cmpl   $0xb,-0x4(%rbp)
     ed6:	7e b4                	jle    e8c <twofiles+0xdc>
    }
  }
  close(fd);
     ed8:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     edb:	89 c7                	mov    %eax,%edi
     edd:	e8 ff 2e 00 00       	callq  3de1 <close>
  if(pid)
     ee2:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
     ee6:	74 11                	je     ef9 <twofiles+0x149>
    wait();
     ee8:	e8 d4 2e 00 00       	callq  3dc1 <wait>
  else
    exit();

  for(i = 0; i < 2; i++){
     eed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
     ef4:	e9 e5 00 00 00       	jmpq   fde <twofiles+0x22e>
    exit();
     ef9:	e8 bb 2e 00 00       	callq  3db9 <exit>
    fd = open(i?"f1":"f2", 0);
     efe:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
     f02:	74 09                	je     f0d <twofiles+0x15d>
     f04:	48 c7 c0 54 4a 00 00 	mov    $0x4a54,%rax
     f0b:	eb 07                	jmp    f14 <twofiles+0x164>
     f0d:	48 c7 c0 57 4a 00 00 	mov    $0x4a57,%rax
     f14:	be 00 00 00 00       	mov    $0x0,%esi
     f19:	48 89 c7             	mov    %rax,%rdi
     f1c:	e8 d8 2e 00 00       	callq  3df9 <open>
     f21:	89 45 e4             	mov    %eax,-0x1c(%rbp)
    total = 0;
     f24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     f2b:	eb 5b                	jmp    f88 <twofiles+0x1d8>
      for(j = 0; j < n; j++){
     f2d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
     f34:	eb 44                	jmp    f7a <twofiles+0x1ca>
        if(buf[j] != (i?'p':'c')){
     f36:	8b 45 f8             	mov    -0x8(%rbp),%eax
     f39:	48 98                	cltq   
     f3b:	0f b6 80 20 63 00 00 	movzbl 0x6320(%rax),%eax
     f42:	0f be c0             	movsbl %al,%eax
     f45:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
     f49:	74 07                	je     f52 <twofiles+0x1a2>
     f4b:	ba 70 00 00 00       	mov    $0x70,%edx
     f50:	eb 05                	jmp    f57 <twofiles+0x1a7>
     f52:	ba 63 00 00 00       	mov    $0x63,%edx
     f57:	39 c2                	cmp    %eax,%edx
     f59:	74 1b                	je     f76 <twofiles+0x1c6>
          printf(1, "wrong char\n");
     f5b:	48 c7 c6 7a 4a 00 00 	mov    $0x4a7a,%rsi
     f62:	bf 01 00 00 00       	mov    $0x1,%edi
     f67:	b8 00 00 00 00       	mov    $0x0,%eax
     f6c:	e8 d1 2f 00 00       	callq  3f42 <printf>
          exit();
     f71:	e8 43 2e 00 00       	callq  3db9 <exit>
      for(j = 0; j < n; j++){
     f76:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
     f7a:	8b 45 f8             	mov    -0x8(%rbp),%eax
     f7d:	3b 45 e0             	cmp    -0x20(%rbp),%eax
     f80:	7c b4                	jl     f36 <twofiles+0x186>
        }
      }
      total += n;
     f82:	8b 45 e0             	mov    -0x20(%rbp),%eax
     f85:	01 45 f4             	add    %eax,-0xc(%rbp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     f88:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     f8b:	ba 00 20 00 00       	mov    $0x2000,%edx
     f90:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
     f97:	89 c7                	mov    %eax,%edi
     f99:	e8 33 2e 00 00       	callq  3dd1 <read>
     f9e:	89 45 e0             	mov    %eax,-0x20(%rbp)
     fa1:	83 7d e0 00          	cmpl   $0x0,-0x20(%rbp)
     fa5:	7f 86                	jg     f2d <twofiles+0x17d>
    }
    close(fd);
     fa7:	8b 45 e4             	mov    -0x1c(%rbp),%eax
     faa:	89 c7                	mov    %eax,%edi
     fac:	e8 30 2e 00 00       	callq  3de1 <close>
    if(total != 12*500){
     fb1:	81 7d f4 70 17 00 00 	cmpl   $0x1770,-0xc(%rbp)
     fb8:	74 20                	je     fda <twofiles+0x22a>
      printf(1, "wrong length %d\n", total);
     fba:	8b 45 f4             	mov    -0xc(%rbp),%eax
     fbd:	89 c2                	mov    %eax,%edx
     fbf:	48 c7 c6 86 4a 00 00 	mov    $0x4a86,%rsi
     fc6:	bf 01 00 00 00       	mov    $0x1,%edi
     fcb:	b8 00 00 00 00       	mov    $0x0,%eax
     fd0:	e8 6d 2f 00 00       	callq  3f42 <printf>
      exit();
     fd5:	e8 df 2d 00 00       	callq  3db9 <exit>
  for(i = 0; i < 2; i++){
     fda:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
     fde:	83 7d fc 01          	cmpl   $0x1,-0x4(%rbp)
     fe2:	0f 8e 16 ff ff ff    	jle    efe <twofiles+0x14e>
    }
  }

  unlink("f1");
     fe8:	48 c7 c7 54 4a 00 00 	mov    $0x4a54,%rdi
     fef:	e8 15 2e 00 00       	callq  3e09 <unlink>
  unlink("f2");
     ff4:	48 c7 c7 57 4a 00 00 	mov    $0x4a57,%rdi
     ffb:	e8 09 2e 00 00       	callq  3e09 <unlink>

  printf(1, "twofiles ok\n");
    1000:	48 c7 c6 97 4a 00 00 	mov    $0x4a97,%rsi
    1007:	bf 01 00 00 00       	mov    $0x1,%edi
    100c:	b8 00 00 00 00       	mov    $0x0,%eax
    1011:	e8 2c 2f 00 00       	callq  3f42 <printf>
}
    1016:	90                   	nop
    1017:	c9                   	leaveq 
    1018:	c3                   	retq   

0000000000001019 <createdelete>:

// two processes create and delete different files in same directory
void
createdelete(void)
{
    1019:	55                   	push   %rbp
    101a:	48 89 e5             	mov    %rsp,%rbp
    101d:	48 83 ec 30          	sub    $0x30,%rsp
  enum { N = 20 };
  int pid, i, fd;
  char name[32];

  printf(1, "createdelete test\n");
    1021:	48 c7 c6 a4 4a 00 00 	mov    $0x4aa4,%rsi
    1028:	bf 01 00 00 00       	mov    $0x1,%edi
    102d:	b8 00 00 00 00       	mov    $0x0,%eax
    1032:	e8 0b 2f 00 00       	callq  3f42 <printf>
  pid = fork();
    1037:	e8 75 2d 00 00       	callq  3db1 <fork>
    103c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(pid < 0){
    103f:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    1043:	79 1b                	jns    1060 <createdelete+0x47>
    printf(1, "fork failed\n");
    1045:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
    104c:	bf 01 00 00 00       	mov    $0x1,%edi
    1051:	b8 00 00 00 00       	mov    $0x0,%eax
    1056:	e8 e7 2e 00 00       	callq  3f42 <printf>
    exit();
    105b:	e8 59 2d 00 00       	callq  3db9 <exit>
  }

  name[0] = pid ? 'p' : 'c';
    1060:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    1064:	74 07                	je     106d <createdelete+0x54>
    1066:	b8 70 00 00 00       	mov    $0x70,%eax
    106b:	eb 05                	jmp    1072 <createdelete+0x59>
    106d:	b8 63 00 00 00       	mov    $0x63,%eax
    1072:	88 45 d0             	mov    %al,-0x30(%rbp)
  name[2] = '\0';
    1075:	c6 45 d2 00          	movb   $0x0,-0x2e(%rbp)
  for(i = 0; i < N; i++){
    1079:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    1080:	e9 99 00 00 00       	jmpq   111e <createdelete+0x105>
    name[1] = '0' + i;
    1085:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1088:	83 c0 30             	add    $0x30,%eax
    108b:	88 45 d1             	mov    %al,-0x2f(%rbp)
    fd = open(name, O_CREATE | O_RDWR);
    108e:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    1092:	be 02 02 00 00       	mov    $0x202,%esi
    1097:	48 89 c7             	mov    %rax,%rdi
    109a:	e8 5a 2d 00 00       	callq  3df9 <open>
    109f:	89 45 f4             	mov    %eax,-0xc(%rbp)
    if(fd < 0){
    10a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    10a6:	79 1b                	jns    10c3 <createdelete+0xaa>
      printf(1, "create failed\n");
    10a8:	48 c7 c6 5a 4a 00 00 	mov    $0x4a5a,%rsi
    10af:	bf 01 00 00 00       	mov    $0x1,%edi
    10b4:	b8 00 00 00 00       	mov    $0x0,%eax
    10b9:	e8 84 2e 00 00       	callq  3f42 <printf>
      exit();
    10be:	e8 f6 2c 00 00       	callq  3db9 <exit>
    }
    close(fd);
    10c3:	8b 45 f4             	mov    -0xc(%rbp),%eax
    10c6:	89 c7                	mov    %eax,%edi
    10c8:	e8 14 2d 00 00       	callq  3de1 <close>
    if(i > 0 && (i % 2 ) == 0){
    10cd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    10d1:	7e 47                	jle    111a <createdelete+0x101>
    10d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
    10d6:	83 e0 01             	and    $0x1,%eax
    10d9:	85 c0                	test   %eax,%eax
    10db:	75 3d                	jne    111a <createdelete+0x101>
      name[1] = '0' + (i / 2);
    10dd:	8b 45 fc             	mov    -0x4(%rbp),%eax
    10e0:	89 c2                	mov    %eax,%edx
    10e2:	c1 ea 1f             	shr    $0x1f,%edx
    10e5:	01 d0                	add    %edx,%eax
    10e7:	d1 f8                	sar    %eax
    10e9:	83 c0 30             	add    $0x30,%eax
    10ec:	88 45 d1             	mov    %al,-0x2f(%rbp)
      if(unlink(name) < 0){
    10ef:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    10f3:	48 89 c7             	mov    %rax,%rdi
    10f6:	e8 0e 2d 00 00       	callq  3e09 <unlink>
    10fb:	85 c0                	test   %eax,%eax
    10fd:	79 1b                	jns    111a <createdelete+0x101>
        printf(1, "unlink failed\n");
    10ff:	48 c7 c6 b7 4a 00 00 	mov    $0x4ab7,%rsi
    1106:	bf 01 00 00 00       	mov    $0x1,%edi
    110b:	b8 00 00 00 00       	mov    $0x0,%eax
    1110:	e8 2d 2e 00 00       	callq  3f42 <printf>
        exit();
    1115:	e8 9f 2c 00 00       	callq  3db9 <exit>
  for(i = 0; i < N; i++){
    111a:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    111e:	83 7d fc 13          	cmpl   $0x13,-0x4(%rbp)
    1122:	0f 8e 5d ff ff ff    	jle    1085 <createdelete+0x6c>
      }
    }
  }

  if(pid==0)
    1128:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    112c:	75 05                	jne    1133 <createdelete+0x11a>
    exit();
    112e:	e8 86 2c 00 00       	callq  3db9 <exit>
  else
    wait();
    1133:	e8 89 2c 00 00       	callq  3dc1 <wait>

  for(i = 0; i < N; i++){
    1138:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    113f:	e9 36 01 00 00       	jmpq   127a <createdelete+0x261>
    name[0] = 'p';
    1144:	c6 45 d0 70          	movb   $0x70,-0x30(%rbp)
    name[1] = '0' + i;
    1148:	8b 45 fc             	mov    -0x4(%rbp),%eax
    114b:	83 c0 30             	add    $0x30,%eax
    114e:	88 45 d1             	mov    %al,-0x2f(%rbp)
    fd = open(name, 0);
    1151:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    1155:	be 00 00 00 00       	mov    $0x0,%esi
    115a:	48 89 c7             	mov    %rax,%rdi
    115d:	e8 97 2c 00 00       	callq  3df9 <open>
    1162:	89 45 f4             	mov    %eax,-0xc(%rbp)
    if((i == 0 || i >= N/2) && fd < 0){
    1165:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1169:	74 06                	je     1171 <createdelete+0x158>
    116b:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
    116f:	7e 28                	jle    1199 <createdelete+0x180>
    1171:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1175:	79 22                	jns    1199 <createdelete+0x180>
      printf(1, "oops createdelete %s didn't exist\n", name);
    1177:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    117b:	48 89 c2             	mov    %rax,%rdx
    117e:	48 c7 c6 c8 4a 00 00 	mov    $0x4ac8,%rsi
    1185:	bf 01 00 00 00       	mov    $0x1,%edi
    118a:	b8 00 00 00 00       	mov    $0x0,%eax
    118f:	e8 ae 2d 00 00       	callq  3f42 <printf>
      exit();
    1194:	e8 20 2c 00 00       	callq  3db9 <exit>
    } else if((i >= 1 && i < N/2) && fd >= 0){
    1199:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    119d:	7e 2e                	jle    11cd <createdelete+0x1b4>
    119f:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
    11a3:	7f 28                	jg     11cd <createdelete+0x1b4>
    11a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    11a9:	78 22                	js     11cd <createdelete+0x1b4>
      printf(1, "oops createdelete %s did exist\n", name);
    11ab:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    11af:	48 89 c2             	mov    %rax,%rdx
    11b2:	48 c7 c6 f0 4a 00 00 	mov    $0x4af0,%rsi
    11b9:	bf 01 00 00 00       	mov    $0x1,%edi
    11be:	b8 00 00 00 00       	mov    $0x0,%eax
    11c3:	e8 7a 2d 00 00       	callq  3f42 <printf>
      exit();
    11c8:	e8 ec 2b 00 00       	callq  3db9 <exit>
    }
    if(fd >= 0)
    11cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    11d1:	78 0a                	js     11dd <createdelete+0x1c4>
      close(fd);
    11d3:	8b 45 f4             	mov    -0xc(%rbp),%eax
    11d6:	89 c7                	mov    %eax,%edi
    11d8:	e8 04 2c 00 00       	callq  3de1 <close>

    name[0] = 'c';
    11dd:	c6 45 d0 63          	movb   $0x63,-0x30(%rbp)
    name[1] = '0' + i;
    11e1:	8b 45 fc             	mov    -0x4(%rbp),%eax
    11e4:	83 c0 30             	add    $0x30,%eax
    11e7:	88 45 d1             	mov    %al,-0x2f(%rbp)
    fd = open(name, 0);
    11ea:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    11ee:	be 00 00 00 00       	mov    $0x0,%esi
    11f3:	48 89 c7             	mov    %rax,%rdi
    11f6:	e8 fe 2b 00 00       	callq  3df9 <open>
    11fb:	89 45 f4             	mov    %eax,-0xc(%rbp)
    if((i == 0 || i >= N/2) && fd < 0){
    11fe:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1202:	74 06                	je     120a <createdelete+0x1f1>
    1204:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
    1208:	7e 28                	jle    1232 <createdelete+0x219>
    120a:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    120e:	79 22                	jns    1232 <createdelete+0x219>
      printf(1, "oops createdelete %s didn't exist\n", name);
    1210:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    1214:	48 89 c2             	mov    %rax,%rdx
    1217:	48 c7 c6 c8 4a 00 00 	mov    $0x4ac8,%rsi
    121e:	bf 01 00 00 00       	mov    $0x1,%edi
    1223:	b8 00 00 00 00       	mov    $0x0,%eax
    1228:	e8 15 2d 00 00       	callq  3f42 <printf>
      exit();
    122d:	e8 87 2b 00 00       	callq  3db9 <exit>
    } else if((i >= 1 && i < N/2) && fd >= 0){
    1232:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1236:	7e 2e                	jle    1266 <createdelete+0x24d>
    1238:	83 7d fc 09          	cmpl   $0x9,-0x4(%rbp)
    123c:	7f 28                	jg     1266 <createdelete+0x24d>
    123e:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1242:	78 22                	js     1266 <createdelete+0x24d>
      printf(1, "oops createdelete %s did exist\n", name);
    1244:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    1248:	48 89 c2             	mov    %rax,%rdx
    124b:	48 c7 c6 f0 4a 00 00 	mov    $0x4af0,%rsi
    1252:	bf 01 00 00 00       	mov    $0x1,%edi
    1257:	b8 00 00 00 00       	mov    $0x0,%eax
    125c:	e8 e1 2c 00 00       	callq  3f42 <printf>
      exit();
    1261:	e8 53 2b 00 00       	callq  3db9 <exit>
    }
    if(fd >= 0)
    1266:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    126a:	78 0a                	js     1276 <createdelete+0x25d>
      close(fd);
    126c:	8b 45 f4             	mov    -0xc(%rbp),%eax
    126f:	89 c7                	mov    %eax,%edi
    1271:	e8 6b 2b 00 00       	callq  3de1 <close>
  for(i = 0; i < N; i++){
    1276:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    127a:	83 7d fc 13          	cmpl   $0x13,-0x4(%rbp)
    127e:	0f 8e c0 fe ff ff    	jle    1144 <createdelete+0x12b>
  }

  for(i = 0; i < N; i++){
    1284:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    128b:	eb 2d                	jmp    12ba <createdelete+0x2a1>
    name[0] = 'p';
    128d:	c6 45 d0 70          	movb   $0x70,-0x30(%rbp)
    name[1] = '0' + i;
    1291:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1294:	83 c0 30             	add    $0x30,%eax
    1297:	88 45 d1             	mov    %al,-0x2f(%rbp)
    unlink(name);
    129a:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    129e:	48 89 c7             	mov    %rax,%rdi
    12a1:	e8 63 2b 00 00       	callq  3e09 <unlink>
    name[0] = 'c';
    12a6:	c6 45 d0 63          	movb   $0x63,-0x30(%rbp)
    unlink(name);
    12aa:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
    12ae:	48 89 c7             	mov    %rax,%rdi
    12b1:	e8 53 2b 00 00       	callq  3e09 <unlink>
  for(i = 0; i < N; i++){
    12b6:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    12ba:	83 7d fc 13          	cmpl   $0x13,-0x4(%rbp)
    12be:	7e cd                	jle    128d <createdelete+0x274>
  }

  printf(1, "createdelete ok\n");
    12c0:	48 c7 c6 10 4b 00 00 	mov    $0x4b10,%rsi
    12c7:	bf 01 00 00 00       	mov    $0x1,%edi
    12cc:	b8 00 00 00 00       	mov    $0x0,%eax
    12d1:	e8 6c 2c 00 00       	callq  3f42 <printf>
}
    12d6:	90                   	nop
    12d7:	c9                   	leaveq 
    12d8:	c3                   	retq   

00000000000012d9 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    12d9:	55                   	push   %rbp
    12da:	48 89 e5             	mov    %rsp,%rbp
    12dd:	48 83 ec 10          	sub    $0x10,%rsp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    12e1:	48 c7 c6 21 4b 00 00 	mov    $0x4b21,%rsi
    12e8:	bf 01 00 00 00       	mov    $0x1,%edi
    12ed:	b8 00 00 00 00       	mov    $0x0,%eax
    12f2:	e8 4b 2c 00 00       	callq  3f42 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    12f7:	be 02 02 00 00       	mov    $0x202,%esi
    12fc:	48 c7 c7 32 4b 00 00 	mov    $0x4b32,%rdi
    1303:	e8 f1 2a 00 00       	callq  3df9 <open>
    1308:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    130b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    130f:	79 1b                	jns    132c <unlinkread+0x53>
    printf(1, "create unlinkread failed\n");
    1311:	48 c7 c6 3d 4b 00 00 	mov    $0x4b3d,%rsi
    1318:	bf 01 00 00 00       	mov    $0x1,%edi
    131d:	b8 00 00 00 00       	mov    $0x0,%eax
    1322:	e8 1b 2c 00 00       	callq  3f42 <printf>
    exit();
    1327:	e8 8d 2a 00 00       	callq  3db9 <exit>
  }
  write(fd, "hello", 5);
    132c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    132f:	ba 05 00 00 00       	mov    $0x5,%edx
    1334:	48 c7 c6 57 4b 00 00 	mov    $0x4b57,%rsi
    133b:	89 c7                	mov    %eax,%edi
    133d:	e8 97 2a 00 00       	callq  3dd9 <write>
  close(fd);
    1342:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1345:	89 c7                	mov    %eax,%edi
    1347:	e8 95 2a 00 00       	callq  3de1 <close>

  fd = open("unlinkread", O_RDWR);
    134c:	be 02 00 00 00       	mov    $0x2,%esi
    1351:	48 c7 c7 32 4b 00 00 	mov    $0x4b32,%rdi
    1358:	e8 9c 2a 00 00       	callq  3df9 <open>
    135d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    1360:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1364:	79 1b                	jns    1381 <unlinkread+0xa8>
    printf(1, "open unlinkread failed\n");
    1366:	48 c7 c6 5d 4b 00 00 	mov    $0x4b5d,%rsi
    136d:	bf 01 00 00 00       	mov    $0x1,%edi
    1372:	b8 00 00 00 00       	mov    $0x0,%eax
    1377:	e8 c6 2b 00 00       	callq  3f42 <printf>
    exit();
    137c:	e8 38 2a 00 00       	callq  3db9 <exit>
  }
  if(unlink("unlinkread") != 0){
    1381:	48 c7 c7 32 4b 00 00 	mov    $0x4b32,%rdi
    1388:	e8 7c 2a 00 00       	callq  3e09 <unlink>
    138d:	85 c0                	test   %eax,%eax
    138f:	74 1b                	je     13ac <unlinkread+0xd3>
    printf(1, "unlink unlinkread failed\n");
    1391:	48 c7 c6 75 4b 00 00 	mov    $0x4b75,%rsi
    1398:	bf 01 00 00 00       	mov    $0x1,%edi
    139d:	b8 00 00 00 00       	mov    $0x0,%eax
    13a2:	e8 9b 2b 00 00       	callq  3f42 <printf>
    exit();
    13a7:	e8 0d 2a 00 00       	callq  3db9 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    13ac:	be 02 02 00 00       	mov    $0x202,%esi
    13b1:	48 c7 c7 32 4b 00 00 	mov    $0x4b32,%rdi
    13b8:	e8 3c 2a 00 00       	callq  3df9 <open>
    13bd:	89 45 f8             	mov    %eax,-0x8(%rbp)
  write(fd1, "yyy", 3);
    13c0:	8b 45 f8             	mov    -0x8(%rbp),%eax
    13c3:	ba 03 00 00 00       	mov    $0x3,%edx
    13c8:	48 c7 c6 8f 4b 00 00 	mov    $0x4b8f,%rsi
    13cf:	89 c7                	mov    %eax,%edi
    13d1:	e8 03 2a 00 00       	callq  3dd9 <write>
  close(fd1);
    13d6:	8b 45 f8             	mov    -0x8(%rbp),%eax
    13d9:	89 c7                	mov    %eax,%edi
    13db:	e8 01 2a 00 00       	callq  3de1 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    13e0:	8b 45 fc             	mov    -0x4(%rbp),%eax
    13e3:	ba 00 20 00 00       	mov    $0x2000,%edx
    13e8:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    13ef:	89 c7                	mov    %eax,%edi
    13f1:	e8 db 29 00 00       	callq  3dd1 <read>
    13f6:	83 f8 05             	cmp    $0x5,%eax
    13f9:	74 1b                	je     1416 <unlinkread+0x13d>
    printf(1, "unlinkread read failed");
    13fb:	48 c7 c6 93 4b 00 00 	mov    $0x4b93,%rsi
    1402:	bf 01 00 00 00       	mov    $0x1,%edi
    1407:	b8 00 00 00 00       	mov    $0x0,%eax
    140c:	e8 31 2b 00 00       	callq  3f42 <printf>
    exit();
    1411:	e8 a3 29 00 00       	callq  3db9 <exit>
  }
  if(buf[0] != 'h'){
    1416:	0f b6 05 03 4f 00 00 	movzbl 0x4f03(%rip),%eax        # 6320 <buf>
    141d:	3c 68                	cmp    $0x68,%al
    141f:	74 1b                	je     143c <unlinkread+0x163>
    printf(1, "unlinkread wrong data\n");
    1421:	48 c7 c6 aa 4b 00 00 	mov    $0x4baa,%rsi
    1428:	bf 01 00 00 00       	mov    $0x1,%edi
    142d:	b8 00 00 00 00       	mov    $0x0,%eax
    1432:	e8 0b 2b 00 00       	callq  3f42 <printf>
    exit();
    1437:	e8 7d 29 00 00       	callq  3db9 <exit>
  }
  if(write(fd, buf, 10) != 10){
    143c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    143f:	ba 0a 00 00 00       	mov    $0xa,%edx
    1444:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    144b:	89 c7                	mov    %eax,%edi
    144d:	e8 87 29 00 00       	callq  3dd9 <write>
    1452:	83 f8 0a             	cmp    $0xa,%eax
    1455:	74 1b                	je     1472 <unlinkread+0x199>
    printf(1, "unlinkread write failed\n");
    1457:	48 c7 c6 c1 4b 00 00 	mov    $0x4bc1,%rsi
    145e:	bf 01 00 00 00       	mov    $0x1,%edi
    1463:	b8 00 00 00 00       	mov    $0x0,%eax
    1468:	e8 d5 2a 00 00       	callq  3f42 <printf>
    exit();
    146d:	e8 47 29 00 00       	callq  3db9 <exit>
  }
  close(fd);
    1472:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1475:	89 c7                	mov    %eax,%edi
    1477:	e8 65 29 00 00       	callq  3de1 <close>
  unlink("unlinkread");
    147c:	48 c7 c7 32 4b 00 00 	mov    $0x4b32,%rdi
    1483:	e8 81 29 00 00       	callq  3e09 <unlink>
  printf(1, "unlinkread ok\n");
    1488:	48 c7 c6 da 4b 00 00 	mov    $0x4bda,%rsi
    148f:	bf 01 00 00 00       	mov    $0x1,%edi
    1494:	b8 00 00 00 00       	mov    $0x0,%eax
    1499:	e8 a4 2a 00 00       	callq  3f42 <printf>
}
    149e:	90                   	nop
    149f:	c9                   	leaveq 
    14a0:	c3                   	retq   

00000000000014a1 <linktest>:

void
linktest(void)
{
    14a1:	55                   	push   %rbp
    14a2:	48 89 e5             	mov    %rsp,%rbp
    14a5:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;

  printf(1, "linktest\n");
    14a9:	48 c7 c6 e9 4b 00 00 	mov    $0x4be9,%rsi
    14b0:	bf 01 00 00 00       	mov    $0x1,%edi
    14b5:	b8 00 00 00 00       	mov    $0x0,%eax
    14ba:	e8 83 2a 00 00       	callq  3f42 <printf>

  unlink("lf1");
    14bf:	48 c7 c7 f3 4b 00 00 	mov    $0x4bf3,%rdi
    14c6:	e8 3e 29 00 00       	callq  3e09 <unlink>
  unlink("lf2");
    14cb:	48 c7 c7 f7 4b 00 00 	mov    $0x4bf7,%rdi
    14d2:	e8 32 29 00 00       	callq  3e09 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    14d7:	be 02 02 00 00       	mov    $0x202,%esi
    14dc:	48 c7 c7 f3 4b 00 00 	mov    $0x4bf3,%rdi
    14e3:	e8 11 29 00 00       	callq  3df9 <open>
    14e8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    14eb:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    14ef:	79 1b                	jns    150c <linktest+0x6b>
    printf(1, "create lf1 failed\n");
    14f1:	48 c7 c6 fb 4b 00 00 	mov    $0x4bfb,%rsi
    14f8:	bf 01 00 00 00       	mov    $0x1,%edi
    14fd:	b8 00 00 00 00       	mov    $0x0,%eax
    1502:	e8 3b 2a 00 00       	callq  3f42 <printf>
    exit();
    1507:	e8 ad 28 00 00       	callq  3db9 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    150c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    150f:	ba 05 00 00 00       	mov    $0x5,%edx
    1514:	48 c7 c6 57 4b 00 00 	mov    $0x4b57,%rsi
    151b:	89 c7                	mov    %eax,%edi
    151d:	e8 b7 28 00 00       	callq  3dd9 <write>
    1522:	83 f8 05             	cmp    $0x5,%eax
    1525:	74 1b                	je     1542 <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    1527:	48 c7 c6 0e 4c 00 00 	mov    $0x4c0e,%rsi
    152e:	bf 01 00 00 00       	mov    $0x1,%edi
    1533:	b8 00 00 00 00       	mov    $0x0,%eax
    1538:	e8 05 2a 00 00       	callq  3f42 <printf>
    exit();
    153d:	e8 77 28 00 00       	callq  3db9 <exit>
  }
  close(fd);
    1542:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1545:	89 c7                	mov    %eax,%edi
    1547:	e8 95 28 00 00       	callq  3de1 <close>

  if(link("lf1", "lf2") < 0){
    154c:	48 c7 c6 f7 4b 00 00 	mov    $0x4bf7,%rsi
    1553:	48 c7 c7 f3 4b 00 00 	mov    $0x4bf3,%rdi
    155a:	e8 ba 28 00 00       	callq  3e19 <link>
    155f:	85 c0                	test   %eax,%eax
    1561:	79 1b                	jns    157e <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    1563:	48 c7 c6 20 4c 00 00 	mov    $0x4c20,%rsi
    156a:	bf 01 00 00 00       	mov    $0x1,%edi
    156f:	b8 00 00 00 00       	mov    $0x0,%eax
    1574:	e8 c9 29 00 00       	callq  3f42 <printf>
    exit();
    1579:	e8 3b 28 00 00       	callq  3db9 <exit>
  }
  unlink("lf1");
    157e:	48 c7 c7 f3 4b 00 00 	mov    $0x4bf3,%rdi
    1585:	e8 7f 28 00 00       	callq  3e09 <unlink>

  if(open("lf1", 0) >= 0){
    158a:	be 00 00 00 00       	mov    $0x0,%esi
    158f:	48 c7 c7 f3 4b 00 00 	mov    $0x4bf3,%rdi
    1596:	e8 5e 28 00 00       	callq  3df9 <open>
    159b:	85 c0                	test   %eax,%eax
    159d:	78 1b                	js     15ba <linktest+0x119>
    printf(1, "unlinked lf1 but it is still there!\n");
    159f:	48 c7 c6 38 4c 00 00 	mov    $0x4c38,%rsi
    15a6:	bf 01 00 00 00       	mov    $0x1,%edi
    15ab:	b8 00 00 00 00       	mov    $0x0,%eax
    15b0:	e8 8d 29 00 00       	callq  3f42 <printf>
    exit();
    15b5:	e8 ff 27 00 00       	callq  3db9 <exit>
  }

  fd = open("lf2", 0);
    15ba:	be 00 00 00 00       	mov    $0x0,%esi
    15bf:	48 c7 c7 f7 4b 00 00 	mov    $0x4bf7,%rdi
    15c6:	e8 2e 28 00 00       	callq  3df9 <open>
    15cb:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    15ce:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    15d2:	79 1b                	jns    15ef <linktest+0x14e>
    printf(1, "open lf2 failed\n");
    15d4:	48 c7 c6 5d 4c 00 00 	mov    $0x4c5d,%rsi
    15db:	bf 01 00 00 00       	mov    $0x1,%edi
    15e0:	b8 00 00 00 00       	mov    $0x0,%eax
    15e5:	e8 58 29 00 00       	callq  3f42 <printf>
    exit();
    15ea:	e8 ca 27 00 00       	callq  3db9 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    15ef:	8b 45 fc             	mov    -0x4(%rbp),%eax
    15f2:	ba 00 20 00 00       	mov    $0x2000,%edx
    15f7:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    15fe:	89 c7                	mov    %eax,%edi
    1600:	e8 cc 27 00 00       	callq  3dd1 <read>
    1605:	83 f8 05             	cmp    $0x5,%eax
    1608:	74 1b                	je     1625 <linktest+0x184>
    printf(1, "read lf2 failed\n");
    160a:	48 c7 c6 6e 4c 00 00 	mov    $0x4c6e,%rsi
    1611:	bf 01 00 00 00       	mov    $0x1,%edi
    1616:	b8 00 00 00 00       	mov    $0x0,%eax
    161b:	e8 22 29 00 00       	callq  3f42 <printf>
    exit();
    1620:	e8 94 27 00 00       	callq  3db9 <exit>
  }
  close(fd);
    1625:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1628:	89 c7                	mov    %eax,%edi
    162a:	e8 b2 27 00 00       	callq  3de1 <close>

  if(link("lf2", "lf2") >= 0){
    162f:	48 c7 c6 f7 4b 00 00 	mov    $0x4bf7,%rsi
    1636:	48 c7 c7 f7 4b 00 00 	mov    $0x4bf7,%rdi
    163d:	e8 d7 27 00 00       	callq  3e19 <link>
    1642:	85 c0                	test   %eax,%eax
    1644:	78 1b                	js     1661 <linktest+0x1c0>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1646:	48 c7 c6 7f 4c 00 00 	mov    $0x4c7f,%rsi
    164d:	bf 01 00 00 00       	mov    $0x1,%edi
    1652:	b8 00 00 00 00       	mov    $0x0,%eax
    1657:	e8 e6 28 00 00       	callq  3f42 <printf>
    exit();
    165c:	e8 58 27 00 00       	callq  3db9 <exit>
  }

  unlink("lf2");
    1661:	48 c7 c7 f7 4b 00 00 	mov    $0x4bf7,%rdi
    1668:	e8 9c 27 00 00       	callq  3e09 <unlink>
  if(link("lf2", "lf1") >= 0){
    166d:	48 c7 c6 f3 4b 00 00 	mov    $0x4bf3,%rsi
    1674:	48 c7 c7 f7 4b 00 00 	mov    $0x4bf7,%rdi
    167b:	e8 99 27 00 00       	callq  3e19 <link>
    1680:	85 c0                	test   %eax,%eax
    1682:	78 1b                	js     169f <linktest+0x1fe>
    printf(1, "link non-existant succeeded! oops\n");
    1684:	48 c7 c6 a0 4c 00 00 	mov    $0x4ca0,%rsi
    168b:	bf 01 00 00 00       	mov    $0x1,%edi
    1690:	b8 00 00 00 00       	mov    $0x0,%eax
    1695:	e8 a8 28 00 00       	callq  3f42 <printf>
    exit();
    169a:	e8 1a 27 00 00       	callq  3db9 <exit>
  }

  if(link(".", "lf1") >= 0){
    169f:	48 c7 c6 f3 4b 00 00 	mov    $0x4bf3,%rsi
    16a6:	48 c7 c7 c3 4c 00 00 	mov    $0x4cc3,%rdi
    16ad:	e8 67 27 00 00       	callq  3e19 <link>
    16b2:	85 c0                	test   %eax,%eax
    16b4:	78 1b                	js     16d1 <linktest+0x230>
    printf(1, "link . lf1 succeeded! oops\n");
    16b6:	48 c7 c6 c5 4c 00 00 	mov    $0x4cc5,%rsi
    16bd:	bf 01 00 00 00       	mov    $0x1,%edi
    16c2:	b8 00 00 00 00       	mov    $0x0,%eax
    16c7:	e8 76 28 00 00       	callq  3f42 <printf>
    exit();
    16cc:	e8 e8 26 00 00       	callq  3db9 <exit>
  }

  printf(1, "linktest ok\n");
    16d1:	48 c7 c6 e1 4c 00 00 	mov    $0x4ce1,%rsi
    16d8:	bf 01 00 00 00       	mov    $0x1,%edi
    16dd:	b8 00 00 00 00       	mov    $0x0,%eax
    16e2:	e8 5b 28 00 00       	callq  3f42 <printf>
}
    16e7:	90                   	nop
    16e8:	c9                   	leaveq 
    16e9:	c3                   	retq   

00000000000016ea <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    16ea:	55                   	push   %rbp
    16eb:	48 89 e5             	mov    %rsp,%rbp
    16ee:	48 83 ec 50          	sub    $0x50,%rsp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    16f2:	48 c7 c6 ee 4c 00 00 	mov    $0x4cee,%rsi
    16f9:	bf 01 00 00 00       	mov    $0x1,%edi
    16fe:	b8 00 00 00 00       	mov    $0x0,%eax
    1703:	e8 3a 28 00 00       	callq  3f42 <printf>
  file[0] = 'C';
    1708:	c6 45 ed 43          	movb   $0x43,-0x13(%rbp)
  file[2] = '\0';
    170c:	c6 45 ef 00          	movb   $0x0,-0x11(%rbp)
  for(i = 0; i < 40; i++){
    1710:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    1717:	e9 f7 00 00 00       	jmpq   1813 <concreate+0x129>
    file[1] = '0' + i;
    171c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    171f:	83 c0 30             	add    $0x30,%eax
    1722:	88 45 ee             	mov    %al,-0x12(%rbp)
    unlink(file);
    1725:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1729:	48 89 c7             	mov    %rax,%rdi
    172c:	e8 d8 26 00 00       	callq  3e09 <unlink>
    pid = fork();
    1731:	e8 7b 26 00 00       	callq  3db1 <fork>
    1736:	89 45 f0             	mov    %eax,-0x10(%rbp)
    if(pid && (i % 3) == 1){
    1739:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    173d:	74 3a                	je     1779 <concreate+0x8f>
    173f:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    1742:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1747:	89 c8                	mov    %ecx,%eax
    1749:	f7 ea                	imul   %edx
    174b:	89 c8                	mov    %ecx,%eax
    174d:	c1 f8 1f             	sar    $0x1f,%eax
    1750:	29 c2                	sub    %eax,%edx
    1752:	89 d0                	mov    %edx,%eax
    1754:	01 c0                	add    %eax,%eax
    1756:	01 d0                	add    %edx,%eax
    1758:	29 c1                	sub    %eax,%ecx
    175a:	89 ca                	mov    %ecx,%edx
    175c:	83 fa 01             	cmp    $0x1,%edx
    175f:	75 18                	jne    1779 <concreate+0x8f>
      link("C0", file);
    1761:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1765:	48 89 c6             	mov    %rax,%rsi
    1768:	48 c7 c7 fe 4c 00 00 	mov    $0x4cfe,%rdi
    176f:	e8 a5 26 00 00       	callq  3e19 <link>
    1774:	e9 86 00 00 00       	jmpq   17ff <concreate+0x115>
    } else if(pid == 0 && (i % 5) == 1){
    1779:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    177d:	75 3a                	jne    17b9 <concreate+0xcf>
    177f:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    1782:	ba 67 66 66 66       	mov    $0x66666667,%edx
    1787:	89 c8                	mov    %ecx,%eax
    1789:	f7 ea                	imul   %edx
    178b:	d1 fa                	sar    %edx
    178d:	89 c8                	mov    %ecx,%eax
    178f:	c1 f8 1f             	sar    $0x1f,%eax
    1792:	29 c2                	sub    %eax,%edx
    1794:	89 d0                	mov    %edx,%eax
    1796:	c1 e0 02             	shl    $0x2,%eax
    1799:	01 d0                	add    %edx,%eax
    179b:	29 c1                	sub    %eax,%ecx
    179d:	89 ca                	mov    %ecx,%edx
    179f:	83 fa 01             	cmp    $0x1,%edx
    17a2:	75 15                	jne    17b9 <concreate+0xcf>
      link("C0", file);
    17a4:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    17a8:	48 89 c6             	mov    %rax,%rsi
    17ab:	48 c7 c7 fe 4c 00 00 	mov    $0x4cfe,%rdi
    17b2:	e8 62 26 00 00       	callq  3e19 <link>
    17b7:	eb 46                	jmp    17ff <concreate+0x115>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    17b9:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    17bd:	be 02 02 00 00       	mov    $0x202,%esi
    17c2:	48 89 c7             	mov    %rax,%rdi
    17c5:	e8 2f 26 00 00       	callq  3df9 <open>
    17ca:	89 45 f4             	mov    %eax,-0xc(%rbp)
      if(fd < 0){
    17cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    17d1:	79 22                	jns    17f5 <concreate+0x10b>
        printf(1, "concreate create %s failed\n", file);
    17d3:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    17d7:	48 89 c2             	mov    %rax,%rdx
    17da:	48 c7 c6 01 4d 00 00 	mov    $0x4d01,%rsi
    17e1:	bf 01 00 00 00       	mov    $0x1,%edi
    17e6:	b8 00 00 00 00       	mov    $0x0,%eax
    17eb:	e8 52 27 00 00       	callq  3f42 <printf>
        exit();
    17f0:	e8 c4 25 00 00       	callq  3db9 <exit>
      }
      close(fd);
    17f5:	8b 45 f4             	mov    -0xc(%rbp),%eax
    17f8:	89 c7                	mov    %eax,%edi
    17fa:	e8 e2 25 00 00       	callq  3de1 <close>
    }
    if(pid == 0)
    17ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    1803:	75 05                	jne    180a <concreate+0x120>
      exit();
    1805:	e8 af 25 00 00       	callq  3db9 <exit>
    else
      wait();
    180a:	e8 b2 25 00 00       	callq  3dc1 <wait>
  for(i = 0; i < 40; i++){
    180f:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    1813:	83 7d fc 27          	cmpl   $0x27,-0x4(%rbp)
    1817:	0f 8e ff fe ff ff    	jle    171c <concreate+0x32>
  }

  memset(fa, 0, sizeof(fa));
    181d:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
    1821:	ba 28 00 00 00       	mov    $0x28,%edx
    1826:	be 00 00 00 00       	mov    $0x0,%esi
    182b:	48 89 c7             	mov    %rax,%rdi
    182e:	e8 91 23 00 00       	callq  3bc4 <memset>
  fd = open(".", 0);
    1833:	be 00 00 00 00       	mov    $0x0,%esi
    1838:	48 c7 c7 c3 4c 00 00 	mov    $0x4cc3,%rdi
    183f:	e8 b5 25 00 00       	callq  3df9 <open>
    1844:	89 45 f4             	mov    %eax,-0xc(%rbp)
  n = 0;
    1847:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  while(read(fd, &de, sizeof(de)) > 0){
    184e:	e9 a9 00 00 00       	jmpq   18fc <concreate+0x212>
    if(de.inum == 0)
    1853:	0f b7 45 b0          	movzwl -0x50(%rbp),%eax
    1857:	66 85 c0             	test   %ax,%ax
    185a:	75 05                	jne    1861 <concreate+0x177>
      continue;
    185c:	e9 9b 00 00 00       	jmpq   18fc <concreate+0x212>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1861:	0f b6 45 b2          	movzbl -0x4e(%rbp),%eax
    1865:	3c 43                	cmp    $0x43,%al
    1867:	0f 85 8f 00 00 00    	jne    18fc <concreate+0x212>
    186d:	0f b6 45 b4          	movzbl -0x4c(%rbp),%eax
    1871:	84 c0                	test   %al,%al
    1873:	0f 85 83 00 00 00    	jne    18fc <concreate+0x212>
      i = de.name[1] - '0';
    1879:	0f b6 45 b3          	movzbl -0x4d(%rbp),%eax
    187d:	0f be c0             	movsbl %al,%eax
    1880:	83 e8 30             	sub    $0x30,%eax
    1883:	89 45 fc             	mov    %eax,-0x4(%rbp)
      if(i < 0 || i >= sizeof(fa)){
    1886:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    188a:	78 08                	js     1894 <concreate+0x1aa>
    188c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    188f:	83 f8 27             	cmp    $0x27,%eax
    1892:	76 26                	jbe    18ba <concreate+0x1d0>
        printf(1, "concreate weird file %s\n", de.name);
    1894:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
    1898:	48 83 c0 02          	add    $0x2,%rax
    189c:	48 89 c2             	mov    %rax,%rdx
    189f:	48 c7 c6 1d 4d 00 00 	mov    $0x4d1d,%rsi
    18a6:	bf 01 00 00 00       	mov    $0x1,%edi
    18ab:	b8 00 00 00 00       	mov    $0x0,%eax
    18b0:	e8 8d 26 00 00       	callq  3f42 <printf>
        exit();
    18b5:	e8 ff 24 00 00       	callq  3db9 <exit>
      }
      if(fa[i]){
    18ba:	8b 45 fc             	mov    -0x4(%rbp),%eax
    18bd:	48 98                	cltq   
    18bf:	0f b6 44 05 c0       	movzbl -0x40(%rbp,%rax,1),%eax
    18c4:	84 c0                	test   %al,%al
    18c6:	74 26                	je     18ee <concreate+0x204>
        printf(1, "concreate duplicate file %s\n", de.name);
    18c8:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
    18cc:	48 83 c0 02          	add    $0x2,%rax
    18d0:	48 89 c2             	mov    %rax,%rdx
    18d3:	48 c7 c6 36 4d 00 00 	mov    $0x4d36,%rsi
    18da:	bf 01 00 00 00       	mov    $0x1,%edi
    18df:	b8 00 00 00 00       	mov    $0x0,%eax
    18e4:	e8 59 26 00 00       	callq  3f42 <printf>
        exit();
    18e9:	e8 cb 24 00 00       	callq  3db9 <exit>
      }
      fa[i] = 1;
    18ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
    18f1:	48 98                	cltq   
    18f3:	c6 44 05 c0 01       	movb   $0x1,-0x40(%rbp,%rax,1)
      n++;
    18f8:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  while(read(fd, &de, sizeof(de)) > 0){
    18fc:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
    1900:	8b 45 f4             	mov    -0xc(%rbp),%eax
    1903:	ba 10 00 00 00       	mov    $0x10,%edx
    1908:	48 89 ce             	mov    %rcx,%rsi
    190b:	89 c7                	mov    %eax,%edi
    190d:	e8 bf 24 00 00       	callq  3dd1 <read>
    1912:	85 c0                	test   %eax,%eax
    1914:	0f 8f 39 ff ff ff    	jg     1853 <concreate+0x169>
    }
  }
  close(fd);
    191a:	8b 45 f4             	mov    -0xc(%rbp),%eax
    191d:	89 c7                	mov    %eax,%edi
    191f:	e8 bd 24 00 00       	callq  3de1 <close>

  if(n != 40){
    1924:	83 7d f8 28          	cmpl   $0x28,-0x8(%rbp)
    1928:	74 1b                	je     1945 <concreate+0x25b>
    printf(1, "concreate not enough files in directory listing\n");
    192a:	48 c7 c6 58 4d 00 00 	mov    $0x4d58,%rsi
    1931:	bf 01 00 00 00       	mov    $0x1,%edi
    1936:	b8 00 00 00 00       	mov    $0x0,%eax
    193b:	e8 02 26 00 00       	callq  3f42 <printf>
    exit();
    1940:	e8 74 24 00 00       	callq  3db9 <exit>
  }

  for(i = 0; i < 40; i++){
    1945:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    194c:	e9 29 01 00 00       	jmpq   1a7a <concreate+0x390>
    file[1] = '0' + i;
    1951:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1954:	83 c0 30             	add    $0x30,%eax
    1957:	88 45 ee             	mov    %al,-0x12(%rbp)
    pid = fork();
    195a:	e8 52 24 00 00       	callq  3db1 <fork>
    195f:	89 45 f0             	mov    %eax,-0x10(%rbp)
    if(pid < 0){
    1962:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    1966:	79 1b                	jns    1983 <concreate+0x299>
      printf(1, "fork failed\n");
    1968:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
    196f:	bf 01 00 00 00       	mov    $0x1,%edi
    1974:	b8 00 00 00 00       	mov    $0x0,%eax
    1979:	e8 c4 25 00 00       	callq  3f42 <printf>
      exit();
    197e:	e8 36 24 00 00       	callq  3db9 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1983:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    1986:	ba 56 55 55 55       	mov    $0x55555556,%edx
    198b:	89 c8                	mov    %ecx,%eax
    198d:	f7 ea                	imul   %edx
    198f:	89 c8                	mov    %ecx,%eax
    1991:	c1 f8 1f             	sar    $0x1f,%eax
    1994:	29 c2                	sub    %eax,%edx
    1996:	89 d0                	mov    %edx,%eax
    1998:	89 c2                	mov    %eax,%edx
    199a:	01 d2                	add    %edx,%edx
    199c:	01 c2                	add    %eax,%edx
    199e:	89 c8                	mov    %ecx,%eax
    19a0:	29 d0                	sub    %edx,%eax
    19a2:	85 c0                	test   %eax,%eax
    19a4:	75 06                	jne    19ac <concreate+0x2c2>
    19a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    19aa:	74 28                	je     19d4 <concreate+0x2ea>
       ((i % 3) == 1 && pid != 0)){
    19ac:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    19af:	ba 56 55 55 55       	mov    $0x55555556,%edx
    19b4:	89 c8                	mov    %ecx,%eax
    19b6:	f7 ea                	imul   %edx
    19b8:	89 c8                	mov    %ecx,%eax
    19ba:	c1 f8 1f             	sar    $0x1f,%eax
    19bd:	29 c2                	sub    %eax,%edx
    19bf:	89 d0                	mov    %edx,%eax
    19c1:	01 c0                	add    %eax,%eax
    19c3:	01 d0                	add    %edx,%eax
    19c5:	29 c1                	sub    %eax,%ecx
    19c7:	89 ca                	mov    %ecx,%edx
    if(((i % 3) == 0 && pid == 0) ||
    19c9:	83 fa 01             	cmp    $0x1,%edx
    19cc:	75 68                	jne    1a36 <concreate+0x34c>
       ((i % 3) == 1 && pid != 0)){
    19ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    19d2:	74 62                	je     1a36 <concreate+0x34c>
      close(open(file, 0));
    19d4:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    19d8:	be 00 00 00 00       	mov    $0x0,%esi
    19dd:	48 89 c7             	mov    %rax,%rdi
    19e0:	e8 14 24 00 00       	callq  3df9 <open>
    19e5:	89 c7                	mov    %eax,%edi
    19e7:	e8 f5 23 00 00       	callq  3de1 <close>
      close(open(file, 0));
    19ec:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    19f0:	be 00 00 00 00       	mov    $0x0,%esi
    19f5:	48 89 c7             	mov    %rax,%rdi
    19f8:	e8 fc 23 00 00       	callq  3df9 <open>
    19fd:	89 c7                	mov    %eax,%edi
    19ff:	e8 dd 23 00 00       	callq  3de1 <close>
      close(open(file, 0));
    1a04:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a08:	be 00 00 00 00       	mov    $0x0,%esi
    1a0d:	48 89 c7             	mov    %rax,%rdi
    1a10:	e8 e4 23 00 00       	callq  3df9 <open>
    1a15:	89 c7                	mov    %eax,%edi
    1a17:	e8 c5 23 00 00       	callq  3de1 <close>
      close(open(file, 0));
    1a1c:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a20:	be 00 00 00 00       	mov    $0x0,%esi
    1a25:	48 89 c7             	mov    %rax,%rdi
    1a28:	e8 cc 23 00 00       	callq  3df9 <open>
    1a2d:	89 c7                	mov    %eax,%edi
    1a2f:	e8 ad 23 00 00       	callq  3de1 <close>
    1a34:	eb 30                	jmp    1a66 <concreate+0x37c>
    } else {
      unlink(file);
    1a36:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a3a:	48 89 c7             	mov    %rax,%rdi
    1a3d:	e8 c7 23 00 00       	callq  3e09 <unlink>
      unlink(file);
    1a42:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a46:	48 89 c7             	mov    %rax,%rdi
    1a49:	e8 bb 23 00 00       	callq  3e09 <unlink>
      unlink(file);
    1a4e:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a52:	48 89 c7             	mov    %rax,%rdi
    1a55:	e8 af 23 00 00       	callq  3e09 <unlink>
      unlink(file);
    1a5a:	48 8d 45 ed          	lea    -0x13(%rbp),%rax
    1a5e:	48 89 c7             	mov    %rax,%rdi
    1a61:	e8 a3 23 00 00       	callq  3e09 <unlink>
    }
    if(pid == 0)
    1a66:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    1a6a:	75 05                	jne    1a71 <concreate+0x387>
      exit();
    1a6c:	e8 48 23 00 00       	callq  3db9 <exit>
    else
      wait();
    1a71:	e8 4b 23 00 00       	callq  3dc1 <wait>
  for(i = 0; i < 40; i++){
    1a76:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    1a7a:	83 7d fc 27          	cmpl   $0x27,-0x4(%rbp)
    1a7e:	0f 8e cd fe ff ff    	jle    1951 <concreate+0x267>
  }

  printf(1, "concreate ok\n");
    1a84:	48 c7 c6 89 4d 00 00 	mov    $0x4d89,%rsi
    1a8b:	bf 01 00 00 00       	mov    $0x1,%edi
    1a90:	b8 00 00 00 00       	mov    $0x0,%eax
    1a95:	e8 a8 24 00 00       	callq  3f42 <printf>
}
    1a9a:	90                   	nop
    1a9b:	c9                   	leaveq 
    1a9c:	c3                   	retq   

0000000000001a9d <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1a9d:	55                   	push   %rbp
    1a9e:	48 89 e5             	mov    %rsp,%rbp
    1aa1:	48 83 ec 10          	sub    $0x10,%rsp
  int pid, i;

  printf(1, "linkunlink test\n");
    1aa5:	48 c7 c6 97 4d 00 00 	mov    $0x4d97,%rsi
    1aac:	bf 01 00 00 00       	mov    $0x1,%edi
    1ab1:	b8 00 00 00 00       	mov    $0x0,%eax
    1ab6:	e8 87 24 00 00       	callq  3f42 <printf>

  unlink("x");
    1abb:	48 c7 c7 f2 48 00 00 	mov    $0x48f2,%rdi
    1ac2:	e8 42 23 00 00       	callq  3e09 <unlink>
  pid = fork();
    1ac7:	e8 e5 22 00 00       	callq  3db1 <fork>
    1acc:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(pid < 0){
    1acf:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1ad3:	79 1b                	jns    1af0 <linkunlink+0x53>
    printf(1, "fork failed\n");
    1ad5:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
    1adc:	bf 01 00 00 00       	mov    $0x1,%edi
    1ae1:	b8 00 00 00 00       	mov    $0x0,%eax
    1ae6:	e8 57 24 00 00       	callq  3f42 <printf>
    exit();
    1aeb:	e8 c9 22 00 00       	callq  3db9 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1af0:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1af4:	74 07                	je     1afd <linkunlink+0x60>
    1af6:	b8 01 00 00 00       	mov    $0x1,%eax
    1afb:	eb 05                	jmp    1b02 <linkunlink+0x65>
    1afd:	b8 61 00 00 00       	mov    $0x61,%eax
    1b02:	89 45 f8             	mov    %eax,-0x8(%rbp)
  for(i = 0; i < 100; i++){
    1b05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    1b0c:	e9 8b 00 00 00       	jmpq   1b9c <linkunlink+0xff>
    x = x * 1103515245 + 12345;
    1b11:	8b 45 f8             	mov    -0x8(%rbp),%eax
    1b14:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1b1a:	05 39 30 00 00       	add    $0x3039,%eax
    1b1f:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if((x % 3) == 0){
    1b22:	8b 4d f8             	mov    -0x8(%rbp),%ecx
    1b25:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1b2a:	89 c8                	mov    %ecx,%eax
    1b2c:	f7 e2                	mul    %edx
    1b2e:	89 d0                	mov    %edx,%eax
    1b30:	d1 e8                	shr    %eax
    1b32:	89 c2                	mov    %eax,%edx
    1b34:	01 d2                	add    %edx,%edx
    1b36:	01 c2                	add    %eax,%edx
    1b38:	89 c8                	mov    %ecx,%eax
    1b3a:	29 d0                	sub    %edx,%eax
    1b3c:	85 c0                	test   %eax,%eax
    1b3e:	75 1a                	jne    1b5a <linkunlink+0xbd>
      close(open("x", O_RDWR | O_CREATE));
    1b40:	be 02 02 00 00       	mov    $0x202,%esi
    1b45:	48 c7 c7 f2 48 00 00 	mov    $0x48f2,%rdi
    1b4c:	e8 a8 22 00 00       	callq  3df9 <open>
    1b51:	89 c7                	mov    %eax,%edi
    1b53:	e8 89 22 00 00       	callq  3de1 <close>
    1b58:	eb 3e                	jmp    1b98 <linkunlink+0xfb>
    } else if((x % 3) == 1){
    1b5a:	8b 4d f8             	mov    -0x8(%rbp),%ecx
    1b5d:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1b62:	89 c8                	mov    %ecx,%eax
    1b64:	f7 e2                	mul    %edx
    1b66:	d1 ea                	shr    %edx
    1b68:	89 d0                	mov    %edx,%eax
    1b6a:	01 c0                	add    %eax,%eax
    1b6c:	01 d0                	add    %edx,%eax
    1b6e:	29 c1                	sub    %eax,%ecx
    1b70:	89 ca                	mov    %ecx,%edx
    1b72:	83 fa 01             	cmp    $0x1,%edx
    1b75:	75 15                	jne    1b8c <linkunlink+0xef>
      link("cat", "x");
    1b77:	48 c7 c6 f2 48 00 00 	mov    $0x48f2,%rsi
    1b7e:	48 c7 c7 a8 4d 00 00 	mov    $0x4da8,%rdi
    1b85:	e8 8f 22 00 00       	callq  3e19 <link>
    1b8a:	eb 0c                	jmp    1b98 <linkunlink+0xfb>
    } else {
      unlink("x");
    1b8c:	48 c7 c7 f2 48 00 00 	mov    $0x48f2,%rdi
    1b93:	e8 71 22 00 00       	callq  3e09 <unlink>
  for(i = 0; i < 100; i++){
    1b98:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    1b9c:	83 7d fc 63          	cmpl   $0x63,-0x4(%rbp)
    1ba0:	0f 8e 6b ff ff ff    	jle    1b11 <linkunlink+0x74>
    }
  }

  if(pid)
    1ba6:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    1baa:	74 07                	je     1bb3 <linkunlink+0x116>
    wait();
    1bac:	e8 10 22 00 00       	callq  3dc1 <wait>
    1bb1:	eb 05                	jmp    1bb8 <linkunlink+0x11b>
  else 
    exit();
    1bb3:	e8 01 22 00 00       	callq  3db9 <exit>

  printf(1, "linkunlink ok\n");
    1bb8:	48 c7 c6 ac 4d 00 00 	mov    $0x4dac,%rsi
    1bbf:	bf 01 00 00 00       	mov    $0x1,%edi
    1bc4:	b8 00 00 00 00       	mov    $0x0,%eax
    1bc9:	e8 74 23 00 00       	callq  3f42 <printf>
}
    1bce:	90                   	nop
    1bcf:	c9                   	leaveq 
    1bd0:	c3                   	retq   

0000000000001bd1 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1bd1:	55                   	push   %rbp
    1bd2:	48 89 e5             	mov    %rsp,%rbp
    1bd5:	48 83 ec 20          	sub    $0x20,%rsp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1bd9:	48 c7 c6 bb 4d 00 00 	mov    $0x4dbb,%rsi
    1be0:	bf 01 00 00 00       	mov    $0x1,%edi
    1be5:	b8 00 00 00 00       	mov    $0x0,%eax
    1bea:	e8 53 23 00 00       	callq  3f42 <printf>
  unlink("bd");
    1bef:	48 c7 c7 c8 4d 00 00 	mov    $0x4dc8,%rdi
    1bf6:	e8 0e 22 00 00       	callq  3e09 <unlink>

  fd = open("bd", O_CREATE);
    1bfb:	be 00 02 00 00       	mov    $0x200,%esi
    1c00:	48 c7 c7 c8 4d 00 00 	mov    $0x4dc8,%rdi
    1c07:	e8 ed 21 00 00       	callq  3df9 <open>
    1c0c:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(fd < 0){
    1c0f:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    1c13:	79 1b                	jns    1c30 <bigdir+0x5f>
    printf(1, "bigdir create failed\n");
    1c15:	48 c7 c6 cb 4d 00 00 	mov    $0x4dcb,%rsi
    1c1c:	bf 01 00 00 00       	mov    $0x1,%edi
    1c21:	b8 00 00 00 00       	mov    $0x0,%eax
    1c26:	e8 17 23 00 00       	callq  3f42 <printf>
    exit();
    1c2b:	e8 89 21 00 00       	callq  3db9 <exit>
  }
  close(fd);
    1c30:	8b 45 f8             	mov    -0x8(%rbp),%eax
    1c33:	89 c7                	mov    %eax,%edi
    1c35:	e8 a7 21 00 00       	callq  3de1 <close>

  for(i = 0; i < 500; i++){
    1c3a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    1c41:	eb 66                	jmp    1ca9 <bigdir+0xd8>
    name[0] = 'x';
    1c43:	c6 45 ee 78          	movb   $0x78,-0x12(%rbp)
    name[1] = '0' + (i / 64);
    1c47:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1c4a:	8d 50 3f             	lea    0x3f(%rax),%edx
    1c4d:	85 c0                	test   %eax,%eax
    1c4f:	0f 48 c2             	cmovs  %edx,%eax
    1c52:	c1 f8 06             	sar    $0x6,%eax
    1c55:	83 c0 30             	add    $0x30,%eax
    1c58:	88 45 ef             	mov    %al,-0x11(%rbp)
    name[2] = '0' + (i % 64);
    1c5b:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1c5e:	99                   	cltd   
    1c5f:	c1 ea 1a             	shr    $0x1a,%edx
    1c62:	01 d0                	add    %edx,%eax
    1c64:	83 e0 3f             	and    $0x3f,%eax
    1c67:	29 d0                	sub    %edx,%eax
    1c69:	83 c0 30             	add    $0x30,%eax
    1c6c:	88 45 f0             	mov    %al,-0x10(%rbp)
    name[3] = '\0';
    1c6f:	c6 45 f1 00          	movb   $0x0,-0xf(%rbp)
    if(link("bd", name) != 0){
    1c73:	48 8d 45 ee          	lea    -0x12(%rbp),%rax
    1c77:	48 89 c6             	mov    %rax,%rsi
    1c7a:	48 c7 c7 c8 4d 00 00 	mov    $0x4dc8,%rdi
    1c81:	e8 93 21 00 00       	callq  3e19 <link>
    1c86:	85 c0                	test   %eax,%eax
    1c88:	74 1b                	je     1ca5 <bigdir+0xd4>
      printf(1, "bigdir link failed\n");
    1c8a:	48 c7 c6 e1 4d 00 00 	mov    $0x4de1,%rsi
    1c91:	bf 01 00 00 00       	mov    $0x1,%edi
    1c96:	b8 00 00 00 00       	mov    $0x0,%eax
    1c9b:	e8 a2 22 00 00       	callq  3f42 <printf>
      exit();
    1ca0:	e8 14 21 00 00       	callq  3db9 <exit>
  for(i = 0; i < 500; i++){
    1ca5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    1ca9:	81 7d fc f3 01 00 00 	cmpl   $0x1f3,-0x4(%rbp)
    1cb0:	7e 91                	jle    1c43 <bigdir+0x72>
    }
  }

  unlink("bd");
    1cb2:	48 c7 c7 c8 4d 00 00 	mov    $0x4dc8,%rdi
    1cb9:	e8 4b 21 00 00       	callq  3e09 <unlink>
  for(i = 0; i < 500; i++){
    1cbe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    1cc5:	eb 5f                	jmp    1d26 <bigdir+0x155>
    name[0] = 'x';
    1cc7:	c6 45 ee 78          	movb   $0x78,-0x12(%rbp)
    name[1] = '0' + (i / 64);
    1ccb:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1cce:	8d 50 3f             	lea    0x3f(%rax),%edx
    1cd1:	85 c0                	test   %eax,%eax
    1cd3:	0f 48 c2             	cmovs  %edx,%eax
    1cd6:	c1 f8 06             	sar    $0x6,%eax
    1cd9:	83 c0 30             	add    $0x30,%eax
    1cdc:	88 45 ef             	mov    %al,-0x11(%rbp)
    name[2] = '0' + (i % 64);
    1cdf:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1ce2:	99                   	cltd   
    1ce3:	c1 ea 1a             	shr    $0x1a,%edx
    1ce6:	01 d0                	add    %edx,%eax
    1ce8:	83 e0 3f             	and    $0x3f,%eax
    1ceb:	29 d0                	sub    %edx,%eax
    1ced:	83 c0 30             	add    $0x30,%eax
    1cf0:	88 45 f0             	mov    %al,-0x10(%rbp)
    name[3] = '\0';
    1cf3:	c6 45 f1 00          	movb   $0x0,-0xf(%rbp)
    if(unlink(name) != 0){
    1cf7:	48 8d 45 ee          	lea    -0x12(%rbp),%rax
    1cfb:	48 89 c7             	mov    %rax,%rdi
    1cfe:	e8 06 21 00 00       	callq  3e09 <unlink>
    1d03:	85 c0                	test   %eax,%eax
    1d05:	74 1b                	je     1d22 <bigdir+0x151>
      printf(1, "bigdir unlink failed");
    1d07:	48 c7 c6 f5 4d 00 00 	mov    $0x4df5,%rsi
    1d0e:	bf 01 00 00 00       	mov    $0x1,%edi
    1d13:	b8 00 00 00 00       	mov    $0x0,%eax
    1d18:	e8 25 22 00 00       	callq  3f42 <printf>
      exit();
    1d1d:	e8 97 20 00 00       	callq  3db9 <exit>
  for(i = 0; i < 500; i++){
    1d22:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    1d26:	81 7d fc f3 01 00 00 	cmpl   $0x1f3,-0x4(%rbp)
    1d2d:	7e 98                	jle    1cc7 <bigdir+0xf6>
    }
  }

  printf(1, "bigdir ok\n");
    1d2f:	48 c7 c6 0a 4e 00 00 	mov    $0x4e0a,%rsi
    1d36:	bf 01 00 00 00       	mov    $0x1,%edi
    1d3b:	b8 00 00 00 00       	mov    $0x0,%eax
    1d40:	e8 fd 21 00 00       	callq  3f42 <printf>
}
    1d45:	90                   	nop
    1d46:	c9                   	leaveq 
    1d47:	c3                   	retq   

0000000000001d48 <subdir>:

void
subdir(void)
{
    1d48:	55                   	push   %rbp
    1d49:	48 89 e5             	mov    %rsp,%rbp
    1d4c:	48 83 ec 10          	sub    $0x10,%rsp
  int fd, cc;

  printf(1, "subdir test\n");
    1d50:	48 c7 c6 15 4e 00 00 	mov    $0x4e15,%rsi
    1d57:	bf 01 00 00 00       	mov    $0x1,%edi
    1d5c:	b8 00 00 00 00       	mov    $0x0,%eax
    1d61:	e8 dc 21 00 00       	callq  3f42 <printf>

  unlink("ff");
    1d66:	48 c7 c7 22 4e 00 00 	mov    $0x4e22,%rdi
    1d6d:	e8 97 20 00 00       	callq  3e09 <unlink>
  if(mkdir("dd") != 0){
    1d72:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    1d79:	e8 a3 20 00 00       	callq  3e21 <mkdir>
    1d7e:	85 c0                	test   %eax,%eax
    1d80:	74 1b                	je     1d9d <subdir+0x55>
    printf(1, "subdir mkdir dd failed\n");
    1d82:	48 c7 c6 28 4e 00 00 	mov    $0x4e28,%rsi
    1d89:	bf 01 00 00 00       	mov    $0x1,%edi
    1d8e:	b8 00 00 00 00       	mov    $0x0,%eax
    1d93:	e8 aa 21 00 00       	callq  3f42 <printf>
    exit();
    1d98:	e8 1c 20 00 00       	callq  3db9 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1d9d:	be 02 02 00 00       	mov    $0x202,%esi
    1da2:	48 c7 c7 40 4e 00 00 	mov    $0x4e40,%rdi
    1da9:	e8 4b 20 00 00       	callq  3df9 <open>
    1dae:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    1db1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1db5:	79 1b                	jns    1dd2 <subdir+0x8a>
    printf(1, "create dd/ff failed\n");
    1db7:	48 c7 c6 46 4e 00 00 	mov    $0x4e46,%rsi
    1dbe:	bf 01 00 00 00       	mov    $0x1,%edi
    1dc3:	b8 00 00 00 00       	mov    $0x0,%eax
    1dc8:	e8 75 21 00 00       	callq  3f42 <printf>
    exit();
    1dcd:	e8 e7 1f 00 00       	callq  3db9 <exit>
  }
  write(fd, "ff", 2);
    1dd2:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1dd5:	ba 02 00 00 00       	mov    $0x2,%edx
    1dda:	48 c7 c6 22 4e 00 00 	mov    $0x4e22,%rsi
    1de1:	89 c7                	mov    %eax,%edi
    1de3:	e8 f1 1f 00 00       	callq  3dd9 <write>
  close(fd);
    1de8:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1deb:	89 c7                	mov    %eax,%edi
    1ded:	e8 ef 1f 00 00       	callq  3de1 <close>
  
  if(unlink("dd") >= 0){
    1df2:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    1df9:	e8 0b 20 00 00       	callq  3e09 <unlink>
    1dfe:	85 c0                	test   %eax,%eax
    1e00:	78 1b                	js     1e1d <subdir+0xd5>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1e02:	48 c7 c6 60 4e 00 00 	mov    $0x4e60,%rsi
    1e09:	bf 01 00 00 00       	mov    $0x1,%edi
    1e0e:	b8 00 00 00 00       	mov    $0x0,%eax
    1e13:	e8 2a 21 00 00       	callq  3f42 <printf>
    exit();
    1e18:	e8 9c 1f 00 00       	callq  3db9 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    1e1d:	48 c7 c7 86 4e 00 00 	mov    $0x4e86,%rdi
    1e24:	e8 f8 1f 00 00       	callq  3e21 <mkdir>
    1e29:	85 c0                	test   %eax,%eax
    1e2b:	74 1b                	je     1e48 <subdir+0x100>
    printf(1, "subdir mkdir dd/dd failed\n");
    1e2d:	48 c7 c6 8d 4e 00 00 	mov    $0x4e8d,%rsi
    1e34:	bf 01 00 00 00       	mov    $0x1,%edi
    1e39:	b8 00 00 00 00       	mov    $0x0,%eax
    1e3e:	e8 ff 20 00 00       	callq  3f42 <printf>
    exit();
    1e43:	e8 71 1f 00 00       	callq  3db9 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1e48:	be 02 02 00 00       	mov    $0x202,%esi
    1e4d:	48 c7 c7 a8 4e 00 00 	mov    $0x4ea8,%rdi
    1e54:	e8 a0 1f 00 00       	callq  3df9 <open>
    1e59:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    1e5c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1e60:	79 1b                	jns    1e7d <subdir+0x135>
    printf(1, "create dd/dd/ff failed\n");
    1e62:	48 c7 c6 b1 4e 00 00 	mov    $0x4eb1,%rsi
    1e69:	bf 01 00 00 00       	mov    $0x1,%edi
    1e6e:	b8 00 00 00 00       	mov    $0x0,%eax
    1e73:	e8 ca 20 00 00       	callq  3f42 <printf>
    exit();
    1e78:	e8 3c 1f 00 00       	callq  3db9 <exit>
  }
  write(fd, "FF", 2);
    1e7d:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1e80:	ba 02 00 00 00       	mov    $0x2,%edx
    1e85:	48 c7 c6 c9 4e 00 00 	mov    $0x4ec9,%rsi
    1e8c:	89 c7                	mov    %eax,%edi
    1e8e:	e8 46 1f 00 00       	callq  3dd9 <write>
  close(fd);
    1e93:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1e96:	89 c7                	mov    %eax,%edi
    1e98:	e8 44 1f 00 00       	callq  3de1 <close>

  fd = open("dd/dd/../ff", 0);
    1e9d:	be 00 00 00 00       	mov    $0x0,%esi
    1ea2:	48 c7 c7 cc 4e 00 00 	mov    $0x4ecc,%rdi
    1ea9:	e8 4b 1f 00 00       	callq  3df9 <open>
    1eae:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    1eb1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    1eb5:	79 1b                	jns    1ed2 <subdir+0x18a>
    printf(1, "open dd/dd/../ff failed\n");
    1eb7:	48 c7 c6 d8 4e 00 00 	mov    $0x4ed8,%rsi
    1ebe:	bf 01 00 00 00       	mov    $0x1,%edi
    1ec3:	b8 00 00 00 00       	mov    $0x0,%eax
    1ec8:	e8 75 20 00 00       	callq  3f42 <printf>
    exit();
    1ecd:	e8 e7 1e 00 00       	callq  3db9 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    1ed2:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1ed5:	ba 00 20 00 00       	mov    $0x2000,%edx
    1eda:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    1ee1:	89 c7                	mov    %eax,%edi
    1ee3:	e8 e9 1e 00 00       	callq  3dd1 <read>
    1ee8:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(cc != 2 || buf[0] != 'f'){
    1eeb:	83 7d f8 02          	cmpl   $0x2,-0x8(%rbp)
    1eef:	75 0b                	jne    1efc <subdir+0x1b4>
    1ef1:	0f b6 05 28 44 00 00 	movzbl 0x4428(%rip),%eax        # 6320 <buf>
    1ef8:	3c 66                	cmp    $0x66,%al
    1efa:	74 1b                	je     1f17 <subdir+0x1cf>
    printf(1, "dd/dd/../ff wrong content\n");
    1efc:	48 c7 c6 f1 4e 00 00 	mov    $0x4ef1,%rsi
    1f03:	bf 01 00 00 00       	mov    $0x1,%edi
    1f08:	b8 00 00 00 00       	mov    $0x0,%eax
    1f0d:	e8 30 20 00 00       	callq  3f42 <printf>
    exit();
    1f12:	e8 a2 1e 00 00       	callq  3db9 <exit>
  }
  close(fd);
    1f17:	8b 45 fc             	mov    -0x4(%rbp),%eax
    1f1a:	89 c7                	mov    %eax,%edi
    1f1c:	e8 c0 1e 00 00       	callq  3de1 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1f21:	48 c7 c6 0c 4f 00 00 	mov    $0x4f0c,%rsi
    1f28:	48 c7 c7 a8 4e 00 00 	mov    $0x4ea8,%rdi
    1f2f:	e8 e5 1e 00 00       	callq  3e19 <link>
    1f34:	85 c0                	test   %eax,%eax
    1f36:	74 1b                	je     1f53 <subdir+0x20b>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1f38:	48 c7 c6 18 4f 00 00 	mov    $0x4f18,%rsi
    1f3f:	bf 01 00 00 00       	mov    $0x1,%edi
    1f44:	b8 00 00 00 00       	mov    $0x0,%eax
    1f49:	e8 f4 1f 00 00       	callq  3f42 <printf>
    exit();
    1f4e:	e8 66 1e 00 00       	callq  3db9 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    1f53:	48 c7 c7 a8 4e 00 00 	mov    $0x4ea8,%rdi
    1f5a:	e8 aa 1e 00 00       	callq  3e09 <unlink>
    1f5f:	85 c0                	test   %eax,%eax
    1f61:	74 1b                	je     1f7e <subdir+0x236>
    printf(1, "unlink dd/dd/ff failed\n");
    1f63:	48 c7 c6 39 4f 00 00 	mov    $0x4f39,%rsi
    1f6a:	bf 01 00 00 00       	mov    $0x1,%edi
    1f6f:	b8 00 00 00 00       	mov    $0x0,%eax
    1f74:	e8 c9 1f 00 00       	callq  3f42 <printf>
    exit();
    1f79:	e8 3b 1e 00 00       	callq  3db9 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1f7e:	be 00 00 00 00       	mov    $0x0,%esi
    1f83:	48 c7 c7 a8 4e 00 00 	mov    $0x4ea8,%rdi
    1f8a:	e8 6a 1e 00 00       	callq  3df9 <open>
    1f8f:	85 c0                	test   %eax,%eax
    1f91:	78 1b                	js     1fae <subdir+0x266>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    1f93:	48 c7 c6 58 4f 00 00 	mov    $0x4f58,%rsi
    1f9a:	bf 01 00 00 00       	mov    $0x1,%edi
    1f9f:	b8 00 00 00 00       	mov    $0x0,%eax
    1fa4:	e8 99 1f 00 00       	callq  3f42 <printf>
    exit();
    1fa9:	e8 0b 1e 00 00       	callq  3db9 <exit>
  }

  if(chdir("dd") != 0){
    1fae:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    1fb5:	e8 6f 1e 00 00       	callq  3e29 <chdir>
    1fba:	85 c0                	test   %eax,%eax
    1fbc:	74 1b                	je     1fd9 <subdir+0x291>
    printf(1, "chdir dd failed\n");
    1fbe:	48 c7 c6 7c 4f 00 00 	mov    $0x4f7c,%rsi
    1fc5:	bf 01 00 00 00       	mov    $0x1,%edi
    1fca:	b8 00 00 00 00       	mov    $0x0,%eax
    1fcf:	e8 6e 1f 00 00       	callq  3f42 <printf>
    exit();
    1fd4:	e8 e0 1d 00 00       	callq  3db9 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    1fd9:	48 c7 c7 8d 4f 00 00 	mov    $0x4f8d,%rdi
    1fe0:	e8 44 1e 00 00       	callq  3e29 <chdir>
    1fe5:	85 c0                	test   %eax,%eax
    1fe7:	74 1b                	je     2004 <subdir+0x2bc>
    printf(1, "chdir dd/../../dd failed\n");
    1fe9:	48 c7 c6 99 4f 00 00 	mov    $0x4f99,%rsi
    1ff0:	bf 01 00 00 00       	mov    $0x1,%edi
    1ff5:	b8 00 00 00 00       	mov    $0x0,%eax
    1ffa:	e8 43 1f 00 00       	callq  3f42 <printf>
    exit();
    1fff:	e8 b5 1d 00 00       	callq  3db9 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    2004:	48 c7 c7 b3 4f 00 00 	mov    $0x4fb3,%rdi
    200b:	e8 19 1e 00 00       	callq  3e29 <chdir>
    2010:	85 c0                	test   %eax,%eax
    2012:	74 1b                	je     202f <subdir+0x2e7>
    printf(1, "chdir dd/../../dd failed\n");
    2014:	48 c7 c6 99 4f 00 00 	mov    $0x4f99,%rsi
    201b:	bf 01 00 00 00       	mov    $0x1,%edi
    2020:	b8 00 00 00 00       	mov    $0x0,%eax
    2025:	e8 18 1f 00 00       	callq  3f42 <printf>
    exit();
    202a:	e8 8a 1d 00 00       	callq  3db9 <exit>
  }
  if(chdir("./..") != 0){
    202f:	48 c7 c7 c2 4f 00 00 	mov    $0x4fc2,%rdi
    2036:	e8 ee 1d 00 00       	callq  3e29 <chdir>
    203b:	85 c0                	test   %eax,%eax
    203d:	74 1b                	je     205a <subdir+0x312>
    printf(1, "chdir ./.. failed\n");
    203f:	48 c7 c6 c7 4f 00 00 	mov    $0x4fc7,%rsi
    2046:	bf 01 00 00 00       	mov    $0x1,%edi
    204b:	b8 00 00 00 00       	mov    $0x0,%eax
    2050:	e8 ed 1e 00 00       	callq  3f42 <printf>
    exit();
    2055:	e8 5f 1d 00 00       	callq  3db9 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    205a:	be 00 00 00 00       	mov    $0x0,%esi
    205f:	48 c7 c7 0c 4f 00 00 	mov    $0x4f0c,%rdi
    2066:	e8 8e 1d 00 00       	callq  3df9 <open>
    206b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    206e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2072:	79 1b                	jns    208f <subdir+0x347>
    printf(1, "open dd/dd/ffff failed\n");
    2074:	48 c7 c6 da 4f 00 00 	mov    $0x4fda,%rsi
    207b:	bf 01 00 00 00       	mov    $0x1,%edi
    2080:	b8 00 00 00 00       	mov    $0x0,%eax
    2085:	e8 b8 1e 00 00       	callq  3f42 <printf>
    exit();
    208a:	e8 2a 1d 00 00       	callq  3db9 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    208f:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2092:	ba 00 20 00 00       	mov    $0x2000,%edx
    2097:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    209e:	89 c7                	mov    %eax,%edi
    20a0:	e8 2c 1d 00 00       	callq  3dd1 <read>
    20a5:	83 f8 02             	cmp    $0x2,%eax
    20a8:	74 1b                	je     20c5 <subdir+0x37d>
    printf(1, "read dd/dd/ffff wrong len\n");
    20aa:	48 c7 c6 f2 4f 00 00 	mov    $0x4ff2,%rsi
    20b1:	bf 01 00 00 00       	mov    $0x1,%edi
    20b6:	b8 00 00 00 00       	mov    $0x0,%eax
    20bb:	e8 82 1e 00 00       	callq  3f42 <printf>
    exit();
    20c0:	e8 f4 1c 00 00       	callq  3db9 <exit>
  }
  close(fd);
    20c5:	8b 45 fc             	mov    -0x4(%rbp),%eax
    20c8:	89 c7                	mov    %eax,%edi
    20ca:	e8 12 1d 00 00       	callq  3de1 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    20cf:	be 00 00 00 00       	mov    $0x0,%esi
    20d4:	48 c7 c7 a8 4e 00 00 	mov    $0x4ea8,%rdi
    20db:	e8 19 1d 00 00       	callq  3df9 <open>
    20e0:	85 c0                	test   %eax,%eax
    20e2:	78 1b                	js     20ff <subdir+0x3b7>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    20e4:	48 c7 c6 10 50 00 00 	mov    $0x5010,%rsi
    20eb:	bf 01 00 00 00       	mov    $0x1,%edi
    20f0:	b8 00 00 00 00       	mov    $0x0,%eax
    20f5:	e8 48 1e 00 00       	callq  3f42 <printf>
    exit();
    20fa:	e8 ba 1c 00 00       	callq  3db9 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    20ff:	be 02 02 00 00       	mov    $0x202,%esi
    2104:	48 c7 c7 35 50 00 00 	mov    $0x5035,%rdi
    210b:	e8 e9 1c 00 00       	callq  3df9 <open>
    2110:	85 c0                	test   %eax,%eax
    2112:	78 1b                	js     212f <subdir+0x3e7>
    printf(1, "create dd/ff/ff succeeded!\n");
    2114:	48 c7 c6 3e 50 00 00 	mov    $0x503e,%rsi
    211b:	bf 01 00 00 00       	mov    $0x1,%edi
    2120:	b8 00 00 00 00       	mov    $0x0,%eax
    2125:	e8 18 1e 00 00       	callq  3f42 <printf>
    exit();
    212a:	e8 8a 1c 00 00       	callq  3db9 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    212f:	be 02 02 00 00       	mov    $0x202,%esi
    2134:	48 c7 c7 5a 50 00 00 	mov    $0x505a,%rdi
    213b:	e8 b9 1c 00 00       	callq  3df9 <open>
    2140:	85 c0                	test   %eax,%eax
    2142:	78 1b                	js     215f <subdir+0x417>
    printf(1, "create dd/xx/ff succeeded!\n");
    2144:	48 c7 c6 63 50 00 00 	mov    $0x5063,%rsi
    214b:	bf 01 00 00 00       	mov    $0x1,%edi
    2150:	b8 00 00 00 00       	mov    $0x0,%eax
    2155:	e8 e8 1d 00 00       	callq  3f42 <printf>
    exit();
    215a:	e8 5a 1c 00 00       	callq  3db9 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    215f:	be 00 02 00 00       	mov    $0x200,%esi
    2164:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    216b:	e8 89 1c 00 00       	callq  3df9 <open>
    2170:	85 c0                	test   %eax,%eax
    2172:	78 1b                	js     218f <subdir+0x447>
    printf(1, "create dd succeeded!\n");
    2174:	48 c7 c6 7f 50 00 00 	mov    $0x507f,%rsi
    217b:	bf 01 00 00 00       	mov    $0x1,%edi
    2180:	b8 00 00 00 00       	mov    $0x0,%eax
    2185:	e8 b8 1d 00 00       	callq  3f42 <printf>
    exit();
    218a:	e8 2a 1c 00 00       	callq  3db9 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    218f:	be 02 00 00 00       	mov    $0x2,%esi
    2194:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    219b:	e8 59 1c 00 00       	callq  3df9 <open>
    21a0:	85 c0                	test   %eax,%eax
    21a2:	78 1b                	js     21bf <subdir+0x477>
    printf(1, "open dd rdwr succeeded!\n");
    21a4:	48 c7 c6 95 50 00 00 	mov    $0x5095,%rsi
    21ab:	bf 01 00 00 00       	mov    $0x1,%edi
    21b0:	b8 00 00 00 00       	mov    $0x0,%eax
    21b5:	e8 88 1d 00 00       	callq  3f42 <printf>
    exit();
    21ba:	e8 fa 1b 00 00       	callq  3db9 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    21bf:	be 01 00 00 00       	mov    $0x1,%esi
    21c4:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    21cb:	e8 29 1c 00 00       	callq  3df9 <open>
    21d0:	85 c0                	test   %eax,%eax
    21d2:	78 1b                	js     21ef <subdir+0x4a7>
    printf(1, "open dd wronly succeeded!\n");
    21d4:	48 c7 c6 ae 50 00 00 	mov    $0x50ae,%rsi
    21db:	bf 01 00 00 00       	mov    $0x1,%edi
    21e0:	b8 00 00 00 00       	mov    $0x0,%eax
    21e5:	e8 58 1d 00 00       	callq  3f42 <printf>
    exit();
    21ea:	e8 ca 1b 00 00       	callq  3db9 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    21ef:	48 c7 c6 c9 50 00 00 	mov    $0x50c9,%rsi
    21f6:	48 c7 c7 35 50 00 00 	mov    $0x5035,%rdi
    21fd:	e8 17 1c 00 00       	callq  3e19 <link>
    2202:	85 c0                	test   %eax,%eax
    2204:	75 1b                	jne    2221 <subdir+0x4d9>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    2206:	48 c7 c6 d8 50 00 00 	mov    $0x50d8,%rsi
    220d:	bf 01 00 00 00       	mov    $0x1,%edi
    2212:	b8 00 00 00 00       	mov    $0x0,%eax
    2217:	e8 26 1d 00 00       	callq  3f42 <printf>
    exit();
    221c:	e8 98 1b 00 00       	callq  3db9 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2221:	48 c7 c6 c9 50 00 00 	mov    $0x50c9,%rsi
    2228:	48 c7 c7 5a 50 00 00 	mov    $0x505a,%rdi
    222f:	e8 e5 1b 00 00       	callq  3e19 <link>
    2234:	85 c0                	test   %eax,%eax
    2236:	75 1b                	jne    2253 <subdir+0x50b>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    2238:	48 c7 c6 00 51 00 00 	mov    $0x5100,%rsi
    223f:	bf 01 00 00 00       	mov    $0x1,%edi
    2244:	b8 00 00 00 00       	mov    $0x0,%eax
    2249:	e8 f4 1c 00 00       	callq  3f42 <printf>
    exit();
    224e:	e8 66 1b 00 00       	callq  3db9 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2253:	48 c7 c6 0c 4f 00 00 	mov    $0x4f0c,%rsi
    225a:	48 c7 c7 40 4e 00 00 	mov    $0x4e40,%rdi
    2261:	e8 b3 1b 00 00       	callq  3e19 <link>
    2266:	85 c0                	test   %eax,%eax
    2268:	75 1b                	jne    2285 <subdir+0x53d>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    226a:	48 c7 c6 28 51 00 00 	mov    $0x5128,%rsi
    2271:	bf 01 00 00 00       	mov    $0x1,%edi
    2276:	b8 00 00 00 00       	mov    $0x0,%eax
    227b:	e8 c2 1c 00 00       	callq  3f42 <printf>
    exit();
    2280:	e8 34 1b 00 00       	callq  3db9 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    2285:	48 c7 c7 35 50 00 00 	mov    $0x5035,%rdi
    228c:	e8 90 1b 00 00       	callq  3e21 <mkdir>
    2291:	85 c0                	test   %eax,%eax
    2293:	75 1b                	jne    22b0 <subdir+0x568>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    2295:	48 c7 c6 4a 51 00 00 	mov    $0x514a,%rsi
    229c:	bf 01 00 00 00       	mov    $0x1,%edi
    22a1:	b8 00 00 00 00       	mov    $0x0,%eax
    22a6:	e8 97 1c 00 00       	callq  3f42 <printf>
    exit();
    22ab:	e8 09 1b 00 00       	callq  3db9 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    22b0:	48 c7 c7 5a 50 00 00 	mov    $0x505a,%rdi
    22b7:	e8 65 1b 00 00       	callq  3e21 <mkdir>
    22bc:	85 c0                	test   %eax,%eax
    22be:	75 1b                	jne    22db <subdir+0x593>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    22c0:	48 c7 c6 65 51 00 00 	mov    $0x5165,%rsi
    22c7:	bf 01 00 00 00       	mov    $0x1,%edi
    22cc:	b8 00 00 00 00       	mov    $0x0,%eax
    22d1:	e8 6c 1c 00 00       	callq  3f42 <printf>
    exit();
    22d6:	e8 de 1a 00 00       	callq  3db9 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    22db:	48 c7 c7 0c 4f 00 00 	mov    $0x4f0c,%rdi
    22e2:	e8 3a 1b 00 00       	callq  3e21 <mkdir>
    22e7:	85 c0                	test   %eax,%eax
    22e9:	75 1b                	jne    2306 <subdir+0x5be>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    22eb:	48 c7 c6 80 51 00 00 	mov    $0x5180,%rsi
    22f2:	bf 01 00 00 00       	mov    $0x1,%edi
    22f7:	b8 00 00 00 00       	mov    $0x0,%eax
    22fc:	e8 41 1c 00 00       	callq  3f42 <printf>
    exit();
    2301:	e8 b3 1a 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    2306:	48 c7 c7 5a 50 00 00 	mov    $0x505a,%rdi
    230d:	e8 f7 1a 00 00       	callq  3e09 <unlink>
    2312:	85 c0                	test   %eax,%eax
    2314:	75 1b                	jne    2331 <subdir+0x5e9>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    2316:	48 c7 c6 9d 51 00 00 	mov    $0x519d,%rsi
    231d:	bf 01 00 00 00       	mov    $0x1,%edi
    2322:	b8 00 00 00 00       	mov    $0x0,%eax
    2327:	e8 16 1c 00 00       	callq  3f42 <printf>
    exit();
    232c:	e8 88 1a 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    2331:	48 c7 c7 35 50 00 00 	mov    $0x5035,%rdi
    2338:	e8 cc 1a 00 00       	callq  3e09 <unlink>
    233d:	85 c0                	test   %eax,%eax
    233f:	75 1b                	jne    235c <subdir+0x614>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    2341:	48 c7 c6 b9 51 00 00 	mov    $0x51b9,%rsi
    2348:	bf 01 00 00 00       	mov    $0x1,%edi
    234d:	b8 00 00 00 00       	mov    $0x0,%eax
    2352:	e8 eb 1b 00 00       	callq  3f42 <printf>
    exit();
    2357:	e8 5d 1a 00 00       	callq  3db9 <exit>
  }
  if(chdir("dd/ff") == 0){
    235c:	48 c7 c7 40 4e 00 00 	mov    $0x4e40,%rdi
    2363:	e8 c1 1a 00 00       	callq  3e29 <chdir>
    2368:	85 c0                	test   %eax,%eax
    236a:	75 1b                	jne    2387 <subdir+0x63f>
    printf(1, "chdir dd/ff succeeded!\n");
    236c:	48 c7 c6 d5 51 00 00 	mov    $0x51d5,%rsi
    2373:	bf 01 00 00 00       	mov    $0x1,%edi
    2378:	b8 00 00 00 00       	mov    $0x0,%eax
    237d:	e8 c0 1b 00 00       	callq  3f42 <printf>
    exit();
    2382:	e8 32 1a 00 00       	callq  3db9 <exit>
  }
  if(chdir("dd/xx") == 0){
    2387:	48 c7 c7 ed 51 00 00 	mov    $0x51ed,%rdi
    238e:	e8 96 1a 00 00       	callq  3e29 <chdir>
    2393:	85 c0                	test   %eax,%eax
    2395:	75 1b                	jne    23b2 <subdir+0x66a>
    printf(1, "chdir dd/xx succeeded!\n");
    2397:	48 c7 c6 f3 51 00 00 	mov    $0x51f3,%rsi
    239e:	bf 01 00 00 00       	mov    $0x1,%edi
    23a3:	b8 00 00 00 00       	mov    $0x0,%eax
    23a8:	e8 95 1b 00 00       	callq  3f42 <printf>
    exit();
    23ad:	e8 07 1a 00 00       	callq  3db9 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    23b2:	48 c7 c7 0c 4f 00 00 	mov    $0x4f0c,%rdi
    23b9:	e8 4b 1a 00 00       	callq  3e09 <unlink>
    23be:	85 c0                	test   %eax,%eax
    23c0:	74 1b                	je     23dd <subdir+0x695>
    printf(1, "unlink dd/dd/ff failed\n");
    23c2:	48 c7 c6 39 4f 00 00 	mov    $0x4f39,%rsi
    23c9:	bf 01 00 00 00       	mov    $0x1,%edi
    23ce:	b8 00 00 00 00       	mov    $0x0,%eax
    23d3:	e8 6a 1b 00 00       	callq  3f42 <printf>
    exit();
    23d8:	e8 dc 19 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd/ff") != 0){
    23dd:	48 c7 c7 40 4e 00 00 	mov    $0x4e40,%rdi
    23e4:	e8 20 1a 00 00       	callq  3e09 <unlink>
    23e9:	85 c0                	test   %eax,%eax
    23eb:	74 1b                	je     2408 <subdir+0x6c0>
    printf(1, "unlink dd/ff failed\n");
    23ed:	48 c7 c6 0b 52 00 00 	mov    $0x520b,%rsi
    23f4:	bf 01 00 00 00       	mov    $0x1,%edi
    23f9:	b8 00 00 00 00       	mov    $0x0,%eax
    23fe:	e8 3f 1b 00 00       	callq  3f42 <printf>
    exit();
    2403:	e8 b1 19 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd") == 0){
    2408:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    240f:	e8 f5 19 00 00       	callq  3e09 <unlink>
    2414:	85 c0                	test   %eax,%eax
    2416:	75 1b                	jne    2433 <subdir+0x6eb>
    printf(1, "unlink non-empty dd succeeded!\n");
    2418:	48 c7 c6 20 52 00 00 	mov    $0x5220,%rsi
    241f:	bf 01 00 00 00       	mov    $0x1,%edi
    2424:	b8 00 00 00 00       	mov    $0x0,%eax
    2429:	e8 14 1b 00 00       	callq  3f42 <printf>
    exit();
    242e:	e8 86 19 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd/dd") < 0){
    2433:	48 c7 c7 40 52 00 00 	mov    $0x5240,%rdi
    243a:	e8 ca 19 00 00       	callq  3e09 <unlink>
    243f:	85 c0                	test   %eax,%eax
    2441:	79 1b                	jns    245e <subdir+0x716>
    printf(1, "unlink dd/dd failed\n");
    2443:	48 c7 c6 46 52 00 00 	mov    $0x5246,%rsi
    244a:	bf 01 00 00 00       	mov    $0x1,%edi
    244f:	b8 00 00 00 00       	mov    $0x0,%eax
    2454:	e8 e9 1a 00 00       	callq  3f42 <printf>
    exit();
    2459:	e8 5b 19 00 00       	callq  3db9 <exit>
  }
  if(unlink("dd") < 0){
    245e:	48 c7 c7 25 4e 00 00 	mov    $0x4e25,%rdi
    2465:	e8 9f 19 00 00       	callq  3e09 <unlink>
    246a:	85 c0                	test   %eax,%eax
    246c:	79 1b                	jns    2489 <subdir+0x741>
    printf(1, "unlink dd failed\n");
    246e:	48 c7 c6 5b 52 00 00 	mov    $0x525b,%rsi
    2475:	bf 01 00 00 00       	mov    $0x1,%edi
    247a:	b8 00 00 00 00       	mov    $0x0,%eax
    247f:	e8 be 1a 00 00       	callq  3f42 <printf>
    exit();
    2484:	e8 30 19 00 00       	callq  3db9 <exit>
  }

  printf(1, "subdir ok\n");
    2489:	48 c7 c6 6d 52 00 00 	mov    $0x526d,%rsi
    2490:	bf 01 00 00 00       	mov    $0x1,%edi
    2495:	b8 00 00 00 00       	mov    $0x0,%eax
    249a:	e8 a3 1a 00 00       	callq  3f42 <printf>
}
    249f:	90                   	nop
    24a0:	c9                   	leaveq 
    24a1:	c3                   	retq   

00000000000024a2 <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    24a2:	55                   	push   %rbp
    24a3:	48 89 e5             	mov    %rsp,%rbp
    24a6:	48 83 ec 10          	sub    $0x10,%rsp
  int fd, sz;

  printf(1, "bigwrite test\n");
    24aa:	48 c7 c6 78 52 00 00 	mov    $0x5278,%rsi
    24b1:	bf 01 00 00 00       	mov    $0x1,%edi
    24b6:	b8 00 00 00 00       	mov    $0x0,%eax
    24bb:	e8 82 1a 00 00       	callq  3f42 <printf>

  unlink("bigwrite");
    24c0:	48 c7 c7 87 52 00 00 	mov    $0x5287,%rdi
    24c7:	e8 3d 19 00 00       	callq  3e09 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    24cc:	c7 45 fc f3 01 00 00 	movl   $0x1f3,-0x4(%rbp)
    24d3:	e9 a9 00 00 00       	jmpq   2581 <bigwrite+0xdf>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    24d8:	be 02 02 00 00       	mov    $0x202,%esi
    24dd:	48 c7 c7 87 52 00 00 	mov    $0x5287,%rdi
    24e4:	e8 10 19 00 00       	callq  3df9 <open>
    24e9:	89 45 f4             	mov    %eax,-0xc(%rbp)
    if(fd < 0){
    24ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    24f0:	79 1b                	jns    250d <bigwrite+0x6b>
      printf(1, "cannot create bigwrite\n");
    24f2:	48 c7 c6 90 52 00 00 	mov    $0x5290,%rsi
    24f9:	bf 01 00 00 00       	mov    $0x1,%edi
    24fe:	b8 00 00 00 00       	mov    $0x0,%eax
    2503:	e8 3a 1a 00 00       	callq  3f42 <printf>
      exit();
    2508:	e8 ac 18 00 00       	callq  3db9 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    250d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
    2514:	eb 48                	jmp    255e <bigwrite+0xbc>
      int cc = write(fd, buf, sz);
    2516:	8b 55 fc             	mov    -0x4(%rbp),%edx
    2519:	8b 45 f4             	mov    -0xc(%rbp),%eax
    251c:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    2523:	89 c7                	mov    %eax,%edi
    2525:	e8 af 18 00 00       	callq  3dd9 <write>
    252a:	89 45 f0             	mov    %eax,-0x10(%rbp)
      if(cc != sz){
    252d:	8b 45 f0             	mov    -0x10(%rbp),%eax
    2530:	3b 45 fc             	cmp    -0x4(%rbp),%eax
    2533:	74 25                	je     255a <bigwrite+0xb8>
        printf(1, "write(%d) ret %d\n", sz, cc);
    2535:	8b 55 f0             	mov    -0x10(%rbp),%edx
    2538:	8b 45 fc             	mov    -0x4(%rbp),%eax
    253b:	89 d1                	mov    %edx,%ecx
    253d:	89 c2                	mov    %eax,%edx
    253f:	48 c7 c6 a8 52 00 00 	mov    $0x52a8,%rsi
    2546:	bf 01 00 00 00       	mov    $0x1,%edi
    254b:	b8 00 00 00 00       	mov    $0x0,%eax
    2550:	e8 ed 19 00 00       	callq  3f42 <printf>
        exit();
    2555:	e8 5f 18 00 00       	callq  3db9 <exit>
    for(i = 0; i < 2; i++){
    255a:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
    255e:	83 7d f8 01          	cmpl   $0x1,-0x8(%rbp)
    2562:	7e b2                	jle    2516 <bigwrite+0x74>
      }
    }
    close(fd);
    2564:	8b 45 f4             	mov    -0xc(%rbp),%eax
    2567:	89 c7                	mov    %eax,%edi
    2569:	e8 73 18 00 00       	callq  3de1 <close>
    unlink("bigwrite");
    256e:	48 c7 c7 87 52 00 00 	mov    $0x5287,%rdi
    2575:	e8 8f 18 00 00       	callq  3e09 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    257a:	81 45 fc d7 01 00 00 	addl   $0x1d7,-0x4(%rbp)
    2581:	81 7d fc ff 17 00 00 	cmpl   $0x17ff,-0x4(%rbp)
    2588:	0f 8e 4a ff ff ff    	jle    24d8 <bigwrite+0x36>
  }

  printf(1, "bigwrite ok\n");
    258e:	48 c7 c6 ba 52 00 00 	mov    $0x52ba,%rsi
    2595:	bf 01 00 00 00       	mov    $0x1,%edi
    259a:	b8 00 00 00 00       	mov    $0x0,%eax
    259f:	e8 9e 19 00 00       	callq  3f42 <printf>
}
    25a4:	90                   	nop
    25a5:	c9                   	leaveq 
    25a6:	c3                   	retq   

00000000000025a7 <bigfile>:

void
bigfile(void)
{
    25a7:	55                   	push   %rbp
    25a8:	48 89 e5             	mov    %rsp,%rbp
    25ab:	48 83 ec 10          	sub    $0x10,%rsp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    25af:	48 c7 c6 c7 52 00 00 	mov    $0x52c7,%rsi
    25b6:	bf 01 00 00 00       	mov    $0x1,%edi
    25bb:	b8 00 00 00 00       	mov    $0x0,%eax
    25c0:	e8 7d 19 00 00       	callq  3f42 <printf>

  unlink("bigfile");
    25c5:	48 c7 c7 d5 52 00 00 	mov    $0x52d5,%rdi
    25cc:	e8 38 18 00 00       	callq  3e09 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    25d1:	be 02 02 00 00       	mov    $0x202,%esi
    25d6:	48 c7 c7 d5 52 00 00 	mov    $0x52d5,%rdi
    25dd:	e8 17 18 00 00       	callq  3df9 <open>
    25e2:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(fd < 0){
    25e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    25e9:	79 1b                	jns    2606 <bigfile+0x5f>
    printf(1, "cannot create bigfile");
    25eb:	48 c7 c6 dd 52 00 00 	mov    $0x52dd,%rsi
    25f2:	bf 01 00 00 00       	mov    $0x1,%edi
    25f7:	b8 00 00 00 00       	mov    $0x0,%eax
    25fc:	e8 41 19 00 00       	callq  3f42 <printf>
    exit();
    2601:	e8 b3 17 00 00       	callq  3db9 <exit>
  }
  for(i = 0; i < 20; i++){
    2606:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    260d:	eb 52                	jmp    2661 <bigfile+0xba>
    memset(buf, i, 600);
    260f:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2612:	ba 58 02 00 00       	mov    $0x258,%edx
    2617:	89 c6                	mov    %eax,%esi
    2619:	48 c7 c7 20 63 00 00 	mov    $0x6320,%rdi
    2620:	e8 9f 15 00 00       	callq  3bc4 <memset>
    if(write(fd, buf, 600) != 600){
    2625:	8b 45 f4             	mov    -0xc(%rbp),%eax
    2628:	ba 58 02 00 00       	mov    $0x258,%edx
    262d:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    2634:	89 c7                	mov    %eax,%edi
    2636:	e8 9e 17 00 00       	callq  3dd9 <write>
    263b:	3d 58 02 00 00       	cmp    $0x258,%eax
    2640:	74 1b                	je     265d <bigfile+0xb6>
      printf(1, "write bigfile failed\n");
    2642:	48 c7 c6 f3 52 00 00 	mov    $0x52f3,%rsi
    2649:	bf 01 00 00 00       	mov    $0x1,%edi
    264e:	b8 00 00 00 00       	mov    $0x0,%eax
    2653:	e8 ea 18 00 00       	callq  3f42 <printf>
      exit();
    2658:	e8 5c 17 00 00       	callq  3db9 <exit>
  for(i = 0; i < 20; i++){
    265d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    2661:	83 7d fc 13          	cmpl   $0x13,-0x4(%rbp)
    2665:	7e a8                	jle    260f <bigfile+0x68>
    }
  }
  close(fd);
    2667:	8b 45 f4             	mov    -0xc(%rbp),%eax
    266a:	89 c7                	mov    %eax,%edi
    266c:	e8 70 17 00 00       	callq  3de1 <close>

  fd = open("bigfile", 0);
    2671:	be 00 00 00 00       	mov    $0x0,%esi
    2676:	48 c7 c7 d5 52 00 00 	mov    $0x52d5,%rdi
    267d:	e8 77 17 00 00       	callq  3df9 <open>
    2682:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(fd < 0){
    2685:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    2689:	79 1b                	jns    26a6 <bigfile+0xff>
    printf(1, "cannot open bigfile\n");
    268b:	48 c7 c6 09 53 00 00 	mov    $0x5309,%rsi
    2692:	bf 01 00 00 00       	mov    $0x1,%edi
    2697:	b8 00 00 00 00       	mov    $0x0,%eax
    269c:	e8 a1 18 00 00       	callq  3f42 <printf>
    exit();
    26a1:	e8 13 17 00 00       	callq  3db9 <exit>
  }
  total = 0;
    26a6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  for(i = 0; ; i++){
    26ad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    cc = read(fd, buf, 300);
    26b4:	8b 45 f4             	mov    -0xc(%rbp),%eax
    26b7:	ba 2c 01 00 00       	mov    $0x12c,%edx
    26bc:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    26c3:	89 c7                	mov    %eax,%edi
    26c5:	e8 07 17 00 00       	callq  3dd1 <read>
    26ca:	89 45 f0             	mov    %eax,-0x10(%rbp)
    if(cc < 0){
    26cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    26d1:	79 1b                	jns    26ee <bigfile+0x147>
      printf(1, "read bigfile failed\n");
    26d3:	48 c7 c6 1e 53 00 00 	mov    $0x531e,%rsi
    26da:	bf 01 00 00 00       	mov    $0x1,%edi
    26df:	b8 00 00 00 00       	mov    $0x0,%eax
    26e4:	e8 59 18 00 00       	callq  3f42 <printf>
      exit();
    26e9:	e8 cb 16 00 00       	callq  3db9 <exit>
    }
    if(cc == 0)
    26ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    26f2:	0f 84 82 00 00 00    	je     277a <bigfile+0x1d3>
      break;
    if(cc != 300){
    26f8:	81 7d f0 2c 01 00 00 	cmpl   $0x12c,-0x10(%rbp)
    26ff:	74 1b                	je     271c <bigfile+0x175>
      printf(1, "short read bigfile\n");
    2701:	48 c7 c6 33 53 00 00 	mov    $0x5333,%rsi
    2708:	bf 01 00 00 00       	mov    $0x1,%edi
    270d:	b8 00 00 00 00       	mov    $0x0,%eax
    2712:	e8 2b 18 00 00       	callq  3f42 <printf>
      exit();
    2717:	e8 9d 16 00 00       	callq  3db9 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    271c:	0f b6 05 fd 3b 00 00 	movzbl 0x3bfd(%rip),%eax        # 6320 <buf>
    2723:	0f be d0             	movsbl %al,%edx
    2726:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2729:	89 c1                	mov    %eax,%ecx
    272b:	c1 e9 1f             	shr    $0x1f,%ecx
    272e:	01 c8                	add    %ecx,%eax
    2730:	d1 f8                	sar    %eax
    2732:	39 c2                	cmp    %eax,%edx
    2734:	75 1a                	jne    2750 <bigfile+0x1a9>
    2736:	0f b6 05 0e 3d 00 00 	movzbl 0x3d0e(%rip),%eax        # 644b <buf+0x12b>
    273d:	0f be d0             	movsbl %al,%edx
    2740:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2743:	89 c1                	mov    %eax,%ecx
    2745:	c1 e9 1f             	shr    $0x1f,%ecx
    2748:	01 c8                	add    %ecx,%eax
    274a:	d1 f8                	sar    %eax
    274c:	39 c2                	cmp    %eax,%edx
    274e:	74 1b                	je     276b <bigfile+0x1c4>
      printf(1, "read bigfile wrong data\n");
    2750:	48 c7 c6 47 53 00 00 	mov    $0x5347,%rsi
    2757:	bf 01 00 00 00       	mov    $0x1,%edi
    275c:	b8 00 00 00 00       	mov    $0x0,%eax
    2761:	e8 dc 17 00 00       	callq  3f42 <printf>
      exit();
    2766:	e8 4e 16 00 00       	callq  3db9 <exit>
    }
    total += cc;
    276b:	8b 45 f0             	mov    -0x10(%rbp),%eax
    276e:	01 45 f8             	add    %eax,-0x8(%rbp)
  for(i = 0; ; i++){
    2771:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    cc = read(fd, buf, 300);
    2775:	e9 3a ff ff ff       	jmpq   26b4 <bigfile+0x10d>
      break;
    277a:	90                   	nop
  }
  close(fd);
    277b:	8b 45 f4             	mov    -0xc(%rbp),%eax
    277e:	89 c7                	mov    %eax,%edi
    2780:	e8 5c 16 00 00       	callq  3de1 <close>
  if(total != 20*600){
    2785:	81 7d f8 e0 2e 00 00 	cmpl   $0x2ee0,-0x8(%rbp)
    278c:	74 1b                	je     27a9 <bigfile+0x202>
    printf(1, "read bigfile wrong total\n");
    278e:	48 c7 c6 60 53 00 00 	mov    $0x5360,%rsi
    2795:	bf 01 00 00 00       	mov    $0x1,%edi
    279a:	b8 00 00 00 00       	mov    $0x0,%eax
    279f:	e8 9e 17 00 00       	callq  3f42 <printf>
    exit();
    27a4:	e8 10 16 00 00       	callq  3db9 <exit>
  }
  unlink("bigfile");
    27a9:	48 c7 c7 d5 52 00 00 	mov    $0x52d5,%rdi
    27b0:	e8 54 16 00 00       	callq  3e09 <unlink>

  printf(1, "bigfile test ok\n");
    27b5:	48 c7 c6 7a 53 00 00 	mov    $0x537a,%rsi
    27bc:	bf 01 00 00 00       	mov    $0x1,%edi
    27c1:	b8 00 00 00 00       	mov    $0x0,%eax
    27c6:	e8 77 17 00 00       	callq  3f42 <printf>
}
    27cb:	90                   	nop
    27cc:	c9                   	leaveq 
    27cd:	c3                   	retq   

00000000000027ce <fourteen>:

void
fourteen(void)
{
    27ce:	55                   	push   %rbp
    27cf:	48 89 e5             	mov    %rsp,%rbp
    27d2:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    27d6:	48 c7 c6 8b 53 00 00 	mov    $0x538b,%rsi
    27dd:	bf 01 00 00 00       	mov    $0x1,%edi
    27e2:	b8 00 00 00 00       	mov    $0x0,%eax
    27e7:	e8 56 17 00 00       	callq  3f42 <printf>

  if(mkdir("12345678901234") != 0){
    27ec:	48 c7 c7 9a 53 00 00 	mov    $0x539a,%rdi
    27f3:	e8 29 16 00 00       	callq  3e21 <mkdir>
    27f8:	85 c0                	test   %eax,%eax
    27fa:	74 1b                	je     2817 <fourteen+0x49>
    printf(1, "mkdir 12345678901234 failed\n");
    27fc:	48 c7 c6 a9 53 00 00 	mov    $0x53a9,%rsi
    2803:	bf 01 00 00 00       	mov    $0x1,%edi
    2808:	b8 00 00 00 00       	mov    $0x0,%eax
    280d:	e8 30 17 00 00       	callq  3f42 <printf>
    exit();
    2812:	e8 a2 15 00 00       	callq  3db9 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    2817:	48 c7 c7 c8 53 00 00 	mov    $0x53c8,%rdi
    281e:	e8 fe 15 00 00       	callq  3e21 <mkdir>
    2823:	85 c0                	test   %eax,%eax
    2825:	74 1b                	je     2842 <fourteen+0x74>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    2827:	48 c7 c6 e8 53 00 00 	mov    $0x53e8,%rsi
    282e:	bf 01 00 00 00       	mov    $0x1,%edi
    2833:	b8 00 00 00 00       	mov    $0x0,%eax
    2838:	e8 05 17 00 00       	callq  3f42 <printf>
    exit();
    283d:	e8 77 15 00 00       	callq  3db9 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2842:	be 00 02 00 00       	mov    $0x200,%esi
    2847:	48 c7 c7 18 54 00 00 	mov    $0x5418,%rdi
    284e:	e8 a6 15 00 00       	callq  3df9 <open>
    2853:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    2856:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    285a:	79 1b                	jns    2877 <fourteen+0xa9>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    285c:	48 c7 c6 48 54 00 00 	mov    $0x5448,%rsi
    2863:	bf 01 00 00 00       	mov    $0x1,%edi
    2868:	b8 00 00 00 00       	mov    $0x0,%eax
    286d:	e8 d0 16 00 00       	callq  3f42 <printf>
    exit();
    2872:	e8 42 15 00 00       	callq  3db9 <exit>
  }
  close(fd);
    2877:	8b 45 fc             	mov    -0x4(%rbp),%eax
    287a:	89 c7                	mov    %eax,%edi
    287c:	e8 60 15 00 00       	callq  3de1 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2881:	be 00 00 00 00       	mov    $0x0,%esi
    2886:	48 c7 c7 88 54 00 00 	mov    $0x5488,%rdi
    288d:	e8 67 15 00 00       	callq  3df9 <open>
    2892:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    2895:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2899:	79 1b                	jns    28b6 <fourteen+0xe8>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    289b:	48 c7 c6 b8 54 00 00 	mov    $0x54b8,%rsi
    28a2:	bf 01 00 00 00       	mov    $0x1,%edi
    28a7:	b8 00 00 00 00       	mov    $0x0,%eax
    28ac:	e8 91 16 00 00       	callq  3f42 <printf>
    exit();
    28b1:	e8 03 15 00 00       	callq  3db9 <exit>
  }
  close(fd);
    28b6:	8b 45 fc             	mov    -0x4(%rbp),%eax
    28b9:	89 c7                	mov    %eax,%edi
    28bb:	e8 21 15 00 00       	callq  3de1 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    28c0:	48 c7 c7 f2 54 00 00 	mov    $0x54f2,%rdi
    28c7:	e8 55 15 00 00       	callq  3e21 <mkdir>
    28cc:	85 c0                	test   %eax,%eax
    28ce:	75 1b                	jne    28eb <fourteen+0x11d>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    28d0:	48 c7 c6 10 55 00 00 	mov    $0x5510,%rsi
    28d7:	bf 01 00 00 00       	mov    $0x1,%edi
    28dc:	b8 00 00 00 00       	mov    $0x0,%eax
    28e1:	e8 5c 16 00 00       	callq  3f42 <printf>
    exit();
    28e6:	e8 ce 14 00 00       	callq  3db9 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    28eb:	48 c7 c7 40 55 00 00 	mov    $0x5540,%rdi
    28f2:	e8 2a 15 00 00       	callq  3e21 <mkdir>
    28f7:	85 c0                	test   %eax,%eax
    28f9:	75 1b                	jne    2916 <fourteen+0x148>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    28fb:	48 c7 c6 60 55 00 00 	mov    $0x5560,%rsi
    2902:	bf 01 00 00 00       	mov    $0x1,%edi
    2907:	b8 00 00 00 00       	mov    $0x0,%eax
    290c:	e8 31 16 00 00       	callq  3f42 <printf>
    exit();
    2911:	e8 a3 14 00 00       	callq  3db9 <exit>
  }

  printf(1, "fourteen ok\n");
    2916:	48 c7 c6 91 55 00 00 	mov    $0x5591,%rsi
    291d:	bf 01 00 00 00       	mov    $0x1,%edi
    2922:	b8 00 00 00 00       	mov    $0x0,%eax
    2927:	e8 16 16 00 00       	callq  3f42 <printf>
}
    292c:	90                   	nop
    292d:	c9                   	leaveq 
    292e:	c3                   	retq   

000000000000292f <rmdot>:

void
rmdot(void)
{
    292f:	55                   	push   %rbp
    2930:	48 89 e5             	mov    %rsp,%rbp
  printf(1, "rmdot test\n");
    2933:	48 c7 c6 9e 55 00 00 	mov    $0x559e,%rsi
    293a:	bf 01 00 00 00       	mov    $0x1,%edi
    293f:	b8 00 00 00 00       	mov    $0x0,%eax
    2944:	e8 f9 15 00 00       	callq  3f42 <printf>
  if(mkdir("dots") != 0){
    2949:	48 c7 c7 aa 55 00 00 	mov    $0x55aa,%rdi
    2950:	e8 cc 14 00 00       	callq  3e21 <mkdir>
    2955:	85 c0                	test   %eax,%eax
    2957:	74 1b                	je     2974 <rmdot+0x45>
    printf(1, "mkdir dots failed\n");
    2959:	48 c7 c6 af 55 00 00 	mov    $0x55af,%rsi
    2960:	bf 01 00 00 00       	mov    $0x1,%edi
    2965:	b8 00 00 00 00       	mov    $0x0,%eax
    296a:	e8 d3 15 00 00       	callq  3f42 <printf>
    exit();
    296f:	e8 45 14 00 00       	callq  3db9 <exit>
  }
  if(chdir("dots") != 0){
    2974:	48 c7 c7 aa 55 00 00 	mov    $0x55aa,%rdi
    297b:	e8 a9 14 00 00       	callq  3e29 <chdir>
    2980:	85 c0                	test   %eax,%eax
    2982:	74 1b                	je     299f <rmdot+0x70>
    printf(1, "chdir dots failed\n");
    2984:	48 c7 c6 c2 55 00 00 	mov    $0x55c2,%rsi
    298b:	bf 01 00 00 00       	mov    $0x1,%edi
    2990:	b8 00 00 00 00       	mov    $0x0,%eax
    2995:	e8 a8 15 00 00       	callq  3f42 <printf>
    exit();
    299a:	e8 1a 14 00 00       	callq  3db9 <exit>
  }
  if(unlink(".") == 0){
    299f:	48 c7 c7 c3 4c 00 00 	mov    $0x4cc3,%rdi
    29a6:	e8 5e 14 00 00       	callq  3e09 <unlink>
    29ab:	85 c0                	test   %eax,%eax
    29ad:	75 1b                	jne    29ca <rmdot+0x9b>
    printf(1, "rm . worked!\n");
    29af:	48 c7 c6 d5 55 00 00 	mov    $0x55d5,%rsi
    29b6:	bf 01 00 00 00       	mov    $0x1,%edi
    29bb:	b8 00 00 00 00       	mov    $0x0,%eax
    29c0:	e8 7d 15 00 00       	callq  3f42 <printf>
    exit();
    29c5:	e8 ef 13 00 00       	callq  3db9 <exit>
  }
  if(unlink("..") == 0){
    29ca:	48 c7 c7 48 48 00 00 	mov    $0x4848,%rdi
    29d1:	e8 33 14 00 00       	callq  3e09 <unlink>
    29d6:	85 c0                	test   %eax,%eax
    29d8:	75 1b                	jne    29f5 <rmdot+0xc6>
    printf(1, "rm .. worked!\n");
    29da:	48 c7 c6 e3 55 00 00 	mov    $0x55e3,%rsi
    29e1:	bf 01 00 00 00       	mov    $0x1,%edi
    29e6:	b8 00 00 00 00       	mov    $0x0,%eax
    29eb:	e8 52 15 00 00       	callq  3f42 <printf>
    exit();
    29f0:	e8 c4 13 00 00       	callq  3db9 <exit>
  }
  if(chdir("/") != 0){
    29f5:	48 c7 c7 f2 55 00 00 	mov    $0x55f2,%rdi
    29fc:	e8 28 14 00 00       	callq  3e29 <chdir>
    2a01:	85 c0                	test   %eax,%eax
    2a03:	74 1b                	je     2a20 <rmdot+0xf1>
    printf(1, "chdir / failed\n");
    2a05:	48 c7 c6 f4 55 00 00 	mov    $0x55f4,%rsi
    2a0c:	bf 01 00 00 00       	mov    $0x1,%edi
    2a11:	b8 00 00 00 00       	mov    $0x0,%eax
    2a16:	e8 27 15 00 00       	callq  3f42 <printf>
    exit();
    2a1b:	e8 99 13 00 00       	callq  3db9 <exit>
  }
  if(unlink("dots/.") == 0){
    2a20:	48 c7 c7 04 56 00 00 	mov    $0x5604,%rdi
    2a27:	e8 dd 13 00 00       	callq  3e09 <unlink>
    2a2c:	85 c0                	test   %eax,%eax
    2a2e:	75 1b                	jne    2a4b <rmdot+0x11c>
    printf(1, "unlink dots/. worked!\n");
    2a30:	48 c7 c6 0b 56 00 00 	mov    $0x560b,%rsi
    2a37:	bf 01 00 00 00       	mov    $0x1,%edi
    2a3c:	b8 00 00 00 00       	mov    $0x0,%eax
    2a41:	e8 fc 14 00 00       	callq  3f42 <printf>
    exit();
    2a46:	e8 6e 13 00 00       	callq  3db9 <exit>
  }
  if(unlink("dots/..") == 0){
    2a4b:	48 c7 c7 22 56 00 00 	mov    $0x5622,%rdi
    2a52:	e8 b2 13 00 00       	callq  3e09 <unlink>
    2a57:	85 c0                	test   %eax,%eax
    2a59:	75 1b                	jne    2a76 <rmdot+0x147>
    printf(1, "unlink dots/.. worked!\n");
    2a5b:	48 c7 c6 2a 56 00 00 	mov    $0x562a,%rsi
    2a62:	bf 01 00 00 00       	mov    $0x1,%edi
    2a67:	b8 00 00 00 00       	mov    $0x0,%eax
    2a6c:	e8 d1 14 00 00       	callq  3f42 <printf>
    exit();
    2a71:	e8 43 13 00 00       	callq  3db9 <exit>
  }
  if(unlink("dots") != 0){
    2a76:	48 c7 c7 aa 55 00 00 	mov    $0x55aa,%rdi
    2a7d:	e8 87 13 00 00       	callq  3e09 <unlink>
    2a82:	85 c0                	test   %eax,%eax
    2a84:	74 1b                	je     2aa1 <rmdot+0x172>
    printf(1, "unlink dots failed!\n");
    2a86:	48 c7 c6 42 56 00 00 	mov    $0x5642,%rsi
    2a8d:	bf 01 00 00 00       	mov    $0x1,%edi
    2a92:	b8 00 00 00 00       	mov    $0x0,%eax
    2a97:	e8 a6 14 00 00       	callq  3f42 <printf>
    exit();
    2a9c:	e8 18 13 00 00       	callq  3db9 <exit>
  }
  printf(1, "rmdot ok\n");
    2aa1:	48 c7 c6 57 56 00 00 	mov    $0x5657,%rsi
    2aa8:	bf 01 00 00 00       	mov    $0x1,%edi
    2aad:	b8 00 00 00 00       	mov    $0x0,%eax
    2ab2:	e8 8b 14 00 00       	callq  3f42 <printf>
}
    2ab7:	90                   	nop
    2ab8:	5d                   	pop    %rbp
    2ab9:	c3                   	retq   

0000000000002aba <dirfile>:

void
dirfile(void)
{
    2aba:	55                   	push   %rbp
    2abb:	48 89 e5             	mov    %rsp,%rbp
    2abe:	48 83 ec 10          	sub    $0x10,%rsp
  int fd;

  printf(1, "dir vs file\n");
    2ac2:	48 c7 c6 61 56 00 00 	mov    $0x5661,%rsi
    2ac9:	bf 01 00 00 00       	mov    $0x1,%edi
    2ace:	b8 00 00 00 00       	mov    $0x0,%eax
    2ad3:	e8 6a 14 00 00       	callq  3f42 <printf>

  fd = open("dirfile", O_CREATE);
    2ad8:	be 00 02 00 00       	mov    $0x200,%esi
    2add:	48 c7 c7 6e 56 00 00 	mov    $0x566e,%rdi
    2ae4:	e8 10 13 00 00       	callq  3df9 <open>
    2ae9:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0){
    2aec:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2af0:	79 1b                	jns    2b0d <dirfile+0x53>
    printf(1, "create dirfile failed\n");
    2af2:	48 c7 c6 76 56 00 00 	mov    $0x5676,%rsi
    2af9:	bf 01 00 00 00       	mov    $0x1,%edi
    2afe:	b8 00 00 00 00       	mov    $0x0,%eax
    2b03:	e8 3a 14 00 00       	callq  3f42 <printf>
    exit();
    2b08:	e8 ac 12 00 00       	callq  3db9 <exit>
  }
  close(fd);
    2b0d:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2b10:	89 c7                	mov    %eax,%edi
    2b12:	e8 ca 12 00 00       	callq  3de1 <close>
  if(chdir("dirfile") == 0){
    2b17:	48 c7 c7 6e 56 00 00 	mov    $0x566e,%rdi
    2b1e:	e8 06 13 00 00       	callq  3e29 <chdir>
    2b23:	85 c0                	test   %eax,%eax
    2b25:	75 1b                	jne    2b42 <dirfile+0x88>
    printf(1, "chdir dirfile succeeded!\n");
    2b27:	48 c7 c6 8d 56 00 00 	mov    $0x568d,%rsi
    2b2e:	bf 01 00 00 00       	mov    $0x1,%edi
    2b33:	b8 00 00 00 00       	mov    $0x0,%eax
    2b38:	e8 05 14 00 00       	callq  3f42 <printf>
    exit();
    2b3d:	e8 77 12 00 00       	callq  3db9 <exit>
  }
  fd = open("dirfile/xx", 0);
    2b42:	be 00 00 00 00       	mov    $0x0,%esi
    2b47:	48 c7 c7 a7 56 00 00 	mov    $0x56a7,%rdi
    2b4e:	e8 a6 12 00 00       	callq  3df9 <open>
    2b53:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd >= 0){
    2b56:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2b5a:	78 1b                	js     2b77 <dirfile+0xbd>
    printf(1, "create dirfile/xx succeeded!\n");
    2b5c:	48 c7 c6 b2 56 00 00 	mov    $0x56b2,%rsi
    2b63:	bf 01 00 00 00       	mov    $0x1,%edi
    2b68:	b8 00 00 00 00       	mov    $0x0,%eax
    2b6d:	e8 d0 13 00 00       	callq  3f42 <printf>
    exit();
    2b72:	e8 42 12 00 00       	callq  3db9 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2b77:	be 00 02 00 00       	mov    $0x200,%esi
    2b7c:	48 c7 c7 a7 56 00 00 	mov    $0x56a7,%rdi
    2b83:	e8 71 12 00 00       	callq  3df9 <open>
    2b88:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd >= 0){
    2b8b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2b8f:	78 1b                	js     2bac <dirfile+0xf2>
    printf(1, "create dirfile/xx succeeded!\n");
    2b91:	48 c7 c6 b2 56 00 00 	mov    $0x56b2,%rsi
    2b98:	bf 01 00 00 00       	mov    $0x1,%edi
    2b9d:	b8 00 00 00 00       	mov    $0x0,%eax
    2ba2:	e8 9b 13 00 00       	callq  3f42 <printf>
    exit();
    2ba7:	e8 0d 12 00 00       	callq  3db9 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2bac:	48 c7 c7 a7 56 00 00 	mov    $0x56a7,%rdi
    2bb3:	e8 69 12 00 00       	callq  3e21 <mkdir>
    2bb8:	85 c0                	test   %eax,%eax
    2bba:	75 1b                	jne    2bd7 <dirfile+0x11d>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2bbc:	48 c7 c6 d0 56 00 00 	mov    $0x56d0,%rsi
    2bc3:	bf 01 00 00 00       	mov    $0x1,%edi
    2bc8:	b8 00 00 00 00       	mov    $0x0,%eax
    2bcd:	e8 70 13 00 00       	callq  3f42 <printf>
    exit();
    2bd2:	e8 e2 11 00 00       	callq  3db9 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2bd7:	48 c7 c7 a7 56 00 00 	mov    $0x56a7,%rdi
    2bde:	e8 26 12 00 00       	callq  3e09 <unlink>
    2be3:	85 c0                	test   %eax,%eax
    2be5:	75 1b                	jne    2c02 <dirfile+0x148>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2be7:	48 c7 c6 ed 56 00 00 	mov    $0x56ed,%rsi
    2bee:	bf 01 00 00 00       	mov    $0x1,%edi
    2bf3:	b8 00 00 00 00       	mov    $0x0,%eax
    2bf8:	e8 45 13 00 00       	callq  3f42 <printf>
    exit();
    2bfd:	e8 b7 11 00 00       	callq  3db9 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2c02:	48 c7 c6 a7 56 00 00 	mov    $0x56a7,%rsi
    2c09:	48 c7 c7 0b 57 00 00 	mov    $0x570b,%rdi
    2c10:	e8 04 12 00 00       	callq  3e19 <link>
    2c15:	85 c0                	test   %eax,%eax
    2c17:	75 1b                	jne    2c34 <dirfile+0x17a>
    printf(1, "link to dirfile/xx succeeded!\n");
    2c19:	48 c7 c6 18 57 00 00 	mov    $0x5718,%rsi
    2c20:	bf 01 00 00 00       	mov    $0x1,%edi
    2c25:	b8 00 00 00 00       	mov    $0x0,%eax
    2c2a:	e8 13 13 00 00       	callq  3f42 <printf>
    exit();
    2c2f:	e8 85 11 00 00       	callq  3db9 <exit>
  }
  if(unlink("dirfile") != 0){
    2c34:	48 c7 c7 6e 56 00 00 	mov    $0x566e,%rdi
    2c3b:	e8 c9 11 00 00       	callq  3e09 <unlink>
    2c40:	85 c0                	test   %eax,%eax
    2c42:	74 1b                	je     2c5f <dirfile+0x1a5>
    printf(1, "unlink dirfile failed!\n");
    2c44:	48 c7 c6 37 57 00 00 	mov    $0x5737,%rsi
    2c4b:	bf 01 00 00 00       	mov    $0x1,%edi
    2c50:	b8 00 00 00 00       	mov    $0x0,%eax
    2c55:	e8 e8 12 00 00       	callq  3f42 <printf>
    exit();
    2c5a:	e8 5a 11 00 00       	callq  3db9 <exit>
  }

  fd = open(".", O_RDWR);
    2c5f:	be 02 00 00 00       	mov    $0x2,%esi
    2c64:	48 c7 c7 c3 4c 00 00 	mov    $0x4cc3,%rdi
    2c6b:	e8 89 11 00 00       	callq  3df9 <open>
    2c70:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd >= 0){
    2c73:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2c77:	78 1b                	js     2c94 <dirfile+0x1da>
    printf(1, "open . for writing succeeded!\n");
    2c79:	48 c7 c6 50 57 00 00 	mov    $0x5750,%rsi
    2c80:	bf 01 00 00 00       	mov    $0x1,%edi
    2c85:	b8 00 00 00 00       	mov    $0x0,%eax
    2c8a:	e8 b3 12 00 00       	callq  3f42 <printf>
    exit();
    2c8f:	e8 25 11 00 00       	callq  3db9 <exit>
  }
  fd = open(".", 0);
    2c94:	be 00 00 00 00       	mov    $0x0,%esi
    2c99:	48 c7 c7 c3 4c 00 00 	mov    $0x4cc3,%rdi
    2ca0:	e8 54 11 00 00       	callq  3df9 <open>
    2ca5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(write(fd, "x", 1) > 0){
    2ca8:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2cab:	ba 01 00 00 00       	mov    $0x1,%edx
    2cb0:	48 c7 c6 f2 48 00 00 	mov    $0x48f2,%rsi
    2cb7:	89 c7                	mov    %eax,%edi
    2cb9:	e8 1b 11 00 00       	callq  3dd9 <write>
    2cbe:	85 c0                	test   %eax,%eax
    2cc0:	7e 1b                	jle    2cdd <dirfile+0x223>
    printf(1, "write . succeeded!\n");
    2cc2:	48 c7 c6 6f 57 00 00 	mov    $0x576f,%rsi
    2cc9:	bf 01 00 00 00       	mov    $0x1,%edi
    2cce:	b8 00 00 00 00       	mov    $0x0,%eax
    2cd3:	e8 6a 12 00 00       	callq  3f42 <printf>
    exit();
    2cd8:	e8 dc 10 00 00       	callq  3db9 <exit>
  }
  close(fd);
    2cdd:	8b 45 fc             	mov    -0x4(%rbp),%eax
    2ce0:	89 c7                	mov    %eax,%edi
    2ce2:	e8 fa 10 00 00       	callq  3de1 <close>

  printf(1, "dir vs file OK\n");
    2ce7:	48 c7 c6 83 57 00 00 	mov    $0x5783,%rsi
    2cee:	bf 01 00 00 00       	mov    $0x1,%edi
    2cf3:	b8 00 00 00 00       	mov    $0x0,%eax
    2cf8:	e8 45 12 00 00       	callq  3f42 <printf>
}
    2cfd:	90                   	nop
    2cfe:	c9                   	leaveq 
    2cff:	c3                   	retq   

0000000000002d00 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2d00:	55                   	push   %rbp
    2d01:	48 89 e5             	mov    %rsp,%rbp
    2d04:	48 83 ec 10          	sub    $0x10,%rsp
  int i, fd;

  printf(1, "empty file name\n");
    2d08:	48 c7 c6 93 57 00 00 	mov    $0x5793,%rsi
    2d0f:	bf 01 00 00 00       	mov    $0x1,%edi
    2d14:	b8 00 00 00 00       	mov    $0x0,%eax
    2d19:	e8 24 12 00 00       	callq  3f42 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2d1e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    2d25:	e9 cd 00 00 00       	jmpq   2df7 <iref+0xf7>
    if(mkdir("irefd") != 0){
    2d2a:	48 c7 c7 a4 57 00 00 	mov    $0x57a4,%rdi
    2d31:	e8 eb 10 00 00       	callq  3e21 <mkdir>
    2d36:	85 c0                	test   %eax,%eax
    2d38:	74 1b                	je     2d55 <iref+0x55>
      printf(1, "mkdir irefd failed\n");
    2d3a:	48 c7 c6 aa 57 00 00 	mov    $0x57aa,%rsi
    2d41:	bf 01 00 00 00       	mov    $0x1,%edi
    2d46:	b8 00 00 00 00       	mov    $0x0,%eax
    2d4b:	e8 f2 11 00 00       	callq  3f42 <printf>
      exit();
    2d50:	e8 64 10 00 00       	callq  3db9 <exit>
    }
    if(chdir("irefd") != 0){
    2d55:	48 c7 c7 a4 57 00 00 	mov    $0x57a4,%rdi
    2d5c:	e8 c8 10 00 00       	callq  3e29 <chdir>
    2d61:	85 c0                	test   %eax,%eax
    2d63:	74 1b                	je     2d80 <iref+0x80>
      printf(1, "chdir irefd failed\n");
    2d65:	48 c7 c6 be 57 00 00 	mov    $0x57be,%rsi
    2d6c:	bf 01 00 00 00       	mov    $0x1,%edi
    2d71:	b8 00 00 00 00       	mov    $0x0,%eax
    2d76:	e8 c7 11 00 00       	callq  3f42 <printf>
      exit();
    2d7b:	e8 39 10 00 00       	callq  3db9 <exit>
    }

    mkdir("");
    2d80:	48 c7 c7 d2 57 00 00 	mov    $0x57d2,%rdi
    2d87:	e8 95 10 00 00       	callq  3e21 <mkdir>
    link("README", "");
    2d8c:	48 c7 c6 d2 57 00 00 	mov    $0x57d2,%rsi
    2d93:	48 c7 c7 0b 57 00 00 	mov    $0x570b,%rdi
    2d9a:	e8 7a 10 00 00       	callq  3e19 <link>
    fd = open("", O_CREATE);
    2d9f:	be 00 02 00 00       	mov    $0x200,%esi
    2da4:	48 c7 c7 d2 57 00 00 	mov    $0x57d2,%rdi
    2dab:	e8 49 10 00 00       	callq  3df9 <open>
    2db0:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(fd >= 0)
    2db3:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    2db7:	78 0a                	js     2dc3 <iref+0xc3>
      close(fd);
    2db9:	8b 45 f8             	mov    -0x8(%rbp),%eax
    2dbc:	89 c7                	mov    %eax,%edi
    2dbe:	e8 1e 10 00 00       	callq  3de1 <close>
    fd = open("xx", O_CREATE);
    2dc3:	be 00 02 00 00       	mov    $0x200,%esi
    2dc8:	48 c7 c7 d3 57 00 00 	mov    $0x57d3,%rdi
    2dcf:	e8 25 10 00 00       	callq  3df9 <open>
    2dd4:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(fd >= 0)
    2dd7:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    2ddb:	78 0a                	js     2de7 <iref+0xe7>
      close(fd);
    2ddd:	8b 45 f8             	mov    -0x8(%rbp),%eax
    2de0:	89 c7                	mov    %eax,%edi
    2de2:	e8 fa 0f 00 00       	callq  3de1 <close>
    unlink("xx");
    2de7:	48 c7 c7 d3 57 00 00 	mov    $0x57d3,%rdi
    2dee:	e8 16 10 00 00       	callq  3e09 <unlink>
  for(i = 0; i < 50 + 1; i++){
    2df3:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    2df7:	83 7d fc 32          	cmpl   $0x32,-0x4(%rbp)
    2dfb:	0f 8e 29 ff ff ff    	jle    2d2a <iref+0x2a>
  }

  chdir("/");
    2e01:	48 c7 c7 f2 55 00 00 	mov    $0x55f2,%rdi
    2e08:	e8 1c 10 00 00       	callq  3e29 <chdir>
  printf(1, "empty file name OK\n");
    2e0d:	48 c7 c6 d6 57 00 00 	mov    $0x57d6,%rsi
    2e14:	bf 01 00 00 00       	mov    $0x1,%edi
    2e19:	b8 00 00 00 00       	mov    $0x0,%eax
    2e1e:	e8 1f 11 00 00       	callq  3f42 <printf>
}
    2e23:	90                   	nop
    2e24:	c9                   	leaveq 
    2e25:	c3                   	retq   

0000000000002e26 <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2e26:	55                   	push   %rbp
    2e27:	48 89 e5             	mov    %rsp,%rbp
    2e2a:	48 83 ec 10          	sub    $0x10,%rsp
  int n, pid;

  printf(1, "fork test\n");
    2e2e:	48 c7 c6 ea 57 00 00 	mov    $0x57ea,%rsi
    2e35:	bf 01 00 00 00       	mov    $0x1,%edi
    2e3a:	b8 00 00 00 00       	mov    $0x0,%eax
    2e3f:	e8 fe 10 00 00       	callq  3f42 <printf>

  for(n=0; n<1000; n++){
    2e44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    2e4b:	eb 1d                	jmp    2e6a <forktest+0x44>
    pid = fork();
    2e4d:	e8 5f 0f 00 00       	callq  3db1 <fork>
    2e52:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(pid < 0)
    2e55:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    2e59:	78 1a                	js     2e75 <forktest+0x4f>
      break;
    if(pid == 0)
    2e5b:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    2e5f:	75 05                	jne    2e66 <forktest+0x40>
      exit();
    2e61:	e8 53 0f 00 00       	callq  3db9 <exit>
  for(n=0; n<1000; n++){
    2e66:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    2e6a:	81 7d fc e7 03 00 00 	cmpl   $0x3e7,-0x4(%rbp)
    2e71:	7e da                	jle    2e4d <forktest+0x27>
    2e73:	eb 01                	jmp    2e76 <forktest+0x50>
      break;
    2e75:	90                   	nop
  }
  
  if(n == 1000){
    2e76:	81 7d fc e8 03 00 00 	cmpl   $0x3e8,-0x4(%rbp)
    2e7d:	75 43                	jne    2ec2 <forktest+0x9c>
    printf(1, "fork claimed to work 1000 times!\n");
    2e7f:	48 c7 c6 f8 57 00 00 	mov    $0x57f8,%rsi
    2e86:	bf 01 00 00 00       	mov    $0x1,%edi
    2e8b:	b8 00 00 00 00       	mov    $0x0,%eax
    2e90:	e8 ad 10 00 00       	callq  3f42 <printf>
    exit();
    2e95:	e8 1f 0f 00 00       	callq  3db9 <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
    2e9a:	e8 22 0f 00 00       	callq  3dc1 <wait>
    2e9f:	85 c0                	test   %eax,%eax
    2ea1:	79 1b                	jns    2ebe <forktest+0x98>
      printf(1, "wait stopped early\n");
    2ea3:	48 c7 c6 1a 58 00 00 	mov    $0x581a,%rsi
    2eaa:	bf 01 00 00 00       	mov    $0x1,%edi
    2eaf:	b8 00 00 00 00       	mov    $0x0,%eax
    2eb4:	e8 89 10 00 00       	callq  3f42 <printf>
      exit();
    2eb9:	e8 fb 0e 00 00       	callq  3db9 <exit>
  for(; n > 0; n--){
    2ebe:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
    2ec2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    2ec6:	7f d2                	jg     2e9a <forktest+0x74>
    }
  }
  
  if(wait() != -1){
    2ec8:	e8 f4 0e 00 00       	callq  3dc1 <wait>
    2ecd:	83 f8 ff             	cmp    $0xffffffff,%eax
    2ed0:	74 1b                	je     2eed <forktest+0xc7>
    printf(1, "wait got too many\n");
    2ed2:	48 c7 c6 2e 58 00 00 	mov    $0x582e,%rsi
    2ed9:	bf 01 00 00 00       	mov    $0x1,%edi
    2ede:	b8 00 00 00 00       	mov    $0x0,%eax
    2ee3:	e8 5a 10 00 00       	callq  3f42 <printf>
    exit();
    2ee8:	e8 cc 0e 00 00       	callq  3db9 <exit>
  }
  
  printf(1, "fork test OK\n");
    2eed:	48 c7 c6 41 58 00 00 	mov    $0x5841,%rsi
    2ef4:	bf 01 00 00 00       	mov    $0x1,%edi
    2ef9:	b8 00 00 00 00       	mov    $0x0,%eax
    2efe:	e8 3f 10 00 00       	callq  3f42 <printf>
}
    2f03:	90                   	nop
    2f04:	c9                   	leaveq 
    2f05:	c3                   	retq   

0000000000002f06 <sbrktest>:

void
sbrktest(void)
{
    2f06:	55                   	push   %rbp
    2f07:	48 89 e5             	mov    %rsp,%rbp
    2f0a:	53                   	push   %rbx
    2f0b:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2f12:	8b 05 d0 33 00 00    	mov    0x33d0(%rip),%eax        # 62e8 <stdout>
    2f18:	48 c7 c6 4f 58 00 00 	mov    $0x584f,%rsi
    2f1f:	89 c7                	mov    %eax,%edi
    2f21:	b8 00 00 00 00       	mov    $0x0,%eax
    2f26:	e8 17 10 00 00       	callq  3f42 <printf>
  oldbrk = sbrk(0);
    2f2b:	bf 00 00 00 00       	mov    $0x0,%edi
    2f30:	e8 0c 0f 00 00       	callq  3e41 <sbrk>
    2f35:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    2f39:	bf 00 00 00 00       	mov    $0x0,%edi
    2f3e:	e8 fe 0e 00 00       	callq  3e41 <sbrk>
    2f43:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  int i;
  for(i = 0; i < 5000; i++){ 
    2f47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
    2f4e:	eb 5b                	jmp    2fab <sbrktest+0xa5>
    b = sbrk(1);
    2f50:	bf 01 00 00 00       	mov    $0x1,%edi
    2f55:	e8 e7 0e 00 00       	callq  3e41 <sbrk>
    2f5a:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    if(b != a){
    2f5e:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
    2f62:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
    2f66:	74 2c                	je     2f94 <sbrktest+0x8e>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    2f68:	8b 05 7a 33 00 00    	mov    0x337a(%rip),%eax        # 62e8 <stdout>
    2f6e:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
    2f72:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
    2f76:	8b 55 e4             	mov    -0x1c(%rbp),%edx
    2f79:	49 89 f0             	mov    %rsi,%r8
    2f7c:	48 c7 c6 5a 58 00 00 	mov    $0x585a,%rsi
    2f83:	89 c7                	mov    %eax,%edi
    2f85:	b8 00 00 00 00       	mov    $0x0,%eax
    2f8a:	e8 b3 0f 00 00       	callq  3f42 <printf>
      exit();
    2f8f:	e8 25 0e 00 00       	callq  3db9 <exit>
    }
    *b = 1;
    2f94:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
    2f98:	c6 00 01             	movb   $0x1,(%rax)
    a = b + 1;
    2f9b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
    2f9f:	48 83 c0 01          	add    $0x1,%rax
    2fa3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  for(i = 0; i < 5000; i++){ 
    2fa7:	83 45 e4 01          	addl   $0x1,-0x1c(%rbp)
    2fab:	81 7d e4 87 13 00 00 	cmpl   $0x1387,-0x1c(%rbp)
    2fb2:	7e 9c                	jle    2f50 <sbrktest+0x4a>
  }
  pid = fork();
    2fb4:	e8 f8 0d 00 00       	callq  3db1 <fork>
    2fb9:	89 45 d4             	mov    %eax,-0x2c(%rbp)
  if(pid < 0){
    2fbc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    2fc0:	79 1e                	jns    2fe0 <sbrktest+0xda>
    printf(stdout, "sbrk test fork failed\n");
    2fc2:	8b 05 20 33 00 00    	mov    0x3320(%rip),%eax        # 62e8 <stdout>
    2fc8:	48 c7 c6 75 58 00 00 	mov    $0x5875,%rsi
    2fcf:	89 c7                	mov    %eax,%edi
    2fd1:	b8 00 00 00 00       	mov    $0x0,%eax
    2fd6:	e8 67 0f 00 00       	callq  3f42 <printf>
    exit();
    2fdb:	e8 d9 0d 00 00       	callq  3db9 <exit>
  }
  c = sbrk(1);
    2fe0:	bf 01 00 00 00       	mov    $0x1,%edi
    2fe5:	e8 57 0e 00 00       	callq  3e41 <sbrk>
    2fea:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  c = sbrk(1);
    2fee:	bf 01 00 00 00       	mov    $0x1,%edi
    2ff3:	e8 49 0e 00 00       	callq  3e41 <sbrk>
    2ff8:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  if(c != a + 1){
    2ffc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3000:	48 83 c0 01          	add    $0x1,%rax
    3004:	48 39 45 c8          	cmp    %rax,-0x38(%rbp)
    3008:	74 1e                	je     3028 <sbrktest+0x122>
    printf(stdout, "sbrk test failed post-fork\n");
    300a:	8b 05 d8 32 00 00    	mov    0x32d8(%rip),%eax        # 62e8 <stdout>
    3010:	48 c7 c6 8c 58 00 00 	mov    $0x588c,%rsi
    3017:	89 c7                	mov    %eax,%edi
    3019:	b8 00 00 00 00       	mov    $0x0,%eax
    301e:	e8 1f 0f 00 00       	callq  3f42 <printf>
    exit();
    3023:	e8 91 0d 00 00       	callq  3db9 <exit>
  }
  if(pid == 0)
    3028:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    302c:	75 05                	jne    3033 <sbrktest+0x12d>
    exit();
    302e:	e8 86 0d 00 00       	callq  3db9 <exit>
  wait();
    3033:	e8 89 0d 00 00       	callq  3dc1 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    3038:	bf 00 00 00 00       	mov    $0x0,%edi
    303d:	e8 ff 0d 00 00       	callq  3e41 <sbrk>
    3042:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  amt = (BIG) - (uint)a;
    3046:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    304a:	ba 00 00 40 06       	mov    $0x6400000,%edx
    304f:	29 c2                	sub    %eax,%edx
    3051:	89 d0                	mov    %edx,%eax
    3053:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  p = sbrk(amt);
    3056:	8b 45 c4             	mov    -0x3c(%rbp),%eax
    3059:	89 c7                	mov    %eax,%edi
    305b:	e8 e1 0d 00 00       	callq  3e41 <sbrk>
    3060:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  if (p != a) { 
    3064:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
    3068:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
    306c:	74 1e                	je     308c <sbrktest+0x186>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    306e:	8b 05 74 32 00 00    	mov    0x3274(%rip),%eax        # 62e8 <stdout>
    3074:	48 c7 c6 a8 58 00 00 	mov    $0x58a8,%rsi
    307b:	89 c7                	mov    %eax,%edi
    307d:	b8 00 00 00 00       	mov    $0x0,%eax
    3082:	e8 bb 0e 00 00       	callq  3f42 <printf>
    exit();
    3087:	e8 2d 0d 00 00       	callq  3db9 <exit>
  }
  lastaddr = (char*) (BIG-1);
    308c:	48 c7 45 b0 ff ff 3f 	movq   $0x63fffff,-0x50(%rbp)
    3093:	06 
  *lastaddr = 99;
    3094:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    3098:	c6 00 63             	movb   $0x63,(%rax)

  // can one de-allocate?
  a = sbrk(0);
    309b:	bf 00 00 00 00       	mov    $0x0,%edi
    30a0:	e8 9c 0d 00 00       	callq  3e41 <sbrk>
    30a5:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  c = sbrk(-4096);
    30a9:	bf 00 f0 ff ff       	mov    $0xfffff000,%edi
    30ae:	e8 8e 0d 00 00       	callq  3e41 <sbrk>
    30b3:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  if(c == (char*)0xffffffff){
    30b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    30bc:	48 39 45 c8          	cmp    %rax,-0x38(%rbp)
    30c0:	75 1e                	jne    30e0 <sbrktest+0x1da>
    printf(stdout, "sbrk could not deallocate\n");
    30c2:	8b 05 20 32 00 00    	mov    0x3220(%rip),%eax        # 62e8 <stdout>
    30c8:	48 c7 c6 e6 58 00 00 	mov    $0x58e6,%rsi
    30cf:	89 c7                	mov    %eax,%edi
    30d1:	b8 00 00 00 00       	mov    $0x0,%eax
    30d6:	e8 67 0e 00 00       	callq  3f42 <printf>
    exit();
    30db:	e8 d9 0c 00 00       	callq  3db9 <exit>
  }
  c = sbrk(0);
    30e0:	bf 00 00 00 00       	mov    $0x0,%edi
    30e5:	e8 57 0d 00 00       	callq  3e41 <sbrk>
    30ea:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  if(c != a - 4096){
    30ee:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    30f2:	48 2d 00 10 00 00    	sub    $0x1000,%rax
    30f8:	48 39 45 c8          	cmp    %rax,-0x38(%rbp)
    30fc:	74 26                	je     3124 <sbrktest+0x21e>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    30fe:	8b 05 e4 31 00 00    	mov    0x31e4(%rip),%eax        # 62e8 <stdout>
    3104:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    3108:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    310c:	48 c7 c6 08 59 00 00 	mov    $0x5908,%rsi
    3113:	89 c7                	mov    %eax,%edi
    3115:	b8 00 00 00 00       	mov    $0x0,%eax
    311a:	e8 23 0e 00 00       	callq  3f42 <printf>
    exit();
    311f:	e8 95 0c 00 00       	callq  3db9 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    3124:	bf 00 00 00 00       	mov    $0x0,%edi
    3129:	e8 13 0d 00 00       	callq  3e41 <sbrk>
    312e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  c = sbrk(4096);
    3132:	bf 00 10 00 00       	mov    $0x1000,%edi
    3137:	e8 05 0d 00 00       	callq  3e41 <sbrk>
    313c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  if(c != a || sbrk(0) != a + 4096){
    3140:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    3144:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
    3148:	75 1c                	jne    3166 <sbrktest+0x260>
    314a:	bf 00 00 00 00       	mov    $0x0,%edi
    314f:	e8 ed 0c 00 00       	callq  3e41 <sbrk>
    3154:	48 89 c2             	mov    %rax,%rdx
    3157:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    315b:	48 05 00 10 00 00    	add    $0x1000,%rax
    3161:	48 39 c2             	cmp    %rax,%rdx
    3164:	74 26                	je     318c <sbrktest+0x286>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    3166:	8b 05 7c 31 00 00    	mov    0x317c(%rip),%eax        # 62e8 <stdout>
    316c:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    3170:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    3174:	48 c7 c6 40 59 00 00 	mov    $0x5940,%rsi
    317b:	89 c7                	mov    %eax,%edi
    317d:	b8 00 00 00 00       	mov    $0x0,%eax
    3182:	e8 bb 0d 00 00       	callq  3f42 <printf>
    exit();
    3187:	e8 2d 0c 00 00       	callq  3db9 <exit>
  }
  if(*lastaddr == 99){
    318c:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
    3190:	0f b6 00             	movzbl (%rax),%eax
    3193:	3c 63                	cmp    $0x63,%al
    3195:	75 1e                	jne    31b5 <sbrktest+0x2af>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    3197:	8b 05 4b 31 00 00    	mov    0x314b(%rip),%eax        # 62e8 <stdout>
    319d:	48 c7 c6 68 59 00 00 	mov    $0x5968,%rsi
    31a4:	89 c7                	mov    %eax,%edi
    31a6:	b8 00 00 00 00       	mov    $0x0,%eax
    31ab:	e8 92 0d 00 00       	callq  3f42 <printf>
    exit();
    31b0:	e8 04 0c 00 00       	callq  3db9 <exit>
  }

  a = sbrk(0);
    31b5:	bf 00 00 00 00       	mov    $0x0,%edi
    31ba:	e8 82 0c 00 00       	callq  3e41 <sbrk>
    31bf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  c = sbrk(-(sbrk(0) - oldbrk));
    31c3:	48 8b 5d d8          	mov    -0x28(%rbp),%rbx
    31c7:	bf 00 00 00 00       	mov    $0x0,%edi
    31cc:	e8 70 0c 00 00       	callq  3e41 <sbrk>
    31d1:	48 29 c3             	sub    %rax,%rbx
    31d4:	48 89 d8             	mov    %rbx,%rax
    31d7:	89 c7                	mov    %eax,%edi
    31d9:	e8 63 0c 00 00       	callq  3e41 <sbrk>
    31de:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  if(c != a){
    31e2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
    31e6:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
    31ea:	74 26                	je     3212 <sbrktest+0x30c>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    31ec:	8b 05 f6 30 00 00    	mov    0x30f6(%rip),%eax        # 62e8 <stdout>
    31f2:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
    31f6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    31fa:	48 c7 c6 98 59 00 00 	mov    $0x5998,%rsi
    3201:	89 c7                	mov    %eax,%edi
    3203:	b8 00 00 00 00       	mov    $0x0,%eax
    3208:	e8 35 0d 00 00       	callq  3f42 <printf>
    exit();
    320d:	e8 a7 0b 00 00       	callq  3db9 <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3212:	48 c7 45 e8 00 00 00 	movq   $0xffffffff80000000,-0x18(%rbp)
    3219:	80 
    321a:	eb 7d                	jmp    3299 <sbrktest+0x393>
    ppid = getpid();
    321c:	e8 18 0c 00 00       	callq  3e39 <getpid>
    3221:	89 45 ac             	mov    %eax,-0x54(%rbp)
    pid = fork();
    3224:	e8 88 0b 00 00       	callq  3db1 <fork>
    3229:	89 45 d4             	mov    %eax,-0x2c(%rbp)
    if(pid < 0){
    322c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    3230:	79 1e                	jns    3250 <sbrktest+0x34a>
      printf(stdout, "fork failed\n");
    3232:	8b 05 b0 30 00 00    	mov    0x30b0(%rip),%eax        # 62e8 <stdout>
    3238:	48 c7 c6 39 49 00 00 	mov    $0x4939,%rsi
    323f:	89 c7                	mov    %eax,%edi
    3241:	b8 00 00 00 00       	mov    $0x0,%eax
    3246:	e8 f7 0c 00 00       	callq  3f42 <printf>
      exit();
    324b:	e8 69 0b 00 00       	callq  3db9 <exit>
    }
    if(pid == 0){
    3250:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
    3254:	75 36                	jne    328c <sbrktest+0x386>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    3256:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    325a:	0f b6 00             	movzbl (%rax),%eax
    325d:	0f be c8             	movsbl %al,%ecx
    3260:	8b 05 82 30 00 00    	mov    0x3082(%rip),%eax        # 62e8 <stdout>
    3266:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
    326a:	48 c7 c6 b9 59 00 00 	mov    $0x59b9,%rsi
    3271:	89 c7                	mov    %eax,%edi
    3273:	b8 00 00 00 00       	mov    $0x0,%eax
    3278:	e8 c5 0c 00 00       	callq  3f42 <printf>
      kill(ppid);
    327d:	8b 45 ac             	mov    -0x54(%rbp),%eax
    3280:	89 c7                	mov    %eax,%edi
    3282:	e8 62 0b 00 00       	callq  3de9 <kill>
      exit();
    3287:	e8 2d 0b 00 00       	callq  3db9 <exit>
    }
    wait();
    328c:	e8 30 0b 00 00       	callq  3dc1 <wait>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    3291:	48 81 45 e8 50 c3 00 	addq   $0xc350,-0x18(%rbp)
    3298:	00 
    3299:	48 81 7d e8 7f 84 1e 	cmpq   $0xffffffff801e847f,-0x18(%rbp)
    32a0:	80 
    32a1:	0f 86 75 ff ff ff    	jbe    321c <sbrktest+0x316>
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    32a7:	48 8d 45 98          	lea    -0x68(%rbp),%rax
    32ab:	48 89 c7             	mov    %rax,%rdi
    32ae:	e8 16 0b 00 00       	callq  3dc9 <pipe>
    32b3:	85 c0                	test   %eax,%eax
    32b5:	74 1b                	je     32d2 <sbrktest+0x3cc>
    printf(1, "pipe() failed\n");
    32b7:	48 c7 c6 8d 48 00 00 	mov    $0x488d,%rsi
    32be:	bf 01 00 00 00       	mov    $0x1,%edi
    32c3:	b8 00 00 00 00       	mov    $0x0,%eax
    32c8:	e8 75 0c 00 00       	callq  3f42 <printf>
    exit();
    32cd:	e8 e7 0a 00 00       	callq  3db9 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    32d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
    32d9:	e9 8d 00 00 00       	jmpq   336b <sbrktest+0x465>
    if((pids[i] = fork()) == 0){
    32de:	e8 ce 0a 00 00       	callq  3db1 <fork>
    32e3:	89 c2                	mov    %eax,%edx
    32e5:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    32e8:	48 98                	cltq   
    32ea:	89 94 85 70 ff ff ff 	mov    %edx,-0x90(%rbp,%rax,4)
    32f1:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    32f4:	48 98                	cltq   
    32f6:	8b 84 85 70 ff ff ff 	mov    -0x90(%rbp,%rax,4),%eax
    32fd:	85 c0                	test   %eax,%eax
    32ff:	75 3c                	jne    333d <sbrktest+0x437>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3301:	bf 00 00 00 00       	mov    $0x0,%edi
    3306:	e8 36 0b 00 00       	callq  3e41 <sbrk>
    330b:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3310:	29 c2                	sub    %eax,%edx
    3312:	89 d0                	mov    %edx,%eax
    3314:	89 c7                	mov    %eax,%edi
    3316:	e8 26 0b 00 00       	callq  3e41 <sbrk>
      write(fds[1], "x", 1);
    331b:	8b 45 9c             	mov    -0x64(%rbp),%eax
    331e:	ba 01 00 00 00       	mov    $0x1,%edx
    3323:	48 c7 c6 f2 48 00 00 	mov    $0x48f2,%rsi
    332a:	89 c7                	mov    %eax,%edi
    332c:	e8 a8 0a 00 00       	callq  3dd9 <write>
      // sit around until killed
      for(;;) sleep(1000);
    3331:	bf e8 03 00 00       	mov    $0x3e8,%edi
    3336:	e8 0e 0b 00 00       	callq  3e49 <sleep>
    333b:	eb f4                	jmp    3331 <sbrktest+0x42b>
    }
    if(pids[i] != -1)
    333d:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    3340:	48 98                	cltq   
    3342:	8b 84 85 70 ff ff ff 	mov    -0x90(%rbp,%rax,4),%eax
    3349:	83 f8 ff             	cmp    $0xffffffff,%eax
    334c:	74 19                	je     3367 <sbrktest+0x461>
      read(fds[0], &scratch, 1);
    334e:	8b 45 98             	mov    -0x68(%rbp),%eax
    3351:	48 8d 8d 6f ff ff ff 	lea    -0x91(%rbp),%rcx
    3358:	ba 01 00 00 00       	mov    $0x1,%edx
    335d:	48 89 ce             	mov    %rcx,%rsi
    3360:	89 c7                	mov    %eax,%edi
    3362:	e8 6a 0a 00 00       	callq  3dd1 <read>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3367:	83 45 e4 01          	addl   $0x1,-0x1c(%rbp)
    336b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    336e:	83 f8 09             	cmp    $0x9,%eax
    3371:	0f 86 67 ff ff ff    	jbe    32de <sbrktest+0x3d8>
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    3377:	bf 00 10 00 00       	mov    $0x1000,%edi
    337c:	e8 c0 0a 00 00       	callq  3e41 <sbrk>
    3381:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3385:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
    338c:	eb 30                	jmp    33be <sbrktest+0x4b8>
    if(pids[i] == -1)
    338e:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    3391:	48 98                	cltq   
    3393:	8b 84 85 70 ff ff ff 	mov    -0x90(%rbp,%rax,4),%eax
    339a:	83 f8 ff             	cmp    $0xffffffff,%eax
    339d:	74 1a                	je     33b9 <sbrktest+0x4b3>
      continue;
    kill(pids[i]);
    339f:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    33a2:	48 98                	cltq   
    33a4:	8b 84 85 70 ff ff ff 	mov    -0x90(%rbp,%rax,4),%eax
    33ab:	89 c7                	mov    %eax,%edi
    33ad:	e8 37 0a 00 00       	callq  3de9 <kill>
    wait();
    33b2:	e8 0a 0a 00 00       	callq  3dc1 <wait>
    33b7:	eb 01                	jmp    33ba <sbrktest+0x4b4>
      continue;
    33b9:	90                   	nop
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    33ba:	83 45 e4 01          	addl   $0x1,-0x1c(%rbp)
    33be:	8b 45 e4             	mov    -0x1c(%rbp),%eax
    33c1:	83 f8 09             	cmp    $0x9,%eax
    33c4:	76 c8                	jbe    338e <sbrktest+0x488>
  }
  if(c == (char*)0xffffffff){
    33c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    33cb:	48 39 45 c8          	cmp    %rax,-0x38(%rbp)
    33cf:	75 1e                	jne    33ef <sbrktest+0x4e9>
    printf(stdout, "failed sbrk leaked memory\n");
    33d1:	8b 05 11 2f 00 00    	mov    0x2f11(%rip),%eax        # 62e8 <stdout>
    33d7:	48 c7 c6 d2 59 00 00 	mov    $0x59d2,%rsi
    33de:	89 c7                	mov    %eax,%edi
    33e0:	b8 00 00 00 00       	mov    $0x0,%eax
    33e5:	e8 58 0b 00 00       	callq  3f42 <printf>
    exit();
    33ea:	e8 ca 09 00 00       	callq  3db9 <exit>
  }

  if(sbrk(0) > oldbrk)
    33ef:	bf 00 00 00 00       	mov    $0x0,%edi
    33f4:	e8 48 0a 00 00       	callq  3e41 <sbrk>
    33f9:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
    33fd:	73 1b                	jae    341a <sbrktest+0x514>
    sbrk(-(sbrk(0) - oldbrk));
    33ff:	48 8b 5d d8          	mov    -0x28(%rbp),%rbx
    3403:	bf 00 00 00 00       	mov    $0x0,%edi
    3408:	e8 34 0a 00 00       	callq  3e41 <sbrk>
    340d:	48 29 c3             	sub    %rax,%rbx
    3410:	48 89 d8             	mov    %rbx,%rax
    3413:	89 c7                	mov    %eax,%edi
    3415:	e8 27 0a 00 00       	callq  3e41 <sbrk>

  printf(stdout, "sbrk test OK\n");
    341a:	8b 05 c8 2e 00 00    	mov    0x2ec8(%rip),%eax        # 62e8 <stdout>
    3420:	48 c7 c6 ed 59 00 00 	mov    $0x59ed,%rsi
    3427:	89 c7                	mov    %eax,%edi
    3429:	b8 00 00 00 00       	mov    $0x0,%eax
    342e:	e8 0f 0b 00 00       	callq  3f42 <printf>
}
    3433:	90                   	nop
    3434:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
    343b:	5b                   	pop    %rbx
    343c:	5d                   	pop    %rbp
    343d:	c3                   	retq   

000000000000343e <validateint>:

void
validateint(int *p)
{
    343e:	55                   	push   %rbp
    343f:	48 89 e5             	mov    %rsp,%rbp
    3442:	48 83 ec 08          	sub    $0x8,%rsp
    3446:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
#endif
}
    344a:	90                   	nop
    344b:	c9                   	leaveq 
    344c:	c3                   	retq   

000000000000344d <validatetest>:

void
validatetest(void)
{
    344d:	55                   	push   %rbp
    344e:	48 89 e5             	mov    %rsp,%rbp
    3451:	48 83 ec 10          	sub    $0x10,%rsp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3455:	8b 05 8d 2e 00 00    	mov    0x2e8d(%rip),%eax        # 62e8 <stdout>
    345b:	48 c7 c6 fb 59 00 00 	mov    $0x59fb,%rsi
    3462:	89 c7                	mov    %eax,%edi
    3464:	b8 00 00 00 00       	mov    $0x0,%eax
    3469:	e8 d4 0a 00 00       	callq  3f42 <printf>
  hi = 1100*1024;
    346e:	c7 45 f8 00 30 11 00 	movl   $0x113000,-0x8(%rbp)

  for(p = 0; p <= (uint)hi; p += 4096){
    3475:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    347c:	eb 7d                	jmp    34fb <validatetest+0xae>
    if((pid = fork()) == 0){
    347e:	e8 2e 09 00 00       	callq  3db1 <fork>
    3483:	89 45 f4             	mov    %eax,-0xc(%rbp)
    3486:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    348a:	75 10                	jne    349c <validatetest+0x4f>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    348c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    348f:	48 89 c7             	mov    %rax,%rdi
    3492:	e8 a7 ff ff ff       	callq  343e <validateint>
      exit();
    3497:	e8 1d 09 00 00       	callq  3db9 <exit>
    }
    sleep(0);
    349c:	bf 00 00 00 00       	mov    $0x0,%edi
    34a1:	e8 a3 09 00 00       	callq  3e49 <sleep>
    sleep(0);
    34a6:	bf 00 00 00 00       	mov    $0x0,%edi
    34ab:	e8 99 09 00 00       	callq  3e49 <sleep>
    kill(pid);
    34b0:	8b 45 f4             	mov    -0xc(%rbp),%eax
    34b3:	89 c7                	mov    %eax,%edi
    34b5:	e8 2f 09 00 00       	callq  3de9 <kill>
    wait();
    34ba:	e8 02 09 00 00       	callq  3dc1 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    34bf:	8b 45 fc             	mov    -0x4(%rbp),%eax
    34c2:	48 89 c6             	mov    %rax,%rsi
    34c5:	48 c7 c7 0a 5a 00 00 	mov    $0x5a0a,%rdi
    34cc:	e8 48 09 00 00       	callq  3e19 <link>
    34d1:	83 f8 ff             	cmp    $0xffffffff,%eax
    34d4:	74 1e                	je     34f4 <validatetest+0xa7>
      printf(stdout, "link should not succeed\n");
    34d6:	8b 05 0c 2e 00 00    	mov    0x2e0c(%rip),%eax        # 62e8 <stdout>
    34dc:	48 c7 c6 15 5a 00 00 	mov    $0x5a15,%rsi
    34e3:	89 c7                	mov    %eax,%edi
    34e5:	b8 00 00 00 00       	mov    $0x0,%eax
    34ea:	e8 53 0a 00 00       	callq  3f42 <printf>
      exit();
    34ef:	e8 c5 08 00 00       	callq  3db9 <exit>
  for(p = 0; p <= (uint)hi; p += 4096){
    34f4:	81 45 fc 00 10 00 00 	addl   $0x1000,-0x4(%rbp)
    34fb:	8b 45 f8             	mov    -0x8(%rbp),%eax
    34fe:	39 45 fc             	cmp    %eax,-0x4(%rbp)
    3501:	0f 86 77 ff ff ff    	jbe    347e <validatetest+0x31>
    }
  }

  printf(stdout, "validate ok\n");
    3507:	8b 05 db 2d 00 00    	mov    0x2ddb(%rip),%eax        # 62e8 <stdout>
    350d:	48 c7 c6 2e 5a 00 00 	mov    $0x5a2e,%rsi
    3514:	89 c7                	mov    %eax,%edi
    3516:	b8 00 00 00 00       	mov    $0x0,%eax
    351b:	e8 22 0a 00 00       	callq  3f42 <printf>
}
    3520:	90                   	nop
    3521:	c9                   	leaveq 
    3522:	c3                   	retq   

0000000000003523 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3523:	55                   	push   %rbp
    3524:	48 89 e5             	mov    %rsp,%rbp
    3527:	48 83 ec 10          	sub    $0x10,%rsp
  int i;

  printf(stdout, "bss test\n");
    352b:	8b 05 b7 2d 00 00    	mov    0x2db7(%rip),%eax        # 62e8 <stdout>
    3531:	48 c7 c6 3b 5a 00 00 	mov    $0x5a3b,%rsi
    3538:	89 c7                	mov    %eax,%edi
    353a:	b8 00 00 00 00       	mov    $0x0,%eax
    353f:	e8 fe 09 00 00       	callq  3f42 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    3544:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    354b:	eb 32                	jmp    357f <bsstest+0x5c>
    if(uninit[i] != '\0'){
    354d:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3550:	48 98                	cltq   
    3552:	0f b6 80 40 83 00 00 	movzbl 0x8340(%rax),%eax
    3559:	84 c0                	test   %al,%al
    355b:	74 1e                	je     357b <bsstest+0x58>
      printf(stdout, "bss test failed\n");
    355d:	8b 05 85 2d 00 00    	mov    0x2d85(%rip),%eax        # 62e8 <stdout>
    3563:	48 c7 c6 45 5a 00 00 	mov    $0x5a45,%rsi
    356a:	89 c7                	mov    %eax,%edi
    356c:	b8 00 00 00 00       	mov    $0x0,%eax
    3571:	e8 cc 09 00 00       	callq  3f42 <printf>
      exit();
    3576:	e8 3e 08 00 00       	callq  3db9 <exit>
  for(i = 0; i < sizeof(uninit); i++){
    357b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    357f:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3582:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    3587:	76 c4                	jbe    354d <bsstest+0x2a>
    }
  }
  printf(stdout, "bss test ok\n");
    3589:	8b 05 59 2d 00 00    	mov    0x2d59(%rip),%eax        # 62e8 <stdout>
    358f:	48 c7 c6 56 5a 00 00 	mov    $0x5a56,%rsi
    3596:	89 c7                	mov    %eax,%edi
    3598:	b8 00 00 00 00       	mov    $0x0,%eax
    359d:	e8 a0 09 00 00       	callq  3f42 <printf>
}
    35a2:	90                   	nop
    35a3:	c9                   	leaveq 
    35a4:	c3                   	retq   

00000000000035a5 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    35a5:	55                   	push   %rbp
    35a6:	48 89 e5             	mov    %rsp,%rbp
    35a9:	48 83 ec 10          	sub    $0x10,%rsp
  int pid, fd;

  unlink("bigarg-ok");
    35ad:	48 c7 c7 63 5a 00 00 	mov    $0x5a63,%rdi
    35b4:	e8 50 08 00 00       	callq  3e09 <unlink>
  pid = fork();
    35b9:	e8 f3 07 00 00       	callq  3db1 <fork>
    35be:	89 45 f8             	mov    %eax,-0x8(%rbp)
  if(pid == 0){
    35c1:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    35c5:	0f 85 97 00 00 00    	jne    3662 <bigargtest+0xbd>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    35cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    35d2:	eb 15                	jmp    35e9 <bigargtest+0x44>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    35d4:	8b 45 fc             	mov    -0x4(%rbp),%eax
    35d7:	48 98                	cltq   
    35d9:	48 c7 04 c5 60 aa 00 	movq   $0x5a70,0xaa60(,%rax,8)
    35e0:	00 70 5a 00 00 
    for(i = 0; i < MAXARG-1; i++)
    35e5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    35e9:	83 7d fc 1e          	cmpl   $0x1e,-0x4(%rbp)
    35ed:	7e e5                	jle    35d4 <bigargtest+0x2f>
    args[MAXARG-1] = 0;
    35ef:	48 c7 05 5e 75 00 00 	movq   $0x0,0x755e(%rip)        # ab58 <args.1761+0xf8>
    35f6:	00 00 00 00 
    printf(stdout, "bigarg test\n");
    35fa:	8b 05 e8 2c 00 00    	mov    0x2ce8(%rip),%eax        # 62e8 <stdout>
    3600:	48 c7 c6 4d 5b 00 00 	mov    $0x5b4d,%rsi
    3607:	89 c7                	mov    %eax,%edi
    3609:	b8 00 00 00 00       	mov    $0x0,%eax
    360e:	e8 2f 09 00 00       	callq  3f42 <printf>
    exec("echo", args);
    3613:	48 c7 c6 60 aa 00 00 	mov    $0xaa60,%rsi
    361a:	48 c7 c7 48 45 00 00 	mov    $0x4548,%rdi
    3621:	e8 cb 07 00 00       	callq  3df1 <exec>
    printf(stdout, "bigarg test ok\n");
    3626:	8b 05 bc 2c 00 00    	mov    0x2cbc(%rip),%eax        # 62e8 <stdout>
    362c:	48 c7 c6 5a 5b 00 00 	mov    $0x5b5a,%rsi
    3633:	89 c7                	mov    %eax,%edi
    3635:	b8 00 00 00 00       	mov    $0x0,%eax
    363a:	e8 03 09 00 00       	callq  3f42 <printf>
    fd = open("bigarg-ok", O_CREATE);
    363f:	be 00 02 00 00       	mov    $0x200,%esi
    3644:	48 c7 c7 63 5a 00 00 	mov    $0x5a63,%rdi
    364b:	e8 a9 07 00 00       	callq  3df9 <open>
    3650:	89 45 f4             	mov    %eax,-0xc(%rbp)
    close(fd);
    3653:	8b 45 f4             	mov    -0xc(%rbp),%eax
    3656:	89 c7                	mov    %eax,%edi
    3658:	e8 84 07 00 00       	callq  3de1 <close>
    exit();
    365d:	e8 57 07 00 00       	callq  3db9 <exit>
  } else if(pid < 0){
    3662:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    3666:	79 1e                	jns    3686 <bigargtest+0xe1>
    printf(stdout, "bigargtest: fork failed\n");
    3668:	8b 05 7a 2c 00 00    	mov    0x2c7a(%rip),%eax        # 62e8 <stdout>
    366e:	48 c7 c6 6a 5b 00 00 	mov    $0x5b6a,%rsi
    3675:	89 c7                	mov    %eax,%edi
    3677:	b8 00 00 00 00       	mov    $0x0,%eax
    367c:	e8 c1 08 00 00       	callq  3f42 <printf>
    exit();
    3681:	e8 33 07 00 00       	callq  3db9 <exit>
  }
  wait();
    3686:	e8 36 07 00 00       	callq  3dc1 <wait>
  fd = open("bigarg-ok", 0);
    368b:	be 00 00 00 00       	mov    $0x0,%esi
    3690:	48 c7 c7 63 5a 00 00 	mov    $0x5a63,%rdi
    3697:	e8 5d 07 00 00       	callq  3df9 <open>
    369c:	89 45 f4             	mov    %eax,-0xc(%rbp)
  if(fd < 0){
    369f:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    36a3:	79 1e                	jns    36c3 <bigargtest+0x11e>
    printf(stdout, "bigarg test failed!\n");
    36a5:	8b 05 3d 2c 00 00    	mov    0x2c3d(%rip),%eax        # 62e8 <stdout>
    36ab:	48 c7 c6 83 5b 00 00 	mov    $0x5b83,%rsi
    36b2:	89 c7                	mov    %eax,%edi
    36b4:	b8 00 00 00 00       	mov    $0x0,%eax
    36b9:	e8 84 08 00 00       	callq  3f42 <printf>
    exit();
    36be:	e8 f6 06 00 00       	callq  3db9 <exit>
  }
  close(fd);
    36c3:	8b 45 f4             	mov    -0xc(%rbp),%eax
    36c6:	89 c7                	mov    %eax,%edi
    36c8:	e8 14 07 00 00       	callq  3de1 <close>
  unlink("bigarg-ok");
    36cd:	48 c7 c7 63 5a 00 00 	mov    $0x5a63,%rdi
    36d4:	e8 30 07 00 00       	callq  3e09 <unlink>
}
    36d9:	90                   	nop
    36da:	c9                   	leaveq 
    36db:	c3                   	retq   

00000000000036dc <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    36dc:	55                   	push   %rbp
    36dd:	48 89 e5             	mov    %rsp,%rbp
    36e0:	48 83 ec 60          	sub    $0x60,%rsp
  int nfiles;
  int fsblocks = 0;
    36e4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)

  printf(1, "fsfull test\n");
    36eb:	48 c7 c6 98 5b 00 00 	mov    $0x5b98,%rsi
    36f2:	bf 01 00 00 00       	mov    $0x1,%edi
    36f7:	b8 00 00 00 00       	mov    $0x0,%eax
    36fc:	e8 41 08 00 00       	callq  3f42 <printf>

  for(nfiles = 0; ; nfiles++){
    3701:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    char name[64];
    name[0] = 'f';
    3708:	c6 45 a0 66          	movb   $0x66,-0x60(%rbp)
    name[1] = '0' + nfiles / 1000;
    370c:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    370f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3714:	89 c8                	mov    %ecx,%eax
    3716:	f7 ea                	imul   %edx
    3718:	c1 fa 06             	sar    $0x6,%edx
    371b:	89 c8                	mov    %ecx,%eax
    371d:	c1 f8 1f             	sar    $0x1f,%eax
    3720:	29 c2                	sub    %eax,%edx
    3722:	89 d0                	mov    %edx,%eax
    3724:	83 c0 30             	add    $0x30,%eax
    3727:	88 45 a1             	mov    %al,-0x5f(%rbp)
    name[2] = '0' + (nfiles % 1000) / 100;
    372a:	8b 75 fc             	mov    -0x4(%rbp),%esi
    372d:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3732:	89 f0                	mov    %esi,%eax
    3734:	f7 ea                	imul   %edx
    3736:	c1 fa 06             	sar    $0x6,%edx
    3739:	89 f0                	mov    %esi,%eax
    373b:	c1 f8 1f             	sar    $0x1f,%eax
    373e:	89 d1                	mov    %edx,%ecx
    3740:	29 c1                	sub    %eax,%ecx
    3742:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3748:	29 c6                	sub    %eax,%esi
    374a:	89 f1                	mov    %esi,%ecx
    374c:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3751:	89 c8                	mov    %ecx,%eax
    3753:	f7 ea                	imul   %edx
    3755:	c1 fa 05             	sar    $0x5,%edx
    3758:	89 c8                	mov    %ecx,%eax
    375a:	c1 f8 1f             	sar    $0x1f,%eax
    375d:	29 c2                	sub    %eax,%edx
    375f:	89 d0                	mov    %edx,%eax
    3761:	83 c0 30             	add    $0x30,%eax
    3764:	88 45 a2             	mov    %al,-0x5e(%rbp)
    name[3] = '0' + (nfiles % 100) / 10;
    3767:	8b 75 fc             	mov    -0x4(%rbp),%esi
    376a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    376f:	89 f0                	mov    %esi,%eax
    3771:	f7 ea                	imul   %edx
    3773:	c1 fa 05             	sar    $0x5,%edx
    3776:	89 f0                	mov    %esi,%eax
    3778:	c1 f8 1f             	sar    $0x1f,%eax
    377b:	89 d1                	mov    %edx,%ecx
    377d:	29 c1                	sub    %eax,%ecx
    377f:	6b c1 64             	imul   $0x64,%ecx,%eax
    3782:	29 c6                	sub    %eax,%esi
    3784:	89 f1                	mov    %esi,%ecx
    3786:	ba 67 66 66 66       	mov    $0x66666667,%edx
    378b:	89 c8                	mov    %ecx,%eax
    378d:	f7 ea                	imul   %edx
    378f:	c1 fa 02             	sar    $0x2,%edx
    3792:	89 c8                	mov    %ecx,%eax
    3794:	c1 f8 1f             	sar    $0x1f,%eax
    3797:	29 c2                	sub    %eax,%edx
    3799:	89 d0                	mov    %edx,%eax
    379b:	83 c0 30             	add    $0x30,%eax
    379e:	88 45 a3             	mov    %al,-0x5d(%rbp)
    name[4] = '0' + (nfiles % 10);
    37a1:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    37a4:	ba 67 66 66 66       	mov    $0x66666667,%edx
    37a9:	89 c8                	mov    %ecx,%eax
    37ab:	f7 ea                	imul   %edx
    37ad:	c1 fa 02             	sar    $0x2,%edx
    37b0:	89 c8                	mov    %ecx,%eax
    37b2:	c1 f8 1f             	sar    $0x1f,%eax
    37b5:	29 c2                	sub    %eax,%edx
    37b7:	89 d0                	mov    %edx,%eax
    37b9:	c1 e0 02             	shl    $0x2,%eax
    37bc:	01 d0                	add    %edx,%eax
    37be:	01 c0                	add    %eax,%eax
    37c0:	29 c1                	sub    %eax,%ecx
    37c2:	89 ca                	mov    %ecx,%edx
    37c4:	89 d0                	mov    %edx,%eax
    37c6:	83 c0 30             	add    $0x30,%eax
    37c9:	88 45 a4             	mov    %al,-0x5c(%rbp)
    name[5] = '\0';
    37cc:	c6 45 a5 00          	movb   $0x0,-0x5b(%rbp)
    printf(1, "writing %s\n", name);
    37d0:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
    37d4:	48 89 c2             	mov    %rax,%rdx
    37d7:	48 c7 c6 a5 5b 00 00 	mov    $0x5ba5,%rsi
    37de:	bf 01 00 00 00       	mov    $0x1,%edi
    37e3:	b8 00 00 00 00       	mov    $0x0,%eax
    37e8:	e8 55 07 00 00       	callq  3f42 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    37ed:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
    37f1:	be 02 02 00 00       	mov    $0x202,%esi
    37f6:	48 89 c7             	mov    %rax,%rdi
    37f9:	e8 fb 05 00 00       	callq  3df9 <open>
    37fe:	89 45 f0             	mov    %eax,-0x10(%rbp)
    if(fd < 0){
    3801:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
    3805:	79 1f                	jns    3826 <fsfull+0x14a>
      printf(1, "open %s failed\n", name);
    3807:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
    380b:	48 89 c2             	mov    %rax,%rdx
    380e:	48 c7 c6 b1 5b 00 00 	mov    $0x5bb1,%rsi
    3815:	bf 01 00 00 00       	mov    $0x1,%edi
    381a:	b8 00 00 00 00       	mov    $0x0,%eax
    381f:	e8 1e 07 00 00       	callq  3f42 <printf>
      break;
    3824:	eb 6b                	jmp    3891 <fsfull+0x1b5>
    }
    int total = 0;
    3826:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    while(1){
      int cc = write(fd, buf, 512);
    382d:	8b 45 f0             	mov    -0x10(%rbp),%eax
    3830:	ba 00 02 00 00       	mov    $0x200,%edx
    3835:	48 c7 c6 20 63 00 00 	mov    $0x6320,%rsi
    383c:	89 c7                	mov    %eax,%edi
    383e:	e8 96 05 00 00       	callq  3dd9 <write>
    3843:	89 45 ec             	mov    %eax,-0x14(%rbp)
      if(cc < 512)
    3846:	81 7d ec ff 01 00 00 	cmpl   $0x1ff,-0x14(%rbp)
    384d:	7e 0c                	jle    385b <fsfull+0x17f>
        break;
      total += cc;
    384f:	8b 45 ec             	mov    -0x14(%rbp),%eax
    3852:	01 45 f4             	add    %eax,-0xc(%rbp)
      fsblocks++;
    3855:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
    while(1){
    3859:	eb d2                	jmp    382d <fsfull+0x151>
        break;
    385b:	90                   	nop
    }
    printf(1, "wrote %d bytes\n", total);
    385c:	8b 45 f4             	mov    -0xc(%rbp),%eax
    385f:	89 c2                	mov    %eax,%edx
    3861:	48 c7 c6 c1 5b 00 00 	mov    $0x5bc1,%rsi
    3868:	bf 01 00 00 00       	mov    $0x1,%edi
    386d:	b8 00 00 00 00       	mov    $0x0,%eax
    3872:	e8 cb 06 00 00       	callq  3f42 <printf>
    close(fd);
    3877:	8b 45 f0             	mov    -0x10(%rbp),%eax
    387a:	89 c7                	mov    %eax,%edi
    387c:	e8 60 05 00 00       	callq  3de1 <close>
    if(total == 0)
    3881:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    3885:	74 09                	je     3890 <fsfull+0x1b4>
  for(nfiles = 0; ; nfiles++){
    3887:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    388b:	e9 78 fe ff ff       	jmpq   3708 <fsfull+0x2c>
      break;
    3890:	90                   	nop
  }

  while(nfiles >= 0){
    3891:	e9 d8 00 00 00       	jmpq   396e <fsfull+0x292>
    char name[64];
    name[0] = 'f';
    3896:	c6 45 a0 66          	movb   $0x66,-0x60(%rbp)
    name[1] = '0' + nfiles / 1000;
    389a:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    389d:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38a2:	89 c8                	mov    %ecx,%eax
    38a4:	f7 ea                	imul   %edx
    38a6:	c1 fa 06             	sar    $0x6,%edx
    38a9:	89 c8                	mov    %ecx,%eax
    38ab:	c1 f8 1f             	sar    $0x1f,%eax
    38ae:	29 c2                	sub    %eax,%edx
    38b0:	89 d0                	mov    %edx,%eax
    38b2:	83 c0 30             	add    $0x30,%eax
    38b5:	88 45 a1             	mov    %al,-0x5f(%rbp)
    name[2] = '0' + (nfiles % 1000) / 100;
    38b8:	8b 75 fc             	mov    -0x4(%rbp),%esi
    38bb:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    38c0:	89 f0                	mov    %esi,%eax
    38c2:	f7 ea                	imul   %edx
    38c4:	c1 fa 06             	sar    $0x6,%edx
    38c7:	89 f0                	mov    %esi,%eax
    38c9:	c1 f8 1f             	sar    $0x1f,%eax
    38cc:	89 d1                	mov    %edx,%ecx
    38ce:	29 c1                	sub    %eax,%ecx
    38d0:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    38d6:	29 c6                	sub    %eax,%esi
    38d8:	89 f1                	mov    %esi,%ecx
    38da:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    38df:	89 c8                	mov    %ecx,%eax
    38e1:	f7 ea                	imul   %edx
    38e3:	c1 fa 05             	sar    $0x5,%edx
    38e6:	89 c8                	mov    %ecx,%eax
    38e8:	c1 f8 1f             	sar    $0x1f,%eax
    38eb:	29 c2                	sub    %eax,%edx
    38ed:	89 d0                	mov    %edx,%eax
    38ef:	83 c0 30             	add    $0x30,%eax
    38f2:	88 45 a2             	mov    %al,-0x5e(%rbp)
    name[3] = '0' + (nfiles % 100) / 10;
    38f5:	8b 75 fc             	mov    -0x4(%rbp),%esi
    38f8:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    38fd:	89 f0                	mov    %esi,%eax
    38ff:	f7 ea                	imul   %edx
    3901:	c1 fa 05             	sar    $0x5,%edx
    3904:	89 f0                	mov    %esi,%eax
    3906:	c1 f8 1f             	sar    $0x1f,%eax
    3909:	89 d1                	mov    %edx,%ecx
    390b:	29 c1                	sub    %eax,%ecx
    390d:	6b c1 64             	imul   $0x64,%ecx,%eax
    3910:	29 c6                	sub    %eax,%esi
    3912:	89 f1                	mov    %esi,%ecx
    3914:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3919:	89 c8                	mov    %ecx,%eax
    391b:	f7 ea                	imul   %edx
    391d:	c1 fa 02             	sar    $0x2,%edx
    3920:	89 c8                	mov    %ecx,%eax
    3922:	c1 f8 1f             	sar    $0x1f,%eax
    3925:	29 c2                	sub    %eax,%edx
    3927:	89 d0                	mov    %edx,%eax
    3929:	83 c0 30             	add    $0x30,%eax
    392c:	88 45 a3             	mov    %al,-0x5d(%rbp)
    name[4] = '0' + (nfiles % 10);
    392f:	8b 4d fc             	mov    -0x4(%rbp),%ecx
    3932:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3937:	89 c8                	mov    %ecx,%eax
    3939:	f7 ea                	imul   %edx
    393b:	c1 fa 02             	sar    $0x2,%edx
    393e:	89 c8                	mov    %ecx,%eax
    3940:	c1 f8 1f             	sar    $0x1f,%eax
    3943:	29 c2                	sub    %eax,%edx
    3945:	89 d0                	mov    %edx,%eax
    3947:	c1 e0 02             	shl    $0x2,%eax
    394a:	01 d0                	add    %edx,%eax
    394c:	01 c0                	add    %eax,%eax
    394e:	29 c1                	sub    %eax,%ecx
    3950:	89 ca                	mov    %ecx,%edx
    3952:	89 d0                	mov    %edx,%eax
    3954:	83 c0 30             	add    $0x30,%eax
    3957:	88 45 a4             	mov    %al,-0x5c(%rbp)
    name[5] = '\0';
    395a:	c6 45 a5 00          	movb   $0x0,-0x5b(%rbp)
    unlink(name);
    395e:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
    3962:	48 89 c7             	mov    %rax,%rdi
    3965:	e8 9f 04 00 00       	callq  3e09 <unlink>
    nfiles--;
    396a:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
  while(nfiles >= 0){
    396e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    3972:	0f 89 1e ff ff ff    	jns    3896 <fsfull+0x1ba>
  }

  printf(1, "fsfull test finished\n");
    3978:	48 c7 c6 d1 5b 00 00 	mov    $0x5bd1,%rsi
    397f:	bf 01 00 00 00       	mov    $0x1,%edi
    3984:	b8 00 00 00 00       	mov    $0x0,%eax
    3989:	e8 b4 05 00 00       	callq  3f42 <printf>
}
    398e:	90                   	nop
    398f:	c9                   	leaveq 
    3990:	c3                   	retq   

0000000000003991 <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3991:	55                   	push   %rbp
    3992:	48 89 e5             	mov    %rsp,%rbp
  randstate = randstate * 1664525 + 1013904223;
    3995:	48 8b 05 54 29 00 00 	mov    0x2954(%rip),%rax        # 62f0 <randstate>
    399c:	48 69 c0 0d 66 19 00 	imul   $0x19660d,%rax,%rax
    39a3:	48 05 5f f3 6e 3c    	add    $0x3c6ef35f,%rax
    39a9:	48 89 05 40 29 00 00 	mov    %rax,0x2940(%rip)        # 62f0 <randstate>
  return randstate;
    39b0:	48 8b 05 39 29 00 00 	mov    0x2939(%rip),%rax        # 62f0 <randstate>
}
    39b7:	5d                   	pop    %rbp
    39b8:	c3                   	retq   

00000000000039b9 <main>:

int
main(int argc, char *argv[])
{
    39b9:	55                   	push   %rbp
    39ba:	48 89 e5             	mov    %rsp,%rbp
    39bd:	48 83 ec 10          	sub    $0x10,%rsp
    39c1:	89 7d fc             	mov    %edi,-0x4(%rbp)
    39c4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  printf(1, "usertests starting\n");
    39c8:	48 c7 c6 e7 5b 00 00 	mov    $0x5be7,%rsi
    39cf:	bf 01 00 00 00       	mov    $0x1,%edi
    39d4:	b8 00 00 00 00       	mov    $0x0,%eax
    39d9:	e8 64 05 00 00       	callq  3f42 <printf>

  if(open("usertests.ran", 0) >= 0){
    39de:	be 00 00 00 00       	mov    $0x0,%esi
    39e3:	48 c7 c7 fb 5b 00 00 	mov    $0x5bfb,%rdi
    39ea:	e8 0a 04 00 00       	callq  3df9 <open>
    39ef:	85 c0                	test   %eax,%eax
    39f1:	78 1b                	js     3a0e <main+0x55>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    39f3:	48 c7 c6 10 5c 00 00 	mov    $0x5c10,%rsi
    39fa:	bf 01 00 00 00       	mov    $0x1,%edi
    39ff:	b8 00 00 00 00       	mov    $0x0,%eax
    3a04:	e8 39 05 00 00       	callq  3f42 <printf>
    exit();
    3a09:	e8 ab 03 00 00       	callq  3db9 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    3a0e:	be 00 02 00 00       	mov    $0x200,%esi
    3a13:	48 c7 c7 fb 5b 00 00 	mov    $0x5bfb,%rdi
    3a1a:	e8 da 03 00 00       	callq  3df9 <open>
    3a1f:	89 c7                	mov    %eax,%edi
    3a21:	e8 bb 03 00 00       	callq  3de1 <close>

  bigargtest();
    3a26:	e8 7a fb ff ff       	callq  35a5 <bigargtest>
  bigwrite();
    3a2b:	e8 72 ea ff ff       	callq  24a2 <bigwrite>
  bigargtest();
    3a30:	e8 70 fb ff ff       	callq  35a5 <bigargtest>
  bsstest();
    3a35:	e8 e9 fa ff ff       	callq  3523 <bsstest>
  sbrktest();
    3a3a:	e8 c7 f4 ff ff       	callq  2f06 <sbrktest>
  validatetest();
    3a3f:	e8 09 fa ff ff       	callq  344d <validatetest>

  opentest();
    3a44:	e8 b7 c5 ff ff       	callq  0 <opentest>
  writetest();
    3a49:	e8 69 c6 ff ff       	callq  b7 <writetest>
  writetest1();
    3a4e:	e8 8d c8 ff ff       	callq  2e0 <writetest1>
  createtest();
    3a53:	e8 98 ca ff ff       	callq  4f0 <createtest>

  mem();
    3a58:	e8 66 d0 ff ff       	callq  ac3 <mem>
  pipe1();
    3a5d:	e8 95 cc ff ff       	callq  6f7 <pipe1>
  preempt();
    3a62:	e8 7f ce ff ff       	callq  8e6 <preempt>
  exitwait();
    3a67:	e8 d1 cf ff ff       	callq  a3d <exitwait>

  rmdot();
    3a6c:	e8 be ee ff ff       	callq  292f <rmdot>
  fourteen();
    3a71:	e8 58 ed ff ff       	callq  27ce <fourteen>
  bigfile();
    3a76:	e8 2c eb ff ff       	callq  25a7 <bigfile>
  subdir();
    3a7b:	e8 c8 e2 ff ff       	callq  1d48 <subdir>
  concreate();
    3a80:	e8 65 dc ff ff       	callq  16ea <concreate>
  linkunlink();
    3a85:	b8 00 00 00 00       	mov    $0x0,%eax
    3a8a:	e8 0e e0 ff ff       	callq  1a9d <linkunlink>
  linktest();
    3a8f:	e8 0d da ff ff       	callq  14a1 <linktest>
  unlinkread();
    3a94:	e8 40 d8 ff ff       	callq  12d9 <unlinkread>
  createdelete();
    3a99:	e8 7b d5 ff ff       	callq  1019 <createdelete>
  twofiles();
    3a9e:	e8 0d d3 ff ff       	callq  db0 <twofiles>
  sharedfd();
    3aa3:	e8 16 d1 ff ff       	callq  bbe <sharedfd>
  dirfile();
    3aa8:	e8 0d f0 ff ff       	callq  2aba <dirfile>
  iref();
    3aad:	e8 4e f2 ff ff       	callq  2d00 <iref>
  forktest();
    3ab2:	e8 6f f3 ff ff       	callq  2e26 <forktest>
  bigdir(); // slow
    3ab7:	e8 15 e1 ff ff       	callq  1bd1 <bigdir>

  exectest();
    3abc:	e8 e1 cb ff ff       	callq  6a2 <exectest>

  exit();
    3ac1:	e8 f3 02 00 00       	callq  3db9 <exit>

0000000000003ac6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    3ac6:	55                   	push   %rbp
    3ac7:	48 89 e5             	mov    %rsp,%rbp
    3aca:	48 83 ec 10          	sub    $0x10,%rsp
    3ace:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    3ad2:	89 75 f4             	mov    %esi,-0xc(%rbp)
    3ad5:	89 55 f0             	mov    %edx,-0x10(%rbp)
  asm volatile("cld; rep stosb" :
    3ad8:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
    3adc:	8b 55 f0             	mov    -0x10(%rbp),%edx
    3adf:	8b 45 f4             	mov    -0xc(%rbp),%eax
    3ae2:	48 89 ce             	mov    %rcx,%rsi
    3ae5:	48 89 f7             	mov    %rsi,%rdi
    3ae8:	89 d1                	mov    %edx,%ecx
    3aea:	fc                   	cld    
    3aeb:	f3 aa                	rep stos %al,%es:(%rdi)
    3aed:	89 ca                	mov    %ecx,%edx
    3aef:	48 89 fe             	mov    %rdi,%rsi
    3af2:	48 89 75 f8          	mov    %rsi,-0x8(%rbp)
    3af6:	89 55 f0             	mov    %edx,-0x10(%rbp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    3af9:	90                   	nop
    3afa:	c9                   	leaveq 
    3afb:	c3                   	retq   

0000000000003afc <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    3afc:	55                   	push   %rbp
    3afd:	48 89 e5             	mov    %rsp,%rbp
    3b00:	48 83 ec 20          	sub    $0x20,%rsp
    3b04:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    3b08:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  char *os;

  os = s;
    3b0c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3b10:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  while((*s++ = *t++) != 0)
    3b14:	90                   	nop
    3b15:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
    3b19:	48 8d 42 01          	lea    0x1(%rdx),%rax
    3b1d:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    3b21:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3b25:	48 8d 48 01          	lea    0x1(%rax),%rcx
    3b29:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
    3b2d:	0f b6 12             	movzbl (%rdx),%edx
    3b30:	88 10                	mov    %dl,(%rax)
    3b32:	0f b6 00             	movzbl (%rax),%eax
    3b35:	84 c0                	test   %al,%al
    3b37:	75 dc                	jne    3b15 <strcpy+0x19>
    ;
  return os;
    3b39:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
    3b3d:	c9                   	leaveq 
    3b3e:	c3                   	retq   

0000000000003b3f <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3b3f:	55                   	push   %rbp
    3b40:	48 89 e5             	mov    %rsp,%rbp
    3b43:	48 83 ec 10          	sub    $0x10,%rsp
    3b47:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    3b4b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  while(*p && *p == *q)
    3b4f:	eb 0a                	jmp    3b5b <strcmp+0x1c>
    p++, q++;
    3b51:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    3b56:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  while(*p && *p == *q)
    3b5b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3b5f:	0f b6 00             	movzbl (%rax),%eax
    3b62:	84 c0                	test   %al,%al
    3b64:	74 12                	je     3b78 <strcmp+0x39>
    3b66:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3b6a:	0f b6 10             	movzbl (%rax),%edx
    3b6d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    3b71:	0f b6 00             	movzbl (%rax),%eax
    3b74:	38 c2                	cmp    %al,%dl
    3b76:	74 d9                	je     3b51 <strcmp+0x12>
  return (uchar)*p - (uchar)*q;
    3b78:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3b7c:	0f b6 00             	movzbl (%rax),%eax
    3b7f:	0f b6 d0             	movzbl %al,%edx
    3b82:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    3b86:	0f b6 00             	movzbl (%rax),%eax
    3b89:	0f b6 c0             	movzbl %al,%eax
    3b8c:	29 c2                	sub    %eax,%edx
    3b8e:	89 d0                	mov    %edx,%eax
}
    3b90:	c9                   	leaveq 
    3b91:	c3                   	retq   

0000000000003b92 <strlen>:

uint
strlen(char *s)
{
    3b92:	55                   	push   %rbp
    3b93:	48 89 e5             	mov    %rsp,%rbp
    3b96:	48 83 ec 18          	sub    $0x18,%rsp
    3b9a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  for(n = 0; s[n]; n++)
    3b9e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    3ba5:	eb 04                	jmp    3bab <strlen+0x19>
    3ba7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
    3bab:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3bae:	48 63 d0             	movslq %eax,%rdx
    3bb1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3bb5:	48 01 d0             	add    %rdx,%rax
    3bb8:	0f b6 00             	movzbl (%rax),%eax
    3bbb:	84 c0                	test   %al,%al
    3bbd:	75 e8                	jne    3ba7 <strlen+0x15>
    ;
  return n;
    3bbf:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
    3bc2:	c9                   	leaveq 
    3bc3:	c3                   	retq   

0000000000003bc4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    3bc4:	55                   	push   %rbp
    3bc5:	48 89 e5             	mov    %rsp,%rbp
    3bc8:	48 83 ec 10          	sub    $0x10,%rsp
    3bcc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    3bd0:	89 75 f4             	mov    %esi,-0xc(%rbp)
    3bd3:	89 55 f0             	mov    %edx,-0x10(%rbp)
  stosb(dst, c, n);
    3bd6:	8b 55 f0             	mov    -0x10(%rbp),%edx
    3bd9:	8b 4d f4             	mov    -0xc(%rbp),%ecx
    3bdc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3be0:	89 ce                	mov    %ecx,%esi
    3be2:	48 89 c7             	mov    %rax,%rdi
    3be5:	e8 dc fe ff ff       	callq  3ac6 <stosb>
  return dst;
    3bea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
    3bee:	c9                   	leaveq 
    3bef:	c3                   	retq   

0000000000003bf0 <strchr>:

char*
strchr(const char *s, char c)
{
    3bf0:	55                   	push   %rbp
    3bf1:	48 89 e5             	mov    %rsp,%rbp
    3bf4:	48 83 ec 10          	sub    $0x10,%rsp
    3bf8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    3bfc:	89 f0                	mov    %esi,%eax
    3bfe:	88 45 f4             	mov    %al,-0xc(%rbp)
  for(; *s; s++)
    3c01:	eb 17                	jmp    3c1a <strchr+0x2a>
    if(*s == c)
    3c03:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3c07:	0f b6 00             	movzbl (%rax),%eax
    3c0a:	38 45 f4             	cmp    %al,-0xc(%rbp)
    3c0d:	75 06                	jne    3c15 <strchr+0x25>
      return (char*)s;
    3c0f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3c13:	eb 15                	jmp    3c2a <strchr+0x3a>
  for(; *s; s++)
    3c15:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    3c1a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3c1e:	0f b6 00             	movzbl (%rax),%eax
    3c21:	84 c0                	test   %al,%al
    3c23:	75 de                	jne    3c03 <strchr+0x13>
  return 0;
    3c25:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3c2a:	c9                   	leaveq 
    3c2b:	c3                   	retq   

0000000000003c2c <gets>:

char*
gets(char *buf, int max)
{
    3c2c:	55                   	push   %rbp
    3c2d:	48 89 e5             	mov    %rsp,%rbp
    3c30:	48 83 ec 20          	sub    $0x20,%rsp
    3c34:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    3c38:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3c3b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    3c42:	eb 48                	jmp    3c8c <gets+0x60>
    cc = read(0, &c, 1);
    3c44:	48 8d 45 f7          	lea    -0x9(%rbp),%rax
    3c48:	ba 01 00 00 00       	mov    $0x1,%edx
    3c4d:	48 89 c6             	mov    %rax,%rsi
    3c50:	bf 00 00 00 00       	mov    $0x0,%edi
    3c55:	e8 77 01 00 00       	callq  3dd1 <read>
    3c5a:	89 45 f8             	mov    %eax,-0x8(%rbp)
    if(cc < 1)
    3c5d:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    3c61:	7e 36                	jle    3c99 <gets+0x6d>
      break;
    buf[i++] = c;
    3c63:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3c66:	8d 50 01             	lea    0x1(%rax),%edx
    3c69:	89 55 fc             	mov    %edx,-0x4(%rbp)
    3c6c:	48 63 d0             	movslq %eax,%rdx
    3c6f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3c73:	48 01 c2             	add    %rax,%rdx
    3c76:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    3c7a:	88 02                	mov    %al,(%rdx)
    if(c == '\n' || c == '\r')
    3c7c:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    3c80:	3c 0a                	cmp    $0xa,%al
    3c82:	74 16                	je     3c9a <gets+0x6e>
    3c84:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
    3c88:	3c 0d                	cmp    $0xd,%al
    3c8a:	74 0e                	je     3c9a <gets+0x6e>
  for(i=0; i+1 < max; ){
    3c8c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3c8f:	83 c0 01             	add    $0x1,%eax
    3c92:	39 45 e4             	cmp    %eax,-0x1c(%rbp)
    3c95:	7f ad                	jg     3c44 <gets+0x18>
    3c97:	eb 01                	jmp    3c9a <gets+0x6e>
      break;
    3c99:	90                   	nop
      break;
  }
  buf[i] = '\0';
    3c9a:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3c9d:	48 63 d0             	movslq %eax,%rdx
    3ca0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3ca4:	48 01 d0             	add    %rdx,%rax
    3ca7:	c6 00 00             	movb   $0x0,(%rax)
  return buf;
    3caa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
    3cae:	c9                   	leaveq 
    3caf:	c3                   	retq   

0000000000003cb0 <stat>:

int
stat(char *n, struct stat *st)
{
    3cb0:	55                   	push   %rbp
    3cb1:	48 89 e5             	mov    %rsp,%rbp
    3cb4:	48 83 ec 20          	sub    $0x20,%rsp
    3cb8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    3cbc:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3cc0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3cc4:	be 00 00 00 00       	mov    $0x0,%esi
    3cc9:	48 89 c7             	mov    %rax,%rdi
    3ccc:	e8 28 01 00 00       	callq  3df9 <open>
    3cd1:	89 45 fc             	mov    %eax,-0x4(%rbp)
  if(fd < 0)
    3cd4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    3cd8:	79 07                	jns    3ce1 <stat+0x31>
    return -1;
    3cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3cdf:	eb 21                	jmp    3d02 <stat+0x52>
  r = fstat(fd, st);
    3ce1:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
    3ce5:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3ce8:	48 89 d6             	mov    %rdx,%rsi
    3ceb:	89 c7                	mov    %eax,%edi
    3ced:	e8 1f 01 00 00       	callq  3e11 <fstat>
    3cf2:	89 45 f8             	mov    %eax,-0x8(%rbp)
  close(fd);
    3cf5:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3cf8:	89 c7                	mov    %eax,%edi
    3cfa:	e8 e2 00 00 00       	callq  3de1 <close>
  return r;
    3cff:	8b 45 f8             	mov    -0x8(%rbp),%eax
}
    3d02:	c9                   	leaveq 
    3d03:	c3                   	retq   

0000000000003d04 <atoi>:

int
atoi(const char *s)
{
    3d04:	55                   	push   %rbp
    3d05:	48 89 e5             	mov    %rsp,%rbp
    3d08:	48 83 ec 18          	sub    $0x18,%rsp
    3d0c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  int n;

  n = 0;
    3d10:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
    3d17:	eb 28                	jmp    3d41 <atoi+0x3d>
    n = n*10 + *s++ - '0';
    3d19:	8b 55 fc             	mov    -0x4(%rbp),%edx
    3d1c:	89 d0                	mov    %edx,%eax
    3d1e:	c1 e0 02             	shl    $0x2,%eax
    3d21:	01 d0                	add    %edx,%eax
    3d23:	01 c0                	add    %eax,%eax
    3d25:	89 c1                	mov    %eax,%ecx
    3d27:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3d2b:	48 8d 50 01          	lea    0x1(%rax),%rdx
    3d2f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
    3d33:	0f b6 00             	movzbl (%rax),%eax
    3d36:	0f be c0             	movsbl %al,%eax
    3d39:	01 c8                	add    %ecx,%eax
    3d3b:	83 e8 30             	sub    $0x30,%eax
    3d3e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  while('0' <= *s && *s <= '9')
    3d41:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3d45:	0f b6 00             	movzbl (%rax),%eax
    3d48:	3c 2f                	cmp    $0x2f,%al
    3d4a:	7e 0b                	jle    3d57 <atoi+0x53>
    3d4c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3d50:	0f b6 00             	movzbl (%rax),%eax
    3d53:	3c 39                	cmp    $0x39,%al
    3d55:	7e c2                	jle    3d19 <atoi+0x15>
  return n;
    3d57:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
    3d5a:	c9                   	leaveq 
    3d5b:	c3                   	retq   

0000000000003d5c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3d5c:	55                   	push   %rbp
    3d5d:	48 89 e5             	mov    %rsp,%rbp
    3d60:	48 83 ec 28          	sub    $0x28,%rsp
    3d64:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    3d68:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    3d6c:	89 55 dc             	mov    %edx,-0x24(%rbp)
  char *dst, *src;
  
  dst = vdst;
    3d6f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    3d73:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  src = vsrc;
    3d77:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    3d7b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  while(n-- > 0)
    3d7f:	eb 1d                	jmp    3d9e <memmove+0x42>
    *dst++ = *src++;
    3d81:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
    3d85:	48 8d 42 01          	lea    0x1(%rdx),%rax
    3d89:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    3d8d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    3d91:	48 8d 48 01          	lea    0x1(%rax),%rcx
    3d95:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
    3d99:	0f b6 12             	movzbl (%rdx),%edx
    3d9c:	88 10                	mov    %dl,(%rax)
  while(n-- > 0)
    3d9e:	8b 45 dc             	mov    -0x24(%rbp),%eax
    3da1:	8d 50 ff             	lea    -0x1(%rax),%edx
    3da4:	89 55 dc             	mov    %edx,-0x24(%rbp)
    3da7:	85 c0                	test   %eax,%eax
    3da9:	7f d6                	jg     3d81 <memmove+0x25>
  return vdst;
    3dab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
    3daf:	c9                   	leaveq 
    3db0:	c3                   	retq   

0000000000003db1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3db1:	b8 01 00 00 00       	mov    $0x1,%eax
    3db6:	cd 40                	int    $0x40
    3db8:	c3                   	retq   

0000000000003db9 <exit>:
SYSCALL(exit)
    3db9:	b8 02 00 00 00       	mov    $0x2,%eax
    3dbe:	cd 40                	int    $0x40
    3dc0:	c3                   	retq   

0000000000003dc1 <wait>:
SYSCALL(wait)
    3dc1:	b8 03 00 00 00       	mov    $0x3,%eax
    3dc6:	cd 40                	int    $0x40
    3dc8:	c3                   	retq   

0000000000003dc9 <pipe>:
SYSCALL(pipe)
    3dc9:	b8 04 00 00 00       	mov    $0x4,%eax
    3dce:	cd 40                	int    $0x40
    3dd0:	c3                   	retq   

0000000000003dd1 <read>:
SYSCALL(read)
    3dd1:	b8 05 00 00 00       	mov    $0x5,%eax
    3dd6:	cd 40                	int    $0x40
    3dd8:	c3                   	retq   

0000000000003dd9 <write>:
SYSCALL(write)
    3dd9:	b8 10 00 00 00       	mov    $0x10,%eax
    3dde:	cd 40                	int    $0x40
    3de0:	c3                   	retq   

0000000000003de1 <close>:
SYSCALL(close)
    3de1:	b8 15 00 00 00       	mov    $0x15,%eax
    3de6:	cd 40                	int    $0x40
    3de8:	c3                   	retq   

0000000000003de9 <kill>:
SYSCALL(kill)
    3de9:	b8 06 00 00 00       	mov    $0x6,%eax
    3dee:	cd 40                	int    $0x40
    3df0:	c3                   	retq   

0000000000003df1 <exec>:
SYSCALL(exec)
    3df1:	b8 07 00 00 00       	mov    $0x7,%eax
    3df6:	cd 40                	int    $0x40
    3df8:	c3                   	retq   

0000000000003df9 <open>:
SYSCALL(open)
    3df9:	b8 0f 00 00 00       	mov    $0xf,%eax
    3dfe:	cd 40                	int    $0x40
    3e00:	c3                   	retq   

0000000000003e01 <mknod>:
SYSCALL(mknod)
    3e01:	b8 11 00 00 00       	mov    $0x11,%eax
    3e06:	cd 40                	int    $0x40
    3e08:	c3                   	retq   

0000000000003e09 <unlink>:
SYSCALL(unlink)
    3e09:	b8 12 00 00 00       	mov    $0x12,%eax
    3e0e:	cd 40                	int    $0x40
    3e10:	c3                   	retq   

0000000000003e11 <fstat>:
SYSCALL(fstat)
    3e11:	b8 08 00 00 00       	mov    $0x8,%eax
    3e16:	cd 40                	int    $0x40
    3e18:	c3                   	retq   

0000000000003e19 <link>:
SYSCALL(link)
    3e19:	b8 13 00 00 00       	mov    $0x13,%eax
    3e1e:	cd 40                	int    $0x40
    3e20:	c3                   	retq   

0000000000003e21 <mkdir>:
SYSCALL(mkdir)
    3e21:	b8 14 00 00 00       	mov    $0x14,%eax
    3e26:	cd 40                	int    $0x40
    3e28:	c3                   	retq   

0000000000003e29 <chdir>:
SYSCALL(chdir)
    3e29:	b8 09 00 00 00       	mov    $0x9,%eax
    3e2e:	cd 40                	int    $0x40
    3e30:	c3                   	retq   

0000000000003e31 <dup>:
SYSCALL(dup)
    3e31:	b8 0a 00 00 00       	mov    $0xa,%eax
    3e36:	cd 40                	int    $0x40
    3e38:	c3                   	retq   

0000000000003e39 <getpid>:
SYSCALL(getpid)
    3e39:	b8 0b 00 00 00       	mov    $0xb,%eax
    3e3e:	cd 40                	int    $0x40
    3e40:	c3                   	retq   

0000000000003e41 <sbrk>:
SYSCALL(sbrk)
    3e41:	b8 0c 00 00 00       	mov    $0xc,%eax
    3e46:	cd 40                	int    $0x40
    3e48:	c3                   	retq   

0000000000003e49 <sleep>:
SYSCALL(sleep)
    3e49:	b8 0d 00 00 00       	mov    $0xd,%eax
    3e4e:	cd 40                	int    $0x40
    3e50:	c3                   	retq   

0000000000003e51 <uptime>:
SYSCALL(uptime)
    3e51:	b8 0e 00 00 00       	mov    $0xe,%eax
    3e56:	cd 40                	int    $0x40
    3e58:	c3                   	retq   

0000000000003e59 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3e59:	55                   	push   %rbp
    3e5a:	48 89 e5             	mov    %rsp,%rbp
    3e5d:	48 83 ec 10          	sub    $0x10,%rsp
    3e61:	89 7d fc             	mov    %edi,-0x4(%rbp)
    3e64:	89 f0                	mov    %esi,%eax
    3e66:	88 45 f8             	mov    %al,-0x8(%rbp)
  write(fd, &c, 1);
    3e69:	48 8d 4d f8          	lea    -0x8(%rbp),%rcx
    3e6d:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3e70:	ba 01 00 00 00       	mov    $0x1,%edx
    3e75:	48 89 ce             	mov    %rcx,%rsi
    3e78:	89 c7                	mov    %eax,%edi
    3e7a:	e8 5a ff ff ff       	callq  3dd9 <write>
}
    3e7f:	90                   	nop
    3e80:	c9                   	leaveq 
    3e81:	c3                   	retq   

0000000000003e82 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3e82:	55                   	push   %rbp
    3e83:	48 89 e5             	mov    %rsp,%rbp
    3e86:	48 83 ec 30          	sub    $0x30,%rsp
    3e8a:	89 7d dc             	mov    %edi,-0x24(%rbp)
    3e8d:	89 75 d8             	mov    %esi,-0x28(%rbp)
    3e90:	89 55 d4             	mov    %edx,-0x2c(%rbp)
    3e93:	89 4d d0             	mov    %ecx,-0x30(%rbp)
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3e96:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  if(sgn && xx < 0){
    3e9d:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
    3ea1:	74 17                	je     3eba <printint+0x38>
    3ea3:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
    3ea7:	79 11                	jns    3eba <printint+0x38>
    neg = 1;
    3ea9:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    x = -xx;
    3eb0:	8b 45 d8             	mov    -0x28(%rbp),%eax
    3eb3:	f7 d8                	neg    %eax
    3eb5:	89 45 f4             	mov    %eax,-0xc(%rbp)
    3eb8:	eb 06                	jmp    3ec0 <printint+0x3e>
  } else {
    x = xx;
    3eba:	8b 45 d8             	mov    -0x28(%rbp),%eax
    3ebd:	89 45 f4             	mov    %eax,-0xc(%rbp)
  }

  i = 0;
    3ec0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  do{
    buf[i++] = digits[x % base];
    3ec7:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
    3eca:	8b 45 f4             	mov    -0xc(%rbp),%eax
    3ecd:	ba 00 00 00 00       	mov    $0x0,%edx
    3ed2:	f7 f1                	div    %ecx
    3ed4:	89 d1                	mov    %edx,%ecx
    3ed6:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3ed9:	8d 50 01             	lea    0x1(%rax),%edx
    3edc:	89 55 fc             	mov    %edx,-0x4(%rbp)
    3edf:	89 ca                	mov    %ecx,%edx
    3ee1:	0f b6 92 00 63 00 00 	movzbl 0x6300(%rdx),%edx
    3ee8:	48 98                	cltq   
    3eea:	88 54 05 e0          	mov    %dl,-0x20(%rbp,%rax,1)
  }while((x /= base) != 0);
    3eee:	8b 75 d4             	mov    -0x2c(%rbp),%esi
    3ef1:	8b 45 f4             	mov    -0xc(%rbp),%eax
    3ef4:	ba 00 00 00 00       	mov    $0x0,%edx
    3ef9:	f7 f6                	div    %esi
    3efb:	89 45 f4             	mov    %eax,-0xc(%rbp)
    3efe:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
    3f02:	75 c3                	jne    3ec7 <printint+0x45>
  if(neg)
    3f04:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
    3f08:	74 2b                	je     3f35 <printint+0xb3>
    buf[i++] = '-';
    3f0a:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3f0d:	8d 50 01             	lea    0x1(%rax),%edx
    3f10:	89 55 fc             	mov    %edx,-0x4(%rbp)
    3f13:	48 98                	cltq   
    3f15:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%rbp,%rax,1)

  while(--i >= 0)
    3f1a:	eb 19                	jmp    3f35 <printint+0xb3>
    putc(fd, buf[i]);
    3f1c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    3f1f:	48 98                	cltq   
    3f21:	0f b6 44 05 e0       	movzbl -0x20(%rbp,%rax,1),%eax
    3f26:	0f be d0             	movsbl %al,%edx
    3f29:	8b 45 dc             	mov    -0x24(%rbp),%eax
    3f2c:	89 d6                	mov    %edx,%esi
    3f2e:	89 c7                	mov    %eax,%edi
    3f30:	e8 24 ff ff ff       	callq  3e59 <putc>
  while(--i >= 0)
    3f35:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
    3f39:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
    3f3d:	79 dd                	jns    3f1c <printint+0x9a>
}
    3f3f:	90                   	nop
    3f40:	c9                   	leaveq 
    3f41:	c3                   	retq   

0000000000003f42 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    3f42:	55                   	push   %rbp
    3f43:	48 89 e5             	mov    %rsp,%rbp
    3f46:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
    3f4d:	89 bd 1c ff ff ff    	mov    %edi,-0xe4(%rbp)
    3f53:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
    3f5a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
    3f61:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
    3f68:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
    3f6f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
    3f76:	84 c0                	test   %al,%al
    3f78:	74 20                	je     3f9a <printf+0x58>
    3f7a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
    3f7e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
    3f82:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
    3f86:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
    3f8a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
    3f8e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
    3f92:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
    3f96:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  char *s;
  int c, i, state;
  va_start(ap, fmt);
    3f9a:	c7 85 20 ff ff ff 10 	movl   $0x10,-0xe0(%rbp)
    3fa1:	00 00 00 
    3fa4:	c7 85 24 ff ff ff 30 	movl   $0x30,-0xdc(%rbp)
    3fab:	00 00 00 
    3fae:	48 8d 45 10          	lea    0x10(%rbp),%rax
    3fb2:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
    3fb9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
    3fc0:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)

  state = 0;
    3fc7:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
    3fce:	00 00 00 
  for(i = 0; fmt[i]; i++){
    3fd1:	c7 85 44 ff ff ff 00 	movl   $0x0,-0xbc(%rbp)
    3fd8:	00 00 00 
    3fdb:	e9 a8 02 00 00       	jmpq   4288 <printf+0x346>
    c = fmt[i] & 0xff;
    3fe0:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
    3fe6:	48 63 d0             	movslq %eax,%rdx
    3fe9:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
    3ff0:	48 01 d0             	add    %rdx,%rax
    3ff3:	0f b6 00             	movzbl (%rax),%eax
    3ff6:	0f be c0             	movsbl %al,%eax
    3ff9:	25 ff 00 00 00       	and    $0xff,%eax
    3ffe:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%rbp)
    if(state == 0){
    4004:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%rbp)
    400b:	75 35                	jne    4042 <printf+0x100>
      if(c == '%'){
    400d:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
    4014:	75 0f                	jne    4025 <printf+0xe3>
        state = '%';
    4016:	c7 85 40 ff ff ff 25 	movl   $0x25,-0xc0(%rbp)
    401d:	00 00 00 
    4020:	e9 5c 02 00 00       	jmpq   4281 <printf+0x33f>
      } else {
        putc(fd, c);
    4025:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    402b:	0f be d0             	movsbl %al,%edx
    402e:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    4034:	89 d6                	mov    %edx,%esi
    4036:	89 c7                	mov    %eax,%edi
    4038:	e8 1c fe ff ff       	callq  3e59 <putc>
    403d:	e9 3f 02 00 00       	jmpq   4281 <printf+0x33f>
      }
    } else if(state == '%'){
    4042:	83 bd 40 ff ff ff 25 	cmpl   $0x25,-0xc0(%rbp)
    4049:	0f 85 32 02 00 00    	jne    4281 <printf+0x33f>
      if(c == 'd'){
    404f:	83 bd 3c ff ff ff 64 	cmpl   $0x64,-0xc4(%rbp)
    4056:	75 5e                	jne    40b6 <printf+0x174>
        printint(fd, va_arg(ap, int), 10, 1);
    4058:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    405e:	83 f8 2f             	cmp    $0x2f,%eax
    4061:	77 23                	ja     4086 <printf+0x144>
    4063:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    406a:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    4070:	89 d2                	mov    %edx,%edx
    4072:	48 01 d0             	add    %rdx,%rax
    4075:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    407b:	83 c2 08             	add    $0x8,%edx
    407e:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    4084:	eb 12                	jmp    4098 <printf+0x156>
    4086:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    408d:	48 8d 50 08          	lea    0x8(%rax),%rdx
    4091:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    4098:	8b 30                	mov    (%rax),%esi
    409a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    40a0:	b9 01 00 00 00       	mov    $0x1,%ecx
    40a5:	ba 0a 00 00 00       	mov    $0xa,%edx
    40aa:	89 c7                	mov    %eax,%edi
    40ac:	e8 d1 fd ff ff       	callq  3e82 <printint>
    40b1:	e9 c1 01 00 00       	jmpq   4277 <printf+0x335>
      } else if(c == 'x' || c == 'p'){
    40b6:	83 bd 3c ff ff ff 78 	cmpl   $0x78,-0xc4(%rbp)
    40bd:	74 09                	je     40c8 <printf+0x186>
    40bf:	83 bd 3c ff ff ff 70 	cmpl   $0x70,-0xc4(%rbp)
    40c6:	75 5e                	jne    4126 <printf+0x1e4>
        printint(fd, va_arg(ap, int), 16, 0);
    40c8:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    40ce:	83 f8 2f             	cmp    $0x2f,%eax
    40d1:	77 23                	ja     40f6 <printf+0x1b4>
    40d3:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    40da:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    40e0:	89 d2                	mov    %edx,%edx
    40e2:	48 01 d0             	add    %rdx,%rax
    40e5:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    40eb:	83 c2 08             	add    $0x8,%edx
    40ee:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    40f4:	eb 12                	jmp    4108 <printf+0x1c6>
    40f6:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    40fd:	48 8d 50 08          	lea    0x8(%rax),%rdx
    4101:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    4108:	8b 30                	mov    (%rax),%esi
    410a:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    4110:	b9 00 00 00 00       	mov    $0x0,%ecx
    4115:	ba 10 00 00 00       	mov    $0x10,%edx
    411a:	89 c7                	mov    %eax,%edi
    411c:	e8 61 fd ff ff       	callq  3e82 <printint>
    4121:	e9 51 01 00 00       	jmpq   4277 <printf+0x335>
      } else if(c == 's'){
    4126:	83 bd 3c ff ff ff 73 	cmpl   $0x73,-0xc4(%rbp)
    412d:	0f 85 98 00 00 00    	jne    41cb <printf+0x289>
        s = va_arg(ap, char*);
    4133:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    4139:	83 f8 2f             	cmp    $0x2f,%eax
    413c:	77 23                	ja     4161 <printf+0x21f>
    413e:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    4145:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    414b:	89 d2                	mov    %edx,%edx
    414d:	48 01 d0             	add    %rdx,%rax
    4150:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    4156:	83 c2 08             	add    $0x8,%edx
    4159:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    415f:	eb 12                	jmp    4173 <printf+0x231>
    4161:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    4168:	48 8d 50 08          	lea    0x8(%rax),%rdx
    416c:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    4173:	48 8b 00             	mov    (%rax),%rax
    4176:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
        if(s == 0)
    417d:	48 83 bd 48 ff ff ff 	cmpq   $0x0,-0xb8(%rbp)
    4184:	00 
    4185:	75 31                	jne    41b8 <printf+0x276>
          s = "(null)";
    4187:	48 c7 85 48 ff ff ff 	movq   $0x5c3a,-0xb8(%rbp)
    418e:	3a 5c 00 00 
        while(*s != 0){
    4192:	eb 24                	jmp    41b8 <printf+0x276>
          putc(fd, *s);
    4194:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
    419b:	0f b6 00             	movzbl (%rax),%eax
    419e:	0f be d0             	movsbl %al,%edx
    41a1:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    41a7:	89 d6                	mov    %edx,%esi
    41a9:	89 c7                	mov    %eax,%edi
    41ab:	e8 a9 fc ff ff       	callq  3e59 <putc>
          s++;
    41b0:	48 83 85 48 ff ff ff 	addq   $0x1,-0xb8(%rbp)
    41b7:	01 
        while(*s != 0){
    41b8:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
    41bf:	0f b6 00             	movzbl (%rax),%eax
    41c2:	84 c0                	test   %al,%al
    41c4:	75 ce                	jne    4194 <printf+0x252>
    41c6:	e9 ac 00 00 00       	jmpq   4277 <printf+0x335>
        }
      } else if(c == 'c'){
    41cb:	83 bd 3c ff ff ff 63 	cmpl   $0x63,-0xc4(%rbp)
    41d2:	75 56                	jne    422a <printf+0x2e8>
        putc(fd, va_arg(ap, uint));
    41d4:	8b 85 20 ff ff ff    	mov    -0xe0(%rbp),%eax
    41da:	83 f8 2f             	cmp    $0x2f,%eax
    41dd:	77 23                	ja     4202 <printf+0x2c0>
    41df:	48 8b 85 30 ff ff ff 	mov    -0xd0(%rbp),%rax
    41e6:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    41ec:	89 d2                	mov    %edx,%edx
    41ee:	48 01 d0             	add    %rdx,%rax
    41f1:	8b 95 20 ff ff ff    	mov    -0xe0(%rbp),%edx
    41f7:	83 c2 08             	add    $0x8,%edx
    41fa:	89 95 20 ff ff ff    	mov    %edx,-0xe0(%rbp)
    4200:	eb 12                	jmp    4214 <printf+0x2d2>
    4202:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
    4209:	48 8d 50 08          	lea    0x8(%rax),%rdx
    420d:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
    4214:	8b 00                	mov    (%rax),%eax
    4216:	0f be d0             	movsbl %al,%edx
    4219:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    421f:	89 d6                	mov    %edx,%esi
    4221:	89 c7                	mov    %eax,%edi
    4223:	e8 31 fc ff ff       	callq  3e59 <putc>
    4228:	eb 4d                	jmp    4277 <printf+0x335>
      } else if(c == '%'){
    422a:	83 bd 3c ff ff ff 25 	cmpl   $0x25,-0xc4(%rbp)
    4231:	75 1a                	jne    424d <printf+0x30b>
        putc(fd, c);
    4233:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    4239:	0f be d0             	movsbl %al,%edx
    423c:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    4242:	89 d6                	mov    %edx,%esi
    4244:	89 c7                	mov    %eax,%edi
    4246:	e8 0e fc ff ff       	callq  3e59 <putc>
    424b:	eb 2a                	jmp    4277 <printf+0x335>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    424d:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    4253:	be 25 00 00 00       	mov    $0x25,%esi
    4258:	89 c7                	mov    %eax,%edi
    425a:	e8 fa fb ff ff       	callq  3e59 <putc>
        putc(fd, c);
    425f:	8b 85 3c ff ff ff    	mov    -0xc4(%rbp),%eax
    4265:	0f be d0             	movsbl %al,%edx
    4268:	8b 85 1c ff ff ff    	mov    -0xe4(%rbp),%eax
    426e:	89 d6                	mov    %edx,%esi
    4270:	89 c7                	mov    %eax,%edi
    4272:	e8 e2 fb ff ff       	callq  3e59 <putc>
      }
      state = 0;
    4277:	c7 85 40 ff ff ff 00 	movl   $0x0,-0xc0(%rbp)
    427e:	00 00 00 
  for(i = 0; fmt[i]; i++){
    4281:	83 85 44 ff ff ff 01 	addl   $0x1,-0xbc(%rbp)
    4288:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
    428e:	48 63 d0             	movslq %eax,%rdx
    4291:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
    4298:	48 01 d0             	add    %rdx,%rax
    429b:	0f b6 00             	movzbl (%rax),%eax
    429e:	84 c0                	test   %al,%al
    42a0:	0f 85 3a fd ff ff    	jne    3fe0 <printf+0x9e>
    }
  }
}
    42a6:	90                   	nop
    42a7:	c9                   	leaveq 
    42a8:	c3                   	retq   

00000000000042a9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    42a9:	55                   	push   %rbp
    42aa:	48 89 e5             	mov    %rsp,%rbp
    42ad:	48 83 ec 18          	sub    $0x18,%rsp
    42b1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  Header *bp, *p;

  bp = (Header*)ap - 1;
    42b5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
    42b9:	48 83 e8 10          	sub    $0x10,%rax
    42bd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    42c1:	48 8b 05 a8 68 00 00 	mov    0x68a8(%rip),%rax        # ab70 <freep>
    42c8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    42cc:	eb 2f                	jmp    42fd <free+0x54>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    42ce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    42d2:	48 8b 00             	mov    (%rax),%rax
    42d5:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    42d9:	72 17                	jb     42f2 <free+0x49>
    42db:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    42df:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
    42e3:	77 2f                	ja     4314 <free+0x6b>
    42e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    42e9:	48 8b 00             	mov    (%rax),%rax
    42ec:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    42f0:	72 22                	jb     4314 <free+0x6b>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    42f2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    42f6:	48 8b 00             	mov    (%rax),%rax
    42f9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    42fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    4301:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
    4305:	76 c7                	jbe    42ce <free+0x25>
    4307:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    430b:	48 8b 00             	mov    (%rax),%rax
    430e:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    4312:	73 ba                	jae    42ce <free+0x25>
      break;
  if(bp + bp->s.size == p->s.ptr){
    4314:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    4318:	8b 40 08             	mov    0x8(%rax),%eax
    431b:	89 c0                	mov    %eax,%eax
    431d:	48 c1 e0 04          	shl    $0x4,%rax
    4321:	48 89 c2             	mov    %rax,%rdx
    4324:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    4328:	48 01 c2             	add    %rax,%rdx
    432b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    432f:	48 8b 00             	mov    (%rax),%rax
    4332:	48 39 c2             	cmp    %rax,%rdx
    4335:	75 2d                	jne    4364 <free+0xbb>
    bp->s.size += p->s.ptr->s.size;
    4337:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    433b:	8b 50 08             	mov    0x8(%rax),%edx
    433e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4342:	48 8b 00             	mov    (%rax),%rax
    4345:	8b 40 08             	mov    0x8(%rax),%eax
    4348:	01 c2                	add    %eax,%edx
    434a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    434e:	89 50 08             	mov    %edx,0x8(%rax)
    bp->s.ptr = p->s.ptr->s.ptr;
    4351:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4355:	48 8b 00             	mov    (%rax),%rax
    4358:	48 8b 10             	mov    (%rax),%rdx
    435b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    435f:	48 89 10             	mov    %rdx,(%rax)
    4362:	eb 0e                	jmp    4372 <free+0xc9>
  } else
    bp->s.ptr = p->s.ptr;
    4364:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4368:	48 8b 10             	mov    (%rax),%rdx
    436b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    436f:	48 89 10             	mov    %rdx,(%rax)
  if(p + p->s.size == bp){
    4372:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4376:	8b 40 08             	mov    0x8(%rax),%eax
    4379:	89 c0                	mov    %eax,%eax
    437b:	48 c1 e0 04          	shl    $0x4,%rax
    437f:	48 89 c2             	mov    %rax,%rdx
    4382:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4386:	48 01 d0             	add    %rdx,%rax
    4389:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
    438d:	75 27                	jne    43b6 <free+0x10d>
    p->s.size += bp->s.size;
    438f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4393:	8b 50 08             	mov    0x8(%rax),%edx
    4396:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    439a:	8b 40 08             	mov    0x8(%rax),%eax
    439d:	01 c2                	add    %eax,%edx
    439f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    43a3:	89 50 08             	mov    %edx,0x8(%rax)
    p->s.ptr = bp->s.ptr;
    43a6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    43aa:	48 8b 10             	mov    (%rax),%rdx
    43ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    43b1:	48 89 10             	mov    %rdx,(%rax)
    43b4:	eb 0b                	jmp    43c1 <free+0x118>
  } else
    p->s.ptr = bp;
    43b6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    43ba:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
    43be:	48 89 10             	mov    %rdx,(%rax)
  freep = p;
    43c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    43c5:	48 89 05 a4 67 00 00 	mov    %rax,0x67a4(%rip)        # ab70 <freep>
}
    43cc:	90                   	nop
    43cd:	c9                   	leaveq 
    43ce:	c3                   	retq   

00000000000043cf <morecore>:

static Header*
morecore(uint nu)
{
    43cf:	55                   	push   %rbp
    43d0:	48 89 e5             	mov    %rsp,%rbp
    43d3:	48 83 ec 20          	sub    $0x20,%rsp
    43d7:	89 7d ec             	mov    %edi,-0x14(%rbp)
  char *p;
  Header *hp;

  if(nu < 4096)
    43da:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%rbp)
    43e1:	77 07                	ja     43ea <morecore+0x1b>
    nu = 4096;
    43e3:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%rbp)
  p = sbrk(nu * sizeof(Header));
    43ea:	8b 45 ec             	mov    -0x14(%rbp),%eax
    43ed:	c1 e0 04             	shl    $0x4,%eax
    43f0:	89 c7                	mov    %eax,%edi
    43f2:	e8 4a fa ff ff       	callq  3e41 <sbrk>
    43f7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  if(p == (char*)-1)
    43fb:	48 83 7d f8 ff       	cmpq   $0xffffffffffffffff,-0x8(%rbp)
    4400:	75 07                	jne    4409 <morecore+0x3a>
    return 0;
    4402:	b8 00 00 00 00       	mov    $0x0,%eax
    4407:	eb 29                	jmp    4432 <morecore+0x63>
  hp = (Header*)p;
    4409:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    440d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  hp->s.size = nu;
    4411:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    4415:	8b 55 ec             	mov    -0x14(%rbp),%edx
    4418:	89 50 08             	mov    %edx,0x8(%rax)
  free((void*)(hp + 1));
    441b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    441f:	48 83 c0 10          	add    $0x10,%rax
    4423:	48 89 c7             	mov    %rax,%rdi
    4426:	e8 7e fe ff ff       	callq  42a9 <free>
  return freep;
    442b:	48 8b 05 3e 67 00 00 	mov    0x673e(%rip),%rax        # ab70 <freep>
}
    4432:	c9                   	leaveq 
    4433:	c3                   	retq   

0000000000004434 <malloc>:

void*
malloc(uint nbytes)
{
    4434:	55                   	push   %rbp
    4435:	48 89 e5             	mov    %rsp,%rbp
    4438:	48 83 ec 30          	sub    $0x30,%rsp
    443c:	89 7d dc             	mov    %edi,-0x24(%rbp)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    443f:	8b 45 dc             	mov    -0x24(%rbp),%eax
    4442:	48 83 c0 0f          	add    $0xf,%rax
    4446:	48 c1 e8 04          	shr    $0x4,%rax
    444a:	83 c0 01             	add    $0x1,%eax
    444d:	89 45 ec             	mov    %eax,-0x14(%rbp)
  if((prevp = freep) == 0){
    4450:	48 8b 05 19 67 00 00 	mov    0x6719(%rip),%rax        # ab70 <freep>
    4457:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    445b:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
    4460:	75 2b                	jne    448d <malloc+0x59>
    base.s.ptr = freep = prevp = &base;
    4462:	48 c7 45 f0 60 ab 00 	movq   $0xab60,-0x10(%rbp)
    4469:	00 
    446a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    446e:	48 89 05 fb 66 00 00 	mov    %rax,0x66fb(%rip)        # ab70 <freep>
    4475:	48 8b 05 f4 66 00 00 	mov    0x66f4(%rip),%rax        # ab70 <freep>
    447c:	48 89 05 dd 66 00 00 	mov    %rax,0x66dd(%rip)        # ab60 <base>
    base.s.size = 0;
    4483:	c7 05 db 66 00 00 00 	movl   $0x0,0x66db(%rip)        # ab68 <base+0x8>
    448a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    448d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    4491:	48 8b 00             	mov    (%rax),%rax
    4494:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
    4498:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    449c:	8b 40 08             	mov    0x8(%rax),%eax
    449f:	39 45 ec             	cmp    %eax,-0x14(%rbp)
    44a2:	77 5f                	ja     4503 <malloc+0xcf>
      if(p->s.size == nunits)
    44a4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44a8:	8b 40 08             	mov    0x8(%rax),%eax
    44ab:	39 45 ec             	cmp    %eax,-0x14(%rbp)
    44ae:	75 10                	jne    44c0 <malloc+0x8c>
        prevp->s.ptr = p->s.ptr;
    44b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44b4:	48 8b 10             	mov    (%rax),%rdx
    44b7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    44bb:	48 89 10             	mov    %rdx,(%rax)
    44be:	eb 2e                	jmp    44ee <malloc+0xba>
      else {
        p->s.size -= nunits;
    44c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44c4:	8b 40 08             	mov    0x8(%rax),%eax
    44c7:	2b 45 ec             	sub    -0x14(%rbp),%eax
    44ca:	89 c2                	mov    %eax,%edx
    44cc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44d0:	89 50 08             	mov    %edx,0x8(%rax)
        p += p->s.size;
    44d3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44d7:	8b 40 08             	mov    0x8(%rax),%eax
    44da:	89 c0                	mov    %eax,%eax
    44dc:	48 c1 e0 04          	shl    $0x4,%rax
    44e0:	48 01 45 f8          	add    %rax,-0x8(%rbp)
        p->s.size = nunits;
    44e4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44e8:	8b 55 ec             	mov    -0x14(%rbp),%edx
    44eb:	89 50 08             	mov    %edx,0x8(%rax)
      }
      freep = prevp;
    44ee:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
    44f2:	48 89 05 77 66 00 00 	mov    %rax,0x6677(%rip)        # ab70 <freep>
      return (void*)(p + 1);
    44f9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    44fd:	48 83 c0 10          	add    $0x10,%rax
    4501:	eb 41                	jmp    4544 <malloc+0x110>
    }
    if(p == freep)
    4503:	48 8b 05 66 66 00 00 	mov    0x6666(%rip),%rax        # ab70 <freep>
    450a:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
    450e:	75 1c                	jne    452c <malloc+0xf8>
      if((p = morecore(nunits)) == 0)
    4510:	8b 45 ec             	mov    -0x14(%rbp),%eax
    4513:	89 c7                	mov    %eax,%edi
    4515:	e8 b5 fe ff ff       	callq  43cf <morecore>
    451a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    451e:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
    4523:	75 07                	jne    452c <malloc+0xf8>
        return 0;
    4525:	b8 00 00 00 00       	mov    $0x0,%eax
    452a:	eb 18                	jmp    4544 <malloc+0x110>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    452c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4530:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    4534:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
    4538:	48 8b 00             	mov    (%rax),%rax
    453b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if(p->s.size >= nunits){
    453f:	e9 54 ff ff ff       	jmpq   4498 <malloc+0x64>
  }
}
    4544:	c9                   	leaveq 
    4545:	c3                   	retq   
