# arch-ffmpeg-gpac
Setting up a video transcoding pipeline to create dash/ hls compatible video files &amp; playlists

Recommended usage via Docker [Kitematic](https://kitematic.com/)

Examplary toolchain usage based on the works of [squidpickles](https://github.com/squidpickles). Just use Kitematic to open the shared folder place your video file in there and replace "input.mkv" by your input video file (without "").
```sh
# 1080p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -c:a aac -b:a 128k -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1920,iw)':-4" -crf 22 -movflags faststart intermed_1080p.mp4
# 720p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -c:a aac -b:a 128k -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(1280,iw)':-4" -crf 22 -movflags faststart intermed_720p.mp4
# 480p@CRF22
ffmpeg -y -threads 4 -i "input.mkv" -c:a aac -b:a 128k -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' -profile:v high -level 4.0 -vf "scale=min'(720,iw)':-4" -crf 22 -movflags faststart intermed_480p.mp4

# 128k AAC audio only
ffmpeg -y -threads 4 -i "input.mkv" -vn -c:a aac -b:a 128k audio_128k.m4a

# Create MPEG-DASH files (segments & mpd-playlist)
MP4Box -dash 2000 -rap -frag-rap -url-template -dash-profile onDemand -segment-name 'segment_$RepresentationID$' -out playlist.mpd intermed_1080p.mp4 intermed_720p.mp4 intermed_480p.mp4 audio_128k.m4a

# Create HLS playlists for each quality level
ffmpeg -i intermed_1080p.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_1.m3u8
ffmpeg -i intermed_720p.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_2.m3u8
ffmpeg -i intermed_480p.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_3.m3u8
ffmpeg -i audio_128k.m4a -acodec copy -vcodec copy -hls_time 2 -hls_list_size 0 -hls_flags single_file segment_4.m3u8

# Transform MPD-Master-Playlist to M3U8-Master-Playlist
xsltproc --stringparam run_id "segment" ../mpd-to-m3u8/mpd_to_hls.xsl playlist.mpd > playlist.m3u8
```
