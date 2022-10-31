{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudify-manager-worker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudify-manager-worker.fullname" -}}
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
{{- define "cloudify-manager-worker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cloudify-manager-worker.labels" -}}
app.kubernetes.io/name: {{ include "cloudify-manager-worker.name" . }}
helm.sh/chart: {{ include "cloudify-manager-worker.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Define value for manager.public_ip parameter in cloudify main config file
*/}}
{{- define "cloudify-manager-worker.public_ip" -}}
{{- if .Values.config.public_ip -}}
    {{- .Values.config.public_ip -}}
{{- else if .Values.ingress.enabled -}}
    {{- .Values.ingress.host -}}
{{- else -}}
    {{- printf "%s.%s.%s" .Values.service.host .Release.Namespace "svc.cluster.local" -}}
{{- end -}}
{{- end -}}

{{/*
Define value for manager.private_ip parameter in cloudify main config file
*/}}
{{- define "cloudify-manager-worker.private_ip" -}}
{{- if .Values.config.private_ip -}}
    {{- .Values.config.private_ip -}}
{{- else -}}
    {{- printf "%s.%s.%s" .Values.service.host .Release.Namespace "svc.cluster.local" -}}
{{- end -}}
{{- end -}}