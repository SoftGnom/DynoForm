

# GUIA DE CREACIÓ DE QÜESTIONARIS

## ÍNDEX: 📋 Estructura Completa del Manual

A continuació es detalla l'índex estructural de la guia operativa per a la configuració, modificació i control de qualitat dels formularis JSON de l'aplicació.

### MÒDUL 1: ELS FONAMENTS DEL LLENGUATGE JSON I L'ESQUELET MESTRE

* **1.1.** Què és un fitxer JSON i per què els ordinadors són tan rígids llegint-lo.
* **1.2.** El mapa conceptual de l'estructura mestre: Relació entre l'arrel, les preguntes i la jerarquia de components.
* **1.3.** Les 5 Regles d'Or de la puntuació (Sintaxi per a no-programadors).
* **1.3.1.** El secret de les cometes dobles (`""`) obligatòries.
* **1.3.2.** L'ús dels dos punts (`:`) com a connector de dades.
* **1.3.3.** La llei estricta de la coma (`,`): Quan posar-la i on està prohibit fer-ho.
* **1.3.4.** Les claus (`{}`) com a caixes d'objectes i propietats.
* **1.3.5.** Els corxets (`[]`) com a llistes ordenades d'elements.

### MÒDUL 2: L'ANATOMIA DE L'ARREL (THE ROOT SCHEMA)

* **2.1.** El camp `"versio"`: El passaport de control del fitxer.
* **2.1.1.** Per què és obligatori i què passa si s'esborra.
* **2.1.2.** Com escriure correctament la versió semàntica (Ex: `"p1-0.1"`).
* **2.1.3.** El futur de la traçabilitat del model de dades sense alterar l'App.
* **2.2.** L'objecte `"preguntesBlocks"`: El magatzem global de continguts.
* **2.2.1.** Definició de blocs de preguntes independents.
* **2.2.2.** Com s'enllacen els blocs amb les pantalles visuals de l'aplicació.
* **2.3.** L'objecte `"fillsBlocks"`: El motor de relacions i dependències.
* **2.3.1.** Entendre el concepte de "Bloc Pare" i "Bloc Fill".
* **2.3.2.** Com dissenyar estructures repetitives (Ex: Múltiples vehicles o múltiples registres).

### MÒDUL 3: EL BLOC DE PREGUNTES (preguntesBlocks) A DETALL

* **3.1.** Estructura interna d'una pregunta estàndard (Camps obligatoris).
* **3.1.1.** `"nom_intern_de_la_pregunta"`: Creació de claus de referència úniques i format *snake_case*.
* **3.1.2.** `"numero"`: El control de l'ordre seqüencial de renderitzat.
* **3.1.3.** `"id_camp"`: La clau de registre única per a la base de dades RAM.
* **3.1.4.** `"enunciat"`: Redacció del text final per als usuaris finals.
* **3.1.5.** `"privat"`: Control de visibilitat i seguretat de dades.
* **3.2.** Catàleg de ginys visuals (`"tipus"`) i el seu comportament.
* **3.2.1.** Tipus `"bool"`: Botons selectors verticals de SÍ i NO.
* **3.2.2.** Tipus `"text"`: Camps de text lliure amb esborrat ràpid integrat.
* **3.2.3.** Tipus `"choice"`: Menús desplegables amb motor de cerca de selecció única.
* **3.2.4.** Tipus `"choice_multi"`: Desplegables tipus acordió per a selecció múltiple.

### MÒDUL 4: CONFIGURACIÓ DE MAPES INTERACTIUS SOBRE IMATGES

* **4.1.** L'ús de la imatge del cotxe (`cotxe_horitzontal.jpg`).
* **4.1.1.** L'orientació del canvas.
* **4.1.2.** Mapejat lateral.
* **4.1.3.** Definició d'àrees per a seients (`tipus: "imatge_zones"`).
* **4.1.4.** Definició d'àrees per a impactes i airbags (`tipus: "imatge_zones_multi"`).
* **4.2.** L'ús de la imatge anatòmica (`mapa_anatomic.jpg`).
* **4.2.1.** Divisió exacta del pla vertical al 50%.
* **4.2.2.** Configuració de la meitat esquerra: Projecció Anterior.
* **4.2.3.** Configuració de la meitat dreta: Projecció Posterior.
* **4.3.** El sistema de coordenades cartesianes decimals (0.0 a 1.0).
* **4.3.1.** Càlcul del punt d'origen (`left` i `top`).
* **4.3.2.** Càlcul de les dimensions del botó (`width` i `height`).
* **4.3.3.** Disseny de zones tàctils optimitzades.

### MÒDUL 5: EL MOTOR DE GENERACIÓ DINÀMICA (fillsBlocks) A DETALL

* **5.1.** Anatomia de la propietat de creació de sub-blocs.
* **5.1.1.** `"tipus_fill"`: Com indicar a l'aplicació quin tipus de mòdul ha de fabricar.
* **5.1.2.** `"titol_base"`: El text dinàmic que es pintarà al botó d'acció de la interfície.
* **5.2.** Com connecta el JSON amb el codi de la interfície d'usuari.
* **5.2.1.** El funcionament del giny `BotoCreacioBlocConcret`.
* **5.2.2.** Com calcula el sistema el número de component automàticament (Ex: Vehicle 1, Vehicle 2).
* **5.2.3.** Creació de dependències en cascada (Un registre principal té elements associats, un element té detalls).

### MÒDUL 6: GUIA D'OPERACIONS RÀPIDES (PAS A PAS DE MODIFICACIÓ)

* **6.1.** Operació d'Edició: Canviar textos, enunciats o llistes d'opcions.
* **6.2.** Operació d'Eliminació: Esborrar una pregunta o un sub-bloc de forma segura.
* **6.3.** Operació d'Addició: Copiar, enganxar i reconfigurar elements nous.
* **6.4.** Operació de Creació Absoluta: Com obrir un fitxer buit i aixecar un qüestionari de zero.

### MÒDUL 7: RESOLUCIÓ DE PROBLEMES I CONTROL DE QUALITAT

* **7.1.** Els 4 errors típics que fan caure l'aplicació (I com trobar-los).
* **7.1.1.** L'error de la coma penjant al final d'un bloc (*Trailing Comma*).
* **7.1.2.** L'error d'obrir unes cometes o una clau i no tancar-les.
* **7.1.3.** L'error de col·lisió per IDs duplicats a la base de dades RAM.
* **7.1.4.** L'error de coordenades decimals que superen el rang màxim de 1.0.
* **7.2.** Ús d'eines de validació externes (Com utilitzar JSONLint pas a pas).
* **7.3.** Checklist final de seguretat abans de desplegar el fitxer en entorns de producció.

