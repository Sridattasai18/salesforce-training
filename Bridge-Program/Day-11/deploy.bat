@echo off
REM Day 11 Deployment Script
REM Deploys REST API Integration components to Salesforce

echo ========================================
echo Day 11 - REST API Integration Deployment
echo ========================================
echo.

REM Get the root directory (2 levels up from this script)
cd /d "%~dp0..\.."

echo Current directory: %CD%
echo.

REM Check if Salesforce CLI is installed
sf --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Salesforce CLI not found!
    echo Please install Salesforce CLI from https://developer.salesforce.com/tools/salesforcecli
    pause
    exit /b 1
)

echo Salesforce CLI found!
echo.

REM Display available orgs
echo Available Salesforce Orgs:
sf org list
echo.

REM Check if default org is set
sf org display >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No default org configured!
    echo Please set a default org: sf config set target-org [alias/username]
    pause
    exit /b 1
)

echo Using default org:
sf org display --json
echo.

echo ========================================
echo Step 1: Deploying Custom Object (Integration_Log__c)
echo ========================================
sf project deploy start --source-dir force-app/main/default/objects/Integration_Log__c
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy Integration_Log__c
    pause
    exit /b 1
)
echo SUCCESS: Integration_Log__c deployed
echo.

echo ========================================
echo Step 2: Deploying Named Credential (Recruitment_API)
echo ========================================
sf project deploy start --source-dir force-app/main/default/namedCredentials
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy Named Credential
    pause
    exit /b 1
)
echo SUCCESS: Named Credential deployed
echo.

echo ========================================
echo Step 3: Deploying Apex Classes
echo ========================================
sf project deploy start --metadata ApexClass:ApplicationTriggerHandler
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy ApplicationTriggerHandler
    pause
    exit /b 1
)
echo SUCCESS: ApplicationTriggerHandler deployed
echo.

sf project deploy start --metadata ApexClass:CandidateSyncJob
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy CandidateSyncJob
    pause
    exit /b 1
)
echo SUCCESS: CandidateSyncJob deployed
echo.

sf project deploy start --metadata ApexClass:ExternalPlacementService
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy ExternalPlacementService
    pause
    exit /b 1
)
echo SUCCESS: ExternalPlacementService deployed
echo.

echo ========================================
echo Step 4: Deploying Trigger
echo ========================================
sf project deploy start --metadata ApexTrigger:ApplicationTrigger
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy ApplicationTrigger
    pause
    exit /b 1
)
echo SUCCESS: ApplicationTrigger deployed
echo.

echo ========================================
echo ✅ Deployment Complete!
echo ========================================
echo.
echo Deployed Components:
echo   ✓ Integration_Log__c (Custom Object with 8 fields)
echo   ✓ Recruitment_API (Named Credential)
echo   ✓ ApplicationTriggerHandler.cls
echo   ✓ CandidateSyncJob.cls
echo   ✓ ExternalPlacementService.cls
echo   ✓ ApplicationTrigger.trigger
echo.
echo Next Steps:
echo 1. Test the integration by updating an Application status to "Selected"
echo 2. Check Apex Jobs for queued CandidateSyncJob
echo 3. Query Integration_Log__c to verify callout was logged
echo 4. Review Debug Logs for callout details
echo.
echo For manual testing, run the anonymous Apex script in:
echo   Bridge-Program/Day-11/README.md
echo.

pause
