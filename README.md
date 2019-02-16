# Redmine with MySql deployed in EKS cluster using Terrafom/Helm
## Pre-requisites
Initially you have to setup your local server(deployment box). This can be your desktop or and EC2.

* AWS account with privileges. 
* AWS cli should be installed.(Refer https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Helm and Tiller should be installed. (https://docs.helm.sh/using_helm/#installing-helm)
* Install IAM Authenticator. (https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* Install kubectl.(https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (probably you have to set repo_gpgcheck=1)
* Install Terraform.(https://learn.hashicorp.com/terraform/getting-started/install.html)

## Procedure
Clone this repository. 
Here, I have used local tfstate as the backend due to demonstration.

1. Configure aws cli with your AWS Access Key ID and AWS Secret Access Key. This is to avoid store your credentials in terraform files.``` 
   
        
   ```
        aws configure
     
     ```
2. Clone the reposroty.
    ```
      git clone https://github.com/codefreaker/terraform-eks-rail-helm.git
    ```

3. Move to the directory.

```
cd terraform-eks-rail-helm/
```

4. Run below terraform commands.
``` 
   terraform init
   terraform plan
    ```
