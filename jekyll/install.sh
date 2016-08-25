cmdname=jekyll
bindir="${HOME}/bin"
target="${bindir}/${cmdname}"

echo "installing '${cmdname}' into '${bindir}'"
cat > "${target}" <<'EOF'
#!/usr/bin/env bash

docker run --rm -it \
    --label=jekyll \
    -v ~/work/github/zpz.github.io:/srv/jekyll \
    -p 127.0.0.1:4000:4000 \
    jekyll/jekyll \
    $@
EOF

chmod +x "${target}"


