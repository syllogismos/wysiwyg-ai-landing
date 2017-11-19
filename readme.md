

## How to deploy

After changing the details, run this command to make the changes


```s3cmd sync --acl-public --exclude=.git --exclude=make-website.sh --cf-invalidate --cf-invalidate-default-index ./ s3://www.eschernode.com```


## Bare domain instructions
https://www.davidbaumgold.com/tutorials/host-static-site-aws-s3-cloudfront/#redirect-bare-domain-to-www
## Notes
This landing page is hosted on S3 and Cloudfront using this script lifted from here https://gist.github.com/tomfuertes/9175005
```
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
```