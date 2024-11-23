
out/bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
    7c00:	fa                   	cli    
    7c01:	31 c0                	xor    %eax,%eax
    7c03:	8e d8                	mov    %eax,%ds
    7c05:	8e c0                	mov    %eax,%es
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:
    7c09:	e4 64                	in     $0x64,%al
    7c0b:	a8 02                	test   $0x2,%al
    7c0d:	75 fa                	jne    7c09 <seta20.1>
    7c0f:	b0 d1                	mov    $0xd1,%al
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:
    7c13:	e4 64                	in     $0x64,%al
    7c15:	a8 02                	test   $0x2,%al
    7c17:	75 fa                	jne    7c13 <seta20.2>
    7c19:	b0 df                	mov    $0xdf,%al
    7c1b:	e6 60                	out    %al,$0x60
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	78 7c                	js     7c9e <readsect+0x11>
    7c22:	0f 20 c0             	mov    %cr0,%eax
    7c25:	66 83 c8 01          	or     $0x1,%ax
    7c29:	0f 22 c0             	mov    %eax,%cr0
    7c2c:	ea                   	.byte 0xea
    7c2d:	31 7c 08 00          	xor    %edi,0x0(%eax,%ecx,1)

00007c31 <start32>:
    7c31:	66 b8 10 00          	mov    $0x10,%ax
    7c35:	8e d8                	mov    %eax,%ds
    7c37:	8e c0                	mov    %eax,%es
    7c39:	8e d0                	mov    %eax,%ss
    7c3b:	66 b8 00 00          	mov    $0x0,%ax
    7c3f:	8e e0                	mov    %eax,%fs
    7c41:	8e e8                	mov    %eax,%gs
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    7c48:	e8 e5 00 00 00       	call   7d32 <bootmain>
    7c4d:	66 b8 00 8a          	mov    $0x8a00,%ax
    7c51:	66 89 c2             	mov    %ax,%dx
    7c54:	66 ef                	out    %ax,(%dx)
    7c56:	66 b8 e0 8a          	mov    $0x8ae0,%ax
    7c5a:	66 ef                	out    %ax,(%dx)

00007c5c <spin>:
    7c5c:	eb fe                	jmp    7c5c <spin>
    7c5e:	66 90                	xchg   %ax,%ax

00007c60 <gdt>:
	...
    7c68:	ff                   	(bad)  
    7c69:	ff 00                	incl   (%eax)
    7c6b:	00 00                	add    %al,(%eax)
    7c6d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c74:	00                   	.byte 0x0
    7c75:	92                   	xchg   %eax,%edx
    7c76:	cf                   	iret   
	...

00007c78 <gdtdesc>:
    7c78:	17                   	pop    %ss
    7c79:	00 60 7c             	add    %ah,0x7c(%eax)
	...

00007c7e <waitdisk>:
    7c7e:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c83:	ec                   	in     (%dx),%al
    7c84:	83 e0 c0             	and    $0xffffffc0,%eax
    7c87:	3c 40                	cmp    $0x40,%al
    7c89:	75 f8                	jne    7c83 <waitdisk+0x5>
    7c8b:	f3 c3                	repz ret 

00007c8d <readsect>:
    7c8d:	57                   	push   %edi
    7c8e:	53                   	push   %ebx
    7c8f:	8b 5c 24 10          	mov    0x10(%esp),%ebx
    7c93:	e8 e6 ff ff ff       	call   7c7e <waitdisk>
    7c98:	b8 01 00 00 00       	mov    $0x1,%eax
    7c9d:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7ca2:	ee                   	out    %al,(%dx)
    7ca3:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7ca8:	89 d8                	mov    %ebx,%eax
    7caa:	ee                   	out    %al,(%dx)
    7cab:	89 d8                	mov    %ebx,%eax
    7cad:	c1 e8 08             	shr    $0x8,%eax
    7cb0:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cb5:	ee                   	out    %al,(%dx)
    7cb6:	89 d8                	mov    %ebx,%eax
    7cb8:	c1 e8 10             	shr    $0x10,%eax
    7cbb:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cc0:	ee                   	out    %al,(%dx)
    7cc1:	89 d8                	mov    %ebx,%eax
    7cc3:	c1 e8 18             	shr    $0x18,%eax
    7cc6:	83 c8 e0             	or     $0xffffffe0,%eax
    7cc9:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cce:	ee                   	out    %al,(%dx)
    7ccf:	b8 20 00 00 00       	mov    $0x20,%eax
    7cd4:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cd9:	ee                   	out    %al,(%dx)
    7cda:	e8 9f ff ff ff       	call   7c7e <waitdisk>
    7cdf:	8b 7c 24 0c          	mov    0xc(%esp),%edi
    7ce3:	b9 80 00 00 00       	mov    $0x80,%ecx
    7ce8:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7ced:	fc                   	cld    
    7cee:	f3 6d                	rep insl (%dx),%es:(%edi)
    7cf0:	5b                   	pop    %ebx
    7cf1:	5f                   	pop    %edi
    7cf2:	c3                   	ret    

