# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit games java-pkg-2

DESCRIPTION="Dedicated Feed the Beast Ultimate server for Minecraft"
HOMEPAGE="http://feed-the-beast.com/"
SRC_URI="http://www.creeperrepo.net/direct/FTB2/6745399749f7ae55047294c82af08b82/modpacks%5EUltimate%5E1_1_1%5EUltimate_Server.zip -> ${P}.zip"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"
RESTRICT="mirror"

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	games-server/minecraft-common"

S="${WORKDIR}"

pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

src_unpack() {
	unpack "${A}" || die

	cd "${S}"

	mv ftbserver.jar ${PN}.jar || die

	rm -f ServerStart.sh
	rm -f ServerStart.bat

	mkdir data || die
	mkdir data/backup || die

	mv config/	data/	|| die
	mv mods/	data/	|| die
	mv coremods/	data/	|| die
}

java_prepare() {
	cp "${FILESDIR}"/{directory,init}.sh . || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" directory.sh || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" init.sh || die

	sed -i "s#@DATA_DIR@#${GAMES_DATADIR}/${PN}#g" directory.sh || die
	sed -i "s/@PACKAGE_NAME@/${P}/g" directory.sh || die
}

src_install() {
	local ARGS
	use ipv6 || ARGS="-Djava.net.preferIPv4Stack=true"

	newinitd init.sh ${PN} || die

	java-pkg_newjar "${PN}.jar" "${PN}.jar"
	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" -pre directory.sh \
		--java_args "-Xmx1024M -Xms512M ${ARGS}" --pkg_args "nogui" \
		--main net.minecraft.server.MinecraftServer

	insinto "${GAMES_DATADIR}/${PN}/"
	doins -r data/* || die

	prepgamesdirs
}

pkg_postinst() {
	einfo "You may run ${PN} as a regular user or start a system-wide"
	einfo "instance using /etc/init.d/${PN}. The multiverse files are"
	einfo "stored in ~/.minecraft/servers or /var/lib/minecraft respectively."
	echo
	einfo "The console for system-wide instances can be accessed by any user in"
	einfo "the ${GAMES_GROUP} group using the minecraft-server-console command. This"
	einfo "starts a client instance of tmux. The most important key-binding to"
	einfo "remember is Ctrl-b d, which will detach the console and return you to"
	einfo "your previous screen without stopping the server."
	echo
	einfo "This package allows you to start multiple Minecraft server instances."
	einfo "You can do this by adding a multiverse name after ${PN} or by"
	einfo "creating a symlink such as /etc/init.d/${PN}.foo. You would"
	einfo "then access the console with \"minecraft-server-console foo\". The"
	einfo "default multiverse name is \"main\"."
	echo

    ewarn "You may run two servers against the same multiverse but not simultaneously."
    ewarn "This is not recommended though so don't come crying to us if it"
    ewarn "trashes your world."
    echo

	games_pkg_postinst
}
