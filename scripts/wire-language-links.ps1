$ErrorActionPreference = 'Stop'

$englishRoot = Join-Path (Get-Location) 'EN'
$georgianRoot = Join-Path (Get-Location) 'GE'
$languageButton = '<button class="lang-btn" id="lang-btn">GE</button>'
$togglePattern = "langBtn\.addEventListener\('click', \(\) => \{\s*langBtn\.textContent = langBtn\.textContent === 'GE' \? 'EN' : 'GE'\s*\}\)"
$destination = "langBtn.addEventListener('click', () => { window.location.href = window.location.href.replace('/EN/', '/GE/') })"

Get-ChildItem -Path $englishRoot -Filter '*.html' -Recurse | ForEach-Object {
    $html = Get-Content -Path $_.FullName -Raw -Encoding utf8
    $html = $html.Replace($languageButton, '<button class="lang-btn" id="lang-btn" type="button">GE</button>')
    $html = $html -replace $togglePattern, $destination
    if ($html -notmatch 'data-language-link="ge"') {
        $html = $html.Replace('</body>', "<script data-language-link=`"ge`">document.getElementById('lang-btn').addEventListener('click', () => { window.location.href = window.location.href.replace('/EN/', '/GE/') })</script>`n</body>")
    }
    Set-Content -Path $_.FullName -Value $html -Encoding utf8
}

Get-ChildItem -Path $georgianRoot -Filter '*.html' -Recurse | ForEach-Object {
    $html = Get-Content -Path $_.FullName -Raw -Encoding utf8
    if ($html -notmatch 'data-language-link="en"') {
        $html = $html.Replace('</body>', "<script data-language-link=`"en`">document.getElementById('lang-btn').addEventListener('click', () => { window.location.href = window.location.href.replace('/GE/', '/EN/') })</script>`n</body>")
    }
    Set-Content -Path $_.FullName -Value $html -Encoding utf8
}

Write-Host "Updated two-way language links for 87 English and 87 Georgian HTML pages."