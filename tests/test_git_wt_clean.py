"""Exercise git-wt-clean only in disposable, local Git repositories."""
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CleanupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="wt-clean-test-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / "primary"
        self.wt = self.root / "feature worktree"
        self.branch = "feature/example"
        self.env = os.environ.copy()
        for key in list(self.env):
            if key.startswith("GIT_"):
                del self.env[key]
        home = self.root / "home"
        home.mkdir()
        empty = self.root / "empty"
        empty.mkdir()
        self.env.update(
            HOME=str(home),
            PATH=str(ROOT / "bin") + os.pathsep + self.env.get("PATH", ""),
            GIT_CONFIG_NOSYSTEM="1",
            GIT_CONFIG_GLOBAL=os.devnull,
            GIT_CONFIG_COUNT="3",
            GIT_CONFIG_KEY_0="core.hooksPath",
            GIT_CONFIG_VALUE_0=str(empty),
            GIT_CONFIG_KEY_1="init.templateDir",
            GIT_CONFIG_VALUE_1=str(empty),
            GIT_CONFIG_KEY_2="commit.gpgSign",
            GIT_CONFIG_VALUE_2="false",
        )
        self.git("init", "-b", "main", str(self.repo), cwd=self.root)
        (self.repo / "README").write_text("original\n")
        (self.repo / ".gitignore").write_text(".venv/\n")
        self.git("add", "README", ".gitignore")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                 "commit", "-m", "fixture")
        self.git("worktree", "add", "-b", self.branch, str(self.wt))

    def git(self, *args, cwd=None, check=True):
        return subprocess.run(["git", *args], cwd=cwd or self.repo, env=self.env,
                              text=True, capture_output=True, check=check)

    def command(self, *args, answer="y\n", cwd=None):
        return subprocess.run(["git", "wt-clean", *args],
                              cwd=cwd or self.repo, env=self.env,
                              input=answer, text=True, capture_output=True, check=False)

    def branch_exists(self, branch=None):
        return self.git("show-ref", "--verify", "--quiet",
                        "refs/heads/" + (branch or self.branch), check=False).returncode == 0

    def assert_preserved(self):
        self.assertTrue(self.wt.is_dir())
        self.assertTrue(self.branch_exists())

    def test_confirmed_cleanup_removes_both(self):
        result = self.command(self.branch)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.wt.exists())
        self.assertFalse(self.branch_exists())
        self.assertNotIn(str(self.wt), self.git("worktree", "list", "--porcelain").stdout)

    def test_ignored_environment_is_disclosed_and_removed_after_confirmation(self):
        (self.wt / ".venv").mkdir()
        (self.wt / ".venv/marker").write_text("generated fixture\n")
        result = self.command(self.branch)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn(".venv/", result.stdout)
        self.assertIn("忽略", result.stdout)
        self.assertFalse(self.wt.exists())
        self.assertFalse(self.branch_exists())

    def test_tracked_changes_block_cleanup(self):
        (self.wt / "README").write_text("do not lose this\n")
        result = self.command(self.branch)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("未提交", result.stderr)
        self.assert_preserved()
        self.assertEqual((self.wt / "README").read_text(), "do not lose this\n")

    def test_untracked_files_block_cleanup(self):
        (self.wt / "notes.txt").write_text("keep\n")
        result = self.command(self.branch)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("未跟踪", result.stderr)
        self.assert_preserved()

    def test_main_is_protected(self):
        result = self.command("main")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("保护", result.stderr)
        self.assertTrue(self.repo.is_dir())
        self.assertTrue(self.branch_exists("main"))

    def test_main_case_variant_is_rejected_without_deleting_branch(self):
        result = self.command("MAIN")
        self.assertTrue(self.branch_exists("main"), result.stdout + result.stderr)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("确认删除", result.stdout)
        self.assert_preserved()

    def test_checked_out_branch_case_variant_is_rejected(self):
        result = self.command("Feature/Example")
        self.assertTrue(self.branch_exists(), result.stdout + result.stderr)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("确认删除", result.stdout)
        self.assert_preserved()

    def test_primary_worktree_is_protected_on_a_feature_branch(self):
        self.git("switch", "-c", "feature/primary")
        result = self.command("feature/primary")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("主工作树", result.stderr)
        self.assertTrue(self.repo.is_dir())
        self.assertTrue(self.branch_exists("feature/primary"))

    def test_declining_keeps_everything(self):
        result = self.command(self.branch, answer="n\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("取消", result.stdout)
        self.assert_preserved()

    def test_eof_keeps_everything(self):
        result = self.command(self.branch, answer="")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_preserved()

    def test_running_inside_target_is_rejected(self):
        result = self.command(self.branch, cwd=self.wt)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("目录外", result.stderr)
        self.assert_preserved()

    def test_already_removed_worktree_still_allows_branch_cleanup(self):
        self.git("worktree", "remove", str(self.wt))
        result = self.command(self.branch)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.branch_exists())

    def test_locked_worktree_is_not_forced(self):
        self.git("worktree", "lock", str(self.wt))
        result = self.command(self.branch)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("锁定", result.stderr)
        self.assert_preserved()

    def test_missing_branch_is_an_error(self):
        result = self.command("feature/nonexistent")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("不存在", result.stderr)
        self.assert_preserved()

    def test_wrong_arguments_do_not_delete_anything(self):
        result = self.command()
        self.assertNotEqual(result.returncode, 0)
        self.assert_preserved()


if __name__ == "__main__":
    unittest.main(verbosity=2)
