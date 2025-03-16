import json
import boto3
import csv
import io

# Initialize AWS Clients
s3_client = boto3.client("s3")
bedrock_runtime = boto3.client("bedrock-runtime", region_name="us-east-1")

# Lambda Handler
def lambda_handler(event, context):
    bucket_name = "my-terraform-state-aws-ai-dev-wgl"
    file_key = "reviews/movie-critic-reviews.csv"

    # Read CSV from S3
    csv_obj = s3_client.get_object(Bucket=bucket_name, Key=file_key)
    body = csv_obj["Body"].read().decode("utf-8")
    reader = csv.DictReader(io.StringIO(body))

    # Process first review
    first_review = next(reader)["review_content"]

    # AI Text Analysis with AWS Bedrock
    response = bedrock_runtime.invoke_model(
        modelId="amazon.titan-text-lite-v1",
        body=json.dumps({"inputText": first_review})
    )

    # Parse AI Response
    ai_summary = json.loads(response["body"].read().decode())["outputText"]

    return {
        "statusCode": 200,
        "body": json.dumps({
            "original_review": first_review,
            "summary": ai_summary
        })
    }
