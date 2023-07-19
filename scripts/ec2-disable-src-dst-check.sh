#!/usr/bin/env bash

if [ -z ${AWS_PROFILE} ]; then
  echo "Error: required variable ${AWS_PROFILE} not set"
  exit 1
fi
if [ -z ${AWS_REGION} ]; then
  echo "Error: required variable AWS_REGION not set"
  exit 1
fi
if [ -z ${INSTANCE_ID} ]; then
  echo "Error: required variable INSTANCE_ID not set"
  exit 1
fi

aws ec2 modify-instance-attribute --profile ${AWS_PROFILE} --region ${AWS_REGION} \
                  --no-source-dest-check \
                  --instance-id ${INSTANCE_ID}
