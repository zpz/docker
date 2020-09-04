# Docker

- A Docker base image [`py3`](./py3) for Python code development, emphasizing data science.
- A Docker utility [`run-docker`](./bin/run-docker), which is integrated with the small image [`mini`](./mini).
- A [template](./project-template) for a minimal Python project that uses this Docker stack.

In a more serious setting, the image `mini` and script `run-docker` could be defined in a separate repo, so that they can evolve independent of the base image `py3`.


## Unit tests with `py.test`

Put all tests in `tests/` in the root of the repo.
Put package code in `src/<package-name>`.

### Run all tests

```
$ py.test [-s] [--cov=src/] tests
```

### Run selected tests

```
$ py.test [options] <path-to-file>/<file-name>.py[::function]
```

### Control logging level to show

```
$ py.test --log-cli-level debug ...
```

### Enter debugger upon error

```
$ py.test --pudb ...
```

This does not require breakpoints to be set in advance.


## Debugging with `pudb`

- Use `Ctrl-x` to show/hide the Python console window at the bottom of the left panel.
To adjust the height of this window, move focus onto the `< clear >` sign
to the right, then use `+/-`.
- When cursor is in the right panel, use `+/-` to adjust the width of the panel.

Suppose the script `program.py` has crashed.
Take the following steps to debug.

1. Re-run the program to investigate the exception. Do

```
$ pudb program.py
```

The first screen will show the source code without running it.

Hit `c` (continue) to run. It will stop in the debugger when and where error occurs.

After checking things, hit `q`. You'll get a confirmation window.
Choose `< Restart >` if you want to.
Hit `q` again will quit for real.

2. Re-run the program with breakpoints pre-set with

```
breakpoint()
```

in the source code. Then start with

```
$ python program.py
```

Execution will pause in the debugger at the first breakpoint.

Such breakpoints are set independent of `pudb`. *Remember* to remove these lines after investigation.

If error occurs in tests, use `py.test --pudb ...` to run the test.