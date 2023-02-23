# Setting up your local kind cluster for this Workshop


## Creating a Cluster

```
    >cd setup-kind
    > kind create cluster --config=kind-config.yml
    
    # Check that context is set to kind-kind
    > kubectl config current-context
    
    # Switch if necessary
    > kubectl config use-context kind-kind
    
    > kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
! TODO: installation of ingress-nginx should be done with terraform

## Changing the terraform.tfvars

```
    > kubectl config view --minify --flatten
```

Define the variables in a terraform.tfvars file.

- `host` corresponds with `clusters.cluster.server`.
- `client_certificate` corresponds with `users.user.client-certificate-data`.
- `client_key` corresponds with `users.user.client-key-data`.
- `cluster_ca_certificate` corresponds with `clusters.cluster.certificate-authority-data`.

## Adding routes to /etc/hosts

Add some routes like this to your /etc/hosts so that you dont have to bother with port-forwards

```
    127.0.0.1       prometheus.localhost
    127.0.0.1       grafana.localhost
    127.0.0.1       gitea.localhost
    127.0.0.1       evidently.localhost
```

## Installing the platform with terraform

Now we can apply the rest of the stack with terraform on to our created kind cluster.

```
    > cd platform-terraform
    platform-terraform> terraform init
    platform-terraform> terraform apply
```

###

As long as the evidently image is not built automatically by terraform execute this.
- Assuming the image is locally present and called evidently with latest tag
```
    kind load docker-image evidently
```