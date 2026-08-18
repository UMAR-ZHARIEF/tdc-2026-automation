*** Settings ***
Documentation     Page object: classic Shopify customer authentication forms — the login page
...               (/account/login: customer[email], customer[password], Sign In submit) and the
...               registration page (/account/register: customer[first_name], customer[last_name],
...               customer[email], customer[password], Create submit). Built for TS-16 User
...               Authentication (UC-16) under the zero-store-traffic
...               constraint: every locator below is PROVISIONAL — inferred from Shopify classic
...               theme conventions and Test Basis v1.0 observations, not from
...               a live visit to these two pages. Each is flagged individually; live-verify
...               before relying on this file outside dry-run. Error/validation oracles are
...               written as UNION checks (a locator-based surface OR a body-text regex) so a
...               wrong PROVISIONAL locator does not by itself make an assertion unwinnable once
...               this suite runs live.
Library           Browser
Resource          ../common.resource

*** Variables ***
${LOGIN_EMAIL_INPUT}            css=input[name="customer[email]"]:visible    # LIVE-VERIFIED (TC-16-003/006 executed runs)
${LOGIN_PASSWORD_INPUT}         css=input[name="customer[password]"]:visible    # LIVE-VERIFIED (TC-16-003/006 executed runs)
${LOGIN_SUBMIT}                 xpath=//input[@type='submit' and (contains(@value,'Sign In') or contains(@value,'Sign in'))] | //button[contains(normalize-space(),'Sign In') or contains(normalize-space(),'Sign in')]    # LIVE-VERIFIED (TC-16-003/006 executed runs)
${LOGIN_ERROR_SURFACE}          css=#customer_login .errors, #login_form .errors, .form__message, [class*="error"]:visible    # PROVISIONAL — exact class/id unconfirmed, used only as one arm of a union oracle
${REGISTER_FIRST_NAME_INPUT}    css=input[name="customer[first_name]"]:visible    # LIVE-VERIFIED 12 Aug 2026 (one-time account registration used these exact names)
${REGISTER_LAST_NAME_INPUT}     css=input[name="customer[last_name]"]:visible    # LIVE-VERIFIED 12 Aug 2026
${REGISTER_EMAIL_INPUT}         css=input[name="customer[email]"]:visible    # LIVE-VERIFIED 12 Aug 2026
${REGISTER_PASSWORD_INPUT}      css=input[name="customer[password]"]:visible    # LIVE-VERIFIED 12 Aug 2026
${REGISTER_SUBMIT}              xpath=//input[@type='submit' and contains(@value,'Create')] | //button[contains(normalize-space(),'Create')]    # LIVE-VERIFIED 12 Aug 2026 (button "Create")
${REGISTER_ERROR_SURFACE}       css=#create_customer .errors, .form__message, [class*="error"]:visible    # PROVISIONAL — exact class/id unconfirmed, used only as one arm of a union oracle
${ACCOUNT_LOGGED_IN_MARK}       css=a[href*="/account/logout"]:visible    # LIVE-VERIFIED 12 Aug 2026 (header "Log Out" link while logged in); presence is the active-session marker
${GUEST_LOGIN_LINK}             css=a[href*="/account/login"]:visible    # LIVE-VERIFIED 12 Aug 2026 (guest header "Log In" link)
${FORGOT_PASSWORD_LINK}         xpath=//a[contains(translate(normalize-space(),'FORGOT','forgot'),'forgot') or contains(@href,'recover')]    # PROVISIONAL — classic themes use a "Forgot your password?" link that toggles or navigates to the recover form
${RECOVERY_EMAIL_INPUT}         css=form[action*="recover"] input[type="email"]:visible, form[action*="recover"] input[name="email"]:visible    # PROVISIONAL — classic recover form
${RECOVERY_SUBMIT}              css=form[action*="recover"] input[type="submit"]:visible, form[action*="recover"] button[type="submit"]:visible    # PROVISIONAL — classic recover form

*** Keywords ***
Open Login Page
    [Documentation]    Direct navigation to the classic Shopify customer login form.
    Go To    ${STORE_URL}account/login

Open Register Page
    [Documentation]    Direct navigation to the classic Shopify customer registration form.
    Go To    ${STORE_URL}account/register

