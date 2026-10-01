## 1. Objectius Generals

### O - 1. Vessant d'Operativitat i Usuari

1. **Optimitzar la recollida de dades a peu de camp**:
    
    Dissenyar i desenvolupar una interfície d'usuari mòbil per a tauletes que permeti registrar la totalitat de la informació requerida d'una **actuació** en un temps inferior a 10 minuts, validant-ne l'eficiència mitjançant proves d'usabilitat amb usuaris finals.
    
      
    
2. **Garantir la resiliència del sistema**:
    
    Implementar un mecanisme de persistència local i sincronització asíncrona (automatitzada o sota demanda) que asseguri la integritat del 100% de les dades introduïdes durant períodes de desconnexió de la xarxa, garantint la no-pèrdua d'informació en restablir-se l'enllaç mitjançant assajos automatitzats de tall de comunicacions.
    
      
    
3. **Automatitzar la intel·ligència de dades**:
    
    Desenvolupar un motor de formularis capaç d'adaptar el qüestionari en temps real (mostrant o ocultant camps dinàmicament) segons la tipologia i l'evolució de l'**actuació** a partir de les interaccions de l'**operador de camp**. El sistema ha de permetre modificacions estructurals en la lògica dels formularis mitjançant fitxers de configuració interpretats en temps d'execució, evitant explícitament la necessitat de recopilar o redistribuir l'aplicació client davant de canvis en les plantilles operatives.
    
      
    

### O - 2. Vessant d'Arquitectura de Dades (Nucli del Backend)

1. **Desenvolupar un model d'emmagatzematge altament resilient**:
    
    Dissenyar una arquitectura de base de dades no relacional (NoSQL/JSON) capaç d'absorbir modificacions estructurals en els formularis de recollida de dades, garantint la compatibilitat amb versions anteriors (_backward compatibility_) i un temps d'inactivitat (_downtime_) de zero segons en el servidor durant les actualitzacions d'esquema.
    
      
    
2. **Garantir l'eficiència de les dades per a una explotació analítica eficaç**:
    
    Desenvolupar un model d'indexació i agregació de dades capaç de respondre a consultes estadístiques i mètriques complexes en un temps inferior a 3 segons, validat sobre un volum de prova de 40.000 registres històrics simulats.
    
      
    

### O - 3. Vessant Legal i de Seguretat (Integrada per Disseny)

1. **Implementar la Privadesa des del Disseny (_Privacy by Design_)**:
    
    Dissenyar el flux de dades de manera que el 100% de les dades de caràcter personal (com matrícules o DNIs) quedin pseudonimitzades o dissociades en les taules d'analítica, assegurant que la informació explotada estadísticament no contingui vectors directes d'identificació de ciutadans, seguint el Reglament General de Protecció de Dades (RGPD).
    
      
    
2. **Garantir la seguretat i integritat de la informació**:
    
    Assegurar que les dades emmagatzemades localment a la tauleta i les dades en trànsit cap al servidor siguin immunes a atacs d'intercepció o extraccions no autoritzades. Es validarà mitjançant la implementació d'algoritmes de xifratge estàndard (AES-256 en repòs i TLS 1.3 en trànsit) i la verificació mitjançant auditories de codi i anàlisi de trànsit de xarxa.
    
      
    
3. **Complir amb el deure d'informació**:
    
    Desenvolupar un mòdul automatitzat dins l'aplicació que permeti complir de manera transparent amb el deure d'informació als ciutadans afectats en el mateix **lloc d'actuació**, mitjançant la generació immediata d'una marca identificativa d'accés (com un codi QR) a les clàusules legals i drets de l'RGPD, i que implementi una finestra emergent (_pop-up_) de confirmació obligatòria en el 100% dels camps predictius simples perquè l'usuari en validi l'exactitud de forma expressa.
    
      
    

## 2. Estructura dels Mòduls del Sistema

Atesa la complexitat de la solució i el calendari d'execució ajustat, els requisits s'han organitzat en els mòduls o seccions següents. Aquesta classificació permet una gestió més eficient del projecte i facilita la priorització de les funcionalitats clau.

  

### 2.1. Mòduls del Client (App Tablet)

#### 2.1.1. Mòdul d'Orquestració i Flux

- **Concepte**: Centre de control de l'experiència d'usuari i navegador de l'aplicació.
    
      
    
- **Justificació**: Actua com la capa superior que guia l'**operador** per les funcionalitats (crear test, revisar pendents, etc.) de forma intuïtiva, minimitzant la càrrega cognitiva en entorns d'estrès.
    
      
    
- **Relació amb Objectius**: Respon a l'**Optimització de la recollida (O-1.1)** facilitant un accés ràpid a les eines i a l'**Automatització (O-1.3)** en simplificar els passos que l'usuari ha de seguir.
    
      
    

#### 2.1.2. Mòdul de Gestió de Sessió

- **Concepte**: Gestiona la identitat del dispositiu vinculada a la **unitat operativa**.
    
      
    
- **Justificació**: Encara que els perfils siguin estàtics per dispositiu, aquest mòdul assigna l'origen de la dada. És vital per decidir la jerarquia de la informació en cas de concurrència d'unitats en una mateixa **actuació**.
    
      
    
- **Relació amb Objectius**: Fonamental per a la **Integritat de les dades (O-3.2)**, ja que cada registre queda segellat amb el seu origen i rang d'autoritat.
    
      
    

#### 2.1.3. Mòdul del Motor Dinàmic (El Qüestionari)

