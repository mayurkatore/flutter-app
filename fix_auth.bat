@echo off
echo Fixing GitHub authentication issues...

REM Clear stored credentials
git config --global --unset credential.helper

echo Credentials cleared. Please run the following command and enter your GitHub username and personal access token when prompted:
echo.
echo git push origin master
echo.
echo "When prompted for username, enter your GitHub username"
echo "When prompted for password, enter your personal access token (NOT your GitHub password)"
echo.
echo "If you don't have a personal access token, create one at https://github.com/settings/tokens"