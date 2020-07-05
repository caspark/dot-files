#!/usr/bin/env python3

import sys
import os

self_name = sys.argv[0]
args = sys.argv[1:]

if len(args) < 1:
    print(f'Usage: {self_name} HOST [PORT_TO_FORWARD_1 [PORT_TO_FORWARD_2 [...]]]')
    sys.exit(1)

host = args[0]
ports = args[1:]

args = ['-A']
for port in ports:
    args.append('-L')
    args.append(f'{port}:{host}:{port}')
args.append(host)

print("\n".join(args))

