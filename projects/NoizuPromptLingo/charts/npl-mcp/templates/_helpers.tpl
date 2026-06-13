{{- define "npl-mcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "npl-mcp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "npl-mcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "npl-mcp.labels" -}}
helm.sh/chart: {{ include "npl-mcp.chart" . }}
app.kubernetes.io/name: {{ include "npl-mcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "npl-mcp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "npl-mcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "npl-mcp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "npl-mcp.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "npl-mcp.secretName" -}}
{{- if .Values.secrets.name -}}
{{- .Values.secrets.name -}}
{{- else -}}
{{- printf "%s-secrets" (include "npl-mcp.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "npl-mcp.databaseHost" -}}
{{- if .Values.database.host -}}
{{- .Values.database.host -}}
{{- else if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" (include "npl-mcp.fullname" .) -}}
{{- else -}}
{{- fail "database.host is required when postgresql.enabled=false" -}}
{{- end -}}
{{- end -}}

{{- define "npl-mcp.valkeyHost" -}}
{{- printf "%s-valkey" (include "npl-mcp.fullname" .) -}}
{{- end -}}
