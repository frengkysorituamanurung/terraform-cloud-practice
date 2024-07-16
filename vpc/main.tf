# google_compute_network
resource "google_compute_network" "network_terragrunt" {
  name                    = "vpc-network-terragrunt"
  auto_create_subnetworks = false
  mtu                     = 1460

}

# google_compute_subnetwork
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "terragrunt-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-southeast2"
  network       = google_compute_network.network_terragrunt.self_link
}

# google_compute_instance
resource "google_compute_instance" "vm_instance" {
  name         = "example-terragrunt-instance"
  machine_type = "f1-micro"
  zone         = "asia-southeast2-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.network-with-private-secondary-ip-ranges.self_link
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["http-server", "https-server", "ssh"]
}



# google_compute_firewall SSH Rules
resource "google_compute_firewall" "terragrunt_firewall" {
  name    = "terragrunt-firewall"
  network = google_compute_network.network_terragrunt.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
  target_tags   = ["ssh"]
}

# google_compute_firewall flask
resource "google_compute_firewall" "flask" {
  name    = "flask-app-terragrunt"
  network = google_compute_network.network_terragrunt.id

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}

// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
  value = join("", ["http://", google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip, ":5000"])
}

# google_compute_router
resource "google_compute_router" "router-terragrunt" {
  name    = "terragrunt-router"
  network = google_compute_network.network_terragrunt.id
  region  = "asia-southeast2"
  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "1.2.3.4"
    }
    advertised_ip_ranges {
      range = "6.7.0.0/16"
    }
  }
}

# google_compute_router_nat
resource "google_compute_router_nat" "nat" {
  name                               = "terragrunt-router-nat"
  router                             = google_compute_router.router-terragrunt.name
  region                             = google_compute_router.router-terragrunt.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
