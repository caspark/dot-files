;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(setq select-enable-clipboard t)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Caspar Krieger"
      user-mail-address "caspar@asparck.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 15))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. 'doom-one is the default:
(setq doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/src/org")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

; a bunch of settings
(setq
 projectile-project-search-path '("~/src/" "/mnt/c/src/")
 evil-goggles-duration 0.25
 server-use-tcp t)

(defun ck-test ()
  (interactive)
  (print "ck test executed"))

(defun ck-vterm-buffer-p (buffer)
  "Return t if buffer BUFFER is a VTerm buffer."
  (eq (buffer-local-value 'major-mode buffer) 'vterm-mode))
(defun ck--vterms ()
  "List all the (other) VTerm buffers.
List all the VTerm buffers, if the current one is a VTerm buffer,
exclude it."
  (seq-filter #'ck-vterm-buffer-p
              (delq (current-buffer) (buffer-list))))
(defun ck-vterm ()
  "Get the first vterm"
  (first (ck--vterms))
  )

(defun ck-vterm-send-string (str)
  "A version of vterm-send-string that works even when not currently focused on
a vterm buffer"
  (process-send-string (get-buffer-process (ck-vterm)) str)
  )

(defun ck-vterm-send-line-at-point ()
  "Send the line at point to the first open vterm found"
  (interactive)
  (ck-vterm-send-string (thing-at-point 'line t)))

(defun ck-vterm-send-line-extra-enter-at-point ()
  "Send the line at point to the first open vterm found, but also send an
extra enter. Useful when dealing with apps like running cmd.exe inside a WSL
terminal."
  (interactive)
  (ck-vterm-send-string (concat (thing-at-point 'line t) "\C-m")))

(map! :leader
      (:prefix-map ("r" . "ck-extensions")
       :desc "Keybinding test" "q" #'ck-test
       :desc "Send to line to vterm" "r" #'ck-vterm-send-line-at-point
       :desc "Send to line w/ extra enter to vterm" "RET" #'ck-vterm-send-line-extra-enter-at-point))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("2f1518e906a8b60fac943d02ad415f1d8b3933a5a7f75e307e6e9a26ef5bf570" "79278310dd6cacf2d2f491063c4ab8b129fee2a498e4c25912ddaa6c3c5b621e" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
