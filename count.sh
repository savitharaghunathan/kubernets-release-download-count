#!/bin/bash

# Output file
OUTPUT_FILE="kubernetes_download_counts.txt"

# Initialize total download counter
total_downloads=0

# Write the command to the output file
echo "Command executed:" > $OUTPUT_FILE
echo 'for i in {0..15}; do curl -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/kubernetes/kubernetes/releases/tags/v1.22.$i" | jq ".assets[] | {name: .name, download_count: .download_count, version: \"v1.22.$i\"}"; done' >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Iterate through each release and fetch download counts
for i in {0..15}; do
  echo "Release: v1.22.$i" >> $OUTPUT_FILE

  # Fetch release data
  response=$(curl -s -H "Accept: application/vnd.github.v3+json" \
       "https://api.github.com/repos/kubernetes/kubernetes/releases/tags/v1.22.$i")

  # Check if response contains "assets"
  if echo "$response" | jq -e '.assets' > /dev/null 2>&1; then
    # Calculate downloads for this release
    release_downloads=$(echo "$response" | jq '[.assets[].download_count] | add')
    total_downloads=$((total_downloads + release_downloads))
    echo "Downloads for v1.22.$i: $release_downloads" >> $OUTPUT_FILE
  else
    echo "No assets found for v1.22.$i or API error" >> $OUTPUT_FILE
    release_downloads=0
  fi
done

# Write the total downloads to the file
echo "" >> $OUTPUT_FILE
echo "Total Downloads for v1.22.0 to v1.22.15: $total_downloads" >> $OUTPUT_FILE

# Print total downloads on the console
echo "Total Downloads for v1.22.0 to v1.22.15: $total_downloads"
