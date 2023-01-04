# Repo Structure
## Top-level Folder

| Folder | Description |
| --- | --- |
acm | contains manifests relating to `Applications` deployed by ACM `Subscriptions` and the `Applications` may reference any of the other manifests in the other folders.  It also contains the `root` folder that contains the [root-application] Application that pulls in all Applications from the [applications] folder
applications | contains manifests relating to applications to be deployed to managed clusters.  These folders contain the application artefacts and content and kustomize `base` and `overlays` folders that govern their deployment.  The convention for the kustomize folders is described in [section] below
exclude | contains manifests that are not yet to be deployed and is not referenced by any ACM `Applications`
operators | contains manifests that relate to OpenShift Operators from Red Hat and other third-parties.  The folders all follow the same kustomize convention with a `base` and an `overlays` folder.  The `overlays` folder typically contains sub folders for specific operator versions, with the `Subscription` channel patched in the `kustomization.yml`.  The standard folder structure for the Operators folders is describe in [section] below.
policies | contains ACM policies for all clusters.  It uses the kustomise `base` and `overlays` folder structure, with overlays for each cluster when needed.  Additionally there is a `stores` folder that contains a `PlacementRule` for each store.

## ACM Applications (`manifests/acm`)
Contains two folders, applications and root.  The `root/root-application.yml` should be loaded manually into ACM and it will then take over and load all the applications from the `applications` folder.

### Platform Applications
Application | Channel Support | Description
--- | --- | ---
compliance-operator | 4.7 | Installs the OpenShift Compliance operator
file-integrity-operator | 4.7 | Installs the OpenShift File Integrity operator
nfd-operator | stable | Installs the Node Feature Discovery operator used with the NVIDIA operator
nmstate-operator | stable | Installs the NMState operator
nvidia-operator | stable | Installs the NVIDIA GPU operator
RHACS-operator | rhacs-3.72 | Installs the Red Hat Advanced Cluster Security operator.  This is locked to the rhacs-3.72 channel because of the bug in rhacs-3.73 that causes the Compliance window to crash
virtualization-operator | stable | Installs the OpenShift Virtualization operator <br>
### Workload Applications
Application | Variation | Description
--- | --- | ---
camera-check | none | `ffmpeg` application that runs as a CronJob and takes a JPEG snapshot from a camera each time the job runs.  With some enhancement the overlays could choose which IP camera to connect to but as this changes the data in a ConfigMap it is not strightforward
dcgmproftester | Deployment replicas 0,1,4,8 | Load test tool from NVIDIA that can be used to create load on the GPU
santa-message | Deployment replicas 0,1,2,4 | Simple NGINX Angular app that lets you type text to create a message in the window
stable-diffusion | none | Will hopefully deploy the Stable Diffusion app (https://stablediffusionweb.com/) that will present an application for entering text that will generate an image based on the text and downloaded model data.  This uses the GPUs to generate the image

## Applications (`manifests/applications`)
The application folders in `operators` vary in their structure due to the requirements and components of the application.  Where possible or time permitted, a kustomize pattern is used and the overlays folder represents the Variations identified in the table above.  Each application includes its own README.md file in the root of its folders.

## Operators (`manifests/operators`)
Operator applications will only install the base operator from the Operator Hub.  Any operands that need to be created afterwards are created as policies deployed by ACM Governance.
#### Operator Folder Template
The operator folders in `operators` all follow the same kustomize pattern.  Each has a `base` folder that contains the components to be deployed and there are one or more `overlays` folders that are used to patch the components in the base folder.  Typically the overlays will set the Subscription channel.  The `base` folder typically has three components for most operators <br>
Filename | Component
--- | ---
\<app\>-operator-namespace | The namespace the operator is to be installed into
\<app\>-operator-operatorgroup | The operator group associated with the operator subscription
\<app\>-operator-subscription | The subscription to the channel containing the operator

## Governance Policies (`manifests/policies`)
TODO