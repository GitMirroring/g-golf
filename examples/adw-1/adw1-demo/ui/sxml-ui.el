
;;;;
;;;; Copyright (C) 2023
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


;;;
;;; sxml-ui derived mode
;;;   sxml template ui mode
;;;

(defvar %template-ui-sxml-tags-indent-0
  '(section
    item
    style
    layout))

(defvar %template-ui-sxml-tags-indent-1
  '(interface
    template
    object
    property
    child
    menu
    section
    item
    attribute
    binding
    closure
    lookup
    signal))

(define-derived-mode sxml-ui-mode
  scheme-mode "sxml template ui mode"
  "sxml template ui mode"
  
  (dolist (elt %template-ui-sxml-tags-indent-0)
    (put elt 'scheme-indent-function 0))
  
  (dolist (elt %template-ui-sxml-tags-indent-1)
    (put elt 'scheme-indent-function 1)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(menu\\)\\>"
     . font-lock-constant-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(binding\\)\\>"
     . font-lock-constant-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(section\\)\\>"
     . font-lock-doc-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(item\\)\\>"
     . font-lock-warning-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(property\\)\\>"
     . font-lock-comment-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(attribute\\)\\>"
     . font-lock-comment-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(lookup\\)\\>"
     . font-lock-comment-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(interface\\|template\\)\\>"
     . font-lock-preprocessor-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(requires\\)\\>"
     . font-lock-comment-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(object\\|\\|template\\)\\>"
     . font-lock-preprocessor-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(child\\)\\>"
     . font-lock-warning-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(style\\\|layout\\|condition\\)\\>"
     . font-lock-doc-markup-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(setter\\)\\>"
     . font-lock-type-face)))

(font-lock-add-keywords 'sxml-ui-mode
  '(("\\<\\(version\\|class\\|parent\\|name\\|translatable\\|id\\|bind-source\\|bind-property\\|bind-flags\\|type\\)\\>"
     . font-lock-variable-name-face)))
