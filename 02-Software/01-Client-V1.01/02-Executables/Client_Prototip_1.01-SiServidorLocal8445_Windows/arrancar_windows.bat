@echo off
:: Canvia el directori de treball a la ruta actual de la carpeta
cd /d "%~dp0"
:: Inicia el servidor de fitxers estàtics de Caddy de forma local
start "" caddy_windows_amd64.exe file-server --listen :8000
:: Espera un segon i obre el navegador predeterminat del Windows
timeout /t 1 >nul
start http://localhost:8000
