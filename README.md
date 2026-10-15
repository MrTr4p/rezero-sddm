# Re:Zero — Another Beginning

An ivory-and-lavender **Qt 6 SDDM theme** with drifting feathers, gentle hair sway, a CAVA audio spectrum, and three matching wallpapers. Includes an interactive localhost preview of the actual QML scene.

![Another Beginning login screen](docs/preview.png)

## Install and test the SDDM theme temporarily

Use this method to check the theme with the **real Qt 6 SDDM greeter** from your running graphical desktop. It copies the theme into a temporary user directory and removes that copy when the test exits. Your selected login theme and SDDM configuration stay unchanged; no logout, reboot, or display-manager restart is needed.

### 1. Check dependencies

On Arch Linux, install any missing runtime dependencies:

```sh
sudo pacman -S --needed git sddm qt6-declarative qt6-multimedia qt6-svg \
  mesa ttf-jetbrains-mono noto-fonts-cjk
```

Skip this command if the dependencies are already installed. Packages installed by the command remain installed; only the test theme copy is temporary. The native greeter test does not require Python, noVNC, CAVA, or the preview service. The compiled hair shader is included in the repository.

### 2. Get the theme

Run this in the directory where you keep your projects, or enter your existing checkout:

```sh
git clone https://github.com/MrTr4p/rezero-sddm.git
cd rezero-sddm
```

### 3. Install a temporary copy and test it

Run the entire block from the repository root, in a terminal inside your graphical session:

```sh
(
  set -eu
  test -f theme/Main.qml
  mkdir -p "$HOME/.local/share"
  theme_test_dir=$(mktemp -d "$HOME/.local/share/rezero-sddm-test.XXXXXX")
  trap 'rm -rf -- "$theme_test_dir"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  cp -R theme "$theme_test_dir/theme"
  sed -i 's|^TelemetryUrl=.*|TelemetryUrl=|' "$theme_test_dir/theme/theme.conf"

  QT_QPA_PLATFORM=xcb QT_QUICK_CONTROLS_STYLE=Basic QSG_RHI_BACKEND=opengl \
    sddm-greeter-qt6 --test-mode --theme "$theme_test_dir/theme"
)
```

This uses X11 or XWayland, including on a Wayland desktop such as Hyprland. Use `sddm-greeter-qt6`; the Qt 5 greeter cannot load this theme. If the executable is missing, check your distribution's Qt 6 SDDM package. If Qt cannot connect to the display, run the command from a terminal in your graphical desktop session.

The theme should show its artwork, animated feathers, session choices, and login controls. Try selecting a session, entering dummy text, toggling password visibility, and pressing Escape to clear the password. Press **Ctrl+C in the launching terminal** to finish; the temporary theme copy is removed automatically. The repository and original `theme/theme.conf` remain intact.

