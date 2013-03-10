#!/bin/sh

######################################################################
#
#  s3authget - Simple Authenticated HTTP GET from Amazon S3
#
#  Requires OpenSSL and curl
#
#  Uses new-style virtual host bucket access, which should
#  work with all regions including US Standard.
#
#  See S3 Documentation "Virtual Hosting of Buckets" for more info:
#  http://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
#
######################################################################

usage() {
  echo "$0 s3-bucket object-path"
  echo "    The s3-bucket should be a DNS-friendly S3 bucket name"
  echo "    The object-path should include the leading /"
  exit 1
}

s3sign() {
  local httpverb="${1}"
  local resource="${2}"
  local datetime="${3}"
  printf "%s\n\n\n%s\n%s" "${httpverb}" "${datetime}" "${resource}" | \
  openssl dgst -sha1 -hmac "${AWS_SECRET_ACCESS_KEY}" -binary | \
  openssl base64 -e -a
}

bucket="$1"
objpath="$2"

[ -z "$bucket" ]  && { usage; }
[ -z "$objpath" ] && { usage; }

[ -z "$AWS_ACCESS_KEY_ID" ]     && { echo "Need AWS credentials" ; exit 1; }
[ -z "$AWS_SECRET_ACCESS_KEY" ] && { echo "Need AWS credentials" ; exit 1; }

s3host="${bucket}.s3.amazonaws.com";
date="$(date -u '+%a, %d %b %Y %H:%M:%S %Z')"
signature="$( s3sign "GET" "/${bucket}${objpath}" "${date}" )"
url="https://${s3host}${objpath}"
auth="Authorization: AWS ${AWS_ACCESS_KEY_ID}:${signature}"

curl -H "$auth" -H "Date: $date" -s "$url"