- **Concepte**: El nucli que renderitza el qüestionari a partir d'una definició externa.
    
      
    
- **Justificació**: És la peça que permet la resiliència operativa. Si cal recollir dades sobre **noves seccions o tipologies de dades**, només cal actualitzar la plantilla sense modificar el codi de l'App.
    
      
    
- **Relació amb Objectius**: Directament lligat a l'**Automatització de la intel·ligència (O-1.3)** i al **Model d'emmagatzematge resilient (O-2.1)**.
    
      
    

#### 2.1.4. Mòdul de Persistència Local i Seguretat

- **Concepte**: Magatzem temporal de dades dins la tauleta amb capes de seguretat activa.
    
      
    
- **Justificació**: Garanteix que el treball no es perdi per fallades de bateria. Inclou el xifratge de dades sensibles (matrícules, dades personals) per complir amb el RGPD en cas de robatori o pèrdua de la tauleta.
    
      
    
- **Relació amb Objectius**: Garanteix la **Seguretat i integritat de la informació (O-3.2)** i la **Privadesa des del disseny (O-3.1)**.
    
      
    

#### 2.1.5. Mòdul de Sincronització i Comunicació

- **Concepte**: Gestor de la cua d'enviaments cap al servidor.
    
      
    
- **Justificació**: Implementa la lògica de connectivitat automàtica, permetent a l'**operador** "enviar i oblidar". S'encarrega de gestionar la comunicació en zones amb connectivitat nul·la o intermitent.
    
      
    
- **Relació amb Objectius**: Clau per a la **Resiliència del sistema (O-1.2)**.
    
      
    

#### 2.1.6. Mòdul Legal Local

- **Concepte:** Centre de documentació normativa, transparència i gestió de drets integrat en el dispositiu.
    
      
    
- **Justificació:** Garanteix que tota la base legal (clàusules informatives, RAT i polítiques de privacitat) estigui disponible de forma permanent i offline. Permet a l'**operador** complir amb el deure d'informar la ciutadania en el moment de la recollida de dades, actuant com un mecanisme de control humà i transparència proactiva.
    
      
    
- **Relació amb Objectius:** Clau per a la **Capa Legal i Normativa** del sistema (O-1.3) i el compliment del RGPD en entorns de mobilitat.
    
      
    

### 2.2. Mòduls del Servidor (Backend)

#### 2.2.1. Mòdul de Sincronització i Comunicació (Servidor)

- **Concepte**: Punt d'entrada de dades des de les tauletes (API Gateway).
    
      
    
- **Justificació**: Verifica la integritat dels paquets rebuts i valida que les dades s'ajustin a la plantilla vigent abans de permetre'n l'emmagatzematge.
    
      
    
- **Relació amb Objectius**: Assegura la **Integritat de la informació (O-3.2)** i el control de la plantilla com a filtre.
    
      
    

#### 2.2.2. Mòdul d'Interconnexió

- **Concepte**: Lògica de negoci que agrupa dades de diferents **unitats** en un únic **registre/incident**.
    
      
    
- **Justificació**: Aquest mòdul és el responsable d'agafar tot l'**input rebut** del client i realitzar les transformacions i gestions necessàries per enviar la informació cap al mòdul d'emmagatzematge de la forma adequada. No només resol conflictes de duplicats, sinó que assegura que la dada bruta es converteixi en informació estructurada i útil per a l'emmagatzematge i l'anàlisi.
    
      
    
- **Relació amb Objectius**: Essencial per a l'**Explotació analítica eficaç (O-2.2)**.
    
      
    

#### 2.2.3. Mòdul d'Emmagatzematge

- **Concepte**: Capa de persistència NoSQL o d'estructura flexible.
    
      
    
- **Justificació**: Tal com s'ha definit en els objectius, aquest mòdul ha de ser capaç d'acceptar les estructures prefixades i de suportar qualsevol camp nou que s'afegeixi a la plantilla del test sense necessitar migracions de base de dades.
    
      
    
- **Relació amb Objectius**: Respon directament al **Model d'emmagatzematge resilient (O-2.1)** i a l'**Explotació analítica eficaç (O-2.2)**.
    
      
    

#### 2.2.4. Mòdul de Transparència i Compliment Legal

- **Concepte**: Repositori centralitzat d'informació legal i clàusules de privadesa per als usuaris i ciutadans afectats.
    
      
    
- **Justificació**: És necessari que es pugui consultar la informació sobre el tractament de les dades d'una forma clara i accessible. Tenir un espai on resideixi tota aquesta informació de forma aïllada és beneficiós tant per al compliment normatiu com per a la confiança dels ciutadans en el servei.
    
      
    
- **Relació amb Objectius**: Respon directament al **Deure d'informació (O-3.3)**.
    
      
    

## 3. Requisits Detallats dels Mòduls

### 3.1. Mòduls del Client (App Tablet)

#### 3.1.1. Mòdul d'Orquestració i Flux

