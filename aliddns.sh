#!/bin/sh
sleep 10
while true
do
  urlencode()
  {
    php -r "echo urlencode('$1');" | sed -e 's/+/%20/g' -e 's/*/%21/g' -e 's/%7E/~/g'
    #php used, can be replaced by your own urlencode function
  }

  version='2015-01-09'
  accessKeyId='' #your accessKeyId here
  accessKeySecret='' #your accessKeySecret here
  signatureMethod='HMAC-SHA1'
  timestamp=$(date -u +%Y-%m-%dT%TZ)
  signatureVersion='1.0'
  signatureNonce=$(cat /proc/sys/kernel/random/uuid)
  action='UpdateDomainRecord'
  recordId=0 #your recordId here, this can be found by viewing the source code on aliyun web console
  rR='@'
  type='A'
  value=$(curl -s 'http://members.3322.org/dyndns/getip')

  query="AccessKeyId=$accessKeyId&Action=$action&RR=$(urlencode $rR)&RecordId=$recordId&SignatureMethod=$signatureMethod&SignatureNonce=$signatureNonce&SignatureVersion=$signatureVersion&Timestamp=$(urlencode $timestamp)&Type=$type&Value=$value&Version=$version"
  toSign="GET&$(urlencode "/")&$(urlencode $query)"
  signature=$(echo -n $toSign | openssl sha1 -binary -hmac "$accessKeySecret&" | base64)
  requestQuery="AccessKeyId=$accessKeyId&Action=$action&RR=$(urlencode $rR)&RecordId=$recordId&Signature=$(urlencode $signature)&SignatureMethod=$signatureMethod&SignatureNonce=$signatureNonce&SignatureVersion=$signatureVersion&Timestamp=$(urlencode $timestamp)&Type=$type&Value=$value&Version=$version"
  url="http://alidns.aliyuncs.com/?$requestQuery"

  curl $url
  echo
  sleep 60
done