"""Inspect exported ZIP contents and native ELF alignment; does not sign artifacts.

Usage: python tests/audit_android.py builds/game.apk --report builds/audit.json
ELF/ZIP inspection is a static check, not a 16KB device runtime test.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import zipfile

RETIRED_RESOURCES = (
    'scenes/main.tscn', 'scenes/inventory.tscn', 'scenes/upgrades.tscn',
    'scripts/main.gd', 'scripts/inventory_screen.gd', 'scripts/upgrades_screen.gd',
    'scripts/shop_view.gd', 'scripts/customer_manager.gd', 'scripts/product_icons.gd',
)


def native_segments(data):
    if data[:4] != b'\x7fELF' or data[5] != 1:
        raise ValueError('Expected little-endian ELF')
    is_64 = data[4] == 2
    if is_64:
        offset = struct.unpack_from('<Q', data, 32)[0]
        size, count = struct.unpack_from('<HH', data, 54)
    else:
        offset = struct.unpack_from('<I', data, 28)[0]
        size, count = struct.unpack_from('<HH', data, 42)
    segments = []
    for index in range(count):
        position = offset + index * size
        kind = struct.unpack_from('<I', data, position)[0]
        if kind != 1:
            continue
        if is_64:
            file_offset, address = struct.unpack_from('<QQ', data, position + 8)
            alignment = struct.unpack_from('<Q', data, position + 48)[0]
        else:
            file_offset, address = struct.unpack_from('<II', data, position + 4)
            alignment = struct.unpack_from('<I', data, position + 28)[0]
        segments.append({'alignment': alignment, 'offset': file_offset, 'address': address})
    return segments


def audit(path):
    result = {'artifact': path.name, 'bytes': path.stat().st_size,
              'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
              'native_libraries': [], 'excluded_content_leaks': [], 'errors': []}
    with zipfile.ZipFile(path) as archive:
        result['zip_crc_ok'] = archive.testzip() is None
        names = archive.namelist()
        result['bundle'] = 'BundleConfig.pb' in names
        result['jar_signatures'] = [n for n in names if n.startswith('META-INF/') and n.endswith(('.RSA', '.DSA', '.EC'))]
        for name in names:
            resource = name.removeprefix('base/').removeprefix('assets/')
            if resource.startswith('assets/icons/') or any(resource == old or resource == old + '.remap' or resource == old + 'c' for old in RETIRED_RESOURCES):
                result['errors'].append('Retired grocery content exported: ' + name)
            if any('/' + directory + '/' in '/' + name for directory in ('tests', 'docs', 'tools', '.git')) or name.endswith(('.jks', '.keystore', 'export_credentials.cfg', 'progress.json', 'preferences.cfg')):
                result['excluded_content_leaks'].append(name)
            if name.endswith('.so'):
                segments = native_segments(archive.read(name))
                compatible = bool(segments) and all(s['alignment'] >= 16384 and (s['address'] - s['offset']) % 16384 == 0 for s in segments)
                result['native_libraries'].append({'name': name, 'load_segments': segments,
                                                    'elf_16kb_aligned': compatible})
                if 'arm64-v8a' in name and not compatible:
                    result['errors'].append('ARM64 ELF does not support 16KB alignment: ' + name)
        if not result['zip_crc_ok']:
            result['errors'].append('ZIP CRC failure')
        if result['excluded_content_leaks']:
            result['errors'].append('Development-only content exported')
        if not any('arm64-v8a' in n['name'] for n in result['native_libraries']):
            result['errors'].append('Missing ARM64 native library')
        if path.suffix == '.aab' and not all(n in names for n in ('BundleConfig.pb', 'base/manifest/AndroidManifest.xml', 'base/resources.pb')):
            result['errors'].append('Missing required bundle structure')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('artifact', type=Path)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    report = audit(args.artifact)
    if args.report:
        args.report.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(report['errors']))
