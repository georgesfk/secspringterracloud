# TODO: Fix gke.tf Firewall Rule Issue

- [x] Edit `terraform/gcp/gke.tf` to fix the `source_ranges` in the `allow_ssh` firewall rule by removing the extra list wrapping around `var.bastion_allowed_ips`.
- [ ] Run `terraform validate` to ensure the configuration is valid.
- [ ] Optionally, run `terraform plan` to review changes.
