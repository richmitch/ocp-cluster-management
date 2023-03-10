{{- define "library.operator.subscription" -}}
{{- if .Values.operators }}
{{- range $op := .Values.operators }}
{{- $sub := $op.subscription }}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
{{- include "operator.labels" $ | indent 2 }}
  name: {{ $op.name }}
  namespace: {{ $op.namespace.name }}
spec:
  channel: {{ $sub.channel | quote }} 
  installPlanApproval: {{ $sub.approval | default "Automatic" }}
  name: {{ $sub.operatorName }}
  source: {{ $sub.sourceName | default "redhat-operators" }}
  sourceNamespace: {{ $sub.sourceNamespace | default "openshift-marketplace" }}
{{- if $sub.csv }}
  startingCSV: {{ $sub.csv }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
