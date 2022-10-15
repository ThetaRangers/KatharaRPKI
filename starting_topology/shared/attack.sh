#!/bin/bash
ifconfig lo:1 150.0.0.0 netmask 255.255.255.240 up
vtysh -c "conf t" \
        -c "router bgp 201" \
        -c "network 150.0.0.0/28" \
        -c "ip prefix-list export permit 150.0.0.0/28" \
        -c "exit" \
        -c "exit" \
        -c "clear ip bgp * out"
