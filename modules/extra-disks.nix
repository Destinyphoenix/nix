# modules/extra-disks.nix
#
# Mountet die "extraDisks"-Liste aus hosts/<hostname>/disks.nix – diese
# Platten sind IMMER aktiv, unabhängig von Specialisations. Für Platten,
# die nur in der gaming-Specialisation gemountet werden sollen, siehe
# extraDisksGaming in derselben disks.nix (wird von specialisations/gaming.nix
# ausgewertet, nicht hier).
{
  lib,
  extraDisks ? [ ],
  ...
}:
{
  fileSystems = lib.listToAttrs (
    map (disk: {
      name = disk.mountPoint;
      value = {
        device = "/dev/disk/by-uuid/${disk.uuid}";
        fsType = disk.fsType or "xfs";
        options = [
          "nofail"
          "x-systemd.automount"
          "x-systemd.device-timeout=10"
          "x-systemd.mkdir"
        ]
        ++ (disk.options or [ ]);
      };
    }) extraDisks
  );
}
