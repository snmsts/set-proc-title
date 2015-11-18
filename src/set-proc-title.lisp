(in-package :cl-user)
(defpackage set-proc-title
  (:use :cl))
(in-package :set-proc-title)

#+(or linux darwin)
(defvar *argv* (or #+sbcl (sb-alien-internals:alien-value-sap sb-sys::*native-posix-argv*)
		   #+ccl (ccl::%get-kernel-global-ptr 'ccl::argv (ccl::%null-ptr))))
#+(or linux darwin)
(progn
  (cffi:defcvar "environ" :pointer)
  (defun pointer-of-pointer-loop (mem f)
    (loop :for i :from 0
       :for p := (cffi:mem-aref mem :pointer i)
       :until (cffi:null-pointer-p p)
       :collect (funcall f p)))

  (defvar *environment-copied* nil)

  (defun estimate-max-length-argv0 ()
    (unless *environment-copied*
      (flet ((copy-environment ()
               (let* ((str (pointer-of-pointer-loop *environ*
                                                    (lambda (x) (cffi:foreign-string-to-lisp x))))
                      (alloc (cffi:foreign-alloc :pointer :count (length str))))
                 (loop :for e :in str
                    :for i :from 0
                    :do (setf (cffi:mem-aref alloc :pointer i) (cffi:foreign-string-alloc e))
                    (setf *environ* alloc))))
             (f (x) (list (cffi:pointer-address x)
                          (1+ (length (cffi:foreign-string-to-lisp x))))))
        (loop
           :with args := (append (pointer-of-pointer-loop *argv* #'f)
                                 (pointer-of-pointer-loop *environ* #'f))
           :with begin := (first args)
           :for old := nil :then (+ x y)
           :for result := nil :then old
           :for (x y) :in args
           :while (or (not old) (= old x))
           :finally
           (setf *environment-copied* (cons (- (or result (+ x y)) (first begin) 1) (second begin)))
           (copy-environment))))
    *environment-copied*))

#+freebsd
(progn
  (cffi:defcfun ("setproctitle" %setproctitle) :void
    (fmt :string)
    (str :string))
  (defun setproctitle (string)
    (%setproctitle "%s" string)
    string))

#+darwin
(cffi:defcfun ("_NSGetArgv" getargv) :pointer) ;;what for?

(export
 (defun setproctitle (name)
   #+(or linux darwin)
   (let* ((maxlen (first (estimate-max-length-argv0)))
          (initiallen (rest (estimate-max-length-argv0)))
          (b (babel:string-to-octets name))
          (length (length b)))
     (when (>= length maxlen)
       (error "name too long ~A" name))
     (setf (cffi:mem-aref *argv* :pointer 1) (cffi:null-pointer))
     (setf (cffi:mem-aref *argv* :pointer 2) (cffi:null-pointer))
     (loop :for i :from 0 :below initiallen
           :do (setf (cffi:mem-aref (cffi:mem-aref *argv* :pointer) :char i) 0))
     (loop :for i :from 0 :below length
           :do (setf (cffi:mem-aref (cffi:mem-aref *argv* :pointer) :char i)
                     (aref b i)))
     (setf (cffi:mem-aref (cffi:mem-aref *argv* :pointer) :char length) 0))
   #+freebsd
   (setproctitle name)
   name))
