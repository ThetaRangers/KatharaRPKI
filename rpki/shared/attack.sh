#!/bin/bash
ifconfig lo:1 2.255.0.2 netmask 255.255.255.255 up
vtysh -c "conf t" \
        -c "router bgp 201" \
        -c "network 2.255.0.2/32" \
        -c "exit" \
        -c "exit" \
        -c "clear ip bgp * out"
