#!/bin/bash
# Generate invalid API traffic (schema violations) for PeakCart API Shield demos

BASE_URL="https://peakcart-api.jsherron.com"

for i in {1..5}; do
    # Wrong types + extra field
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": "abc", "quantity": 999, "coupon_code": "SQLI-ATTEMPT"}' > /dev/null

    # Missing required field
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": 1}' > /dev/null

    # Empty body
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null

    # Wrong content type
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: text/plain" \
        -d 'not even json' > /dev/null

    # Bad enum value
    curl -s "$BASE_URL/api/v1/products?category=weapons" > /dev/null

    # Undocumented endpoint (shadow API)
    curl -s "$BASE_URL/api/v1/admin/users" > /dev/null

    # Wrong HTTP method
    curl -s -X DELETE "$BASE_URL/api/v1/products/1" > /dev/null

    # Path param wrong type
    curl -s "$BASE_URL/api/v1/products/abc" > /dev/null

    # Negative quantity
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": 1, "quantity": -5}' > /dev/null

    # SQL injection attempt
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": "1 OR 1=1", "quantity": 1}' > /dev/null

    echo "Round $i of 5 done"
    sleep 1
done
