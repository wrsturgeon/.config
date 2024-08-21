ctx: {
  etc = {
    gitignore.text = ''
      **/.DS_Store
    '';
  };
  extraInit = ''
    echo 'Hello from `extraInit`!'
  '';
  pathsToLink = [ "/share/zsh" ];
  shellAliases = {
    e = "emacs";
    vi = "vim";
    vim = "nvim";
  };
  systemPackages =
    ctx.dock-apps
    ++ (with ctx; [
      emacs
      git
      vim
    ])
    ++ (with ctx.pkgs; [
      cargo
      coreutils-full
      fd
      gcc
      gimp
      gnumake
      nil
      nixfmt-rfc-style
      ripgrep
      rss2email
      rust-analyzer
      rustfmt
      taplo
      tree
      # wezterm
      zoom-us
    ])
    ++ (with ctx.pkgs.coqPackages; [ coq ])
    ++ (ctx.linux-mac [ ] [ ctx.pkgs.vlc-bin ]);
  variables = {
    EDITOR = "vi";
    LANG = "fr_FR.UTF-8";
  };
}
