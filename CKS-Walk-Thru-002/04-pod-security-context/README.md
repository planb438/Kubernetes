🔐 Scenario 4: Pod Security Context Hardening

---

This is heavily tested on the CKS and applies real-world enforcement of Linux security controls at the container and pod level.

🧱 Scenario Overview

-

You will create and test:

-

Pod that runs as non-root

-

Pod with read-only root filesystem

-

Pod with Seccomp profile applied

-

Pod with Linux capabilities dropped

-

Pod with a runAsGroup / runAsUser context

----

📁 File Layout
-
cks-labs/
└── 04-pod-security-context/
    ├── 01-run-as-non-root.yaml
    ├── 02-readonly-rootfs.yaml
    ├── 03-seccomp-profile.yaml
    ├── 04-drop-capabilities.yaml
    ├── 05-user-group.yaml
    ├── README.md


---

# 🔐 Scenario 4: Pod SecurityContext Hardening

## 🎯 Goal
Apply pod-level and container-level hardening using SecurityContext fields.

## ✅ Test Cases
- ✅ Run as non-root user
- ✅ Use read-only root filesystem
- ✅ Apply `runtime/default` Seccomp profile
- ✅ Drop all Linux capabilities
- ✅ Set specific UID/GID

## 🔍 To Test
```bash
kubectl logs non-root-pod -n security-context
kubectl logs non-root-pod -n security-context

kubectl apply -f 02-readonly-rootfs.yaml
kubectl describe pod readonly-fs-pod -n security-context

kubectl apply -f 03-seccomp-profile.yaml
kubectl get pod seccomp-restricted-pod -n security-context -o json | jq '.metadata.annotations'

kubectl apply -f 04-drop-capabilities.yaml
kubectl -n security-context exec -it drop-cap-pod -- sh

kubectl apply -f 05-user-group.yaml
kubectl logs uid-gid-pod -n security-context
