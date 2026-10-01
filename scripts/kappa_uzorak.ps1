# Uzorak za provjeru pouzdanosti kodiranja: 20 ukljucenih + 20 iskljucenih, slucajno (seed 2026)
$root = Join-Path $env:USERPROFILE 'Desktop\Radovi 2026\agrobiznis_ai'
$corpus = @{}; Import-Csv (Join-Path $root 'data\corpus.csv') -Encoding UTF8 | % { $corpus[$_.id] = $_ }
$all = Import-Csv (Join-Path $root 'data\coded_all.csv') -Encoding UTF8 | ? { $_.duplicate -eq '0' }
$rnd = New-Object System.Random 2026
$inc = @($all | ? include -eq '1' | Sort-Object { $rnd.Next() } | Select -First 20)
$exc = @($all | ? include -eq '0' | Sort-Object { $rnd.Next() } | Select -First 20)
$sample = @($inc + $exc) | Sort-Object { $rnd.Next() }
# kljuc (AI kodovi) sprema se odvojeno da ne utjece na ljudsko kodiranje
$sample | Select id, include, excl, primary, role | Export-Csv (Join-Path $root 'data\kappa_kljuc_AI.csv') -NoTypeInformation -Encoding UTF8
$xl = New-Object -ComObject Excel.Application; $xl.Visible = $false; $xl.DisplayAlerts = $false
$wb = $xl.Workbooks.Add(); $ws = $wb.Worksheets.Item(1); $ws.Name = 'Kodiranje'
$hdr = 'Rb','ID','Godina','Naslov','Sazetak','UKLJUCITI (1/0)','Razlog iskljucenja (E1-E6)','Primarna razina (O/T/S)','Uloga UI (INFO/REC/AUTO)','Napomena'
for ($c=1; $c -le $hdr.Count; $c++) { $ws.Cells.Item(1,$c) = $hdr[$c-1] }
$r = 2
foreach ($s in $sample) { $m = $corpus[$s.id]
  $ws.Cells.Item($r,1) = $r-1; $ws.Cells.Item($r,2) = $s.id; $ws.Cells.Item($r,3) = $m.year; $ws.Cells.Item($r,4) = $m.title
  $a = $m.abstract; if ($a.Length -gt 3000) { $a = $a.Substring(0,3000) + ' [...]' }; $ws.Cells.Item($r,5) = $a; $r++ }
$last = $r - 1
$ws.Range("F2:F$last").Validation.Add(3,1,1,'1,0') | Out-Null
$ws.Range("G2:G$last").Validation.Add(3,1,1,'-,E1,E2,E3,E4,E5,E6') | Out-Null
$ws.Range("H2:H$last").Validation.Add(3,1,1,'-,O,T,S') | Out-Null
$ws.Range("I2:I$last").Validation.Add(3,1,1,'-,INFO,REC,AUTO') | Out-Null
$ws.Rows.Item(1).Font.Bold = $true; $ws.Range("A1:J1").Interior.Color = 15921906
$w = 5,14,8,45,90,14,16,16,18,30; for ($c=1; $c -le 10; $c++) { $ws.Columns.Item($c).ColumnWidth = $w[$c-1] }
$ws.Range("D2:E$last").WrapText = $true; $ws.Range("A1:J$last").VerticalAlignment = -4160
$ws.Range("F2:I$last").Interior.Color = 13434879
$xl.ActiveWindow.SplitRow = 1; $xl.ActiveWindow.FreezePanes = $true
$ws2 = $wb.Worksheets.Add([Type]::Missing, $ws); $ws2.Name = 'Upute'
$upute = @('Upute za kodiranje (samo naslov i sazetak; ne gledati druge izvore)', '',
 'UKLJUCITI = 1 ako vrijedi sve troje: (I1) koristi se, razvija ili pregledava metoda UI; (I2) kontekst je agrobiznis (farme, agroprehrambena poduzeca, zadruge, opskrbni lanci); (I3) rezultat UI izricito sluzi odluci aktera u agrobiznisu.',
 'Inace UKLJUCITI = 0 i upisati razlog:',
 '  E1 cisto tehnicki rad, bez navedene uporabe u odlucivanju', '  E2 izvan agrobiznisa (i ribarstvo, akvakultura)', '  E3 laboratorijsko otkrivanje kvalitete ili sigurnosti hrane',
 '  E4 samo javne politike ili makrorazina', '  E5 UI nije temeljna metoda (samo spomenuta; ARIMA, AHP, obicna optimizacija)', '  E6 nije znanstveni rad', '',
 'Za ukljucene radove:', '  Razina O operativna: sati do tjedni, rutinske odluke (navodnjavanje, doziranje, zastita bilja, berba, hranidba, rute)',
 '  Razina T takticka: sezona do oko 2 godine (sezonsko planiranje, nabava, predvidanje potraznje i cijena, krediti)',
 '  Razina S strateska: vise godina (investicije, usvajanje tehnologije, ulazak na trziste, oblikovanje lanca, strategija odrzivosti)',
 '  Uloga INFO: UI daje informaciju, covjek odlucuje; REC: UI preporucuje konkretan izbor; AUTO: UI sama izvrsava odluku', '',
 'Cijela kodna shema: data\codebook_v1.md. Kad zavrsite, datoteku vratite Vedranu; izracunat ce Cohenovu kapu.')
for ($i=0; $i -lt $upute.Count; $i++) { $ws2.Cells.Item($i+1,1) = $upute[$i] }
$ws2.Rows.Item(1).Font.Bold = $true; $ws2.Columns.Item(1).ColumnWidth = 130
$ws.Activate()
$out = Join-Path $root 'kappa_uzorak_za_kodiranje.xlsx'; $wb.SaveAs($out, 51); $wb.Close(); $xl.Quit()
"OK $out : ukljucenih $($inc.Count), iskljucenih $($exc.Count)"
