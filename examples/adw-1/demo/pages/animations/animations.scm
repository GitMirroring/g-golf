;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023 - 2024
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


(define-module (pages animations animations)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)
  #:use-module (pages animations animations-scene)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-animations>))


;; There is actually no need to export these accessors
#;(g-export !timed-animation
          !spring-animation
          !animation-scene
          !animation-sample
          !animation-bt-box
          !skip-backward-bt
          !play-pause-bt
          !skip-forward-bt
          !animation-prefs-stack
          !ta-easing
          !ta-duration
          !ta-repeat-count
          !ta-reverse
          !ta-alternate
          !sa-velocity
          !sa-damping
          !sa-mass
          !sa-stiffness
          !sa-epsilon
          !sa-clamp-switch)


(define-class <adw-demo-page-animations> (<adw-bin>)
  ;; g-object (new) properties
  (timed-animation #:g-param `(object
                                  #:type ,<adw-animation>)
                   #:accessor !timed-animation)
  (spring-animation #:g-param `(object
                                   #:type ,<adw-animation>)
                    #:accessor !spring-animation)
  ;; slots
  (animation-scene #:accessor !animation-scene)
  (current-animation #:accessor !current-animation #:init-value #f)
  ;; child-id slots
  (animation-clamp #:child-id "animation-clamp" #:accessor !animation-clamp)
  (animation-bt-box #:child-id "animation-bt-box" #:accessor !animation-bt-box)
  (skip-backward-bt #:child-id "skip-backward-bt" #:accessor !skip-backward-bt)
  (play-pause-bt #:child-id "play-pause-bt" #:accessor !play-pause-bt)
  (skip-forward-bt #:child-id "skip-forward-bt" #:accessor !skip-forward-bt)
  (animation-prefs-stack #:child-id "animation-prefs-stack" #:accessor !animation-prefs-stack)
  (ta-easing #:child-id "ta-easing" #:accessor !ta-easing)
  (ta-duration #:child-id "ta-duration" #:accessor !ta-duration)
  (ta-repeat-count #:child-id "ta-repeat-count" #:accessor !ta-repeat-count)
  (ta-reverse #:child-id "ta-reverse" #:accessor !ta-reverse)
  (ta-alternate #:child-id "ta-alternate" #:accessor !ta-alternate)
  (sa-velocity #:child-id "sa-velocity" #:accessor !sa-velocity)
  (sa-damping #:child-id "sa-damping" #:accessor !sa-damping)
  (sa-mass #:child-id "sa-mass" #:accessor !sa-mass)
  (sa-stiffness #:child-id "sa-stiffness" #:accessor !sa-stiffness)
  (sa-epsilon #:child-id "sa-epsilon" #:accessor !sa-epsilon)
  (sa-clamp-switch #:child-id "sa-clamp-switch" #:accessor !sa-clamp-switch)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/animations/animations-ui.ui")
  #:child-ids '("animation-clamp"
                "animation-bt-box"
                "skip-backward-bt"
                "play-pause-bt"
                "skip-forward-bt"
                "animation-prefs-stack"
                "ta-easing"
                "ta-duration"
                "ta-repeat-count"
                "ta-reverse"
                "ta-alternate"
                "sa-velocity"
                "sa-damping"
                "sa-mass"
                "sa-stiffness"
                "sa-epsilon"
                "sa-clamp-switch"))

(define-method (initialize (self <adw-demo-page-animations>) initargs)
  (next-method)
  (let ((animation-clamp (!animation-clamp self))
        (animation-scene (make <animation-scene> #:margin-bottom 36))
        (animation-prefs-stack (!animation-prefs-stack self)))
    (set! (!animation-scene self) animation-scene)
    (set-child animation-clamp animation-scene)
    (receive (timed-animation spring-animation)
        (set-animations self)
      (set-expressions self)
      (bind-expressions self)
      (bind-properties self)

      (connect animation-prefs-stack
               'notify::visible-child-name
               (lambda (stack p-spec)
                 (prefs-stack-visible-child-cb self stack)))
      ;; we need to emit the signal, so the current-animation slot is set
      (notify animation-prefs-stack "visible-child-name")

      (connect (!skip-backward-bt self)
               'clicked
               (lambda (b)
                 (animations-reset self)))

      (connect (!play-pause-bt self)
               'clicked
               (lambda (b)
                 (animation-play-pause self)))

      (connect (!skip-forward-bt self)
               'clicked
               (lambda (b)
                 (animations-skip self)))

      (connect (!sa-damping self)
               'notify::value
               (lambda (spin-row p-spec)
                 (notify-spring-params-change self)))

      (connect (!sa-mass self)
               'notify::value
               (lambda (spin-row p-spec)
                 (notify-spring-params-change self)))

      (connect (!sa-stiffness self)
               'notify::value
               (lambda (spin-row p-spec)
                 (notify-spring-params-change self)))

      (set-easing timed-animation 'ease-in-out-cubic)
      (set-follow-enable-animations-setting timed-animation #f)
      (set-follow-enable-animations-setting spring-animation #f)
      (notify self "timed-animation")
      (notify self "spring-animation")
      (set-direction (!animation-bt-box self) 'ltr))))

(define (set-animations animations-page)
  (let* ((animation-scene (!animation-scene animations-page))
         (animation-cb (animation-cb-handler animation-scene))
         (target (adw-callback-animation-target-new animation-cb #f #f))
         (timed-animation (adw-timed-animation-new animation-scene
                                                   0 1 100
                                                   ;; upstream calls (g-object-ref target)
                                                   target))
         (spring-animation (adw-spring-animation-new animation-scene
                                                     0 1
                                                     (adw-spring-params-new-full 10 1 100)
                                                     target)))
    (mslot-set! animations-page
                'timed-animation timed-animation
                'spring-animation spring-animation)
    (values timed-animation spring-animation)))


;;;
;;; set expressions
;;;

(define-method (set-expressions (self <adw-demo-page-animations>))
  (let ((ta-easing (!ta-easing self)))
    ;; AdwComboRow requires their expression property to be set, it is
    ;; used to bind strings to the labels produced by the default
    ;; factory (if AdwComboRow:factory is not set).
    (set! (!expression ta-easing) (ta-name-expression))))

(define (ta-name-expression)
  (make-expression 'string
                   (ta-name-closure)
                   '()))

(define (ta-name-closure)
  (make <closure>
    #:function ta-name
    #:return-type 'string
    #:param-types `(,<adw-enum-list-item>)))

(define (ta-name adw-enum-list-item)
  (let ((adw-easing (gi-cache-ref 'enum 'adw-easing))
        (value (!value adw-enum-list-item)))
    (case (enum->symbol adw-easing value)
      ((linear) "Linear") ;;  later (G_ "Linear")
      ((ease-in-quad) "Ease-in (Quadratic)")
      ((ease-out-quad) "Ease-out (Quadratic)")
      ((ease-in-out-quad) "Ease-in-out (Quadratic)")
      ((ease-in-cubic) "Ease-in (Cubic)")
      ((ease-out-cubic) "Ease-out (Cubic)")
      ((ease-in-out-cubic) "Ease-in-out (Cubic)")
      ((ease-in-quart) "Ease-in (Quartic)")
      ((ease-out-quart) "Ease-out (Quartic)")
      ((ease-in-out-quart) "Ease-in-out (Quartic)")
      ((ease-in-quint) "Ease-in (Quintic)")
      ((ease-out-quint) "Ease-out (Quintic)")
      ((ease-in-out-quint) "Ease-in-out (Quintic)")
      ((ease-in-sine) "Ease-in (Sine)")
      ((ease-out-sine) "Ease-out (Sine)")
      ((ease-in-out-sine) "Ease-in-out (Sine)")
      ((ease-in-expo) "Ease-in (Exponential)")
      ((ease-out-expo) "Ease-out (Exponential)")
      ((ease-in-out-expo) "Ease-in-out (Exponential)")
      ((ease-in-circ) "Ease-in (Circular)")
      ((ease-out-circ) "Ease-out (Circular)")
      ((ease-in-out-circ) "Ease-in-out (Circular)")
      ((ease-in-elastic) "Ease-in (Elastic)")
      ((ease-out-elastic) "Ease-out (Elastic)")
      ((ease-in-out-elastic) "Ease-in-out (Elastic)")
      ((ease-in-back) "Ease-in (Back)")
      ((ease-out-back) "Ease-out (Back)")
      ((ease-in-out-back) "Ease-in-out (Back)")
      ((ease-in-bounce) "Ease-in (Bounce)")
      ((ease-out-bounce) "Ease-out (Bounce)")
      ((ease-in-out-bounce) "Ease-in-out (Bounce)")
      ((ease) "Ease")
      ((ease-in) "Ease-in")
      ((ease-out) "Ease-out")
      ((ease-in-out) "Ease-in-out")
      (else
       (let ((name (enum->name adw-easing value)))
       (displayln (string-append "Warning - Unprocessed adwaita easing name: "
                                 name))
       name)))))


;;;
;;; bind expressions
;;;

(define-method (bind-expressions (self <adw-demo-page-animations>))
  (bind (animation-can-reset-expression self)
        (!skip-backward-bt self)
        "sensitive"
        self)

  (bind (play-pause-icon-name-expression)
        (!play-pause-bt self)
        "icon-name"
        self)

  (bind (animation-can-skip-expression)
        (!skip-forward-bt self)
        "sensitive"
        self))

(define-method (animation-can-reset-expression (self <adw-demo-page-animations>))
  (let* ((ta-lookup (lookup <adw-demo-page-animations> #f "timed-animation"))
         (ta-state-lookup (lookup <adw-animation> ta-lookup "state"))
         (sa-lookup (lookup <adw-demo-page-animations> #f "spring-animation"))
         (sa-state-lookup (lookup <adw-animation> sa-lookup "state")))
    (make-expression 'boolean
                     (animation-can-reset-closure)
                     (list ta-state-lookup sa-state-lookup))))

(define (animation-can-reset-closure)
  (make <closure>
    #:function animation-can-reset?
    #:return-type 'boolean
    #:param-types `(,<adw-demo-page-animations>)))

(define (animation-can-reset? animations-page ta-state sa-state)
    (or (not (eq? ta-state 'idle))
        (not (eq? sa-state 'idle))))

(define (play-pause-icon-name-expression)
  (let* ((ta-lookup (lookup <adw-demo-page-animations> #f "timed-animation"))
         (ta-state-lookup (lookup <adw-animation> ta-lookup "state"))
         (sa-lookup (lookup <adw-demo-page-animations> #f "spring-animation"))
         (sa-state-lookup (lookup <adw-animation> sa-lookup "state")))
    (make-expression 'string
                     (play-pause-icon-name-closure)
                     (list ta-state-lookup sa-state-lookup))))

(define (play-pause-icon-name-closure)
  (make <closure>
    #:function play-pause-icon-name
    #:return-type 'string
    #:param-types `(,<adw-demo-page-animations>)))

(define (play-pause-icon-name animations-page ta-state sa-state)
  (if (or (eq? ta-state 'playing)
          (eq? sa-state 'playing))
      "media-playback-pause-symbolic"
      "media-playback-start-symbolic"))

(define (animation-can-skip-expression)
  (let* ((ta-lookup (lookup <adw-demo-page-animations> #f "timed-animation"))
         (ta-state-lookup (lookup <adw-animation> ta-lookup "state"))
         (sa-lookup (lookup <adw-demo-page-animations> #f "spring-animation"))
         (sa-state-lookup (lookup <adw-animation> sa-lookup "state")))
    (make-expression 'boolean
                     (animation-can-skip-closure)
                     (list ta-state-lookup sa-state-lookup))))

(define (animation-can-skip-closure)
  (make <closure>
    #:function animation-can-skip?
    #:return-type 'boolean
    #:param-types `(,<adw-demo-page-animations>)))

(define (animation-can-skip? animations-page ta-state sa-state)
    (and (not (eq? ta-state 'finished))
         (not (eq? sa-state 'finished))))


;;;
;;; bind properties
;;;

(define (bind-properties animations-page)
  (let ((timed-animation (!timed-animation animations-page))
        (spring-animation (!spring-animation animations-page)))
    ;; timed-animations
    (bind-property (!ta-repeat-count animations-page)	;; source
                   "value"
                   timed-animation			;; target
                   "repeat-count"
                   '(sync-create bidirectional))	;; flags
    (bind-property (!ta-reverse animations-page)
                   "active"
                   timed-animation
                   "reverse"
                   '(sync-create bidirectional))
    (bind-property (!ta-alternate animations-page)
                   "active"
                   timed-animation
                   "alternate"
                   '(sync-create bidirectional))
    (bind-property (!ta-duration animations-page)
                   "value"
                   timed-animation
                   "duration"
                   '(sync-create bidirectional))
    (bind-property (!ta-easing animations-page)
                   "selected"
                   timed-animation
                   "easing"
                   '(sync-create bidirectional))
    ;; spring-anmation
    (bind-property (!sa-velocity animations-page)
                   "value"
                   spring-animation
                   "initial-velocity"
                   '(sync-create bidirectional))
    (bind-property (!sa-epsilon animations-page)
                   "value"
                   spring-animation
                   "epsilon"
                   '(sync-create bidirectional))
    (bind-property (!sa-clamp-switch animations-page)
                   "active"
                   spring-animation
                   "clamp"
                   '(sync-create bidirectional))))


;;;
;;; callback
;;;

(define (animation-cb-handler animation-scene)
  (lambda (value user-data)
    (queue-allocate animation-scene)))

(define (prefs-stack-visible-child-cb animations-page stack)
  (animations-reset animations-page)
  ;; we also need to update the current-animation (animations-page
  ;; instance) slot, as it's used by the <animation-layout>, which
  ;; allows to (drastically) reduces the number of calls to
  ;; get-visible-child-name and string->symbol.
  (let ((visible-child (get-visible-child-name stack)))
    (case (string->symbol visible-child)
      ((Timed)
       (set! (!current-animation animations-page)
             (!timed-animation animations-page)))
      ((Spring)
       (set! (!current-animation animations-page)
             (!spring-animation animations-page))))))

(define (animations-reset animations-page)
  (reset (!timed-animation animations-page))
  (reset (!spring-animation animations-page)))

(define (animations-skip animations-page)
  (skip (!timed-animation animations-page))
  (skip (!spring-animation animations-page)))

(define (animation-play-pause animations-page)
  (let* ((animation (!current-animation animations-page))
         (state (get-state animation)))
    (case state
      ((idle
        finished)
       (play animation))
      ((paused)
       (resume animation))
      ((playing)
       (pause animation))
      (else
       (scm-error 'impossible #f "Unreached current animation: ~S"
                  (list animations-page) #f)))))

(define (notify-spring-params-change animations-page)
  (let ((spring-params
         (adw-spring-params-new-full
          (get-value (!sa-damping animations-page))
          (get-value (!sa-mass animations-page))
          (get-value (!sa-stiffness animations-page)))))
    (set-spring-params (!spring-animation animations-page) spring-params)
    (adw-spring-params-unref spring-params)))


;;;
;;; utils
;;;

(define (lookup type expr name)
  (gtk-property-expression-new (!g-type type) expr name))

(define (make-expression type closure params)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              params))
