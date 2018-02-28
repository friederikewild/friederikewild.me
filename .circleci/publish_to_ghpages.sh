#!/usr/bin/env bash

# Exit script if any command in it happens to fail
set -e

# Prevent accidentally publishing uncommited changes
if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

# Remove public directory and clean information about git worktrees
echo "Deleting old publication"
rm -rf public
git worktree prune

# Checkout current master branch into public directory
echo "Checking out master branch into public"
git worktree add -B master public origin/master

# After checkout you'll have current page version, remove it
# before building new one
echo "Removing existing files"
rm -rf public/*

echo "Generating site into public directory"
docker-compose run hugo

# If you're not using custom domain or don't need CNAME
# file you can just remove those 2 lines.
echo "Copying CNAME"
cp CNAME public/

# Set timestamp to time in miliseconds from epoch
# It's gonna be used to tag release.
timestamp=$(date +%s%3N)
echo "Publishing version $timestamp"

# Commit everything in public dir, push changes and add git tag to it.
cd public && \
  git add --all && \
  git commit -m "publish_to_ghpages" && \
  git tag "$timestamp" && \
  git push origin master && \
  git push origin "$timestamp"


echo "Published version $timestamp"