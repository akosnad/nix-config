#!/usr/bin/env python3

import argparse
import asyncio
import aioesphomeapi
import sys


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default="6053", help="Port to connect to")
    parser.add_argument("name", type=str, help="Name of ESPHome device to connect to")
    parser.add_argument(
        "target_version", type=str, help="Expected version string to check"
    )
    return parser.parse_args()


async def main():
    args = parse_args()
    api = aioesphomeapi.APIClient(args.name, args.port, "")
    await api.connect(login=False)

    print(api.api_version, file=sys.stderr)

    device_info = await api.device_info()
    print(device_info, file=sys.stderr)

    found_version = device_info.project_version
    expected_version = args.target_version

    if expected_version == "unclean-tree":
        print("expected version tree is unclean, forcing upgrade")
        sys.exit(0)

    if found_version == expected_version:
        print("firmware version up-to-date:", found_version)
        print("skipping upgrade...")
        sys.exit(1)

    print("found firmware version:", found_version)
    print("expected:", expected_version)
    sys.exit(0)


if __name__ == "__main__":
    asyncio.run(main())