Aquest mòdul actua com el nucli de navegació que relliga les pantalles dels diferents mòduls, garantint una estructura d'ús intuïtiva i centralitzada.

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.1**|Si el Mòdul de Sessió cedeix el control, el sistema **ha de** proveir a l'**usuari** la capacitat d'accedir al menú principal que contingui els accessos a tots els mòduls operatius.|Garanteix que l'usuari només accedeix a la navegació un cop s'ha identificat correctament (control d'accés).|
|**R-1.2**|Si l'usuari selecciona una funcionalitat específica, el sistema **ha de** ser capaç de carregar i mostrar la interfície gràfica corresponent al mòdul seleccionat amb les especificacions establertes.|Permet la interoperabilitat visual entre el menú general i les eines específiques (qüestionari, mapes, etc.).|
|**R-1.3**|Si l'**operador** es troba dins d'un mòdul secundari, el sistema **ha de** proveir a la interfície la capacitat de retornar al menú d'orquestració de forma immediata.|Millora l'agilitat operativa permetent saltar entre tasques sense haver de reiniciar l'aplicació.|
|**R-1.4**|Si l'usuari utilitza el control de "tornar enrere" del dispositiu o de l'aplicació, el sistema **ha de** ser capaç de gestionar la transició cap a la pantalla anterior del flux de navegació.|Assegura que l'experiència d'usuari (UX) sigui coherent amb el sistema operatiu, evitant confusions en moments de tensió.|
|**R-1.5**|Si l'usuari realitza una transició entre mòduls, el sistema **hauria de** proveir una navegació fluida que eviti temps d'espera o recàrregues completes d'interfície.|Redueix la càrrega cognitiva i el temps de resposta del sistema, punts clau per a l'eficiència al camp.|

#### 3.1.2. Mòdul de Gestió de Sessió

Aquest mòdul és l'encarregat de controlar l'accés a l'aplicatiu, gestionar la identitat de l'usuari mitjançant el seu rang i assegurar que la sessió sigui persistent i segura en l'emmagatzematge local.

  

**A. Gestió del Cicle de Vida de la Sessió i Persistència**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.2.A.1**|Si la sessió es tanca, el sistema **ha de** ser capaç d'esborrar la sessió establerta.|Evita que, en cas de pèrdua o robatori de la tauleta, algú pugui accedir a la informació del registre sense autenticació.|
|**R-1.2.A.2**|Si l'usuari inicia l'aplicació, el sistema **ha de** demanar la contrasenya per a desbloquejar la base de dades local.|Protegeix les dades en repòs abans de permetre qualsevol operació de lectura o escriptura.|

**B. Interfície Visual d'Inici de Sessió**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.2.B.1**|Si l'aplicació es troba en estat bloquejat, el sistema **ha de** proveir a l'**usuari** una interfície gràfica d'inici de sessió clara i accessible.|Punt d'entrada obligatori que impedeix l'ús de l'aplicació per part de personal no autoritzat.|
|**R-1.2.B.2**|Si l'usuari inicia l'aplicació, el sistema **ha de** proveir a l'**operador** la capacitat de seleccionar el seu rang operatiu.|Estableix el context necessari per a l'identificador absolut de l'actuació i el nivell d'autoritat de les dades segons el rang.|
|**R-1.2.B.3**|Si l'usuari selecciona un rang diferent, el sistema **ha de** registrar el canvi en el log d'activitat de l'actuació.|**Traçabilitat de l'autoritat:** Assegura que cada dada introduïda quedi vinculada al rang que l'**operador** tenia en aquell moment, permetent auditories posteriors.|

**C. Interfície de Canvi d'Elements de Sessió (Configuració)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.2.C.1**|Si l'**operador** necessita actualitzar el seu rol o rang, el sistema **ha de** proveir a l'usuari la capacitat de modificar aquests elements des d'una finestra de configuració de sessió.|Permet l'adaptabilitat de l'eina a la realitat del comandament al camp, on els rols poden variar segons l'arribada d'unitats.|

**D. Indicador Gràfic de Nivell i Rang**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.2.D.1**|Si hi ha una sessió activa, el sistema **hauria de** proveir a la interfície un element gràfic persistent que indiqui el rang actualment autenticat.|Permet a l'**operador** verificar d'un cop d'ull amb quin perfil està treballant, evitant errors en la introducció de dades.|
|**R-1.2.D.2**|Si el rang autenticat canvia, el sistema **ha de** ser capaç d'actualitzar l'indicador gràfic per reflectir la nova situació administrativa de l'usuari.|Manté la coherència entre la realitat jurídica del subjecte i el que mostra el programari.|

#### 3.1.3. Mòdul del Motor Dinàmic (El Qüestionari)

Aquest mòdul transforma plantilles estructurades (JSON/XML) en interfícies interactives, gestionant la lògica de flux i la traçabilitat de la informació recollida.

  

**A. Interpretació de Plantilles i Generació de UI**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.3.A.1**|Si es detecta una plantilla, el sistema **ha de** ser capaç d'identificar-la.|Garanteix la flexibilitat del sistema davant futurs canvis en l'arquitectura de dades de l'**organització**.|
|**R-1.3.A.2**|Si s'analitza una plantilla, el sistema **ha de** ser capaç d'identificar de forma única la seva versió mitjançant un codi d'identificació intern en la plantilla.|Evita conflictes de dades entre la tauleta i el servidor, assegurant que les respostes corresponen a la versió correcta del protocol.|
|**R-1.3.A.3**|Si es dissenya una nova plantilla, el sistema **ha de** ser capaç d'interpretar-la mitjançant una estructura clara i fàcil per facilitar la creació de qüestionaris sense complicar l'intèrpret.|Redueix el temps de manteniment i la corba d'aprenentatge per als administradors del sistema.|

**B. Lògica de Flux Evolutiva (Motor Reactiu)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.3.B.1**|Si la plantilla indica canvis en el contingut (incorporar, treure o modificar), el sistema **ha de** ser capaç d'actuar d'acord amb les normes establertes en el flux del qüestionari.|Permet que la interfície s'adapti dinàmicament a la situació de l'**actuació de camp**, mostrant només el que és rellevant.|
|**R-1.3.B.2**|Si el sistema introdueix dades de forma automàtica, el sistema **ha de** proveir a l'usuari la capacitat de validar explícitament que la informació és correcta abans de tancar el bloc.|El sistema no pot decidir per si sol; cal que el responsable humà (**operador**) verifiqui les dades automatitzades.|
|**R-1.3.B.3**|Si l'usuari introdueix una dada manualment, el sistema **ha de** ser capaç de validar el format i rang de la dada en temps real.|Prevé la introducció de dades incoherents o errònies durant l'activitat de camp.|

**C. Injecció de Context i Traçabilitat**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.3.C.1**|Si es genera una resposta, el sistema **ha de** ser capaç d'adjuntar-hi automàticament el rang de l'usuari, la data i l'hora exacta.|Proveeix la traçabilitat necessària (pseudonimització) sense carregar de feina manual a l'**operador**.|
|**R-1.3.C.2**|Si es finalitza el qüestionari, el sistema **ha de** proveir a l'usuari un resum de les dades recollides per a la seva validació final.|Actua com a mecanisme de control humà sobre el tractament automatitzat de les dades.|
|**R-1.3.C.3**|Si s'intenta obrir un qüestionari amb una versió desactualitzada, el sistema **ha de** ser capaç de bloquejar l'accés i notificar la necessitat de sincronització amb el servidor.|Garanteix la integritat del procés de recollida de dades, evitant que s'enviïn tests que el servidor no pugui processar.|
|**R-1.3.C.4**|Si es visualitza el qüestionari, el sistema **ha de** ser capaç de mostrar el progrés que indiqui visualment el percentatge de completat del qüestionari.|Millora l'experiència d'usuari (UX) en situacions operatives, permetent saber d'un cop d'ull quina informació falta per completar el procés.|

#### 3.1.4. Mòdul de Persistència Local i Seguretat

Aquest mòdul gestiona l'emmagatzematge físic de la informació a la Tablet, assegurant la disponibilitat de les dades en mode offline i l'aplicació estricta de mesures de seguretat en repòs.

  

**A. Arquitectura i Seguretat de la Base de Dades (BD)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.4.A.1**|Si el sistema emmagatzema dades en el dispositiu, el sistema **ha de** utilitzar un motor de base de dades flexible per poder suportar totes les dades a introduir, incloses les de les plantilles dinàmiques.|Permet desar qüestionaris amb estructures diferents sense haver de modificar l'esquema de la base de dades constantment.|
|**R-1.4.A.2**|Si el sistema emmagatzema dades en repòs, el sistema **ha de** xifrar la base de dades mitjançant AES-256 amb una clau vinculada a la sessió activa.|**Seguretat Física:** Protegeix la informació sensible en cas de robatori o pèrdua física de la tauleta en el **camp d'actuació**.|
|**R-1.4.A.3**|Si el Mòdul de Sessió es bloqueja per inactivitat, el sistema **ha de** revocar l'accés a les claus de descodificació de la base de dades local.|**Tancament de seguretat:** Garanteix que, encara que la tauleta estigui encesa, les dades romanguin inaccessibles si l'**usuari** no està autenticat.|
|**R-1.4.A.4**|Si es realitzen múltiples escriptures simultànies, el sistema **ha de** ser capaç de gestionar la concurrència per mantenir la base de dades en un estat consistent i accessible.|Garanteix la robustesa del sistema davant tancaments sobtats o fallades del sistema operatiu.|
|**R-1.4.A.5**|Si el sistema emmagatzema dades personals, el sistema **ha de** garantir la **separació lògica** (fragmentació) d'aquestes respecte a les dades operatives.|Evita la vinculació directa de dades d'identificació personal amb els registres operatius en local.|
|**R-1.4.A.6**|Si l'usuari introdueix informació, el sistema **ha de** guardar periòdicament a disc les dades registrades per evitar pèrdues davant d'interrupcions.|Assegura la preservació contínua del treball realitzat a peu de camp.|

**B. Interfície d'Accés i Estandardització (Capa d'Abstracció)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.4.B.1**|Si un mòdul extern requereix desar informació, el sistema **ha de** proveir una interfície estàndard (API local) que centralitzi totes les peticions d'escriptura.|Evita que cada mòdul gestioni la seva pròpia lògica d'emmagatzematge, simplificant el codi i facilitant el manteniment.|
|**R-1.4.B.2**|Si es requereix una consulta de dades, el sistema **ha de** ser capaç de retornar els objectes en un format estàndard compatible.|Assegura la interoperabilitat total entre el que s'ha guardat i el que es mostra per pantalla.|
|**R-1.4.B.3**|Si el volum de dades pendents de sincronització és elevat, el sistema **hauria de** proveir un mecanisme de cua d'escriptura per no bloquejar la interfície d'usuari.|Millora l'operativitat al camp, permetent que l'**operador** continuï treballant mentre el sistema gestiona la persistència en segon pla.|

