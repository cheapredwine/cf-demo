$baseUrl = "https://public-api.electric-harbor.sxplab.com"

1..50 | ForEach-Object {
    curl.exe -s "$baseUrl/api/v1/admin/users" | Out-Null
    curl.exe -s "$baseUrl/api/v1/admin/config" | Out-Null
    curl.exe -s "$baseUrl/api/v1/internal/debug" | Out-Null
    curl.exe -s "$baseUrl/api/v1/users/export" | Out-Null
    curl.exe -s -X POST "$baseUrl/api/v1/admin/login" -H "Content-Type: application/json" -d "{\"username\": \"admin\", \"password\": \"password123\"}" | Out-Null
    curl.exe -s "$baseUrl/api/v2/products" | Out-Null
    curl.exe -s "$baseUrl/.env" | Out-Null
    curl.exe -s "$baseUrl/api/v1/graphql" | Out-Null
    Write-Host "Round $_ of 50 done"
    Start-Sleep -Milliseconds 500
}
