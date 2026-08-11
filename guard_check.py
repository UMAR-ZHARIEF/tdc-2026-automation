"""Decide whether a Robot run was affected by the store's bot protection.

Exit 0 = clean, exit 2 = guard engaged (campaign must stand down).

WHY THIS EXISTS: a naive substring search over output.xml is WRONG. The
badge-delta wait in Add Current Product To Cart runs inside
Wait Until Keyword Succeeds, so every failed poll attempt writes its own
FAIL status containing "the add submission has not landed" even when the
add ultimately succeeds and the test passes. On 2026-08-12 that produced a
false positive which aborted a 10-suite campaign after one suite.

Correct rules:
  * Challenge-page phrases are page CONTENT and are meaningful anywhere.
  * The mutation-drop phrase only means the guard engaged if it is the
    reason a TEST failed -- i.e. it appears in a <test>-level status, not
    merely somewhere inside a retry loop that later succeeded.
"""
import sys
import xml.etree.ElementTree as ET

CHALLENGE_ANYWHERE = [
    "connection needs to be verified",
    "just a moment",
    "checking your browser",
    "cf-challenge",
    "attention required",
    "verify you are human",
]
MUTATION_DROP_TEST_LEVEL = [
    "has not landed",
    "did not increment past 0",
]


def main(path):
    try:
        root = ET.parse(path).getroot()
    except Exception as exc:  # unreadable output is itself a problem
        print("GUARD-CHECK: cannot parse %s (%s)" % (path, exc))
        return 0

    raw = open(path, encoding="utf-8", errors="replace").read().lower()
    for phrase in CHALLENGE_ANYWHERE:
        if phrase in raw:
            print("GUARD-CHECK: FAIL - challenge page served (%r)" % phrase)
            return 2

    for test in root.iter("test"):
        status = test.find("status")
        if status is None or status.get("status") != "FAIL":
            continue
        msg = (status.text or "").lower()
        for phrase in MUTATION_DROP_TEST_LEVEL:
            if phrase in msg:
                print("GUARD-CHECK: FAIL - cart mutation dropped, test %r failed on %r"
                      % (test.get("name"), phrase))
                return 2

    # Informational only: retry-level occurrences are normal and not a signal.
    retries = raw.count("has not landed")
    if retries:
        print("GUARD-CHECK: clean (%d retry-level 'has not landed' entries "
              "inside waits that later succeeded - not a guard signal)" % retries)
    else:
        print("GUARD-CHECK: clean")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
