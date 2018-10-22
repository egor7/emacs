; DIRED
; C-o - открыть в другом окне, не переходя в него
; i - вставить директорию
; C-u k - на так вставленной папке ее обратно скроет
;
;
; NARROW
; C-x n n - оставить только этот регион на экране
; C-x n w - показать все
;
; HIGHLIGHT
; C-x w h - раскрасить REGEXP
; C-x w r - снять раскраску
;
; M-$ - spell

(require 'uniquify)
(require 'dired)
(require 'ls-lisp)
(require 'info)

(setenv "EMACS" "true")
(fset 'yes-or-no-p 'y-or-n-p)
(set-language-environment 'UTF-8)

(custom-set-variables
 '(inhibit-startup-screen t)
 '(initial-scratch-message "; M-x lisp-interaction-mode\n; C-j to evaluate\n\n")
 '(global-auto-revert-mode t)
 '(menu-bar-mode nil)
 '(confirm-kill-emacs (quote yes-or-no-p))
 '(kill-whole-line t)
 '(show-paren-mode t)
 '(truncate-lines t)
 '(transient-mark-mode t)
 '(uniquify-buffer-name-style 'reverse)
 '(undo-limit 500000)
 '(undo-strong-limit 500000)
 '(undo-outer-limit 50000000)
 '(dired-recursive-copies 'always)
 '(dired-recursive-deletes 'always)
 '(dired-dwim-target t) ; guess target dir
 '(dired-listing-switches "-alhp")
 '(ls-lisp-use-insert-directory-program nil) ; this 3 lines
 '(ls-lisp-dirs-first t) ; makes dirs first
 '(ls-lisp-ignore-case t) ; sort in alf order ignore case
 '(grep-find-command "find . -type f -name \"X\" -exec grep -nH -e Y {} \\;")
 '(make-backup-files nil)
 '(backward-delete-char-untabify-method nil)
 '(compilation-scroll-output t)
 '(scroll-bar-mode (quote right))
 '(scroll-conservatively 100)
 '(scroll-margin 5)
 '(scroll-preserve-screen-position (quote t))
 '(column-number-mode t)
 '(require-final-newline nil)
 '(mode-require-final-newline nil)
 '(cursor-type 'bar)
 '(same-window-buffer-names (quote ("*shell*" "*mail*" "*inferior-lisp*" "*Buffer List*" "*Async Shell Command*")))
 )

;; compile .emacs on save
(defun autocompile nil
  (interactive)
  (require 'bytecomp)
  (if (string= (buffer-file-name) (expand-file-name (concat default-directory ".emacs")))
      (byte-compile-file (buffer-file-name)))
  )
(add-hook 'after-save-hook 'autocompile)

;(global-set-key (kbd "DEL") 'backward-delete-char)
;(global-set-key (kbd "TAB") 'self-insert-command)
;(global-set-key [(ctrl z)] 'undo)
;(global-set-key "\M-n" '(lambda () (interactive) (scroll-up 1)))
;(global-set-key "\M-p" '(lambda () (interactive) (scroll-down 1)))
;(global-set-key [(control tab)] 'other-window)
;(global-set-key [(control down)] '(lambda () (interactive) (scroll-up 1)))
;(global-set-key [(control up)] '(lambda () (interactive) (scroll-down 1)))
;(global-set-key [(meta down)] '(lambda () (interactive) (scroll-up 1)))
;(global-set-key [(meta up)] '(lambda () (interactive) (scroll-down 1)))


;; match parens
(defun goto-match-paren (arg)
  "Goto matching paren."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))
(global-set-key [(meta $)] 'goto-match-paren)


(setq-default c-basic-offset 4
              tab-width 4
	      indent-tabs-mode t)
(global-set-key (kbd "TAB") 'self-insert-command)
(global-set-key [(ctrl z)] 'undo)
(global-set-key "\M-n" '(lambda () (interactive) (scroll-up 1)))
(global-set-key "\M-p" '(lambda () (interactive) (scroll-down 1)))

(setq ediff-split-window-function 'split-window-horizontally)
(defun my-diff (switch)
  "diff"
  (let ((file1 (pop command-line-args-left))
        (file2 (pop command-line-args-left)))
       (ediff-files file1 file2)))
(add-to-list 'command-switch-alist '("-diff" . my-diff))

(defun user-save-and-build ()
  "save and call compile as make all"
  (interactive)
  (save-buffer)
  (compile "./build.sh"))
(global-set-key [f8] 'user-save-and-build)

(defun user-save-and-test ()
  "save and call compile as make all"
  (interactive)
  (save-buffer)
  (if (file-exists-p "test.sh")
	  (compile "./test.sh")
      (cd "test")
      (compile "./test.sh")
      (cd "..")
  )
  (message "tests from ./test/ executed!"))
(global-set-key [f9] 'user-save-and-test)
(global-set-key [(shift f9)] 'user-save-and-intest)


; alias c='eval cd `cat ~/cwd`'
(defun dired-export-cwd ()
  (interactive)
  (with-temp-file "~/cwd"
    (insert default-directory))
)
(define-key dired-mode-map "c" 'dired-export-cwd)

(defun pt-pbpaste ()
  "Paste data from pasteboard."
  (interactive)
  (shell-command-on-region
   (point)
   (if mark-active (mark) (point))
   "pbpaste" nil t)
)
(defun pt-pbcopy ()
  "Copy region to pasteboard."
  (interactive)
  (print (mark))
  (when mark-active
    (shell-command-on-region
     (point) (mark) "pbcopy")
    (kill-buffer "*Shell Command Output*"))
)
(global-set-key [?\C-x ?\C-y] 'pt-pbpaste)
(global-set-key [?\C-x ?\M-w] 'pt-pbcopy)

;(setq x-alt-keysym 'meta)

(setq tramp-default-method "ssh")

;(add-to-list 'same-window-buffer-names "*Buffer List*")


(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
	  (let* ((this-win-buffer (window-buffer))
			 (next-win-buffer (window-buffer (next-window)))
			 (this-win-edges (window-edges (selected-window)))
			 (next-win-edges (window-edges (next-window)))
			 (this-win-2nd (not (and (<= (car this-win-edges)
										 (car next-win-edges))
									 (<= (cadr this-win-edges)
										 (cadr next-win-edges)))))
			 (splitter
			  (if (= (car this-win-edges)
					 (car (window-edges (next-window))))
				  'split-window-horizontally
				'split-window-vertically)))
		(delete-other-windows)
		(let ((first-win (selected-window)))
		  (funcall splitter)
		  (if this-win-2nd (other-window 1))
		  (set-window-buffer (selected-window) this-win-buffer)
		  (set-window-buffer (next-window) next-win-buffer)
		  (select-window first-win)
		  (if this-win-2nd (other-window 1))))))
(define-key ctl-x-4-map "t" 'toggle-window-split)
(global-set-key [(control tab)] 'other-window)

; python
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))
(setq python-indent-guess-indent-offset nil)
(setq-default indent-tabs-mode nil)


; x-clip
(defun copy-to-x-clipboard ()
  (interactive)
  (if (region-active-p)
      (progn
        (call-process-region (region-beginning) (region-end) "xclip" nil 0 nil "-silent" "-i")
        (call-process-region (region-beginning) (region-end) "xclip" nil 0 nil "-silent" "-i" "-selection" "clipboard")
        (message "Yanked region to clipboard!")
        (deactivate-mark)
       )
       (message "No region active; can't yank to clipboard!")))
(defun paste-from-x-clipboard ()
  (interactive)
  (insert (shell-command-to-string "xclip -o -selection clipboard")))
(defun paste-from-x-clipboard-term ()
  (interactive)
  (insert (shell-command-to-string "xclip -o")))
(global-set-key (kbd "C-x M-w") 'copy-to-x-clipboard)
(global-set-key (kbd "C-x C-y") 'paste-from-x-clipboard)
(global-set-key (kbd "C-x M-y") 'paste-from-x-clipboard-term)

;(desktop-save-mode 1)
(setq desktop-restore-frames t)
(setq desktop-restore-in-current-display t)
(setq desktop-restore-forces-onscreen nil)

;(set-input-method "greek")

; colorize ansi output in *compilation* buffer
(require 'ansi-color)
(defun endless/colorize-compilation ()
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))
(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

(add-hook 'c-mode-common-hook
  (lambda() 
    (local-set-key  (kbd "C-o") 'ff-find-other-file)))

(setq cc-search-directories '(
  "."
  "/home/egor/Downloads/plan9port/include"
  "/usr/include/*"
  "/home/egor/Downloads/plan9port/src/*"
  "/home/egor/Downloads/tig/include/*"
))


;;; ctags
;;; link: http://blog.binchen.org/posts/how-to-use-ctags-in-emacs-effectively-3.html
(defun my-project-name-contains-substring (REGEX)
  (let ((dir (if (buffer-file-name)
                 (file-name-directory (buffer-file-name))
               "")))
    (string-match-p REGEX dir)))

(defun my-create-tags-if-needed (SRC-DIR &optional FORCE)
  "return the full path of tags file"
  (let ((dir (file-name-as-directory (file-truename SRC-DIR)) )
       file)
    (setq file (concat dir "TAGS"))
    (when (or FORCE (not (file-exists-p file)))
      (message "Creating TAGS in %s ..." dir)
      (shell-command
       (format "ctags -f %s -e -R %s" file dir))
      )
    file
    ))

(defvar my-tags-updated-time nil)

(defun my-update-tags ()
  (interactive)
  "check the tags in tags-table-list and re-create it"
  (dolist (tag tags-table-list)
    (my-create-tags-if-needed (file-name-directory tag) t)
    ))

(defun my-auto-update-tags-when-save ()
  (interactive)
  (cond
   ((not my-tags-updated-time)
    (setq my-tags-updated-time (current-time)))
   ((< (- (float-time (current-time)) (float-time my-tags-updated-time)) 300)
    ;; < 300 seconds
    ;; do nothing
    )
   (t
    (setq my-tags-updated-time (current-time))
    (my-update-tags)
    (message "updated tags after %d seconds." (- (float-time (current-time))  (float-time my-tags-updated-time)))
    )
   ))

(defun my-setup-develop-environment ()
    (when (my-project-name-contains-substring "plan9port")
      (setq tags-table-list (list (my-create-tags-if-needed "/home/egor/Downloads/plan9port"))))
    (when (my-project-name-contains-substring "tig")
      (setq tags-table-list (list (my-create-tags-if-needed "/home/egor/Downloads/tig"))))
)

(add-hook 'after-save-hook 'my-auto-update-tags-when-save)
;(add-hook 'js2-mode-hook 'my-setup-develop-environment)
;(add-hook 'web-mode-hook 'my-setup-develop-environment)
(add-hook 'c++-mode-hook 'my-setup-develop-environment)
(add-hook 'c-mode-hook 'my-setup-develop-environment)
