{ raspberrypi-armstubs
, raspberrypifw
, runCommand
, ubootRaspberryPi4_64bit
}:

runCommand "firmware" { } ''
mkdir -p $out
fwdir=${raspberrypifw}/share/raspberrypi/boot/

cp ${raspberrypi-armstubs}/armstub8-gic.bin $out/armstub8-gic.bin
cp ${ubootRaspberryPi4_64bit}/u-boot.bin    $out/u-boot-rpi4.bin
cp $fwdir/bcm2711-rpi-cm4.dtb               $out/
cp $fwdir/bootcode.bin                      $out/
cp $fwdir/fixup*                            $out/
cp $fwdir/start*                            $out/
cp -r $fwdir/overlays                       $out/overlays

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

# pibox specifics
dtoverlay=spi0-1cs
dtoverlay=dwc2,dr_mode=host
hdmi_force_hotplug=1
dtoverlay=drm-minipitft13,rotate=0,fps=60
EOF
''
