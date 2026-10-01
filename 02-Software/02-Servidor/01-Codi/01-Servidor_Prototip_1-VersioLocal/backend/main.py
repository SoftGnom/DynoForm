# Servidor
from fastapi import FastAPI, File, UploadFile, HTTPException, Query
from pydantic import BaseModel
from fastapi import Request
from fastapi import Form, Depends
from fastapi.encoders import jsonable_encoder
# Dades Permanents
from tinydb import TinyDB, Query
from tinydb.storages import JSONStorage  
from tinydb.storages import Storage # Importem Storage en lloc de JSONStorage
import json
import logging
import pymongo
# Seguretat
from cryptography.fernet import Fernet
import uuid
import hashlib
import canonicaljson
# Sistema
import time
import os
# Tipus de dades
from typing import Dict, Any, List
from datetime import datetime
# ALtres
import asyncio



# --- Configuració de Seguretat ---
# Aquesta clau s'ha de guardar de forma segura. 
# Pots generar-ne una de nova amb: Fernet.generate_key()
# NOTA: Ha de ser una cadena de 32 bytes codificada en base64.
CLAU_SECRET_FERNET = b'Fq5d6EFoZ-iAhFpmnqOS530rG7y5LiLXZ7-cJUduc3E='  #b'u7_X8_clau_secreta_de_32_bytes_anvaa_Exemple=' 
cipher_suite = Fernet(CLAU_SECRET_FERNET)

ENCRYPTION_KEY = "clau_super_secreta_anvaa_2024" # Definim una clau de xifratge (hauria d'estar en una variable d'entorn)(TinyDB)

CONTRASEYA_INSCRIURE_TAULETA = "contra_proves"

class EncryptedStorage(Storage):
    """Estructura personalitzada per xifrar el fitxer de TinyDB manualment"""
    def __init__(self, filename):
        self.filename = filename

    def read(self):
        # 1. Si no existeix, és el primer cop, retornem None
        if not os.path.exists(self.filename):
            return None
            
        with open(self.filename, 'rb') as f:
            encrypted_data = f.read()
            
        if not encrypted_data:
            return None
            
        # 2. SENSE TRY/EXCEPT. Si la clau falla (InvalidToken), el servidor 
        # ha de mostrar un error 500, no pas continuar i esborrar les dades.
        decrypted_data = cipher_suite.decrypt(encrypted_data)
        return json.loads(decrypted_data.decode('utf-8'))

    def write(self, data):
        data_json = json.dumps(data).encode('utf-8')
        encrypted_data = cipher_suite.encrypt(data_json)
        with open(self.filename, 'wb') as f:
            f.write(encrypted_data)

    def close(self):
        pass


# --- Iniciar Elements ---

# Inicialitzem el servidor
app = FastAPI(title="Servidor - Core")


# Garanteix que la carpeta d'imatges existexi des de l'inici
os.makedirs("./Imatges", exist_ok=True) 

# Inicialitzem la base de dades local (es crearà un fitxer db.json)


# ======================================================================================
# CONFIGURACIÓ DEL XIFRAT (Comenta/Descomenta per activar o desactivar en proves)
# ======================================================================================

# OPCIÓ A: Mode SENSE XIFRAT (Estàndard en clar JSON)
# db = TinyDB('cahe.anvaa_server.no_xifrat.json', storage=JSONStorage)

# OPCIÓ B: Mode AMB XIFRAT (Producció)
db = TinyDB('cahe.anvaa_server.xifrat.json', storage=EncryptedStorage)
# ======================================================================================

table_tauletes = db.table('tauletes')

