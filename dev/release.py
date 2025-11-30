import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Final
from zoneinfo import ZoneInfo

from packaging.version import InvalidVersion, Version, parse as parse_version

try:
    import readline
except ImportError:
    pass


# This script will prompt you for a version number, and then create a tag for that version number and push it.
# It does not have any restrictions on which branch it can be ran from. It is expected to be paired with a
# dedicated release pipeline triggered by pushing tags of the form 'v*'.


TZ_MEL: Final = ZoneInfo("Australia/Melbourne")
CHANGELOG_PATH: Final = Path("CHANGELOG.md")


def perform_git_branch_checks() -> None:
    status_output = subprocess.check_output(("git", "status", "--porcelain"), text=True)
    if status_output:
        print("There are uncommitted changes in this repository. This script will not commit changelog or other updates for you.")
        sys.exit(1)

    # We don't push commits. We expect the current commit to have already been pushed, and a successful
    # CI build run. If the current branch hasn't even been pushed, attempting to retrieve the latest
    # pushed commit for the current brnch will fail. Therefore, we need to check to see if the branch
    # has been pushed first, before attempting to get the latest pushed commit.
    current_branch = subprocess.check_output(("git", "rev-parse", "--abbrev-ref", "HEAD"), text=True).strip()

    try:
        subprocess.check_call(
            ("git", "rev-parse", f"refs/remotes/origin/{current_branch}"),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.CalledProcessError:
        print("It looks like this branch has not been pushed to the remote.")
        print("All changes must be pushed to the remote first, and a successful CI build run.")
        sys.exit(1)

    # This gets the hash of the latest pushed commit on the current branch.
    latest_pushed_commit = subprocess.check_output(("git", "rev-parse", f"refs/remotes/origin/{current_branch}"), text=True).strip()

    # This checks to see if the latest commit on the current branch has been pushed.
    try:
        subprocess.check_call(
            ("git", "merge-base", "--is-ancestor", "HEAD", latest_pushed_commit),
        )
    except subprocess.CalledProcessError:
        print("There are unpushed changes on this branch.")
        print("All changes must be pushed to the remote first, and a successful CI build run.")
        sys.exit(1)


def prompt_for_version() -> Version:
    print("Version numbers must be compatible with PEP440: https://packaging.python.org/en/latest/specifications/version-specifiers/")
    print("Please enter a version number (eg. '1.2.3'):")

    version = None
    while not version:
        raw_version = input("> ")
        try:
            version = parse_version(raw_version)
        except InvalidVersion:
            print("Invalid version entered.")

    return version


def check_for_correct_changelog_entry(tag: str) -> None:
    changelog = CHANGELOG_PATH.read_text(encoding="utf-8")

    version_line_start_escaped = re.escape(f"## {tag}")
    version_line_match = re.search(rf"^{version_line_start_escaped} - (?P<date>\d{{4}}-\d{{2}}-\d{{2}})$", changelog, re.MULTILINE)
    if not version_line_match:
        raise Exception(f"No changelog entry found for {tag}.")

    changelog_entry_date = version_line_match.group("date")

    today = datetime.now(tz=TZ_MEL)
    today_str = today.strftime("%Y-%m-%d")
    if changelog_entry_date != today_str:
        raise Exception(
            f"Changelog entry date for {tag} ({changelog_entry_date}) is not today ({today_str}).",
        )

    changelog_entry_match = re.search(fr"({version_line_start_escaped} - .*?)(\#\# .*|$)", changelog, re.DOTALL)
    if not changelog_entry_match:
        raise Exception(f"Full changelog entry not found for {tag}.")

    print("Does this changelog entry look correct?\n")
    print(changelog_entry_match.group(1))
    result = input("[y/n] ")
    if result != "y":
        sys.exit(1)


def tag_and_push(tag: str) -> None:
    subprocess.check_call(("git", "tag", tag))
    subprocess.check_call(("git", "push", "origin", f"refs/tags/{tag}"))


def main() -> None:
    perform_git_branch_checks()

    version = prompt_for_version()
    tag = f"v{version}"

    if not version.is_prerelease:
        # We don't currently require changelog entries for pre-releases.
        check_for_correct_changelog_entry(tag)

    tag_and_push(tag)


if __name__ == "__main__":
    main()