#### 3.1.5. Mòdul de Sincronització i Comunicació (Client)

Aquest mòdul actua com el gestor logístic de la informació, encarregant-se de la comunicació bidireccional amb el servidor central i de l'administració de la memòria operativa de la Tablet a través de la biblioteca de qüestionaris.

  

**A. Transmissió i Confirmació de Dades (Capa de Comunicació)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.5.A.1**|Si es detecta una connexió estable, el sistema **ha de** ser capaç d'enviar automàticament sota demanda els paquets de dades al servidor de forma asíncrona i amb un **canal xifrat (TLS/HTTPS)**.|Només s'han d'enviar aquells qüestionaris marcats explícitament per a la tramesa, evitant l'enviament accidental d'esborranys incomplets o informació no validada per l'**operador**.|
|**R-1.5.A.2**|Si el servidor confirma la recepció correcta, el sistema **ha de** proveir a la persistència local la capacitat de marcar el qüestionari com a "Sincronitzat".|Aquesta marca d'estat és essencial per evitar duplicats en la base de dades central i permetre la posterior neteja de la memòria local amb garanties.|
|**R-1.5.A.3**|Si es produeix un error en la tramesa, el sistema **ha de** ser capaç de reintentar l'enviament de forma exponencial per evitar el col·lapse de la xarxa.|Augmenta la resiliència del sistema en entorns crítics amb cobertura degradada, assegurant que la dada arribi finalment al destí sense intervenció manual constant.|
|**R-1.5.A.4**|Si s'inicia un procés de tramesa, el sistema **ha de** ser capaç de gestionar una cua d'enviaments que emmagatzemi les dades de forma persistent fins que es confirmi l'entrega al servidor.|Implementa la filosofia d'"enviar i oblidar", permetent que l'**operador** continuï amb les seves tasques operatives mentre el sistema gestiona la comunicació en segon pla (Objectiu 2: Resiliència).|
|**R-1.5.A.5**|Si es descobreix la primera posada en marxa de l'aplicació, el sistema **ha de** sol·licitar un identificador únic al servidor i desar-lo de manera permanent en el dispositiu.|Permet la vinculació unívoca i persistent de la tauleta amb la plataforma central.|

