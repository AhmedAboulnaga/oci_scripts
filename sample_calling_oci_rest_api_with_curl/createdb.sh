#!/bin/bash

#########################################
# Reference
#########################################
# https://www.ateam-oracle.com/post/oracle-cloud-infrastructure-oci-rest-call-walkthrough-with-curl

#########################################
# Fill these in with your values
#########################################

#----------------------------------------
# OCID of the tenancy calls are being made in to
#----------------------------------------
tenancy_ocid="XXXXXXXXXX"

#----------------------------------------
# OCID of the user making the rest call
#----------------------------------------
user_ocid="XXXXXXXXXX"

#----------------------------------------
# Path to private PEM format key for this user
#----------------------------------------
privateKeyPath="/root/ocitemp/oci.pem"

#----------------------------------------
# Fingerprint of the private key for this user
#----------------------------------------
fingerprint="XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"

#----------------------------------------
# REST API you want to call
#----------------------------------------
rest_api="/20160918/autonomousDatabases"

#----------------------------------------
# Host you want to make the call against
#----------------------------------------
host="database.us-ashburn-1.oraclecloud.com"

#----------------------------------------
# JSON file containing the data you want to POST to the REST endpoint
#----------------------------------------
body="./request.json"

#########################################
# Do not modify anything under here
#########################################

#----------------------------------------
# Extra headers required for a POST/PUT request
#----------------------------------------
body_arg=(--data-binary @${body})
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
content_sha256_header="x-content-sha256: $content_sha256"
content_length="$(wc -c < $body | xargs)";
content_length_header="content-length: $content_length"
headers="(request-target) date host"

#----------------------------------------
# Add on the extra fields required for a POST/PUT
#----------------------------------------
headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): post $rest_api"

#----------------------------------------
# Note the order of items. The order in the signing_string matches the order in the headers, including the extra POST fields
#----------------------------------------
signing_string="$request_target\n$date_header\n$host_header"

#----------------------------------------
# Add on the extra fields required for a POST/PUT
#----------------------------------------
signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"

#----------------------------------------
# Invoke cURL
#----------------------------------------
echo "====================================================================================================="
printf '%b' "signing string is $signing_string \n"
signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
printf '%b' "Signed Request is  \n$signature\n"

echo "====================================================================================================="
set -x
curl -v -X POST --data-binary "@request.json" -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\""
