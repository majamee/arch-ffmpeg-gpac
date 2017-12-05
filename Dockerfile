FROM base/archlinux

VOLUME /app/transcode
WORKDIR /app/transcode

RUN                 pacman -Sy --noconfirm && \
                    pacman -S --noconfirm ffmpeg gpac git libxslt && \
                    pacman -Scc --noconfirm && \
                    cd /app/ && git clone https://github.com/squidpickles/mpd-to-m3u8.git

COPY                ./transcode.sh /bin/transcode.sh
ENTRYPOINT          ["/bin/transcode.sh"]
CMD                 ["*.mkv"]
