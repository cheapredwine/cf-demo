#!/bin/bash
# Generate shadow API probing traffic for PeakCart API Shield demos

BASE_URL="https://peakcart-api.jsherron.com"

for i in {1..50}; do
    curl -s "$BASE_URL/api/v1/admin/users" > /dev/null
    curl -s "$BASE_URL/api/v1/admin/config" > /dev/null
    curl -s "$BASE_URL/api/v1/internal/debug" > /dev/null
    curl -s "$BASE_URL/api/v1/users/export" > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/admin/login" \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "password123"}' > /dev/null
    curl -s "$BASE_URL/api/v2/products" > /dev/null
    curl -s "$BASE_URL/.env" > /dev/null
    curl -s "$BASE_URL/api/v1/graphql" > /dev/null

    echo "Round $i of 50 done"
    sleep 0.5
done
