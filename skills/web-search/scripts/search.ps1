#!/usr/bin/env pwsh
param(
  [Parameter(Mandatory = $false)]
  [string]$JsonInput
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($JsonInput)) {
  Write-Output "Usage: ./search.ps1 '<json>'"
  Write-Output ""
  Write-Output "Required:"
  Write-Output "  query: string - Search query (keep under 400 chars)"
  Write-Output ""
  Write-Output "Optional:"
  Write-Output "  search_depth: \"ultra-fast\", \"fast\", \"basic\" (default), \"advanced\""
  Write-Output "  topic: \"general\" (default), \"news\", \"finance\""
  Write-Output "  max_results: 1-20 (default: 5)"
  Write-Output "  chunks_per_source: 1-5 (default: 3, advanced/fast depth only)"
  Write-Output "  time_range: \"day\", \"week\", \"month\", \"year\""
  Write-Output "  start_date: \"YYYY-MM-DD\""
  Write-Output "  end_date: \"YYYY-MM-DD\""
  Write-Output "  include_domains: [\"domain1.com\", \"domain2.com\"]"
  Write-Output "  exclude_domains: [\"domain1.com\", \"domain2.com\"]"
  Write-Output "  country: country name (general topic only)"
  Write-Output "  include_answer: true/false or \"basic\"/\"advanced\""
  Write-Output "  include_raw_content: true/false or \"markdown\"/\"text\""
  Write-Output "  include_images: true/false"
  Write-Output "  include_image_descriptions: true/false"
  Write-Output "  include_favicon: true/false"
  Write-Output ""
  Write-Output "Example:"
  Write-Output "  ./search.ps1 '{\"query\": \"latest AI trends\", \"topic\": \"news\", \"time_range\": \"week\"}'"
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

if (-not $payload.query) {
  Write-Output "Error: 'query' field is required"
  exit 1
}

$headers = @{
  Authorization = "Bearer $env:TAVILY_API_KEY"
  "x-client-source" = "ds-agent-skills"
}

$response = Invoke-RestMethod -Method Post -Uri "https://api.tavily.com/search" -Headers $headers -ContentType "application/json" -Body $JsonInput
$response | ConvertTo-Json -Depth 10
