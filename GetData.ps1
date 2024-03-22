Clear-Host

$gameDates = @"
2024-03-21
2024-03-22
2024-03-23
2024-03-24
2024-03-28
2024-03-29
2024-03-30
2024-03-31
2024-04-06
2024-04-08
"@ -split "`r?`n"

$allGames = $gameDates.ForEach{
    $ymd = $_ -replace '-','/'

    $response = Invoke-RestMethod "https://ncaa-api.henrygd.me/scoreboard/basketball-men/d1/$ymd"
    Write-Host "$ymd Returned $($response.games.count) games."

    $response.games.ForEach{
        $ThisGame = $_.Game
        [PSCustomObject]@{
            GameId = $ThisGame.GameId
            GameState = $ThisGame.gameState
            FinalMessage = $ThisGame.finalMessage
            Round = [System.Web.HttpUtility]::HtmlDecode($ThisGame.bracketRound)
            Region = $ThisGame.bracketRegion
            Network = $ThisGame.network
            StartDate = $ThisGame.StartDate
            StartTime = $ThisGame.startTime
            HomeTeam = $ThisGame.Home.names.short
            AwayTeam = $ThisGame.Away.names.short
            HomeScore = $ThisGame.Home.score
            AwayScore = $ThisGame.Away.score
            Winner = $(
                If($ThisGame.finalMessage -ne 'Final') { 
                    $null 
                } ElseIf($ThisGame.Home.score -gt $ThisGame.Away.score) { 
                    $ThisGame.Home.names.short 
                } ElseIf($ThisGame.Away.score -gt $ThisGame.Home.score) { 
                    $ThisGame.Away.Names.Short 
                } Else { "?" })
        }
    }
}


$allTeams = $allGames.ForEach{
    [PSCustomObject]@{
        GameId = $_.GameId
        GameState = $_.gameState
        FinalMessage = $_.finalMessage
        Round = [System.Web.HttpUtility]::HtmlDecode($_.Round)
        Region = $_.Region
        Network = $_.network
        StartDate = $_.StartDate
        StartTime = $_.startTime
        TeamName = $_.AwayTeam
        Versus = $_.HomeTeam
        TeamScore = $_.HomeScore
        OpponentScore = $_.AwayScore
        WinningTeam = $_.Winner
    }
    [PSCustomObject]@{
        GameId = $_.GameId
        GameState = $_.gameState
        FinalMessage = $_.finalMessage
        Round = [System.Web.HttpUtility]::HtmlDecode($_.Round)
        Region = $_.Region
        Network = $_.network
        StartDate = $_.StartDate
        StartTime = $_.startTime
        TeamName = $_.HomeTeam
        Versus = $_.AwayTeam
        TeamScore = $_.HomeScore
        OpponentScore = $_.AwayScore
        WinningTeam = $_.Winner
    }
}

$allGames | Export-Csv -Path $PSScriptRoot\allGames.csv
$allGames | ConvertTo-Json | Out-File $PSScriptRoot\allGames.json
$allTeams | Export-Csv -Path $PSScriptRoot\allTeams.csv
$allTeams | ConvertTo-Json | Out-File $PSScriptRoot\allTeams.json

