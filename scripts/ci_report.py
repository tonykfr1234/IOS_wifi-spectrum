#!/usr/bin/env python3
"""Turn xcodebuild logs and the xcresult summary into a short Markdown report for CI."""
import json
import re
import sys
from pathlib import Path


def main() -> int:
    build = Path(sys.argv[1] if len(sys.argv) > 1 else 'build')
    out = ['# iOS CI report', '']
    summary = build / 'test-summary.json'
    if summary.exists() and summary.stat().st_size:
        try:
            s = json.loads(summary.read_text())
            out.append(f"- Result: **{s.get('result')}**")
            out.append(f"- Passed {s.get('passedTests')} · failed {s.get('failedTests')} · skipped {s.get('skippedTests')} · total {s.get('totalTestCount')}")
            for f in s.get('testFailures', [])[:30]:
                out.append(f"  - FAIL `{f.get('testIdentifierString')}`: {f.get('failureText')}")
        except ValueError:
            out.append('- test summary unreadable')
    errors = []
    for log in sorted(build.glob('*.log')):
        for line in log.read_text(errors='replace').splitlines():
            if re.search(r'(error:|\*\* (TEST|BUILD) FAILED|Test Case .* failed|fatal error)', line):
                errors.append(f'{log.name}: {line.strip()[:300]}')
    if errors:
        out += ['', '## Errors', ''] + [f'- {e}' for e in errors[:60]]
    shots = sorted(p.name for p in (build / 'screenshots').glob('*.png')) if (build / 'screenshots').exists() else []
    out += ['', f'Screenshots: {len(shots)}'] + [f'- {s}' for s in shots]
    print('\n'.join(out))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
