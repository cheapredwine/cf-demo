# PeakCart API — Agent Instructions

## Overview

This is a **demo API** for Cloudflare API Shield demos. It simulates a headless e-commerce API with both documented endpoints (defined in OpenAPI schema) and shadow/undocumented endpoints for testing API security features.

## Architecture

- **Runtime**: Cloudflare Workers (edge JavaScript)
- **Router**: Simple pattern matching on URL pathname + HTTP method
- **Data**: In-memory product catalog (no external database)
- **CORS**: Enabled for all origins (demo purposes)

## File Structure

```
.
├── src/index.js          # Main worker code (single file)
├── peakcart-schema.yaml  # OpenAPI 3.0 schema (for API Shield)
├── wrangler.toml         # Cloudflare Workers config
├── package.json          # Dependencies (just wrangler)
└── doc/                  # Demo scripts and documentation
    └── 021222061517/
        ├── demo-teleprompter.md      # Demo script
        └── api-shield-demo-setup-guide-windows.md

# Traffic generation scripts
├── create-validtraffic.ps      # Normal API traffic (PowerShell)
├── create-validtraffic.sh      # Normal API traffic (Bash)
├── create-invalidtraffic.ps1   # Schema violations (PowerShell)
├── create-invalidtraffic.sh    # Schema violations (Bash)
├── create-shadowtraffic.ps1    # Shadow API probing (PowerShell)
└── create-shadowtraffic.sh     # Shadow API probing (Bash)
```

## Documented Endpoints (in OpenAPI schema)

These endpoints are in `peakcart-schema.yaml` and should pass schema validation:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/products` | List all products (optional `?category=` filter) |
| GET | `/api/v1/products/{id}` | Get single product by ID |
| POST | `/api/v1/cart/add` | Add item to cart (body: `{product_id, quantity}`) |
| GET | `/api/v1/health` | Health check |

## Shadow/Undocumented Endpoints (NOT in schema)

These simulate legacy or forgotten endpoints for API Shield fallthrough demos:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/admin/users` | Lists admin users (sensitive) |
| GET | `/api/v1/admin/config` | Exposes config including DB host |

## Development Commands

```bash
# Local development
npm run dev

# Deploy to Cloudflare
npm run deploy

# View live logs
npm run tail
```

## Deployment

The API is deployed via Wrangler (not GitHub Actions):

1. Ensure you're authenticated: `wrangler login`
2. Deploy: `wrangler deploy` or `npm run deploy`
3. Optional: Configure custom domain in `wrangler.toml`

## Demo Flow

1. **Valid traffic**: Run `create-validtraffic.ps` to generate baseline traffic
2. **Invalid traffic**: Run `create-invalidtraffic.ps1` to trigger schema violations
3. **Shadow traffic**: Run `create-shadowtraffic.ps1` to probe undocumented endpoints
4. **API Shield setup**: Upload `peakcart-schema.yaml` to Cloudflare, enable fallthrough rule
5. **Show results**: Shadow endpoints now blocked, schema violations logged

## Key Demo Points

- **Shadow API Discovery**: `/api/v1/admin/*` endpoints exist but aren't in schema
- **Schema Validation**: POST body validation (types, ranges, required fields)
- **Rate Limiting**: Can be added per-endpoint in API Shield
- **Sequence Enforcement**: Browse → Cart → Checkout flow can be enforced

## Modifying the Code

Keep changes minimal — this is demo code. If adding endpoints:

1. Add to `src/index.js` route handlers
2. Update `peakcart-schema.yaml` if it should be documented
3. Keep error handling simple (just status codes + JSON)
4. Maintain CORS headers for browser demos
