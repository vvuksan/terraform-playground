# Name of the Google Cloud project to use
variable "gce_project" { }

variable "gce_network" {
  description   = "GCE network to use"
  default       = "production"
}

############################################################################
# Specify the name of a region and two zones you want your app deployed in
############################################################################
variable "gce_region1" {
  description   = "GCE Region 1"
  default       = "us-central1"
}

# Specify the two zones in region 1
variable "gce_region1_zone1" {
    default     = "us-central1-f"
}

variable "gce_region1_zone2" {
    default     = "us-central1-a"
}

variable "gce_image" {
  description   = "OS image to boot VMs using"
  default       = "ubuntu-1604-xenial-v20160420c"
}
