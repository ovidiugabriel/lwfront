#lang racket

;;
;; IEEE Std 1003.1, 2004 Edition
;; http://pubs.opengroup.org/onlinepubs/009695399/basedefs/stdint.h.html
;;

;;
;; Extension to the ISO C standard 
;;
;; The functionality described is an extension to the ISO C standard. 
;; Application writers may make use of an extension as it is supported on all IEEE Std 1003.1-2001-conforming systems.
;;
;; With each function or header from the ISO C standard, a statement to the effect that ``any conflict is unintentional''
;; is included. 
;; That is intended to refer to a direct conflict. 
;; IEEE Std 1003.1-2001 acts in part as a profile of the ISO C standard,
;; and it may choose to further constrain behaviors allowed to vary by the ISO C standard.
;; Such limitations are not considered conflicts.
;;

(provide stdint:int8)
(provide stdint:uint8)
(provide stdint:int16)
(provide stdint:uint16)
(provide stdint:int32)
(provide stdint:uint32)
(provide stdint:int64)
(provide stdint:uint64)
(provide stdint:header)

;; Exact-width integer types

;;
;; The typedef name int N _t designates a signed integer type with width N, no padding bits, 
;; and a two's-complement representation. 
;; Thus, int8_t denotes a signed integer type with a width of exactly 8 bits.
;;
;; The typedef name uint N _t designates an unsigned integer type with width N. 
;; Thus, uint24_t denotes an unsigned integer type with a width of exactly 24 bits.
;;

(define stdint:int8 "int8_t")
(define stdint:uint8 "uint8_t")
(define stdint:int16 "int16_t")
(define stdint:uint16 "uint16_t")
(define stdint:int32 "int32_t")
(define stdint:uint32 "uint32_t")
(define stdint:int64 "int64_t")
(define stdint:uint64 "uint64_t")
(define stdint:header "stdint.h")
