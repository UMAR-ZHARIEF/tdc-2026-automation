*** Settings ***
Documentation     Component object: the product listing grid, as rendered on the homepage
...               (featured products), the catalogue and the search results. The visible
...               product-link locator lives ONLY here. The store renders hidden duplicate
...               product links, so all interaction filters to :visible (an earlier finding from
...               the retired prototype smoke suite; holds store-wide).
Library           Browser

*** Variables ***
${VISIBLE_PRODUCT_LINK}    css=a[href*="/products/"]:visible

*** Keywords ***
Products Should Be Listed
    Get Element Count    ${VISIBLE_PRODUCT_LINK}    >    0

No Products Should Be Listed
    ${hits}=    Get Element Count    ${VISIBLE_PRODUCT_LINK}
    Should Be Equal As Integers    ${hits}    0
    ...    msg=Product links were listed where none were expected

Listed Product Count
    ${n}=    Get Element Count    ${VISIBLE_PRODUCT_LINK}
    RETURN    ${n}

Listed Prices Should Be Shown
    Get Text    body    contains    £

Open First Listed Product
    [Documentation]    Captures the first visible product link at run time, extracts its
    ...    handle, clicks it and verifies the landing URL. Catalogue hrefs are
    ...    collection-scoped but the store lands on the canonical /products/<handle>
    ...    (automation finding AF-02), so only the handle tail is asserted.
    ${target}=    Get Attribute    ${VISIBLE_PRODUCT_LINK}    href
    ${handle}=    Evaluate    """${target}""".split('/products/')[-1]
    Click    ${VISIBLE_PRODUCT_LINK}
    Get Url    contains    /products/${handle}
