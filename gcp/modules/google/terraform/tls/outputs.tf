output "tls_secret_key" {
  value       = jsonencode(local.tls_secret)
  // value          = module.tls_secret[*].secret
  // value       = google_secret_manager_secret.secret.secret_id
  description = <<EOD
The project-local Secret Manager key containing the TLS certificate, key, and CA.
EOD
}
