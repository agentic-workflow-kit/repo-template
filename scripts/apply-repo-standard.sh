#!/usr/bin/env bash
#
# Apply the agentic-workflow-kit repository standard to a GitHub repo:
#   - merge settings: squash-only, auto-delete merged branches
#   - default workflow permissions: read-only
#   - a `main` branch ruleset: PR required, squash-only, conversation resolution,
#     required `check` status (strict), linear history, no force-push, no deletion
#
# Idempotent: updates the existing `main` ruleset if one exists, else creates it.
# Requires: gh (authenticated, with admin on the target repo).
#
# Usage: scripts/apply-repo-standard.sh <owner>/<repo>
#
set -euo pipefail

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "usage: $0 <owner>/<repo>" >&2
  exit 1
fi

echo "Applying the agentic-workflow-kit repo standard to ${REPO}"

echo "- merge settings: squash-only, auto-delete merged branches"
gh api -X PATCH "repos/${REPO}" \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true >/dev/null

echo "- default workflow permissions: read-only"
gh api -X PUT "repos/${REPO}/actions/permissions/workflow" \
  -F default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=false >/dev/null

ruleset_payload() {
  cat <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["squash"],
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "do_not_enforce_on_create": false,
        "required_status_checks": [{ "context": "check" }],
        "strict_required_status_checks_policy": true
      }
    }
  ]
}
JSON
}

existing_id="$(gh api "repos/${REPO}/rulesets" --jq '.[] | select(.name=="main") | .id' 2>/dev/null | head -1 || true)"
if [ -n "${existing_id}" ]; then
  echo "- main ruleset: updating existing (id ${existing_id})"
  ruleset_payload | gh api -X PUT "repos/${REPO}/rulesets/${existing_id}" --input - >/dev/null
else
  echo "- main ruleset: creating"
  ruleset_payload | gh api -X POST "repos/${REPO}/rulesets" --input - >/dev/null
fi

echo "Done. Verify with: gh api repos/${REPO}/rulesets"
