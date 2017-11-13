#!/usr/bin/env python

def run(line):
    with open("/tmp/shell-output", "a") as myfile:
        myfile.write("".join([line, "\n"]))
    print line


if __name__ == "__main__":
    while True:
        cmd = raw_input(">")
        run(cmd)
