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
    parser.add_argument(
        "esphome_target_version", type=str, help="Expected ESPHome version to check"
    )
    return parser.parse_args()


async def get_device_info(api):
    await api.connect(login=False)

    print(api.api_version, file=sys.stderr)

    device_info = await api.device_info()
    print(device_info, file=sys.stderr)
    return device_info


async def main():
    args = parse_args()
    api = aioesphomeapi.APIClient(args.name, args.port, "")
    device_info = {}
    try:
        device_info = await get_device_info(api)
    except Exception as e:
        print(e, file=sys.stderr)
        print("failed to get device info...")
        # mark unit as failed
        # reference: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#ExecCondition=
        sys.exit(255)

    found_esphome_version = device_info.esphome_version
    expected_esphome_version = args.esphome_target_version

    if found_esphome_version == expected_esphome_version:
        print("ESPHome version up-to-date:", found_esphome_version)
    else:
        print("found ESPHome version:", found_esphome_version)
        print("expected:", expected_esphome_version)
        sys.exit(0)

    found_version = device_info.project_version
    expected_version = args.target_version

    if found_version == expected_version:
        print("firmware version up-to-date:", found_version)
        print("skipping upgrade...")
        sys.exit(1)

    print("found firmware version:", found_version)
    print("expected:", expected_version)
    sys.exit(0)


if __name__ == "__main__":
    asyncio.run(main())
