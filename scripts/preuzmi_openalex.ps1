# Preuzimanje korpusa iz OpenAlexa - AI u agrobiznisu (2016-2026)
# Upit B (siri korpus); upit C (s pojmovima odlucivanja) oznacava se naknadno u MATLAB-u
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$raw  = Join-Path $root 'data\raw'
$ai  = '("artificial intelligence" OR "machine learning" OR "deep learning" OR "neural network" OR "decision support system" OR "expert system")'
$agB = '(agribusiness OR "agri-food" OR agrifood OR "agri-business" OR "farm management" OR "agricultural supply chain" OR "food supply chain" OR "agricultural value chain")'
$q = "$ai AND $agB"
$f = ',publication_year:2016-2026,type:article%7Creview,language:en'
$sel = 'id,doi,title,publication_year,publication_date,type,language,primary_location,authorships,cited_by_count,abstract_inverted_index,keywords,topics,primary_topic'
$base = 'https://api.openalex.org/works?filter=title_and_abstract.search:' + [uri]::EscapeDataString($q) + $f + "&per-page=200&select=$sel&mailto=vuros@veleknin.hr"
Set-Content -Path (Join-Path $root 'data\upit_openalex.txt') -Value @("Datum preuzimanja: $(Get-Date -Format 'yyyy-MM-dd HH:mm')", "Polje: title_and_abstract.search", "Upit: $q", "Filteri: publication_year 2016-2026, type article|review, language en", "URL: $base") -Encoding UTF8
$cursor = '*'; $p = 0
while ($cursor) {
  $p++
  $u = $base + '&cursor=' + [uri]::EscapeDataString($cursor)
  $ok = $false; $try = 0
  while (-not $ok -and $try -lt 5) {
    try { $r = Invoke-WebRequest $u -UseBasicParsing; $ok = $true } catch { $try++; Start-Sleep -Seconds (2*$try) }
  }
  if (-not $ok) { "Stranica $p neuspjesna, prekidam"; break }
  $out = Join-Path $raw ('page_{0:D3}.json' -f $p)
  [IO.File]::WriteAllText($out, $r.Content, [Text.Encoding]::UTF8)
  $cursor = [regex]::Match($r.Content, '"next_cursor":\s*"([^"]+)"').Groups[1].Value
  $nres = ([regex]::Matches($r.Content, '"id":\s*"https://openalex.org/W')).Count
  "Stranica $p : $nres zapisa, rem_usd=$($r.Headers['X-RateLimit-Remaining-USD'])"
  if ($nres -eq 0) { break }
  Start-Sleep -Milliseconds 1200
}
"Gotovo."
