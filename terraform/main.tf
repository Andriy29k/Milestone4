terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  credentials = var.google_credentials_file
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Network module (VPC, subnets, firewalls)
module "network" {
  source              = "./modules/network"
  vpc_name            = var.network_name
  project_id          = var.project_id
  zone                = var.zone
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "bastion" {
  source              = "./modules/bastion"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone
  network_name        = module.network.network_name
  public_subnet_name  = module.network.public_subnet_name
  private_subnet_name = module.network.private_subnet_name
  machine_type        = var.machine_type
  image               = var.image
  size                = var.size
  ssh_path_to_bastion = var.ssh_path_to_bastion
  ssh_user            = var.ssh_user
}

# Compute instances: frontend, backend, monitopring
module "compute" {
  source                = "./modules/compute"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  network_name          = module.network.network_name
  public_subnet_name    = module.network.public_subnet_name
  private_subnet_name   = module.network.private_subnet_name
  machine_type          = var.machine_type
  image                 = var.image
  size                  = var.size
  ssh_path_over_bastion = var.ssh_path_over_bastion
  ssh_user              = var.ssh_user
}

module "control_plane" {
  source                = "./modules/control_plane"
  project_id            = var.project_id
  region                = var.region
  image                 = var.image
  machine_type          = var.machine_type
  zone                  = var.zone
  size                  = var.size
  network_name          = module.network.network_name
  public_subnet_name    = module.network.public_subnet_name
  ssh_path_over_bastion = var.ssh_path_over_bastion
  ssh_user              = var.ssh_user
}

# Database instance
module "database" {
  source                = "./modules/database"
  zone                  = var.zone
  db_machine_type       = var.db_machine_type
  image                 = var.image
  size                  = var.size
  ssh_path_over_bastion = var.ssh_path_over_bastion
  ssh_user              = var.ssh_user
  public_subnet_name    = module.network.public_subnet_name
  private_subnet_name   = module.network.private_subnet_name
}

module "ssh_config" {
  source            = "./modules/ssh_config"
  bastion_public_ip = module.bastion.bastion_external_ip
  machines = concat(
    keys(module.compute.all_internal_ips),
    ["control_plane", "database"]
  )

  machine_private_ips = merge(
    module.compute.all_internal_ips,
    {
      control_plane = module.control_plane.control_plane_internal_ip,
      database      = module.database.database_internal_ip,
    }
  )

  control_plane_ip = module.control_plane.control_plane_internal_ip
  database_ip      = module.database.database_internal_ip

  ssh_user                      = var.ssh_user
  ssh_path_to_bastion_private   = var.ssh_path_to_bastion_private
  ssh_path_over_bastion_private = var.ssh_path_over_bastion_private

  depends_on = [module.bastion, module.compute, module.control_plane, module.database]
}
