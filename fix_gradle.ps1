# Set GRADLE_USER_HOME to use local cache directory
$env:GRADLE_USER_HOME = "E:\Global\Desktop\app\.gradle-cache"

# Set TEMP and TMP directories to a location with more space
$env:TEMP = "E:\Global\Desktop\app\temp"
$env:TMP = "E:\Global\Desktop\app\temp"

# Create temp directory
if (!(Test-Path -Path "E:\Global\Desktop\app\temp")) {
    New-Item -ItemType Directory -Path "E:\Global\Desktop\app\temp"
}

# Clean up Gradle cache to free up space
Write-Host "Cleaning up Gradle cache..."
if (Test-Path -Path "C:\Users\Global\.gradle") {
    # Remove old Gradle cache directories but keep the most recent ones
    Get-ChildItem -Path "C:\Users\Global\.gradle\caches" -Directory | Where-Object { $_.Name -ne "8.9" } | Remove-Item -Recurse -Force
}

# Clean up Flutter cache to free up space
Write-Host "Cleaning up Flutter cache..."
flutter pub cache clean

# Update build.gradle file to replace jcenter() with mavenCentral()
$gradleFile = "$env:USERPROFILE\.pub-cache\hosted\pub.dev\usage_stats-1.3.1\android\build.gradle"
$content = Get-Content $gradleFile -Raw
$newContent = $content -replace "jcenter\(\)", "mavenCentral()"
Set-Content -Path $gradleFile -Value $newContent
Write-Host "Updated build.gradle file successfully"

# Run Flutter clean to free up space
Write-Host "Running Flutter clean..."
flutter clean

# Run Flutter pub get to ensure dependencies are up to date
Write-Host "Running Flutter pub get..."
flutter pub get

# Run Flutter build command
Write-Host "Running Flutter build..."
flutter build

# Run Flutter push command (custom deployment)
Write-Host "Running Flutter push..."
flutter push
