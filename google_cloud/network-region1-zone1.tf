##########################################################################
# Create a NAT instance - region 1 zone 1
##########################################################################
resource "google_compute_instance" "nat-region1-zone1" {
    zone            = "${var.gce_region1_zone1}"
    name            = "nat-${var.gce_region1_zone1}"
    tags            = [ "${google_compute_network.production.name}", "nat", "public"]
    machine_type    = "${var.gce_machine_type_micro}"
    disk {
        image       = "${var.gce_image}"
        auto_delete = true
    }

    network_interface {
        network     = "${google_compute_network.production.name}"
        access_config {
            # Ephemeral IP
        }
    }

    metadata_startup_script = "${file("scripts/setup-nat-routing.sh")}"
    
    can_ip_forward = true

}

##########################################################################
# Create a Bastion instance - region 1 zone 1
##########################################################################
resource "google_compute_instance" "bastion-region1-zone1" {
    zone            = "${var.gce_region1_zone1}"
    name            = "bastion-${var.gce_region1_zone1}"
    tags            = [ "${google_compute_network.production.name}", "bastion", "public"]
    machine_type    = "${var.gce_machine_type_micro}"
    disk {
        image       = "${var.gce_image}"
        auto_delete = true
    }

    network_interface {
        network     = "${google_compute_network.production.name}"
        access_config {
            # Ephemeral IP
        }
    }

}

########################################################################
# Route
########################################################################
resource "google_compute_route" "default-nat-region1-zone1" {
    name            = "default-nat-route-${var.gce_region1_zone1}"
    dest_range      = "0.0.0.0/0"
    network         = "${google_compute_network.production.name}"
    next_hop_ip     = "${google_compute_instance.nat-region1-zone1.network_interface.0.address}"
    priority        = 100
    tags            = [ "no-ip-${var.gce_region1_zone1}" ]
}
