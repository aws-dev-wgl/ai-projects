import boto3
import json

bedrock_client = boto3.client("bedrock-runtime")

def analyze_review(review_text):
    response = bedrock_client.invoke_model(
        modelId="anthropic.claude-v3",
        body=json.dumps({
            "prompt": f"Analyze sentiment and summarize:\n\n{review_text}",
            "maxTokens": 200
        })
    )
    return response["body"].read().decode("utf-8")

