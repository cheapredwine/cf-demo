#!/bin/bash
# Generate valid API traffic for PeakCart API Shield demos
# Uses rotating Authorization headers to trigger API discovery

BASE_URL="https://jsherron.com/api"

for i in {1..20}; do
    # Generate a unique auth token for this batch (simulates different users)
    AUTH_TOKEN="Bearer batch$(printf "%03d" $i)-$(echo -n "user$i" | base64 | cut -c1-20)"
    
    curl -s "$BASE_URL/api/v1/products" -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/products?category=electronics" -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/products/1" -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/products/2" -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/products/3" -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": 1, "quantity": 2}' > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": 3, "quantity": 1}' > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"product_id": 5, "quantity": 4}' > /dev/null
    curl -s "$BASE_URL/api/v1/health" -H "Authorization: $AUTH_TOKEN" > /dev/null

    echo "Batch $i of 20 sent (Auth: ${AUTH_TOKEN:0:30}...)"
    sleep 0.5
done
