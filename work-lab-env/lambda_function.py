import json
import boto3
import base64
import requests
import os

# AWS S3 client
s3 = boto3.client("s3")

# Retrieve environment variables (GitHub credentials & repo details)
GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_REPO = os.environ["GITHUB_REPO"]
GITHUB_BRANCH = os.environ["GITHUB_BRANCH"]
GITHUB_FILE_PATH = os.environ["GITHUB_FILE_PATH"]

def lambda_handler(event, context):
    """
    AWS Lambda function triggered by S3 when a file is uploaded.
    It reads the file from S3 and uploads/updates it in a GitHub repository.
    """
    try:
        # Get S3 bucket and object key from the event
        bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
        object_key = event["Records"][0]["s3"]["object"]["key"]

        # Download file from S3
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        file_content = response["Body"].read().decode("utf-8")  # Decode file content

        # GitHub API URL
        url = f"https://api.github.com/repos/{GITHUB_REPO}/contents/{GITHUB_FILE_PATH}"
        headers = {
            "Authorization": f"token {GITHUB_TOKEN}",
            "Accept": "application/vnd.github.v3+json"
        }

        # Check if the file already exists in GitHub
        existing_file = requests.get(url, headers=headers)
        sha = existing_file.json().get("sha", "")  # Needed for updating files

        # Prepare payload for GitHub API (Base64 encoding required)
        payload = {
            "message": f"Upload {object_key} from S3",
            "content": base64.b64encode(file_content.encode()).decode(),
            "branch": GITHUB_BRANCH
        }
        if sha:
            payload["sha"] = sha  # Include SHA if updating an existing file

        # Send request to GitHub API
        response = requests.put(url, headers=headers, json=payload)

        if response.status_code in [200, 201]:
            return {"statusCode": 200, "body": json.dumps("File uploaded successfully to GitHub")}
        else:
            return {"statusCode": response.status_code, "body": response.text}

    except Exception as e:
        return {"statusCode": 500, "body": str(e)}
