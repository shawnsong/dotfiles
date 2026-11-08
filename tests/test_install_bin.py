"""Install the repository's Git helper into a disposable HOME."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class InstallBinTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="dotfiles-bin-test-")
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.env = os.environ.copy()
        self.env["HOME"] = str(self.home)
        self.target = self.home / ".local/bin/git-wt-clean"
        self.source = ROOT / "bin/git-wt-clean"

    def install(self, root=ROOT):
        return subprocess.run(["bash", str(root / "install-bin.sh")],
                              cwd=self.home, env=self.env, text=True,
                              capture_output=True, check=False)

    def test_installs_a_link_to_repository_source(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual(self.target.resolve(), self.source.resolve())
        self.assertTrue(os.access(self.target, os.X_OK))
        long_target = self.target.with_name("git-worktree-clean")
        self.assertTrue(long_target.is_symlink())
        self.assertEqual(long_target.resolve(), self.source.resolve())

    def test_long_command_conflict_does_not_partially_install(self):
        self.target.parent.mkdir(parents=True)
        long_target = self.target.with_name("git-worktree-clean")
        long_target.write_text("unrelated command\n")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.exists())
        self.assertEqual(long_target.read_text(), "unrelated command\n")

    def test_migrates_identical_copy_and_can_be_rerun(self):
        self.target.parent.mkdir(parents=True)
        shutil.copy2(self.source, self.target)
        expected = self.target.read_bytes()
        backup = self.target.with_name("git-wt-clean.pre-dotfiles")
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual(self.target.resolve(), self.source.resolve())
        self.assertEqual(backup.read_bytes(), expected)
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(backup.read_bytes(), expected)

    def test_refuses_different_existing_file(self):
        self.target.parent.mkdir(parents=True)
        self.target.write_text("do not replace\n")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_text(), "do not replace\n")

    def test_refuses_broken_symlink(self):
        self.target.parent.mkdir(parents=True)
        self.target.symlink_to(self.home / "missing")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual(os.readlink(self.target), str(self.home / "missing"))

    def test_refuses_to_overwrite_existing_backup(self):
        self.target.parent.mkdir(parents=True)
        shutil.copy2(self.source, self.target)
        backup = self.target.with_name("git-wt-clean.pre-dotfiles")
        backup.write_text("older backup\n")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_bytes(), self.source.read_bytes())
        self.assertEqual(backup.read_text(), "older backup\n")

    def test_repository_path_with_spaces(self):
        root = self.home / "repo with spaces"
        shutil.copytree(ROOT / "bin", root / "bin")
        shutil.copy2(ROOT / "install-bin.sh", root / "install-bin.sh")
        result = self.install(root=root)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.target.resolve(), (root / "bin/git-wt-clean").resolve())


if __name__ == "__main__":
    unittest.main(verbosity=2)
