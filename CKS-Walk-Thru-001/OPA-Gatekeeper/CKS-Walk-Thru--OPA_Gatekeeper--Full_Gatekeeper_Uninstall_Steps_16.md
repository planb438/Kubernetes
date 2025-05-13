### Full Gatekeeper Uninstall Steps
---

Perfect — here’s how to fully uninstall OPA Gatekeeper from your cluster.

--
🔥 Full Gatekeeper Uninstall Steps
Run the following in order:

1. 🗑️ Uninstall Gatekeeper Core Components
-


kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.15/deploy/gatekeeper.yaml

--

This removes all Gatekeeper controllers, webhooks, and CRDs.

2. 🧹 Clean Up Constraints & Templates (If Any Left)
Check and delete any leftovers:
--


kubectl get constraints.constraints.gatekeeper.sh
kubectl get constrainttemplates.templates.gatekeeper.sh

--

If anything still exists:

-


kubectl delete constrainttemplates --all
kubectl delete constraints --all

-


3. 🚮 Delete the Namespace (Optional but Clean)
--


kubectl delete ns gatekeeper-system --ignore-not-found

--


4. ✅ Confirm Cleanup
Make sure no Gatekeeper-related webhook configs remain:
--


kubectl get validatingwebhookconfigurations | grep gatekeeper
kubectl get mutatingwebhookconfigurations | grep gatekeeper

--

If any still exist (rare), delete manually:

--


kubectl delete validatingwebhookconfiguration <name>
kubectl delete mutatingwebhookconfiguration <name>

--




