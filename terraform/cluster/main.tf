# SERVERS
locals {
  nodes = {
    "klabs-cp-1"     = { type = "cx23", ip = "10.0.1.10", role = "control-plane" }
    "klabs-worker-1" = { type = "cx33", ip = "10.0.1.21", role = "worker" }
    "klabs-worker-2" = { type = "cx33", ip = "10.0.1.22", role = "worker" }
  }
}

# SSH key

resource "hcloud_ssh_key" "oscar" {
  name       = "oscar"
  public_key = trimspace(file("${path.module}/keys/oscar.pub"))
}

# Network

resource "hcloud_network" "network" {
  name     = "klabs-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "nodes" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Firewall

resource "hcloud_firewall" "nodes" {
  name = "klabs-nodes"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "${var.source_ip}/32"
    ]
  }
}

resource "hcloud_firewall" "runner" {
  name = "ci-ssh"

  lifecycle {
    ignore_changes = [rule]
  }

  apply_to {
    label_selector = "role in (control-plane,worker)"
  }
}

# Servers

resource "hcloud_server" "node" {
  for_each     = local.nodes
  name         = each.key
  server_type  = each.value.type
  image        = "ubuntu-24.04"
  location     = "fsn1"
  ssh_keys     = [hcloud_ssh_key.oscar.id]
  firewall_ids = [hcloud_firewall.nodes.id]
  labels       = { role = each.value.role }

  network {
    network_id = hcloud_network.network.id
    ip         = each.value.ip
  }

  depends_on = [hcloud_network_subnet.nodes]
}