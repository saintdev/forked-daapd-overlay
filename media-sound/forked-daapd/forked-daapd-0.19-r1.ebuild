# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils autotools

DESCRIPTION="DAAP and RSP media server. It is a complete rewrite of mt-daapd (Firefly Media Server)."
HOMEPAGE="http://www.technologeek.org/projects/daapd/index.html"
SRC_URI="http://alioth.debian.org/~jblache/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="flac itunes musepack"

RDEPEND="itunes? ( >=app-pda/libplist-0.16 )
	dev-db/sqlite:3[unlock-notify,threadsafe]
	>=dev-libs/antlr-c-3.1.3
	>=dev-libs/avl-0.3.5
	dev-libs/confuse
	<dev-libs/libevent-2.0
	dev-libs/libgcrypt
	>=dev-libs/libunistring-0.9.3
	dev-libs/mini-xml
	media-libs/alsa-lib
	flac? ( media-libs/flac )
	musepack? ( media-libs/taglib )
	>=net-dns/avahi-0.6.24
	>=sys-libs/zlib-1.2.5-r2
	virtual/ffmpeg"

DEPEND="${RDEPEND}
	dev-java/antlr:3
	dev-util/gperf
	dev-util/pkgconfig"

RESTRICT="primaryuri"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.12-configure.patch"
	eautoreconf
}

src_configure() {
	econf $(use_enable flac) \
		$(use_enable itunes)\
		$(use_enable musepack)
}

src_install() {
	emake DESTDIR="${D}" install

	newinitd "${FILESDIR}/${PN}.init.d" "${PN}"
	keepdir /etc/forked.daapd.d /var/cache/forked-daapd
	mv "${D}/etc/forked-daapd.conf" "${D}/etc/forked.daapd.d/"

	insinto /etc/logrotate.d
	newins "${FILESDIR}/forked-daapd.logrotate" forked-daapd

	dodoc AUTHORS ChangeLog README NEWS
}

pkg_preinst() {
	enewgroup daapd
	enewuser daapd -1 -1 /dev/null daapd
	fowners -R daapd:daapd /etc/forked.daapd.d
	fowners -R daapd:daapd /var/cache/forked-daapd
	fperms -R 0700 /etc/forked.daapd.d
	fperms -R 0700 /var/cache/forked-daapd
}

pkg_postinst() {
	einfo
	elog "If you want to start more than one ${PN} service, symlink"
	elog "/etc/init.d/${PN} to /etc/init.d/${PN}.<name>, and it will"
	elog "load the data from /etc/${PN}.d/<name>.conf."
	elog "Make sure that you have different cache directories for them."
	einfo
}
