terraform {
  required_version = ">= 0.14.0"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    google = {
      source = "hashicorp/google"
      version = ">= 5.4.0"
    }
  }
}