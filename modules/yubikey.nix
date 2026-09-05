# modules/yubikey.nix
#
# YubiKey 5 Systemintegration: Smartcard-Zugriff (GPG/SSH), udev-Regeln,
# PAM-U2F für Login/Sway-Lock/sudo, sowie CLI/GUI-Verwaltungstools.
{ pkgs, ... }:
{
  # programs.yubikey-manager bringt automatisch mit:
  #   - ykman (CLI) in environment.systemPackages
  #   - services.pcscd.enable = true (Smartcard-Daemon)
  #   - services.udev.packages = [ yubikey-personalization ] (Berechtigungen)
  # siehe nixpkgs: nixos/modules/programs/yubikey-manager.nix
  programs.yubikey-manager.enable = true;

  # Yubico Authenticator (GUI) – TOTP/OATH-Codes verwalten und anzeigen.
  environment.systemPackages = [ pkgs.yubioath-flutter ];

  # pam_u2f: FIDO/U2F als Zweitfaktor für Login, Sway-Lock und sudo.
  # control = "sufficient" -> Yubikey ODER Passwort reicht. Erst auf
  # "required" umstellen, wenn ein zweiter, identisch registrierter
  # Backup-Key existiert – sonst Lockout-Risiko bei Verlust/Defekt.
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
    settings.cue = true; # Prompt "Bitte Yubikey berühren"
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    swaylock.u2fAuth = true;
  };
}

# gpg --expert --full-generate-key
# 11
# s Certify only
# q
# 1
# 1y
# phoenix
# mail
# enter
# O
# secure passphrase with pw manager
# finish
# gpg --expert --edit-key phoenix
# addkey
# 11
# sign only
# ...
# addkey
# authenticate only
# addkey
# 12 (encrypt)
# ..
# save
# BACKUP:
# gpg --export --armor 0x6BBCDF5E9A54FE5B > ~/pubkey.asc
# gpg --export-secret-keys --armor 0x6BBCDF5E9A54FE5B > ~/master-secret.asc
# cp ~/.gnupg/openpgp-revocs.d/0EF0568076B4BE5E09FCF7246BBCDF5E9A54FE5B.rev ~/revoke.asc
# export to key
# gpg --edit-key phoenix
# key 1 (usage: S)
# 1 (Signature key)
# pw gpg key
# pw admin yubi !!!!! 2 mal !!!!!
# key 1
# key 2 (usage: A)
# ..
# key 2
# key 3 (Usage: E)
# 2 (Encryption)
# ...
# reboot
# ykman openpgp keys set-touch aut on
# ykman openpgp keys set-touch sig on
# ykman openpgp keys set-touch enc off
# Trust
# gpg --edit-key
# trust
# 5 (Ultimate)
# gpg --export-ssh-key <KEYID> > ~/.ssh/yubikey.pub
# mkdir -p ~/.config/Yubico
# pamu2fcfg > ~/.config/Yubico/u2f_keys
