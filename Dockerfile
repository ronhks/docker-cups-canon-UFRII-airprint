FROM znetwork/synology-airprint
LABEL description="AIRPRINT FROM SYNOLOGY DSM 7 (Canon URFII, HP, SAMSUNG, ETC)"

# Install Canon URFII driver
WORKDIR /usr/src
COPY canon-driver/linux-UFRII-drv-v590-m17n-03-ronhks-mod.tar.gz .
RUN tar -xf linux-UFRII-drv-v590-m17n-03-ronhks-mod.tar.gz
WORKDIR /usr/src/linux-UFRII-drv-v590-m17n
RUN /usr/src/linux-UFRII-drv-v590-m17n/install.sh

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	echo "BrowseWebIF Yes" >> /etc/cups/cupsd.conf
