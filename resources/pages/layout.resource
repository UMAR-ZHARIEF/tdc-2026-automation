*** Settings ***
Documentation     Page object: persistent site chrome present on every storefront page:
...               the header (cart badge, search box, mini-cart drawer) and sidebar navigation.
...               Locators for these shared elements live ONLY here. The mini-cart drawer is a
...               plain top-level container (id="drawer", no distinguishing class; it is NOT
...               selectable via a ".drawer" class); its open/closed state and contents are
...               detected instead via its visible form[action="/cart"] content, which is
...               present (hidden when closed) on every page once the cart holds an item.
...               Also holds the Blog and About Us site-navigation entry points (TS-18 Content
...               & Error Pages), relocated here from content_pages.resource
...               (coordinator-directed housekeeping move: same "persistent site chrome"
...               concern as ${CATALOGUE_NAV} below). Unlike the rest of this file's
...               already-live locators, ${BLOG_NAV_LINK} and ${ABOUT_NAV_LINK} are PROVISIONAL:
...               live-verify before relying on them outside dry-run.
...               Also holds the Wish list, Refer a Friend, and social-links chrome for TS-14
...               Secondary & Support Services, coordinator-granted addition.
...               The Wish list and Refer a Friend controls are documented inert remnants of the
...               defunct Sauce app (click-verified live: no response); ${WISHLIST_LINK},
...               ${REFER_FRIEND_LINK} and ${SOCIAL_LINKS} are PROVISIONAL: live-verify before
...               relying on them outside dry-run. Oracle/sweep logic built on these locators
...               lives in resources/pages/secondary_services.resource, not here.
Library           Browser

*** Variables ***
${SEARCH_BOX}             css=input[name="q"]:visible
${CATALOGUE_NAV}          css=a[href*="/collections/"]:visible
${BLOG_NAV_LINK}          xpath=//a[contains(normalize-space(),'Blog') or contains(normalize-space(),'News')]    # PROVISIONAL: live-verify before commit; nav label unconfirmed (URL family /blogs/news)
${ABOUT_NAV_LINK}         xpath=//a[contains(normalize-space(),'About')]    # PROVISIONAL: live-verify before commit
${WISHLIST_LINK}          xpath=//a[contains(normalize-space(),'Wish list') or contains(normalize-space(),'Wish List') or contains(normalize-space(),'Wishlist')]    # PROVISIONAL: live-verify before commit; documented inert Sauce-app remnant
${REFER_FRIEND_LINK}      xpath=//a[contains(normalize-space(),'Refer a friend') or contains(normalize-space(),'Refer a Friend')]    # PROVISIONAL: live-verify before commit; documented inert Sauce-app remnant
${SOCIAL_LINKS}           css=a[href*="facebook.com"]:visible, a[href*="twitter.com"]:visible, a[href*="instagram.com"]:visible, a[href*="pinterest.com"]:visible    # PROVISIONAL: live-verify before commit; recorded targets (facebook.com/shopify, twitter.com/sauce_io [defunct], instagram.com/shopify, a personal Pinterest board)
${DRAWER_TOGGLE}          css=a.toggle-drawer.cart.desktop
${DRAWER_FORM_VISIBLE}    css=form[action="/cart"]:visible
${DRAWER_PRODUCT_LINK}    css=form[action="/cart"] a[href*="/products/"]:visible
${DRAWER_QTY_INPUT}       css=form[action="/cart"] input[name^="updates"]:visible
${DRAWER_REMOVE_LINK}     css=form[action="/cart"] a.removeLine:visible
${DRAWER_CHECKOUT}        css=form[action="/cart"] input[type="submit"]:visible

*** Keywords ***
Cart Badge Should Show
    [Documentation]    Asserts the header cart badge reads "My Cart (<count>)".
    [Arguments]    ${count}
    Get Text    body    contains    My Cart (${count})

