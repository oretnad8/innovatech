@echo off
set /p NUEVA_IP="Introduce la nueva IP de AWS (ej. 54.198.73.188): "

echo Procesando cambios de IP en los componentes...

:: 1. FRONTEND: .env y archivos .jsx
if exist ".\front_despacho\.env" (
    powershell -Command "$ip='%NUEVA_IP%'.Trim(); (Get-Content '.\front_despacho\.env') -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', $ip | Set-Content '.\front_despacho\.env'"
    echo [+] Actualizado: .env del frontend.
)

powershell -Command "$ip='%NUEVA_IP%'.Trim(); Get-ChildItem -Path '.\front_despacho' -Recurse -Filter '*.jsx' | ForEach-Object { (Get-Content $_.FullName) -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', $ip | Set-Content $_.FullName }"
echo [+] Actualizado: Archivos .jsx en front_despacho.

:: 2. DOCKER-COMPOSE: docker-compose.yml
if exist ".\docker-compose.yml" (
    powershell -Command "$ip='%NUEVA_IP%'.Trim(); (Get-Content '.\docker-compose.yml') -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', $ip | Set-Content '.\docker-compose.yml'"
    echo [+] Actualizado: docker-compose.yml.
)

:: 3. GITHUB ACTIONS WORKFLOW: .github/workflows/deploy.yml
if exist ".\.github\workflows\deploy.yml" (
    powershell -Command "$ip='%NUEVA_IP%'.Trim(); (Get-Content '.\.github\workflows\deploy.yml') -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', $ip | Set-Content '.\.github\workflows\deploy.yml'"
    echo [+] Actualizado: .github/workflows/deploy.yml.
)

:: 4. BACKENDS: application.properties
powershell -Command "$ip='%NUEVA_IP%'.Trim(); Get-ChildItem -Path '.\back-Ventas_SpringBoot', '.\back-Despachos_SpringBoot' -Recurse -Filter 'application.properties' | ForEach-Object { (Get-Content $_.FullName) -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', $ip | Set-Content $_.FullName }"
echo [+] Actualizado: Archivos application.properties.

echo --------------------------------------------------
echo ¡Listo! Archivos de codigo actualizados con la IP: %NUEVA_IP%
echo Recuerda hacer Git Push para que GitHub Actions tome los cambios.
echo --------------------------------------------------
pause