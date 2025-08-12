@echo off
echo Auto-saving your Flutter app to GitHub...

REM Add all changes
git add .

REM Check if there are changes to commit
git diff-index --quiet HEAD || git commit -m "Auto-save on %date% at %time%"

REM Push to GitHub
git push origin master

echo Auto-save completed.