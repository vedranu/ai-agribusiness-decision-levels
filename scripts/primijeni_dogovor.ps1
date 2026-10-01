# Primjena dogovora (kappa_neslaganja_usuglaseno.xlsx) na kodirane podatke
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$xl = New-Object -ComObject Excel.Application; $xl.Visible=$false
$wb = $xl.Workbooks.Open((Join-Path $root 'kappa_neslaganja_usuglaseno.xlsx'), 0, $true); $ws = $wb.Worksheets.Item(1)
$cons = for ($r=2; $r -le $ws.UsedRange.Rows.Count; $r++) { [pscustomobject]@{ id=$ws.Cells.Item($r,2).Text.Trim(); inc=$ws.Cells.Item($r,15).Text.Trim(); lev=$ws.Cells.Item($r,16).Text.Trim(); role=$ws.Cells.Item($r,17).Text.Trim(); rule=$ws.Cells.Item($r,18).Text.Trim() } }
$wb.Close($false); $xl.Quit()
$cons | Export-Csv (Join-Path $root 'data\kappa_dogovor_runda1.csv') -NoTypeInformation -Encoding UTF8
foreach ($c in $cons) { $c | Add-Member excl ((($c.rule -split ':')[0]).Trim()) }
foreach ($f in 'coded_all.csv','included_combined.csv') {
  $path = Join-Path $root "data\$f"; if (-not (Test-Path "$path.v1")) { Copy-Item $path "$path.v1" }
  $d = Import-Csv $path -Encoding UTF8; $ch = 0
  foreach ($row in $d) { $c = $cons | ? id -eq $row.id
    if (-not $c) { continue }
    if ($row.include -ne $c.inc) { "  PAZNJA: $f $($row.id) ukljucivanje $($row.include) -> $($c.inc) (nije primijenjeno automatski)" ; continue }
    if ($c.inc -eq '1' -and ($row.primary -ne $c.lev -or $row.role -ne $c.role)) { "  $f $($row.id): $($row.primary)/$($row.role) -> $($c.lev)/$($c.role)"; $row.primary = $c.lev; $row.role = $c.role
      if (($row.levels -split ';') -notcontains $c.lev) { $row.levels = (@($row.levels -split ';' | ? { $_ -and $_ -ne '-' }) + $c.lev) -join ';' }; $ch++ }
    if ($c.inc -eq '0' -and $c.excl -match '^E\d$' -and $row.excl -ne $c.excl) { "  $f $($row.id): $($row.excl) -> $($c.excl)"; $row.excl = $c.excl; $ch++ }
  }
  $d | Export-Csv $path -NoTypeInformation -Encoding UTF8; "$f : promjena $ch"
}
