# Bundle inventory (CHARTE §3) — wild bundles, sandboxes, byte-exact markers.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)

# wild bundle: directory present, no inventory row
mkdir -p "$sb/bundles/wild-bundle/concepts"
run_lint "$sb"
lint_dirty "wild bundle rejected"
out_has "not in CHARTE.md inventory" "…with the §10 message"
rm -rf "$sb/bundles/wild-bundle"

# _-prefixed sandbox: warning locally (exit 0), error in --ci
mkdir -p "$sb/bundles/_scratch/concepts"
regen "$sb"
run_lint "$sb"
lint_clean "_-prefixed sandbox tolerated locally (exit 0)"
out_has "sandbox bundle (allowed locally, forbidden in CI)" "…with the sandbox warning"
run_lint "$sb" --ci
lint_dirty "_-prefixed sandbox rejected in --ci"
rm -rf "$sb/bundles/_scratch"

# inventory markers must stay byte-for-byte
run_lint "$sb"
lint_clean "restored tree clean"
file_has "$sb/CHARTE.md" "<!-- inventory:start -->" "inventory:start marker present"
file_has "$sb/CHARTE.md" "<!-- inventory:end -->" "inventory:end marker present"

python3 - "$sb" <<'EOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1]) / "CHARTE.md"
p.write_text(p.read_text().replace("<!-- inventory:start -->", "<!-- inventory start -->"))
EOF
run_lint "$sb"
lint_dirty "altered inventory marker rejected"
out_has "inventory markers not found" "…with the dedicated message"

# and the row removal logic of init.sh keys on the first column: `| \`example\``
sb2=$(new_sandbox)
file_has "$sb2/CHARTE.md" "| \`example\`" "example inventory row starts with the expected first column"

exit_case
