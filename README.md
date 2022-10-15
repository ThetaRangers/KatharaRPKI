# KatharaRPKI

This project is structured in two parts. In the first part, a BGP Hijacking attack is implemented. In the second part, it is shown how a Resource Public Key Infrastructure (RPKI) makes it possible to prevent this type of threat.

This lab is heavily inspired by the [mini-internet project](https://github.com/nsg-ethz/mini_internet_project/tree/rpki-dev).

## Prerequisites
- Docker
- Kathará
- OpenSSL

## Dockerfiles
This laboratory uses custom docker images that are present in the directory [dockerfiles](https://github.com/ThetaRangers/KatharaRPKI/tree/main/dockerfiles). The images are also available on DockerHub with the tags:
- ferrarally/frr
- ferrarally/routinator
- ferrarally/krill

## Starting Topology
The network is structured in the following way:
![](https://i.imgur.com/dDCUYvK.jpeg)

Run Kathará in the [starting_topology](https://github.com/ThetaRangers/KatharaRPKI/tree/main/starting_topology) folder.
```bash
cd starting_topology
kathara lstart
```

After some time the routing tables will reach a stable state. 
The command traceroute shows the path taken by packets in the network. In this example customer 1 is executing traceroute to reach the subnet of customer 3:
```
root@customer1r1:/# traceroute 150.0.0.4
traceroute to 150.0.0.4 (150.0.0.4), 30 hops max, 60 byte packets
 1  20.255.0.1 (20.255.0.1)  2.266 ms  2.124 ms  2.055 ms
 2  20.255.0.3 (20.255.0.3)  2.004 ms  1.932 ms  1.861 ms
 3  150.0.0.4 (150.0.0.4)  1.785 ms  1.560 ms  1.338 ms
```
Packets pass through router 1 and 2 of ISP1, then they reach customer3 through the IXP.

### Attack
Run the script [attack.sh](https://github.com/ThetaRangers/KatharaRPKI/blob/main/rpki/shared/attack.sh)

```
root@customer2r1:/# ./shared/attack.sh
```
This script will execute the attack advertising a more specific prefix of AS150 from customer 2. The execution of traceroute on customer 1 will show this output:

```
root@customer1r1:/# traceroute 150.0.0.4
traceroute to 150.0.0.4 (150.0.0.4), 30 hops max, 60 byte packets
 1  20.255.0.1 (20.255.0.1)  0.084 ms  0.037 ms  0.039 ms
 2  150.0.0.4 (150.0.0.4)  0.059 ms  0.045 ms  0.042 ms
```
It is possible to see that customer 1 is relying on ISP1, but ISP1 is fooled into routing packets to customer 2.


## RPKI topology
![](https://i.imgur.com/5XpWDz5.jpg)
Routers marked in red are executing [Routinator](https://www.nlnetlabs.nl/projects/rpki/routinator/). The router of AS42 is also running [Krill](https://www.nlnetlabs.nl/projects/rpki/krill/). Every router will contact the validation server of his own AS to check if an update matches a ROA. Then it will apply a route-map present in the configuration of the router. If the update matches a ROA it will be accepted with maximum priority, if the ROA is not found the update will be accepted with lower priority and if it is invalid it will be denied.

```
!
! RPKI
!
rpki
rpki polling_period 60
rpki cache 10.0.0.1 3323 pref 1
!
route-map rpki permit 4
match rpki valid
set local-preference 150
!
route-map rpki permit 6
match rpki notfound
set local-preference 10
!
route-map rpki deny 8
match rpki invalid
!
route-map rpki permit 40
!
```

### Certificates Generation
Before starting the laboratory it is required to execute the script [gen_certs.sh](https://github.com/ThetaRangers/KatharaRPKI/blob/main/rpki/certificates/gen_certs.sh).

```bash
cd rpki/certificates
./gen_certs.sh
```

### Configuration Setup
To move the configuration files in the correct locations, the script [move_confs.sh](https://github.com/ThetaRangers/KatharaRPKI/blob/main/rpki/configurations/move_confs.sh) can be used.

### ROAs
ROAs are generated using the script [add_roas.sh](https://github.com/ThetaRangers/KatharaRPKI/blob/main/rpki/krill/add_roas.sh) invoked by [krill.startup](https://github.com/ThetaRangers/KatharaRPKI/blob/main/rpki/krill.startup).

### RPKI prevention
Running traceroute on customer 1 gives the same output as before:
```
root@customer1r1:/# traceroute 150.0.0.4
traceroute to 150.0.0.4 (150.0.0.4), 30 hops max, 60 byte packets
 1  20.255.0.1 (20.255.0.1)  6.084 ms  5.764 ms  5.556 ms
 2  20.255.0.3 (20.255.0.3)  5.367 ms  5.126 ms  4.843 ms
 3  150.0.0.4 (150.0.0.4)  4.602 ms  3.925 ms  3.408 ms
```

Running the attack:
```
root@customer2r1:/# ./shared/attack.sh
```

Running traceroute again:
```
root@customer1r1:/# traceroute 150.0.0.4
traceroute to 150.0.0.4 (150.0.0.4), 30 hops max, 60 byte packets
 1  20.255.0.1 (20.255.0.1)  3.325 ms  3.129 ms  3.023 ms
 2  20.255.0.3 (20.255.0.3)  2.899 ms  2.745 ms  2.644 ms
 3  150.0.0.4 (150.0.0.4)  2.515 ms  2.237 ms  1.995 ms
```
The path taken by packets is unchanged because the malicious update of customer 2 is rejected by ISP1.

Checking the log of router 1 of ISP1 we can see that the update is rejected:
```
2022/10/15 13:54:54 BGP: 10.20.201.2 rcvd UPDATE about 150.0.0.0/28 IPv4 unicast -- DENIED due to: route-map;
```