;;; email/gnus/config.el -*- lexical-binding: t; -*-

(defun +shr-no-colourise-region (&rest ignore))

(def-package! shr
  :config
  ;; Do not colorize html text
  (setq shr-use-colors nil)
  (setq shr-color-visible-luminance-min 80)
  (advice-add #'shr-colorize-region :around #'+shr-no-colourise-region))
