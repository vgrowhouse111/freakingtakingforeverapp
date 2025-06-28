# Deployment Script for Bolt Application
# This script helps deploy both frontend and backend components

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
    Write-Host "  Bolt Application Deployment Script" -ForegroundColor $infoColor
    Write-Host "========================================" -ForegroundColor $infoColor
    Write-Host ""
}

function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

function Install-RequiredTools {
    Write-Host "Checking for required tools..." -ForegroundColor $infoColor
    
    $tools = @("node", "npm", "git")
    $missingTools = @()
    
    foreach ($tool in $tools) {
        if (-not (Test-CommandExists $tool)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Host "The following required tools are missing: $($missingTools -join ', ')" -ForegroundColor $warningColor
        $installChoice = Read-Host "Would you like to install the missing tools? (y/n)"
        
        if ($installChoice -eq 'y') {
            # Check for Chocolatey
            if (-not (Test-CommandExists choco)) {
                Write-Host "Installing Chocolatey package manager..." -ForegroundColor $infoColor
                Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            }
            
            # Install missing tools using Chocolatey
            foreach ($tool in $missingTools) {
                Write-Host "Installing $tool..." -ForegroundColor $infoColor
                choco install $tool -y
            }
        } else {
            Write-Host "Please install the required tools and try again." -ForegroundColor $errorColor
            exit 1
        }
    } else {
        Write-Host "All required tools are installed." -ForegroundColor $successColor
    }
}

function Deploy-Backend {
    param(
        [string]$environment = "production"
    )
    
    Write-Host "`n=== Deploying Backend ($environment) ===" -ForegroundColor $infoColor
    
    try {
        # Navigate to server directory
        Push-Location -Path ".\server" -ErrorAction Stop
        
        # Check if render.yaml exists
        if (-not (Test-Path "render.yaml")) {
            throw "render.yaml not found in server directory. Please make sure you're in the correct directory."
        }
        
        # Install dependencies
        Write-Host "Installing backend dependencies..." -ForegroundColor $infoColor
        npm install --production
        
        # Build the application if needed
        if (Test-Path "package.json") {
            $packageJson = Get-Content "package.json" | ConvertFrom-Json
            if ($packageJson.scripts.build) {
                Write-Host "Building backend application..." -ForegroundColor $infoColor
                npm run build
            }
        }
        
        # Deploy to Render
        Write-Host "Deploying to Render..." -ForegroundColor $infoColor
        
        # Check if render-cli is installed
        if (-not (Test-CommandExists "render")) {
            Write-Host "Installing Render CLI..." -ForegroundColor $infoColor
            npm install -g @render-oss/cli
        }
        
        # Deploy to Render
        render services create --dir . --yes
        
        Write-Host "Backend deployed successfully!" -ForegroundColor $successColor
    }
    catch {
        Write-Host "Error deploying backend: $_" -ForegroundColor $errorColor
        throw
    }
    finally {
        # Return to the original directory
        Pop-Location
    }
}

function Deploy-Frontend {
    param(
        [string]$environment = "production"
    )
    
    Write-Host "`n=== Deploying Frontend ($environment) ===" -ForegroundColor $infoColor
    
    try {
        # Install dependencies
        Write-Host "Installing frontend dependencies..." -ForegroundColor $infoColor
        npm install
        
        # Build the application
        Write-Host "Building frontend application..." -ForegroundColor $infoColor
        npm run build
        
        # Deploy to Vercel
        if (-not (Test-CommandExists "vercel")) {
            Write-Host "Installing Vercel CLI..." -ForegroundColor $infoColor
            npm install -g vercel
        }
        
        Write-Host "Deploying to Vercel..." -ForegroundColor $infoColor
        vercel --prod
        
        Write-Host "Frontend deployed successfully!" -ForegroundColor $successColor
    }
    catch {
        Write-Host "Error deploying frontend: $_" -ForegroundColor $errorColor
        throw
    }
}

# Main execution
Show-Header

# Check for required tools
Install-RequiredTools

# Ask user what to deploy
$deployChoice = Read-Host "What would you like to deploy? (1: Backend, 2: Frontend, 3: Both, 0: Exit)"

switch ($deployChoice) {
    "1" { 
        Deploy-Backend -environment "production"
    }
    "2" { 
        Deploy-Frontend -environment "production"
    }
    "3" { 
        Deploy-Backend -environment "production"
        Deploy-Frontend -environment "production"
    }
    default {
        Write-Host "Exiting without deployment." -ForegroundColor $infoColor
        exit 0
    }
}

Write-Host "`nDeployment completed successfully!" -ForegroundColor $successColor
