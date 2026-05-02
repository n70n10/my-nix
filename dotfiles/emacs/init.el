;;; init.el — complete Emacs config

;;; ── Startup ─────────────────────────────────────────────────────────────────

(setq inhibit-startup-screen  t
      inhibit-startup-message t
      initial-scratch-message nil)

;; Defer GC during startup, restore after
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;;; ── GUI chrome ───────────────────────────────────────────────────────────────

(when (fboundp 'menu-bar-mode)   (menu-bar-mode   -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode   -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)    (tooltip-mode    -1))
(setq use-dialog-box nil)
(fringe-mode 4)

(defun toggle-transparency ()
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha-background)))
    (if (or (not alpha) (= alpha 100))
        (set-frame-parameter nil 'alpha-background 85)
      (set-frame-parameter nil 'alpha-background 100))))

(set-frame-parameter nil 'alpha-background 90)

;;; ── Core behaviour ───────────────────────────────────────────────────────────

(setq-default
 ;; Editing
 indent-tabs-mode          nil
 tab-width                 4
 fill-column               80
 sentence-end-double-space nil
 ;; Scrolling
 scroll-margin             4
 scroll-conservatively     101
 hscroll-margin            4
 hscroll-step              1)

;; FIX: backup-directory-alist and auto-save-file-name-transforms are not
;; buffer-local — they must be set with setq, not setq-default.
(setq
 backup-directory-alist         `(("." . ,(expand-file-name "backups" user-emacs-directory)))
 auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t))
 create-lockfiles               nil
 ;; Misc
 ring-bell-function             'ignore
 require-final-newline          t
 uniquify-buffer-name-style     'forward
 ;; Electric
 electric-pair-preserve-balance t)

;; FIX: coding-system-for-read/write are dynamic variables intended for
;; temporary use around I/O calls, not permanent global settings.
;; Use prefer-coding-system / set-default-coding-systems instead.
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)

(global-auto-revert-mode  1)   ; reload files changed on disk
(delete-selection-mode    1)   ; typing replaces selection
(electric-pair-mode       1)   ; auto-close brackets
(show-paren-mode          1)   ; highlight matching parens
(column-number-mode       1)   ; column in mode line
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(global-hl-line-mode      1)

;; Keep custom-set-variables out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

;; Auto-create dirs
(dolist (dir (list (expand-file-name "backups"   user-emacs-directory)
                   (expand-file-name "auto-saves" user-emacs-directory)))
  (unless (file-exists-p dir) (make-directory dir t)))

;; Set indentation to 2 spaces specifically for Nix
;; FIX: nix-indent-level does not exist; the correct variable is nix-indent-offset.
(add-hook 'nix-mode-hook
          (lambda ()
            (setq nix-indent-offset 2)
            (setq tab-width 2)
            (setq indent-tabs-mode nil)))

;;; ── package.el ───────────────────────────────────────────────────────────────

(require 'package)
(setq package-archives
      '(("melpa"        . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("gnu"          . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

;;; ── use-package ──────────────────────────────────────────────────────────────

(unless (package-installed-p 'use-package) (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;; ── Rosé Pine (local) ────────────────────────────────────────────────────────

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
;; Variants: rose-pine  rose-pine-moon  rose-pine-dawn
(load-theme 'rose-pine t)

;;; ── Fonts ────────────────────────────────────────────────────────────────────

;; Adjust family/size to taste
(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family "Iosevka SS12"
                      :height 150)
  (set-face-attribute 'fixed-pitch nil
                      :family "Iosevka SS12"
                      :height 150)
  (set-face-attribute 'variable-pitch nil
                      :family "Iosevka Aile"
                      :height 150))

;;; ── which-key ────────────────────────────────────────────────────────────────

(use-package which-key
  :init (which-key-mode 1)
  :config
  (setq which-key-idle-delay          0.4
        which-key-idle-secondary-delay 0.05
        which-key-separator            " → "
        which-key-prefix-prefix        "+"
        which-key-sort-order           'which-key-key-order-alpha
        which-key-max-display-columns  4))

;;; ── Undo ─────────────────────────────────────────────────────────────────────

;; FIX: Emacs's native undo model treats undo operations as regular commands
;; that can be redone, causing "u" to silently reverse direction mid-sequence.
;; undo-fu provides a proper linear undo/redo model.
(use-package undo-fu)

(use-package undo-fu-session
  :config (undo-fu-session-global-mode))  ; persist undo history across sessions

;;; ── Meow (modal editing) ─────────────────────────────────────────────────────

(use-package meow
  :after undo-fu
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; ── Digit arguments ───────────────────────────────────────────────────
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)

     ;; ── Files ─────────────────────────────────────────────────────────────
     '("f f" . find-file)
     '("f r" . consult-recent-file)
     '("f s" . save-buffer)
     '("f S" . write-file)

     ;; ── Buffers ───────────────────────────────────────────────────────────
     '("b b" . consult-buffer)
     '("b d" . kill-current-buffer)
     '("b r" . revert-buffer)
     '("b n" . next-buffer)
     '("b p" . previous-buffer)
     '("b i" . ibuffer)

     ;; ── Windows ───────────────────────────────────────────────────────────
     '("w s" . split-window-below)
     '("w v" . split-window-right)
     '("w d" . delete-window)
     '("w o" . delete-other-windows)
     '("w u" . winner-undo)
     '("w r" . winner-redo)
     '("w h" . windmove-left)
     '("w j" . windmove-down)
     '("w k" . windmove-up)
     '("w l" . windmove-right)

     ;; ── Search ────────────────────────────────────────────────────────────
     '("s s" . consult-line)
     '("s r" . consult-ripgrep)
     '("s f" . consult-find)
     '("s i" . consult-imenu)
     '("s ." . embark-act)

     ;; ── Git ───────────────────────────────────────────────────────────────
     '("v g" . magit-status)
     '("v b" . magit-blame)
     '("v l" . magit-log-current)
     '("v d" . magit-diff-buffer-file)
     '("v s" . magit-stage-file)

     ;; ── LSP / code ────────────────────────────────────────────────────────
     '("c a" . eglot-code-actions)
     '("c r" . eglot-rename)
     '("c f" . eglot-format-buffer)
     '("c d" . xref-find-definitions)
     '("c D" . xref-find-definitions-other-window)
     '("c R" . xref-find-references)
     '("c e" . consult-flymake)
     '("c h" . eldoc-box-help-at-point)

     ;; ── Project ───────────────────────────────────────────────────────────
     '("p p" . project-switch-project)
     '("p f" . project-find-file)
     '("p b" . project-switch-to-buffer)
     '("p k" . project-kill-buffers)
     '("p s" . consult-ripgrep)

     ;; ── Jump ──────────────────────────────────────────────────────────────
     '("j j" . avy-goto-char-timer)
     '("j l" . avy-goto-line)
     '("j d" . xref-find-definitions)

     ;; ── Toggle ────────────────────────────────────────────────────────────
     '("t l" . display-line-numbers-mode)
     '("t h" . hl-line-mode)
     '("t w" . whitespace-mode)
     '("t v" . visual-line-mode)
     '("t i" . indent-bars-mode)
     '("t t" . toggle-transparency)

     ;; ── Help ──────────────────────────────────────────────────────────────
     '("h f" . describe-function)
     '("h v" . describe-variable)
     '("h k" . describe-key)
     '("h m" . describe-mode)
     '("h p" . describe-package)

     ;; ── Misc ──────────────────────────────────────────────────────────────
     '("u"   . universal-argument)
     '(";"   . comment-dwim)
     '("x"   . execute-extended-command)
     '("'"   . repeat)
     '("q q" . save-buffers-kill-emacs))

    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("1" . meow-expand-1)
     '("2" . meow-expand-2)
     '("3" . meow-expand-3)
     '("4" . meow-expand-4)
     '("5" . meow-expand-5)
     '("6" . meow-expand-6)
     '("7" . meow-expand-7)
     '("8" . meow-expand-8)
     '("9" . meow-expand-9)
     '("-" . negative-argument)
     '(";" . meow-reverse)        ; FIX: was double-bound; comment-line moved to M-;
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . undo-fu-only-undo)   ; FIX: was meow-undo (broken Emacs undo model)
     '("U" . undo-fu-only-redo)   ; FIX: was meow-undo-in-selection
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("M-;" . comment-line)      ; FIX: moved here from ";" to free it for meow-reverse
     '("<escape>" . ignore)))
  ;; FIX: meow-keypad-threshold expects an integer; 0.5 is invalid.
  (setq meow-keypad-threshold 1)
  (meow-setup)
  (meow-global-mode 1))

;;; ── Vertico ──────────────────────────────────────────────────────────────────

(use-package vertico
  :init (vertico-mode 1)
  :config
  (setq vertico-cycle  t
        vertico-count  15
        vertico-resize t))

;; Persist history across sessions (used by vertico)
(use-package savehist
  :ensure nil   ; built-in
  :init (savehist-mode 1))

;;; ── Orderless ────────────────────────────────────────────────────────────────

(use-package orderless
  :config
  (setq completion-styles             '(orderless basic)
        completion-category-defaults  nil
        completion-category-overrides '((file (styles partial-completion)))))

;;; ── Marginalia ───────────────────────────────────────────────────────────────

(use-package marginalia
  :init (marginalia-mode 1))

;;; ── Consult (QoL: better grep/find/switch) ───────────────────────────────────

(use-package consult
  :bind
  (("M-/"   . consult-line)
   ("C-/" . consult-buffer)
   ("M-y"   . consult-yank-pop)
   ("M-g g" . consult-goto-line)
   ("M-g i" . consult-imenu)
   ("M-s r" . consult-ripgrep)
   ("M-s f" . consult-find))
  :config
  (setq consult-preview-key "M-."))

;;; ── Corfu (in-buffer completion) ─────────────────────────────────────────────

(use-package corfu
  :init (global-corfu-mode 1)
  :config
  (setq corfu-cycle        t
        corfu-auto         t
        corfu-auto-delay   0.2
        corfu-auto-prefix  2
        corfu-quit-no-match t
        corfu-preselect    'prompt))

;; Corfu in terminal
(use-package popon
  :unless (display-graphic-p)
  :vc (:url "https://codeberg.org/akib/emacs-popon" :rev :newest))

(use-package corfu-terminal
  :unless (display-graphic-p)
  :vc (:url "https://codeberg.org/akib/emacs-corfu-terminal" :rev :newest)
  :after popon
  :config (corfu-terminal-mode 1))

;; Show documentation popup next to corfu
(use-package corfu-popupinfo
  :ensure nil   ; ships with corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :config (setq corfu-popupinfo-delay '(0.5 . 0.2)))

;; Rich annotations inside corfu candidates
(use-package kind-icon
  :after corfu
  :config
  (setq kind-icon-default-face 'corfu-default)
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;;; ── Cape (completion-at-point extensions) ────────────────────────────────────

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;;; ── Tree-sitter ──────────────────────────────────────────────────────────────

(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode 1))

;;; ── Eglot (LSP) ──────────────────────────────────────────────────────────────

(use-package eglot
  :ensure nil   ; built-in since Emacs 29
  :hook
  ((rust-ts-mode    . eglot-ensure)
   (go-ts-mode      . eglot-ensure)
   (nix-mode        . eglot-ensure)
   (markdown-mode   . eglot-ensure))
  :config
  (setq eglot-autoshutdown              t
        eglot-confirm-server-initiated-edits nil
        eglot-extend-to-xref            t)
  ;; Servers — ensure these are on $PATH / in scope:
  ;;   rust:     rustup component add rust-analyzer
  ;;   go:       gopls via devshell
  ;;   nix:      nil via system packages (environment.systemPackages)
  ;;   markdown: npm i -g unified-language-server
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rustup" "run" "stable" "rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '(nix-mode . ("nil")))
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("unified-language-server"
                                  "--parser=remark-parse"
                                  "--stdio"))))

;; direnv — makes Emacs inherit devshell $PATH and env vars.
;; Without this, eglot won't find gopls/rust-analyzer unless
;; Emacs was launched from inside nix develop.
(use-package direnv
  :config
  (setq direnv-always-show-summary nil)
  (direnv-mode))

;; Better Eglot UI via eldoc box
;; Note: eldoc-box-only-multiline avoids popup conflicts with corfu.
(use-package eldoc-box
  :hook (eglot-managed-mode . eldoc-box-hover-mode)
  :config
  (setq eldoc-box-max-pixel-width  500
        eldoc-box-max-pixel-height 300
        eldoc-box-only-multiline   t))

;;; ── Language: Rust ───────────────────────────────────────────────────────────

;; FIX: treesit-auto redirects .rs files to rust-ts-mode, so rust-mode's
;; rust-format-on-save setting never fires. Format via eglot instead.
(use-package rust-mode
  :mode "\\.rs\\'")

(add-hook 'rust-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'eglot-format-buffer nil t)))

;;; ── Language: Go ─────────────────────────────────────────────────────────────

;; FIX: treesit-auto redirects .go files to go-ts-mode, so the before-save
;; hook on go-mode never fires. Hook gofmt onto go-ts-mode instead.
(use-package go-mode
  :mode "\\.go\\'")

(add-hook 'go-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'gofmt-before-save nil t)))

;;; ── Language: Nix ────────────────────────────────────────────────────────────

(use-package nix-mode
  :mode "\\.nix\\'")

;;; ── Language: Markdown ───────────────────────────────────────────────────────

(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :config
  (setq markdown-command          "pandoc"
        markdown-fontify-code-blocks-natively t
        markdown-hide-markup      nil))

;;; ── Magit ────────────────────────────────────────────────────────────────────

(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1
        magit-diff-refine-hunk        t
        magit-save-repository-buffers 'dontask))

;; Show diff indicators in the fringe
(use-package diff-hl
  :init (global-diff-hl-mode 1)
  :hook
  (magit-pre-refresh  . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

;;; ── QoL: editing ─────────────────────────────────────────────────────────────

;; Move lines/regions with M-up/down
(use-package move-text
  :config (move-text-default-bindings))

;; Multiple cursors
(use-package multiple-cursors
  :bind
  (("C->"   . mc/mark-next-like-this)
   ("C-<"   . mc/mark-previous-like-this)
   ("C-c a" . mc/mark-all-like-this)))

;; Expand region by semantic units
;; Use the treesit-aware fork to avoid native-compiler warnings
(use-package expand-region
  :vc (:url "https://github.com/garyo/expand-region.el" :rev :newest)
  :bind ("C-=" . er/expand-region))

;; Show available keybindings as you type
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; ── QoL: navigation ──────────────────────────────────────────────────────────

;; Jump to any visible character
(use-package avy
  :bind
  (("M-j"   . avy-goto-char-timer)
   ("M-J"   . avy-goto-line)))

;; Project management
(use-package project
  :ensure nil   ; built-in
  :bind-keymap ("C-x p" . project-prefix-map))

;;; ── QoL: UI ──────────────────────────────────────────────────────────────────

;; Nicer modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height          28
        doom-modeline-icon            t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-encoding nil
        doom-modeline-lsp             t))

;; Icons (required by doom-modeline and kind-icon)
(use-package nerd-icons
  :config
  ;; Run once: M-x nerd-icons-install-fonts
  )

;; Highlight TODO/FIXME/HACK/NOTE in comments
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-keyword-faces
        `(("TODO"  . "#f6c177")
          ("FIXME" . "#eb6f92")
          ("HACK"  . "#c4a7e7")
          ("NOTE"  . "#9ccfd8")
          ("WARN"  . "#eb6f92"))))

;; Indent guides
(use-package indent-bars
  :hook (prog-mode . indent-bars-mode))

;; Coloured delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; ── QoL: buffer/window ───────────────────────────────────────────────────────

;; Easy window switching with M-<arrow>
(windmove-default-keybindings 'meta)

;; Restore window layout with C-c left/right
(winner-mode 1)

;; Dim inactive windows
(use-package dimmer
  :config
  (setq dimmer-fraction 0.25)
  (dimmer-mode 1))

;;; end of init.el
