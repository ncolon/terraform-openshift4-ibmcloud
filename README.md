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
|**ibmcloud_api_key**                   | Your IBM Cloud IAM API Key.  From Prereq. #2 The IAM API key for authenticating with IBM Cloud APIs. | -               | string |
|ibmcloud_bootstrap_instance_type       | Instance type for the bootstrap node.                          | bx2-4x16        | string |
|**ibmcloud_cis_crn**                   | The CRN of CIS instance to use.  From Prereq. #1               | -               | string |
|**ibmcloud_region**                    | The target IBM Cloud region for the cluster.                   | -               | string |
|ibmcloud_master_instance_type          | Instance type for the master node(s).                          | bx2-4x16        | string |
|ibmcloud_master_dedicated_hosts        | The list of dedicated hosts in which to create the control plane nodes. | -               | list(map(string)) |
|ibmcloud_worker_dedicated_hosts        | The list of dedicated hosts in which to create the compute nodes.       | -               | list(map(string)) |
|ibmcloud_extra_tags                    | Extra IBM Cloud tags to be applied to created resources.       | []              | list(string) |
|ibmcloud_publish_strategy              | The cluster publishing strategy, either Internal or External   | External        | string |
|ibmcloud_resource_group_name           | The name of the resource group for the cluster. If this is set, the cluster is installed to that existing resource group
otherwise a new resource group will be created using cluster id.                                         | -               | string |
|**openshift_cluster_name**             | The name of the OpenShift cluster                              | -               | string |
|openshift_version                      | Version of OpenShift to install. Can be stable-4.x or 4.x.y    | stable-4.10     | string |
|**openshift_base_domain**              | Base domain for the OpenShift cluster                          | -               | string |
|**openshift_pull_secret**                  | Path to the pull secret for the OpenShift cluster.  From prereq. #3 |                 | string |
|public_ssh_key                         | Path to the public SSH key for the OpenShift cluster.  Default is to generate a new public/private keypair under `./installer/<cluster_name>/openshift_rsa` | ""              | string |
|airgap_config_path                     | AirGap Configuration for the OpenShift cluster                 | disabled        | map(string) |
|proxy_config_path                      | Proxy Configuration for the OpenShift cluster                  | disabled        | map(string) |
|openshift_cluster_network_cidr         | Cluster Network CIDR                                           | 10.128.0.0/14   | string |
|openshift_service_network_cidr         | Service Network CIDR                                           | 172.30.0.0/16   | string |
|openshift_cluster_network_host_prefix  | OpenShift Cluster Network Host Prefix                          | 23              | number |
|openshift_machine_cidr                 | OpenShift Machine CIDR                                         | ["10.0.0.0/16"] | list(string) |
|openshift_master_count                 | OpenShift Master Node Count. Must be set to 3 at this time.    | 3               | number |
|openshift_node_count                   | OpenShift Worker Node Count                                    | 3               | number |
|ibmcloud_worker_instance_type          | Instance type for the worker nodes.                            | bx2-4x16 | string |
|openshift_trust_bundle                 | Path to file containing PEM-encoded additional Trust Bundle    | ""              | string |
|network_resource_group_name            | preexisting IBM Cloud resrouce group name for network resources (future release feature) |                 | string |
|destroy_bootstrap                      | Destroy the bootstrap node after cluster deployment            | false           | bool |
|rhcos_image_url                        | URL of RHCOS image.  Use only for development purposes.        | ""              | string |
|deploy_infra_nodes                     | Inject Machine Config yamls for Infrastructure Nodes into OpenShift Manifests | false           | bool |
|deploy_storage_nodes                   | Inject Machine Config yamls for Storage Nodes into OpenShift Manifests | false   | bool |
|infra_vm_type                          | Instance type for the infrastructure node(s).                  | bx2-4x16        | string |
|storage_vm_type                        | Instance type for the storage node(s).                         | bx2-16x64       | string |

**BOLD** = required


## Deploy with Terraform

