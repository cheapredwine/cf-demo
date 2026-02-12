# TELEPROMPTER — Cloudflare AppSec Demo

---

## 0:00 – OPENING

Apologize for AE absence — unavoidable conflict

"Before we get into your specific challenges, let me set the stage with what makes this platform different."

### Cloudflare Global Network

*Advance to network slide.*

**Say 3 numbers:** 335+ cities, 449 Tbps, ~20% of Internet traffic.

**Architecture:** Every server runs every service. No separate scrubbing centers. One server handles DDoS, WAF, bot scoring, API validation, rate limiting — all in one pass. Composable, zero added latency.

**Built in-house:** Every service built in-house, on commodity hardware. Shared data models, shared rules engine, shared threat intel. Competitors bolt on acquired bot/API/client-side tools — you feel the seams. "Here, there are no seams."

### What We Heard

*Advance to "What We Heard" slide.*

"Now with that context — let me make sure we're aligned on the problem."

**4 pain points:**
- Bot attacks → flash sale conversions dropped 2% → 0.5%, traffic tripled
- API sprawl → 33% more endpoints than you realize
- Client-side supply chain → PCI 4.0 now enforceable (6.4.3 & 11.6.1)
- DDoS during peak → summer flash sale outage cost ~$200K in 4 hours

"Does that capture it? Anything shifted in priority?"

---

## START OF DEMO

### Request Journey — What Happens When a Customer Hits Your Site

**DNS** → domain resolves to Cloudflare, not your origin. Every request lands on CF first.

**HTTPS** → SSL terminated at the edge. TLS 1.3. Secure connection back to origin.

**Security stack inline** → DDoS, WAF rules, bot scoring, API validation, rate limiting — all before traffic touches your infrastructure. Clean traffic forwarded. Everything else handled at the edge, within 50ms of the user.

### Account Overview

**Open:** Analytics & Logs > Account Analytics

"10,000-foot view — aggregate traffic across all domains."

**Log Explorer** = mini SIEM. **Logpush** for Splunk/Datadog. "Nothing is a black box."

**Account Security Analytics** — traffic across all zones, spot cross-domain attack patterns
**Account WAF** — one rule, deployed to every zone at once, propagated in seconds

**Platform:** Workers (compute), R2 (storage), Images (edge optimization). **Turnstile** — CF's CAPTCHA replacement, alternative to reCAPTCHA. Privacy-first, one JS snippet, invisible. Free. Works alongside Bot Management.

**Zero Trust** = separate conversation, same network + dashboard.

### Manage Account

**Members** → RBAC: SOC gets security, devs get zone-level, finance gets billing
**Notifications** → DDoS, cert expiry, origin health. Webhooks → Slack, PagerDuty
**Configurations > Lists** → reusable IP/hostname/ASN lists across all rules, all domains. **Managed Lists** — CF-curated: open proxies, botnets, Tor exit nodes. Auto-updated.

### Click Into Domain — Onboarding

**Click domain from account home.**

"Getting traffic onto CF — point nameservers to us or CNAME specific hostnames. Once traffic flows, everything lights up."

### SSL/TLS

**Open:** SSL/TLS

"First thing once traffic arrives." CF auto-issues and renews certs — or upload your own. TLS terminated at edge, TLS 1.3 by default. Easy.

### Performance — Tiered Caching

**Open:** Caching

"Speed is revenue for e-commerce."

Static content cached at 335+ DCs. **Tiered Cache** = hierarchy so origin gets a handful of requests instead of 335 DCs asking independently.

"Flash sale, millions loading same pages — this is why your origin doesn't fall over."

---

## 2:00 – WAF & BOT MANAGEMENT

### Security Overview — Starting Point

**Open:** Security > Overview

"First thing you'd see every morning. CF scans your zone, surfaces prioritized suggestions."

**Click All Suggestions tab** — scroll through. Detected attacks, risks, misconfigurations. One-click fixes.

"Not just reacting to attacks — proactively telling you where your gaps are."

### WAF Managed Rules

**Open:** Security > WAF > Managed rules → **Browse Rules** on Cloudflare Managed Ruleset → **scroll to bottom to show rule count**

"Before bots — the foundation everything sits on"

**Cloudflare Managed Ruleset** — enable with one click. The zero-day one. New vuln drops, CF pushes a rule globally within hours. Plus **OWASP Core Ruleset** available to deploy. You choose which to enable, tune individual rules. Auto-updating.

**Open:** Security > Settings > Detection Tools

**Sensitive Data Detection** — scans outbound for passwords, API keys, CC#s

### Bot Management & Account Takeover Demo

"How WAF, bot scoring, and credential detection work together"

**Open:** Security > Analytics > Bot Analysis

Every request gets a bot score 1–99. Multiple engines: ML (60M req/sec), behavioral, fingerprinting. All invisible. No CAPTCHAs.

**Build rule live:** Security > Security rules
- score < 30 + login path + leaked credentials → **Managed Challenge**
- `(cf.bot_management.score lt 30 and http.request.uri.path contains "/api/v1/auth/login" and cf.waf.credential_check.username_and_password_leaked)`

"Propagates globally in under 30 seconds. That's composability — WAF, bot, and credential signals in one rules engine."

