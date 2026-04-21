// PeakCart Demo API — Simplified for Cloudflare API Shield demos
// Simulates an e-commerce API with both documented and shadow endpoints

const PRODUCTS = [
  { id: 1, name: "Wireless Headphones", price: 79.99, category: "electronics", stock: 142 },
  { id: 2, name: "Running Shoes", price: 129.95, category: "footwear", stock: 58 },
  { id: 3, name: "Organic Coffee Beans", price: 18.50, category: "grocery", stock: 300 },
  { id: 4, name: "Leather Backpack", price: 199.00, category: "accessories", stock: 23 },
  { id: 5, name: "Yoga Mat", price: 34.99, category: "fitness", stock: 87 },
];

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const json = (data, status = 200) => Response.json(data, { status, headers: CORS });

export default {
  async fetch(req) {
    const { pathname: path, searchParams } = new URL(req.url);
    const method = req.method;

    if (method === "OPTIONS") return new Response(null, { headers: CORS });

    // === DOCUMENTED ENDPOINTS (in OpenAPI schema) ===

    // GET /api/v1/products — List products (optional category filter)
    if (path === "/api/v1/products" && method === "GET") {
      const category = searchParams.get("category");
      const results = category ? PRODUCTS.filter(p => p.category === category) : PRODUCTS;
      return json({ success: true, data: results, count: results.length });
    }

    // GET /api/v1/products/:id — Get single product
    const singleMatch = path.match(/^\/api\/v1\/products\/(\d+)$/);
    if (singleMatch && method === "GET") {
      const product = PRODUCTS.find(p => p.id === parseInt(singleMatch[1]));
      return product
        ? json({ success: true, data: product })
        : json({ success: false, error: "Product not found" }, 404);
    }

    // POST /api/v1/cart/add — Add item to cart
    if (path === "/api/v1/cart/add" && method === "POST") {
      const body = await req.json().catch(() => null);
      if (!body) return json({ success: false, error: "Invalid JSON" }, 400);

      const { product_id, quantity } = body;
      const product = PRODUCTS.find(p => p.id === product_id);

      if (!product) return json({ success: false, error: "Product not found" }, 404);
      if (!Number.isInteger(quantity) || quantity < 1 || quantity > 10) {
        return json({ success: false, error: "quantity must be 1-10" }, 400);
      }

      return json({
        success: true,
        message: `Added ${quantity}x ${product.name} to cart`,
        cart_total: (product.price * quantity).toFixed(2),
      }, 201);
    }

    // GET /api/v1/health — Health check
    if (path === "/api/v1/health") {
      return json({ status: "ok", service: "peakcart-api", version: "1.0.0" });
    }

    // === SHADOW / UNDOCUMENTED ENDPOINTS (NOT in OpenAPI schema) ===
    // These simulate legacy/forgotten endpoints for API Shield demos

    // GET /api/v1/admin/users — Legacy admin endpoint
    if (path === "/api/v1/admin/users" && method === "GET") {
      return json({
        success: true,
        warning: "This endpoint is deprecated.",
        data: [
          { id: 101, email: "admin@peakcart.io", role: "super_admin" },
          { id: 102, email: "ops@peakcart.io", role: "warehouse_admin" },
        ],
      });
    }

    // GET /api/v1/admin/config — Exposed config
    if (path === "/api/v1/admin/config" && method === "GET") {
      return json({
        environment: "production",
        debug_mode: false,
        db_host: "rds-prod-peakcart.us-east-1.amazonaws.com",
      });
    }

    // 404 for everything else
    return json({ success: false, error: "Endpoint not found" }, 404);
  },
};
