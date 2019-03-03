import pathlib
from setuptools import setup, find_packages

HERE = pathlib.Path(__file__).parent

# Assume the repo's name is the Python package's name.
# The package is in `src/package_name` and contains a file `version.py`
# that defines `__version__`.
# If this is not true, write the actual package name and version below.

def get_repo_name():
    name = ''
    if (HERE / '.git').exists():
        substr = 'github.com:zpz/'
        for line in open(HERE / '.git' / 'config'):
            if substr in line:
                line = line.strip()
                idx = line.rindex(substr)
                assert line.endswith('.git')
                name = line[idx + len(substr) : -4]
                break
    else:
        name = HERE.resolve().name
        folders = list((HERE / 'src').glob('*'))
        if len(folders) > 1:
            raise Exception('Expecting a single directory in "src/" to infer package name')
        name = folders[0].name
    assert name
    return name


def get_version():
    if (HERE / 'src' / name / 'version.py').exists():
        _locals = locals()
        exec((HERE / 'src' / name / 'version.py').read_text(), globals(), _locals())
        version = _locals['__version__']
    else:
        version = '0.1.0'
    return version


name = get_repo_name()
version = get_version()


setup(
    name=name,
    version=version,
    description='Package ' + name,
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    include_package_data=True,
)
