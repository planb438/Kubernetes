### apparmor

Before you begin
AppArmor is an optional kernel module and Kubernetes feature, so verify it is supported on your Nodes before proceeding:
1. AppArmor kernel module is enabled -- For the Linux kernel to enforce an AppArmor profile, the AppArmor kernel module must be installed and enabled. Several distributions enable the module by default, such as Ubuntu and SUSE, and many others provide optional support. To check whether the module is enabled, check the /sys/module/apparmor/parameters/enabled file:
cat /sys/module/apparmor/parameters/enabled



1. The kubelet verifies that AppArmor is enabled on the host before admitting a pod with AppArmor explicitly configured.

2. Container runtime supports AppArmor -- All common Kubernetes-supported container runtimes should support AppArmor, including containerd and CRI-O. Please refer to the corresponding runtime documentation and verify that the cluster fulfills the requirements to use AppArmor.

3. Profile is loaded -- AppArmor is applied to a Pod by specifying an AppArmor profile that each container should be run with. If any of the specified profiles are not loaded in the kernel, the kubelet will reject the Pod. You can view which profiles are loaded on a node by checking the /sys/kernel/security/apparmor/profiles file. For example:
sudo cat /sys/kernel/security/apparmor/profiles | sort


Usage: aa-status [OPTIONS]
Displays various information about the currently loaded AppArmor policy.
Default if no options given
  --show=all

aa-status

