%% analiza_v2.m - revizija (LIMEN): kodna shema v2, prosireni AI blok, primjedbe recenzenta
% Ulaz: data\included_v2.csv ; Izlaz: results\v2_*.csv, results\rezultati_v2.txt, figures\*_v2.png/.tif
clear; clc; rng(42);
root = fileparts(fileparts(mfilename('fullpath')));
res = fullfile(root,'results'); fig = fullfile(root,'figures');
opts = detectImportOptions(fullfile(root,'data','included_v2.csv'),'TextType','string');
sv = intersect(opts.VariableNames, {'id','include','excl','levels','primary','role','domain','technique','study','actor','note','title','type','source','doi','db'});
opts = setvartype(opts, sv, 'string');
D = readtable(fullfile(root,'data','included_v2.csv'), opts);
D.year = double(D.year); N = height(D);
fid = fopen(fullfile(res,'rezultati_v2.txt'),'w','n','UTF-8'); out = @(varargin) fprintf(fid, varargin{:});
L = ["O","T","S"]; Lname = ["Operational","Tactical","Strategic"];
R = ["INFO","REC","AUTO"]; Rname = ["Informational","Recommendation","Automation"];
out('N = %d (OpenAlex %d, OpenAlex-ext %d, Scopus %d, Scopus-ext %d)\n', N, sum(D.db=="OpenAlex"), sum(D.db=="OpenAlex-ext"), sum(D.db=="Scopus"), sum(D.db=="Scopus-ext"));
out('Tip rada: EMP %d, CON %d, REV %d\n', sum(D.study=="EMP"), sum(D.study=="CON"), sum(D.study=="REV"));
out('Godine 2016-2022: %d; 2023-2026: %d; 2025: %d; median godina: %g\n', sum(D.year<=2022), sum(D.year>=2023), sum(D.year==2025), median(D.year));
dm = ["CROP","LIVE","FARM","SCM","MKT","FIN","PROC","SUST"];
out('Domene: '); for k=dm, out('%s %d, ', k, sum(D.domain==k)); end; out('\n');
tq = ["HYB","ML","DL","DSS","OPT","GEN"]; out('Tehnike: '); for k=tq, out('%s %d, ', k, sum(D.technique==k)); end; out('\n');
ac = ["FARMER","FIRM","SC","MIX"]; out('Akteri: '); for k=ac, out('%s %d, ', k, sum(D.actor==k)); end; out('\n\n');
%% RQ1 razine
cntL = arrayfun(@(x) sum(D.primary==x), L);
out('RAZINE: O %d (%.1f %%), T %d (%.1f %%), S %d (%.1f %%)\n', cntL(1), 100*cntL(1)/N, cntL(2), 100*cntL(2)/N, cntL(3), 100*cntL(3)/N);
anyL = arrayfun(@(x) sum(contains(D.levels, x)), L); multi = sum(count(D.levels,";")>=1);
out('  sve oznacene razine: O %d, T %d, S %d; vise razina %d (%.1f %%)\n', anyL, multi, 100*multi/N);
out('  binomni test udio O > 0.5: p = %.3g\n', 1 - binocdf(cntL(1)-1, N, 0.5));
[lo, hi] = wilson(cntL(3), N); out('  udio S = %.1f %% (95%% CI %.1f-%.1f)\n', 100*cntL(3)/N, 100*lo, 100*hi);
Sy = D.year(D.primary=="S"); out('  strateski radovi po godinama: '); for y = unique(Sy)', out('%d:%d ', y, sum(Sy==y)); end; out('\n\n');
%% RQ2 razina x uloga
M = crossT(D.primary, L, D.role, R);
writetable(array2table(M,'VariableNames',cellstr(Rname),'RowNames',cellstr(Lname)), fullfile(res,'v2_T_razina_uloga.csv'),'WriteRowNames',true);
out('ULOGA: INFO %d (%.1f %%), REC %d (%.1f %%), AUTO %d (%.1f %%)\n', sum(M(:,1)), 100*sum(M(:,1))/N, sum(M(:,2)), 100*sum(M(:,2))/N, sum(M(:,3)), 100*sum(M(:,3))/N);
reportCT(out, 'Razina x uloga', M, Lname, Rname);
%% domena x razina (opisno)
MD = crossT(D.domain, dm, D.primary, L);
writetable(array2table([MD sum(MD,2)],'VariableNames',[cellstr(Lname) {'Total'}],'RowNames',cellstr(dm)), fullfile(res,'v2_T_domena_razina.csv'),'WriteRowNames',true);
reportCT(out, 'Domena x razina (opisno; dio definicijski uvjetovan)', MD(sum(MD,2)>0,:), dm(sum(MD,2)>0), Lname);
for k=1:numel(dm), if sum(MD(k,:))>0, out('  %-5s n=%3d  O %.1f %%  T %.1f %%  S %.1f %%\n', dm(k), sum(MD(k,:)), 100*MD(k,:)/sum(MD(k,:))); end, end
%% akter x razina, tehnika, tip rada
MA = crossT(D.actor, ac, D.primary, L); reportCT(out, 'Akter x razina', MA, ac, Lname);
for k=1:numel(ac), out('  %-6s n=%3d  O %.1f %%  T %.1f %%  S %.1f %%\n', ac(k), sum(MA(k,:)), 100*MA(k,:)/sum(MA(k,:))); end
MT = crossT(D.technique, tq, D.primary, L); reportCT(out, 'Tehnika x razina', MT(sum(MT,2)>0,:), tq(sum(MT,2)>0), Lname);
MS = crossT(D.study, ["EMP","CON","REV"], D.primary, L); reportCT(out, 'Tip rada x razina', MS, ["EMP","CON","REV"], Lname);
%% vrijeme
yrs=(2016:2026)'; Y = zeros(numel(yrs),3); for t=1:numel(yrs), for i=1:3, Y(t,i)=sum(D.year==yrs(t) & D.primary==L(i)); end, end
writetable(array2table([yrs Y sum(Y,2)],'VariableNames',{'Year','Operational','Tactical','Strategic','Total'}), fullfile(res,'v2_T_godine_razina.csv'));
out('\nGodina x razina:\n'); for t=1:numel(yrs), out('  %d  O %3d T %3d S %3d | %3d\n', yrs(t), Y(t,:), sum(Y(t,:))); end
Mp = [arrayfun(@(x) sum(D.year<=2022 & D.primary==x), L); arrayfun(@(x) sum(D.year>=2023 & D.primary==x), L)];
reportCT(out, 'Razdoblje (2016-2022 / 2023-2026) x razina', Mp, ["2016-2022","2023-2026"], Lname);
g = fitglm(D.year, double(D.primary~="O"), 'Distribution','binomial'); ci = g.coefCI;
out('  Logit: P(primarna razina T ili S) ~ godina: b = %.3f, OR = %.3f, 95%% CI %.3f-%.3f, p = %.3g\n', g.Coefficients.Estimate(2), exp(g.Coefficients.Estimate(2)), exp(ci(2,1)), exp(ci(2,2)), g.Coefficients.pValue(2));
g2 = fitglm(D.year, double(D.role~="INFO"), 'Distribution','binomial');
out('  Logit: P(uloga REC ili AUTO) ~ godina: OR = %.3f, p = %.3g\n', exp(g2.Coefficients.Estimate(2)), g2.Coefficients.pValue(2));
%% osjetljivost: samo primarne studije (bez preglednih radova)
P = D(D.study~="REV",:); nP = height(P); cP = arrayfun(@(x) sum(P.primary==x), L);
out('\nOSJETLJIVOST (bez REV, n=%d): O %.1f %%, T %.1f %%, S %.1f %%; AUTO %d, INFO %.1f %%\n', nP, 100*cP/nP, sum(P.role=="AUTO"), 100*mean(P.role=="INFO"));
reportCT(out, 'Osjetljivost: razina x uloga (bez REV)', crossT(P.primary, L, P.role, R), Lname, Rname);
gP = fitglm(P.year, double(P.primary~="O"), 'Distribution','binomial'); out('  Logit bez REV: OR = %.3f, p = %.3g\n', exp(gP.Coefficients.Estimate(2)), gP.Coefficients.pValue(2));
fclose(fid);

