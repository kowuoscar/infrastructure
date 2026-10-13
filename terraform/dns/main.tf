resource "cloudflare_zone" "zone" {
  provider = cloudflare
  account = {
    id = "5f0f6e59b2612cc27a4eb95f863e5977"
  }
  name = "kowulabs.com"
  type = "full"

  lifecycle {
    prevent_destroy = true
  }
}

import {
  provider = cloudflare
  id       = var.zone_id
  to       = cloudflare_zone.zone
}

# A Record

resource "cloudflare_dns_record" "a_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "A"
  content  = "192.64.119.135"
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/335bfda28435d468d97e52e358cd7d9d"
  to       = cloudflare_dns_record.a_record
}

# MX 1

resource "cloudflare_dns_record" "mx_1_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "MX"
  content  = "eforward5.registrar-servers.com"
  priority = 20
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/61269e876b8d707fa1cb8814732549b1"
  to       = cloudflare_dns_record.mx_1_record
}

# MX 2

resource "cloudflare_dns_record" "mx_2_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "MX"
  content  = "eforward4.registrar-servers.com"
  priority = 15
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/47b69a112d34c31eaf87c3e01935c29c"
  to       = cloudflare_dns_record.mx_2_record
}

# MX 3

resource "cloudflare_dns_record" "mx_3_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "MX"
  content  = "eforward3.registrar-servers.com"
  priority = 10
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/a2928bd0ee0aeca92edfaa750a640e27"
  to       = cloudflare_dns_record.mx_3_record
}

# MX 4

resource "cloudflare_dns_record" "mx_4_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "MX"
  content  = "eforward2.registrar-servers.com"
  priority = 10
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/ae398d49ad8dfb96db6f82a96d508508"
  to       = cloudflare_dns_record.mx_4_record
}

# MX 5

resource "cloudflare_dns_record" "mx_5_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "MX"
  content  = "eforward1.registrar-servers.com"
  priority = 10
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/164a85b5960b247a02b9e7941a872cf6"
  to       = cloudflare_dns_record.mx_5_record
}

# TXT

resource "cloudflare_dns_record" "txt_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = var.domain_name
  ttl      = 1
  type     = "TXT"
  content  = "\"v=spf1 include:spf.efwd.registrar-servers.com ~all\""
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/730021eb281bc5b8b3caf18ca2f2aca0"
  to       = cloudflare_dns_record.txt_record
}

# CNAME

resource "cloudflare_dns_record" "cname_record" {
  provider = cloudflare
  zone_id  = cloudflare_zone.zone.id
  name     = "www.${var.domain_name}"
  ttl      = 1
  type     = "CNAME"
  content  = "parkingpage.namecheap.com"
  proxied  = false
}

import {
  provider = cloudflare
  id       = "${var.zone_id}/0d180a9c4d33726b63d8315a1a8e353e"
  to       = cloudflare_dns_record.cname_record
}

