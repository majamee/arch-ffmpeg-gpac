[![](https://images.microbadger.com/badges/image/majamee/arch-ffmpeg-gpac.svg)](https://microbadger.com/images/majamee/arch-ffmpeg-gpac) [![](https://images.microbadger.com/badges/version/majamee/arch-ffmpeg-gpac.svg)](https://microbadger.com/images/majamee/arch-ffmpeg-gpac) [![Docker Automated build](https://img.shields.io/docker/automated/majamee/arch-ffmpeg-gpac.svg)]() [![Docker Build Status](https://img.shields.io/docker/build/majamee/arch-ffmpeg-gpac.svg)]()

# arch-ffmpeg-gpac
A ready-prepared video transcoding pipeline to create DASH/ HLS compatible video files &amp; playlists.

Recommended usage via Docker [Kitematic](https://kitematic.com/) & [Docker Hub](https://hub.docker.com/r/majamee/arch-ffmpeg-gpac/).

# Examplary toolchain usage
(Based on work of [squidpickles](https://github.com/squidpickles))

Just use Kitematic to open the shared folder, place your video file in there, replace `"input.mkv"` in the commands below by your input video file (without `""`) and execute the shell commands subsequent into the Docker container.
```sh
# 1080p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 intermed_1080p.mp4
# 720p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -an -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1280,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 intermed_720p.mp4
# 480p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -an aac -b:a 128k -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(720,iw)':-4" -crf 22 -movflags faststart -write_tmcd 0 intermed_480p.mp4

# 128k AAC audio only
ffmpeg -y -threads 4 -i "input.mkv" -vn -c:a aac -b:a 128k audio_128k.m4a

# Create MPEG-DASH files (segments & mpd-playlist)
MP4Box -dash 2000 -rap -frag-rap -url-template -dash-profile onDemand -segment-name 'segment_$RepresentationID$' -out playlist.mpd intermed_1080p.mp4 intermed_720p.mp4 intermed_480p.mp4 audio_128k.m4a

# Create HLS playlists for each quality level
ffmpeg -i intermed_1080p.mp4 -i audio_128k.m4a -map 0:v:0 -map 1:a:0 -shortest -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_1.m3u8
ffmpeg -i intermed_720p.mp4 -i audio_128k.m4a -map 0:v:0 -map 1:a:0 -shortest -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_2.m3u8
ffmpeg -i intermed_480p.mp4 -i audio_128k.m4a -map 0:v:0 -map 1:a:0 -shortest -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_3.m3u8
ffmpeg -i audio_128k.m4a -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_4.m3u8

# Transform MPD-Master-Playlist to M3U8-Master-Playlist
xsltproc --stringparam run_id "segment" ../mpd-to-m3u8/mpd_to_hls.xsl playlist.mpd > playlist.m3u8
```

I am glad to receive any improvement ideas about this "any video to DASH/ HLS" pipeline. 
Especially if someone has any input on integrating better [Apple's support of fragemented mp4 (fmp4) files](https://gpac.wp.imt.fr/tag/hls-fmp4/) in this pipeline.

Suggestions welcome. :)

# General hints for hosting the files (to test streaming)
* Video and playlist files should be hosted best via HTTPS
* DASH requires the .mpd playlist to be set as `Content-Type: application/dash+xml`
* No specific streaming server is required, but your hosting should have progressive downloading enabled
* If using a different domain name for the video files compared to the page where the player is hosted CORS headers need to be set

# Tools to test the generated files for streaming
* HLS (e.g. Safari on Mac OS X): https://videojs.github.io/videojs-contrib-hls/ (use the .m3u8 master-playlist)
* DASH (e.g. Firefox/ Chrome): http://reference.dashif.org/dash.js/ (use the latest released version & the .mpd playlist)
