*** Settings ***
Documentation     TS-16 User Authentication: executable mirror of TCS cases TC-16-001..009.
...               Authorities: the team's Test Case Specification and Test Basis, UC-16. 2 cases
...               automated end-to-end
...               (TC-16-007 client-side sign-up validation; TC-16-008 recovery UI half, live-
...               passed on a later run); 1 verify-then-skip (TC-16-006 captures the client-side
...               validation-contrast observation live, no submission); 6 documented SKIPs.
...               THE REGISTERED TEST ACCOUNT EXISTS: created earlier as the one-time
...               controlled team action (TC-16-004 performed by hand: identity Tdc Fictitious,
...               project inbox forprojectdump@gmail.com; the registration submit is
...               hCaptcha-GATED, challenge solved by a human).
...               ⚠️ hCAPTCHA GOVERNS THIS WHOLE SUITE (established via a three-step
...               evidence chain): (1) registration drew an interactive challenge; (2) the first
...               account-based automated run showed login submissions SILENTLY SWALLOWED: form
...               still filled, no navigation, no error, badge visible (fail screenshots,
...               results/ts16_live_2026-08-12/); (3) the manual confirmation retest proved the
...               server's true behaviour: failed logins draw the generic red "Incorrect email
...               or password." (results/MANUAL_TS16_LOGIN_2026-08-12/). CONSEQUENCES: the
...               former "silent failed login" defect (TC-16-003) is STRUCK as an automation
...               artifact; the former "no validation" defect (TC-16-006) is DOWNGRADED to a
...               client-side consistency observation (missing required/empty enforcement on
...               the login e-mail field; type='email' format checking exists); TC-16-001/002/003/009 are captcha-gated
...               documented Skips with manual evidence attached and their implemented steps
...               retained (automation does not defeat bot protection); TC-16-005 likewise
...               (duplicate-e-mail response sits behind the same captcha). Every executing
...               case ends in guest state. TC-16-008's inbox half stays manual (TC-13-007
...               split; the reset link is never followed: it would change the registered
...               credential). TC-16-003 mode was amended to Executable (the Test Case
...               Specification's audit addendum A4); its execution is now human, not automated.
...               Resource: resources/pages/account_pages.resource, the login/register field
...               and session-marker locators are LIVE-VERIFIED (executed runs + the account
...               registration); the recover-form and error-surface locators remain
...               PROVISIONAL until TC-16-008's first live pass (union oracles keep those
...               assertions winnable either way).
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role;
...               every executed case here is designed to end in guest state (no session is
...               ever created).
...               Traffic: ~5 page loads per run (TC-16-006 opens the login page for its DOM
...               observation; TC-16-007 one register-page load, client-side only; TC-16-008
...               login page + recover flow; captcha-gated cases skip before any navigation);
...               run sparingly (shared live store). NOTE: automated runs of TC-16-008 dispatch
...               NO recovery e-mail: the account-form captcha silently swallows automated
...               submissions (proven live: an all-folder mailbox search found zero
...               robot-triggered reset e-mails from the automated runs, while an identical
...               human-submitted request produced one shortly after; evidence:
...               results/MANUAL_TC-16-008_INBOX_2026-08-13/).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/account_pages.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-16    UC-16    guest

*** Variables ***
${MALFORMED_EMAIL}          user@@test
${FICTITIOUS_FIRST_NAME}    Tdc
${FICTITIOUS_LAST_NAME}     Fictitious
${FICTITIOUS_PASSWORD}      Tdc-Fictitious-Pw-2026!
# Registered test account: created once (TC-16-004 one-time controlled team
# action; hCaptcha solved by a human; identity Tdc Fictitious; team project inbox). Committing
# the fictitious credential is deliberate under the team's test-data policy.
${TEST_ACCOUNT_EMAIL}       forprojectdump@gmail.com
${TEST_ACCOUNT_PASSWORD}    ${FICTITIOUS_PASSWORD}

