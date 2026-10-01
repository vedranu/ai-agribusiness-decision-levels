# Spajanje kodiranja, deduplikacija po normaliziranom naslovu, osnovne tablice
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$corpus = @{}; foreach ($r in (Import-Csv (Join-Path $root 'data\corpus.csv') -Encoding UTF8)) { $corpus[$r.id] = $r }
$cols = 'id','include','excl','levels','primary','role','domain','technique','study','actor','note'
$coded = foreach ($f in Get-ChildItem (Join-Path $root 'data\screening\coded_*.tsv') | Sort-Object Name) {
  Get-Content $f.FullName -Encoding UTF8 | Where-Object { $_.Trim() } | ForEach-Object {
    $p = $_.TrimStart([char]0xFEFF) -split "`t"
    $o = [ordered]@{}; for ($i=0; $i -lt $cols.Count; $i++) { $o[$cols[$i]] = if ($i -lt $p.Count) { $p[$i].Trim() } else { '' } }
    [pscustomobject]$o
  }
}
"Kodiranih redaka: $($coded.Count)"
$seen = @{}; $dups = 0
$merged = foreach ($c in $coded) {
  $m = $corpus[$c.id]
  $key = (($m.title).ToLower() -replace '[^a-z0-9]', '')
  $dup = 0; if ($seen.ContainsKey($key)) { $dup = 1; $dups++ } else { $seen[$key] = $c.id }
  [pscustomobject]@{ id=$c.id; year=$m.year; type=$m.type; title=$m.title; source=$m.source; countries=$m.countries; cited_by=$m.cited_by
    include=$c.include; excl=$c.excl; levels=$c.levels; primary=$c.primary; role=$c.role; domain=$c.domain; technique=$c.technique; study=$c.study; actor=$c.actor; note=$c.note; duplicate=$dup; doi=$m.doi }
}
$merged | Export-Csv (Join-Path $root 'data\coded_all.csv') -NoTypeInformation -Encoding UTF8
$fin = @($merged | Where-Object { $_.include -eq '1' -and $_.duplicate -eq 0 })
$fin | Export-Csv (Join-Path $root 'data\included_final.csv') -NoTypeInformation -Encoding UTF8
"Duplikata: $dups"
"Iskljuceno (bez duplikata):"; $merged | ? { $_.include -eq '0' -and $_.duplicate -eq 0 } | Group-Object excl | Sort-Object Name | % { "  $($_.Name) $($_.Count)" }
"Ukljuceno (bez duplikata): $($fin.Count)"
foreach ($v in 'primary','role','domain','technique','study','actor') { "--- $v"; $fin | Group-Object $v | Sort-Object Count -Descending | % { "  {0,-6} {1}" -f $_.Name, $_.Count } }
"--- razine (sve oznacene)"; foreach ($L in 'O','T','S') { "  $L  " + @($fin | ? { ($_.levels -split ';') -contains $L }).Count }
"--- vise razina: " + @($fin | ? { ($_.levels -split ';').Count -gt 1 }).Count
"--- primary x role"; foreach ($L in 'O','T','S') { $line = "  $L"; foreach ($R in 'INFO','REC','AUTO') { $line += "`t$R=" + @($fin | ? { $_.primary -eq $L -and $_.role -eq $R }).Count }; $line }
"--- primary x study"; foreach ($L in 'O','T','S') { $line = "  $L"; foreach ($R in 'EMP','CON','REV') { $line += "`t$R=" + @($fin | ? { $_.primary -eq $L -and $_.study -eq $R }).Count }; $line }
"--- godine"; $fin | Group-Object year | Sort-Object Name | % { "  $($_.Name) $($_.Count)" }
"--- neispravne vrijednosti"; $fin | ? { $_.primary -notin 'O','T','S' -or $_.role -notin 'INFO','REC','AUTO' } | % { "  $($_.id) $($_.primary) $($_.role)" }
