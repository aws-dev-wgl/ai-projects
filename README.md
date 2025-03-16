<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI-Powered Text Summarizer</title>
</head>
<body>

<h1>AI-Powered Text Summarizer</h1>

<h2>Overview</h2>
<p>
    This AI-powered text summarizer is a scalable and modular solution designed to automate the extraction of key insights 
    from large datasets of text-based reviews. Built on AWS infrastructure, it leverages AI/ML capabilities through AWS Bedrock 
    while maintaining an efficient and cost-effective deployment. This solution integrates multiple AWS services to process, 
    summarize, and store movie critic reviews, making it applicable across various domains where text summarization is required.
</p>

<h2>Business Impact</h2>
<ul>
    <li><strong>Improved Decision-Making:</strong> Organizations can quickly analyze textual data for trends and insights.</li>
    <li><strong>Operational Efficiency:</strong> Eliminates manual summarization efforts, reducing resource allocation.</li>
    <li><strong>Scalability:</strong> Designed to handle high-volume datasets with serverless AWS infrastructure.</li>
    <li><strong>Versatility:</strong> Can be applied to various industries, including entertainment, finance, healthcare, and e-commerce.</li>
</ul>

<h2>Core Features</h2>
<ul>
    <li><strong>AWS Bedrock Integration:</strong> Utilizes Amazon Titan models to generate AI-powered summaries.</li>
    <li><strong>Serverless Architecture:</strong> Deploys AWS Lambda for event-driven processing.</li>
    <li><strong>Storage and Retrieval:</strong> Uses Amazon S3 for data storage and retrieval.</li>
    <li><strong>API Gateway:</strong> Provides a RESTful interface to trigger and retrieve summarization tasks.</li>
    <li><strong>Security & IAM:</strong> Implements least-privilege access policies to control resource access.</li>
</ul>

<h2>AWS Services Utilized</h2>
<ul>
    <li><strong>AWS Bedrock:</strong> AI model inference for text summarization.</li>
    <li><strong>AWS Lambda:</strong> Serverless function execution.</li>
    <li><strong>Amazon S3:</strong> Storage for input data and summarized outputs.</li>
    <li><strong>Amazon API Gateway:</strong> API layer for triggering summarization requests.</li>
    <li><strong>AWS IAM:</strong> Role-based access control for security enforcement.</li>
</ul>

<h2>Deployment Instructions</h2>

<h3>1. Set Up AWS Environment</h3>
<p>Ensure you have the necessary AWS credentials configured with IAM permissions to deploy infrastructure using Terraform.</p>

<h3>2. Clone Repository</h3>
<pre>
<code>
git clone &lt;repository-url&gt;
cd ai-powered-text-summarizer
</code>
</pre>

<h3>3. Initialize and Deploy Infrastructure</h3>
<pre>
<code>
terraform init
terraform apply --auto-approve
</code>
</pre>
<p>This step provisions all required AWS resources, including Lambda, API Gateway, and S3.</p>

<h3>4. Upload Data to S3</h3>
<pre>
<code>
aws s3 cp cleaned_reviews.csv s3://my-terraform-state-aws-ai-dev-wgl/reviews/cleaned_reviews.csv
</code>
</pre>

<h3>5. Trigger AI Summarization</h3>
<pre>
<code>
curl -X POST "https://&lt;api-gateway-url&gt;/prod/summarize" \
     -H "Content-Type: application/json" \
     -d '{"bucket_name": "my-terraform-state-aws-ai-dev-wgl", "file_key": "reviews/cleaned_reviews.csv"}'
</code>
</pre>

<h3>6. Retrieve Summarized Reviews</h3>
<pre>
<code>
aws s3 cp s3://my-terraform-state-aws-ai-dev-wgl/reviews/summaries/summarized_reviews_cleaned_reviews.json .
</code>
</pre>

<h3>7. Validate AI Summaries</h3>
<pre>
<code>
cat summarized_reviews_cleaned_reviews.json | jq
</code>
</pre>

<h2>Architecture Diagram</h2>
<pre>
[User] → [API Gateway] → [Lambda] → [AWS Bedrock] → [S3]
                           ↓
                        [S3 Output Storage]
</pre>

<h2>Future Enhancements</h2>
<ul>
    <li><strong>DynamoDB Integration:</strong> Store and index summarized reviews for quick retrieval.</li>
    <li><strong>EventBridge Automation:</strong> Trigger summarization upon new file uploads.</li>
    <li><strong>Performance Optimization:</strong> Batch processing to reduce API calls and improve throughput.</li>
    <li><strong>Custom AI Models:</strong> Fine-tune Bedrock models based on domain-specific data.</li>
</ul>

<h2>Conclusion</h2>
<p>
    This project is an example of how AI-powered solutions can be seamlessly integrated into cloud environments to automate 
    and enhance decision-making. The architecture ensures flexibility and extensibility, making it a foundational component 
    for organizations looking to incorporate AI-driven text analytics into their workflow.
</p>

</body>
</html>

