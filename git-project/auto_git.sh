#!/bin/bash

# Set working directory
cd /Users/D073963/mygithub/learn-cloud-ops-main/git-project || exit

# Switch to main branch
git checkout main

# Check for unstaged changes before pulling
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  Unstaged changes detected. Stashing them temporarily..."
    git stash
fi

# Pull the latest changes with rebase
if ! git pull --rebase origin main; then
    echo "❌ Rebase failed. Aborting..."
    git rebase --abort
    exit 1
fi

# Restore any stashed changes
if git stash list | grep -q "WIP"; then
    echo "🔄 Restoring stashed changes..."
    git stash pop
fi

# Check if there are changes to commit
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "Auto commit: $(date)"
    git push origin main
    echo "✅ Changes successfully committed and pushed."
else
    echo "✅ No new changes to commit. Skipping push."
fi
