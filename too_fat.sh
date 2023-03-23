#!/bin/bash
# This script is used to clean up the /tmp and /var/log directories

echo " _____             _____     _   "
echo "|_   _|__   ___   |  ___|_ _| |_ "
echo "  | |/ _ \ / _ \  | |_ / _\`| __|"
echo "  | | (_) | (_) | |  _| (_| | |_ "
echo "  |_|\___/ \___/  |_|  \__,_|\__|"


# get OS and display it
hostname=$(hostname)
echo ""
echo ""
echo ""
echo "Your currently at ---> ${hostname} <---"
echo ""
echo ""
echo ""

# Reecord the current size of /tmp and /var/log
tmp_before=$(du -sh /tmp)
log_before=$(du -sh /var/log)
echo "tmp before: ${tmp_before}"
echo "log before: ${log_before}"
echo ""
echo ""
echo ""


# Prompt the user to choose which job to perform
echo "Which job would you like to perform?"
echo ""
echo "1. Clean /tmp only"
echo ""
echo "2. Clean old logs"
echo ""
echo "3. Clean all"
echo ""
echo ""
echo ""

read choice

# Ask files to be deleted for over how many days not been modified
echo "How many days not been modified?"
read days


# Select files not been modified for input days and show the list of files that will be deleted, and total size
case $choice in
1)
    echo "File sizes in /tmp:"
    echo "---------------------"
    find /tmp -type f -mtime +$days -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    echo ""
    echo "Total file size in /tmp:"
    echo "------------------------"
    find /tmp -type f -mtime +$days -exec du -s {} \; | awk '{ sum += $1 } END { printf "%.2f MB\n", sum / 1024 }'
    ;;
2)
    echo "File sizes in /var/log:"
    echo "------------------------"
    find /var/log -type f -mtime +$days -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    echo ""
    echo "Total file size in /var/log:"
    echo "---------------------------"
    find /var/log -type f -mtime +$days -exec du -s {} \; | awk '{ sum += $1 } END { printf "%.2f MB\n", sum / 1024 }'
    ;;
3)
    echo "File sizes in /tmp:"
    echo "---------------------"
    find /tmp -type f -mtime +$days -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    echo ""
    echo "Total file size in /tmp:"
    echo "------------------------"
    find /tmp -type f -mtime +$days -exec du -s {} \; | awk '{ sum += $1 } END { printf "%.2f MB\n", sum / 1024 }'
    echo ""
    echo "File sizes in /var/log:"
    echo "------------------------"
    find /var/log -type f -mtime +$days -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
    echo ""
    echo "Total file size in /var/log:"
    echo "---------------------------"
    find /var/log -type f -mtime +$days -exec du -s {} \; | awk '{ sum += $1 } END { printf "%.2f MB\n", sum / 1024 }'
    ;;
*)
    echo "Invalid choice"
    ;;
esac


echo ""
echo ""
echo ""
# Prompt the user to confirm the deletion
echo "Are you sure you want to delete these files that are not been modified for $days days? (y/n)"
read confirm

# Delete the files if the user types Y/y or yes
case $confirm in
y|Y|yes)
    case $choice in
    1)
        rm -rf /tmp/*
        ;;
    2)
        rm -rf /var/log/*
        ;;
    3)
        rm -rf /tmp/*
        rm -rf /var/log/*
        ;;
    *)
        echo "Invalid choice"
        ;;
    esac
    ;;
*)
    echo "No files deleted"
    ;;
esac


# Display the remaining free space, compared to the original free space
tmp_after=$(du -sh /tmp)
log_after=$(du -sh /var/log)
echo ""
echo ""
echo "=========Results========="
echo ""
echo "tmp after: ${tmp_after}, before: ${tmp_before}"
echo ""
echo "log after: ${log_after}, before: ${log_before}"
echo ""


# End of script