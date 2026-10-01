# Spajanje OpenAlex i Scopus-only kodiranja u konacni skup uključenih radova
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$oa = @(Import-Csv (Join-Path $root 'data\included_final.csv') -Encoding UTF8 | ForEach-Object { $_ | Add-Member -NotePropertyName db -NotePropertyValue 'OpenAlex' -PassThru })
$meta = @{}; Import-Csv (Join-Path $root 'data\scopus\scopus_only_meta.tsv') -Delimiter "`t" -Encoding UTF8 | ForEach-Object { $meta[$_.eid] = $_ }
$cols = 'id','include','excl','levels','primary','role','domain','technique','study','actor','note'
$sc = Get-Content (Join-Path $root 'data\scopus\coded_scopus.tsv') -Encoding UTF8 | Where-Object { $_.Trim() } | ForEach-Object {
  $p = $_.TrimStart([char]0xFEFF) -split "`t"; $o = [ordered]@{}; for ($i=0; $i -lt 11; $i++) { $o[$cols[$i]] = $p[$i].Trim() }; [pscustomobject]$o }
"Scopus-only kodiranih: $($sc.Count); ukljucenih: $(@($sc | ? include -eq '1').Count)"
"Scopus iskljucenja:"; $sc | ? include -eq '0' | Group-Object excl | Sort-Object Name | % { "  $($_.Name) $($_.Count)" }
$scInc = foreach ($c in ($sc | ? include -eq '1')) { $m = $meta[$c.id]
  [pscustomobject]@{ id=$c.id; year=$m.year; type=$m.type; title=$m.title; source=$m.source; countries=''; cited_by=$m.cited
    include='1'; excl='-'; levels=$c.levels; primary=$c.primary; role=$c.role; domain=$c.domain; technique=$c.technique; study=$c.study; actor=$c.actor; note=$c.note; duplicate=0; doi=$m.doi; db='Scopus' } }
$all = @($oa) + @($scInc)
$all | Export-Csv (Join-Path $root 'data\included_combined.csv') -NoTypeInformation -Encoding UTF8
"UKUPNO ukljuceno: $($all.Count)"
"--- primary"; $all | Group-Object primary | Sort-Object Name | % { "  $($_.Name) $($_.Count)" }
"--- primary x role"; foreach ($L in 'O','T','S') { $line = "  $L"; foreach ($R in 'INFO','REC','AUTO') { $line += "`t$R=" + @($all | ? { $_.primary -eq $L -and $_.role -eq $R }).Count }; $line }
