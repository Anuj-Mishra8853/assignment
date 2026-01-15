#!/bin/bash

echo "=== S3 Access Testing Script ==="
echo

BUCKET_NAME=${S3_BUCKET_NAME}
TEST_FILE="test-file-$(date +%s).txt"
TEST_CONTENT="Hello from RBAC test pod at $(date)"

if [ -z "$BUCKET_NAME" ]; then
    echo "ERROR: S3_BUCKET_NAME environment variable not set"
    exit 1
fi

echo "Testing S3 bucket: $BUCKET_NAME"
echo

# Test 1: Upload file to S3
echo "1. Testing: Upload file to S3"
echo "$TEST_CONTENT" > /tmp/$TEST_FILE
aws s3 cp /tmp/$TEST_FILE s3://$BUCKET_NAME/$TEST_FILE
if [ $? -eq 0 ]; then
    echo "✅ Upload successful"
else
    echo "❌ Upload failed"
fi
echo

# Test 2: List bucket contents
echo "2. Testing: List bucket contents"
aws s3 ls s3://$BUCKET_NAME/
echo

# Test 3: Download file from S3
echo "3. Testing: Download file from S3"
aws s3 cp s3://$BUCKET_NAME/$TEST_FILE /tmp/downloaded-$TEST_FILE
if [ $? -eq 0 ]; then
    echo "✅ Download successful"
    echo "Downloaded content:"
    cat /tmp/downloaded-$TEST_FILE
else
    echo "❌ Download failed"
fi
echo

# Test 4: Delete file from S3
echo "4. Testing: Delete file from S3"
aws s3 rm s3://$BUCKET_NAME/$TEST_FILE
if [ $? -eq 0 ]; then
    echo "✅ Delete successful"
else
    echo "❌ Delete failed"
fi
echo

echo "=== S3 Testing Complete ==="
