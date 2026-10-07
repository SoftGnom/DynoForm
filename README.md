# 📋 DynoForm - Sistema de Recollida de Dades i Gestió d'Actuacions de Camp

Aquest projecte consisteix en una plataforma integrada per a la recollida, gestió i sincronització de dades en actuacions de camp i serveis d'emergència. El sistema està dissenyat amb una filosofia *offline-first*, garantint la continuïtat operativa sense connexió a internet, una interfície dinàmica adaptable mitjançant plantilles externes i un compliment estricte del Reglament General de Protecció de Dades (RGPD).

---

## 🛠️ Arquitectura i Tecnologies Principals

El sistema s'estructura en dues capes principals totalment desarticulades: el client mòbil/tablet i el servidor central.

### 📱 Client (Aplicació Mòbil / Tablet)

* **Framework**: Desenvolupat en **Flutter (Dart)** per oferir alt rendiment i consistència visual multi-plataforma (Android, Linux, Windows).


* **Base de Dades Local (Offline-First)**: Utilitza la base de dades NoSQL **Sembast** per emmagatzemar registres i formularis en local.


* **Seguretat en Repòs**: Protecció i xifratge local de dades mitjançant **AES-256**.


* **Motor Dinàmic de Formularis**: Interpretació de plantilles de qüestionaris en format JSON/YAML, permetent modificar l'estructura dels formularis sense necessitat de recompilar l'aplicació.



### 🖥️ Servidor (Backend & Persistència)

* **API Backend**: Desenvolupada amb **Python (FastAPI)** per a la gestió asíncrona de peticions, verificació d'integritat i gestió de tauletes.


* **Proxy Invers & HTTPS**: **Nginx** gestiona la terminació SSL/TLS i aïlla el backend de la xarxa externa.


* **Base de Dades NoSQL**: Clúster de **MongoDB** per a la persistència d'incidents, auditories i metadades.


* **Contenidors**: Execució aïllada amb **Podman (Rootless)** per minimitzar la superfície d'atac i garantir la seguretat del sistema.


* **Segregació RGPD**: Separació estricta entre dades públiques (operatives) i privades (confidencials), validant la integritat mitjançant hashes SHA256 i JSON canònic.



---

## 📂 Estructura del Repositori

```text
.
├── 01-Documentacio/          # Documentació tècnica i disseny del sistema
│   ├── 01-Objectius_i_Requisits/
│   │   └── 01-Objectius i Requisits.md   # Especificació d'objectius i requisits
│   ├── 02-App Completa/
│   │   ├── 01-Arquitectura_del_Sistema.png
│   │   └── 01-Codi_i_Link-Diagrama_d'Arquitectura_del_Sistema.md # Diagrama Mermaid global
│   └── 03-Prototip 1/
│       ├── 02-Diagrama-prototip_1.md     # Diagrames de classes i arquitectura
│       ├── 02-Diagrama-prototip_1-Servidor.png
│       └── 03-Tecnologies.md             # Especificació tecnològica detallada
│
└── 02-Software/              # Codi font i executables del sistema
    ├── 01-Client-V1.01/      # Mòdul de l'aplicació client (Flutter)
    │   ├── 01-Codi_Flutter/              # Codi font en Dart/Flutter
    │   ├── 02-Executables/               # Executables portables (Android, Linux, Windows)
    │   └── 03-Manuals_Suport/            # Guia d'ús client i manual de qüestionaris JSON
    │
    └── 02-Servidor/          # Mòdul del backend (FastAPI, Nginx, MongoDB)
        ├── 01-Codi/                      # Entorns de desplegament (Versió Local i Servidor)
        │   ├── 01-Servidor_Prototip_1-VersioLocal/
        │   └── 02-Servidor_Prototip_1-VersioServidor/
        └── 02-Manuals_Suport/            # Manuals d'operació de Podman i del servidor

```

---

## 🎯 Objectius Clau del Sistema

1. **Efectivitat a Peu de Camp**: Reduir el temps de recollida d'informació a menys de 10 minuts per actuació.


2. **Resiliència Offline-First**: Preservar el 100% de les dades introduïdes durant períodes de desconnexió i sincronitzar-les automàticament en restablir-se l'enllaç.


3. **Intel·ligència de Dades i Formularis Adaptatius**: Modificació dinàmica de la lògica dels qüestionaris mitjançant la publicació de fitxers de configuració JSON.


4. **Privadesa des del Disseny (RGPD)**: Pseudonimització de dades personals, xifratge extrem a extrem (AES-256 i TLS 1.3) i generació de logs d'auditoria immutables.



---

## 🚀 Guia d'Inici Ràpid

### 1. Execució de l'Aplicació Client (Tablet)

Dins del directori `02-Software/01-Client-V1.01/` trobareu diferents formes d'execució:

* **Executables Directes (`02-Executables/`)**:
* **Windows**: Executar el fitxer `arrancar_windows.bat` de la versió desitjada.


* **Linux**: Executar l'script `./arrancar_linux.sh`.


* **Android**: Instal·lar el paquet `app-release.apk`.




* **Codi Font (`01-Codi_Flutter/`)**:
* Executar `flutter pub get` i posteriorment `flutter run`.



> Per aprendre a crear o editar plantilles de formularis JSON, consulteu la [Guia de creació de qüestionaris](https://www.google.com/search?q=02-Software/01-Client-V1.01/03-Manuals_Suport/02-Guia_de_creaci%C3%B3_de_q%C3%BCestionaris.md)[cite: 6].

### 2. Desplegament del Servidor (Backend)

Per posar en marxa la infraestructura del backend utilitzant Podman:

1. Accediu a la carpeta del servidor corresponent (p. ex. `02-Software/02-Servidor/01-Codi/01-Servidor_Prototip_1-VersioLocal/`).
2. Inicieu l'entorn multicontenidor en segon pla[cite: 7, 9]:
```bash
podman-compose up -d

```


3. Verifiqueu que els serveis (Proxy, Backend i MongoDB) s'estan executant correctament[cite: 7, 9]:
```bash
podman ps

```



> Per a informació detallada sobre la configuració de Nginx, certificats SSL/TLS o gestió de magatzem a Podman, consulteu el [Manual d'Operació del Servidor](https://www.google.com/search?q=02-Software/02-Servidor/02-Manuals_Suport/01-README.md).
> 
> 

---

## 📚 Enllaços a la Documentació de Suport

* [📄 Objectius i Requisits del Sistema](https://www.google.com/search?q=01-Documentacio/01-Objectius_i_Requisits/01-Objectius%2520i%2520Requisits.md)

* [📄 Especificació Tecnològica](https://www.google.com/search?q=01-Documentacio/03-Prototip%25201/03-Tecnologies.md)

* [📄 Manual de Creació de Qüestionaris JSON](https://www.google.com/search?q=02-Software/01-Client-V1.01/03-Manuals_Suport/02-Guia_de_creaci%C3%B3_de_q%C3%BCestionaris.md)[cite: 6]
* [📄 Manual d'Operació del Servidor](https://www.google.com/search?q=02-Software/02-Servidor/02-Manuals_Suport/01-README.md)

* [📄 Manual de Comandes Podman](https://www.google.com/search?q=02-Software/02-Servidor/02-Manuals_Suport/02-Manual_Podman.md)[cite: 7]
