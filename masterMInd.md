# AI Planning Prompt Template

## 1. Objective
- Analyze and harden the OneDay Flutter app so it can move from UI-heavy prototype to a production-ready community-impact platform.
- Produce an implementation plan that prioritizes reliable challenge verification, real backend data, secure configuration, test coverage, and release readiness.

## 2. Project Overview
- Project name: OneDay (`one_day` package).
- Product concept: Daily micro-challenges that create measurable local community impact.
- Current app flow:
	- App start in `main.dart`.
	- Loads `.env`, initializes Supabase.
	- Launches `OneDayApp` with onboarding page.
	- Main navigation to Explore (challenges), Impact dashboard, and Profile.
- Current stage: Early prototype / pre-MVP hardening stage.

## 3. Business Context
- Problem addressed: Low consistency in daily civic and environmental action.
- Value proposition: Convert small repeatable actions into visible impact points, streaks, and community goals.
- Initial target usage appears localized/community-oriented (Bishoftu mentioned in UI copy).
- Business dependency: Trustworthy proof verification and clear impact scoring are central to user trust.

## 4. Current System Architecture
- Client: Flutter, Material 3.
- App architecture (partial clean architecture pattern):
	- Presentation: Pages/widgets/bloc.
	- Domain: Entities + repository abstractions.
	- Data: Repository implementations (mock + Hugging Face verification).
- Backend/services:
	- Supabase initialized globally (auth/storage capabilities available).
	- Hugging Face Inference API used for image-based verification.
- Data flow (current):
	1. Challenge feed loads mock challenges.
	2. User opens challenge detail and submits image.
	3. Verification bloc calls HF repository.
	4. If verified, image proof uploads to Supabase Storage bucket `challenge_proofs`.

## 5. Tech Stack
- Flutter platform support:
	- Android
	- iOS
	- Web (browser runtime via HTML/CSS/Canvas, with WebAssembly support in newer build modes)
	- Desktop
- Web build target:
	- Flutter web compiles Dart to JavaScript (and to WebAssembly in newer modes).
- Language: Dart (SDK `>=3.0.0 <4.0.0`).
- Framework: Flutter.
- State management: `flutter_bloc`, `equatable`.
- DI tooling present: `get_it`, `injectable` (not yet integrated in app wiring).
- Networking: `http`, `dio` (currently verification uses `http`).
- Backend: `supabase_flutter`.
- Config/secrets: `flutter_dotenv` with `.env` asset.
- UI libraries: `google_fonts`, `flutter_animate`, `lottie`, `cached_network_image`, `font_awesome_flutter`.
- Tooling/linting: `flutter_lints`.

### Tech Stack Alignment Rules
- Phase 0 to Phase 2 must use the existing Flutter/Dart stack and currently declared dependencies unless a change request is approved.
- Backend/data layer must remain Supabase-first (`supabase_flutter`) with the same shared contracts consumed by all clients.
- Verification integration remains Hugging Face-based in hardening phases; improvements should focus on pipeline quality, not stack replacement.
- State management in Flutter phases must stay consistent with `flutter_bloc` patterns already used in the codebase.
- React is introduced only in Phase 3 for web implementation and must consume the same backend contracts, storage conventions, and event taxonomy.
- Any new library added in a phase must include rationale, owner, migration impact, and rollback path.

## 6. Existing Modules and Responsibilities
- `lib/main.dart`: Bootstraps env + Supabase + app.
- `lib/app.dart`: MaterialApp configuration and theme setup.
- `lib/core/theme/app_theme.dart`: Light/dark theme config.
- `lib/core/config/app_config.dart`: Exposes env-driven app config (HF key/model).
- `lib/features/onboarding/...`: First-run onboarding/entry CTA.
- `lib/features/main_page.dart`: Bottom navigation shell.
- Challenge feature:
	- `domain/entities/challenge.dart`: Core challenge entity and category enum.
	- `domain/repositories/challenge_repository.dart`: Challenge contract.
	- `domain/repositories/verification_repository.dart`: Verification contract.
	- `data/repositories/mock_challenge_repository.dart`: In-memory sample challenges.
	- `data/repositories/hf_verification_repository.dart`: HF API verification implementation.
	- `presentation/bloc/verification_bloc.dart`: Verification state/event orchestration + proof upload.
	- `presentation/pages/*`: Feed and details UX.
