# Docker

- A Docker base image [`py3`](./py3) for Python code development, emphasizing data science.
- A Docker utility [`run-docker`](./bin/run-docker), which is integrated with the small image [`mini`](./mini).
- A [template](./project-template) for a minimal Python project that uses this Docker stack.

In a more serious setting, the image `mini` and script `run-docker` could be defined in a separate repo, so that they can evolve independent of the base image `py3`.
