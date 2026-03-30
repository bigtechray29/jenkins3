#Requires -Version 5.1
<#
.SYNOPSIS
  Triggers Generic Webhook Trigger with Jenkins CSRF crumb + Basic auth.

  Set secrets in the shell (do not commit them):
    $env:JENKINS_URL   = "http://54.89.54.90:8080"
    $env:JENKINS_USER  = "your_user"
    $env:JENKINS_TOKEN = "your_api_token"   # Jenkins User -> Configure -> API Token
    $env:WEBHOOK_TOKEN = "jenkins4-git-webhook"

  Optional:
    $env:WEBHOOK_REF = "refs/heads/main"
#>
param(
    [string] $BaseUrl = $env:JENKINS_URL,
    [string] $User = $env:JENKINS_USER,
    [string] $Token = $env:JENKINS_TOKEN,
    [string] $InvokeToken = $(if ($env:WEBHOOK_TOKEN) { $env:WEBHOOK_TOKEN } else { 'jenkins4-git-webhook' }),
    [string] $Ref = $(if ($env:WEBHOOK_REF) { $env:WEBHOOK_REF } else { 'refs/heads/main' })
)

$ErrorActionPreference = 'Stop'
if (-not $BaseUrl) { $BaseUrl = 'http://54.89.54.90:8080' }
$BaseUrl = $BaseUrl.TrimEnd('/')

if (-not $User -or -not $Token) {
    Write-Error "Set JENKINS_USER and JENKINS_TOKEN (or pass as parameters). See script header."
    exit 1
}

$pair = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${User}:${Token}"))
$authHeaders = @{ Authorization = "Basic $pair" }

$crumb = Invoke-RestMethod -Uri "$BaseUrl/crumbIssuer/api/json" -Headers $authHeaders -Method Get

$headers = [ordered]@{
    Authorization             = "Basic $pair"
    $crumb.crumbRequestField = $crumb.crumb
}

$uri = "$BaseUrl/generic-webhook-trigger/invoke?token=$([uri]::EscapeDataString($InvokeToken))"
$body = "{`"ref`":`"$Ref`"}"

$response = Invoke-WebRequest -Uri $uri -Method Post -Body $body -ContentType 'application/json' `
    -Headers $headers -UseBasicParsing

Write-Host "Status: $($response.StatusCode)"
Write-Host $response.Content
