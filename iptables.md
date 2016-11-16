
## allow only one IP ssh and disallow all other

vim `allow_ssh_from_one_ip.sh`  then run `nohup allow_ssh_from_one_ip.sh` If you don't run
it with nohup you will be kicked from ssh and basically screwed.

```
# flush
iptables -F INPUT

# allow only ssh & dns from one IP

iptables -A INPUT -p tcp -s 52.123.123.123 --dport 22 -j ACCEPT
iptables -A INPUT -p udp -s 52.123.123.123 --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -s 52.123.123.123 --dport 53 -j ACCEPT


# disallow ssh from anywhere else

iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 22 -j DROP
iptables -A INPUT -p udp -s 0.0.0.0/0 --dport 53 -j DROP
iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 53 -j DROP


# all out trafic

iptables -I OUTPUT -o eth0 -d 0.0.0.0/0 -j ACCEPT
iptables -I INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT



# Optional - allow port 80 to everywhere
# iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 80 -j ACCEPT
# iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 443 -j ACCEPT

## Resouces
#
http://serverfault.com/questions/429400/iptables-rule-to-allow-all-outbound-locally-originating-traffic
# https://www.youtube.com/watch?v=XKfhOQWrUVw
```
