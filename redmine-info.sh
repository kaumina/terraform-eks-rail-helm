#!/bin/bash
export SERVICE_IP=$(kubectl get svc --namespace default redmine-redmine --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Redmine URL: http://$SERVICE_IP/"
echo Username: user
echo Password: $(kubectl get secret --namespace default redmine-redmine -o jsonpath="{.data.redmine-password}" | base64 --decode)
