#!/bin/bash


#Save token encrypted
save_token(){ #TODO
token="$(xclip -o -selection clipboard)"
echo "$token" > token.temp
token_name="$2"
gpg -c $HOME/.zerotier/token.temp
mv $HOME/.zerotier/token.temp.gpg "${token_name}.gpg"
gpg -q -d "$HOME/.zerotier/${token_name}.gpg"
shred -zu $HOME/.zerotier/token.temp
}
if [ "$1" = "--save-token" ] || [ "$1" = "-st" ]; then #TODO
save_token
exit 20
else
echo $error
exit 020
fi


#Message for help use
help(){
echo "zerotier 1.2
Usage: zerotier [Options] {token} {network} {member}
              --save-token NAME TODO
              --list-network TOKEN
              --list-member TOKEN NETWORK
              --authorize TOKEN NETWORK MEMBER
              --deauthorize TOKEN NETWORK MEMBER
Options Summary
  -st, --save-token: just save the token encrypted and use the name of the token instead of the token itself. You don't have to paste your token into the terminal to keep your account secure. make sure it's in your clipboard for the first time you create it. TO DO
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


#List current network
list_current_network(){
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network" | jq '.[] | [
    .id,
    .config.name,
    .config.description,
    .totalMemberCount,
    .config.creationTime,
    .config.ipAssignmentPools[0].ipRangeStart,
    .config.ipAssignmentPools[0].ipRangeEnd
  ]' | jq -rs '.[] | @csv' 2>> $HOME/.zerotier/error.log
}
if [ "$1" = "--list-network" ] || [ "$1" = "-ln" ]; then
list_current_network
exit 22
else
echo $error
exit 022
fi


#List network members
list_network_members(){
curl -s -H "Authorization: token $2" "https://api.zerotier.com/api/v1/network/$3/member" | jq '.[] | [
    .id,
    .lastOnline,
    .physicalAddress,
    .ipAssignments,
    .name
  ]' | jq -rs '.[] | @csv' 2>> $HOME/.zerotier/error.log
}
if [ "$1" = "--list-members" ] || [ "$1" = "-lm" ]; then
list_network_members
exit 23
else
echo $error
exit 023
fi


#Authorize a network member
authorize(){
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": true}}' 2>> $HOME/.zerotier/error.log
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
curl -s -H "Authorization: token $2" -X POST "https://api.zerotier.com/api/v1/network/$3/member/$4" --data '{"config": {"authorized": false}}' 2>> $HOME/.zerotier/error.log
}
if ["$1" = "--deauthorize" ] || [ "$1" = "-d" ]; then
deauthorize
exit 25
else
echo $error
exit 025
fi


#Message for when there are no compatible arguments
error="Error, try --help or -h for help."