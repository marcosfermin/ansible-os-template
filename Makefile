ENV ?= dev
INVENTORY = inventories/$(ENV)/hosts.ini

install-collections:
	ansible-galaxy install -r requirements.yml

lint:
	ansible-lint

syntax:
	ansible-playbook -i $(INVENTORY) playbooks/site.yml --syntax-check

dry-run:
	ansible-playbook -i $(INVENTORY) playbooks/site.yml --check --diff

deploy:
	ansible-playbook -i $(INVENTORY) playbooks/site.yml
