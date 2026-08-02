terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "Your GCP Project ID"
}

variable "region" {
  type    = string
  default = "us-central1"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Cloud Storage Bucket for Artifacts
resource "google_storage_bucket" "nexus_bucket" {
  name          = "${var.project_id}-nexus-artifacts"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}

# 2. GKE Control Plane (Brain)
resource "google_container_cluster" "primary" {
  name                     = "nexus-gke-cluster"
  location                 = "${var.region}-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false
}

# 3. Custom Node Pool (1 Node, n1-standard-1, Preemptible)
resource "google_container_node_pool" "primary_nodes" {
  name       = "nexus-node-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}