Fill Login Credentials
    [Documentation]    Types the given email and password into the login form. Does not submit.
    [Arguments]    ${email}    ${password}
    Fill Text    ${LOGIN_EMAIL_INPUT}    ${email}
    Fill Text    ${LOGIN_PASSWORD_INPUT}    ${password}

Submit Login
    Click    ${LOGIN_SUBMIT}

Generate Fictitious Nonexistent Email
    [Documentation]    Builds a random-ish, syntactically valid e-mail address for an account
    ...    guaranteed not to be registered (TC-16-003) — avoids hardcoding one fixed string that
    ...    could coincidentally collide with a real or future test account.
    ${suffix}=    Evaluate    random.randint(100000, 999999)    modules=random
    ${email}=    Set Variable    tdc.nonexistent.${suffix}@example-tdc-invalid.test
    RETURN    ${email}

Login Error Should Be Shown
    [Documentation]    Asserts a generic authentication error/notice is shown after a failed
    ...    login attempt — union oracle: the PROVISIONAL error-surface element is present, or
    ...    the page text carries a generic error/invalid-credentials message (keeps the check
    ...    robust even if the surface locator proves wrong once live-verified). Realigned
    ...    TC-16-003 expected result (02 v2.1 §REWORDS): a generic error that does not reveal
    ...    whether the account exists or which field is wrong.
    ...
    ...    THE CHECK RETRIES. Submitting the login form is a full page reload, so asserting
    ...    immediately after the click can read the PRE-reload page, which of course carries no
    ...    error. Polling for up to 15s removes that ambiguity: a failure after the wait means
    ...    the store genuinely gave the customer no feedback on a failed login, which is a
    ...    finding worth recording rather than a timing artifact.
    Wait Until Keyword Succeeds    15s    1s    Login Error Surface Or Text Should Be Present

