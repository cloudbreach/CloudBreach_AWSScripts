#!/bin/bash

cat << "EOF"
 _____ _                 _______                     _       _       
/  __ \ |               | | ___ \                   | |     (_)      
| /  \/ | ___  _   _  __| | |_/ /_ __ ___  __ _  ___| |__    _  ___  
| |   | |/ _ \| | | |/ _` | ___ \ '__/ _ \/ _` |/ __| '_ \  | |/ _ \ 
| \__/\ | (_) | |_| | (_| | |_/ / | |  __/ (_| | (__| | | |_| | (_) |
 \____/_|\___/ \__,_|\__,_\____/|_|  \___|\__,_|\___|_| |_(_)_|\___/ 


AWS Script that retrieves and base64 decodes userData from EC2 instances.


EOF

# Get a list of instance IDs using describe-instances
instance_ids=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text)

# Loop through each instance ID
for instance_id in $instance_ids; do
    
    echo "Getting userData for instance: $instance_id"
    
    # Try to retrieve userData for the instance
    user_data=$(aws ec2 describe-instance-attribute --instance-id "$instance_id" --attribute userData --output text 2>/dev/null)
    
    # Check if userData is available
    if [ -n "$user_data" ]; then
    
        # Remove "USERDATA" and leading spaces
        removedUserData=$(echo "$user_data" | sed 's/^USERDATA\s*//')
        user_data=$(echo "$removedUserData" | sed '1d' | sed 's/^[[:space:]]*//')
        echo "userData for instance $instance_id (base64 encoded):"
        echo "$user_data"
        
        # Base64 decode the userData
        decoded_user_data=$(echo "$user_data" | base64 -d)
        echo "Decoded userData for instance $instance_id:"
        echo "                                           "
        echo "                                           "
        echo "$decoded_user_data"
        echo "                                           "
        echo "                                           "
    else
        echo "userData not available for instance $instance_id"
    fi
done
