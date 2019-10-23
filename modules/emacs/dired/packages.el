;; -*- no-byte-compile: t; -*-
;;; emacs/dired/packages.el

(package! diredfl)
(package! dired-k)
(package! dired-rsync)
(package! dired-git-info)
(when (featurep! +ranger)
  (package! ranger))
(when (featurep! +icons)
  (package! all-the-icons-dired))
