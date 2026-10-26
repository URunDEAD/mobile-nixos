{ config, lib, pkgs, ... }:

# Fairphone (Gen. 6), Qualcomm SM7635 ("milos").
#
# DRAFT: see README.adoc for what still blocks upstreaming (vendor
# firmware source, Android boot image header v2 with a separate DTB).

{
  mobile.device.name = "fairphone-fp6";
  mobile.device.identity = {
    name = "Fairphone (Gen. 6)";
    manufacturer = "Fairphone";
  };
  mobile.device.supportLevel = "unsupported";

  mobile.hardware = {
    soc = "qualcomm-sm7635";
    ram = 1024 * 8;
    screen = {
      width = 1116; height = 2484;
    };
  };

  mobile.device.firmware = pkgs.callPackage ./firmware {};

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel {};
    kernel.modular = true;
    # Display panel and the touchscreen's SPI controller are needed for the
    # stage-1 GUI.
    kernel.modules = [ "panel_novatek_nt37705" "spi_geni_qcom" ];
    compression = "zstd";
    firmware = [
      (pkgs.runCommand "fp6-initrd-firmware" {} ''
        mkdir -p $out/lib/firmware/qcom/milos/fairphone/fp6
        cp ${config.mobile.device.firmware}/lib/firmware/qcom/milos/fairphone/fp6/gen80300_zap.mbn \
          $out/lib/firmware/qcom/milos/fairphone/fp6/
      '')
    ];
  };

  mobile.system.android = {
    device_name = "FP6";
    ab_partitions = true;
    boot_as_recovery = false;
    has_recovery_partition = false;
    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00000000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  mobile.usb = {
    mode = "gadgetfs";
    # Google
    idVendor = "18d1";
    # "Nexus 4"
    idProduct = "4ee3";
    gadgetfs.functions = {
      rndis = "ncm.usb0";
      adb = "ffs.adb";
    };
  };

  mobile.system.type = "android";

  # TODO: the boot image must be an Android header v2 image with the DTB in
  # the header's dtb section. Until mkbootimg is wired up for that here, the
  # image is repacked from a known-good stock-format template.
  mobile.quirks.supportsStage-0 = false;
  mobile.outputs.android.android-bootimg = lib.mkForce (pkgs.runCommand "fairphone-fp6-boot.img" {
    nativeBuildInputs = [ pkgs.buildPackages.python3 ];
  } ''
    python ${./repack-boot.py} ${pkgs.callPackage ./boot-template.nix {}} \
      ${config.mobile.outputs.initrd} $out \
      --cmdline ${lib.escapeShellArg (lib.concatStringsSep " " config.boot.kernelParams)}
  '');
}
