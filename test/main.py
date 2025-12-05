#!/usr/bin/env python3

import decrypt

def run_test(test):
    print(f"Running test '{test.name()}'", end="... ")
    test.run()
    print(f"Test successful!")

def main():
    run_test(decrypt)

if __name__ == "__main__":
    main()
