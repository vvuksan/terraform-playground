variable "gce_project" {
  description = "GCE Project Name to create machines inside of"
  default     = "my_project_name"
}

variable "gce_region" {
  description = "GCE Region to use"
  default     = "us-central1"
}

variable "gce_network" {
  description = "GCE network to use"
  default     = "vladtest-global"
}

variable "gce_image_minecraft" {
  description = "The name of the image to base the launched instances."
  default     = "ubuntu-1604-xenial-v20160420c"
}

variable "gce_region_zone" {
  description = "GCE Region to use"

  # us-central1-[a,b,c,f], us-east1-[a,b,c]
  default = "us-central1-f"
}

variable "gce_machine_type_minecraft" {
  description = "The machine type to use for minecraft"
  default     = "g1-small"
}

resource "google_compute_firewall" "inbound-minecraft" {
  name    = "inbound-minecraft"
  network = "${var.gce_network}"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft"]

  allow {
    protocol = "tcp"
    ports    = ["22", "25565-26000"]
  }
}

# Create a persistent disk to store Minecraft server data
resource "google_compute_disk" "minecraft-permdisk" {
  name = "minecraft-permdisk"
  size = "10"
  zone = "${var.gce_region_zone}"
}

# Create a new minecraft server
resource "google_compute_instance" "minecraft-server" {
  zone         = "${var.gce_region_zone}"
  name         = "minecraft"
  tags         = ["minecraft"]
  machine_type = "${var.gce_machine_type_minecraft}"

  disk {
    image       = "${var.gce_image_minecraft}"
    auto_delete = true
  }

  # Attach the permanent disk defined above
  disk {
    disk        = "${google_compute_disk.minecraft-permdisk.name}"
    device_name = "data-permdisk"
    auto_delete = false
  }

  network_interface {
    network       = "${var.gce_network}"
    access_config = {
    }
  }

  metadata_startup_script = "${file("minecraft.init")}"
}
