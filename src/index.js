// PeakCart Demo API — Product Catalog
// Simulates a headless commerce API for an e-commerce retailer

const PRODUCTS = [
  { id: 1, name: "Wireless Headphones", price: 79.99, category: "electronics", stock: 142 },
  { id: 2, name: "Running Shoes", price: 129.95, category: "footwear", stock: 58 },
  { id: 3, name: "Organic Coffee Beans", price: 18.50, category: "grocery", stock: 300 },
  { id: 4, name: "Leather Backpack", price: 199.00, category: "accessories", stock: 23 },
  { id: 5, name: "Yoga Mat", price: 34.99, category: "fitness", stock: 87 },
];

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    if (method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    // GET /api/v1/products — List all products
    if (path === "/api/v1/products" && method === "GET") {
      const category = url.searchParams.get("category");
      let results = PRODUCTS;
      if (category) {
        results = PRODUCTS.filter(p => p.category === category);
      }
      return Response.json(
        { success: true, data: results, count: results.length },
        { headers: corsHeaders }
      );
    }

    // GET /api/v1/products/:id — Get single product
    const singleMatch = path.match(/^\/api\/v1\/products\/(\d+)$/);
    if (singleMatch && method === "GET") {
      const id = parseInt(singleMatch[1]);
      const product = PRODUCTS.find(p => p.id === id);
      if (!product) {
        return Response.json(
          { success: false, error: "Product not found" },
          { status: 404, headers: corsHeaders }
        );
      }
      return Response.json(
        { success: true, data: product },
        { headers: corsHeaders }
      );
    }

    // POST /api/v1/cart/add — Add item to cart
    // Expects: { "product_id": int, "quantity": int }
    if (path === "/api/v1/cart/add" && method === "POST") {
      let body;
      try {
        body = await request.json();
      } catch (e) {
        return Response.json(
          { success: false, error: "Invalid JSON body" },
          { status: 400, headers: corsHeaders }
        );
      }

      const { product_id, quantity } = body;

      if (!Number.isInteger(product_id) || !Number.isInteger(quantity)) {
        return Response.json(
          { success: false, error: "product_id and quantity must be integers" },
          { status: 400, headers: corsHeaders }
        );
      }

      if (quantity < 1 || quantity > 10) {
        return Response.json(
          { success: false, error: "quantity must be between 1 and 10" },
          { status: 400, headers: corsHeaders }
        );
      }

      const product = PRODUCTS.find(p => p.id === product_id);
      if (!product) {
        return Response.json(
          { success: false, error: "Product not found" },
          { status: 404, headers: corsHeaders }
        );
      }

      return Response.json(
        {
          success: true,
          message: "Added " + quantity + "x " + product.name + " to cart",
          cart_total: (product.price * quantity).toFixed(2),
        },
        { status: 201, headers: corsHeaders }
      );
    }

    // GET /api/v1/health — Health check
    if (path === "/api/v1/health") {
      return Response.json(
        { status: "ok", service: "peakcart-api", version: "1.0.0" },
        { headers: corsHeaders }
      );
    }

    // ============================================
    // SHADOW / UNDOCUMENTED ENDPOINTS
    // These simulate legacy or forgotten endpoints that exist in
    // the application but are NOT in the OpenAPI schema.
    // API Shield's fallthrough rule should catch and block these.
    // ============================================

    // GET /api/v1/admin/users — Legacy admin user list (NOT in schema)
    if (path === "/api/v1/admin/users" && method === "GET") {
      return Response.json(
        {
          success: true,
          data: [
            { id: 101, email: "admin@peakcart.io", role: "super_admin", last_login: "2026-02-10T14:32:00Z" },
            { id: 102, email: "ops@peakcart.io", role: "warehouse_admin", last_login: "2026-02-09T09:15:00Z" },
            { id: 103, email: "dev@peakcart.io", role: "developer", last_login: "2026-01-28T22:41:00Z" },
          ],
          warning: "This endpoint is deprecated. Use /admin/v2/users instead.",
        },
        { headers: corsHeaders }
      );
    }

    // GET /api/v1/admin/config — Exposed config endpoint (NOT in schema)
    if (path === "/api/v1/admin/config" && method === "GET") {
      return Response.json(
        {
          environment: "production",
          debug_mode: false,
          db_host: "rds-prod-peakcart.us-east-1.amazonaws.com",
          stripe_webhook_url: "https://peakcart.io/webhooks/stripe",
          feature_flags: { new_checkout: true, ai_recommendations: false },
        },
        { headers: corsHeaders }
      );
    }

    // Catch-all: 404
    return Response.json(
      { success: false, error: "Endpoint not found" },
      { status: 404, headers: corsHeaders }
    );
  },
};