#!/bin/bash

# List of project directories (Update this list with your actual paths)
PROJECTS=(
    "/Users/D073963/mygithub/learn-cloud-ops-main/git-project"
    "/Users/D073963/mygithub/learn-cloud-ops-main/aws-terraform-project"
)

echo "🚀 Starting Git update process for all projects..."

# Loop through each project directory
for PROJECT_DIR in "${PROJECTS[@]}"; do
    echo "🔄 Processing project: $PROJECT_DIR"

    # Check if directory exists
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "❌ Directory not found: $PROJECT_DIR. Skipping..."
        continue
    fi

    # Navigate to project directory
    cd "$PROJECT_DIR" || exit

    # Ensure we're on the main branch
    git checkout main

    # Check for unstaged changes before pulling
    if [[ -n $(git status --porcelain) ]]; then
        echo "⚠️  Unstaged changes detected in $PROJECT_DIR. Stashing them..."
        git stash
    fi

    # Pull the latest changes with rebase
    if ! git pull --rebase origin main; then
        echo "❌ Rebase failed in $PROJECT_DIR. Aborting..."
        git rebase --abort
        continue
    fi

    # Restore stashed changes if they exist
    if git stash list | grep -q "WIP"; then
        echo "🔄 Restoring stashed changes in $PROJECT_DIR..."
        git stash pop
    fi

    # Check if there are changes to commit
    if [[ -n $(git status --porcelain) ]]; then
        git add .
        git commit -m "Auto commit: $(date)"
        git push origin main
        echo "✅ Changes successfully committed and pushed in $PROJECT_DIR."
    else
        echo "✅ No new changes to commit in $PROJECT_DIR. Skipping push."
    fi

    echo "--------------------------------------"
done

echo "🎉 All projects processed successfully!"
