# LaTeX-Integration: Schreiben in Zed, Build-on-Save über texlab + latexmk,
# Anzeige in Zathura.
#
# Zed kann PDFs nicht selbst darstellen, daher läuft Zathura daneben und ist
# per SyncTeX in beide Richtungen gekoppelt:
#   vorwärts:   Speichern in Zed -> latexmk baut -> Zathura springt zur Cursorzeile
#   rückwärts:  Strg+Klick im PDF -> Zed springt zur passenden Zeile im .tex
#
# Ergänzt nur die bestehende Zed-Config aus hm-modules/zed.nix – Listen
# (extensions, extraPackages) und userSettings werden von HM zusammengeführt.
{
  pkgs,
  lib,
  config,
  theme,
  ...
}:

let
  # Befehl, mit dem Zathura bei Rückwärtssuche Zed an der Zeile öffnet.
  editorCommand = "zeditor %{input}:%{line}";
in
{
  # --- TeX Live -------------------------------------------------------------
  # scheme-full enthält alle CTAN-Pakete, also auch latexmk, biber, chktex,
  # collection-langgerman usw. – einzelne Pakete müssen nicht mehr ergänzt werden.
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs) scheme-full; };
  };

  # --- Zathura (PDF-Viewer) ---------------------------------------------------
  programs.zathura = {
    enable = true;
    options = {
      synctex = true;
      synctex-editor-command = editorCommand;
      selection-clipboard = "clipboard"; # markierter Text landet in Strg+V

      font = "${theme.font} ${toString theme.fontSize}";
      default-bg = theme.background;
      default-fg = theme.foreground;
      statusbar-bg = theme.surface;
      statusbar-fg = theme.foreground;
      inputbar-bg = theme.surface;
      inputbar-fg = theme.foreground;
      notification-error-bg = theme.error;
      notification-error-fg = theme.background;
      notification-warning-bg = theme.warning;
      notification-warning-fg = theme.background;
      highlight-color = theme.primary;
      highlight-active-color = theme.accent;

      # Dunkles PDF per Strg+r (recolor), standardmäßig aus.
      recolor-darkcolor = theme.foreground;
      recolor-lightcolor = theme.background;
    };
  };

  # PDFs generell mit Zathura öffnen.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
  };

  # --- Zed --------------------------------------------------------------------
  programs.zed-editor = {
    extensions = [ "latex" ]; # Zed-Extension, nutzt texlab als LSP

    # texlab aus nixpkgs statt Download durch die Extension.
    extraPackages = [ pkgs.texlab ];

    userSettings.lsp.texlab.settings.texlab = {
      # Bei jedem Speichern bauen und danach im Viewer zur Cursorzeile springen.
      # Hilfsdateien (aux, log, fls, …) landen in build/, nur PDF und SyncTeX im Projektordner.
      build = {
        onSave = true;
        forwardSearchAfter = true;
        executable = "latexmk";
        args = [
          "-pdf"
          "-interaction=nonstopmode"
          "-synctex=1"
          "-auxdir=build"
          "%f"
        ];
        # texlab muss wissen, wo das Log liegt (für Fehler und Warnungen im Editor)
        #pdfDirectory = "build";
        auxDirectory = "build";
        logDirectory = "build";
      };

      # Vorwärtssuche: öffnet Zathura bzw. springt in der laufenden Instanz.
      forwardSearch = {
        executable = lib.getExe config.programs.zathura.package;
        args = [
          "--synctex-forward"
          "%l:1:%f"
          "-x"
          editorCommand
          "%p"
        ];
      };

      chktex.onOpenAndSave = true;
    };
  };
}