**B. Interfície de Gestió de Qüestionaris (Biblioteca Operativa)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.5.B.1**|Si l'usuari accedeix a la biblioteca, el sistema **ha de** proveir una interfície gràfica que llisti de forma clara els qüestionaris pendents, completats i sincronitzats.|Proveeix una visió global de la càrrega de treball i de l'estat de les dades, facilitant el control humà directe sobre el flux d'informació.|
|**R-1.5.B.2**|Si l'**operador** selecciona un qüestionari incomplet de la llista, el sistema **ha de** ser capaç d'obrir-lo en el Mòdul Dinàmic recuperant íntegrament l'estat de les respostes anteriors.|Requisit crític per a l'operativitat; permet la gestió d'actuacions de llarga durada on la recollida de dades es pot veure interrompuda per necessitats del servei.|
|**R-1.5.B.3**|Si l'usuari decideix esborrar un qüestionari local, el sistema **ha de** demanar una confirmació explícita mitjançant una acció conscient abans d'executar l'acció.|El sistema ha de prevenir l'eliminació accidental de dades de l'actuació, exigint sempre una decisió humana responsable.|
|**R-1.5.B.4**|Si un qüestionari és enviat manualment o marcat per a tramesa, el sistema **ha de** ser capaç de bloquejar la seva edició posterior per garantir la integritat de la dada sincronitzada.|Garanteix que la informació que rep el centre de control al servidor sigui idèntica a la que queda registrada a la Tablet, evitant divergències documentals.|
|**R-1.5.B.5**|Si es visualitza un qüestionari a la biblioteca, el sistema **ha de** ser capaç de mostrar una barra de progrés que indiqui visualment el percentatge de completat del qüestionari.|Millora l'experiència d'usuari (UX) en situacions operatives, permetent saber d'un cop d'ull quina informació falta per completar el procés.|
|**R-1.5.B.6**|Si l'usuari es troba a la biblioteca, el sistema **ha de** proveir un accés directe i clar per a la creació de nous qüestionaris buits.|Facilita la ràpida resposta davant noves actuacions o necessitats de documentació addicional al camp.|
|**R-1.5.B.7**|Si el sistema confirma la sincronització correcta amb el servidor, el sistema **ha de** proveir la capacitat d'esborrar automàticament la dada local un cop verificada la seva integritat al destí.|Aplica el principi de limitació de la conservació: un cop la dada és segura al servidor central (Responsable), s'ha d'eliminar del terminal mòbil per minimitzar riscos de seguretat.|
|**R-1.5.B.8**|Si s'està realitzant una sincronització, el sistema **ha de** proveir a l'**usuari** la capacitat de visualitzar l'estat actual del procés (pendents, enviant, enviats).|Aporta transparència total a l'**usuari** sobre la situació de les seves dades, garantint que tingui el control sobre el que s'ha transmès i el que no.|

#### 3.1.6. Mòdul Legal Local

Aquest mòdul garanteix que tota la base normativa i informativa estigui disponible per a l'operador i per a l'administrat, assegurant que el sistema compleix amb el deure d'informar i la responsabilitat proactiva sense dependre de servidors externs.

  

