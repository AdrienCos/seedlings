# Quickstart

This file provides a quick documentation of the most useful features of this
template.

- [How do I...?](#how-do-i)
  - [...setup my development environment?](#setup-my-development-environment)
  - [...get the list of available commands?](#get-the-list-of-available-commands)
  - [...test my code?](#test-my-code)
  - [...format my code?](#format-my-code)
  - [...lint my code?](#lint-my-code)
  - [...generate test coverage?](#generate-test-coverage)
  - [...add runtime dependencies to my project?](#add-runtime-dependencies-to-my-project)
  - [...add development dependencies to my project?](#add-development-dependencies-to-my-project)
  - [...bump the version number of my package?](#bump-the-version-number-of-my-package)
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
[mise](https://mise.jdx.dev/), a tool that allows you to easily manage
the versions of Python and other tools you have installed on your machine.

You will also need [`uv`](https://docs.astral.sh/uv/) and
[`just`](https://github.com/casey/just) to be installed on your machine.
`uv` is a fast Python package and project manager, and `just` is a command
runner that powers this project's lifecycle. The recommended way to install
them is via `mise` or your system package manager.

Once Python, `uv`, and `just` are available, you can setup the environment with:

``` sh
# Clone this repo
git clone {{ repository_url }}
# Move into the directory
cd {{ package_name }}
# Create a new virtualenv, install the project,
# its dependencies, and the pre-commit hooks
just setup
# Check that everything worked as expected by running the linters,
# test suite, and building the package
# NOTE: This can take a couple of minutes
just lint
just test
just docker-build
just build
```

You now have a `virtualenv` in `.venv/` with all the development dependencies
installed, as well as your package installed in development mode.

### ...get the list of available commands?

`just --list`

This will print the list of `just` recipes (defined in `Justfile`), and a
short description of their purpose.

### ...test my code?

`just test`

This will run the test suite located in the `tests/` directory against the
available Python3 install.

### ...format my code?

`just format`

This will run `ruff format` on the `src/` and `tests/` directories,
formatting your code properly.

### ...lint my code?

`just lint`

This will call various linters (`ruff`, `ty`), and
tell you if your code passes them.

### ...generate test coverage?

`just coverage`

This will run the test suite against the available Python3 install, and generate
a code coverage report in the `htmlcov` directory.

### ...add runtime dependencies to my project?

`uv add $PACKAGE`

This will add the requested package to `pyproject.toml`, resolve the all the
dependencies, and lock them in `uv.lock`.

**Note**: `$PACKAGE` can contain version specifier, such as `"foobar>=2,<3"`

### ...add development dependencies to my project?

`uv add --dev $PACKAGE`

Similar to the previous command, this will add the package to a different list of
dependencies, that is only installed when installing the project in development
mode with `uv`, and not in production.

### ...bump the version number of my package?

`git tag X.Y.Z`

Apply a new `git` tag to the commit you want to define as a new version. When
building the package from the repository, the build backend will use this tag as
the version number of the package.

Make sure to follow the [Semantic Versioning](https://semver.org/) rule, to
always keep a consistent version for your package.

### ...generate a distribution archive?

`just build`

This will build a `.tar.gz` and a `.whl` distribution files, that can then be
installed on a target machine with `pip install $FILENAME`.

### ...build a Docker image that runs my package?

`just docker-build`

This will build a `.whl` distribution, and use it to build a minimal Docker
image, tagged `{{ package_name }}:latest` and `{{ package_name }}:$VERSION`,
that runs it.

### ...publish my package to a Pip repository?

`uv publish`

This will build the `.whl` and `.tar.gz` of the package, and upload them to
[Pypi](https://pypi.org).

**Warning**: You must run this command from a properly tagged `git` commit,
otherwise your package will be rejected by the repository.

For more control over this process, look at the [documentation of `uv
publish`](https://docs.astral.sh/uv/guides/publish/)

### ...clean my local project directory?

`just clean`

This will use `pyclean` to find and delete the binary python files, the various
cache directories, and the `dist/` directory.

### ...update the project to the latest version of the template?

`just template-update`

This will update your project to the latest release of the template. Your
previous answers to the template questions will be kept, and only the new
questions will be asked.

Any conflict created by the update of the template will be written in the
related files, with the usual merge conflict syntax. Make sure to review and
resolve them before committing the updates to the repository.
