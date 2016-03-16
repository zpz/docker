images=( "zppz/rr" "zppz/py3r" "zppz/py3" )

echo deleting all containers...
sudo docker rm $(sudo docker ps -aq) 2>/dev/null

for img in "${images[@]}"; do
    echo
    echo deleting images like "$img"'* ...'
    sudo docker rmi -f $(sudo docker images -q "$img") 2>/dev/null
done

echo
echo deleting unused intermediate images ...
sudo docker rmi $(sudo docker images | grep '<none>' | awk '{print $3}') 2>/dev/null

