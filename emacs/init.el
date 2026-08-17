;; Forbid emacs from editing `init.el` directly.
;; I did `customize-themes` and it edited this file. This file should be edited
;; only by the user.
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

;; Don't show the splash screen
(setq inhibit-startup-message t)

;; disable beep and flash
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; get rid of menu-, scroll- and tool-bars
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; set a theme
(load-theme 'tango-dark t)

;; display line numbers in each buffer
(global-display-line-numbers-mode 1)

;; set font to intelOne-Mono
(set-frame-font "intelOne Mono 12" nil t)

;; make it truly full-screen
(setq frame-resize-pixelwise t)

;; set tab
(setq-default c-basic-offset 8)

;; enable electric pair mode
(electric-pair-mode -1)

;; maximize frame at startup
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))

(when (display-graphic-p)
(global-set-key (kbd "C-S-f") 'forward-word)
(global-set-key (kbd "C-S-b") 'backward-word)
(global-set-key (kbd "C-.") 'xref-find-definitions) ;; Remap M-. (xref-find-definitions) to C-.
(global-set-key (kbd "C-,") 'xref-pop-marker-stack) ;; Remap M-, (xref-pop-marker-stack) to C-,
(global-set-key (kbd "C-S-v") 'scroll-down-command)
)

;; Turn on auto-fill-mode globally with Linux kernel line length (80)
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)       ;; for text-mode and derivatives
(add-hook 'prog-mode-hook #'auto-fill-mode)       ;; for programming modes
(add-hook 'conf-mode-hook #'auto-fill-mode)       ;; for config files

(defun modi/revert-all-file-buffers ()
  "Refresh all open file buffers without confirmation.
Buffers in modified (not yet saved) state in emacs will not be reverted. They
will be reverted though if they were modified outside emacs.
Buffers visiting files which do not exist any more or are no longer readable
will be killed."
  (interactive)
  (dolist (buf (buffer-list))
    (let ((filename (buffer-file-name buf)))
      ;; Revert only buffers containing files, which are not modified;
      ;; do not try to revert non-file buffers like *Messages*.
      (when (and filename
                 (not (buffer-modified-p buf)))
        (if (file-readable-p filename)
            ;; If the file exists and is readable, revert the buffer.
            (with-current-buffer buf
              (revert-buffer :ignore-auto :noconfirm :preserve-modes))
          ;; Otherwise, kill the buffer.
          (let (kill-buffer-query-functions) ; No query done when killing buffer
            (kill-buffer buf)
            (message "Killed non-existing/unreadable file buffer: %s" filename))))))
  (message "Finished reverting buffers containing unmodified files."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; package configs
;; sources:
;;	https://stackoverflow.com/questions/55038594/setting-up-emacs-on-new-machine-with-init-el-and-package-installation
;;	https://docs.projectile.mx/projectile/usage.html
;; download packages if they aren't already downloaded.
;; this block reduces startup time by a bit but I don't care.
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa". "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("gnu". "https://elpa.gnu.org/packages/") t)

(package-initialize)
;; I may have forgotten adding a few. Might have to be updated on a new machine.
(setq req-packages
      '(projectile
	ag
	vertico
	which-key-posframe
	magit
	notmuch
	dts-mode
	org-roam
	org-journal
	markdown-mode))
;; Iterate on packages and install missing ones
(dolist (pkg req-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; projectile specific changes start ;;
;; all of the below in the projectile section is copied from the docs.

;; Optional: ag is nice alternative to using grep with Projectile
(use-package ag
  :ensure t)

;; Optional: Enable vertico as the selection framework to use with Projectile
(use-package vertico
  :ensure t
  :init
  (vertico-mode +1))

;; Optional: which-key will show you options for partially completed keybindings
;; It's extremely useful for packages with many keybindings like Projectile.
(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/projects/" "~/git/" "~/ti/git" "~/learn/nrf54l15-dk/i2c/bmesensor/" "~/zephyrproject"))
  :config
  ;; On Linux, however, I usually go with another one
  (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

;; projectile specific changes start ;;

;; patch/diff colorization in notmuch-show buffers start ;;
;; By default notmuch-show renders patch bodies as plain text, so added and
;; removed lines look identical to context. Reuse diff-mode's faces to color
;; them the way `git diff` / `diff-mode` do.
(require 'diff-mode)
(defun modi/notmuch-show-colorize-diff ()
  "Colorize +/-/@@ patch lines in the current notmuch-show buffer."
  (font-lock-add-keywords
   nil
   '(("^\\(---\\|\\+\\+\\+\\) .*$" . 'diff-file-header)
     ("^@@ .*@@.*$" . 'diff-hunk-header)
     ("^-.*$" . 'diff-removed)
     ("^\\+.*$" . 'diff-added)))
  (font-lock-flush))
(add-hook 'notmuch-show-hook #'modi/notmuch-show-colorize-diff)
;; patch/diff colorization in notmuch-show buffers end ;;

;; notmuch config specific changes start ;;
(require 'notmuch)
(setq notmuch-saved-searches
      '((:name "Inbox"   :query "tag:inbox" :key "i")
        (:name "Unread"  :query "tag:unread" :key "u")
        (:name "Sent"    :query "folder:sent" :key "t")
        (:name "linux-crypto"  :query "folder:linux-crypto" :key "c")
        (:name "u-boot"  :query "folder:u-boot" :key "b")
        (:name "selinux"  :query "folder:selinux" :key "s")
        (:name "linux-security-modules" :query "folder:linux-security-modules" :key "s")))

;; sending mail: route through msmtp (same ~/.msmtprc account used by
;; mutt and git-send-email) instead of Emacs' built-in smtpmail.
(setq user-full-name "Suhaas Joshi")
(setq user-mail-address "joshiesuhaas0@gmail.com")
(setq message-send-mail-function #'message-send-mail-with-sendmail)
(setq sendmail-program "msmtp")
(setq message-sendmail-extra-arguments '("--account=gmail"))
;; msmtp already knows the envelope-from via the account config; don't
;; let message-mode pass its own "-f" and second-guess it.
(setq message-sendmail-f-is-evil t)
(setq mail-specify-envelope-from t)
(setq message-sendmail-envelope-from 'header)
(setq mail-user-agent 'notmuch-user-agent)

;; keep a local copy of everything sent, indexed by notmuch
;; (relative to notmuch's database.path, i.e. ~/mail/sent)
(setq notmuch-fcc-dirs "sent")
;; notmuch config specific changes start ;;


;; org-mode configs
(global-set-key (kbd "C-c C-o l") #'org-store-link)
(global-set-key (kbd "C-c C-o a") #'org-agenda)
(global-set-key (kbd "C-c C-o c") #'org-capture)


(use-package eglot
  :ensure nil  ;; built-in
  :hook ((c-mode c++-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '((c-mode c++-mode) . ("clangd"))))


;;; eglot uses project.el in backend. I use projectile. To ensure there's no
;;; clash, add projectile as the backend service for project.el. So eglot uses
;;; it indirectly too. TODO: switch over to project.el completely sometime in
;;; the future.
(use-package projectile
  :ensure t
  :init
  (setq projectile-keymap-prefix (kbd "C-c C-p"))
  :config
  (projectile-mode +1)
  ;; make project.el (and thus eglot) recognize projectile roots
  (defun my/projectile-project-find-function (dir)
    (let ((root (projectile-project-root dir)))
      (and root (cons 'transient root))))
  (add-hook 'project-find-functions #'my/projectile-project-find-function))

;;; persp-mode
;;; perspective and project will have the same name. Switching a project
;;; automatically switches the perspective, but doesn't happen the other way
;;; around. State can be saved and loaded, thus a perspective will open as I
;;; last saved it before killing it / emacs.
(use-package perspective
  :ensure t
  :custom
  (persp-mode-prefix-key (kbd "C-c w"))
  :init
  (persp-mode))

(add-hook 'projectile-after-switch-project-hook
          (lambda () (persp-switch (projectile-project-name))))

(setq persp-suppress-no-prefix-key-warning t)  ;; silence startup warning if prefix isn't C-x x

;; make buffer-switching commands (C-x b, ibuffer, etc.) respect the current perspective
(setq persp-show-modestring t)  ;; shows current persp name in the mode-line — very useful for sanity checking

;; if you want ibuffer scoped per-perspective too:
(use-package ibuffer
  :ensure nil
  :hook (ibuffer-mode . (lambda () (require 'perspective))))

(global-set-key (kbd "C-c i") 'persp-buffer-menu)
