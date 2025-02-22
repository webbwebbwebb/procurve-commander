#!/bin/bash -e

programName=$0

usage () {
    cat <<HELP_USAGE
Procurve-commander 1.0.0: execute commands against an HP Procurve switch

Usage: $programName --host <host_name> --user <user_name> [--password=<password>] --commands <command_list> [--legacyKeys]

   -c,  --commands     Comma separated list of commands to execute against the switch
   -h,  --help         Display this message and exit

Connection options:
   -H,  --host         Hostname or IP address of the switch
   -u,  --user         Username used to connect
   -p,  --password     Password for user
   -l,  --legacyKeys   Force use of deprecated key algorithms when connecting - required when connecting to older switches

Example: ./procurve-commander.sh --user manager --host procurve.home --commands "show time" --legacyKeys
HELP_USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --commands*|-c*)
      if [[ "$1" != *=* ]]; then shift; fi
      commandList="${1#*=}"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --host*|-H*)
      if [[ "$1" != *=* ]]; then shift; fi
      host="${1#*=}"
      ;;
    --legacyKeys|-l)
      useLegacyKeyAlgorithms=true
      ;;
    --password*|-p*)
      if [[ "$1" != *=* ]]; then shift; fi
      password="${1#*=}"
      ;;
    --user*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi
      user="${1#*=}"
      ;;
    *)
      >&2 printf "Unrecognised argument $1\n"
      usage
      exit 1
      ;;
  esac
  shift
done

passwordSupplied=true
if [ -z "$password" ]
then
    echo password not supplied, will attempt passwordless login
    passwordSupplied=false
fi

if [ "$useLegacyKeyAlgorithms" = true ] 
then
  sshArgs="-o KexAlgorithms=diffie-hellman-group14-sha1 -o HostKeyAlgorithms=ssh-rsa -m hmac-sha1-96"
fi

# set bash internal field separator to comma
IFS=,

# iterate through commandList to build expect commands
for command in $commandList; do
  # trim
  command=`echo $command |  xargs`
  toBeSent="${toBeSent}expect \"#\"; send \"$command\n\"; "
done

# write the expect script into the $es variable
es="expect -c '"
es="${es}  set timeout 20;"
es="${es}  spawn ssh $sshArgs $user@$host;"
if [ "$passwordSupplied" = true ] 
then
  es="${es}  expect \"password\";"
  es="${es}  send \"$password\r\";"
fi
es="${es}  expect \"continue\";"
es="${es}  send \"\n\";"
es="${es}  $toBeSent"
es="${es}  expect \"#\";"
es="${es}  send \"exit\n\";"
es="${es}  expect \">\";"
es="${es}  send \"exit\n\";"
es="${es}  expect \"log out\";"
es="${es}  send \"y\";"
es="${es}  expect eof;"
es="${es}  wait"
es="${es}  '"

# reset IFS to default value (usually space)
unset IFS

# execute the expect script
eval $es

# swallow any control codes left at the terminal prompt
read -e -t1
