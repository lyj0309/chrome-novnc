FROM ubuntu:22.04

LABEL AboutImage "Ubuntu22.04_Chromium_NoVNC"

LABEL Maintainer "Apoorv Vyavahare <apoorvvyavahare@pm.me>"

ARG DEBIAN_FRONTEND=noninteractive

#VNC Server Password
ENV	VNC_PASS="654321" \
#VNC Server Title(w/o spaces)
	VNC_TITLE="Chromium" \
#VNC Resolution(720p is preferable)
	VNC_RESOLUTION="1280x720" \
#VNC Shared Mode (0=off, 1=on)
	VNC_SHARED=1 \
#NoVNC Port
	NOVNC_PORT=$PORT \
	PORT=8080 \
#Locale
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="Asia/Kolkata"

COPY rootfs/ /

SHELL ["/bin/bash", "-c"]

RUN	apt-get update && \
	apt-get install -y tzdata ca-certificates supervisor socat curl wget sed unzip xvfb x11vnc websockify openbox libnss3 libgbm-dev libasound2 fonts-droid-fallback && \
#Chromium
	wget https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1235467%2Fchrome-linux.zip?alt=media -O /tmp/chrome-linux.zip && \
	unzip /tmp/chrome-linux.zip -d /opt && \
#noVNC
	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/ST=Maharastra/L=Private/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key  -out /etc/ssl/novnc.cert && \
#TimeZone
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
#Wipe Temp Files
	rm -rf /var/lib/apt/lists/* && \ 
	apt-get remove -y wget unzip && \
	apt-get -y autoremove && \
	apt-get clean && \
	rm -rf /tmp/*

ENTRYPOINT ["supervisord", "-l", "/var/log/supervisord.log", "-c"]

CMD ["/config/supervisord.conf"]
