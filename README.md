# E-Commerce Store: Cloud Native Java Microservices on Amazon EKS with Spring Boot, Kubernetes, Terraform, Auth0 and JHipster

This is an example application accompanying the blog post [Deploy Secure Spring Boot Microservices on Amazon EKS Using Terraform and Kubernetes](https://auth0.com/blog/terraform-eks-java-microservices/) on the [Auth0 developer blog](https://auth0.com/blog/developers/).

**Prerequisites**

- [AWS account](https://portal.aws.amazon.com/billing/signup) with the [IAM permissions to create EKS clusters](https://docs.aws.amazon.com/eks/latest/userguide/security_iam_id-based-policy-examples.html)
- AWS CLI [installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Docker](https://docs.docker.com/get-docker/) installed and configured
- [Terraform](https://www.terraform.io/downloads) installed
- [Java 11+](https://sdkman.io/usage) installed
- [Auth0 CLI](https://auth0.github.io/auth0-cli/) installed
- [Optional] [JHipster](https://www.jhipster.tech/installation/) CLI installed
- [Optional] [KDash](https://github.com/kdash-rs/kdash)

## Create an EKS cluster and Auth0 application using Terraform

To deploy the stack to AWS EKS, we need to create a cluster. So let's begin by creating a cluster using Terraform.

### Create a cluster

Ensure you have configured your AWS CLI and IAM Authenticator to use the correct AWS account. If not, run and following:

```bash
# Visit https://console.aws.amazon.com/iam/home?#/security_credentials for creating access keys
aws configure
```

Update the `terraform/auth0.tf` file with your `your_auth0_domain_uri`.

Now before we can run the scripts we need to create a machine to machine application in Auth0 so that Terraform can communicate with the Auth0 management API. This can be done using the Auth0 CLI. Please note that you also need to have [jq](https://jqlang.github.io/jq/) installed to run the below commands. Run the following commands to create an application after logging into the CLI with the `auth0 login` command:

```bash
# Create a machine to machine application on Auth0
export AUTH0_M2M_APP=$(auth0 apps create \
  --name "Auth0 Terraform Provider" \
  --description "Auth0 Terraform Provider M2M" \
  --type m2m \
  --reveal-secrets \
  --json | jq -r '. | {client_id: .client_id, client_secret: .client_secret}')

# Extract the client ID and client secret from the output.
export AUTH0_CLIENT_ID=$(echo $AUTH0_M2M_APP | jq -r '.client_id')
export AUTH0_CLIENT_SECRET=$(echo $AUTH0_M2M_APP | jq -r '.client_secret')
```

This will create the application and set environment variables for client ID and secret. This application needs to be authorized to use the Auth0 management API. This can be done using the below commands.

```bash
# Get the ID and IDENTIFIER fields of the Auth0 Management API
export AUTH0_MANAGEMENT_API_ID=$(auth0 apis list --json | jq -r 'map(select(.name == "Auth0 Management API"))[0].id')
export AUTH0_MANAGEMENT_API_IDENTIFIER=$(auth0 apis list --json | jq -r 'map(select(.name == "Auth0 Management API"))[0].identifier')
# Get the SCOPES to be authorized
export AUTH0_MANAGEMENT_API_SCOPES=$(auth0 apis scopes list $AUTH0_MANAGEMENT_API_ID --json | jq -r '.[].value' | jq -ncR '[inputs]')

# Authorize the Auth0 Terraform Provider application to use the Auth0 Management API
auth0 api post "client-grants" --data='{"client_id": "'$AUTH0_CLIENT_ID'", "audience": "'$AUTH0_MANAGEMENT_API_IDENTIFIER'", "scope":'$AUTH0_MANAGEMENT_API_SCOPES'}'
```

Initialize, plan and apply the following Terraform configuration:

```bash
cd terraform
# download modules and providers. Initialize state.
terraform init
# see a preview of what will be done
terraform plan
# apply the changes
terraform apply
```

Confirm by typing `yes` when prompted. This will take a while (15-20 minutes), so sit back and have a coffee or contemplate what led you to this point in life 😉.

Once the EKS cluster is ready, you will see the output variables printed on the console.

You should see the cluster details if you run `kdash` or `kubectl get nodes` commands.

## Set up OIDC authentication using Auth0

First get the client ID and secret for the Auth0 application created by Terraform.

```bash
# Client ID
terraform output --json | jq -r '.auth0_webapp_client_id.value'
# Client Secret
terraform output --json | jq -r '.auth0_webapp_client_secret.value'
```

Update `kubernetes/registry-k8s/application-configmap.yml` with the OIDC configuration from above.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-config
  namespace: jhipster
#common configuration shared between all applications
data:
  application.yml: |-
    configserver:
      ...
    jhipster:
      security:
        ...
        oauth2:
          audience:
            - https://<your-auth0-domain>/api/v2/
    spring:
      security:
        oauth2:
          client:
            provider:
              oidc:
                # make sure to include the trailing slash
                issuer-uri: https://<your-auth0-domain>/
            registration:
              oidc:
                client-id: <client-id>
                client-secret: <client-secret>
  # app specific configuration
```

## Deploy the microservice stack to EKS

You need to build Docker images for each app. This is specific to the JHipster application used in this tutorial. Navigate to each app folder (**store**, **invoice**, **product**) and run the following command:

```bash
./gradlew bootJar -Pprod jib -Djib.to.image=<docker-repo-uri-or-name>/<image-name>
```

Image names would be `store`, `invoice`, and `product`.

Once the images are pushed to the Docker registry, we can deploy the stack using the handy script provided by JHipster. Navigate to the `kubernetes` folder created by JHipster and run the following command.

```bash
cd kubernetes
./kubectl-apply.sh -f
```

Once the deployments are done, we must wait for the pods to be in **RUNNING** status.

### Cleanup

Once you are done with the tutorial, you can delete the cluster and all the resources created using Terraform by running the following commands:

```bash
cd terraform
# The commands below might take a while to finish.
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
# If deleting VPC fails, then manually delete the load balancers and security groups
# for the load balancer associated with the VPC from AWS EC2 console and try again.
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
# cleanup anything left over.
terraform destroy -auto-approve
```

## Links

This example uses the following open source projects:

- [JHipster](https://www.jhipster.tech)
- [React](https://reactjs.org/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [Spring Security](https://spring.io/projects/spring-security)
- [Terraform](https://www.terraform.io/)
- [AWS VPC Terraform module](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- [Amazon EKS Blueprints for Terraform](https://github.com/aws-ia/terraform-aws-eks-blueprints)

## Help

Please post any questions as comments on the [blog post](), or visit our [Auth0 Developer Forums](https://community.auth0.com/).

## License

Apache 2.0, see [LICENSE](LICENSE).
