#!/bin/bash

if  [ "$#" -lt 1 ];
then
    echo "Usage: $0 <domains file>"
    exit 1
fi

echo "===== ROBOTS TXT ===="
DOMAINS=$1

if [ ! -d output ];then
    mkdir output
fi
echo "" > output/robots.entries.txt
echo "" > output/robots.sorted.full.path.txt
echo "" > output/robots.sorted.rootfolder.txt
echo "" > output/robots.sorted.files.txt

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
        curl -L -s "$domain/robots.txt" | grep "Disallow:" | cut -d' ' -f2 >> output/robots.entries.txt
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
