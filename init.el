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
(set-frame-font "intelOne Mono 14" nil t)

;; make it truly full-screen
(setq frame-resize-pixelwise t)

;; set tab
(setq-default c-basic-offset 8)

;; enable electric pair mode
(electric-pair-mode -1)

;; maximize frame at startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; get search feature within dired-mode when / is clicked
(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map (kbd "/") 'dired-isearch-filenames)))
