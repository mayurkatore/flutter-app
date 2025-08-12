# GitHub Auto-Save Setup Guide

This document provides a complete guide to setting up automatic saving of your code to GitHub.

## Prerequisites

1. Git installed on your system
2. A GitHub account
3. A repository on GitHub for your project

## Setup Instructions

### 1. Initialize Git Repository

If you haven't already, initialize a Git repository in your project folder:

```bash
git init
```

### 2. Add Files and Make Initial Commit

Add all your files to the repository:

```bash
git add .
git commit -m "Initial commit"
```

### 3. Connect to GitHub Repository

Set the remote origin to your GitHub repository:

```bash
git remote add origin https://github.com/your-username/your-repo-name.git
```

### 4. Configure Authentication

There are several ways to authenticate with GitHub:

#### Option A: Personal Access Token (Recommended)

1. Create a personal access token:
   - Go to https://github.com/settings/tokens
   - Click "Generate new token" and then "Generate new token (classic)"
   - Give your token a name (e.g., "auto-save")
   - Select an expiration date
   - Select the "repo" scope
   - Click "Generate token"
   - Copy the generated token

2. Configure Git to store your credentials:
   ```bash
   git config --global credential.helper store
   ```

3. Run a Git command that requires authentication and enter your username and token when prompted.

#### Option B: SSH Keys

1. Generate SSH keys:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

2. Add the SSH key to your GitHub account:
   - Go to https://github.com/settings/keys
   - Click "New SSH key"
   - Paste your public key (from ~/.ssh/id_rsa.pub) into the key field
   - Give it a title and click "Add SSH key"

3. Change your remote URL to use SSH:
   ```bash
   git remote set-url origin git@github.com:your-username/your-repo-name.git
   ```

### 5. Set Up Auto-Save Scripts

We've created two scripts to help with auto-saving:

- `auto_save.bat` - Windows batch script
- `auto_save.ps1` - PowerShell script

These scripts will:
1. Add all changes to Git
2. Commit with a timestamp message
3. Push to GitHub

### 6. Configure Git Hooks

We've created a pre-commit hook that will automatically save your code:

- `.git/hooks/pre-commit.bat` - Windows batch file

This hook will run automatically before each commit.

## Troubleshooting Common Issues

### Authentication Errors

If you see errors like:
```
remote: Permission to username/repo.git denied to other-user.
fatal: unable to access 'https://github.com/username/repo.git/': The requested URL returned error: 403
```

This means you're authenticated as the wrong user. To fix this:

1. Clear stored credentials:
   ```bash
   git config --global --unset credential.helper
   ```

2. Reconfigure with the correct credentials using one of the authentication methods above.

### Host Key Verification Failed

If you see:
```
Host key verification failed.
```

Add GitHub's SSH key to your known hosts:
```bash
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```

## Testing Auto-Save

To test the auto-save functionality:

1. Make a small change to any file in your project
2. Run one of the auto-save scripts:
   - `auto_save.bat` (Windows)
   - `auto_save.ps1` (PowerShell)
3. Check your GitHub repository to see if the changes were pushed

## Scheduling Auto-Save (Optional)

You can schedule the auto-save script to run automatically using Task Scheduler on Windows:

1. Open Task Scheduler
2. Create a new task
3. Set the trigger to run at your desired frequency (e.g., every hour)
4. Set the action to run the auto_save.bat script
5. Save the task

## Manual Git Commands for Auto-Save

You can also manually run these commands for auto-saving:

```bash
git add .
git commit -m "Auto-save on $(date)"
git push origin master
```

## Conclusion

You now have a complete setup for automatically saving your code to GitHub. The scripts and hooks provided will help ensure your code is regularly backed up to GitHub without requiring manual intervention for each save.