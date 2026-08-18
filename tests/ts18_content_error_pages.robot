*** Settings ***
Documentation     TS-18 Content & Error Pages: executable mirror of TCS cases TC-18-001..003.
...               Authorities: the team's Test Case Specification and Test Basis, UC-18. All 3
...               cases automated (new
...               suite; no skips).
...               New resource: resources/pages/content_pages.resource, blog article and
...               sitemap-only/404 markers. Its locators are PROVISIONAL (inferred from Test
...               Basis observations, not a live visit under this task's zero-store-traffic
...               constraint); live-verify before relying on it outside dry-run. The Blog/About
...               Us site-navigation entry points (Go To Blog Via Navigation / Go To About Us
...               Via Navigation) live in resources/pages/layout.resource, coordinator-directed
...               housekeeping move, same "persistent site chrome" concern as that file's own
...               ${CATALOGUE_NAV}, and reach this suite via the direct layout.resource import
...               below (also imported transitively via content_pages.resource). FLAG FOR
...               COORDINATOR (unresolved): the article breadcrumb count reuses
...               product_page.resource's breadcrumb locator on the assumption it is a shared
...               theme-wide component, kept as an assumption only because this task may not
...               modify product_page.resource.
...               TC-18-001 note: blog articles carry a three-level breadcrumb Home - News -
...               article (distinct from the product page's two-level Home - product trail);
...               the link count is logged as observation evidence, not hard-asserted to an
...               exact number, mirroring TC-03-001's own treatment of the analogous
...               uncertain-count situation. TC-18-002's three pages are sitemap-only and
...               unlinked from navigation by design (per the Test Basis); that status is
...               logged as an observation per case, not probed for or asserted.
...               Page Object Model: element locators live in resources/pages/; this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~10 page loads per run (~6 for TC-18-001, 3 for TC-18-002, 1 for
...               TC-18-003); run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/content_pages.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-18    UC-18    guest

*** Test Cases ***
TC-18-001 Content Pages Load And Navigate
    [Documentation]    Store accessible. Steps: 1. Open Blog from the menu; open the post.
    ...    2. Open About Us. 3. Verify page load, breadcrumbs, and navigation back. Expected:
    ...    both content areas load and navigate correctly; placeholder content is recorded as
    ...    an observation, not asserted as a defect (the Blog carries one default placeholder
    ...    post). Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-18-001
    Open Home
    Go To Blog Via Navigation
    Open Blog Post
    Article Page Should Be Loaded
    ${article_url}=    Current Page Url
    ${bc}=    Article Breadcrumb Level Count
    Log    Blog article breadcrumb link count: ${bc} (expected trail: Home - News - article; observation evidence, not hard-asserted to an exact number). Placeholder-content quality, if any, is likewise logged as an observation, not asserted as a defect.
    Go Back
    ${after_back_url}=    Current Page Url
    Should Not Be Equal    ${after_back_url}    ${article_url}
    ...    msg=Navigating back from the blog article did not change the page URL
    Open Home
    Go To About Us Via Navigation
    About Us Page Should Be Loaded
    Log    About Us page loaded; placeholder-content quality, if any, is logged as an observation, not asserted as a defect.

TC-18-002 Sitemap-Only Pages Load
    [Documentation]    Store accessible. Steps: 1. Open /pages/terms, /pages/login-prompt, and
    ...    /pages/share-review directly. 2. Verify each loads. 3. Record their linkage status
    ...    (unlinked from navigation) and content findings. Expected: all three pages load;
    ...    their unreachability from navigation and content-governance findings are recorded as
    ...    observations (per the Test Basis: full Terms of Service unlinked from any
    ...    navigation; an exposed internal app-test page whose self-stated 3-second prompt does
    ...    not fire; a feedback headline with no form). Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-18-002
    FOR    ${path}    IN    pages/terms    pages/login-prompt    pages/share-review
        Open Content Page By Path    ${path}
        Content Page Should Be Loaded    ${path}
        Log    Page "${path}" loaded — sitemap-only, unlinked from site navigation (content-governance observation; recorded here, not asserted as a defect).
    END

TC-18-003 Invalid URL Returns 404 Page
    [Documentation]    Store accessible. Steps: 1. Navigate to a nonexistent address (e.g.
    ...    /products/does-not-exist). 2. Verify the response and page. Expected: an HTTP 404
    ...    with the store's error page and working navigation (verified live). Priority
    ...    Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-18-003
    Open Nonexistent Product Page    does-not-exist
    404 Error Page Should Be Rendered With Navigation
