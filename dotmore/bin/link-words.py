#!/usr/bin/env python3
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: link-words 'sentence' [urls...]", file=sys.stderr)
        sys.exit(1)

    sentence = sys.argv[1]

    if len(sys.argv) == 2:
        if sys.stdin.isatty():
            print("Enter links (separated by spaces or newlines, Ctrl+D when done):", file=sys.stderr)
        links_input = sys.stdin.read()
        urls = links_input.split()
    else:
        urls = sys.argv[2:]

    words = sentence.split()

    print(f"Words: {len(words)}, Links: {len(urls)}", file=sys.stderr)

    if len(urls) > len(words):
        extra = len(urls) - len(words)
        print(f"Warning: {extra} extra link{'s' if extra > 1 else ''} provided and will be ignored", file=sys.stderr)
    elif len(urls) < len(words):
        missing = len(words) - len(urls)
        print(f"Warning: {missing} link{'s' if missing > 1 else ''} missing, last {missing} word{'s' if missing > 1 else ''} will be unlinked", file=sys.stderr)

    result = []
    for i, word in enumerate(words):
        if i < len(urls):
            result.append(f"[{word}]({urls[i]})")
        else:
            result.append(word)

    print(' '.join(result))

if __name__ == "__main__":
    main()
