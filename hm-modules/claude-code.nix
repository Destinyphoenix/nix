# Claude Code (Anthropic CLI) – deklarativ über Home Manager.
#
# Home Manager hat ein natives `programs.claude-code`-Modul, d.h. settings.json,
# CLAUDE.md, MCP-Server und Plugins werden generiert und liegen als Read-only-
# Symlinks im Store. Was Claude Code selbst zur Laufzeit schreibt (Login-Token,
# History, ~/.claude.json), bleibt davon unberührt.
#
# Zwei Erweiterungen sind hier verdrahtet:
#   mcp-nixos  -> MCP-Server für Paket-/Options-Suche (nixpkgs, Home Manager,
#                 Noogle, Wiki). Kommt aus nixpkgs, also kein uvx/npx/Docker
#                 zur Laufzeit. Nutzt zur Abfrage das Netz (search.nixos.org).
#   ponytail   -> Plugin (Skills + /ponytail-Commands + Always-on-Ruleset).
#                 Quelle ist der Flake-Input `ponytail` (flake = false), damit
#                 die Version in flake.lock gepinnt ist und kein Hash von Hand
#                 gepflegt werden muss: `nix flake update ponytail`.
#
# Wichtig: Claude Code muss mind. 2.1.157 sein, damit Plugins als "personal
# plugins" nach ~/.claude/skills/<name> verlinkt werden. Bei älteren Versionen
# fällt HM auf den `--plugin-dir`-Wrapper zurück und warnt beim Build.
{
  pkgs,
  inputs,
  ...
}:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;

    # --- MCP ----------------------------------------------------------------
    # Landet in einem generierten Plugin namens "hm" als .mcp.json, nicht in
    # settings.json. Toolnamen daher: mcp__plugin_hm_nixos__nix bzw.
    # ..._nixos__nix_versions (mit `/mcp` in Claude Code prüfbar).
    mcpServers.nixos = {
      type = "stdio";
      command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
    };

    # --- Plugins ------------------------------------------------------------
    # Attrset-Form statt Liste: nur so bleibt der Verzeichnisname stabil
    # (Listenform leitet ihn aus dem Store-Pfad ab -> "…-source").
    plugins.ponytail = inputs.ponytail;

    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;

      permissions = {
        # Secrets sind für Claude Code tabu – auch wenn sie im Projektbaum
        # liegen würden.
        deny = [
          "Read(~/.ssh/**)"
          "Read(~/.gnupg/**)"
          "Read(~/.password-store/**)"
          "Read(./.env)"
          "Read(./secrets/**)"
          "Bash(sudo:*)" # nixos-rebuild switch macht Phoenix selbst
        ];

        ask = [
          "Bash(git push:*)"
          "Bash(git commit:*)" # Commits sind GPG-signiert -> YubiKey-Touch
        ];

        allow = [
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git log:*)"
          "Bash(git add:*)" # Flakes lesen self aus dem Git-Index
          "Bash(nix flake check:*)"
          "Bash(nix flake metadata:*)"
          "Bash(nix eval:*)"
          "Bash(nix repl:*)"
          "Bash(nixfmt:*)"
          "mcp__plugin_hm_nixos__nix"
          "mcp__plugin_hm_nixos__nix_versions"
        ];
      };

      # Nach jedem Schreibvorgang formatieren – aber nur .nix-Dateien, sonst
      # läuft nixfmt auf Markdown und schlägt fehl. Hook-Input kommt als JSON
      # auf stdin.
      hooks.PostToolUse = [
        {
          matcher = "Edit|MultiEdit|Write";
          hooks = [
            {
              type = "command";
              command = ''file=$(${pkgs.jq}/bin/jq -r '.tool_input.file_path // empty'); case "$file" in *.nix) ${pkgs.nixfmt}/bin/nixfmt "$file" ;; esac'';
            }
          ];
        }
      ];
    };

    # --- Globales CLAUDE.md -------------------------------------------------
    # Landet als ~/.claude/CLAUDE.md, gilt also für jedes Projekt. Bewusst kurz:
    # jede Zeile hier kostet in jeder Session Kontext.
    context = ''
      # Globaler Kontext

      ## Umgebung
      - NixOS unstable + Home Manager, Sway/Wayland, fish als Shell, Editor Zed
      - Formatter für Nix: nixfmt
      - `nixos-rebuild switch --flake .#<host>` führe ich selbst aus, nicht du

      ## Nix-Config (github.com/Destinyphoenix/nix)
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

      ## Arbeitsweise
      - Optionen und Pakete über das `nixos`-MCP nachsehen, nicht raten
      - Bei nicht-trivialen Entscheidungen erst Varianten mit Vor-/Nachteilen,
        dann implementieren
      - Nach Änderungen die vollständige Datei ausgeben, nicht nur den Diff
    '';
  };

  # Ponytails Lifecycle-Hooks (SessionStart/UserPromptSubmit) rufen ein nacktes
  # `node` auf. Ohne node auf dem PATH bleiben die Skills nutzbar, die
  # Always-on-Aktivierung fällt aber still aus.
  home.packages = [ pkgs.nodejs ];
}
