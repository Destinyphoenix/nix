{ pkgs, ... }:

# Rotierender Hintergrund via wpaperd, gespeist aus dem wallpaper/-Ordner im
# Repo (selber Ordner wie lock.png in hm-sway.nix). lock.png wird
# ausgeschlossen, da sie für swaylock reserviert ist.
let
  wallpapers = pkgs.runCommand "wallpapers" { } ''
    mkdir -p $out
    cp ${../../wallpaper}/*.png $out/
    rm -f $out/lock.png
  '';
in
{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "${wallpapers}";
        duration = "1h"; # Wechselintervall
        sorting = "random"; # oder "ascending" für der-Reihe-nach
        mode = "fit"; # expected one of `stretch`, `center`, `fit`, `tile`, `fit-border-color`
      };
    };
  };
}