**A. Finestra Principal: Centre de Documentació (Configuració/Perfil)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.6.A.1**|Si l'usuari accedeix al menú de configuració, el sistema **ha de** proveir un accés directe a una finestra amb el llistat complet de textos legals (Política de Privacitat, RAT i Avís Legal).|Centralitza la documentació obligatòria perquè l'**operador** pugui consultar-la offline en qualsevol moment.|
|**R-1.6.A.2**|Si s'obre un text legal, el sistema **ha de** mostrar la versió del document i la data de l'última actualització.|Garanteix que la informació és vigent i permet la traçabilitat de quines condicions estaven actives en el moment d'una intervenció.|
|**R-1.6.A.3**|Si un tercer (ciutadà) ho sol·licita, el sistema **ha de** ser capaç de generar un codi QR que enllaci a la versió del RAT (Registre d'Activitats de Tractament) i la Política de Privacitat completa.|Facilita que un ciutadà pugui endur-se la informació legal al seu propi dispositiu sense necessitat de contacte físic o paper.|
|**R-1.6.A.4**|Si es produeix una acceptació o una lectura de clàusula, el sistema **ha de** generar un log d'auditoria inalterable amb la marca de temps i l'ID de l'usuari.|**Evidència Jurídica:** En cas de revisió, l'**organització** pot provar que aquell dia, a aquella hora, el ciutadà va ser informat.|

**B. Finestra Contextual: Clàusula Informativa de Camp**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.6.B.1**|Si l'**operador** inicia un qüestionari que requereix dades personals, el sistema **ha de** mostrar un accés ràpid (icona d'informació) a la clàusula informativa simplificada.|Permet que l'**operador** llegeixi o mostri l'avís legal a l'afectat de forma immediata abans d'introduir la dada, complint amb la intervenció humana.|
|**R-1.6.B.2**|Si l'usuari prem l'accés informatiu, el sistema **ha de** desplegar una finestra emergent (modal) que resumeixi qui és el Responsable del Tractament i com exercir els drets ARCO.|Evita haver de sortir del flux de treball per informar a la ciutadania, mantenint l'operativitat de l'**actuació**.|

**C. Finestra de Bloqueig i Consentiment (Actualitzacions)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-1.6.C.1**|Si el servidor notifica un canvi crític en els protocols de dades, el sistema **ha de** bloquejar l'accés a l'operativa fins que l'usuari visualitzi i accepti la nova finestra de condicions.|Assegura que cap **operador** operi sota protocols legals obsolets, garantint la responsabilitat proactiva de l'organització.|
|**R-1.6.C.2**|Si l'usuari accepta els nous termes, el sistema **ha de** registrar localment la identitat de l'usuari, la data i l'hora de l'acceptació.|Proveeix una prova fefaent que l'**operador** ha estat informat i ha acceptat les seves obligacions de seguretat.|

> **Nota:** Aquest apartat consta de 3 pantalles principals: Finestra de Documentació, Finestra Emergent Informativa i Finestra de Bloqueig per imprevistos (nous terminis).
> 
>   

### 3.2. Mòduls del Servidor (Backend)

#### 3.2.1. Mòdul de Sincronització i Comunicació (Servidor)

Aquest mòdul és l'encarregat de gestionar les connexions entrants de les tauletes, validar la seva identitat mitjançant l'identificador de dispositiu i assegurar que la recepció de dades ha estat íntegra abans de derivar-les al Mòdul d'Interconnexió.

  

**A. Gestió de Connexió i Identificació**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.1.A.1**|Si una tauleta nova sol·licita un identificador, el sistema **ha de** validar la petició, generar un ID únic de dispositiu, guardar-lo en la base de dades local i enviar-lo a la Tablet.|Procés d'emparellament inicial; permet que el servidor "conegui" la tauleta i estableixi una relació de confiança.|
|**R-2.1.A.2**|Si una tauleta intenta establir connexió, el sistema **ha de** validar l'identificador únic del dispositiu (Tablet ID) definit en el primer contacte.|Garanteix que només els dispositius autoritzats i prèviament registrats per l'**organització** puguin transmetre dades al servidor central.|
|**R-2.1.A.3**|Si el Mòdul de Sincronització del client envia un paquet, el sistema **ha de** mantenir un canal de comunicació xifrat extrem a extrem per a la recepció i complir amb l'ENS.|Protegeix la confidencialitat de les dades durant el trànsit per xarxes públiques o privades, evitant interceptacions.|
|**R-2.1.A.4**|Si es rep un paquet de dades, el sistema **ha de** validar la signatura/hash de la tauleta i generar un log d'entrada que vinculi el registre amb l'ID del dispositiu.|**Inalterabilitat:** El servidor confirma que la dada no ha estat modificada des que l'**operador** la va "segellar" a la tauleta. És l'evidència de cadena de custòdia digital.|

**B. Recepció i Verificació d'Integritat**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.1.B.1**|Si es rep un paquet de dades, el sistema **ha de** realitzar una comprovació d'integritat (checksum) per confirmar que la informació no s'ha corromput durant el transport.|Garanteix que les dades operatives que arriben al centre de gestió són exactes i completes.|
|**R-2.1.B.2**|Si la informació rebuda és idèntica a l'enviada pel client, el sistema **ha de** emetre un justificant de recepció (_ACK_) al Mòdul de Sincronització de la Tablet.|Tanca el cicle de comunicació i permet que el client marqui el qüestionari com a "Sincronitzat" i procedeixi al seu esborrat local segur.|

**C. Derivació al Mòdul d'Interconnexió**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.1.C.1**|Si la dada ha estat verificada correctament, el sistema **ha de** transferir de forma immediata el paquet d'informació al Mòdul d'Interconnexió per al seu processament.|Actua com un filtre de seguretat; cap dada pot entrar al nucli del sistema sense haver passat la validació de la "Duana" de comunicació.|
|**R-2.1.C.2**|Si es produeix una fallada en la verificació, el sistema **ha de** registrar l'incident de seguretat i descartar la dada, informant al dispositiu d'origen de l'error.|Prevé la corrupció de la base de dades central i alerta sobre possibles intents de manipulació o fallades de maquinari.|

#### 3.2.2. Mòdul d'Interconnexió

