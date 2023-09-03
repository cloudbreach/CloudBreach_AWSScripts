#!/bin/bash                                                                                                        

cat << "EOF"
 _____ _                 _______                     _       _       
/  __ \ |               | | ___ \                   | |     (_)      
| /  \/ | ___  _   _  __| | |_/ /_ __ ___  __ _  ___| |__    _  ___  
| |   | |/ _ \| | | |/ _` | ___ \ '__/ _ \/ _` |/ __| '_ \  | |/ _ \ 
| \__/\ | (_) | |_| | (_| | |_/ / | |  __/ (_| | (__| | | |_| | (_) |
 \____/_|\___/ \__,_|\__,_\____/|_|  \___|\__,_|\___|_| |_(_)_|\___/ 


AWS Script that list and save all object versions from a specific public S3 bucket.


EOF

# Prompt the user to enter the S3 bucket name
read -p "Enter the S3 bucket name: " BUCKET_NAME

# Prompt the user to enter the local directory path
read -p "Enter the local dir path where the data will be saved. e.g /home/user/Desktop/s3bucket/ : " LOCAL

echo "                                                                                          "
echo "                                                                                          "
echo "                                                                                          "

# List all object versions in the S3 bucket                                                                        
object_versions=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --no-sign-request | jq -c '.Versions[]')  
                                                                                                                   
# Loop through each object version and download it                                                                 
while IFS= read -r object_version; do                                                                              
    echo "$object_version"                                                                                         
    key=$(echo "$object_version" | jq -r '.Key')                                                                   
    version_id=$(echo "$object_version" | jq -r '.VersionId')
    if [ -n "$key" ] && [ "$key" != "null" ] && [ "$version_id" != "null" ]; then
        # Create the local directory if it doesn't exist
        LOCAL_DIR="$LOCAL$key"
        echo $LOCAL_DIR
        mkdir -p "$(dirname "$LOCAL_DIR")"

        aws s3api get-object --bucket "$BUCKET_NAME" --no-sign-request --key "$key" --version-id "$version_id" "$LOCAL_DIR"
    fi
done <<< "$object_versions"
