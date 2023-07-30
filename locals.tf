locals {
  dns_name = var.component == "frontend" && var.env == "prod" ? "www" :
}