1. Clone github repository

    ```bash
    git clone https://github.com/ibm-cloud-architecture/terraform-openshift4-ibmcloud.git
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
    TF_VAR_destroy_bootstrap=true terraform apply
    ```

5. To access your cluster

    ```bash
    $ export KUBECONFIG=$PWD/installer/cluster_name/auth/kubeconfig
    $ oc get nodes
    NAME                           STATUS   ROLES            AGE     VERSION
    ocp410-rlt8u-infra-1-d2hdf     Ready    worker   5m38s   v1.23.3+b63be7f
    ocp410-rlt8u-infra-2-64khz     Ready    worker   7m32s   v1.23.3+b63be7f
    ocp410-rlt8u-infra-3-dcghh     Ready    worker   6m47s   v1.23.3+b63be7f
    ocp410-rlt8u-master-0          Ready    master   20m     v1.23.3+b63be7f
    ocp410-rlt8u-master-1          Ready    master   17m     v1.23.3+b63be7f
    ocp410-rlt8u-master-2          Ready    master   17m     v1.23.3+b63be7f
    ocp410-rlt8u-storage-1-plz68   Ready    worker   7m46s   v1.23.3+b63be7f
    ocp410-rlt8u-storage-2-cmzbk   Ready    worker   6m24s   v1.23.3+b63be7f
    ocp410-rlt8u-storage-3-jvxgj   Ready    worker   5m38s   v1.23.3+b63be7f
    ocp410-rlt8u-worker-1-x4rcl    Ready    worker   7m36s   v1.23.3+b63be7f
    ocp410-rlt8u-worker-2-tpj7j    Ready    worker   5m35s   v1.23.3+b63be7f
    ocp410-rlt8u-worker-3-crphf    Ready    worker   7m46s   v1.23.3+b63be7f
    ```

## Infra and Worker Node Deployment

Deployment of Openshift Worker, Infra and Storage nodes is handled by the Machine Config cluster operator.

```bash
$ oc get machineset -n openshift-machine-api
NAME                     DESIRED   CURRENT   READY   AVAILABLE   AGE
ocp410-rlt8u-infra-1     1         1         1       1           22m
ocp410-rlt8u-infra-2     1         1         1       1           22m
ocp410-rlt8u-infra-3     1         1         1       1           22m
ocp410-rlt8u-storage-1   1         1         1       1           22m
ocp410-rlt8u-storage-2   1         1         1       1           22m
ocp410-rlt8u-storage-3   1         1         1       1           22m
ocp410-rlt8u-worker-1    1         1         1       1           22m
ocp410-rlt8u-worker-2    1         1         1       1           22m
ocp410-rlt8u-worker-3    1         1         1       1           22m

$ oc get machines -n openshift-machine-api
NAME                           PHASE     TYPE        REGION    ZONE        AGE
ocp410-rlt8u-infra-1-d2hdf     Running   bx2-4x16    us-east   us-east-1   15m
ocp410-rlt8u-infra-2-64khz     Running   bx2-4x16    us-east   us-east-2   15m
ocp410-rlt8u-infra-3-dcghh     Running   bx2-4x16    us-east   us-east-3   15m
ocp410-rlt8u-master-0          Running   bx2-4x16    us-east   us-east-1   21m
ocp410-rlt8u-master-1          Running   bx2-4x16    us-east   us-east-2   21m
ocp410-rlt8u-master-2          Running   bx2-4x16    us-east   us-east-3   21m
ocp410-rlt8u-storage-1-plz68   Running   bx2-16x64   us-east   us-east-1   15m
ocp410-rlt8u-storage-2-cmzbk   Running   bx2-16x64   us-east   us-east-2   15m
ocp410-rlt8u-storage-3-jvxgj   Running   bx2-16x64   us-east   us-east-3   15m
ocp410-rlt8u-worker-1-x4rcl    Running   bx2-4x16    us-east   us-east-1   15m
ocp410-rlt8u-worker-2-tpj7j    Running   bx2-4x16    us-east   us-east-2   15m
ocp410-rlt8u-worker-3-crphf    Running   bx2-4x16    us-east   us-east-3   15m
```