00007cf3 <readseg>:
    7cf3:	57                   	push   %edi
    7cf4:	56                   	push   %esi
    7cf5:	53                   	push   %ebx
    7cf6:	8b 5c 24 10          	mov    0x10(%esp),%ebx
    7cfa:	8b 74 24 18          	mov    0x18(%esp),%esi
    7cfe:	89 df                	mov    %ebx,%edi
    7d00:	03 7c 24 14          	add    0x14(%esp),%edi
    7d04:	89 f0                	mov    %esi,%eax
    7d06:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d0b:	29 c3                	sub    %eax,%ebx
    7d0d:	c1 ee 09             	shr    $0x9,%esi
    7d10:	83 c6 01             	add    $0x1,%esi
    7d13:	39 df                	cmp    %ebx,%edi
    7d15:	76 17                	jbe    7d2e <readseg+0x3b>
    7d17:	56                   	push   %esi
    7d18:	53                   	push   %ebx
    7d19:	e8 6f ff ff ff       	call   7c8d <readsect>
    7d1e:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d24:	83 c6 01             	add    $0x1,%esi
    7d27:	83 c4 08             	add    $0x8,%esp
    7d2a:	39 df                	cmp    %ebx,%edi
    7d2c:	77 e9                	ja     7d17 <readseg+0x24>
    7d2e:	5b                   	pop    %ebx
    7d2f:	5e                   	pop    %esi
    7d30:	5f                   	pop    %edi
    7d31:	c3                   	ret    

00007d32 <bootmain>:
    7d32:	57                   	push   %edi
    7d33:	56                   	push   %esi
    7d34:	53                   	push   %ebx
    7d35:	6a 00                	push   $0x0
    7d37:	68 00 20 00 00       	push   $0x2000
    7d3c:	68 00 00 01 00       	push   $0x10000
    7d41:	e8 ad ff ff ff       	call   7cf3 <readseg>
    7d46:	83 c4 0c             	add    $0xc,%esp
    7d49:	b8 00 00 01 00       	mov    $0x10000,%eax
    7d4e:	eb 0a                	jmp    7d5a <bootmain+0x28>
    7d50:	83 c0 04             	add    $0x4,%eax
    7d53:	3d 00 20 01 00       	cmp    $0x12000,%eax
    7d58:	74 35                	je     7d8f <bootmain+0x5d>
    7d5a:	8d 88 00 00 ff ff    	lea    -0x10000(%eax),%ecx
    7d60:	89 c3                	mov    %eax,%ebx
    7d62:	81 38 02 b0 ad 1b    	cmpl   $0x1badb002,(%eax)
    7d68:	75 e6                	jne    7d50 <bootmain+0x1e>
    7d6a:	8b 50 08             	mov    0x8(%eax),%edx
    7d6d:	03 50 04             	add    0x4(%eax),%edx
    7d70:	81 fa fe 4f 52 e4    	cmp    $0xe4524ffe,%edx
    7d76:	75 d8                	jne    7d50 <bootmain+0x1e>
    7d78:	f6 40 06 01          	testb  $0x1,0x6(%eax)
    7d7c:	74 11                	je     7d8f <bootmain+0x5d>
    7d7e:	8b 40 10             	mov    0x10(%eax),%eax
    7d81:	8b 53 0c             	mov    0xc(%ebx),%edx
    7d84:	39 d0                	cmp    %edx,%eax
    7d86:	77 07                	ja     7d8f <bootmain+0x5d>
    7d88:	8b 73 14             	mov    0x14(%ebx),%esi
    7d8b:	39 f0                	cmp    %esi,%eax
    7d8d:	76 04                	jbe    7d93 <bootmain+0x61>
    7d8f:	5b                   	pop    %ebx
    7d90:	5e                   	pop    %esi
    7d91:	5f                   	pop    %edi
    7d92:	c3                   	ret    
    7d93:	01 c1                	add    %eax,%ecx
    7d95:	29 d1                	sub    %edx,%ecx
    7d97:	51                   	push   %ecx
    7d98:	29 c6                	sub    %eax,%esi
    7d9a:	56                   	push   %esi
    7d9b:	50                   	push   %eax
    7d9c:	e8 52 ff ff ff       	call   7cf3 <readseg>
    7da1:	8b 43 18             	mov    0x18(%ebx),%eax
    7da4:	8b 53 14             	mov    0x14(%ebx),%edx
    7da7:	83 c4 0c             	add    $0xc,%esp
    7daa:	39 d0                	cmp    %edx,%eax
    7dac:	76 0e                	jbe    7dbc <bootmain+0x8a>
    7dae:	29 d0                	sub    %edx,%eax
    7db0:	89 d7                	mov    %edx,%edi
    7db2:	89 c1                	mov    %eax,%ecx
    7db4:	b8 00 00 00 00       	mov    $0x0,%eax
    7db9:	fc                   	cld    
    7dba:	f3 aa                	rep stos %al,%es:(%edi)
    7dbc:	ff 53 1c             	call   *0x1c(%ebx)
    7dbf:	eb ce                	jmp    7d8f <bootmain+0x5d>
