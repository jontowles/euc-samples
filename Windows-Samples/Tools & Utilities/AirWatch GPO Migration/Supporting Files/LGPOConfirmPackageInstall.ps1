function Write-Log {
    Param (
        [Parameter(Mandatory=$False)]
        [string]$logType = "Info",
        [Parameter(Mandatory=$True)]
        [string]$logString
    )
    
    $logDate = Get-Date -UFormat "%Y-%m-%d"
    $datetime = (Get-Date).ToString()
    $logPath = "$($env:ProgramData)\AirWatch\GPOs"
    if (!(Test-Path -Path $logPath)) { New-Item -Path $logPath -ItemType Directory | Out-Null }
     
    $logfilePath = "$logPath\log-$logDate.txt"
    "$dateTime | $logType | $logString" | Out-File -FilePath $logfilePath -Append
}

function MAIN {
    $result = 0
    try {
        $appPath = "$($env:ProgramData)\AirWatch\GPOs\deployment"
        $filepath = "$appPath\lgpoResults.csv"

        $csvPathExists = Test-Path -Path $filepath
        Write-Log -logString "LGPOConfirmPackageInstall filepath $filepath exists = $csvPathExists"
        
        # Ensure lgpoResults.csv has been created 
        if ($csvPathExists) { 
            $lgpoResults = Import-Csv -Path $filepath -Delimiter "," #','
            Write-Log -logString "LGPOConfirmPackageInstall lgpoResults = $lgpoResults"

            $lgpoResults | ForEach-Object -Process {
                Write-Log -logString "LGPOConfirmPackageInstall '$($_.filename)' completed: $($_.completed)"
                if ($_.completed -eq $false) {
                    $result = 1
                    break
                }
            }
        }
        else {
            $result = 1
        }
    }
    catch {
        Write-Log -logString "LGPOConfirmPackageInstall ERROR = $PSItem"
        $result = 1
    }

    Write-Log -logString "LGPOConfirmPackageInstall result = $result"
    return $result   
}

$code = MAIN
echo $code
EXIT $code