*** Test Cases ***
TC-16-001 Successful Login
    [Documentation]    Scenario: Successful login, using the registered test account's valid
    ...    credentials. Precondition: registered user (already exists). Steps:
    ...    1. Enter valid credentials. 2. Activate Sign In. Expected: login successful: the
    ...    header switches to the logged-in state (My Account / Log Out; live-verified marker).
    ...    Ends in guest state via teardown. Priority High / Positive (final4 value; supersedes
    ...    the former Critical override recorded in the Test Case Specification's suite-wins
    ...    rule, alignment anomaly item 24, and restores the detail table's original High).
    [Tags]    priority-high    type-positive    captcha-gated    TC-16-001
    [Teardown]    Ensure Logged Out
    Skip    Captcha-gated for automation (discovered live): the login submit is hCaptcha-protected and automated submissions are silently swallowed: the form stays filled, the page never navigates, no error renders (fail-screenshot evidence, results/ts16_live_2026-08-12/). The flow itself is HUMAN-VERIFIED the same day: the account logged straight in at creation (header switched to My Account / Log Out). Steps retained below for a future maintenance re-attempt; automation does not defeat bot protection.
    Log In With    ${TEST_ACCOUNT_EMAIL}    ${TEST_ACCOUNT_PASSWORD}
    Logged In State Should Be Shown

TC-16-002 Login With Incorrect Password
    [Documentation]    Scenario: Invalid login (suite title: Login with incorrect password).
    ...    Precondition: registered user (already exists). Steps: 1. Enter the
    ...    registered e-mail with a wrong password. 2. Activate Sign In. Expected:
    ...    authentication error displayed; no session established. RESOLVED BY MANUAL
    ...    CONFIRMATION RETEST: a human submitting the registered e-mail with a
    ...    wrong password receives the generic red error "Incorrect email or password.": the
    ...    REQUIREMENT IS MET (verified PASS, manually). Automated submissions of this form
    ...    never reach the server (hCaptcha, see TC-16-001), which is also why the earlier
    ...    "silent failed login" automated results were artifacts, not store behaviour.
    ...    Priority High / Negative (final4 value; supersedes the former Critical override,
    ...    the Test Case Specification's alignment anomaly item 25, and restores the detail
    ...    table's original High).
    [Tags]    priority-high    type-negative    captcha-gated    TC-16-002
    [Teardown]    Ensure Logged Out
    Skip    Captcha-gated for automation; requirement HUMAN-VERIFIED PASS: wrong password on the registered account produced the generic "Incorrect email or password." error (screenshot evidence, results/MANUAL_TS16_LOGIN_2026-08-12/). Automated submits are swallowed by hCaptcha and never reach the server. Steps retained below for a future maintenance re-attempt.
    Log In With    ${TEST_ACCOUNT_EMAIL}    Wrong-${TEST_ACCOUNT_PASSWORD}
    Login Error Should Be Shown
    No Session Should Be Established

TC-16-003 Login With Non-Existing Account
    [Documentation]    Login page open; no account exists for the credentials used (the Test Case
    ...    Specification's audit addendum A17 precondition/steps). Steps: 1. Enter credentials for
    ...    an account that does not exist. 2. Activate Sign In. Expected (realigned content: the
    ...    Test Case Specification's §REWORDS, its "Authentication security" origin resolved into
    ...    this case): login with
    ...    a non-existing account is rejected with a generic error that does not reveal whether
    ...    the account exists or which field is wrong. The e-mail is generated random-ish at
    ...    run time so this case is guaranteed to target an unregistered account without
    ...    hardcoding one fixed fictitious address. Priority High / Negative.
    ...    ⚠️ RE-GRADED in a later pass: THE "SILENT FAILED LOGIN" DEFECT IS STRUCK AS AN
    ...    AUTOMATION ARTIFACT. The earlier "EXPECTED FAIL, defect harvested" result (no
    ...    feedback after 15s) was recorded by an automated browser whose login submission
    ...    never reached the server: the submit is hCaptcha-protected and silently swallowed
    ...    (fail-screenshot: form still filled, no navigation, hCaptcha badge present). The
    ...    manual confirmation retest shows the store's true behaviour: a failed
    ...    login draws the generic red "Incorrect email or password.": feedback exists and is
    ...    properly non-revealing (it does not disclose whether the account exists, the exact
    ...    A17 requirement). Requirement judged MET on manual evidence; the same generic
    ...    server-side error path serves nonexistent-account and wrong-password submissions.
    [Tags]    priority-high    type-negative    captcha-gated    TC-16-003
    Skip    Captcha-gated for automation; requirement HUMAN-VERIFIED: the store answers failed logins with the generic, non-revealing "Incorrect email or password." (screenshot evidence, results/MANUAL_TS16_LOGIN_2026-08-12/). The previous automated FAILs ("no feedback") are RE-GRADED as artifacts: hCaptcha silently swallowed automated submissions, so the server never produced its error. Steps retained below for a future maintenance re-attempt.
    Open Login Page
    ${email}=    Generate Fictitious Nonexistent Email
    Fill Login Credentials    ${email}    ${FICTITIOUS_PASSWORD}
    Submit Login
    Login Error Should Be Shown
    No Session Should Be Established

TC-16-004 Successful Registration (Not Automated, SKIP)
    [Documentation]    Scenario: Successful registration. Precondition: guest user. Steps:
    ...    1. Register new account. Expected: account created successfully. Priority High /
    ...    Positive. Not automated by deliberate policy, not by data unavailability: unlike
    ...    TC-16-001/002/005/008/009 this flow needs no pre-existing account (registration
    ...    itself creates one), but running it on every automation pass would create a fresh
    ...    duplicate account each time. PERFORMED ONCE BY HAND: the submit is
    ...    hCaptcha-gated (a human solved the challenge), so the flow is also not automatable
    ...    in principle; the registered account is live.
    [Tags]    priority-high    type-positive    TC-16-004
    Skip    One-time action ALREADY PERFORMED: the registered test account exists (Tdc Fictitious, project inbox; hCaptcha on the registration submit solved by a human). Not repeatable (duplicate accounts) and not automatable (automation does not defeat bot protection). Designed case retained in the TCS.

TC-16-005 Register With Existing Email (Captcha-Gated, SKIP)
    [Documentation]    Scenario: Register existing email (suite title: Register with existing
    ...    email). Precondition: existing account (already exists). Steps: 1. Register
    ...    using same email. Expected: duplicate account message displayed. Priority High /
    ...    Negative. NOT automatable: the duplicate-account response requires the registration
    ...    submit to reach the server, and that submit is hCaptcha-GATED (observed live
    ...    during the one-time account creation). Automation does not attempt to
    ...    defeat bot protection; the case is coverable in the Phase H manual round, where a
    ...    human passes the captcha.
    [Tags]    priority-high    type-negative    TC-16-005
    Skip    Not automatable: the registration submit is hCaptcha-gated (observed live): reaching the server's duplicate-e-mail response would require defeating bot protection, which automation does not do. The registered account exists; the case is coverable manually in Phase H (a human passes the captcha). Designed case retained in the TCS.

TC-16-006 Empty Login Fields
    [Documentation]    Login page open; fields empty. Steps: 1. Activate Sign In with both
    ...    fields empty. 2. Observe validation. Expected: login is refused with clear
    ...    validation; no session is created. ⚠️ RE-GRADED in a later pass: the former "login form
    ...    has NO validation at all" defect is DOWNGRADED TO AN OBSERVATION. Its submit-half
    ...    evidence was an automation artifact (hCaptcha swallows automated submissions, so no
    ...    server response was ever observed); the manual retest proves the server answers
    ...    failed submissions with the generic "Incorrect email or password." What SURVIVES,
    ...    because it is DOM-inspectable without any submission, is the client-side contrast:
    ...    the login e-mail field is NOT required (an empty submission passes client-side)
    ...    unlike the sign-up form's stricter enforcement. (The field does carry type='email',
    ...    so FORMAT checking exists; the contrast is specifically the missing required/empty
    ...    enforcement: v6 run readback corrected an earlier overbroad "no format validation"
    ...    phrasing.) An inconsistency observation, not a defect. This case now performs that observation live
    ...    (verify-then-skip, the TC-04-004 pattern) and documents the captcha-gated submit
    ...    half. Priority High / Negative.
    [Tags]    priority-high    type-negative    captcha-gated    TC-16-006
    Open Login Page
    ${facts}=    Login Email Client Validation Facts
    Log    OBSERVATION (TC-16-006): client-side validation facts for the login e-mail field (no submission involved): ${facts}. Contrast: the sign-up e-mail field enforces HTML5 format validation (TC-16-007 asserts it live). The login form relies wholly on the server's generic error for feedback: an inconsistency OBSERVATION; feedback itself exists (human-verified live).    level=WARN
    Skip    Submit-half captcha-gated for automation; the server's failed-submission feedback is HUMAN-VERIFIED (generic "Incorrect email or password.", results/MANUAL_TS16_LOGIN_2026-08-12/). The client-side validation-contrast observation above was captured live by this run. Former "no validation at all" defect DOWNGRADED to that observation.

TC-16-007 Invalid E-Mail Format During Sign Up
    [Documentation]    Registration page open. Steps: 1. Enter a first/last name and password;
    ...    enter a malformed e-mail (e.g. "user@@test"). 2. Activate Create. 3. Observe
    ...    validation. Expected: registration is refused with a clear e-mail-format error; no
    ...    account is created. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-16-007
    Open Register Page
    Fill Registration Details    ${FICTITIOUS_FIRST_NAME}    ${FICTITIOUS_LAST_NAME}    ${MALFORMED_EMAIL}    ${FICTITIOUS_PASSWORD}
    Submit Registration
    Registration Email Format Error Should Be Shown
    No Account Created Should Be Confirmed

TC-16-008 Password Recovery E-Mail
    [Documentation]    Registered test account exists; login page open. Steps:
    ...    1. Activate "Forgot your password?". 2. Verify the Reset Password form appears.
    ...    3. Submit the account e-mail and verify the store renders its generic on-screen
    ...    confirmation. This automated case exercises the recovery UI half ONLY: the
    ...    account-form captcha silently swallows automated submissions, so NO e-mail is sent
    ...    on automated runs: the on-screen confirmation renders regardless and is UI evidence
    ...    only, not proof the request was processed (proven live: an all-folder mailbox
    ...    search found no robot-triggered reset e-mail from the automated runs, while an identical
    ...    human-submitted request produced one, "Customer account password reset" from Sauce
    ...    Demo, received shortly after; evidence:
    ...    results/MANUAL_TC-16-008_INBOX_2026-08-13/). The e-mail half of the requirement is
    ...    HUMAN-VERIFIED PASS. TCS steps 4–5 (read the inbox, follow the link, set
    ...    a new password, log in with it) are the MANUAL half against the project inbox (the
    ...    TC-13-007 split) and are deliberately never automated: following the reset link would
    ...    change the registered credential and break TC-16-001. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-16-008
    Open Login Page
    Open Password Recovery
    Recovery Form Should Be Shown
    Submit Recovery For    ${TEST_ACCOUNT_EMAIL}
    Recovery Dispatch Should Be Confirmed
    Log    Automated half complete: recover form shown, on-screen confirmation rendered: UI evidence only, not proof of dispatch (automated submissions are silently swallowed by the account-form captcha, so no e-mail is sent on automated runs, proven live). E-mail half is HUMAN-VERIFIED PASS: a human-submitted request produced the e-mail. The reset flow itself is never automated here, to preserve the registered credential.

TC-16-009 Log Out Returns To Guest State
    [Documentation]    Logged in with the test account (login performed by this case; account
    ...    already exists). Steps: 1. Activate the log-out control. 2. Verify the
    ...    header returns to guest state (Log In visible, Log Out gone). 3. Verify /account is
    ...    no longer accessible without login (answered with the login page). Expected: the
    ...    session ends; the UI and access rights return to the guest state. Priority Medium /
    ...    Positive.
    [Tags]    priority-medium    type-positive    captcha-gated    TC-16-009
    [Teardown]    Ensure Logged Out
    Skip    Captcha-gated for automation: the case's login precondition cannot be established (hCaptcha swallows automated login submissions). The logout mechanism itself is LIVE-OBSERVED working the same day: activating the header Log Out control ends the session and returns the guest header (observed during the one-time account creation). Steps retained below for a future maintenance re-attempt.
    Log In With    ${TEST_ACCOUNT_EMAIL}    ${TEST_ACCOUNT_PASSWORD}
    Logged In State Should Be Shown
    Log Out Via Header
    Guest State Should Be Shown
    Account Area Should Require Login
