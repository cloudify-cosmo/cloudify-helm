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
{{- $ca := genCA "cloudify-services-ca" 3650 }}
{{- if and (.Values.certs.ca_cert) (.Values.certs.ca_key) }}
{{- $ca = buildCustomCert .Values.certs.ca_cert .Values.certs.ca_key }}
{{- end }}
{{- $externalCert := genSignedCert "cloudify-entrypoint" nil (list "nginx" "cloudify-entrypont") 3650 $ca -}}
{{- if and (.Values.certs.external_cert) (.Values.certs.external_key) }}
{{- $externalCert = buildCustomCert .Values.certs.external_cert .Values.certs.external_key }}
{{- end }}
{{- $internalCert := genSignedCert "cloudify-entrypoint" nil (list "nginx" "cloudify-entrypoint") 3650 $ca -}}
{{- if and (.Values.certs.internal_cert) (.Values.certs.internal_key) }}
{{- $internalCert = buildCustomCert .Values.certs.internal_cert .Values.certs.internal_key }}
{{- end }}
{{- $rabbitmqCert := genSignedCert "rabbitmq" nil (list "rabbitmq") 3650 $ca -}}
{{- if and (.Values.certs.rabbitmq_cert) (.Values.certs.rabbitmq_key) }}
{{- $rabbitmqCert = buildCustomCert .Values.certs.rabbitmq_cert .Values.certs.rabbitmq_key }}
{{- end }}
cloudify_internal_ca_cert.pem: {{ $ca.Cert | b64enc }}
cloudify_internal_ca_key.pem: {{ $ca.Key | b64enc }}
cloudify_external_cert.pem: {{ $externalCert.Cert | b64enc }}
cloudify_external_key.pem: {{ $externalCert.Key | b64enc }}
cloudify_internal_cert.pem: {{ $internalCert.Cert | b64enc }}
cloudify_internal_key.pem: {{ $internalCert.Key | b64enc }}
rabbitmq-cert.pem: {{ $rabbitmqCert.Cert | b64enc }}
rabbitmq-key.pem: {{ $rabbitmqCert.Key | b64enc }}
{{- end -}}

{{/*
Generate list of curl commands to download resources.  Argument to this function
is a list of two elements:
  - base directory for downloads
  - map of destination file names to download urls
Output is a string like:
  curl -o /dir/f1 -L ftp://files.com/1 && curl -o /dir/f2 -L http://files.org/2
*/}}
{{- define "cloudify-services.curl-download" -}}
{{- $destination := index . 0 -}}
{{- $curls := list -}}
{{- range $artifact, $url := (index . 1) -}}
{{- $cmd := printf "curl -o %s/%s -L %s" $destination $artifact $url -}}
{{- $curls = append $curls $cmd -}}
{{- end -}}
{{- printf (join " && " $curls ) -}}
{{- end -}}


{{/*
Return env vars block with postgresql connection parameters.
*/}}
{{- define "cloudify-services.postgres_env_vars" -}}
- name: POSTGRES_HOST
  value: {{ .Values.db.host }}
- name: POSTGRES_DB
  value: {{ .Values.db.dbName }}
- name: POSTGRES_USER
  value: {{ .Values.db.user }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.db.k8sSecret.name }}
      key: {{ .Values.db.k8sSecret.key }}
{{- end -}}
