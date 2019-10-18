## tcpdump/networking #1: what does this snippet show?

This snippet shows a 3 way TCP handshake transaction to establish a connection between two IPv4 hosts. Let's use `hostA` to identify the host at `192.168.100.4` and `hostB` to identify the host at `192.168.100.10`. 

Diagrammatically:
```
hostA SYN --->
          <--- hostB SYN-ACK
hostA ACK --->
```

Lets take a closer look at each packet in this snippet:

#### Packet 1
```
    14:19:35.917759 
    IP 192.168.100.4.56281 > 192.168.100.10.80: 
        Flags [S],                         
        seq 1744248651,                    
        win 65535, 
        options [ mss 1413, nop, wscale 5, nop, nop, TS val 605356177 ecr 0, sackOK, eol ], 
        length 0
``` 

- The first line in the timestamp at which the packet is actually processed by the receiving system's clock
- The second line tells us that this is an IPv4 transaction and that `hostA` (at port `56281`) is sending this packet to `hostB` (at port `80`)
- The flag is set to `S` which denotes that the SYN bit has been set, telling `hostB` that this is an initial connection
- Sequence number:
    - `hostA` also generates and sends over a sequence number 
    - `hostB` uses this number to ensure that it receives all subsequent packets and in order
    - Note: This is one of the biggest advantages of using TCP
- win or window size:
    - specificies the maximum number of bytes that can be transmitted at this point in time
    - here, nothing needs to be processed on the hostB side and both sender and receiver buffers are empty
    - so upto the maximum number of bytes (2^16) can be sent
- length: specifies the length (bytes) of payload data. In this case, no data is sent so it is 0.

#### Packet 2
```
14:19:35.932161 
    IP 192.168.100.10.80 > 192.168.100.4.56281: 
        Flags [S.],                         
        seq 1282826745,                     
        ack 1744248652,                     
        win 42540, 
        options [ mss 1412, sackOK, TS val 422394176 ecr 605356177, nop, wscale 7 ], 
        length 0
```

- Again, the first line in the timestamp at which the packet is actually processed
- In this case, the second line tells us that now `hostB` is sending this packet to `hostA`
- The flag is set to `S.` which denotes that both the ACK and the SYN bits have been set
    - ACK: 
        - `hostB` is sending back an acknowledgement to the initial SYN request that `hostA` sent in the first packet
        - `hostB` also specifies the next sequence number that `hostA` should use when sending a subsequent data packet
        - if the next data packet from `hostA` has a different sequence number, theres a potential of:
            - packets are either arriving out of order
            - packet loss
            - crossing conversations between hosts at different posts
    - SYN:
        - since TCP is bidirectional, `hostB` must also repeat the SYN process with `hostA` in the opposite direction
        - so `hostB` also generates and sends over a sequence number in a similar manner as `hostA` did in the first packet
- win: once again, the window size specifies the number of bytes allowed to be in transit from hostA to hostB
    - in this case, a maximum of 42540 bytes can be sent over the connection, potentially since this is the maximum size of the hostA buffer
- length: specifies the length (bytes) of payload data. In this case, no data is sent so it is 0.

#### Packet 3
```
14:19:35.932249 
    IP 192.168.100.4.56281 > 192.168.100.10.80: 
        Flags [.], 
        ack 1, 
        win 4112, 
        options [ nop, nop, TS val 605356191 ecr 422394176], 
        length 0
```
- Again, the first line in the timestamp at which the packet is actually processed
- In this case, once again, `hostA` is now sending a response to `hostB`
- The flag is set to `.` which denotes that only the ACK bit has been set
    - ACK: 
        - `hostA` is now sending back an acknowledgement to the SYN request that `hostB` sent in the second packet
        - the ACK number of 1 is the expected sequence number
        - `hostB` will need to use this number as its sequence number for the subsequent packet it sends to `hostA` next
- length: specifies the length (bytes) of payload data. In this case, no data is sent so it is 0.

## tcpdump/networking #2: what does this snippet show?

```
14:21:27.709546 
    IP 192.168.100.4.56299 > 192.168.100.1.21: 
        Flags [S], 
        seq 2441442505, 
        win 65535, 
        options [ mss 1413, nop, wscale 5, nop, nop, TS val 605467583 ecr 0, sackOK, eol ], 
        length 0
        
14:21:27.711601 
    IP 192.168.100.1.21 > 192.168.100.4.56299: 
        Flags [R.], 
        seq 0, 
        ack 2441442506, 
        win 0, 
        length 0
```

Here the flag `R.` refers to a `RST-ACK` response. If hostB sends `RST-ACK` as a response to a `SYN`, this is generally a sign that hostA is trying to make a connection to a port on hostB that is inaccessible. This could be due to a port mapping issue or that the port itself might simply be closed.

## tcpdump/networking #3. sniff packets on only one specific connection.
`tcpdump -i any host 192.168.1.10 and port 4450 -A`

where:
    - `i any`: used to capture packets sent over any of the interfaces on the local machine
    - `host`: defines the remote host's ip address
    - `port`: defines the specific port on the remote host
    - `-A`: displays captured packets in ASCII
