locals {
  project_id       = "subtle-creek-386806"
  network          = "default"
  image            = "debian-cloud/debian-11"
  ssh_user         = "ansible"
  private_key_path = "C:/Users/J-PC/.ssh/ansbile_ed25519"
}

provider "google" {
  project = "subtle-creek-386806"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_service_account" "ansible" {
  account_id = "ansible-admin"
}

resource "google_compute_firewall" "web" {
  name    = "web-access"
  network = local.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "ansible-terraform-2"
  machine_type = "e2-medium"



  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = local.network

    access_config {
      // Removed empty block
    }
  }

  tags = ["web"]

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'",
    "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main",
    "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367",
     "sudo apt update",
    "sudo apt install ansible"
     ]


    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }

    
  }

  
}

