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
    # ("managed by your organization"). This is what clears the field for
    # Proton Pass — see the note about "main one" below.
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
}
