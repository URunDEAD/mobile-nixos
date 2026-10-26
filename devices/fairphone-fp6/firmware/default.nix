{ runCommand
, requireFile
}:

# The FP6 firmware (ADSP/CDSP/modem/WPSS, GPU zap shader, Wi-Fi/BT, audio
# topology) is not redistributable from here. It has to be extracted from
# the device's own firmware partitions (or from the postmarketOS
# firmware-fairphone-fp6 package) into a tarball containing lib/firmware/.
let
  tarball = requireFile {
    name = "fairphone-fp6-firmware.tar";
    sha256 = "e4d88aec68ce982304c559c88ee1aa4e9433c4fc248550785f0ef48d6cb13568";
    message = ''
      Extract the Fairphone 6 firmware into a tarball with a top-level
      firmware/ directory (as installed under /lib), then add it with:
        nix-store --add-fixed sha256 fairphone-fp6-firmware.tar
    '';
  };
in
runCommand "fairphone-fp6-firmware" {} ''
  mkdir -p $out/lib
  tar xf ${tarball} -C $out/lib
  if [ -d $out/lib/firmware/postmarketos ]; then
    cp $out/lib/firmware/postmarketos/* $out/lib/firmware/
  fi
''
