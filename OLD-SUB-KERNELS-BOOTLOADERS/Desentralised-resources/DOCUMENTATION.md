# MDK Cluster Demo Instructions

## 1. Prerequisites
- **QEMU** must be installed.
- Two or more terminal windows.

## 2. Launching the Cluster
Open two separate terminals in the project root.

**Terminal 1 (Node 1):**
```bash
make node1
```

**Terminal 2 (Node 2):**
```bash
make node2
```

## 3. Verifying Connectivity
Once both nodes are running:
1. In either terminal, type `nodes`. 
2. You should see both `Node 1` and `Node 2` listed in the active mesh.
3. Use `whoami` to verify the local node's identity.

## 4. Cluster Commands
- `nodes`: List discovered peers.
- `runjob`: Perform a distributed computation across the mesh.
- `top`: Real-time network and uptime stats.
- `ls` / `cat <file>`: Interact with the RAM filesystem.
