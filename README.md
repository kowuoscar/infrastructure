# Infrastructure: Kowu Labs

## Domaine

Namecheap: kowulabs.com - 14 €/yr
- Cost: 14 €/yr

## Serveur Kubernetes

Cloud Provider: Hetzner - 30 €/mo
- Control Plane, CX23 - 6.59 €/mo
- Workers (2), CX33 -  10.19 €/mo

## Terraform

Boostrap - directory that contains the object storage bootstrap to store all states.
- Versioning - (Enabled) can be verify by using AWS CLI.
```shell
aws s3api get-bucket-versioning \
    --bucket klabs-state-bucket \
    --endpoint-url https://fsn1.your-objectstorage.com
```