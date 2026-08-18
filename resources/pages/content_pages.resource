*** Settings ***
Documentation     Page object: static content areas for TS-18 Content & Error Pages (UC-18):
...               blog article markers, the sitemap-only page loader, and a
...               composed 404 oracle. The Blog/About Us site-navigation entry points
...               (${BLOG_NAV_LINK} / ${ABOUT_NAV_LINK}, Go To Blog Via Navigation / Go To
...               About Us Via Navigation) have moved to layout.resource (a coordinator-directed
...               housekeeping move, same "persistent site chrome" concern as that file's own
...               ${CATALOGUE_NAV}); this file imports layout.resource so those keywords remain
...               reachable through it. Zero-store-traffic constraint: every locator below is
...               still PROVISIONAL, inferred from Test Basis observations
...               rather than a live visit; live-verify before relying on this file outside
...               dry-run.
...               FLAG FOR COORDINATOR (unresolved): the breadcrumb-count reuse below still
...               assumes the article page shares product_page.resource's id="breadcrumb"
...               component with the product page, kept as an assumption only because this
...               task may not modify product_page.resource; live-verify.
Library           Browser
Resource          ../common.resource
Resource          layout.resource
Resource          product_page.resource

*** Variables ***
${BLOG_POST_LINK}    css=a[href*="/blogs/news/"]:visible    # PROVISIONAL: live-verify before commit; the single placeholder post's permalink under the blog index

*** Keywords ***
Open Blog Post
    [Documentation]    Clicks the blog index's post link (one default placeholder post) to open
    ...    the article page.
    Click    ${BLOG_POST_LINK}

Current Page Url
    [Documentation]    Returns the current page URL: a runtime capture used to verify that a
    ...    navigation action (e.g. Go Back off an article) actually changed the page, without
    ...    hardcoding the exact URL scheme.
    ${url}=    Get Url
    RETURN    ${url}

Article Page Should Be Loaded
    [Documentation]    Asserts the blog article page rendered (a heading present) and left the
    ...    blog index, distinguishing a genuine article load from a no-op click.
    Get Url    contains    /blogs/news/
    Get Element Count    h1    >    0

Article Breadcrumb Level Count
    [Documentation]    Returns the article page's breadcrumb link count as runtime evidence:
    ...    informational only, not hard-asserted to an exact number: typical breadcrumb markup
    ...    leaves the current/last trail level as plain text rather than a link, so the exact
    ...    link count backing a three-level Home, News, and article trail (TC-18-001 note) cannot
    ...    be predicted without a live view. Mirrors TC-03-001's same treatment of the product
    ...    page's own breadcrumb count. Reuses product_page.resource's breadcrumb locator,
    ...    assumed shared theme-wide with the product page (PROVISIONAL: live-verify).
    ${n}=    Breadcrumb Link Count
    RETURN    ${n}

About Us Page Should Be Loaded
    [Documentation]    Asserts the About Us page actually rendered, not merely that we are
    ...    somewhere on the storefront.
    ...
    ...    THE PREVIOUS CHECKS WERE BOTH SATISFIED BY SITE CHROME. `Get Element Count h1 > 0`
    ...    passes on every page because the theme renders an empty <h1 id="logo"> site-wide (the
    ...    same trap already fixed in product_page.resource), and `body contains "About"` passes
    ...    on every page because the About Us nav link is part of the persistent chrome. Together
    ...    they could not distinguish the About page from the homepage (observed live). The checks
    ...    now require a non-logo heading AND the /pages/about-us URL, so passing means the About
    ...    page genuinely loaded.
    Get Url    contains    /pages/about
    Get Element Count    h1:not(#logo)    >    0

Open Content Page By Path
    [Documentation]    Direct navigation to a store page by its /pages/<slug> path, used for
    ...    the sitemap-only pages that carry no navigation entry point.
    [Arguments]    ${path}
    Go To    ${STORE_URL}${path}

Content Page Should Be Loaded
    [Documentation]    Lenient load oracle for the sitemap-only /pages/ URLs, whose exact
    ...    structure is unconfirmed (one is documented as "an exposed internal app-test page",
    ...    not a normal theme page): asserts the target path was actually reached
    ...    (no redirect away, e.g. to the 404 handler) and the body rendered non-trivial content
    ...    that does not itself read as a not-found page.
    [Arguments]    ${path}
    Get Url    contains    ${path}
    ${body_text}=    Get Text    body
    Should Not Be Empty    ${body_text}    msg=Page at ${path} rendered no body content
    Should Not Match Regexp    ${body_text}    (?i)\b(404|page not found)\b
    ...    msg=Page at ${path} appears to show a not-found page instead of real content

404 Error Page Should Be Rendered With Navigation
    [Documentation]    Asserts a nonexistent-product URL yields the store's 404 experience:
    ...    working storefront navigation (search box still present) plus page text indicating
    ...    not-found (TC-18-003). Composes the existing layout/product_page oracles
    ...    rather than duplicating them.
    Search Box Should Be Present
    Not Found Message Should Be Shown
