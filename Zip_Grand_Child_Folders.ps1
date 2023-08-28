$orgDirectory = Read-Host -Prompt 'Input the grand parent folder where log files are located'
$requisiteChildFolderName = Read-Host -Prompt 'What text do all child folder names need to contain to be eligible?'

$days = [datetime]::Now.AddDays(-14)

$userFolders = Get-ChildItem -Path $orgDirectory | Where-Object {$_.Attributes -eq "Directory" -and $_.Name.Contains($requisiteChildFolderName)} | ForEach-Object -Process {[System.IO.Path]::GetFileNameWithoutExtension($_)}

ForEach ($userFolder in $userFolders) {
    $logPath = $orgDirectory + '\' + $userFolder
    $logFolders = Get-ChildItem -Path $logPath | Where-Object {$_.CreationTime -lt $days -and $_.Attributes -eq "Directory"} | ForEach-Object -Process {[System.IO.Path]::GetFileNameWithoutExtension($_)}

    ForEach ($logFolder in $logFolders) {
        $logFolderPath = $logPath + '\' + $logFolder
        $zipFolderPath = $logFolderPath + '.zip'

        $logFolderPath
        Compress-Archive -LiteralPath $logFolderPath -DestinationPath $zipFolderPath

        if (test-path $zipFolderPath) {
            Remove-item $logFolderPath -Recurse
        }
        else {
            write-host "zip not found"
        }
    }   
}