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

# fixme
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

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

# Modify hostname fixme
sed -i 's/LEDE/Morgan/g' package/base-files/files/bin/config_generate

# Modify default IP
sed -i 's/192.168.1.1/192.168.11.1/g' package/base-files/files/bin/config_generate

sed -i "s/system.ntp.enable_server='1'/system.ntp.enable_server='0'/g" package/base-files/files/bin/config_generate

cat package/base-files/files/bin/config_generate

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


# fixme
rm -rf package/lean/luci-app-adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/lean/luci-app-adguardhome

curl -LJO https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.55/AdGuardHome_linux_arm64.tar.gz
mkdir -p package/lean/luci-app-adguardhome/root/usr/bin/
tar -xzf AdGuardHome_linux_arm64.tar.gz -C package/lean/luci-app-adguardhome/root/usr/bin/

sed -i "s/'\/etc\/AdGuardHome.yaml'/'\/usr\/share\/AdGuardHome\/AdGuardHome_template.yaml'/g" package/lean/luci-app-adguardhome/root/etc/config/AdGuardHome
rm -rf package/lean/luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml
cat>package/lean/luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml<<EOF
http:
  pprof:
    port: 6060
    enabled: false
  address: 192.168.11.1:3000
  session_ttl: 2h
users: []
auth_attempts: 5
block_auth_min: 1
http_proxy: ""
language: ""
theme: auto
dns:
  bind_hosts:
    - 0.0.0.0
  port: 953
  anonymize_client_ip: false
  ratelimit: 0
  ratelimit_subnet_len_ipv4: 24
  ratelimit_subnet_len_ipv6: 56
  ratelimit_whitelist: []
  refuse_any: true
  upstream_dns:
    - https://dns.alidns.com/dns-query
  upstream_dns_file: ""
  bootstrap_dns:
    - 223.5.5.5
  fallback_dns: []
  upstream_mode: parallel
  fastest_timeout: 1s
  allowed_clients: []
  disallowed_clients: []
  blocked_hosts:
    - version.bind
    - id.server
    - hostname.bind
  trusted_proxies:
    - 127.0.0.0/8
    - ::1/128
  cache_size: 1048576
  cache_ttl_min: 10
  cache_ttl_max: 120
  cache_optimistic: false
  bogus_nxdomain: []
  aaaa_disabled: false
  enable_dnssec: false
  edns_client_subnet:
    custom_ip: ""
    enabled: false
    use_custom: false
  max_goroutines: 20
  handle_ddr: true
  ipset: []
  ipset_file: ""
  bootstrap_prefer_ipv6: false
  upstream_timeout: 10s
  private_networks: []
  use_private_ptr_resolvers: false
  local_ptr_upstreams: []
  use_dns64: false
  dns64_prefixes: []
  serve_http3: false
  use_http3_upstreams: false
  serve_plain_dns: true
  hostsfile_enabled: true
tls:
  enabled: false
  server_name: ""
  force_https: false
  port_https: 443
  port_dns_over_tls: 853
  port_dns_over_quic: 784
  port_dnscrypt: 0
  dnscrypt_config_file: ""
  allow_unencrypted_doh: false
  certificate_chain: ""
  private_key: ""
  certificate_path: ""
  private_key_path: ""
  strict_sni_check: false
querylog:
  dir_path: ""
  ignored: []
  interval: 2h
  size_memory: 1000
  enabled: true
  file_enabled: true
statistics:
  dir_path: ""
  ignored: []
  interval: 1h
  enabled: true
filters:
  - enabled: true
    url: https://gcore.jsdelivr.net/gh/217heidai/adblockfilters@main/rules/adblockdns.txt
    name: https://github.com/217heidai/adblockfilters
    id: 1236547890
whitelist_filters: []
user_rules: []
dhcp:
  enabled: false
  interface_name: ""
  local_domain_name: lan
  dhcpv4:
    gateway_ip: ""
    subnet_mask: ""
    range_start: ""
    range_end: ""
    lease_duration: 86400
    icmp_timeout_msec: 1000
    options: []
  dhcpv6:
    range_start: ""
    lease_duration: 86400
    ra_slaac_only: false
    ra_allow_slaac: false
filtering:
  blocking_ipv4: ""
  blocking_ipv6: ""
  blocked_services:
    schedule:
      time_zone: UTC
    ids: []
  protection_disabled_until: null
  safe_search:
    enabled: false
    bing: true
    duckduckgo: true
    google: true
    pixabay: true
    yandex: true
    youtube: true
  blocking_mode: default
  parental_block_host: family-block.dns.adguard.com
  safebrowsing_block_host: standard-block.dns.adguard.com
  rewrites: []
  safebrowsing_cache_size: 1048576
  safesearch_cache_size: 1048576
  parental_cache_size: 1048576
  cache_time: 30
  filters_update_interval: 24
  blocked_response_ttl: 10
  filtering_enabled: true
  parental_enabled: false
  safebrowsing_enabled: false
  protection_enabled: true
clients:
  runtime_sources:
    whois: true
    arp: true
    rdns: false
    dhcp: true
    hosts: true
  persistent: []
log:
  enabled: true
  file: ""
  max_backups: 0
  max_size: 100
  max_age: 3
  compress: false
  local_time: false
  verbose: false
os:
  group: ""
  user: ""
  rlimit_nofile: 0
schema_version: 29
EOF

ls -lash package/lean
