"""Checks the JavaScript and CSS libraries that core and extras bundle, listed in js-libraries.json.

    python3 check-js-libraries.py                   every reference to a library has its version
    python3 check-js-libraries.py --latest          also lists the libraries behind their latest npm release
    python3 check-js-libraries.py --latest --issues also opens or updates one issue per library behind,
                                                    in its repository, with the gh CLI (needs GH_TOKEN)

The first check runs on every build and fails when, for example, the bundled copy of a library
and the URL its XxxURL module loads have different versions. The other two run weekly.
Run it from the root of the parent, with the submodules checked out. Exits with 1 when a
reference is wrong; libraries behind npm are reported but don't fail.
"""
import json
import os
import re
import subprocess
import sys
import urllib.request

ROOT = os.path.dirname(os.path.abspath(__file__))
ORG = 'gwtbootstrap5'
LABEL = 'js-update'
# Files whose content is searched; bundled libraries are only matched by name
CONTENT_SUFFIXES = ('.java', '.gwt.xml')


def files_under(path):
    if os.path.isfile(path):
        yield path
        return
    for folder, _, names in os.walk(path):
        for name in names:
            yield os.path.join(folder, name)


def versions_found(reference):
    """Returns (version, where) for every match of the reference's expression."""
    regex = re.compile(reference['regex'])
    base = os.path.join(ROOT, reference['path'])
    found = []
    for path in files_under(base):
        where = os.path.relpath(path, ROOT)
        for match in regex.finditer(where):
            found.append((match.group(1), where))
        if path.endswith(CONTENT_SUFFIXES) or os.path.isfile(base):
            text = open(path, encoding='utf-8').read()
            for match in regex.finditer(text):
                line = text.count('\n', 0, match.start()) + 1
                found.append((match.group(1), '%s:%d' % (where, line)))
    return found


def check_references(libraries):
    errors = []
    for library in libraries:
        for reference in library['references']:
            found = versions_found(reference)
            if not found:
                errors.append('%s: nothing matches %s in %s' % (library['name'], reference['regex'], reference['path']))
            for version, where in sorted(set(found)):
                if version != library['version']:
                    errors.append('%s: %s says %s, not %s' % (library['name'], where, version, library['version']))
    return errors


def latest_version(package):
    url = 'https://registry.npmjs.org/%s/latest' % package.replace('/', '%2F')
    with urllib.request.urlopen(url, timeout=30) as response:
        return json.load(response)['version']


def numbers(version):
    return tuple(int(part) for part in re.findall(r'\d+', version)[:3])


def gh(*args):
    return subprocess.run(['gh', *args], check=True, capture_output=True, text=True).stdout


def report_issue(library, latest):
    repo = '%s/%s' % (ORG, library['repo'])
    major = numbers(latest)[0] > numbers(library['version'])[0]
    title = 'Update %s to %s' % (library['name'], latest)
    body = '\n'.join([
        '%s %s is out; GwtBootstrap5 bundles %s.' % (library['name'], latest, library['version']),
        '',
        '- npm: https://www.npmjs.com/package/%s/v/%s' % (library['npm'], latest),
        '- Read its changelog for options the wrapper uses that were renamed or removed.',
        '- Replace the bundled files and the URL of its `XxxURL` module, then update the version '
        'in `js-libraries.json` of gwtbootstrap5-parent; `check-js-libraries.py` finds what still '
        'says the old one.',
        '- Check its demo page with `src/test/browser/check.py`.',
    ])
    if major:
        body += ('\n\nThis is a new **major** version: it may change the API, which can only go into '
                 'a minor release of GwtBootstrap5, not a patch.')
    body += '\n\n_Opened by the weekly check of the gwtbootstrap5-parent repository._'
    gh('label', 'create', LABEL, '-R', repo, '--color', 'C5DEF5', '--force',
       '--description', 'A bundled JavaScript library has a new version')
    # One open issue per library: a newer release updates it instead of opening another
    issues = json.loads(gh('issue', 'list', '-R', repo, '--label', LABEL, '--state', 'open',
                           '--json', 'number,title', '--limit', '100'))
    prefix = 'Update %s to ' % library['name']
    existing = [issue for issue in issues if issue['title'].startswith(prefix)]
    if not existing:
        print('  opened %s' % gh('issue', 'create', '-R', repo, '--title', title, '--body', body,
                                 '--label', LABEL).strip())
    elif existing[0]['title'] != title:
        gh('issue', 'edit', str(existing[0]['number']), '-R', repo, '--title', title, '--body', body)
        print('  updated %s#%d' % (repo, existing[0]['number']))
    else:
        print('  already open: %s#%d' % (repo, existing[0]['number']))


def main(args):
    libraries = json.load(open(os.path.join(ROOT, 'js-libraries.json'), encoding='utf-8'))['libraries']
    errors = check_references(libraries)
    for error in errors:
        print('ERROR ' + error)
    print('%d libraries, %d wrong references' % (len(libraries), len(errors)))

    if '--latest' in args:
        for library in libraries:
            latest = latest_version(library['npm'])
            if numbers(latest) > numbers(library['version']):
                print('BEHIND %s %s, latest %s' % (library['name'], library['version'], latest))
                if '--issues' in args:
                    report_issue(library, latest)
            else:
                print('OK %s %s' % (library['name'], library['version']))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