- `features/impact/...` and `features/profile/...`: Rich UI pages currently populated by static/mock values.

## 7. Data Sources and Data Contracts
- Current data sources:
	- Static/mock challenge list from `MockChallengeRepository`.
	- User-facing metrics in Impact/Profile are hard-coded.
	- Image verification labels from Hugging Face model output.
	- Supabase Storage used for proof image upload.
- Existing contracts:
	- `Challenge` entity fields: `id`, `title`, `description`, `category`, `imageUrl`, `impactPoints`, `verificationKeywords`.
	- `ChallengeRepository` contract: list and by-id retrieval.
	- `VerificationRepository` contract: `verifyChallengeCompletion(challengeDescription, image)`.
- Missing contracts (needed):
	- Challenge completion record schema.
	- User profile schema (XP, streak, rank).
	- Impact aggregation schema and API response DTOs.
	- Audit fields for verification decision explainability.

## 8. API Surface and Integrations
- Supabase:
	- `Supabase.initialize(...)` during app startup.
	- Storage upload on successful verification to bucket `challenge_proofs`.
	- No explicit auth/session management yet.
- Hugging Face:
	- POST to `https://router.huggingface.co/hf-inference/models/{model}`.
	- Sends base64 image as `inputs`.
	- Parses top labels and does keyword containment matching against challenge description.
- Integrations not yet implemented but implied by dependencies:
	- Firebase configuration file exists in Android project but app code does not integrate Firebase services.
	- `dio`, `get_it`, `injectable` included but currently underused.

## 9. Environment and Deployment Context
- Multi-platform Flutter targets present: Android, iOS, Web, Linux, macOS, Windows.
- Environment variables via `.env` asset expected at runtime.
- Required runtime keys:
	- `SUPABASE_URL`
	- `SUPABASE_ANON_KEY`
	- `HF_API_KEY`
- Current fallback behavior uses placeholder values for Supabase URL/key if missing, which can mask configuration issues until runtime operations fail.
- CI/CD config not visible in current repository scan.

## 10. Security and Compliance Constraints
- Secrets currently read from `.env`; ensure `.env` is excluded from source control and release artifacts where not needed.
- Potential risk: detailed debug prints in verification and storage flow may expose internal behavior; remove/sanitize for production.
- Public URL generation for uploaded proofs should be reviewed for privacy requirements (proof images may contain faces/PII).
- Need explicit data retention and deletion policy for uploaded verification media.
- If targeting minors/community programs, define consent and moderation requirements for image uploads.

## 11. Performance and Scalability Constraints
- Challenge feed currently lightweight but built on mock local data.
- HF inference round-trip can be slow; UX already includes loading overlay.
- Image upload cost/latency depends on network and file size; compression is currently basic (`imageQuality: 85`).
- No caching, pagination, or retry/backoff strategy implemented for backend calls.
- No offline strategy yet.

## 12. Reliability and Availability Requirements
- App should gracefully handle:
	- Missing env config.
	- HF API failure/timeouts/rate limits.
	- Supabase upload failures.
	- Device/network interruptions during verification.
- Verification and proof persistence should eventually be atomic from business perspective (today verification success can occur even if proof upload fails).
- Critical user journeys must be resumable where possible.

## 13. UX and Product Constraints
- UX style is already strong and intentionally designed (non-boilerplate visual language).
- Required product behaviors:
	- Fast challenge browsing.
	- Clear verification feedback with retry path.
	- Transparent points and progress updates.
- Current limitations:
	- No localization wiring despite localization dependency and ARB file.
	- Many values are static placeholders in Impact/Profile.
	- Onboarding uses gradient placeholder rather than dynamic local visual content.

