# Paced live-verification campaign: ts09 -> ts18, one suite per sitting, 30-minute gaps.
# Aborts the WHOLE campaign on the first bot-protection signature (standing rule:
# first response to any challenge is full stand-down, never window-probing).
# Zero orders: ALLOW_ORDERS stays at its default False, so every order-creating
# case is skipped by its first-line Skip If.
# NOTE: this file is deliberately pure ASCII. A non-ASCII character in a BOM-less
# script is misread by Windows PowerShell 5.1 (ANSI) and breaks parsing.

$ErrorActionPreference = 'Continue'
$env:PYTHONIOENCODING = 'utf-8'

$repo    = 'c:\Users\Guess\Documents\Projects\TDC\automation'
$outRoot = Join-Path $repo 'results\headed_verify_2026-08-12'
$status  = Join-Path $outRoot '_campaign_status.md'
$gapSec  = 0
# Start immediately on user instruction (12 Aug). Inter-suite gaps are retained.
$initialDelaySec = 0

# Execution order from the ratified schedule (ts15 before ts14 deliberately:
# ts14 is the expected-failure defect harvest and is scheduled late).
$suites = @(
  'ts09_checkout_validation',
  'ts10_shipping_selection',
  'ts11_discount',
  'ts12_payment',
  'ts13_order_confirmation',
  'ts15_guest_purchase',
  'ts14_secondary_services',
  'ts16_authentication',
  'ts17_search',
  'ts18_content_error_pages'
)

# Guard detection lives in guard_check.py -- see that file for why a plain
# substring search over output.xml is wrong.

New-Item -ItemType Directory -Force -Path $outRoot | Out-Null

$header = @(
  ('# Live-verification campaign - started ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
  '',
  '| Suite | Started | Pass | Fail | Skip | Verdict |',
  '|-------|---------|------|------|------|---------|'
)
Set-Content -Path $status -Value $header -Encoding utf8

Set-Location $repo
$aborted = $false

Start-Sleep -Seconds $initialDelaySec

for ($i = 0; $i -lt $suites.Count; $i++) {
    $suite = $suites[$i]
    $dir   = Join-Path $outRoot $suite
    $start = Get-Date

    & py -m robot --outputdir $dir ('tests\' + $suite + '.robot') 2>&1 |
        Out-File (Join-Path $outRoot ($suite + '.console.txt')) -Encoding utf8

    $xml     = Join-Path $dir 'output.xml'
    $pass    = 0
    $fail    = 0
    $skip    = 0
    $verdict = 'NO OUTPUT'

    if (Test-Path $xml) {
        $raw = Get-Content $xml -Raw

        # Guard check first: a challenged run's numbers are meaningless.
        # Delegated to guard_check.py, which distinguishes a real engagement
        # from the retry-poll artifacts that produced a false abort on 12 Aug.
        $guardOut = & py (Join-Path $repo 'guard_check.py') $xml 2>&1
        $guardCode = $LASTEXITCODE
        Add-Content -Path $status -Value ('<!-- ' + $suite + ': ' + ($guardOut -join ' ') + ' -->')

        [xml]$doc = $raw
        $stats = $doc.robot.statistics.total.stat | Select-Object -Last 1
        $pass  = [int]$stats.pass
        $fail  = [int]$stats.fail
        if ($stats.skip) { $skip = [int]$stats.skip } else { $skip = 0 }

        if ($guardCode -eq 2) {
            $hit = ($guardOut -join ' ')
            $verdict = "ABORT - " + $hit
            $row = '| ' + $suite + ' | ' + $start.ToString('HH:mm') + ' | ' + $pass + ' | ' + $fail + ' | ' + $skip + ' | ' + $verdict + ' |'
            Add-Content -Path $status -Value $row
            Add-Content -Path $status -Value ''
            Add-Content -Path $status -Value ('**CAMPAIGN ABORTED** at ' + $suite + ' - store guard engaged. No further suites run. Results from this suite are NOT valid evidence.')
            $aborted = $true
            break
        }

        if ($fail -eq 0) { $verdict = 'GREEN' } else { $verdict = ([string]$fail + ' failed - needs triage') }
    }

    $row = '| ' + $suite + ' | ' + $start.ToString('HH:mm') + ' | ' + $pass + ' | ' + $fail + ' | ' + $skip + ' | ' + $verdict + ' |'
    Add-Content -Path $status -Value $row

    if ($i -lt ($suites.Count - 1)) {
        Start-Sleep -Seconds $gapSec
    }
}

if (-not $aborted) {
    Add-Content -Path $status -Value ''
    Add-Content -Path $status -Value ('**Campaign complete** ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' - all ' + $suites.Count + ' suites attempted.')
}
