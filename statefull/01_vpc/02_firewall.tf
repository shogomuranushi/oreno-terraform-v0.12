resource "google_project_service" "gce" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_firewall" "ssh" {
  name    = "maintenance-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["123.456.789.012/32", "234.567.890.123/32"]
}
