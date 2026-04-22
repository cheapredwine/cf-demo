#!/bin/bash
# Generate invalid API traffic (schema violations) for PeakCart API Shield demos
# Uses rotating Authorization headers to trigger API discovery

BASE_URL="https://jsherron.com/api"

for i in {1..3}; do
    # Generate a unique auth token for this round (simulates different users)
    AUTH_TOKEN="Bearer invalid$(printf "%03d" $i)-$(echo -n "baduser$i" | base64 | cut -c1-20)"
    
    # Wrong types + extra field
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": "abc", "quantity": 999, "coupon_code": "SQLI-ATTEMPT"}' > /dev/null

    # Missing required field
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": 1}' > /dev/null

    # Empty body
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{}' > /dev/null

    # Wrong content type
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: text/plain" \
        -H "Authorization: $AUTH_TOKEN" \
        -d 'not even json' > /dev/null

    # Bad enum value
    curl -s "$BASE_URL/v1/products?category=weapons" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null

    # Undocumented endpoint (shadow API)
    curl -s "$BASE_URL/v1/admin/users" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null

    # Wrong HTTP method
    curl -s -X DELETE "$BASE_URL/v1/products/1" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null

    # Path param wrong type
    curl -s "$BASE_URL/v1/products/abc" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null

    # Negative quantity
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": 1, "quantity": -5}' > /dev/null

    # SQL injection attempt
    curl -s -X POST "$BASE_URL/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": "1 OR 1=1", "quantity": 1}' > /dev/null

    echo "Round $i of 3 done (Auth: ${AUTH_TOKEN:0:30}...)"
    sleep 1
done
