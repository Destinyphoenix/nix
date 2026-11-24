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
#   ponytail   -> Plugin über lokalen Marketplace (Skills, Commands, Hooks, Band).
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
  # Claude Code registriert zur Laufzeit seinen URL-Handler in mimeapps.list und
  # ersetzt damit den HM-Symlink → Eintrag deklarativ und HM darf überschreiben.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
  };
  xdg.configFile."mimeapps.list".force = true;

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
    # Als lokaler Marketplace statt `plugins.*`: nur echt installierte Plugins
    # laden Hooks und Band-Module, als Personal Plugin laufen nur die Skills.
    # Version bleibt über den Flake-Input in flake.lock gepinnt.
    marketplaces.ponytail = inputs.ponytail;

    settings = {
      theme = "dark";
      enabledPlugins."ponytail@ponytail" = true;
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

      # Die Sandbox blockt unter Linux Unix-Sockets per seccomp (pfadgenaues
      # allowUnixSockets geht nur auf macOS). nix braucht den Daemon-Socket,
      # läuft deshalb außerhalb der Sandbox – Permission-Regeln gelten weiter.
      sandbox.excludedCommands = [ "nix" ];

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
    # jede Zeile hier kostet in jeder Session Kontext. Was nur für dieses Repo
    # gilt, steht in ./CLAUDE.md im Root der Config.
    context = ''
      # Globaler Kontext

      ## Umgebung
      - NixOS unstable + Home Manager, Sway/Wayland, fish als Shell, Editor Zed
      - Formatter für Nix: nixfmt

      ## Arbeitsweise
      - Bei Coding-Aufgaben immer zuerst den Skill `ponytail` aufrufen
      - Nix-Optionen und -Pakete über das `nixos`-MCP nachsehen, nicht raten
      - Bei nicht-trivialen Entscheidungen erst Varianten mit Vor-/Nachteilen,
        dann implementieren
    '';
  };

  # Ponytails Lifecycle-Hooks (SessionStart/UserPromptSubmit) rufen ein nacktes
  # `node` auf. Ohne node auf dem PATH bleiben die Skills nutzbar, die
  # Always-on-Aktivierung fällt aber still aus.
  home.packages = [ pkgs.nodejs ];
}
