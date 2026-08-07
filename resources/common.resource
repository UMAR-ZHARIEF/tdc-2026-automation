*** Settings ***
Documentation     Shared store constants and browser-session keywords for the TDC 2026 suites.
...               Brave is Chromium-based, so Playwright's chromium engine drives it directly
...               via executablePath (no driver-version matching needed).
Library           Browser

*** Variables ***
${STORE_URL}      https://sauce-demo.myshopify.com/
${BRAVE_PATH}     C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe
# Override from the command line for unattended runs: --variable HEADLESS:True
${HEADLESS}       False
# Trusted persistent browser profile (7 Aug 2026 countermeasure): the live store's bot
# protection silently drops cart-mutation submissions from a fresh automation browser while
# serving it ordinary pages. Suites therefore run on a persistent COPY of an
# already-trusted, history-carrying profile when one exists at this path (populate it by
# copying the trusted profile; NEVER commit it — .gitignore'd; refresh by re-copying).
# Openly documented in the Part 2 report. Set to a nonexistent path to force the plain
# fresh-browser behaviour. Anchored to this resource file's own location (${CURDIR} =
# resources\) so the default resolves to automation\.robot-profile regardless of the
# directory robot is launched from — the original ${EXECDIR} anchor silently fell back to
# the plain fresh browser whenever robot ran from outside automation\ (7 Aug run evidence).
${ROBOT_PROFILE_DIR}    ${CURDIR}${/}..${/}.robot-profile

*** Keywords ***
Open Store Session
    [Documentation]    Starts Brave with a blank page. Deliberately does NOT pre-load the store:
    ...    navigation itself is under test in TS-01. When the trusted persistent profile
    ...    directory exists (see ${ROBOT_PROFILE_DIR} above), the session launches AS that
    ...    profile via New Persistent Context — the store then treats the suite like the
    ...    trusted, history-carrying browser; otherwise falls back to the original plain
    ...    fresh-browser launch.
    ${profile_exists}=    Evaluate    os.path.isdir($ROBOT_PROFILE_DIR)    modules=os
    IF    ${profile_exists}
        New Persistent Context    userDataDir=${ROBOT_PROFILE_DIR}    browser=chromium
        ...    headless=${HEADLESS}    executablePath=${BRAVE_PATH}
    ELSE
        New Browser    chromium    headless=${HEADLESS}    executablePath=${BRAVE_PATH}
    END
    New Page    about:blank
    # Browser-library equivalent of the old Selenium implicit wait
    Set Browser Timeout    15 seconds
    Set Retry Assertions For    15 seconds
    # The store renders hidden duplicate elements — take the first match instead of
    # failing on multiple matches (see Suite A, TC-A-003 finding)
    Set Strict Mode    False

Close Store Session
    Close Browser    ALL

Open Fresh Context
    [Documentation]    Opens a new browser context on a blank page — no cookies or history
    ...    carry over from earlier tests (used by bookmark/direct-link cases). Under a
    ...    persistent-profile session (see Open Store Session) Playwright cannot spawn a
    ...    second context from the same launch, so this keyword falls back to starting a
    ...    plain secondary browser for the fresh context — correct for these cases, which are
    ...    read-only navigations that never needed the trusted profile (page GETs were always
    ...    served; only cart mutations were dropped).
    ${status}    ${error}=    Run Keyword And Ignore Error    New Context
    IF    '${status}' == 'FAIL'
        New Browser    chromium    headless=${HEADLESS}    executablePath=${BRAVE_PATH}
        New Context
    END
    New Page    about:blank

Go Offline
    [Documentation]    Client-side offline emulation (Playwright Set Offline) — while offline
    ...    no request leaves this machine; the live store is untouched.
    Set Offline    True

Go Online
    Set Offline    False
