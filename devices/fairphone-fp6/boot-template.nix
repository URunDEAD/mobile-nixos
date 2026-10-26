{ requireFile }:

# A boot.img in the FP6's Android header v2 format, used only for its
# kernel, DTB and header layout (see ./default.nix). Temporary.
requireFile {
  name = "fairphone-fp6-boot-template.img";
  sha256 = "98ed20373d229a5ebac482f81f7f601150137db3d9f5220ef8b6d6feab781cf8";
  message = ''
    Provide a known-good FP6 header v2 boot image built from the kernel in
    ./kernel (kernel Image.gz + milos-fairphone-fp6.dtb), then add it with:
      nix-store --add-fixed sha256 fairphone-fp6-boot-template.img
  '';
}
