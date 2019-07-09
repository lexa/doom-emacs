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

(defvar stash-repository-alist '())

(defclass stash-repository ()
  ((path :initarg :path)
   (remotes :initarg :remotes)))

(defun git-remotes-href ()
  (mapcar
   (lambda (remote-name) (magit-get (format "remote.%s.url" remote-name)))
   (magit-list-remotes)))

(defun make-stash-repository-object (path)
  (let ((default-directory path))
    (stash-repository
     :path path
     :remotes (git-remotes-href))))

(setq stash-repository-alist
      (list
       (make-stash-repository-object ".")
       (make-stash-repository-object "/home/lexa/tmp/rest-api-sandbox")
       ))

(defun find-repos-by-href (href)
  (find href stash-repository-alist
        :key (lambda (x) (oref x remotes))
        :test (lambda (href remotes) (find href remotes :test #'string-equal))))

(defun map-any (func seq)
  (if (null seq)
      nil
    (let ((ret (funcall func (car seq))))
    (if ret
        ret
      (map-any func (cdr seq))))))

(defun json-get1 (json accessors)
  (cond
   ((null accessors) json)
   (t (let ((sub (alist-get (car accessors) json)))
        (cond
         ((vectorp sub) (mapcar (lambda (x) (json-get1 x (cdr accessors))) sub))
          (t (json-get1 sub (cdr accessors))))))))

(defun json-get (json &rest accessors)
  (json-get1 json accessors))



(cl-defun stash-open-review (pr)
  (let* ((hrefs (json-get pr 'fromRef 'repository 'links 'clone 'href))
         (repo (map-any #'find-repos-by-href hrefs)))
    (message "working on pr %S %S" hrefs repo)))

(cl-defun stash-update-buffer-callback (&key data &allow-other-keys)
  (let* ((inhibit-read-only t))
    (erase-buffer)
    (mapc (lambda (pr)
            (let* ((stash-id (alist-get 'id pr))
                   (title (alist-get 'title pr))
                   (line (format "%3d:%S\n" stash-id title)))
              (insert-text-button line
                             'action (lambda (&rest args) (stash-open-review pr))
                             )))
          (alist-get 'values data))
    )
  )

(require 'request)
(defun +stash-get-inbox ()
  (interactive)
  (lexical-let ((buf (current-buffer)))
    (do-stash-request "/inbox/pull-requests"
                      :sync t
                      :success (cl-function
                                (lambda (&rest args)
                                  (let ((debug-on-error t))
                                    (with-current-buffer buf
                                      (apply #'stash-update-buffer-callback args)
                                      ))
                      )
    ))))

(define-derived-mode stash-mode fundamental-mode "StashInbox"
  "Major mode for infix argument popups."
  :mode 'stash-mode
  (setq truncate-lines t)
  (setq buffer-read-only t)
  (setq-local scroll-margin 0))

(define-key stash-mode-map (kbd "g") #'+stash-get-inbox)
