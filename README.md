# Resource-health-monitoring-automation-script

Purpose:
This script automates an AWS resource health check.
It checks EC2 instances, RDS databases, and EBS volumes, logs the results, and sends an email alert if any resources are unhealthy.

Explanation:
This script automates the health monitoring of AWS resources.
First, it checks EC2 instances to see if they are in the running state and both system and instance statuses are ok.
Next, it verifies RDS databases to ensure they are in the available state.
Then, it inspects EBS volumes to find any that are not in use.
All the results are collected into a log file. If any resources are found to be unhealthy or unused, the script automatically sends an email alert with the details using ssmtp.
At the end, it prints the log to the terminal and removes the log file to avoid storing sensitive information

For output and code refer the attached files

