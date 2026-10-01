#!/bin/bash

# Situa el Bash a la carpeta on està guardat l'script
cd "$(dirname "$0")"

# Donem permisos d'execució al fitxer de Caddy per si de cas
chmod +x ./caddy_linux

# El Bash arranca el Caddy de Linux en segon pla al port 8000
./caddy_linux_amd64 file-server --listen :8000 &
PID_SERVER=$!

# Esperem un segon i obrim el Firefox
sleep 1
xdg-open http://localhost:8000

# Manté el Bash obert fins que es tanqui el procés
wait $PID_SERVER