Current Cart Badge Count
    [Documentation]    Returns the header cart badge's current count as an integer. Use this when
    ...    a case needs to compare the cart against its OWN starting state rather than an absolute
    ...    number; suites chain cases against a shared cart, so a hard-coded expectation like
    ...    "1" silently depends on which cases ran first (TC-15-004 failed this way:
    ...    an earlier case had left one item, so the badge read 2, not 1).
    ${text}=    Get Text    body
    ${count}=    Evaluate    int(re.search(r'My Cart \\((\\d+)\\)', $text).group(1))    modules=re
    RETURN    ${count}

Cart Indicator Should Be Present
    Get Text    body    contains    My Cart (

Search Box Should Be Present
    Get Element Count    ${SEARCH_BOX}    >    0

Catalogue Navigation Should Be Present
    Get Element Count    ${CATALOGUE_NAV}    >    0

Search For
    [Documentation]    Types the term into the header search box and submits with Enter.
    [Arguments]    ${term}
    Fill Text    ${SEARCH_BOX}    ${term}
    Keyboard Key    press    Enter

Go To Catalogue Via Navigation
    Click    ${CATALOGUE_NAV}

Go To Blog Via Navigation
    [Documentation]    Clicks the site navigation's Blog entry point.
    Click    ${BLOG_NAV_LINK}

Go To About Us Via Navigation
    [Documentation]    Clicks the site navigation's About Us entry point.
    Click    ${ABOUT_NAV_LINK}

Activate Wish List Control
    [Documentation]    Clicks the Wish list menu control (documented inert Sauce-app remnant;
    ...    click-verified live to produce no response).
    Click    ${WISHLIST_LINK}

Activate Refer A Friend Control
    [Documentation]    Clicks the Refer a Friend control (documented inert Sauce-app remnant;
    ...    click-verified live to produce no response).
    Click    ${REFER_FRIEND_LINK}

Social Link Count
    [Documentation]    Returns the number of social-icon/link elements found in the storefront
    ...    chrome.
    ${n}=    Get Element Count    ${SOCIAL_LINKS}
    RETURN    ${n}

Social Link Target At Index
    [Documentation]    Returns the href of the social link at the given zero-based index,
    ...    never clicked/navigated to (competition Don't #3: external sites are out of scope).
    [Arguments]    ${index}
    ${href}=    Get Attribute    ${SOCIAL_LINKS} >> nth=${index}    href
    RETURN    ${href}

Open Mini Cart Drawer
    [Documentation]    Clicks the header's "My Cart" toggle to open the mini-cart drawer.
    Click    ${DRAWER_TOGGLE}

Close Mini Cart Drawer
    [Documentation]    Clicks the same toggle again to close the drawer.
    Click    ${DRAWER_TOGGLE}

Mini Cart Drawer Should Be Visible
    Get Element Count    ${DRAWER_FORM_VISIBLE}    >    0

Mini Cart Drawer Should Be Hidden
    Get Element Count    ${DRAWER_FORM_VISIBLE}    ==    0

Mini Cart Drawer Should Contain Product Link
    Get Element Count    ${DRAWER_PRODUCT_LINK}    >    0

Mini Cart Drawer Should Contain Quantity Input
    Get Element Count    ${DRAWER_QTY_INPUT}    >    0

Mini Cart Drawer Should Contain Remove Link
    Get Element Count    ${DRAWER_REMOVE_LINK}    >    0

Mini Cart Drawer Should Contain Checkout Control
    Get Element Count    ${DRAWER_CHECKOUT}    >    0

Mini Cart Drawer Line Title Text
    [Documentation]    Returns the drawer's product-link text: runtime evidence capture for the
    ...    known display defect (the title renders triplicated in the drawer).
    ...    Callers should assert "contains", not equality, against the product name.
    ${text}=    Get Text    ${DRAWER_PRODUCT_LINK}
    RETURN    ${text}
