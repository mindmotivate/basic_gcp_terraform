// Define the Google Cloud Storage bucket
resource "google_storage_bucket" "GCS2" {
  name          = "malgus-bucket-from-terraform3"
  location      = "US-CENTRAL1"
  force_destroy = true

  labels = {
    "env" = "tf_env"
    "dep" = "dev"
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"  # Optional error page
  }

  uniform_bucket_level_access = false
}

// Set the bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.GCS2.name
  predefined_acl = "publicRead"
}

// Upload and set public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.GCS2.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Set public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Upload and set public read access for image files
resource "google_storage_bucket_object" "upload_mp4" {
  for_each     = fileset("${path.module}/", "*.mp4")
  bucket       = google_storage_bucket.GCS2.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "video/mp4"
}

// Set public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_mp4
  bucket         = google_storage_bucket_object.upload_mp4[each.key].bucket
  object         = google_storage_bucket_object.upload_mp4[each.key].name
  predefined_acl = "publicRead"
}

// Output the website URL
output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.GCS2.name}/index.html"
}
