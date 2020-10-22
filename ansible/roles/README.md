```bash
# Create a new role
gen-molecule role-name
# Or without alias
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
