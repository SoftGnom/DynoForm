
És completament normal que et passi això. Quan executes `podman-compose build --no-cache` repetidament, Podman es veu obligat a descarregar i compilar totes les capes des de zero cada vegada. Les capes i imatges anteriors no s'esborren automàticament; es queden emmagatzemades al teu disc dur en forma d'**imatges orfes (dangling images)** o temporals, i poden arribar a ocupar desenes de Gigabytes molt ràpidament.

Per alliberar aquest espai immediatament, pots utilitzar les eines de neteja natives de Podman. Executa aquestes comandes a la teva terminal:

### 1. Comprova el泄 (Quant està ocupant Podman?)

Abans de començar, si vols veure exactament quants gigabytes està consumint Podman en imatges, contenidors i volums, executa:

```Bash
podman system df
```

### 2. La neteja profunda (L'opció recomanada per al teu cas)

Com que has fet molts _builds_ sense memòria cau, tindràs moltes imatges duplicades que no s'estan fent servir. La millor comanda per netejar tot el que s'ha quedat "penjat" és:

```Bash
podman system prune -a
```

- **Què fa?** Esborra tots els contenidors aturats, les xarxes que no s'usin i, el més important amb el paràmetre `-a`, **totes les imatges que no estiguin associades a un contenidor actiu ara mateix**.
    
- _Nota:_ Et demanarà una confirmació (`y/N`), prem la `y` i veuràs com comença a esborrar gigabytes de capes velles.
    

### 3. Netejar volums orfes (Anònims)

Si en algun moment has aixecat el sistema sense definir rutes locals, és possible que s'hagin creat volums virtuals ocults dins de Podman. Pots fer neteja amb:

```Bash
podman volume prune
```

- **Alerta de seguretat:** No pateixis per la teva base de dades actual de MongoDB. Com que al teu `podman-compose.yml` utilitzes una ruta local configurada per tu (`./mongoDB:/data/db:Z`), aquestes dades es guarden a la teva carpeta del projecte i Podman **no les esborrarà**. Només esborrarà volums temporals de proves velles que hagin quedat oblidats.
    

### 4. Vols fer neteja absoluta de cop?

Si vols llançar una sola comanda que ho esborri absolutament tot (contenidors vells, imatges antigues, capes corruptes i volums anònims) per recuperar el màxim d'espai possible a l'ordinador, executa:

```Bash
podman system prune -a --volumes
```

Un cop executat, si tornes a fer un `podman system df` veuràs que el comptador haurà tornat pràcticament a zero i el teu ordinador tornarà a tenir espai lliure per poder continuar treballant i fent els _builds_ de l'aplicació de forma neta.