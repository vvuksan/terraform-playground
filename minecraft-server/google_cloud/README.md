This is a set of terraform templates to create a Minecraft server. It uses a persistent disk to store state of game play so that you can shut down your compute instance when you are not using it and save money

What it does
============

* It will create a persistent disk called minecraft-permdisk
* Create inbound firewall rules that allow SSH access and access to a range of ports you can use for minecraft starting with the standard 25565
* It will create an compute instance and attach the minecraft-permdisk to it
* Once the instance is launched it will download the minecraft server JAR file and install the necessary pieces to kick off the server. Please look at minecraft.init file for more details. Inside it you will also be able to change minecraft server versions

Requirements
============

* Terraform binary - download it from [https://www.terraform.io/](https://www.terraform.io/)
* Account credentials stored in the account.json file in this directory (you can override that by adjusting variables in provider.tf)
* In main.tf you will need to specify the name of the GCP project you are creating resources in

Optional
========

* These is a dns.tf.disabled file that can also update your DNS settings

How to use
==========

There is a Makefile inside this directory that makes things easier to use

* Create - type make create - this will spin up all the resources.
* Destroy Instance - type make destroy - this will only destroy your compute instance leaving your permanent disk untouched
