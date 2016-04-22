########################################################################
# My Compute instance template
# 
# It uses the local cloud-init.web file as a startup-script
########################################################################
resource "google_compute_instance_template" "fantomtest_region1_zone2" {
    name                = "fantomtest-${var.gce_region1_zone2}"
    machine_type        = "${var.gce_machine_type_fantomtest}"
    can_ip_forward      = false
    tags                = [ "fantomtest", "no-ip-${var.gce_region1_zone2}" ]

    disk {
        source_image    = "${var.gce_image}"
        auto_delete     = true
    }

    network_interface {
        network         = "${google_compute_network.production.name}"
    }

    metadata {
        startup-script  = "${file("scripts/cloud-init.app")}"
    }

}

resource "google_compute_instance_group_manager" "fantomtest_region1_zone2" {
    name                = "fantomtest"
    instance_template   = "${google_compute_instance_template.fantomtest_region1_zone2.self_link}"
    target_pools        = ["${google_compute_target_pool.fantomtest_region1_zone2.self_link}"]
    base_instance_name  = "fantomtest"
    zone                = "${var.gce_region1_zone2}"

    named_port {
        name            = "http"
        port            = 80
    }

}

resource "google_compute_autoscaler" "fantomtest_region1_zone2" {
    name                = "fantomtest"
    zone                = "${var.gce_region1_zone2}"
    target              = "${google_compute_instance_group_manager.fantomtest_region1_zone2.self_link}"
    autoscaling_policy = {
        max_replicas    = 5
        min_replicas    = 1
        cooldown_period = 60
        cpu_utilization = {
            target = 0.5
        }
    }
}
