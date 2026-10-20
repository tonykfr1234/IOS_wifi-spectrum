#!/usr/bin/env python3
"""Regenerate docs/media from real simulator screenshots.

The UI tests (AppUITests) drive the app in demo mode and save PNGs named 01_connection.png ...
09_about.png. Point this script at that folder, or let it pull the latest set that CI pushed to
the `ci-artifacts` branch, and it assembles:
  docs/media/wifi-spectrum-ios-demo.gif  silent preview, 1 frame per second
  docs/media/wifi-spectrum-ios-demo.mp4  silent H.264 video
  docs/media/connection.png, speedtest.png, channel-calculator.png

Usage:
  python scripts/generate_demo.py                 # use origin/ci-artifacts:screenshots
  python scripts/generate_demo.py build/screenshots

Needs ffmpeg on PATH (and git for the ci-artifacts mode).
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MEDIA = ROOT / 'docs' / 'media'
STILLS = [('01_connection.png', 'connection.png'),
          ('02_speedtest.png', 'speedtest.png'),
          ('04_channel_calculator.png', 'channel-calculator.png')]


def run(*cmd: str) -> None:
    print('+', ' '.join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True)


def from_ci(target: Path) -> Path:
    ref = 'refs/remotes/origin/ci-artifacts'
    run('git', 'fetch', '-q', 'origin', f'+refs/heads/ci-artifacts:{ref}')
    names = subprocess.run(['git', 'ls-tree', '--name-only', f'{ref}:screenshots'], cwd=ROOT,
                           check=True, capture_output=True, text=True).stdout.split()
    for name in names:
        if name.endswith('.png'):
            blob = subprocess.run(['git', 'show', f'{ref}:screenshots/{name}'], cwd=ROOT,
                                  check=True, capture_output=True).stdout
            (target / name).write_bytes(blob)
    return target


def main(argv: list[str]) -> int:
    if shutil.which('ffmpeg') is None:
        print('ffmpeg is required', file=sys.stderr)
        return 1
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        source = Path(argv[1]).resolve() if len(argv) > 1 else from_ci(work)
        shots = sorted(p for p in source.glob('[0-9][0-9]_*.png'))
        if not shots:
            print(f'no screenshots in {source}', file=sys.stderr)
            return 1
        frames = work / 'frames'
        frames.mkdir()
        for i, png in enumerate(shots, 1):
            shutil.copy2(png, frames / f'frame_{i:03d}.png')
        MEDIA.mkdir(parents=True, exist_ok=True)
        pattern = str(frames / 'frame_%03d.png')
        palette = str(work / 'palette.png')
        run('ffmpeg', '-y', '-loglevel', 'error', '-framerate', '1', '-i', pattern,
            '-vf', 'scale=320:-1:flags=lanczos,palettegen=max_colors=128', palette)
        run('ffmpeg', '-y', '-loglevel', 'error', '-framerate', '1', '-i', pattern, '-i', palette,
            '-lavfi', 'scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=4',
            '-loop', '0', str(MEDIA / 'wifi-spectrum-ios-demo.gif'))
        run('ffmpeg', '-y', '-loglevel', 'error', '-framerate', '1', '-i', pattern,
            '-vf', 'scale=540:-2,format=yuv420p', '-r', '30', '-c:v', 'libx264', '-crf', '20',
            '-movflags', '+faststart', '-an', str(MEDIA / 'wifi-spectrum-ios-demo.mp4'))
        for src, dst in STILLS:
            if (source / src).exists():
                run('ffmpeg', '-y', '-loglevel', 'error', '-i', str(source / src),
                    '-vf', 'scale=540:-1', str(MEDIA / dst))
    print('demo media updated in', MEDIA)
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
