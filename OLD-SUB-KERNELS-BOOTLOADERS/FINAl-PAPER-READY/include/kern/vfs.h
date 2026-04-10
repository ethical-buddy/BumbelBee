#ifndef VFS_H
#define VFS_H

#include <stdint.h>


/*
  VFS - abstraction layer the OS uses to perform FS ops.
  Basic node-graph implementation here, implementing the following functions
  1. Open
  2. Close
  3. Read.
  4. Write.
  5. Readdir
  6. Finddir
*/


#define FS_FILE        0x01
#define FS_DIRECTORY   0x02
#define FS_CHARDEVICE  0x03
#define FS_BLOCKDEVICE 0x04
#define FS_PIPE        0x05
#define FS_SYMLINK     0x06
#define FS_MOUNTPOINT  0x08

struct vfs_node;
struct dirent{
  char name[128];
  uint32_t ino;
};


typedef uint32_t (*read_t)(struct vfs_node*, uint32_t, uint32_t, uint8_t*);
typedef uint32_t (*write_t)(struct vfs_node*, uint32_t, uint32_t, uint8_t*);
typedef void (*open_t)(struct vfs_node*);
typedef void (*close_t)(struct vfs_node*);
typedef struct dirent* (*readdir_t)(struct vfs_node*, uint32_t);
typedef struct vfs_node* (*finddir_t)(struct vfs_node*, char *name);

typedef struct vfs_node {
  char name[96];
  uint32_t flags;
  uint32_t mask;
  uint32_t gid;
  uint32_t uid;
  uint32_t size;
  uint32_t inode;
  uint32_t length;
  uint32_t impl;

  /* Function pointers for basic operations */

  open_t open;
  close_t close;
  read_t read;
  write_t write;
  readdir_t readdir;
  finddir_t finddir;

  struct vfs_node *ptr;  
}fsnode_t;


extern fsnode_t* fs_root;

uint32_t
read_fs(fsnode_t* node, uint32_t offset, uint32_t size, uint8_t* buffer);

uint32_t
write_fs(fsnode_t* node, uint32_t offset, uint32_t size, uint8_t* buffer);

void
open_fs(fsnode_t* node, uint32_t flags);

void
close_fs(fsnode_t* node);

struct dirent*
readdir_fs(fsnode_t* node, uint32_t index);

fsnode_t*
finddir_fs(fsnode_t* node, char* name);


#endif // VFS_H
