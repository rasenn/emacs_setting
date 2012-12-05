;; set load path
(setq load-path (cons "~/.emacs.d/" load-path))

;; set language Japanese
(set-language-environment 'Japanese)
;; UTF-8
(prefer-coding-system 'utf-8)


;; Font
(when (eq window-system 'ns)
(let ((my-font-height 120)
(my-font (cond
;; (t "Monaco") ;; XCode 3.1 で使っているフォント
;; (nil "Menlo") ;; XCode 3.2 で使ってるフォント
))
(my-font-ja "Hiragino Maru Gothic Pro"))
(setq mac-allow-anti-aliasing t)
;; フォントサイズの微調節 (12ptで合うように)
(setq face-font-rescale-alist
'(("^-apple-hiragino.*" . 1.2)
(".*osaka-bold.*" . 1.2)
(".*osaka-medium.*" . 1.2)
(".*courier-bold-.*-mac-roman" . 1.0)
(".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
(".*monaco-bold-.*-mac-roman" . 0.9)
("-cdac$" . 1.3)))
;; デフォルトフォント設定
(when my-font
(set-face-attribute 'default nil :family my-font :height my-font-height)
;;(set-frame-font (format "%s-%d" my-font (/ my-font-height 10)))
)
;; 日本語文字に別のフォントを指定
(when my-font-ja
(let ((fn (frame-parameter nil 'font))
(rg "iso10646-1"))
(set-fontset-font fn 'katakana-jisx0201 `(,my-font-ja . ,rg))
(set-fontset-font fn 'japanese-jisx0208 `(,my-font-ja . ,rg))
(set-fontset-font fn 'japanese-jisx0212 `(,my-font-ja . ,rg))))))


;; show line and column number
(custom-set-variables '(line-number-mode t)
'(column-number-mode t))


;; show filename in title bar
(setq frame-title-format (format "%%f - Emacs@%s" (system-name)))


;; newline and indent
(global-set-key "\C-m" 'newline-and-indent)

;; Base settings
(setq read-file-name-completion-ignore-case t) ;; 補完で大文字小文字無視
(global-font-lock-mode t) ;;文字の色つけ
(display-time) ;;時計を表示
(auto-compression-mode t) ;;日本語infoの文字化け防止
(setq inhibit-startup-message t) ;;起動時のメッセージは消す
(setq-default tab-width 4 indent-tabs-mode nil);;tabは4文字分、改行後に自動インデント
(setq visible-bell t) ;; 警告音を消す
(show-paren-mode 1) ;; 対応する括弧を光らせる。
(global-hl-line-mode) ;; 編集行のハイライト
(setq require-final-newline t) ;; ファイル末の改行がなければ追加
;(menu-bar-mode -1) ;;メニューバーを消す
;(tool-bar-mode 0) ;;ツールバーを表示しない
(setq truncate-partial-width-windows nil) ;; ウインドウ分割時に画面外へ出る文章を折り返す


;
;====================================
;;jaspace.el を使った全角空白、タブ、改行表示モード
;;切り替えは M-x jaspace-mode-on or -off
;====================================
(require 'jaspace)
;; 全角空白を表示させる。
(setq jaspace-alternate-jaspace-string "□")
;; 改行記号を表示させる。
(setq jaspace-alternate-eol-string "↓\n")
;; タブ記号を表示。
;;(setq jaspace-highlight-tabs t) ; highlight tabs

;; EXPERIMENTAL: On Emacs 21.3.50.1 (as of June 2004) or 22.0.5.1, a tab
;; character may also be shown as the alternate character if
;; font-lock-mode is enabled.
;; タブ記号を表示。
(setq jaspace-highlight-tabs ?^ ) ; use ^ as a tab marker


;; ruby-mode

(add-to-list 'load-path "~/.emacs.d/ruby-mode")
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)
(setq auto-mode-alist (cons '("\\.rb$" . ruby-mode) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby" "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby-keys)))


;; ruby-electric.el --- electric editing commands for ruby files
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))


;; set ruby-mode indent
(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)



;; Interactively Do Things (highly recommended, but not strictly required)
(require 'ido)
(ido-mode t)
;; Rinari
(add-to-list 'load-path "~/.emacs.d/rinari")
(require 'rinari)


;; load-pathにyasnippetのパスを通す
(setq load-path (cons (expand-file-name "~/.emacs.d/yasnippet") load-path))

;; yasnippetのロード
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/yasnippets-rails/rails-snippets")





;; flymake for ruby
(require 'flymake)
;; Invoke ruby with '-c' to get syntax checking
(defun flymake-ruby-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))
(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
(add-hook
 'ruby-mode-hook
 '(lambda ()
    ;; Don't want flymake mode for ruby regions in rhtml files
    (if (not (null buffer-file-name)) (flymake-mode))
    ;; エラー行で C-c d するとエラーの内容をミニバッファで表示する
    (define-key ruby-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no (flymake-current-line-no))
         (line-err-info-list (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))






;; rsense
(setq rsense-home (expand-file-name "~/.emacs.d/rsense"))
(add-to-list 'load-path (concat rsense-home "/etc"))
(require 'rsense)
(add-hook 'ruby-mode-hook
                    '(lambda ()
                                    ;; .や::を入力直後から補完開始
                                    (add-to-list 'ac-sources 'ac-source-rsense-method)
                                                 (add-to-list 'ac-sources 'ac-source-rsense-constant)
                                                              ;; C-x .で補完出来るようキーを設定
                                                              (define-key ruby-mode-map (kbd "C-x .") 'ac-complete-rsense)))
