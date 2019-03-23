#!/bin/bash

# use SEARCH and REPLACE to change hostname in dump file if necessary;
# e.g. replace www.example.com with 127.0.0.1:8000
SEARCH=""
REPLACE=""

CONFIG_FILE="/var/www/html/wordpress/wp-config.php"
DUMP_FILE=$([ -e /var ] && ls -t /var/*.sql | head -1)

if [ ! -e $CONFIG_FILE ]; then
    echo "No config file"
    exit 2
fi
if [ ! -e $DUMP_FILE ]; then
    echo "No dump file"
    exit 2
fi

DB_HOST=$(grep "'DB_HOST'" $CONFIG_FILE | perl -ne '/,\s*\W(.+?)\W\s*\);/; print $1')
DB_NAME=$(grep "'DB_NAME'" $CONFIG_FILE | perl -ne '/,\s*\W(.+?)\W\s*\);/; print $1')
DB_USER=$(grep "'DB_USER'" $CONFIG_FILE | perl -ne '/,\s*\W(.+?)\W\s*\);/; print $1')
DB_PASSWORD=$(grep "'DB_PASSWORD'" $CONFIG_FILE | perl -ne '/,\s*\W(.+?)\W\s*\);/; print $1')

# create DB and user as described in wp-config.php

echo "drop database if exists $DB_NAME;" | mysql -u root -v
echo "drop user '$DB_USER'@'$BD_HOST'" | mysql -u root -v
echo "create user '$DB_USER'@'$DB_HOST' identified by '$DB_PASSWORD'"  | mysql -u root
echo "grant all privileges on $DB_NAME.* to '$DB_USER'@'$DB_HOST'" | mysql -u root -v
echo "create database $DB_NAME" | mysql -u root

if [ $SEARCH ] && [ $REPLACE ]; then
    perl -i -pe "s/$SEARCH/$REPLACE/g" $DUMP_FILE
fi

echo "Restoring database $DB_NAME from $DUMP_FILE"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < $DUMP_FILE