# Introductie

Dit project is een prototype om de multiplayer mogelijkheden van Godot te leren.
Het bevat code voor:
- een server
- clients
- een publieke chat
- een personage voor elke speler
- objecten in de wereld die physics gebruiken (botsingen)

Wat zit er (nog) niet in?
- beperkte zichtbaarheid. Nu krijgen alle spelers alle positie informatie over de hele wereld en alle andere tegenstanders. Voor een echte server is dit verspilling van bandbreedte en onveilig voor hacks.
- account registratie en licenties. Hiervoor zet je normaal een aparte server op, niet gemaakt in Godot
- een game lobby of iets dergelijk. Je kiest nu de server op basis van IP adres.
- een echte game

# Build/Run
De github repo bevat het volledige project.
Het project is gemaakt in godot 4.2.
Download de code en importeer het project vanuit de godot project manager.

De start-scene is "res://menu/menu.tscn". Om gemakkelijk te testen met zowel een server als clients, heeft godot de optie om je game meerdere keren te runnen. In menu 'Debug' - 'Run Multiple Instances' staat de optie op 'Run 3 Instances'. Daardoor krijg je 3 vensters wanneer je op Run (F5) klikt. Standaard komen deze 3 vensters op mekaar te liggen, zodat je misschien niet merkt dat het er 3 zijn.

Als je het project start, moet je in 1 venster een server opstarten. Deze draait lokaal. In de andere vensters kan je dan een client laten joinen.

Om niet iedere keer meermaals te moeten klikken om de server op te zetten en clients te laten joinen, en de vensters handmatig te verslepen, is er een stukje code om dit vanzelf te doen direct na het starten van het programma. Deze kan je aanzetten in 'menu/menu.tscn' door voor 'AutoConnectTimer' de eigenschap 'autostart' op ON te zetten.

# Structuur van het project
## Algemeen
- De map 'menu' bevat een heel eenvoudige menu om ofwel een server, ofwel een client te starten. 'Menu.tscn' is de start scene.

- De map 'network' bevat algemene code voor networking: de game server, de game client, en de chat. 'network.gd' is gebruikt als auto-load, en zal automatisch laden bij de start van het programma (nog voor de menu scene getoond wordt). De server en client scene zijn de hoofd-scenes voor een server of client. Zodra de menu scene een server of client heeft gestart, wordt de menu scene vervangen door de juiste hoofd-scene.

- De map 'game' bevat de eigenlijke scene van de game. Zowel de server als de client scene bevatten een game scene. De inhoud van de game is (nog) zeer beperkt. Er is een background, en nodes 'Players' en 'Asteroids' die als parent dienen voor alle speler en asteroid nodes die door 'PlayerSpawner' en 'AsteroidSpawner' gemaakt worden.

- De map 'player' bevat een algemene player scene, die een karakter bevat, collisionshape, camera, en andere nodes voor multiplayer synchronisatie. Momenteel is er maar 1 karakter mogelijk voor een speler, de kikker.

- De map 'frog' bevat het kikker karakter. Dit is momenteel nog onvolledig, de beweeg animaties zijn niet geconfigureerd.

- De map 'objects' bevat momenteel enkel de asteroide. Dit is een physics object dat zweeft in de ruimte en kan botsen.

# Credits
Background texture space by n4 https://opengameart.org/content/seamless-space-stars

Frog sprites from https://penzilla.itch.io/animated-rpg-frog-character

Asteriod sprite from https://www.creativefabrica.com/product/asteroid-doodle-space-rock-or-planet-co/
