#  Prototip Conceptual d'Aplicació (Versió Local Portable)

Aquest paquet conté un prototip funcional i completament independent de l'aplicació, dissenyat específicament per a la validació de la interfície gràfica i el flux del qüestionari. Es tracta d'un entorn tancat de proves (_sandbox_) que s'executa al 100% en local. No requereix cap tipus d'instal·lació prèvia, canvis en la configuració del sistema, privilegis d'administrador ni connexió a internet.

## 💻 Guia d'Ús Ràpida (Per a usuaris no tècnics)

Per executar i provar el prototip, seguiu les instruccions corresponents al sistema operatiu del vostre ordinador:

### En sistemes Windows:

1. **Descomprimiu** el fitxer ZIP del lliurament, el qual trobareu identificat amb el nom de carpeta `ClientPrototip-<detalls_versio>_Windows`.
    
2. Accediu a la carpeta i feu **doble clic** sobre el fitxer anomenat **`arrancar_windows.bat`**.
    
3. S'obrirà automàticament una finestra negra de la consola de comandes. **És imprescindible que no la tanqueu**, ja que actua com el motor que serveix l'aplicació. De manera immediata, s'obrirà el vostre navegador web predeterminat mostrant el prototip.
    

### En sistemes Linux (Ubuntu i similars):

1. **Descomprimiu** el fitxer ZIP del lliurament, el qual trobareu identificat amb el nom de carpeta `ClientPrototip-<detalls_versio>_Linux`.
    
2. Accediu a la carpeta, feu **clic dret** sobre el fitxer **`arrancar_linux.sh`** i seleccioneu l'opció **"Executar com a programa"** (alternativament, podeu obrir una terminal dins la carpeta i llançar-lo executant `./arrancar_linux.sh`).
    
3. El vostre navegador d'internet s'obrirà directament connectant amb el prototip local.
    

> 🛑 **Com tancar l'aplicació:** Quan hàgiu acabat de realitzar les vostres proves, només cal que tanqueu la finestra o pestanya del navegador web i la finestra negra de la consola de comandes. El programa s'aturarà de forma immediata per complet, sense deixar cap tipus de residu ni fitxer temporal col·locat a l'ordinador.

## ⏱️ Què esperar durant l'execució? (Flux de l'aplicació)

Una vegada s'obri el navegador web, l'aplicació seguirà un comportament seqüencial estructurat en tres fases clau:

1. **La Pantalla en Blanc (Càrrega Inicial):** El navegador es mantindrà amb la **pantalla completament en blanc durant un interval d'entre 5 i 30 segons** (aquest temps variarà segons la potència de processament de l'ordinador). Aquest comportament és completament normal i esperat: el sistema està descompressant i inicialitzant en la memòria de l'explorador tot el codi web optimitzat, els mòduls de JavaScript i els actius gràfics necessaris per renderitzar l'entorn de manera fluida.
    
2. **Càrrega del Fitxer Data (JSON):** Una vegada completada la inicialització i superada la pantalla en blanc, la interfície d'usuari es mostrarà activa i us demanarà explícitament que seleccioneu o introduïu un fitxer de configuració en format `.json`.
    
3. **Accés i Resolució del Qüestionari:** En prémer el botó **"Següent"**, l'aplicació llegirà de manera interna l'estructura del fitxer de dades aportat i renderitzarà dinàmicament el qüestionari a la pantalla, permetent-vos interactuar amb tots els camps de text, selectors i elements de formulari configurats.
    

## ⚠️ IMPORTANT: Resolució de problemes amb la memòria cau

Si esteu duent a terme auditories o proves consecutives substituint carpetes o comparant diferents versions del programa en un mateix ordinador sense reiniciar-lo, **el navegador web tendirà a confondre's i a carregar la primera versió** que ha deixat emmagatzemada de manera persistent a la seva memòria cau interna (_cache_).

Si observeu que el programa mostra pantalles ja superades, que no aplica els canvis dels nous fitxers o que obrir una finestra estàndard addicional manté els elements vells, heu d'aplicar de manera estricta un d'aquests dos mètodes d'anul·lació:

- **Forçar la recàrrega neta i buidatge (Recomanat):** Amb la pestanya de l'aplicació oberta al navegador, premeu simultàniament la combinació de tecles **`Ctrl + F5`** (en ordinadors Mac, utilitzeu **`Cmd + Shift + R`**). Això obliga el navegador a ignorar qualsevol fitxer emmagatzemat al disc dur i a descarregar la llista de fitxers actualitzada directament de la carpeta local.
    
- **Ús del Mode Incògnit Estricte:** Tanqueu les finestres prèvies, obriu una **Finestra d'Incògnit / Privada** totalment nova al vostre navegador web i escriviu manualment l'adreça de connexió local a la barra superior de navegació:
    
    👉 `http://localhost:8000`



## 🌐 Connexió en l'Entorn de Versió amb Servidor (Permisos d'Accés API)

Quan s'utilitza la versió de l'aplicació que requereix connexió directa amb el servidor central (en lloc de la versió portable 100% local i aïllada), és imprescindible establir una passarel·la de confiança entre el client web i l'API de dades per permetre l'intercanvi de protocols.

Si el servidor utilitza certificats de seguretat auto-signats o bústies de xarxa restringides, els navegadors web moderns (com Google Chrome, Microsoft Edge o Mozilla Firefox) activaran per defecte els seus mecanismes de protecció contra elements nocius, bloquejant de manera silenciosa totes les peticions internes de l'aplicació. En aquest escenari, el prototip es quedarà congelat o mostrarà errors de connectivitat.

### Pas a pas per autoritzar la connexió amb el servidor:

Per desbloquejar manualment aquesta restricció de seguretat del navegador i donar permís al sistema per connectar-se a la URL de l'API, heu d'executar estrictament el següent procediment d'excepció:

1. **Obtenció de la URL:** Identifiqueu l'adreça de connexió del servidor que s'utilitza en la configuració del vostre entorn (per exemple: `https://<ip_del_servidor>:<port>/api`).
2. **Accés Directe:** Obriu una pestanya completament nova a la barra superior del vostre navegador d'internet habitual, enganxeu-hi aquesta URL del servidor de forma directa i premeu *Intro*.
3. **Alerta de Seguretat:** El navegador detindrà la càrrega immediatament i mostrarà una pantalla d'alerta a pantalla completa amb un fons vermell o gris, acompanyada d'un text d'advertència similar a: *"La connexió no és privada"* o *"Risc potencial de seguretat"*.
4. **Desbloqueig Avançat:** Dirigiu la mirada a la part inferior d'aquest missatge d'alerta i feu clic sobre el botó o enllaç anomenat **"Configuració avançada"**.
5. **Autorització Definitiva:** Es desplegarà un subtext amb detalls tècnics. Heu de buscar i prémer l'opció final que diu **"Accedir a... (no segur)"** o **"Continuar i acceptar el risc"**.

Un cop fet això, s'haurà concedit un permís d'excepció temporal a la memòria del navegador per a aquesta adreça específica. Podeu tancar aquesta pestanya, retornar a la pestanya principal on teniu executant-se l'aplicació del client i recarregar la pàgina (`Ctrl + F5`). A partir d'aquest moment, el flux de dades i la càrrega dels qüestionaris connectats operarà de manera totalment fluida i lliure de bloquejos de xarxa.