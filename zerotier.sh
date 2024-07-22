#!/bin/bash

#VARIABLES +++++
error="Error, try --help or -h for help."
#token=~/.z3rotier/.... TO DO 

#Message for help use +++++
help(){
echo "z3rotier 1.1
Usage: z3rotier [Options] {token} {network} {member}
              --create-token TO DO
              --list-network TOKEN 
              --list-member TOKEN NETWORK
              --authorize TOKEN NETWORK MEMBER
              --deauthorize TOKEN NETWORK MEMBER
Options Summary
  -ct, --create-token: you'll be asked for a name for your token. use the name of the token instead of the token itself. TO DO
  -ln, --list-network: list current networks.
  -lm, --list-members: list network members.
  -a, --authorize: authorize a network member.
  -d, --deauthorize: deauthorize a network member." 
}
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
help
exit 21
else
echo $error
exit 021
fi


#List current network +++++
list_current_network(){
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network" | jq '.[] | [
    .id,
    .config.name,
    .config.description,
    .totalMemberCount,
    .config.creationTime,
    .config.ipAssignmentPools[0].ipRangeStart,
    .config.ipAssignmentPools[0].ipRangeEnd
  ]' | jq -rs '.[] | @csv' 2>> ~/.z3rotier/error.log
}
if [ "$1" = "--list-network" ] || [ "$1" = "-ln" ]; then
list_current_network
exit 22
else
echo $error
exit 022
fi


#List network members +++++
list_network_members(){
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network/$3/member" | jq '.[] | [
    .id,
    .lastOnline,
    .physicalAddress,
    .ipAssignments,
    .name
  ]' | jq -rs '.[] | @csv' 2>> ~/.z3rotier/error.log
}
if [ "$1" = "--list-members" ] || [ "$1" = "-lm" ]; then
list_network_members
exit 23
else
echo $error
exit 023
fi


#Authorize a network member +++++
authorize(){
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": true}}' 2>> ~/.z3rotier/error.log
}

if [ "$1" = "--authorize" ] || [ "$1" = "-a" ]; then
authorize
exit 24
else
echo $error
exit 024
fi


#Deauthorize a network member
deauthorize(){
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": false}}' 2>> ~/.z3rotier/error.log
}
if ["$1" = "--deauthorize" ] || [ "$1" = "-d" ]; then
deauthorize
exit 25
else
#Message for when there are no compatible arguments
echo $error
exit 025
fi

