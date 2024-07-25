gcloud auth list
gcloud config list project

# Task 1. Working with backends
touch main.tf
gcloud config list --format 'value(core.project)'

provider "google" {
  project     = "# REPLACE WITH YOUR PROJECT ID"
  region      = "europe-west4"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "# REPLACE WITH YOUR PROJECT ID"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}

terraform init
terraform apply

terraform {
  backend "gcs" {
    bucket  = "# REPLACE WITH YOUR BUCKET NAME"
    prefix  = "terraform/state"
  }
}

terraform init -migrate-state
terraform refresh
terraform show

# Task 2. Import Terraform configuration
docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest
docker ps
git clone https://github.com/hashicorp/learn-terraform-import.git
cd learn-terraform-import
terraform init

provider "docker" {
#   host    = "npipe:////.//pipe//docker_engine"
}