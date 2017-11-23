FROM base/archlinux

ENTRYPOINT  []

RUN       pacman -Sy --noconfirm && \
          pacman -S --noconfirm ffmpeg gpac && \
          pacman -Scc --noconfirm
