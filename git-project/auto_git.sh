#!/bin/bash

cd /Users/D073963/mygithub/learn-cloud-ops-main/git-project || exit

git checkout main
git pull --rebase origin main || git rebase --abort

git add .
git commit -m "Auto commit: $(date)"
git push origin main