[SDDM test mode](https://github.com/sddm/sddm/blob/v0.21.0/docs/THEMING.md#testing) does not perform real authentication, start a desktop, or execute power actions. A blank username, `localhost` greeting, or disabled power controls can occur without the display-manager connection. Use the browser demo below to exercise simulated successful and failed sign-ins; its `test` password belongs to that demo only.

The temporary copy has `TelemetryUrl` cleared so it works independently of the preview service. CPU/RAM values are unavailable and CAVA shows **offline** in this test. This procedure checks theme loading and rendering; it does not enable the theme for boot or validate a real login session.

## Try the interactive browser demo

The preview runs on Linux with a systemd user session. It displays the theme in an isolated Xvfb display through noVNC. It never authenticates against the operating system, launches a desktop, executes power operations, or modifies the installed SDDM configuration.

### Dependencies

On Arch Linux:

```sh
sudo pacman -S --needed base-devel git python python-pip \
  qt6-base qt6-declarative qt6-multimedia qt6-svg qt6-shadertools mesa \
  xorg-server-xvfb x11vnc cava ttf-jetbrains-mono noto-fonts-cjk
```

Install the Python [websockify bridge](https://github.com/novnc/websockify) in a user environment. noVNC 1.6.0 is already included, so no Node setup is needed.

```sh
git clone https://github.com/MrTr4p/rezero-sddm.git
cd rezero-sddm
python3 -m venv "$HOME/.local/share/rezero-sddm/venv"
"$HOME/.local/share/rezero-sddm/venv/bin/pip" install -r preview/requirements.txt
./start.sh
```

Open **http://localhost:8770/** once the service starts. Use your prefilled username and the demo password **`test`**. A different nonempty password demonstrates the error state. If no desktop session is installed, sign-in is disabled.

The bottom toolbar lets you switch wallpapers, reset the demo, and enter full screen. Wallpaper selection lasts for the current preview service session. Switching backgrounds resets the demo form.

```sh
./stop.sh
```

The transient `rezero-sddm-preview.service` does not start at boot. All network listeners bind to loopback: HTTP `8770`, WebSocket `6070`, and VNC `5970`; the isolated display is `:170`. Runtime logs are in `runtime/`, excluded from Git.

For startup problems, inspect `journalctl --user -u rezero-sddm-preview.service -n 50` and `runtime/login.log`. The launcher finds system tools automatically; custom locations can be supplied through `REZERO_X11VNC`, `REZERO_CAVA`, or `REZERO_WEBSOCKIFY_PYTHON` before running `./start.sh`.

## Wallpapers

All backgrounds use warm ivory paper, pale lavender linework, and clear space around the login controls. PNG files are 1672 × 941 pixels.

| Another Beginning | Royal Capital | Moonlit Forest |
| --- | --- | --- |
| [![Emilia and Subaru overlooking the city](theme/assets/background.png)](theme/assets/background.png) | [![Misty royal capital](theme/assets/royal-capital.png)](theme/assets/royal-capital.png) | [![Moonlit silver forest](theme/assets/moonlit-forest.png)](theme/assets/moonlit-forest.png) |
| Original character artwork, with gentle hair sway | Stone bridges, castle spires, and wisteria at dawn | Frosted birches and a quiet path through ivory mist |

For the QML theme, set `Background` in [`theme/theme.conf`](theme/theme.conf) to one of:

```ini
Background=assets/background.png
# Background=assets/royal-capital.png
# Background=assets/moonlit-forest.png
```

The localhost toolbar selects its own background without editing this file. `HairSway=auto` applies the hair shader only to the original portrait; the landscape alternatives retain the drifting feathers and animated header. For a custom background, use `HairSway=false` unless its composition matches the original hair masks.

## Theme features

- 22 drifting feathers, a continuously flowing header ornament, a breathing compass, entrance transitions, and button hover effects. No floating star particles.
- Gentle localized hair sway on the original wallpaper; the face and city stay fixed. Set `Animations=false` for reduced ambient motion.
- Compact rectangular Sign in button, with the power controls aligned to the Current session section.
- Hostname greeting from `sddm.hostName`, username from `userModel.lastUser`, and desktop choices from `sessionModel`.
- Central clock; the footer shows keyboard layout and battery without repeating date or time.
- Password visibility, Enter to submit, Escape to clear, Caps Lock feedback, failure recovery, and capability-aware power confirmations.

The hair shader needs a Qt graphics backend such as OpenGL. Qt's software scenegraph shows a still portrait while retaining feather motion. Shader source and the compiled Qt shader package are in `theme/shaders/`; the launcher rebuilds the shader when needed.

## Audio and telemetry

The System panel uses **CAVA** to monitor the default audio output through PulseAudio or PipeWire's PulseAudio interface. It streams 64 frequency bars at 30 Hz. Silent output produces a flat spectrum; an unavailable CAVA process is shown as offline.

The Audio play button starts the included synthesized ambient loop. Volume and mute affect only the theme's audio. Audio starts paused. CPU, memory, swap, and battery values come from Linux system files through the local preview bridge.

`TelemetryUrl` in `theme/theme.conf` points to the optional localhost bridge; leave it empty to disable telemetry. An installed SDDM greeter would need a bridge and audio setup in its own session. **This repository provides a local preview and does not install or configure the real login manager.**

## Development and validation

```sh
./preview/build.sh
./preview/test.sh
```

The interaction checks cover hostname and username, session selection, authentication validation, duplicate submissions, success/failure recovery, keyboard controls, audio controls, and simulated power actions. Session fixtures make the tests independent of the installed desktop. The browser preview is also checked with each wallpaper.

| Path | Purpose |
| --- | --- |
| `theme/` | Native QML SDDM theme, artwork, audio, and shaders |
| `preview/` | Mock SDDM context, localhost server, and browser viewer |
| `preview/vendor/novnc/` | Vendored noVNC source with its upstream licenses |
| `docs/artwork.md` | Image-generation prompts and asset provenance |

## Credits

An unofficial Re:Zero fan theme. Artwork was generated with the built-in imagegen tool; the original used the supplied design reference. Exact prompts are in [the artwork notes](docs/artwork.md). The ambient loop is synthesized audio, and the compass, feather, and input icons are code-native vectors.

noVNC and its bundled dependencies retain their [upstream licenses](preview/vendor/novnc/LICENSE.txt). API references: [SDDM theme API](https://github.com/sddm/sddm/blob/develop/docs/THEMING.md), [Qt ShaderEffect](https://doc.qt.io/qt-6/qml-qtquick-shadereffect.html), and [CAVA configuration](https://github.com/karlstav/cava/blob/master/example_files/config).
