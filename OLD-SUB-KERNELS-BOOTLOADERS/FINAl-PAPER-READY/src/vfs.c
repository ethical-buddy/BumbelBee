#include <kern/vfs.h>

fsnode_t *fs_root = 0; // The root of the filesystem

uint32_t
read_fs(fsnode_t* node, uint32_t offset, uint32_t size, uint8_t* buffer)
{
  if (node->read != 0)
    return node->read(node, offset, size, buffer);
  else
    return 0;
  
}

uint32_t
write_fs(fsnode_t* node, uint32_t offset, uint32_t size, uint8_t* buffer)
{
  if(node->write != 0)
    return node->write(node, offset, size, buffer);
  else
    return 0;
}

void
open_fs(fsnode_t* node, uint32_t flags)
{
  if(node->open != 0)
    node->open(node);
    
}

void
close_fs(fsnode_t* node)
{
  if(node->close)
    node->close(node);
}

struct dirent*
readdir_fs(fsnode_t* node, uint32_t index)
{
  if((node->flags & 0x07) == FS_DIRECTORY && node->readdir != 0)
    node->readdir(node, index);
}

fsnode_t*
finddir_fs(fsnode_t* node, char* name)
{
    if((node->flags & 0x07) == FS_DIRECTORY && node->finddir != 0)
    node->finddir(node, name);
}