> **Consell de navegació:** Si utilitzes un editor compatible amb Markdown (com VS Code, Obsidian o GitHub), pots fer clic directament sobre els títols dels mòduls per desplaçar-te de forma automàtica a la secció corresponent del document.

---

## MÒDUL 1: ELS FONAMENTS DEL LLENGUATGE JSON I L'ESQUELET MESTRE

### 1.1. Què és un fitxer JSON i per què els ordinadors són tan rígids llegint-lo

Un fitxer **JSON** (*JavaScript Object Notation*) no és un programa informàtic que executi accions, sinó un format de text simple dissenyat exclusivament per emmagatzemar i intercanviar informació estructurada. En el context de l'aplicació de gestió de formularis, el fitxer JSON actua com el "llibre d'instruccions" o la plantilla mestre que l'aplicació llegeix cada vegada que s'obre un qüestionari. En lloc de programar a mà cada pregunta dins del codi font de l'aplicació en Dart/Flutter, el sistema llegeix aquest fitxer de text, l'interpreta en la memòria RAM i dibuixa dinàmicament les pantalles, els botons i els formularis.

La rigidesa extrema dels ordinadors a l'hora de desxifrar un JSON prové de la naturalesa de la programació automatitzada. Els éssers humans disposem d'intel·ligència contextual: si llegim una frase on falta una coma, un punt final, o s'ha comès una falta d'ortografia, el nostre cervell omple els buits inconscientment i comprenem la intenció de l'emissor.

Un ordinador no pensa; avalua la sintaxi mitjançant un component de programari anomenat *parser* (analitzador sintàctic). El *parser* opera sota una lògica binària estricta d'operacions en cascada. Quan troba un caràcter inesperat (com una coma de més o una clau sense tancar), el flux lògic es trenca immediatament. L'aplicació no pot pressuposar què volia escriure l'usuari. Si ho fes, podria assignar una dada a una casella equivocada, provocant una corrupció estructural del qüestionari. Per salvaguardar la integritat de les dades, el sistema prefereix aturar-se i llançar una excepció o pantalla d'error abans de processar un text mal estructurat.

### 1.2. El mapa conceptual de l'estructura mestre: Relació entre l'arrel, les preguntes i la jerarquia de components

L'esquelet complet de qualsevol qüestionari de la nostra aplicació està governat per una estructura de tres pilars fonamentals continguts dins de l'arrel (*root*) del document. Aquesta arrel s'obre al primer caràcter del fitxer i es tanca a l'últim. Cap dada pot quedar fora.

L'esquelet mestre obligatori té aquest aspecte precís:

```JSON
{
  "versio": "1.0.0",
  "preguntesBlocks": {
    "bloc_principal": {
      "preguntes": []
    }
  },
  "fillsBlocks": {
    "bloc_principal": {
      "tipus_fill": "element_modul",
      "titol_base": "Element Afectat"
    }
  }
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

La relació jeràrquica d'aquests elements es configura com un arbre invertit:

1. **L'Arrel (The Root Object):** Representada per les claus inicials `{` i finals `}` del fitxer. És el contenidor universal. Si s'escriu qualsevol caràcter de text fora d'aquestes claus, el fitxer queda automàticament invalidat.
2. **El node `"versio"`:** És un camp de metadades horitzontal de tipus text. Tot i que actualment l'aplicació no utilitza aquest número per fer càlculs complexos, la seva presència és un requisit estructural del motor de càrrega. Actua com un passaport d'identificació del model.
3. **L'objecte `"preguntesBlocks"`:** És el catàleg o magatzem de continguts. Dins d'ell es defineixen, sota identificadors únics (com `"bloc_principal"`), les llistes de preguntes que la interfície mòbil mostrarà de manera seqüencial (els formularis de text, botons de SÍ/NO, o selectors de mapes).
4. **L'objecte `"fillsBlocks"`:** És el motor dinàmic o configurador de dependències en cascada. No conté preguntes, sinó instruccions de reproducció. Diu a l'aplicació: *"Quan estiguis renderitzant el bloc X, avalua si has d'afegir un botó especial a la part inferior per permetre que l'usuari creï infinits sub-blocs del tipus Y (per exemple, anar afegint elements o seccions a mesura que es requereixin)"*.

### 1.3. Les 5 Regles d'Or de la puntuació (Sintaxi per a no-programadors)

Perquè una persona sense experiència en programació pugui dominar la creació i modificació de qüestionaris sense por de trencar l'aplicació, ha de memoritzar i aplicar sistemàticament cinc regles d'ortografia digital.

#### 1.3.1. El secret de les cometes dobles (`""`) obligatòries

En JSON, tot el text conceptual —tant les etiquetes de configuració (claus) com els valors de tipus text (cadenes de text o *strings*)— ha d'estar encapsulat obligatòriament entre cometes dobles tradicionals (`""`).

* **Prohibició de cometes simples:** A diferència de llenguatges com JavaScript o Python, fer servir `'text'` provocarà un col·lapse immediat del validador.
* **Prohibició de cometes tipogràfiques:** Editors de text com Microsoft Word o WordPad canvien automàticament les cometes rectes per cometes corbes d'obertura i tancament (`“` i `”`). El *parser* informàtic no reconeix les cometes corbes com a delimitadors, sinó com a caràcters de text normals, fent que l'estructura falli. Fes servir sempre editors nets com Notepad++, VS Code o l'editor simple de notes del sistema operatiu.
* **Excepcions de cometes:** Els valors de tipus numèric (com `"numero": 1`) i els valors lògics booleans (com `"privat": false`) s'escriuen "nus", és a dir, sense cometes. Si poses `"1"` entre cometes, l'ordinador ho llegirà com el caràcter gràfic "un" i no com un número matemàtic, impedint que l'aplicació pugui ordenar correctament les preguntes a la pantalla.

#### 1.3.2. L'ús dels dos punts (`:`) com a connector de dades

Els dos punts actuen com el pont d'unió exclusiu entre una propietat i el seu contingut. Separen la "clau" (el nom del camp que l'aplicació busca internament) del "valor" (la configuració real d'aquell camp).

* **L'estructura és immutable:** `"etiqueta" : valor`
* La clau sempre se situa a l'esquerra dels dos punts, i el valor sempre se situa a la dreta.
* És una bona pràctica de lectura deixar un espai en blanc després dels dos punts per facilitar la revisió visual humana, però per a l'ordinador aquest espai buit és completament indiferent. El caràcter físic `:` és el que realitza el canvi d'estat en el lector de dades.

#### 1.3.3. La llei estricta de la coma (`,`): Quan posar-la i on està prohibit fer-ho

Aquesta és la font del 90% dels errors en l'edició manual de fitxers de configuració. La coma s'ha d'entendre estretament com un **separador d'elements consecutius**, mai com un finalitzador de línia.

* **On posar-la:** Si dins d'una caixa o d'una llista hi ha més d'una línia o més d'un element, s'ha de col·locar una coma al final de cada element per indicar al *parser* que hi ha un següent element en camí.
* **On està prohibit (L'error de la coma penjant o *Trailing Comma*):** L'últim element d'un bloc **mai** pot portar coma. Si es col·loca una coma després de l'últim component, el motor de l'aplicació intentarà saltar a una següent línia de dades que no existeix, interpretant que el fitxer està incomplet o tallat abruptament, provocant un error fatal de lectura.

*Exemple visual d'error i correcció:*

```JSON
// ERROR FATAL: Coma vermella que trenca el fitxer
{
  "id_camp": "codi_identificador",
  "tipus": "text", // <-- Correcte: hi ha una dada després
  "enunciat": "Introdueix el codi:" // <-- ERROR: Coma abans de tancar el bloc!
}

