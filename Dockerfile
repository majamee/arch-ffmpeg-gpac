FROM base/archlinux

RUN       pacman -Sy --noconfirm && \
          pacman -S --noconfirm ffmpeg gpac git && \
          pacman -Scc --noconfirm
          
VOLUME /app/transcode
WORKDIR /app/transcode

RUN       cd /app/ && git clone https://github.com/squidpickles/mpd-to-m3u8.git
