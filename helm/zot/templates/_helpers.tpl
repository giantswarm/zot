{{/*
Expand the name of the chart.
*/}}
{{- define "zot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zot.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zot.labels" -}}
helm.sh/chart: {{ include "zot.chart" . }}
{{ include "zot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "zot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "zot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "resource.vpa.enabled" -}}
{{- if and (or (.Capabilities.APIVersions.Has "autoscaling.k8s.io/v1") (.Values.giantswarm.verticalPodAutoscaler.force)) (.Values.giantswarm.verticalPodAutoscaler.enabled) }}true{{ else }}false{{ end }}
{{- end -}}

{{- define "resource.zot.resources" -}}
requests:
{{ toYaml .Values.resources | indent 2 -}}
{{ if eq (include "resource.vpa.enabled" .) "false" }}
limits:
{{ toYaml .Values.resources.limits | indent 2 -}}
{{- end -}}
{{- end -}}

{{- define "resource.test.resources" -}}
resources:
  requests:
    cpu: 100m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 64Mi
{{- end }}
