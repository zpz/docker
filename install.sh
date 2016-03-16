
(  # put the whole script in a subshell

BIN=/usr/local/bin


echo "installing 'py3' into '$BIN'..."
sudo tee "$BIN"/py3 1>/dev/null <<EOF
#!/usr/bin/env bash

sudo docker run --rm -it zppz/py3:0.1 \$@
EOF
(( $? == 0 )) || exit 1
sudo chmod +x "$BIN"/py3 || exit 1


echo "installing 'ipy3' into '$BIN'..."
sudo tee "$BIN"/ipy3 1>/dev/null <<EOF
#!/usr/bin/env bash

sudo docker run --rm -it zppz/py3:0.1 ipython \$@
EOF
(( $? == 0 )) || exit 1
sudo chmod +x "$BIN"/ipy3 || exit 1


echo "installing 'py3r' into '$BIN'..."
sudo tee "$BIN"/py3r 1>/dev/null <<EOF
#!/usr/bin/env bash

sudo docker run --rm -it zppz/py3r:0.1 \$@
EOF
(( $? == 0 )) || exit 1
sudo chmod +x "$BIN"/py3r || exit 1


echo "installing 'R' into '$BIN'..."
sudo tee "$BIN"/R 1>/dev/null <<EOF
#!/usr/bin/env bash

sudo docker run --rm -it zppz/rr:0.1 R --no-save \$@
EOF
(( $? == 0 )) || exit 1
sudo chmod +x "$BIN"/R || exit 1

)

