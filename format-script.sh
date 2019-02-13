#!/bin/bash

stat() {
    if [ $? -eq 0 ]; then
       echo "$1 Success"
    else
       echo "$1 Failed"
       exit 1
    fi
}

STACK_ID=$1
TEMPLATE_ID=$2

if [ -z "$STACK_ID" -o -z "$TEMPLATE_ID" ]; then
   echo -e "Both Stack name and file name needed"
   exit 1
fi

aws cloudformation list-stacks | grep $STACK_ID &>/dev/null
stat 'List Stack' $?

if [ $? -eq 0 ]; then
   aws cloudformation delete-stack --stack-name $STACK_ID &>/dev/null
   stat 'Del Stack' $?
   aws cloudformation wait stack-delete-complete --stack-name $STACK_ID
fi

aws cloudformation create-stack --stack-name $STACK_ID --template-body file://$TEMPLATE_ID &>/tmp/stack-log

if [ $? -ne 0 ]; then
   cat /tmp/stack-log
fi
stat 'Create Stack' $?

aws cloudformation wait stack-create-complete --stack-name $STACK_ID
