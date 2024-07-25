gcloud auth list
gcloud config list project

# Task 1. Build infrastructure
touch main.tf

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}
provider "google" {

  project = "qwiklabs-gcp-04-655aadf14360"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

terraform init
terraform apply

# Task 2. Change infrastructure
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

terraform apply

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]
  # ...
}

terraform apply

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

terraform apply

terraform destroy

# Task 3. Create resource dependencies
terraform apply

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

terraform plan

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }

terraform plan -out static_ip

terraform apply "static_ip"

# New resource for the storage bucket our application will use.
resource "google_storage_bucket" "example_bucket" {
  name     = "<UNIQUE-BUCKET-NAME>"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Create a new instance that uses the bucket
resource "google_compute_instance" "another_instance" {
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]

  name         = "terraform-instance-2"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

terraform plan
terraform apply

# Task 4. Provision infrastructure
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  tags         = ["web", "dev"]

  provisioner "local-exec" {
    command = "echo ${google_compute_instance.vm_instance.name}:  ${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} >> ip_address.txt"
  }

  # ...
}

terraform apply
terraform taint google_compute_instance.vm_instance
terraform apply

