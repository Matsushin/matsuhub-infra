#!/bin/bash
set -e
source .env
function get_aws_user {                                                                                                                                                                            
      ls -lah $HOME/.aws/credentials | awk '{print $NF}' |xargs basename
}
if [[ $(get_aws_user) != $(echo $app_aws_user) ]];then
   echo "AWS Account $get_aws_user is invlid."
   echo "check if the account is correct"
   exit 1
fi

echo "AWS Account is correct: $(get_aws_user)"


function plan {
  echo "Executing:  terraform plan"
  terraform plan -out=tf.output || exit 1
}
function apply {
  echo "Executing:  terraform apply"
  terraform apply tf.output || exit 1
  echo "Done:  terraform apply"
  echo "Executing: check idempotency"
  get_one_if_no_chenge=$(terraform plan -no-color| grep "No changes. Your infrastructure matches the configuration." | wc -l)
  if [[ $get_one_if_no_chenge -eq 1 ]];then
    echo "Done: check idempotency"
    git add .
  else
    echo "Failed: check idempotency"
    echo "something wrong."
    echo "Do not execute : git add ."
  fi
}

subcommand="$1"
shift

case $subcommand in
    plan)
        plan
        ;;
    apply)
        apply
        ;;
    *)
        echo "default"
        ;;
esac
