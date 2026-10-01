# 1. Donar de alta la tauleta i desar el seu ID únic en una variable de la consola
ID_TAULETA=$(curl -k -s -X POST "https://localhost:8443/tauleta/declarar" \
     -H "Content-Type: application/json" \
     -d '{"contrasenya":"12345", "model_dispositiu":"Tauleta Simulada Bash"}' | tr -d '"')

echo "-> ID de la tauleta generat pel servidor: $ID_TAULETA"

# 2. Definim el contingut a enviar en format JSON compacte (sense espais) per evitar fallades de Hash
PRIVAT_JSON='{"detall_ocult":"Usuari conflictiu a la zona de caixes."}'
PUBLIC_JSON='{"tipus":"Robatori","zona":"Pasillo 3"}'

# 3. Calculem els corresponents Hashes SHA-256 en Bash
HASH_PRIVAT=$(echo -n "$PRIVAT_JSON" | sha256sum | awk '{print $1}')
HASH_PUBLIC=$(echo -n "$PUBLIC_JSON" | sha256sum | awk '{print $1}')

echo "-> Hash Privat calculat: $HASH_PRIVAT"
echo "-> Hash Públic calculat: $HASH_PUBLIC"

# 4. Fem el segon curl injectant totes les dades recollides i els Hashes coincidents
curl -k -X POST "https://localhost:8443/incident/sincro/data" \
     -H "Content-Type: application/json" \
     -d "{
       \"incident_in\": {
         \"ids\": {
           \"tablet\": \"$ID_TAULETA\",
           \"incident\": \"inc-bash-001\"
         },
         \"contingut_dinamic_privat\": $PRIVAT_JSON,
         \"contingut_dinamic_public\": $PUBLIC_JSON,
         \"datetime\": \"2026-06-08T15:30:00Z\"
       },
       \"hash_data\": {
         \"privat\": \"$HASH_PRIVAT\",
         \"public\": \"$HASH_PUBLIC\"
       }
     }"
