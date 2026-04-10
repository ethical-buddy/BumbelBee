// UEFI From Scratch - ThatOSDev ( 2021 - 2022 )
// https://codeberg.org/ThatOSDev/UEFI-Tuts

#ifndef STDINT_H
#define STDINT_H

//  https://en.wikipedia.org/wiki/C_data_types

#define PAGE_SIZE     4096

#define CHAR_MIN      (-128)
#define CHAR_MAX      127

#define CHAR_BIT      8
#define SCHAR_MIN     (-128)
#define SCHAR_MAX     127
#define UCHAR_MIN      0
#define UCHAR_MAX     255
#define SHRT_MIN      (-1-0x7fff)
#define SHRT_MAX      0x7fff
#define USHRT_MAX     0xffff
#define INT_MIN       (-1-0x7fffffff)
#define INT_MAX       0x7fffffff
#define UINT_MAX      0xffffffffU
#define LONG_MIN      (-LONG_MAX-1)
#define ULONG_MAX     (2UL*LONG_MAX+1)
#define LLONG_MIN     (-LLONG_MAX-1)
#define ULLONG_MAX    (2ULL*LLONG_MAX+1)
#define LONG_BIT      32
#define LONG_MAX      0x7fffffffL
#define LLONG_MAX     0x7fffffffffffffffLL

typedef	int	     bool;
#define	false    0
#define	true	 1

typedef __builtin_va_list   va_list;

#define va_start(ap, param) __builtin_va_start(ap, param)
#define va_end(ap)			__builtin_va_end(ap)
#define va_arg(ap, type)	__builtin_va_arg(ap, type)

#define __va_copy(d,s)      __builtin_va_copy(d,s)

typedef float               float_t;
typedef double              double_t;

typedef signed char         int8_t;
typedef signed short int    int16_t;
typedef signed long int     int32_t;
typedef signed long long    int64_t;

typedef unsigned char       uint8_t;
typedef unsigned short int  uint16_t;
typedef unsigned long int   uint32_t;
typedef unsigned long long  uint64_t;

typedef int8_t              int_fast8_t;
typedef int64_t             int_fast64_t;
				            
typedef int8_t              int_least8_t;
typedef int16_t             int_least16_t;
typedef int32_t             int_least32_t;
typedef int64_t             int_least64_t;
				            
typedef uint8_t             uint_fast8_t;
typedef uint64_t            uint_fast64_t;
				            
typedef uint8_t             uint_least8_t;
typedef uint16_t            uint_least16_t;
typedef uint32_t            uint_least32_t;
typedef uint64_t            uint_least64_t;

#define INT8_MIN            (-1-0x7f)
#define INT16_MIN           (-1-0x7fff)
#define INT32_MIN           (-1-0x7fffffff)
#define INT64_MIN           (-1-0x7fffffffffffffff)
				            
#define INT8_MAX            (0x7f)
#define INT16_MAX           (0x7fff)
#define INT32_MAX           (0x7fffffff)
#define INT64_MAX           (0x7fffffffffffffff)
				            
#define UINT8_MAX           (0xff)
#define UINT16_MAX          (0xffff)
#define UINT32_MAX          (0xffffffff)
#define UINT64_MAX          (0xffffffffffffffff)
						    
#define INT_FAST8_MIN       INT8_MIN
#define INT_FAST64_MIN      INT64_MIN
						    
#define INT_LEAST8_MIN      INT8_MIN
#define INT_LEAST16_MIN     INT16_MIN
#define INT_LEAST32_MIN     INT32_MIN
#define INT_LEAST64_MIN     INT64_MIN
						    
#define INT_FAST8_MAX       INT8_MAX
#define INT_FAST64_MAX      INT64_MAX

#define INT_LEAST8_MAX      INT8_MAX
#define INT_LEAST16_MAX     INT16_MAX
#define INT_LEAST32_MAX     INT32_MAX
#define INT_LEAST64_MAX     INT64_MAX
						    
#define UINT_FAST8_MAX      UINT8_MAX
#define UINT_FAST64_MAX     UINT64_MAX
						    
#define UINT_LEAST8_MAX     UINT8_MAX
#define UINT_LEAST16_MAX    UINT16_MAX
#define UINT_LEAST32_MAX    UINT32_MAX
#define UINT_LEAST64_MAX    UINT64_MAX
						    
#define INTMAX_MIN          INT64_MIN
#define INTMAX_MAX          INT64_MAX
#define UINTMAX_MAX         UINT64_MAX
						    
#define WINT_MIN            0
#define WINT_MAX            UINT32_MAX
						    
#if L'\0'-1 > 0             
#define WCHAR_MAX           (0xffffffffu+L'\0')
#define WCHAR_MIN           (0+L'\0')
#else                       
#define WCHAR_MAX           (0x7fffffff+L'\0')
#define WCHAR_MIN           (-1-0x7fffffff+L'\0')
#endif

#endif  // STDINT_H
    