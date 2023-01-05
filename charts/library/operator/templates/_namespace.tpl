{{- define "library.operator.namespace" -}}
{{- if .Values.operators }}
{{- range $op := .Values.operators }}
{{- if $op.namespace }}
{{- if $op.namespace.create }}
{{- $ns := $op.namespace }}
---
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app: "{{ .Chart.Name }}"
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  name: {{ $ns.name }} 
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
