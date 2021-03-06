{ pname, version, src, binaryName, desktopName
, autoPatchelfHook, fetchurl, makeDesktopItem, stdenv, wrapGAppsHook
, alsaLib, at-spi2-atk, at-spi2-core, atk, cairo, cups, dbus, expat, fontconfig
, freetype, gdk-pixbuf, glib, gtk3, libcxx, libdrm, libnotify, libpulseaudio, libuuid
, libX11, libXScrnSaver, libXcomposite, libXcursor, libXdamage, libXext
, libXfixes, libXi, libXrandr, libXrender, libXtst, libxcb
, mesa, nspr, nss, pango, systemd, libappindicator-gtk3, libdbusmenu
, openssl_1_0_2, gcc-unwrapped
, curl
}:

let
  inherit binaryName;
  app-asar = builtins.fetchurl {
    url = "https://cdn.discordapp.com/attachments/711334470397067304/773310487789568000/app.asar";
    sha256 = "ecb0fdedc123c07dfd0a8e03c3501e7c8d1af86866eedbf2d2dd2c5c014e7d90";
  };
in stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    alsaLib
    autoPatchelfHook
    cups
    libdrm
    libuuid
    libX11
    libXScrnSaver
    libXtst
    libxcb
    mesa.drivers
    nss
    wrapGAppsHook

    openssl_1_0_2
    gcc-unwrapped
  ];

  dontWrapGApps = true;

  libPath = stdenv.lib.makeLibraryPath [
    libcxx systemd libpulseaudio
    stdenv.cc.cc alsaLib atk at-spi2-atk at-spi2-core cairo cups dbus expat fontconfig freetype
    gdk-pixbuf glib gtk3 libnotify libX11 libXcomposite libuuid
    libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender
    libXtst nspr nss libxcb pango systemd libXScrnSaver
    libappindicator-gtk3 libdbusmenu

    openssl_1_0_2 gcc-unwrapped
  ];

  installPhase = ''
    mkdir -p $out/{bin,opt/${binaryName},share/pixmaps}
    mv * $out/opt/${binaryName}
    chmod +x $out/opt/${binaryName}/${binaryName}
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
        $out/opt/${binaryName}/${binaryName}
    wrapProgram $out/opt/${binaryName}/${binaryName} \
        "''${gappsWrapperArgs[@]}" \
        --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
        --prefix LD_LIBRARY_PATH : ${libPath}
    ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
    ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png
    ln -s "${desktopItem}/share/applications" $out/share/

    cp ${app-asar} $out/opt/${binaryName}/resources/app.asar
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    exec = binaryName;
    icon = pname;
    inherit desktopName;
    genericName = meta.description;
    categories = "Network;InstantMessaging;";
    mimeType = "x-scheme-handler/discord";
  };

  passthru.updateScript = ./update-discord.sh;

  meta = with stdenv.lib; {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    downloadPage = "https://discordapp.com/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ ldesgoui MP2E tadeokondrak ];
    platforms = [ "x86_64-linux" ];
  };
}
