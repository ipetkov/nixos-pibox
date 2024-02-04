{ defaultOverlays ? null # Set to `[]` to clear
, deviceTree
, dtc
, extraOverlays ? [ ]
, lib
, raspberrypi-armstubs
, raspberrypifw
, runCommand
, ubootRaspberryPi4_64bit
}:

let
  fwdir = "${raspberrypifw}/share/raspberrypi/boot";

  mkOverlay = name: text: {
    inherit name;
    filter = null;
    dtboFile = runCommand "${name}-dtbo"
      {
        nativeBuildInputs = [ dtc ];
      } ''
      dtc -I dts -O dtb -@ -o $out <<EOF
        ${text}
      EOF
    '';
  };

  initializedDefaultOverlays =
    if defaultOverlays != null
    then defaultOverlays
    else [
      (mkOverlay "pwm-overlay" ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "brcm,bcm2711";
          fragment@0 {
            target = <&gpio>;
            __overlay__ {
              pwm_pins: pwm_pins {
                brcm,pins = <18>;
                brcm,function = <2>; /* Alt5 */
              };
            };
          };
          fragment@1 {
            target = <&pwm>;
            __overlay__ {
              pinctrl-names = "default";
              assigned-clock-rates = <100000000>;
              status = "okay";
              pinctrl-0 = <&pwm_pins>;
            };
          };
        };
      '')
    ];

  finalDtb = deviceTree.applyOverlays
    (lib.sourceFilesBySuffices fwdir [ "bcm2711-rpi-cm4.dtb" ])
    (initializedDefaultOverlays ++ extraOverlays);
in
runCommand "firmware" { } ''
  mkdir -p $out
  fwdir=${fwdir}

  cp ${raspberrypi-armstubs}/armstub8-gic.bin $out/armstub8-gic.bin
  cp ${ubootRaspberryPi4_64bit}/u-boot.bin    $out/u-boot-rpi4.bin
  cp ${finalDtb}/bcm2711-rpi-cm4.dtb          $out/
  cp $fwdir/bootcode.bin                      $out/
  cp $fwdir/fixup*                            $out/
  cp $fwdir/start*                            $out/

  # Copy the config over
  cat >$out/config.txt <<EOF
  [pi4]
  kernel=u-boot-rpi4.bin
  enable_gic=1
  armstub=armstub8-gic.bin
  disable_overscan=1
  arm_boost=1

  [cm4]
  # Enable host mode on the 2711 built-in XHCI USB controller.
  # This line should be removed if the legacy DWC2 controller is required
  # (e.g. for USB device mode) or if USB support is not required.
  otg_mode=1

  [all]
  # Boot in 64-bit mode.
  arm_64bit=1

  # U-Boot needs this to work, regardless of whether UART is actually used or not.
  # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
  # a requirement in the future.
  enable_uart=1

  # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
  # when attempting to show low-voltage or overtemperature warnings.
  avoid_warnings=1

  # Force HDMI on so we don't allocate a tty on the LCD
  hdmi_force_hotplug=1

  dtoverlay=spi0-1cs
  dtoverlay=dwc2,dr_mode=host
  dtparam=spi=on
  EOF
''
