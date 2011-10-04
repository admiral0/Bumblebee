
srcdir = install-files

include config.mk

export BUMBLEBEE_VERSION BINDIR SBINDIR CONFDIR LIBDIR BUILDDIR \
	DRIVER XORG_MODULEPATH

INSTALL = install
INSTALL_DIR = $(INSTALL) -m 755 -d
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL) -m 755

# XXX input with spaces won't work
locate = $(firstword $(wildcard $(BUILDDIR)/$(1) $(srcdir)/$(1)))

build:
	bash -c '. .configure && . stages/buildfiles'

install-conf:
	test -d $(CONFDIR) || $(INSTALL_DIR) $(DESTDIR)$(CONFDIR)
	$(INSTALL_DATA) $(call locate,bumblebee.conf) \
		$(DESTDIR)$(CONFDIR)/bumblebee.conf
	$(foreach driver,$(DRIVERS),\
		$(INSTALL_DATA) $(srcdir)/xorg.conf.$(driver) \
			$(DESTDIR)$(CONFDIR)/xorg.conf.$(driver) \
	)

install-lib:
	test -d $(LIBDIR) || $(INSTALL_DIR) $(DESTDIR)$(LIBDIR)
	$(INSTALL_DATA) $(call locate,common-paths) \
		$(DESTDIR)$(LIBDIR)/common-paths
	$(INSTALL_DATA) $(call locate,common-functions) \
		$(DESTDIR)$(LIBDIR)/common-functions

install-lib-DRIVERS:
	test -d $(LIBDIR) || $(INSTALL_DIR) $(DESTDIR)$(LIBDIR)/DRIVERS
# XXX: this won't work, need to pass distro-dependent settings
	$(foreach driver,$(DRIVERS),\
		$(INSTALL_DATA) $(call locate,drivers/$(driver).options.$(distro)) \
			$(DESTDIR)$(LIBDIR)/drivers/$(driver).options \
	)

install-sbin:
	test -d $(SBINDIR) || $(INSTALL_DIR) $(DESTDIR)$(SBINDIR)
	$(INSTALL_PROGRAM) $(call locate,bumblebee) $(DESTDIR)$(SBINDIR)/bumblebee

install-bin:
	test -d $(BINDIR) || $(INSTALL_DIR) $(DESTDIR)$(BINDIR)
	$(INSTALL_PROGRAM) $(call locate,optirun) $(DESTDIR)$(BINDIR)/optirun
	$(INSTALL_PROGRAM) $(call locate,bumblebee-bugreport) \
		$(DESTDIR)$(BINDIR)/bumblebee-bugreport

# install bash completion, example handler, perhaps default conf?
install-data:
	test -d $(BINDIR) || $(INSTALL_DIR) $(DESTDIR)$(datadir)
	$(INSTALL_DATA) $(call locate,bumblebee.handler) \
		$(DESTDIR)$(datadir)/bumblebee.handler
	$(INSTALL_DATA) $(call locate,optirun.bash_completion) \
		$(DESTDIR)$(datadir)/optirun.bash_completion

install: install-conf install-lib install-lib-DRIVERS install-sbin install-bin

.PHONY: build install install-conf install-lib install-lib-DRIVERS \
	install-sbin install-bin install-data
