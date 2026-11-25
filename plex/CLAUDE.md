# CPZero — el Cardputer Zero desde el móvil

Esta carpeta es la de la sesión de Claude Code **«CPZero»** de `plex`, la que Bruno maneja desde
la app de Claude del móvil (Remote Control) cuando lleva el Cardputer encima. La otra sesión de
`plex` («plex», en `~`) es la de Home Assistant: aquí no se toca nada de la casa.

Montada el 22-nov-2026 desde el portátil. Responder siempre en español.

## Cómo se llega al aparato

- El Cardputer es **`cpzero`** en Tailscale: `ssh cpzero` (usuario `bruno`, sudo sin contraseña).
  Suele estar apagado o dormido: si no contesta, decírselo a Bruno, no insistir.
- Fuera de casa se conecta al punto de acceso del móvil (la wifi «Pixel» ya está guardada) y
  sigue en Tailscale, así que `ssh cpzero` funciona igual si el móvil tiene datos.
- **Si `ssh cpzero` dice «tailnet policy does not permit you to SSH to this node»**: falta la
  regla de la ACL de Tailscale que deja a `tag:server` entrar en `tag:server` (plex y cpzero
  llevan esa etiqueta). La pone Bruno en la consola de Tailscale; no intentar rodearla.
- **ZeroRemote** (pantalla, teclado y archivos en el navegador): `http://<IP de Tailscale de cpzero>:8320/` (la da `ssh cpzero tailscale ip -4`)
  (sólo desde la red de Tailscale; el nombre `cpzero` no resuelve en el móvil). En el
  Cardputer, la app **Remote** del lanzador enseña el QR y los interruptores «Remote screen» y
  «File sharing»; también se cambian en `~/.config/zeroremote/remote.conf` (`screen=`,
  `files=`). Servicio: `systemctl status zeroremote`. Para ver la pantalla desde aquí sin
  navegador: `ssh cpzero 'head -c 108800 /dev/fb0'` da una imagen RGB565 de 320×170.
- **El lanzador se cae con 20 apps** (launcher#268): había 15 el 22-nov-2026 (se quitaron
  FactoryTest, GPS de origen, IR Chat, Keyboard Guide y SubG Chat, y se ocultó la calculadora) y el
  24-nov-2026 se desinstalaron IGN GPS y RF / NFC. Contar antes de instalar otra.
- **Ver la pantalla como imagen**: `ssh cpzero 'head -c 108800 /dev/fb0' > fb.raw` y
  `ffmpeg -f rawvideo -pixel_format rgb565le -video_size 320x170 -i fb.raw -frames:v 1 fb.png`
  (negro = pantalla dormida). Las letras salen más altas en el aparato que en el simulador:
  lo que cabe en el simulador puede montarse en el aparato.
- **Pulsar teclas sin tocarlo**: además del truco de abajo, el WebSocket de ZeroRemote
  (`ws://<IP de Tailscale>:8320/ws`) acepta JSON: `{"t":"wake","unlock":true}`,
  `{"t":"tap","code":N}` (códigos evdev) y `{"t":"key","code":1,"down":true|false}` (mantener ESC
  sale de una app). Tras salir de una app el carrusel suele volver a **CLI**: mirar la pantalla
  antes de pulsar ENTER (CLI no se cierra con ESC: `exit`, ENTER y otra tecla).

## El aparato

- M5Stack Cardputer Zero: Raspberry Pi CM0 (4 núcleos a 1 GHz, 512 MB), Debian 13 arm64,
  pantalla SPI de 320×170 (`/dev/fb0`, RGB565), teclado `tca8418` (`/dev/input/event3`),
  batería de 1.750 mAh con medidor `bq27220` en `/sys/class/power_supply/bq27220-0`
  (`current_now` en µA, negativo al descargar).
- Lanzador oficial `APPLaunch` (servicio **de usuario**). Su salvapantallas se desbloquea con
  `TAB` y luego `ENTER`.
- **ZeroPower** (`zeropowerd`): pausa el lanzador con la pantalla apagada, apaga la pantalla
  tras unos minutos sin teclas y apaga el sistema al 5 % de batería. Registro:
  `journalctl -u zeropowerd`. «Apagar» sólo detiene el CM0: la placa sigue con corriente.
- **Interruptor USB Host/Slave** (lateral izquierdo): en Slave gasta unos 88 mA menos (≈2,5 h más
  de batería), pero se desconecta el hub USB y con él Ethernet, el USB-A y el USB-C de salida; los
  Cap y el Grove siguen funcionando y carga igual. Se sabe la posición con `lsusb` (en Slave sólo
  sale el root hub) y ZeroPower la enseña en la pantalla Battery.
