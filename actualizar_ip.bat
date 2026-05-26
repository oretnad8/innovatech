@echo off
setlocal enabledelayedexpansion
title InnovaTech IP Configuration Tool

echo ======================================================================
echo          INNOVATECH - MULTI-TIER INSTANCE IP CONFIGURATION            
echo ======================================================================
echo This script updates the IP configurations in your local codebase.
echo Press [ENTER] to use the default/current values listed in brackets.
echo ======================================================================
echo.

set DEFAULT_FRONT=44.215.72.96
set DEFAULT_BACK=98.86.164.163
set DEFAULT_DB=44.213.90.125

set /p IP_FRONT="[1/3] Enter Frontend Instance IP [%DEFAULT_FRONT%]: "
if "!IP_FRONT!"=="" set IP_FRONT=!DEFAULT_FRONT!
set IP_FRONT=!IP_FRONT: =!

set /p IP_BACK="[2/3] Enter Backends Instance IP [%DEFAULT_BACK%]: "
if "!IP_BACK!"=="" set IP_BACK=!DEFAULT_BACK!
set IP_BACK=!IP_BACK: =!

set /p IP_DB="[3/3] Enter Database Instance IP [%DEFAULT_DB%]: "
if "!IP_DB!"=="" set IP_DB=!DEFAULT_DB!
set IP_DB=!IP_DB: =!

echo.
echo ======================================================================
echo CONFIRM NEW IP CONFIGURATIONS:
echo   - FRONTEND INSTANCE: !IP_FRONT!
echo   - BACKENDS INSTANCE: !IP_BACK!
echo   - DATABASE INSTANCE: !IP_DB!
echo ======================================================================
echo.
pause

echo.
echo [+] Processing IP updates in codebase...

:: 1. FRONTEND ENVIRONMENT FILE (.env) -> Needs to point to Backend Instance IP
if exist ".\front_despacho\.env" (
    powershell -Command "$ip='!IP_BACK!'; (Get-Content '.\front_despacho\.env') -replace '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', $ip | Set-Content '.\front_despacho\.env'"
    echo [+] Updated: .\front_despacho\.env (Endpoints mapped to Backends IP: !IP_BACK!)
) else (
    echo [!] Warning: .\front_despacho\.env was not found.
)

:: 2. FRONTEND SOURCE JSX FILES -> In case there are hardcoded IP references
powershell -Command "$ip='!IP_BACK!'; Get-ChildItem -Path '.\front_despacho' -Recurse -Filter '*.jsx' | ForEach-Object { (Get-Content $_.FullName) -replace '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', $ip | Set-Content $_.FullName }"
echo [+] Updated: Raw IP references in all front_despacho .jsx files.

:: 3. BACKEND COMPOSE CONFIGURATION (docker-compose-backends.yml) -> Needs database IP
if exist ".\docker-compose-backends.yml" (
    powershell -Command "$ip='!IP_DB!'; (Get-Content '.\docker-compose-backends.yml') -replace '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', $ip -replace 'IP_PRIVADA_DE_TU_EC2_DATABASE', $ip | Set-Content '.\docker-compose-backends.yml'"
    echo [+] Updated: .\docker-compose-backends.yml (SPRING_DATASOURCE_URL mapped to Database IP: !IP_DB!)
) else (
    echo [!] Warning: .\docker-compose-backends.yml was not found.
)

:: 4. SPRINGBOOT application.properties (both backends) -> Backup update for properties files
powershell -Command "$ip='!IP_DB!'; Get-ChildItem -Path '.\back-Ventas_SpringBoot', '.\back-Despachos_SpringBoot' -Recurse -Filter 'application.properties' | ForEach-Object { (Get-Content $_.FullName) -replace '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', $ip | Set-Content $_.FullName }"
echo [+] Updated: Raw IP references in Spring Boot application.properties.

echo.
echo ======================================================================
echo                IMPORTANT: GITHUB SECRETS REQUIREMENT                  
echo ======================================================================
echo Since you are using a Multi-Tier architecture with three separate
echo servers, the GitHub Actions deployment workflow relies on Secrets.
echo.
echo Please go to your GitHub repository:
echo Settings - Secrets and variables - Actions
echo.
echo Update or create the following Repository Secrets with these values:
echo.
echo     AWS_HOST_FRONT  ==^>  !IP_FRONT!
echo     AWS_HOST_BACK   ==^>  !IP_BACK!
echo     AWS_HOST_DB     ==^>  !IP_DB!
echo.
echo Also verify that your:
echo     AWS_SSH_KEY
echo contains a valid private SSH key (.pem) authorized on all three servers.
echo ======================================================================
echo.
echo Complete the update in Git by executing:
echo   git add .
echo   git commit -m "chore: update architecture server IPs to new tier instances"
echo   git push origin deploy
echo ======================================================================
echo.
pause