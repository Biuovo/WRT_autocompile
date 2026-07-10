#!/bin/sh

BOARD="$(board_name 2>/dev/null)"

case "$BOARD" in
  jdcloud,re-cs-07)
    ;;
  *)
    exit 0
    ;;
esac

uci -q batch <<'UCI'
delete network.lan
delete network.wan
delete network.wan6
delete network.br_lan
set network.br_lan='device'
set network.br_lan.name='br-lan'
set network.br_lan.type='bridge'
add_list network.br_lan.ports='lan1'
add_list network.br_lan.ports='lan2'
add_list network.br_lan.ports='lan3'
set network.lan='interface'
set network.lan.device='br-lan'
set network.lan.proto='static'
set network.lan.ipaddr='192.168.100.1'
set network.lan.netmask='255.255.255.0'
set network.wan='interface'
set network.wan.device='wan'
set network.wan.proto='dhcp'
set network.wan6='interface'
set network.wan6.device='@wan'
set network.wan6.proto='dhcpv6'
commit network
delete dhcp.lan
set dhcp.lan='dhcp'
set dhcp.lan.interface='lan'
set dhcp.lan.start='100'
set dhcp.lan.limit='150'
set dhcp.lan.leasetime='12h'
set dhcp.lan.ignore='0'
commit dhcp
UCI

/etc/init.d/network reload >/dev/null 2>&1 || true
/etc/init.d/dnsmasq restart >/dev/null 2>&1 || true
exit 0
