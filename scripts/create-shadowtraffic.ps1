# Generate shadow API probing traffic for PeakCart API Shield demos
# Uses rotating Authorization headers to trigger API discovery

$baseUrl = "https://jsherron.com/api"

1..10 | ForEach-Object {
    # Generate a unique auth token for this round (simulates different attackers)
    $authToken = "Bearer shadow{0:D3}-$([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("attacker$_"))).Substring(0,20)" -f $_
    
    curl.exe -s "$baseUrl/v1/admin/users" -H "Authorization: $authToken" | Out-Null
    curl.exe -s "$baseUrl/v1/admin/config" -H "Authorization: $authToken" | Out-Null
    curl.exe -s "$baseUrl/v1/internal/debug" -H "Authorization: $authToken" | Out-Null
    curl.exe -s "$baseUrl/v1/users/export" -H "Authorization: $authToken" | Out-Null
    curl.exe -s -X POST "$baseUrl/v1/admin/login" -H "Content-Type: application/json" -H "Authorization: $authToken" -d '{"username": "admin", "password": "password123"}' | Out-Null
    curl.exe -s "$baseUrl/v2/products" -H "Authorization: $authToken" | Out-Null
    curl.exe -s "$baseUrl/.env" -H "Authorization: $authToken" | Out-Null
    curl.exe -s "$baseUrl/v1/graphql" -H "Authorization: $authToken" | Out-Null
    
    Write-Host "Round $_ of 10 done (Auth: $($authToken.Substring(0,30))...)"
    Start-Sleep -Milliseconds 500
}
