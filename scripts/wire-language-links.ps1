$ErrorActionPreference = 'Stop'

$root = Get-Location
$englishRoot = Join-Path $root 'EN'
$georgianRoot = Join-Path $root 'GE'

function Set-DesktopLangButton {
    param([string]$Html, [string]$Label)
    return $Html -replace '(<button class="lang-btn" id="lang-btn"[^>]*>).*?(</button>)', "`$1$Label`$2"
}

function Set-MobileLangLink {
    param([string]$Html, [string]$RelPath, [string]$OtherLangFolder, [string]$Label)

    $depth = ($RelPath -split '/').Count - 1
    if ($depth -eq 0) {
        $target = "../$OtherLangFolder/$RelPath"
    } else {
        $target = "../../$OtherLangFolder/$RelPath"
    }
    $anchor = '<a href="' + $target + '" class="mobile-link">' + $Label + '</a>'

    # Legacy button-based switch -> plain link matching other mobile-menu items
    $legacyPattern = '<div class="mobile-nav-group mobile-lang-switch">\s*<button class="mobile-link mobile-lang-btn" id="mobile-lang-btn" type="button">[A-Za-z]+</button>\s*</div>'
    $Html = [regex]::Replace($Html, $legacyPattern, [System.Text.RegularExpressions.Regex]::Escape($anchor).Replace('\', ''), 'Singleline')

    # Already a plain link -> normalize target/label (also matches manually-edited variants)
    $linkPattern = '<a\s+href="[^"]*"\s+class="mobile-link"\s*(?:type="button")?\s*>\s*[A-Za-z]+\s*</a>\s*(?=\s*</div>\s*</header>)'
    if ($Html -match $linkPattern) {
        $Html = [regex]::Replace($Html, $linkPattern, [System.Text.RegularExpressions.Regex]::Escape($anchor).Replace('\', ''), 'Singleline')
    } elseif ($Html -notmatch [regex]::Escape($anchor)) {
        # Neither pattern found -> insert before closing of mobile-menu/header
        $insertPattern = '(?s)(<div class="mobile-menu"[^>]*>.*?)(\r?\n\s*</div>\s*</header>)'
        $Html = [regex]::Replace($Html, $insertPattern, "`$1`n      $anchor`$2")
    }

    return $Html
}

function Set-LanguageScript {
    param([string]$Html, [string]$DataAttr, [string]$FromFolder, [string]$ToFolder)

    $destination = "document.querySelectorAll('#lang-btn').forEach((button) => { button.addEventListener('click', () => { window.location.href = window.location.href.replace('/$FromFolder/', '/$ToFolder/') }) })"
    $Html = $Html -replace "(?s)<script data-language-link=`"$DataAttr`">.*?</script>", "<script data-language-link=`"$DataAttr`">$destination</script>"
    if ($Html -notmatch "data-language-link=`"$DataAttr`"") {
        $Html = $Html.Replace('</body>', "<script data-language-link=`"$DataAttr`">$destination</script>`n</body>")
    }
    return $Html
}

Get-ChildItem -Path $englishRoot -Filter '*.html' -Recurse | ForEach-Object {
    $relPath = $_.FullName.Substring($englishRoot.ToString().Length + 1) -replace '\\', '/'
    $html = Get-Content -Path $_.FullName -Raw -Encoding utf8
    $html = Set-DesktopLangButton -Html $html -Label 'GE'
    $html = Set-MobileLangLink -Html $html -RelPath $relPath -OtherLangFolder 'GE' -Label 'GE'
    $html = Set-LanguageScript -Html $html -DataAttr 'ge' -FromFolder 'EN' -ToFolder 'GE'
    Set-Content -Path $_.FullName -Value $html -Encoding utf8
}

Get-ChildItem -Path $georgianRoot -Filter '*.html' -Recurse | ForEach-Object {
    $relPath = $_.FullName.Substring($georgianRoot.ToString().Length + 1) -replace '\\', '/'
    $html = Get-Content -Path $_.FullName -Raw -Encoding utf8
    $html = Set-DesktopLangButton -Html $html -Label 'EN'
    $html = Set-MobileLangLink -Html $html -RelPath $relPath -OtherLangFolder 'EN' -Label 'EN'
    $html = Set-LanguageScript -Html $html -DataAttr 'en' -FromFolder 'GE' -ToFolder 'EN'
    Set-Content -Path $_.FullName -Value $html -Encoding utf8
}

Write-Host "Updated two-way language links for English and Georgian HTML pages."