{{- define "default.labels" -}}
{{- $app := .Chart.Name }}
{{- $chart := print .Chart.Name "-" .Chart.Version }}
{{- $release := .Release.Name }}
{{- $heritage := .Release.Service }}
labels:
  app: {{ $app }}
  chart: {{ $chart }}
  release: {{ $release }}
  heritage: {{ $heritage }}
{{- end }}