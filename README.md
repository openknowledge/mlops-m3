# mlops-m3
An MLOps Plattform for a local k8s minikube setup to demo a Machine Learning Application and how to keep a model in production.

## Local k8s platform

You can use k3s or minikube if you are on linux or macos if you are familiar with it.
For Windows we recommend to use KinD (Kubernetes in Docker).

## Setting up your local kind cluster for this Workshop

We are using a two staged terraform stack to apply all the infrastructure and services that we need.
But, first of all we need a cluster.
! TODO: This should be done by terraform as well!

### Creating a Cluster

```
    > kind create cluster --config=setup-kind/kind-config.yml
    
    # Check that context is set to kind-kind (Look out if thats also the context that your kind cluster is using!
    > kubectl config current-context
    
    # Switch if necessary
    > kubectl config use-context kind-kind
    
    > kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
! TODO: installation of ingress-nginx should be done with terraform

### Changing the terraform.tfvars

```
    > kubectl config view --minify --flatten
```

Define the variables in a terraform.tfvars file.
An example is already commited in the repository under the resources folder, which you are welcome
to change and use if you want.

- `host` corresponds with `clusters.cluster.server`.
- `client_certificate` corresponds with `users.user.client-certificate-data`.
- `client_key` corresponds with `users.user.client-key-data`.
- `cluster_ca_certificate` corresponds with `clusters.cluster.certificate-authority-data`.

### Adding routes to /etc/hosts

Add some routes like this to your /etc/hosts so that you don't have to bother with port-forwards.

```
    127.0.0.1       prometheus.localhost
    127.0.0.1       grafana.localhost
    127.0.0.1       gitea.local
    127.0.0.1       evidently.localhost
```

### Installing the platform with terraform

Now we can apply the rest of the stack with terraform on to our created kind cluster.

HINT: you can omit the -var-file option, if you create your own terraform.tfvars in the same directory
as the main.tf that you are applying or if you want to get the input prompts by terraform during the
apply command.

```
    > cd src/main/terraform/cluster-infrastructure
    cluster-infrastructure > terraform init
    cluster-infrastructure > terraform apply -var-file=../../resources/terraform.tfvars
    
    > cd ../platform
    platform > terraform init
    platform > terraform apply -var-file=../../resources/terraform.tfvars
```

###

As long as the evidently image is not built automatically by terraform execute this.
- Assuming the image is locally present and called evidently with latest tag
```
    kind load docker-image evidently
```