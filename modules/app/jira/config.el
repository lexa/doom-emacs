;;; app/jira/config.el -*- lexical-binding: t; -*-

(load! "func.el")

(def-package! browse-at-remote
  :command #'browse-at-remote
  :config
  (add-to-list 'browse-at-remote-remote-type-domains '("stash.opensynergy.com" . "stash")))

(map! :leader
      (:prefix ("j" . "Jira/Stash")
        "j" #'+jira-open-at-point
        "b" #'browse-at-remote))
