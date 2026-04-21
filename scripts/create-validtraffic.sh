#!/bin/bash
# Generate valid API traffic for PeakCart API Shield demos

BASE_URL="https://peakcart-api.jsherron.com"

for i in {1..100}; do
    curl -s "$BASE_URL/api/v1/products" > /dev/null
    curl -s "$BASE_URL/api/v1/products?category=electronics" > /dev/null
    curl -s "$BASE_URL/api/v1/products/1" > /dev/null
    curl -s "$BASE_URL/api/v1/products/2" > /dev/null
    curl -s "$BASE_URL/api/v1/products/3" > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": 1, "quantity": 2}' > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": 3, "quantity": 1}' > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/cart/add" \
        -H "Content-Type: application/json" \
        -d '{"product_id": 5, "quantity": 4}' > /dev/null
    curl -s "$BASE_URL/api/v1/health" > /dev/null

    echo "Batch $i of 100 sent"
    sleep 0.5
done
