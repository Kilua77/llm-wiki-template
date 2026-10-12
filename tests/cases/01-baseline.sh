# Baseline — the pristine working tree lints clean, indexes are fresh,
# and every demo page validates against the JSON schema.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
run_lint "$sb"
lint_clean "pristine tree lints clean (exit 0)"
out_lacks "ERROR" "no ERROR line on the pristine tree"

(cd "$sb" && python3 tools/gen-index.py --check >/dev/null 2>&1)
if [ $? -eq 0 ]; then ok "gen-index --check green on the pristine tree"; else fail "gen-index --check red on the pristine tree"; fi

# Schema round-trip — skipped (and said so) when jsonschema is not installed.
if python3 -c "import jsonschema" 2>/dev/null; then
  bad=$(cd "$sb" && python3 - <<'EOF'
import json, pathlib, yaml
from jsonschema import Draft202012Validator
v = Draft202012Validator(json.load(open("schemas/frontmatter-page.schema.json")))
n = 0
for f in pathlib.Path("bundles").rglob("*.md"):
    if f.name in ("index.md", "log.md") or f.parent.name == "raw":
        continue
    text = f.read_text()
    if not text.startswith("---\n"):
        continue
    fm = yaml.safe_load(text[4:text.find("\n---", 4)])
    fm = json.loads(json.dumps(fm, default=lambda o: o.isoformat()))
    n += sum(1 for _ in v.iter_errors(fm))
print(n)
EOF
)
  if [ "$bad" = "0" ]; then ok "all demo pages validate against the page schema"; else fail "$bad schema violation(s) in demo pages"; fi
else
  echo "  SKIP: jsonschema not installed — schema round-trip not run"
fi

exit_case
