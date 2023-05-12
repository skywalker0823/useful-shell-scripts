#!/bin/bash

usage=$(df -h /game | awk 'NR==2{print $3}')

total=$(df -h --total | awk '/total/ {print "Total disk space: " $2}')

# Convert the usage and total to GB
usage_gb=$(echo "scale=2; $usage/1024/1024" | bc)
total_gb=$(echo "scale=2; $total/1024/1024" | bc)

# Display the usage and total in GB
echo "Usage: $usage_gb GB / $total_gb GB"

# Check if the usage is over 80%
if [ $usage -gt 80 ]; then
  # Delete folders older than 120 days in /home/logs/
  find /game/logs/* -type d -mtime +120 -exec rm -rf {} \;
fi