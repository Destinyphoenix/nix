# Git.
#
# Identity is NOT hardcoded here — `fullName` and `mail` arrive via
# extraSpecialArgs from flake.nix, so the values live in exactly one place and
# are reusable by other modules (ssh, gpg, email). Same pattern as the
# donvini94 reference repo.
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

      # core.editor is intentionally omitted: programs.zed-editor.defaultEditor
      # sets EDITOR/VISUAL to `zeditor --wait`, which git picks up automatically
      # and which blocks correctly while you write a commit message. Uncomment
      # only if you want git to diverge from $EDITOR.
      # core.editor = "zeditor --wait";

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
        # Destructive: discards ALL uncommitted work in the tree, not just the
        # last commit. Ported as-is from your .gitconfig. If what you actually
        # wanted was "undo the last commit but keep my changes", that is
        # `reset --soft HEAD~1`.
        undo = "reset --hard HEAD";
        last = "log -1 HEAD";
      };
    };
  };

  # Signing needs a working gpg-agent with a pinentry, or every commit fails.
  # The *key itself* stays outside Nix (it is a secret — keep generating it with
  # `gpg --full-generate-key` as in your init.sh, or restore from backup).
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3; # use pinentry-curses on a TTY-only host
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };
}
