;;; app/jira/stash.el -*- lexical-binding: t; -*-

;;; Code:

(defconst +stash-api-entry-point "https://stash.opensynergy.com/rest/api/1.0")
(defconst +auth-headers '(("Authorization" . "Basic YWZlOmNocGhlaTdjIiNlOXVHaDU=")))

(defun do-stash-request (api &rest args)
  (apply #'request (concat +stash-api-entry-point api)
         :headers +auth-headers
         :parser 'json-read
         args))

(setq request-log-level 'debug)

(defun +stash-get-inbox ()
  (interactive)
  (lexical-let ((buf (current-buffer)))
     (do-stash-request "/inbox/pull-requests"
                       :sync t
                       :complete (cl-function (lambda (&key error-thrown &allow-other-keys)
                                                (message "Error thrown: %S" error-thrown)))
                      :success (cl-function
                                (lambda (&key data &allow-other-keys)
                                  (let ((debug-on-error t))
                                    (message "%S" buf)
                                    (with-current-buffer buf
                                      (message "ZZZ %S" buf)
                                      (let* ((inhibit-read-only t))
                                        (message "BBB %S" buf)
                                        (erase-buffer)
                                        (insert (format "%S" data))
                                        ;(print data)
                                        )
                                      ))))
                      )
    ))

(define-derived-mode stash-mode fundamental-mode "StashInbox"
  "Major mode for infix argument popups."
  :mode 'stash-mode
  (setq truncate-lines t)
  (setq buffer-read-only t)
  (setq-local scroll-margin 0))

(define-key stash-mode-map (kbd "g") #'+stash-get-inbox)
