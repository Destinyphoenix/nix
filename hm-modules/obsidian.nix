# Obsidian über das Home-Manager-Modul.
#
# Das Modul mischt bei jeder Aktivierung `updateDisabled = true` in
# ~/.config/obsidian/obsidian.json (bestehende Vaults bleiben erhalten).
# Grund: der eingebaute Updater lädt ein neueres obsidian-*.asar, das nicht
# zum Electron aus nixpkgs passt. Updates kommen nur noch über nixpkgs.
{
  programs.obsidian.enable = true;
}
