import json
import boto3
import csv
import io
import logging
import re
import time  # ✅ Fix for Bedrock rate limits

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3 = boto3.client("s3")
bedrock_runtime = boto3.client("bedrock-runtime", region_name="us-east-1")


def retrieve_summary(bucket_name, file_key):
    """Retrieve saved summaries from S3."""
    try:
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        content = response["Body"].read().decode("utf-8")
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": content
        }
    except Exception as e:
        logger.error(f"Error retrieving summary from S3: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }


def lambda_handler(event, context):
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        http_method = event.get("httpMethod", "")

        # ✅ Fix: Allow both "wrapped body" and direct JSON payloads
        body = event.get("body", "{}")
        if isinstance(body, str):
            try:
                body = json.loads(body)  # Try parsing if it's a string
            except json.JSONDecodeError:
                logger.error("Error parsing request body")
                return {
                    "statusCode": 400,
                    "headers": {"Content-Type": "application/json"},
                    "body": json.dumps({"error": "Invalid request format."})
                }

        if http_method == "POST" and "bucket_name" in body and "file_key" in body:
            return process_and_store_summary(body)

        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": "Invalid request."})
        }

    except Exception as e:
        logger.error(f"Lambda Execution Error: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }

def process_and_store_summary(body):
    """Process multiple reviews and store summary in S3."""
    try:
        bucket_name = body.get("bucket_name", "")
        file_key = body.get("file_key", "")

        logger.info(f"Fetching file from S3: s3://{bucket_name}/{file_key}")
        obj = s3.get_object(Bucket=bucket_name, Key=file_key)
        csv_content = obj['Body'].read().decode('utf-8')

        csv_reader = csv.DictReader(io.StringIO(csv_content))

        summaries = []

        for i, row in enumerate(csv_reader):
            review_text = row.get("review_content", "").strip()
            critic_name = row.get("critic_name", "Unknown Critic")

            if not review_text:
                logger.warning(f"Skipping row due to missing review_content: {row}")
                continue

            # ✅ Fix: Ensure clean input format for AWS Bedrock
            formatted_input = json.dumps({
                "inputText": f"Summarize this movie review in one sentence without introductory phrases: {review_text}"
            })

            try:
                response = bedrock_runtime.invoke_model(
                    modelId="amazon.titan-text-lite-v1",
                    contentType="application/json",  # ✅ Fix: Add contentType
                    accept="application/json",       # ✅ Fix: Add accept header
                    body=formatted_input
                )
                response_body = json.loads(response["body"].read().decode())

                summary_text = response_body["results"][0]["outputText"].strip()
                summaries.append({"critic_name": critic_name, "summary": clean_summary(summary_text)})

            except Exception as e:
                logger.error(f"Error calling Bedrock for review {i}: {str(e)}", exc_info=True)
                continue  # ✅ Skip and continue processing next reviews

            # ✅ Fix: Sleep to avoid hitting AWS Bedrock rate limits
            time.sleep(1)  # Adjust if needed

        # ✅ Fix: Ensure summaries list contains multiple entries
        if not summaries:
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": "No reviews were processed."})
            }

        summary_filename = f"summarized_reviews_{file_key.split('/')[-1].replace('.csv', '.json')}"
        summary_s3_key = f"reviews/summaries/{summary_filename}"

        s3.put_object(
            Bucket=bucket_name,
            Key=summary_s3_key,
            Body=json.dumps({"summaries": summaries}),
            ContentType="application/json"
        )

        logger.info(f"Summaries saved to S3 at: s3://{bucket_name}/{summary_s3_key}")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"summaries": summaries, "summary_s3_key": summary_s3_key})
        }

    except Exception as e:
        logger.error(f"Error processing reviews: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }


def clean_summary(text):
    """Removes unnecessary punctuation, whitespace, and newlines for better readability."""
    text = text.strip()
    text = re.sub(r"^\.\s*", "", text)  # Remove leading period & spaces
    text = re.sub(r"\s*\.\s*", ". ", text)  # Normalize spacing around periods
    text = text.replace("\n", " ")  # Remove unwanted newlines
    return text.strip()
