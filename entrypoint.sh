#!/bin/bash

set -e

git --version

git fetch --prune --prune-tags

latest_tag=''

if [ "${INPUT_SEMVER_ONLY}" = 'false' ]; then
  # Get a actual latest tag.
  latest_tag=$(git describe --abbrev=0 --tags)
else
  # Get a latest tag in the shape of semver.
  for ref in $(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags); do
    tag="${ref#refs/tags/}"
    if echo "${tag}" | grep -Eq '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$'; then
      latest_tag="${tag}"
      break
    fi
  done
fi

if [ "${latest_tag}" != '' ]; then
  echo "Latest (by time) semver tag is $latest_tag"
  git_commit=$(git rev-list -n 1 $latest_tag)
  assigned_tags_str=$(git tag --points-at $git_commit)

  assigned_tags=($assigned_tags_str)
  assigned_tags_len=${#assigned_tags[@]}

  if [ $assigned_tags_len -gt 1 ]; then

    echo "Multile other tags were found: ${assigned_tags[@]}"
    
    for i in "${assigned_tags[@]}"
    do
      echo "check $i"
      result=$(source semver2.sh $latest_tag $i)

      if [ $result = -1 ]; then
        echo "$i is the latest tag now"
        latest_tag=$i
      fi
    done

  fi

elif [ "${latest_tag}" = '' ] && [ "${INPUT_WITH_INITIAL_VERSION}" = 'true' ]; then
  latest_tag="${INPUT_INITIAL_VERSION}"
fi

echo "::set-output name=tag::${latest_tag}" 