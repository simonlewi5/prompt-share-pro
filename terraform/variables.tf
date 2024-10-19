variable "project_id" {
    description = "The ID of the project in which resources will be managed."
    type        = string
    default     = "proverbial-deck-439120-h2"
}

variable "region" {
    description = "The region in which resources will be managed."
    default     = "us-west1"
}

variable "public_key_paths" {
    description = "List of public ssh key file paths"
    type        = list(string)
}

