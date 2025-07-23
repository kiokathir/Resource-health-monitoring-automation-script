#!/bin/bash

# =========================
# AWS Resource Health Check Script
# Author : Kathir
# =========================

# Requirements:
# - AWS CLI configured (`aws configure`)
# - `jq` installed (JSON parser) #sudo yum install jq #jq --version
# - install ssmtp


#!/bin/bash

email="kiokathir007@gmail.com"
subject="Aws resource health check alert"
log_file="/tmp/aws_health_check.log"
> "$log_file"

#subject
echo "Subject: $subject" >> "$log_file"
echo "" >> "$log_file"  # blank line after subject is required

#ec2 -check
ec2=$(aws ec2 describe-instance-status --include-all-instances --output json)
ec2_issues=$(echo "$ec2" | jq -r '.InstanceStatuses[] | select(.InstanceState.Name!="running" or .InstanceStatus.Status!="ok" or .SystemStatus.Status != "ok" ) | "\(.InstanceId) \(.InstanceState.Name) \(.InstanceStatus.Status) \(.SystemStatus.Status)"')

if [ -z "$ec2_issues" ]; then
    echo "all instances are healthy" >> "$log_file"
else 
    echo "Ec2: unhealthy instances " >> "$log_file"
    echo "$ec2_issues" >> "$log_file"
fi

#rds -check
rds=$(aws rds describe-db-instances --output json)
rds_issues=$(echo $rds | jq -r '.DBInstances[] | select(.DBInstanceStatus!="available") | "\(.DBInstanceIdentifier) \(.DBInstanceStatus)"')

if [ -z "$rds_issues" ]; then
    echo " RDS : All instances are healthy" >> "$log_file"
else 
    echo " RDS : unhealthy Instances " >> "$log_file"
    echo "$rds_issues" >> "$log_file"
fi

#ebs volume check
ebs=$(aws ec2 describe-volumes --output json)
ebs_issues=$(echo $ebs | jq -r '.Volumes[] | select(.State != "in-use") | "\(.VolumeId) \(.State)"')

if [ -z "$ebs_issues" ]; then
    echo "EBS : All volumes are in use" >> "$log_file"
else
    echo "EBS : Volumes not in use: " >> "$log_file"
    echo  "$ebs_issues" >> "$log_file"
fi

#ssmtp
if grep -q "unhealthy instances" "$log_file" || grep -q "not in use" "$log_file" ;then
    ssmtp "$email" < "$log_file"

fi

#display and delete log file
cat "$log_file"
rm -f "$log_file"
