#!/bin/bash


cat << EOF
Welcome,This is a AWS S3 bucket hosting script
Please make sure you have the following prerequisites:
1. AWS CLI installed
2. AWS credentials configured
3. Enough permissions to create a new bucket, and update bucket policy
4. Your file ready to be uploaded.(file path should be absolute path)
EOF

# Clean up or create
echo "Do you want to clean up or create a new bucket?"
echo "1. Clean up"
echo "2. Create a new bucket"
read -p "Please enter your choice:" choice
case $choice in
1)
    echo "Clean up"
    ;;
2)
    echo "Create a new bucket"
    ;;
*)
    echo "Invalid input"
    exit 1
    ;;
esac



# Static file path
echo "Please enter your file path:"
read -p "Please enter your file path:" file_path
#check if *.html file exists
if [find $file_path -name "*.html" -type f]; then
  echo "html file exists"
else
  echo "html file does not exist"
  exit 1
fi

# Bucket name
echo "Please enter your bucket name:"
read -p "Please enter your bucket name:" bucket_name
cat << EOF
Choose region:
1. us-east-1
2. us-east-2
3. us-west-1
4. us-west-2
EOF

# Region
read -p "Please enter your choice:" region
case $region in
1)
    region='us-east-1'
    ;;
2)
    region='us-east-2'
    ;;
3)
    region='us-west-1'
    ;;
4)
    region='us-west-2'
    ;;
*)
    echo "Invalid input"
    exit 1
    ;;
esac

# 1. Create a new bucket with a unique name
echo "\033[31;1mCreating bucket $bucket_name in $region ...\033[0m"
aws s3 mb --region $region "s3://$bucket_name"
aws s3 ls --region $region
if [ $? -ne 0 ]; then
  echo "Bucket creation failed"
  exit 1
fi
echo "...Bucket creation succeeded"

# 2. Enable public access to the bucket
echo "\033[31;1mEnabling public access to the bucket ...\033[0m"
aws s3api put-public-access-block \
  --region $region \
  --bucket $bucket_name \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
if  [ $? -ne 0 ]; then
  echo "Public access block configuration failed"
    exit 1
fi
echo "...Public access block configuration succeeded"

# 3. Update the bucket policy for public read access:
echo "\033[31;1mUpdating the bucket policy for public read access ...\033[0m"
aws s3api put-bucket-policy \
  --region $region \
  --bucket $bucket_name \
  --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
      {
          \"Sid\": \"PublicReadGetObject\",
          \"Effect\": \"Allow\",
          \"Principal\": \"*\",
          \"Action\": \"s3:GetObject\",
          \"Resource\": \"arn:aws:s3:::$bucket_name/*\"
      }
  ]
}"
if  [ $? -ne 0 ]; then
  echo "Bucket policy update failed"
    exit 1
fi
echo "...Bucket policy update succeeded"

# 4. Enable the s3 bucket to host an `index` and `error` html page
echo "\033[31;1mEnabling the s3 bucket to host an index and error html page ...\033[0m"
aws s3 website "s3://$bucket_name" \
  --region $region \
  --index-document index.html \
  --error-document index.html
if  [ $? -ne 0 ]; then
  echo "Bucket website configuration failed"
    exit 1
fi
echo "...Bucket website configuration succeeded"

# # 5. Upload you website
echo "\033[31;1mUploading your website ...\033[0m"
aws s3 sync --region $region "s3://$bucket_name/"
if  [ $? -ne 0 ]; then
  echo "Website upload failed"
    exit 1
fi
echo "...Website upload succeeded"

# 6. Display the website URL
echo "\033[31;1mDisplaying the website URL ...\033[0m"
aws s3api get-bucket-website \
  --region $region \
  --bucket $bucket_name
if  [ $? -ne 0 ]; then
  echo "Website URL display failed"
    exit 1
fi
echo "...Website URL display succeeded"

# 7. Clean up
echo "\033[31;1mCleaning up ...\033[0m"
aws s3 rm --recursive --region $region "s3://$bucket_name"
if  [ $? -ne 0 ]; then
  echo "Bucket cleanup failed"
    exit 1
fi
echo "...Bucket cleanup succeeded"