import boto3
import os

# Initialize the RDS client
rds = boto3.client('rds')

# Environment variable for RDS instance identifier
RDS_INSTANCE = os.environ['RDS_INSTANCE']

def lambda_handler(event, context):
    # Extract action from the event payload
    action = event.get('action')
    
    if action == 'start':
        try:
            print(f"Starting RDS instance: {RDS_INSTANCE}")
            rds.start_db_instance(DBInstanceIdentifier=RDS_INSTANCE)
            print(f"RDS instance {RDS_INSTANCE} started successfully.")
        except Exception as e:
            print(f"Error starting RDS instance: {str(e)}")
    elif action == 'stop':
        try:
            print(f"Stopping RDS instance: {RDS_INSTANCE}")
            rds.stop_db_instance(DBInstanceIdentifier=RDS_INSTANCE)
            print(f"RDS instance {RDS_INSTANCE} stopped successfully.")
        except Exception as e:
            print(f"Error stopping RDS instance: {str(e)}")
    else:
        print(f"Invalid action: {action}. Please use 'start' or 'stop'.")