## 14. Codebase Conventions
- Lints: `flutter_lints` baseline.
- Module organization mostly feature-first with domain/data/presentation split in challenge feature.
- Naming style: clear file names and typed entities; stateless/stateful widgets as appropriate.
- Conventions gaps:
	- Logging uses `print` in production code.
	- Mixed architecture maturity across features (challenge is partially layered; profile/impact are mostly UI-only).

## 15. Dependencies and Version Constraints
- Key dependencies (from `pubspec.yaml`):
	- `flutter_bloc: ^9.1.1`
	- `supabase_flutter: ^2.12.2`
	- `http: ^1.2.1`
	- `dio: ^5.3.2`
	- `flutter_dotenv: ^5.1.0`
	- `google_fonts: ^8.0.2`
	- `flutter_animate: ^4.2.0`
	- `cached_network_image: ^3.3.0`
- Potential cleanup: remove unused dependencies or adopt them consistently (`dio`, DI libs) to reduce maintenance surface.

## 16. Known Issues and Technical Debt
- `test/widget_test.dart` is still default counter template and does not match actual app UI.
- Core product data is still mock/static in key screens.
- Verification logic is heuristic and brittle:
	- Keyword match against free-form labels.
	- No thresholding strategy or model-specific postprocessing.
- Verification success does not strictly guarantee proof persistence.
- No explicit auth/user identity wiring in presented code.
- No repository implementation for real challenge feed backend.
- Localization file exists but not integrated into `MaterialApp` delegates/locales.

## 17. Non-Goals and Out-of-Scope Items
- Building a complete social network layer (chat, follows, complex moderation) in first hardening phase.
- Advanced ML model training/custom model deployment inside this repo.
- Full redesign of existing polished UI.
- Migrating to a different framework/backend unless blocked by hard requirements.

## 18. Assumptions
- Supabase project and storage bucket provisioning are available or will be provisioned.
- HF API key has sufficient quota for expected MVP verification volume.
- Challenge verification accuracy can initially be improved via better prompts/rules and metadata before model replacement.
- First releases prioritize mobile (Android/iOS), while desktop/web parity can follow.

## 19. Risks and Trade-Offs
- Risk: false positive/negative verification can undermine trust.
	- Trade-off: strict verification reduces abuse but may frustrate users.
- Risk: storing proof images can create privacy/legal obligations.
	- Trade-off: keeping evidence improves auditability.
- Risk: heavy UI progress with limited backend grounding can delay reliable launch.
	- Trade-off: strong visual prototype helps product validation and stakeholder buy-in.
- Risk: dependency sprawl without usage increases upgrade burden.

## 20. Success Criteria
- Functional:
	- Real backend-driven challenge feed and completion tracking.
	- Deterministic verification pipeline with measurable pass/fail quality.
	- Impact/Profile values sourced from user data, not static constants.
- Quality:
	- No placeholder/default tests failing or misleading.
	- Unit + widget tests cover critical flows.
	- App handles common error states with user-friendly messages.
- Operational:
	- Environment setup documented and validated.
	- Release checklist and rollback plan established.

## 21. Required Deliverables
- Architecture hardening doc (target-state modules and data flows).
- Supabase schema + storage policy design.
- Backend repository implementations (challenge feed, profile, impact summaries).
- Improved verification service logic and error handling.
- Test suite for repositories, bloc, and critical pages.
- Release readiness checklist (security, logging, env, monitoring).

## 22. Validation and Testing Plan
- Unit tests:
	- Verification repository response parsing + edge cases.
	- Verification bloc state transitions on success/failure/upload errors.
	- Challenge repository data mapping from backend DTOs.
- Widget tests:
	- Onboarding to main navigation flow.
	- Challenge feed loading/error/list states.
	- Challenge verification UI states and dialogs.
- Integration tests:
	- End-to-end verify-and-upload flow with mocked network.
- Static checks:
	- `flutter analyze`
	- `flutter test`
- Replace/remove obsolete template test that asserts nonexistent counter behavior.