%% Slike (manje, 12 x 6 cm, Times New Roman; PNG za Word + TIF 300 dpi za predaju)
col = [0.35 0.55 0.75; 0.93 0.60 0.25; 0.30 0.62 0.40];
set(groot,'defaultAxesFontName','Times New Roman','defaultAxesFontSize',9,'defaultTextFontName','Times New Roman','defaultLegendFontSize',8);
f = figure('Color','w','Units','centimeters','Position',[2 2 12 6]);
bh = bar(yrs, Y, 'stacked', 'EdgeColor','none','BarWidth',0.75); for i=1:3, bh(i).FaceColor = col(i,:); end
xlabel('Publication year'); ylabel('Number of studies'); legend(Lname,'Location','northwest','Box','off');
xticks(yrs); xtickangle(0); box off; grid on; set(gca,'GridAlpha',0.12,'TickDir','out');
text(2026, sum(Y(end,:))+4, '*', 'HorizontalAlignment','center','FontName','Times New Roman');
exportgraphics(f, fullfile(fig,'Figure1_years_levels_v2.png'), 'Resolution', 300);
exportgraphics(f, fullfile(fig,'Figure1_years_levels_v2.tif'), 'Resolution', 300); close(f);
dn = ["Crop production","Livestock","Whole-farm management","Supply chain and logistics","Markets and pricing","Finance and risk","Food processing","Sustainability"];
[~, ord] = sort(sum(MD,2)); f = figure('Color','w','Units','centimeters','Position',[2 2 12 6]);
bh = barh(MD(ord,:), 'stacked', 'EdgeColor','none','BarWidth',0.7); for i=1:3, bh(i).FaceColor = col(i,:); end
yticks(1:numel(ord)); yticklabels(dn(ord)); xlabel('Number of studies'); legend(Lname,'Location','southeast','Box','off'); box off; set(gca,'TickDir','out');
exportgraphics(f, fullfile(fig,'Figure2_domains_levels_v2.png'), 'Resolution', 300);
exportgraphics(f, fullfile(fig,'Figure2_domains_levels_v2.tif'), 'Resolution', 300); close(f);
disp('Analiza v2 gotova.'); type(fullfile(res,'rezultati_v2.txt'));

