```bash
# Create a new role
molecule init role -d podman role-name
# Run role
molecule converge
# Login to the instance
molecule login
# Run tests
molecule test --destroy never
# Delete instance
molecule destroy
```
