#######################################################################
# Allow Google LB to connect to our web instances
#######################################################################
resource "google_compute_firewall" "allow-google-lb" {
    name            = "allow-google-lb"
    network         = "${google_compute_network.production.name}"

    allow {
        protocol    = "tcp"
        ports       = [ "80", "443" ]
    }

    target_tags     = [ "fantomtest", "letsencrypt" ]
    source_ranges   = [ "130.211.0.0/22" ]

}

resource "google_compute_target_pool" "fantomtest_region1_zone1" {
    name                = "fantomtest-region1-zone1"
}

resource "google_compute_target_pool" "fantomtest_region1_zone2" {
    name                = "fantomtest-region1-zone2"
}

############################################################################
# Create a health check
############################################################################
resource "google_compute_http_health_check" "fantomtest" {
    name                = "fantomtest"
    request_path        = "/"
    check_interval_sec  = 15
    timeout_sec         = 1
}


resource "google_compute_backend_service" "fantomtest" {
    name                = "fantomtest"
    description         = "Fantomtest"
    port_name           = "http"
    protocol            = "HTTP"
    timeout_sec         = 10
    region              = "us-central1"

    # Specify all backend applicable
    backend {
        group           = "${google_compute_instance_group_manager.fantomtest_region1_zone1.instance_group}"
    }

    backend {
        group           = "${google_compute_instance_group_manager.fantomtest_region1_zone2.instance_group}"
    }

    health_checks       = ["${google_compute_http_health_check.fantomtest.self_link}"]
}


resource "google_compute_url_map" "fantomtest" {
    name                = "fantomtest-url-map"
    description         = "Fantomtest URL map"
    default_service     = "${google_compute_backend_service.fantomtest.self_link}"
    
    # Add Letsencrypt
    host_rule {
        hosts           = ["*"]
        path_matcher    = "letsencrypt-paths"
    }

    path_matcher {
        default_service = "${google_compute_backend_service.fantomtest.self_link}"
        name            = "letsencrypt-paths"
        path_rule {
            paths       = ["/.well-known/*"]
            service     = "${google_compute_backend_service.lets-encrypt-backend-service.self_link}"
        }
    }    
    
}

resource "google_compute_target_http_proxy" "fantomtest" {
    name                = "fantomtest-http-proxy"
    description         = "Fantomtest HTTP proxy"
    url_map             = "${google_compute_url_map.fantomtest.self_link}"
}

#
resource "google_compute_global_forwarding_rule" "fantomtest-http-forwarding-rule" {
    name                = "fantomtest-http-forward-rule"
    target              = "${google_compute_target_http_proxy.fantomtest.self_link}"
    port_range          = "80"
}

