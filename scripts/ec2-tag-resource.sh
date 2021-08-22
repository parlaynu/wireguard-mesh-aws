#!/usr/bin/env bash

if [ -z ${TAG_PROFILE} ]; then
  echo "Error: required variable ${TAG_PROFILE} not set"
  exit 1
fi
if [ -z ${TAG_REGION} ]; then
  echo "Error: required variable TAG_REGION not set"
  exit 1
fi
if [ -z ${TAG_RESOURCE_ID} ]; then
  echo "Error: required variable TAG_RESOURCE_ID not set"
  exit 1
fi
if [ -z ${TAG_NAME} ]; then
  echo "Error: required variable TAG_NAME not set"
  exit 1
fi
if [ -z ${TAG_VALUE} ]; then
  echo "Error: required variable TAG_VALUE not set"
  exit 1
fi

aws ec2 create-tags --profile ${TAG_PROFILE} --region ${TAG_REGION} \
                    --resources ${TAG_RESOURCE_ID} \
                    --tags Key=${TAG_NAME},Value=${TAG_VALUE}

