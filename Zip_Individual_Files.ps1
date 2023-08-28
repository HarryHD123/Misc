Add-Type -AssemblyName System.IO.Compression.FileSystem

# Prompt the user for the file location
$sourceFolder = Read-Host "Enter the location of the files to be zipped"

if (-not (Test-Path -Path $sourceFolder -PathType Container)) {
    Write-Host "Invalid source folder path: $sourceFolder"
    return
}

# Prompt the user for the destination folder for the zipped files
$destinationFolder = Read-Host "Enter the destination folder for the zipped files"

if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
    Write-Host "Invalid destination folder path: $destinationFolder"
    return
}

# Prompt the user for the time period to zip the files (minimum 3 days from now)
do {
    $days = Read-Host "Enter the number of days ago from which files should be zipped (minimum 3 days)"

    if (-not [int]::TryParse($days, [ref]$null) -or [int]$days -lt 3) {
        Write-Host "Invalid input. Please enter a valid number (minimum 3 days)."
    }
} while ([int]$days -lt 3)

# Calculate the date from which to start zipping the files
$zipStartDate = (Get-Date).AddDays(-[int]$days)

# Get the files in the source folder that are older than the zip start date
$filesToZip = Get-ChildItem -Path $sourceFolder -File | Where-Object { $_.LastWriteTime -lt $zipStartDate }

# Zip the files individually and delete the initial files
foreach ($file in $filesToZip) {
    $fileName = $file.Name
    $zipFileName = "$fileName.zip"
    $zipFilePath = Join-Path -Path $destinationFolder -ChildPath $zipFileName

    try {
        # Create a new zip file
        $zipFile = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')

        # Add the file to the zip file
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, $file.FullName, $fileName)

        $zipFile.Dispose()

        Write-Host "File '$fileName' has been successfully zipped. The zipped file is saved at: $zipFilePath"

        # Remove the initial file
        Remove-Item -LiteralPath $file.FullName -Force
        Write-Host "The initial file '$fileName' has been deleted."
    }
    catch {
        Write-Host "Error occurred while creating the zip file for file '$fileName': $_"
    }
}
