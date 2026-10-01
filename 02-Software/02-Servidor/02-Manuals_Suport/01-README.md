# 🚀 Manual d'Operació del Servidor (Entorn de Producció/Proves)

Aquest document detalla la configuració, desplegament, seguretat i manteniment de la infraestructura del servidor (Proxy Invers Nginx, API Backend Python i Clúster NoSQL MongoDB) utilitzant l'ecosistema de contenidors **Podman**.

## 1. Funcionament del Servidor i Arquitectura

L'arquitectura del servidor està dissenyada sota un esquema multicontenidor aïllat per garantir la seguretat de les dades, la integritat dels dades rebudes i un registre auditable de totes les accions. El sistema es divideix en tres components principals:

1. **Proxy Invers (Nginx):** Actua com a porta d'entrada única del sistema (_Frontal_). S'encarrega de la terminació SSL/TLS, interceptant totes les peticions HTTPS externes pel port segur i derivant-les internament mitjançant HTTP net cap al contenidor del Backend. Això aïlla completament la lògica de negoci de l'exposició directa a la xarxa.
    
2. **Backend (Python / FastAPI):** Gestiona la lògica de negoci, executa les operacions criptogràfiques de validació d'integritat (_Canonical JSON_ i verificació de _Hashes_ SHA256), processa l'alta i control de les tauletes del personal d'emergències, gestiona les llistes de control d'accés (ACL) i interacciona amb el motor de persistència de dades NoSQL.
    
3. **Base de Dades (MongoDB):** Emmagatzema de forma altament estructurada i eficient els formularis de resposta, l'històric d'incidents, els registres de control de les tauletes i l'auditoria del sistema.
    

**Comandes d'Operació Ràpida (Terminal de l'Administrador):**

- **Arrencada de l'entorn:** `podman-compose up -d`
    
    _(Aixeca la xarxa virtual i arrenca els serveis en segon pla sense blocar la consola)_
    
