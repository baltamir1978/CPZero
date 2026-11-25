# CPZero (configuración de la sesión de plex)

Este repositorio **no es la sesión**: es la configuración de la sesión «CPZero» de Claude Code
que corre en `plex` (ver `README.md`). El CLAUDE.md que lee esa sesión es `plex/CLAUDE.md`
(en plex, `~/CPZero/CLAUDE.md`).

- Se cambia aquí y se instala con `Tools/instalar-en-plex.sh`. No editar a mano en plex: lo
  de aquí lo pisaría en la siguiente instalación (si se cambió allí, traerlo antes con
  `scp plex:CPZero/CLAUDE.md plex/CLAUDE.md`).
- Estilo de `~/Proyectos/CLAUDE.md`: español, el porqué, ni secretos ni datos personales.
- Cuando cambie algo del Cardputer que la sesión deba saber (una app nueva, otra dirección,
  otro arreglo del sistema), ponerlo en `plex/CLAUDE.md` e instalar.

## Estado

- **22-nov-2026 — montada.** `claude-remote-cpzero.service` activo en plex junto a
  `claude-remote.service` (la sesión «plex» de Home Assistant, que no se toca). Regla de la
  ACL de Tailscale puesta por Bruno: plex entra en cpzero por SSH (comprobado: ssh, sudo y la
  web de ZeroRemote desde plex). Sin probar todavía una conversación desde el móvil.
- **25-nov-2026 — `plex/CLAUDE.md` al día** con lo del 24-nov-2026: SDK fuera de `~/Proyectos`,
  repositorios que sólo están en GitHub, ZeroGPS y RF / NFC desinstaladas, el fork de Music y el
  envío a la tele, cómo ver y manejar la pantalla, el interruptor Host/Slave, preguntar antes de
  publicar en la tienda y la idea (sin decidir) del servidor offline. Copiado a plex sólo el
  fichero, sin reiniciar el servicio: lo lee la próxima conversación.
