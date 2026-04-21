# PeakCart API

A demo e-commerce API for Cloudflare API Shield demonstrations. Simulates a headless commerce platform with both documented endpoints and shadow/undocumented endpoints for security testing.

Built with **TypeScript** and deployed on **Cloudflare Workers**.

## Quick Start

```bash
# Install dependencies
npm install

# Run locally
npm run dev

# Deploy to Cloudflare Workers
npm run deploy
```

## API Endpoints

### Documented (in OpenAPI schema)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/products` | List products (filter: `?category=electronics`) |
| GET | `/api/v1/products/{id}` | Get product by ID |
| POST | `/api/v1/cart/add` | Add to cart: `{product_id, quantity}` |
| GET | `/api/v1/health` | Health check |

### Shadow (undocumented) — for API Shield demos

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/users` | Exposed admin user list |
| GET | `/api/v1/admin/config` | Exposed configuration |

## Example Requests

```bash
# List all products
curl https://jsherron.com/api/v1/products

# Filter by category
curl "https://jsherron.com/api/v1/products?category=electronics"

# Get single product
curl https://jsherron.com/api/v1/products/1

# Add to cart
curl -X POST https://jsherron.com/api/v1/cart/add \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Health check
curl https://jsherron.com/api/v1/health

# Shadow endpoint (undocumented)
curl https://jsherron.com/api/v1/admin/users
```

**Note**: The API is configured at `https://jsherron.com/api/*` to enable Cloudflare API Shield's automatic discovery mechanism. The worker also responds at `https://peakcart-api.jsherron.com` for direct access.

## API Shield Demo Flow

1. **Upload Schema**: Import `peakcart-schema.yaml` into Cloudflare API Shield
2. **Generate Traffic**: Run the scripts in the `scripts/` directory to create traffic logs
3. **Enable Protection**: Turn on schema validation and fallthrough blocking
4. **See Results**: Shadow endpoints blocked, schema violations logged

### Traffic Scripts

PowerShell (Windows):
- `scripts/create-validtraffic.ps` — Normal API usage
- `scripts/create-invalidtraffic.ps1` — Schema violations (wrong types, missing fields)
- `scripts/create-shadowtraffic.ps1` — Probes undocumented endpoints

Bash (macOS/Linux):
- `scripts/create-validtraffic.sh` — Normal API usage
- `scripts/create-invalidtraffic.sh` — Schema violations
- `scripts/create-shadowtraffic.sh` — Probes undocumented endpoints

## Configuration

### wrangler.toml

```toml
name = "peakcart-api"
main = "src/index.ts"
compatibility_date = "2024-12-01"

# API Shield discovery requires API under /api path on main domain
routes = [
  { pattern = "jsherron.com/api/*", zone_name = "jsherron.com" },
  { pattern = "peakcart-api.jsherron.com", custom_domain = true }
]
```

### Environment Variables (optional)

Create a `.dev.vars` file for local development:

```
DEBUG=true
```

## Project Structure

```
.
├── src/
│   └── index.ts              # Worker code (TypeScript)
├── scripts/                  # Traffic generation scripts
│   ├── create-validtraffic.sh
│   ├── create-invalidtraffic.sh
│   └── create-shadowtraffic.sh
├── peakcart-schema.yaml      # OpenAPI 3.0 schema
├── wrangler.toml             # Cloudflare config
├── package.json              # npm config
├── tsconfig.json             # TypeScript config
└── doc/                      # Demo documentation
```

## Technologies

- [Cloudflare Workers](https://workers.cloudflare.com/) — Edge compute platform
- [TypeScript](https://www.typescriptlang.org/) — Typed JavaScript
- [Wrangler](https://developers.cloudflare.com/workers/wrangler/) — CLI for deployment
- [OpenAPI 3.0](https://spec.openapis.org/oas/v3.0.0) — API schema specification

## License

ISC
