#! /usr/bin/env bash

for dir in /data/slskd/downloads/*; do
  [[ -d "$dir" ]] || continue
  wrtag move "$dir"
done

