;; -*- no-byte-compile: t; -*-
;;; app/jira/packages.el

(package! browse-at-remote)
(package! request)

(load! "func.el")

(add-hook 'org-clock-out-hook 'opsy-org-jira-clock-out)
(add-hook 'git-commit-mode-hook 'opsy-org-jira-update-current-issue)
(add-hook 'git-commit-mode-hook 'opsy-git-add-context)
(global-set-key (kbd "C-c i") #'opsy-org-jira-insert-active-task)
