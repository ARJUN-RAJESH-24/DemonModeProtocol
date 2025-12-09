$url = "https://github.com/spotify/android-app-remote-sdk/archive/refs/heads/master.zip"
$zipPath = "spotify-sdk.zip"
$extractPath = "temp_spotify_sdk"
$destDir = "..\android\spotify-app-remote"

Write-Host "Downloading Spotify SDK..."
Invoke-WebRequest -Uri $url -OutFile $zipPath

Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

$aarSource = Get-ChildItem -Path $extractPath -Recurse -Filter "*.aar" | Select-Object -First 1

if ($aarSource) {
    Write-Host "Found AAR: $($aarSource.FullName)"
    
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }

    Copy-Item -Path $aarSource.FullName -Destination "$destDir\spotify-app-remote-release-0.7.2.aar"
    
    # Create build.gradle for the module
    $buildGradleContent = @"
configurations.maybeCreate("default")
artifacts.add("default", file("spotify-app-remote-release-0.7.2.aar"))
"@
    Set-Content -Path "$destDir\build.gradle" -Value $buildGradleContent

    Write-Host "Spotify SDK setup complete in $destDir"
} else {
    Write-Error "Could not find .aar file in the downloaded zip."
}

Remove-Item -Path $zipPath -Force
Remove-Item -Path $extractPath -Recurse -Force
