*** Settings ***
Documentation     Page object: product detail page (PDP) — title, price, add-to-cart control,
...               variant selectors, breadcrumb trail and description. Every PDP locator
...               lives ONLY here. Theme facts encoded: the add control is an
...               <input type=submit> OR a <button> (union locator); the breadcrumb sits in
...               an id-only div; variant selects are linked (the second dimension is
...               constrained by availability at the chosen first option).
Library           Browser
Resource          ../common.resource

*** Variables ***
${ADD_TO_CART_ANY}       xpath=//button[normalize-space()='Add to Cart'] | //input[@type='submit' and @value='Add to Cart']
${ACTIVE_ADD_TO_CART}    xpath=//button[normalize-space()='Add to Cart' and not(@disabled)] | //input[@type='submit' and @value='Add to Cart' and not(@disabled)]
${VARIANT_SELECT}        css=form[action*="/cart/add"] select
${BREADCRUMB_LINKS}      css=div[id="breadcrumb"] a
${DESCRIPTION_BLOCKS}    css=.product-description, #product-description, .description, .rte
${FIRST_PRICE_TEXT}      xpath=(//*[contains(text(),'£')])[1]

*** Keywords ***
Open Product
    [Documentation]    Direct navigation to a product by handle; the landing URL is verified.
    [Arguments]    ${handle}
    Go To    ${STORE_URL}products/${handle}
    Get Url    contains    /products/${handle}

Open Nonexistent Product Page
    [Arguments]    ${handle}=no-such-product-tdc-check
    Go To    ${STORE_URL}products/${handle}

Product Page Should Be Complete
    Get Element Count    h1    >    0
    Get Text    body    contains    £

Product Price Should Be Displayed
    Get Text    body    contains    £

Product Title
    ${name}=    Get Text    h1
    RETURN    ${name}

Product Name Should Be Displayed
    [Arguments]    ${name}
    Get Text    body    contains    ${name}

Visible Price Text
    [Documentation]    Runtime-captured oracle: returns the first visible price text so a
    ...    later page (for example the cart) can be asserted against it.
    ${price}=    Get Text    ${FIRST_PRICE_TEXT}
    RETURN    ${price}

Add To Cart Control Should Be Present
    Get Element Count    ${ADD_TO_CART_ANY}    >    0

Active Add To Cart Should Be Present
    Get Element Count    ${ACTIVE_ADD_TO_CART}    >    0

Add Current Product To Cart
    Click    ${ACTIVE_ADD_TO_CART}

Sold Out State Should Be Indicated
    [Documentation]    A sold-out product must show a Sold Out indicator or offer no active
    ...    add-to-cart control (union oracle).
    ${sold_out_shown}=    Run Keyword And Return Status    Get Text    body    contains    Sold Out
    ${active_add}=    Get Element Count    ${ACTIVE_ADD_TO_CART}
    Should Be True    ${sold_out_shown} or ${active_add} == 0
    ...    msg=Neither a Sold Out indicator nor a blocked add-to-cart control found on a sold-out product

Not Found Message Should Be Shown
    ${page_text}=    Get Text    body
    Should Match Regexp    ${page_text}    (?i)(404|not found|does not exist|no longer available)
    ...    msg=No explicit not-found message shown for a nonexistent product page

Variant Dimension Count
    ${n}=    Get Element Count    ${VARIANT_SELECT}
    RETURN    ${n}

Variant Option Count
    [Arguments]    ${dimension}
    ${n}=    Get Property    ${VARIANT_SELECT} >> nth=${dimension}    length
    RETURN    ${n}

Selected Variant Label
    [Arguments]    ${dimension}
    ${label}=    Get Selected Options    ${VARIANT_SELECT} >> nth=${dimension}    label
    RETURN    ${label}

Select Variant Option
    [Arguments]    ${dimension}    ${index}
    Select Options By    ${VARIANT_SELECT} >> nth=${dimension}    index    ${index}

All Variant Dimensions Should Have Defaults
    [Documentation]    Verifies the theme's safeguard: every variant dimension loads with a
    ...    default option preselected, so an unselected add is unreachable by design.
    ${n}=    Get Element Count    ${VARIANT_SELECT}
    Should Be True    ${n} >= 1    msg=No variant selectors found on the variant product page
    FOR    ${i}    IN RANGE    ${n}
        ${value}=    Get Selected Options    ${VARIANT_SELECT} >> nth=${i}    value
        Should Not Be Empty    ${value}    msg=Variant dimension ${i} loaded without a preselected default
    END

Breadcrumb Link Count
    ${n}=    Get Element Count    ${BREADCRUMB_LINKS}
    RETURN    ${n}

Description Block Count
    ${n}=    Get Element Count    ${DESCRIPTION_BLOCKS}
    RETURN    ${n}
