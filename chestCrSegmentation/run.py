#!/usr/bin/env python
from flywheel_gear_toolkit import GearToolkitContext
# See docs at https://flywheel-io.gitlab.io/public/gear-toolkit/index.html

def main(context):
    # Get input defined in manifest
    input_file = context.get_input_path("input-file")

    print(f"I found an input 'input_file' at {input_file}")

if __name__ == '__main__':
    # Initialize Gear Toolkit context
    with GearToolkitContext() as context:
        context.init_logging()
        main(context)