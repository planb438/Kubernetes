## Check kube-apiserver pod status

Check kube-apiserver pod status
Since it’s a static pod, check its logs:
bash
CopyEdit


sudo crictl ps -a | grep kube-apiserver


Then check logs for the pod ID you see:



sudo crictl logs <CONTAINER_ID>


You’re likely to see a config parsing or key error.