Aquest mòdul actua com el nucli analític del servidor, gestionant un _cache_ de registres recents per identificar similituds en temps real i anotar possibles coincidències al mòdul d'emmagatzematge sense comprometre la integritat de cada registre individual ni la traçabilitat de la font original.

  

**A. Processament i Gestió de Cache Operatiu**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.2.A.1**|Si el Mòdul de Sincronització envia un paquet, el sistema **ha de** desglossar la informació en metadades i dades operatives per al seu tractament individualitzat.|Permet indexar el registre segons paràmetres de context (posició geogràfica, marca de temps, tipologia) per a una cerca posterior optimitzada.|
|**R-2.2.A.2**|Si s'ha processat un registre d'actuació, el sistema **ha de** mantenir un _cache_ d'actuacions mef-actives per permetre una comparativa immediata i ràpida amb les noves entrades.|Millora dràsticament el rendiment del servidor en situacions de gran volum de dades, evitant consultes costoses a la base de dades persistent.|
|**R-2.2.A.3**|Si un registre es transforma per incloure's en el _cache_, el sistema **ha de** ser capaç d'incorporar-lo i gestionar l'espai per a una consulta dirigida i eficient.|Garanteix la disponibilitat del sistema evitant la degradació del rendiment i eliminant dades que ja no són rellevants per a la detecció de coincidències recents.|

**B. Identificació de Similituds i Notificació**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.2.B.1**|Si arriba un nou qüestionari, el sistema **ha de** comparar mitjançant el _cache_ les coordenades i la tipologia amb les actuacions obertes.|Algorisme de detecció que identifica si diversos efectius estan informant del mateix succés, permetent una visió holística del servei.|
|**R-2.2.B.2**|Si es detecta una similitud elevada, el sistema **ha de** notificar al Mòdul d'Emmagatzematge l'existència d'una possible coincidència mitjançant una etiqueta de vinculació.|Proveeix una orientació sobre possibles duplicitats sense destruir la dada original, preservant la responsabilitat individual de cada informant.|

> **Nota de disseny:** El sistema no pretén realitzar una deduplicació totalment automatitzada, sinó oferir una eina de suport a la decisió que identifiqui registres potencialment vinculats per a la seva posterior revisió humana o processament estadístic.
> 
>   

**C. Interfície cap a Emmagatzematge i Control**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.2.C.1**|Si la dada ha estat analitzada, el sistema **ha de** enviar al Mòdul d'Emmagatzematge el paquet complet amb les metadades de coincidència generades.|Assegura que la base de dades final rebi tota la informació necessària per a la posterior revisió o la unificació administrativa manual.|
|**R-2.2.C.2**|Si s'identifica una coincidència entre registres, el sistema **ha de** marcar el registre de forma consistent, proporcional i determinista.|Alerta als gestors del sistema que hi ha versions d'un mateix succés, forçant la intervenció humana segons criteris objectius i no arbitraris.|

#### 3.2.3. Mòdul d'Emmagatzematge

Aquest mòdul gestiona la persistència definitiva de la informació al servidor, distribuint les dades rebudes del Mòdul d'Interconnexió en quatre dipòsits especialitzats segons el seu nivell de criticitat, ús posterior i requisits de rendiment.

  

**A. Motor de Distribució per Plantilles (Orquestrador)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.3.A.1**|Si el Mòdul d'Interconnexió envia dades unificades, el sistema **ha de** aplicar la plantilla indicada per a separar la informació en els blocs d'emmagatzematge.|Garanteix que cada dada es desi en el nivell de seguretat adequat de forma automatitzada, eliminant el risc de fuga de dades per error de configuració.|
|**R-2.3.A.2**|Si s'executa la distribució de la informació en diferents bases de dades, el sistema **ha de** mantenir un vincle lògic xifrat entre els blocs per permetre la reconstrucció de l'actuació.|Permet que, tot i la fragmentació física per seguretat, el sistema pugui recompondre la traçabilitat completa del succés quan sigui legalment necessari.|
|**R-2.3.A.3**|Si el sistema distribueix dades en diferents dipòsits, el sistema **ha de** utilitzar identificadors anònims (Hashes) per vincular-les, evitant claus primàries que continguin informació personal.|**Pseudonimització tècnica:** Garanteix que si algú coneix l'identificador no obtingui cap informació extra.|

