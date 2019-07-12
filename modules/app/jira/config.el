;;; app/jira/config.el -*- lexical-binding: t; -*-

(load! "func.el")

(def-package! browse-at-remote
  :commands browse-at-remote
  :config
  (add-to-list 'browse-at-remote-remote-type-domains '("stash.opensynergy.com" . "stash")))

(def-package! request
  :commands request)

(map! :leader
      (:prefix ("j" . "Jira/Stash")
        "b" #'browse-at-remote))
