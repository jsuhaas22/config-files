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

;; notmuch config specific changes start ;;
(require 'notmuch)
(setq notmuch-saved-searches
      '((:name "Inbox"   :query "tag:inbox" :key "i")
        (:name "Unread"  :query "tag:unread" :key "u")
        (:name "linux-crypto"  :query "folder:linux-crypto" :key "c")
        (:name "u-boot"  :query "folder:u-boot" :key "b")
        (:name "linux-security-modules" :query "folder:linux-security-modules" :key "s")))
;; notmuch config specific changes start ;;
