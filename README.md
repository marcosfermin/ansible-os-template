# Ansible OS Template (Ubuntu / Debian / RHEL-like)

This repo is a clean starter **template** you can reuse for almost any Ansible operation,
with **multi-distro support** (Ubuntu, Debian, and RHEL-like). It includes a sane project
layout, CI linting, Molecule scaffolding, and examples (common baseline + optional web stack).

> Tested on Ubuntu 20.04/22.04/24.04, Debian 11/12, and RHEL-like (RHEL 8/9, Rocky, Alma, CentOS Stream).

## Quick start

```bash
# 1) Install Ansible on your control node
pipx install ansible || pip install ansible

# 2) Install collections (once)
ansible-galaxy install -r requirements.yml

# 3) Set your inventory (inventories/dev/hosts.ini) and ping
ansible -i inventories/dev/hosts.ini all -m ping

# 4) Run the baseline & (optionally) the web stack
ansible-playbook -i inventories/dev/hosts.ini playbooks/site.yml
```

## What’s inside

- `ansible.cfg` — sane defaults (YAML output, roles path, etc.).
- `inventories/{dev,staging,prod}/hosts.ini` — environment inventories.
- `group_vars/all.yml` — global vars (timezone, user, web stack toggle).
- `playbooks/site.yml` — main entry point; runs `common` on all hosts and,
  if enabled, a web stack (`nginx` or `apache`) + `php` + `mysql` on `[web]` or `[db]` groups.
- `roles/common` — cross-distro baseline: update cache, install base packages,
  optional firewall, deploy user + SSH settings, timezone.
- `roles/nginx`, `roles/apache`, `roles/php`, `roles/mysql` — minimal, cross‑distro-aware roles.
- `roles/skeleton` — empty role you can copy for new ops.
- `.github/workflows/lint.yml` — ansible-lint + dry-run.
- `molecule/` — scenario scaffold for local role testing (Docker).
- `aws_ec2.yml` — example dynamic inventory for AWS.

> Use this template as a **single repo** you can fork/clone for new projects.

## Variables you may want to tweak

Open `group_vars/all.yml`:

```yaml
deploy_user: deploy
deploy_user_ssh_pubkey: ""          # paste your public key here
system_timezone: Etc/UTC

enable_firewall: false              # set true to configure UFW/Firewalld
open_ports: [22, 80, 443]

web_stack_enabled: false            # true to enable web stack play
web_stack: nginx                    # or "apache"

php_version: ""                     # e.g., 8.2 on Ubuntu 22.04; empty tries defaults
php_fpm_service_override: ""        # set if your service name is versioned (e.g., php8.2-fpm)
```

### Notes on PHP-FPM service names
- **Ubuntu/Debian** commonly use `phpX.Y-fpm` (e.g., `php8.2-fpm`). If the generic `php-fpm` service
  is not present, set `php_version` (e.g. `8.2`) or override `php_fpm_service_override`.
- **RHEL-like** typically uses `php-fpm`.

## Example inventory

`inventories/dev/hosts.ini`:
```ini
[all:vars]
ansible_user=ubuntu

[web]
web1 ansible_host=10.0.0.11
web2 ansible_host=10.0.0.12

[db]
db1 ansible_host=10.0.0.21
```

## Make targets

```bash
make install-collections   # install Ansible collections
make lint                  # ansible-lint
make syntax                # playbook syntax check
make dry-run ENV=dev       # check mode on dev
make deploy  ENV=dev       # full run on dev
```

## AWS dynamic inventory (optional)

Fill credentials via env or config, then:
```bash
ansible-inventory -i aws_ec2.yml --graph
ansible -i aws_ec2.yml all -m ping
```