- **Aturada i Neteja de l'entorn:** `podman-compose down`
    
    _(Atura els contenidors i destrueix l'entorn virtual de memòria netejant la pila, sense danyar els volums persistents del disc)_
    
- **Veure logs del sistema en temps real:** `podman-compose logs -f`
    
    _(Mostra de manera unificada el trànsit de Nginx, el codi de sortida del backend i les connexions de Mongo)_
    
- **Entrar al contenidor del backend:** `podman exec -it backend_app /bin/bash`
    
    _(Obre un intèrpret de comandes interactiu directament dins de l'entorn virtual del servidor Python)_
    

### 🔐 1.1. Gestió del Proxy Invers (Nginx)

El proxy invers és l'únic servei exposat a l'exterior de la màquina i garanteix que tota la comunicació estigui protegida contra atacs de tipus _Man-in-the-Middle_.

#### Manteniment i Regeneració de Certificats TLS/SSL:

Al tractar-se d'una prova de concepte (PoC) o entorn de proves, s'utilitzen certificats auto-signats. Si aquests certificats han caducat o necessites reconfigurar l'adreça de domini de la màquina remota, desplaça't a la carpeta del host `./proxy/certs` i executa de manera estricta la següent seqüència de comandes:

Bash

```
# 1. Generar una nova clau privada RSA de 2048 bits
openssl genrsa -out server.key 2048

# 2. Generar el certificat d'estructura x509 vàlid per a un any de proves (365 dies)
openssl req -new -x509 -key server.key -out server.crt -days 365
```

⚠️ **IMPORTANT (Seguretat de fitxers):** Un cop generats els fitxers, és absolutament obligatori restringir-ne els permisos de lectura en el host mitjançant la comanda `chmod 600 server.key`. Això impedeix que altres usuaris locals sense privilegis puguin extreure la clau privada.

Perquè el contenidor Nginx apliqui els nous certificats de seguretat generats, no és necessari aturar tot el servidor; n'hi ha prou amb reiniciar exclusivament el seu propi mòdul:

Bash

```
podman-compose restart proxy_https
```

### 📡 1.2. Interacció amb l'API del Servidor i Lògica Interna

El backend en Python implementa una arquitectura basada en FastAPI que exposa una sèrie d'endpoints dissenyats específicament pel cicle de vida de les dades d'emergències.

#### Endpoints Principals:

- **POST `/tauleta/declarar`** Aquest és el pas inicial i obligatori per a qualsevol dispositiu físic o simulador que es vulgui comunicar amb la xarxa. La tauleta transmet les seves credencials bàsiques (com la contrasenya d'homologació) i el seu model de maquinari. El servidor valida la petició i, si és correcta, genera de forma dinàmica un **ID únic de dispositiu (UUID4)** que retorna a la tauleta juntament amb un missatge d'èxit persistit. Aquest identificador actua com una clau d'auditoria unívoca: a partir d'aquest moment, la tauleta haurà d'adjuntar de forma obligatòria aquest ID en qualsevol petició d'enviament de dades.
    
- **POST `/incident/sincro/data`** Endpoint crític per a la recepció sincronitzada d'incidents. El servidor està programat per rebre una estructura JSON dividida estrictament en dues grans àrees: el cos de les dades de l'incident (subdividit en contingut privat sota directiva RGPD i contingut públic operacional) i una secció de verificació anomenada `hash_data`. El servidor avalua l'incident en text pla o format _canonicaljson_ i comprova els hashes SHA256 calculats. Si el resultat calculat en calent pel backend no coincideix al 100% amb el hash subministrat per la tauleta a la petició, el sistema bloca immediatament la persistència i retorna un error de seguretat, evitant així la injecció de formularis manipulats o corruptes.
    

> 📝 _Nota de Testing:_ Actualment, altres endpoints auxiliars exposats al codi de l'API o mètodes de consulta directa no estan validats per a l'ús en producció o es troben en fase de desenvolupament modular. Es recomana centrar les proves exclusivament en la parella d'endpoints esmentada.

#### Sistema de Traçabilitat i Logs d'Auditoria:

El backend disposa de dos fitxers de registre diferents de manera simultània per separar la traçabilitat del sistema de les auditories de seguretat:

1. **Log d'Auditoria de Seguretat (`logger_auditoria`):** Enregistra exclusivament els canvis en el cicle de vida de les dades sensibles, per exemple, quan una tauleta sol·licita l'alta, quan es descarrega una plantilla de qüestionari o quan es detecta un accés fallit de sincronització.
    
2. **Log d'Error i Sistema Estàndard:** Desa les traces clàssiques d'excepcions de programari, pèrdues temporals de connexió amb MongoDB o problemes sintàctics en rebre payloads JSON malformats.
    

#### Configuració del Control de Persistència (`main.py`, Línies 83-93)

Dins de l'arxiu central del servidor (`main.py`), localitzat específicament entre les línies **83 i 93**, es troba implementat el bloc selector del motor de persistència de dades que utilitzarà l'aplicació. El comportament del servidor canvia de forma radical depenent de quina d'aquestes dues opcions estigui activa a nivell de línia de codi:

Python

```
# OPCIÓ A: Mode SENSE XIFRAT (Estàndard en clar JSON)
# [Aquest bloc inicialitza l'emmagatzematge genèric on les dades són llegibles de manera directa pel administrador]

# OPCIÓ B: Mode AMB XIFRAT (Producció)
# [Aquest bloc inicialitza la persistència utilitzant l'EncryptedStorage combinat amb el xifratge simètric Fernet]
```

⚠️ **AVÍS CRÍTIC DE L'ARQUITECTURA DE DADES:** Canviar d'opció mitjançant comentaris (`#`) i descomentaris de codi **no desxifra automàticament les dades ja existents a la base de dades ni al disc**. Cada opció apunta a connectors i fitxers de configuració totalment independents. Si el sistema s'engega en Mode B (Amb Xifrat), llegirà i escriurà sobre el magatzem xifrat; si es canvia al Mode A (Sense Xifrat), el sistema passarà a operar amb un entorn completament net en clar, ignorant l'existència de la informació prèvia xifrada. L'administrador ha de triar la modalitat abans de començar la recollida de formularis de camp.

### 🗄️ 1.3. Base de Dades NoSQL (MongoDB)

El repositori permanent d'informació s'executa aïllat de l'exterior de la màquina mitjançant la configuració de la `xarxa_interna` del fitxer de composició de Podman.

- **Estratègia de Persistència i Aïllament:** Les dades físiques de MongoDB es mantenen al disc dur de la màquina amfitriona mitjançant el mapatge de volums: `- ./mongoDB:/data/db:Z`. L'ús del modificador o _flag_ **`:Z` (Majúscula)** és absolutament indispensable en sistemes operatius moderns corporatius que tenen activat el mòdul de seguretat **SELinux** (com Red Hat Enterprise Linux, Fedora o CentOS). Aquesta flag instrueix a Podman perquè re-etiqueti el context de seguretat de la carpeta local, evitant que el servei de MongoDB sigui blocat pel nucli de Linux a l'intentar escriure dades.
    
- **Mètode de Comprovació de Salut:** Si el servidor no manté els formularis desats després d'un reinici complet, el mètode de diagnòstic consisteix a verificar que la carpeta local `./mongoDB` té permisos d'escriptura per a l'ID d'usuari (UID) no privilegiat que està executant el servei de Podman en la sessió de l'usuari (_Rootless Podman_).
    

## 🧪 2. Guia de Testing del Flux del Sistema

Abans d'executar qualsevol tipus de prova, l'operador s'ha d'assegurar d'haver realitzat de forma manual les següents verificacions del sistema:

1. Validar que la pila de serveis està completament operativa executant la comanda `podman ps`. S'ha de verificar que el proxy, el backend i mongo mostren l'estat `Up`.
    
2. Confirmar que la contrasenya d'homologació de seguretat definida a la petició de testing és idèntica a la configurada a les constants de seguretat del servidor.
    
3. Configurar les eines cliente per utilitzar sempre la flag `-k` o `--insecure`, la qual cosa indica a les utilitats de xarxa que han de passar per alt el fet que el certificat HTTPS utilitzat és auto-signat (sense entitat certificadora oficial de confiança).
    

### 📑 2.1. Procediment de Testing Manual

Per avaluar i auditar el comportament del servidor sense l'ús d'entorns de desenvolupament (IDEs) o interfícies gràfiques de tercers, s'ha de seguir de manera seqüencial el recorregut d'operacions definit al document **`TestingManualRecorregutSimplificat.txt`**.

Aquest procediment requereix l'obertura d'una consola nativa de comandos del sistema operatiu (Bash/Zsh) i consisteix en la introducció ordenada de comandes utilitzant l'eina de transferència `curl`. L'operador ha d'enviar primer la petició en brut de declaració de la tauleta, capturar la cadena JSON de resposta proporcionada pel servidor per extraure manualment l'identificador dinàmic generat (`id_tauleta`) i, posteriorment, utilitzar aquest identificador per construir la segona comanda `curl` d'enviament de l'incident a la ruta `/incident/sincro/data`.

### ⚙️ 2.2. Procediment de Testing Automàtic (`test_ok.sh`)

Per a proves de regressió ràpides en entorns on es fan modificacions de codi contínues, disposem de l'script d'automatització **`test_ok.sh`**. Aquest fitxer encapsula tota la complexitat criptogràfica del protocol en una única execució:

Bash

```
bash test_ok.sh
```

#### Mecanisme de Funcionament Intern del Script:

1. **Fase d'Alta Automàtica:** Executa de forma directa una petició `curl` cap al proxy invers sol·licitant la declaració. Filtra en calent la resposta JSON del backend i utilitza el comando de transformació de cadenes `tr -d '"'` per aïllar i guardar l'identificador dinàmic generat dins d'una variable local de memòria de la consola anomenada `$ID_TAULETA`.
    
2. **Normalització de Dades Operacionals:** Defineix les estructures JSON que simulen les dades de camp (com `PRIVAT_JSON` i `PUBLIC_JSON`) en un format completament compactat, és a dir, **sense espais en blanc ni salts de línia entremig**. Això és vital perquè la representació dels caràcters sigui unívoca.
    
3. **Càlcul Criptogràfic en Calent:** Utilitza una canonada d'execució combinant la comanda del sistema Linux `sha256sum` juntament amb el processador de text per columnes `awk '{print $1}'` per calcular a l'acte el Hash SHA256 exacte de cada bloc de dades.
    
4. **Injecció de Payload Compilat:** Construeix una darrera petició `curl` que injecta de forma directa l'identificador, els JSON dels formularis i els hashes calculats dins del cos del payload cap a l'endpoint de sincronització, mostrant per pantalla el codi de confirmació de persistència final.
    

## 🛠️ 3. Resolució de Problemes Comuns (Troubleshooting)

- **Saturació i Espai en Disc Exhaurit (Errors de Build):** Quan es fan múltiples compilacions consecutives de les imatges del servidor (utilitzant paràmetres com `--no-cache`), Podman emmagatzema de forma persistent totes les capes intermèdies i imatges antigues en forma d'imatges orfes (_dangling images_). Això pot omplir ràpidament el disc del host de gigabytes inútils i bloquejar el muntatge dels contenidors. La solució consisteix a forçar una purga profunda del sistema de contenidors mitjançant:
    
    Bash
    
    ```
    podman system prune -a
    ```
    
    _Nota de seguretat:_ Pots executar aquesta comanda amb total tranquil·litat, ja que les teves dades permanent d'incidents estan salvades a la carpeta física del host `./mongoDB` i les comandes de neteja de Podman mai esborraran directoris muntats explícitament de la teva màquina amfitriona.
    
- **Manca de Persistència entre Reinicis:** Si en aixecar el servei es detecta que la base de dades s'ha buidat, s'ha de comprovar de manera estricta que les rutes del fitxer `podman-compose.yml` mantenen el mapeig correcte i que l'usuari del host no ha canviat els permisos de lectura i escriptura del directori local `./mongoDB`.
    
- **Errors de Certificat SSL Bloquejats (Falta de Flag):** Si les comandes de validació o els scripts automatitzats de testing es queden bloquejats o retornen codis d'error associats a la cadena de confiança de la capa de transport, verifica que no t'has oblidat d'afegir el paràmetre `-k` a la línia de comandes de `curl`. En el moment que el sistema es moga cap a un entorn final corporatiu amb certificats de seguretat verificats per una autoritat de certificació (CA), **aquest paràmetre `-k` s'haurà d'eliminar de forma obligatòria** de tots els punts per fer efectiva la validació estricta de la cadena de seguretat.
    
- **Errors de Credencials Fallides en Testing:** Si el servidor respon sistemàticament amb codis de denegació de petició durant l'execució del testing automàtic o manual, revisa que la contrasenya subministrada al JSON del client coincideix lletra per lletra amb la constant emmagatzemada a l'arxiu lògic del backend.
    
- **Conflictes d'Accés al Port Reial de Seguretat (Port 443):** Dins dels sistemes operatius basats en Linux, tots els ports de xarxa inferiors al port 1024 estan considerats de caràcter privilegiat. Això significa que cap aplicació o contenidor que s'estigui executant sota un usuari estàndard sense privilegis (_Rootless Mode_) pot obrir o escoltar directament a través del port 443 del host. Per esquivar aquest bloqueig de seguretat sense haver de córrer el risc d'executar Podman com a usuari `root`, el fitxer de configuració del proxy s'ha mapejat cap al port alternatiu accessible **8443**.
    
    Si el requeriment de desplegament de la teva xarxa de servidors exigeix de manera estricta que el sistema rebi i escolte el trànsit directament a través del port estàndard **443** de la targeta de xarxa externa, s'ha de configurar una regla de redirecció a nivell de nucli (_kernel_) directament sobre la taula de traducció d'adreces de la màquina host, executant la següent sentència amb drets d'administrador del sistema:
    
    Bash
    
    ```
    sudo iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443
    ```
    

## 4. Consells a Futur per a la Robustesa de l'Entorn

### 🛡️ Migració de Seguretat i Configuració d'Entorn Estricta (`.env`)

Actualment, al tractar-se d'una prova de concepte de programari, el codi de configuració central del servidor conté cadenes de text i claus criptogràfiques escrites de forma fixa i directa (_hardcoded_) dins del fitxer font `main.py` (tals com `CLAU_SECRET_FERNET` o `ENCRYPTION_KEY`). **Aquesta pràctica suposa un risc crític de seguretat en l'enginyeria del programari**, ja que qualsevol usuari amb dret de lectura sobre el repositori de codi podria comprometre el xifratge de les dades.

Per evolucionar cap a un model segur de producció basat en el principi de seguretat per disseny, s'ha d'implementar el següent procediment d'aïllament:

1. **Creació del Fitxer Ocult d'Entorn:** A l'arrel de la carpeta del servidor, crea un fitxer de text l'extensió del qual es diu literalment **`.env`** (sense cap nom al davant de la inicial del punt).
    
2. **Definició de Variables de Propietat Sensible:** Obre el fitxer `.env` i declara els paràmetres de configuració que vols extreure del codi font utilitzant el següent format d'assignació d'estat:
    
    Fragmento de código
    
    ```
    MONGO_USER=usuari_admin
    MONGO_PASS=la_teva_contrasenya_segura_de_la_poc
    CLAU_SECRET_FERNET=Fq5d6EFoZ-iAhFpmnqOS530rG7y5LiLXZ7-cJUduc3E=
    ```
    
1. **Mecanisme d'Aïllament en el Control de Versions:** Afegeix immediatament de forma obligatòria la línia `.env` dins del fitxer d'exclusions de Git anomenat **`.gitignore`**. Això garanteix que les credencials reals romandran exclusivament emmagatzemades a la màquina local del servidor i que cap programador podrà pujar de forma accidental claus secretes a repositoris públics de Git, assolint així la conformitat amb els estàndards actuals de disseny de programari segur.
