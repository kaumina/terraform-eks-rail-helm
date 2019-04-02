# Deploy Redmine/MariaDB EKS cluster using Terraform and Helm
## Introduction
This demonstration uses Terraform, EKS, Helm and you need to setup below tools and binaries in your running server. Terraform scripts are self documented and used instance type is t2.micro. Therefore, it will take some time to get EKS nodes and containers ready.
## Pre-requisites
Initially you have to setup your local server(deployment box). This can be your desktop or EC2.

* AWS IAM user with least privilege with generated AWS Access Key ID and AWS Secret Access Key. 
* AWS CLI should be installed.(Refer https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Helm and Tiller should be installed. (https://docs.helm.sh/using_helm/#installing-helm)
* Install IAM Authenticator. (https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* Install kubectl.(https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (probably you have to set repo_gpgcheck=1)
* Install Terraform.(https://learn.hashicorp.com/terraform/getting-started/install.html)

## Procedure
Here, I have used local tfstate as the backend due to being a demonstration.

1. Configure AWS CLI with your AWS Access Key ID and AWS Secret Access Key. This is to avoid store your credentials in Terraform files.
   ```
   aws configure     
   ```
2. Clone the repository.
   ```
   git clone https://github.com/codefreaker/terraform-eks-rail-helm.git
   ```
3. Move to the directory.
   ```
   cd terraform-eks-rail-helm
   ```
4. Run below Terraform commands.
   ``` 
   terraform init
   terraform plan 
   ```
5. If plan ran successfully, now you may apply the changes.(remove --auto--approve if you want)
   ```
   terraform apply --auto--approve
   ```
6. After creating the EKS cluter, run below script to join the nodes to EKS master.
   ```
   chmod +x join-nodes.sh;./join-nodes.sh
   ```
7. Now you get the node's status and from kubectl. Wait few minutes, since it takes some time to get ready due to the lower instance type.
   ```
   kubectl get nodes
   [ec2-user@ip-172-31-82-243 terraform-eks-rail-helm]$ kubectl get nodes
   NAME                         STATUS   ROLES    AGE   VERSION
   ip-10-0-0-8.ec2.internal     Ready    <none>   7m    v1.11.5
   ip-10-0-1-189.ec2.internal   Ready    <none>   7m    v1.11.5
   ip-10-0-1-234.ec2.internal   Ready    <none>   7m    v1.11.5
   ```
      
8. Run start and initiate Tiller now.
   ```
   helm init
   ```
   
9. Now, we need to set permission to run tiller in EKS cluster since EKS is RBAC enabled.
   ```
   kubectl create serviceaccount tiller --namespace kube-system
   kubectl create -f tiller-clusterrolebinding.yaml
   helm init --service-account tiller --upgrade
   ```
   OR
   You can execute 
   ```
   chmod +x get-helm-ready.sh;./get-helm-ready.sh
   ````
   
10. It's time to install Redmine using Helm. This will take some time and need to wait few minues since our EKS nodes are t2.micro.
    ```
    helm install --name redmine stable/redmine
    ```
11. Verify the deployment. Ready status will show in ~ 5 mins.
    ```
    [ec2-user@ip-172-31-82-243 terraform-eks-rail-helm]$ helm ls
    NAME    REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
    redmine 1               Sun Feb 17 02:16:49 2019        DEPLOYED        redmine-8.0.3   4.0.1           default
    ```
    ```
    [ec2-user@ip-172-31-82-243 terraform-eks-rail-helm]$ kubectl get pods -o wide
    NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE                         NOMINATED NODE
    redmine-mariadb-0                  1/1     Running   0          10m   10.0.1.237   ip-10-0-1-234.ec2.internal   <none>
    redmine-redmine-65c84c84b7-b42mf   1/1     Running   0          10m   10.0.0.37    ip-10-0-0-8.ec2.internal     <none>
    ```  
12. Run below script to get the Redmine cluster and login info.
    ```
    chmod +x redmine-info.sh;./redmine-info.sh
    ```
13. To uninstall/delete Redmine.
    ```
    helm delete redmine
    ```
    or below to remove the deployment completly. This will delete the Helm Provisioned AWS resources completely.
    
    ```
     helm del --purge redmine
    ```
14. Dispose the EKS cluster with below. Make sure to delete redmine (helm del --purge redmine) fully otherwise Terrafom struggles to destroy the stack due to the dependent AWS resources created by Helm.
    ```
    terraform destroy --auto-approve
    ```

