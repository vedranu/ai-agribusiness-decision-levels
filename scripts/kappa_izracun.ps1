# Cohenova kappa: Sanjino rucno kodiranje vs AI kodiranje (uzorak 40)
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$key = @{}; Import-Csv (Join-Path $root 'data\kappa_kljuc_AI.csv') -Encoding UTF8 | % { $key[$_.id] = $_ }
$xl = New-Object -ComObject Excel.Application; $xl.Visible=$false
$wb = $xl.Workbooks.Open((Join-Path $root 'kappa_uzorak_za_kodiranje.xlsx'), 0, $true); $ws = $wb.Worksheets.Item(1)
$rows = for ($r=2; $r -le 41; $r++) { [pscustomobject]@{ id=$ws.Cells.Item($r,2).Text.Trim(); inc=$ws.Cells.Item($r,6).Text.Trim(); excl=$ws.Cells.Item($r,7).Text.Trim(); lev=$ws.Cells.Item($r,8).Text.Trim().ToUpper(); role=$ws.Cells.Item($r,9).Text.Trim().ToUpper() } }
$wb.Close($false); $xl.Quit()
function Kappa($a, $b) {
  $n = $a.Count; $cats = @($a + $b | Sort-Object -Unique)
  $po = 0; for ($i=0; $i -lt $n; $i++) { if ($a[$i] -eq $b[$i]) { $po++ } }; $po /= $n
  $pe = 0; foreach ($c in $cats) { $pe += (@($a | ? { $_ -eq $c }).Count / $n) * (@($b | ? { $_ -eq $c }).Count / $n) }
  $k = if ($pe -lt 1) { ($po - $pe) / (1 - $pe) } else { 1 }
  [pscustomobject]@{ n=$n; agree=[math]::Round(100*$po,1); kappa=[math]::Round($k,3) }
}
function CM($a, $b, $cats) { "        " + (($cats | % { "{0,6}" -f $_ }) -join ''); foreach ($r in $cats) { "  {0,-5}" -f $r + (($cats | % { $c=$_; "{0,6}" -f @(0..($a.Count-1) | ? { $a[$_] -eq $r -and $b[$_] -eq $c }).Count }) -join '') } }
$missing = @($rows | ? { -not $key.ContainsKey($_.id) }).Count
$H = @($rows | % { $_.inc }); $A = @($rows | % { $key[$_.id].include })
"Nedostaje u kljucu: $missing"
"UKLJUCIVANJE (sva 40):"; Kappa $H $A | Format-List | Out-String; "  redak = Sanja, stupac = AI"; CM $H $A @('1','0')
$both = @($rows | ? { $_.inc -eq '1' -and $key[$_.id].include -eq '1' })
$HL = @($both | % { $_.lev }); $AL = @($both | % { $key[$_.id].primary })
"`nPRIMARNA RAZINA (oba ukljucila, n=$($both.Count)):"; Kappa $HL $AL | Format-List | Out-String; CM $HL $AL @('O','T','S')
$HR = @($both | % { $_.role }); $AR = @($both | % { $key[$_.id].role })
"`nULOGA UI (oba ukljucila):"; Kappa $HR $AR | Format-List | Out-String; CM $HR $AR @('INFO','REC','AUTO')
$hx = @($rows | ? { $_.inc -eq '0' -and $key[$_.id].include -eq '0' })
"`nRAZLOG ISKLJUCENJA (oba iskljucila, n=$($hx.Count)): slaganje " + @($hx | ? { $_.excl -eq $key[$_.id].excl }).Count
"`nNESLAGANJA:"
foreach ($r in $rows) { $k = $key[$r.id]; if ($r.inc -ne $k.include -or ($r.inc -eq '1' -and ($r.lev -ne $k.primary -or $r.role -ne $k.role))) { "  $($r.id)  Sanja: $($r.inc) $($r.excl) $($r.lev) $($r.role)  |  AI: $($k.include) $($k.excl) $($k.primary) $($k.role)" } }
"`nRaspodjela razina - Sanja (ukljuceni): " + (($rows | ? inc -eq '1' | Group-Object lev | % { "$($_.Name)=$($_.Count)" }) -join ', ')
"Raspodjela razina - AI (ukljuceni):    " + (($rows | ? { $key[$_.id].include -eq '1' } | Group-Object { $key[$_.id].primary } | % { "$($_.Name)=$($_.Count)" }) -join ', ')
