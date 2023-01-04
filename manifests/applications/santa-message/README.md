# nginx

Podman

```bash
podman build -t nginx .
podman run -d -p 8080:8080 nginx
```

OpenShift

```bash
oc create secret generic git-secret \
     --from-file=ssh-privatekey=/home/mike/.ssh/consulting-gitlab \
     --type=kubernetes.io/ssh-auth

oc secrets link builder git-secret

oc annotate secret git-secret \
    'build.openshift.io/source-secret-match-uri-1=ssh://gitlab.consulting.redhat.com:2222/*'

oc new-app nginx~ssh://git@gitlab.consulting.redhat.com:2222/woolworths-group/stores-openshift-poc.git \
  --name=nginx --strategy=docker --context-dir=manifests/applications/nginx

oc create route edge nginx --service=nginx --port=8080
```
