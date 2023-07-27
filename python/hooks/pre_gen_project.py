# Initial version taken from:
# https://github.com/audreyfeldroy/cookiecutter-pypackage

import re
import sys

MODULE_REGEX = r"^[_a-zA-Z][_a-zA-Z0-9]+$"

module_name = "{{ cookiecutter.project_slug }}"

if not re.match(MODULE_REGEX, module_name):
    # Log and exit
    sys.exit(
        f"ERROR: The project slug ({module_name}) is not a valid Python \
module name. Please do not use a - and use _ instead"
    )
