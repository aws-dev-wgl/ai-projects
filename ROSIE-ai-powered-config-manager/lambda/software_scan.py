import boto3
import json
import os

# AWS Clients
ssm_client = boto3.client("ssm")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def lambda_handler(event, context):
    try:
        # Get a list of all managed EC2 instances
        response = ssm_client.describe_instance_information()
        instances = response.get("InstanceInformation", [])

        results = []

        for instance in instances:
            instance_id = instance["InstanceId"]

            # Retrieve installed software using SSM command
            command_response = ssm_client.send_command(
                InstanceIds=[instance_id],
                DocumentName="AWS-RunShellScript",
                Parameters={"commands": ["dpkg --get-selections"]}  # Change for Windows
            )

            command_id = command_response["Command"]["CommandId"]

            # Wait for command result
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id
            )

            # Parse software list
            software_list = output["StandardOutputContent"].strip().split("\n")

            # Store software data in DynamoDB
            for software in software_list:
                software_name = software.split("\t")[0]  # Adjust parsing as needed

                table.put_item(
                    Item={
                        "instance_id": instance_id,
                        "software_name": software_name
                    }
                )

                results.append({"instance_id": instance_id, "software_name": software_name})

        return {
            "statusCode": 200,
            "body": json.dumps(results)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
