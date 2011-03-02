# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 2009/10/07 florent.teichteil@gmail.com Exp $

EAPI="2"
MY_P="libantlr3c-${PV}"
inherit eutils

DESCRIPTION="The ANTLR3 C Runtime"
HOMEPAGE="http://fisheye2.atlassian.com/browse/antlr/runtime/C/dist/"
SRC_URI="http://www.antlr.org/download/C/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug debugger doc static-libs"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-3.1.4-doxygen.patch"
}
src_configure() {
	local myconf

	if ((use amd64) || (use ia64)); then
		myconf="${myconf} --enable-64bit"
	else
		myconf="${myconf} --disable-64bit"
	fi

	econf \
		$(use_enable static-libs static) \
		$(use_enable debug debuginfo ) \
		$(use_enable debugger antlrdebug ) \
		${myconf}
}

src_compile() {
	emake || die "make failed"

	if use doc; then
		einfo "Generating documentation API ..."
		doxygen -u doxyfile
		doxygen doxyfile || die "doxygen failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed."

	# remove useless .la files
	find "${D}" -name '*.la' -delete

	dodoc AUTHORS ChangeLog NEWS README
	if use doc; then
		dohtml api/* || die "installing doxygen documentation"
	fi
}
