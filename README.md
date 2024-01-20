# Introductie

Dit project is een prototype om de multiplayer mogelijkheden van Godot te leren.
Het bevat code voor:
- een server
- clients
- een publieke chat
- een personage voor elke speler
- objecten in de wereld die physics gebruiken (botsingen)

Wat zit er (nog) niet in?
- beperkte zichtbaarheid. Nu krijgen alle spelers alle positie informatie over de hele wereld en alle andere tegenstanders. Voor een echte server is dit verspilling van bandbreedte en onveilig voor cheaters.
- account registratie en licenties. Hiervoor zet je normaal een aparte server op, niet gemaakt in Godot
- een game lobby of iets dergelijk. Je kiest nu de server op basis van IP adres.
- een echte game

# Build/Run
De github repo bevat het volledige project.
Het project is gemaakt in godot 4.2.
Download de code en importeer het project vanuit de godot project manager.

De start-scene is `//menu/menu.tscn`. Om gemakkelijk te testen met zowel een server als clients, heeft godot de optie om je game meerdere keren te runnen. In menu `Debug` - `Run Multiple Instances` staat de optie op `Run 3 Instances`. Daardoor krijg je 3 vensters wanneer je op `Run(F5)` klikt. Standaard komen deze 3 vensters op mekaar te liggen, zodat je misschien niet merkt dat het er 3 zijn.

Als je het project start, moet je in 1 venster een server opstarten. Deze draait lokaal. In de andere vensters kan je dan een client laten joinen.

Om niet iedere keer meermaals te moeten klikken om de server op te zetten en clients te laten joinen, en de vensters handmatig te verslepen, is er een stukje code om dit vanzelf te doen direct na het starten van het programma. Deze kan je aanzetten in `menu/menu.tscn` door voor `AutoConnectTimer` de eigenschap `autostart` op ON te zetten.

# Structuur van het project
## Algemeen
- De map `menu` bevat een heel eenvoudige menu om ofwel een server, ofwel een client te starten. `Menu.tscn` is de start scene.

- De map `network` bevat algemene code voor networking: de game server, de game client, en de chat. `network.gd` is gebruikt als auto-load, en zal automatisch laden bij de start van het programma (nog voor de menu scene getoond wordt). De server en client scene zijn de hoofd-scenes voor een server of client. Zodra de menu scene een server of client heeft gestart, wordt de menu scene vervangen door de juiste hoofd-scene.

- De map `game` bevat de eigenlijke scene van de game. Zowel de server als de client scene bevatten deze game scene. De inhoud van de game is (nog) zeer beperkt. Er is een background, en nodes `Players` en `Asteroids` die als parent dienen voor alle speler en asteroid nodes die door `PlayerSpawner` en `AsteroidSpawner` gemaakt worden.

- De map `player` bevat een algemene player scene, die een karakter bevat, collisionshape, camera, en andere nodes voor multiplayer synchronisatie. Momenteel is er maar 1 karakter mogelijk voor een speler, de kikker.

- De map `frog` bevat het kikker karakter. Dit is momenteel nog onvolledig, de beweeg animaties zijn niet geconfigureerd.

- De map `objects` bevat enkel de asteroide. Dit is een physics object dat zweeft in de ruimte en kan botsen.

## Details
- Voor de server geef je een `url` en `poortnummer` op. Voor een client dien je dezelfde `url` en `poortnummer` te gebruiken. Het project bevat al standaardwaarden om lokaal te testen.
- Je moet ook een `username` opgeven. De functionaliteit rond usernames is zelf geschreven en nog zeer beperkt. Godot werkt zelf met _nummers_ voor elke client, en we koppelen deze nummers aan usernames via code. De username is vrij te kiezen, zonder paswoord, en er wordt niet gekeken of de naam uniek is.
- Een server en client starten allemaal vanuit hetzelfde project met dezelfde code, maar ze voeren niet altijd dezelfde code uit. In `network.gd` heb je een `start_server` en een `start_client` functie. 
- Ook zijn er 2 verschillend hoofd-scenes: `server.tscn` en `client.tscn`. Deze verschillen subtiel, maar gebruiken vervolgens wel allebei dezelfde `game.tscn` voor het spel zelf. Dit is verplicht. Godot multiplayer verwacht dat de node structuur (pad) hetzelfde is voor alle nodes die gesynchroniseerd worden over het netwerk.
- Het was een hoop geprul om de physics van de asteroide werkende te krijgen. De physics berekeningen mogen enkel op de server gebeuren, en het synchroniseren gebeurt via hulp-variabelen (zie commentaar in `asteroid.gd`). De meeste games hebben geen echte physics nodig.


