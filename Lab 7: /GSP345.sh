# Task 1. Create the configuration files
touch main.tf variables.tf
mkdir -p modules/instances
cd modules/instances
touch instances.tf outputs.tf variables.tf
mkdir -p modules/storage
cd ../../modules/storage
touch storage.tf outputs.tf variables.tf

variable "region" {
  description = "desc"
  default     = "XXX"
}
variable "zone" {
  description = "desc"
  default     = "XXX"
}
variable "project_id" {
  description = "desc"
  default     = "XXX"
}

provider "google" {
  project     = "my-project-id"
  region      = var.region
}

terraform init

# Task 2. Import infrastructure
terraform import module.foo.aws_instance.bar i-abcd1234

# Task 3. Configure a remote backend

# Task 4. Modify and update infrastructure

# Task 5. Destroy resources

# Task 6. Use a module from the Registry

# Task 7. Configure a firewall
