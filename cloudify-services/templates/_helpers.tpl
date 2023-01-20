{{/*
Expand the name of the chart.
*/}}
{{- define "cloudify-services.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudify-services.fullname" -}}
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
{{- define "cloudify-services.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cloudify-services.labels" -}}
helm.sh/chart: {{ include "cloudify-services.chart" . }}
{{ include "cloudify-services.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: "Helm"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cloudify-services.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cloudify-services.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloudify-services.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cloudify-services.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Generate certificates for cloudify-services
*/}}
{{- define "cloudify-services.gen-certs" -}}
{{- $ca := genCA "cloudify-services-ca" 3650 -}}
{{- $externalCert := genSignedCert "nginx" nil nil 3650 $ca -}}
{{- $internalCert := genSignedCert "nginx" nil nil 3650 $ca -}}
{{- $rabbitCert := genSignedCert "rabbitmq" nil nil 3650 $ca -}}
cloudify_internal_ca_key.pem: {{ $ca.Key | b64enc }}
cloudify_internal_ca_cert.pem: {{ $ca.Cert | b64enc }}
cloudify_external_key.pem: {{ $externalCert.Key | b64enc }}
cloudify_external_cert.pem: {{ $externalCert.Cert | b64enc }}
cloudify_internal_key.pem: {{ $internalCert.Key | b64enc }}
cloudify_internal_cert.pem: {{ $internalCert.Cert | b64enc }}
rabbitmq-key.pem: {{ $rabbitCert.Key | b64enc }}
rabbitmq-cert.pem: {{ $rabbitCert.Cert | b64enc }}
{{- end -}}