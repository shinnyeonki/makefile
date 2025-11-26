# ==============================================================================
# 고성능 C/C++ 빌드 시스템 (High-Performance C/C++ Build System)
# ==============================================================================
# 특징:
#   - 지연 평가: make help, make clean 실행 시 헤비한 연산(find, pkg-config) 실행 안 됨
#   - 조건부 실행: 빌드 관련 타겟에서만 의존성 분석 수행
#   - 구조적 배치: 변수 정의 → 입력 처리 → 조건부 로직 → 타겟 정의 순서
# ==============================================================================

# ==============================================================================
# 섹션 1: 전역 상수 정의 (Global Constants)
# ==============================================================================
# 동작: 변경 빈도가 낮은 상수들을 최상단에 배치 (ANSI 색상, 확장자, 유틸리티)
# 조건: Makefile 로드 시 즉시 평가되며 이후 변경되지 않음
# ==============================================================================

# ------------------------------------------------------------------------------
# 1.1 ANSI 터미널 색상 코드
# ------------------------------------------------------------------------------
ANSI_RESET                      := \033[0m
ANSI_BOLD                       := \033[0;1m
ANSI_BOLD_UNDERLINE             := \033[0;4m
ANSI_BOLD_UL                    := \033[0;1;4m
ANSI_FG_RED                     := \033[0;31m
ANSI_FG_GREEN                   := \033[0;32m
ANSI_FG_YELLOW                  := \033[0;33m
ANSI_FG_BLUE                    := \033[0;34m
ANSI_FG_MAGENTA                 := \033[0;35m
ANSI_FG_CYAN                    := \033[0;36m
ANSI_FG_BRIGHT_BLUE             := \033[0;94m
ANSI_FG_MAGENTA_BOLD_UNDERLINE  := \033[0;4;35m

# ------------------------------------------------------------------------------
# 1.2 파일 확장자 정의
# ------------------------------------------------------------------------------
EXT_C   := .c
EXT_CPP := .cpp .cc .cxx .C
EXT_HDR := .h .hpp .hh .hxx .H
ALL_EXTS := $(EXT_CPP) $(EXT_C)

# ------------------------------------------------------------------------------
# 1.3 시스템 도구
# ------------------------------------------------------------------------------
MKDIR_P := mkdir -p
FIND_FLAGS := $(foreach ext,$(ALL_EXTS), -name '*$(ext)' -o)

# ==============================================================================
# 섹션 2: 사용자 설정 및 기본값 (User Configuration & Defaults)
# ==============================================================================
# 동작: 사용자가 수정 가능한 변수들을 한 곳에 모음
# 조건: ?= 연산자로 명령줄 오버라이드 허용
# ==============================================================================

# ------------------------------------------------------------------------------
# 2.1 디렉토리 구조
# ------------------------------------------------------------------------------
PROJECT_ROOT ?= .
SRC_ROOT     ?= $(PROJECT_ROOT)
BUILD_ROOT   ?= $(PROJECT_ROOT)/build

# ------------------------------------------------------------------------------
# 2.1.1 설정 변수 출력 플래그
# ------------------------------------------------------------------------------
# CONFIG_PRINT=1 설정 시 빌드 설정 정보 출력
CONFIG_PRINT ?= 0

# ------------------------------------------------------------------------------
# 2.2 컴파일러 설정 (조건부 실행 블록으로 이동 예정)
# ------------------------------------------------------------------------------
# 주의: 이 섹션의 uname 호출은 나중에 조건부 블록으로 이동될 예정
# 현재는 기존 호환성 유지를 위해 여기 배치
CXX ?= g++
CC  ?= gcc

# ------------------------------------------------------------------------------
# 2.3 컴파일 플래그 기본값
# ------------------------------------------------------------------------------

# ==============================================================================
# 전처리기 플래그 (CPPFLAGS) - C/C++ 공통
# ==============================================================================
CPPFLAGS ?=
CPPFLAGS += -I$(SRC_ROOT)                     # 소스 루트 디렉토리 포함
# CPPFLAGS += -I/usr/local/include            # 추가 헤더 경로
# CPPFLAGS += -DDEBUG                         # DEBUG 매크로 정의
# CPPFLAGS += -DNDEBUG                        # assert() 비활성화 (릴리즈)
# CPPFLAGS += -D_FORTIFY_SOURCE=2             # 버퍼 오버플로우 보호 (릴리즈)
# CPPFLAGS += -MMD -MP                        # 의존성 파일 자동 생성

# ==============================================================================
# C++ 컴파일러 플래그 (CXXFLAGS)
# ==============================================================================
CXXFLAGS ?=

# --- C++ 표준 버전 선택 (하나만 주석 해제) ---
# CXXFLAGS += -std=c++11
CXXFLAGS += -std=c++17
# CXXFLAGS += -std=c++20
# CXXFLAGS += -std=c++23

# --- 디버그 모드 (기본) ---
# CXXFLAGS += -O0                               # 최적화 비활성화
# CXXFLAGS += -g                                # 디버그 심볼 생성
# CXXFLAGS += -g3                               # 최대 디버그 정보 (매크로 포함)
CXXFLAGS += -Wall                             # 기본 경고 활성화
# CXXFLAGS += -Wextra                           # 추가 경고 활성화
# CXXFLAGS += -fsanitize=address              # 메모리 오류 검출 (AddressSanitizer)
# CXXFLAGS += -fsanitize=undefined            # 정의되지 않은 동작 검출 (UBSanitizer)
# CXXFLAGS += -fsanitize=thread               # 스레드 경쟁 상태 검출 (ThreadSanitizer)
# CXXFLAGS += -fsanitize=leak                 # 메모리 누수 검출 (LeakSanitizer)
# CXXFLAGS += -D_GLIBCXX_DEBUG                # STL 디버그 모드 (범위 체크 등)
# CXXFLAGS += -D_GLIBCXX_DEBUG_PEDANTIC       # STL 엄격한 디버그 모드
# CXXFLAGS += -D_GLIBCXX_ASSERTIONS           # STL assertion 활성화

# --- 릴리즈 모드 (성능 최적화) ---
# CXXFLAGS += -O1                             # 기본 최적화
# CXXFLAGS += -O2                             # 권장 최적화 (속도/크기 균형)
# CXXFLAGS += -O3                             # 적극적 최적화 (속도 우선)
# CXXFLAGS += -Ofast                          # 최대 속도 (표준 준수 완화)
# CXXFLAGS += -Os                             # 크기 최적화
# CXXFLAGS += -Oz                             # 적극적 크기 최적화 (clang)
# CXXFLAGS += -march=native                   # CPU 특화 최적화
# CXXFLAGS += -mtune=native                   # CPU 튜닝
# CXXFLAGS += -flto                           # Link Time Optimization
# CXXFLAGS += -ffast-math                     # 빠른 수학 연산 (정확도 감소)
# CXXFLAGS += -funroll-loops                  # 루프 언롤링
# CXXFLAGS += -finline-functions              # 함수 인라이닝
# CXXFLAGS += -fomit-frame-pointer            # 프레임 포인터 생략

# --- 코드 크기 최적화 ---
# CXXFLAGS += -ffunction-sections             # 함수별 섹션 분리
# CXXFLAGS += -fdata-sections                 # 데이터별 섹션 분리
# CXXFLAGS += -fno-exceptions                 # 예외 처리 비활성화
# CXXFLAGS += -fno-rtti                       # RTTI 비활성화

# --- 표준 준수 및 호환성 ---
# CXXFLAGS += -Wpedantic                      # 표준 엄격 준수
# CXXFLAGS += -pedantic-errors                # 표준 위반 시 에러 발생
# CXXFLAGS += -ansi                           # ANSI 표준 준수

# --- 경고 옵션 (추가 경고 활성화) ---
# CXXFLAGS += -Wshadow                        # 변수 shadowing 경고
# CXXFLAGS += -Wconversion                    # 암묵적 타입 변환 경고
# CXXFLAGS += -Wsign-conversion               # 부호 변환 경고
# CXXFLAGS += -Wcast-qual                     # const 제거 경고
# CXXFLAGS += -Wcast-align                    # 정렬 위반 경고
# CXXFLAGS += -Wold-style-cast                # C 스타일 캐스트 경고 (C++만)
# CXXFLAGS += -Wunused                        # 사용하지 않는 코드 경고
# CXXFLAGS += -Wdouble-promotion              # float->double 승격 경고
# CXXFLAGS += -Wformat=2                      # printf 포맷 문자열 검사 강화
# CXXFLAGS += -Wnull-dereference              # NULL 역참조 경고
# CXXFLAGS += -Wuninitialized                 # 초기화되지 않은 변수 경고
# CXXFLAGS += -Wstrict-overflow=5             # 정수 오버플로우 경고
# CXXFLAGS += -Wwrite-strings                 # 문자열 리터럴 수정 경고
# CXXFLAGS += -Wpointer-arith                 # 포인터 연산 경고
# CXXFLAGS += -Wredundant-decls               # 중복 선언 경고
# CXXFLAGS += -Wmissing-declarations          # 선언 누락 경고
# CXXFLAGS += -Woverloaded-virtual            # 가상 함수 오버로딩 경고
# CXXFLAGS += -Wnon-virtual-dtor              # 비가상 소멸자 경고
# CXXFLAGS += -Weffc++                        # Effective C++ 규칙 경고
# CXXFLAGS += -Werror                         # 모든 경고를 에러로 처리
# CXXFLAGS += -Wfatal-errors                  # 첫 에러에서 중단

# ==============================================================================
# C 컴파일러 플래그 (CFLAGS)
# ==============================================================================
CFLAGS ?=

# --- C 표준 버전 선택 (하나만 주석 해제) ---
# CFLAGS += -std=c89                          # ANSI C / C89 표준
# CFLAGS += -std=c99                          # C99 표준
CFLAGS += -std=c11                            # C11 표준
# CFLAGS += -std=c17                          # C17 표준
# CFLAGS += -std=c2x                          # C23 표준 (실험적)

# --- 디버그 모드 (기본) ---
# CFLAGS += -O0                                 # 최적화 비활성화
# CFLAGS += -g                                  # 디버그 심볼 생성
# CFLAGS += -g3                                 # 최대 디버그 정보
CFLAGS += -Wall                               # 기본 경고 활성화
# CFLAGS += -Wextra                             # 추가 경고 활성화
# CFLAGS += -fsanitize=address                # 메모리 오류 검출
# CFLAGS += -fsanitize=undefined              # 정의되지 않은 동작 검출

# --- 릴리즈 모드 (성능 최적화) ---
# CFLAGS += -O1                               # 기본 최적화
# CFLAGS += -O2                               # 권장 최적화
# CFLAGS += -O3                               # 적극적 최적화
# CFLAGS += -Ofast                            # 최대 속도
# CFLAGS += -Os                               # 크기 최적화
# CFLAGS += -march=native                     # CPU 특화 최적화
# CFLAGS += -mtune=native                     # CPU 튜닝
# CFLAGS += -flto                             # Link Time Optimization

# --- 코드 크기 최적화 ---
# CFLAGS += -ffunction-sections               # 함수별 섹션 분리
# CFLAGS += -fdata-sections                   # 데이터별 섹션 분리

# --- 표준 준수 및 호환성 ---
# CFLAGS += -Wpedantic                        # 표준 엄격 준수
# CFLAGS += -pedantic-errors                  # 표준 위반 시 에러
# CFLAGS += -ansi                             # ANSI 표준 준수

# --- 경고 옵션 (C 특화) ---
# CFLAGS += -Wshadow                          # 변수 shadowing 경고
# CFLAGS += -Wconversion                      # 타입 변환 경고
# CFLAGS += -Wsign-conversion                 # 부호 변환 경고
# CFLAGS += -Wcast-qual                       # const 제거 경고
# CFLAGS += -Wcast-align                      # 정렬 위반 경고
# CFLAGS += -Wunused                          # 사용하지 않는 코드 경고
# CFLAGS += -Wformat=2                        # printf 포맷 검사
# CFLAGS += -Wnull-dereference                # NULL 역참조 경고
# CFLAGS += -Wuninitialized                   # 초기화되지 않은 변수
# CFLAGS += -Wstrict-prototypes               # 함수 프로토타입 경고 (C 전용)
# CFLAGS += -Wmissing-prototypes              # 프로토타입 누락 경고 (C 전용)
# CFLAGS += -Wold-style-definition            # 구식 함수 정의 경고 (C 전용)
# CFLAGS += -Werror                           # 모든 경고를 에러로 처리

# ==============================================================================
# 링커 플래그 (LDFLAGS)
# ==============================================================================
LDFLAGS ?=

# --- 라이브러리 경로 ---
# LDFLAGS += -L/usr/local/lib                 # 추가 라이브러리 경로
# LDFLAGS += -L$(BUILD_ROOT)/lib              # 빌드 라이브러리 경로

# --- 런타임 경로 설정 (rpath) ---
# LDFLAGS += -Wl,-rpath,/usr/local/lib        # 런타임 라이브러리 경로
# LDFLAGS += -Wl,-rpath,'$$ORIGIN'            # 실행 파일 기준 상대 경로
# LDFLAGS += -Wl,-rpath,'$$ORIGIN/../lib'     # 상대 경로 (../lib)

# --- 최적화 및 링크 옵션 ---
# LDFLAGS += -flto                            # Link Time Optimization
# LDFLAGS += -Wl,-O1                          # 링커 최적화 레벨 1
# LDFLAGS += -Wl,-O2                          # 링커 최적화 레벨 2
# LDFLAGS += -Wl,--gc-sections                # 사용하지 않는 섹션 제거
# LDFLAGS += -Wl,--strip-all                  # 모든 심볼 제거 (릴리즈)
# LDFLAGS += -Wl,--strip-debug                # 디버그 심볼만 제거
# LDFLAGS += -Wl,--as-needed                  # 필요한 라이브러리만 링크

# --- 보안 옵션 ---
# LDFLAGS += -Wl,-z,relro                     # RELRO (Relocation Read-Only)
# LDFLAGS += -Wl,-z,now                       # 즉시 바인딩 (보안 강화)
# LDFLAGS += -Wl,-z,noexecstack               # 실행 불가능한 스택
# LDFLAGS += -pie                             # Position Independent Executable
# LDFLAGS += -fPIE                            # Position Independent Executable

# --- 프로파일링 및 분석 ---
# LDFLAGS += -pg                              # gprof 프로파일링
# LDFLAGS += -fprofile-arcs                   # gcov 커버리지

# --- 디버그 및 개발 옵션 ---
# LDFLAGS += -Wl,--print-memory-usage         # 메모리 사용량 출력
# LDFLAGS += -Wl,--verbose                    # 링커 상세 출력
# LDFLAGS += -Wl,-Map=$(BUILD_ROOT)/output.map # 링크 맵 파일 생성

# ==============================================================================
# 링크 라이브러리 (LDLIBS)
# ==============================================================================
LDLIBS ?=

# --- 표준 라이브러리 ---
# LDLIBS += -lm                               # 수학 라이브러리 (C)
# LDLIBS += -lstdc++                          # C++ 표준 라이브러리
# LDLIBS += -lc                               # C 표준 라이브러리

# --- 스레딩 ---
# LDLIBS += -lpthread                         # POSIX 스레드 라이브러리
# LDLIBS += -latomic                          # Atomic 연산 라이브러리

# --- 시스템 라이브러리 ---
# LDLIBS += -ldl                              # 동적 링킹 로더
# LDLIBS += -lrt                              # 실시간 확장 라이브러리

# --- Boost 라이브러리 ---
# LDLIBS += -lboost_system                    # Boost 시스템
# LDLIBS += -lboost_thread                    # Boost 스레드
# LDLIBS += -lboost_filesystem                # Boost 파일시스템
# LDLIBS += -lboost_program_options           # Boost 프로그램 옵션
# LDLIBS += -lboost_regex                     # Boost 정규표현식

# --- 압축 라이브러리 ---
# LDLIBS += -lz                               # zlib 압축
# LDLIBS += -lbz2                             # bzip2 압축

# --- 암호화 및 보안 ---
# LDLIBS += -lssl                             # OpenSSL
# LDLIBS += -lcrypto                          # OpenSSL 암호화

# --- 데이터베이스 ---
# LDLIBS += -lsqlite3                         # SQLite3
# LDLIBS += -lmysqlclient                     # MySQL

# --- 네트워킹 ---
# LDLIBS += -lcurl                            # libcurl

# --- 프로파일링 및 분석 ---
# LDLIBS += -lgcov                            # gcov 커버리지
# LDLIBS += -lprofiler                        # Google perftools profiler

# ==============================================================================
# 추가 컴파일러 옵션 (C/C++ 공통)
# ==============================================================================

# --- 멀티스레딩 지원 ---
# CFLAGS   += -pthread                        # POSIX 스레드 지원 (C)
# CXXFLAGS += -pthread                        # POSIX 스레드 지원 (C++)

# --- 색상 출력 (진단 메시지) ---
# CFLAGS   += -fdiagnostics-color=always      # 항상 색상 출력 (GCC)
# CXXFLAGS += -fdiagnostics-color=always      # 항상 색상 출력 (GCC)
# CFLAGS   += -fcolor-diagnostics             # 색상 출력 (Clang)
# CXXFLAGS += -fcolor-diagnostics             # 색상 출력 (Clang)

# --- 스택 보호 ---
# CFLAGS   += -fstack-protector               # 기본 스택 보호
# CXXFLAGS += -fstack-protector               # 기본 스택 보호
# CFLAGS   += -fstack-protector-strong        # 강화된 스택 보호
# CXXFLAGS += -fstack-protector-strong        # 강화된 스택 보호
# CFLAGS   += -fstack-protector-all           # 모든 함수 스택 보호
# CXXFLAGS += -fstack-protector-all           # 모든 함수 스택 보호

# --- Position Independent Code ---
# CFLAGS   += -fPIC                           # PIC 생성 (공유 라이브러리)
# CXXFLAGS += -fPIC                           # PIC 생성 (공유 라이브러리)

# --- 실행 시간 체크 ---
# CFLAGS   += -fstack-clash-protection        # 스택 충돌 보호
# CXXFLAGS += -fstack-clash-protection        # 스택 충돌 보호
# CFLAGS   += -fcf-protection                 # 제어 흐름 보호
# CXXFLAGS += -fcf-protection                 # 제어 흐름 보호

# ==============================================================================
# 주석 제거 처리 (Remove Comments from Flag Variables)
# ==============================================================================
# 동작: 변수에 포함된 인라인 주석(#로 시작하는 부분)과 연속 공백을 제거
# 조건: CPPFLAGS, CXXFLAGS, CFLAGS, LDFLAGS, LDLIBS에 적용
# 이유: 주석이 포함된 변수가 컴파일러/링커에 전달되는 것을 방지
# ==============================================================================
H := \#
CPPFLAGS := $(strip $(shell echo '$(CPPFLAGS)' | sed 's/[[:space:]]*$(H)[^$(H)]*//g'))
CXXFLAGS := $(strip $(shell echo '$(CXXFLAGS)' | sed 's/[[:space:]]*$(H)[^$(H)]*//g'))
CFLAGS   := $(strip $(shell echo '$(CFLAGS)' | sed 's/[[:space:]]*$(H)[^$(H)]*//g'))
LDFLAGS  := $(strip $(shell echo '$(LDFLAGS)' | sed 's/[[:space:]]*$(H)[^$(H)]*//g'))
LDLIBS   := $(strip $(shell echo '$(LDLIBS)' | sed 's/[[:space:]]*$(H)[^$(H)]*//g'))

# ------------------------------------------------------------------------------
# 2.4 pkg-config 라이브러리 설정
# ------------------------------------------------------------------------------
PKGS ?=

# ------------------------------------------------------------------------------
# 2.5 추가 소스 파일 수동 지정 (Manual Source Files)
# ------------------------------------------------------------------------------
# 설명: 의존성 탐색과 관계없이 강제로 포함할 소스 파일들
# 사용법: 파일 내에 직접 적거나, CLI에서 SRCS="foo.cpp bar.c" 형태로 전달
SRCS ?=

# ==============================================================================
# 섹션 3: 입력 변수 처리 및 정규화 (Input Processing)
# ==============================================================================
# 동작: CLI에서 전달된 별칭을 정식 변수명으로 변환하고 검증
# 조건: 빈 값은 무시하여 기본값 설정이 정상 작동하도록 함
# ==============================================================================

# ------------------------------------------------------------------------------
# 3.1 변수 별칭 매핑 (CLI Alias Mapping)
# ------------------------------------------------------------------------------
USER_SRC    := $(strip $(or $(firstword $(s)),$(SRC)))
MAIN_SRC    := $(strip $(or $(firstword $(m)),$(MAIN_SRC)))
MODE_LOG    := $(strip $(or $(firstword $(l)),$(MODE_LOG),normal))
MODE_DEPS   := $(strip $(or $(firstword $(d)),$(MODE_DEPS),path))
MODE_TARGET := $(strip $(or $(firstword $(t)),$(MODE_TARGET),executable))
LIB_NAME    := $(strip $(or $(firstword $(n)),$(LIB_NAME)))
STDIN       := $(strip $(or $(firstword $(i)),$(STDIN)))
STDOUT      := $(strip $(or $(firstword $(o)),$(STDOUT)))
STDERR      := $(strip $(or $(firstword $(e)),$(STDERR)))
ARGS        := $(strip $(or $(firstword $(a)),$(ARGS)))

# ------------------------------------------------------------------------------
# 3.2 의존성 모드 별칭 정규화
# ------------------------------------------------------------------------------
override MODE_DEPS := $(strip \
  $(if $(filter s,$(MODE_DEPS)),standalone,\
  $(if $(filter p,$(MODE_DEPS)),path,\
  $(if $(filter f,$(MODE_DEPS)),file,\
  $(if $(filter a,$(MODE_DEPS)),all,\
  $(MODE_DEPS))))))
MODE_DEPS := $(strip $(MODE_DEPS))
ifneq ($(filter $(MODE_DEPS), path file standalone all),)
    MODE_DEPS := $(MODE_DEPS)
else
    $(warning [경고] 지원하지 않는 의존성 모드: '$(MODE_DEPS)' → 기본값 'path'로 설정)
    MODE_DEPS := path
endif

# ------------------------------------------------------------------------------
# 3.3 출력 모드 값 정규화
# ------------------------------------------------------------------------------
override MODE_LOG := $(strip \
  $(if $(filter v,$(MODE_LOG)),verbose,\
  $(if $(filter s,$(MODE_LOG)),silent,\
  $(if $(filter n,$(MODE_LOG)),normal,\
  $(if $(filter b,$(MODE_LOG)),binary,\
  $(if $(filter r,$(MODE_LOG)),raw,\
  $(MODE_LOG)))))))

MODE_LOG := $(strip $(MODE_LOG))
ifneq ($(filter $(MODE_LOG), normal silent verbose binary raw),)
    LOG_MODE := $(MODE_LOG)
else
    $(warning [경고] 지원하지 않는 출력 모드: '$(MODE_LOG)' → 기본값 'normal'로 설정)
    LOG_MODE := normal
endif

# ------------------------------------------------------------------------------
# 3.5 실행 인자 구성
# ------------------------------------------------------------------------------
FINAL_ARGS :=
ifneq ($(STDIN),)
    FINAL_ARGS += < $(STDIN)
endif
ifneq ($(STDOUT),)
    FINAL_ARGS += > $(STDOUT)
endif
ifneq ($(STDERR),)
    FINAL_ARGS += 2> $(STDERR)
endif
ifneq ($(ARGS),)
    FINAL_ARGS += $(ARGS)
endif

# ------------------------------------------------------------------------------
# 3.6 빌드 타겟 타입 별칭 정규화
# ------------------------------------------------------------------------------
override MODE_TARGET := $(strip \
  $(if $(filter exe bin out,$(MODE_TARGET)),executable,\
  $(if $(filter so dll dylib,$(MODE_TARGET)),shared,\
  $(if $(filter a,$(MODE_TARGET)),static,\
  $(MODE_TARGET)))))

# ------------------------------------------------------------------------------
# 3.7 라이브러리 모드 기본 설정
# ------------------------------------------------------------------------------
ifneq ($(MODE_TARGET),executable)
    CFLAGS   += -fPIC
    CXXFLAGS += -fPIC
endif

# ------------------------------------------------------------------------------
# 3.8 라이브러리 경로 계산 (빌드 타겟에서 최종 검증)
# ------------------------------------------------------------------------------
LIB_PATH :=
ifneq ($(LIB_NAME),)
    ifeq ($(findstring /,$(LIB_NAME)),)
        LIB_PATH := $(BUILD_ROOT)/$(LIB_NAME)
    else
        LIB_PATH := $(LIB_NAME)
    endif
endif

# ==============================================================================
# 섹션 4: 로깅 시스템 (Logging System)
# ==============================================================================
# 동작: LOG_MODE에 따라 로그 매크로 정의
# 조건: 출력 모드별로 조건부 분기
# ==============================================================================

# ------------------------------------------------------------------------------
# 4.1 모드: normal (일반 모드)
# ------------------------------------------------------------------------------
ifeq ($(LOG_MODE),normal)
    LOG_CFG_AUTO                = @echo "$(ANSI_FG_BLUE)[정보] MAIN_SRC 미지정. 프로젝트 내 main 파일을 자동 탐색합니다.$(ANSI_RESET)"
    LOG_CFG_MANUAL              = @echo "$(ANSI_FG_BLUE)[정보] 수동 모드. 다음 파일을 빌드합니다: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)"
    LOG_CFG_TARGET              = @echo "$(ANSI_FG_BLUE)[정보] 빌드 대상: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)"
    ERR_CFG_NO_MAIN             := "[설정 오류] 'main.c' 또는 'main.cpp'를 찾을 수 없습니다."
    WRN_CFG_INVALID_MODE        := "$(ANSI_FG_RED)[설정 오류] 지원하지 않는 출력 모드입니다.$(ANSI_RESET)"
    ERR_CFG_FILE_NOT_FOUND      := "$(ANSI_FG_RED)[파일 오류] 지정된 소스 파일이 존재하지 않습니다.$(ANSI_RESET)"
    ERR_CFG_FILE_INVALID_EXT    := "$(ANSI_FG_RED)[파일 오류] 지정된 파일이 C/C++ 소스가 아닙니다.$(ANSI_RESET)"
    WRN_CFG_FILE_NO_HEADER      := "$(ANSI_FG_YELLOW)[파일 경고] 필수 헤더 파일을 찾을 수 없습니다.$(ANSI_RESET)"
    WRN_CFG_EXPERIMENTAL        := "[설정 경고] 실험적 기능이 활성화되었습니다: 전이적 의존성 탐색 (느릴 수 있음)"
    ERR_CFG_LIB_NO_NAME         := "[설정 오류] 라이브러리 빌드 시 결과물 이름(LIB_NAME=filename) 지정이 필수입니다."
    ERR_RUN_NOT_EXE             := "[설정 오류] 라이브러리(shared/static) 모드에서 run 타겟은 불가능합니다."
    LOG_CLN_MARKER_OK           = @echo "$(ANSI_FG_GREEN)[안전] 빌드 폴더의 빌드 마커 확인 완료. 삭제를 진행합니다.$(ANSI_RESET)"
    LOG_CLN_SUCCESS             = @echo "$(ANSI_FG_GREEN)[완료] 빌드 디렉토리 삭제: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(BUILD_ROOT)$(ANSI_RESET)"
    ERR_CLN_NO_MARKER           := $(ANSI_FG_RED)[안전 오류] 빌드 마커가 없습니다. 이 디렉토리는 이 Makefile로 생성되지 않았습니다.$(ANSI_RESET)
    ERR_CLN_DANGEROUS           := $(ANSI_FG_RED)[안전 오류] 안전하지 않은 경로입니다. 삭제를 거부합니다.$(ANSI_RESET)
    LOG_BLD_MARKER_CREATE       = @echo "$(ANSI_FG_BLUE)[안전] 빌드 마커 생성: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(BUILD_ROOT)/.make_safe_marker$(ANSI_RESET)"
    LOG_BLD_START               = @echo "$(ANSI_FG_BLUE)[시작] 빌드 프로세스를 시작합니다.$(ANSI_RESET)"
    LOG_BLD_COMPILE             = @printf "$(ANSI_FG_CYAN)[컴파일]$(ANSI_RESET) $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)%s$(ANSI_RESET) $(ANSI_FG_BRIGHT_BLUE)=>$(ANSI_RESET) $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)%s$(ANSI_RESET)\n" "$(1)" "$(2)"
    LOG_BLD_LINK                = @echo "$(ANSI_FG_CYAN)[링킹] 실행 파일 생성: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)"
    LOG_BLD_SUCCESS             = @echo "$(ANSI_FG_GREEN)[완료] 생성된 바이너리: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)"
    ERR_BLD_COMPILE             := $(ANSI_FG_RED)[빌드 실패] 컴파일 실패$(ANSI_RESET)
    ERR_BLD_LINK                := $(ANSI_FG_RED)[빌드 실패] 링킹 실패$(ANSI_RESET)
    WRN_CFG_INVALID_MODE        := $(ANSI_FG_YELLOW)[빌드 경고] 전처리 및 의존성 분석 실패$(ANSI_RESET)
    LOG_RUN_EXEC                = @echo "$(ANSI_FG_GREEN)[실행] 프로그램 실행: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)..."
    LOG_RUN_START               = @echo "$(ANSI_FG_GREEN)[실행] 프로그램 실행: $(ANSI_FG_MAGENTA_BOLD_UNDERLINE)$(1)$(ANSI_RESET)"
    ERR_RUN_NO_BIN              := $(ANSI_FG_RED)[실행 오류] 실행할 파일이 없습니다.$(ANSI_RESET)
    ERR_RUN_FAIL                := $(ANSI_FG_RED)[실행 오류] 프로그램 실행 중 런타임 에러가 발생했습니다.$(ANSI_RESET)
    Q                           := @
    ABORT_ON_ERR                = || ( echo "$(1)" >&2; exit 1 )
    FMT_ERR                     = $(1)
    FMT_WRN                     = $(1)
    LOG_BUILD_FINISH            := @:

# ------------------------------------------------------------------------------
# 4.2 모드: verbose (상세 모드)
# ------------------------------------------------------------------------------
else ifeq ($(LOG_MODE),verbose)
    LOG_CFG_AUTO                = @echo "[INFO] Auto-detecting main source file."
    LOG_CFG_MANUAL              = @echo "[INFO] Manual mode selected. File: $(1)"
    LOG_CFG_TARGET              = @echo "[INFO] Target binary: $(1)"
    ERR_CFG_NO_MAIN             := [CONFIG ERROR] Could not find main.c or main.cpp.
    WRN_CFG_INVALID_MODE        := [CONFIG ERROR] Unsupported output mode specified.
    ERR_CFG_FILE_NOT_FOUND      := [FILE ERROR] The specified file does not exist
    ERR_CFG_FILE_INVALID_EXT    := [FILE ERROR] The specified file is not a valid C/C++ extension
    WRN_CFG_FILE_NO_HEADER      := [FILE ERROR] Required header file not found.
    WRN_CFG_EXPERIMENTAL        := [CONFIG WARNING] Experimental feature enabled: Transitive dependency discovery (may be slow).
    ERR_CFG_LIB_NO_NAME         := "[CONFIG ERROR] Library build requires a name (n=filename)."
    LOG_CLN_SUCCESS             = @echo "[INFO] Cleaning build directory: $(BUILD_ROOT)"
    LOG_CLN_MARKER_OK           = @echo "[SAFE] Build marker verified. Proceeding with deletion."
    ERR_CLN_NO_MARKER           := [SAFETY ERROR] Build marker not found. This directory was not created by this Makefile.
    ERR_CLN_DANGEROUS           := [SAFETY ERROR] Unsafe path detected. Deletion refused.
    LOG_BLD_MARKER_CREATE       = @echo "[SAFE] Creating build marker: $(BUILD_ROOT)/.make_safe_marker"
    LOG_BLD_START               = @echo "[INFO] Build process started."
    LOG_BLD_COMPILE             = @echo "[INFO] Compiling: $(1)"
    LOG_BLD_LINK                = @echo "[INFO] Linking object files to: $(1)"
    LOG_BLD_SUCCESS             = @echo "[INFO] Build successful. Binary at: $(1)"
    ERR_BLD_COMPILE             := [BUILD FAILED] Compilation error
    ERR_BLD_LINK                := [BUILD FAILED] Linking error
    WRN_CFG_INVALID_MODE        := [BUILD FAILED] Preprocessing and dependency analysis failed
    LOG_RUN_EXEC                = @echo "[INFO] Executing binary: $(1)"
    LOG_RUN_START               = @echo "[INFO] Executing binary: $(1)"
    ERR_RUN_NOT_EXE             := "[CONFIG ERROR] Cannot run target with library mode."
    ERR_RUN_NO_BIN              := [RUNTIME ERROR] Executable not found
    ERR_RUN_FAIL                := [RUNTIME ERROR] Runtime error occurred during program execution.
    Q                           :=
    ABORT_ON_ERR                = || ( echo "$(1)" >&2; exit 1 )
    FMT_ERR                     = $(1)
    FMT_WRN                     = $(1)
    LOG_BUILD_FINISH            := @:

# ------------------------------------------------------------------------------
# 4.3 모드: silent (조용한 모드)
# ------------------------------------------------------------------------------
else ifeq ($(LOG_MODE),silent)
    LOG_CFG_AUTO                = @:
    LOG_CFG_MANUAL              = @:
    LOG_CFG_TARGET              = @:
    ERR_CFG_NO_MAIN             := Config error: Main file not found.
    WRN_CFG_INVALID_MODE        := Config error: Invalid output mode.
    ERR_CFG_FILE_NOT_FOUND      := File error: Source file not found.
    ERR_CFG_FILE_INVALID_EXT    := File error: Not a source file.
    WRN_CFG_FILE_NO_HEADER      := File error: Header file not found.
    WRN_CFG_EXPERIMENTAL        := Config warning: Experimental feature enabled.
    ERR_CFG_LIB_NO_NAME         := Config error: Missing library name.
    LOG_CLN_SUCCESS             = @:
    LOG_CLN_MARKER_OK           = @:
    ERR_CLN_NO_MARKER           := Safety error: No build marker found.
    ERR_CLN_DANGEROUS           := Safety error: Unsafe path.
    LOG_BLD_MARKER_CREATE       = @:
    LOG_BLD_START               = @:
    LOG_BLD_COMPILE             = @:
    LOG_BLD_LINK                = @:
    LOG_BLD_SUCCESS             = @:
    ERR_BLD_COMPILE             := Build failed: Compilation failed
    ERR_BLD_LINK                := Build failed: Linking failed
    WRN_CFG_INVALID_MODE        := Build failed: Preprocessing failed
    LOG_RUN_EXEC                = @:
    LOG_RUN_START               = @:
    ERR_RUN_NO_BIN              := Runtime error: Binary not found.
    ERR_RUN_FAIL                := Runtime error: Execution failed.
    ERR_RUN_NOT_EXE             := Config error: Target is not executable.
    Q                           := @
    ABORT_ON_ERR                = || ( echo "$(1)" >&2; exit 1 )
    FMT_ERR                     = $(1)
    FMT_WRN                     = $(1)
    LOG_BUILD_FINISH            := @:

# ------------------------------------------------------------------------------
# 4.4 모드: binary (바이너리 경로 출력)
# ------------------------------------------------------------------------------
else ifeq ($(LOG_MODE),binary)
    LOG_CFG_AUTO                = @:
    LOG_CFG_MANUAL              = @:
    LOG_CFG_TARGET              = @:
    ERR_CFG_NO_MAIN             := [CONFIG] No main file
    WRN_CFG_INVALID_MODE        := [CONFIG] Invalid mode
    ERR_CFG_FILE_NOT_FOUND      := [FILE] Missing file
    ERR_CFG_FILE_INVALID_EXT    := [FILE] Invalid type
    WRN_CFG_FILE_NO_HEADER      := [FILE] No header
    WRN_CFG_EXPERIMENTAL        := [CONFIG] Experimental feature enabled.
    ERR_CFG_LIB_NO_NAME         := [CONFIG] No lib name
    LOG_CLN_SUCCESS             = @:
    LOG_CLN_MARKER_OK           = @:
    ERR_CLN_NO_MARKER           := [SAFETY] No marker
    ERR_CLN_DANGEROUS           := [SAFETY] Unsafe path
    LOG_BLD_MARKER_CREATE       = @:
    LOG_BLD_START               = @:
    LOG_BLD_COMPILE             = @:
    LOG_BLD_LINK                = @:
    LOG_BLD_SUCCESS             = @:
    ERR_BLD_COMPILE             := [BUILD] Compile error
    ERR_BLD_LINK                := [BUILD] Link error
    WRN_CFG_INVALID_MODE        := [BUILD] Preproc error
    LOG_RUN_EXEC                = @:
    LOG_RUN_START               = @:
    ERR_RUN_NO_BIN              := [RUN] No binary
    ERR_RUN_FAIL                := [RUN] Runtime error
    ERR_RUN_NOT_EXE             := [CONFIG] Not executable
    Q                           := @
    ABORT_ON_ERR                = ||  exit 1
    FMT_ERR                     = $(1)
    FMT_WRN                     = $(1)
    LOG_BUILD_FINISH            = @echo "$(1)"

# ------------------------------------------------------------------------------
# 4.5 모드: raw (원시 출력)
# ------------------------------------------------------------------------------
else ifeq ($(LOG_MODE),raw)
    LOG_CFG_AUTO                = @:
    LOG_CFG_MANUAL              = @:
    LOG_CFG_TARGET              = @:
    ERR_CFG_NO_MAIN             :=
    WRN_CFG_INVALID_MODE        :=
    ERR_CFG_FILE_NOT_FOUND      :=
    ERR_CFG_FILE_INVALID_EXT    :=
    WRN_CFG_FILE_NO_HEADER      :=
    WRN_CFG_EXPERIMENTAL        :=
    ERR_CFG_LIB_NO_NAME         :=
    LOG_CLN_SUCCESS             = @:
    LOG_CLN_MARKER_OK           = @:
    ERR_CLN_NO_MARKER           :=
    ERR_CLN_DANGEROUS           :=
    LOG_BLD_MARKER_CREATE       = @:
    LOG_BLD_START               = @:
    LOG_BLD_COMPILE             = @:
    LOG_BLD_LINK                = @:
    LOG_BLD_SUCCESS             = @:
    ERR_BLD_COMPILE             :=
    ERR_BLD_LINK                :=
    WRN_CFG_INVALID_MODE        :=
    LOG_RUN_EXEC                = @:
    LOG_RUN_START               = @:
    ERR_RUN_NO_BIN              :=
    ERR_RUN_FAIL                :=
    ERR_RUN_NOT_EXE             :=
    Q                           :=
    ABORT_ON_ERR                =
    FMT_ERR                     = $(1)
    FMT_WRN                     = $(1)
    LOG_BUILD_FINISH            := @:
endif
# ==============================================================================
# 섹션 5: 조건부 로직 및 환경 감지 (Conditional Logic - Build Targets Only)
# ==============================================================================
# 동작: 빌드 관련 타겟이 호출될 때만 실행되는 헤비한 연산들
# 조건: $(MAKECMDGOALS)에 TARGET_GOALS가 포함될 때만 실행
# 효과: make help, make clean 실행 시 0.1초 이하로 즉시 반응
# ==============================================================================

TARGET_GOALS := build run build-run clean-build clean-build-run list-headers

ifneq ($(filter $(TARGET_GOALS),$(MAKECMDGOALS)),)

    # --------------------------------------------------------------------------
    # 5.0 실행 불가능한 조합 사전 차단 (Fail Fast)
    # --------------------------------------------------------------------------
    # 설명: 사용자가 run 관련 타겟을 요청했으나, TARGET_TYPE이 executable이 아닌 경우 즉시 중단
    RUN_GOALS := run build-run clean-build-run
    ifneq ($(filter $(RUN_GOALS),$(MAKECMDGOALS)),)
        ifneq ($(MODE_TARGET),executable)
            $(error $(call FMT_ERR,$(ERR_RUN_NOT_EXE)))
        endif
    endif

    # --------------------------------------------------------------------------
    # 5.1 OS 감지 및 컴파일러 자동 선택
    # --------------------------------------------------------------------------
    _UNAME_S := $(shell uname -s)
    ifeq ($(_UNAME_S),Darwin)
        CXX ?= clang++
        CC ?= clang
    else ifeq ($(_UNAME_S),Linux)
        CXX ?= g++
        CC ?= gcc
    else
        CXX ?= g++
        CC ?= gcc
    endif

    # --------------------------------------------------------------------------
    # 5.2 pkg-config 처리
    # --------------------------------------------------------------------------
    ifneq ($(PKGS),)
        HAS_PKG_CONFIG := $(shell which pkg-config 2>/dev/null)
        ifeq ($(HAS_PKG_CONFIG),)
            $(error $(ANSI_FG_RED)[설정 오류] 'pkg-config'가 설치되어 있지 않습니다. PKGS 옵션을 사용하려면 pkg-config가 필요합니다.$(ANSI_RESET))
        endif
        PKG_EXISTS := $(shell pkg-config --exists $(PKGS) && echo 1 || echo 0)
        ifeq ($(PKG_EXISTS),0)
            PKG_ERR := $(shell pkg-config --errors-to-stdout --print-errors $(PKGS))
            $(error $(ANSI_FG_RED)[패키지 오류] 다음 라이브러리를 찾을 수 없습니다: $(PKGS)$(ANSI_RESET)$(n)$(ANSI_FG_YELLOW)$(PKG_ERR)$(ANSI_RESET))
        else
            PKG_CFLAGS := $(shell pkg-config --cflags $(PKGS))
            PKG_LIBS   := $(shell pkg-config --libs $(PKGS))
            CFLAGS   += $(PKG_CFLAGS)
            CXXFLAGS += $(PKG_CFLAGS)
            LDLIBS   += $(PKG_LIBS)
            ifeq ($(MODE_LOG),verbose)
                $(info [INFO] pkg-config: Found $(PKGS))
                $(info [INFO] pkg-config CFLAGS: $(PKG_CFLAGS))
                $(info [INFO] pkg-config LIBS: $(PKG_LIBS))
            endif
        endif
    endif

    # --------------------------------------------------------------------------
    # 5.3 소스 파일 탐색 (지연 평가)
    # --------------------------------------------------------------------------
    _PROJECT_FILE_POOL = $(shell find $(SRC_ROOT) -type f \( $(FIND_FLAGS) -false \) -not -path '$(BUILD_ROOT)/*' | sed 's|^./||' | sort -u)

    # --------------------------------------------------------------------------
    # 5.4 유틸리티 함수 정의
    # --------------------------------------------------------------------------
    IS_C = $(if $(filter $(suffix $(1)),$(EXT_C)),1,)
    IS_CPP = $(if $(filter $(suffix $(1)),$(EXT_CPP)),1,)
    IS_SRC = $(or $(call IS_C,$(1)),$(call IS_CPP,$(1)))

    # --------------------------------------------------------------------------
    # 5.5 실행 파일 빌드 모드
    # --------------------------------------------------------------------------
    ifeq ($(MODE_TARGET),executable)
        # 1. 메인 소스 파일 결정
        ifeq ($(MAIN_SRC),)
            MAIN_SRC_AUTO := $(firstword $(filter %main.cpp %main.c,$(_PROJECT_FILE_POOL)))
            ifeq ($(MAIN_SRC_AUTO),)
                $(error $(call FMT_ERR,$(ERR_CFG_NO_MAIN)))
            endif
            _SRC_MAIN_NORM := $(MAIN_SRC_AUTO)
            CMD_LOG_MODE  := $(LOG_CFG_AUTO)
        else
            _SRC_MAIN_NORM := $(shell echo $(MAIN_SRC) | sed 's|^./||')
            ifeq ($(wildcard $(_SRC_MAIN_NORM)),)
                $(error $(call FMT_ERR,$(ERR_CFG_FILE_NOT_FOUND): $(_SRC_MAIN_NORM)))
            endif
            ifneq ($(call IS_SRC,$(_SRC_MAIN_NORM)),1)
                $(error $(call FMT_ERR,$(ERR_CFG_FILE_INVALID_EXT): $(_SRC_MAIN_NORM)))
            endif
            CMD_LOG_MODE := $(call LOG_CFG_MANUAL,$(_SRC_MAIN_NORM))
        endif

        # 2. 사용자 추가 소스 정규화 (USER_SRCS -> _USER_SRCS_NORM)
        # 사용자가 make SRCS="a.c b.c" 로 입력했거나 파일에 SRCS를 정의한 경우 처리
        _USER_SRCS_NORM :=
        ifneq ($(USER_SRCS),)
            _USER_SRCS_NORM := $(shell echo $(USER_SRCS) | sed 's|^./||')
        endif

        # 3. 빌드 타겟 경로 생성
        _TARGET := $(BUILD_ROOT)/$(basename $(_SRC_MAIN_NORM))
        CMD_LOG_MODE := $(call LOG_CFG_TARGET,$(_TARGET) [$(MODE_TARGET)])

        # 4. 컴파일러 선택 및 기본 전처리기 설정
        ifeq ($(call IS_CPP,$(_SRC_MAIN_NORM)),1)
            PREPROC := $(CXX) $(CPPFLAGS) $(CXXFLAGS)
        else
            PREPROC := $(CC) $(CPPFLAGS) $(CFLAGS)
        endif

        # 5. 헤더 파싱 헬퍼 매크로
        EXTRACT_HEADERS = $(sort $(filter $(foreach ext,$(EXT_HDR),%$(ext)),$(subst \, ,$(subst :, ,$(1)))))

        # 6. [Step 1] 의존성 모드별 자동 탐색 결과(_DISCOVERED_SRCS) 결정
        # 주의: 여기서는 MAIN_SRC 만을 기준으로 탐색합니다. (USER_SRCS는 제외)
        ifeq ($(MODE_DEPS),standalone)
            _DISCOVERED_SRCS := $(_SRC_MAIN_NORM)

        else ifeq ($(MODE_DEPS),path)
            # path 모드: MAIN_SRC 만 큐에 넣고 시작
            _DISCOVERED_SRCS := $(shell \
                start_file="$(_SRC_MAIN_NORM)"; \
                found_srcs="$$start_file"; \
                visited=""; \
                queue="$$start_file"; \
                while [ -n "$$queue" ]; do \
                    set -- $$queue; \
                    current=$$1; shift; \
                    queue="$$*"; \
                    is_visited=`echo "$$visited" | grep -F -w "$$current"`; \
                    if [ -n "$$is_visited" ]; then continue; fi; \
                    visited="$$visited $$current"; \
                    raw_deps=`$(PREPROC) -MM "$$current" 2>/dev/null`; \
                    headers=`echo "$$raw_deps" | sed 's/\\\\//g' | tr ' ' '\n' | grep -E '\.(h|hpp|hh|hxx|H)$$' | sort -u`; \
                    for hdr in $$headers; do \
                        is_hdr_visited=`echo "$$visited" | grep -F -w "$$hdr"`; \
                        if [ -z "$$is_hdr_visited" ]; then queue="$$queue $$hdr"; fi; \
                        base="$${hdr%.*}"; cand=""; \
                        if [ -f "$${base}.cpp" ]; then cand="$${base}.cpp"; \
                        elif [ -f "$${base}.c" ]; then cand="$${base}.c"; \
                        elif [ -f "$${base}.cc" ]; then cand="$${base}.cc"; \
                        elif [ -f "$${base}.cxx" ]; then cand="$${base}.cxx"; \
                        elif [ -f "$${base}.C" ]; then cand="$${base}.C"; fi; \
                        if [ -n "$$cand" ]; then \
                            is_added=`echo "$$found_srcs" | grep -F -w "$$cand"`; \
                            if [ -z "$$is_added" ]; then found_srcs="$$found_srcs $$cand"; queue="$$queue $$cand"; fi; \
                        fi; \
                    done; \
                done; \
                echo $$found_srcs)

        else ifeq ($(MODE_DEPS),file)
            # file 모드: MAIN_SRC 만 큐에 넣고 시작
            _DISCOVERED_SRCS := $(shell \
                all_srcs="$(_PROJECT_FILE_POOL)"; \
                start_file="$(_SRC_MAIN_NORM)"; \
                found_srcs="$$start_file"; \
                visited=""; \
                queue="$$start_file"; \
                while [ -n "$$queue" ]; do \
                    set -- $$queue; \
                    current=$$1; shift; \
                    queue="$$*"; \
                    is_visited=`echo "$$visited" | grep -F -w "$$current"`; \
                    if [ -n "$$is_visited" ]; then continue; fi; \
                    visited="$$visited $$current"; \
                    raw_deps=`$(PREPROC) -MM "$$current" 2>/dev/null`; \
                    headers=`echo "$$raw_deps" | sed 's/\\\\//g' | tr ' ' '\n' | grep -E '\.(h|hpp|hh|hxx|H)$$' | sort -u`; \
                    for hdr in $$headers; do \
                        is_hdr_visited=`echo "$$visited" | grep -F -w "$$hdr"`; \
                        if [ -z "$$is_hdr_visited" ]; then queue="$$queue $$hdr"; fi; \
                        hdr_base=$$(basename "$$hdr"); \
                        name=$${hdr_base%.*}; \
                        match_srcs=`echo "$$all_srcs" | tr ' ' '\n' | grep -E "(^|/)$$name\.(cpp|cc|cxx|C|c)$$"` ; \
                        for cand in $$match_srcs; do \
                            if [ -n "$$cand" ]; then \
                                is_added=`echo "$$found_srcs" | grep -F -w "$$cand"`; \
                                if [ -z "$$is_added" ]; then found_srcs="$$found_srcs $$cand"; queue="$$queue $$cand"; fi; \
                            fi; \
                        done; \
                    done; \
                done; \
                echo $$found_srcs)

        else ifeq ($(MODE_DEPS),all)
            _DISCOVERED_SRCS := $(_PROJECT_FILE_POOL)
        endif

        # 7. 최종 소스 파일 병합 (_FINAL_SRCS)
        # 자동 탐색된 파일들과 사용자가 수동으로 지정한 파일들을 합칩니다.
        # sort 함수가 중복을 제거해줍니다.
        _FINAL_SRCS := $(sort $(_DISCOVERED_SRCS) $(_USER_SRCS_NORM))

        # 8. [Step 2] 최종 HDRS 추출 (일괄 처리)
        # 확정된 모든 소스 파일(_FINAL_SRCS)을 대상으로 헤더 의존성을 한 번에 뽑아냅니다.
        DEPS_ALL := $(shell $(PREPROC) -MM $(_FINAL_SRCS) 2>/dev/null)
        HDRS := $(call EXTRACT_HEADERS,$(DEPS_ALL))

        # 9. 헤더 파일 존재 여부 검증
        $(foreach hdr,$(HDRS),$(if $(wildcard $(hdr)),,$(warning $(call FMT_WRN,$(WRN_CFG_FILE_NO_HEADER)): $(hdr))))

    # --------------------------------------------------------------------------
    # 5.6 라이브러리 빌드 모드
    # --------------------------------------------------------------------------
    else
        ifeq ($(LIB_NAME),)
            $(error $(call FMT_ERR,$(ERR_CFG_LIB_NO_NAME)))
        endif
        override MODE_DEPS := all
        
        # 사용자가 지정한 파일(USER_SRCS)이 있으면 그것을 우선 사용, 없으면 전체 사용
        ifneq ($(USER_SRCS),)
             _FINAL_SRCS := $(USER_SRCS)
        else
             _FINAL_SRCS := $(_PROJECT_FILE_POOL)
        endif

        _TARGET := $(LIB_PATH)
        CMD_LOG_MODE := $(call LOG_CFG_TARGET,$(_TARGET) [$(MODE_TARGET)])

        # 라이브러리 모드도 일관성을 위해 헤더 정보 추출
        EXTRACT_HEADERS_LIB = $(sort $(filter $(foreach ext,$(EXT_HDR),%$(ext)),$(subst \, ,$(subst :, ,$(1)))))
        DEPS_ALL := $(shell $(if $(filter %.cpp %.cc %.cxx %.C,$(_FINAL_SRCS)),$(CXX) $(CPPFLAGS) $(CXXFLAGS),$(CC) $(CPPFLAGS) $(CFLAGS)) -MM $(_FINAL_SRCS) 2>/dev/null)
        HDRS := $(call EXTRACT_HEADERS_LIB,$(DEPS_ALL))
    endif

    # --------------------------------------------------------------------------
    # 5.7 오브젝트 파일 경로 생성
    # --------------------------------------------------------------------------
    _OBJS_TO_LINK := $(addsuffix .o,$(addprefix $(BUILD_ROOT)/,$(basename $(_FINAL_SRCS))))

    # --------------------------------------------------------------------------
    # 5.8 링커 자동 선택
    # --------------------------------------------------------------------------
    IS_CPP_PROJECT := $(filter $(foreach ext,$(EXT_CPP),%$(ext)),$(_FINAL_SRCS))
    ifeq ($(IS_CPP_PROJECT),)
        LINKER := $(CC)
    else
        LINKER := $(CXX)
    endif

    # --------------------------------------------------------------------------
    # 5.9 링크 명령 결정
    # --------------------------------------------------------------------------
    ifeq ($(MODE_TARGET),static)
        LINK_CMD = ar rcs $(_TARGET) $(_OBJS_TO_LINK)
    else ifeq ($(MODE_TARGET),shared)
        LINK_CMD = $(LINKER) -shared $(LDFLAGS) -o $(_TARGET) $(_OBJS_TO_LINK) $(LDLIBS)
    else
        LINK_CMD = $(LINKER) $(LDFLAGS) -o $(_TARGET) $(_OBJS_TO_LINK) $(LDLIBS)
    endif

endif

# ==============================================================================
# 섹션 6: 타겟 및 규칙 (Targets & Rules)
# ==============================================================================
# 동작: 사용자가 호출하는 실제 빌드 작업 정의
# 조건: .PHONY 선언으로 항상 실행되도록 설정
# ==============================================================================

.DEFAULT_GOAL := help
.PHONY: all help build run build-run clean clean-build clean-build-run pre-build-setup
.PHONY: _internal_build _internal_run _internal_clean

# ------------------------------------------------------------------------------
# 6.1 help 타겟
# ------------------------------------------------------------------------------
help:
	@echo ""
	@echo "$(ANSI_BOLD)NAME$(ANSI_RESET)"
	@echo "    make - C/C++ 프로젝트 빌드 시스템"
	@echo ""
	@echo "$(ANSI_BOLD)SYNOPSIS$(ANSI_RESET)"
	@echo "    make [$(ANSI_FG_CYAN)target$(ANSI_RESET)] [$(ANSI_FG_YELLOW)MAIN_SRC$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET)] [$(ANSI_FG_YELLOW)MODE_LOG$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)]"
	@echo ""
	@echo "$(ANSI_BOLD)TARGETS$(ANSI_RESET)"
	@echo "    $(ANSI_FG_CYAN)build$(ANSI_RESET)            소스 파일을 컴파일하여 실행 파일 생성"
	@echo "    $(ANSI_FG_CYAN)run$(ANSI_RESET)              빌드된 실행 파일을 실행"
	@echo "    $(ANSI_FG_CYAN)build-run$(ANSI_RESET)        빌드와 실행을 연속으로 수행"
	@echo "    $(ANSI_FG_CYAN)clean$(ANSI_RESET)            빌드 디렉토리 안전하게 삭제"
	@echo "    $(ANSI_FG_CYAN)clean-build$(ANSI_RESET)      클린 후 완전히 새로 빌드"
	@echo "    $(ANSI_FG_CYAN)clean-build-run$(ANSI_RESET)  클린, 빌드, 실행을 순차 수행"
	@echo "    $(ANSI_FG_CYAN)list-headers$(ANSI_RESET)     의존된 헤더 파일 목록 출력(경로 포함)"
	@echo "    $(ANSI_FG_CYAN)help$(ANSI_RESET)             이 도움말 표시"
	@echo ""
	@echo "$(ANSI_BOLD)VARIABLES$(ANSI_RESET)"
	@echo "    $(ANSI_FG_YELLOW)MAIN_SRC$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)m$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET)) (관련: build(target), run(target))"
	@echo "        빌드할 메인 소스 파일 경로. 미지정 시 main.c/main.cpp 자동 탐색"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)SRCS$(ANSI_RESET)=$(ANSI_FG_MAGENTA)\"file1 file2 ...\"$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)s$(ANSI_RESET)=$(ANSI_FG_MAGENTA)\"file1 file2 ...\"$(ANSI_RESET)) (관련: build(target), MODE_DEPS(option), MODE_TARGET(option))"
	@echo "        추가로 빌드할 소스 파일 수동 목록 지정."
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)MODE_LOG$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)l$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)) (관련: 모든 빌드 관련 타겟)"
	@echo "        빌드 출력 형식 제어. 기본값: normal"
	@echo "        $(ANSI_FG_MAGENTA)normal (n)$(ANSI_RESET)            한글 메시지, 색상 강조 (기본값)"
	@echo "        $(ANSI_FG_MAGENTA)silent (s)$(ANSI_RESET)            성공 시 출력 없음, 에러만 표시"
	@echo "        $(ANSI_FG_MAGENTA)verbose (v)$(ANSI_RESET)           영어 메시지, 모든 명령어 출력"
	@echo "        $(ANSI_FG_MAGENTA)binary (b)$(ANSI_RESET)            바이너리 경로만 출력 (도구 연동용)"
	@echo "        $(ANSI_FG_MAGENTA)raw (r)$(ANSI_RESET)               컴파일러 원본 출력만 표시"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)MODE_TARGET$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)t$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)) (static, shared 모드일때는 LIB_NAME 옵션 필수)"
	@echo "        빌드 유형. 기본값: executable"
	@echo "        $(ANSI_FG_MAGENTA)executable (exe, bin, out)$(ANSI_RESET)        실행파일 생성 (기본값)"
	@echo "        $(ANSI_FG_MAGENTA)static (a)$(ANSI_RESET)                        정적 라이브러리 (a)"
	@echo "        $(ANSI_FG_MAGENTA)shared (so, dll, dylib)$(ANSI_RESET)           동적 라이브러리 (so, dll, dylib)"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)MODE_DEPS$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)d$(ANSI_RESET)=$(ANSI_FG_MAGENTA)mode$(ANSI_RESET))"
	@echo "        의존성 탐색 방식. 기본값: path"
	@echo "        $(ANSI_FG_MAGENTA)standalone (s)$(ANSI_RESET)                단독 빌드 (의존성 무시)"
	@echo "        $(ANSI_FG_MAGENTA)path (p)$(ANSI_RESET)                      전이적 경로 기반"
	@echo "        $(ANSI_FG_MAGENTA)file (f)$(ANSI_RESET)                      전이적 파일명 기반"
	@echo "        $(ANSI_FG_MAGENTA)all (a)$(ANSI_RESET)                       전체 링크 (모든 소스 포함)"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)LIB_NAME$(ANSI_RESET)=$(ANSI_FG_MAGENTA)name$(ANSI_RESET)  (별칭: $(ANSI_FG_YELLOW)n$(ANSI_RESET)=$(ANSI_FG_MAGENTA)name$(ANSI_RESET)) (관련: build(target), MODE_TARGET(option))"
	@echo "        라이브러리 모드시에 필수 옵션, 이름, 경로와 함께 지정 가능"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)STDIN$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET) (별칭: $(ANSI_FG_YELLOW)i$(ANSI_RESET)), $(ANSI_FG_YELLOW)STDOUT$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET) (별칭: $(ANSI_FG_YELLOW)o$(ANSI_RESET)), $(ANSI_FG_YELLOW)STDERR$(ANSI_RESET)=$(ANSI_FG_MAGENTA)file$(ANSI_RESET) (별칭: $(ANSI_FG_YELLOW)e$(ANSI_RESET)), $(ANSI_FG_YELLOW)ARGS$(ANSI_RESET)=$(ANSI_FG_MAGENTA)args$(ANSI_RESET) (별칭: $(ANSI_FG_YELLOW)a$(ANSI_RESET)) (관련: run(target))"
	@echo "        실행 시 입출력 리다이렉션 및 추가 인자 지정"
	@echo ""
	@echo "    $(ANSI_FG_YELLOW)PKGS$(ANSI_RESET)=$(ANSI_FG_MAGENTA)\"pkg1 pkg2 ...\"$(ANSI_RESET)"
	@echo "         pkg-config를 통해 포함할 외부 라이브러리 목록 지정"
	@echo ""
	@echo "$(ANSI_BOLD)ADVANCED VARIABLES$(ANSI_RESET)"
	@echo "    일반적으로 파일을 고쳐서 변경하는 것이 좋음"
	@echo "    $(ANSI_FG_YELLOW)SRC_ROOT$(ANSI_RESET)    = $(ANSI_FG_MAGENTA)path$(ANSI_RESET)          소스 파일 탐색의 루트 디렉토리 지정 (기본값: ./)"
	@echo "    $(ANSI_FG_YELLOW)BUILD_ROOT$(ANSI_RESET)  = $(ANSI_FG_MAGENTA)path$(ANSI_RESET)          빌드 출력 디렉토리 경로 지정 (기본값: ./build)"
	@echo "    $(ANSI_FG_YELLOW)CPPFLAGS$(ANSI_RESET)   += $(ANSI_FG_MAGENTA)flags$(ANSI_RESET)         전처리기 플래그 지정 C/C++ 공통"
	@echo "    $(ANSI_FG_YELLOW)CFLAGS$(ANSI_RESET)     += $(ANSI_FG_MAGENTA)flags$(ANSI_RESET)         C 컴파일러에 전달할 추가 플래그 지정"
	@echo "    $(ANSI_FG_YELLOW)CXXFLAGS$(ANSI_RESET)   += $(ANSI_FG_MAGENTA)flags$(ANSI_RESET)         C++ 컴파일러에 전달할 추가 플래그 지정"
	@echo "    $(ANSI_FG_YELLOW)LDFLAGS$(ANSI_RESET)    += $(ANSI_FG_MAGENTA)flags$(ANSI_RESET)         링커에 전달할 추가 플래그 지정"
	@echo "    $(ANSI_FG_YELLOW)LDLIBS$(ANSI_RESET)     += $(ANSI_FG_MAGENTA)libs$(ANSI_RESET)          링커에 전달할 추가 라이브러리 지정"
	@echo ""
	@echo "$(ANSI_BOLD)EXAMPLES$(ANSI_RESET)"
	@echo "    $(ANSI_FG_CYAN)1.$(ANSI_RESET) 기본 빌드 (main.c/main.cpp 자동 탐색):"
	@echo "        $(ANSI_FG_MAGENTA)make build$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)2.$(ANSI_RESET) 특정 파일 빌드 및 실행 (짧은 별칭):"
	@echo "        $(ANSI_FG_MAGENTA)make build-run m=leetcode/700.cpp$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)3.$(ANSI_RESET) 상세 로그와 함께 클린 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make clean-build m=swea/1244/main.cpp l=v$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)4.$(ANSI_RESET) 벤치마크 도구와 연동 (바이너리 경로 출력):"
	@echo "        $(ANSI_FG_MAGENTA)hyperfine '\$$(make build m=leetcode/700.cpp l=b)'$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)5.$(ANSI_RESET) 라이브러리 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make build LIB_NAME=mylib MODE_TARGET=static m=mylib/util.cpp$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)6.$(ANSI_RESET) 입력 파일로 실행 (stdin 리다이렉션):"
	@echo "        $(ANSI_FG_MAGENTA)make build-run m=swea/1206/main.cpp i=swea/1206/input.txt$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)7.$(ANSI_RESET) 출력을 파일로 저장:"
	@echo "        $(ANSI_FG_MAGENTA)make build-run m=swea/1206/main.cpp i=swea/1206/input.txt o=swea/1206/output.txt$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)8.$(ANSI_RESET) 단독 빌드 (의존성 무시, 단일 파일만, PS 문제들):"
	@echo "        $(ANSI_FG_MAGENTA)make build m=leetcode/104.cpp d=s$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)9.$(ANSI_RESET) 전이적 의존성 탐색 (깊은 의존성 추적):"
	@echo "        $(ANSI_FG_MAGENTA)make build m=include_transitive/main.c d=tp$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)10.$(ANSI_RESET) 디버그 플래그 추가 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make build m=leetcode/236.cpp CXXFLAGS+='-g3 -O0 -fsanitize=address'$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)11.$(ANSI_RESET) 릴리즈 최적화 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make build m=leetcode/700.cpp CXXFLAGS+='-O3 -march=native -flto'$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)12.$(ANSI_RESET) 외부 라이브러리 연동 (pkg-config):"
	@echo "        $(ANSI_FG_MAGENTA)make build m=main.cpp PKGS='opencv4 gtk+-3.0'$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)13.$(ANSI_RESET) 조용한 모드로 CI/CD 파이프라인 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make build-run m=test/main.cpp l=s$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)14.$(ANSI_RESET) 동적 라이브러리(shared) 빌드:"
	@echo "        $(ANSI_FG_MAGENTA)make build t=shared n=libutil.so$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)15.$(ANSI_RESET) 명령행 인자와 함께 실행:"
	@echo "        $(ANSI_FG_MAGENTA)make build-run m=main.cpp a='--verbose --config=test.json'$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)16.$(ANSI_RESET) 15번과 동일 but binary 모드로 연동:"
	@echo "        $(ANSI_FG_MAGENTA)./\$$(make build m=main.cpp MODE_LOG=binary) --verbose --config=test.json$(ANSI_RESET)"
	@echo ""
	@echo "    $(ANSI_FG_CYAN)17.$(ANSI_RESET) 의존 헤더 목록 확인:"
	@echo "        $(ANSI_FG_MAGENTA)make list-headers m=include/main.c$(ANSI_RESET)"
	@echo ""
	@echo "$(ANSI_BOLD)EXIT STATUS$(ANSI_RESET)"
	@echo "    빌드 성공 시 0 반환, 실패 시 1 반환"
	@echo ""
	@echo "$(ANSI_BOLD)NOTES$(ANSI_RESET)"
	@echo "    • $(ANSI_FG_GREEN)[안전 기능]$(ANSI_RESET) clean은 마커 파일 확인으로 실수 삭제 방지"
	@echo "    • 헤더 파일 변경 시 관련 소스 자동 재컴파일"
	@echo "    • MODE_TARGET이 라이브러리인 경우 run 타겟은 실행 불가"
	@echo "    • MODE_TARGET이 라이브러리인 경우 링킹 시 LDLIBS 무시"
	@echo "    • MODE_TARGET이 라이브러리인 경우 LIB_NAME 지정 필수"
	@echo "    • MODE_TARGET이 실행파일인 경우 && MAIN_SRC 가 없으면 main.c/main.cpp 자동 탐색"
	@echo "    • 다중 코어(-j 옵션) 사용시 clean build run 같이 타겟을 분할해서 하지 말고 clean-build-run 같이 한 번에 처리하면 경쟁 상태를 방지할 수 있음"
	@echo ""