## 23. Rollout Strategy
- Phase 0: Foundation lock (shared backend and contracts).
	- Stack scope: Flutter/Dart + Supabase + existing repository contracts (no platform/framework expansion).
	- Freeze Supabase schema, RLS policy strategy, and repository interfaces used by all clients.
	- Finalize verification decision contract (pass/fail/reason/confidence/pending-upload).
	- Exit criteria: shared API/data contracts approved and versioned.
- Phase 1: Android-first production completion (Flutter Android).
	- Stack scope: Flutter Android app, `flutter_bloc` state management, `supabase_flutter`, existing verification service.
	- Prioritize Android user journey end-to-end: onboarding -> challenge -> verify -> proof upload -> impact/profile updates.
	- Replace mock/static data with live Supabase-backed repositories.
	- Harden Android reliability: retries, timeout handling, resumable proof upload state.
	- Exit criteria: Android beta build passes QA checklist, crash-free core flow, telemetry active.
- Phase 2: Web parity using existing Flutter codebase (Flutter Web).
	- Stack scope: same Flutter/Dart codebase compiled for web; same Supabase and verification contracts.
	- Recreate Android-complete behavior on Flutter Web with same business rules and API contracts.
	- Adapt platform-specific pieces (image picking, upload limits, responsiveness, auth/session persistence).
	- Validate verification UX and fallback behavior for browser constraints.
	- Exit criteria: Flutter Web reaches functional parity for core flows and passes web-specific QA.
- Phase 3: React web implementation (new client, same backend contracts).
	- Stack scope: React web client only; backend/services remain Supabase + existing verification API contracts.
	- Build React frontend using the same Supabase tables, storage conventions, and verification API contract.
	- Recreate UX intent and feature parity in staged increments (Explore -> Challenge detail -> Verification -> Impact/Profile).
	- Reuse observability taxonomy and analytics event names to keep cross-platform comparability.
	- Exit criteria: React web MVP matches agreed parity scope and can run in parallel A/B with Flutter Web.
- Phase 4: Consolidation and launch strategy.
	- Decide long-term web client (Flutter Web vs React) based on performance, maintainability, and team velocity.
	- Execute phased rollout: internal alpha -> limited beta -> public release.
	- Maintain rollback-ready releases for Android and chosen web client.

## 24. Observability and Monitoring
- Replace `print` debug logs with structured logging strategy.
- Track events:
	- Challenge viewed.
	- Verification started/succeeded/failed.
	- Upload succeeded/failed.
	- API latency and error categories.
- Add health metrics dashboard for:
	- Verification pass rate.
	- False rejection reports.
	- Upload failure rate.
	- Daily active users and completion counts.

## 25. Failure Handling and Rollback Plan
- Verification API failure: show retryable UI and queue optional delayed retries.
- Upload failure after verification: mark completion as pending media sync and retry in background.
- Bad release rollback:
	- Maintain previous stable build artifacts.
	- Feature-flag new verification logic when possible.
	- Revert to fallback mock/local mode only for internal testing, not public production.

## 26. Open Questions
- What is the required verification precision/recall threshold for launch?
- Should proofs be private by default with signed URLs instead of public URLs?
- What is the authoritative scoring formula for impact points and streak logic?
- Is anonymous usage allowed, or is authenticated user identity mandatory?
- Which geographies/languages are in scope for v1 localization?
- Are there moderation workflows for inappropriate uploaded images?

## 27. Requested Output Format from AI
- Provide output in these sections:
	1. Executive summary (max 10 lines).
	2. Priority backlog (P0/P1/P2) with effort estimates.
	3. Proposed architecture changes with diagram-friendly bullet points.
	4. Data model and API contract proposals.
	5. Test plan and acceptance criteria.
	6. Risks with mitigation and decision log.
	7. 30/60/90 day execution roadmap.

## 28. Step-by-Step Execution Plan
1. Phase 0 - Contract baseline:
	- Run `flutter analyze` and `flutter test`; remove obsolete template tests and fix red checks.
	- Define canonical backend contracts for challenges, completions, profiles, and impact summaries.
	- Confirm stack lock document for Phases 0 to 2 (Flutter/Dart + Supabase + HF + Bloc).
