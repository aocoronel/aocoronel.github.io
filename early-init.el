;; -*- lexical-binding: t; -*-

;; Enable to debug configuration
;; (setq debug-on-error t)

(defun my/display-startup-time ()
  "Display the startup time after Emacs initialization."
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'my/display-startup-time)

(setq-default
 gc-cons-threshold 35000000
 gc-cons-percentage 0.6
 read-process-output-max (* 4 1024 1024)
 process-adaptive-read-buffering nil
 byte-compile-warnings '(not obsolete)
 warning-suppress-log-types '((comp) (bytecomp))
 native-comp-async-report-warnings-errors 'silent
 warning-suppress-types '((lexical-binding))
 warning-minimum-level :error
 bidi-display-reordering 'left-to-right
 bidi-paragraph-direction 'left-to-right
 bidi-inhibit-bpa t
 inhibit-compacting-font-caches t
 inhibit-splash-screen t
 inhibit-startup-buffer-menu t
 inhibit-startup-echo-area-message user-login-name
 inhibit-startup-screen t
 inhibit-x-resources t
 initial-scratch-message nil
 ring-bell-function 'ignore
 load-prefer-newer t
 frame-inhibit-implied-resize 'force
 frame-resize-pixelwise t
 package-enable-at-startup nil
 hl-line-sticky-flag nil
 global-hl-line-sticky-flag nil
 initial-major-mode 'fundamental-mode
 gnutls-verify-error t
 tls-checktrust t
 gnutls-min-prime-bits 3072
 read-extended-command-predicate #'command-completion-default-include-p
 use-dialog-box nil
 use-file-dialog nil
 visible-bell nil)

(hl-line-mode 1)

(when (not (eq system-type 'android))
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (column-number-mode 1))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(advice-add 'display-startup-echo-area-message :override #'ignore)
(advice-add 'display-startup-screen :override #'ignore)
(advice-add 'tool-bar-setup :override #'ignore)

(set-language-environment "UTF-8")
(add-to-list 'default-frame-alist `(font . ,"JetBrainsMonoNL Nerd Font-12"))

;; The theme is available at https://codeberg.org/aocoronel/elegantvagrant
(when
  (file-readable-p "~/.emacs.d/elegantvagrant-theme.el") (load "~/.emacs.d/elegantvagrant-theme.el")
  (add-to-list 'custom-theme-load-path "~/.emacs.d/elegantvagrant-theme.el")
  (load-theme 'elegantvagrant t))
