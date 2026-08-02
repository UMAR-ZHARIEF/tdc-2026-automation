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

*** Keywords ***
Open Store Session
    [Documentation]    Starts Brave with a blank page. Deliberately does NOT pre-load the store:
    ...    navigation itself is under test in TS-01.
    New Browser    chromium    headless=${HEADLESS}    executablePath=${BRAVE_PATH}
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
    ...    carry over from earlier tests (used by bookmark/direct-link cases).
    New Context
    New Page    about:blank

Go Offline
    [Documentation]    Client-side offline emulation (Playwright Set Offline) — while offline
    ...    no request leaves this machine; the live store is untouched.
    Set Offline    True

Go Online
    Set Offline    False
