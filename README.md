AI-Powered Text Summarizer

Overview

This AI-powered text summarizer is a scalable and modular solution designed to automate the extraction of key insights from large datasets of text-based reviews. Built on AWS infrastructure, it leverages AI/ML capabilities through AWS Bedrock while maintaining an efficient and cost-effective deployment. This solution integrates multiple AWS services to process, summarize, and store movie critic reviews, making it applicable across various domains where text summarization is required.

Business Impact

Organizations working with large volumes of textual data—such as customer feedback, reviews, or support logs—often struggle with extracting meaningful insights efficiently. This AI solution automates the summarization process, reducing manual effort, accelerating decision-making, and ensuring consistency. Key benefits include:

Improved Decision-Making: Organizations can quickly analyze textual data for trends and insights.

Operational Efficiency: Eliminates manual summarization efforts, reducing resource allocation.

Scalability: Designed to handle high-volume datasets with serverless AWS infrastructure.

Versatility: Can be applied to various industries, including entertainment, finance, healthcare, and e-commerce.

Core Features

AWS Bedrock Integration: Utilizes Amazon Titan models to generate AI-powered summaries.

Serverless Architecture: Deploys AWS Lambda for event-driven processing.

Storage and Retrieval: Uses Amazon S3 for data storage and retrieval.

API Gateway: Provides a RESTful interface to trigger and retrieve summarization tasks.

Security & IAM: Implements least-privilege access policies to control resource access.

AWS Services Utilized

AWS Bedrock – AI model inference for text summarization.

AWS Lambda – Serverless function execution.

Amazon S3 – Storage for input data and summarized outputs.

Amazon API Gateway – API layer for triggering summarization requests.

AWS IAM – Role-based access control for security enforcement.

Deployment Instructions

1. Set Up AWS Environment

Ensure you have the necessary AWS credentials configured with IAM permissions to deploy infrastructure using Terraform.

2. Clone Repository

 git clone <repository-url>
 cd ai-powered-text-summarizer

3. Initialize and Deploy Infrastructure

terraform init
terraform apply --auto-approve

This step provisions all required AWS resources, including Lambda, API Gateway, and S3.

4. Upload Data to S3

Prepare and upload a CSV file containing movie reviews.

aws s3 cp cleaned_reviews.csv s3://my-terraform-state-aws-ai-dev-wgl/reviews/cleaned_reviews.csv

5. Trigger AI Summarization

Invoke the API Gateway endpoint to generate AI-powered summaries.

curl -X POST "https://<api-gateway-url>/prod/summarize" \
     -H "Content-Type: application/json" \
     -d '{"bucket_name": "my-terraform-state-aws-ai-dev-wgl", "file_key": "reviews/cleaned_reviews.csv"}'

6. Retrieve Summarized Reviews

Fetch the summarized content stored in S3.

aws s3 cp s3://my-terraform-state-aws-ai-dev-wgl/reviews/summaries/summarized_reviews_cleaned_reviews.json .

7. Validate AI Summaries

Inspect the output JSON file to confirm that reviews have been successfully summarized.

cat summarized_reviews_cleaned_reviews.json | jq

Architecture Diagram

[User] → [API Gateway] → [Lambda] → [AWS Bedrock] → [S3]
                           ↓
                        [S3 Output Storage]

Future Enhancements

DynamoDB Integration: Store and index summarized reviews for quick retrieval.

EventBridge Automation: Trigger summarization upon new file uploads.

Performance Optimization: Batch processing to reduce API calls and improve throughput.

Custom AI Models: Fine-tune Bedrock models based on domain-specific data.

Conclusion

This project is an example of how AI-powered solutions can be seamlessly integrated into cloud environments to automate and enhance decision-making. The architecture ensures flexibility and extensibility, making it a foundational component for organizations looking to incorporate AI-driven text analytics into their workflow.

