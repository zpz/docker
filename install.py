from __future__ import print_function

import argparse
import os
from os import path
import stat
from sys import exit


def maketext():
    text = """\
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

launchdir=$(pwd)
if [[ "${{launchdir}}" == "{hostworkdir}"* ]]; then
    workdir="{dockerworkdir}""${{launchdir#{hostworkdir}}}"
else
    workdir="{dockerworkdir}"
fi

ARGS="\\
    -v "{hostworkdir}":"{dockerworkdir}" \\
    -e CFGDIR="{dockerworkdir}/config" \\
    -e LOGDIR="{dockerworkdir}/log" \\
    -e DATADIR="{dockerworkdir}/data" \\
    -e TMPDIR="{dockerworkdir}/tmp" \\
    -e ENVIRONMENT_NAME={imgname} \\
    -e PYTHONPATH={pypath} \\
    -u {dockeruser} \\
    --rm -it \\
    -w "${{workdir}}" \\
    -e TZ=America/Los_Angeles"

if (( $# > 0 )); then
    if [[ "$1" == "ipynb" ]]; then
        ARGS="${{ARGS}} \\
    --expose=8888 \\
    -p 8888:8888"
        workdir="{dockerworkdir}"
        shift
        command="jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir='${{workdir}}' --NotebookApp.token='' $@"
    else
        command="$@"
    fi
else
    command="{defaultcmd}"
fi

docker run ${{ARGS}} {imgname}:{imgversion} ${{command}}
""".format(hostworkdir=hostworkdir,
           dockeruser=dockeruser,
           dockerworkdir=dockerworkdir,
           imgname=imgname,
           imgversion=imgversion,
           defaultcmd=defaultcmd,
           pypath=pypath,
           )

    return text


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument(
        '--bin',
        required=True,
        help='name of generated script'
    )
    p.add_argument(
        '--bindir',
        help='directory where the command will be installed'
    )
    p.add_argument(
        '--defaultcmd',
        help='default command to launch in the Docker container',
    )
    p.add_argument(
        '--imgdir',
        help='diretory where the Dockerfile is located',
    )
    p.add_argument(
        '--dockeruser',
        help='username in the Docker container',
    )
    p.add_argument(
        '--pypath',
        action='append',
        default=[],
        help='add the specified directory to PYTHONPATH; the directory starts below `hostworkdir`',
    )
    args = p.parse_args()

    imgdir = args.imgdir or os.getcwd()
    imgname = path.join(imgdir, 'name')
    if not path.isfile(imgname):
        exit()
    imgname = open(imgname).read().strip('\n')
    imgversion = path.join(imgdir, 'version')
    if not path.isfile(imgversion):
        exit()
    imgversion = open(imgversion).read().strip('\n')

    hosthomedir = os.environ['HOME']
    hostworkdir = path.join(hosthomedir, 'work')
    if not path.isdir(hostworkdir):
        hostworkdir = hosthomedir

    bindir = args.bindir or path.join(hostworkdir, 'bin')
    if not path.isdir(bindir):
        os.mkdir(bindir)
    target = path.join(bindir, args.bin)

    dockeruser = args.dockeruser or 'docker-user'
    defaultcmd = args.defaultcmd or 'python'

    dockerworkdir = path.join('/home', dockeruser, path.basename(hostworkdir))

    pypath = ':'.join([path.join(dockerworkdir, p) for p in args.pypath])

    print('installing', args.bin, 'into', bindir)
    text = maketext()
    open(target, 'w').write(text)
    os.chmod(target,
             stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR |
             stat.S_IRGRP | stat.S_IXGRP |
             stat.S_IROTH | stat.S_IXOTH
             )
