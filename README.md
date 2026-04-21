# PeakCart API

A demo e-commerce API for Cloudflare API Shield demonstrations. Simulates a headless commerce platform with both documented endpoints and shadow/undocumented endpoints for security testing.

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
curl https://your-domain.com/api/v1/products

# Filter by category
curl "https://your-domain.com/api/v1/products?category=electronics"

# Get single product
curl https://your-domain.com/api/v1/products/1

# Add to cart
curl -X POST https://your-domain.com/api/v1/cart/add \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Health check
curl https://your-domain.com/api/v1/health

# Shadow endpoint (undocumented)
curl https://your-domain.com/api/v1/admin/users
```

## API Shield Demo Flow

1. **Upload Schema**: Import `peakcart-schema.yaml` into Cloudflare API Shield
2. **Generate Traffic**: Run the PowerShell scripts to create traffic logs
3. **Enable Protection**: Turn on schema validation and fallthrough blocking
4. **See Results**: Shadow endpoints blocked, schema violations logged

### Traffic Scripts

PowerShell (Windows):
- `create-validtraffic.ps` — Normal API usage
- `create-invalidtraffic.ps1` — Schema violations (wrong types, missing fields)
- `create-shadowtraffic.ps1` — Probes undocumented endpoints

Bash (macOS/Linux):
- `create-validtraffic.sh` — Normal API usage
- `create-invalidtraffic.sh` — Schema violations
- `create-shadowtraffic.sh` — Probes undocumented endpoints

## Configuration

### wrangler.toml

```toml
name = "peakcart-api"
main = "src/index.js"
compatibility_date = "2024-12-01"

# Optional: custom domain
routes = [{ pattern = "your-domain.com", custom_domain = true }]
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
│   └── index.js          # Worker code
├── peakcart-schema.yaml  # OpenAPI 3.0 schema
├── wrangler.toml         # Cloudflare config
├── package.json          # npm config
└── doc/                  # Demo documentation
```

## Technologies

- [Cloudflare Workers](https://workers.cloudflare.com/) — Edge compute platform
- [Wrangler](https://developers.cloudflare.com/workers/wrangler/) — CLI for deployment
- [OpenAPI 3.0](https://spec.openapis.org/oas/v3.0.0) — API schema specification

## License

ISC
