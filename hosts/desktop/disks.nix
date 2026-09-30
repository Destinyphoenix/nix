# hosts/<hostname>/disks.nix
#
# Zusätzliche Festplatten für diesen Host, getrennt nach:
#   - extraDisks:       immer gemountet (normaler Boot, jede Session)
#   - extraDisksGaming: NUR gemountet, wenn die gaming-Specialisation
#                        gebootet wird (siehe specialisations/gaming.nix)
#
# Quick-Guide zum Ergänzen einer neuen Platte:
#   1. `lsblk -f` auf dem Host ausführen, UUID + Dateisystemtyp notieren
#   2. Unten im passenden Array (extraDisks oder extraDisksGaming) einen
#      Eintrag anhängen:
#        {
#          mountPoint = "/mnt/mein-mountpoint";
#          uuid = "xxxx-xxxx-...";
#          fsType = "xfs"; # oder ext4/btrfs/...
#        }
#   3. `git add -A` + `sudo nixos-rebuild switch --flake .#<host>`
#      (für extraDisksGaming zusätzlich: gaming-Specialisation im Bootmenü wählen)
{
  extraDisks = [
    # Beispiel, aktuell ungenutzt – hier landen Platten, die IMMER gemountet
    # werden sollen, unabhängig von der gaming-Specialisation:
    # {
    #   mountPoint = "/mnt/hdd1tb";
    #   uuid = "1548a8a2-7e1e-4238-812c-3dd55ec4b9b1";
    #   fsType = "xfs";
    # }
  ];

  extraDisksGaming = [
    {
      mountPoint = "/mnt/ssd1tb";
      uuid = "a7691747-a001-49da-954e-28ba9b9e731e";
      fsType = "xfs";
    }
    {
      mountPoint = "/mnt/ssd2tb";
      uuid = "a517c1c3-045b-422b-8664-b9ccb599bf9f";
      fsType = "xfs";
    }
    {
      mountPoint = "/mnt/m21tb";
      uuid = "8cb19ddf-383c-4ca3-8f43-5777c9bd5696";
      fsType = "xfs";
    }
  ];
}
