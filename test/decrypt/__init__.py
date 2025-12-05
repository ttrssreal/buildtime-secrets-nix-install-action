import subprocess
import shutil

EXPECTED_DECRYPTED_VALUE = "meow"

def nix(cmd):
    return subprocess.run(
        [ shutil.which("nix-build") ] + cmd,
        env={ "NO_COLOR": "1" },
        text=True,
        capture_output=True
    )

def name():
    return "decrypt"

def run():
    result = nix([ "test/decrypt/test.nix" ])
    try:
        result.check_returncode()
    except subprocess.CalledProcessError as e:
        print(f"error: test (decrypt): {e}")
        print("stdout:", result.stdout)
        print("stderr:", result.stderr)
        raise e

    with open("result", "r") as f:
        decrypted = f.read()
        assert decrypted == EXPECTED_DECRYPTED_VALUE, \
            f"Secret decrypted to '{decrypted}' when we were expecting '{EXPECTED_DECRYPTED_VALUE}'"
