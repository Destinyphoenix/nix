# Zed editor.
#
# Unlike tofi, Home Manager has a native `programs.zed-editor` module, so this
# is real declarative config rather than a written-out file.
#
# Mutability split — this mirrors how your dotfiles repo already treats Zed:
#   keymap.json   -> tracked in git  -> mutableUserKeymaps = false (store symlink,
#                                       read-only, this file is the source of truth)
#   settings.json -> NOT tracked     -> mutableUserSettings = true (default; HM
#                                       merges the values below into whatever Zed
#                                       writes, so in-app setting changes survive)
#
# Consequence of mutableUserSettings = true: userSettings act as a *floor*, not a
# lock. Zed can override them at runtime. If you ever want settings fully pinned,
# flip it to false — but then Zed cannot save any preference to disk.
{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    # Sets EDITOR/VISUAL to `zeditor --wait`. Your .gitconfig currently hardcodes
    # `editor = zeditor` (without --wait, which can misbehave for commit messages).
    # With this on you can drop that line from .gitconfig and let git use $EDITOR.
    defaultEditor = true;

    # Keymap is version-controlled, so make it immutable and authoritative.
    mutableUserKeymaps = false;

    # Language servers and tools put on Zed's PATH. Zed is wrapped so it finds
    # these without them polluting your global environment.
    extraPackages = with pkgs; [
      nixd # Nix LSP. Your reference flake uses `nil` instead — swap if preferred.
      nixfmt # formatter for Nix
    ];

    # Auto-installed on startup. Names are repo names from
    # github.com/zed-industries/extensions — verify before adding new ones.
    extensions = [
      "nix"
      "toml"
      "fish"
    ];

    userSettings = {
      vim_mode = true; # your keymap uses the VimControl context, which only exists in vim mode

      # --- Fonts ------------------------------------------------------------
      # Matches the Noto Sans Mono you use in tofi. Change freely — this is the
      # one block I had no existing source of truth for.
      buffer_font_family = "Noto Sans Mono";
      buffer_font_size = 15;
      ui_font_size = 15;

      # --- Privacy / AI -----------------------------------------------------
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      features.edit_prediction_provider = "none";

      # --- Editor behaviour -------------------------------------------------
      format_on_save = "on";
      relative_line_numbers = true; # sensible with vim mode
      terminal.shell.program = "fish"; # you use fish

      # --- Nix language server ----------------------------------------------
      languages.Nix.language_servers = [ "nixd" ];
      lsp.nixd.settings.formatting.command = [ "nixfmt" ];
    };

    # Faithful port of .config/zed/keymap.json.
    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          # "shift shift" = "file_finder::Toggle";
          "shift shift" = "terminal_panel::ToggleFocus";
          "ctrl-w" = "pane::CloseActiveItem";
          "alt-h" = "workspace::ToggleLeftDock";
          "alt-j" = "workspace::ToggleBottomDock";
          "alt-k" = "workspace::ToggleRightDock";
        };
      }

      {
        context = "editor";
        bindings = {
          # "j k" = [ "workspace::SendKeystrokes" "escape" ];
        };
      }

      {
        context = "VimControl";
        bindings = {
          "ctrl-w" = "pane::CloseActiveItem";
          "space w v" = "pane::SplitVertical";
          "space w w" = "workspace::ActivateNextPane";
          "space w d" = "pane::CloseActiveItem";
          "space ." = "file_finder::Toggle";
          "space f s" = "workspace::Save";
          "space t n" = "workspace::OpenInTerminal";
          "t t" = "workspace::OpenInTerminal";
          "space c c" = "vim::ToggleComments";
          "space p p" = "projects::OpenRecent";
          "space g g" = "git::Add";
          "space ö ö" = "editor::Tab";
        };
      }

      {
        context = "Terminal";
        bindings = {
          "shift shift" = "workspace::ActivateLastPane";
          "ctrl-w" = "pane::CloseActiveItem";
        };
      }
    ];
  };
}
