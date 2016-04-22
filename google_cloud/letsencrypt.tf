variable "gce_image_le" {
    description         = "The name of the image for Let's Encrypt."
    default             = "google-containers/container-vm-v20160321"
}

# Create an instance template
resource "google_compute_instance_template" "lets-encrypt-instance-template" {
    name                = "lets-encrypt-instance-template"
    machine_type        = "${var.gce_machine_type_fantomtest}"
    can_ip_forward      = false
    tags                = [ "letsencrypt", "no-ip-${var.gce_region1_zone1}" ]

    disk {
        source_image    = "${var.gce_image_le}"
        auto_delete     = true
    }

    network_interface {
        network         = "${google_compute_network.production.name}"
    }

    metadata {
        startup-script  = "${file("scripts/letsencrypt-init")}"
    }

}

resource "google_compute_instance_group_manager" "lets-encrypt-igm" {
    name                = "lets-encrypt-igm"
    instance_template   = "${google_compute_instance_template.lets-encrypt-instance-template.self_link}"
    base_instance_name  = "letsencrypt"
    zone                = "${var.gce_region1_zone1}"

    named_port {
        name            = "http"
        port            = 80
    }

}

resource "google_compute_autoscaler" "lets-encrypt-as" {
    name                = "lets-encrypt-as"
    zone                = "${var.gce_region1_zone1}"
    target              = "${google_compute_instance_group_manager.lets-encrypt-igm.self_link}"
    autoscaling_policy = {
        max_replicas    = 1
        min_replicas    = 1
        cooldown_period = 60
        cpu_utilization = {
            target = 0.5
        }
    }
}

resource "google_compute_backend_service" "lets-encrypt-backend-service" {
    name                = "lets-encrypt-backend-service"
    port_name           = "http"
    protocol            = "HTTP"
    timeout_sec         = 10
    region              = "${var.gce_region1}"

    backend {
        group           = "${google_compute_instance_group_manager.lets-encrypt-igm.instance_group}"
    }

    health_checks       = ["${google_compute_http_health_check.fantomtest.self_link}"]    
    
}