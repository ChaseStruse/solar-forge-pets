# Solar Forge Pet

A little ASCII cyberpet that lives at the bottom right of your Omarchy desktop. It runs as a native Quattro shell plugin inside `omarchy-shell`, with no separate daemon or extra packages.

```text
 /\_/\
[ >.< ]
 /|#|\
  / \
```

The pet blinks, notices your cursor, reacts to attention, and falls asleep after 90 seconds without interaction. Its neon terminal card has three controls:

| Control | Effect |
| --- | --- |
| Click the pet or **PAT** | Give it attention |
| **FEED** | Give it some bytes to snack on |
| **NAP** | Let it sleep until you hover over it |

## Install

Requires Omarchy with the Quattro `omarchy-shell` plugin system. After this repository is available on GitHub:

```bash
omarchy plugin add https://github.com/ChaseStruse/solar-forge-pets.git --enable
```

The shell starts the pet when the plugin is enabled. If the shell is already running and it does not appear, run:

```bash
omarchy-shell shell rescanPlugins
```

To temporarily hide it or bring it back:

```bash
omarchy plugin disable io.github.chasestruse.solar-forge-pet
omarchy plugin enable io.github.chasestruse.solar-forge-pet
```

To remove the plugin:

```bash
omarchy plugin remove io.github.chasestruse.solar-forge-pet
```

## Develop

The repository root is the plugin folder. `manifest.json` declares one `service` entry point, `Pet.qml`. The service owns a small Wayland layer-shell window and loads with Omarchy's existing shell process. Changes to plugin files hot-reload when the plugin is installed in `~/.config/omarchy/plugins/`.

Validate the manifest before sharing changes:

```bash
omarchy plugin validate .
```

Omarchy plugins run with your user permissions. Review code before enabling third-party plugins. For plugin structure and manifest rules, see the [Omarchy shell plugin guide](https://github.com/omacom/omarchy/blob/quattro/shell/README.md) and [development guide](https://plugins.omarchy.org/develop.html).

## License

MIT; see [LICENSE](LICENSE).
