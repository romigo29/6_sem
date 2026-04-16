$uri = "http://localhost:7000/lb"

$results = @{
    X = 0
    Y = 0
    Z = 0
}

function Send-Requests($method, $count) {
    for ($i = 0; $i -lt $count; $i++) {
        try {
            $response = Invoke-RestMethod `
                -Uri $uri `
                -Method $method `
                -TimeoutSec 10

            $nick = $response.Nick
            $results[$nick]++

            Write-Host "$method [$i] => $nick"
        }
        catch {
            Write-Host "Error during $method request"
            Write-Host $_
        }

        # небольшая пауза, чтобы не перегружать сервер
        Start-Sleep -Milliseconds 20
    }
}

# 50 запросов каждого метода
Send-Requests "GET" 50
Send-Requests "POST" 50
Send-Requests "PUT" 50
Send-Requests "DELETE" 50

# итоговая статистика
Write-Host "`nRESULT:"
$results.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)"
}