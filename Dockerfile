FROM base/archlinux

WORKDIR /video

COPY                ./transcode.sh /bin/transcode.sh

RUN                 pacman -Sy --noconfirm && \
                    pacman -S --noconfirm ffmpeg gpac git libxslt && \
                    pacman -Scc --noconfirm && \
                    cd /app/ && git clone https://github.com/squidpickles/mpd-to-m3u8.git && \
                    chmod +x /bin/transcode.sh

ENTRYPOINT          ["/bin/transcode.sh"]
CMD                 ["*.mkv"]
