dev:
	@rm -rf .terrafrom
	@git pull
	@terraform init -backend-config=env-dev/state.tfvars
	@terraform apply -auto-approve -var-file=env-dev/main.tfvars

dev-destroy:
	@rm -rf .terrafrom
	@git pull
	@terraform init -backend-config=env-dev/state.tfvars
	@terraform apply -auto-approve -var-file=env-dev/main.tfvars