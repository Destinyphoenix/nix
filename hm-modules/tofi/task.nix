# Neuer Super-Productivity-Task — tofi-Freitext-Eingabe, systemweit per
# Tastenkombination (Binding in hm-sway.nix).
#
# Nutzt den superproductivity://create-task-Handler der App: Electrons
# Global-Shortcuts (globalAddTask) greifen unter Sway nicht. Läuft die App
# bereits, landet der Task in der laufenden Instanz, sonst startet sie.
# Optik: wiederverwendetes websearch-Theme, nur anderes Prompt-Icon.
#
# Aufruf: tofi-task
{ pkgs, lib, ... }:

let
  tofi-task = pkgs.writeShellScriptBin "tofi-task" ''
    set -euo pipefail
    tofi="${pkgs.tofi}/bin/tofi"
    jq="${pkgs.jq}/bin/jq"

    title=$(printf "" | "$tofi" \
      --config "$HOME/.config/tofi/websearch" \
      --require-match=false \
      --prompt-text "󰄬 ")
    [ -z "$title" ] && exit 0

    encoded=$("$jq" -sRr '@uri' <<< "$title")
    setsid -f ${lib.getExe pkgs.super-productivity} \
      "superproductivity://create-task?title=$encoded" >/dev/null 2>&1
  '';
in
{
  home.packages = [ tofi-task ];
}
