# Izgradnja korpusa iz sirovih OpenAlex JSON stranica -> data\corpus_ext_all.csv
# Koristi JavaScriptSerializer (razlikuje velika/mala slova u kljucevima, npr. "The"/"the" u abstract_inverted_index)
Add-Type -AssemblyName System.Web.Extensions
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$js.MaxJsonLength = [int]::MaxValue
$decRx = '\b(decision|decisions|decision-making|management|managerial|strategic|strategy|planning)\b'
$rows = New-Object System.Collections.Generic.List[object]
$seen = @{}
foreach ($file in Get-ChildItem (Join-Path $root 'data\raw_ext\page_*.json') | Sort-Object Name) {
  $o = $js.DeserializeObject([IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8))
  foreach ($w in $o['results']) {
    $id = ($w['id'] -replace 'https://openalex.org/', '')
    if ($seen.ContainsKey($id)) { continue }; $seen[$id] = 1
    $abs = ''
    $inv = $w['abstract_inverted_index']
    if ($inv) {
      $pos = @{}
      foreach ($k in $inv.Keys) { foreach ($i in $inv[$k]) { $pos[[int]$i] = $k } }
      $abs = ($pos.Keys | Sort-Object | ForEach-Object { $pos[$_] }) -join ' '
    }
    $src = ''; $srcType = ''
    if ($w['primary_location'] -and $w['primary_location']['source']) { $src = $w['primary_location']['source']['display_name']; $srcType = $w['primary_location']['source']['type'] }
    $countries = @(); $firstAuth = ''
    $n = 0
    foreach ($a in $w['authorships']) {
      $n++
      if ($n -eq 1 -and $a['author']) { $firstAuth = $a['author']['display_name'] }
      foreach ($c in $a['countries']) { if ($countries -notcontains $c) { $countries += $c } }
    }
    $kw = @($w['keywords'] | ForEach-Object { $_['display_name'] }) -join '; '
    $pt = ''; $field = ''; $domain = ''
    if ($w['primary_topic']) { $pt = $w['primary_topic']['display_name']; $field = $w['primary_topic']['field']['display_name']; $domain = $w['primary_topic']['domain']['display_name'] }
    $title = [string]$w['title']
    $dec = [int]([regex]::IsMatch("$title $abs", $decRx, 'IgnoreCase'))
    $rows.Add([pscustomobject]@{
      id=$id; doi=($w['doi'] -replace 'https://doi.org/', ''); year=$w['publication_year']; type=$w['type']
      title=$title; source=$src; source_type=$srcType; first_author=$firstAuth; n_authors=$n
      countries=($countries -join ';'); cited_by=$w['cited_by_count']; primary_topic=$pt; field=$field; domain=$domain
      keywords=$kw; has_abstract=[int]($abs.Length -gt 0); decision_terms=$dec; abstract=$abs })
  }
}
$rows | Export-Csv (Join-Path $root 'data\corpus_ext_all.csv') -NoTypeInformation -Encoding UTF8
"Zapisa: $($rows.Count); s sazetkom: $(($rows | ? has_abstract -eq 1).Count); s pojmovima odlucivanja: $(($rows | ? decision_terms -eq 1).Count)"

