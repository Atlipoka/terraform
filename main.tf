
locals {
  instance_zone = {
    env = "ru-central1-a"
  }
  instance_count = {
    stage = 1
    prod  = 1
  }
  each_count = {
    prod  = { prod1 = "prod1", prod2 = "prod2" }
    stage = { stage = "stage" }
  }
  name = {
    stage = "stage"
    prod  = "prod"
  }
}

#Вариант с count
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "vm-count" {
  count       = local.instance_count[terraform.workspace]
  name        = local.name[terraform.workspace]
  zone        = local.instance_zone.env
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_terraform.id
    nat       = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Вариант с for_each
resource "yandex_compute_instance" "vm_each" {
  for_each    = local.each_count[terraform.workspace]
  name        = each.value
  zone        = local.instance_zone.env
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_terraform.id
    nat       = true
  }
}

resource "yandex_vpc_network" "network_terraform" {
  name = "net_terraform"
}

resource "yandex_vpc_subnet" "subnet_terraform" {
  name           = "sub_terraform"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_terraform.id
  v4_cidr_blocks = ["192.168.15.0/24"]
}
