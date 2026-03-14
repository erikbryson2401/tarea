{{/*
Expand the name of the chart.
*/}}
{{- define "mi-app-chart.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mi-app-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "mi-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mi-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mi-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