- Pulsar una tecla desde fuera (despierta la pantalla, por ejemplo):
  ```sh
  ssh cpzero 'python3 -c "
  import struct,time,os
  fd=os.open(\"/dev/input/event3\",os.O_WRONLY)
  ev=lambda t,c,v: os.write(fd,struct.pack(\"llHHi\",0,0,t,c,v))
  ev(1,42,1);ev(0,0,0);time.sleep(0.05);ev(1,42,0);ev(0,0,0)"'
  ```
  (42 = Shift izquierdo: no hace nada en las apps. Códigos en `linux/input-event-codes.h`.)
- El arranque se aligeró el 22-nov-2026 (de 45 a 26 s): conexiones de netplan pasadas a
  NetworkManager y cloud-init desactivado. Copia de lo cambiado en `/root/arranque-backup-20261122/`.

## Las apps de Bruno para el Cardputer

Repositorios públicos en `github.com/baltamir1978` (ni secretos ni datos personales en ellos).
Cada uno tiene su `CLAUDE.md`: **leerlo antes de decir qué le falta a una app**.

| Repositorio | En el lanzador | Qué es |
|---|---|---|
| `ZeroGallery` | Gallery | Fotos y vídeo; desde la 0.5 los manda a la tele (DLNA y Google Cast, tecla `V`) |
| `CardputerZero-Music` | Music | Fork de la app oficial (rama `carpetas` de `baltamir1978/Music`): carpetas y mandar a la tele; comparte el código de DLNA/Cast con ZeroGallery |
| `ZeroPower` | Power | Ahorro de batería y ajustes de energía (en la tienda) |
| `ZeroRemote` | — | La pantalla remota de arriba (`Tools/instalar.sh` la instala en cpzero) |
| `ZeroTVBGone` ☁ | TV-B-Gone | Apagar teles por infrarrojos |
| `ZeroGPS` ☁ | — | GPS con los mapas del IGN (Cap LoRa-1262); **desinstalada** del aparato el 24-nov-2026, con sus mapas (sigue en la tienda) |
| `ZeroRF-NFC` ☁ | — | Sub-GHz y NFC (Cap CC1101+NFC); **desinstalada** el 24-nov-2026 |
| `CPZero` | — | La configuración de esta sesión (este CLAUDE.md y su servicio); se instala desde el portátil |

☁ = desde el 24-nov-2026 el repositorio sólo está en GitHub, no en `~/Proyectos`: para tocarlo,
clonarlo en `~/Proyectos` desde `github.com/baltamir1978` (y crear su enlace `.cache`, abajo).

- Los repositorios están en `~/Proyectos/<repo>`, que Syncthing mantiene igual que en el
  portátil (desde el 24-nov-2026, `.git` incluido): lo hecho allí aparece aquí sin pasar por
  GitHub. No trabajar en el mismo repositorio desde las dos máquinas a la vez (Syncthing deja
  copias `*.sync-conflict-*`); antes de tocar uno, `git fetch` y lo de GitHub se integra, nunca
  se pisa. Lo que no se sincroniza y por qué está en `~/Proyectos/CLAUDE.md`.
- El SDK del Cardputer (LVGL y el *sysroot*) está **fuera de `~/Proyectos`**, en
  `~/.local/share/cardputer-zero-sdk` (desde el 24-nov-2026; antes en `ZeroTVBGone/.cache`). Cada
  app Zero tiene `.cache -> ~/.local/share/cardputer-zero-sdk`; ese enlace no viaja con Syncthing:
  en un clon nuevo, `mkdir -p ~/.local/share/cardputer-zero-sdk && ln -s ~/.local/share/cardputer-zero-sdk .cache`.
- Los `.deb` van a `~/Documentos/Software` (sólo el último de cada app).
- **Antes de mandar algo a la tienda, preguntar a Bruno**: `czdev publish` abre un PR desde su
  cuenta.
- Se compilan con `Tools/compilar.sh pruebas|deb` (en `plex` usa Docker). Para instalar en el
  aparato: `scp` del `.deb` y `sudo apt-get install -y /tmp/<deb>`.
- Nombres sobrios y descriptivos (nada de «hacker» ni marketing).

## Ideas sin decidir

- **25-nov-2026 — servidor offline de bolsillo**, inspirado en Jcorp Nomad (ESP32-S3, GPL-3) y
  Project NOMAD (Kiwix, Apache 2.0): que el Cardputer cree su propia wifi con un QR y sirva al
  móvil por el navegador pelis, música, libros (OPDS) y Wikipedia en ZIM (`kiwix-serve`), y quizá
  haga de servidor DLNA para la tele. Bruno **aún no ha decidido** si lo quiere ni cómo. Antes de
  nada, comprobar en el aparato el disco libre y si la wifi del CM0 puede hacer de punto de acceso
  (y si a la vez puede seguir en Tailscale), y medir lo que gasta el hotspot. Si se hace, una sola
  app (por el límite del lanzador) y código propio, sin copiar el de Jcorp por ser GPL.