# ------------------------------------------------------------------------------
# 6.2
# ------------------------------------------------------------------------------
_internal_print_config:
	@echo "====== Build Configuration ======"
	@echo "SRC_ROOT:        $(SRC_ROOT)"
	@echo "BUILD_ROOT:      $(BUILD_ROOT)"
	@echo "MAIN_SRC:        $(MAIN_SRC)"
	@echo "MODE_LOG:        $(LOG_MODE)"
	@echo "MODE_TARGET:     $(MODE_TARGET)"
	@echo "MODE_DEPS:       $(MODE_DEPS)"
	@echo "LIB_NAME:        $(LIB_NAME)"
	@echo "LIB_PATH:        $(LIB_PATH)"
	@echo "CXX:             $(CXX)"
	@echo "CC:              $(CC)"
	@echo "CPPFLAGS:        $(CPPFLAGS)"
	@echo "CFLAGS:          $(CFLAGS)"
	@echo "CXXFLAGS:        $(CXXFLAGS)"
	@echo "LDFLAGS:         $(LDFLAGS)"
	@echo "LDLIBS:          $(LDLIBS)"
	@echo "PKGS:            $(PKGS)"
	@echo "TARGET:          $(_TARGET)"
	@echo "RESOLVED_SRCS:   $(_FINAL_SRCS)"
	@echo "OBJS_TO_LINK:    $(_OBJS_TO_LINK)"
	@echo "HDRS:            $(HDRS)"
	@echo "LINK_CMD:        $(LINK_CMD)"
	@echo "================================="

