#!/bin/bash
set -e

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

# For public IPv4 address:
# value=$(curl -sS 'http://members.3322.org/dyndns/getip')

# For global IPv6 address:
# type='AAAA'
# [[ "$(ip addr show dev eth0 scope 0)" =~ inet6\ ([^/]+) ]]

[[ "$(ip addr show dev eth0 scope 0)" =~ inet\ ([^/]+) ]]
value=${BASH_REMATCH[1]}

query="AccessKeyId=$accessKeyId&Action=$action&RR=$(urlencode $rr)&RecordId=$recordId&SignatureMethod=$signatureMethod&SignatureNonce=$signatureNonce&SignatureVersion=$signatureVersion&Timestamp=$(urlencode $timestamp)&Type=$type&Value=$(urlencode $value)&Version=$version"
toSign="GET&$(urlencode "/")&$(urlencode $query)"
signature=$(echo -n $toSign | openssl sha1 -binary -hmac "$accessKeySecret&" | base64)
requestQuery="$query&Signature=$(urlencode $signature)"
url="http://alidns.aliyuncs.com/?$requestQuery"

resp=$(curl -sS $url)

if [[ ! "$resp" =~ Error ]]; then
  echo "<5>Updated: $value"
elif [[ ! "$resp" =~ DomainRecordDuplicate ]]; then
  [[ "$resp" =~ \<Message\>(.+)\</Message\> ]]
  echo "<4>Error: ${BASH_REMATCH[1]}"
fi
