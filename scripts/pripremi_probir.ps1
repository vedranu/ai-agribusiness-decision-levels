# Priprema skupova za probir: zapisi sa sazetkom i pojmovima odlucivanja, podijeljeni u dijelove
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$c = Import-Csv (Join-Path $root 'data\corpus.csv') -Encoding UTF8
$s = @($c | Where-Object { $_.has_abstract -eq '1' -and $_.decision_terms -eq '1' })
"Za probir: $($s.Count)"
$dir = Join-Path $root 'data\screening'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$size = 110; $k = 0
for ($i = 0; $i -lt $s.Count; $i += $size) {
  $k++
  $part = $s[$i..([Math]::Min($i+$size, $s.Count)-1)]
  $lines = foreach ($r in $part) {
    $a = $r.abstract; if ($a.Length -gt 1600) { $a = $a.Substring(0,1600) + ' [...]' }
    "### $($r.id) | $($r.year) | $($r.source)`nTITLE: $($r.title)`nABSTRACT: $a`n"
  }
  [IO.File]::WriteAllText((Join-Path $dir ('chunk_{0:D2}.txt' -f $k)), ($lines -join "`n"), [Text.Encoding]::UTF8)
}
"Dijelova: $k"
