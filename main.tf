# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "gcp_key_file" {}

variable "gcp_project" {}

variable "gcp_region" {}

variable "gcp_zone" {}

variable "image" {}

variable "ssh_user" {}

variable "ssh_pub_key_file" {}

# //////////////////////////////
# PROVIDERS
# //////////////////////////////
provider "google" {
  credentials = file(var.gcp_key_file)
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

# //////////////////////////////
# RESOURCES
# //////////////////////////////

#Instance
resource "google_compute_instance" "tf-experiment" {
	name         = "tf-experiment"
  machine_type = "f1-micro"

	boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.tf-experiment.self_link
    #access_config {
    #}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}

#VPC
resource "google_compute_network" "tf-experiment" {
  name                    = "tf-experiment"
  auto_create_subnetworks = "false"
}

#Subnet
resource "google_compute_subnetwork" "tf-experiment" {
  name          = "tf-experiment"
  ip_cidr_range = "192.168.0.0/16"
  network       = google_compute_network.tf-experiment.id
}


#Security Group
resource "google_compute_firewall" "tf-experiment" {
  name    = "tf-experiment"
  network = google_compute_network.tf-experiment.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
}

# //////////////////////////////
# DATA
# //////////////////////////////

# //////////////////////////////
# OUTPUT
# //////////////////////////////

#output "public_ip" {
#  value = google_compute_instance.tf-experiment.network_interface[0].access_config[0].nat_ip
#}
output "local_ip" {
  value = google_compute_instance.tf-experiment.network_interface[0].network_ip
}