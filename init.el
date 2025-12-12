;; -*- lexical-binding: t; -*-

;; C-x r SPC [l]
;; C-x r j [l]

; (require 'profiler)
; (profiler-start 'cpu)

(setenv "GIT_CONFIG_GLOBAL" (concat (getenv "HOME") "/.config/gitconfig"))
(setenv "GNUPGHOME" (concat (getenv "HOME") "/.config/gnupg"))

(add-to-list 'load-path "~/.emacs.d/user-lisp")

(require 'compile)
(require 'dired-x)
(require 'phi-search)
(require 'hide-comnt)
(require 'zoxide)
(require 'treesit)

(add-to-list 'treesit-language-source-alist '(odin "https://github.com/tree-sitter-grammars/tree-sitter-odin" "master" "src"))

(put 'downcase-region 'disabled nil)
(add-hook 'emacs-startup-hook #'global-auto-revert-mode)

(setq-default
 undo-limit (* 13 160000)
 undo-strong-limit (* 13 240000)
 undo-outer-limit (* 13 24000000)
 truncate-string-ellipsis "…"
 eval-expression-print-length nil
 eval-expression-print-level nil
 x-underline-at-descent-line t
 create-lockfiles nil
 make-backup-files t
 backup-directory-alist
 `(("." . ,(expand-file-name "backup" user-emacs-directory)))
 backup-by-copying-when-linked t
 backup-by-copying t
 delete-old-versions t
 version-control t
 kept-new-versions 5
 kept-old-versions 5

 epg-pinentry-mode 'loopback

 c-basic-offset 4
 c-default-style '((java-mode . "java")
                   (awk-mode . "awk")
                   (other . "bsd"))

 auto-save-default nil

 vc-git-print-log-follow t
 vc-make-backup-files nil
 vc-git-diff-switches '("--histogram")

 kept-old-versions 10
 kept-new-versions 10

 kill-buffer-delete-auto-save-files t
 kill-do-not-save-duplicates t

 revert-without-query (list ".")
 auto-revert-stop-on-user-input nil
 auto-revert-verbose t

 global-auto-revert-non-file-buffers t
 global-auto-revert-ignore-modes '(Buffer-menu-mode)

 auto-revert-interval 3
 auto-revert-remote-files nil
 auto-revert-use-notify t
 auto-revert-avoid-polling nil
 auto-revert-verbose t

 kill-region-dwim 'emacs-word
 delete-pair-push-mark t
 global-goto-address-mode t

 select-enable-clipboard t

 save-place-file (expand-file-name "saveplace" user-emacs-directory)
 save-place-limit 600
 history-length 300
 savehist-save-minibuffer-history t
 savehist-additional-variables
       '(kill-ring                        ; clipboard
         register-alist                   ; macros
         mark-ring global-mark-ring       ; marks
         search-ring regexp-search-ring) ; searches

 window-resize-pixelwise nil

 window-divider-default-bottom-width 1
       window-divider-default-places t
       window-divider-default-right-width 1

 redisplay-skip-fontification-on-input t

 fast-but-imprecise-scrolling t

 auto-window-vscroll nil

 cursor-in-non-selected-windows nil
 highlight-nonselected-windows nil

 global-text-scale-adjust-resizes-frames nil

 comment-multi-line t
 comment-empty-lines t

 sentence-end-double-space nil
 lazy-highlight-initial-delay 0

 enable-recursive-minibuffers t
 read-extended-command-predicate #'command-completion-default-include-p
 minibuffer-prompt-properties
 '(read-only t cursor-intangible t face minibuffer-prompt)

 ;; recentf
 recentf-max-saved-items 300 ; default is 20
 recentf-max-menu-items 15
 recentf-auto-cleanup 'mode
 recentf-exclude nil

 ;; Spelling
 ispell-program-name "aspell"
 ispell-dictionary "en_US"
 flyspell-issue-message-flag nil
 flyspell-issue-welcome-flag nil

 ;; Smooth scrolling
 scroll-conservatively 20
 hscroll-margin 10
 scroll-margin 30
 next-screen-context-lines 0

 ;; flymake
 flymake-no-changes-timeout 0.5
 flymake-start-on-save-buffer t
 flymake-start-on-flymake-mode t
 flymake-show-diagnostics-at-end-of-line nil
 flymake-wrap-around nil

 ;; proced
 proced-enable-color-flag t
 proced-tree-flag t
 proced-auto-update-flag 'visible
 proced-auto-update-interval 1
 proced-descend t
 proced-format 'medium
 proced-filter 'user

 ;; isearch
 isearch-wrap-pause 'no
 search-whitespace-regexp ".*?"
 isearch-lazy-count t
 lazy-count-prefix-format "%s/%s "
 lazy-count-suffix-format nil

 vc-follow-symlinks t

 project-vc-extra-root-markers '("build" ".gitignore" ".git/")

 find-file-visit-truename t

 ffap-machine-p-known 'reject

 org-startup-truncated nil
 org-agenda-files (directory-files-recursively "~/wiki/agenda/" "\\.org$")

 org-capture-templates
             '(("r" "Refile" plain (file+headline "~/wiki/agenda/refile.org" "Inbox")
                    "* %?\n  %i\n  %a")
                 ("t" "Task" plain (file+headline "~/wiki/agenda/refile.org" "Tasks")
                    "* TODO %?\n  %i\n  %a"))
 org-archive-location "~/wiki/agenda/archive::**"
 org-archive-file-header-format nil

 org-agenda-custom-commands
      '(("f" "find TODOs in file"
         (lambda (_arg)
           (let* ((file (completing-read "Org file: " org-agenda-files nil t))
                  (org-agenda-files (list file)))
             (org-todo-list))))
        ("b" "Today"
         tags "today")
        ("w" "Week"
         tags "week"))

 org-tag-alist
      '(("today"     . ?t)
        ("week"      . ?w)
        ("month"     . ?m)
        ("year"      . ?y))

 org-startup-folded t
 org-hide-leading-stars t
 org-auto-align-tags nil
 org-tags-column 0
 org-fold-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-use-sub-superscripts nil
 org-agenda-tags-column 0
 org-agenda-block-separator ?─
 org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "◀── now ─────────────────────────────────────────────────"

 webjump-sites
   '(("DuckDuckGo"     . [simple-query "https://www.duckduckgo.com" "https://www.duckduckgo.com/?q=" ""])
     ("Duckai"     . [simple-query "https://duck.ai" "https://duck.ai/?q=" ""])
     ("YouTube"        . [simple-query "https://www.youtube.com" "https://www.youtube.com/results?search_query=" ""])
     ("ChatGPT"        . [simple-query "https://chatgpt.com" "https://chatgpt.com/?q=" ""]))

 ;; compile-mode
 compilation-scroll-output t
 compilation-always-kill t
 ansi-color-for-compilation-mode t

 save-interprogram-paste-before-kill t
 auto-revert-remote-files nil
 auto-revert-use-notify t
 global-auto-revert-non-file-buffers t

 ;; show-paren-mode
 show-paren-delay 0.1
 show-paren-highlight-openparen t
 show-paren-when-point-inside-paren t
 show-paren-when-point-in-periphery t

 ;; completions
 read-file-name-completion-ignore-case t
 read-buffer-completion-ignore-case t
 completion-ignore-case t
 completions-detailed t

 delete-by-moving-to-trash nil
 kill-do-not-save-duplicates t

 redisplay-skip-fontification-on-input t
 register-use-preview t

 truncate-lines nil

 treesit-font-lock-level 4
 treesit-auto-install-grammar 'always
 treesit-enabled-modes t

 set-mark-command-repeat-pop t ;; repeat C-u C-SPAC C-SPC...

 display-line-numbers-type 'relative

 fill-column 100

 whitespace-line-column nil

 set-mark-command-repeat-pop t

 ;; tramp
 tramp-backup-directory-alist backup-directory-alist
 tramp-auto-save-directory
       (expand-file-name "tramp-autosave/" user-emacs-directory)
 tramp-default-method "ssh"
 tramp-auto-save-directory "/tmp"
 tramp-verbose 1
 tramp-default-remote-shell "/bin/bash"
 tramp-completion-reread-directory-timeout 50

 ;; tabs
 tab-always-indent 'complete
 tab-width 4
 indent-tabs-mode nil

 ;; grep
 grep-command "grep -rn "
 grep-find-ignored-directories
 '(".git" "build")

 ;; dired
 wdired-create-parent-directories t
 dired-omit-files (concat dired-omit-files "\\|^\\..+$")
 dired-dwim-target t
 dired-listing-switches "-alh"
 dired-mouse-drag-files t
 dired-free-space nil
 dired-dwim-target t  ; Propose a target for intelligent moving/copying
 dired-deletion-confirmer 'y-or-n-p
 dired-filter-verbose nil
 dired-recursive-deletes 'top
 dired-recursive-copies 'always
 dired-vc-rename-file t
 dired-create-destination-dirs 'ask
 dired-kill-when-opening-new-dired-buffer t
 dired-listing-switches "--group-directories-first -ahlv"
 dired-clean-confirm-killing-deleted-buffers nil
 dired-auto-revert-buffer 'dired-buffer-stale-p
 dired-omit-files
 (concat "\\|^__pycache__\\'"
         "\\|^\\.project\\(?:ile\\)?\\'"
         "\\|^flycheck_.*"
         "\\|^flymake_.*")
 ls-lisp-verbosity nil
 ls-lisp-dirs-first t

 ibuffer-human-readable-size t
 use-short-answers t
 read-answer-short t)

(blink-cursor-mode 0)
(delete-selection-mode 1)
(delete-trailing-whitespace-mode 1)
(global-auto-revert-mode 1)
(global-display-fill-column-indicator-mode)
(recentf-mode 1)
(repeat-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(show-paren-mode 1)
(winner-mode 1)
; (electric-pair-mode 1)
;; (global-display-line-numbers-mode)

(require 'tramp)
(tramp-set-completion-function
 "ssh" (append (tramp-get-completion-function "ssh")
               (mapcar (lambda (file) `(tramp-parse-sconfig ,file))
                       (directory-files
                        "~/.ssh/"
                        'full directory-files-no-dot-files-regexp))))

(defun rc/modeline-region-lines ()
  (when (use-region-p)
    (format " %d lines" (count-lines (region-beginning) (region-end)))))

(setq-default mode-line-format (append mode-line-format
                      '((:eval (rc/modeline-region-lines)))))

(defvar audio-extensions      (make-hash-table :test 'equal))
(defvar external-extensions   (make-hash-table :test 'equal))

(defun register-extension (table extensions)
    (dolist (ext extensions) (puthash ext t table)))

(register-extension external-extensions
                    '("mp4" "mkv" "webm" "gif" "docx" "odt" "doc"))
(register-extension audio-extensions
                    '("mp3" "opus" "wav" "flac" "ogg" "m4a" "aac" "wma"))


(defun dired-smart-open ()
    (interactive)
    (let* ((filename (dired-get-filename)) (ext (file-name-extension filename)))
        (cond
         ((gethash ext audio-extensions)
            (emms-play-file filename))
         ((gethash ext external-extensions)
            (start-process "xdg-open" nil "xdg-open" filename))
         (t (dired-find-file)))))

(define-key dired-mode-map (kbd "RET") #'dired-smart-open)

(when nil
  (setq ; Which-key is only useful for discoverability
   which-key-separator "  "
   which-key-prefix-prefix "... "
   which-key-idle-delay 1.0
   which-key-idle-secondary-delay 0.25
   which-key-add-column-padding 1
   which-key-max-description-length 40
   which-func-update-delay 1.0)
  (which-key-mode 1))

(defun emacs-solo/dired-rsync-copy (dest)
  "Copy marked files in Dired to DEST using rsync in an async shell buffer."
  (interactive
   (list (expand-file-name (read-file-name "rsync to: "
                                           (dired-dwim-target-directory)))))
  (let* ((files (dired-get-marked-files nil current-prefix-arg))
         (dest-original dest)
         (dest-rsync
          (if (file-remote-p dest)
              (let* ((vec (tramp-dissect-file-name dest))
                     (user (tramp-file-name-user vec))
                     (host (tramp-file-name-host vec))
                     (path (tramp-file-name-localname vec)))
                (concat (if user (concat user "@") "")
                        host
                        ":"
                        path))
            dest))
         (files-rsync
          (mapcar
           (lambda (f)
             (if (file-remote-p f)
                 (let ((vec (tramp-dissect-file-name f)))
                   (let ((user (tramp-file-name-user vec))
                         (host (tramp-file-name-host vec))
                         (path (tramp-file-name-localname vec)))
                     (concat (if user (concat user "@") "")
                             host ":" path)))
               f))
           files))
         (command (append '("rsync" "-hPur") files-rsync (list dest-rsync)))
         (buffer (get-buffer-create "*rsync*")))

    (message ">>> rsync original dest %s" dest-original)
    (message ">>> rsync converted dest %s" dest-rsync)
    (message ">>> rsync source files %s" files-rsync)
    (message ">>> rsync command %s" (string-join command " "))

    (with-current-buffer buffer
      (erase-buffer)
      (insert "Running rsync...\n"))

    (defun rsync-process-filter (proc string)
      (with-current-buffer (process-buffer proc)
        (goto-char (point-max))
        (insert string)
        (goto-char (point-max))
        (while (re-search-backward "\r" nil t)
          (replace-match "\n" nil nil))))

    (make-process
     :name "dired-rsync"
     :buffer buffer
     :command command
     :filter #'rsync-process-filter
     :sentinel
     (lambda (_proc event)
       (when (string-match-p "finished" event)
         (with-current-buffer buffer
           (goto-char (point-max))
           (insert "\n* rsync done *\n"))
         (dired-revert)))
     :stderr buffer)

    (display-buffer buffer)
    (message ">>> rsync started...")))

;; https://stackoverflow.com/questions/23207938/in-emacs-how-to-enable-automatic-hiding-of-dired-details
(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(defun org-agenda-todos-from-file ()
  (interactive)
  (let* ((file (completing-read
                "Org file: "
                org-agenda-files
                nil
                t))
         (org-agenda-files (list file)))
    (org-todo-list)))

(defun rc/turn-on-eldoc-mode () (interactive) (eldoc-mode 1))
(add-hook 'elisp-mode-hook 'rc/turn-on-eldoc-mode)

; https://www.rahuljuliato.com/posts/abbrev-mode
(defun emacs-solo/abbrev--replace-placeholders ()
  (let ((cursor-pos nil))
    (save-excursion
      (goto-char (point-min))
      (let ((loop 0)
            (values (make-hash-table :test 'equal)))
        (while (re-search-forward "$\\([0-9]+\\|@\\)" nil t)
          (setq loop (1+ loop))
          (let* ((index (match-string 1))
                  (start (match-beginning 0))
                  (end (match-end 0)))
            (cond
              ((string= index "@")
              (setq cursor-pos start)
              (delete-region start end))
              (t
              (let* ((key (format "$%s" index))
                      (val (or (gethash key values)
                              (let ((input (read-string (format "Value for %s: " key))))
                                (puthash key input values)
                                input))))
                (goto-char start)
                (delete-region start end)
                (insert val)
                (goto-char (+ start (length val))))))))))
    (when cursor-pos
      (goto-char cursor-pos))))

(defun rc/abbrev-goto ()
  (search-backward "@")
  (delete-char 1))

(define-abbrev-table 'org-mode-abbrev-table
  '(("ua" "↑")
    ("da" "↓")
    ("b" "#+BEGIN_SRC @\n\n#+END_SRC" rc/abbrev-goto)))

(define-abbrev-table 'odin-ts-mode-abbrev-table
  '(("main" "main :: proc() {\n    @\n    return\n}" rc/abbrev-goto)))

(define-abbrev-table 'simpc-mode-abbrev-table
  '(("main" "int main(int argc, char *argv[]) {\n    @\n    return 0;\n}" rc/abbrev-goto)))

(define-abbrev-table 'html-mode-abbrev-table
  '(("t" "<$1>$@</$1>" emacs-solo/abbrev--replace-placeholders)))

(defun emacs-solo/sudo-edit (&optional arg)
    "Edit currently visited file as root.
With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
    (interactive "P")
    (if (or arg (not buffer-file-name))
        (find-file (concat "/sudo:root@localhost:"
                           (read-file-name "Find file (as root): ")))
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun rc/isearch-region ()
  (interactive)
  (if (use-region-p)
      (let ((string (buffer-substring-no-properties
                     (region-beginning)
                     (region-end))))
        (deactivate-mark)
        (isearch-resume string nil nil t string nil))
    (isearch-forward)))

(defun rc/set-keys (&rest bindings)
  (dolist (binding bindings)
    (global-set-key (kbd (car binding)) (cdr binding))))

(defun rc/unset-keys (&rest bindings)
  (dolist (binding bindings)
    (keymap-global-unset binding)))

(defun android-browse-url (url unused)
    (interactive "sURL: ")
    (start-process "xdg-open" nil "xdg-open" url))

(defun markdown-join-wrapped-lines (beg end)
  "This acts like join-line, but uses the initial bullet point as the starting point"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)

      (goto-char (point-min))

      (let ((in-code-block nil))
        (while (not (eobp))
          (let ((line1 (buffer-substring-no-properties
                        (line-beginning-position)
                        (line-end-position))))

            (when (string-match-p "^```" line1)
              (setq in-code-block (not in-code-block)))

            (unless (= (line-end-position) (point-max))
              (let ((line2
                     (save-excursion
                       (forward-line 1)
                       (buffer-substring-no-properties
                        (line-beginning-position)
                        (line-end-position)))))

                (when (and (not in-code-block)
                           (not (string-match-p "^\\s-*$" line1))
                           (not (string-match-p "^\\s-*$" line2))
                           (not (string-match-p
                                 "^\\s-*\\(?:[-*+]\\s-\\|[0-9]+\\.\\s-\\|#\\|```\\)"
                                 line2)))

                  (end-of-line)
                  (delete-char 1)
                  (just-one-space)
                  (forward-line -1)))))

          (forward-line 1))))))

(defun my/scroll-down ()
  (interactive)
  (next-line 20))

(defun my/scroll-up ()
  (interactive)
  (previous-line 20))

(defun kill-all-other-buffers ()
  "Kill all buffers except the current one."
  (interactive)
  (mapc #'kill-buffer (delq (current-buffer) (buffer-list))))

(defun surround-with-next-char (beg end)
  "Surround the region from BEG to END with the next input character on both sides."
  (interactive "r")
  (let ((char (read-char "Enter surround char: ")))
    (goto-char beg)
    (insert char)
    (goto-char (1+ end))
    (insert char)
    (goto-char (+ beg 1))))

(defun rc/open-eshell-here ()
  "Open Eshell in the current buffer's directory."
  (interactive)
  (let ((default-directory
     (or
      (and
       (buffer-file-name)
           (file-name-directory (buffer-file-name)))
          default-directory)))
    (eshell t)))

(defun rc/increment-numbers-region (start end)
  (interactive "r")
  (let ((n 0))
    (save-excursion
      (goto-char start)
      (beginning-of-line)
      (while (< (point) end)
        (when (re-search-forward "\\[[0-9]+\\]" (line-end-position) t)
          (replace-match (format "[%d]" n))
          (setq n (1+ n)))
        (forward-line 1)))))

(defun backward-mark-word (arg)
  (interactive "p")
  (unless (eq last-command this-command) (set-mark (point)))
  (backward-word arg)
  (setq deactivate-mark nil))

;; http://stackoverflow.com/questions/2416655/file-path-to-clipboard-in-emacs
(defun rc/put-file-name-on-clipboard ()
  "Put the current file name on the clipboard"
  (interactive)
  (let ((filename
     (if (equal major-mode 'dired-mode)
         default-directory
       (buffer-file-name))))
    (when filename (kill-new filename) (message filename))))

(defun rc/put-buffer-name-on-clipboard ()
  "Put the current buffer name on the clipboard"
  (interactive)
  (kill-new (buffer-name))
  (message (buffer-name)))

(defun rc/kill-buffers-matching (pattern)
  "Kill all buffers whose names match the given regexp PATTERN."
  (interactive "sBuffers to kill (regexp): ")
  (dolist (buffer (buffer-list))
    (let ((name (buffer-name buffer)))
      (when (and name (string-match-p pattern name))
        (kill-buffer buffer)
        (message "Killed buffer %s" name))))
  (message "Killed buffers matching %s" pattern))

;; http://ergoemacs.org/emacs/emacs_unfill-paragraph.html
(defun rc/unfill-paragraph ()
  "Replace newline chars in current paragraph by single spaces.
This command does the inverse of `fill-paragraph'."
  (interactive)
  (let ((fill-column 90002000)) (fill-paragraph nil)))

(defun rc/insert-timestamp ()
  (interactive)
  (insert (format-time-string "%Y%m%d-%H%M%S" nil t)))

(defun rc/rgrep-selected (beg end)
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-min))))
  (rgrep (buffer-substring-no-properties beg end) "*" (pwd)))

;; === Packages ===

(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Tsoding's rc/require (https://github.com/rexim/dotfiles/)
(defvar rc/package-contents-refreshed nil)
;; Packages not in this list will be removed automatically
(defvar rc/required-packages nil)

(defun rc/package-refresh-contents-once ()
  (when (not rc/package-contents-refreshed)
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))

(defun rc/require-one-package (package)
  (when (not (package-installed-p package))
    (rc/package-refresh-contents-once)
    (package-install package)))

(defun rc/require (&rest packages)
  (dolist (package packages)
    (add-to-list 'rc/required-packages package)
    (rc/require-one-package package)))

(cond ((eq system-type 'windows-nt) (rc/require 'cl-lib)))

(unless (eq system-type 'android)
  (rc/require 'pdf-tools))

(rc/require
 'buffer-terminator
 'calfw
 'calfw-org
 'corfu 'cape
 'elfeed
 'embark
 'emms
 'expreg
 'ledger-mode
 'magit
 'move-text
 'multiple-cursors
 'orderless
 'org-roam
 'rainbow-mode
 'reformatter
 'undo-fu
 'vertico)

(vertico-mode)
(define-key vertico-map (kbd "C-.") #'embark-act)

(global-set-key (kbd "C-.") #'embark-act)
(global-set-key (kbd "C-^") #'embark-act)

;; Every 5 minutes kill inactives buffers
;; Buffers get inactive after 10 minutes
(setq
 buffer-terminator-verbose nil
 buffer-terminator-inactivity-timeout (* 10 60)
 buffer-terminator-interval (* 5 60)
 buffer-terminator-mode 1)

(reformatter-define c-format    :program "clang-format"                   :group 'c)
(reformatter-define odin-format :program "odinfmt"      :args '("-stdin") :group 'odin)

(global-corfu-mode)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-history)
(setq
 corfu-auto t
 corfu-auto-delay 0.2
 corfu-auto-prefix 2)

(with-eval-after-load 'corfu (define-key corfu-map (kbd "RET") #'newline))

(setq
 orderless-matching-styles '(orderless-literal orderless-flex)
 orderless-component-separator "[ &]"
 completion-category-defaults nil
 icomplete-compute-delay 0.01
 completion-pcm-leading-wildcard t
 completion-styles '(basic orderless substring partial-completion flex)
 completion-pcm-leading-wildcard t
 completion-category-defaults nil
 completion-category-overrides '((file (styles partial-completion))))

(setq
 zoxide-use-cache t
 zoxide-completion-function #'completing-read)

;; === Non essential packages are configured with use-package instead ===

(use-package simpc-mode
  :ensure nil
  :defer t
  :config
  :hook (simpc-mode . c-format-on-save-mode)
  :mode (("\\.[hc]\\(pp\\)?$" . simpc-mode)
         ("\\.b$" . simpc-mode)))

(use-package odin-ts-mode
  :ensure nil
  :defer t
  :hook (odin-ts-mode . odin-format-on-save-mode)
  :bind
  (("C-c o b" . odin-import-base)
   ("C-c o c" . odin-import-core)
   ("C-c o v" . odin-import-vendor)
   ("C-c o s" . odin-import-shared))
  :mode (("\\.odin\\'" . odin-ts-mode)))

(use-package eglot
  :commands (eglot)
  :hook ((simpc-mode . eglot-ensure)
         (odin-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(odin-ts-mode . ("ols")))
  (add-to-list 'eglot-server-programs '(simpc-mode . ("clangd")))
  (setq eglot-autoshutdown t
  eglot-events-buffer-size 0
  eglot-report-progress nil
  eglot-send-changes-idle-time 0.5
  eglot-sync-connect 0
  jsonrpc-default-request-timeout 5
  jsonrpc-event-hook nil
  eglot-documentation-renderer 'markdown-ts-view-mode
  eglot-events-buffer-config '(:size 0 :format short)
  eglot-ignored-server-capabilities
     '(:hoverProvider                    ;; Documentation on hover
       ;:completionProvider              ;; Code completion
       ;:signatureHelpProvider           ;; Function signature help
       ;:definitionProvider              ;; Go to definition
       ;:typeDefinitionProvider          ;; Go to type definition
       ;:implementationProvider          ;; Go to implementation
       ;:declarationProvider             ;; Go to declaration
       ;:referencesProvider              ;; Find references
       :documentHighlightProvider        ;; Highlight symbols automatically
       ;:documentSymbolProvider          ;; List symbols in buffer
       ;:workspaceSymbolProvider         ;; List symbols in workspace
       ;:codeActionProvider              ;; Execute code actions
       ;:codeLensProvider                ;; Code lens
       :documentFormattingProvider       ;; Format buffer
       :documentRangeFormattingProvider  ;; Format portion of buffer
       :documentOnTypeFormattingProvider ;; On-type formatting
       ;:renameProvider                  ;; Rename symbol
       ;:documentLinkProvider            ;; Highlight links in document
       :colorProvider                    ;; Decorate color references
       ;:foldingRangeProvider            ;; Fold regions of buffer
       ;:executeCommandProvider          ;; Execute custom commands
       :inlayHintProvider                ;; Inlay hints
       :semanticTokensProvider           ;; Semantic tokens
       :typeHierarchyProvider            ;; Type hierarchies
       :callHierarchyProvider            ;; Call hierarchies
       :diagnosticProvider               ;; On-demand \"pull\" diagnostics
       )))

(use-package calfw :defer t
  :commands (calfw-open-calendar-buffer))

(use-package calfw-org :defer t
  :commands (calfw-org-open-calendar))

(use-package mu4e
  :commands (mu4e compose-mail)
  :config
  (load-file "~/.config/mu4e/mu4e-config.el"))

(use-package org-roam
  :bind
  ("C-c n l" . org-roam-buffer-toggle)
  ("C-c n f" . org-roam-node-find)
  ("C-c n i" . org-roam-node-insert)
  ("C-c n c" . org-roam-capture)
  :config
  (setq org-roam-capture-templates
   '(("d" "default" plain "%?" :target (file+head "${slug}.org" "#+title: ${title}")
      :unnarrowed t))
   org-roam-directory (file-truename "~/wiki/")
   org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))))

(use-package emms
  :bind
  (("C-c e d" . emms-play-directory-tree)
   ("C-c e a" . emms-playlist-mode-go)
   ("C-c e h" . emms-shuffle)
   ("C-c e x" . emms-pause)
   ("C-c e s" . emms-stop)
   ("C-c e p" . emms-previous)
   ("C-c e n" . emms-next))
  :config
  (emms-all)
  (emms-default-players)
  (emms-mode-line 1)
  (emms-playing-time 1)
  (setq
   emms-source-file-default-directory "~/music/"
   emms-playlist-buffer-name "*Music*"
   emms-info-asynchronously t
   emms-source-file-directory-tree-function 'emms-source-file-directory-tree-find))

(use-package magit
  :bind
  (("C-c m s"     . magit-status)
   ("C-c m l"     . magit-log))
  :custom
  (magit-auto-revert-mode nil))

(use-package elfeed
  :defer t
  :config
  (defun elfeed-yt ()
    (interactive)
    (setq elfeed-feeds
      '("https://youtube.com/feeds/videos.xml?channel_id=UCEf5U1dB5a2e2S-XUlnhxSA")))
  (defun elfeed-news ()
    (interactive)
    (setq elfeed-feeds
      '("https://www.phoronix.com/rss.php"
        "https://feeds.arstechnica.com/arstechnica/index"
        "https://feed.alternativeto.net/news/all"
        "https://cyberinsider.com/news/feed/"
        "https://ziglang.org/news/index.xml")))
  :custom
  (elfeed-feeds
      '("https://www.phoronix.com/rss.php"
        "https://feeds.arstechnica.com/arstechnica/index"
        "https://feed.alternativeto.net/news/all"
        "https://cyberinsider.com/news/feed/"
        "https://ziglang.org/news/index.xml")))

;; === Keybindings ===

(rc/unset-keys
 "M-z"         ;; zap-to-char
 "C-x f"       ;; set-fill-column
 "C-x C-d"     ;; list-directory
 "C-/"         ;; undo
 "C-s"         ;; isearch
 "C-M-<right>" ;; forward-sexp
 "C-M-<left>"  ;; backward-sexp
)

(rc/set-keys
 '("C-s"                 . rc/isearch-region)
 '("C-c M-q"             . rc/unfill-paragraph)
 '("C-,"                 . duplicate-line)
 '("C-x p d"             . rc/insert-timestamp)
 '("C-x p s"             . rc/rgrep-selected)
 '("C-x C-g"             . find-file-at-point)
 '("C-c i m"             . imenu)
 '("C-c a"               . org-agenda)
 '("C-v"                 . my/scroll-down)
 '("M-v"                 . my/scroll-up)
 '("M-p"                 . move-text-up)
 '("M-n"                 . move-text-down)
 '("C-c M-q"             . rc/unfill-paragraph)
 '("S-M-<backspace>"     . backward-mark-word)
 '("C-x C-1"             . delete-other-windows)
 '("C-x C-2"             . split-window-below)
 '("C-x C-3"             . split-window-right)
 '("C-x C-0"             . delete-window)
 '("M-z f"               . zoxide-find-file)
 '("M-z c"               . zoxide-travel)
 '("C-c s"               . surround-with-next-char)
 '("C-M-k"               . kill-whole-line)
 '("C-."                 . imenu-anywhere)
 '("C-'"                 . imenu-list-smart-toggle)
 '("C-x C-1"             . delete-other-windows)
 '("C-x C-2"             . split-window-below)
 '("C-x C-3"             . split-window-right)
 '("C-x C-0"             . delete-window)
 '("C-."                 . repeat)
 '("C-x c"               . compile)
 '("M-H"                 . windmove-left)
 '("M-L"                 . windmove-right)
 '("M-K"                 . windmove-up)
 '("M-J"                 . windmove-down)
 '("C-M-<right>"         . narrow-to-defun)
 '("C-M-<left>"          . widen)
  ;; Undo
 '("C-/"                 . undo-fu-only-undo)
 '("C-S-/"               . undo-fu-only-redo)
  ;; Multiple Cursors
 '("C-S-c C-S-c"         . mc/edit-lines)
 '("C->"                 . mc/mark-next-like-this)
 '("C-<"                 . mc/mark-previous-like-this)
 '("C-c C-<"             . mc/mark-all-like-this)
 '("C-\""                . mc/skip-to-next-like-this)
 '("C-:"                 . mc/skip-to-previous-like-this)
 '("C-S-c C-S-c"         . mc/edit-lines)
 '("C->"                 . mc/mark-next-like-this)
 '("C-<"                 . mc/mark-previous-like-this)
 '("C-c C-<"             . mc/mark-all-like-this)
 '("C-\""                . mc/skip-to-next-like-this)
 '("C-:"                 . mc/skip-to-previous-like-this))

;; Multiple Cursors
(defvar mc/keymap (make-sparse-keymap))
(define-key mc/keymap (kbd "<return>") #'newline) ;; [Enter] insert newline
(define-key mc/keymap (kbd "C-g") #'mc/keyboard-quit)
(define-key mc/keymap (kbd "C-:") #'mc/repeat-command)
(define-key mc/keymap (kbd "C-s") #'phi-search)
(define-key mc/keymap (kbd "C-r") #'phi-search-backward)

(defun org-agenda-toggle-today ()
  (interactive)
  (if (member "today" org-agenda-tag-filter)
      (org-agenda-filter-remove-all)
    (org-agenda-set-tags "today")))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "C-t") #'org-agenda-toggle-today))

(define-key dired-mode-map (kbd "b") #'dired-up-directory)
(define-key dired-mode-map (kbd "r") #'wdired-change-to-wdired-mode)

(when (eq system-type 'android)
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (column-number-mode 1)
  (setq-default tab-width 2))

(unless (eq system-type 'android)
  (use-package pdf-tools :mode (("\\.pdf\\'" . pdf-view-mode))
    :config
    (pdf-tools-install)
    (pdf-loader-install)))

;; Removes all non-required packages
(setq package-selected-packages rc/required-packages)
(package-autoremove)

(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file) (load-file custom-file))

; (profiler-stop)

;; EOF
