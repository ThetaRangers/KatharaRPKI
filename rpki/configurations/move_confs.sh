#!/bin/bash

for folder in $(find ../ -type d -name '*r1')
do
            mkdir -p "${folder}/root"
            cp rpki_exceptions.json "${folder}/root/rpki_exceptions.json"
            cp routinator.conf "${folder}/root/.routinator.conf"
done

mkdir -p "../krill/root"
mkdir -p "../krill/var/krill"
mkdir -p "../krill/etc/haproxy/"
cp rpki_exceptions.json "../krill/root/rpki_exceptions.json"
cp routinator.conf "../krill/root/.routinator.conf"
cp krill.conf "../krill/var/krill/krill.conf"
cp haproxy.cfg "../krill/etc/haproxy/haproxy.cfg"
