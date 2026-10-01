# LLM coding prompt (codebook v2 pass, 1 October 2026)

Model: Claude (Anthropic), configured model identifier claude-opus-5-5, run as independent sub-agents, one per batch of about 110 records. Each sub-agent saw only the codebook and its batch of titles and abstracts, not earlier codes.

Prompt (identical for every batch except file names):

You are coding records for a structured literature review on AI in agribusiness managerial decision-making. Files are on the user's Windows computer, reachable through the Desktop Commander tools.
1. Read the codebook: data\codebook_v2.md. Apply it strictly, including the clarified rules R1-R10.
2. Read the input batch (title and abstract per record, each starting with "### W" or "### 2-s2.0-"). Cover every record.
3. For EVERY record apply the codebook. Judge only from title and abstract. When I3 is doubtful, exclude with E1. Do not open any other coding files.
4. Write one TAB-separated line per record in the codebook output format, no header, same order as the input, to the output file. Mark duplicate records (same paper, different id) with a note starting "Duplicate;".
5. Re-read the output and verify: line count equals record count, every id once, 11 columns.
Final reply: counts (included, primary level O/T/S, role INFO/REC/AUTO, exclusion codes) and up to 8 hard cases.
