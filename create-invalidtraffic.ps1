$baseUrl = "https://public-api.electric-harbor.sxplab.com"

1..5 | ForEach-Object {
    # Wrong types + extra field
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: application/json" -d "{\"product_id\": \"abc\", \"quantity\": 999, \"coupon_code\": \"SQLI-ATTEMPT\"}" | Out-Null
    # Missing required field
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: application/json" -d "{\"product_id\": 1}" | Out-Null
    # Empty body
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: application/json" -d "{}" | Out-Null
    # Wrong content type
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: text/plain" -d "not even json" | Out-Null
    # Bad enum value
    curl.exe -s "$baseUrl/api/v1/products?category=weapons" | Out-Null
    # Undocumented endpoint (shadow API)
    curl.exe -s "$baseUrl/api/v1/admin/users" | Out-Null
    # Wrong HTTP method
    curl.exe -s -X DELETE "$baseUrl/api/v1/products/1" | Out-Null
    # Path param wrong type
    curl.exe -s "$baseUrl/api/v1/products/abc" | Out-Null
    # Negative quantity
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: application/json" -d "{\"product_id\": 1, \"quantity\": -5}" | Out-Null
    # SQL injection attempt
    curl.exe -s -X POST "$baseUrl/api/v1/cart/add" -H "Content-Type: application/json" -d "{\"product_id\": \"1 OR 1=1\", \"quantity\": 1}" | Out-Null
    Write-Host "Round $_ of 5 done"
    Start-Sleep -Seconds 1
}
