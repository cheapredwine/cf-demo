#!/bin/bash
# Generate shadow API probing traffic for PeakCart API Shield demos
# Uses rotating Authorization headers to trigger API discovery

BASE_URL="https://jsherron.com/api"

for i in {1..50}; do
    # Generate a unique auth token for this round (simulates different attackers)
    AUTH_TOKEN="Bearer shadow$(printf "%03d" $i)-$(echo -n "attacker$i" | base64 | cut -c1-20)"
    
    curl -s "$BASE_URL/api/v1/admin/users" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/admin/config" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/internal/debug" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/users/export" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s -X POST "$BASE_URL/api/v1/admin/login" \
        -H "Content-Type: application/json" \
        -H "Authorization: $AUTH_TOKEN" \
        -d '{"username": "admin", "password": "password123"}' > /dev/null
    curl -s "$BASE_URL/api/v2/products" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/.env" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null
    curl -s "$BASE_URL/api/v1/graphql" \
        -H "Authorization: $AUTH_TOKEN" > /dev/null

    echo "Round $i of 50 done (Auth: ${AUTH_TOKEN:0:30}...)"
    sleep 0.5
done
