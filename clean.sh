# Usage:
#   source this-script

images=( "zppz/rr" "zppz/py3r" "zppz/py3" )

echo deleting all containers...
sudo docker rm $(sudo docker ps -aq) 2>/dev/null

for img in "${images[@]}"; do
    echo
    echo deleting images like "$img"'*...'
    sudo docker rmi -f $(sudo docker images -q "$img") 2>/dev/null
done

echo
echo deleting unused intermediate images...
sudo docker rmi $(sudo docker images | grep '<none>' | awk '{print $3}') 2>/dev/null

echo
commands=(py3 ipy3 py3r R)
for cmd in "${commands[@]}"; do
    echo deleting command "/usr/local/bin/$cmd"
    sudo rm -f /usr/local/bin/$cmd
done
