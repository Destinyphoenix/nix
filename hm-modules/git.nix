# Git.
#
# Identity is NOT hardcoded here — `fullName` and `mail` arrive via
# extraSpecialArgs from flake.nix, so the values live in exactly one place and
#
# API note: programs.git.userName / userEmail / aliases are deprecated renames.
# Current options are settings.user.name / settings.user.email / settings.alias.
{
  pkgs,
  fullName,
  mail,
  ...
}:

{
  programs.git = {
    enable = true;

    signing = {
      key = "${mail}"; # your .gitconfig used the email as signingkey; gpg resolves it
      format = "openpgp";
      signByDefault = true; # was [commit] gpgsign = true
    };

    settings = {
      user = {
        name = "${fullName}";
        email = "${mail}";
      };

      commit.verbose = true;
      push.autoSetupRemote = true;
      init.defaultBranch = "main";

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate --all";
        lga = "log --graph --pretty=format:'%C(auto)%h %C(blue)%ad %C(reset)%s %C(green)(%an)' --date=short";
        amend = "commit --amend --no-edit";
        undo = "reset --hard HEAD";
        last = "log -1 HEAD";
      };
    };
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true; # <- neu: gpg-agent übernimmt auch die Rolle von ssh-agent
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };
}
