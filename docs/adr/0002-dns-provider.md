# Choosing the DNS Provider

## Context

The registrar choosen to provide the domain name `kowulabs.com` is Namecheap.
Namecheap is choosen as the registrar as an exit path in case, I need to opt out of Cloudflare since with cloudflare domain hosting, the zone can't be delegated to anyone else. This ADR is covering the question about which provider to choose as a authoritative server that will host the zone and answers requests for `kowulabs.com`.

## Evaluation

Options: **Namecheap, Hetzner DNS and Cloudflare**

The comparison is based on three criteria:
- Is the provider supported by cert-manager?
- Is the provider supported by external-dns?
- Does the provider provides required API and token limited per zone?

- **Namecheap**
    - Cert-manager and external-dns via a _webhook_
    - API is provided under usage conditions
    - The token provided isn't limited per zone but open the whole account.
- **Hetzner DNS**
    - Cert-manager and external-dns via a _webhook_
    - API is provided
    - token is limited per project
- **Cloudflare**
    - Cert-manager and external-dns _natively_
    - API is free
    - Provides token limited per zone

**Chosen Option: Cloudflare** due to native support and API token limited per zone.

## Consequences

- One additional third-party tool to manage with 2FA.
- Cloudflare down
    - Name resolution will stop to work after the TTL period
    - Certificates will be expired after validity period

## Conditions

Conditions to revisit Cloudflare option:
- cert-manager and external-dns cease the native support of Cloudflare.
- Cloudflare revisit it offers and prices

## Out of scope

Cloudfare Proxy
- Grey cloud (Opted), Cloudflare answers requests with my server IP and the trafic is directly sent to the load balancer.
- Orange cloud, Cloudlfare answers with its IP. The trafic is route through its servers, which deciphers the HTTPS and hide my server IP. The constraint is that only HTTPS can be sent to Cloudflare, SSH or WireGuard to `*.kowulabs.com` wont work anymore.

## Next steps

- Move the nameservers to Cloudflare