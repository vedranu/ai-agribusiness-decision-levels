# Codebook: AI in agribusiness managerial decision-making (v1, 30 Sep 2026)

## Screening (title + abstract)
INCLUDE only if ALL hold:
- I1 An AI method (machine learning, deep learning, neural networks, AI-based decision support / expert system, generative AI) is developed, applied, evaluated or systematically reviewed.
- I2 The context is agribusiness: farms as businesses, agri-food firms, cooperatives, agricultural or food supply / value chains, agricultural markets.
- I3 The AI output is explicitly used (or proposed) to inform or make a decision of an agribusiness actor (farmer/farm manager, agri-food firm manager, supply chain manager).
EXCLUDE (give code):
- E1 purely technical: model/sensor/algorithm accuracy with no decision or management use stated
- E2 not agribusiness (health, general manufacturing, forestry, fisheries, non-food sectors, general food science)
- E3 laboratory food quality / safety / authenticity detection without a managerial decision
- E4 public policy / government / macro-level decisions only (no agribusiness actor)
- E5 AI not really used (AI only mentioned; other methods are the core)
- E6 not a research paper (editorial, erratum, book review) or content unclear

## Coding (included records only)
LEVELS (Anthony 1965; Simon 1960). Code all levels present, then the primary level.
- O operational: short horizon (hours to weeks), structured, repetitive execution of tasks. E.g. irrigation scheduling, fertiliser/pesticide dosing, pest or disease treatment, harvest timing, machinery control, feeding, grading/sorting, routing, inventory replenishment, daily yield/price monitoring.
- T tactical: medium horizon (a season to about 2 years), semi-structured allocation of resources within a given strategy. E.g. seasonal production and crop planning, procurement and supplier selection, demand/price forecasting for planning, sales and pricing planning, workforce and capacity planning, seasonal credit/insurance risk decisions.
- S strategic: long horizon (multi-year), unstructured, whole-organisation direction. E.g. investment and technology adoption strategy, market entry, business model, product portfolio, land-use change, supply chain network design, sustainability strategy, competitive positioning.
ROLE of AI in the decision process:
- INFO: provides descriptive/predictive information (monitoring, detection, forecasting); the human interprets and decides
- REC: prescriptive; recommends or optimises a specific choice; the human approves
- AUTO: the system executes the decision autonomously (closed loop / autonomous control)
DOMAIN: CROP (crop production), LIVE (livestock/dairy), SCM (supply chain and logistics), MKT (markets, pricing, demand, marketing), FIN (finance, credit, insurance, risk), PROC (food processing / manufacturing operations), FARM (whole-farm management), SUST (sustainability, resources, emissions)
TECHNIQUE: ML (classical machine learning), DL (deep learning/neural networks), DSS (AI-based DSS / expert / fuzzy systems), OPT (AI combined with optimisation / metaheuristics), GEN (generative AI / LLM), HYB (hybrid or mixed)
STUDY: EMP (empirical application / model on data), CON (conceptual / framework / qualitative), REV (literature review)
ACTOR: FARMER, FIRM (agri-food company or cooperative), SC (multiple supply chain actors), MIX

## Output format (one TAB-separated line per record, no header, in the same order as the input)
id	include(1/0)	excl_code(or -)	levels(e.g. O;T)	primary_level	role	domain	technique	study	actor	note(max 12 words)
For excluded records fill the coding columns with -.
