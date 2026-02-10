#!/usr/bin/env pwsh
param(
  [Parameter(Mandatory = $false)]
  [string]$JsonInput
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($JsonInput)) {
  Write-Output "Usage: ./extract.ps1 '<json>'"
  Write-Output ""
  Write-Output "Required:"
  Write-Output "  urls: string or array - Single URL or list (max 20)"
  Write-Output ""
  Write-Output "Optional:"
  Write-Output "  extract_depth: \"basic\" (default), \"advanced\" (for JS/complex pages)"
  Write-Output "  query: string - Reranks chunks by relevance to this query"
  Write-Output "  chunks_per_source: 1-5 (default: 3, only with query)"
  Write-Output "  format: \"markdown\" (default), \"text\""
  Write-Output "  include_images: true/false"
  Write-Output "  include_favicon: true/false"
  Write-Output "  timeout: 1.0-60.0 seconds"
  Write-Output ""
  Write-Output "Example:"
  Write-Output "  ./extract.ps1 '{\"urls\": [\"https://docs.example.com/api\"], \"query\": \"authentication\", \"chunks_per_source\": 3}'"
  exit 1
}

if ([string]::IsNullOrWhiteSpace($env:TAVILY_API_KEY)) {
  Write-Output "Error: TAVILY_API_KEY environment variable not set"
  exit 1
}

try {
  $payload = $JsonInput | ConvertFrom-Json -ErrorAction Stop
} catch {
  Write-Output "Error: Invalid JSON input"
  exit 1
}

if (-not $payload.urls) {
  Write-Output "Error: 'urls' field is required"
  exit 1
}

$headers = @{
  Authorization = "Bearer $env:TAVILY_API_KEY"
  "x-client-source" = "ds-agent-skills"
}

$response = Invoke-RestMethod -Method Post -Uri "https://api.tavily.com/extract" -Headers $headers -ContentType "application/json" -Body $JsonInput
$response | ConvertTo-Json -Depth 10
