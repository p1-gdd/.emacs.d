;; Configuration de la source externe des paquets avec MELPA
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
; move-text Alt-(Up|Down)Arrow to move line
(use-package move-text
  :config
  (move-text-default-bindings)
  )

(use-package zygospore
  :bind
  (
   ("C-x 1" . zygospore-toggle-delete-other-windows)
   ("RET" .   newline-and-indent)
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

(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  )

(use-package flycheck-pkg-config)

; C/C++ booyaaaka !
;; company
(global-ede-mode)
(use-package company
  :init
  (global-company-mode 1)
  (delete 'company-semantic company-backends))
(use-package company-c-headers
  :init
  (add-to-list 'company-backends 'company-c-headers))

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
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(use-package function-args
  :config
  (fa-config-default)
  )

(use-package auto-complete-c-headers
  :hook
  (c-mode-common . (lambda ()
                     ;; https://github.com/abo-abo/function-args
                     (function-args-mode t)
                     ;; newline sur certains caractères '{', ';', etc.
                     ;; (c-toggle-auto-state 1)
                     ;; suppression facile des espaces gourmands
                     (c-toggle-hungry-state 1)
                     (add-to-list 'ac-sources 'ac-source-c-headers)
                     (add-to-list 'ac-sources 'ac-source-c-header-symbols t)
                     (add-to-list 'company-c-headers-path-system "/usr/include/c++/8/")
                     )
                 )
  )

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

;;; LaTeX/auctex
(use-package tex
  :ensure auctex
  :config
  (setq LaTeX-verbatim-environments-local '("lstlisting" "bashful"))
  :custom
  (LaTeX-item-indent 0)
  (LaTeX-verbatim-macros-with-braces (quote ("lstinline")))
  (LaTeX-verbatim-macros-with-delims (quote ("verb" "verb*" "lstinline")))
  (TeX-view-program-selection
   (quote
    (((output-dvi has-no-display-manager)
      "dvi2tty")
     ((output-dvi style-pstricks)
      "dvips and gv")
     (output-dvi "Zathura")
     (output-pdf "Zathura")
     (output-html "xdg-open"))))
  (reftex-plug-into-AUCTeX (quote (t t t t t)))
  (reftex-ref-style-alist
   (quote
    (("Default" t
      (("\\ref" 13)
       ("\\pageref" 112)))
     ("Varioref" "varioref"
      (("\\vref" 118)
       ("\\vrefrange" 114)
       ("\\vpageref" 103)
       ("\\Vref" 86)
       ("\\Ref" 82)))
     ("Fancyref" "fancyref"
      (("\\fref" 102)
       ("\\Fref" 70)))
     ("Hyperref" "hyperref"
      (("\\autoref" 97)
       ("\\autopageref" 117)))
     ("Cleveref" "cleveref"
      (("\\cref" 99)
       ("\\Cref" 67)
       ("\\cpageref" 100)
       ("\\Cpageref" 68))))))
  (reftex-ref-style-default-list (quote ("Default" "Varioref")))
  :hook (LaTeX-mode-hook . (lambda () (interactive)
                             (add-to-list 'LaTeX-indent-environment-list '("lstlisting" current-indentation))
                             (add-to-list 'LaTeX-indent-environment-list '("bashful" current-indentation))
                             (TeX-fold-mode t)
                             (reftex-mode t)))
  )

;;; PlantUML mode
(use-package plantuml-mode
  :config
  (setq plantuml-jar-path "/usr/share/plantuml/plantuml.jar")
  )
(use-package flycheck-plantuml
  :config
  (flycheck-plantuml-setup)
  )

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
 '(custom-enabled-themes (quote (leuven)))
 '(gdb-many-windows t)
 '(package-selected-packages (quote (use-package)))
)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "DejaVu Sans Mono" :foundry "PfEd" :slant normal :weight normal :height 97 :width normal))))
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

;;; Neomutt intégration
(add-to-list 'auto-mode-alist '("/tmp/neomutt-*" . mail-mode))

