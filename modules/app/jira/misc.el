;;; app/jira/misc.el -*- lexical-binding: t; -*-

;; Recognize Jira issues
(setq bug-reference-url-format "https://jira.opensynergy.com/browse/%s")
(setq bug-reference-bug-regexp "\\(\\)\\(COQOS-[0-9]+\\|HV-[0-9]+\\)")

;;
;;
(with-eval-after-load "git-commit"
  (add-to-list 'git-commit-setup-hook 'bug-reference-mode))