# Hoe werkt het?
- Bij het starten van het programma wordt de auto-load `network.gd` eerst geladen.
- `network.gd` maakt een variabele `var _multiplayer_peer := ENetMultiplayerPeer.new()`. ENet is een library die door Godot wordt gebruikt om netwerk verbindingen te maken voor multiplayer. Maar we verbinden nu nog niet.
- `network.gd` zal dan `_enter_tree` uitvoeren waar we enkele signal verbindingen leggen, zodat later onze code wordt uitgevoerd bij bepaalde netwerk gebeurtenissen (events).
- Hierbij gebruiken we `.multiplayer`, een eigenschap die _elke_ `node` heeft. Dit is de klasse van Godot zelf die multiplayer networking afhandeld. Deze klasse gaat later de `ENetMultiplayerPeer` klasse gebruiken om de verbinding zelf te maken, maar regelt ook een hoop andere dingen voor ons. Zie documentatie van [MultiplayerAPI](https://docs.godotengine.org/en/stable/classes/class_multiplayerapi.html)
- Er wordt verder nog geen netwerk code uitgevoerd, we wachten gewoon.
- Vervolgens wordt `menu.tscn` gestart en wordt er een venster getoond met een eenvoudige menu: 'host server', 'join game' of 'exit'.
- Als we 'host server' kiezen krijgen we een tweede menu. Hier dienen we een URL in te geven en netwerk poort.
- De URL is standaard ingevuld met `127.0.0.1`. Dit is een speciaal IP adres, de loopback, ofwel 'verbind met jezelf'. Dit is gemakkelijk om te testen.
- De poortnummer is gekozen om geen conflict te hebben met andere software. Je browser gebruikt bijvoorbeeld `http` via poort `80`. De lijst van geregistreerde poort nummers vind je op [deze wikipedia pagina](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
- Klik je op de 'connect' knop in de menu, dan wordt `_on_connect_button_pressed` in `menu.gd` uitgevoerd.
- Afhankelijk van de modus waar we in zitten (hebben we daarvoor op 'host server' of 'join game' geklikt) gaan we nu ofwel een server of client opzetten. 
- De waardes voor de url en poort halen we uit de invulvakjes op het scherm.
- `Network.start_server` zal de volgende stappen nemen:
- de `ENetMultiplayer` die in `_multiplayer_peer` zit krijgt de url mee, en we starten een server op de gevraagde poort.
- als het opzetten van de server gelukt is (de `if x == OK:`) gaan we verder, en anders geven we `false` terug en verlaten de functie.
- is de verbinding gelukt, dan krijgt `multiplayer` van Godot deze verbinding mee om te gebruiken.
- nu doen we een `internal_message`, wat een zelf geschreven functie is. We gebruiken het chat systeem om een message te tonen, maar deze message kwam niet van het netwerk, maar gewoon van onszelf. 
- `Network.start_server` is klaar en zal `true` teruggeven als de server is opgezet.
- Terug in `_on_connect_button_pressed` hebben we een `if` die het resultaat van `Network.start_server` gebruikt. Als de verbinding gelukt is, gaat de menu scene zichzelf volledig vervangen door de server scene (`res://network/server.tscn`).


# Credits
Background texture space by n4 https://opengameart.org/content/seamless-space-stars

Frog sprites from https://penzilla.itch.io/animated-rpg-frog-character

Asteriod sprite from https://www.creativefabrica.com/product/asteroid-doodle-space-rock-or-planet-co/