# ------------------------------------------------------------------------------
# 6.2 clean 타겟 (독립적 실행)
# ------------------------------------------------------------------------------
_internal_clean:
	$(if $(and $(wildcard $(BUILD_ROOT)),$(filter-out $(wildcard $(BUILD_ROOT)/.make_safe_marker),$(wildcard $(BUILD_ROOT)/.make_safe_marker))), \
		$(error $(ERR_CLN_NO_MARKER): $(BUILD_ROOT)))
	$(LOG_CLN_MARKER_OK)
	$(Q)rm -rf $(BUILD_ROOT)
	$(LOG_CLN_SUCCESS)

clean: _internal_clean

# ------------------------------------------------------------------------------
# 6.3 빌드 준비 타겟
# ------------------------------------------------------------------------------
pre-build-setup: $(if $(filter-out 0,$(CONFIG_PRINT)),_internal_print_config)
	@if [ ! -d "$(BUILD_ROOT)" ]; then \
		[ -z "$(Q)" ] && echo "$(MKDIR_P) $(BUILD_ROOT)" || true; \
		$(MKDIR_P) $(BUILD_ROOT); \
	fi
	@if [ ! -f "$(BUILD_ROOT)/.make_safe_marker" ]; then \
		[ -z "$(Q)" ] && echo "touch $(BUILD_ROOT)/.make_safe_marker" || true; \
		touch "$(BUILD_ROOT)/.make_safe_marker"; \
	fi
	$(if $(wildcard $(BUILD_ROOT)/.make_safe_marker),,$(LOG_BLD_MARKER_CREATE))
	$(LOG_BLD_START)
	$(CMD_LOG_MODE)

