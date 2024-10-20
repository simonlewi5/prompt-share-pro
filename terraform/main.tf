locals {
  ssh_keys = [for file in var.public_key_paths : format("%s:%s", 
              trimspace(substr(basename(file), 0, length(basename(file)) - length(".pub"))), 
              trimspace(file("${path.module}/${file}"))
             )]
  ssh_keys_metadata = join("\n", local.ssh_keys)
}

resource "google_compute_address" "static" {
  name = "api-server-ip"
  region = var.region
}

resource "google_compute_instance" "api_server" {
    name         = "api-server"
    machine_type = "e2-micro"
    zone         = "${var.region}-a"

    boot_disk {
        initialize_params {
            image = "ubuntu-2404-noble-amd64-v20241004"
        }
    }

    network_interface {
        network = "default"

        access_config {
            // Static ip
            nat_ip = google_compute_address.static.address
        }
    }

    service_account {
        scopes = ["cloud-platform"]
    }

    metadata = {
        ssh-keys = local.ssh_keys_metadata
    }

    tags = ["http-server", "https-server"]
}

resource "google_compute_firewall" "http" {
    name = "http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80", "443"]
    }

    source_ranges = ["0.0.0.0/0"]

    target_tags = ["http-server"]
}

resource "google_compute_firewall" "ssh" {
    name = "ssh"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["api-server"]
}

resource "google_compute_firewall" "icmp" {
    name = "icmp"
    network = "default"

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["api-server"]
}
