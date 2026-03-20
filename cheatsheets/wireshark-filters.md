# Wireshark Filters Cheatsheet

## Display filters (analysis)

### By protocol
```
http
dns
ftp
smtp
tcp
udp
icmp
ssl or tls
```

### By IP
```
ip.addr == 192.168.1.1
ip.src == 10.0.0.1
ip.dst == 10.0.0.1
ip.addr == 192.168.1.0/24
```

### By port
```
tcp.port == 80
tcp.dstport == 443
udp.port == 53
```

### HTTP specific
```
http.request
http.response
http.request.method == "POST"
http.request.uri contains "admin"
http.response.code == 200
http.response.code >= 400
http.cookie contains "session"
http.authorization
```

### DNS
```
dns.flags.response == 0          # queries only
dns.flags.response == 1          # responses only
dns.qry.name contains "evil"
dns.resp.len > 200               # large TXT records (exfil?)
```

### TCP
```
tcp.flags.syn == 1 && tcp.flags.ack == 0   # SYN scan
tcp.flags.rst == 1                          # resets
tcp.stream eq 5                             # follow stream 5
```

### Credentials / suspicious
```
ftp.request.command == "USER" or ftp.request.command == "PASS"
http.authorization
smtp.auth
telnet
```

### File transfers
```
http.content_type contains "application"
ftp-data
smb
```

## tshark one-liners

```bash
# Extract all IPs
tshark -r file.pcap -T fields -e ip.src -e ip.dst | tr '\t' '\n' | sort -u

# HTTP URIs
tshark -r file.pcap -Y http.request -T fields -e http.request.full_uri

# DNS queries
tshark -r file.pcap -Y "dns.flags.response==0" -T fields -e dns.qry.name | sort -u

# Follow TCP stream N
tshark -r file.pcap -q -z follow,tcp,ascii,0

# Export HTTP objects
tshark -r file.pcap --export-objects http,./output/

# Extract credentials
tshark -r file.pcap -Y "http.authorization" -T fields -e ip.src -e http.authorization
```

## NetworkMiner tips
- Hosts tab → shows all hosts with OS fingerprint
- Files tab → reconstructed transferred files
- Credentials tab → captured creds automatically
- DNS tab → all DNS queries/responses
