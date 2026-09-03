.PHONY: fmt fmt-check init validate plan check security lint install-tools clean

TF = terraform

fmt:
	$(TF) fmt -recursive

fmt-check:
	$(TF) fmt -check -recursive -diff

init:
	$(TF) init -input=false

validate: fmt-check init
	$(TF) validate -no-color

plan: validate
	$(TF) plan -input=false -no-color

security:
	@command -v tfsec >/dev/null 2>&1 || (echo "tfsec not found. Install: curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash" && exit 1)
	tfsec --no-color -m HIGH .

lint:
	@command -v tflint >/dev/null 2>&1 || (echo "tflint not found. Install: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/scripts/install_linux.sh | bash" && exit 1)
	tflint --filter .

check: fmt-check init validate
	$(MAKE) security
	$(MAKE) lint

install-tools:
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/scripts/install_linux.sh | bash
	pip install checkov

clean:
	rm -rf .terraform .terraform.lock.hcl /tmp/tfplan
