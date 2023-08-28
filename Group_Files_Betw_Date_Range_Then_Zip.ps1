$parentFolder = Read-Host -Prompt 'Input the folder where log files are located'
$startRange = Read-Host -Prompt 'Input the the amount of days back you want to leave files untouched, the rest will be zipped. This must be equal or greater than 14'

if ($startRange -lt 3) { 
    Write-Host "The value you input is less than 3." 
}

else {
    $days = (Get-Date -Hour "23" -Minute "59" -Second "59").AddDays(-$startRange -1)

    $logFiles = Get-ChildItem -Path $parentFolder | Where-Object {$_.CreationTime -lt $days}

    Write-Host "The files to be zipped are:"
    $logFiles

    $confirmation = Read-Host -Prompt 'Please enter 1 if you would like to zip the above files, enter anything else to cancel this'

    if ($confirmation -eq 1) {
        ForEach ($file in $logFiles) {
            $date = $file.CreationTime.Date.ToString('yyyy-MM-dd')
            $dateFolder = $parentFolder + '\' + $date + '_TO_BE_ZIPPED'

            $sourceFilePath = $parentFolder + '\' + $file
            $destFilePath = $dateFolder + '\' + $file

            if (Test-Path $dateFolder) {
                Write-Host 'Moving ' $sourceFilePath ' to ' $destFilePath
                Move-Item -Path $sourceFilePath -Destination $destFilePath
            }
            else {
                New-Item -ItemType Directory -Path $dateFolder
                Write-Host 'Folder for ' $date ' created'
                Write-Host 'Moving ' $sourceFilePath ' to ' $destFilePath
                Move-Item -Path $sourceFilePath -Destination $destFilePath
            }
        }

        Write-Host 'Dated folders created and files moved'

        $logFolders = Get-ChildItem -Path $parentFolder | Where-Object {$_.Name.Contains("_TO_BE_ZIPPED") -and $_.Attributes -eq "Directory"} | ForEach-Object -Process {[System.IO.Path]::GetFileNameWithoutExtension($_)}
        
        Write-Host "The folders to be zipped are:"
        $logFolders

        $confirmation = Read-Host -Prompt 'Please enter 1 if you would like to proceed with zipping the above folders individually, enter anything else to cancel this'

        if ($confirmation -eq 1) {
            ForEach ($folder in $logFolders) {
                $sourceFolder = "$parentFolder\$folder"
                $destZip = $sourceFolder.replace('_TO_BE_ZIPPED', '.zip')

                write-host $folder
                Compress-Archive -LiteralPath $sourceFolder -DestinationPath $destZip

                if (test-path $destZip) {
                    write-host "Zip found, removing folder"
                    Remove-item $sourceFolder -Recurse
                }
                else {
                    write-host "zip not found"
                }
            }
        }
    }
}