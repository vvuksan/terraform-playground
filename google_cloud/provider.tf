provider "google" {
  credentials = "${file("account.json")}"
  project = "${var.gce_project}"
  region = "${var.gce_region1}"
}

