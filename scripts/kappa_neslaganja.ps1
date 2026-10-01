# Tablica neslaganja (Sanja vs AI) za usuglasavanje kodiranja
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$key = @{}; Import-Csv (Join-Path $root 'data\kappa_kljuc_AI.csv') -Encoding UTF8 | % { $key[$_.id] = $_ }
$corpus = @{}; Import-Csv (Join-Path $root 'data\corpus.csv') -Encoding UTF8 | % { $corpus[$_.id] = $_ }
$coded = @{}; Import-Csv (Join-Path $root 'data\coded_all.csv') -Encoding UTF8 | % { $coded[$_.id] = $_ }
$xl = New-Object -ComObject Excel.Application; $xl.Visible=$false; $xl.DisplayAlerts=$false
$src = $xl.Workbooks.Open((Join-Path $root 'kappa_uzorak_za_kodiranje.xlsx'), 0, $true); $s = $src.Worksheets.Item(1)
$rows = for ($r=2; $r -le 41; $r++) { [pscustomobject]@{ id=$s.Cells.Item($r,2).Text.Trim(); inc=$s.Cells.Item($r,6).Text.Trim(); excl=$s.Cells.Item($r,7).Text.Trim(); lev=$s.Cells.Item($r,8).Text.Trim().ToUpper(); role=$s.Cells.Item($r,9).Text.Trim().ToUpper(); nap=$s.Cells.Item($r,10).Text.Trim() } }
$src.Close($false)
$dis = @($rows | ? { $k=$key[$_.id]; $_.inc -ne $k.include -or ($_.inc -eq '1' -and ($_.lev -ne $k.primary -or $_.role -ne $k.role)) })
$wb = $xl.Workbooks.Add(); $ws = $wb.Worksheets.Item(1); $ws.Name = 'Neslaganja'
$h = 'Rb','ID','Naslov','Sazetak','Vrsta rada (AI)','Sanja: ukljuciti','Sanja: razlog','Sanja: razina','Sanja: uloga','AI: ukljuciti','AI: razlog','AI: razina','AI: uloga','AI napomena','DOGOVOR: ukljuciti','DOGOVOR: razina','DOGOVOR: uloga','Pravilo / obrazlozenje'
for ($c=1; $c -le $h.Count; $c++) { $ws.Cells.Item(1,$c) = $h[$c-1] }
$r = 2
foreach ($d in $dis) { $k = $key[$d.id]; $m = $corpus[$d.id]; $cd = $coded[$d.id]
  $a = $m.abstract; if ($a.Length -gt 3000) { $a = $a.Substring(0,3000) + ' [...]' }
  $vals = @(($r-1), $d.id, $m.title, $a, $cd.study, $d.inc, $d.excl, $d.lev, $d.role, $k.include, $k.excl, $k.primary, $k.role, $cd.note)
  for ($c=1; $c -le $vals.Count; $c++) { $ws.Cells.Item($r,$c) = [string]$vals[$c-1] }
  $r++ }
$last = $r - 1
$ws.Range("O2:O$last").Validation.Add(3,1,1,'1,0') | Out-Null
$ws.Range("P2:P$last").Validation.Add(3,1,1,'-,O,T,S') | Out-Null
$ws.Range("Q2:Q$last").Validation.Add(3,1,1,'-,INFO,REC,AUTO') | Out-Null
$ws.Rows.Item(1).Font.Bold = $true; $ws.Range("A1:R1").Interior.Color = 15921906
$w = 4,13,40,70,8,8,8,8,8,8,8,8,8,30,10,10,10,40; for ($c=1; $c -le $w.Count; $c++) { $ws.Columns.Item($c).ColumnWidth = $w[$c-1] }
$ws.Range("C2:D$last").WrapText = $true; $ws.Range("N2:N$last").WrapText = $true; $ws.Range("A1:R$last").VerticalAlignment = -4160
$ws.Range("F2:I$last").Interior.Color = 14348258; $ws.Range("J2:N$last").Interior.Color = 15652797; $ws.Range("O2:R$last").Interior.Color = 13434879
$xl.ActiveWindow.SplitRow = 1; $xl.ActiveWindow.SplitColumn = 2; $xl.ActiveWindow.FreezePanes = $true
$out = Join-Path $root 'kappa_neslaganja_za_usuglasavanje.xlsx'; $wb.SaveAs($out, 51); $wb.Close(); $xl.Quit()
"OK $out : $($dis.Count) neslaganja"
