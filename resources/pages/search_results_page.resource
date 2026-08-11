*** Settings ***
Documentation     Page object: search results (/search). Result-grid interaction is provided
...               by the product_listing component; the search box itself belongs to layout.
...               Also holds the TS-17 Search System oracles (UC-17, TB-SRCH-001..004): result
...               -title capture for relevance checking, the empty-query graceful state, and the
...               zero-results state. Merged in from the former resources/pages/
...               search_results.resource (coordinator-directed housekeeping merge; that file
...               is now orphaned and left in place untouched for later recycling).
Library           Browser
Library           Collections
Resource          ../common.resource
Resource          product_listing.resource

*** Keywords ***
Open Search Results For
    [Arguments]    ${term}
    Go To    ${STORE_URL}search?q=${term}

Should Be On Search Results
    Get Url    contains    /search

Search Result Titles
    [Documentation]    Returns a list of the visible result-grid product link texts (runtime
    ...    capture, store content is volatile), for relevance assertions against the search
    ...    query (TB-SRCH-001/002). Reuses product_listing's visible-product-link locator and
    ...    element count rather than redefining them.
    ${count}=    Listed Product Count
    @{titles}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        ${text}=    Get Text    ${VISIBLE_PRODUCT_LINK} >> nth=${i}
        Append To List    ${titles}    ${text}
    END
    RETURN    ${titles}

All Result Titles Should Relate To Query
    [Documentation]    TRUE relevance oracle (TB-SRCH-001/002): every visible result title must
    ...    relate to the given query term. Each title is logged as evidence; per 02 v2.1
    ...    §FRESH CASES (6 results observed for "jacket" on 5 Aug 2026, of which 4 were
    ...    unrelated — placeholder-description matching), a live FAIL here is the intended,
    ...    harvested search-relevance defect evidence, not test breakage.
    [Arguments]    ${query}
    @{titles}=    Search Result Titles
    @{unrelated}=    Create List
    FOR    ${title}    IN    @{titles}
        ${related}=    Run Keyword And Return Status    Should Contain    ${title}    ${query}    ignore_case=True
        IF    not ${related}
            Append To List    ${unrelated}    ${title}
        END
        Log    Result title "${title}" relates to query "${query}": ${related}
    END
    Log    Search relevance check for "${query}" — unrelated result title(s): ${unrelated} (non-empty is the harvested TB-SRCH-002 defect evidence).
    Should Be Empty    ${unrelated}
    ...    msg=Search-relevance defect (TB-SRCH-002, known-defect-lead): result title(s) unrelated to "${query}": ${unrelated}

No Search Performed Message Should Be Shown
    [Documentation]    Asserts the empty-query results page shows the graceful "No search
    ...    performed" state rather than an error or blank page (TB-SRCH-003; TC-17-002; verified
    ...    5 Aug 2026 per 02 v2.1 §FRESH CASES).
    ${page_text}=    Get Text    body
    Should Match Regexp    ${page_text}    (?i)no search performed
    ...    msg=Expected a graceful "No search performed" message for an empty search query

Zero Results Message Should Be Shown
    [Documentation]    Asserts a nonsense query yields the functional zero-results state
    ...    (TB-SRCH-004; TC-17-003). The recovered expectation is that the store tells the
    ...    customer plainly that nothing matched — the exact wording is the store's choice.
    ...    LIVE RUN 12 Aug 2026 established the actual wording: "No results found for zzzqxv".
    ...    The earlier pattern demanded a literal "0 results found", which the store has never
    ...    used, so a correct zero-results page was reported as a failure. The oracle now
    ...    accepts either phrasing of the same message.
    ${page_text}=    Get Text    body
    Should Match Regexp    ${page_text}    (?i)(0|no)\\s+results?\\s+found
    ...    msg=Expected a zero-results message ("no results found" or "0 results found") for a no-match search query
