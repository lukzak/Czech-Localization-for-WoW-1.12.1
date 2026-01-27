import sys
import re

LINE_PATTERN = re.compile(
    r'^"[^"]*","[^"]*","[^"]*"$'
)

def validate_csv(path):
    errors = []

    with open(path, encoding="utf-8") as f:
        for line_num, line in enumerate(f, start=1):
            line = line.rstrip("\n")

            if not LINE_PATTERN.match(line):
                errors.append(f"Line {line_num}: Invalid format")

    return errors


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_csv.py <file.csv>")
        sys.exit(1)

    issues = validate_csv(sys.argv[1])

    if issues:
        print("Validation failed:")
        for issue in issues:
            print(issue)
    else:
        print("CSV is valid.")
