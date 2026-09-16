---
name: job-application
description: Analyze a job description and collaboratively create or tailor a truthful resume and optional cover letter using Jonathan Newton's career evidence bank. Use when evaluating a specific role, matching career evidence to a JD, drafting application materials, or reviewing a tailored resume. Do not use for general job discovery or application submission.
---

# Job Application Orchestrator

Turn a specific job description into evidence-backed application materials through an interactive workflow. The user remains the decision-maker; do not silently complete the entire application when useful evidence discovery or a material choice remains.

## Start with the job description

Accept a public JD URL, pasted text, PDF, or document. Retrieve and read the complete posting when a URL is provided. If the posting is inaccessible or incomplete, ask the user to paste or attach it rather than inferring missing requirements.

Before analyzing career evidence, identify:

- Core responsibilities and likely day-to-day work
- Required and preferred qualifications
- Technologies, architecture, product domain, and seniority signals
- Business outcomes and problems the employer appears to value
- Potential concerns, ambiguities, or interview questions

Distinguish facts stated in the JD from reasonable inferences.

Before matching career evidence, have the strategy-side hiring-manager analyst perform a bounded company-research pass when current web research is available. The research should:

- Prefer official company, product, customer, careers, engineering, announcement, and relevant public-filing sources.
- Use approximately three to five sources and stop once the business, customers, relevant direction, and likely purpose of the role are sufficiently clear.
- Use a reputable external source only when official sources leave a material role-related gap.
- Separate cited verified facts, role-relevant inferences, and unresolved unknowns.
- Exclude generic company history, anonymous culture claims, unrelated news, employee research, and marketing language that does not change the application strategy.

Company research may shape role interpretation, evidence priorities, positioning, discovery questions, and cover-letter advice. It is never candidate evidence and must not be used to manufacture alignment. If current research is unavailable, proceed from the complete JD and disclose that limitation.

## Retrieve evidence progressively

Always read [references/evidence/INDEX.md](references/evidence/INDEX.md) first. It contains the fixed employment chronology, resume-treatment rules, evidence statuses, routing terms, and links to individual role files.

Use the JD themes to search the index and evidence library. Open only the role files relevant to the target role. Do not load every evidence file by default.

Treat the evidence bank as the factual boundary:

- Use `confirmed` evidence freely when relevant.
- Use `source-supported` evidence conservatively and preserve its actual scope.
- Ask for missing context when an item is marked `needs-detail` or could become materially stronger with ownership, scale, outcome, or metrics.
- Never use `unverified` material as a resume claim.
- Never transform a JD requirement, inference, or plausible technology into career evidence.

## Required interactive checkpoint

Before drafting a resume, discuss the proposed evidence with the user. Present:

1. The strongest experience matches and why they are relevant.
2. Promising but incomplete evidence that may benefit from the user's recollection.
3. Material gaps or requirements that should not be claimed.
4. A preliminary recommendation for positioning the candidate.

Ask one to three focused questions at a time. Favor prompts such as: “This experience appears closely related because ____. What other work from that project might demonstrate ____?”

Continue the evidence discussion until the user approves the selected direction. Do not draft the resume before approval unless the user explicitly requests a one-pass or non-interactive result.

Add newly discovered facts to application materials only after the user confirms them. Updating the permanent evidence bank requires the user's explicit approval.

## Content-first role loop

For collaborative applications, approve resume content role by role before trying to fit the page or edit a document. Start with complete, understandable bullets and ask focused questions until ownership, scope, status, and purpose are clear. A bullet should communicate a real contribution to a recruiter without requiring an interview-level architecture explanation.

- Allocate space according to evidence strength, tenure, and project maturity rather than title alone. Very recent roles or in-progress work usually need only one or two distinct bullets.
- Keep separate projects separate, but do not create multiple bullets that restate the same workflow with different technical nouns.
- Prefer plain-language system behavior and business purpose in resume bullets. Preserve mechanisms such as retry policy, idempotency, dead-letter handling, cache design, and detailed failure modes for technical interviews unless the JD makes one essential to the screen.
- Record an explicit priority order and first-cut bullet for each role when space is likely to be tight.
- Do not begin formatting or one-page compression until the user approves the role content and skills panel.

