# Deployment Script for Vercel
# This script deploys both frontend and backend to Vercel

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for console output
$successColor = "Green"
$warningColor = "Yellow"
$errorColor = "Red"
$infoColor = "Cyan"

function Show-Header {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor $infoColor
    Write-Host "  Vercel Deployment Script" -ForegroundColor $infoColor
    Write-Host "========================================" -ForegroundColor $infoColor
    Write-Host ""
}

function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

function Install-VercelCLI {
    Write-Host "Checking for Vercel CLI..." -ForegroundColor $infoColor
    
    if (-not (Test-CommandExists "vercel")) {
        Write-Host "Vercel CLI not found. Installing..." -ForegroundColor $infoColor
        npm install -g vercel
    } else {
        Write-Host "Vercel CLI is already installed." -ForegroundColor $successColor
    }
}

function Deploy-ToVercel {
    param(
        [string]$environment = "production"
    )
    
    Write-Host "`n=== Deploying to Vercel ($environment) ===" -ForegroundColor $infoColor
    
    try {
        # Install Vercel CLI if not already installed
        Install-VercelCLI
        
        # Login to Vercel if not already logged in
        Write-Host "Checking Vercel login status..." -ForegroundColor $infoColor
        $loggedIn = $true
        vercel whoami 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $loggedIn = $false
            Write-Host "Logging in to Vercel..." -ForegroundColor $infoColor
            vercel login
        } else {
            Write-Host "Already logged in to Vercel." -ForegroundColor $successColor
        }
        
        # Deploy to Vercel
        Write-Host "Deploying to Vercel..." -ForegroundColor $infoColor
        
        if ($environment -eq "production") {
            vercel --prod --confirm
        } else {
            vercel
        }
        
        Write-Host "`nDeployment completed successfully!" -ForegroundColor $successColor
        Write-Host "Your application is now live on Vercel!" -ForegroundColor $successColor
    }
    catch {
        Write-Host "Error during deployment: $_" -ForegroundColor $errorColor
        throw
    }
}

# Main execution
Show-Header

# Check for required tools
Write-Host "Checking for required tools..." -ForegroundColor $infoColor
$requiredTools = @("node", "npm", "git")
$missingTools = $requiredTools | Where-Object { -not (Test-CommandExists $_) }

if ($missingTools.Count -gt 0) {
    Write-Host "The following required tools are missing: $($missingTools -join ', ')" -ForegroundColor $errorColor
    Write-Host "Please install the required tools and try again." -ForegroundColor $errorColor
    exit 1
} else {
    Write-Host "All required tools are installed." -ForegroundColor $successColor
}

# Start deployment
$deployChoice = Read-Host "Would you like to deploy to production? (y/n, default: y)"

if ($deployChoice -eq 'n') {
    Deploy-ToVercel -environment "preview"
} else {
    Deploy-ToVercel -environment "production"
}
