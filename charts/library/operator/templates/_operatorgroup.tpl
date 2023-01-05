{{- define "library.operator.operatorgroup" -}}
{{- if .Values.operators }}
{{- range $op := .Values.operators }}
{{- if $op.operatorgroup }}
{{- if $op.operatorgroup.create }}
{{- $og := $op.operatorgroup }}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  labels:
    app: "{{ .Chart.Name }}"
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  name: {{ $op.name }} 
  namespace: {{ $op.namespace.name }}
spec:
  {{- if $og.namespaceSelector }}
  selector:
    matchLabels:
      {{ $og.namespaceSelector }}
  {{ else }}
  targetNamespaces:
  - {{ $op.namespace.name }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
