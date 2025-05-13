### Kube-bench

---

kube-bench is a Go application that checks whether Kubernetes is deployed securely by running the checks documented in the CIS Kubernetes Benchmark. Tests are configured with YAML files, making this tool easy to update as test specifications evolve.

-

 kube-bench implements the CIS Kubernetes Benchmark as closely as possible.




wget https://github.com/aquasecurity/kube-bench/releases/download/v0.4.0/kube-bench_0.4.0_linux_amd64.tar.gz


tar -xf kube-bench_0.4.0_linux_amd64.tar.gz


./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml

