from pathlib import Path
import string

FOLDER = Path(r"Z:\Files")
TOTAL_CHUNKS = 191

def expected_chunks():
    letters = string.ascii_lowercase
    for i in range(TOTAL_CHUNKS):
        yield f"debian_{letters[i // 26]}{letters[i % 26]}"

def main():
    expected = list(expected_chunks())
    found = [name for name in expected if (FOLDER / name).is_file()]
    missing = [name for name in expected if name not in found]

    total_bytes = sum((FOLDER / name).stat().st_size for name in found)
    percent = len(found) / TOTAL_CHUNKS * 100

    print("=" * 40)
    print("       DEBIAN CHUNK TRACKER")
    print("=" * 40)
    print(f"Folder:       {FOLDER}")
    print(f"Chunks found: {len(found)}/{TOTAL_CHUNKS}")
    print(f"Progress:     {percent:.1f}%")
    print(f"Downloaded:   {total_bytes / (1024**2):.2f} MiB")
    print(f"Missing:      {len(missing)}")

    if missing:
        print("\nMissing chunks:")
        for name in missing:
            print(name, end="  ")
            if (missing.index(name) + 1) % 6 == 0:
                print()
        print()
    else:
        print("\nALL 191 CHUNKS ARE PRESENT! 🎉")

    print("=" * 40)

if __name__ == "__main__":
    main()
