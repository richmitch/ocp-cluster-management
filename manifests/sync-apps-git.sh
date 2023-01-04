#!/bin/bash

# if Git Channel has webhook enabled
# apps.open-cluster-management.io/webhook-enabled: "true"
# we need to sync it manually in the lab

curl -k -X POST \
  -H "Content-Type: application/json" \
  -H "X-Gitlab-Event: Push Hook" \
  https://multicluster-operators-subscription-open-cluster-management.apps.rhocphub.stores.wowcorp.com.au/webhook \
  -d "{\"repository\": {\"url\": \"woolworths-group/stores-openshift-poc\",\"description\": \"woolworths-group/stores-openshift-poc\",\"homepage\": \"https://gitlab.consulting.redhat.com/woolworths-group/stores-openshift-poc\",\"name\": \"stores-openshift-poc\"}}"
