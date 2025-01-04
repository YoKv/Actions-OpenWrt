#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

ls -lash

rm -rf package/base-files/files/etc/banner
cat>package/base-files/files/etc/banner<<EOF
 ███▄ ▄███▓ ▒█████   ██▀███    ▄████  ▄▄▄       ███▄    █
▓██▒▀█▀ ██▒▒██▒  ██▒▓██ ▒ ██▒ ██▒ ▀█▒▒████▄     ██ ▀█   █
▓██    ▓██░▒██░  ██▒▓██ ░▄█ ▒▒██░▄▄▄░▒██  ▀█▄  ▓██  ▀█ ██▒
▒██    ▒██ ▒██   ██░▒██▀▀█▄  ░▓█  ██▓░██▄▄▄▄██ ▓██▒  ▐▌██▒
▒██▒   ░██▒░ ████▓▒░░██▓ ▒██▒░▒▓███▀▒ ▓█   ▓██▒▒██░   ▓██░
░ ▒░   ░  ░░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ░▒   ▒  ▒▒   ▓▒█░░ ▒░   ▒ ▒
░  ░      ░  ░ ▒ ▒░   ░▒ ░ ▒░  ░   ░   ▒   ▒▒ ░░ ░░   ░ ▒░
░      ░   ░ ░ ░ ▒    ░░   ░ ░ ░   ░   ░   ▒      ░   ░ ░
       ░       ░ ░     ░           ░       ░  ░         ░
EOF

sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-light/Makefile

# Modify hostname
sed -i 's/LEDE/Morgan/g' package/base-files/luci2/bin/config_generate

# Modify default IP
sed -i 's/192.168.1.1/192.168.11.1/g' package/base-files/luci2/bin/config_generate

sed -i "s/system.ntp.enable_server='1'/system.ntp.enable_server='0'/g" package/base-files/luci2/bin/config_generate

# dhcp leasetime
sed -i 's/12h/2h/g'  package/network/services/odhcpd/files/odhcpd.defaults
sed -i 's/12h/2h/g'  package/network/services/dnsmasq/files/dhcp.conf

# 设置无线的国家代码为CN,wifi的默认功率为20 默认开启MU-MIMO,k,v
sed -i '/set wireless.default_radio${devidx}.encryption=none/a\\t\t\tset wireless.default_radio${devidx}.key=password' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=none/a\\t\t\tset wireless.default_radio${devidx}.ieee80211k=1' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=none/a\\t\t\tset wireless.default_radio${devidx}.ieee80211v=1' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=none/a\\t\t\tset wireless.default_radio${devidx}.bss_transition=1' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=none/a\\t\t\tset wireless.default_radio${devidx}.time_advertisement=0' package/kernel/mac80211/files/lib/wifi/mac80211.sh

sed -i '/set wireless.radio${devidx}.disabled=0/a\\t\t\tset wireless.radio${devidx}.txpower=20' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.radio${devidx}.disabled=0/a\\t\t\tset wireless.radio${devidx}.mu_beamformer=1' package/kernel/mac80211/files/lib/wifi/mac80211.sh

sed -i 's/LEDE/wifi/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/country=US/country=CN/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/encryption=none/encryption=psk-mixed/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/wireless.radio${devidx}.channel=${channel}/wireless.radio${devidx}.channel=auto/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh


rm -rf target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-re-ss-01.dts
cat>target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6000-re-ss-01.dts<<EOF
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT

/dts-v1/;

#include "ipq6018-512m.dtsi"
#include "ipq6018-ess.dtsi"
#include "ipq6018-nss.dtsi"

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>

