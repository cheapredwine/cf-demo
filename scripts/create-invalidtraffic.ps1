# Generate invalid API traffic (schema violations) for PeakCart API Shield demos
# Uses rotating Authorization headers to trigger API discovery

$baseUrl = "https://jsherron.com/api"

1..3 | ForEach-Object {
    # Generate a unique auth token for this round (simulates different users)
    $authToken = "Bearer invalid{0:D3}-$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("baduser$_"))).Substring(0,20)" -f $_
    $headers = @{ "Authorization" = $authToken }
    
    # Wrong types + extra field
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{"product_id": "abc", "quantity": 999, "coupon_code": "SQLI-ATTEMPT"}' | Out-Null
    # Missing required field
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{"product_id": 1}' | Out-Null
    # Empty body
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{}' | Out-Null
    # Wrong content type
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: text/plain" -H "Authorization: $authToken" -d 'not even json' | Out-Null
    # Bad enum value
    curl.exe -s "$baseUrl/v1/products?category=weapons" -H "Authorization: $authToken" | Out-Null
    # Undocumented endpoint (shadow API)
    curl.exe -s "$baseUrl/v1/admin/users" -H "Authorization: $authToken" | Out-Null
    # Wrong HTTP method
    curl.exe -s -X DELETE "$baseUrl/v1/products/1" -H "Authorization: $authToken" | Out-Null
    # Path param wrong type
    curl.exe -s "$baseUrl/v1/products/abc" -H "Authorization: $authToken" | Out-Null
    # Negative quantity
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{"product_id": 1, "quantity": -5}' | Out-Null
    # SQL injection attempt
    curl.exe -s -X POST "$baseUrl/v1/cart/add" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{"product_id": "1 OR 1=1", "quantity": 1}' | Out-Null
    
    Write-Host "Round $_ of 3 done (Auth: $($authToken.Substring(0,30))...)"
    Start-Sleep -Seconds 1
}
