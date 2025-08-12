Write-Host "Auto-saving your Flutter app to GitHub..."

# Add all changes
git add .

# Check if there are changes to commit
$gitStatus = git diff-index --quiet HEAD; $gitStatusExitCode = $LASTEXITCODE

if ($gitStatusExitCode -ne 0) {
    # There are changes to commit
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    git commit -m "Auto-save on $timestamp"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Changes committed successfully."
    } else {
        Write-Host "Failed to commit changes."
        exit 1
    }
} else {
    Write-Host "No changes to commit."
}

# Push to GitHub
git push origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "Auto-save completed successfully."
} else {
    Write-Host "Failed to push changes to GitHub."
    exit 1
}