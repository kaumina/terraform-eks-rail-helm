#!/bin/bash
echo ### Instllaing and configuring Helm and Tiller for the 1st time !! ##
helm init
kubectl create serviceaccount tiller --namespace kube-system
kubectl create -f tiller-clusterrolebinding.yaml
helm init --service-account tiller --upgrade
