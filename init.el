;; Don't show the splash screen
(setq inhibit-startup-message t)

;; disable beep and flash
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; get rid of menu-, scroll- and tool-bars
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; display line numbers in each buffer
(global-display-line-numbers-mode 1)

;; load dark theme
(load-theme 'deeper-blue t)

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

;; Don't show the splash screen
(setq inhibit-startup-message t)

;; disable beep and flash
(setq visible-bell nil)
(setq ring-bell-function 'ignore)

;; get rid of menu-, scroll- and tool-bars
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; display line numbers in each buffer
(global-display-line-numbers-mode 1)

;; load dark theme
(load-theme 'deeper-blue t)

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

(global-set-key (kbd "C-S-f") 'forward-word)
(global-set-key (kbd "C-S-b") 'backward-word)
(global-set-key (kbd "C-.") 'xref-find-definitions) ;; Remap M-. (xref-find-definitions) to C-.
(global-set-key (kbd "C-,") 'xref-pop-marker-stack) ;; Remap M-, (xref-pop-marker-stack) to C-,
(global-set-key (kbd "C-S-v") 'scroll-down-command)

;; Turn on auto-fill-mode globally with Linux kernel line length (80)
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)       ;; for text-mode and derivatives
(add-hook 'prog-mode-hook #'auto-fill-mode)       ;; for programming modes
(add-hook 'conf-mode-hook #'auto-fill-mode)       ;; for config files

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(dts-mode magit markdown-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
