# Emergency Patch Exemption Process

## Purpose
Allow emergency security patches in kube-system namespace when immediate deployment is required and images cannot be signed immediately.

## Requirements
1. **Only for kube-system namespace**
2. **Must have annotation**: `emergency-patch: "true"`
3. **Must include reason**: `emergency-reason: "<description>"`
4. **Maximum lifetime**: 24 hours
5. **Audit trail required**: All emergency deployments logged

## Approval Process
1. Security team approval required
2. Ticket reference must be included
3. Patch must be signed within 24 hours
4. Regular image must replace emergency patch

## Monitoring
- All emergency deployments are logged
- Alerts sent to security team
- Automatic cleanup after 24 hours
- Regular audit of exemptions