*** Settings ***
Documentation     TS-16 User Authentication — executable mirror of TCS cases TC-16-001..009.
...               Authorities: 02 - Test Case Specification v2.1 and 01 - Test Basis v1.0
...               (approved 2026-08-05), UC-16 (TB-AUTH-001..007). 3 cases automated; 6
...               documented SKIP: TC-16-001/002/005/008/009 require the registered test
...               account — its creation is a one-time controlled team action (fictitious
...               identity, project inbox) whose automated coverage activates post-creation
...               (maintenance testing); TC-16-004 (registration itself) is deliberately NOT
...               automated because repeating a real account-creation run per automation pass
...               would create duplicate accounts under the team's test-data policy. TC-16-003
...               mode amended to Executable (02 v2.1 audit addendum A4): logging in with a
...               guaranteed-nonexistent, random-ish fictitious e-mail never touches or creates
...               real account state, so it carries none of the duplication risk that keeps
...               TC-16-004 a documented skip.
...               New resource: resources/pages/account_pages.resource — every /account/login
...               and /account/register locator there is PROVISIONAL (inferred from Shopify
...               classic theme conventions and Test Basis observations, not a live visit under
...               this task's zero-store-traffic constraint); live-verify before relying on it
...               outside dry-run.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role —
...               every executed case here is designed to end in guest state (no session is
...               ever created).
...               Traffic: ~6 page loads across 3 auth-form submissions per run (one navigation
...               + one submit per executing case, no loops) — run sparingly (shared live store).
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

*** Test Cases ***
TC-16-001 Successful Login (Requires Test Account — SKIP)
    [Documentation]    Scenario: Successful login, using the registered test account's valid
    ...    credentials. Precondition: registered user. Steps: 1. Enter valid credentials.
    ...    2. Activate Sign In. Expected: login successful. Priority Critical / Positive
    ...    (suite value; the superseded detail table's "High" is overridden per 02 v2.1's
    ...    suite-wins rule, alignment anomaly item 24).
    [Tags]    priority-critical    type-positive    TC-16-001    TB-AUTH-001    TB-AUTH-002    TB-AUTH-003    TB-AUTH-004    TB-AUTH-005    TB-AUTH-006    TB-AUTH-007
    Skip    Requires the registered test account — its creation is a one-time controlled team action (fictitious identity, project inbox); automated coverage of this flow activates post-creation (maintenance testing).

TC-16-002 Login With Incorrect Password (Requires Test Account — SKIP)
    [Documentation]    Scenario: Invalid login (suite title: Login with incorrect password).
    ...    Precondition: registered user. Steps: 1. Enter wrong password. 2. Activate Sign In.
    ...    Expected: authentication error displayed. Priority Critical / Negative (suite value;
    ...    alignment anomaly item 25 overrides the superseded detail table's "High").
    [Tags]    priority-critical    type-negative    TC-16-002    TB-AUTH-001    TB-AUTH-002    TB-AUTH-003    TB-AUTH-004    TB-AUTH-005    TB-AUTH-006    TB-AUTH-007
    Skip    Requires the registered test account — its creation is a one-time controlled team action (fictitious identity, project inbox); automated coverage of this flow activates post-creation (maintenance testing).

TC-16-003 Login With Non-Existing Account
    [Documentation]    Login page open; no account exists for the credentials used (02 v2.1
    ...    audit addendum A17 precondition/steps). Steps: 1. Enter credentials for an account
    ...    that does not exist. 2. Activate Sign In. Expected (realigned content — 02 v2.1
    ...    §REWORDS, its "Authentication security" origin resolved into this case): login with
    ...    a non-existing account is rejected with a generic error that does not reveal whether
    ...    the account exists or which field is wrong. The e-mail is generated random-ish at
    ...    run time so this case is guaranteed to target an unregistered account without
    ...    hardcoding one fixed fictitious address. Priority High / Negative.
    ...    LIVE RESULT 12 Aug 2026 — EXPECTED FAIL, defect harvested: after submitting
    ...    credentials for a non-existent account the store shows NO feedback at all. Polled for
    ...    15s: zero error-surface elements and no error wording anywhere in the page text; the
    ...    browser simply remains on the Customer Login page. The session is correctly refused,
    ...    but the customer is told nothing — the same "protection works, communication does
    ...    not" shape as the empty-cart checkout finding (TC-08-004). This FAIL is the defect
    ...    record, not test breakage.
    [Tags]    priority-high    type-negative    known-defect-lead    TC-16-003    TB-AUTH-001    TB-AUTH-002    TB-AUTH-003    TB-AUTH-004    TB-AUTH-005    TB-AUTH-006    TB-AUTH-007
    Open Login Page
    ${email}=    Generate Fictitious Nonexistent Email
    Fill Login Credentials    ${email}    ${FICTITIOUS_PASSWORD}
    Submit Login
    Login Error Should Be Shown
    No Session Should Be Established

TC-16-004 Successful Registration (Not Automated — SKIP)
    [Documentation]    Scenario: Successful registration. Precondition: guest user. Steps:
    ...    1. Register new account. Expected: account created successfully. Priority High /
    ...    Positive. Not automated by deliberate policy, not by data unavailability: unlike
    ...    TC-16-001/002/005/008/009 this flow needs no pre-existing account (registration
    ...    itself creates one), but running it on every automation pass would create a fresh
    ...    duplicate account each time.
    [Tags]    priority-high    type-positive    TC-16-004    TB-AUTH-001    TB-AUTH-002    TB-AUTH-003    TB-AUTH-004    TB-AUTH-005    TB-AUTH-006    TB-AUTH-007
    Skip    Account creation is deliberately NOT automated: it is a one-time controlled team action under the test-data policy; repeating it per automation run would create duplicate accounts.

TC-16-005 Register With Existing Email (Requires Test Account — SKIP)
    [Documentation]    Scenario: Register existing email (suite title: Register with existing
    ...    email). Precondition: existing account. Steps: 1. Register using same email.
    ...    Expected: duplicate account message displayed. Priority High / Negative. Needs the
    ...    registered test account's e-mail on hand to attempt a genuine duplicate-registration
    ...    conflict.
    [Tags]    priority-high    type-negative    TC-16-005    TB-AUTH-001    TB-AUTH-002    TB-AUTH-003    TB-AUTH-004    TB-AUTH-005    TB-AUTH-006    TB-AUTH-007
    Skip    Requires the registered test account — its creation is a one-time controlled team action (fictitious identity, project inbox); automated coverage of this flow activates post-creation (maintenance testing).

TC-16-006 Empty Login Fields
    [Documentation]    Login page open; fields empty. Steps: 1. Activate Sign In with both
    ...    fields empty. 2. Observe validation. Expected: login is refused with clear
    ...    validation; no session is created. Priority High / Negative.
    [Tags]    priority-high    type-negative    known-defect-lead    TC-16-006    TB-AUTH-001
    Open Login Page
    Submit Login
    Empty Login Validation Should Be Shown
    No Session Should Be Established

TC-16-007 Invalid E-Mail Format During Sign Up
    [Documentation]    Registration page open. Steps: 1. Enter a first/last name and password;
    ...    enter a malformed e-mail (e.g. "user@@test"). 2. Activate Create. 3. Observe
    ...    validation. Expected: registration is refused with a clear e-mail-format error; no
    ...    account is created. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-16-007    TB-AUTH-002
    Open Register Page
    Fill Registration Details    ${FICTITIOUS_FIRST_NAME}    ${FICTITIOUS_LAST_NAME}    ${MALFORMED_EMAIL}    ${FICTITIOUS_PASSWORD}
    Submit Registration
    Registration Email Format Error Should Be Shown
    No Account Created Should Be Confirmed

TC-16-008 Password Recovery E-Mail (Requires Test Account — SKIP)
    [Documentation]    Registered test account exists; login page open. Steps: 1. Activate
    ...    "Forgot your password?". 2. Verify the Reset Password form appears. 3. Submit the
    ...    account e-mail. 4. Check the inbox for the reset e-mail and follow it to set a new
    ...    password. 5. Log in with the new password. Expected: the reset form functions; the
    ...    e-mail arrives; the new password grants access. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-16-008    TB-AUTH-005
    Skip    Requires the registered test account — its creation is a one-time controlled team action (fictitious identity, project inbox); automated coverage of this flow activates post-creation (maintenance testing).

TC-16-009 Log Out Returns To Guest State (Requires Test Account — SKIP)
    [Documentation]    Logged in with the test account. Steps: 1. Activate the log-out control.
    ...    2. Verify the header returns to guest state (Log In / Sign up visible). 3. Verify
    ...    account pages are no longer accessible without login. Expected: the session ends;
    ...    the UI and access rights return to the guest state. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-16-009    TB-AUTH-006
    Skip    Requires the registered test account — its creation is a one-time controlled team action (fictitious identity, project inbox); automated coverage of this flow activates post-creation (maintenance testing).
