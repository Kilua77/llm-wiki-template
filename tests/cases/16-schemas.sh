# Schemas — the pre-flight: a filled template validates, a broken one is
# rejected. Skipped (loudly) when jsonschema is not installed.
. "$(dirname "$0")/../lib.sh"

if ! python3 -c "import jsonschema" 2>/dev/null; then
  echo "  SKIP: jsonschema not installed — schema cases not run"
  exit 0
fi

sb=$(new_sandbox)

(cd "$sb" && python3 - <<'EOF'
import json, yaml, copy
from jsonschema import Draft202012Validator
v = Draft202012Validator(json.load(open("schemas/frontmatter-page.schema.json")))

def to_json(fm):
    return json.loads(json.dumps(fm, default=lambda o: o.isoformat()))

def check(fm):
    return list(v.iter_errors(to_json(fm)))

good = yaml.safe_load("""
type: Decision
title: Use a single writer queue
description: One queue serializes writers.
tags: [architecture]
status: stable
stale_after: 2027-10-13
generated: { by: agent/model, at: 2026-10-13T00:00:00Z }
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/queue.cpp
    lines: 10-20
applies_to: [/concepts/queue.md]
sources:
  - { id: o, resource: "observation:2026-10", title: Direct observation }
""")
errs = check(good)
if not errs: print("GOOD-OK")
else: print("GOOD-FAIL " + "; ".join(e.message for e in errs))

bad = copy.deepcopy(to_json(good)); bad.pop("code_refs")
errs = check(bad)
if errs: print("BAD-OK")
else: print("BAD-FAIL no error for missing code_refs")

bad2 = copy.deepcopy(to_json(good))
bad2["code_refs"][0]["commit"] = "deadbeef"
errs = check(bad2)
if errs: print("SHORTSHA-OK")
else: print("SHORTSHA-FAIL")

bad3 = copy.deepcopy(to_json(good))
bad3["source_file"] = {"name": "a.pdf", "sha256": "xyz", "stored_at": "storage:x"}
errs = check(bad3)
if errs: print("SF-OK")
else: print("SF-FAIL")
EOF
) > "$TESTS_TMP/schema-res"
res=$(cat "$TESTS_TMP/schema-res")
for want in GOOD-OK BAD-OK SHORTSHA-OK SF-OK; do
  if grep -qF "$want" "$TESTS_TMP/schema-res"; then ok "$want"; else fail "$want missing — got: $res"; fi
done

exit_case
