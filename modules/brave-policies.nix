# Brave enterprise policies.
#
# NixOS-Ebene, NICHT hm-modules/ — Brave liest Policies aus
# /etc/brave/policies/managed/ (laut Brave Help Center), und Home Manager
# schreibt ausschließlich nach $HOME.
#
# Place at: modules/brave-policies.nix
# Import from configuration.nix:  imports = [ ./modules/brave-policies.nix ];
#
# Verify after rebuild:  open brave://policy  -> all entries must show "OK".
{ ... }:

{
  environment.etc."brave/policies/managed/passwords.json".text = builtins.toJSON {
    # --- Built-in password manager off ------------------------------------
    # Brave stops offering to save passwords and the Settings entry is locked
    PasswordManagerEnabled = false;

    # --- Form suggestions off ---------------------------------------------
    # These two are what "form suggest" actually maps to in Chromium. There is
    # no single autofill switch; addresses and cards are separate policies.
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;

    # --- Optional: keep Proton Pass unremovable and pinned ------------------
    # Chromium has NO concept of a "default password manager", so this is the
    # closest equivalent: force-install it and pin it to the toolbar.
    #
    # Leave this commented if you are happy managing all three extensions via
    # hm-modules/brave.nix. Enabling it means Proton Pass is installed TWICE by
    # two mechanisms — harmless (same ID wins), but confusing later. Pick one.
    #
    # ExtensionInstallForcelist = [
    #   "ghmbeldphafepmbegfdlkpapadhbakde;https://clients2.google.com/service/update2/crx"
    # ];
    # ExtensionSettings = {
    #   "ghmbeldphafepmbegfdlkpapadhbakde" = {
    #     installation_mode = "force_installed";
    #     update_url = "https://clients2.google.com/service/update2/crx";
    #     toolbar_pin = "force_pinned";
    #   };
    # };
  };
  environment.etc."brave/policies/managed/spellcheck.json".text = builtins.toJSON {
    # --- Spellcheck languages -----------------------------------------------
    # SpellcheckLanguage nimmt Chromium-Sprachcodes (nicht BCP-47 mit
    # Region-Freiheit) — "en-US" statt nur "en", "de" reicht bei Deutsch.
    SpellcheckEnabled = true;
    SpellcheckLanguage = [
      "en-US"
      "de"
    ];
  };
  environment.etc."brave/policies/managed/bookmarks.json".text = builtins.toJSON {
    # --- Vordefinierte Bookmarks --------------------------------------------
    # ManagedBookmarks ist auf Linux (JSON-Policy-Datei) ein normales JSON-
    # Array — NICHT nochmal als String kodiert, das ist nur der Windows-
    # Registry-Sonderfall. Der erste Eintrag mit "toplevel_name" legt nur den
    # Ordnernamen fest und erzeugt selbst kein Bookmark. Echte Einträge:
    #   { name = "Beispiel"; url = "example.com"; }
    # Ordner lassen sich verschachteln über:
    #   { name = "Unterordner"; children = [ { name = ...; url = ...; } ]; }
    ManagedBookmarks = [
      { toplevel_name = "bm"; }
      {
        name = "type game";
        url = "https://typ.ing/text/daily-challenge";
      }
      {
        name = "github";
        url = "https://github.com/repos";
      }
      {
        name = "AI";
        children = [
          {
            name = "claude";
            url = "https://claude.ai/";
          }
          {
            name = "chat";
            url = "https://chatgpt.com/";
          }
          {
            name = "gemi";
            url = "https://gemini.google.com/app?hl=de";
          }
        ];
      }
      {
        name = "nix";
        children = [
          {
            name = "NixOS Options Search";
            url = "search.nixos.org/options";
          }
          {
            name = "NixOS Packages Search";
            url = "search.nixos.org/packages";
          }
          {
            name = "Home Manager Option Search";
            url = "home-manager-options.extranix.com";
          }
          {
            name = "Noogle (lib.* Suche)";
            url = "noogle.dev";
          }
          {
            name = "nix.dev";
            url = "nix.dev";
          }
          {
            name = "NixOS Wiki";
            url = "nixos.wiki";
          }
          {
            name = "nixpkgs (GitHub)";
            url = "github.com/NixOS/nixpkgs";
          }
          {
            name = "NixOS & Flakes Book";
            url = "nixos-and-flakes.thiscute.world";
          }
          {
            name = "vimjoyer (YouTube)";
            url = "youtube.com/@vimjoyer";
          }
          {
            name = "donvini94/nixos-config";
            url = "github.com/donvini94/nixos-config";
          }
        ];
      }
      {
        name = "Studium";
        children = [
          {
            name = "Wahlfächer";
            url = "https://raumzeit.hka-iwi.de/private/student/electives";
          }
          {
            name = "Stundenplan";
            url = "https://raumzeit.hka-iwi.de/private/student/plans";
          }
          {
            name = "mail";
            url = "https://owa.h-ka.de/";
          }
          {
            name = "prüfungsverwaltung";
            url = "https://qis-extern.hs-karlsruhe.de/";
          }
          {
            name = "verwaltung";
            url = " https://hisinone.extern-hs-karlsruhe.de";
          }
          {
            name = "ilias";
            url = "https://ilias.h-ka.de/";
          }
          {
            name = "modulhandbuch";
            url = "https://raumzeit.hka-iwi.de/mhb/INFB/8";
          }
          {
            name = "mfa";
            url = "https://mfa.h-ka.de/";
          }
        ];
      }
      {
        name = "Jobs";
        children = [
          {
            name = "Workwise";
            url = "https://www.workwise.io/profil";
          }
        ];
      }
    ];

    # Ohne die Bookmark-Leiste bleibt der Ordner unsichtbar.
    BookmarkBarEnabled = true;
  };
}
