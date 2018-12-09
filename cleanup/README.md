# Terraform code that can be used to delete infrastructure and clean up.

Create a virtualenv

Install requirements

Run python script to find all terraform states and destroy.

The program will fail if terraform commands fail for any error.

The program takes the backup of the state files under the state_backup folder and also delete
state file from the s3 bucket. 

This allows the program to re-run multiple times if there are any failured. 

All states which are successfully destroyed those state files will be backed up in the local state_backup folder 
and remote state will be delete.

If the terraform command fails for a state that perticular file will not be deleted or downloaed. 
So when you re-run the program it will re-try to destroy the infrastructure. 