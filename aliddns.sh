#!/bin/bash

urlencode() {
    # urlencode <string>

    local LANG=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}

sleep 10
while true
do
  version='2015-01-09'

  # Acquire your own access key and fill it below.
  # See: https://ram.console.aliyun.com/ (Preferred)
  #      https://usercenter.console.aliyun.com/
  accessKeyId='yourown'
  accessKeySecret='yourown'

  signatureMethod='HMAC-SHA1'
  timestamp=$(date -u +%Y-%m-%dT%TZ)
  signatureVersion='1.0'
  signatureNonce=$(cat /proc/sys/kernel/random/uuid)
  action='UpdateDomainRecord'

  # Record ID can be found by viewing the source code of
  # Aliyun DNS Resolution Settings page. It is located in
  # the attribute "data-row-key" of the label "tr", at the
  # row of the record.
  # See: https://dns.console.aliyun.com/
  recordId='233'

  rr='@'
  type='A'
  value=$(curl -s 'http://members.3322.org/dyndns/getip')
  # For global IPv6 address:
  # type='AAAA'
  # value=$(ip -6 addr show dev eth0 scope 0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')

  query="AccessKeyId=$accessKeyId&Action=$action&RR=$(urlencode $rr)&RecordId=$recordId&SignatureMethod=$signatureMethod&SignatureNonce=$signatureNonce&SignatureVersion=$signatureVersion&Timestamp=$(urlencode $timestamp)&Type=$type&Value=$(urlencode $value)&Version=$version"
  toSign="GET&$(urlencode "/")&$(urlencode $query)"
  signature=$(echo -n $toSign | openssl sha1 -binary -hmac "$accessKeySecret&" | base64)
  requestQuery="$query&Signature=$(urlencode $signature)"
  url="http://alidns.aliyuncs.com/?$requestQuery"

  curl $url
  echo
  sleep 60
done
