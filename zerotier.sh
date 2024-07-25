#!/bin/bash


#Message for when there are no compatible arguments
error="Error, try --help or -h for help."


#Checking files
if [ -f "$HOME/.zerotier/errors.log" ]; then
      echo -n ""
else
      mkdir -p "$HOME/.zerotier"
fi


#Input capture
argument_1=$1
argument_2=$2
argument_3=$3
argument_4=$4
token_name=$(grep "$argument_2" "$HOME/.zerotier/zerotier.conf" | tail -n1)


#Testing argument_2
if [ "$token_name" = "$argument_2" ]; then
     token=$(gpg -q -d "$HOME/.zerotier/${argument_2}.gpg") 2>> "$HOME/.zerotier/errors.log"
     authorization="Authorization: token "$token""
else
     authorization="Authorization: token "$argument_2""
fi


#Save token encrypted
save_token(){ 
token="$(xclip -o -selection clipboard)"
echo "$token" > $HOME/.zerotier/token.temp
echo "$argument_2" >> "$HOME/.zerotier/zerotier.conf"
gpg -c $HOME/.zerotier/token.temp
mv $HOME/.zerotier/token.temp.gpg "$HOME/.zerotier/${argument_2}.gpg"
shred -zu $HOME/.zerotier/token.temp
}


#Message for help use
help(){
echo "zerotier 1.3
Usage: zerotier [Options] {token} {network} {member}
    --save-token NAME 
    --list-network TOKEN
    --list-member TOKEN NETWORK
    --authorize TOKEN NETWORK MEMBER
    --deauthorize TOKEN NETWORK MEMBER
Options Summary
    -st, --save-token: Encrypt and save your token from the clipboard.
    -ln, --list-network: List current networks.
    -lm, --list-members: List network members.
    -a, --authorize: Authorize a network member.
    -d, --deauthorize: Deauthorize a network member." 
}


#List current network
list_current_network(){
curl -s -H "$authorization" "https://api.zerotier.com/api/v1/network" | jq '.[] | [
    .id,
    .config.name,
    .config.description,
    .totalMemberCount,
    .config.creationTime,
    .config.ipAssignmentPools[0].ipRangeStart,
    .config.ipAssignmentPools[0].ipRangeEnd
  ]' | jq -rs '.[] | @csv' 2>> $HOME/.zerotier/errors.log
}


#List network members
list_network_members(){
curl -s -H "$authorization" "https://api.zerotier.com/api/v1/network/$argument_3/member" | jq '.[] | [
    .id,
    .lastOnline,
    .physicalAddress,
    .ipAssignments,
    .name
  ]' | jq -rs '.[] | @csv' 2>> $HOME/.zerotier/errors.log
}


#Authorize a network member
authorize(){
curl -s -H "$authorization" -X POST "https://api.zerotier.com/api/v1/network/$argument_3/member/$argument_4" --data '{"config": {"authorized": true}}' | grep -Po "\"authorized\"\:\S{1,4}" 2>> $HOME/.zerotier/errors.log
}


#Deauthorize a network member
deauthorize(){
curl -s -H "$authorization" -X POST "https://api.zerotier.com/api/v1/network/$argument_3/member/$argument_4" --data '{"config": {"authorized": false}}' | grep -Po "\"authorized\"\:\S{1,5}" 2>> $HOME/.zerotier/errors.log
}


if [ "$1" = "--save-token" ] || [ "$1" = "-st" ]; then
    save_token
exit 20
fi
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    help
exit 21
fi
if [ "$1" = "--list-network" ] || [ "$1" = "-ln" ]; then
    list_current_network
exit 22
fi
if [ "$1" = "--list-members" ] || [ "$1" = "-lm" ]; then
    list_network_members
exit 23
fi
if [ "$1" = "--authorize" ] || [ "$1" = "-a" ]; then
    authorize
exit 24
fi
if [ "$1" = "--deauthorize" ] || [ "$1" = "-d" ]; then
    deauthorize 
exit 25
else
    echo $error
    exit 26
fi