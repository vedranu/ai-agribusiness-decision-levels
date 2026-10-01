# Spajanje kodiranja v2 (OpenAlex chunk 01-13 + Scopus-only), provjera, deduplikacija, usporedba s v1
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$cols = 'id','include','excl','levels','primary','role','domain','technique','study','actor','note'
function ReadTsv($path) { Get-Content $path -Encoding UTF8 | ? { $_.Trim() } | % { $p = $_.TrimStart([char]0xFEFF) -split "`t"; $o=[ordered]@{}; for ($i=0;$i -lt 11;$i++){ $o[$cols[$i]] = if ($i -lt $p.Count) { $p[$i].Trim() } else { '' } }; [pscustomobject]$o } }
function Ids($path) { [regex]::Matches((Get-Content $path -Raw -Encoding UTF8), '(?m)^\W?### (\S+)') | % { $_.Groups[1].Value } }
$meta = @{}
Import-Csv "$root\data\corpus.csv" -Encoding UTF8 | % { $meta[$_.id] = [pscustomobject]@{ title=$_.title; year=$_.year; type=$_.type; source=$_.source; cited=$_.cited_by; doi=$_.doi; db='OpenAlex' } }
Import-Csv "$root\data\corpus_ext_new.csv" -Encoding UTF8 | % { $meta[$_.id] = [pscustomobject]@{ title=$_.title; year=$_.year; type=$_.type; source=$_.source; cited=$_.cited_by; doi=$_.doi; db='OpenAlex-ext' } }
Import-Csv "$root\data\scopus\scopus_only_meta.tsv" -Delimiter "`t" -Encoding UTF8 | % { $meta[$_.eid] = [pscustomobject]@{ title=$_.title; year=$_.year; type=$_.type; source=$_.source; cited=$_.cited; doi=$_.doi; db='Scopus' } }
if (Test-Path "$root\data\scopus\scopus_ext_meta.tsv") { Import-Csv "$root\data\scopus\scopus_ext_meta.tsv" -Delimiter "`t" -Encoding UTF8 | % { $meta[$_.eid] = [pscustomobject]@{ title=$_.title; year=$_.year; type=$_.type; source=$_.source; cited=$_.cited; doi=$_.doi; db='Scopus-ext' } } }
$pairs = New-Object System.Collections.ArrayList
foreach ($k in 1..13) { [void]$pairs.Add(@(("$root\data\screening\chunk_{0:D2}.txt" -f $k), ("$root\data\screening\coded_v2_{0:D2}.tsv" -f $k))) }
[void]$pairs.Add(@("$root\data\scopus\scopus_only_screening.txt", "$root\data\scopus\coded_v2_scopus.tsv"))
if (Test-Path "$root\data\scopus\coded_v2_scopus_ext.tsv") { [void]$pairs.Add(@("$root\data\scopus\scopus_ext_screening.txt", "$root\data\scopus\coded_v2_scopus_ext.tsv")) }
$all = @()
foreach ($pr in $pairs) { $in = @(Ids $pr[0]); $c = @(ReadTsv $pr[1]); $ok = ($in.Count -eq $c.Count) -and (-not (Compare-Object $in @($c | % id) -SyncWindow 0))
  "{0,-28} ulaz {1,4}  kod {2,4}  {3}" -f (Split-Path $pr[1] -Leaf), $in.Count, $c.Count, $(if ($ok) {'OK'} else {'NESLAGANJE!'}); $all += $c }
# usklađivanje: akvakultura = E2 (kao ribarstvo), odluka autora
$aqua = 'W4292324117','W3191538504','W4367669882','W7197995101'
foreach ($r in $all) { if ($aqua -contains $r.id -and $r.include -eq '1') { $r.include='0'; $r.excl='E2'; $r.levels='-'; $r.primary='-'; $r.role='-'; $r.domain='-'; $r.technique='-'; $r.study='-'; $r.actor='-'; $r.note = 'Harmonised: aquaculture treated as fisheries (E2)' } }
# deduplikacija: normalizirani naslov ili oznaka Duplicate
$seen=@{}; $seenId=@{}; $rows = foreach ($r in $all) { $m = $meta[$r.id]; $key = (([string]$m.title).ToLower() -replace '[^a-z0-9]',''); $dup = 0
  $ref = [regex]::Matches($r.note, 'W\d{6,}|2-s2\.0-\d+') | % Value | ? { $_ -ne $r.id }
  if ($seen.ContainsKey($key) -or ($r.note -match '^Duplicate' -and @($ref | ? { $seenId.ContainsKey($_) }).Count -gt 0)) { $dup = 1 } else { $seen[$key] = $r.id }
  $seenId[$r.id] = 1
  $r | Add-Member -NotePropertyMembers @{ duplicate=$dup; title=$m.title; year=$m.year; type=$m.type; source=$m.source; cited_by=$m.cited; doi=$m.doi; db=$m.db } -PassThru }
