#!/bin/bash

# Set variables for resource names
BUCKET_NAME="tf-state-react-jenkins"  # Unique bucket name using timestamp
TABLE_NAME="terraform-state-lock"
REGION="us-east-1"  # Change this to your preferred region

# Create S3 bucket with versioning enabled
aws s3api create-bucket \
    --bucket ${BUCKET_NAME} \
    --region ${REGION} \
    $(if [ "${REGION}" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=${REGION}"; fi)

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
    --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

# Enable server-side encryption for the bucket
aws s3api put-bucket-encryption \
    --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block all public access to the bucket
aws s3api put-public-access-block \
    --bucket ${BUCKET_NAME} \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name ${TABLE_NAME} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ${REGION}

# Output the bucket name for reference
echo "Created S3 bucket: ${BUCKET_NAME}"
echo "Created DynamoDB table: ${TABLE_NAME}"