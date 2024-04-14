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
Return the target Kubernetes version
*/}}
{{- define "common.capabilities.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
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

{{/*
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return values or placeholders for replace in script
*/}}
{{- define "cloudify-manager-worker.postgresServerPassword" -}}
    {{- if .Values.db.serverExistingPasswordSecret -}}
        {{- printf "#{postgresServerPassword}" -}}
    {{- else -}}
        {{- .Values.db.serverPassword -}}
    {{- end -}}
{{- end -}}
{{- define "cloudify-manager-worker.postgresCloudifyPassword" -}}
    {{- if .Values.db.cloudifyExistingPassword.secret -}}
        {{- printf "#{postgresCloudifyPassword}" -}}
    {{- else -}}
        {{- .Values.db.cloudifyPassword -}}
    {{- end -}}
{{- end -}}
{{- define "cloudify-manager-worker.rabbitmqPassword" -}}
    {{- if .Values.queue.existingPasswordSecret -}}
        {{- printf "#{rabbitmqPassword}" -}}
    {{- else -}}
        {{- .Values.queue.password -}}
    {{- end -}}
{{- end -}}
{{- define "cloudify-manager-worker.CfyAdminPassword" -}}
    {{- if .Values.config.security.existingAdminPassword.secret -}}
        {{- printf "#{CfyAdminPassword}" -}}
    {{- else -}}
        {{- .Values.config.security.adminPassword -}}
    {{- end -}}
{{- end -}}

{{/*
Function to generate Fastly image name
*/}}
{{- define "helper.fastly.image" -}}
{{- printf "%s/%s:%s" .fastly.repo .fastly.image_name .fastly.tag }}
{{- end }}

{{/*
{{ include "helper.fastly.revproxy.port" (dict "fastly" $.Values.nginx.fastly) }}
*/}}

{{/*
Determine Fastly Service Port
*/}}
{{- define "helper.fastly.revproxy.port" -}}
{{- if .fastly.enabled }}
{{- .fastly.nginx.proxy_port }}
{{- else }}
80
{{- end }}
{{- end }}

{{/*
Generate String with Proxy Port
*/}}
{{- define "helper.fastly.revproxy.listener" -}}
{{- $proxyPort := .fastly.nginx.proxy_port }}
{{- print "http:{listener='http://0.0.0.0:" $proxyPort "',upstreams='http://0.0.0.0:80',access-log='/dev/stdout'}" }}
{{- end }}