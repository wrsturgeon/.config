ctx:
let
  inherit (ctx) pkgs linux-mac;
  spacer = " ";
  os-emoji = linux-mac ":penguin:" ":apple:";
  extra-options = linux-mac "--install-bootloader" "--option sandbox false";
  cmd = linux-mac "${sudo} -A nixos-rebuild" "${nix} --extra-experimental-features flakes --extra-experimental-features nix-command run --no-sandbox nix-darwin --";
  config-dir = "/etc/nixos";
  users-dir = linux-mac "/home" "/Users";

  cut = "${pkgs.coreutils}/bin/cut";
  date = "${pkgs.coreutils}/bin/date";
  gh = "${pkgs.gh}/bin/gh";
  git = "${ctx.git}/bin/git";
  grep = "${pkgs.gnugrep}/bin/grep";
  ls = "${pkgs.coreutils}/bin/ls";
  make = "${pkgs.gnumake}/bin/make";
  nix = "${nix-version}/bin/nix"; # for now
  nix-collect-garbage = "${nix-version}/bin/nix-collect-garbage";
  nix-store = "${nix-version}/bin/nix-store";
  nix-version = pkgs.nixVersions.latest;
  nixfmt = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
  rm = "${pkgs.coreutils}/bin/rm";
  sed = "${pkgs.gnused}/bin/sed";
  stat = "${pkgs.coreutils}/bin/stat";
  sudo = "sudo"; # for now
  touch = "${pkgs.coreutils}/bin/touch";
  xargs = "${pkgs.findutils}/bin/xargs -r";

in
pkgs.writeScriptBin "rebuild" ''
  #!${pkgs.bash}/bin/bash

  set -eu

  # ${gh} api user --jq '.login' &> /dev/null || ${gh} auth login

  export GITHUB_USERNAME="$(${gh} api user --jq '.login')"
  export COMMIT_PREFIX='`'"$(${date} '+%Y/%m/%d %H:%M:%S')"'`${spacer}${os-emoji}'

  # Synchronize Logseq notes:
  cd ${users-dir}
  for user in $(${ls} .); do
    if [ -d ${users-dir}/''${user}/Desktop/logseq/.git ]; then
      cd ${users-dir}/''${user}/Desktop/logseq
      ${git} pull
      ${git} submodule update --init --recursive --remote
      ${make} .updated
      ${git} add -A
      if [ -z "$(${git} status --porcelain)" ]; then :; else
        ${git} commit -m "''${COMMIT_PREFIX}"
        ${git} push
      fi
    fi
  done

  # Nav to the configuration directory:
  cd ${config-dir}

  ${git} config --global --add safe.directory ${config-dir}/.git

  ${git} fetch --all
  if [ -z "$(${git} status --porcelain)" ]; then
    ${git} pull
  fi

  ${nixfmt} .

  # Check if anything changed, and, if so, remove the success/failure flag:
  if [ -z "$(${git} status --porcelain)" ]; then :; else
    ${rm} -f .build-succeeded .build-failed
  fi

  # Push changes upstream with a W.I.P. note (wrench emoji):
  if [ "''${GITHUB_USERNAME}" = "wrsturgeon" ]; then
    if [ -f .build-succeeded ]; then :; else
      if [ -f .build-failed ]; then :; else
        ${git} add -A
        ${git} commit -m "''${COMMIT_PREFIX}${spacer}:wrench:"
        ${git} push
      fi
    fi
  fi

  # Update dependencies:
  if [ "''${GITHUB_USERNAME}" = "wrsturgeon" ]; then
    ${nix} flake update || : # rate limits!
    if [ -z "$(${git} status --porcelain)" ]; then :; else
      ${git} add -A
      ${git} commit -m "''${COMMIT_PREFIX}${spacer}:arrow_up:"
      ${git} push
    fi
  fi

  # Rebuild the Nix system:
  if
    ${cmd} switch --flake ${config-dir} --keep-going -v -j auto --show-trace ${extra-options}
  then
    export BUILD_STATUS_FILE='.build-succeeded'
    export STATUS_EMOJI=':white_check_mark:'
  else
    export BUILD_STATUS_FILE='.build-failed'
    export STATUS_EMOJI=':fire:'
  fi

  cd ${config-dir}
  ${rm} -f .build-succeeded .build-failed
  ${touch} ''${BUILD_STATUS_FILE}
  if [ "''${GITHUB_USERNAME}" = "wrsturgeon" ]; then
    ${git} status --porcelain | ${cut} -d ' ' -f 2 | ${grep} '^\.build' | ${xargs} ${git} add
    ${git} commit -m "''${COMMIT_PREFIX}${spacer}''${STATUS_EMOJI}"
    ${git} push
  fi

  if [ "''${BUILD_STATUS_FILE}" = '.build-succeeded' ]; then

    # Delete all old `result` symlinks from `nix build`s:
    ${nix-store} --gc --print-roots | ${grep} 'result -> ' | ${sed} -n -e 's/ -> .*$//p' | ${xargs} ${rm} -f

    # Delete old `.direnv` environments:
    export ONE_WEEK_AGO="$(( $(${date} +%s) - 604800 ))"
    for d in $(${nix-store} --gc --print-roots | ${grep} '/\.direnv' | ${sed} -n -e 's/.direnv.*$/.direnv/p'); do
      if (( "$(${stat} --format '%X' "''${d}")" < "''${ONE_WEEK_AGO}" )); then
        ${rm} -fr "''${d}"
      fi
    done

    # From <https://nixos.wiki/wiki/Cleaning_the_nix_store>:
    ${nix-store} --gc --print-roots | ${grep} -E -v "^(/nix/var|/run/\w+-system|\{memory|/proc)" | ${sed} -n -e 's/ -> .*$//p' | ${grep} -v '^{censored}$' | ${grep} -v '^{lsof}$' | ${grep} -v '^/var/root/.cache/nix/flake-registry.json$' | ${xargs} ${rm} -f

    # Garbage collection:
    ${nix-collect-garbage} --delete-older-than 1d --verbose

    # Store optimization:
    ${nix-store} --optimise --verbose

  fi
''
