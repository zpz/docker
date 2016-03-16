(

echo pushing images to the cloud:

images=(zppz/py3:0.1 zppz/py3r:0.1 zppz/rr:0.1)
for img in "${images[@]}"; do
    echo
    echo pushing $f ...
    echo
    sudo docker push $f
    (( $? == 0 )) || break
done

)


