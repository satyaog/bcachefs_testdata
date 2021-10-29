from argparse import ArgumentParser
import os


def main():
    parser = ArgumentParser()
    parser.add_argument('-i', type=int)
    parser.add_argument('-b', type=int)
    parser.add_argument('folder', type=str)
    args = parser.parse_args()

    data = []
    for root, _, files in os.walk(args.folder):
        for f in files:
            data.append(os.path.join(root, f))

    data.sort()

    s = args.i * args.b
    e = s + args.b

    try:
        print(' '.join(data[s:e]))
    except Exception as e:
        print()

if __name__ == '__main__':
    main()
