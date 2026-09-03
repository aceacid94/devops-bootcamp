#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
TOTAL=0

step() {
  echo -e "\n${YELLOW}==> $1${NC}"
}

success() {
  echo -e "${GREEN}[PASS] $1${NC}"
  ((PASS++)) || true
  ((TOTAL++)) || true
}

fail() {
  echo -e "${RED}[FAIL] $1${NC}"
  ((FAIL++)) || true
  ((TOTAL++)) || true
}

info() {
  echo -e "${YELLOW}[INFO] $1${NC}"
}

step "1. Terraform Format Check"
if terraform fmt -check -recursive -diff 2>&1; then
  success "All .tf files are properly formatted"
else
  fail "Format issues found. Run 'terraform fmt -recursive' to fix"
fi

step "2. Terraform Init"
info "Initializing Terraform..."
if terraform init -input=false -backend=false 2>&1; then
  success "Terraform init succeeded"
else
  fail "Terraform init failed"
  exit 1
fi

step "3. Terraform Validate"
info "Validating configuration syntax..."
if terraform validate -no-color 2>&1; then
  success "Configuration is valid"
else
  fail "Configuration validation failed"
fi

step "4. Terraform Plan"
info "Generating execution plan..."
if terraform plan -input=false -no-color -out=/tmp/tfplan 2>&1; then
  success "Plan generated successfully"
  rm -f /tmp/tfplan
else
  fail "Plan generation failed"
fi

step "5. Security Scan (tfsec)"
if command -v tfsec &>/dev/null; then
  if tfsec --no-color -m HIGH . 2>&1; then
    success "tfsec: No HIGH/CRITICAL issues found"
  else
    fail "tfsec: Issues detected"
  fi
else
  info "tfsec not installed, skipping security scan"
  info "Install with: curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash"
fi

step "6. Lint (tflint)"
if command -v tflint &>/dev/null; then
  if tflint --filter . 2>&1; then
    success "tflint: No issues found"
  else
    fail "tflint: Issues detected"
  fi
else
  info "tflint not installed, skipping lint"
  info "Install with: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/scripts/install_linux.sh | bash"
fi

step "7. Checkov Scan"
if command -v checkov &>/dev/null; then
  if checkov -d . --framework terraform --soft-fail-on LOW --no-color 2>&1; then
    success "Checkov: No critical issues found"
  else
    fail "Checkov: Issues detected"
  fi
else
  info "checkov not installed, skipping compliance scan"
  info "Install with: pip install checkov"
fi

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Results: ${PASS} passed, ${FAIL} failed, ${TOTAL} total${NC}"
echo -e "${YELLOW}========================================${NC}"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
