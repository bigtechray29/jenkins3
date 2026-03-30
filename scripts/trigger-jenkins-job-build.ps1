#Requires -Version 5.1
<#
.SYNOPSIS
  Triggers a Jenkins job via REST API (CSRF crumb + Basic auth).

  Example — job jenkins4 (S3 pipeline needs S3_BUCKET):
    $env:JENKINS_URL   = "http://54.89.54.90:8080"
    $env:JENKINS_USER  = "your_user"
    $env:JENKINS_TOKEN = "your_api_token"
    & .\trigger-jenkins-job-build.ps1 -JobName jenkins4 -Parameters @{
        S3_BUCKET = "my-app-prod"
        AWS_REGION = "us-east-1"
    }
#>
param(
    [string] $BaseUrl = $env:JENKINS_URL,
    [string] $User = $env:JENKINS_USER,
    [string] $Token = $env:JENKINS_TOKEN,
    [string] $JobName = 'jenkins4',
    [hashtable] $Parameters = @{}
)

$ErrorActionPreference = 'Stop'
if (-not $BaseUrl) { $BaseUrl = 'http://54.89.54.90:8080' }
$BaseUrl = $BaseUrl.TrimEnd('/')

if (-not $User -or -not $Token) {
    Write-Error "Set JENKINS_USER and JENKINS_TOKEN (API token). See script header."
    exit 1
}

$pair = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${User}:${Token}"))
$authHeaders = @{ Authorization = "Basic $pair" }

$crumb = Invoke-RestMethod -Uri "$BaseUrl/crumbIssuer/api/json" -Headers $authHeaders -Method Get

$headers = [ordered]@{
    Authorization             = "Basic $pair"
    $crumb.crumbRequestField = $crumb.crumb
}

# Escape each path segment (supports folder/job style names)
$jobPath = ($JobName -split '/').ForEach({ [uri]::EscapeDataString($_) }) -join '/'

if ($Parameters.Count -gt 0) {
    $uri = "$BaseUrl/job/$jobPath/buildWithParameters"
    $bodyParts = foreach ($k in $Parameters.Keys) {
        "{0}={1}" -f [uri]::EscapeDataString($k), [uri]::EscapeDataString([string]$Parameters[$k])
    }
    $body = $bodyParts -join '&'
    $response = Invoke-WebRequest -Uri $uri -Method Post -Body $body `
        -ContentType 'application/x-www-form-urlencoded' -Headers $headers -UseBasicParsing
} else {
    $uri = "$BaseUrl/job/$jobPath/build"
    $response = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers -UseBasicParsing
}

Write-Host "Status: $($response.StatusCode)"
if ($response.Headers.Location) {
    Write-Host "Location: $($response.Headers.Location)"
}