2. Phase 1 - Android hardening:
	- Implement Supabase-backed repositories for challenge feed, profile, and impact pages.
	- Harden verification with thresholds, explainable results, and upload consistency states.
	- Replace `print` logs with structured logging and event instrumentation.
	- Keep architecture and dependencies aligned with existing Flutter stack; defer web framework changes.
3. Phase 1 - Android release readiness:
	- Wire localization delegates and externalize remaining hard-coded strings.
	- Complete Android QA matrix (offline, flaky network, API failures, media upload retry).
	- Ship Android closed beta and monitor verification/upload error rates.
4. Phase 2 - Flutter Web parity:
	- Port Android-complete logic to web-safe adapters (image input, auth persistence, upload constraints).
	- Optimize responsive layouts and browser-specific error handling.
	- Run parity test suite and web smoke tests in CI.
5. Phase 3 - React web rebuild:
	- Create React app against same Supabase schema and contract definitions.
	- Implement feature slices in sequence: auth/session, challenge feed, verification flow, impact/profile.
	- Add contract tests to verify consistent response handling between Flutter and React clients.
	- Keep React scope parity-focused; no backend contract drift from Flutter clients.
6. Phase 4 - Convergence and launch:
	- Compare KPIs (load time, conversion, verification success, maintenance cost) for Flutter Web vs React.
	- Select primary web client and execute staged production rollout with rollback plan.

## 29. Review Checklist
- [ ] All hard-coded product metrics replaced by live or clearly marked mock data.
- [ ] Challenge verification behavior documented and test-covered.
- [ ] Proof storage privacy/access policy approved.
- [ ] Env configuration validated for all target platforms.
- [ ] Obsolete default Flutter tests removed or rewritten.
- [ ] `flutter analyze` and `flutter test` passing.
- [ ] Launch risks reviewed with mitigation owners.

## 30. Final Prompt
You are assisting on the OneDay Flutter app, a daily community-impact challenge platform currently in prototype stage. The app already includes polished onboarding/challenge/profile/impact UIs, partial clean architecture in the challenge feature, Supabase initialization, Hugging Face image verification, and proof image upload to Supabase Storage. However, major gaps remain: mock/static data in core screens, brittle verification heuristics, weak error handling consistency, incomplete localization wiring, legacy template tests, and limited observability.

Using the project context below, generate an implementation-ready technical plan that prioritizes production hardening while preserving the current UX direction.

Project facts to use:
- Flutter + Dart app with `flutter_bloc`, `supabase_flutter`, `http`, `flutter_dotenv`, `google_fonts`, `flutter_animate`.
- Startup loads `.env`, initializes Supabase, and launches onboarding.
- Challenge flow: feed -> details -> image pick -> HF verification -> optional Supabase Storage upload.
- Current challenge repository is mock-based; impact/profile data is static in UI.
- Existing contracts: `Challenge`, `ChallengeRepository`, `VerificationRepository`.
- Existing risks: verification quality, privacy around proof images, missing auth/business consistency, debug logging in production code.

Output requirements:
1. Executive summary.
2. Prioritized backlog (P0/P1/P2) with rationale and rough effort.
3. Target architecture updates (presentation/domain/data/backend boundaries).
4. Supabase schema and API contract proposal for challenges, completions, profiles, impact summaries.
5. Verification pipeline redesign (accuracy, explainability, fallback behavior).
6. Security/privacy controls and storage policy recommendations.
7. Test strategy (unit/widget/integration) with concrete test cases.
8. Rollout plan (beta to production), observability metrics, and rollback strategy.
9. Explicit assumptions, open questions, and decision trade-offs.
10. Phase plan must explicitly sequence delivery as: Android first, then Flutter Web parity, then React web implementation.
11. Every recommendation must explicitly align with the declared tech stack for that phase and flag any proposed stack deviation.
