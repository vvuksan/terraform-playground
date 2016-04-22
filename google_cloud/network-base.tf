variable "gce_machine_type_micro" {
    description = "The Micro type instances"
    default     = "f1-micro"
}

resource "google_compute_network" "production" {
    name = "${var.gce_network}"
    auto_create_subnetworks = true    
}

resource "google_compute_firewall" "inbound-bastion-ssh" {
  name = "inbound-bastion-ssh"
  network = "${google_compute_network.production.name}"

  source_ranges     = [ "0.0.0.0/0" ]
  target_tags       = [ "bastion" ]

  allow {
    protocol        = "tcp"
    ports           = [ "22" ]
  }
}


resource "google_compute_firewall" "allow-all-internal" {
  name = "allow-all-internal-${google_compute_network.production.name}"
  network = "${google_compute_network.production.name}"

  source_ranges     = [ "10.0.0.0/8" ]
  target_tags       = [ "bastion", "no-ip-${var.gce_region1_zone1}", "no-ip-${var.gce_region1_zone2}", "nat" ]

  allow {
    protocol        = "tcp"
  }

  allow {
    protocol        = "udp"
  }

  allow {
    protocol        = "icmp"
  }

}


