#!/bin/bash

# Replace YOUR_GITHUB_TOKEN with your actual GitHub token
GITHUB_TOKEN="YOUR_GITHUB_TOKEN"

# Output file
OUTPUT_FILE="kubernetes_download_counts_debug.txt"

# Initialize total download counters for each release version
total_downloads_122=0
total_downloads_121=0
total_downloads_120=0
total_downloads_119=0

# Write the commands to the output file
echo "Commands executed:" > $OUTPUT_FILE

# Function to fetch download counts for a specified version
fetch_download_counts() {
  local version=$1
  local start=$2
  local end=$3
  local total_downloads=0

  for i in $(seq $start $end); do
    echo "Command executed: curl -H \"Authorization: token $GITHUB_TOKEN\" -H \"Accept: application/vnd.github.v3+json\" \"https://api.github.com/repos/kubernetes/kubernetes/releases/tags/${version}.$i\"" >> $OUTPUT_FILE
    echo "Release: ${version}.$i" >> $OUTPUT_FILE

    # Fetch release data
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" \
         "https://api.github.com/repos/kubernetes/kubernetes/releases/tags/${version}.$i")

    # Debug: write the raw response to the output file
    echo "Raw response for ${version}.$i:" >> $OUTPUT_FILE
    echo "$response" >> $OUTPUT_FILE

    # Check if response contains "message": "Not Found"
    if echo "$response" | jq -e '.message == "Not Found"' > /dev/null 2>&1; then
      echo "Release ${version}.$i not found or does not exist" >> $OUTPUT_FILE
      continue
    fi

    # Check if response contains "assets"
    if echo "$response" | jq -e '.assets | length > 0' > /dev/null 2>&1; then
      # Calculate downloads for this release
      release_downloads=$(echo "$response" | jq '[.assets[].download_count] | add')
      if [ "$release_downloads" != "null" ]; then
        total_downloads=$((total_downloads + release_downloads))
        echo "Downloads for ${version}.$i: $release_downloads" >> $OUTPUT_FILE
      else
        echo "No downloads data available for ${version}.$i" >> $OUTPUT_FILE
      fi
    else
      echo "No assets found for ${version}.$i or API error" >> $OUTPUT_FILE
    fi
  done

  # Return the total downloads for this version
  echo $total_downloads
}

# Fetch download counts for each version
total_downloads_122=$(fetch_download_counts "v1.22" 0 15)
total_downloads_121=$(fetch_download_counts "v1.21" 0 14)
total_downloads_120=$(fetch_download_counts "v1.20" 0 15)
total_downloads_119=$(fetch_download_counts "v1.19" 0 16)

# Write the total downloads to the file
echo "" >> $OUTPUT_FILE
echo "Total Downloads for v1.22.0 to v1.22.15: $total_downloads_122" >> $OUTPUT_FILE
echo "Total Downloads for v1.21.0 to v1.21.14: $total_downloads_121" >> $OUTPUT_FILE
echo "Total Downloads for v1.20.0 to v1.20.15: $total_downloads_120" >> $OUTPUT_FILE
echo "Total Downloads for v1.19.0 to v1.19.16: $total_downloads_119" >> $OUTPUT_FILE

# Print total downloads on the console
echo "Total Downloads for v1.22.0 to v1.22.15: $total_downloads_122"
echo "Total Downloads for v1.21.0 to v1.21.14: $total_downloads_121"
echo "Total Downloads for v1.20.0 to v1.20.15: $total_downloads_120"
echo "Total Downloads for v1.19.0 to v1.19.16: $total_downloads_119"