$rows | Export-Csv "$root\data\coded_all_v2.csv" -NoTypeInformation -Encoding UTF8
$u = @($rows | ? duplicate -eq 0); $inc = @($u | ? include -eq '1')
$inc | Export-Csv "$root\data\included_v2.csv" -NoTypeInformation -Encoding UTF8
"`nUkupno kodiranih: $($rows.Count); duplikata: $(@($rows | ? duplicate -eq 1).Count); jedinstvenih: $($u.Count); ukljucenih: $($inc.Count)"
"Iskljucenja: " + (($u | ? include -eq '0' | Group-Object excl | Sort-Object Name | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Razina: " + (($inc | Group-Object primary | Sort-Object Name | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Uloga: " + (($inc | Group-Object role | Sort-Object Name | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Po bazi: " + (($inc | Group-Object db | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Tehnika: " + (($inc | Group-Object technique | Sort-Object Count -Desc | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Neispravne vrijednosti: " + @($inc | ? { $_.primary -notin 'O','T','S' -or $_.role -notin 'INFO','REC','AUTO' -or $_.study -notin 'EMP','CON','REV' }).Count
"Ukljuceni s rijecima aquac/shrimp/prawn/fish u naslovu: " + (($inc | ? { $_.title -match 'aquac|shrimp|prawn|fish' } | % id) -join ', ')
# dosljednost v1 vs v2 (isti zapisi)
$v1 = @{}; Import-Csv "$root\data\coded_all.csv.v1" -Encoding UTF8 | % { $v1[$_.id] = $_ }
Import-Csv "$root\data\scopus\..\included_combined.csv.v1" -Encoding UTF8 -ErrorAction SilentlyContinue | ? db -eq 'Scopus' | % { $v1[$_.id] = $_ }
function Kappa($a,$b){ $n=$a.Count; $cats=@($a+$b|Sort-Object -Unique); $po=0; for($i=0;$i -lt $n;$i++){ if($a[$i] -eq $b[$i]){$po++} }; $po/=$n; $pe=0; foreach($c in $cats){ $pe += (@($a|?{$_ -eq $c}).Count/$n)*(@($b|?{$_ -eq $c}).Count/$n) }; "n=$n, slaganje $([math]::Round(100*$po,1)) %, kappa $([math]::Round(($po-$pe)/(1-$pe),3))" }
$common = @($u | ? { $v1.ContainsKey($_.id) -and $v1[$_.id].duplicate -ne '1' })
"`nv1 vs v2 ukljucivanje (OpenAlex): " + (Kappa @($common | % { $v1[$_.id].include }) @($common | % include))
$bi = @($common | ? { $_.include -eq '1' -and $v1[$_.id].include -eq '1' })
"v1 vs v2 razina (oba ukljucila): " + (Kappa @($bi | % { $v1[$_.id].primary }) @($bi | % primary))
"v1 vs v2 uloga (oba ukljucila): " + (Kappa @($bi | % { $v1[$_.id].role }) @($bi | % role))
"v1 ukljuceno -> v2 iskljuceno: $(@($common | ? { $v1[$_.id].include -eq '1' -and $_.include -eq '0' }).Count); v1 iskljuceno -> v2 ukljuceno: $(@($common | ? { $v1[$_.id].include -eq '0' -and $_.include -eq '1' }).Count)"
"Razlozi v1-ukljuceno -> v2-iskljuceno: " + (($common | ? { $v1[$_.id].include -eq '1' -and $_.include -eq '0' } | Group-Object excl | % { "$($_.Name)=$($_.Count)" }) -join ', ')
# kappa ljudskog kodiranja prema v2 kodovima
$v2 = @{}; foreach ($r in $rows) { $v2[$r.id] = $r }
foreach ($rd in @(@('kappa_uzorak_za_kodiranje.xlsx','Runda 1'), @('kappa_uzorak_runda2_kodirano.xlsx','Runda 2'))) {
  $xl = New-Object -ComObject Excel.Application; $xl.Visible=$false; $wb = $xl.Workbooks.Open("$root\$($rd[0])",0,$true); $ws=$wb.Worksheets.Item(1)
  $h = for ($r=2;$r -le 41;$r++) { [pscustomobject]@{ id=$ws.Cells.Item($r,2).Text.Trim(); inc=$ws.Cells.Item($r,6).Text.Trim(); lev=$ws.Cells.Item($r,8).Text.Trim().ToUpper(); role=$ws.Cells.Item($r,9).Text.Trim().ToUpper() } }; $wb.Close($false); $xl.Quit()
  "`n$($rd[1]) covjek vs LLM v2 - ukljucivanje: " + (Kappa @($h | % inc) @($h | % { $v2[$_.id].include }))
  $b = @($h | ? { $_.inc -eq '1' -and $v2[$_.id].include -eq '1' })
  "$($rd[1]) - razina: " + (Kappa @($b | % lev) @($b | % { $v2[$_.id].primary })); "$($rd[1]) - uloga: " + (Kappa @($b | % role) @($b | % { $v2[$_.id].role }))
}
