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
          !animation-widget
          !animation-button-box
          !animation-preferences-stack
          !skip-backward-bt
          !play-pause-bt
          !skip-forward-bt
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
  ;; child-id slots
  (animation-button-box #:child-id "animation-button-box"
                        #:accessor !animation-button-box)
  (animation-preferences-stack #:child-id "animation-preferences-stack"
                               #:accessor !animation-preferences-stack)
  (animation-scene #:child-id "animation-scene" #:accessor !animation-scene)
  #;(animation-widget #:child-id "animation-widget" #:accessor !animation-widget)
  (skip-backward-bt #:child-id "skip-backward-bt" #:accessor !skip-backward-bt)
  (play-pause-bt #:child-id "play-pause-bt" #:accessor !play-pause-bt)
  (skip-forward-bt #:child-id "skip-forward-bt" #:accessor !skip-forward-bt)
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
  #:child-ids '("animation-scene"
                #;"animation-widget"
                "animation-button-box"
                "animation-preferences-stack"
                "skip-backward-bt"
                "play-pause-bt"
                "skip-forward-bt"
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
  (receive (timed-animation spring-animation)
      (set-animations self)
    (set-expressions self)
    (bind-properties self)
    
    (connect (!animation-preferences-stack self)
             'notify::visible-child-name
             (lambda (stack p-spec)
               (animations-reset self)))

    (connect (!skip-backward-bt self)
             'clicked
             (lambda (b)
               (animations-reset self)))

    (connect (!play-pause-bt self)
             'clicked
             (lambda (b)
               (display-some-animation-sceme-infos self)
               #;(animation-play-pause self)))

    (connect (!skip-forward-bt self)
             'clicked
             (lambda (b)
               (set-custom-layout-manager (!animation-scene self))
               #;(animations-skip self)))

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
    (set-direction (!animation-button-box self) 'ltr)))

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

(define (set-expressions animations-page)
  (let ((ta-easing (!ta-easing animations-page)))
    ;; AdwComboRow requires their expression property to be set, it is
    ;; used to bind strings to the labels produced by the default
    ;; factory (if AdwComboRow:factory is not set).
    (set! (!expression ta-easing)
          (ta-name-expression))

    (bind (animation-can-reset-expression)
          (!skip-backward-bt animations-page)
          "sensitive"
          animations-page)

    (bind (play-pause-icon-name-expression)
          (!play-pause-bt animations-page)
          "icon-name"
          animations-page)

    (bind (animation-can-skip-expression)
          (!skip-forward-bt animations-page)
          "sensitive"
          animations-page)))

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
      (else
       (displayln "Warning: unprocessed adwaita easing name.")
       (enum->name adw-easing value)))))

(define (play-pause-icon-name-expression)
  (make-expression 'string
                   (play-pause-icon-name-closure)
                   '())) ;; flags

(define (play-pause-icon-name-closure)
  (make <closure>
    #:function play-pause-icon-name
    #:return-type 'string
    #:param-types `(,<adw-demo-page-animations>)))

(define (play-pause-icon-name animations-page)
  (let ((timed-state (!state (!timed-animation animations-page)))
        (spring-state (!state (!spring-animation animations-page))))
    #;(dimfi 'get-play-pause-icon-name)
    #;(dimfi "  " 'timed-state timed-state)
    #;(dimfi "  " 'spring-state spring-state)
    (if (or (eq? timed-state 'playing)
            (eq? spring-state 'playing))
        "media-playback-pause-symbolic"
        "media-playback-start-symbolic")))

(define (animation-can-reset-expression)
  (make-expression 'boolean
                   (animation-can-reset-closure)
                   '())) ;; flags

(define (animation-can-reset-closure)
  (make <closure>
    #:function animation-can-reset
    #:return-type 'boolean
    #:param-types `(,<adw-demo-page-animations>)))

(define (animation-can-reset animations-page)
  (let ((timed-state (!state (!timed-animation animations-page)))
        (spring-state (!state (!spring-animation animations-page))))
    #;(dimfi 'animation-can-reset)
    #;(dimfi "  " 'timed-state timed-state)
    #;(dimfi "  " 'spring-state spring-state)
    (and (not (eq? timed-state 'idle))
         (not (eq? spring-state 'idle)))))

(define (animation-can-skip-expression)
  (make-expression 'boolean
                   (animation-can-skip-closure)
                   '())) ;; flags

(define (animation-can-skip-closure)
  (make <closure>
    #:function animation-can-skip
    #:return-type 'boolean
    #:param-types `(,<adw-demo-page-animations>)))

(define (animation-can-skip animations-page)
  (let ((timed-state (!state (!timed-animation animations-page)))
        (spring-state (!state (!spring-animation animations-page))))
    #;(dimfi 'animation-can-skip)
    #;(dimfi "  " 'timed-state timed-state)
    #;(dimfi "  " 'spring-state spring-state)
    (and (not (eq? timed-state 'finished))
         (not (eq? spring-state 'finished)))))

(define (bind-properties animations-page)
  (let ((timed-animation (!timed-animation animations-page))
        (spring-animation (!spring-animation animations-page)))
    ;; timed-animations
    (bind-property (!ta-repeat-count animations-page)
                   "value"
                   timed-animation
                   "repeat-count"
                   '(sync-create bidirectional))
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

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))


;;;
;;; custom layout manager
;;;

(define (set-custom-layout-manager scene)
  #;(dimfi 'set-layout-manager scene)
  (set-layout-manager scene
                      (gtk-custom-layout-new #f
                                             custom-measure
                                             custom-allocate)))

(define (custom-measure scene orientation for-size)
  #;(dimfi-widget-measures 'WITHIN-custom-measure-func scene)
  (let ((child (get-first-child scene)))
    (receive (minimum natural minimum-baseline natural-baseline)
        (measure child orientation for-size)
      #;(dimfi-widget-measures 'CHILD-size child)
      (values minimum natural minimum-baseline natural-baseline))))

(define (custom-allocate scene width height baseline)
  #;(dimfi-widget-measures 'WITHIN-custom-allocate-func scene)
  (let ((child (get-first-child scene))
        (progress (get-progress scene)))
    #;(dimfi-widget-measures 'CHILD-size child)
    (receive (child-width natural minimum-baseline natural-baseline)
        (measure child 'horizontal -1)
      (allocate child width height baseline
                (transform width child-width progress))
      (values))))


;;;
;;; custom layout manager utils
;;;

(define (get-progress scene)
  (let* ((ancestor (get-ancestor scene
                                 (!g-type <adw-demo-page-animations>)))
         (animation (get-current-animation ancestor)))
    (get-value animation)))

(define (get-offset width child-width progress)
  (inexact->exact (* (- width child-width)
                     (- progress 0.5))))

(define (transform width child-width progress)
  (gsk-transform-translate #f
                           (graphene-point-init (graphene-point-alloc)
                                                (get-offset width child-width progress)
                                                0)))


;;;
;;; get currrent animation
;;;

(define (get-current-animation animations-page)
  (let* ((animation-preferences-stack (!animation-preferences-stack animations-page))
         (current-animation (get-visible-child-name animation-preferences-stack)))
    (case (string->symbol current-animation)
      ((Timed)
       (!timed-animation animations-page))
      ((Spring)
       (!spring-animation animations-page))
      (else
       (scm-error 'impossible #f "Unreached current animation: ~S"
                  (list animations-page) #f)))))


;;;
;;; callback
;;;

(define (animation-cb-handler animation-scene)
  (lambda (value user-data)
    (dimfi 'queue-allocate animation-scene)
    (queue-allocate animation-scene)))

(define (animations-reset animations-page)
  (reset (!timed-animation animations-page))
  (reset (!spring-animation animations-page)))

(define (animations-skip animations-page)
  (skip (!timed-animation animations-page))
  (skip (!spring-animation animations-page)))

(define (animation-play-pause animations-page)
  (let* ((animation (get-current-animation animations-page))
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
;;; Debug - utils
;;;

(define (display-some-animation-sceme-infos self)
  (let* ((animation-scene (!animation-scene self))
         (parent (get-ancestor animation-scene
                               (!g-type <adw-clamp>)))
         (child (get-first-child animation-scene)))
    (dimfi-widget-measures 'parent parent)
    (dimfi-widget-measures 'animation-scene animation-scene)
    (dimfi-widget-measures 'child child)))

(define (dimfi-widget-measures title widget)
  (dimfi title)
  (dimfi " " widget)
  (dimfi (format #f "~20,,,' @A:" 'get-width) (get-width widget))
  (dimfi (format #f "~20,,,' @A:" 'get-height) (get-height widget))
  #;(dimfi "  --- (gtk-widget-measure widget 'horizontal -1)")
  #;(receive (minimum natural minimum-baseline natural-baseline)
      (measure widget 'horizontal -1)
    (dimfi (format #f "~20,,,' @A:" 'minimum) minimum)
    (dimfi (format #f "~20,,,' @A:" 'natural) natural)
    (dimfi (format #f "~20,,,' @A:" 'minimum-baseline) minimum-baseline)
    (dimfi (format #f "~20,,,' @A:" 'natural-baseline) natural-baseline))
  #;(dimfi "   --- (gtk-widget-measure widget 'vertical -1)")
  #;(receive (minimum natural minimum-baseline natural-baseline)
      (measure widget 'vertical -1)
    (dimfi (format #f "~20,,,' @A:" 'minimum) minimum)
    (dimfi (format #f "~20,,,' @A:" 'natural) natural)
    (dimfi (format #f "~20,,,' @A:" 'minimum-baseline) minimum-baseline)
    (dimfi (format #f "~20,,,' @A:" 'natural-baseline) natural-baseline)))
