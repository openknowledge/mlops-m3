# mlops-m3
An MLOps Plattform for a local k8s minikube setup to demo a Machine Learning Application and how to keep a model in production.

## Local k8s platform

You can use k3s or minikube if you are on linux or macos if you are familiar with it.
For Windows we recommend to use KinD (Kubernetes in Docker).

## Setting up your local kind cluster for this Workshop

We are using a two staged terraform stack to apply all the infrastructure and services that we need.
First Stage is to create a cluster and some infrastructure parts.
Second Stage will apply platform services that allow observability and CICD.

### Adding routes to /etc/hosts
The Cluster will expose some ingresses.
Add some routes like this to your /etc/hosts so that you don't have to bother with port-forwards.

```
    127.0.0.1       prometheus.localhost
    127.0.0.1       grafana.localhost
    127.0.0.1       gitea.local
    127.0.0.1       tekton.localhost
```

#### Hosts on Windows (including WSL)

Add those routes to `C:/WINDOWS/system32/drivers/etc/hosts` as admin (e.g. by starting PowerShell as Admin and start editor from there). It is safest to reboot Windows after doing so. Routes will automatically be added to WSL `/etc/hosts` as well.

#### If you dont have Admin permissions or dont want to edit your hosts file

All of the services required and listed above are also exposed via NodePorts and extra Portmappings
in the KinD Cluster. So you can also use the following URLs to access the services.

```
    For Prometheus: http://localhost:30090
    For Gitea: http://localhost:30030
    For Grafana http://localhost:30031
    For Tekton Dashboard: http://localhost:30097
```

### Creating a Cluster and its Infrastructure

To create the Kind cluster and some infrastructure parts we are using Terraform.

```
    > cd src/main/terraform/cluster-infrastructure
    cluster-infrastructure > terraform init
    cluster-infrastructure > terraform apply
```

### Installing the platform with terraform

Now we can apply the rest of the stack with terraform on to our created kind cluster.

``` 
    > cd ../platform
    platform > terraform init
    platform > terraform apply
```