/ {
	model = "JDCloud AX1800 Pro";
	compatible = "jdcloud,re-ss-01", "qcom,ipq6018";

	aliases {
		serial0 = &blsp1_uart3;
		led-boot = &led_status_blue;
		led-failsafe = &led_status_red;
		led-running = &led_status_green;
		led-upgrade = &led_status_red;

		ethernet1 = "/soc/dp2";
		ethernet2 = "/soc/dp3";
		ethernet3 = "/soc/dp4";
		ethernet4 = "/soc/dp5";
	};

	keys {
		compatible = "gpio-keys";
		pinctrl-0 = <&button_pins>;
		pinctrl-names = "default";

		wps {
			label = "wps";
			linux,code = <KEY_WPS_BUTTON>;
			gpios = <&tlmm 8 GPIO_ACTIVE_LOW>;
		};

		reset {
			label = "reset";
			linux,code = <KEY_RESTART>;
			gpios = <&tlmm 9 GPIO_ACTIVE_LOW>;
		};
	};

	leds {
		compatible = "gpio-leds";

		led_status_red: red {
			label = "red:status";
			gpios = <&tlmm 37 GPIO_ACTIVE_HIGH>;
		};

		led_status_blue: blue {
			label = "blue:status";
			gpios = <&tlmm 35 GPIO_ACTIVE_HIGH>;
		};

		led_status_green: green {
			label = "green:status";
			gpios = <&tlmm 50 GPIO_ACTIVE_HIGH>;
		};
	};
};

&tlmm {
	gpio-reserved-ranges = <20 1>;

	button_pins: button_pins {
		mux {
			pins = "gpio8", "gpio9";
			function = "gpio";
			drive-strength = <8>;
			bias-pull-up;
		};
	};

	mdio_pins: mdio-pins {
		mdc {
			pins = "gpio64";
			function = "mdc";
			drive-strength = <8>;
			bias-pull-up;
		};

		mdio {
			pins = "gpio65";
			function = "mdio";
			drive-strength = <8>;
			bias-pull-up;
		};
	};
};

&blsp1_uart3 {
	pinctrl-0 = <&serial_3_pins>;
	pinctrl-names = "default";
	status = "okay";
};

&qusb_phy_0 {
	status = "okay";
};

&rpm {
	status = "disabled";
};

&sdhc {
	bus-width = <8>;
	mmc-ddr-1_8v;
	mmc-hs200-1_8v;
	non-removable;
	status = "okay";
};

&ssphy_0 {
	status = "okay";
};

&usb3 {
	status = "okay";
};

&mdio {
	status = "okay";

	pinctrl-0 = <&mdio_pins>;
	pinctrl-names = "default";
	reset-gpios = <&tlmm 75 GPIO_ACTIVE_LOW>;

	qca8075_1: ethernet-phy@1 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <1>;
	};

	qca8075_2: ethernet-phy@2 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <2>;
	};

	qca8075_3: ethernet-phy@3 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <3>;
	};

	qca8075_4: ethernet-phy@4 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <4>;
	};
};

&switch {
	status = "okay";

	switch_cpu_bmp = <0x1>;  /* cpu port bitmap */
	switch_lan_bmp = <0x1e>; /* lan port bitmap */
	switch_wan_bmp = <0x20>; /* wan port bitmap */
	switch_inner_bmp = <0xc0>; /*inner port bitmap*/
	switch_mac_mode = <0x0>; /* mac mode for uniphy 0*/
	switch_mac_mode1 = <0xff>; /* mac mode for uniphy 1*/
	switch_mac_mode2 = <0xff>; /* mac mode for uniphy 2*/

	qcom,port_phyinfo {
		port@2 {
			port_id = <2>;
			phy_address = <1>;
		};
		port@3 {
			port_id = <3>;
			phy_address = <2>;
		};
		port@4 {
			port_id = <4>;
			phy_address = <3>;
		};
		port@5 {
			port_id = <5>;
			phy_address = <4>;
		};
	};
};

&edma {
	status = "okay";
};

&dp2 {
	status = "okay";
	phy-handle = <&qca8075_1>;
	label = "lan1";
};

&dp3 {
	status = "okay";
	phy-handle = <&qca8075_2>;
	label = "lan2";
};

&dp4 {
	status = "okay";
	phy-handle = <&qca8075_3>;
	label = "lan3";
};

&dp5 {
	status = "okay";
	phy-handle = <&qca8075_4>;
	label = "wan";
};

&wifi {
	status = "okay";
	qcom,ath11k-calibration-variant = "JDC-AX1800-Pro";
	qcom,ath11k-fw-memory-mode = <1>;
};
EOF



