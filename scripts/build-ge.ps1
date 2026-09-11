$ErrorActionPreference = 'Stop'

$repositoryRoot = Get-Location
$sourceRoot = Join-Path $repositoryRoot 'EN'
$targetRoot = Join-Path $repositoryRoot 'GE'

$translations = [ordered]@{
    'Multi-storey Buildings' = 'მრავალბინიანი შენობები'
    'Individual Homes' = 'ინდივიდუალური სახლები'
    'CommercialBuildings/Public Buildings' = 'კომერციული და საზოგადოებრივი შენობები'
    'Complete structural services' = 'სრული კონსტრუქციული მომსახურება'
    'from structural design to author supervision' = 'კონსტრუქციული პროექტირებიდან საავტორო ზედამხედველობამდე'
    'Working Hours' = 'სამუშაო საათები'
    'Navigation' = 'ნავიგაცია'
    'Reconstructions' = 'რეკონსტრუქციები'
    'Reconstruction' = 'რეკონსტრუქცია'
    'Structural Design' = 'კონსტრუქციული პროექტირება'
    'Author Supervision' = 'საავტორო ზედამხედველობა'
    'Chief Engineer' = 'მთავარი ინჟინერი'
    'Senior Structural Engineer' = 'უფროსი კონსტრუქტორი ინჟინერი'
    'Junior Engineer' = 'უმცროსი ინჟინერი'
    'Contact Us' = 'დაგვიკავშირდით'
    'Contact' = 'კონტაქტი'
    'Services' = 'სერვისები'
    'Projects' = 'პროექტები'
    'Partners' = 'პარტნიორები'
    'Overview' = 'ჩვენს შესახებ'
    'About Us' = 'ჩვენს შესახებ'
    'About' = 'ჩვენს შესახებ'
    'Home' = 'მთავარი'
    'Team' = 'გუნდი'
    'Founder' = 'დამფუძნებელი'
    'Partner' = 'პარტნიორი'
    'Location' = 'მდებარეობა'
    'Address' = 'მისამართი'
    'Phone' = 'ტელეფონი'
    'Email' = 'ელფოსტა'
    'Monday' = 'ორშაბათი'
    'Tuesday' = 'სამშაბათი'
    'Wednesday' = 'ოთხშაბათი'
    'Thursday' = 'ხუთშაბათი'
    'Friday' = 'პარასკევი'
    'Saturday' = 'შაბათი'
    'Sunday' = 'კვირა'
    'Closed' = 'დახურულია'
}

if (Test-Path $targetRoot) {
    Remove-Item -Path $targetRoot -Recurse -Force
}
Copy-Item -Path $sourceRoot -Destination $targetRoot -Recurse

Get-ChildItem -Path $targetRoot -Filter '*.html' -Recurse | ForEach-Object {
    $file = $_
    $html = Get-Content -Path $file.FullName -Raw
    $html = $html -replace '<html lang="en">', '<html lang="ka">'

    foreach ($entry in $translations.GetEnumerator()) {
        $html = $html.Replace($entry.Key, $entry.Value)
    }

    $relativePath = $file.FullName.Substring($targetRoot.Length).TrimStart('\', '/') -replace '\\', '/'
    $englishUrl = ('../../EN/' + $relativePath)
    $depth = ($relativePath -split '/').Count - 1
    if ($depth -eq 0) {
        $englishUrl = '../EN/' + $relativePath
    } elseif ($depth -eq 1) {
        $englishUrl = '../../EN/' + $relativePath
    } else {
        $englishUrl = ('../' * ($depth + 1)) + 'EN/' + $relativePath
    }

    $html = $html -replace '<button class="lang-btn" id="lang-btn">GE</button>', '<button class="lang-btn" id="lang-btn" type="button">EN</button>'
    $html = $html -replace "langBtn\.addEventListener\('click', \(\) => \{\s*langBtn\.textContent = langBtn\.textContent === 'GE' \? 'EN' : 'GE'\s*\}\)", "langBtn.addEventListener('click', () => { window.location.href = '$englishUrl' })"

    Set-Content -Path $file.FullName -Value $html -Encoding utf8
}

Write-Host "Created Georgian mirror: $((Get-ChildItem -Path $targetRoot -Recurse -Filter '*.html').Count) HTML pages."