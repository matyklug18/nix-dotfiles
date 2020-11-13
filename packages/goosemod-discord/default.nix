{ pkgs }:
((pkgs.discord
  .override {
   pname = "goosemod-discord";
   binaryName = "goosemod-Discord";
    desktopName = "goosemod-Discord";
  })
  .overrideAttrs (oldAttrs: {
    preInstall = ''
      mv Discord goosemod-Discord
    '';

    installPhase = ''
      runHook preInstall

      ${oldAttrs.installPhase}

      runHook postInstall
    '';

    postInstall = ''
      wrapProgram $out/opt/goosemod-Discord/goosemod-Discord \
        "''${gappsWrapperArgs[@]}" \
        --run 'export XDG_CONFIG_HOME=$HOME/.config/goosemod-discord' \
        --run 'mkdir -p $HOME/.config/goosemod-discord/discord' \
        --run $'echo \'{"UPDATE_ENDPOINT":"https://updates.goosemod.tk"}\' > "$HOME/.config/goosemod-discord/discord/settings.json"'
    '';
  })
)
