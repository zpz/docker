# Usage after installation:
#
# $ jekyll jekyll serve
#
# Then check the website at localhost:4000 in browser.
#
# Alternatively,
#
# $ jekyll /bin/bash
#
# Within the container, do
#
# $ jekyll serve
#
# and check with browser.


cmdname=jekyll
bindir="${HOME}/work/bin"
target="${bindir}/${cmdname}"

echo "installing '${cmdname}' into '${bindir}'"
cat > "${target}" <<'EOF'
#!/usr/bin/env bash

docker run --rm -it \
    --label=jekyll \
    -v ~/work/src/github-zpz/zpz.github.io:/srv/jekyll \
    -p 127.0.0.1:4000:4000 \
    jekyll/jekyll \
    $@
EOF

chmod +x "${target}"


