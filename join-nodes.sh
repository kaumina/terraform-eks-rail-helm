#!/bin/bash
mkdir -p ~/.kube/
terraform output config_map_aws_auth > config_map_aws_auth.yaml
terraform output kubeconfig >~/.kube/config
kubectl apply -f config_map_aws_auth.yaml