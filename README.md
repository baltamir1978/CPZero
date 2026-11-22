# CPZero

La sesión **«CPZero»** de Claude Code: el Cardputer Zero manejado desde la app de Claude del
móvil. Corre en `plex` (el servidor de casa, siempre encendido) con Remote Control y llega al
Cardputer por Tailscale (`ssh cpzero`), también fuera de casa, con el Cardputer conectado al
punto de acceso del móvil.

Va aparte de la sesión «plex», la de Home Assistant: otra carpeta, otro servicio, otro nombre
en la app.

## Qué hay

| Fichero | En plex | Qué es |
|---|---|---|
| `plex/CLAUDE.md` | `~/CPZero/CLAUDE.md` | Lo que la sesión necesita saber del Cardputer y de las apps |
| `systemd/claude-remote-cpzero.service` | `~/.config/systemd/user/` | `claude remote-control --name CPZero`, arranca con plex |
| `Tools/instalar-en-plex.sh` | — | Copia lo anterior a plex y reinicia el servicio |

Los cambios se hacen aquí y se llevan con `Tools/instalar-en-plex.sh`.

## Requisitos

- `claude` instalado en plex (`~/.local/bin/claude`) y el usuario con *linger*.
- Una regla de SSH en la política de Tailscale que deje a `tag:server` (plex) entrar en
  `tag:server` (cpzero) como `bruno`:
  `{"action": "accept", "src": ["tag:server"], "dst": ["tag:server"], "users": ["bruno"]}`.

## Relacionado

- [ZeroRemote](https://github.com/baltamir1978/ZeroRemote): la pantalla y el teclado del
  Cardputer en el navegador (`http://cpzero:8320/`).
