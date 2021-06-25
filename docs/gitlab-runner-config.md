# Gitlab Runner pre-reqs

## Add Gitlab Cert
```
-----BEGIN CERTIFICATE-----
MIIDTjCCAjagAwIBAgIUHRpDcfZWS5v4SvbEMrTY9Tw9Sh0wDQYJKoZIhvcNAQEL
BQAwFzEVMBMGA1UEAwwMbWFnZXZlbnQubmV0MB4XDTIxMDYyNDIzMTYwMFoXDTMx
MDYyMjIzMTYwMFowFzEVMBMGA1UEAwwMbWFnZXZlbnQubmV0MIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwoadMoiI+zyw2up+i3QV9TM1MQP62+ZxbLM/
+M8fr/J3lrINqD+NrbSij8nd953WL+cyQYpL1xJjY/XZzyJvO45gjzJtGsAZwUiM
bztZNeiMJBSIXcBbpOD3yeSujdxMrzoqWysBSwsLApqLSJkDkUZXuuD5JLGAjuzp
zg/yUmsasad8m14TL9rB+FDKUJuh58gxEckEPDGgSkcQx6U3je+2UQYFwhJxPT+z
gET0MDYVvD6u28a+wH/7TKI4/NShzUDi+1e3RoRFsH2F12C9bxAQ4aj8Np1ClNqW
lxyXvsNVTYHEe/YOviW94KuZtsGcKU8ljP1fts00wwhK0rrCuQIDAQABo4GRMIGO
MB0GA1UdDgQWBBTvZB/p6RMSTsslrGrlB4jz+BDnbDBSBgNVHSMESzBJgBTvZB/p
6RMSTsslrGrlB4jz+BDnbKEbpBkwFzEVMBMGA1UEAwwMbWFnZXZlbnQubmV0ghQd
GkNx9lZLm/hK9sQytNj1PD1KHTAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjAN
BgkqhkiG9w0BAQsFAAOCAQEAifq9rd8NBhS+hgqAEgHePmNpF06agn4uxqU4b3P7
AWgFu8+K4ZDXwP70IkHWDey/mKr42x7ykzcFqcd08R6qaLMsslIBznXhRaf9efVG
2ktQJNWQNonb3UpdUYltDEzUzKhM1wWZ79uas+fMoYd45TiIaNJ3YaHc9k2Ar7dy
BlxanOgucwPOhFIqN7D8PjTQ6cYK3XFsRCrBQT5N64beu2EpqFCxKvDgo6ipWS0F
GXYQvp4Ti3C6wGRDVz7kQf1eTkbIZ65sYTMYjEfEiPfj1I1SMNnSss4NQCMU//vD
bgpUtQnN+EQ0+U4JW+mRhBUZELB9vNl/v1PhhMhj0PsnyQ==
-----END CERTIFICATE-----
```
* Put that in /usr/local/share/ca-certificates/mitm.magevent.net.crt
* sudo update-ca-certificates

## Download Packer / Terraform

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer terraform
```

## Install GitLab Runner

https://docs.gitlab.com/runner/install/linux-repository.html
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt update
sudo -E apt-get install gitlab-runner
```