# ------------------------------------------------------------------------------
# 6.4 주요 빌드 타겟
# ------------------------------------------------------------------------------
.NOTPARALLEL: build-run clean-build clean-build-run

_internal_build: $(_TARGET)
	$(call LOG_BUILD_FINISH,$(_TARGET))

_internal_run:
	$(Q)test -f "$(_TARGET)" $(call ABORT_ON_ERR,$(ERR_RUN_NO_BIN): $(_TARGET))
	$(call LOG_RUN_START,$(_TARGET))
	$(Q)$(_TARGET) $(FINAL_ARGS) $(call ABORT_ON_ERR,$(ERR_RUN_FAIL))

build: _internal_build

run: _internal_run

build-run: _internal_build _internal_run

clean-build: _internal_clean _internal_build

clean-build-run: _internal_clean _internal_build _internal_run

list-headers:
	@echo $(HDRS)
# ------------------------------------------------------------------------------
# 6.5 링킹 규칙
# ------------------------------------------------------------------------------
$(_TARGET): $(_OBJS_TO_LINK) | pre-build-setup
	$(if $(wildcard $(dir $@)),,$(Q)$(MKDIR_P) $(dir $@))
	$(call LOG_BLD_LINK,$@)
	$(Q)$(LINK_CMD) $(call ABORT_ON_ERR,$(ERR_BLD_LINK): $@)
	$(call LOG_BLD_SUCCESS,$@)

