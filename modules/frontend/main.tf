resource "aws_amplify_app" "review_summary_app" {
  name          = "ReviewSummaryApp"
  repository    = "https://github.com/yourusername/review-summary-frontend.git"
  oauth_token  = var.github_token

  build_spec = <<EOT
version: 1
frontend:
  phases:
    build:
      commands:
        - npm install
        - npm run build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
EOT
}