*Navigate to Security > Bots > AI Crawl Control.*

**AI Crawl Control:** Dashboard shows which AI crawlers are hitting your site and how often. Block, allow, or charge per crawl.

**Transition:** "Do you have visibility into how much traffic is automated today?"

---

## 6:30 – API SECURITY

"How many API endpoints does your team track today?"

*(Let them answer)*

"Orgs have 33% more public endpoints than they know about"

**Open:** Security > Web assets

### Discovery
- ML-based, passive, finds undocumented endpoints
- Shows traffic volume, methods, auth status

### Schema Validation — Positive Security Model

"Upload or we learn your OpenAPI schema — we enforce it. Define what good looks like, reject everything else."

Malformed request, undocumented parameter, wrong type → blocked before it reaches origin.

### Shadow API — LIVE DEMO

**▶ HIT /api/v1/admin/users** → show response comes back (wide open)

"Admin emails, roles, last login timestamps. Your team may not know this exists."

**Create fallthrough rule:** Security > Web assets → action = Block for any endpoint not in schema → enable

"Let me fix that right now. One toggle."

**▶ HIT /api/v1/admin/users again** → show blocked response

"Blocked. Same endpoint — now rejected. Shadow APIs eliminated in seconds."

**Open:** Security > Analytics (Events) → filter by Service = Custom rules → show the block

### Rate Limiting & Sequence Mitigation
- Auto-recommended rate limits per endpoint
- Sequence enforcement: browse → cart → checkout
- Skip steps = anomalous → flag or block

**Transition:** "This gap between known and actual API surface surprises most security teams."

---

## 11:00 – PAGE SHIELD & PCI 4.0

"Most time-sensitive issue — PCI 4.0 is now enforceable"

**Requirements:** inventory all scripts, justify each, ensure integrity, detect changes

**Open:** Security > Web assets > Client-side resources

**How it works:** lightweight CSP in report-only → browsers report back → full inventory in hours

We flag malicious scripts, alert on changes, enforce a real CSP. Inventory → detection → alerting → enforcement — one dashboard.

"Direct path to PCI 6.4.3 and 11.6.1. No additional vendor."

**Key stat:** "30% of all 2025 data breaches linked to third-party vendors"

*(Pause here — compliance stakeholders often lean in)*

---

## 14:30 – DDoS & PEAK PROTECTION

"Your CFO and VP eCommerce care most about this one"

**Open:** Security > DDoS

449 Tbps — largest attacks are a fraction of that. Every DC runs full mitigation. Volumetric = automatic, zero config, unlimited, no surge pricing. App-layer = autonomous edge.

"On by default — zero rules. Sensitivity tuning available if needed."

**Open:** Security > Waiting Room

Fair branded queue at the edge. Configure path (e.g. `/checkout`), session limits, branded queue page. Dynamic admission based on origin capacity. No crashed checkout, no oversold inventory.

**⬅ Switch back to slide deck → advance to "Firewall for AI" slide**

---

## 16:00 – FIREWALL FOR AI

"Your LLM chatbot and NL search introduce a different class of risk"

"Traditional APIs accept structured data. LLMs accept free text. That opens the door to:"
- Prompt injection (OWASP #1 for LLMs)
- PII in prompts → ends up in logs/training
- Toxic content in your brand's voice

**3 capabilities:**
- **PII detection** — NER at edge, catches CC#s, SSNs, phones
- **Prompt injection scoring** — 1–99, same concept as bot scores
- **Content moderation** — Llama Guard, safety categories

"Same WAF rules engine. Same dashboard. One platform."

**Shadow AI discovery** — finds LLM endpoints your team doesn't know about

"This is the ideal time — enable in log-only during beta, have policies ready before production"

---

## 18:00 – SUMMARY & CLOSE

*Advance to Summary slide.*

### What We Saw

- **Platform** — Workers, R2, Images, account-wide rules, RBAC, webhooks, Log Explorer
- **Onboarding** — nameservers or CNAME → SSL auto-issued → Tiered Cache protects origin
- **WAF** — Managed Rulesets (zero-day), ATO protection, Sensitive Data Detection
- **Bots** — ML scoring, Turnstile, AI Crawl Control
- **API** — Discovery, schema validation, shadow API blocking
- **Page Shield** — script monitoring, PCI 4.0 compliance
- **Firewall for AI** — PII, prompt injection, content safety
- **DDoS** — 449 Tbps, Waiting Room

"One network, one dashboard, one vendor. Rules are composable, threat intel is shared, logging feeds one place."

### What CF Helps You Do

- Protect revenue windows — stop bots crashing flash sales
- Eliminate API blind spots — discover, enforce, block shadows
- PCI compliant before next audit — zero code changes
- Secure AI before production — guardrails in beta
- Survive any traffic spike — DDoS + Waiting Room
- Consolidate — replace aging WAF + 5 tools with one platform

### Next Steps

*Advance to Next Steps slide.*

1. **POV** — log-only mode, traffic flowing in a day, visibility in 48 hours
2. **PCI call** — 30 min with your auditor + our compliance team
3. **Firewall for AI beta** — enable on your zone now
4. **Peak modeling** — rate limiting + DDoS config for summer sale

"Sound like a plan?"
