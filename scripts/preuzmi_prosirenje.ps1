# Prosireni AI blok: samo novi pojmovi AND isti agrobiznis blok; preuzimanje i razlika prema postojecem korpusu
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$raw = Join-Path $root 'data\raw_ext'; New-Item -ItemType Directory -Force $raw | Out-Null
$aiNew = '("generative AI" OR "generative artificial intelligence" OR "large language model" OR "large language models" OR ChatGPT OR "reinforcement learning")'
$agB = '(agribusiness OR "agri-food" OR agrifood OR "agri-business" OR "farm management" OR "agricultural supply chain" OR "food supply chain" OR "agricultural value chain")'
$q = "$aiNew AND $agB"
$f = ',publication_year:2016-2026,type:article%7Creview,language:en'
$sel = 'id,doi,title,publication_year,publication_date,type,language,primary_location,authorships,cited_by_count,abstract_inverted_index,keywords,topics,primary_topic'
$base = 'https://api.openalex.org/works?filter=title_and_abstract.search:' + [uri]::EscapeDataString($q) + $f + "&per-page=200&select=$sel&mailto=vuros@veleknin.hr"
Add-Content -Path (Join-Path $root 'data\upit_openalex.txt') -Value @('', "PROSIRENJE (revizija), datum: $(Get-Date -Format 'yyyy-MM-dd HH:mm')", "Upit (novi AI pojmovi): $q", "URL: $base") -Encoding UTF8
$cursor = '*'; $p = 0
while ($cursor) { $p++
  $u = $base + '&cursor=' + [uri]::EscapeDataString($cursor); $ok=$false; $t=0
  while (-not $ok -and $t -lt 5) { try { $r = Invoke-WebRequest $u -UseBasicParsing; $ok=$true } catch { $t++; Start-Sleep -Seconds (2*$t) } }
  if (-not $ok) { "greska str. $p"; break }
  [IO.File]::WriteAllText((Join-Path $raw ('page_{0:D3}.json' -f $p)), $r.Content, [Text.Encoding]::UTF8)
  $cursor = [regex]::Match($r.Content, '"next_cursor":\s*"([^"]+)"').Groups[1].Value
  $n = ([regex]::Matches($r.Content, '"id":\s*"https://openalex.org/W')).Count; "str. $p : $n"
  if ($n -eq 0) { break }; Start-Sleep -Milliseconds 1200 }
