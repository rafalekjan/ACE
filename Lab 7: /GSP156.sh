# Task 2. Build infrastructure
touch instance.tf

resource "google_compute_instance" "terraform" {
  project      = "qwiklabs-gcp-04-2c61f217abc6"
  name         = "terraform"
  machine_type = "e2-medium"
  zone         = "europe-west1-d"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

terraform init
terraform plan
terraform apply
terraform show
