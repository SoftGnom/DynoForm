# Especificació Tecnològica del Sistema

Aquest document detalla l'ecosistema tecnològic escollit per garantir l'operativitat en entorns hostils, la flexibilitat del motor de dades i el compliment estricte de la normativa de protecció de dades (RGPD).

## 1. Arquitectura del Client (App Tablet)

L'objectiu principal de l'aplicació és l'**operativitat total en mode offline** i una interfície reactiva que minimitzi la càrrega cognitiva del usuari.

- **Framework:** **Flutter (Dart)**. Escollit per la seva capacitat de generar interfícies natius d'alt rendiment amb un sol codi, garantint consistència visual en qualsevol model de tauleta Android.
    
- **Base de Dades Local (Offline-First):** **Sembast**.
    
    - **Tipus:** NoSQL basada en documents (similar a MongoDB).
        
    - **Seguretat:** Implementació de xifratge **AES-256** per protegir les dades en repòs de forma independant a Sembast.
        
    - **Justificació:** És la millor opció per gestionar el motor dinàmic, ja que emmagatzema els incidents com a objectes JSON flexibles sense necessitat d'esquemes rígids.
    

---

## 2. Arquitectura del Backend i Sincronització

Dissenyat per ser un sistema lleuger, modular i d'alta seguretat per a la gestió de dades sensibles.

- **Llenguatge i Framework:** **Python (FastAPI)**. Permet una gestió asíncrona de les peticions i una integració nativa amb les estructures JSON que envien les tauletes.
    
- **Contenidors:** **Podman (Rootless)**. S'utilitza per a l'execució del backend, aportant una capa de seguretat superior a Docker en no requerir privilegis d'administrador (`root`) per a l'execució de contenidors que gestionen dades de salut.
    
- **Estratègia d'Emmagatzematge:** **Flat Files (JSON) i TinyDB(Si xifratge)**.
    
    - **Estructura per Blocs:** Les dades s'organitzen en fitxers diaris (`bloc_YYYY_MM_DD.json`).
        
    - **Optimització de Cerca:** Un script de Python manté en memòria el bloc del dia actual i l'anterior per realitzar cerques de similituds i detecció de duplicats de forma instantània.
        

---

## 3. Motor de Plantilles i Dinamisme

El sistema separa totalment la lògica de programació de la lògica operativa.

- **Formats de Configuració:** YAML / JSON.
    
- **Estructura de Sincronització:**
    
    - `master.json`: Índex global que vincula tipus d'incident amb els mòduls corresponents.
        
    - `moduls/*.json`: Definició de camps, lògica de salts (skip logic), validacions i rangs d'autoritat.
        
- **Flux d'Actualització:** Les tauletes verifiquen la versió de la plantilla en detectar connexió (HTTPS) i actualitzen el qüestionari sense necessitat de reinstal·lar l'aplicació.
    

---

## 4. Anàlisi Comparativa i Decisió de BD Local

Per decidir l'emmagatzematge a la tauleta, s'han analitzat les dues opcions principals de l'ecosistema Flutter:

|**Característica**|**Sembast (Escollida)**|**Hive (Descartada)**|
|---|---|---|
|**Model de dades**|NoSQL (Documents JSON)|Key-Value (Binari)|
|**Compatibilitat**|Alta (parla el mateix idioma que el motor)|Baixa (requereix classes fixes)|
|**Cerca Interna**|**Nativa i complexa** (filtra dins del JSON)|Limitada (cal carregar tot a RAM)|
|**Xifratge**|AES-256 (via codi)|Integrat (nadiu)|
|**Flexibilitat**|Total davant canvis de protocol|Rígida (requereix `TypeAdapters`)|

### Veredicte Final: Per què Sembast?

Tot i que **Hive** és teòricament més ràpida en escriptura bruta, la seva rigidesa la fa **incompatible amb el motor dinàmic** del projecte. Hive obligaria a definir classes fixes (`TypeAdapters`) per cada camp, per a tenir un rendiment molt bo (amb menys de 100 instancies podria anar be), cosa que trenca la capacitat d'actualitzar els qüestionaris des del servidor sense tocar el codi de l'App.

**Sembast** permet guardar JSON fen-ho compatible amb el motor dinàmic.

---

## 5. Seguretat i Compliment Legal (RGPD)

Per garantir la integritat i la confidencialitat de la informació en un entorn d'emergències:

1. **Traçabilitat:** Cada accés, consulta o modificació en els fitxers del servidor genera un **log d'auditoria** immutable en un volum separat.
    
2. **Xifratge en Trànsit:** Totes les comunicacions es realitzen mitjançant **HTTPS amb certificats SSL/TLS**.
    
3. **Xifratge en Repòs:** Protecció obligatòria AES-256 a la tauleta i xifratge de sistema de fitxers al servidor de destinació.
    
4. **Minimització:** L'ús de Podman Rootless minimitza la superfície d'atac en cas d'intent d'exfiltració de dades des del servidor.
    

---
## Z. Mes


utilitzar Keystore/Keychain si es pot per a guardar la contraenya
