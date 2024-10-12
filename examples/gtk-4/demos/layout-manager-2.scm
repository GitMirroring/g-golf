;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2024
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation; either version 3 of the
;;;; License, or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.

;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with GNU G-Golf.  If not, see
;;;; <https://www.gnu.org/licenses/lgpl.html>.
;;;;

;;; Commentary:

;;; Code:


(define-module (demos layout-manager-2)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos layout-manager-2-init)
  #:use-module (demos demo-widget-2)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (activate-demo))


#;(g-export )

(define (activate-demo app)
  (let ((window (make <gtk-application-window>
                  #:title "Layout Manager — Transformation"
                  #:default-width 600
                  #:default-height 620
                  #:application app))
        (demo-widget (make <demo-widget-2>)))
    (populate-demo-widget demo-widget)
    (set-child window demo-widget)
    (present window)))

(define (populate-demo-widget demo-widget)
  (let ((n-names (length %icon-names))
        (icon-names %icon-names))
    (do ((i 0
            (+ i 1)))
        ((>= i (* 18 36)))
      (let ((icon-name (list-ref icon-names (modulo i n-names))))
        (add-child demo-widget
                   (make <gtk-image>
                     #:icon-name icon-name
                     #:margin-start 4
                     #:margin-end 4
                     #:margin-top 4
                     #:margin-bottom 4))))))


;;;
;;; colors
;;;

(define %icon-names
  '("action-unavailable-symbolic"
    "address-book-new-symbolic"
    "application-exit-symbolic"
    "appointment-new-symbolic"
    "bookmark-new-symbolic"
    "call-start-symbolic"
    "call-stop-symbolic"
    "camera-switch-symbolic"
    "chat-message-new-symbolic"
    "color-select-symbolic"
    "contact-new-symbolic"
    "document-edit-symbolic"
    "document-new-symbolic"
    "document-open-recent-symbolic"
    "document-open-symbolic"
    "document-page-setup-symbolic"
    "document-print-preview-symbolic"
    "document-print-symbolic"
    "document-properties-symbolic"
    "document-revert-symbolic-rtl"
    "document-revert-symbolic"
    "document-save-as-symbolic"
    "document-save-symbolic"
    "document-send-symbolic"
    "edit-clear-all-symbolic"
    "edit-clear-symbolic-rtl"
    "edit-clear-symbolic"
    "edit-copy-symbolic"
    "edit-cut-symbolic"
    "edit-delete-symbolic"
    "edit-find-replace-symbolic"
    "edit-find-symbolic"
    "edit-paste-symbolic"
    "edit-redo-symbolic-rtl"
    "edit-redo-symbolic"
    "edit-select-all-symbolic"
    "edit-select-symbolic"
    "edit-undo-symbolic-rtl"
    "edit-undo-symbolic"
    "error-correct-symbolic"
    "find-location-symbolic"
    "folder-new-symbolic"
    "font-select-symbolic"
    "format-indent-less-symbolic-rtl"
    "format-indent-less-symbolic"
    "format-indent-more-symbolic-rtl"
    "format-indent-more-symbolic"
    "format-justify-center-symbolic"
    "format-justify-fill-symbolic"
    "format-justify-left-symbolic"
    "format-justify-right-symbolic"
    "format-text-bold-symbolic"
    "format-text-direction-symbolic-rtl"
    "format-text-direction-symbolic"
    "format-text-italic-symbolic"
    "format-text-strikethrough-symbolic"
    "format-text-underline-symbolic"
    "go-bottom-symbolic"
    "go-down-symbolic"
    "go-first-symbolic-rtl"
    "go-first-symbolic"
    "go-home-symbolic"
    "go-jump-symbolic-rtl"
    "go-jump-symbolic"
    "go-last-symbolic-rtl"
    "go-last-symbolic"
    "go-next-symbolic-rtl"
    "go-next-symbolic"
    "go-previous-symbolic-rtl"
    "go-previous-symbolic"
    "go-top-symbolic"
    "go-up-symbolic"
    "help-about-symbolic"
    "insert-image-symbolic"
    "insert-link-symbolic"
    "insert-object-symbolic"
    "insert-text-symbolic"
    "list-add-symbolic"
    "list-remove-all-symbolic"
    "list-remove-symbolic"
    "mail-forward-symbolic"
    "mail-mark-important-symbolic"
    "mail-mark-junk-symbolic"
    "mail-mark-notjunk-symbolic"
    "mail-message-new-symbolic"
    "mail-reply-all-symbolic"
    "mail-reply-sender-symbolic"
    "mail-send-receive-symbolic"
    "mail-send-symbolic"
    "mark-location-symbolic"
    "media-eject-symbolic"
    "media-playback-pause-symbolic"
    "media-playback-start-symbolic"
    "media-playback-stop-symbolic"
    "media-record-symbolic"
    "media-seek-backward-symbolic"
    "media-seek-forward-symbolic"
    "media-skip-backward-symbolic"
    "media-skip-forward-symbolic"
    "media-view-subtitles-symbolic"
    "object-flip-horizontal-symbolic"
    "object-flip-vertical-symbolic"
    "object-rotate-left-symbolic"
    "object-rotate-right-symbolic"
    "object-select-symbolic"
    "open-menu-symbolic"
    "process-stop-symbolic"
    "send-to-symbolic"
    "sidebar-hide-symbolic"
    "sidebar-show-symbolic"
    "star-new-symbolic"
    "system-log-out-symbolic"
    "system-reboot-symbolic"
    "system-run-symbolic"
    "system-search-symbolic"
    "system-shutdown-symbolic"
    "system-switch-user-symbolic"
    "tab-new-symbolic"
    "tools-check-spelling-symbolic"
    "value-decrease-symbolic"
    "value-increase-symbolic"
    "view-app-grid-symbolic"
    "view-conceal-symbolic"
    "view-continuous-symbolic"
    "view-dual-symbolic"
    "view-fullscreen-symbolic"
    "view-grid-symbolic"
    "view-list-bullet-symbolic"
    "view-list-ordered-symbolic"
    "view-list-symbolic"
    "view-mirror-symbolic"
    "view-more-horizontal-symbolic"
    "view-more-symbolic"
    "view-paged-symbolic"
    "view-pin-symbolic"
    "view-refresh-symbolic"
    "view-restore-symbolic"
    "view-reveal-symbolic"
    "view-sort-ascending-symbolic"
    "view-sort-descending-symbolic"
    "zoom-fit-best-symbolic"
    "zoom-in-symbolic"
    "zoom-original-symbolic"
    "zoom-out-symbolic"))

