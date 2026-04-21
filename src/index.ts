// PeakCart Demo API — TypeScript version for Cloudflare API Shield demos

interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
  stock: number;
}

interface CartRequest {
  product_id: number;
  quantity: number;
}

interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  count?: number;
  cart_total?: string;
  warning?: string;
}

interface HealthResponse {
  status: string;
  service: string;
  version: string;
}

interface AdminUser {
  id: number;
  email: string;
  role: string;
}

interface AdminUsersResponse {
  success: boolean;
  warning: string;
  data: AdminUser[];
}

interface ConfigResponse {
  environment: string;
  debug_mode: boolean;
  db_host: string;
}

const PRODUCTS: readonly Product[] = [
  { id: 1, name: "Wireless Headphones", price: 79.99, category: "electronics", stock: 142 },
  { id: 2, name: "Running Shoes", price: 129.95, category: "footwear", stock: 58 },
  { id: 3, name: "Organic Coffee Beans", price: 18.50, category: "grocery", stock: 300 },
  { id: 4, name: "Leather Backpack", price: 199.00, category: "accessories", stock: 23 },
  { id: 5, name: "Yoga Mat", price: 34.99, category: "fitness", stock: 87 },
] as const;

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const jsonResponse = <T>(data: T, status = 200): Response =>
  Response.json(data, { status, headers: CORS_HEADERS });

const findProduct = (id: number): Product | undefined =>
  PRODUCTS.find(p => p.id === id);

const validateCartRequest = (body: unknown): body is CartRequest => {
  if (typeof body !== "object" || body === null) return false;
  const req = body as Record<string, unknown>;
  return (
    typeof req.product_id === "number" &&
    typeof req.quantity === "number" &&
    Number.isInteger(req.product_id) &&
    Number.isInteger(req.quantity)
  );
};

export default {
  async fetch(request: Request): Promise<Response> {
    const { pathname: path, searchParams } = new URL(request.url);
    const method = request.method;

    if (method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    // === DOCUMENTED ENDPOINTS (in OpenAPI schema) ===

    // GET /api/v1/products — List products (optional category filter)
    if (path === "/api/v1/products" && method === "GET") {
      const category = searchParams.get("category");
      const results = category
        ? PRODUCTS.filter(p => p.category === category)
        : [...PRODUCTS];

      const response: ApiResponse<Product[]> = {
        success: true,
        data: results,
        count: results.length,
      };
      return jsonResponse(response);
    }

    // GET /api/v1/products/:id — Get single product
    const singleMatch = path.match(/^\/api\/v1\/products\/(\d+)$/);
    if (singleMatch && method === "GET") {
      const id = parseInt(singleMatch[1]!, 10);
      const product = findProduct(id);

      if (!product) {
        const response: ApiResponse = {
          success: false,
          error: "Product not found",
        };
        return jsonResponse(response, 404);
      }

      const response: ApiResponse<Product> = {
        success: true,
        data: product,
      };
      return jsonResponse(response);
    }

    // POST /api/v1/cart/add — Add item to cart
    if (path === "/api/v1/cart/add" && method === "POST") {
      let body: unknown;
      try {
        body = await request.json();
      } catch {
        const response: ApiResponse = {
          success: false,
          error: "Invalid JSON",
        };
        return jsonResponse(response, 400);
      }

      if (!validateCartRequest(body)) {
        const response: ApiResponse = {
          success: false,
          error: "Invalid request body",
        };
        return jsonResponse(response, 400);
      }

      const { product_id, quantity } = body;
      const product = findProduct(product_id);

      if (!product) {
        const response: ApiResponse = {
          success: false,
          error: "Product not found",
        };
        return jsonResponse(response, 404);
      }

      if (quantity < 1 || quantity > 10) {
        const response: ApiResponse = {
          success: false,
          error: "quantity must be 1-10",
        };
        return jsonResponse(response, 400);
      }

      const response: ApiResponse = {
        success: true,
        message: `Added ${quantity}x ${product.name} to cart`,
        cart_total: (product.price * quantity).toFixed(2),
      };
      return jsonResponse(response, 201);
    }

    // GET /api/v1/health — Health check
    if (path === "/api/v1/health") {
      const response: HealthResponse = {
        status: "ok",
        service: "peakcart-api",
        version: "1.0.0",
      };
      return jsonResponse(response);
    }

    // === SHADOW / UNDOCUMENTED ENDPOINTS (NOT in OpenAPI schema) ===

    // GET /api/v1/admin/users — Legacy admin endpoint
    if (path === "/api/v1/admin/users" && method === "GET") {
      const response: AdminUsersResponse = {
        success: true,
        warning: "This endpoint is deprecated.",
        data: [
          { id: 101, email: "admin@peakcart.io", role: "super_admin" },
          { id: 102, email: "ops@peakcart.io", role: "warehouse_admin" },
        ],
      };
      return jsonResponse(response);
    }

    // GET /api/v1/admin/config — Exposed config
    if (path === "/api/v1/admin/config" && method === "GET") {
      const response: ConfigResponse = {
        environment: "production",
        debug_mode: false,
        db_host: "rds-prod-peakcart.us-east-1.amazonaws.com",
      };
      return jsonResponse(response);
    }

    // 404 for everything else
    const response: ApiResponse = {
      success: false,
      error: "Endpoint not found",
    };
    return jsonResponse(response, 404);
  },
} satisfies ExportedHandler;
