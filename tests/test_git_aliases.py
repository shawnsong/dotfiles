"""Check shared Git aliases without executing real Git operations."""
import os
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("zsh"), "zsh is required for alias checks")
class GitAliasTests(unittest.TestCase):
    def test_ghwc_forwards_arguments_and_preserves_existing_aliases(self):
        script = r'''
source "$1" || exit 1
[[ ${aliases[ghwc]-} == 'git worktree-clean' ]] || {
  print -u2 'ghwc alias missing or incorrect'
  exit 1
}
[[ ${aliases[gibr]-} == 'git branch' ]] || exit 1
[[ ${aliases[gicm]-} == git_commit ]] || exit 1
git() { printf '%s\n' "$@"; }
eval 'ghwc "$2"'
'''
        result = subprocess.run(
            ["zsh", "-fc", script, "--", str(ROOT / "zsh/.alias"), "feature/example"],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.splitlines(), ["worktree-clean", "feature/example"])

    def test_long_command_dispatches_to_existing_cleanup_helper(self):
        env = os.environ.copy()
        env["PATH"] = str(ROOT / "bin") + os.pathsep + env.get("PATH", "")
        result = subprocess.run(
            ["git", "worktree-clean", "-h"], cwd=ROOT, env=env,
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("usage:", result.stdout)
        self.assertEqual((ROOT / "bin/git-worktree-clean").resolve(),
                         (ROOT / "bin/git-wt-clean").resolve())


if __name__ == "__main__":
    unittest.main(verbosity=2)
