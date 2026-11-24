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
- **El lanzador se cae con 20 apps** (launcher#268): hay 15 desde el 22-nov-2026 (se quitaron
  FactoryTest, GPS de origen, IR Chat, Keyboard Guide y SubG Chat, y se ocultó la calculadora). Contar
  antes de instalar otra.

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
| `ZeroGallery` | Gallery | Fotos y vídeo |
| `ZeroTVBGone` | TV-B-Gone | Apagar teles por infrarrojos |
| `ZeroPower` | Power | Ahorro de batería y ajustes de energía |
| `ZeroGPS` | IGN GPS | GPS con los mapas del IGN (Cap LoRa-1262) |
| `ZeroRF-NFC` | RF / NFC | Sub-GHz y NFC (Cap CC1101+NFC); local en el portátil, sin publicar |
| `ZeroRemote` | — | La pantalla remota de arriba (`Tools/instalar.sh` la instala en cpzero) |
| `CPZero` | — | La configuración de esta sesión (este CLAUDE.md y su servicio); se instala desde el portátil |

- Los repositorios están en `~/Proyectos/<repo>`, que Syncthing mantiene igual que en el
  portátil (desde el 24-nov-2026, `.git` incluido): lo hecho allí aparece aquí sin pasar por
  GitHub. No trabajar en el mismo repositorio desde las dos máquinas a la vez (Syncthing deja
  copias `*.sync-conflict-*`); antes de tocar uno, `git fetch` y lo de GitHub se integra, nunca
  se pisa. Lo que no se sincroniza y por qué está en `~/Proyectos/CLAUDE.md`.
- El SDK del Cardputer está en `~/Proyectos/ZeroTVBGone/.cache` y las demás apps Zero lo
  enlazan (`.cache -> ../ZeroTVBGone/.cache`); esos enlaces no viajan con Syncthing.
- Se compilan con `Tools/compilar.sh pruebas|deb` (en `plex` usa Docker). Para instalar en el
  aparato: `scp` del `.deb` y `sudo apt-get install -y /tmp/<deb>`.
- Nombres sobrios y descriptivos (nada de «hacker» ni marketing).
