# MDK Technical Deep-Dive

## 1. Runtime Identity Extraction
MDK no longer relies on compile-time ID macros. 
- **Mechanism:** QEMU passes `id=X` via the `-append` flag.
- **Parsing:** The kernel scans the Multiboot command line string at boot, extracts the value after `id=`, and sets the global node identity. This allows the same `kernel.bin` to behave differently based on its launch context.

## 2. P2P UDP Mesh Networking
Due to stability issues with multicast on certain host environments, MDK uses a **Point-to-Peer UDP** socket backend.
- **Topology:** Terminal 1 (Node 1) listens on port 4444 and sends to 4445. Terminal 2 (Node 2) listens on 4445 and sends to 4444.
- **Discovery:** Nodes broadcast "Hello" heartbeats to their peer port. When a node receives a valid MDK packet on its local port, it adds the sender to its internal routing table.

## 3. Aligned Virtio Management
To prevent hardware-induced reboots (Triple Faults), the Virtio-Net descriptors and rings are now **4KB page-aligned**.
- **Memory:** The `kmalloc` allocator was extended to support larger, aligned chunks specifically for the Virtio subsystem.
- **Stability:** Resetting the device and configuring queues in a specific order (ACK -> DRIVER -> SETUP -> DRIVER_OK) ensures compatibility with QEMU's PCI emulation.

## 4. RAMFS Lifecycle
The RAMFS is initialized during the kernel's secondary boot stage. 
- **Storage:** It uses a static pool of `mdk_file` descriptors.
- **Interaction:** Commands like `ls` and `cat` provide a Unix-like experience for inspecting cluster configurations and node logs directly from the interactive shell.
