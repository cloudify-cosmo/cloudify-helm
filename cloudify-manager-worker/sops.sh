#!/usr/bin/env bash

set -eu -o pipefail

command=$1

aws_profile="cloudify-automation"
aws_region="eu-west-1"
key_alias="terraform"
file_path="templates/k8s_secrets.yml"

if [[ $command = "encrypt" ]]; then
	key_info=$(aws --profile $aws_profile --region $aws_region kms list-aliases | jq -r ".Aliases[] | select(.AliasName | contains (\"$key_alias\"))")
	echo "Using key:" 1>&2
	echo "$key_info" | jq 1>&2
	key_id=$(echo "$key_info" | jq -r .TargetKeyId)
	arn_prefix=$(echo "$key_info" | jq -r .AliasArn | sed 's|:alias/.*$||')
	key_arn="$arn_prefix:key/$key_id"
	sops --aws-profile "$aws_profile" --kms "$key_arn" --in-place --encrypt "$file_path"
	exit 0
elif [[ $command = "decrypt" ]]; then
	sops --decrypt --in-place "$file_path"
	exit 0
else
	echo "Unknown command: $command"
	exit 1
fi
