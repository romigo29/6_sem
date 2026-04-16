$uri = "http://localhost:7000/lb"

$results = @{
    X = 0
    Y = 0
    Z = 0
}

function Send-Requests($method, $count) {
    for ($i = 0; $i -lt $count; $i++) {
        try {
            $response = Invoke-RestMethod -Uri $uri -Method $method 

            $nick = $response.Nick

            if ($results.ContainsKey($nick)) {
                $results[$nick]++
            }
            
            Write-Host "Server: $($response.Nick) | Method: $method"
        }
        catch {
    		Write-Host "Error during $method request"
    		Write-Host $_
}    }
}

# 50 запросов каждого типа
Send-Requests "GET" 50
Send-Requests "POST" 50
Send-Requests "PUT" 50
Send-Requests "DELETE" 50

# Вывод результата
Write-Host "Results:"
$results.GetEnumerator() | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)"
}