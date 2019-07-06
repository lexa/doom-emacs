;;; app/jira/func.el -*- lexical-binding: t; -*-

(defconst +opsy-jira "https://jira.opensynergy.com/")

(defun +jira-open-at-point ()
  (interactive)
  (let ((issue (thing-at-point 'symbol)))
    (browse-url (concat +opsy-jira "browse/" issue))))

