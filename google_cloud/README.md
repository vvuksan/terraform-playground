Google Cloud Terraform Scripts
==============================

This is intended as a POC of deploying an application in two different availability zones
inside the Google Cloud. Due to the fact that terraform doesn't allow nested variables
and resource names cannot contain variables we'll use static naming where we'll refer
to zones and regions as region1 and region1_zone1 and slot the actual zone name in 
variables.tf file e.g. gce_region1_zone1 is us-central1-f whereas gce_region1_zone2 is
us-central1-a.

It will do following

* Create a network called production (defined as gce_network variable in variables.tf)
* Create two separate bastion and NAT gateways in two separate availability 
  These can be changed by changing gce_region1_zone1 and gce_region1_zone2 variables in variables.tf
* Firewall rules we'll be added that enable access to SSH for both bastions from anywhere
* Firewall rules that allow internal traffic as well as traffic from the load balancers to the App
* it will create two different autoscalers in the two above defined zones and use a startup
  script cloud-init.app to bootstrap them. Those two apps will have no public ephemeral
  IPs but will use the NAT gateway in their appropriate availability zones
* Load balancer and URL map will be created that balances traffic across both autoscalers
* Another autoscaler will be created to handle Let's Encrypt [http://blog.vuksan.com/2016/04/18/google-compute-load-balancer-lets-encrypt-integration/](integration)

App that is being deployed is Fantomtest from https://github.com/vvuksan/fantomtest. Once it's all configured
you should be able to access the app by using

http://<lb_external_ip>/fantomtest/

To launch it you will need to define following variables

* gce_project needs to be set to name of your project in GCP

There are two ways of doing it.

* Rename env.sh.sample to env.sh and configure the variables in there. Then source the file with

```source env.sh```

* You can also add them directly into the variables.tf file

Once you are done configuring you should type

```terraform plan```

to see the plan of execution. It should not error out. If that is looking good type

```terraform apply```

to execute it. Once it's all done you should have an instance running in the cloud. To find out 
what IP address it got assigned type

```terraform show | grep ipv4```

To destroy it all

```terraform destroy```