%% Pomocne funkcije
function M = crossT(a, ca, b, cb)
  M = zeros(numel(ca), numel(cb)); for i=1:numel(ca), for j=1:numel(cb), M(i,j) = sum(a==ca(i) & b==cb(j)); end, end
end
function [chi2, df, p, V, E] = chi_indep(M)
  M = M(sum(M,2)>0, sum(M,1)>0); n = sum(M(:)); E = sum(M,2)*sum(M,1)/n;
  chi2 = sum(((M-E).^2)./E, 'all'); df = (size(M,1)-1)*(size(M,2)-1); p = 1 - chi2cdf(chi2, df); V = sqrt(chi2/(n*(min(size(M))-1)));
end
function p = mc_chi(M, obs, B)
  M = M(sum(M,2)>0, sum(M,1)>0); r = repelem((1:size(M,1))', sum(M,2)); c = repelem((1:size(M,2))', sum(M,1)'); cnt = 0;
  for k = 1:B, Mk = accumarray([r c(randperm(numel(c)))], 1, size(M)); cnt = cnt + (chi_indep(Mk) >= obs - 1e-9); end
  p = (cnt + 1)/(B + 1);
end
function reportCT(out, name, M, rn, cn)
  out('\n%s:\n', name); out('  %-28s', ''); for j=1:numel(cn), out('%12s', cn(j)); end; out('\n');
  for i=1:size(M,1), out('  %-28s', rn(i)); out('%12d', M(i,:)); out('\n'); end
  [c, d, p, V, E] = chi_indep(M); pm = mc_chi(M, c, 20000);
  out('  chi2(%d) = %.2f, p = %.3g, Cramer V = %.3f, Monte Carlo p = %.4f; celija E<5: %d od %d, min E = %.2f\n', d, c, p, V, pm, sum(E(:)<5), numel(E), min(E(:)));
end
function [lo, hi] = wilson(k, n)
  z = 1.96; ph = k/n; d = 1 + z^2/n; c = ph + z^2/(2*n); s = z*sqrt(ph*(1-ph)/n + z^2/(4*n^2)); lo = (c - s)/d; hi = (c + s)/d;
end
