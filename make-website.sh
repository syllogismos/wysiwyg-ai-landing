#!/usr/bin/env bash

# To run:
# $ brew uninstall s3cmd && brew install s3cmd --HEAD
# $ s3cmd --configure # fill in w/ amazon account vars
# $ cd path/to/local/static/site
# $ wget https://gist.githubusercontent.com/tomfuertes/9175005/raw/make-website.sh
# $ bash make-website.sh
# 
# NOTE: cfcreate takes ~15 minutes to run on AWS.
# NOTE: Domains HAVE TO have a subdomain (aka can't use gaab.today, can use run.gaab.today) / 
#           http://superuser.com/questions/264913/cant-set-example-com-as-a-cname-record

set -e

command -v s3cmd >/dev/null 2>&1 || { echo >&2 "I require s3cmd but it's not installed.  Aborting."; exit 1; }

if [[ ! ( -f ~/.s3cfg ) ]]; then
    echo "I require s3cmd to be configured."
    echo "Please run 's3cmd --configure' and try again."
    exit 1
fi

DOMAIN=$1

echo "making s3 bucket s3://$DOMAIN"
s3cmd mb s3://$DOMAIN

echo "public acl on s3://$DOMAIN"
s3cmd setacl --acl-public s3://$DOMAIN

echo "configure website on s3://$DOMAIN"
s3cmd ws-create --ws-index=index.html s3://$DOMAIN

echo "making cloudfront bucket for $domain"
s3cmd cfcreate --cf-default-root-object=index.html --cf-add-cname=$DOMAIN s3://$DOMAIN

echo "syncing ./ with s3://$domain"
s3cmd sync --acl-public --exclude=.git --exclude=make-website.sh ./ s3://$DOMAIN

echo ""
echo "MANUAL STEP - Now go modify your DNS to CNAME to the cloudfront.net url above"
echo ""
echo "To deploy again, just run the following:"
echo ""
echo "s3cmd sync --acl-public --exclude=.git --exclude=make-website.sh --cf-invalidate --cf-invalidate-default-index ./ s3://$DOMAIN"