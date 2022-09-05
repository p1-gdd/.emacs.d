;;; init.el --- Source externe des paquets avec MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             )
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Configuration Générale
(require 'sr-speedbar)
(global-set-key (kbd "M-s s") 'sr-speedbar-toggle)
(global-set-key (kbd "M-b") 'list-buffers)
(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1)
  )
;; move-text Alt-(Up|Down)Arrow to move line
(use-package move-text
  :config
  (move-text-default-bindings)
  )

(use-package zygospore
  :bind
  (
   ("C-x 1" . zygospore-toggle-delete-other-windows)
   ("RET" . newline-and-indent)
   )
  )

(setq inhibit-splash-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(global-linum-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(global-auto-revert-mode 1)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(delete-selection-mode)


(use-package highlight-parentheses)
(use-package highlight-operators)
(use-package highlight-numbers)

(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)

;;;; C/C++ booyaaaka !
;; Treemacs (https://github.com/Alexander-Miller/treemacs)
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-display-in-side-window          t
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-missing-project-action          'ask
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-sorting                         'alphabetic-asc
          )
    (treemacs-resize-icons 16)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t t"   . treemacs)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

;; lsp
(use-package lsp-mode
  :ensure t
  :hook (
         (c-mode . lsp)
	       (c++-mode . lsp)
         (python-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration)
         )
  :commands lsp
  :config
  (setq read-process-output-max (* 1024 1024)
        gc-cons-threshold 100000000
        lsp-keymap-prefix "C-c l"
        lsp-file-watch-threshold 15000
        )
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  )

(use-package lsp-ui
  :ensure t
  :commands (lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t)
  (setq lsp-ui-doc-delay 1)
  (setq lsp-ui-doc-show-with-cursor t)
  (setq lsp-ui-doc-show-with-mouse t)
  (setq lsp-ui-sideline-enable nil)
  ;; (setq lsp-ui-sideline-show-diagnostics t)
  ;; (setq lsp-ui-sideline-show-hover t)
  ;; (setq lsp-ui-sideline-show-code-actions t)
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  )

(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol
  :config
  (lsp-treemacs-sync-mode 1))

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list)

(use-package dap-mode)
(use-package which-key
    :config
    (which-key-mode))

;; company
(use-package company
  :ensure t
  :bind ("M-/" . company-complete-common-or-cycle) ;; overwritten by flyspell
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-show-numbers t
	company-minimum-prefix-length 1
	company-idle-delay 0.5
	company-backends
	'((company-files          ; files & directory
	   company-keywords       ; keywords
	   company-capf           ; what is this?
	   company-yasnippet)
	  (company-abbrev company-dabbrev))))

(use-package company-box
  :ensure t
  :after company
  :hook (company-mode . company-box-mode))

;; flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config
  (setq flycheck-display-errors-function
	#'flycheck-display-error-messages-unless-error-list)

  (setq flycheck-indication-mode nil))

(use-package flycheck-pkg-config)

(use-package flycheck-pos-tip
  :ensure t
  :after flycheck
  :config
  (flycheck-pos-tip-mode))

