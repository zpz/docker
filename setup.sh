(  # put the whole script in a subshell

BIN=/usr/local/bin

echo "installing 'py3' into '$BIN'..."
echo '\
#!env bash

sudo docker run --rm -it zppz/py3:0.1 $@' > "$BIN"/py3 || exit 1
chmod +x "$BIN"/py3 || exit 1


echo "installing 'ipy3' into '$BIN'..."
echo '\
#!env bash

sudo docker run --rm -it zppz/py3:0.1 ipython $@' > "$BIN"/ipy3 || exit 1
chmod +x "$BIN"/ipy3 || exit 1


echo "installing 'py3r' into '$BIN'..."
echo '\
#!env bash

sudo docker run --rm -it zppz/py3r:0.1 $@' > "$BIN"/py3r || exit 1
chmod +x "$BIN"/py3r || exit 1


echo "installing 'R' into '$BIN'..."
echo '\
#!env bash

sudo docker run --rm -it zppz/rr:0.1 $@' > "$BIN"/R || exit 1
chmod +x "$BIN"/R || exit 1

true

)

