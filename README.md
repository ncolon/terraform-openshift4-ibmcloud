# OpenShift 4 UPI on IBM Cloud

This [terraform](terraform.io) implementation will deploy OpenShift 4.10 and later cluster into an IBM Cloud gen2 VPC, with subnets for controlplane and worker nodes.  Traffic to the master nodes is handled via a pair of loadbalancers, one for internal traffic and another for external API traffic.  Application loadbalancing is handled by a third loadbalancer that talks to the router pods on the infra nodes.  Worker, Infra and Master nodes are deployed across 3 Availability Zones

![Topology](./media/topology.svg)

## Prerequisites

1. [Configure IBM CIS](#placeholder)

2. [Create an IAM Account](#placeholder)

3. [OpenShift Pull Secret](#placeholder)

## Minimal TFVARS file

```terraform
ibmcloud_region = "us-east"
openshift_cluster_name = "ocp410"

# From Prereq. Step #1
ibmcloud_cis_crn = "crn:v1:bluemix:public:internet-svcs:global:a/xxxxxxxx:xxxxxxxxxx::"

# From Prereq. Step #2
ibmcloud_api_key = "xxxxxxxxxxx

# From Prereq. Step #3
openshift_pull_secret = "~/Downloads/pull-secret.json"
```

## Customizable Variables

| Variable                              | Description                                                    | Default         | Type   |
| ------------------------------------- | -------------------------------------------------------------- | --------------- | ------ |
|ibmcloud_api_key                       | placeholder descritption                                       |                 |        |
|ibmcloud_bootstrap_instance_type       | placeholder descritption                                       |                 |        |
|ibmcloud_cis_crn                       | placeholder descritption                                       |                 |        |
|ibmcloud_region                        | placeholder descritption                                       |                 |        |
|ibmcloud_master_instance_type          | placeholder descritption                                       |                 |        |
|ibmcloud_master_availability_zones     | placeholder descritption                                       |                 |        |
|ibmcloud_worker_availability_zones     | placeholder descritption                                       |                 |        |
|ibmcloud_master_dedicated_hosts        | placeholder descritption                                       |                 |        |
|ibmcloud_worker_dedicated_hosts        | placeholder descritption                                       |                 |        |
|ibmcloud_extra_tags                    | placeholder descritption                                       |                 |        |
|ibmcloud_publish_strategy              | placeholder descritption                                       |                 |        |
|ibmcloud_resource_group_name           | placeholder descritption                                       |                 |        |
|openshift_cluster_name                 | placeholder descritption                                       |                 |        |
|openshift_version                      | placeholder descritption                                       |                 |        |
|openshift_base_domain                  | placeholder descritption                                       |                 |        |
|openshift_pull_secret                  | placeholder descritption                                       |                 |        |
|public_ssh_key                         | placeholder descritption                                       |                 |        |
|airgap_config_path                     | placeholder descritption                                       |                 |        |
|proxy_config_path                      | placeholder descritption                                       |                 |        |
|openshift_cluster_network_cidr         | placeholder descritption                                       |                 |        |
|openshift_service_network_cidr         | placeholder descritption                                       |                 |        |
|openshift_cluster_network_host_prefix  | placeholder descritption                                       |                 |        |
|openshift_machine_cidr                 | placeholder descritption                                       |                 |        |
|openshift_master_count                 | placeholder descritption                                       |                 |        |
|openshift_node_count                   | placeholder descritption                                       |                 |        |
|ibmcloud_worker_instance_type          | placeholder descritption                                       |                 |        |
|openshift_trust_bundle                 | placeholder descritption                                       |                 |        |
|network_resource_group_name            | placeholder descritption                                       |                 |        |
|destroy_bootstrap                      | placeholder descritption                                       |                 |        |
|rhcos_image_url                        | placeholder descritption                                       |                 |        |
|deploy_infra_nodes                     | placeholder descritption                                       |                 |        |
|deploy_storage_nodes                   | placeholder descritption                                       |                 |        |
|infra_vm_type                          | placeholder descritption                                       |                 |        |
|storage_vm_type                        | placeholder descritption                                       |                 |        |


## Deploy with Terraform

1. Clone github repository

    ```bash
    git clone git@github.com:ibm-cloud-architecture/terraform-openshift4-ibmcloud.git
    ```

2. Create your `terraform.tfvars` file

3. Deploy with terraform

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

4. Destroy bootstrap node

    ```bash
    TF_VAR_destroy_bootstrap = true terraform apply
    ```

5. To access your cluster

    ```bash
    $ export KUBECONFIG=$PWD/installer/cluster_name/auth/kubeconfig
    $ oc get nodes
    NAME                                STATUS   ROLES            AGE     VERSION
    ibmcloud-tf-dkj0a-infra-1-zhg9v     Ready    infra,worker     16m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-infra-2-zc4bd     Ready    infra,worker     14m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-infra-3-xqjxn     Ready    infra,worker     14m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-master-0          Ready    master           29m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-master-1          Ready    master           25m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-master-2          Ready    master           27m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-storage-1-wmqgm   Ready    storage,worker   9m16s   v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-storage-2-vp9qp   Ready    storage,worker   9m9s    v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-storage-3-ptkbg   Ready    storage,worker   8m50s   v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-worker-1-qtpmq    Ready    worker           16m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-worker-2-k79xl    Ready    worker           14m     v1.23.3+b63be7f
    ibmcloud-tf-dkj0a-worker-3-gzx7m    Ready    worker           14m     v1.23.3+b63be7f
    ```

## Infra and Worker Node Deployment

Deployment of Openshift Worker, Infra and Storage nodes is handled by the Machine Config cluster operator.

```bash
$ oc get machineset -n openshift-machine-api
NAME                          DESIRED   CURRENT   READY   AVAILABLE   AGE
ibmcloud-tf-dkj0a-infra-1     1         1         1       1           13m
ibmcloud-tf-dkj0a-infra-2     1         1         1       1           13m
ibmcloud-tf-dkj0a-infra-3     1         1         1       1           13m
ibmcloud-tf-dkj0a-storage-1   1         1         1       1           13m
ibmcloud-tf-dkj0a-storage-2   1         1         1       1           13m
ibmcloud-tf-dkj0a-storage-3   1         1         1       1           13m
ibmcloud-tf-dkj0a-worker-1    1         1         1       1           33m
ibmcloud-tf-dkj0a-worker-2    1         1         1       1           33m
ibmcloud-tf-dkj0a-worker-3    1         1         1       1           33m

$ oc get machines -n openshift-machine-api
NAME                                PHASE     TYPE        REGION     ZONE         AGE
ibmcloud-tf-dkj0a-infra-1-zhg9v     Running   bx2-4x16    us-south   us-south-1   14m
ibmcloud-tf-dkj0a-infra-2-zc4bd     Running   bx2-4x16    us-south   us-south-2   14m
ibmcloud-tf-dkj0a-infra-3-xqjxn     Running   bx2-4x16    us-south   us-south-3   14m
ibmcloud-tf-dkj0a-master-0          Running   bx2-4x16    us-south   us-south-1   34m
ibmcloud-tf-dkj0a-master-1          Running   bx2-4x16    us-south   us-south-2   34m
ibmcloud-tf-dkj0a-master-2          Running   bx2-4x16    us-south   us-south-3   34m
ibmcloud-tf-dkj0a-storage-1-wmqgm   Running   bx2-16x64   us-south   us-south-1   14m
ibmcloud-tf-dkj0a-storage-2-vp9qp   Running   bx2-16x64   us-south   us-south-2   14m
ibmcloud-tf-dkj0a-storage-3-ptkbg   Running   bx2-16x64   us-south   us-south-3   14m
ibmcloud-tf-dkj0a-worker-1-qtpmq    Running   bx2-4x16    us-south   us-south-1   22m
ibmcloud-tf-dkj0a-worker-2-k79xl    Running   bx2-4x16    us-south   us-south-2   22m
ibmcloud-tf-dkj0a-worker-3-gzx7m    Running   bx2-4x16    us-south   us-south-3   22m
```