Login Error Surface Or Text Should Be Present
    [Documentation]    Single union check for a login error. Internal helper for
    ...    `Login Error Should Be Shown` — call that instead, so the retry wrapper applies.
    ${surface_hits}=    Get Element Count    ${LOGIN_ERROR_SURFACE}
    ${page_text}=    Get Text    body
    ${text_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(incorrect|invalid|wrong|unrecognized|error|could not|didn.?t work)
    Should Be True    ${surface_hits} > 0 or ${text_hit}
    ...    msg=No login error surface and no generic error text found after a failed login attempt

Empty Login Validation Should Be Shown
    [Documentation]    Asserts submitting the login form with both fields empty is refused with
    ...    clear validation (TC-16-006). Union oracle: an explicit validation/error
    ...    message, OR — if the theme relies on native HTML5 "required" field validation, which
    ...    blocks submission client-side with a browser tooltip this stack cannot read as DOM
    ...    text — the page simply remains on the login form with no session created.
    ...
    ...    THE "STILL ON THE LOGIN PAGE" ARM HAS BEEN REMOVED. It was unconditionally true:
    ...    blocking submission is precisely what this case asserts, so the browser always remains
    ...    on /account/login and the union could never fail (12 Aug 2026). The native HTML5
    ...    tooltip the old docstring called unreadable IS readable as the input's
    ...    validationMessage PROPERTY, so that fallback is now a real check rather than a
    ...    tautology.
    ${page_text}=    Get Text    body
    ${message_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(required|can.?t be blank|fill (in|out)|this field|enter (your|a valid))
    ${surface_hits}=    Get Element Count    ${LOGIN_ERROR_SURFACE}
    ${native_msg}=    Native Validation Message For    ${LOGIN_EMAIL_INPUT}
    ${native_hit}=    Evaluate    len($native_msg.strip()) > 0
    Log    Native HTML5 validation message on the e-mail field (evidence): '${native_msg}'
    Should Be True    ${message_hit} or ${surface_hits} > 0 or ${native_hit}
    ...    msg=Submitting the login form with both fields empty produced no validation evidence: no message text, no error surface, and no native HTML5 validation message

No Session Should Be Established
    [Documentation]    Asserts the guest header state persists — no logged-in-session marker is
    ...    present — after a rejected login or registration attempt.
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    ==    0

Fill Registration Details
    [Documentation]    Types the given identity into the registration form. Does not submit.
    [Arguments]    ${first_name}    ${last_name}    ${email}    ${password}
    Fill Text    ${REGISTER_FIRST_NAME_INPUT}    ${first_name}
    Fill Text    ${REGISTER_LAST_NAME_INPUT}    ${last_name}
    Fill Text    ${REGISTER_EMAIL_INPUT}    ${email}
    Fill Text    ${REGISTER_PASSWORD_INPUT}    ${password}

Submit Registration
    Click    ${REGISTER_SUBMIT}

Registration Email Format Error Should Be Shown
    [Documentation]    Asserts a clear e-mail-format error is shown after submitting a malformed
    ...    e-mail on the registration form (TC-16-007). Union oracle across three
    ...    arms: the PROVISIONAL error-surface element is present, or the page text names an
    ...    e-mail/format problem, or — if the theme's e-mail input uses type="email", which makes
    ...    the browser block submission of "user@@test" client-side with a native tooltip this
    ...    stack cannot read as DOM text — the page simply remains on the registration form with
    ...    no account created (same fallback pattern as Empty Login Validation Should Be Shown).
    ...
    ...    THE "STILL ON THE REGISTER PAGE" ARM HAS BEEN REMOVED for the same reason as
    ...    Empty Login Validation Should Be Shown: it was unconditionally true, so the case could
    ...    not fail. The browser's native validationMessage is read instead.
    ${surface_hits}=    Get Element Count    ${REGISTER_ERROR_SURFACE}
    ${page_text}=    Get Text    body
    ${text_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(invalid email|email.{0,15}(invalid|not valid|format)|enter a valid email)
    ${native_msg}=    Native Validation Message For    ${REGISTER_EMAIL_INPUT}
    ${native_hit}=    Evaluate    len($native_msg.strip()) > 0
    Log    Native HTML5 validation message on the sign-up e-mail field (evidence): '${native_msg}'
    Should Be True    ${surface_hits} > 0 or ${text_hit} or ${native_hit}
    ...    msg=Submitting sign-up with a malformed e-mail produced no validation evidence: no error surface, no message text, and no native HTML5 validation message
    ...    msg=No registration error surface, no e-mail-format error text, and no still-on-register-page evidence found after submitting a malformed e-mail

No Account Created Should Be Confirmed
    [Documentation]    Confirms a rejected registration attempt did not create an account: still
    ...    on the registration page (no redirect into the account area) and no logged-in-session
    ...    marker is present.
    Get Url    contains    /account/register
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    ==    0

Native Validation Message For
    [Documentation]    Returns the browser's native HTML5 constraint-validation message for the
    ...    given field, or an empty string if the field is currently valid. This is the readable
    ...    form of the tooltip Playwright cannot capture as DOM text — it lives on the element as
    ...    the validationMessage property. Using it lets the empty-field and bad-format cases
    ...    assert real evidence instead of falling back on "the browser is still on this page",
    ...    which is true by construction whenever submission is blocked.
    [Arguments]    ${locator}
    ${status}    ${value}=    Run Keyword And Ignore Error    Get Property    ${locator}    validationMessage
    IF    '${status}' == 'FAIL'
        RETURN    ${EMPTY}
    END
    RETURN    ${value}

Log In With
    [Documentation]    Full login flow with the given credentials: open the login page, fill,
    ...    submit. Added 12 Aug 2026 with the registered test account (TC-16-001/009).
    [Arguments]    ${email}    ${password}
    Open Login Page
    Fill Login Credentials    ${email}    ${password}
    Submit Login

Logged In State Should Be Shown
    [Documentation]    Asserts an active session: the header's Log Out link is present
    ...    (live-verified marker, 12 Aug 2026). Login submission is a full page reload, so this
    ...    relies on the session-wide retrying assertions to absorb the reload timing.
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    >    0
    ...    message=No logged-in marker (Log Out link) appeared after login — session not established

Guest State Should Be Shown
    [Documentation]    Asserts the guest header state: no Log Out link, and the Log In link is
    ...    back (both markers live-verified 12 Aug 2026).
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    ==    0
    Get Element Count    ${GUEST_LOGIN_LINK}    >    0
    ...    message=Guest header did not return after logout — Log In link absent

Log Out Via Header
    [Documentation]    Ends the session the way a customer does: activates the header's Log Out
    ...    control (a plain GET to /account/logout — observed live 12 Aug 2026 to land back on
    ...    the storefront as guest).
    Click    ${ACCOUNT_LOGGED_IN_MARK}

Ensure Logged Out
    [Documentation]    Best-effort teardown guard: if a session is active, end it, so every case
    ...    leaves the browser in guest state regardless of where it failed. Never fails itself.
    ${status}    ${n}=    Run Keyword And Ignore Error    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}
    IF    '${status}' == 'PASS' and ${n} > 0
        Run Keyword And Ignore Error    Click    ${ACCOUNT_LOGGED_IN_MARK}
    END

Account Area Should Require Login
    [Documentation]    Asserts access rights returned to guest: direct navigation to /account is
    ...    answered with the login page, not the account area (TC-16-009 step 3).
    Go To    ${STORE_URL}account
    Get Url    contains    /account/login

Open Password Recovery
    [Documentation]    Activates "Forgot your password?" on the login page. PROVISIONAL control:
    ...    classic themes either toggle an in-page recover form or navigate to /account/recover —
    ...    both end with the recover form visible, which is what the next keyword asserts.
    Click    ${FORGOT_PASSWORD_LINK}

Recovery Form Should Be Shown
    [Documentation]    Asserts the Reset Password form is displayed (TC-16-008 step 2).
    Get Element Count    ${RECOVERY_EMAIL_INPUT}    >    0
    ...    message=No password-recovery e-mail field appeared after activating Forgot your password

Submit Recovery For
    [Documentation]    Submits the recover form for the given address. On automated runs this
    ...    dispatches NO e-mail: the account-form captcha silently swallows automated submissions
    ...    (proven 13 Aug 2026 — an all-folder mailbox search found no robot-triggered reset
    ...    e-mail from the 12 Aug runs, while an identical human-submitted request produced one,
    ...    received 14:52 the same day; evidence: results/MANUAL_TC-16-008_INBOX_2026-08-13/).
    ...    The e-mail half of the requirement is HUMAN-VERIFIED PASS (13 Aug 2026). The reset
    ...    link itself is never followed by automation (following it would change the registered
    ...    account's password and break TC-16-001).
    [Arguments]    ${email}
    Fill Text    ${RECOVERY_EMAIL_INPUT}    ${email}
    Click    ${RECOVERY_SUBMIT}

Login Email Client Validation Facts
    [Documentation]    Reads the login e-mail field's client-side validation facts WITHOUT any
    ...    submission (submissions are hCaptcha-gated): the input type, the required property,
    ...    and the current native validationMessage. Added 12 Aug 2026 for TC-16-006's
    ...    observation half — these DOM facts are browser-readable regardless of bot protection.
    ${type}=    Get Property    ${LOGIN_EMAIL_INPUT}    type
    ${required}=    Get Property    ${LOGIN_EMAIL_INPUT}    required
    ${msg}=    Native Validation Message For    ${LOGIN_EMAIL_INPUT}
    RETURN    type='${type}', required=${required}, validationMessage='${msg}'

Recovery Dispatch Should Be Confirmed
    [Documentation]    Asserts the store renders its generic on-page confirmation text (classic
    ...    wording: "We've sent you an email with a link to update your password."). UI EVIDENCE
    ...    ONLY: this same text renders whether or not an e-mail is actually dispatched —
    ...    automated submissions are silently swallowed by the account-form captcha, so NO e-mail
    ...    is sent on automated runs (proven 13 Aug 2026, results/MANUAL_TC-16-008_INBOX_2026-08-13/;
    ...    the e-mail half of the requirement is HUMAN-VERIFIED PASS, 13 Aug 2026, separately).
    ...    Text oracle kept loose — asserts the on-page wording only, not proof of dispatch.
    ${text}=    Get Text    body
    Should Match Regexp    ${text}    (?i)(sent you an email|email with a link|reset your password|password reset|check your (e-?)mail)
    ...    msg=No on-page confirmation text rendered for the password-recovery request