### User-controlled resume formatting

Jonathan normally preserves and edits his own resume document. Unless he explicitly asks Codex to create or modify a DOCX or PDF:

- Present one section at a time for approval: professional summary, then each role in reverse chronology, then skills, and any optional cover letter.
- Give finished copy for Jonathan to paste into his existing document. Do not create, edit, render, or pre-compress a resume file while content is still being approved.
- Treat page fit as Jonathan's formatting step. Identify a content-priority order and likely cuts, but do not shrink type, alter spacing, or rewrite approved prose solely to force an unseen document onto one page.
- After all sections are approved, ask Jonathan to generate the final PDF and upload it. Treat that returned PDF as the layout authority and verify page count, visual integrity, text extraction, chronology, filename, and application-specific requirements before final evaluation.
- If Jonathan instead explicitly asks Codex to produce the artifact, follow the document-generation and render-verification workflow below.

## Build a bounded evidence packet

After the interactive checkpoint, assemble a job-specific working packet containing:

- JD facts and prioritized requirements
- Selected career evidence with employer and evidence status
- User-confirmed additions from the discussion
- Explicit exclusions and unsupported claims
- Recommended positioning, skills emphasis, and bullet priorities
- Open questions that remain unresolved

Pass this bounded packet to workers. Do not pass the entire career archive unless a worker genuinely requires it.

## Draft and review

Use these stages in order once the relevant custom agents exist:

1. **Strategy-side hiring-manager analysis (`job_hiring_manager_analyst`):** Perform the bounded company-research pass, assess what the employer is likely screening for, and rank the available evidence from the employer's perspective. This worker may use the complete JD, bounded evidence packet, and current company sources. It is not the blind final evaluator.
2. **Resume writing (`job_resume_writer`):** Tailor the summary, skills, and experience bullets while preserving the required chronology and factual boundaries.
3. **Evidence-aware resume review (`job_evidence_reviewer`):** Check evidence fidelity, JD alignment, clarity, chronology, and unsupported wording. This reviewer may use the bounded evidence packet and returns actionable findings before rewriting.
4. **Cover letter (`job_cover_letter_writer`):** Draft only when the user requests one or the application materially benefits from explaining motivation, a transition, or an unusually strong connection.

Cover letters should default to roughly 150-200 words and three short paragraphs. Use no more than one or two supporting examples, and do not convert the resume into prose or recap each recent employer. The letter's primary job is to add motivation, transition context, or company connection that the resume cannot show. Expand beyond 225 words only when the user or application explicitly calls for a longer letter.

Resume drafting is meaning-first. The writer may identify likely overflow and propose cuts, but must not pre-compress approved evidence into jargon-heavy fragments merely to predict one-page fit. The orchestrator should bring complete content through evidence review, then reduce it with the user using the approved first-cut priorities.

Until a custom worker exists, perform that stage directly and label the role it represents. Do not pretend that an unconfigured worker ran.

Use subagents only for bounded work that benefits from independent analysis. The orchestrator owns user interaction, resolves disagreements, and presents the consolidated result. Workers must not independently change the evidence bank or final application files.

## Independent two-part evaluation gate

After the resume and any cover letter are drafted and evidence-aware review is complete, run two context-isolated evaluations. These evaluators must be new workers that did not participate in strategy, evidence selection, drafting, or revision.

### Part 1: Application screening reviewer

Use the `job_application_screener` worker.

Provide only:

- The complete JD
- The drafted resume
- The drafted cover letter, if one exists

Do not provide the evidence bank, evidence packet, user discussion, writer rationale, previous reviews, or intended positioning.

The screening reviewer should simulate the initial automated and human screening layer. It must assess:

