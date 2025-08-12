# Auto-Save for Flutter App

This document explains how to automatically save your Flutter app code to GitHub using the provided scripts.

## Prerequisites

1. You must have a GitHub account
2. You must have created a repository for your Flutter app
3. You should have Git installed on your system
4. You should have configured Git with your username and email:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

## Setup Instructions

1. Create a personal access token on GitHub:
   - Go to https://github.com/settings/tokens
   - Click "Generate new token" and then "Generate new token (classic)"
   - Give your token a name (e.g., "flutter-app")
   - Select an expiration date
   - Select the "repo" scope (this gives full access to repositories)
   - Click "Generate token"
   - Copy the generated token (you won't see it again)

2. Clone your repository (if not already done):
   ```
   git clone https://github.com/your-username/your-repo-name.git
   ```

3. Configure Git to store your credentials:
   ```
   git config --global credential.helper store
   ```
   
   Then run a git command that requires authentication and enter your username and token when prompted.

## Using the Auto-Save Scripts

### Windows Batch Script (auto_save.bat)

To use the batch script on Windows:

1. Double-click `auto_save.bat` or run it from the command line:
   ```
   .\auto_save.bat
   ```

### PowerShell Script (auto_save.ps1)

To use the PowerShell script:

1. Open PowerShell
2. Run the script:
   ```
   .\auto_save.ps1
   ```

## Scheduling Auto-Save (Optional)

You can schedule the auto-save script to run automatically using Task Scheduler on Windows:

1. Open Task Scheduler
2. Create a new task
3. Set the trigger to run at your desired frequency (e.g., every hour)
4. Set the action to run the auto_save.bat script
5. Save the task

## Troubleshooting

If you encounter authentication issues:

1. Make sure you're using your GitHub username (not email) when prompted
2. Make sure you're entering the personal access token (not your password) when prompted
3. Check that your token has the "repo" scope
4. Try running `git config --global credential.helper store` and then run a git command to re-enter your credentials

## Manual Git Commands

You can also manually run these commands for auto-saving:

```
git add .
git commit -m "Auto-save on $(date)"
git push origin master