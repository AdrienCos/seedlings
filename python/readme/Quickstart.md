# Quickstart

This file provides a quick documentation of the most useful features of this
template.

- [How do I...?](#how-do-i)
  - [...setup my development environment?](#setup-my-development-environment)
  - [...get the list of available commands?](#get-the-list-of-available-commands)
  - [...test my code?](#test-my-code)
  - [...test my code against multiple Python versions?](#test-my-code-against-multiple-python-versions)
  - [...format my code?](#format-my-code)
  - [...spellcheck my project?](#spellcheck-my-project)
  - [...lint my code?](#lint-my-code)
  - [...generate test coverage?](#generate-test-coverage)
  - [...add runtime dependencies to my project?](#add-runtime-dependencies-to-my-project)
  - [...add development dependencies to my project?](#add-development-dependencies-to-my-project)
  - [...bump the version number of my package?](#bump-the-version-number-of-my-package)
  - [...generate a `.pex` executable?](#generate-a-pex-executable)
  - [...generate a distribution archive?](#generate-a-distribution-archive)
  - [...build a Docker image that runs my package?](#build-a-docker-image-that-runs-my-package)
  - [...publish my package to a Pip repository?](#publish-my-package-to-a-pip-repository)
  - [...clean my local project directory?](#clean-my-local-project-directory)
  - [...update the project to the latest version of the template?](#update-the-project-to-the-latest-version-of-the-template)

## How do I...?

### ...setup my development environment?

These instructions assume that you already have a working development version of
Python3 installed on your machine. If this is not the case, start by doing
installing one. One recommended method is by using
[pyenv](https://github.com/pyenv/pyenv), a tool that allows you to easily manage
the versions of Python you have installed on your machine.

You will then need [`pdm`](https://pdm.fming.dev/latest/) to be installed on
your machine. It is a project, package, and dependency manager for Python, and
is what powers most of this project's lifecycle. The recommended way to install
it is with [`pipx`](https://pypa.github.io/pipx/).

Once Python and `pdm` are available, you can setup the environment with:

``` sh
# Clone this repo
git clone {{ repository_url }}
# Move into the directory
cd {{ package_name }}
# Create a new virtualenv, install the project,
# its dependencies, and the pre-commit hooks
pdm setup
# Check that everything worked as expected by running the linters,
# test suite, and building the package
# NOTE: This can take a couple of minutes
pdm lint
pdm test
pdm docker-build
pdm build
pdm pex-build
```

You now have a `virtualenv` in `.venv/` with all the development dependencies
installed, as well as your package installed in development mode.

### ...get the list of available commands?

`pdm help`

This will print the list of `pdm` scripts (defined in `pyproject.toml`), and a
short description of their purpose.

### ...test my code?

`pdm test`

This will run the test suite located in the `tests/` directory against the
available Python3 install.

### ...test my code against multiple Python versions?

`pdm cross-test`

This will use `tox` to test your code against all the Python versions defined in
the `tox.ini` file (make sure to always keep this list consistent with the
`requires-python` and the `classifiers` of the `pyproject.toml`).

**Note**: You will to have every version of Python to run these tests available
in your `$PATH`. We recommend the use of
[`pyenv`](https://github.com/pyenv/pyenv) to manage your Python versions.

### ...format my code?

`pdm format`

This will run `black` and `isort` on the `src/` and `tests/` directories,
formatting your code properly.

### ...spellcheck my project?

`pdm spell`

It will run `typos` on the entire project, and fix any typo it finds.

### ...lint my code?

`pdm lint`

This will call various linters (`black`, `isort`, `ruff`, `pyright`, `typos`), and
tell you if your code passes them.

### ...generate test coverage?

`pdm coverage`

This will run the test suite against the available Python3 install, and generate
a code coverage report in the `htmlcov` directory.

### ...add runtime dependencies to my project?

`pdm add $PACKAGE`

This will add the requested package to `pyproject.toml`, resolve the all the
dependencies, and lock them in `pdm.lock`.

**Note**: `$PACKAGE` can contain version specifier, such as `"foobar>=2,<3"`

### ...add development dependencies to my project?

`pdm add -d/--dev $PACKAGE`

Similar to the previous command, this will add the package to different list of
dependencies, that is only installed when installing the project in development
mode with `pdm`, and not in production.

### ...bump the version number of my package?

`git tag X.Y.Z`

Apply a new `git` tag to the commit you want to define as a new version. When
building the package from the repository, `setuptools_scm` will use this tag as
the version number of the package.

Make sure to follow the [Semantic Versioning](https://semver.org/) rule, to
always keep a consistent version for your package.

### ...generate a `.pex` executable?

`pdm pex-build`

This will generate one `pex` executable archive per entrypoint defined in the
`pyproject.toml` file. Each of this file is a complete `virtualenv`, with the
package and all its dependencies installed inside, and that only need a Python
interpreter to run.

### ...generate a distribution archive?

`pdm build`

This will build a `.tar.gz` and a `.whl` distribution files, that can then be
installed on a target machine with `pip install $FILENAME`.

### ...build a Docker image that runs my package?

`pdm docker-build`

This will build a `.whl` distribution, and use it to build a minimal Docker
image, tagged `{{ package_name }}:latest` and `{{ package_name }}:$VERSION`,
that runs it.

### ...publish my package to a Pip repository?

`pdm publish`

This will build the `.whl` and `.tar.gz` of the package, and upload them to
[Pypi](https://pypi.org).

**Warning**: You must run this command from a properly tagged `git` commit,
otherwise your package will be rejected by the repository.

For more control over this process, look at the [documentation of `pdm
publish`](https://pdm.fming.dev/latest/usage/publish/)

### ...clean my local project directory?

`pdm clean`

This will use `pyclean` to find and delete the binary python files, the various
cache directories, and the `dist/` directory.

### ...update the project to the latest version of the template?

`pdm template-update`

This will update your project to the latest release of the template. Your
previous answers to the template questions will be kept, and only the new
questions will be asked.

Any conflict created by the update of the template will be written in the
related files, with the usual merge conflict syntax. Make sure to review and
resolve them before committing the updates to the repository.