- Whether required and preferred qualifications are visible in the submitted materials
- Whether terminology and evidence are likely to survive keyword, recruiter, and quick-scan filtering
- Whether chronology, titles, formatting, or unclear claims create screening risk
- Which important qualifications appear absent, buried, vague, or unsupported on the page
- A clear advance, borderline, or reject recommendation with reasons

This is an independent evaluation, not a rewriting task. It may recommend changes but must not edit the materials.

### Part 2: Blind hiring manager

Use the `job_blind_hiring_manager` worker.

Provide only the same employer-visible materials: the complete JD, resume, and optional cover letter. Do not provide the screening review or any hidden candidate context.

The blind hiring manager should decide whether to interview the candidate based solely on those materials. It must report:

- Interview or no-interview decision
- Strongest reasons to advance the candidate
- Concerns, doubts, or missing evidence
- Likely interview questions
- Overall perceived level, fit, and credibility

The blind hiring manager must not fill gaps using assumptions, inferred career evidence, or knowledge from the orchestrator.

Run both evaluations independently before comparing their results. The orchestrator should then present agreements, disagreements, and recommended revisions to the user. Do not revise automatically. After the user approves material revisions, run one final blind evaluation pass; avoid open-ended review loops.

## Resume invariants

Follow the exact chronology and bullet-treatment rules in the evidence index. In particular:

- Every resume must render as exactly one page. This is non-negotiable.
- All five software-industry positions must appear in reverse chronological order to preserve the 10+ year career narrative.
- Ryan Specialty, Sitation, and WebPros always receive bullets.
- DecoArt defaults to no bullets but may receive them when materially relevant.
- eLink Design almost always has no bullets and receives them only exceptionally.
- Solve space constraints without removing or reordering positions.

When content exceeds one page, compress it in this order:

1. Remove the user-approved first-cut bullets and other lower-priority or repetitive bullets while retaining at least one bullet for Ryan Specialty, Sitation, and WebPros.
2. Tighten wording only where the bullet still preserves the problem or purpose, the candidate's contribution, and any meaningful result. If tightening would turn it into word soup or a technology inventory, remove the bullet instead.
3. Reduce summary and skills content to the most relevant material.
4. Remove optional DecoArt or eLink bullets.
5. Adjust spacing and typography conservatively while preserving professional readability.

Do not satisfy the one-page requirement with unreadably small type, extreme margins, clipped content, hidden text, or by removing any of the five required positions.

Skills categories must be semantically coherent. Never combine unrelated tools with slashes or pairings merely to save vertical space. Prefer removing a lower-priority skill over creating labels such as `Datadog / Selenium` or `PHP / Composer` that obscure what the items mean. Advertise durable, interview-ready skills; project-specific implementation details may remain in experience bullets without appearing in the general panel.

Tailoring may change bullet selection, emphasis, ordering within a role, summary language, and skills. It may not change employers, titles, dates, factual ownership, project status, or outcomes without confirmed evidence.

## Final approval and artifacts

Show the user the proposed content and any reviewer findings before producing final files. Clearly identify unresolved questions or deliberately omitted requirements.

When generating a resume document:

- Preserve the user's selected resume format unless the user approves a redesign.
- Treat formatting-heavy DOCX templates that rely on direct run formatting, tables, text boxes, or positioned elements as fragile. Prefer exact in-place text-node substitutions. Do not reconstruct paragraphs or runs merely to replace prose; if faithful surgical editing is not practical, provide approved content for the user to place and treat the returned file as authoritative.
- Never repeatedly overwrite the same user-facing filename while iterating. Use unique working files and expose only a stable reviewed deliverable.
- Use the relevant document-generation workflow and visually verify the final artifact.
- Confirm from the rendered output that the resume is exactly one page. A resume is not complete while it renders as zero pages, more than one page, or contains clipped or overflowed content.
- When the user supplies the final PDF, treat that PDF as the layout authority. Verify its actual page count, visual integrity, and text layer even if an earlier DOCX renders differently in another engine.
- Do not create a cover letter automatically.
- Do not submit an application, contact an employer, or change an external system without explicit authorization.
