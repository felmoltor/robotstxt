#!/bin/bash

if  [ "$#" -lt 1 ];
then
    echo "Usage: $0 <domains file>"
    exit 1
fi

hits=$(whereis -b timeout | cut -f2 -d: | tr -d '\n' | wc -c)
if [ $hits -eq 0 ];then
    echo "You don't have the coreutils binary 'timeout'. Install it before executing this script"
    exit 2
fi

echo "===== ROBOTS TXT Dictionary generator ===="
DOMAINS=$1
TIMEOUT=20

if [ ! -d output ];then
    mkdir output
fi
if [ -f output/robots.entries.txt ];then
    read -p "Warning: output folder is not empty, do you want to delete the file contents of this folder [y/N]: " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "" > output/robots.entries.txt
        echo "" > output/robots.sorted.full.path.txt
        echo "" > output/robots.sorted.rootfolder.txt
        echo "" > output/robots.sorted.files.txt
    else
        echo "User canceled the script"
        exit 3
    fi
fi

if [ -f $DOMAINS ];
then
    ndom=$(wc -l $DOMAINS | cut -f1 -d' ')
    cont=0

    for domain in `cat $DOMAINS`
    do
        cont=$((cont+1))
        url=$domain
        # If the domain does not have the protocol http or https handler, add it
        if [ ! "http://*" == $domain ] && [ ! "https://*" == $domain ];
        then
            domain="http://"$domain
        fi
       
        echo "($cont/$ndom) Fetching robots from '$domain'..."
        timeout $TIMEOUT bash -c "curl -L -s \"$domain/robots.txt\" | grep 'Disallow:' | cut -d' ' -f2 >> output/robots.entries.txt"
        err=$?
        if [ $err -gt 0 ];then
            echo "The last command timed out after $TIMEOUT seconds. Skiping to the next domain"
            continue
        fi
    done

    echo ""
    echo "Done fetching robots.txt, now sorting entries"
    echo ""
    # Sort by full path of the denied entry
    cat output/robots.entries.txt | sort | uniq -c | sort -rn > output/robots.sorted.full.path.txt
    # Sort by root folder of the denied entry
    cat output/robots.entries.txt | cut -f2 -d'/' | sort | uniq -c | sort -nr > output/robots.sorted.rootfolder.txt
    # Sort by files frequencies
    cat output/robots.entries.txt | grep -E "\." | awk -F/ '{print $NF}' | awk -F'?' '{print $1}' | sort | uniq -c  | sort -nr > output/robots.sorted.files.txt
    echo "Done sorting stats. Bye"
else
    print "The file '$DOMAINS' is not accessible or doesn't exists"
fi
