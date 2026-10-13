# SERVERS

resource "hcloud_server" "klabs-worker-1" {
  name        = "klabs-worker-1"
  image       = "ubuntu-26"
  server_type = "cx33"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "klabs-worker-2" {
  name        = "klabs-worker-2"
  image       = "ubuntu-2604"
  server_type = "cx33"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "klabs-controlplane" {
  name        = "klabs-controlplane"
  image       = "ubuntu"
  server_type = "cx23"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}