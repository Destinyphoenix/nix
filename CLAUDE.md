# Nix-Config (github.com/Destinyphoenix/nix)

- `nixos-rebuild switch --flake .#<host>` führe ich selbst aus, nicht du
- Flakes lösen `self` gegen den Git-Index auf: neue Dateien vor dem Rebuild
  `git add`-en, sonst findet die Evaluation sie nicht
- `specialArgs` speist NixOS-Module, `extraSpecialArgs` die HM-Module –
  Werte aus dem einen Kanal sind im anderen unsichtbar
- Struktur: `modules/` (NixOS), `hm-modules/` (Home Manager),
  `hosts/<host>/`, `pkgs/` (eigene Derivations)
- Farben und Fonts ausschließlich aus `theme.nix` (Tokens: background,
  surface, foreground, muted, border, primary, error, warning, success,
  info, accent, font, fontSize) – keine Hardcodes in Modulen
- Sway-Keybindings zentral in `hm-modules/sway/hm-sway.nix`, nicht im
  jeweiligen Feature-Modul
- In systemd-Services und Skripten absolute Store-Pfade bzw. `lib.getExe`
- Kommentare in Nix-Dateien auf Deutsch
