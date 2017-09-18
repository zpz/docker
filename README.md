# Docker

Some Docker images aimed at software development.

The images are organized in a directory hierarchy.

Some images showcase a selection of useful packages for a specialized purpose. It is not a goal that every image is directly and completely suitable for an actual project. Feel free to copy-paste relevant snippets into your own image definition.

The Docker container launching scripts (`install.sh` in subdirectories) assume a directory `$HOME/work/bin`, where `$HOME` is the user's home directory. Make sure this directory is on the system `PATH` so that commands installed there can be found.


<!-- toc -->

* [Docker basics](#docker-basics)
* [Directory structure on the development machine](#directory-structure)
* [Execution environment within a Docker container](#env-in-docker)
* [Use `Jupyter Notebook`](#jupyter-notebook)

<!-- end of toc -->

<a name="docker-basics"></a>
## Docker basics

Some key terminology:

+ A Docker `image` is built by following the spec in a `Dockerfile`. An image contains a `Linux` OS (effectively), libraries, run-times, and configurations such as user accounts, environment variables (like `PYTHONPATH`), and actual "stuff" (files etc). Docker images are **read only**.
+ A Docker `container` is the run environment launched based on a Docker `image`. This is a `Linux` box in which one can run programs, read/write files, and so on. A container can be stopped, and re-started/re-entered later. The state of a container can be saved as a new image (but we should *never* do this; instead use a Dockerfile for its reproducibility).
+ `Volume mapping` is the mechanism by which programs inside the container can access files outside of the container (on the "hosting machine", e.g. your laptop or a server node). Due to this capability, it is recommended to **not persist data in a container** and just treat the container as a running "instance" of the (read-only) image, that is, just use Docker containers to run programs, whereas data I/O is on a directory on the hosting machine that is *mapped* to a certain directory in the file system within the container (which is, again, a `Linux` box).


<a name="directory-structure"></a>
## Directory structure for code development

Suppose the home directory is `/Users/username` (on Mac) or `/home/username` (on Ubuntu Linux), represented by the environment variable `HOME`, my Docker stack recommends the following direcotry structure for code development:

```
$HOME/work/
        |-- bin/
        |-- config/
        |-- data/
        |-- log/
        |-- src/
        |     |-- docker/
        |     |-- repo1/
        |     |-- repo2/
        |     |-- and so on
        |-- tmp/
```

The directories in `$HOME/work/src/` are `git` repos and are source-controlled. Other subdirectories of `work` are *not* in source control and *not* stored in the cloud.

Space and non-ascii characters are better avoided in directory and file names, esp under `config`, `log`, and `src`.

This doc assumes the work directory is layed out as above, and will refer to `$HOME/work`  as `$WORKDIR`.


<a name="env-in-docker"></a>
## Execution environment within a Docker container

Take the command `$WORKDIR/bin/py3` for example. If you type (outside of a Docker container)

```
py3
```

you'll end up in a Docker container, which is a Ubuntu linux environment. You can do whatever you want in there, e.g. navigate to the desired directory and run tests. The 'work' directory outside of the container, i.e. `$WORKDIR`, is mapped to `/home/docker-user/work` within the container. You can read/write in this mapped 'volume' (or directory). The changes are visible outside of the container---it's a 'map', not a 'copy'. The beauty of the mapping is that you can do code editing outside of Docker using your favorite IDE; the changes are visible within the container, in which you can run tests.

Within the container there are a number of customizations in place, including Bash shell prompt, `neovim` editor, and terminal window title. The command

```
env
```

will list some environment settings.

`git` is **not** available in the containers. use `git` commands outside of a container.


<a name="jupyter-notebook"></a>
## Use `Jupyter Notebook`

With most of the commands in `$HOME/work/bin`, say `py3`, type

```
py3 ipynb
```

(meaning 'IPython notebook') will start a `Jupyter Notebook` server in the container.

Once the server is running, access it at `http://localhost:8888` using your favorite browser.

The server stays in the front of the terminal. You may kill it by `Control-C`.
  
You can have only one such `ipynb` container running at any time, because it occupies the port `8888`, which can not be used by another `Jupyter Notebook` server.


