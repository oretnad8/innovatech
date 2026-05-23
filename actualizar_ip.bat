@echo off
set /p NUEVA_IP="Introduce la nueva IP de AWS (ej. 54.209.101.72): "

echo Procesando cambios de IP en los componentes...

:: 1. FRONTEND: Reemplazar en todos los archivos .jsx dentro de front_despacho
powershell -Command "Get-ChildItem -Path '.\front_despacho' -Recurse -Filter '*.jsx' | ForEach-Object { (Get-Content $_.FullName) -replace 'http://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', 'http://%NUEVA_IP%' | Set-Content $_.FullName }"

:: 2. BACKENDS: Reemplazar en los application.properties si es que tienen IPs fijas en lugar de 'db'
powershell -Command "Get-ChildItem -Path '.\back-Ventas_SpringBoot', '.\back-Despachos_SpringBoot' -Recurse -Filter 'application.properties' | ForEach-Object { (Get-Content $_.FullName) -replace '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', '%NUEVA_IP%' | Set-Content $_.FullName }"

echo --------------------------------------------------
echo ¡Listo! Archivos de codigo actualizados con la IP: %NUEVA_IP%
echo Recuerda hacer Git Push para que GitHub Actions tome los cambios.
echo --------------------------------------------------
pause