// CORRECTE
{
  "id_camp": "codi_identificador",
  "tipus": "text",
  "enunciat": "Introdueix el codi:" // <-- Net, sense coma. El bloc es tanca de manera segura.
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

#### 1.3.4. Les claus (`{}`) com a caixes d'objectes i propietats

Les claus funcionen com "contenidors de característiques" o "objectes". Tot el que s'agrupa dins d'una clau d'obertura `{` i una de tancament `}` defineix una única entitat amb diferents atributs.

* En el nostre qüestionari, cada pregunta és un objecte protegit dins de les seves pròpies claus. Totes les seves propietats internes (`numero`, `id_camp`, `tipus`, `enunciat`) descriuen aquesta pregunta específica.
* **La regla del tancament simètric:** Qualsevol modificació exigeix comprovar que cada clau que s'obre es tanqui posteriorment. Si mous o copies fragments, assegura't que no s'ha quedat cap clau de tancament `}` desplaçada o eliminada per error, ja que això causaria que una pregunta s'empassés visualment la següent.

#### 1.3.5. Els corxets (`[]`) com a llistes ordenades d'elements

Els corxets (també anomenats parèntesis quadrats) defineixen una **Llista** (o *Array*). S'utilitzen exclusivament quan una propietat necessita emmagatzemar un llistat de múltiples elements que tenen la mateixa naturalesa o importància, disposats en un ordre concret.

* Dins del nostre sistema, els corxets es fan servir principalment en dues situacions:

1. Per definir el llistat complet de preguntes que componen un mòdul: `"preguntes": [ ... ]`
2. Dins de les metadades d'un menú desplegable, per escriure les opcions triables pels usuaris: `"opcions": ["OPCIÓ A", "OPCIÓ B", "OPCIÓ C"]`

* Dins dels corxets s'aplica exactament la mateixa llei de les comes: es col·loquen comes per separar els elements interns (en aquest cas, les opcions de text), però l'últim element de la llista no en porta.

---

## MÒDUL 2: L'ANATOMIA DE L'ARREL (THE ROOT SCHEMA)

### 2.1. El camp `"versio"`: El passaport de control del fitxer

A la part superior absoluta del fitxer JSON, obrint les comportes de tota l'estructura de dades, es troba el camp `"versio"`. Aquest paràmetre funciona com un passaport d'identificació o una declaració de compatibilitat. Abans que l'aplicació llegeixi una sola pregunta o intenti dibuixar cap giny a la pantalla del dispositiu, el motor d'importació analitza aquest camp per verificar que les regles del joc escrites en el text coincideixen amb el que el codi intern de l'App és capaç d'entendre.

L'esquelet base configurat amb el nostre sistema de control d'identitat s'estructura de la següent manera:

```JSON
{
  "versio": "p1-0.1",
  "preguntesBlocks": {
    "bloc_principal": {
      "preguntes": []
    }
  },
  "fillsBlocks": {
    "bloc_principal": {
      "tipus_fill": "element_modul",
      "titol_base": "Element Afectat"
    }
  }
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

#### 2.1.1. Per què és obligatori i què passa si s'esborra

Dins de l'arquitectura de l'aplicació, el subprograma lector de fitxers està programat amb un ordre lògic seqüencial tancat. El primer pas del seu algorisme és cercar la clau exacta `"versio"`. La presència d'aquest camp és un requisit imposat per disseny per evitar errors catastròfics de lectura en la memòria RAM.

Si un editor esborra la línia per descuit, o si en modificar-la es destrueixen les cometes obligatòries, l'analitzador sintàctic (*parser*) de l'aplicació patirà una fallada immediata per component absent (*KeyNotFoundException*). Atès que el sistema operatiu de l'App no pot endevinar quin tipus de fitxer està intentant processar, bloquejarà el qüestionari de forma preventiva, mostrant una pantalla d'error o quedant-se congelat. Això es fa per seguretat: és preferible no obrir el document abans que permetre que dades crítiques es guardin en caselles equivocades de la base de dades per culpa d'una desalineació estructural.

#### 2.1.2. Com escriure correctament la versió semàntica (Ex: `"p1-0.1"`)

Per mantenir un control rigorós de l'evolució de l'aplicació i del contingut de les preguntes, s'utilitza una nomenclatura combinada personalitzada que divideix clarament la **compatibilitat de l'arquitectura** de la **revisió de contingut**. Aquest format s'escriu seguint el patró `"p[PROTOTIP]-[VERSIÓ]"` (com ara, `"p1-0.1"`).

Per a un gestor de formularis encarregat del manteniment del fitxer, el significat de cada bloc i les regles per modificar-los són els següents:

1. **L'identificador del Prototip (`p1`):** Aquesta primera part indica la versió de l'arquitectura base de l'aplicació amb la qual el qüestionari és totalment compatible.

* Si el codi de l'App pateix una reestructuració massiva en el futur (per exemple, es canvia la manera com Flutter renderitza els blocs o com el controlador gestiona el desat a la memòria RAM), es passarà al prototip 2 (`p2`).
* Un fitxer JSON marcat com a `p1` avisarà el sistema que utilitza el motor clàssic, evitant col·lisions de programari si s'intenta carregar en una aplicació moderna que requereixi estructures de tipus `p2`.

2. **El guionet de separació (`-`):** És el caràcter divisor obligatori de tipus text que serveix per delimitar el codi de la plataforma del codi de contingut.
3. **El comptador de versió del qüestionari (`0.1`):** És el dígit numèric incremental que gestiona exclusivament els canvis fets en les preguntes pels mateixos usuaris.

* **El número decimal (PATCH - Ex: de `0.1` a `0.2`):** S'incrementa quan es fan modificacions menors de text que no canvien l'estructura, com ara corregir una falta d'ortografia, reescriure un enunciat per fer-lo més entenedor, o afegir noves opcions a un desplegable de tipus `choice`.
* **El número sencer (MAJOR - Ex: de `0.1` a `1.0`):** S'incrementa quan s'afegeixen preguntes completament noves, s'eliminen blocs antics o es modifiquen els identificadors de base de dades (`id_camp`), fet que pot causar que els informes vells guardats al dispositiu s'hagin de llegir d'una manera diferent.

#### 2.1.3. El futur de la traçabilitat del model de dades sense alterar l'App

L'avantatge principal de comptar amb el passaport `"p1-0.1"` és aconseguir una independència total entre el contingut del formulari i l'aplicació instal·lada. Els protocols i necessitats de recollida d'informació canvien de manera habitual. Si cada vegada que s'hagués de modificar una pregunta calgués recompilar l'aplicació i pujar-la a les botigues privades d'aplicacions (Google Play o App Store), la gestió seria lenta i ineficient.

Amb aquest sistema, quan el comitè tècnic decideix actualitzar el qüestionari (per exemple, per passar a la versió `0.2`), només cal editar aquest fitxer de text JSON i penjar-lo en un servidor central. Quan els dispositius es connecten a la xarxa, descarreguen el text, llegeixen que segueix sent compatible amb l'arquitectura de Prototip 1 (`p1`) i l'actualitzen en calent. L'App actua com un intèrpret pur: llegeix el passaport de la versió, reconeix les instruccions del model i altera els formularis a l'acte sense requerir cap intervenció dels programadors.

### 2.2. L'objecte `"preguntesBlocks"`: El magatzem global de continguts

L'objecte `"preguntesBlocks"` opera com el magatzem central o catàleg general del nostre sistema. És una gran caixa organitzadora que conté, degudament etiquetats, tots els formularis conceptuals que es podran desplegar al llarg d'una operació.

#### 2.2.1. Definició de blocs de preguntes independents

En lloc de dissenyar un fitxer pla on les preguntes principals i les secundàries estiguin barrejades (cosa que faria impossible la navegació en pantalles tàctils), `"preguntesBlocks"` permet encapsular la informació en seccions modulars i completament independents.

Cada secció es defineix mitjançant una clau textual única que actua com l'identificador del bloc, i a dins allotja un llistat estructurat anomenat `"preguntes"` on es disposen els corxets `[]`. Veiem la seva sintaxi i com se separen mitjançant l'ús correcte de les comes:

```JSON
"preguntesBlocks": {
  "bloc_principal": {
    "preguntes": [
      // Mòdul 1: Aquí s'inclouen exclusivament les dades principals
    ]
  }, // <-- Coma obligatòria: indica al parser que hi ha un altre bloc a continuació
  "element_modul": {
    "preguntes": [
      // Mòdul 2: Aquí s'inclouen les preguntes secundàries de detall
    ]
  } // <-- Sense coma: és el final del magatzem de blocs
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

Aquesta independència garanteix que cada bloc funcioni com un compartiment estanc. Si necessites afegir o treure una pregunta d'un mòdul secundari, ho pots fer còmodament obrint i tancant els seus corxets específics, sense por d'afectar la configuració de les preguntes del bloc principal.

#### 2.2.2. Com s'enllacen els blocs amb les pantalles visuals de l'aplicació

El lligam entre aquest text immòbil del JSON i els elements visuals que l'usuari pot prémer a la pantalla es realitza a través d'un coordinador d'interfície anomenat `BlocUniversalWidget`.

El flux d'operació de l'aplicació funciona seguint aquests passos:

1. Quan l'usuari navega pel menú lateral del dispositiu i selecciona una secció activa, l'App rep un senyal amb el codi intern d'aquella ruta (per exemple, `element_modul`).
2. El sistema agafa aquest codi, es desplaça fins a l'objecte `"preguntesBlocks"` del fitxer JSON i busca el bloc que es digui exactament igual.
3. Un cop localitzat, extreu la llista de mapes que hi ha dins dels corxets de `"preguntes"` i els envia en cascada a la classe `FabricaPreguntes.construir`.
4. Aquesta fàbrica llegeix de forma seqüencial el paràmetre `"tipus"` de cada línia (com ara `"bool"`, `"text"` o `"choice"`) i els converteix a l'acte en ginys d'interfície reals de Flutter (`WidgetPreguntaBool`, `WidgetPreguntaText`, etc.), pintant a la pantalla les targetes amb els botons de SÍ/NO, els quadres de text netejables o els selectors desplegables.

### 2.3. L'objecte `"fillsBlocks"`: El motor de relacions i dependències

Si l'objecte anterior definia la llista de preguntes (el contingut estàtic), l'objecte `"fillsBlocks"` s'encarrega d'establir les regles de comportament (la dinàmica interactiva). És el component lògic que determina com s'enllacen els mòduls entre si i com reacciona el formulari a mesura que el registre es fa més gran o complex.

#### 2.3.1. Entendre el concepte de "Bloc Pare" i "Bloc Fill"

Dins d'un entorn de recollida de dades real, la informació no és lineal, sinó que es ramifica de manera natural en funció dels elements implicats. Un registre general no és només un llistat de dades; és un succés central del qual depenen altres elements, que al seu torn contenen sub-elements. Per traslladar aquesta realitat al fitxer de configuració, el JSON utilitza una estructura jeràrquica de **Pare i Fill**:

* **El Bloc Pare (Parent Node):** És el mòdul d'origen o contenidor de rang superior. Per exemple, el bloc de dades generals (`"bloc_principal"`).
* **El Bloc Fill (Child Node):** És un mòdul dependent que neix orgànicament des de l'interior del pare i que no tindria cap sentit si el pare no existís prèviament. Per exemple, la fitxa tècnica d'un element afectat és un fill que depèn directament de l'existència del registre principal; d'igual manera, el detall d'un component és un fill que depèn estructuralment de la fitxa de l'element on s'ubica.

#### 2.3.2. Com dissenyar estructures repetitives (Ex: Múltiples vehicles o múltiples registres)

L'autèntic poder del motor de `"fillsBlocks"` és que evita haver de duplicar codi de manera innecessària. Si en un registre hi ha implicats diversos elements, no cal escriure múltiples vegades les mateixes preguntes dins del JSON. El bloc es defineix una única vegada a `"preguntesBlocks"`, i a `"fillsBlocks"` s'especifica la instrucció de replicació dinàmica en memòria.

Per aconseguir que un bloc pare pugui generar infinits sub-blocs repetitius, s'utilitzen dues propietats clau:

* `"tipus_fill"`: El codi exacte del bloc de `"preguntesBlocks"` que s'utilitzarà com a plantilla o motlle de fabricació.
* `"titol_base"`: El text humà que el motor gràfic pintarà a l'interior del botó interactiu a la pantalla.

Analitzem com es dissenya aquesta xarxa de dependències en cascada:

```JSON
"fillsBlocks": {
  "bloc_principal": {
    "tipus_fill": "element_modul",
    "titol_base": "Element Afectat"
  },
  "element_modul": {
    "tipus_fill": "detall_component",
    "titol_base": "Detall de Component"
  }
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

**Com s'executa aquesta lògica pas a pas en la interfície d'usuari?**

1. Mentre l'usuari es troba contestant les preguntes inicials de l'arrel (`"bloc_principal"`), l'arquitectura de l'App consulta `"fillsBlocks"` i veu que aquest node té una relació de paternitat associada.
2. Automàticament, el sistema activa a la part inferior de la pantalla el giny `BotoCreacioBlocConcret`, dibuixant un botó estilitzat amb una icona de suma que diu: **"Afegir Element Afectat"** (agafant el text de `"titol_base"`).
3. Cada vegada que l'usuari prem aquest botó, el controlador de l'App clona l'estructura buida definida a `"element_modul"` i genera instantàniament un sub-bloc independent vinculat en RAM (calculant de manera automàtica els noms virtuals: Element Afectat 1, Element Afectat 2, Element Afectat 3...).
4. Gràcies a l'estructura en cascada, quan l'usuari accedeixi a la pantalla de gestió de l' "Element Afectat 1", el motor avaluarà que `"element_modul"` és al seu torn pare de `"detall_component"`. Per tant, pintarà a baix de tot un nou botó dinàmic: **"Afegir Detall de Component"**, desplegando una jerarquia tridimensional neta (Registre -> Element 1 -> Component 1) gestionada de forma transparent per un únic bloc de text de configuració.

---

## MÒDUL 3: EL BLOC DE PREGUNTES (`preguntesBlocks`) A DETALL

### 3.1. Estructura interna d'una pregunta estàndard (Camps obligatoris)

Tota pregunta o camp d'entrada definit dins del llistat `"preguntes"` d'un bloc ha de complir amb una estructura de propietats obligatòries. Aquestes propietats permeten al sistema identificar la dada a la base de dades, ordenar-la a la interfície i determinar com s'ha de renderitzar.

Un exemple de pregunta tipus ben estructurada té l'aspecte següent:

```JSON
{
  "nom_intern_de_la_pregunta": "estat_element",
  "numero": 1,
  "id_camp": "element_estat_opt",
  "enunciat": "Indica l'estat general de l'element seleccionat:",
  "privat": false,
  "tipus": "choice",
  "opcions": ["Operatiu", "En revisió", "Fora de servei"]
}

```

#### 3.1.1. `"nom_intern_de_la_pregunta"`: Creació de claus de referència úniques i format *snake_case*

Aquest camp s'utilitza com a identificador d'alt nivell o etiqueta de lectura humana per als desenvolupadors i administradors del fitxer.

* **Formateig *snake_case*:** S'ha d'escriure sempre en minúscules, sense accents, sense caràcters especials (com `ñ` o signes de puntuació) i substituint els espais en blanc per guions baixos (`_`).
* **Unicitat:** Tot i que no s'escriu directament a la base de dades final, és una bona pràctica que no es repeteixi dins del mateix bloc per evitar confusions durant les tasques de manteniment.

#### 3.1.2. `"numero"`: El control de l'ordre seqüencial de renderitzat

El paràmetre `"numero"` és un valor de tipus numèric enter (sense cometes) que determina la posició vertical en la qual es pintarà la pregunta dins de la pantalla de l'aplicació.

* L'aplicació ordena les preguntes de menor a major segons aquest valor.
* Es recomana utilitzar seqüències primàries simples (`1`, `2`, `3`...). En cas de voler reordenar elements en el futur, reassignar els números de manera consecutiva garanteix que la interfície mantingui una estructura fluida i predictible.

#### 3.1.3. `"id_camp"`: La clau de registre única per a la base de dades RAM

Aquest és el camp més crític per a la integritat de les dades. El valor d' `"id_camp"` és la clau exacta amb la qual l'aplicació desarà la resposta de l'usuari en el registre temporal de la memòria RAM i en l'exportació final de dades.

* **Regla absoluta d'unicitat:** Dos camps diferents dins del mateix formulari no poden compartir mai el mateix `"id_camp"`. Si dos camps tenen la mateixa clau, la resposta del segon camp sobreescriurà la dada del primer en la memòria, provocant la pèrdua d'informació.
* **Estabilitat:** Un cop desplaçat un formulari a entorns de producció, l' `"id_camp"` no s'ha de modificar mai, ja que les consultes històriques i els sistemes d'exportació depenen d'aquesta clau exacta.

#### 3.1.4. `"enunciat"`: Redacció del text final per als usuaris finals

És la cadenes de text (`string`) que es mostrarà visualment a la pantalla del dispositiu com a títol o instrucció de la pregunta.

* Ha d'estar redactat de manera clara, concisa i accessible per a l'usuari final.
* Admet caràcters especials, accents, signes de puntuació i espais amb total llibertat, sempre que estigui correctament delimitat entre cometes dobles (`""`).

#### 3.1.5. `"privat"`: Control de visibilitat i seguretat de dades

És un valor booleà (`true` o `false`, sense cometes) que indica al motor de renderitzat si la pregunta conté informació d'accés restringit o d'ús intern.

* Si s'estableix en `false`, el camp es mostra amb normalitat en la interfície estàndard i s'inclou en els informes ordinaris.
* Si s'estableix en `true`, l'aplicació pot aplicar regles de filtratge per ocultar el camp a determinats rols d'usuari o excloure'l de les vistes resumides de control.

---

### 3.2. Catàleg de ginys visuals (`"tipus"`) i el seu comportament

La propietat `"tipus"` indica a la fàbrica de components de l'aplicació quin giny visual de Flutter ha d'instanciar a la pantalla. A continuació es detallen els tipus de dades bàsics suportats:

#### 3.2.1. Tipus `"bool"`: Botons selectors verticals de SÍ i NO

S'utilitza per a preguntes de confirmació binària. Renderitza una targeta visual amb dos botons clarament diferenciats: un per a opció afirmativa (SÍ) i un altre per a opció negativa (NO).

```JSON
{
  "nom_intern_de_la_pregunta": "verificacio_element",
  "numero": 1,
  "id_camp": "element_verificat_bool",
  "enunciat": "S'ha completat la verificació de l'element?",
  "privat": false,
  "tipus": "bool"
}

```

#### 3.2.2. Tipus `"text"`: Camps de text lliure amb esborrat ràpid integrat

Genera un quadre d'entrada de text alfanumèric lliure. Inclou automàticament un botó integrat a la dreta del camp per netejar el contingut de la casella amb una sola pulsació.

```JSON
{
  "nom_intern_de_la_pregunta": "observacions_generals",
  "numero": 2,
  "id_camp": "element_obs_text",
  "enunciat": "Observacions addicionals:",
  "privat": false,
  "tipus": "text"
}

```

#### 3.2.3. Tipus `"choice"`: Menús desplegables amb motor de cerca de selecció única

Permet a l'usuari seleccionar una sola opció d'un llistat definit. Aquest giny desplega un menú emergent que inclou una barra de cerca a la part superior, permetent a l'usuari filtrar ràpidament entre opcions quan la llista és extensa.

* **Camp obligatori addicional:** Requerix la propietat `"opcions"`, que conté un llistat de cadenes de text entre corxets.

```JSON
{
  "nom_intern_de_la_pregunta": "categoria_element",
  "numero": 3,
  "id_camp": "element_cat_choice",
  "enunciat": "Selecciona la categoria corresponent:",
  "privat": false,
  "tipus": "choice",
  "opcions": ["Categoria A", "Categoria B", "Categoria C", "Altres"]
}

```

#### 3.2.4. Tipus `"choice_multi"`: Desplegables tipus acordió per a selecció múltiple

Dissenyat per a situacions on l'usuari pot marcar múltiples opcions simultàniament. Es mostra com un panell desplegable tipus acordió que s'amplia en prémer-lo, mostrant caselles de verificació (*checkboxes*) per a cada opció disponible.

```JSON
{
  "nom_intern_de_la_pregunta": "components_afectats",
  "numero": 4,
  "id_camp": "element_comp_multi",
  "enunciat": "Marca tots els components afectats:",
  "privat": false,
  "tipus": "choice_multi",
  "opcions": ["Estructura", "Sistema elèctric", "Coberta", "Sistemes auxiliars"]
}

```

---

## MÒDUL 4: CONFIGURACIÓ DE MAPES INTERACTIUS SOBRE IMATGES

L'aplicació permet la configuració de selector gràfics interactius sobre imatges de referència (com diagrames d'equips, esquemes de zonificació o mapes anatòmics). Aquests ginys tradueixen les pulsacions de l'usuari a sobre de la imatge en dades estructurades de coordenades o zones seleccionades.

---

### 4.1. L'ús de la imatge d'equips o vehicles (`esquema_horitzontal.jpg`)

S'utilitza per a la selecció gràfica de components o àrees d'afectació sobre un esquema horitzontal predefinit.

```JSON
{
  "nom_intern_de_la_pregunta": "mapa_impacte_equip",
  "numero": 1,
  "id_camp": "equip_dammages_map",
  "enunciat": "Selecciona visualment les zones afectades sobre l'esquema:",
  "privat": false,
  "tipus": "imatge_zones_multi",
  "imatge_fons": "esquema_horitzontal.jpg",
  "zones": [
    {
      "id_zona": "zona_frontal",
      "etiqueta": "Sector Frontal",
      "left": 0.05,
      "top": 0.20,
      "width": 0.25,
      "height": 0.60
    },
    {
      "id_zona": "zona_lateral_esquerra",
      "etiqueta": "Lateral Esquerre",
      "left": 0.30,
      "top": 0.10,
      "width": 0.40,
      "height": 0.25
    }
  ]
}

```

#### 4.1.1. L'orientació del canvas

El *canvas* o llenç de dibuix es calcula sempre en proporció a l'amplada i alçada de la imatge de fons especificada a `"imatge_fons"`. L'aplicació escala automàticament la imatge per adaptar-la a l'amplada de la pantalla del dispositiu mantenint la relació d'aspecte (*aspect ratio*).

#### 4.1.2. Mapejat lateral i de sectors

Les zones interactives es defineixen com a àrees rectangulars invisibles (o semitransparents quan es seleccionen) que se situen per sobre de la imatge utilitzant el sistema de coordenades percentuals.

#### 4.1.3. Definició d'àrees per a selecció única (`tipus: "imatge_zones"`)

Quan el tipus es configura com a `"imatge_zones"`, el giny es comporta com un selector de radiobotó (*radio button*): l'usuari només pot tenir una única zona seleccionada sobre la imatge. Si en prem una de nova, la selecció anterior es desmarca automàticament.

#### 4.1.4. Definició d'àrees per a selecció múltiple (`tipus: "imatge_zones_multi"`)

En la modalitat `"imatge_zones_multi"`, l'usuari pot tocar i marcar múltiples sectors de la imatge simultàniament. La dada guardada a la base de dades serà una llista dels identificadors de totes les zones que s'hagin activat.

---

### 4.2. L'ús de la imatge anatòmica (`mapa_anatomic.jpg`)

S'utilitza específicament en qüestionaris de registre mèdic o d'avaluació de personal per delimitar regions corporals afectades.

```JSON
{
  "nom_intern_de_la_pregunta": "localitzacio_lesions",
  "numero": 1,
  "id_camp": "anatomic_zones_map",
  "enunciat": "Indica sobre el mapa corporal les regions afectades:",
  "privat": false,
  "tipus": "imatge_zones_multi",
  "imatge_fons": "mapa_anatomic.jpg",
  "zones": [
    {
      "id_zona": "cap_anterior",
      "etiqueta": "Cap (Vista Anterior)",
      "left": 0.18,
      "top": 0.02,
      "width": 0.14,
      "height": 0.12
    },
    {
      "id_zona": "torax_anterior",
      "etiqueta": "Tòrax (Vista Anterior)",
      "left": 0.12,
      "top": 0.15,
      "width": 0.26,
      "height": 0.25
    }
  ]
}

```

#### 4.2.1. Divisió exacta del pla vertical al 50%

La imatge d'avaluació corporal està dividida verticalment en dues meitats exactes:

* **De `0.0` a `0.5` d'amplada (eix horizontal `left`):** Correspon a la projecció o vista **Anterior** (frontal).
* **De `0.5` a `1.0` d'amplada (eix horizontal `left`):** Correspon a la projecció o vista **Posterior** (dorsal).

#### 4.2.2. Configuració de la meitat esquerra: Projecció Anterior

Totes les zones definides per a la cara frontal de la imatge han de mantenir valors de `left` i una amplada `width` que, sumats, no superin mai el límit de `0.50`.

#### 4.2.3. Configuració de la meitat dreta: Projecció Posterior

Totes les zones destinades a la part dorsal han de començar amb un valor de `left` igual o superior a `0.50`.

---

### 4.3. El sistema de coordenades cartesianes decimals (0.0 a 1.0)

Per garantir que les zones tàctils s'ubiquin exactament al mateix lloc independentment de la mida o resolució de la pantalla del dispositiu (telèfon mòbil, tauleta, etc.), el sistema no utilitza píxels fixos, sinó un **sistema de coordenades decimals unificades relatives** d' `0.0` a `1.0`.

```
(0.0, 0.0) ------------------------ (1.0, 0.0)
|                                           |
|       left: 0.10, top: 0.20               |
|       +------+                            |
|       | Zona | height: 0.15               |
|       +------+                            |
|       width: 0.30                         |
|                                           |
(0.0, 1.0) ------------------------ (1.0, 1.0)

```

#### 4.3.1. Càlcul del punt d'origen (`left` i `top`)

* **`left` (Posició X):** Distància des de la línia esquerra de la imatge fins a la línia esquerra del botó. Ex: `0.10` equival al 10% d'amplada de la imatge des de l'esquerra.
* **`top` (Posició Y):** Distància des de la línia superior de la imatge fins a la línia superior del botó. Ex: `0.20` equival al 20% d'alçada de la imatge des de dalt.

#### 4.3.2. Càlcul de les dimensions del botó (`width` i `height`)

* **`width` (Amplada de la zona):** Ample que ocuparà el botó tàctil expressat en percentatge del total de la imatge.
* **`height` (Alçada de la zona):** Altura que ocuparà el botó tàctil expressat en percentatge del total de la imatge.

#### 4.3.3. Disseny de zones tàctils optimitzades

* **Mida mínima recomanada:** Es recomana que cap àrea tàctil tingui una amplada o alçada inferior a `0.08` (8% de la imatge) per garantir que pugui ser premuda fàcilment amb el dit en pantalles petites.
* **Comprovació de límits:** La suma de `left + width` mai pot superar `1.0`. D'igual manera, la suma de `top + height` mai pot superar `1.0`. Qualsevol valor superior a `1.0` farà que el botó s'imprimeixi fora dels límits visibles de la imatge.


---

## MÒDUL 5: EL MOTOR DE GENERACIÓ DINÀMICA (`fillsBlocks`) A DETALL

### 5.1. Anatomia de la propietat de creació de sub-blocs

L'objecte `"fillsBlocks"` defineix les regles per generar instàncies dinàmiques de formularis dependents durant l'emplenament d'un qüestionari. En lloc de duplicar estructures de preguntes en el document, s'estableix un vincle entre el bloc actual (pare) i el bloc secundari (fill) que es crearà a petició de l'usuari.

Un exemple de configuració de sub-blocs és el següent:

```JSON
"fillsBlocks": {
  "bloc_principal": {
    "tipus_fill": "element_modul",
    "titol_base": "Element Afectat"
  },
  "element_modul": {
    "tipus_fill": "detall_component",
    "titol_base": "Detall de Component"
  }
}

```

> Nota: la combinació de "/" més "/" (és a dir, "//") s'utilitza per introduir comentaris, és a dir, text que és invisible per a la finalitat o el llenguatge fet servir, per aportar informació d'alguna classe per al lector humà.

#### 5.1.1. `"tipus_fill"`: Com indicar a l'aplicació quin tipus de mòdul ha de fabricar

Aquesta propietat especifica la clau exacta del bloc definit prèviament a `"preguntesBlocks"` que s'utilitzarà com a plantilla per a la generació del sub-formulari.

* El valor ha de coincidir exactament, caràcter per caràcter (incloent majúscules, minúscules i guions baixos), amb l'identificador del bloc de preguntes corresponent.

#### 5.1.2. `"titol_base"`: El text dinàmic que es pintarà al botó d'acció de la interfície

És el text de referència que utilitzarà la interfície per als elements interactius de creació. A partir d'aquesta cadena de text, l'aplicació generarà automàticament els títols i etiquetes dels nous registres creats (per exemple: "Element Afectat 1", "Element Afectat 2").

---

### 5.2. Com connecta el JSON amb el codi de la interfície d'usuari

#### 5.2.1. El funcionament del giny `BotoCreacioBlocConcret`

Quan el motor de renderitzat detecta que el bloc actiu té una entrada a `"fillsBlocks"`, afegeix automàticament a la part inferior de la vista el component `BotoCreacioBlocConcret`. Aquest botó permet a l'usuari afegir instàncies addicionals del sub-bloc sense eixir del flux principal de treball.

#### 5.2.2. Com calcula el sistema el número de component automàticament

El controlador de l'aplicació manté un comptador d'instàncies en la memòria RAM per a cada tipus de sub-bloc generat. Quan es prem el botó de creació:

1. Incrementa el comptador intern en una unitat.
2. Assigna un identificador únic a la nova instància (per exemple, `element_modul_1`).
3. Clona l'estructura de preguntes associada i la renderitza dins del contenidor de la interfície.

#### 5.2.3. Creació de dependències en cascada

És possible establir múltiples nivells de jerarquia (Pare -> Fill -> Sub-fill). Cada nivell avalua la seva pròpia entrada a `"fillsBlocks"`, permetent estructures complexes d'agrupació de dades mantingudes de manera totalment independent.

---

## MÒDUL 6: GUIA D'OPERACIONS RÀPIDES (PAS A PAS DE MODIFICACIÓ)

### 6.1. Operació d'Edició: Canviar textos, enunciats o llistes d'opcions

Per modificar el text d'una pregunta o actualitzar les opcions d'un menú desplegable:

1. Localitza el bloc corresponent dins de `"preguntesBlocks"`.
2. Ubica la pregunta concreta utilitzant el seu `"nom_intern_de_la_pregunta"` o `"numero"`.
3. Edita la cadena de text compresa entre les cometes de la propietat `"enunciat"`.
4. Si es tracta d'un tipus `"choice"` o `"choice_multi"`, modifica o afegeix les cadenes de text dins de la llista `"opcions"`, assegurant-te de separar els elements amb comes (excepte l'últim).
5. Desa el fitxer i valida la sintaxi JSON.

### 6.2. Operació d'Eliminació: Esborrar una pregunta o un sub-bloc de forma segura

Per eliminar una pregunta existent sense trencar l'estructura del document:

1. Selecciona tot l'objecte comprensat entre la clau d'obertura `{` i la clau de tancament `}` de la pregunta.
2. Elimina la selecció.
3. Revisa la línia anterior o posterior: si la pregunta eliminada no era l'última del llistat, assegura't que l'element anterior manté la coma de separació. Si era l'últim element, elimina la coma sobrant de l'element anterior.
4. Ajusta la seqüència del camp `"numero"` en les preguntes restants si és necessari.

### 6.3. Operació d'Addició: Copiar, enganxar i reconfigurar elements nous

Per afegir una nova pregunta a un formulari:

1. Copia un objecte de pregunta del mateix tipus per utilitzar-lo com a plantilla.
2. Enganxa el bloc en la posició desitjada dins del llistat `"preguntes"`.
3. Assegura les comes de separació entre objectes.
4. Assigna un `"id_camp"` únic i no utilitzat anteriorment.
5. Actualitza el `"nom_intern_de_la_pregunta"`, el `"numero"` d'ordre i l' `"enunciat"`.

### 6.4. Operació de Creació Absoluta: Com obrir un fitxer buit i aixecar un qüestionari de zero

Per crear un nou fitxer de formulari complet:

1. Crea un fitxer de text en blanc amb extensió `.json`.
2. Escriu l'estructura d'arrel bàsica:
```JSON
{
  "versio": "p1-0.1",
  "preguntesBlocks": {},
  "fillsBlocks": {}
}

```


3. Afegeix els blocs de preguntes necessaris dins de `"preguntesBlocks"`.
4. Defineix les preguntes i camps d'entrada per a cada bloc.
5. Configura les relacions entre blocs dins de `"fillsBlocks"` si requereixes sub-formularis dinàmics.
6. Valida el fitxer complet mitjançant una eina de verificació sintàctica.

---

## MÒDUL 7: RESOLUCIÓ DE PROBLEMES I CONTROL DE QUALITAT

### 7.1. Els 4 errors típics que fan caure l'aplicació (I com trobar-los)

#### 7.1.1. L'error de la coma penjant al final d'un bloc (*Trailing Comma*)

Col·locar una coma després de l'últim element d'un objecte o llista és l'error de sintaxi més freqüent. Provoca que l'analitzador sintàctic aturi la lectura del fitxer.

* **Simptoma:** L'aplicació no carrega el formulari o mostra un error d'anàlisi sintàctica (*unexpected character*).
* **Solució:** Revisar l'últim element abans de cada clau `}` o corxet `]` de tancament i eliminar la coma sobrant.

#### 7.1.2. L'error d'obrir unes cometes o una clau i no tancar-les

Si oblides tancar un parell de cometes `""` o un delimitador `{}` / `[]`, la resta del document s'interpretarà de manera errònia.

* **Simptoma:** Error de lectura en línies posteriors que aparentment estan ben escrites.
* **Solució:** Utilitzar un editor de codi amb ressaltat de sintaxi per identificar parells de delimitadors no tancats.

#### 7.1.3. L'error de col·lisió per IDs duplicats a la base de dades RAM

Assignar el mateix `"id_camp"` a dues preguntes diferents no genera un error de sintaxi JSON, però invalida el registre de dades.

* **Simptoma:** Les respostes d'una pregunta sobreescriuen les d'una altra o es perden dades en desar el formulari.
* **Solució:** Fer una cerca de text en el fitxer per comprovar que cada `"id_camp"` és únic.

#### 7.1.4. L'error de coordenades decimals que superen el rang màxim de 1.0

En la configuració de mapes interactius sobre imatges, indicar valors superiors a `1.0` o sumes de `left + width` / `top + height` que superin la unitat.

* **Simptoma:** Zones tàctils desplaçades fora de la imatge o botons no premibles.
* **Solució:** Recalcular els valors percentuals assegurant que cap posició o mida excedeixi el rang de `0.0` a `1.0`.

---

### 7.2. Ús d'eines de validació externes (Com utilitzar JSONLint pas a pas)

Abans de desplegar qualsevol fitxer de configuració JSON en entorns de producció o de proves, s'ha de validar la seva estructura sintàctica.

1. Accedeix a un validador en línia com [JSONLint](https://jsonlint.com/) o utilitza l'extensió de validació del teu editor de text (VS Code, Notepad++).
2. Copia el contingut complet del fitxer JSON i enganxa'l al quadre de text de l'eina.
3. Prem el botó **Validate JSON**.
4. Si el fitxer conté errors, l'eina indicarà el número de línia exacte i el tipus d'error detectat per procedir a la seva correcció.

---

### 7.3. Checklist final de seguretat abans de desplegar el fitxer en entorns de producció

Abans d'enviar o publicar un nou fitxer de formulari, comprova els següents punts:

* [ ] El camp `"versio"` està present i segueix el format definit (`"p1-X.X"`).
* [ ] El fitxer ha passat la validació sintàctica en una eina externa sense cap error.
* [ ] Tots els camps `"id_camp"` són únics al llarg de tot el document.
* [ ] Totes les preguntes de tipus `"choice"` i `"choice_multi"` tenen la propietat `"opcions"` amb almenys un element.
* [ ] Els blocs referenciats a `"fillsBlocks"` (`"tipus_fill"`) existeixen exactament amb el mateix nom a `"preguntesBlocks"`.
* [ ] En les imatges de zones, cap coordenada o dimensió supera el valor `1.0`.