#!/bin/bash
#
# mpd-lyriki 0.1.3 - 2006-07-17
# based on lyrc 0.1.2 (authored by Angel Olivera (redondos) <redondos at gmail.com>)
# License: GPLv2
# 
TMP="/tmp/mpd-lyriki.$$.tmp"
getsong () {
        SONG="$@"
        SONG="${SONG//\?/%3F}"
        SONG="${SONG//\&/%26}"
        w3m -dump -no-cookie -T text/html "http://www.lyriki.com/index.php?search=${SONG}" > $TMP
}
parse () {
if grep "Article title matches" $TMP > /dev/null; then
        echo "$ARTIST:$TITLE lyrics not found. Suggestions:"
        grep " [0-9]*\. .* bytes" $TMP | sed -e 's/^\W*[0-9]*\. //' > $TMP.2
        mv $TMP.2 $TMP
        cat -n $TMP
        echo "Pick one (q to quit):"
        read num

        if [ "$num" != "q" ]; then 
                getsong `cat $TMP | head -n $num | tail -n 1 | sed -e 's/ .[0-9]* bytes.//'`
                parse
        fi
elif grep "There is no page titled" $TMP > /dev/null; then
        echo "No results."
else
        # This will show the lyrics, cleaned up a bit
        sed -e '2,6d' -e '/Retrieved from/,$d' $TMP
        echo ""
fi
}

if [ `mpc |wc -l` != 1 ]; then
        ARTIST=`mpc --format "%artist%" | head -n 1`
        TITLE=`mpc --format "%title%" | head -n 1`
        getsong "${ARTIST}:${TITLE}"
        parse
        rm $TMP
else
        echo "No currently playing song. (MPD stopped?)"
fi

