#!/usr/bin/python

import argparse
import sys
import json

import pygments
import pygments.lexers
import pygments.formatters

from subprocess import Popen, PIPE


def usage():
    print("Usage: %s <filename> [...]"  % (sys.argv[0],))


def process_contents(contents, lexer=None):
    # For some reason, json is detected as 'velocity'
    try:
        if lexer is None:
            json.loads(contents)
            lexer = pygments.lexers.JsonLexer()
    except ValueError:
        pass

    if lexer is None:
        try:
            lexer = pygments.lexers.guess_lexer(contents)
        except pygments.util.ClassNotFound:
            pass

    if lexer is not None:
        formatter = pygments.formatters.get_formatter_by_name("terminal")
        output = pygments.highlight(contents, lexer, formatter)
    else:
        output = contents

    Popen(['less', '-FXR'], stdin=PIPE).communicate(output)


def process(filename, lexer=None):
    try:
        if lexer is None:
            lexer = pygments.lexers.get_lexer_for_filename(filename)
    except pygments.util.ClassNotFound:
        pass

    try:
        with open(filename, 'r') as f:
            contents = f.read()
    except Exception as e:
        print(e)
        exit(1)

    process_contents(contents, lexer)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='highlight words matching a pattern')
    parser.add_argument('files', metavar='file', type=str, nargs='*',
                        help='files to highlight')
    parser.add_argument('-l', metavar='lexer', dest='lexer', type=str,
                        help='Override the pygments lexer')
    args = parser.parse_args()

    lexer = None
    try:
        if args.lexer:
            lexer = pygments.lexers.get_lexer_by_name(args.lexer)
    except pygments.util.ClassNotFound:
        print("Error: no lexer for alias '{}' found".format(args.lexer))
        exit(1)

    if not args.files:
        try:
            process_contents(sys.stdin.read(), lexer)
        except KeyboardInterrupt:
            exit(130)
    else:
        for filename in args.files:
            process(filename, lexer)
