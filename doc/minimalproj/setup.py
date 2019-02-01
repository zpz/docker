import pathlib
from setuptools import setup, find_packages

HERE = pathlib.Path(__file__).parent

# Assume the repo's name is the Python package's name.
# If this is not true, write the actual package name below.
name = HERE.resolve().name

exec((HERE / 'src' / name / 'version.py').read_text())
version = __version__

setup(
    name=name,
    version=version,
    description='Package ' + name,
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    include_package_data=True,
)
