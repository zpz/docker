# Docker

Some Docker images aimed at software development, especially using Python.

The installation script (`install.sh`) assume a directory `$HOME/work/bin`, where `$HOME` is the user's home directory. Make sure this directory is on the system `PATH` so that commands installed there can be found.


<!-- toc -->

* [Directory structure on the development machine](#directory-structure)
* [Execution environment within a Docker container](#env-in-docker)
* [Use `Jupyter Notebook`](#jupyter-notebook)

<!-- end of toc -->


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

`git` is **not** available in the containers. Use `git` commands outside of a container.


<a name="jupyter-notebook"></a>
## Use `Jupyter Notebook`

With most of the commands in `$HOME/work/bin`, say `py3`, type

```
py3 notebook
```

(meaning 'IPython notebook') will start a `Jupyter Notebook` server in the container.

Once the server is running, access it at `http://localhost:8888` using your favorite browser.

The server stays in the front of the terminal. You may kill it by `Control-C`.

You can have only one such `notebook` container running at any time, because it occupies the port `8888`, which can not be used by another `Jupyter Notebook` server.


