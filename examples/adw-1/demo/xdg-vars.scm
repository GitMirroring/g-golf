;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2026
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf.

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published
;;;; by the Free Software Foundation; either version 3 of the License,
;;;; or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.

;;;; You should have received a copy of the GNU General Public License
;;;;along with GNU G-Golf.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:


(define-module (xdg-vars)
  #:declarative? #f

  #:export (%xdg-data-home
            %xdg-config-home
            %xdg-state-home
            %xdg-cache-home))


(define %xdg-data-home #f)
(define %xdg-config-home #f)
(define %xdg-state-home #f)
(define %xdg-cache-home #f)


(eval-when (expand load eval)
  (let ((home (getenv "HOME")))
    (set! %xdg-data-home
          (or (getenv "$XDG_DATA_HOME")
              (string-append home "/.local/share")))
    (set! %xdg-config-home
          (or (getenv "$XDG_CONFIG_HOME")
              (string-append home "/.config")))
    (set! %xdg-state-home
          (or (getenv "$XDG_STATE_HOME")
              (string-append home "/.local/state")))
    (set! %xdg-cache-home
          (or (getenv "$XDG_CACHE_HOME")
              (string-append home "/.cache")))))
