output "bootstrap_file" {
  value = data.external.ignition.result.bootstrap_ignition_file
}

output "master_ignition" {
  value = data.external.ignition.result.master_ignition
}
