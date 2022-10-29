# Ansible

Run the system-wide setup:
```bash
ansible-playbook -K full.yml -e "myhostname=bogen"
# you can alternatively use sudo instead of -K
```

Apply the config for the current user:
```bash
ansible-playbook user.yml -e "myfullname='John Doe'" -e "myemail='john@doe.com'"
```