**B. Base de Dades Confidencial (Blindatge de Privacitat)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.3.B.1**|Si una dada és catalogada com a identificativa directa o indirectament (Exemples: Noms, DNI, dates precises, hora de l'actuació, matrícules), el sistema **ha de** emmagatzemar-la en la BD Confidencial amb xifratge asíncron.|Evita la reidentificació per deducció o encreuament temporal (atac de rellotge), protegint el dret a la intimitat dels implicats.|
|**R-2.3.B.2**|Si es realitza una consulta a la BD Confidencial, el sistema **ha de** registrar un log d'auditoria immutable amb la identitat de l'usuari i el motiu de la consulta.|Garanteix el control total sobre l'accés a dades sensibles, sent la base per a futures auditories de seguretat.|
|**R-2.3.B.3**|Si es detecta una dada de "Categoria Especial" (Art. 9), el sistema **ha de** aplicar un xifratge de capa d'aplicació (clau per registre) addicional al xifratge del disc.|**Doble Blindatge:** Protegeix dades sensibles (com salut). Si el servidor cau en mans alienes, les dades de salut segueixen xifrades registre a registre.|

**C. Base de Dades d'Anàlisi i Mètriques (Estadística Operativa)**

  

Base de dades optimitzada per a la consulta massiva i el càlcul d'indicadors de rendiment dels **equips operatius**.

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.3.C.1**|Si una dada té valor operatiu (paràmetres operatius, unitats, recursos), el sistema **ha de** emmagatzemar-la en la BD d'Anàlisi.|Permet millorar els protocols operatius i extreure coneixement sense posar en risc cap dada personal, complint amb la minimització estricta.|
|**R-2.3.C.2**|Si s'executen consultes, el sistema **ha de** estar preparat per realitzar cerques de forma eficaç garantint l'anonimització absoluta del resultat.|En estar desvinculada de dades directes o indirectes, qualsevol exportació d'aquesta BD és segura per a ús públic o administratiu.|

**D. Base de Dades de Relacions (Mapeig de Similituds)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.3.D.1**|Si es detecta una possible coincidència, el sistema **ha de** emmagatzemar en la BD de Relacions els IDs vinculats i el percentatge de similitud calculat.|Crea un graf de relacions que permet als analistes detectar duplicitats o focus d'interès sense alterar els testimonis originals dels **operadors**.|
|**R-2.3.D.2**|Si es requereix una reconstrucció d'actuacions, el sistema **ha de** estar preparat per fer cerques de relacions de forma eficaç mitjançant índexs de vinculació.|Permet als gestors agrupar tota la informació fragmentada d'un succés de forma ràpida en situacions de post-actuació o investigació.|

**E. Magatzem d'Objectes de Gran Volum (Imatges i Multimèdia)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.3.E.1**|Si l'actuació inclou fotos o vídeos, el sistema **ha de** emmagatzemar-los independentment de la base de dades textual.|Prevé el col·lapse de les bases de dades informacionals i manté la velocitat de resposta.|
|**R-2.3.E.2**|Si es guarda una imatge, el sistema **ha de** xifrar el fitxer individualment i guardar el seu _path_ i clau de validació a la BD Confidencial.|Vincula la prova gràfica al context legal, assegurant que només personal autoritzat pugui accedir al contingut visual de l'actuació.|

#### 3.2.4. Mòdul de Transparència i Compliment Legal

Aquest mòdul centralitza la documentació normativa, la gestió de drets dels interessats i l'accés als registres d'auditoria, garantint que el sistema no només sigui segur, sinó també transparent i auditable a llarg termini.

  

**A. Portal de Polítiques i Certificacions**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.4.A.1**|El sistema **ha de** publicar la versió estesa de la Política de Privacitat, desglossant el tractament per cada tipus de dada (operativa vs. confidencial).|Permet una consulta profunda sobre com es gestionen les dades, complint amb el dret a la informació en la seva màxima expressió.|
|**R-2.4.A.2**|El sistema **ha de** mostrar els certificats de compliment de l'ENS i els segells d'auditoria tècnica de la infraestructura del servidor.|Aporta una capa de confiança institutional, demostrant que el servidor ha passat controls externs de ciberseguretat.|
|**R-2.4.A.3**|El sistema **ha de** mantenir un historial de versions de tota la documentació legal, permetent descarregar la política vigent en una data concreta.|Essencial per a la traçabilitat jurídica: saber quines normes s'aplicaven exactament en la data d'un registre passat.|

**B. Gestor de Drets de l'Interessat (Drets ARCO+)**

  

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.4.B.1**|El sistema **ha de** proveir un formulari d'accés per a l'exercici de drets que vinculi automàticament la petició amb el Hash identificatiu de l'interessat.|Automatitza la relació ciutadà-Administració, permetent trobar les dades fragmentades sense necessitat de cercar per DNI directament.|
|**R-2.4.B.2**|Si s'introdueix una petició de drets, el sistema **ha de** generar un tiquet de seguiment amb el segell de temps i el termini legal de resposta calculat.|Garanteix la seguretat jurídica de l'interessat, informant-lo de quan rebrà una solució a la seva demanda.|

**C. Tauler d'Auditoria per al DPD i Supervisors**

|**ID**|**Requisit (Seguint el motlle)**|**Descripció / Justificació**|
|---|---|---|
|**R-2.4.C.1**|El sistema **ha de** permetre la visualització dels logs d'accés a la BD Confidencial i de Relacions, garantint que el registre d'auditoria sigui immutable.|Eina clau per detectar accessos anòmals. La immutabilitat impedeix que un administrador esborri el rastre de la seva pròpia consulta.|
|**R-2.4.C.2**|Si es detecta una bretxa de seguretat, el sistema **ha de** ser capaç de generar un informe d'impacte preliminar amb el nombre d'afectats i dades compromeses.|Redueix el temps de reacció, facilitant el compliment del termini de notificació de 72 hores a l'autoritat de control.|
|**R-2.4.C.3**|Si es consulta una dada de categoria especial (salut), el sistema **ha de** forçar a l'usuari a introduir una justificació textual del motiu d'accés.|Afegeix un nivell de control humà reforçat; l'auditoria no només diu qui ha entrat, sinó per quina causa justificada ho ha fet.|
|**R-2.4.C.4**|El sistema **ha de** ser capaç de generar automàticament el Registre d'Activitats de Tractament (RAT) en un format estàndard exportable.|Demostra la responsabilitat proactiva del sistema davant d'una inspecció, mantenint el llistat de tractaments sempre actualitzat.|
|**R-2.4.C.5**|Si es detecta un accés massiu a dades confidencials en un curt període de temps, el sistema **ha de** disparar una alerta automàtica al DPD.|Actua com a mecanisme de defensa davant d'usuaris interns maliciosos o exfiltració de dades per atac extern.|