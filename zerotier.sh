#!/usr/bin/env bash

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
#Message for help use
  echo "Usage: zerotier.sh [OPTION]..."
  echo "--list-network 'token'"
  echo "--list-members 'token' 'member'"
  echo "--authorize 'token' 'network identifier' 'member identifier'"
  echo "--deauthorize 'token' 'network identifier' 'member identifier'"

elif [ "$1" = "--list-network" ]; then
#List current network
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network" | jq '.[] | [
    .id,
    .config.name,
    .config.description,
    .totalMemberCount,
    .config.creationTime,
    .config.ipAssignmentPools[0].ipRangeStart,
    .config.ipAssignmentPools[0].ipRangeEnd
  ]' | jq -rs '.[] | @csv'

elif [ "$1" = "--list-members" ]; then
#List network members
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network/$3/member" | jq '.[] | [
    .id,
    .lastOnline,
    .physicalAddress,
    .ipAssignments,
    .name
  ]' | jq -rs '.[] | @csv'

elif [ "$1" = "--authorize" ]; then
#Authorize a network member
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": true}}'

elif ["$1" = "--deauthorize" ]; then
#Deauthorize a network member
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": false}}'
else
#Message for when there are no compatible arguments
  echo "Error, try --help or -h for help."
fi