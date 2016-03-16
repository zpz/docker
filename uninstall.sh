(

commands=(py3 ipy3 py3r R)

echo uninstalling image-launching commands ...

for cmd in "${commands[@]}"; do
    f=/usr/local/bin/"$cmd"
    if [[ -f "$f" ]]; then
        echo uninstalling "$f"
        if ! grep -q 'docker run' "$f"; then
            echo "'$f' doesn't look like the command that I installed earlier; don't know how to proceed!"
            exit 1
        fi
        sudo rm -f "$f"
    fi
done

)

