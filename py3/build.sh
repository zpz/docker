cp -rf ../dotfiles .
( sudo docker build -t zppz/py3:0.1 . )
rm -rf dotfiles
