# 🚀 Manual d'Operació del Backend (Podman)

Aquest document conté les comandes essencials per aixecar, aturar i gestionar l'entorn multicontenidor del servidor (Proxy Nginx, API Python i MongoDB) utilitzant **Podman**.


## 🏁 1. Com activar el projecte

Per aixecar tot l'entorn (descarregar imatges, crear xarxes, muntar carpetes i arrancar els contenidors), executa la següent comanda a l'arrel del projecte:

```Bash
podman-compose up -d
```

> 💡 **Què fa el `-d`?** Significa _Detached mode_. Fa que els contenidors s'executin en segon pla, deixant-te la terminal lliure per continuar treballant.

### Com comprovar que tot funciona?

Per veure si els tres contenidors estan vius i quins ports estan utilitzant:


```Bash
podman ps
```




## 🛑 2. Com tancar el projecte

Tens dues opcions per aturar el projecte depenent de si vols esborrar l'entorn virtual o només pausar-lo:

### Opció A: Aturar i netejar (Recomanat)

Atura els contenidors i els esborra, netejant la memòria del sistema. **No pateixis, les teves dades de `./mongo_data` i `./backend` no es perdran.**


```Bash
podman-compose down
```

### Opció B: Pausar temporalment

Només congela els contenidors sense esborrar-los. Útil si vols reprendre la feina de seguida.


```Bash
podman-compose stop
```

_(Per tornar-los a activar des d'aquest estat, pots fer un `podman-compose start`)_.




## 🚪 3. Com entrar a dins d'un contenidor

De vegades necessitaràs entrar "físicament" dins d'un contenidor per executar comandes directament (per exemple, per provar scripts de Python o entrar a la consola de Mongo).

La sintaxi és: `podman exec -it <nom_contenidor> <interpret_de_comandes>`

### Entrar al contenidor de Python:

```Bash
podman exec -it backend_app /bin/bash
```

_(Si no funciona `/bin/bash` perquè la imatge és molt lleugera, utilitza `sh`)_.

### Entrar a la terminal de MongoDB:

```Bash
podman exec -it base_dades_nosql bash
```

Una vegada a dins, si vols connectar-te directament a la consola de la base de dades, pots fer:

```Bash
mongosh -u usuari_admin -p contrasenya_super_segura
```

Per **sortir** de qualsevol contenidor i tornar a la teva màquina, simplement escriu:

```Bash
exit
```




## 🛠️ 4. Eines extres de diagnòstic

### Veure què està passant (Logs/Rastreig)

Si l'aplicació Python dona un error o la teva aplicació Flutter no es pot connectar, necessitaràs veure què està imprimint el servidor.

- **Veure els logs de tots els contenidors a la vegada:**

 ```Bash
    podman-compose logs -f
 ```
    
- **Veure els logs d'un sol contenidor (ex: només el backend):**
    
 ```Bash
    podman logs -f backend_app
 ```

> 💡 El paràmetre `-f` (_follow_) fa que la pantalla es quedi oberta i es vagi actualitzant en temps real cada vegada que arribi una nova petició. Per sortir, prem `Ctrl + C`.

### Forçar la reconstrucció (Rebuild)

Si afegeixes una nova llibreria al teu `requirements.txt` de Python, Podman no la detectrà automàticament. Has de forçar-lo a reinstal·lar-ho tot amb:

```Bash
podman-compose up -d --build
```

