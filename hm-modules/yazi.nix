# Yazi — Terminal-Dateimanager (Ersatz/Ergänzung zu nautilus, Mod4+e).
#
# Home Manager hat ein natives `programs.yazi`-Modul, anders als bei tofi
# (dort gibt's keins -> raw xdg.configFile). Hier schreiben wir also echte
# Nix-Attrsets statt TOML-Strings; HM serialisiert sie selbst.
#
# Gestartet über Mod4+Shift+e (kitty -e yazi), siehe hm-sway.nix.
# Theming: 1:1 auf Phoenix-Ember-Tokens gemappt, analog zu terminal.nix
# (kitty) und tofi.nix — jede sichtbare Sektion bekommt einen Token, keine
# frei erfundenen Farben.
{ pkgs, theme, ... }:

let
  # Kurzform-Styles, um Wiederholung in der theme.toml-Struktur klein zu
  # halten (analog zu den ANSI-Farbblöcken in terminal.nix).
  bold = style: style // { bold = true; };
  italic = style: style // { italic = true; };
in
{

  programs.yazi = {
    enable = true;
    enableFishIntegration = true; # `y`-Wrapper: cd ins letzte Verzeichnis beim Beenden
    shellWrapperName = "y";
    keymap.mgr.prepend_keymap = [
      {
        on = [ "T" ];
        #run = "shell 'kitty -e fish' --confirm";
        run = ''shell "$SHELL" --block'';
        desc = "Terminal im aktuellen Verzeichnis öffnen";
      }
    ];
    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        tab_size = 2;
        max_width = 1200;
        max_height = 1200;
      };

      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
      };
    };

    theme = {
      mgr = {
        cwd = {
          fg = theme.primary;
        };

        find_keyword = bold { fg = theme.warning; };
        find_position = {
          fg = theme.muted;
        };

        symlink_target = italic { fg = theme.muted; };

        marker_copied = {
          fg = theme.success;
          bg = theme.success;
        };
        marker_cut = {
          fg = theme.error;
          bg = theme.error;
        };
        marker_marked = {
          fg = theme.warning;
          bg = theme.warning;
        };
        marker_selected = {
          fg = theme.primary;
          bg = theme.primary;
        };

        count_copied = {
          fg = theme.background;
          bg = theme.success;
        };
        count_cut = {
          fg = theme.background;
          bg = theme.error;
        };
        count_selected = {
          fg = theme.background;
          bg = theme.primary;
        };

        border_symbol = "│";
        border_style = {
          fg = theme.border;
        };
      };

      indicator = {
        parent = {
          fg = theme.muted;
        };
        current = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        preview = {
          fg = theme.muted;
        };
      };

      tabs = {
        active = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        inactive = {
          fg = theme.muted;
          bg = theme.surface;
        };
        sep_inner = {
          open = "";
          close = "";
        };
        sep_outer = {
          open = "";
          close = "";
        };
      };

      mode = {
        normal_main = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        normal_alt = {
          fg = theme.primary;
          bg = theme.surface;
        };

        select_main = bold {
          fg = theme.background;
          bg = theme.warning;
        };
        select_alt = {
          fg = theme.warning;
          bg = theme.surface;
        };

        unset_main = bold {
          fg = theme.background;
          bg = theme.error;
        };
        unset_alt = {
          fg = theme.error;
          bg = theme.surface;
        };
      };

      status = {
        overall = {
          fg = theme.foreground;
          bg = theme.surface;
        };
        sep_left = {
          open = "";
          close = "";
        };
        sep_right = {
          open = "";
          close = "";
        };

        perm_type = {
          fg = theme.info;
        };
        perm_read = {
          fg = theme.warning;
        };
        perm_write = {
          fg = theme.error;
        };
        perm_exec = {
          fg = theme.success;
        };
        perm_sep = {
          fg = theme.muted;
        };

        progress_label = bold { fg = theme.foreground; };
        progress_normal = {
          fg = theme.primary;
          bg = theme.surface;
        };
        progress_error = {
          fg = theme.error;
          bg = theme.surface;
        };
      };

      which = {
        border = {
          fg = theme.primary;
        };
        cols = 2;
        mask = {
          bg = theme.background;
        };
        cand = {
          fg = theme.primary;
        };
        rest = {
          fg = theme.muted;
        };
        desc = {
          fg = theme.foreground;
        };
        separator = " → ";
        separator_style = {
          fg = theme.border;
        };
      };

      confirm = {
        border = {
          fg = theme.primary;
        };
        title = bold { fg = theme.primary; };
        body = {
          fg = theme.foreground;
        };
        list = {
          fg = theme.muted;
        };
        btn_yes = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        btn_no = {
          fg = theme.muted;
          bg = theme.surface;
        };
        btn_labels = [
          " Yes "
          " No "
        ];
      };

      spot = {
        border = {
          fg = theme.primary;
        };
        title = bold { fg = theme.primary; };
        tbl_col = {
          fg = theme.primary;
        };
        tbl_cell = {
          fg = theme.background;
          bg = theme.primary;
        };
      };

      notify = {
        title_info = {
          fg = theme.info;
        };
        title_warn = {
          fg = theme.warning;
        };
        title_error = {
          fg = theme.error;
        };
      };

      pick = {
        border = {
          fg = theme.primary;
        };
        active = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        inactive = {
          fg = theme.foreground;
        };
      };

      input = {
        border = {
          fg = theme.primary;
        };
        title = bold { fg = theme.primary; };
        value = {
          fg = theme.foreground;
        };
        selected = {
          fg = theme.background;
          bg = theme.primary;
        };
      };

      cmp = {
        border = {
          fg = theme.primary;
        };
        active = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        inactive = {
          fg = theme.foreground;
        };
        icon_file = "󰈔";
        icon_folder = "󰉋";
        icon_command = "";
      };

      tasks = {
        border = {
          fg = theme.primary;
        };
        title = bold { fg = theme.primary; };
        hovered = {
          fg = theme.background;
          bg = theme.primary;
        };
      };

      help = {
        border = {
          fg = theme.primary;
        };
        chord = bold {
          fg = theme.background;
          bg = theme.primary;
        };
        action = {
          fg = theme.foreground;
        };
        hovered = bold { fg = theme.primary; };
      };

      filetype = {
        rules = [
          # Verzeichnisse
          {
            url = "*/";
            fg = theme.primary;
            bold = true;
          }

          # Medien
          {
            mime = "image/*";
            fg = theme.success;
          }
          {
            mime = "{audio,video}/*";
            fg = theme.info;
          }

          # Archive
          {
            mime = "application/{zip,gzip,x-tar,x-bzip*,x-7z-compressed,x-rar,x-xz,zstd}";
            fg = theme.error;
          }

          # Leere Dateien
          {
            mime = "inode/empty";
            fg = theme.muted;
          }

          # Verwaiste Symlinks zuerst, sonst normale Symlinks
          {
            url = "*";
            is = "orphan";
            fg = theme.error;
            italic = true;
          }
          {
            url = "*";
            is = "link";
            fg = theme.warning;
            italic = true;
          }

          # Ausführbare Dateien
          {
            url = "*";
            is = "exec";
            fg = theme.success;
            bold = true;
          }

          # Fallback
          {
            url = "*";
            fg = theme.foreground;
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    yazi
    ffmpegthumbnailer # Video-Thumbnails im Preview
    unar # Archiv-Preview/Extraktion
    jq # JSON-Preview
    poppler # PDF-Preview
  ];
  # in hm-modules/yazi.nix, als neue Top-Level-Option neben settings/theme:
}
