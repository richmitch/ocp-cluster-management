- [Cluster Context](#cluster-context)
- [Openshift Compliance Operator](#openshift-compliance-operator)
  - [Scan Types](#scan-types)
  - [OpenSCAP Scan Specs](#openscap-scan-specs)
    - [Platform Scan](#platform-scan)
    - [Node Scan](#node-scan)
  - [Deploying The Operator](#deploying-the-operator)
  - [Configure Operator](#configure-operator)
    - [Create ProfileBundle](#create-profilebundle)
    - [Listing Available SCAP profiles](#listing-available-scap-profiles)
    - [Create Scan Settings](#create-scan-settings)
    - [Assign the Scan Policy to Scan Profile](#assign-the-scan-policy-to-scan-profile)
    - [Get Scan Status](#get-scan-status)
  - [Extract Scan Reports](#extract-scan-reports)
  - [Triggering A Manual Scan](#triggering-a-manual-scan)
  - [Profile Tailoring](#profile-tailoring)
  - [Apply Remediations](#apply-remediations)
    - [View Scan Results](#view-scan-results)
  - [Applied Hardening](#applied-hardening)
    - [Control Plane](#control-plane)
    - [Compute](#compute)
  - [Current Scan State](#current-scan-state)
    - [References & Resources](#references--resources)
- [File Integrity Operator](#file-integrity-operator)
  - [Deploying The Operator](#deploying-the-operator-1)
  - [Configure Operator](#configure-operator-1)
  - [Checking the `FileIntegrity` Status](#checking-the-fileintegrity-status)
  - [`FileIntegrityNodeStatus` CR status](#fileintegritynodestatus-cr-status)
    - [References & Resources](#references--resources-1)

# Cluster Context
| Item | Description |
|---|---|
Envrionment | Lab |
Infrastructure | Bare Metal |
Cluster Name | rhocplab |
Applications | <ul><li>TBD</li><li>TBD</li></ul> |

# Openshift Compliance Operator

The compliance-operator is a OpenShift Operator that allows an administrator to run compliance scans and provide remediation for the issues found. The operator leverages OpenSCAP under the hood to perform the scans.

By default, the operator runs in the `openshift-compliance` namespace, so make sure all namespaced resources like the deployment or the custom resources the operator consumes are created there. However, it is possible for the operator to be deployed in other namespaces as well.

The primary interface towards the Compliance Operator is the `ComplianceSuite` object, representing a set of scans. The `ComplianceSuite` can be defined either manually or with the help of `ScanSetting` and `ScanSettingBinding` objects. Note that while it is possible to use the lower-level `ComplianceScan` directly as well, it is not recommended.

## Scan Types

These profiles define different compliance benchmarks and as well as the scans fall into two basic categories - platform and node.

- **Platform scans** are targeting the cluster itself, with the CIS Benchmark being the one of choice, the compliance operator profile `ocp4-latest-cis`
- **Node scans** are targeting the actual cluster nodes (masters and workers). The compliance operator profile `ocp4-latest-cis-node` will be used.

## OpenSCAP Scan Specs

Below are the configured specs

### Platform Scan

- Compliance Operator Scan Profile: ocp4-latest-cis
- Security Benchmark: CIS
- OpenSCAP Profile: xccdf_org.ssgproject.content_profile_cis
- OpenSCAP Content: ssg-ocp4-ds.xml
- Scan Schedule: 0 1 * * *

### Node Scan

- Compliance Operator Scan Profile: ocp4-latest-cis-node
- Security Benchmark: CIS
- OpenSCAP Profile: xccdf_org.ssgproject.content_profile_cis-node
- OpenSCAP Content: ssg-ocp4-ds.xml
- Scan Schedule: 0 1 * * *

## Deploying The Operator

1. In the OpenShift Container Platform web console, navigate to **Operators** -> **OperatorHub**.
2. Search for the Compliance Operator, then click **Install**.
3. Keep the default selection of **Installation mode** and **namespace** to ensure that the Operator will be installed to the `openshift-compliance` namespace.
4. Click **Install**.

## Configure Operator

### Create ProfileBundle

The OpenSCAP scan profiles are provided through container images. By creating the profile bundle we are pointing to the latest updates of available SCAP profiles to ensure the scheduled scan always uses these up-to-date profiles.

```yaml
oc create -f manifests/profilebundle.yml
```

```yaml
---
apiVersion: compliance.openshift.io/v1alpha1
kind: ProfileBundle
metadata:
  name: ocp4-latest
  namespace: openshift-compliance
spec:
  contentFile: ssg-ocp4-ds.xml
  contentImage: quay.io/complianceascode/ocp4:latest
---
apiVersion: compliance.openshift.io/v1alpha1
kind: ProfileBundle
metadata:
  name: rhcos4-latest
  namespace: openshift-compliance
spec:
  contentFile: ssg-rhcos4-ds.xml
  contentImage: quay.io/complianceascode/ocp4:latest
```

```yaml
$ oc get -n openshift-compliance profilebundle
NAME            CONTENTIMAGE                                                                                                                               CONTENTFILE         STATUS
ocp4            registry.redhat.io/compliance/openshift-compliance-content-rhel8@sha256:f4b11b36cf16421bcd2a3d2bd1aba7328389ac34ed9dcca474cc9993b6837957   ssg-ocp4-ds.xml     VALID
ocp4-latest     quay.io/complianceascode/ocp4:latest                                                                                                       ssg-ocp4-ds.xml     VALID
rhcos4          registry.redhat.io/compliance/openshift-compliance-content-rhel8@sha256:f4b11b36cf16421bcd2a3d2bd1aba7328389ac34ed9dcca474cc9993b6837957   ssg-rhcos4-ds.xml   VALID
rhcos4-latest   quay.io/complianceascode/ocp4:latest                                                                                                       ssg-rhcos4-ds.xml   VALID
```

To list the SCAP profiles in a ProfileBundle

```bash
oc get profiles.compliance -l compliance.openshift.io/profile-bundle=ocp4-latest
NAME                        AGE
ocp4-latest-cis             22h
ocp4-latest-cis-node        22h
ocp4-latest-e8              22h
ocp4-latest-high            22h
ocp4-latest-high-node       22h
ocp4-latest-moderate        22h
ocp4-latest-moderate-node   22h
ocp4-latest-nerc-cip        22h
ocp4-latest-nerc-cip-node   22h
ocp4-latest-pci-dss         22h
ocp4-latest-pci-dss-node    22h
```

To List the compliance checks within a specific profile bundle

```bash
oc get rules.compliance -l compliance.openshift.io/profile-bundle=ocp4-latest
```

### Listing Available SCAP profiles

The compliance operator profiles pulled by the profile bundle added follow the naming convention `<profilebundle_name>-<scap_profile_name>`

```bash
$ oc get profiles.compliance
NAME                                    AGE
ocp4-cis                                22h
ocp4-cis-node                           22h
ocp4-e8                                 22h
ocp4-latest-cis                         22h
ocp4-latest-cis-node                    22h
ocp4-latest-e8                          22h
ocp4-latest-high                        22h
ocp4-latest-high-node                   22h
ocp4-latest-moderate                    22h
ocp4-latest-moderate-node               22h
ocp4-latest-nerc-cip                    22h
ocp4-latest-nerc-cip-node               22h
ocp4-latest-pci-dss                     22h
ocp4-latest-pci-dss-node                22h
ocp4-moderate                           22h
ocp4-moderate-node                      22h
ocp4-nerc-cip                           22h
ocp4-nerc-cip-node                      22h
ocp4-pci-dss                            22h
ocp4-pci-dss-node                       22h
rhcos4-e8                               22h
rhcos4-latest-anssi-bp28-enhanced       22h
rhcos4-latest-anssi-bp28-high           22h
rhcos4-latest-anssi-bp28-intermediary   22h
rhcos4-latest-anssi-bp28-minimal        22h
rhcos4-latest-e8                        22h
rhcos4-latest-high                      22h
rhcos4-latest-moderate                  22h
rhcos4-latest-nerc-cip                  22h
rhcos4-latest-ospp                      22h
rhcos4-latest-stig                      22h
rhcos4-moderate                         22h
rhcos4-nerc-cip                         22h
```

### Create Scan Settings

We need to configure how the scans will run, This is achieved by configuring `ScanSetting` customer resource.

The size of the `PersistentVolume` is set on a per `ComplianceScan` resource defined.

```bash
oc create -f manifests/scansetting-scan-only.yml
```

```yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSetting
metadata:
  name: wow-policy-scan-only
  namespace: openshift-compliance
autoUpdateRemediations: false
autoApplyRemediations: false
rawResultStorage:
  pvAccessModes:
    - ReadWriteOnce
  rotation: 3
  size: 10Gi
schedule: 0 1 * * *
roles:
  - worker
  - master
scanTolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
    operator: Exists
```

```bash
$ oc get scansetting
NAME                   AGE
default                22h
default-auto-apply     22h
wow-policy-scan-only   22h
```

### Assign the Scan Policy to Scan Profile

Once we bind the Scan Policy to a compliance profile, the operator creates `ComplianceSuite` resource to manage  `ComplianceScan` objects, and use it to track the progress of our scan.

**Platform Scan**

```yaml
oc create -f manifests/scansettingbinding-platform.yml
```

```yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSettingBinding
metadata:
  name: platform-cis-scan
  namespace: openshift-compliance
profiles:
  - name: ocp4-latest-cis
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
settingsRef:
  name: wow-policy-scan-only
  kind: ScanSetting
  apiGroup: compliance.openshift.io/v1alpha1
```

**Node Scan**

```yaml
oc create -f manifests/scansettingbinding-nodes.yml
```

```yaml
apiVersion: compliance.openshift.io/v1alpha1
kind: ScanSettingBinding
metadata:
  name: node-cis-scan
  namespace: openshift-compliance
profiles:
  - name: ocp4-latest-cis-node
    kind: Profile
    apiGroup: compliance.openshift.io/v1alpha1
settingsRef:
  name: wow-policy-scan-only
  kind: ScanSetting
  apiGroup: compliance.openshift.io/v1alpha1
```

### Get Scan Status

```bash
oc get compliancesuites
NAME                PHASE   RESULT
node-cis-scan       DONE    NON-COMPLIANT
platform-cis-scan   DONE    NON-COMPLIANT
```

```bash
oc get compliancescan
NAME                          PHASE   RESULT
ocp4-latest-cis               DONE    NON-COMPLIANT
ocp4-latest-cis-node-master   DONE    NON-COMPLIANT
ocp4-latest-cis-node-worker   DONE    NON-COMPLIANT
```

## Extract Scan Reports

The scans provide two kinds of raw results: the full report in the ARF format and just the list of scan results in the XCCDF format. The ARF reports are, due to their large size, copied into persistent volumes:

```bash
oc get pv | grep openshift-compliance
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                           STORAGECLASS   REASON   AGE
pvc-33c80371-6e5f-4780-8869-76b6f2ce84e4   10Gi       RWO            Delete           Bound    openshift-compliance/ocp4-latest-cis-node-worker                ocs-storagecluster-ceph-rbd            21h
pvc-890c7d37-8c5c-4afa-b63d-a1ce3afe2b91   10Gi       RWO            Delete           Bound    openshift-compliance/ocp4-latest-cis-node-master                ocs-storagecluster-ceph-rbd            21h
pvc-c145b419-7df6-4582-99b9-4269c867a77f   10Gi       RWO            Delete           Bound    openshift-compliance/ocp4-latest-cis                            ocs-storagecluster-ceph-rbd            22h
```

```bash
oc get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                  AGE
ocp4-latest-cis               Bound    pvc-c145b419-7df6-4582-99b9-4269c867a77f   10Gi       RWO            ocs-storagecluster-ceph-rbd   22h
ocp4-latest-cis-node-master   Bound    pvc-890c7d37-8c5c-4afa-b63d-a1ce3afe2b91   10Gi       RWO            ocs-storagecluster-ceph-rbd   21h
ocp4-latest-cis-node-worker   Bound    pvc-33c80371-6e5f-4780-8869-76b6f2ce84e4   10Gi       RWO            ocs-storagecluster-ceph-rbd   21h
```

Once the scan had finished, there is a `PersistentVolumeClaim` named after the scan:

```bash
oc get pvc ocp4-latest-cis
```

Create a POD to mount the `PVC` as follows:

```yaml
apiVersion: "v1"
kind: Pod
metadata:
  name: report-extractor
spec:
  containers:
    - name: report-extract-pod
      image: registry.access.redhat.com/ubi8/ubi
      command: ["sleep", "3000"]
      volumeMounts:
        - mountPath: "/scan-results"
          name: scan-vol
  volumes:
    - name: scan-vol
      persistentVolumeClaim:
        claimName: ocp-latest-cis   <----- Claim name
```

Once the pod is started, copy the scan results locally

```bash
oc cp report-extractor:/scan-results .
```

The files are bzipped. To get the raw ARF file:

```bash
bunzip2 -c ocp4-latest-cis-api-checks-pod.xml.bzip2 > ocp4-latest-cis-api-checks-pod.xml
```

Use `oscap` tool to generate the full HTML report

```bash
oscap xccdf generate report ocp4-latest-cis-api-checks-pod.xml > ocp4-latest-cis-api-checks-pod.html
```

## Triggering A Manual Scan

```bash
oc get compliancescans
```

```bash
oc annotate compliancescans/<scan_name> compliance.openshift.io/rescan=
```

## Profile Tailoring

TBA If Required

## Apply Remediations

### View Scan Results

```yaml
oc get compliancescan
NAME                          PHASE   RESULT
ocp4-latest-cis               DONE    NON-COMPLIANT
ocp4-latest-cis-node-master   DONE    NON-COMPLIANT
ocp4-latest-cis-node-worker   DONE    NON-COMPLIANT
```

Results can be viewed per each `ComplianceSuite` using labels

```bash
oc get compliancecheckresults -l compliance.openshift.io/suite=node-cis-scan
```

Also, we can use labels to identify failures

```yaml
oc get compliancecheckresults -l compliance.openshift.io/check-status=FAIL
```

List checks that belong to a specific scan

```yaml
oc get compliancecheckresults -l compliance.openshift.io/scan-name=ocp4-latest-cis-nodes-master
```

Each `ComplianceCheckResult` represents a result of one compliance rule check. If the rule can be remediated automatically, a `ComplianceRemediation` object with the same name, owned by the `ComplianceCheckResult` is created.

To apply remediation to a remediation object :

```yaml
oc patch complianceremediations/<scan_name>-sysctl-net-ipv4-conf-all-accept-redirects --patch '{"spec":{"apply":true}}' --type=merge
```

## Applied Hardening 

The findings and remediation items generated by the compliance scan have been remediated and CIS hardening is applied to the cluster using the below manifests creating the required `MachineConfig` And `KubeletConfig` objects.

Once those manifests are applied, rolling restarts will take place to the control plane and compute nodes, so be patient :grin:

### Control Plane

```bash
oc create -f manifests/75-master-kubelet-sysctls.yml -f manifests/master-kubeletconfig.yml
```

### Compute


```bash
oc create -f manifests/75-worker-kubelet-sysctls.yml -f manifests/worker-kubeletconfig.yml
```

## Current Scan State

The current security state of the scan is as below.

```bash
$ oc get compliancescan
NAME                          PHASE   RESULT
ocp4-latest-cis               DONE    NON-COMPLIANT
ocp4-latest-cis-node-master   DONE    COMPLIANT
ocp4-latest-cis-node-worker   DONE    COMPLIANT
```

The table below summarizes the security stance


Scan    | Pass Rate   | Notes
------- | ----------- | -------------
CIS Node Master | 100 % | Compliant
CIS Node Worker | 100 % | Compliant
CIS Platform    | 66 %  | Pending internal integrations setup and log forwarding 

### References & Resources

- **How does Compliance Operator work for OpenShift? (Part 1)** https://www.openshift.com/blog/how-does-compliance-operator-work-for-openshift-part-1

- **How does Compliance Operator work for OpenShift? (Part 2)** https://www.openshift.com/blog/how-does-compliance-operator-work-for-openshift-part-2






# File Integrity Operator

The File Integrity Operator is an OpenShift Container Platform Operator that continually runs file integrity checks on the cluster nodes. It deploys a daemon set that initializes and runs privileged advanced intrusion detection environment (AIDE) containers on each node, providing a status object with a log of files that are modified during the initial run of the daemon set pods.

## Deploying The Operator

1. In the OpenShift Container Platform web console, navigate to **Operators** -> **OperatorHub**.
2. Search for the File Integrity Operator, then click **Install**.
3. Keep the default selection of **Installation mode** and **namespace** to ensure that the Operator will be installed to the `openshift-file-integrity` namespace.
4. Click **Install**.

## Configure Operator

An instance of a FileIntegrity custom resource (CR) represents a set of continuous file integrity scans for one or more nodes.

We will configure `Fileintegrity` resource for both Workers and Masters. 


- Master

  ```yaml
  oc create -f manifests/master_fileintegrity.yml
  ```

  ```yaml
  apiVersion: fileintegrity.openshift.io/v1alpha1
  kind: FileIntegrity
  metadata:
    name: master-fileintegrity
    namespace: openshift-file-integrity
  spec:
    nodeSelector:
        node-role.kubernetes.io/master: ""
    config: {}
  ```

- Worker

  ```yaml
  oc create -f manifests/worker_fileintegrity.yml
  ```

  ```yaml
  apiVersion: fileintegrity.openshift.io/v1alpha1
  kind: FileIntegrity
  metadata:
    name: worker-fileintegrity
    namespace: openshift-file-integrity
  spec:
    nodeSelector:
        node-role.kubernetes.io/worker: ""
    config: {}
  ```

## Checking the `FileIntegrity` Status

- Check resource status

  ```bash
  $ oc get fileintegrities/worker-fileintegrity  -o jsonpath="{ .status.phase }"
  Active


  $ oc get fileintegrities/master-fileintegrity  -o jsonpath="{ .status.phase }"
  Active
  ```

- Verify Pods are running on all nodes

  ```bash
  [root@wk1 co]# oc get pods -o wide
  NAME                                       READY   STATUS    RESTARTS         AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
  aide-master-fileintegrity-82h51            1/1     Running   0                16h     100.100.1.65  sno.rhocplab.stores.wowcorp.com.au   <none>           <none>
  file-integrity-operator-779576c85c-c26cq   1/1     Running   7 (48 mins ago)  16h     100.100.1.64  sno.rhocplab.stores.wowcorp.com.au   <none>           <none>
  ```

After the deployment of the `FileIntegrity` resource, it would take around 30 minutes for the scanners to report the status 


## `FileIntegrityNodeStatus` CR status 

The scan results of the `FileIntegrity` CR are reported in another object called `FileIntegrityNodeStatuses`.

These conditions are reported in the results array of the corresponding FileIntegrityNodeStatus CR status:

- `Succeeded` - The integrity check passed; the files and directories covered by the AIDE check have not been modified since the database was last initialized.

- `Failed` - The integrity check failed; some files or directories covered by the AIDE check have been modified since the database was last initialized.

- `Errored` - The AIDE scanner encountered an internal error.


Check the Status: 

```bash
$ oc get fileintegritynodestatuses
NAME                                                        NODE                                 STATUS
master-fileintegrity-sno.rhocplab.stores.wowcorp.com.au     sno.rhocplab.stores.wowcorp.com.au   Succeeded
```

### References & Resources

- **Understanding the File Integrity Operator** https://docs.openshift.com/container-platform/4.8/security/file_integrity_operator/file-integrity-operator-understanding.html

