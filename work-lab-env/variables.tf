variable "github_token" {
  description = "GitHub Personal Access Token (PAT)"
  type        = string
}

variable "github_repo" {
  description = "GitHub Repository (format: username/repository)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to push files to"
  default     = "main"
  type        = string
}

variable "github_file_path" {
  description = "Path in the GitHub repository to upload the file"
  default     = "uploaded_file.txt"
  type        = string
}