# Configurem el sistema de logs
logging.basicConfig(
    filename='auditoria_rgpd.log',
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# Configuració de MongoDB
# Agafem la URI de la variable d'entorn del contenedor; si no existeix, posem una per defecte en local
MONGO_URI = os.getenv("MONGO_URI", "mongodb://usuari_admin:contrasenya_super_segura@base_dades_nosql:27017/db_principal?authSource=admin")

try:
    client_mongo = pymongo.MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
    # Seleccionem la base de dades especificada a la teva URI (db_principal)
    db_mongo = client_mongo.get_default_database()
    print("Connexió inicial amb MongoDB establerta correctament.")
except Exception as e:
    print("No s'ha pogut connectar a MongoDB:", e)


# --- Carregar en memoria ---

# Diccionari en memòria per a cerques ultra-ràpides (O(1))
# Es carregarà en iniciar el servidor si ja hi ha dades a la DB
registre_ids_actius = {t['id_tauleta']: True for t in table_tauletes.all()}

logger_auditoria = logging.getLogger("RGPD_Auditoria")




# --- MÒDUL D'INTERCONNEXIÓ (Lògica de Reconeixement) ---

def generar_id_abstracte(id_tablet: str, id_incident_local: str) -> str:
    """
    Crea un ID opac per a la BD. No conté l'ID de la tablet directament.
    Això protegeix la identitat del dispositiu en cas de fuga de dades.
    """
    llavor = "ANVAA_SECRET_SALT_2024" # Una clau interna del servidor
    cadena_combinada = f"{id_tablet}{id_incident_local}{llavor}"
    return hashlib.sha256(cadena_combinada.encode()).hexdigest()

"""
async def persistir_a_la_bd(dades_preparades: Dict[str, Any], taula_nom: str = "incidents"):
    "" "
    Funció genèrica que rep les dades i les guarda de forma segura
    utilitzant el pany centralitzat per evitar corrupció a TinyDB.
    "" "
    pany = obtenir_pany("anvaa_server_db")
    await pany.acquire()
    try:
        taula = db.table(taula_nom)
        taula.insert(dades_preparades)
        return True
    except Exception as e:
        logger_auditoria.error(f"ERROR PERSISTÈNCIA: No s'ha pogut guardar a {taula_nom}. Detall: {e}")
        return False
    finally:
        pany.release()
     

async def persistir_a_la_bd(dades_preparades: Dict[str, Any], taula_nom: str = "incidents"): //Funciona be - tot u dica al mateix lloc
    "" "
    Persisteix un document directament a la col·lecció corresponent de MongoDB.
    Neteja els objectes complexos de Pydantic abans de desar-los.
    "" "
    pany = obtenir_pany("mongo_db_lock")
    
    async with pany:
        try:
            colleccio = db_mongo[taula_nom]
                        
            
            # --- CAPA DE XIFRAT DE DADES PER A MONGODB (Opcional en proves) ---
            # Si vols desactivar el xifrat de dades de MongoDB a les teves proves, comenta el bloc d'abaix
            # i deixa passar 'dades_preparades' directament.
            
            # BLOC DE XIFRAT (Comenta des d'aquí si vols veure les dades en clar a Mongo-Express):
            # dades_a_guardar = {
            #     "id_encriptat": dades_preparades.get("id_incident", str(uuid.uuid4())),
            #     "dades_segures": cipher_suite.encrypt(json.dumps(dades_preparades).encode()).decode(),
            #     "data_registre": datetime.utcnow()
            # }
            # ----------------------------------------------------------------------------------
            
            # --- SOLUCIÓ AL CRASH: Convertim tot a tipus natius (dict, list, str...) ---
            # Això transforma automàticament el 'HashPar' de Pydantic en un diccionari natiu
            dades_natives = jsonable_encoder(dades_preparades)
            
            # BLOC EN CLAR (Per a les teves proves locals):
            dades_a_guardar = dades_natives
            
            # Assignem la clau primària de MongoDB (_id) utilitzant l'ID que ja tens calculat
            if "_id" not in dades_a_guardar:
                # Busquem si l'ID combinat o l'ID de l'incident s'ha passat com a paràmetre
                dades_a_guardar["_id"] = dades_a_guardar.get("id_incident", str(uuid.uuid4()))

            id_document = dades_a_guardar["_id"]

            # Inserció / Actualització a MongoDB
            colleccio.update_one(
                {"_id": id_document},
                {"$set": dades_a_guardar},
                upsert=True
            )
            
            logger_auditoria.info(f"MongoDB: Document guardat correctament a la col·lecció '{taula_nom}'.")
            return True
        except Exception as e:
            logger_auditoria.error(f"Error crític en persistir a MongoDB (Col·lecció {taula_nom}): {str(e)}")
            raise HTTPException(status_code=500, detail="Error intern al desar les dades de seguretat.")
            return False

         
async def persistir_a_la_bd(dades_preparades: Dict[str, Any], taula_nom: str = "incidents"): //funciona - diferetes colecions
    "" "
    Persisteix un document de forma segregada a MongoDB en 3 col·leccions diferents:
    - {taula_nom}_privat: Conté exclusivament l'ID i les dades privades.
    - {taula_nom}_public: Conté exclusivament l'ID i les dades públiques.
    - {taula_nom}_metadata: Conté exclusivament l'ID i el control de hashes/coincidències.
    
    Això garanteix el principi de minimització i dissociació del RGPD.
    "" "
    pany = obtenir_pany("mongo_db_lock")
    
    async with pany:
        try:
            # 1. Convertim tot a tipus natius per evitar qualsevol problema amb objectes Pydantic
            dades_natives = jsonable_encoder(dades_preparades)
            
            # 2. Recuperem l'ID opac que servirà de clau primària comuna (_id)
            id_central = dades_natives.get("id_intern_servidor")
            if not id_central:
                # Fallback de seguretat en cas que no s'hagi calculat
                id_central = str(uuid.uuid4())
            
            # 3. Separació de paquets (Un id_intern_servidor per governar-los a tots)
            paquet_privat = {
                "_id": id_central,
                "contingut_privat": dades_natives.get("contingut_privat", {})
            }
            
            paquet_public = {
                "_id": id_central,
                "contingut_public": dades_natives.get("contingut_public", {})
            }
            
            paquet_metadata = {
                "_id": id_central,
                "metadata": dades_natives.get("metadata", {})
            }
            
            # 4. Connexió a les 3 col·leccions independents derivades del nom base
            colleccio_privada = db_mongo[f"{taula_nom}_privat"]
            colleccio_publica = db_mongo[f"{taula_nom}_public"]
            colleccio_metadata = db_mongo[f"{taula_nom}_metadata"]
            
            # 5. Escriptura / Actualització en paral·lel o seqüencial controlada (upsert=True)
            colleccio_privada.update_one({"_id": id_central}, {"$set": paquet_privat}, upsert=True)
            colleccio_publica.update_one({"_id": id_central}, {"$set": paquet_public}, upsert=True)
            colleccio_metadata.update_one({"_id": id_central}, {"$set": paquet_metadata}, upsert=True)
            
            # Registrem l'auditoria d'èxit general
            logger_auditoria.info(
                f"MongoDB Segregat: S'ha compartimentat correctament l'incident {id_central[:10]} "
                f"en les col·leccions privades, públiques i de metadades."
            )
            
            # Retornem True per indicar a l'endpoint que tot el procés s'ha completat sense errors
            return True

        except Exception as e:
            logger_auditoria.error(f"Error crític en la persistència segregada a MongoDB (Base: {taula_nom}): {str(e)}")
            # Si falla qualsevol de les tres escriptures, aixequem un error 500
            raise HTTPException(status_code=500, detail="Error intern al desar les dades compartimentades de seguretat.")
            
"""
        
        
async def persistir_a_la_bd(dades_preparades: Dict[str, Any], taula_nom: str = "incidents"): # funciona per en diferetes BDs
    """
    Persisteix un document segregant les dades en BASES DE DADES diferents de MongoDB
    per complir amb el principi de màxima privacitat i aïllament administratriu.
    """
    pany = obtenir_pany("mongo_db_lock")
    
    async with pany:
        try:
            # Convertim objectes de Pydantic a tipus natius
            dades_natives = jsonable_encoder(dades_preparades)
            
            id_central = dades_natives.get("id_intern_servidor", str(uuid.uuid4()))
            
            # 1. Separació neta dels paquets de dades
            paquet_privat = {"_id": id_central, "contingut_privat": dades_natives.get("contingut_privat", {})}
            paquet_public = {"_id": id_central, "contingut_public": dades_natives.get("contingut_public", {})}
            paquet_metadata = {"_id": id_central, "metadata": dades_natives.get("metadata", {})}
            
            # ==============================================================================
            # CANVI CLAU: Connectem a BASES DE DADES independents en lloc de col·leccions
            # ==============================================================================
            # client_mongo és l'objecte que hem instanciat al principi de tot del main.py
            bd_privada = client_mongo["db_dades_privades"]
            bd_publica = client_mongo["db_dades_publiques"]
            bd_metadata = client_mongo["db_auditoria_metadata"]
            
            # Dins de cada base de dades, la col·lecció es pot dir igual (ex: 'incidents')
            colleccio_privada = bd_privada[taula_nom]
            colleccio_publica = bd_publica[taula_nom]
            colleccio_metadata = bd_metadata[taula_nom]
            # ==============================================================================
            
            # 2. Escriptura a cada Base de Dades independent
            colleccio_privada.update_one({"_id": id_central}, {"$set": paquet_privat}, upsert=True)
            colleccio_publica.update_one({"_id": id_central}, {"$set": paquet_public}, upsert=True)
            colleccio_metadata.update_one({"_id": id_central}, {"$set": paquet_metadata}, upsert=True)
            
            logger_auditoria.info(f"MongoDB Segregat: Èxit en desar {id_central} a 3 BDs diferents.")
            return True

        except Exception as e:
            logger_auditoria.error(f"Error crític en persistència multi-db: {str(e)}")
            raise HTTPException(status_code=500, detail="Error intern de persistència compartimentada.")



def aplanar_dict(d: Dict[str, Any], parent_key: str = '', sep: str = '/') -> Dict[str, str]:
    """
    Transforma un diccionari niat en un diccionari pla on la clau és el path.
    Exemple: {'ferits': {'greus': 2}} -> {'ferits/greus': '2'}
    """
    items = {}
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.update(aplanar_dict(v, new_key, sep=sep))
        elif isinstance(v, list):
            for i, val in enumerate(v):
                items.update(aplanar_dict({str(i): val}, new_key, sep=sep))
        else:
            # Només indexem valors finals (strings, ints, bools) convertits a string
            items[new_key] = str(v)
    return items


def obtenir_identificador_bloc(dt: datetime) -> str:
    """Retorna una cadena tipus '2026-05-15-0' (matí) o '2026-05-15-1' (tarda)"""
    bloc = 0 if dt.hour < 12 else 1
    return f"{dt.strftime('%Y-%m-%d')}-{bloc}"

def cerca_coincidentes(
    id_abstracte_actual: str,
    dades_privades: dict,
    dia_hora: datetime,
) -> list:
    """
    Sistema de detecció de duplicats amb Finestra Temporal Dinàmica.
    Cerca en el bloc actual, el bloc anterior i el bloc posterior (Y, Y-1, Y+1).
    """
    comptador_vots = {}
    
    try:
        # 1. Determinar els 3 blocs de cerca per cobrir la finestra temporal
        noms_blocs = [
            obtenir_identificador_bloc(dia_hora - datetime(hours=12)),
            obtenir_identificador_bloc(dia_hora),
            obtenir_identificador_bloc(dia_hora + datetime(hours=12))
        ]

        # 2. Obtenim la vista aplanada de les dades actuals
        dict_aplanat = aplanar_dict(dades_privades)
        registres_per_indexar = []
        
        Cerca = Query()

        for path, valor in dict_aplanat.items():
            # Neteja i normalització
            if valor is None or valor == "": continue
            
            if isinstance(valor, (int, float, bool)):
                valor_net = str(valor).lower()
            else:
                valor_net = str(valor).strip().lower()
                if valor_net == "none": continue

            # Generem el hash compost (Path + Valor)
            id_dada = hashlib.sha256(f"{path}:{valor_net}".encode()).hexdigest()

            # --- CERCA MULTI-BLOC ---
            # Busquem la dada en les taules dels 3 blocs temporals
            for nom_bloc in noms_blocs:
                taula_bloc = db.table(f"cache_{nom_bloc}")
                resultats = taula_bloc.search(Cerca.id_dada == id_dada)

                for res in resultats:
                    id_existent = res['id_servidor']
                    if id_existent != id_abstracte_actual:
                        comptador_vots[id_existent] = comptador_vots.get(id_existent, 0) + 1

            # Preparem per a la persistència (només en el bloc actual)
            registres_per_indexar.append({
                "id_dada": id_dada,
                "id_servidor": id_abstracte_actual
            })

        # 3. FILTRATGE: Llindar de 2 vots
        coincidencies = [id_serv for id_serv, vots in comptador_vots.items() if vots >= 2]

        # 4. PERSISTÈNCIA: Guardem només al bloc que li toca per data
        if registres_per_indexar:
            bloc_desti = obtenir_identificador_bloc(dia_hora)
            taula_desti = db.table(f"cache_{bloc_desti}")
            taula_desti.insert_multiple(registres_per_indexar)

        return coincidencies

    except Exception as e:
        logger_auditoria.error(f"ERROR CRÍTIC MOTOR COINCIDÈNCIES TEMPORAL: {e}")
        return []


async def guardar_mapa_interconnexio(relacio: Dict[str, Any]):
    """
    Guarda la relació entre l'ID real i l'ID abstracte en una taula protegida.
    Això permet 'reconstruir el camí' en cas d'auditoria legal.
    """
    pany = obtenir_pany("anvaa_server_db")
    await pany.acquire()
    try:
        taula_mapa = db.table('mapa_interconnexio')
        # Evitem duplicats al mapa
        Mapa = Query()
        if not taula_mapa.search(Mapa.id_intern_servidor == relacio["id_intern_servidor"]):
            taula_mapa.insert(relacio)
        return True
    except Exception as e:
        logger_auditoria.error(f"Error al guardar mapa d'interconnexió: {e}")
        return False
    finally:
        pany.release()

def carregar_plantilla_disc():
    """Llegeix el fitxer JSON i el retorna com a diccionari."""
    try:
        if not os.path.exists("plantilla.json"):
            # Plantilla per defecte si el fitxer no existeix
            return {"versio": "0.0", "plantilla": {"camps": []}}
        
        with open("plantilla.json", "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        logger_auditoria.error(f"Error llegint plantilla: {e}")
        return None


def persistir_imatges_xifrades(blocs_a_processar: list) -> int:
    """
    Gestiona l'escriptura física al disc. 
    Aplica xifratge Fernet a cada binari abans de guardar-lo.
    Retorna el nombre de fitxers nous realment escrits.
    """
    comptador_nous = 0
    try:
        for bloc in blocs_a_processar:
            # Si el fitxer ja existeix (mateix incident i mateix contingut), no fem res
            if bloc["ja_existeix"]:
                continue

            # --- XIFRATGE DEL BINARI ---
            # El contingut original es xifra completament
            contingut_xifrat = cipher_suite.encrypt(bloc["contingut"])

            # Escriptura en mode binari 'wb'
            with open(bloc["ruta"], "wb") as f:
                f.write(contingut_xifrat)
            
            comptador_nous += 1
            
        return comptador_nous

    except Exception as e:
        logger_auditoria.error(f"FALLADA CRÍTICA ESCRIPTURA XIFRADA: {e}")
        # Propaguem l'error per fer un rollback lògic a l'endpoint
        raise e




# --- MODELS DE DADES (Què entra) ---

class RegistreTauleta(BaseModel):
    contrasenya: str
    model_dispositiu: str

class IDClient(BaseModel):
    tablet: str  
    incident: str

class IncidentDades(BaseModel):
    ids : IDClient  
    contingut_dinamic_privat: Dict[str, Any]  
    contingut_dinamic_public: Dict[str, Any]  
    datetime : str

class HashPar(BaseModel):
    privat: str
    public: str

class MetaImatges:
    def __init__(
        self,
        id_tablet: str = Form(...),
        id_incident: str = Form(...),
        hashes_imatges: str = Form(...) # Rebrem els hashes separats per comes
    ):
        self.id_tablet = id_tablet
        self.id_incident = id_incident
        # Convertim la cadena "hash1,hash2" en una llista real
        self.hashes = [h.strip() for h in hashes_imatges.split(",")]




# --- ENDPOINTS (Processament i Retorn) ---

# 1. DECLARACIÓ DE TAULETES
@app.post("/tauleta/declarar")
async def declarar_tauleta(
    registre: RegistreTauleta,
    request: Request, # Demanem la informació de la connexió
):  
    """
    ENTRA: Credencials i info de la tauleta.
    PROCESSA: 
    1. Valida credencials (simulat).
    2. Genera un UUID.
    3. Comprova unicitat al diccionari.
    4. Guarda en TinyDB i actualitza diccionari.
    5. Registra l'operació al Log d'Auditoria (RGPD).
    TORNA: L'ID únic que la tauleta guardarà per sempre.
    """
    # --- 5. LOG D'INTENT (Opcional, però recomanat per a màxima traçabilitat) --- 
    logger_auditoria.info(f"SOL·LICITUD: Intent de registre per a model {registre.model_dispositiu}")

    # --- 2. Validació de seguretat ---
    if registre.contrasenya != CONTRASEYA_INSCRIURE_TAULETA:
        # REGISTRE DE FALLADA: Molt important per detectar intrusions
        logger_auditoria.warning(
            f"ACCÉS DENEGAT: Contrasenya incorrecta. Model dispositiu: {registre.model_dispositiu} | IP: {request.client.host}"
            f"IP d'origen: (Es podria extreure de la request)"
        )
        raise HTTPException(
            status_code=401, 
            detail="1001-Credencials no vàlides per al registre del dispositiu"
        )

    try:
        # --- 3. Generació d'identitat única ---
        trobat = True
        intent_id = ""
        while trobat:
            intent_id = str(uuid.uuid4())
            if intent_id not in registre_ids_actius:
                trobat = False

        # --- 4. Persistència i Audit Log ---
        nova_tauleta = {
            "id_tauleta": intent_id,
            "model": registre.model_dispositiu,
            "data_registre": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        
        # Inserció xifrada a disc
        table_tauletes.insert(nova_tauleta)
        
        # Actualització de memòria ràpida
        registre_ids_actius[intent_id] = True 

        # LOG D'ÈXIT: Traçabilitat segons Art. 30 RGPD
        logger_auditoria.info(f"REGISTRE COMPLETAT: ID {intent_id} assignat correctament al model {registre.model_dispositiu}")

        return {
            "status": "declarada",
            "id_tauleta": intent_id,
            "ack": True,
            "missatge": "Registre completat i persistit correctament",
        }

    except Exception as e:
        # Si falla l'escriptura a disc o qualsevol procés intern
        logger_auditoria.error(f"ERROR INTERN: Fallada en el procés de registre de l'ID {intent_id}. Detall: {e}")
        raise HTTPException(status_code=500, detail="1002Error intern del servidor al guardar la declaració")




# --- ENDPOINT 2 ---
@app.post("/incident/sincro/data")
async def sincronitzar_incident(
    incident_in: IncidentDades, 
    hash_data: HashPar, 
    request: Request
):
    """
    ENTRA: Objecte IncidentDades (amb IDInstanciaIncident niat), hash SHA-256.
    PROCESSA:
    1. Valida l'existència de la tauleta (tablet) al registre actiu.
    2. Recalcula el hash del contingut dinàmic per seguretat.
    3. Construeix un ID compost per a la base de dades.
    4. Enllesar els mateixos incidents.
    5. Desa l'incident xifrat i registra l'acció.
    6. Registra l'operació al Log d'Auditoria (RGPD).
    TORNA: misatge de confirmacio.
    """
    
    # --- 1. LOG D'INTENT  (Pilar 6)  --- 
    logger_auditoria.info(f"SOL·LICITUD SINCRO: Tablet {incident_in.ids.tablet}")
    
    # --- 2. VALIDACIÓ DE SEGURETAT (Pilar 1) --- 
    if incident_in.ids.tablet not in registre_ids_actius:
        logger_auditoria.warning(f"ACCÉS DENEGAT: Tauleta {incident_in.ids.tablet} no autoritzada.")
        raise HTTPException(status_code=403, detail="2001-Dispositiu no registrat")

    # --- 3. VERIFICACIÓ D'INTEGRITAT (Pilar 2) --- 
    # Generem la seqüència de bytes sota la codificació canònica estricta de l'estàndard
    bytes_canonics_privat = canonicaljson.encode_canonical_json(incident_in.contingut_dinamic_privat)
    hash_verificacio_privat = hashlib.sha256(bytes_canonics_privat).hexdigest()
    
    bytes_canonics_public = canonicaljson.encode_canonical_json(incident_in.contingut_dinamic_public)
    hash_verificacio_public = hashlib.sha256(bytes_canonics_public).hexdigest()

    if hash_verificacio_privat != hash_data.privat or hash_verificacio_public != hash_data.public :
        logger_auditoria.error(f"HASH ERROR: Integritat trencada en tablet {incident_in.ids.tablet}")
        raise HTTPException(status_code=400, detail="2002-Error d'integritat de dades (Hash public Missmatch)")
        
    try:
            
        # --- 4. CONSTRUCCIÓ DE L'ID ABSTRACTE (Pilar 3) --- 
        id_bd_opac = generar_id_abstracte(
            incident_in.ids.tablet,
            incident_in.ids.incident
        )
    
        # --- 5. Comprovar Incidents amb Similituts (Interconnexió)(Pilar 4) --- 
        """ //TODO: esta en fase preliminar
        incidents_amb_coincidentes = cerca_coincidentes(
            id_bd_opac,
            incident_in.contingut_dinamic_privat,
            incident_in.datetime
        )
        """
        # --- 6. PREPARACIÓ I PERSISTÈNCIA (Pilar 5) ---
        
        # A. Guardem la relació d'IDs (Mapa d'Interconnexió)
        relacio_id_incident = {
            "id_intern_servidor": id_bd_opac,
            "metadades_ruta": {
                "origin_tablet": incident_in.ids.tablet,
                "origin_local_id": incident_in.ids.incident
            }
        }
        
        relacio_guardat = await guardar_mapa_interconnexio(relacio_id_incident)
        
        if relacio_guardat:
            logger_auditoria.info(f"SINCRO OK: Incident emmagatzemat amb ID (id del client): {incident_in.ids.incident}-{incident_in.ids.tablet}")
        else:
            logger_auditoria.error(f"SINCRO ERROR: Incident emmagatzemat amb ID (id del client): {incident_in.ids.incident}-{incident_in.ids.tablet}")
            raise HTTPException(status_code=500, detail="2004-Error en l'escriptura xifrada")


        # B. Preparem l'objecte incident per a la BD (Sense info intrínseca directa)
        incident_out = {
            "id_intern_servidor": id_bd_opac,
            "contingut_privat": incident_in.contingut_dinamic_privat,
            "contingut_public": incident_in.contingut_dinamic_public,
            "metadata": {
                "hashes": hash_data.dict(),
                "id_internts_conicidents": ""#incidents_amb_coincidentes  //TODO: esta en fase preliminar
            }
        }

        
        # C. Guardem l'incident a través de la funció de persistència
        exit_guardat = await persistir_a_la_bd(incident_out)# enviuar per a guardar tota la info en la base de dades
    
        if exit_guardat:
            logger_auditoria.info(f"SINCRO OK: Incident emmagatzemat amb ID Abstracte(id del servidor): {id_bd_opac[:10]}")
            return {
                "status": "sincronitzat",
                "id_referencia": incident_in.ids.incident, # La tablet podria guardar aquest ID de confirmació
                "ack": True,
                "missatge": "Dades rebudes i verificades",
            }
        else:
            logger_auditoria.error(f"HASH ERROR: Incident emmagatzemat amb ID Abstracte(id del servidor): {id_bd_opac[:10]}")
            raise HTTPException(status_code=500, detail="2003-Error en l'escriptura xifrada")

    except Exception as e:
        logger_auditoria.error(f"SINCRO CRITICAL ERROR: Fallada de BD en incident {incident_in.ids.incident}-{incident_in.ids.tablet}. Error: {e}")
        raise HTTPException(status_code=500, detail="2005-Error de persistència al servidor")




# 3. SINCRONITZACIÓ D'IMATGES
@app.post("/incident/sincro/imatges/multiple")
async def pujar_multiple_imatges(
    meta: MetaImatges = Depends(), # Agrupem id_tablet, id_incident_local, etc.
    fitxers: List[UploadFile] = File(...) # Aquí acceptem la llista de fitxers
):
    """
    ENTRA: ID compost, hash de la imatge i el fitxer binari.
    PROCESSA: 
        1. Recalcula el hash per valida que les imatges estan be.
        2. Valida el ID del Client per saber si la tauleta existeix.
        3. Valida el format (jpg/png).
        4. Desa el fitxer en el volum persistent.
        5. Registra l'operació al Log d'Auditoria (RGPD).
    TORNA: Confirmació de desament.
    """
    # --- 1. LOG D'INTENT  (Pilar 6)  --- 
    logger_auditoria.info(f"SOL·LICITUD SINCRO Imatges: Tablet {meta.id_tablet}")
    
    # --- 2. VALIDACIÓ DE SEGURETAT (Pilar 1) --- 
    if meta.id_tablet not in registre_ids_actius:
        logger_auditoria.warning(f"ACCÉS DENEGAT: Tauleta {meta.id_tablet} no autoritzada.")
        raise HTTPException(status_code=403, detail="3001-Dispositiu no registrat")

    # --- 2. RECUPERACIÓ DE L'ID OPAC REAL DES DE LA DB ---
    # En lloc de calcular-lo, verifiquem que l'incident realment existeix
    try:
        taula_mapa = db.table('mapa_interconnexio')
        Mapa = Query()
        # Busquem l'incident que coincideixi amb la tablet i l'id local del client
        registre = taula_mapa.get(
            (Mapa.metadades_ruta.origin_tablet == meta.id_tablet) & 
            (Mapa.metadades_ruta.origin_local_id == meta.id_incident)
        )
        
        if not registre:
            logger_auditoria.error(f"VINCLE FALLIT: L'incident {meta.id_incident_local} no ha estat sincronitzat prèviament.")
            raise HTTPException(status_code=404, detail="3002-Incident base no trobat. Sincronitzi les dades primer.")
        
        id_bd_opac = registre["id_intern_servidor"]
        
    except Exception as e:
        logger_auditoria.error(f"ERROR CONSULTA MAPA: {e}")
        raise HTTPException(status_code=500, detail="3003-Error de base de dades en verificar vincle.")


    # --- 1. VALIDACIÓ DE QUANTITAT ---
    if len(fitxers) != len(meta.hashes):
        raise HTTPException(status_code=400, detail="3004-El nombre de fitxers i de hashes no coincideix.")

    # --- 4. PROCESSAMENT ATÒMIC EN MEMÒRIA ---
    # Guardarem els continguts en una llista temporal. Si un falla, tot s'atura.
    blocs_binaris_validats = []
    
    try:
        for i, fitxer in enumerate(fitxers):
            # A. Verificació de format
            if fitxer.content_type not in ["image/jpeg", "image/png"]:
                raise HTTPException(status_code=400, detail=f"3005-Format no permès en fitxer {i}")

            # B. Lectura i verificació de Hash
            contingut = await fitxer.read()
            hash_recalculat = hashlib.sha256(contingut).hexdigest()
            
            if hash_recalculat != meta.hashes[i]:
                logger_auditoria.error(f"INTEGRITAT TRENCADA: Hash mismatch al fitxer {i}")
                raise HTTPException(status_code=400, detail=f"3006-Error d'integritat en la foto {i}")

            # C. Comprovació de duplicats (Opcional: No guardar si ja existeix el fitxer)
            nom_fitxer = f"{id_bd_opac}_{hash_recalculat}.jpg"
            ruta = os.path.join("./Imatges", nom_fitxer)
            
            # Si el fitxer ja existeix, podem saltar-lo o marcar-lo com a "ja guardat"
            ja_existeix = os.path.exists(ruta)
            
            blocs_binaris_validats.append({
                "contingut": contingut,
                "ruta": ruta,
                "ja_existeix": ja_existeix,
                "hash": hash_recalculat
            })

        # --- 5. PERSISTÈNCIA FINAL (Només si tot el bucle anterior ha tingut èxit) ---
        nous_escrits = persistir_imatges_xifrades(blocs_binaris_validats)

            
        # --- 6. REGISTRE D'ÈXIT ---
        logger_auditoria.info(f"SINCRO IMATGES FINALITZADA: Incident {id_bd_opac[:10]}. Nous: {nous_escrits}. Totals: {len(fitxers)}")

        return {
            "status": "sincronitzat",
            "id_servidor": id_bd_opac,
            "ack": True,
            "detall": {
                "totals": len(fitxers),
                "nous_registrats": nous_escrits,
                "ja_existents": (len(fitxers) - nous_escrits),
            },
            "missatge": "Sincronització binària completada correctament"
        }

    except HTTPException as he:
        # Re-llancem les nostres pròpies excepcions controlades
        raise he
    except Exception as e:
        logger_auditoria.error(f"FALLADA CRÍTICA EN ESCRIURE IMATGES: {e}")
        raise HTTPException(status_code=500, detail="3007-Error en l'escriptura física dels fitxers.")
    finally:
        # Molt important: tancar tots els UploadFiles per alliberar memòria RAM
        for f in fitxers:
            await f.close()




# 4. GESTIÓ DE PLANTILLES (CONFIGURACIÓ)
@app.get("/plantilles/versio")
async def versio_plantilla(
    ids : IDClient
):
    """
    ENTRA: Res (petició GET).
    PROCESSA: Busca la darrera versió del qüestionari dinàmic.
    TORNA: La versio de la ultima plantilla JSON que l'App de Flutter ha de dibuixar.
    """
    
    # --- 1. LOG D'INTENT  (Pilar 6)  --- 
    logger_auditoria.info(f"SOL·LICITUD Versio Plantilla: Tablet {ids.tablet}")
    
    # --- 2. VALIDACIÓ DE SEGURETAT (Pilar 1) --- 
    if ids.tablet not in registre_ids_actius:
        logger_auditoria.warning(f"ACCÉS DENEGAT: Tauleta {ids.tablet} no autoritzada.")
        raise HTTPException(status_code=403, detail="4001-Dispositiu no registrat")
    
    dades = carregar_plantilla_disc()
    if dades:
        logger_auditoria.info("PLANTILLA Info: Una tauleta ha preguntat la versio de la darrera versio.")
        return {"versio": dades.get("versio", "0.0")}
    logger_auditoria.error("PLANTILLA Error: Una tauleta ha intentat preguntar la versio de la darrera versio.")
    raise HTTPException(status_code=500, detail="4002-No s'ha pogut llegir la versió")




@app.get("/plantilles/actualitzar")
async def obtenir_plantilla(
    ids : IDClient
):
    """
    ENTRA: Res (petició GET).
    PROCESSA: Busca la darrera versió del qüestionari dinàmic.
    TORNA: El JSON de la plantilla que l'App de Flutter ha de dibuixar.
    """
    
    # --- 1. LOG D'INTENT  (Pilar 6)  --- 
    logger_auditoria.info(f"SOL·LICITUD Plantilla: Tablet {ids.tablet}")
    
    # --- 2. VALIDACIÓ DE SEGURETAT (Pilar 1) --- 
    if ids.tablet not in registre_ids_actius:
        logger_auditoria.warning(f"ACCÉS DENEGAT: Tauleta {ids.tablet} no autoritzada.")
        raise HTTPException(status_code=403, detail="4051-Dispositiu no registrat")
    
    
    dades = carregar_plantilla_disc()
    if dades:
        # Registrem l'accés per auditoria (Saber qui s'està actualitzant)
        logger_auditoria.info("PLANTILLA Info: Una tauleta ha descarregat la darrera configuració.")
        return dades
    logger_auditoria.error("PLANTILLA Error: Una tauleta ha intentat descarregat la darrera configuració.")
    raise HTTPException(status_code=500, detail="4052-Error en el lliurament de la plantilla")



########################################################################################################################



# 1. Diccionari centralitzat on guardarem els panys indexats per etiqueta
PANYS_DE_SISTEMA: Dict[str, asyncio.Lock] = {}

def obtenir_pany(etiqueta: str) -> asyncio.Lock:
    """
    Retorna el pany específic per a una etiqueta/fitxer.
    Si no existeix, el crea i el guarda per a futures peticions.
    """
    if etiqueta not in PANYS_DE_SISTEMA:
        PANYS_DE_SISTEMA[etiqueta] = asyncio.Lock()
    return PANYS_DE_SISTEMA[etiqueta]

async def persitir(dades_preparades: Dict[str, Any], taula_nom: str = "incidents"):
    pany = obtenir_pany("anvaa_server_db")
    
    await pany.acquire()  # <-- OBRIM EL PANY MANUALMENT
    try:
        taula = db.table(taula_nom)
        taula.insert(dades_preparades)
        return True
    finally:
        pany.release()    # <-- TANQUEM EL PANY MANUALMENT (Sempre s'executa)
