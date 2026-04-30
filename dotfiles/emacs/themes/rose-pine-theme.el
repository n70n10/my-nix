;;; rose-pine-theme.el --- Rosé Pine (main) -*- lexical-binding: t -*-
;; Official palette: https://rosepinetheme.com/palette/ingredients

(deftheme rose-pine "Rosé Pine — all natural pine, faux fur and a bit of soho vibes.")

(let ((base       "#191724")
      (surface    "#1f1d2e")
      (overlay    "#26233a")
      (muted      "#6e6a86")
      (subtle     "#908caa")
      (text       "#e0def4")
      (love       "#eb6f92")
      (gold       "#f6c177")
      (rose       "#ebbcba")
      (pine       "#31748f")
      (foam       "#9ccfd8")
      (iris       "#c4a7e7")
      (hl-low     "#21202e")
      (hl-med     "#403d52")
      (hl-high    "#524f67"))

  (custom-theme-set-faces
   'rose-pine

   ;; ── Core ────────────────────────────────────────────────────────────────
   `(default                    ((t :background ,base    :foreground ,text)))
   `(fringe                     ((t :background ,base    :foreground ,muted)))
   `(vertical-border            ((t :foreground ,overlay)))
   `(border                     ((t :foreground ,overlay)))
   `(cursor                     ((t :background ,rose)))
   `(mouse                      ((t :foreground ,text)))
   `(highlight                  ((t :background ,hl-med)))
   `(region                     ((t :background ,hl-med  :extend t)))
   `(secondary-selection        ((t :background ,hl-low  :extend t)))
   `(hl-line                    ((t :background ,hl-low  :extend t)))
   `(match                      ((t :foreground ,rose    :weight bold)))
   `(shadow                     ((t :foreground ,muted)))
   `(minibuffer-prompt          ((t :foreground ,iris    :weight bold)))
   `(error                      ((t :foreground ,love    :weight bold)))
   `(warning                    ((t :foreground ,gold    :weight bold)))
   `(success                    ((t :foreground ,foam    :weight bold)))
   `(escape-glyph               ((t :foreground ,rose)))
   `(trailing-whitespace        ((t :background ,love)))

   ;; ── Line numbers ────────────────────────────────────────────────────────
   `(line-number                ((t :background ,base    :foreground ,muted)))
   `(line-number-current-line   ((t :background ,base    :foreground ,subtle  :weight bold)))

   ;; ── Mode line ───────────────────────────────────────────────────────────
   `(mode-line                  ((t :background ,overlay :foreground ,subtle)))
   `(mode-line-inactive         ((t :background ,surface :foreground ,muted)))
   `(mode-line-buffer-id        ((t :foreground ,text    :weight bold)))
   `(mode-line-emphasis         ((t :foreground ,iris    :weight bold)))
   `(mode-line-highlight        ((t :foreground ,rose)))

   ;; ── Links ───────────────────────────────────────────────────────────────
   `(link                       ((t :foreground ,iris    :underline t)))
   `(link-visited               ((t :foreground ,muted   :underline t)))
   `(button                     ((t :foreground ,iris    :underline t)))

   ;; ── Search ──────────────────────────────────────────────────────────────
   `(isearch                    ((t :background ,rose    :foreground ,base    :weight bold)))
   `(isearch-fail               ((t :background ,love    :foreground ,base)))
   `(lazy-highlight             ((t :background ,hl-med  :foreground ,subtle)))
   `(query-replace              ((t :background ,gold    :foreground ,base)))

   ;; ── Font lock (syntax) ──────────────────────────────────────────────────
   ;; Rosé Pine semantic assignments:
   ;;   keywords   → pine   (control flow, language keywords)
   ;;   functions  → rose   (function/method names)
   ;;   types      → foam   (types, classes, interfaces)
   ;;   builtins   → love   (built-in functions/macros)
   ;;   constants  → iris   (constants, numbers, booleans)
   ;;   strings    → gold   (string literals)
   ;;   variables  → foam   (variable names)
   ;;   comments   → muted  (all comments, italic)
   ;;   preprocessor/macro → iris
   `(font-lock-keyword-face           ((t :foreground ,pine)))
   `(font-lock-function-name-face     ((t :foreground ,rose)))
   `(font-lock-type-face              ((t :foreground ,foam)))
   `(font-lock-builtin-face           ((t :foreground ,love)))
   `(font-lock-constant-face          ((t :foreground ,iris)))
   `(font-lock-string-face            ((t :foreground ,gold)))
   `(font-lock-variable-name-face     ((t :foreground ,foam)))
   `(font-lock-comment-face           ((t :foreground ,muted  :slant italic)))
   `(font-lock-comment-delimiter-face ((t :foreground ,muted  :slant italic)))
   `(font-lock-doc-face               ((t :foreground ,muted  :slant italic)))
   `(font-lock-doc-markup-face        ((t :foreground ,subtle)))
   `(font-lock-preprocessor-face      ((t :foreground ,iris)))
   `(font-lock-negation-char-face     ((t :foreground ,love)))
   `(font-lock-warning-face           ((t :foreground ,love   :weight bold)))
   `(font-lock-number-face            ((t :foreground ,iris)))
   `(font-lock-operator-face          ((t :foreground ,subtle)))
   `(font-lock-punctuation-face       ((t :foreground ,subtle)))
   `(font-lock-bracket-face           ((t :foreground ,subtle)))
   `(font-lock-delimiter-face         ((t :foreground ,subtle)))
   `(font-lock-regexp-grouping-backslash ((t :foreground ,pine)))
   `(font-lock-regexp-grouping-construct ((t :foreground ,iris)))

   ;; ── Completions ─────────────────────────────────────────────────────────
   `(completions-annotations          ((t :foreground ,muted)))
   `(completions-common-part          ((t :foreground ,iris   :weight bold)))
   `(completions-first-difference     ((t :foreground ,love)))

   ;; ── Dired ───────────────────────────────────────────────────────────────
   `(dired-directory            ((t :foreground ,foam    :weight bold)))
   `(dired-flagged              ((t :foreground ,love)))
   `(dired-header               ((t :foreground ,pine    :weight bold)))
   `(dired-mark                 ((t :foreground ,gold)))
   `(dired-marked               ((t :foreground ,gold    :weight bold)))
   `(dired-symlink              ((t :foreground ,rose)))
   `(dired-perm-write           ((t :foreground ,subtle)))

   ;; ── Whitespace ──────────────────────────────────────────────────────────
   `(whitespace-tab             ((t :background ,base    :foreground ,hl-med)))
   `(whitespace-newline         ((t :foreground ,hl-med)))
   `(whitespace-trailing        ((t :background ,love)))
   `(whitespace-space           ((t :foreground ,hl-med)))

   ;; ── Org ─────────────────────────────────────────────────────────────────
   `(org-block                  ((t :background ,surface :extend t)))
   `(org-block-begin-line       ((t :background ,surface :foreground ,muted   :slant italic :extend t)))
   `(org-block-end-line         ((t :background ,surface :foreground ,muted   :slant italic :extend t)))
   `(org-code                   ((t :foreground ,gold)))
   `(org-verbatim               ((t :foreground ,gold)))
   `(org-date                   ((t :foreground ,iris)))
   `(org-document-info          ((t :foreground ,subtle)))
   `(org-document-title         ((t :foreground ,text    :weight bold)))
   `(org-done                   ((t :foreground ,muted)))
   `(org-todo                   ((t :foreground ,love    :weight bold)))
   `(org-headline-done          ((t :foreground ,muted)))
   `(org-footnote               ((t :foreground ,iris)))
   `(org-formula                ((t :foreground ,rose)))
   `(org-level-1                ((t :foreground ,rose    :weight bold)))
   `(org-level-2                ((t :foreground ,foam    :weight bold)))
   `(org-level-3                ((t :foreground ,iris    :weight bold)))
   `(org-level-4                ((t :foreground ,gold    :weight bold)))
   `(org-level-5                ((t :foreground ,pine    :weight bold)))
   `(org-level-6                ((t :foreground ,love    :weight bold)))
   `(org-level-7                ((t :foreground ,subtle  :weight bold)))
   `(org-level-8                ((t :foreground ,muted   :weight bold)))
   `(org-link                   ((t :foreground ,iris    :underline t)))
   `(org-meta-line              ((t :foreground ,muted)))
   `(org-table                  ((t :foreground ,subtle)))
   `(org-tag                    ((t :foreground ,muted   :weight bold)))
   `(org-warning                ((t :foreground ,gold    :weight bold)))

   ;; ── Vertico ─────────────────────────────────────────────────────────────
   `(vertico-current            ((t :background ,hl-med  :extend t)))

   ;; ── Marginalia ──────────────────────────────────────────────────────────
   `(marginalia-documentation   ((t :foreground ,muted   :slant italic)))

   ;; ── Orderless ───────────────────────────────────────────────────────────
   `(orderless-match-face-0     ((t :foreground ,iris    :weight bold)))
   `(orderless-match-face-1     ((t :foreground ,rose    :weight bold)))
   `(orderless-match-face-2     ((t :foreground ,foam    :weight bold)))
   `(orderless-match-face-3     ((t :foreground ,gold    :weight bold)))

   ;; ── Corfu ───────────────────────────────────────────────────────────────
   `(corfu-default              ((t :background ,overlay)))
   `(corfu-current              ((t :background ,hl-med)))
   `(corfu-bar                  ((t :background ,muted)))
   `(corfu-border               ((t :background ,hl-high)))
   `(corfu-annotations          ((t :foreground ,muted)))
   `(corfu-deprecated           ((t :foreground ,muted   :strike-through t)))

   ;; ── Eglot ───────────────────────────────────────────────────────────────
   `(eglot-highlight-symbol-face          ((t :background ,hl-med)))
   `(eglot-diagnostic-tag-unnecessary-face ((t :foreground ,muted)))

   ;; ── Flymake / Flycheck ──────────────────────────────────────────────────
   `(flymake-error              ((t :underline (:style wave :color ,love))))
   `(flymake-warning            ((t :underline (:style wave :color ,gold))))
   `(flymake-note               ((t :underline (:style wave :color ,foam))))
   `(flycheck-error             ((t :underline (:style wave :color ,love))))
   `(flycheck-warning           ((t :underline (:style wave :color ,gold))))
   `(flycheck-info              ((t :underline (:style wave :color ,foam))))

   ;; ── Magit ───────────────────────────────────────────────────────────────
   `(magit-branch-local                   ((t :foreground ,foam)))
   `(magit-branch-remote                  ((t :foreground ,pine)))
   `(magit-diff-added                     ((t :background "#1a2f25" :foreground ,foam    :extend t)))
   `(magit-diff-added-highlight           ((t :background "#1e3a2d" :foreground ,foam    :extend t)))
   `(magit-diff-removed                   ((t :background "#2e1a25" :foreground ,love    :extend t)))
   `(magit-diff-removed-highlight         ((t :background "#3a1e2d" :foreground ,love    :extend t)))
   `(magit-diff-context                   ((t :foreground ,muted    :extend t)))
   `(magit-diff-context-highlight         ((t :background ,surface  :foreground ,subtle  :extend t)))
   `(magit-diff-hunk-heading              ((t :background ,overlay  :foreground ,subtle)))
   `(magit-diff-hunk-heading-highlight    ((t :background ,overlay  :foreground ,text    :weight bold)))
   `(magit-filename                       ((t :foreground ,rose)))
   `(magit-hash                           ((t :foreground ,muted)))
   `(magit-header-line                    ((t :foreground ,iris     :weight bold)))
   `(magit-log-author                     ((t :foreground ,gold)))
   `(magit-log-date                       ((t :foreground ,subtle)))
   `(magit-log-graph                      ((t :foreground ,muted)))
   `(magit-process-ng                     ((t :foreground ,love     :weight bold)))
   `(magit-process-ok                     ((t :foreground ,foam     :weight bold)))
   `(magit-section-heading                ((t :foreground ,gold     :weight bold)))
   `(magit-section-highlight              ((t :background ,surface  :extend t)))
   `(magit-tag                            ((t :foreground ,gold)))

   ;; ── diff-hl ─────────────────────────────────────────────────────────────
   `(diff-hl-insert             ((t :foreground ,foam    :background ,foam)))
   `(diff-hl-delete             ((t :foreground ,love    :background ,love)))
   `(diff-hl-change             ((t :foreground ,gold    :background ,gold)))

   ;; ── Tab bar ─────────────────────────────────────────────────────────────
   `(tab-bar                    ((t :background ,base    :foreground ,subtle)))
   `(tab-bar-tab                ((t :background ,overlay :foreground ,text    :weight bold)))
   `(tab-bar-tab-inactive       ((t :background ,base    :foreground ,muted)))))

(provide-theme 'rose-pine)
;;; rose-pine-theme.el ends here
