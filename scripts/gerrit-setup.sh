#!/usr/bin/env bash
# This script setups some Gerrit hooks.
# Must be called from the root of the repository.

set -e

# Install post-commit hook for "Change-Id: ",
# that is needed by Gerrit to track different patchsets for the same review
scp -pqO "scp://$(git remote get-url origin | sed 's#^\(ssh\|git\|https?\)://##' | sed 's#/.*##')"/hooks/commit-msg .git/hooks/commit-msg
echo 'Created .git/hooks/commit-msg to generate "Change-Id:" headers'

# Prevent accidental direct pushes to master
cat > .git/hooks/pre-push <<'EOF'
#!/usr/bin/env bash
# Abort if the user is not pushing to a Gerrit review ref
die () {
	echo >&2 "$*"
	exit 1
}
if [ -n "$NO_GERRIT" ]; then
	exit 0
fi
# Pushed refs must contain a "refs/for/" ref, otherwise we are not pushing for review
grep -q "refs/for/" || die "Error: You are pushing to git directly, which would skip the Gerrit review process entirely. Set the NO_GERRIT=1 environment variable, if this is intended. Please push to the HEAD:refs/for/master ref instead, if you want to push for Gerrit review."
EOF
chmod +x .git/hooks/pre-push
echo 'Created .git/hooks/pre-push to prevent direct pushes skipping Gerrit review.'
