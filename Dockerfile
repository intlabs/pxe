FROM debian:wheezy
RUN apt-get update
RUN apt-get -y install dnsmasq wget iptables
RUN wget --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework



ENV ARCH amd64
ENV DIST wheezy
ENV MIRROR http://ftp.nl.debian.org


RUN chmod +x pipework
RUN mkdir /tftp
WORKDIR /tftp
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/linux
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/initrd.gz
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN mkdir pxelinux.cfg
RUN printf "DEFAULT linux\nKERNEL linux\nAPPEND initrd=initrd.gz\n" >pxelinux.cfg/default
CMD echo Starting DHCP+TFTP server...&&\
    dnsmasq --interface=eth1 \
    	    --dhcp-range=192.168.242.2,192.168.242.99,255.255.255.0,1h \
	    --dhcp-boot=pxelinux.0,pxeserver,192.168.242.1 \
	    --pxe-service=x86PC,"Install Linux",pxelinux \
	    --enable-tftp --tftp-root=/tftp/ --no-daemon
# Let's be honest: I don't know if the --pxe-service option is necessary.
# The iPXE loader in QEMU boots without it.  But I know how some PXE ROMs
# can be picky, so I decided to leave it, since it shouldn't hurt.
