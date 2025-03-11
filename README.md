# oc-k8s-netperf-image

Image built from [cloud-bulldozer/k8s-netperf](https://github.com/cloud-bulldozer/k8s-netperf)
- Added `kubectl`, `oc`, and `k8s-netperf` binaries. 

Pull image from `quay.io/rjhowe/oc-k8s-netperf:latest`


# OpenShift 4 Network Performance Throughput Testing

## Issue
- How do I do performance testing to test the network bewteen nodes and pods? 
- What tool does RedHat use to test network performance? 

## Environment
- OpenShift 4

## Resolution
[k8s-netperf](https://github.com/cloud-bulldozer/k8s-netperf) is a tool used by RedHat

Download:  [k8s-netperf_Linux_v0.1.27_x86_64.tar.gz](https://github.com/cloud-bulldozer/k8s-netperf/releases/download/v0.1.27/k8s-netperf_Linux_v0.1.27_x86_64.tar.gz)

Image: [quay.io/rjhowe/oc-k8s-netperf:latest](quay.io/rjhowe/oc-k8s-netperf:latest)

### Label nodes

Apply a label to the nodes you want the client and server running

```
$ oc label nodes node-name netperf=client
$ oc label nodes node-name netperf=server
```

Run k8s-netperf with must-gather: 
```
# oc adm must-gather --image quay.io/rjhowe/oc-k8s-netperf:latest -- k8s-netperf --all  --iperf --netperf
```


### Sample test configuration 
```
$ cat ./test.yml

tests :
  - TCPStream1:       
    parallelism: 1     
    profile: "TCP_STREAM" 
    duration: 30          
    samples: 3          
    messagesize: 1024     
    burst: 1               
    service: false   
  - TCPStream2:           
    parallelism: 1     
    profile: "TCP_STREAM" 
    duration: 30           
    samples: 3            
    messagesize: 4096   
    burst: 3                                                                                                                      service: false
```


Run k8s-netperf from an image mounting your own config. 
```
$ podman run -it --rm --entrypoint /bin/k8s-netperf -v ./test:/test.yml:z -v ~/.kube/config:/config:z -e KUBECONFIG=/config quay.io/rjhowe/oc-k8s-netperf:latest --config /test.yml --all  --netperf
```


Run test locally if binary is installed
``` 
$ k8s-netperf --config ./test.yml  --all --netperf 
```

* `k8s-netperf` will clean up all objects it creatd after done running


### Output

```shell 
+-------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-------------------+------------------------------+
|    RESULT TYPE    | DRIVER  |  SCENARIO  | PARALLELISM | HOST NETWORK | SERVICE | MESSAGE SIZE | BURST | SAME NODE | DURATION | SAMPLES |     AVG VALUE     |   95% CONFIDENCE INTERVAL    |
+-------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-------------------+------------------------------+
| 📊 Stream Results | netperf | TCP_STREAM | 1           | true         | false   | 1024         | 1     | false     | 10       | 1       | 930.410000 (Mb/s) | 0.000000-0.000000 (Mb/s)     |
| 📊 Stream Results | netperf | TCP_STREAM | 1           | false        | false   | 1024         | 1     | false     | 10       | 1       | 889.120000 (Mb/s) | 0.000000-0.000000 (Mb/s)     |
| 📊 Stream Results | iperf3  | TCP_STREAM | 1           | true         | false   | 1024         | 1     | false     | 10       | 1       | 928.957888 (Mb/s) | 0.000000-0.000000 (Mb/s)     |
| 📊 Stream Results | iperf3  | TCP_STREAM | 1           | false        | false   | 1024         | 1     | false     | 10       | 1       | 885.254144 (Mb/s) | 0.000000-0.000000 (Mb/s)     |
| 📊 Stream Results | netperf | TCP_STREAM | 1           | true         | false   | 4096         | 3     | false     | 10       | 3       | 927.996667 (Mb/s) | 918.250728-937.742605 (Mb/s) |
| 📊 Stream Results | netperf | TCP_STREAM | 1           | false        | false   | 4096         | 3     | false     | 10       | 3       | 892.200000 (Mb/s) | 886.264626-898.135374 (Mb/s) |
| 📊 Stream Results | iperf3  | TCP_STREAM | 1           | true         | false   | 4096         | 3     | false     | 10       | 3       | 932.046400 (Mb/s) | 929.476927-934.615873 (Mb/s) |
| 📊 Stream Results | iperf3  | TCP_STREAM | 1           | false        | false   | 4096         | 3     | false     | 10       | 3       | 891.465728 (Mb/s) | 886.350566-896.580890 (Mb/s) |
+-------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-------------------+------------------------------+
+---------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-----------+
|        TYPE         | DRIVER  |  SCENARIO  | PARALLELISM | HOST NETWORK | SERVICE | MESSAGE SIZE | BURST | SAME NODE | DURATION | SAMPLES | AVG VALUE |
+---------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-----------+
| TCP Retransmissions | netperf | TCP_STREAM | 1           | true         | false   | 1024         | 1     | false     | 10       | 1       | 44.000000 |
| TCP Retransmissions | netperf | TCP_STREAM | 1           | false        | false   | 1024         | 1     | false     | 10       | 1       | 0.000000  |
| TCP Retransmissions | iperf3  | TCP_STREAM | 1           | true         | false   | 1024         | 1     | false     | 10       | 1       | 34.000000 |
| TCP Retransmissions | iperf3  | TCP_STREAM | 1           | false        | false   | 1024         | 1     | false     | 10       | 1       | 5.000000  |
| TCP Retransmissions | netperf | TCP_STREAM | 1           | true         | false   | 4096         | 3     | false     | 10       | 3       | 99.000000 |
| TCP Retransmissions | netperf | TCP_STREAM | 1           | false        | false   | 4096         | 3     | false     | 10       | 3       | 54.000000 |
| TCP Retransmissions | iperf3  | TCP_STREAM | 1           | true         | false   | 4096         | 3     | false     | 10       | 3       | 30.666667 |
| TCP Retransmissions | iperf3  | TCP_STREAM | 1           | false        | false   | 4096         | 3     | false     | 10       | 3       | 56.000000 |
+---------------------+---------+------------+-------------+--------------+---------+--------------+-------+-----------+----------+---------+-----------+
```
