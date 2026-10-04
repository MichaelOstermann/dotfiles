#!/usr/bin/env bash
# Downloads a track from YouTube into the mpd library with proper tags.
#
#   yt <url>             download, tag, file under Artist/Album/
#   yt --retag <file>    fix the tags of a file already in the library
#   yt --move <file>     the same, and move it to Artist/Album/ too
#
# Tags are proposed from what YouTube knows (the artist/track/album of a music
# release, otherwise "Artist - Title" taken apart) and can be edited before
# anything is written. A file named "... [videoid].ext" by yt-dlp is looked up
# again when retagging.
set -euo pipefail

# -h, --help, or no arguments: print the header above.
case "${1:-}" in
    ""|-h|--help) sed -n '2,/^set -/{/^set -/d;s/^# \{0,1\}//;p}' "$0"; exit 0 ;;
esac

music=${MUSIC_DIR:-$(sed -n 's/^\s*music_directory\s*"\(.*\)".*/\1/p' ~/.config/mpd/mpd.conf | sed "s|^~|$HOME|")}
[ -d "$music" ] || { echo "No music directory at '$music'" >&2; exit 1; }

# prompt <label> <default>: editable when run in a terminal.
prompt() {
    local answer
    if [ -t 0 ]; then
        read -rep "$(printf '%-7s' "$1") " -i "$2" answer
    else
        read -r answer || true
        answer=${answer:-$2}
    fi
    printf '%s' "$answer"
}

# Proposed tags as "artist<TAB>title<TAB>album<TAB>year" from a video's metadata.
propose() {
    yt-dlp -j --no-playlist --no-warnings "$1" | jq -r '
        # "(Official Video)", "[Lyrics]", "(HD)" and the like.
        def clean: gsub("\\s*[\\(\\[][^\\)\\]]*(official|video|audio|lyrics?|visuali[sz]er|hd|hq|4k)[^\\)\\]]*[\\)\\]]"; ""; "i") | gsub("^\\s+|\\s+$"; "");
        (.title | clean) as $title
        | ($title | capture("^(?<a>.+?)\\s+[-–—]\\s+(?<t>.+)$") // null) as $split
        | [
            (.artist // .creator // $split.a // (.uploader // "" | sub(" - Topic$"; ""))),
            (.track // $split.t // $title),
            (.album // ""),
            ((.release_year // (.upload_date // "" | .[0:4])) | tostring)
          ] | @tsv'
}

# ask_tags <artist> <title> <album> <year>: sets artist/title/album/track/year.
ask_tags() {
    echo "Tags — edit, or Enter to accept:"
    artist=$(prompt Artist "$1")
    title=$(prompt Title "$2")
    album=$(prompt Album "$3")
    track=$(prompt Track "${5:-}")
    year=$(prompt Year "$4")
}

# write_tags <in> <out>: copies the file as it is, with the tags set.
write_tags() {
    local args=() pair
    # Ogg keeps its tags on the audio stream, m4a and mp3 on the file: set both,
    # or an existing stream tag would win over the new one.
    for pair in "title=$title" "artist=$artist" "album=$album" "track=$track" "date=$year"; do
        args+=(-metadata "$pair" -metadata:s:a:0 "$pair")
    done
    ffmpeg -nostdin -loglevel error -y -i "$1" -map 0 -c copy "${args[@]}" "$2"
}

safe() { printf '%s' "$1" | tr '/' '-'; }

if [ "${1:-}" = "--retag" ] || [ "${1:-}" = "--move" ]; then
    file=${2:?usage: yt-music.sh $1 <file>}
    [ -f "$file" ] || { echo "No such file: $file" >&2; exit 1; }
    tag() { ffprobe -v error -show_entries "format_tags=$1:stream_tags=$1" -of default=nw=1:nk=1 "$file" | head -n 1; }

    guess=""
    if [[ $(basename "$file") =~ \[([A-Za-z0-9_-]{11})\]\.[^.]+$ ]]; then
        echo "Looking up ${BASH_REMATCH[1]} on YouTube…"
        guess=$(propose "https://www.youtube.com/watch?v=${BASH_REMATCH[1]}" || true)
    fi
    IFS=$'\t' read -r g_artist g_title g_album g_year <<<"$guess"
    name=$(basename "${file%.*}" | sed -E 's/^[0-9]+\. //; s/ \[[A-Za-z0-9_-]{11}\]$//')
    a=$(tag artist); t=$(tag title); al=$(tag album); y=$(tag date); n=$(tag track)
    ask_tags "${a:-$g_artist}" "${t:-${g_title:-$name}}" "${al:-$g_album}" "${y:-$g_year}" "$n"

    tmp=$(mktemp --suffix=".${file##*.}")
    trap 'rm -f "$tmp"' EXIT
    write_tags "$file" "$tmp"
    cat "$tmp" >"$file"
    # --retag leaves the path alone, so playlists that hold the file keep
    # working; --move files it like a fresh download.
    if [ "$1" = "--move" ]; then
        dir="$music/$(safe "${artist:-No Artist}")/$(safe "${album:-No Album}")"
        name=$(safe "$title")
        [ -n "$track" ] && name=$(printf '%02d. %s' "$((10#${track%%/*}))" "$name")
        mkdir -p "$dir"
        mv -n "$file" "$dir/$name.${file##*.}"
        file="$dir/$name.${file##*.}"
    fi
    mpc -q update >/dev/null 2>&1 || true
    echo "Tagged $file"
    exit 0
fi

url=${1:?usage: yt-music.sh <url> | --retag <file>}
IFS=$'\t' read -r p_artist p_title p_album p_year <<<"$(propose "$url")"
ask_tags "$p_artist" "$p_title" "$p_album" "$p_year"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# YouTube's own AAC stream when there is one, so nothing is re-encoded.
yt-dlp --no-playlist --no-warnings -f 'bestaudio[ext=m4a]/bestaudio' -x --audio-format m4a \
    -o "$tmp/audio.%(ext)s" "$url"

dir="$music/$(safe "${artist:-No Artist}")/$(safe "${album:-No Album}")"
name=$(safe "$title")
[ -n "$track" ] && name=$(printf '%02d. %s' "$((10#${track%%/*}))" "$name")
mkdir -p "$dir"
write_tags "$tmp/audio.m4a" "$tmp/tagged.m4a"
mv -n "$tmp/tagged.m4a" "$dir/$name.m4a"
mpc -q update >/dev/null 2>&1 || true
echo "Added $dir/$name.m4a"