# ------------------------------------------------------------------------------
# 6.6 컴파일 규칙 (패턴 규칙 생성 매크로)
# ------------------------------------------------------------------------------
define RULE_CPP
$(BUILD_ROOT)/%.o: %$(1) | pre-build-setup
	$$(Q)$(MKDIR_P) $$(@D)
	$$(call LOG_BLD_COMPILE,$$<,$$@)
	$$(Q)$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ $$(call ABORT_ON_ERR,$(ERR_BLD_COMPILE): $$<)
endef

define RULE_C
$(BUILD_ROOT)/%.o: %$(1) | pre-build-setup
	$$(Q)$(MKDIR_P) $$(@D)
	$$(call LOG_BLD_COMPILE,$$<,$$@)
	$$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ $$(call ABORT_ON_ERR,$(ERR_BLD_COMPILE): $$<)
endef

# 컴파일 규칙 생성
$(foreach ext,$(EXT_CPP),$(eval $(call RULE_CPP,$(ext))))
$(foreach ext,$(EXT_C),$(eval $(call RULE_C,$(ext))))

# ------------------------------------------------------------------------------
# 6.7 의존성 파일 포함
# ------------------------------------------------------------------------------
ifneq ($(_OBJS_TO_LINK),)
    -include $(_OBJS_TO_LINK:.o=.d)
endif
