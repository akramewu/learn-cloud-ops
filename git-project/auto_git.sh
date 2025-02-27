#!/bin/bash

# Change to the directory of your Git repository
cd /Users/D073963/mygithub/learn-cloud-ops-main || exit

# Add all changes
git add .

# Commit with a timestamp message
commit_message="Auto commit: $(date +'%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_message"

# Push changes to the remote repository
git push origin main  # Change 'main' to your branch if needed

echo "Git changes pushed successfully!"