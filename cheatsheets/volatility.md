# Volatility3 Cheatsheet

## Basic syntax
```
vol -f <dump> <plugin> [options]
```

## Essential plugins

### Process analysis
```bash
vol -f dump.mem windows.pstree          # process tree
vol -f dump.mem windows.pslist          # flat process list
vol -f dump.mem windows.cmdline         # command line args per process
vol -f dump.mem windows.dlllist         # DLLs per process
vol -f dump.mem windows.handles         # open handles
vol -f dump.mem windows.malfind         # injected code / suspicious memory
```

### Network
```bash
vol -f dump.mem windows.netscan         # active + closed connections
vol -f dump.mem windows.netstat         # active connections only
```

### Filesystem
```bash
vol -f dump.mem windows.filescan        # all file objects in memory
vol -f dump.mem windows.dumpfiles --virtaddr <addr>   # extract file
```

### Registry
```bash
vol -f dump.mem windows.registry.hivelist
vol -f dump.mem windows.registry.printkey --key "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

### Credentials
```bash
vol -f dump.mem windows.hashdump        # SAM hashes
vol -f dump.mem windows.lsadump         # LSA secrets
```

### Misc
```bash
vol -f dump.mem windows.info            # OS version, arch
vol -f dump.mem windows.envars          # environment variables per process
vol -f dump.mem windows.privs           # process privileges
```

## Filtering output
```bash
vol -f dump.mem windows.pstree | grep -i "powershell\|cmd\|wscript\|mshta"
vol -f dump.mem windows.netscan | grep ESTABLISHED
vol -f dump.mem windows.cmdline | grep -v "^$\|PID"
```

## Symbols
- Windows symbols auto-downloaded from Microsoft
- Linux: need to build ISF file from kernel
- Store in: `seckit/tools/windows/VolatilityWorkbench/symbols/`

## Common malware indicators
- `malfind` hits with MZ header → injected PE
- Process with no parent or wrong parent (e.g. cmd.exe spawned by explorer)
- `cmdline` with base64 encoded strings
- Network connections from non-network processes (e.g. notepad.exe)
- DLLs loaded from temp/appdata paths
