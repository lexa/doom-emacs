;;; app/jira/func.el -*- lexical-binding: t; -*-

(defvar opsy-org-jira-active-task nil)

(setq jiralib-url "https://jira.opensynergy.com")
(setq org-jira-working-dir "~/org/jira/")

(defun opsy-org-jira-clock-out ()
  "Stop org clocks and update a worklog"
  (interactive)
  (when opsy-org-jira-active-task
    (when (derived-mode-p 'org-agenda-mode)
      (let* ((marker (org-get-at-bol 'org-marker))
             (buf (marker-buffer marker))
             (pos (marker-position marker))
             )
        (with-current-buffer buf
          (goto-char pos)
          (org-jira-update-worklogs-from-org-clocks))))

    (when (derived-mode-p 'org-mode)
      (org-jira-update-worklogs-from-org-clocks))
    (setq opsy-org-jira-active-task nil)))

(defun opsy-git-add-context ()
  (interactive)
  (require 'cl-lib)
  (let ((context
         (cl-remove-duplicates
          (cl-loop
           for filename in (magit-staged-files)
           for context = (directory-file-name  (or (file-name-directory filename) filename))
           collect context
           )
         :test 'string-equal
         )))
    (while (re-search-forward "<context>" nil t)
      (replace-match (string-join context ",")))
    (forward-char 1) ; Move one char forward to put cusor in more convenient position
    ))

(defun opsy-org-jira-update-current-issue ()
  (interactive)
  (when opsy-org-jira-active-task
    (save-excursion
      (when (search-forward "Issue:" nil t)

        (let* ((eol (save-excursion (end-of-line) (point)))
               (issue-list (split-string (buffer-substring-no-properties (point) eol) "[ \f\t\n\r\v,]+" t)))

          (setq issue-list (cl-remove-duplicates
                            (append issue-list (list opsy-org-jira-active-task))
                            :test 'string-equal
                            ))
          (kill-region (point) eol)
          (insert " ")
          (insert (string-join issue-list ", "))
          )))))


(defun opsy-org-jira-insert-active-task ()
  (interactive)
  (if opsy-org-jira-active-task
      (insert opsy-org-jira-active-task)
    (error "No org jira active task")
    ))

(defun opsy-org-jira-set-active-task (mark)
  (interactive
   (let* ((mark
           (or
            (cond
             ((derived-mode-p 'org-agenda-mode)  (org-get-at-bol 'org-marker))
             ((derived-mode-p 'org-mode)   (point-marker))
             )
            (save-excursion (call-interactively 'org-jira-get-issue) (point-marker)) ;;read the issue id and fetch it from the server
            ))
          )
     (list mark)))
  (require 'org-jira)
  (with-current-buffer (marker-buffer mark)
    (print mark)
    (goto-char mark)
    (org-clock-in)
    (setq opsy-org-jira-active-task (org-jira-get-from-org 'issue 'key))))

