{{- define "start-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "start-app.fullname" -}}
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

{{- define "start-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "start-app.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "start-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "start-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "start-app.cloudflareWhitelist" -}}
173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/13,104.24.0.0/14,172.64.0.0/13,131.0.72.0/22,2400:cb00::/32,2606:4700::/32,2803:f800::/32,2405:b500::/32,2405:8100::/32,2a06:98c0::/29,2c0f:f248::/32
{{- end }}

{{- define "start-app.backendEnv" -}}
- name: DB_HOST
  value: {{ .Values.database.host | quote }}
- name: DB_PORT
  value: {{ .Values.database.port | quote }}
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.dbUser }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.dbPassword }}
- name: DB_NAME
  value: {{ .Values.database.name | quote }}
{{- if .Values.secrets.keys.databaseUrl }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.databaseUrl }}
{{- end }}
- name: SECRET_KEY_BASE
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.secretKeyBase }}
- name: GUARDIAN_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.guardianSecretKey }}
- name: REDIS_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.redisUrl }}
- name: PHX_HOST
  value: {{ .Values.domain | quote }}
- name: FRONTEND_URL
  value: "https://{{ .Values.domain }}"
- name: PHX_SERVER
  value: "true"
- name: PORT
  value: {{ .Values.backend.port | quote }}
{{- if .Values.secrets.keys.sendgridApiKey }}
- name: SENDGRID_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.sendgridApiKey }}
{{- end }}
- name: MAIL_FROM_NAME
  value: {{ .Values.mail.fromName | default .Values.domain | quote }}
- name: MAIL_FROM_ADDRESS
  value: {{ .Values.mail.fromAddress | default (printf "noreply@%s" .Values.domain) | quote }}
{{- if .Values.sso.oidc.issuer }}
- name: OIDC_ISSUER
  value: {{ .Values.sso.oidc.issuer | quote }}
- name: OIDC_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.oidcClientId }}
- name: OIDC_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.oidcClientSecret }}
- name: OIDC_REDIRECT_URI
  value: "https://{{ .Values.domain }}/auth/oidc/callback"
{{- end }}
{{- if .Values.secrets.keys.googleClientId }}
- name: GOOGLE_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.googleClientId }}
- name: GOOGLE_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.googleClientSecret }}
{{- end }}
{{- if .Values.secrets.keys.facebookClientId }}
- name: FACEBOOK_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.facebookClientId }}
- name: FACEBOOK_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.facebookClientSecret }}
{{- end }}
{{- if .Values.secrets.keys.githubClientId }}
- name: GITHUB_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.githubClientId }}
- name: GITHUB_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.githubClientSecret }}
{{- end }}
{{- if .Values.secrets.keys.linkedinClientId }}
- name: LINKEDIN_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.linkedinClientId }}
- name: LINKEDIN_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.linkedinClientSecret }}
{{- end }}
{{- if .Values.sso.saml.idpMetadataUrl }}
- name: SAML_IDP_METADATA_URL
  value: {{ .Values.sso.saml.idpMetadataUrl | quote }}
- name: SAML_SP_ENTITY_ID
  value: {{ .Values.sso.saml.spEntityId | default (printf "https://%s" .Values.domain) | quote }}
- name: SAML_SP_BASE_URL
  value: "https://{{ .Values.domain }}/sso/saml"
- name: SAML_SP_CERT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.samlSpCert }}
- name: SAML_SP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.samlSpKey }}
{{- end }}
{{- if .Values.sso.requireInvite }}
- name: SSO_REQUIRE_INVITE
  value: "true"
{{- end }}
{{- end }}

{{- define "start-app.otelEnv" -}}
{{- if .Values.otel.enabled }}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ .Values.otel.collectorEndpoint | quote }}
- name: OTEL_SERVICE_NAME
  value: {{ .Values.otel.serviceName | quote }}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: "deployment.environment={{ .Release.Namespace }}"
{{- end }}
{{- end }}

{{- define "start-app.storageEnv" -}}
{{- if .Values.storage.enabled }}
- name: S3_BUCKET
  value: {{ .Values.storage.bucket | quote }}
- name: S3_REGION
  value: {{ .Values.storage.region | quote }}
{{- if .Values.storage.endpoint }}
- name: S3_ENDPOINT
  value: {{ .Values.storage.endpoint | quote }}
{{- end }}
- name: S3_SCHEME
  value: {{ .Values.storage.scheme | quote }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.awsAccessKeyId | default "AWS_ACCESS_KEY_ID" }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.name }}
      key: {{ .Values.secrets.keys.awsSecretAccessKey | default "AWS_SECRET_ACCESS_KEY" }}
{{- end }}
{{- end }}
