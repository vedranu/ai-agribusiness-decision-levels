# AI in agribusiness managerial decision-making: replication package

Data, codebooks, LLM prompts, scripts and results for the structured review

> Jurić Gubeljić, S., & Uroš, V. (2026). *Artificial Intelligence in Agribusiness from Operational Optimization to Strategic Decision-Making.* Paper submitted to the LIMEN 2026 conference.

The review maps 350 journal studies (2016 to September 2026, OpenAlex and Scopus) by the level of managerial decision supported by artificial intelligence (operational, tactical, strategic) and by the role of AI in the decision process (informational, recommendation, automation).

## Main results

| Primary decision level | Studies | Share |
|---|---|---|
| Operational | 244 | 69.7% |
| Tactical | 93 | 26.6% |
| Strategic | 13 | 3.7% |

AI mainly informs human decision-makers at all levels (64.3%), and automation (3.1%) occurs only at the operational level. The share of tactical and strategic studies declines over time (logistic regression, OR = 0.86 per year, p = 0.011). Full output: `results/results_v2.txt`.

## Contents

| Folder | Content |
|---|---|
| `query/` | Exact OpenAlex queries, filters and retrieval dates (main search 30 September 2026, extension 1 October 2026). Scopus used the equivalent TITLE-ABS queries described in the paper. |
| `data/` | Record metadata (OpenAlex IDs or Scopus EIDs, DOI, title, year, source), LLM codes for all screened records (codebook v1 and v2), the final included set, and human and LLM codes for both reliability rounds. |
| `codebook/` | Codebook v1, codebook v2 with the ten clarified rules (R1-R10), and the prompt used for LLM coding. |
| `scripts/` | PowerShell scripts for retrieval from the OpenAlex API, corpus building, screening batches, merging, deduplication and reliability (Cohen's kappa). |
| `matlab/` | `analiza_v2.m`: all tables, tests (chi-square with Monte Carlo permutation p-values, binomial test, logistic regression, sensitivity analysis) and figures. |
| `results/`, `figures/` | Analysis output and figures. |

Abstracts are not redistributed. OpenAlex abstracts can be retrieved again with `scripts/preuzmi_openalex.ps1` and `scripts/izgradi_korpus.ps1`; Scopus records require institutional access. Script and column names are partly in Croatian (for example `ukljuciti` = include, `razina` = level, `uloga` = role).

## Selection (PRISMA 2020)

| Stage | Records |
|---|---|
| Identified: OpenAlex (2,048 + 90 extension) | 2,138 |
| Identified: Scopus (1,368 + 65 extension) | 1,433 |
| Removed before screening: duplicates | 1,393 |
| Removed before screening by automation tools (no abstract 322; no decision or management term 564) | 886 |
| Screened on title and abstract | 1,292 |
| Excluded (E1 272, E2 101, E3 51, E4 47, E5 436, E6 35) | 942 |
| Included (primary studies 240, reviews 110) | 350 |

## Coding and reliability

Screening and coding were performed by a large language model (Claude, Anthropic, model identifier claude-opus-5-5, 30 September to 1 October 2026) under the codebooks in `codebook/`. Reliability against an independent human coder (first author):

| Round | Inclusion | Decision level | Role of AI |
|---|---|---|---|
| Round 1 (n = 40, codebook v1) | κ = 0.30 | κ = 0.19 | - |
| Round 2 (n = 40, final v2 codes) | κ = 0.85 | κ = 0.88 | κ = 0.63 |
| LLM pass v1 vs v2 | κ = 0.81 (n = 1,208) | κ = 0.81 (n = 318) | κ = 0.81 |

## How to cite

Please cite the paper and this package (see `CITATION.cff`; the Zenodo DOI is shown on the repository page).

## Licence

Data and documentation: CC BY 4.0. Code: MIT. See `LICENSE`.