(use-package srefactor
  :ensure t
  :config
  (semantic-mode 1)
  (define-key c-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
  (define-key c++-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
  )

(setq auto-mode-alist
      (cons '("SConstruct" . python-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("SConscript" . python-mode) auto-mode-alist))

;; Available C style:
;; “gnu”: The default style for GNU projects
;; “k&r”: What Kernighan and Ritchie, the authors of C used in their book
;; “bsd”: What BSD developers use, aka “Allman style” after Eric Allman.
;; “whitesmith”: Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
;; “stroustrup”: What Stroustrup, the author of C++ used in his book
;; “ellemtel”: Popular C++ coding standards as defined by “Programming in C++, Rules and Recommendations,” Erik Nyquist and Mats Henricson, Ellemtel
;; “linux”: What the Linux developers use for kernel development
;; “python”: What Python developers use for extension modules
;; “java”: The default style for java-mode (see below)
;; “user”: When you want to define your own style
(setq c-default-style "bsd")
(setq c-basic-offset 2)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(global-set-key (kbd "RET") 'newline-and-indent)

(use-package highlight-doxygen
  :hook
  (c-mode-common . (lambda ()
                     (highlight-doxygen-mode)
                     )
                 )
  )

;; Ouvrir les fichiers .h en c++-mode
;;(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; (use-package function-args
;;   :config
;;   (fa-config-default)
;;   )

;;(use-package helm)

;; (use-package auto-complete-c-headers
;;   :hook
;;   (c-mode-common . (lambda ()
;;                      ;; https://github.com/abo-abo/function-args
;;                      ;; (function-args-mode t)
;;                      ;; newline sur certains caractères '{', ';', etc.
;;                      ;; (c-toggle-auto-state 1)
;;                      ;; suppression facile des espaces gourmands
;;                      (c-toggle-hungry-state 1)
;;                      (add-to-list 'ac-sources 'ac-source-c-headers)
;;                      (add-to-list 'ac-sources 'ac-source-c-header-symbols t)
;;                      (add-to-list 'company-c-headers-path-system "/usr/include/c++/10/")
;;                      (add-to-list 'company-c-headers-path-system "/usr/include/c++/11/")
;;                      (add-to-list 'company-c-headers-path-system "/usr/include/c++/12/")
;;                      )
;;                  )
;;   )

;; Semantic modes
(setq semantic-default-submodes
      '(;; Perform semantic actions during idle time
        global-semantic-idle-scheduler-mode
        ;; Use a database of parsed tags
        global-semanticdb-minor-mode
        ;; Decorate buffers with additional semantic information
        global-semantic-decoration-mode
        ;; Highlight the name of the function you're currently in
        global-semantic-highlight-func-mode
        ;; show the name of the function at the top in a sticky
        ;; global-semantic-stickyfunc-mode
        ;; Generate a summary of the current tag when idle
        global-semantic-idle-summary-mode
        ;; Show a breadcrumb of location during idle time
        global-semantic-idle-breadcrumbs-mode
        ;; Switch to recently changed tags with `semantic-mrub-switch-tags',
        ;; or `C-x B'
        ;;global-semantic-mru-bookmark-mode
        )
      )

(require 'semantic/sb)

;;; LaTeX/auctex
(use-package tex
  :ensure auctex
  )

;;; PlantUML mode
(use-package plantuml-mode
  :config
  (setq plantuml-executable-path "/usr/bin/plantuml")
  (setq plantuml-default-exec-mode 'executable)
  )
(use-package flycheck-plantuml
  :config
  (flycheck-plantuml-setup)
  )
;; Enable plantuml-mode for PlantUML files
(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
(add-to-list 'auto-mode-alist '("\\.puml\\'" . plantuml-mode))

;; Markdown
(use-package markdown-mode
  :config
  )
(use-package markdown-toc
  :config
  )

;;; Gitlab et CI/CD
(use-package gitlab-ci-mode)
(use-package gitlab-ci-mode-flycheck)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-view-program-selection
   '(((output-dvi has-no-display-manager)
      "dvi2tty")
     ((output-dvi style-pstricks)
      "dvips and gv")
     (output-dvi "xdvi")
     (output-pdf "Zathura")
     (output-html "xdg-open")))
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#FFFFFF" "#d15120" "#5f9411" "#d2ad00" "#6b82a7" "#a66bab" "#6b82a7" "#505050"])
 '(ansi-term-color-vector
   [unspecified "#FFFFFF" "#d15120" "#5f9411" "#d2ad00" "#6b82a7" "#a66bab" "#6b82a7" "#505050"])
 '(custom-enabled-themes '(one-light))
 '(custom-safe-themes
   '("5b89b65f5e9e30d98af9d851297ee753e28528676e8ee18a032934a12762a5f2" "854f0e982e9f46844374b7d72c0137276621db317738281888f15fddb1565aeb" "e7ba99d0f4c93b9c5ca0a3f795c155fa29361927cadb99cfce301caf96055dfd" "b73a23e836b3122637563ad37ae8c7533121c2ac2c8f7c87b381dd7322714cd0" "0dd2666921bd4c651c7f8a724b3416e95228a13fca1aa27dc0022f4e023bf197" "76b4632612953d1a8976d983c4fdf5c3af92d216e2f87ce2b0726a1f37606158" default))
 '(fci-rule-character-color "#d9d9d9")
 '(fci-rule-color "#d9d9d9")
 '(flycheck-checker-error-threshold 500)
 '(gdb-many-windows t)
 '(indent-tabs-mode nil)
 '(ispell-dictionary nil)
 '(js-indent-level 2)
 '(package-selected-packages
   '(dap-mode django-commands company-auctex company-reftex company-shell company ac-c-headers ac-clang ac-rtags auto-complete auto-complete-c-headers sr-speedbar mermaid-mode aircon-theme iodine-theme twilight-theme one-themes twilight-bright-theme realgud realgud-ipdb realgud-lldb realgud-node-debug realgud-node-inspect editorconfig editorconfig-charset-extras editorconfig-custom-majormode editorconfig-domain-specific editorconfig-generate groovy-mode jenkinsfile-mode company-rtags disaster ecb flycheck-projectile flycheck-rtags helm helm-ag helm-flycheck helm-projectile helm-rtags projectile projectile-git-autofetch rtags srefactor smart-tabs-mode plantuml-mode magit auctex-lua company-lua flymake-lua lua-mode idle-highlight-mode use-package))
 '(plantuml-default-exec-mode 'executable)
 '(plantuml-executable-args '("-headless -tsvg"))
 '(plantuml-executable-path "/usr/bin/plantuml")
 '(sr-speedbar-skip-other-window-p t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Monospace" :foundry "PfEd" :slant normal :weight normal :height 95 :width normal))))
 '(mode-line ((t (:background "cornflower blue" :foreground "#494B53" :box (:line-width 1 :color "#F0F0F0") :weight normal))))
 '(mode-line-inactive ((t (:inherit mode-line :background "light steel blue" :foreground "#A0A1A7" :weight normal))))
 '(sphinx-code-block-face ((t (:inherit fixed-pitch :inverse-video t)))))

(global-set-key (kbd "C-M-<left>")  'windmove-left)
(global-set-key (kbd "C-M-<right>") 'windmove-right)
(global-set-key (kbd "C-M-<up>")    'windmove-up)
(global-set-key (kbd "C-M-<down>")  'windmove-down)

;;; DevHelp sur le mot via <f7>
(defun devhelp-word-at-point ()
  "Cherche dans DevHelp le mot courant sous le curseur"
  (interactive)
  (start-process-shell-command "devhelp" nil (concat "devhelp" " -s " (current-word)))
  (set-process-query-on-exit-flag (get-process "devhelp") nil)
  )
(global-set-key (kbd "<f7>") 'devhelp-word-at-point)

;;; Smart-tabs
(use-package smart-tabs-mode
  :config
  )
(smart-tabs-insinuate 'c)

;;; Whitespace
(global-set-key (kbd "C-c w") 'whitespace-mode)
(global-set-key (kbd "C-c t") 'whitespace-toggle-options)

(provide 'init)
;;; init.el ends here
