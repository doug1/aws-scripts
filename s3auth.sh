#!/bin/sh


s3sign() {
  local httpverb="${1}"
  local resource="${2}"
  local datetime="${3}"
  printf "%s\n\n\n%s\n%s%s" "${httpverb}" "${datetime}" "${resource}" | \
  openssl dgst -sha1 -hmac "${AWS_SECRET_ACCESS_KEY}" -binary | \
  openssl base64 -e -a
}

[ -z "$AWS_ACCESS_KEY_ID" ]     && { echo "Need AWS credentials" ; exit 1; }
[ -z "$AWS_SECRET_ACCESS_KEY" ] && { echo "Need AWS credentials" ; exit 1; }

s3endpoint="https://s3.amazonaws.com";
object="/bucket/filename.txt"
date="$(date -u '+%a, %d %b %Y %H:%M:%S %Z')"
signature="$( s3sign GET "${object}" "${date}" )"
curl -v -H "Authorization: AWS ${AWS_ACCESS_KEY_ID}:${signature}" \
        -H "Date: $date" "$s3endpoint$object" > /dev/null

