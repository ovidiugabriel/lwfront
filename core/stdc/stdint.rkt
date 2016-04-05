#lang racket

(provide stdint:int8)
(provide stdint:uint8)
(provide stdint:int16)
(provide stdint:uint16)
(provide stdint:int32)
(provide stdint:uint32)
(provide stdint:int64)
(provide stdint:uint64)
(provide stdint:header)

(define stdint:int8 "int8_t")
(define stdint:uint8 "uint8_t")
(define stdint:int16 "int16_t")
(define stdint:uint16 "uint16_t")
(define stdint:int32 "int32_t")
(define stdint:uint32 "uint32_t")
(define stdint:int64 "int64_t")
(define stdint:uint64 "uint64_t")
(define stdint:header "stdint.h")