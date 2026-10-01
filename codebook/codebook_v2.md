# Codebook: AI in agribusiness managerial decision-making (v2, 1 Oct 2026; v1 + clarified rules after reliability round 1)

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

## Clarified rules (v2), agreed by the authors after reliability round 1 (27 disagreements, see kappa_dogovor_runda1.csv)
R1 The decision level is the level of the concrete decision that the AI output supports, NOT the general strategic importance of AI or digitalisation for the organisation or sector.
R2 Broad reviews and overviews are coded by the dominant type of decision covered by the applications they describe (e.g. disease detection, irrigation, input dosing = O). They are not S only because they discuss the future or transformation of agriculture.
R3 Typical anchors: price or yield forecasting for sales and seasonal planning = T; production scheduling over days, routing, resource allocation in logistics = O; multi-year investment in training, human resources, land or technology = S.
R4 Food supply chains from farm to retail belong to agribusiness (I2). Household or consumer food waste is NOT an agribusiness decision (E2).
R5 Papers that only describe AI adoption, digital transformation or change management, with AI merely listed among technologies, are E5.
R6 Benchmark datasets, model accuracy reports and bibliometric analyses of technical architectures without a stated decision of an agribusiness actor are E1. Laboratory or process-chemistry studies (e.g. AI for screening solvents) are E1.
R7 Studies covering several sectors where agribusiness is only one of them and findings are not specific to it are E2.
R8 National or aggregate forecasts whose conclusions are aimed at public policy are E4, even if exporters or producers are mentioned generically.
R9 Editorials, special-issue introductions and commentaries are E6. Perspective papers in scientific journals are research papers.
R10 Role: REC when the system proposes a concrete choice (schedule, quantity, seed, fertiliser, route); INFO when it gives insight or a forecast only. AUTO only when the AI model itself executes the action; actuators driven by simple IoT rules do not make the AI role AUTO.
