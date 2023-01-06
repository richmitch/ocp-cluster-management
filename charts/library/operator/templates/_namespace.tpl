{{- define "library.operator.namespace" -}}
{{- $app := .Chart.Name }}
{{- $chart := print .Chart.Name "-" .Chart.Version }}
{{- $release := .Release.Name }}
{{- $heritage := .Release.Service }}
{{- if .Values.operators }}
{{- range $op := .Values.operators }}
{{- if $op.namespace }}
{{- if $op.namespace.create }}
{{- $ns := $op.namespace }}
---
apiVersion: v1
kind: Namespace
metadata:
{{- include "default.labels" $ | indent 2 }}
  name: {{ $ns.name }} 
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
