#!/bin/bash
# Test script to verify headers being sent to flarebin

BASE_URL="https://flarebin.jsherron.com"

for i in {1..3}; do
    AUTH_TOKEN="Bearer batch$(printf "%03d" $i)-$(echo -n "user$i" | base64 | cut -c1-20)"

    curl -s "$BASE_URL/post" \
        -H "Authorization: $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"test": "data"}'

    echo ""
    echo "--- Request $i sent with Auth: ${AUTH_TOKEN:0:40}..."
    sleep 1
done
