#!/usr/bin/env bash
# Run conv_demo with the live OpenCV window.
#
# This machine has a version skew between gnome-settings-daemon and
# gsettings-desktop-schemas: the key
#   org.gnome.settings-daemon.plugins.xsettings:antialiasing
# now lives only in the *.deprecated schema, while Qt's GTK3 platform theme
# (.so loaded by the Qt5 xcb plugin) still queries it and aborts with
#   GLib-GIO-ERROR: ... does not contain a key named 'antialiasing'
# We build a private schema directory that adds the missing keys and point
# GSETTINGS_SCHEMA_DIR at it. Only the per-user cache is touched.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
schemas="${XDG_CACHE_HOME:-$HOME/.cache}/conv_accel/schemas"

if [ ! -f "$schemas/gschemas.compiled" ]; then
    mkdir -p "$schemas"
    cp /usr/share/glib-2.0/schemas/* "$schemas"/ 2>/dev/null || true
    python3 - "$schemas/org.gnome.settings-daemon.plugins.xsettings.gschema.xml" <<'PY'
import sys
path = sys.argv[1]
s = open(path).read()
anchor = '    <key type="a{sv}" name="overrides">'
shim = (
    '    <key name="antialiasing" type="s">\n'
    "      <default>'grayscale'</default>\n"
    '      <summary>compat shim for Qt GTK3 platform theme</summary>\n'
    '    </key>\n'
    '    <key name="hinting" type="s">\n'
    "      <default>'slight'</default>\n"
    '      <summary>compat shim</summary>\n'
    '    </key>\n'
    '    <key name="rgba-order" type="s">\n'
    "      <default>'rgb'</default>\n"
    '      <summary>compat shim</summary>\n'
    '    </key>\n'
)
if 'name="antialiasing"' not in s.split(anchor)[0]:
    s = s.replace(anchor, shim + anchor, 1)
    open(path, 'w').write(s)
PY
    glib-compile-schemas "$schemas"
fi

export GSETTINGS_SCHEMA_DIR="$schemas"
exec "$here/build/conv_demo" "$@"
