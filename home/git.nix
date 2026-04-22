{ pkgs, secrets, ... }:

{
  # ── Delta ─────────────────────────────────────────────────────────────────────
  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate      = true;
      light         = false;
      side-by-side  = true;
      line-numbers  = true;
      syntax-theme  = "ansi";
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    settings = {
      user.name  = secrets.fullName;
      user.email = secrets.email;

      init.defaultBranch = "main";

      core = {
        autocrlf = "input";
        editor   = "nvim";
        pager    = "delta";
      };

      pull.rebase  = true;
      push.default = "current";
      push.autoSetupRemote = true;

      rebase.autostash  = true;
      rebase.autosquash = true;

      merge.conflictstyle = "zdiff3";
      diff.algorithm      = "histogram";

      feature.manyFiles = true;

      alias = {
        st       = "status -sb";
        wip      = "!git add -A && git commit -m 'wip'";
        undo     = "reset HEAD~1 --mixed";
        unstage  = "restore --staged";
        aliases  = "config --get-regexp alias";
        branches = "branch -a --sort=-committerdate";
        tags     = "tag -l --sort=-version:refname";
      };
    };

    ignores = [
      ".DS_Store"
      "Thumbs.db"
      "*.swp" "*.swo" "*~"
      ".direnv/"
      ".envrc"
      ".idea/" ".vscode/" "*.iml"
      "result" "result-*"
      "vendor/"
      "target/"
      "*.env" ".env*"
    ];
  };

  # ── GitHub CLI ────────────────────────────────────────────────────────────────
  programs.gh = {
    enable   = true;
    settings = {
      git_protocol = "ssh";
      prompt       = "enabled";
    };
  };

  # ── SSH ───────────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable              = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "github.com" = {
        hostname       = "github.com";
        user           = "git";
        identityFile   = "~/.ssh/id_ed25519";
        addKeysToAgent = "yes";
      };

      # Catch-all for general SSH connections
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };
}
