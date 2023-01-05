{{- define "library.operator.namespace" -}}
{{- $app := .Chart.Name }}
{{- $chart := cat .Chart.Name "-" .Chart.Version }}
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
  labels:
    app: {{ $app }}
    chart: {{ $chart }}
    release: {{ $release }}
    heritage: {{ $heritage }}
  name: {{ $ns.name }} 
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
