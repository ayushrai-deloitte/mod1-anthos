provider "google" {
  #credentials = file("/home/ubuntu/.config/gcloud/application_default_credentials.json")
  type = "service_account"
  project_id = "hu-devops-gcp"
  private_key_id = "e95225a51bc3f37b63c94b30d0fabc1e0e15e8d4"
  private_key = "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCkFGflYTba9BQu\ntEE6TgJ4d+71wKFxz2K1ZAOaGHipO8Bv5PcfDwivndj5feYX3OA84El3BZSpXJTw\nWYi4HLylbTpyEJ8yQQR9zAVwi+J9pwKK0qFx+w4m4OCt1X0BOXrWgfk59O4D5H8R\nINB8HEWrBB+ogbKC+NQyGkK6i9rALeQslSM3XjOfr1h8hkbyUcWHwPcsFxWiqaEX\nXrCL9ZXqsUDDGs1GGT9RvF31pOrDkYzhm2LWatk/JbC+e9og0LBhHTQHTGYMc5KR\nKAGgaPrnHtXMl/6wvni69PFzxJw9Ke6+ASEubR3wmfi8Jmr2qeor9UhFMHU1GOj/\nIKHsYsG3AgMBAAECggEABQllDiKM636VlxXVG2yUFBprMHkMJDEyo8y+221DnRRv\nLUJGSkCvDr3RqhnkGnRr7IsAipYFPIfz2lhClrWVhMB7HWDLLXHXbTh6PVYaNZnT\nRh6o6doIbHqiYWXSDxd2xzhSo5SUKGNuirgGpuCqXVn+FmR7fulGs5bk+p+4wDj3\njbCW1CH1wlSspKYwALquaiHqj06CzyaeKFBwg3+flZ3m0yF02HY889Mmp6TxaCJz\nrSe7Q+i1MKZiZcOVbS3kdqG0UdRDyOUMP+ZV4H3ZFff5UZX6PFDjZ81Ye+hEIPUv\n/p1/xJC5giXnOZumW4dA6nDfYC25VbtpQPEiFhs2FQKBgQDVLOmVFGVDB9aFe8bj\neCrQD5nK7sNsfPBWtlRjFW1ExCYJ518fGkL4ZMP6fVrzmfZRMH/99472sxat4dXb\nJkrvS6FPNyURs3gvTcvu0TlJ2G+aE7WUKTKsEuCi2f3ljP2Ers1wTw9o6h3tziiw\nE/YcFrVGKLDTTZ49+Jy463y4kwKBgQDFCp79KjS7Ziar4xkv/k4BuM41SMH3+dcA\nrwmG7MUMOM1JUGu24rhxep8s28L2V603dSut+bvM/wD4JTsRY1qdZkrrw+a8JKbv\nEoXCfkoZYmZZfc1YRiPdxei1T6z2PAVJTOCQYrLo1B3yr9UBaCL+8JLM0x3z3Slm\nEMCQI428zQKBgQCa3QfLz4dIzNbhHex8r32arNqy/AVoONN4ivh/Cr/Ypw5jP3xw\n4eko/jsJLCv4sC6rCKrS2xc2zR96rodnr0fc03qaS5tYYqK66q9uDPyrUtqwegT9\nX3h6XTRn2imCq4w46axBHI47T2jyq0QPtlCiUzTZhRIAT3DX4FYqWJjAlQKBgQCg\n2fbIPLgnc1CGaTGamEMd7LuJjAesY2w8xqdEWezR+Vy8SMZl2dcv7CYc/Jm/d/uT\nljc+IuxIgLNN3zbFDxJeA6+Nn7KwTEtqRviiuW3MIyPiUmxbb4a/+FvsB0rvCDhY\nikWYGLpsjxyTjS6Zo2VOMR3lz0JYXWb6RxqrkBqY0QKBgQDIhdR27AjBEKn3dXx7\nWCO889ksUnOJzzL4KBZvee4yLJDIuqFWQd5v+rGbUnGvxHP6ih7dRGIDsCc1Q52c\n+hHkRQeqMN08dpz1MDb2tsTJQj0UHmAYn90X5GfoY858SQBYsSITVrlHXvtNt/41\nyDDiWfITgEvmoOCmQQADHnedQA==\n-----END PRIVATE KEY-----\n"
  client_email = "terraform-anthos-jenkins-exp@hu-devops-gcp.iam.gserviceaccount.com"
  client_id = "112414616079407060905"
  auth_uri = "https://accounts.google.com/o/oauth2/auth"
  token_uri = "https://oauth2.googleapis.com/token"
  auth_provider_x509_cert_url = "https://www.googleapis.com/oauth2/v1/certs"
  client_x509_cert_url = "https://www.googleapis.com/robot/v1/metadata/x509/terraform-anthos-jenkins-exp%40hu-devops-gcp.iam.gserviceaccount.com"
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id        = var.project_id
  name              = "${var.cluster_name}-${var.env_name}"
  regional          = false
  region            = var.region
  zones             = ["us-central1-c"]
  network           = module.gcp-network.network_name
  subnetwork        = module.gcp-network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name
  node_pools = [
    {
      name           = "node-pool"
      machine_type   = "n2-standard-2"
      node_locations = "us-central1-c"
      min_count      = var.minnode
      max_count      = var.maxnode
      disk_size_gb   = var.disksize
      preemptible    = false
      auto_repair    = false
      auto_upgrade   = true
    },
  ]
}
output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}
