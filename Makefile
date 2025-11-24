# ==============================================================================
# 사용자 설정 (User Configuration)
# ------------------------------------------------------------------------------
# 동작: 사용자가 프로젝트에 맞게 수정할 수 있는 빌드 옵션들을 정의합니다.
# 조건: Makefile 실행 시 가장 먼저 로드되며, 이후 모든 섹션에서 참조됩니다.
#       명령줄에서 변수를 전달하여 오버라이드할 수 있습니다.
#       예: make build MAIN_SRC=test.cpp OUTPUT_MODE=verbose
# ==============================================================================

# ------------------------------------------------------------------------------
# 1.1 디렉토리 구조 설정
# ------------------------------------------------------------------------------
# 동작: 프로젝트의 디렉토리 구조를 정의합니다.
# 조건: ?= 연산자를 사용하여 명령줄에서 전달된 값이 없을 때만 기본값을 설정합니다.
#       이를 통해 사용자가 make 실행 시 원하는 경로를 지정할 수 있습니다.

# PROJECT_ROOT: Makefile이 위치한 프로젝트 최상위 디렉토리 (기본값: 현재 디렉토리)
PROJECT_ROOT ?= .

# SRC_ROOT: 소스 코드(.c, .cpp 파일)가 위치한 루트 디렉토리 (기본값: 프로젝트 루트)
# 이 디렉토리 하위의 모든 소스 파일이 빌드 대상으로 탐색됩니다.
SRC_ROOT ?= $(PROJECT_ROOT)

# BUILD_ROOT: 컴파일된 오브젝트 파일(.o)과 실행 파일이 저장될 디렉토리
# 소스 트리와 빌드 결과물을 분리하여 프로젝트를 깔끔하게 유지합니다.
BUILD_ROOT ?= $(PROJECT_ROOT)/build


# ------------------------------------------------------------------------------
# 1.2 컴파일러 자동 선택 (Compiler Auto-Detection)
# ------------------------------------------------------------------------------
# 동작: 운영체제를 자동으로 감지하여 적절한 컴파일러를 선택합니다.
# 조건: 
#   - Darwin (macOS)  : clang/clang++ 사용 (Apple의 기본 컴파일러)
#   - Linux           : gcc/g++ 사용 (GNU 컴파일러 컬렉션)
#   - 기타 OS         : gcc/g++를 기본값으로 사용
# 참고: 명령줄에서 오버라이드 가능 (예: make build CXX=clang++ CC=clang)

ifeq ($(shell uname -s),Darwin)
    # macOS 감지: LLVM 기반의 clang 컴파일러 사용
    CXX ?= clang++  # C++ 컴파일러
    CC ?= clang     # C 컴파일러
else ifeq ($(shell uname -s),Linux)
    # Linux 감지: GNU 컴파일러 사용
    CXX ?= g++      # C++ 컴파일러
    CC ?= gcc       # C 컴파일러
else
    # 기타 UNIX 계열 또는 미지원 OS: GNU 컴파일러를 기본값으로 사용
    CXX ?= g++      # C++ 컴파일러 (기본값)
    CC ?= gcc       # C 컴파일러 (기본값)
endif

# ------------------------------------------------------------------------------
# 1.3 파일 확장자 정의 (File Extension Definition)
# ------------------------------------------------------------------------------
# 동작: 빌드 시스템이 인식할 C 및 C++ 소스 파일의 확장자를 정의합니다.
# 조건: 소스 파일 탐색 시 이 확장자 목록을 기준으로 필터링합니다.

# EXT_C: C 언어 소스 파일 확장자
EXT_C := .c

# EXT_CPP: C++ 언어 소스 파일 확장자 (여러 확장자 지원)
# .cpp  : 가장 일반적인 C++ 확장자
# .cc   : Google 스타일 가이드 등에서 사용
# .cxx  : 일부 레거시 프로젝트에서 사용
# .C    : 대문자 C (일부 UNIX 시스템에서 사용)
EXT_CPP := .cpp .cc .cxx .C

# EXT_HDR: 헤더 파일 확장자 정의
# .h   : C/C++ 공용
# .hpp : C++ 전용 (구현 포함 가능)
# .hh, .hxx : 기타 C++ 헤더
EXT_HDR := .h .hpp .hh .hxx .H

# ALL_EXTS: 모든 지원 확장자를 하나의 리스트로 결합
# C++와 C 파일을 모두 포함하여 프로젝트 전체 소스 파일을 탐색할 때 사용
ALL_EXTS := $(EXT_CPP) $(EXT_C)

# ------------------------------------------------------------------------------
# 1.4 의존성 탐색 모드 (Dependency Search Mode)
# ------------------------------------------------------------------------------
# 동작: 헤더 파일에 대응하는 소스 파일(.cpp/.c)을 찾는 방식을 설정합니다.
# 조건:
#   path : [기본값] 경로 기반 매칭 (Path Matching)
#          - 헤더와 소스가 같은 폴더에 위치해야 함 (Colocation)
#          - 소스 파일명이 중복되는 경우 필수 (예: problem1/sol.cpp, problem2/sol.cpp)
#          - 헤더: problem1/sol.h -> 소스: problem1/sol.cpp (찾음)
#
#   file : 파일명 기반 매칭 (Filename Matching)
#          - include/ 와 src/ 가 분리된 일반적인 프로젝트 구조 지원
#          - 헤더: include/utils.h -> 소스: src/utils.cpp (찾음)
#          - 단, 프로젝트 내에 '파일명'은 유일해야 합니다. (중복 시 충돌 가능)
#
#   standalone : [단독 빌드] 의존성 무시 (Standalone Mode)
#          - 오직 MAIN_SRC 파일 하나만 컴파일하고 링크합니다.
#          - 헤더 구현체(.cpp)를 찾지 않으며, 단일 파일 솔루션(PS)에 최적화됨
#
#   all  : [전체 링크] 무조건 전체 포함 (Link All Mode)
#          - 프로젝트 내의 모든 소스 파일을 무조건 함께 링크합니다.
#          - 의존성을 일일이 명시하기 귀찮거나, 공용 유틸리티가 산재해 있을 때 유용합니다.
#          - 주의: main 함수가 2개 이상이면 링커 에러가 발생합니다 (별도 검증 없음).
#          - A->B->C 의존성이 완벽하게 해결됩니다. 즉 전이적 의존성을 위해 속도를 희생하는 방식입니다.
#          - 완벽한 전이적 의존성 해결을 하고 싶다면 다른 고수준의 빌드 시스템(CMake, Bazel 등)을 사용하는 것을 권장합니다.
#          - 링커의 Dead Code Stripping 기능을 믿고 다 넣는 방식입니다.
#          - CXXFLAGS += -fdata-sections -ffunction-sections 추가 권장
#          - CFLAGS   += -fdata-sections -ffunction-sections 추가 권장
#          - LDFLAGS += -Wl,--gc-sections 추가 권장

#   transitive_path : [전이적 경로 기반 링크] 전이적 의존성 포함 + 경로 기반 매칭 (Transitive Path Link Mode)
#          - 의존성 그래프를 따라가며 전이적 의존성을 모두 포함합니다.
#          - 헤더와 소스가 같은 폴더에 위치해야 합니다.
#          - A->B->C 의존성이 완벽하게 해결됩니다.
#   transitive_file : [전이적 파일명 기반 링크] 전이적 의존성 포함 + 파일명 기반 매칭 (Transitive Filename Link Mode)
#          - 의존성 그래프를 따라가며 전이적 의존성을 모두 포함합니다.
#          - include/ 와 src/ 가 분리된 일반적인 프로젝트 구조 지원
#          - 헤더: include/utils.h -> 소스: src/utils.cpp (찾음)
#          - 단, 프로젝트 내에 '파일명'은 유일해야 합니다. (중복 시 충돌 가능)

DEPENDENCY_MODE ?= path

# ------------------------------------------------------------------------------
# 1.5 전처리기 플래그 (CPPFLAGS)
# ------------------------------------------------------------------------------
# 용도: C와 C++ 컴파일러에 공통으로 전달되는 전처리기 옵션
#       헤더 파일 경로(-I)와 매크로 정의(-D)를 설정합니다.

CPPFLAGS ?=

# [인클루드 경로 추가 예시] 헤더 파일이 있는 디렉토리를 -I로 지정
CPPFLAGS += -I$(SRC_ROOT)
# CPPFLAGS += -I./include              # 예시: include 폴더
# CPPFLAGS += -I./third_party          # 예시: third_party 라이브러리 헤더
# CPPFLAGS += -I/usr/local/include     # 예시: 시스템 전역 헤더

# [매크로 정의 예시] -D로 전처리기 매크로 정의
# CPPFLAGS += -DDEBUG                  # 예시: DEBUG 모드 활성화
# CPPFLAGS += -DVERSION=2              # 예시: 버전 번호 지정
# CPPFLAGS += -D_GNU_SOURCE            # 예시: GNU 확장 기능 사용

# ------------------------------------------------------------------------------
# 1.6 C++ 컴파일러 플래그 (CXXFLAGS)
# ------------------------------------------------------------------------------
# 용도: C++ 컴파일 단계의 옵션 (언어 표준, 최적화, 경고)

CXXFLAGS ?=

# [언어 표준] C++ 버전 선택 (1개만 선택)
# CXXFLAGS += -std=c++11
# CXXFLAGS += -std=c++14
CXXFLAGS += -std=c++17
# CXXFLAGS += -std=c++20
# CXXFLAGS += -std=c++23

# [최적화 레벨] 빌드 타입에 따라 1개만 선택
# Debug 빌드 (디버깅 및 개발용)
CXXFLAGS += -O0 -g
# Release 빌드 (배포용)
# CXXFLAGS += -O2 -DNDEBUG
# CXXFLAGS += -O3 -DNDEBUG
# CXXFLAGS += -Os              # 크기 최적화
# CXXFLAGS += -Ofast           # 최대 속도 최적화 (표준 비준수 가능)
# Profile 빌드 (성능 분석용)
# CXXFLAGS += -O2 -g -pg

# [고급 최적화] Release 빌드 시 추가 옵션
# CXXFLAGS += -flto                          # Link Time Optimization
# CXXFLAGS += -march=native                  # CPU 특화 최적화 (이식성 감소)
# CXXFLAGS += -mtune=native                  # CPU 튜닝 (이식성 유지)
# CXXFLAGS += -ffast-math                    # 부동소수점 최적화 (정확도 감소)
# CXXFLAGS += -funroll-loops                 # 루프 언롤링
# CXXFLAGS += -fno-omit-frame-pointer        # 프레임 포인터 유지 (프로파일링용)
# CXXFLAGS += -fdata-sections -ffunction-sections  # 미사용 섹션 제거 준비

# [경고 옵션] 코드 품질 향상
CXXFLAGS += -Wall                          # 기본 경고 활성화
# CXXFLAGS += -Wextra                       # 추가 경고 활성화
# CXXFLAGS += -Wpedantic                    # 엄격한 표준 준수
# CXXFLAGS += -Werror                       # 모든 경고를 에러로 처리
# CXXFLAGS += -Wno-unused-parameter         # 특정 경고 비활성화

# [디버깅 및 분석 도구]
# CXXFLAGS += -fsanitize=address            # AddressSanitizer (메모리 오류 검출)
# CXXFLAGS += -fsanitize=undefined          # UndefinedBehaviorSanitizer
# CXXFLAGS += -fsanitize=thread             # ThreadSanitizer (멀티스레드 오류 검출)
# CXXFLAGS += -fstack-protector-strong      # 스택 버퍼 오버플로우 방지
# CXXFLAGS += -D_GLIBCXX_DEBUG              # libstdc++ 디버그 모드

# ------------------------------------------------------------------------------
# 1.7 C 컴파일러 플래그 (CFLAGS)
# ------------------------------------------------------------------------------
# 용도: C 컴파일 단계의 옵션

CFLAGS ?=

# [언어 표준] C 버전 선택 (1개만 선택)
# CFLAGS += -std=c99
CFLAGS += -std=c11
# CFLAGS += -std=c17
# CFLAGS += -std=c2x

# [최적화 레벨] CXXFLAGS와 동일하게 설정
CFLAGS += -O0 -g
# CFLAGS += -O2 -DNDEBUG
# CFLAGS += -O3 -DNDEBUG

# [경고 옵션]
CFLAGS += -Wall
# CFLAGS += -Wextra
# CFLAGS += -Werror

# ------------------------------------------------------------------------------
# 1.8 링커 플래그 (LDFLAGS) 및 라이브러리 (LDLIBS)
# ------------------------------------------------------------------------------
# LDFLAGS: 링커 동작 제어 및 라이브러리 검색 경로
# LDLIBS:  링크할 라이브러리 지정

LDFLAGS ?=
LDLIBS  ?=

# [라이브러리 검색 경로]
# LDFLAGS += -L./lib
# LDFLAGS += -L/usr/local/lib

# [링커 최적화] Release 빌드 시
# LDFLAGS += -Wl,--gc-sections    # 미사용 섹션 제거 (요구: -fdata-sections -ffunction-sections)
# LDFLAGS += -Wl,-O1              # 링커 최적화
# LDFLAGS += -flto                # LTO 활성화 (CXXFLAGS에도 필요)

# [링크 라이브러리]
# LDLIBS += -lm                   # 수학 라이브러리 (sin, cos, sqrt 등)
# LDLIBS += -lpthread             # POSIX 스레드
# LDLIBS += -lstdc++              # C++ 표준 라이브러리 (C 컴파일 시)
# LDLIBS += -lboost_system        # Boost 라이브러리

# [디버깅 및 분석 도구] (CXXFLAGS/CFLAGS와 일치 필요)
# LDFLAGS += -fsanitize=address
# LDFLAGS += -fsanitize=undefined
# LDFLAGS += -fsanitize=thread
# LDFLAGS += -pg                  # gprof 프로파일링
# LDFLAGS += -fstack-protector-strong  # 스택 보호


# ------------------------------------------------------------------------------
# 1.9 pkg-config 자동 적용 (Pkg-Config Integration)
# ------------------------------------------------------------------------------
# 동작: pkg-config를 통해 외부 라이브러리를 링크합니다.
# 조건: 이 변수에 값이 있을 때만 pkg-config 도구를 호출합니다.
# 동작: PKGS 변수에 값이 할당된 경우에만 pkg-config를 실행하여 플래그를 가져옵니다.
# 조건: PKGS가 비어있으면 이 블록은 완전히 무시됩니다.

PKGS ?=
ifneq ($(PKGS),)
    # 1. pkg-config 도구 설치 여부 확인 (사용하려고 할 때만 검사)
    # 'which' 명령어로 경로를 찾습니다. 없으면 빈 값이 반환됩니다.
    HAS_PKG_CONFIG := $(shell which pkg-config 2>/dev/null)
    
    ifeq ($(HAS_PKG_CONFIG),)
        # PKGS를 썼는데 pkg-config가 없는 경우에만 에러 발생
        $(error $(FG_RED)[설정 오류] 'pkg-config'가 설치되어 있지 않습니다. PKGS 옵션을 사용하려면 pkg-config가 필요합니다.$(C_RESET))
    endif

    # 2. 라이브러리 존재 여부 확인 (--exists)
    # 쉘 종료 코드가 0이면 성공(라이브러리 있음), 아니면 실패
    PKG_EXISTS := $(shell pkg-config --exists $(PKGS) && echo 1 || echo 0)
    
    ifeq ($(PKG_EXISTS),0)
        # 라이브러리를 찾지 못한 경우 pkg-config의 에러 메시지를 보여주고 중단
        PKG_ERR := $(shell pkg-config --errors-to-stdout --print-errors $(PKGS))
        $(error $(FG_RED)[패키지 오류] 다음 라이브러리를 찾을 수 없습니다: $(PKGS)$(C_RESET)$(n)$(FG_YELLOW)$(PKG_ERR)$(C_RESET))
    else
        # 3. 플래그 추출 및 적용
        # --cflags: 헤더 경로 등 -> CFLAGS, CXXFLAGS에 추가
        # --libs: 링커 옵션 -> LDLIBS에 추가
        PKG_CFLAGS := $(shell pkg-config --cflags $(PKGS))
        PKG_LIBS   := $(shell pkg-config --libs $(PKGS))
        
        CFLAGS   += $(PKG_CFLAGS)
        CXXFLAGS += $(PKG_CFLAGS)
        LDLIBS   += $(PKG_LIBS)
        
        # verbose 모드일 때만 정보 출력
        ifeq ($(OUTPUT_MODE),verbose)
            $(info [INFO] pkg-config: Found $(PKGS))
            $(info [INFO] pkg-config CFLAGS: $(PKG_CFLAGS))
            $(info [INFO] pkg-config LIBS: $(PKG_LIBS))
        endif
    endif
endif

# ------------------------------------------------------------------------------
# 1.10 사용자 입력 처리 및 실행 설정 (User Input & Execution Configuration)
# ------------------------------------------------------------------------------
# 동작: 사용자가 명령줄(CLI)에서 전달한 모든 인자, 별칭, 옵션을 처리합니다.
#       짧은 별칭(s, m, i 등)을 정식 변수명으로 변환하고,
#       입력된 값의 유효성을 검사하거나 실행 인자(Args)를 조합합니다.
# 조건: 사용자가 입력한 짧은 변수가 실제 값을 가질 때만 정식 변수(MAIN_SRC, OUTPUT_MODE)로 변환합니다.
#       빈 값은 무시되어 기본값 설정 로직(?=)이 정상 작동합니다.
# ------------------------------------------------------------------------------

# 1.10.1 변수 별칭 매핑 (CLI Alias Mapping)
# 사용 편의를 위해 짧은 변수명을 긴 정식 변수명으로 매핑합니다.
# 우선순위: 정식 변수명(MAIN_SRC) > 짧은 별칭(s)

# [빌드 대상 파일] s -> MAIN_SRC
ifndef MAIN_SRC
    ifneq ($(s),)
        MAIN_SRC := $(firstword $(s))
    endif
endif

# [출력 모드] m -> OUTPUT_MODE
ifndef OUTPUT_MODE
    ifneq ($(m),)
        OUTPUT_MODE := $(firstword $(m))
    endif
endif
OUTPUT_MODE ?= normal  # 기본값 설정

# [실행 입출력] i -> STDIN, o -> STDOUT, e -> STDERR, a -> ARGS
ifndef STDIN
    ifneq ($(i),)
        STDIN := $(firstword $(i))
    endif
endif

ifndef STDOUT
    ifneq ($(o),)
        STDOUT := $(firstword $(o))
    endif
endif

ifndef STDERR
    ifneq ($(e),)
        STDERR := $(firstword $(e))
    endif
endif

ifndef ARGS
    ifneq ($(a),)
        ARGS := $(a)
    endif
endif

# 1.10.2 출력 모드 값 정규화 (Output Mode Normalization)
# 사용자가 입력한 짧은 값(v, s 등)을 전체 단어(verbose, silent)로 확장합니다.

ifeq ($(OUTPUT_MODE),v)
    OUTPUT_MODE := verbose
endif
ifeq ($(OUTPUT_MODE),s)
    OUTPUT_MODE := silent
endif
ifeq ($(OUTPUT_MODE),n)
    OUTPUT_MODE := normal
endif
ifeq ($(OUTPUT_MODE),b)
    OUTPUT_MODE := binary
endif
ifeq ($(OUTPUT_MODE),r)
    OUTPUT_MODE := raw
endif

# 1.10.3 실행 인자 구성 (Execution Arguments Construction)
# run 타겟에서 사용할 최종 실행 인자 문자열을 생성합니다.
# 리다이렉션(<, >, 2>)과 추가 인자를 결합합니다.

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

# ==============================================================================
# 시스템 도구 설정 (System Tools Configuration)
# ------------------------------------------------------------------------------
# 동작: 빌드 과정에서 사용되는 유틸리티 명령어와 파일 탐색 플래그를 정의합니다.
# 조건: Makefile이 로드될 때 한 번 실행되며, 이후 변경되지 않습니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 2.1 유틸리티 명령 정의
# ------------------------------------------------------------------------------
# 동작: 빌드 과정에서 자주 사용되는 셸 명령어와 플래그를 정의합니다.
# 조건: 이 변수들은 빌드 규칙과 타겟에서 재사용됩니다.

# MKDIR_P: 디렉토리를 재귀적으로 생성하는 명령 (부모 디렉토리도 함께 생성)
# 동작: build/leetcode/700.o 를 생성하기 전에 build/leetcode/ 디렉토리를 자동 생성
MKDIR_P := mkdir -p

# FIND_FLAGS: find 명령에서 사용할 파일 확장자 필터
# 동작: ALL_EXTS의 각 확장자를 -name '*.cpp' -o -name '*.c' 형태로 변환
# 예시: -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' -o -name '*.C' -o -name '*.c' -o
# 조건: 소스 파일 탐색 시 이 플래그를 사용하여 지정된 확장자만 찾습니다
FIND_FLAGS := $(foreach ext,$(ALL_EXTS), -name '*$(ext)' -o)

# ==============================================================================
# 출력 및 로깅 시스템 (Output & Logging System)
# ------------------------------------------------------------------------------
# 동작: 빌드 과정에서 터미널에 출력되는 메시지의 형식, 색상, 상세도를 제어합니다.
#       5가지 출력 모드(normal, verbose, silent, binary, raw)를 지원하여
#       다양한 사용 환경(일반 개발, 디버깅, CI/CD 등)에 대응합니다.
# 조건: OUTPUT_MODE 변수의 값에 따라 조건부로 로그 매크로가 정의됩니다.
#       잘못된 모드가 지정되면 경고 메시지를 출력하고 기본값(normal)으로 설정됩니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 3.1 ANSI 터미널 색상 코드 정의
# ------------------------------------------------------------------------------
# 동작: 터미널에서 텍스트의 색상과 스타일을 변경하기 위한 ANSI 이스케이프 시퀀스를 정의합니다.
# 조건: ANSI 색상을 지원하는 터미널(대부분의 현대 터미널)에서 작동합니다.
#       Windows에서는 Windows Terminal 또는 WSL 환경에서 사용 가능합니다.

# C_RESET: 모든 색상 및 스타일 효과를 초기화 (기본 터미널 색상으로 복원)
C_RESET := \033[0m

# 폰트 효과 (Font Effects)
# 굵은 글씨 (강조용)
FX_BOLD    := \033[0;1m
# 밑줄 (경로나 중요 정보 표시용)
FX_UL      := \033[0;4m 
# 굵은 글씨 + 밑줄 (최대 강조용)
FX_BOLD_UL := \033[0;1;4m

# 전경색 - 표준 색상 (Foreground Colors - Standard)
# 용도: 메시지 유형에 따라 다른 색상을 사용하여 가독성 향상
# 빨강 (에러 메시지용)
FG_RED     := \033[0;31m
# 초록 (성공 메시지용)
FG_GREEN   := \033[0;32m
# 노랑 (경고 메시지용)
FG_YELLOW  := \033[0;33m
# 파랑 (정보 메시지용)
FG_BLUE    := \033[0;34m
# 자주색 (파일 경로 강조용)
FG_MAGENTA := \033[0;35m
# 청록 (컴파일/링킹 단계 표시용)
FG_CYAN    := \033[0;36m

# 전경색 - 고강도 색상 (Foreground Colors - High Intensity / Bright)
# 용도: 본문 텍스트에 사용하여 표준 색상보다 밝고 읽기 쉽게 표현
# 밝은 파랑 (설명 텍스트용)
FG_BR_BLUE := \033[0;94m

# 조합 색상 - 파일 경로용 (Combined Colors for File Paths)
# 용도: 파일 경로를 강조하기 위한 굵고 밑줄친 자주색
# 굵고 밑줄친 자주색 (파일 경로 전용)
FG_BOLD_UL_MAGENTA    := \033[0;4;35m

# ------------------------------------------------------------------------------
# 3.2 출력 모드 검증
# ------------------------------------------------------------------------------
# 동작: 사용자가 지정한 OUTPUT_MODE가 유효한지 확인하고, MODE 변수에 할당합니다.
# 조건: 유효한 모드가 아니면 경고를 출력하고 기본값(normal)으로 설정합니다.

OUTPUT_MODE := $(strip $(OUTPUT_MODE))
ifneq ($(filter $(OUTPUT_MODE), normal silent verbose binary raw),)
    # 유효한 모드: OUTPUT_MODE 값을 MODE 변수에 그대로 할당
    MODE := $(OUTPUT_MODE)
else
    # 무효한 모드: 경고 메시지 출력 후 기본값으로 설정
    $(warning $(WRN_CFG_INVALID_MODE): '$(OUTPUT_MODE)' → 기본값 'normal'로 설정합니다.)
    MODE := normal
endif

# ------------------------------------------------------------------------------
# 3.3 출력 모드별 로그 매크로 정의
# ------------------------------------------------------------------------------
# 동작: MODE 변수의 값에 따라 서로 다른 로그 매크로를 정의합니다.
# 조건: Make의 조건부 처리(ifeq/else)를 사용하여 하나의 모드만 활성화됩니다.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 1: normal (일반 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 한글 메시지와 ANSI 색상을 사용하여 사용자 친화적인 출력을 제공합니다.
# 조건: 일반 개발 환경에서 사용하며, 빌드 과정을 직관적으로 확인할 수 있습니다.
ifeq ($(MODE),normal)
    # 1.1 설정 및 검증 (CFG) - 로그
    LOG_CFG_AUTO         = @echo "$(FG_BLUE)[정보] MAIN_SRC 미지정. 프로젝트 내 main 파일을 자동 탐색합니다.$(C_RESET)"
    LOG_CFG_MANUAL       = @echo "$(FG_BLUE)[정보] 수동 모드. 다음 파일을 빌드합니다: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_CFG_TARGET       = @echo "$(FG_BLUE)[정보] 빌드 대상: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    
    # 1.2 설정 및 검증 (CFG) - 에러
    ERR_CFG_NO_MAIN      := "$(FG_RED)[설정 오류] 'main.c' 또는 'main.cpp'를 찾을 수 없습니다.$(C_RESET)"
    WRN_CFG_INVALID_MODE := "$(FG_RED)[설정 오류] 지원하지 않는 출력 모드입니다.$(C_RESET)"
    ERR_CFG_FILE_NOT_FOUND    := "$(FG_RED)[파일 오류] 지정된 소스 파일이 존재하지 않습니다.$(C_RESET)"
    ERR_CFG_FILE_INVALID_EXT  := "$(FG_RED)[파일 오류] 지정된 파일이 C/C++ 소스가 아닙니다.$(C_RESET)"
    WRN_CFG_FILE_NO_HEADER   := "$(FG_YELLOW)[파일 경고] 필수 헤더 파일을 찾을 수 없습니다.$(C_RESET)"
    WRN_CFG_EXPERIMENTAL     := "[설정 경고] 실험적 기능이 활성화되었습니다: 전이적 의존성 탐색 (느릴 수 있음)"

    # 2.1 클린 프로세스 - 로그    
    LOG_CLN_MARKER_OK   = @echo "$(FG_GREEN)[안전] 빌드 폴더의 빌드 마커 확인 완료. 삭제를 진행합니다.$(C_RESET)"
    LOG_CLN_SUCCESS        = @echo "$(FG_GREEN)[완료] 빌드 디렉토리 삭제: $(FG_BOLD_UL_MAGENTA)$(BUILD_ROOT)$(C_RESET)"
    
    # 2.2 클린 프로세스 - 에러
    ERR_CLN_NO_MARKER   := $(FG_RED)[안전 오류] 빌드 마커가 없습니다. 이 디렉토리는 이 Makefile로 생성되지 않았습니다.$(C_RESET)
    ERR_CLN_DANGEROUS   := $(FG_RED)[안전 오류] 안전하지 않은 경로입니다. 삭제를 거부합니다.$(C_RESET)

    # 3.1 빌드 프로세스 (BLD) - 로그
    LOG_BLD_MARKER_CREATE = @echo "$(FG_BLUE)[안전] 빌드 마커 생성: $(FG_BOLD_UL_MAGENTA)$(BUILD_ROOT)/.make_safe_marker$(C_RESET)"
    LOG_BLD_START        = @echo "$(FG_BLUE)[시작] 빌드 프로세스를 시작합니다.$(C_RESET)"
    LOG_BLD_COMPILE      = @printf "$(FG_CYAN)[컴파일]$(C_RESET) $(FG_BOLD_UL_MAGENTA)%s$(C_RESET) $(FG_BR_BLUE)=>$(C_RESET) $(FG_BOLD_UL_MAGENTA)%s$(C_RESET)\n" "$(1)" "$(2)"
    LOG_BLD_LINK         = @echo "$(FG_CYAN)[링킹] 실행 파일 생성: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_BLD_SUCCESS          = @echo "$(FG_GREEN)[완료] 생성된 바이너리: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    
    # 3.2 빌드 프로세스 (BLD) - 에러
    ERR_BLD_COMPILE      := $(FG_RED)[빌드 실패] 컴파일 실패$(C_RESET)
    ERR_BLD_LINK         := $(FG_RED)[빌드 실패] 링킹 실패$(C_RESET)
    WRN_CFG_INVALID_MODE      := $(FG_YELLOW)[빌드 경고] 전처리 및 의존성 분석 실패$(C_RESET)
    
    # 4.1 런타임 (RUN) - 로그
    LOG_RUN_EXEC         = @echo "$(FG_GREEN)[실행] 프로그램 실행: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)..."
    LOG_RUN_START        = @echo "$(FG_GREEN)[실행] 프로그램 실행: $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    
    # 4.2 런타임 (RUN) - 에러
    ERR_RUN_NO_BIN       := $(FG_RED)[실행 오류] 실행할 파일이 없습니다.$(C_RESET)
    ERR_RUN_FAIL         := $(FG_RED)[실행 오류] 프로그램 실행 중 런타임 에러가 발생했습니다.$(C_RESET)
    
    # 5. 유틸리티 및 제어 매크로
    Q                    := @
    ABORT_ON_ERR         = || ( echo "$(1)" >&2; exit 1 )
    FMT_ERR              = $(1)
    FMT_WRN              = $(1)
    LOG_BUILD_FINISH     := @:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 2: verbose (상세 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 영어 메시지를 사용하고 모든 셸 명령을 그대로 출력합니다.
# 조건: 디버깅이나 빌드 과정의 세부 사항을 확인할 때 사용합니다.
#       CI/CD 로그 분석이나 빌드 문제 해결에 유용합니다.
else ifeq ($(MODE),verbose)
    # 1.1 설정 및 검증 (CFG) - 로그
    LOG_CFG_AUTO         = @echo "[INFO] Auto-detecting main source file."
    LOG_CFG_MANUAL       = @echo "[INFO] Manual mode selected. File: $(1)"
    LOG_CFG_TARGET       = @echo "[INFO] Target binary: $(1)"
    
    # 1.2 설정 및 검증 (CFG) - 에러
    ERR_CFG_NO_MAIN      := [CONFIG ERROR] Could not find main.c or main.cpp.
    WRN_CFG_INVALID_MODE := [CONFIG ERROR] Unsupported output mode specified.
    ERR_CFG_FILE_NOT_FOUND    := [FILE ERROR] The specified file does not exist
    ERR_CFG_FILE_INVALID_EXT  := [FILE ERROR] The specified file is not a valid C/C++ extension
    WRN_CFG_FILE_NO_HEADER   := [FILE ERROR] Required header file not found.
    WRN_CFG_EXPERIMENTAL     := [CONFIG WARNING] Experimental feature enabled: Transitive dependency discovery (may be slow).
    
    # 2.1 클린 프로세스 - 로그
    LOG_CLN_SUCCESS        = @echo "[INFO] Cleaning build directory: $(BUILD_ROOT)"
    LOG_CLN_MARKER_OK   = @echo "[SAFE] Build marker verified. Proceeding with deletion."
    
    # 2.2 클린 프로세스 - 에러
    ERR_CLN_NO_MARKER   := [SAFETY ERROR] Build marker not found. This directory was not created by this Makefile.
    ERR_CLN_DANGEROUS   := [SAFETY ERROR] Unsafe path detected. Deletion refused.
    
    # 3.1 빌드 프로세스 (BLD) - 로그
    LOG_BLD_MARKER_CREATE = @echo "[SAFE] Creating build marker: $(BUILD_ROOT)/.make_safe_marker"
    LOG_BLD_START        = @echo "[INFO] Build process started."
    LOG_BLD_COMPILE      = @echo "[INFO] Compiling: $(1)"
    LOG_BLD_LINK         = @echo "[INFO] Linking object files to: $(1)"
    LOG_BLD_SUCCESS          = @echo "[INFO] Build successful. Binary at: $(1)"
    
    # 3.2 빌드 프로세스 (BLD) - 에러
    ERR_BLD_COMPILE      := [BUILD FAILED] Compilation error
    ERR_BLD_LINK         := [BUILD FAILED] Linking error
    WRN_CFG_INVALID_MODE      := [BUILD FAILED] Preprocessing and dependency analysis failed
    
    # 4.1 런타임 (RUN) - 로그
    LOG_RUN_EXEC         = @echo "[INFO] Executing binary: $(1)"
    LOG_RUN_START        = @echo "[INFO] Executing binary: $(1)"
    
    # 4.2 런타임 (RUN) - 에러
    ERR_RUN_NO_BIN       := [RUNTIME ERROR] Executable not found
    ERR_RUN_FAIL         := [RUNTIME ERROR] Runtime error occurred during program execution.
    
    # 5. 유틸리티 및 제어 매크로
    Q                    :=
    ABORT_ON_ERR         =
    FMT_ERR              = $(1)
    FMT_WRN              = $(1)
    LOG_BUILD_FINISH     := @:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 3: silent (조용한 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 성공 시에는 아무것도 출력하지 않고, 에러 발생 시에만 메시지를 출력합니다.
# 조건: 스크립트 내에서 사용하거나, 출력을 최소화하고 싶을 때 사용합니다.
else ifeq ($(MODE),silent)
    # 1.1 설정 및 검증 (CFG) - 로그
    LOG_CFG_AUTO         = @:
    LOG_CFG_MANUAL       = @:
    LOG_CFG_TARGET       = @:
    
    # 1.2 설정 및 검증 (CFG) - 에러
    ERR_CFG_NO_MAIN      := Config error: Main file not found.
    WRN_CFG_INVALID_MODE := Config error: Invalid output mode.
    ERR_CFG_FILE_NOT_FOUND    := File error: Source file not found.
    ERR_CFG_FILE_INVALID_EXT  := File error: Not a source file.
    WRN_CFG_FILE_NO_HEADER   := File error: Header file not found.
    WRN_CFG_EXPERIMENTAL     := Config warning: Experimental feature enabled.
    
    # 2.1 클린 프로세스 - 로그
    LOG_CLN_SUCCESS        = @:
    LOG_CLN_MARKER_OK   = @:
    
    # 2.2 클린 프로세스 - 에러
    ERR_CLN_NO_MARKER   := Safety error: No build marker found.
    ERR_CLN_DANGEROUS   := Safety error: Unsafe path.
    
    # 3.1 빌드 프로세스 (BLD) - 로그
    LOG_BLD_MARKER_CREATE = @:
    LOG_BLD_START        = @:
    LOG_BLD_COMPILE      = @:
    LOG_BLD_LINK         = @:
    LOG_BLD_SUCCESS          = @:
    
    # 3.2 빌드 프로세스 (BLD) - 에러
    ERR_BLD_COMPILE      := Build failed: Compilation failed
    ERR_BLD_LINK         := Build failed: Linking failed
    WRN_CFG_INVALID_MODE      := Build failed: Preprocessing failed
    
    # 4.1 런타임 (RUN) - 로그
    LOG_RUN_EXEC         = @:
    LOG_RUN_START        = @:
    
    # 4.2 런타임 (RUN) - 에러
    ERR_RUN_NO_BIN       := Runtime error: Binary not found.
    ERR_RUN_FAIL         := Runtime error: Execution failed.
    
    # 5. 유틸리티 및 제어 매크로
    Q                    := @
    ABORT_ON_ERR         = || ( echo "$(1)" >&2; exit 1 )
    FMT_ERR              = $(1)
    FMT_WRN              = $(1)
    LOG_BUILD_FINISH     := @:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 4: binary (바이너리 경로 출력 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 빌드 성공 시 생성된 실행 파일의 경로만 출력합니다.
# 조건: 빌드 시스템을 다른 스크립트와 연동할 때 사용합니다.
#       파싱이 쉬워 자동화 스크립트에서 실행 파일 경로를 추출하기 용이합니다.
else ifeq ($(MODE),binary)
    # 1.1 설정 및 검증 (CFG) - 로그
    LOG_CFG_AUTO         = @:
    LOG_CFG_MANUAL       = @:
    LOG_CFG_TARGET       = @:
    
    # 1.2 설정 및 검증 (CFG) - 에러
    ERR_CFG_NO_MAIN      := [CONFIG] No main file
    WRN_CFG_INVALID_MODE := [CONFIG] Invalid mode
    ERR_CFG_FILE_NOT_FOUND    := [FILE] Missing file
    ERR_CFG_FILE_INVALID_EXT  := [FILE] Invalid type
    WRN_CFG_FILE_NO_HEADER   := [FILE] No header
    WRN_CFG_EXPERIMENTAL     := [CONFIG] Experimental feature enabled.
    
    # 2.1 클린 프로세스 - 로그
    LOG_CLN_SUCCESS        = @:
    LOG_CLN_MARKER_OK   = @:
    
    # 2.2 클린 프로세스 - 에러
    ERR_CLN_NO_MARKER   := [SAFETY] No marker
    ERR_CLN_DANGEROUS   := [SAFETY] Unsafe path
    
    # 3.1 빌드 프로세스 (BLD) - 로그
    LOG_BLD_MARKER_CREATE = @:
    LOG_BLD_START        = @:
    LOG_BLD_COMPILE      = @:
    LOG_BLD_LINK         = @:
    LOG_BLD_SUCCESS          = @:
    
    # 3.2 빌드 프로세스 (BLD) - 에러
    ERR_BLD_COMPILE      := [BUILD] Compile error
    ERR_BLD_LINK         := [BUILD] Link error
    WRN_CFG_INVALID_MODE      := [BUILD] Preproc error
    
    # 4.1 런타임 (RUN) - 로그
    LOG_RUN_EXEC         = @:
    LOG_RUN_START        = @:
    
    # 4.2 런타임 (RUN) - 에러
    ERR_RUN_NO_BIN       := [RUN] No binary
    ERR_RUN_FAIL         := [RUN] Runtime error
    
    # 5. 유틸리티 및 제어 매크로
    Q                    := @
    ABORT_ON_ERR         = ||  exit 1
    FMT_ERR              = $(1)
    FMT_WRN              = $(1)
    LOG_BUILD_FINISH     = @echo "$(1)"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 5: raw (원시 출력 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: Make와 컴파일러의 원본 출력만 표시하고, 추가 메시지를 출력하지 않습니다.
# 조건: 고급 사용자가 빌드 도구의 기본 동작을 확인하거나,
#       외부 빌드 분석 도구와 연동할 때 사용합니다.
else ifeq ($(MODE),raw)
    # 1.1 설정 및 검증 (CFG) - 로그
    LOG_CFG_AUTO         = @:
    LOG_CFG_MANUAL       = @:
    LOG_CFG_TARGET       = @:
    
    # 1.2 설정 및 검증 (CFG) - 에러
    ERR_CFG_NO_MAIN      :=
    WRN_CFG_INVALID_MODE :=
    ERR_CFG_FILE_NOT_FOUND    :=
    ERR_CFG_FILE_INVALID_EXT  :=
    WRN_CFG_FILE_NO_HEADER   :=
    WRN_CFG_EXPERIMENTAL     := 
    
    # 2.1 클린 프로세스 - 로그
    LOG_CLN_SUCCESS        = @:
    LOG_CLN_MARKER_OK   = @:
    
    # 2.2 클린 프로세스 - 에러
    ERR_CLN_NO_MARKER   :=
    ERR_CLN_DANGEROUS   :=
    
    # 3.1 빌드 프로세스 (BLD) - 로그
    LOG_BLD_MARKER_CREATE = @:
    LOG_BLD_START        = @:
    LOG_BLD_COMPILE      = @:
    LOG_BLD_LINK         = @:
    LOG_BLD_SUCCESS          = @:
    
    # 3.2 빌드 프로세스 (BLD) - 에러
    ERR_BLD_COMPILE      :=
    ERR_BLD_LINK         :=
    WRN_CFG_INVALID_MODE      :=
    
    # 4.1 런타임 (RUN) - 로그
    LOG_RUN_EXEC         = @:
    LOG_RUN_START        = @:
    
    # 4.2 런타임 (RUN) - 에러
    ERR_RUN_NO_BIN       :=
    ERR_RUN_FAIL         :=
    
    # 5. 유틸리티 및 제어 매크로
    Q                    :=
    ABORT_ON_ERR         =
    FMT_ERR              = $(1)
    FMT_WRN              = $(1)
    LOG_BUILD_FINISH     := @:
endif

# ==============================================================================
# 빌드 준비 및 의존성 분석 (Build Preparation & Dependency Analysis)
# ------------------------------------------------------------------------------
# 동작: 메인 소스 파일을 자동 또는 수동으로 탐색하고, 필요한 헤더 파일과
#       소스 파일 의존성을 자동으로 분석하여 컴파일할 파일 목록을 생성합니다.
# 조건: build, run, build-run, clean-build, clean-build-run 목표가 호출될 때만
#       실행됩니다. help나 clean만 실행할 때는 이 섹션이 처리되지 않습니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 4.1 유틸리티 함수 정의
# ------------------------------------------------------------------------------
# 동작: 파일 확장자를 기준으로 C/C++ 소스 파일인지 판별하는 함수를 정의합니다.
# 조건: 이 함수들은 빌드 과정 전반에서 파일 유형을 확인할 때 사용됩니다.

# IS_C: 주어진 파일이 C 소스 파일(.c)인지 확인
# 반환: C 파일이면 "1", 아니면 빈 문자열
# 사용 예: $(call IS_C,test.c) → "1", $(call IS_C,test.cpp) → ""
IS_C = $(if $(filter $(suffix $(1)),$(EXT_C)),1,)

# IS_CPP: 주어진 파일이 C++ 소스 파일(.cpp, .cc, .cxx, .C)인지 확인
# 반환: C++ 파일이면 "1", 아니면 빈 문자열
# 사용 예: $(call IS_CPP,test.cpp) → "1", $(call IS_CPP,test.c) → ""
IS_CPP = $(if $(filter $(suffix $(1)),$(EXT_CPP)),1,)

# IS_SRC: 주어진 파일이 C 또는 C++ 소스 파일인지 확인
# 반환: 소스 파일이면 "1", 아니면 빈 문자열
# 사용 예: $(call IS_SRC,test.cpp) → "1", $(call IS_SRC,README.md) → ""
IS_SRC = $(or $(call IS_C,$(1)),$(call IS_CPP,$(1)))

# ------------------------------------------------------------------------------
# 4.2 빌드 목표 정의
# ------------------------------------------------------------------------------
# 동작: 빌드 관련 작업이 필요한 Make 목표(target)를 정의합니다.
# 조건: 이 목표들이 명령줄에 지정되었을 때만 의존성 분석이 수행됩니다.

# TARGET_GOALS: 의존성 분석이 필요한 목표 리스트
TARGET_GOALS := build run build-run clean-build clean-build-run
# ------------------------------------------------------------------------------
# 4.3 조건부 의존성 분석 (빌드 목표가 호출될 때만 실행)
# ------------------------------------------------------------------------------
# 동작: 사용자가 빌드 관련 목표를 실행할 때만 이 블록이 처리됩니다.
# 조건: $(MAKECMDGOALS)에 TARGET_GOALS의 목표가 포함되어 있을 때만 동작합니다.
#       예: make build → 실행됨, make clean → 실행 안 됨, make help → 실행 안 됨
ifneq ($(filter $(TARGET_GOALS),$(MAKECMDGOALS)),)
    
    # --------------------------------------------------------------------------
    # 4.3.1 프로젝트 내 모든 소스 파일 탐색 (성능 최적화)
    # --------------------------------------------------------------------------
    # 동작: find 명령으로 SRC_ROOT 하위의 모든 C/C++ 소스 파일을 찾습니다.
    # 최적화: 결과를 SRCS 변수에 저장하여 이후 의존성 확인 시 재사용합니다. (I/O 감소)
    
    # SRCS: 프로젝트 내 모든 소스 파일 경로 목록
    # - find: 파일 시스템 탐색
    # - -type f: 일반 파일만 (디렉토리 제외)
    # - FIND_FLAGS: 지정된 확장자(.c, .cpp 등)만 필터링
    # - -not -path: BUILD_ROOT 내부 파일 제외
    # - sed 's|^./||': 경로 앞의 ./ 제거 (./test.c → test.c)
    # - sort -u: 알파벳 순 정렬 및 중복 제거
    SRCS := $(shell find $(SRC_ROOT) -type f \( $(FIND_FLAGS) -false \) -not -path '$(BUILD_ROOT)/*' | sed 's|^./||' | sort -u)
    
    # --------------------------------------------------------------------------
    # 4.3.2 메인 소스 파일 결정 (자동 탐색 vs 수동 지정)
    # --------------------------------------------------------------------------
    # 동작: MAIN_SRC 변수가 지정되었는지 확인하고, 그에 따라 처리 방식을 결정합니다.
    
    ifeq ($(origin MAIN_SRC), undefined)
        # 케이스 1: 자동 탐색 모드
        # 동작: SRCS 목록 내에서 main.cpp 또는 main.c 파일을 찾습니다.
        # 조건: 찾지 못하면 에러를 발생시켜 빌드를 중단합니다.
        
        MAIN_SRC_AUTO := $(firstword $(filter %main.cpp %main.c,$(SRCS)))
        ifeq ($(MAIN_SRC_AUTO),)
            $(error $(call FMT_ERR,$(ERR_CFG_NO_MAIN)))
        endif
        MAIN_SRC_NORM := $(MAIN_SRC_AUTO)
        CMD_LOG_MODE  := $(LOG_CFG_AUTO)
    else
        # 케이스 2: 수동 지정 모드
        # 동작: 사용자가 지정한 MAIN_SRC 파일의 유효성을 검증합니다.
        # 조건: 파일 존재 여부 및 확장자 확인
        
        # 경로 정규화: ./로 시작하는 경로를 제거 (./test.cpp → test.cpp)
        MAIN_SRC_NORM := $(shell echo $(MAIN_SRC) | sed 's|^./||')
        
        # 유효성 검증 1: 파일 존재 여부 확인
        ifeq ($(wildcard $(MAIN_SRC_NORM)),)
            $(error $(call FMT_ERR,$(ERR_CFG_FILE_NOT_FOUND): $(MAIN_SRC_NORM)))
        endif
        
        # 유효성 검증 2: C/C++ 소스 파일인지 확인
        ifneq ($(call IS_SRC,$(MAIN_SRC_NORM)),1)
            $(error $(call FMT_ERR,$(ERR_CFG_FILE_INVALID_EXT): $(MAIN_SRC_NORM)))
            CMD_LOG_MODE := $(call LOG_CFG_MANUAL,$(MAIN_SRC_NORM))
        endif
    endif
    
    # --------------------------------------------------------------------------
    # 4.3.3 빌드 타겟 경로 생성, 컴파일러 선택 (C vs C++)
    # --------------------------------------------------------------------------
    # 동작: 메인 소스 파일에서 실행 파일 경로를 생성합니다.
    # 동작: 메인 소스 파일의 확장자에 따라 적절한 컴파일러를 선택합니다.
    
    TARGET := $(BUILD_ROOT)/$(basename $(MAIN_SRC_NORM))
    
    ifeq ($(call IS_CPP,$(MAIN_SRC_NORM)),1)
        PREPROC := $(CXX) $(CPPFLAGS) $(CXXFLAGS)
    else
        PREPROC := $(CC) $(CPPFLAGS) $(CFLAGS)
    endif
    
    # --------------------------------------------------------------------------
    # 4.3.4 헤더 파일 의존성 분석
    # --------------------------------------------------------------------------
    # 동작: 컴파일러의 -MM 옵션을 사용하여 메인 소스 파일이 포함하는
    #       헤더 파일(.h) 목록을 자동으로 추출합니다.
    
    # DEPS_RAW: 컴파일러가 출력한 원시 의존성 정보
    DEPS_RAW := $(shell $(PREPROC) -MM $(MAIN_SRC_NORM) 2>/dev/null)
    
    # 전처리 실패 검증: DEPS_RAW가 비어있고 소스 파일이 존재하면 전처리 오류
    ifeq ($(DEPS_RAW),)
        ifneq ($(wildcard $(MAIN_SRC_NORM)),)
            $(warning $(call FMT_WRN,$(WRN_CFG_INVALID_MODE)): $(MAIN_SRC_NORM))
        endif
    endif
    
    # HDRS: 의존성에서 헤더 파일(.h)만 추출
    HDR_PATTERNS := $(foreach ext,$(EXT_HDR),%$(ext))
    HDRS := $(filter $(HDR_PATTERNS),$(subst :, ,$(DEPS_RAW)))
    
    # 헤더 파일 존재 여부 검증
    $(foreach hdr,$(HDRS),$(if $(wildcard $(hdr)),,$(warning $(call FMT_WRN,$(WRN_CFG_FILE_NO_HEADER)): $(hdr))))
    
    # --------------------------------------------------------------------------
    # 4.3.5 대응하는 소스 파일 탐색 (모드별 분기 처리)
    # --------------------------------------------------------------------------
    # 동작: DEPENDENCY_MODE 설정에 따라 헤더에 대응하는 구현 파일을 찾습니다.
    # 조건: 'path' 모드(경로 일치) 또는 'file' 모드(파일명 일치)를 사용합니다.

    ifeq ($(DEPENDENCY_MODE),standalone)
        # [모드: standalone] 단독 빌드
        # 동작: 의존성 분석을 수행하지 않고 메인 소스 파일 하나만 컴파일합니다.
        FINAL_SRCS := $(MAIN_SRC_NORM)

    else ifeq ($(DEPENDENCY_MODE),path)
        # [모드: path] 경로 일치 방식 [ 기본값 ]
        # 용도: LeetCode 등 중복 파일명이 많은 경우. 헤더와 소스가 같은 폴더여야 함.
        # 동작: include/utils.h -> include/utils.cpp 만 검색, 전이적 의존성 미지원
        HDR_BASES := $(basename $(HDRS))
        POTENTIAL_PAT := $(addsuffix .c,$(HDR_BASES)) $(addsuffix .cpp,$(HDR_BASES))
        REAL_DEPS := $(filter $(POTENTIAL_PAT),$(SRCS))
        
        # 최종 소스 결합
        FINAL_SRCS := $(sort $(MAIN_SRC_NORM) $(REAL_DEPS))

    else ifeq ($(DEPENDENCY_MODE),file)
        # [모드: file] 파일명 일치 방식
        # 용도: 일반적인 C++ 프로젝트 (include/ src/ 분리 구조 지원)
        # 동작: include/utils.h -> (utils) -> %/utils.cpp, utils.cpp 검색, 전이적 의존성 미지원
        HDR_FILENAMES := $(notdir $(HDRS))
        HDR_BASES_NO_PATH := $(basename $(HDR_FILENAMES))
        SEARCH_PATTERNS := $(foreach base,$(HDR_BASES_NO_PATH),%/$(base).cpp $(base).cpp %/$(base).c $(base).c)
        REAL_DEPS := $(filter $(SEARCH_PATTERNS),$(SRCS))

        # 최종 소스 결합
        FINAL_SRCS := $(sort $(MAIN_SRC_NORM) $(REAL_DEPS))
#     else ifeq ($(DEPENDENCY_MODE),transitive)
#         # [모드: transitive] 재귀적 의존성 탐색 (Transitive Dependency Discovery)
#         # 동작: BFS 알고리즘을 사용하여 소스->헤더->소스 연결 고리를 끝까지 추적합니다.
#         # 수정사항: Make 파싱 오류 방지를 위해 $() 대신 백틱(`)을 사용했습니다.
        
#         FINAL_SRCS := $(shell \
#             found="$(MAIN_SRC_NORM)"; \
#             queue="$(MAIN_SRC_NORM)"; \
#             while [ -n "$$queue" ]; do \
#                 \
#                 raw_deps=`$(PREPROC) -MM $$queue 2>/dev/null`; \
#                 headers=`echo "$$raw_deps" | sed 's/\\\\//g' | tr ' ' '\n' | grep '\.h$$' | sort -u`; \
#                 \
#                 next_queue=""; \
#                 for hdr in $$headers; do \
#                     base=$${hdr%.*}; \
#                     cand=""; \
#                     \
#                     if [ -f "$${base}.cpp" ]; then cand="$${base}.cpp"; \
#                     elif [ -f "$${base}.c" ]; then cand="$${base}.c"; \
#                     fi; \
#                     \
#                     if [ -n "$$cand" ]; then \
#                         is_exist=`echo "$$found" | grep -F -w "$$cand"`; \
#                         if [ -z "$$is_exist" ]; then \
#                             found="$$found $$cand"; \
#                             next_queue="$$next_queue $$cand"; \
#                         fi; \
#                     fi; \
#                 done; \
#                 \
#                 queue="$$next_queue"; \
#             done; \
#             echo $$found)

    else ifeq ($(DEPENDENCY_MODE),transitive_path)
        # [모드: transitive_path] 동일 폴더 기반 재귀 탐색
        
#         $(if $(filter normal verbose,$(MODE)),$(warning $(call FMT_WRN,$(WRN_CFG_EXPERIMENTAL))))
        
        FINAL_SRCS := $(shell \
            start_file="$(MAIN_SRC_NORM)"; \
            found_srcs="$$start_file"; \
            visited=""; \
            queue="$$start_file"; \
            while [ -n "$$queue" ]; do \
                current=$${queue%% *}; \
                if [ "$$current" = "$$queue" ]; then \
                    queue=""; \
                else \
                    queue="$${queue\#* }"; \
                fi; \
                is_visited=`echo "$$visited" | grep -F -w "$$current"`; \
                if [ -n "$$is_visited" ]; then continue; fi; \
                visited="$$visited $$current"; \
                raw_deps=`$(PREPROC) -MM "$$current" 2>/dev/null`; \
                headers=`echo "$$raw_deps" | sed 's/\\\\//g' | tr ' ' '\n' | grep -E '\.(h|hpp|hh|hxx|H)$$' | sort -u`; \
                for hdr in $$headers; do \
                    is_hdr_visited=`echo "$$visited" | grep -F -w "$$hdr"`; \
                    if [ -z "$$is_hdr_visited" ]; then \
                        queue="$$queue $$hdr"; \
                    fi; \
                    base="$${hdr%.*}"; \
                    cand=""; \
                    if [ -f "$${base}.cpp" ]; then cand="$${base}.cpp"; \
                    elif [ -f "$${base}.c" ]; then cand="$${base}.c"; \
                    elif [ -f "$${base}.cc" ]; then cand="$${base}.cc"; \
                    elif [ -f "$${base}.cxx" ]; then cand="$${base}.cxx"; \
                    elif [ -f "$${base}.C" ]; then cand="$${base}.C"; \
                    fi; \
                    if [ -n "$$cand" ]; then \
                        is_added=`echo "$$found_srcs" | grep -F -w "$$cand"`; \
                        if [ -z "$$is_added" ]; then \
                            found_srcs="$$found_srcs $$cand"; \
                            queue="$$queue $$cand"; \
                        fi; \
                    fi; \
                done; \
            done; \
            echo $$found_srcs)

    else ifeq ($(DEPENDENCY_MODE),transitive_file)
        # [모드: transitive_file] 동일 이름 기반 재귀 탐색
        
#         $(if $(filter normal verbose,$(MODE)),$(warning $(call FMT_WRN,$(WRN_CFG_EXPERIMENTAL))))

        FINAL_SRCS := $(shell \
            all_srcs="$(SRCS)"; \
            start_file="$(MAIN_SRC_NORM)"; \
            found_srcs="$$start_file"; \
            visited=""; \
            queue="$$start_file"; \
            while [ -n "$$queue" ]; do \
                current=$${queue%% *}; \
                if [ "$$current" = "$$queue" ]; then \
                    queue=""; \
                else \
                    queue="$${queue\#* }"; \
                fi; \
                is_visited=`echo "$$visited" | grep -F -w "$$current"`; \
                if [ -n "$$is_visited" ]; then continue; fi; \
                visited="$$visited $$current"; \
                raw_deps=`$(PREPROC) -MM "$$current" 2>/dev/null`; \
                headers=`echo "$$raw_deps" | sed 's/\\\\//g' | tr ' ' '\n' | grep -E '\.(h|hpp|hh|hxx|H)$$' | sort -u`; \
                for hdr in $$headers; do \
                    is_hdr_visited=`echo "$$visited" | grep -F -w "$$hdr"`; \
                    if [ -z "$$is_hdr_visited" ]; then \
                        queue="$$queue $$hdr"; \
                    fi; \
                    hdr_base=$$(basename "$$hdr"); \
                    name=$${hdr_base%.*}; \
                    match_srcs=`echo "$$all_srcs" | tr ' ' '\n' | grep -E "(^|/)$$name\.(cpp|cc|cxx|C|c)$$"` ; \
                    for cand in $$match_srcs; do \
                        if [ -n "$$cand" ]; then \
                            is_added=`echo "$$found_srcs" | grep -F -w "$$cand"`; \
                            if [ -z "$$is_added" ]; then \
                                found_srcs="$$found_srcs $$cand"; \
                                queue="$$queue $$cand"; \
                            fi; \
                        fi; \
                    done; \
                done; \
            done; \
            echo $$found_srcs)

    else ifeq ($(DEPENDENCY_MODE),all)
        # [모드: all] 전체 링크
        # 동작: SRC_ROOT 하위의 모든 소스 파일을 컴파일합니다.
        # 조건: 중복 main 함수에 대한 검증 없이 링커에게 처리를 맡깁니다.
        FINAL_SRCS := $(SRCS)
    endif
    
    # --------------------------------------------------------------------------
    # 4.3.6 오브젝트 파일 경로 생성
    # --------------------------------------------------------------------------
    # 동작: 각 소스 파일에 대응하는 오브젝트 파일(.o) 경로를 생성합니다.
    # 조건: 소스 파일의 디렉토리 구조를 BUILD_ROOT 하위에 그대로 복제합니다.
    
    # LINK_OBJS: 링킹 단계에서 사용할 오브젝트 파일 목록
    # 예: main.cpp → build/main.o
    LINK_OBJS := $(addsuffix .o,$(addprefix $(BUILD_ROOT)/,$(basename $(FINAL_SRCS))))

    # --------------------------------------------------------------------------
    # 4.3.7 링커 자동 선택 (Linker Auto-Selection)
    # --------------------------------------------------------------------------
    # 동작: 소스 파일 구성을 분석하여 적절한 링커(C vs C++)를 선택합니다.
    # 조건: 
    #   - C++ 파일(.cpp, .cc 등)이 하나라도 포함되면 -> $(CXX) (g++/clang++) 사용
    #   - 순수 C 파일(.c)만 존재하면 -> $(CC) (gcc/clang) 사용
    # 효과: 순수 C 프로젝트에서 불필요한 C++ 런타임 라이브러리 링크를 방지합니다.

    IS_CPP_PROJECT := $(filter $(foreach ext,$(EXT_CPP),%$(ext)),$(FINAL_SRCS))
    ifeq ($(IS_CPP_PROJECT),)
        LINKER := $(CC)
    else
        LINKER := $(CXX)
    endif
endif

# ==============================================================================
# 빌드 타겟 및 규칙 (Build Targets & Rules)
# ------------------------------------------------------------------------------
# 동작: 실제 빌드 작업을 수행하는 타겟들과 컴파일 규칙을 정의합니다.
#       make build, make run, make clean 등의 명령어가 여기서 처리됩니다.
# 조건: 사용자가 make 명령과 함께 타겟을 지정하면 해당 타겟이 실행됩니다.
#       타겟 간의 의존 관계에 따라 순차적으로 처리됩니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 5.1 기본 목표 설정 및 도움말
# ------------------------------------------------------------------------------
# 동작: 사용자가 make만 입력했을 때 실행될 기본 목표를 설정합니다.
# 조건: .DEFAULT_GOAL을 help로 설정하여 사용 방법을 안내합니다.

.DEFAULT_GOAL := help

# help 타겟: Makefile 사용 방법 출력
# 동작: 사용 가능한 모든 목표, 변수, 출력 모드, 사용 예시를 표시합니다.
# 조건: make 또는 make help 실행 시 동작합니다.
help:
	@echo ""
	@echo "$(FX_BOLD)NAME$(C_RESET)"
	@echo "    make - C/C++ 프로젝트 빌드 시스템"
	@echo ""
	@echo "$(FX_BOLD)SYNOPSIS$(C_RESET)"
	@echo "    make [$(FG_CYAN)target$(C_RESET)] [$(FG_YELLOW)MAIN_SRC$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)] [$(FG_YELLOW)OUTPUT_MODE$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET)] [$(FG_YELLOW)STDIN, STDOUT, STDERR$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)]"
	@echo ""
	@echo "$(FX_BOLD)DESCRIPTION$(C_RESET)"
	@echo "    C/C++ 소스 코드를 컴파일하고 실행 파일을 생성합니다."
	@echo "    헤더 파일 의존성을 자동으로 분석하여 관련 소스 파일을 함께 컴파일합니다. 만약 정교한 의존성 분석이 필요하다면 DEPENDENCY_MODE 변수를 조정할 수 있습니다."
	@echo ""
	@echo "$(FX_BOLD)TARGETS$(C_RESET)"
	@echo "    $(FG_CYAN)build$(C_RESET)"
	@echo "        소스 파일을 컴파일하여 실행 파일을 생성합니다."
	@echo "        MAIN_SRC가 지정되지 않으면 main.c 또는 main.cpp를 자동 탐색합니다."
	@echo ""
	@echo "    $(FG_CYAN)run$(C_RESET)"
	@echo "        빌드된 실행 파일을 실행합니다."
	@echo "        실행 파일이 없으면 에러를 반환합니다."
	@echo ""
	@echo "    $(FG_CYAN)build-run$(C_RESET)"
	@echo "        빌드와 실행을 연속으로 수행합니다. 가장 많이 사용되는 타겟입니다."
	@echo ""
	@echo "    $(FG_CYAN)clean$(C_RESET)"
	@echo "        빌드 디렉토리(ex: build/)를 안전하게 삭제합니다."
	@echo "        이 Makefile로 생성된 디렉토리만 삭제합니다."
	@echo "        안전을 위해 마커 파일(.make_safe_marker)이 없으면 삭제를 거부하고 종료 코드 1을 반환합니다."
	@echo ""
	@echo "    $(FG_CYAN)clean-build$(C_RESET)"
	@echo "        클린 후 완전히 새로 빌드합니다."
	@echo ""
	@echo "    $(FG_CYAN)clean-build-run$(C_RESET)"
	@echo "        클린, 빌드, 실행을 순차적으로 수행합니다."
	@echo ""
	@echo "    $(FG_CYAN)help$(C_RESET)"
	@echo "        이 도움말을 표시합니다."
	@echo ""
	@echo "$(FX_BOLD)VARIABLES$(C_RESET)"
	@echo "    $(FG_YELLOW)MAIN_SRC$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)  (짧은 별칭: $(FG_YELLOW)s$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)) (관련 타켓 : build, run)"
	@echo "        빌드할 메인 소스 파일의 경로를 지정합니다."
	@echo "        지정하지 않으면 main.c 또는 main.cpp를 자동으로 탐색합니다."
	@echo "        예: make build s=test.cpp"
	@echo ""
	@echo "    $(FG_YELLOW)OUTPUT_MODE$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET)  (짧은 별칭: $(FG_YELLOW)m$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET)) (관련 타켓 : 전체)"
	@echo "        빌드 과정의 출력 형식을 제어합니다."
	@echo "        예: make build m=verbose 또는 make build m=v"
	@echo ""
	@echo "        $(FG_MAGENTA)normal  (n)$(C_RESET)    한글 메시지, 색상 강조 (기본값)"
	@echo "        $(FG_MAGENTA)silent  (s)$(C_RESET)    성공 시 출력 없음, 에러만 표시"
	@echo "        $(FG_MAGENTA)verbose (v)$(C_RESET)    영어 메시지, 모든 명령어 출력"
	@echo "        $(FG_MAGENTA)binary  (b)$(C_RESET)    바이너리 경로만 출력 (도구 연동용)"
	@echo "        $(FG_MAGENTA)raw     (r)$(C_RESET)    Make, 컴파일러, 링커 원본 출력만 표시"
	@echo ""
	@echo "    $(FG_YELLOW)STDIN$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)i$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)) (관련 타켓 : run)"
	@echo "        실행 파일의 표준 입력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDIN=input.txt"
	@echo ""
	@echo "    $(FG_YELLOW)STDOUT$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)o$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)) (관련 타켓 : run)"
	@echo "        실행 파일의 표준 출력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDOUT=output.txt"
	@echo ""
	@echo "    $(FG_YELLOW)STDERR$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)e$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)) (관련 타켓 : run)"
	@echo "        실행 파일의 표준 오류 출력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDERR=error.log"
	@echo ""
	@echo "    $(FG_YELLOW)ARGS$(C_RESET)=$(FG_MAGENTA)"you want"$(C_RESET) (짧은 별칭: $(FG_YELLOW)a$(C_RESET)=$(FG_MAGENTA)"you want"$(C_RESET)) (관련 타켓 : run)"
	@echo "        실행 파일에 전달할 명령줄 인수를 지정합니다."
	@echo "        예: make run s=leetcode/700.cpp ARGS=\"arg1 arg2\""
	@echo "        예: make run s=leetcode/700.cpp a=\"| grep 'test'\""
	@echo "        예: make run s=leetcode/700.cpp a=\"< input.txt > output.txt\""
	@echo "        $(FG_YELLOW)STDIN$(C_RESET), $(FG_YELLOW)STDOUT$(C_RESET), $(FG_YELLOW)STDERR$(C_RESET) 변수 대신 사용할 수 있습니다."
	@echo ""
	@echo "$(FX_BOLD)ADVANCED VARIABLES$(C_RESET) : 일반적으로 인수로 지정하지 않고 Makefile 내에서 설정합니다. 하지만 필요에 따라 인수로 지정할 수 있습니다."
	@echo ""
	@echo "    $(FG_YELLOW)PROJECT_ROOT$(C_RESET)=$(FG_MAGENTA)dir$(C_RESET)"
	@echo "        프로젝트의 루트 디렉토리를 지정합니다. 기본값은 현재 디렉토리(./)입니다."
	@echo ""
	@echo "    $(FG_YELLOW)SRC_ROOT$(C_RESET)=$(FG_MAGENTA)dir$(C_RESET)"
	@echo "        소스 파일이 위치한 디렉토리를 지정합니다. 기본값은 프로젝트 루트 디렉토리(./)입니다."
	@echo ""
	@echo "    $(FG_YELLOW)BUILD_ROOT$(C_RESET)=$(FG_MAGENTA)dir$(C_RESET)"
	@echo "        빌드 결과물이 생성될 디렉토리를 지정합니다. 기본값은 ./build/입니다."
	@echo ""
	@echo "    $(FG_YELLOW)CC$(C_RESET)=$(FG_MAGENTA)compiler$(C_RESET)"
	@echo "        C 컴파일러를 지정합니다. 기본값은 gcc입니다. mac 의 경우 지정하지 않아도 clang이 기본 사용됩니다."
	@echo ""
	@echo "    $(FG_YELLOW)CXX$(C_RESET)=$(FG_MAGENTA)compiler$(C_RESET)"
	@echo "        C++ 컴파일러를 지정합니다. 기본값은 g++입니다. mac 의 경우 지정하지 않아도 clang++이 기본 사용됩니다."
	@echo ""
	@echo "    $(FG_YELLOW)CPPFLAGS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET) (= 대신 += 사용)"
	@echo "        공통 전처리기 플래그를 지정합니다. 기본값은 SRC_ROOT 경로입니다."
	@echo ""
	@echo "    $(FG_YELLOW)CFLAGS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET) (= 대신 += 사용)"
	@echo "        C++ 컴파일러 플래그를 지정합니다. 기본값은 -std=c11 -g -Wall I. 입니다."
	@echo ""
	@echo "    $(FG_YELLOW)CXXFLAGS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET) (= 대신 += 사용)"
	@echo "        C 컴파일러 플래그를 지정합니다. 기본값은 -std=c++17 -g -Wall I.입니다."
	@echo ""
	@echo "    $(FG_YELLOW)LDFLAGS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET) (= 대신 += 사용)"
	@echo "        링커 플래그를 지정합니다. 기본값은 빈 문자열입니다."
	@echo "        예: make build LDFLAGS+=-pthread"
	@echo ""
	@echo "    $(FG_YELLOW)LDLIBS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET) (= 대신 += 사용)"
	@echo "        링커 라이브러리 플래그를 지정합니다. 기본값은 빈 문자열입니다."
	@echo "        예: make build LDLIBS+=-lm"
	@echo "    $(FG_YELLOW)DEPENDENCY_MODE$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET)"
	@echo "        의존성 탐색 방식을 설정합니다. (기본값: path)"
	@echo "         $(FG_MAGENTA)file$(C_RESET) : [기본값] 파일명 기반 매칭 (Filename Matching)"
	@echo "             include/ 와 src/ 가 분리된 일반적인 프로젝트 구조 지원"
	@echo "             헤더: include/utils.h -> 소스: src/utils.cpp (찾음)"
	@echo "             단, 프로젝트 내에 '파일명'은 유일해야 합니다. (중복 시 충돌 가능)"
	@echo "         $(FG_MAGENTA)path$(C_RESET) : 경로 기반 매칭 (Path Matching)"
	@echo "             헤더와 소스가 같은 폴더에 위치해야 함 (Colocation)"
	@echo "             소스 파일명이 중복되는 경우 필수"
	@echo "             헤더: problem1/sol.h -> 소스: problem1/sol.cpp (찾음)"
	@echo "             헤더: problem1/sol.h -> 소스: problem2/sol.cpp (무시함 - 안전)"
	@echo "         $(FG_MAGENTA)standalone$(C_RESET) : 단독 빌드."
	@echo "             의존성 파일을 찾지 않고 MAIN_SRC만 빌드."
	@echo "         $(FG_MAGENTA)all$(C_RESET)"
	@echo "             전체 링크. 프로젝트 내 모든 소스를 링크 (main 중복 시 링커 에러)."
	@echo "             프로젝트 내의 모든 소스 파일을 컴파일 목록에 포함합니다 (전이적 의존성 임시 해결책)."
	@echo "             링커의 Dead Code Stripping 기능을 신뢰해 모든 파일을 포함하는 방식입니다."
	@echo "             사용하지 않는 함수의 코드 제거를 위해 다음 플래그 사용 권장"
	@echo "                 CXXFLAGS += -fdata-sections -ffunction-sections"
	@echo "                 CFLAGS   += -fdata-sections -ffunction-sections"
	@echo "                 LDFLAGS  += -Wl,--gc-sections"
	@echo "             정확한 전이적 의존성 해결 또는 정교한 빌드 기능을 원한다면 다른 고수준의 빌드 시스템(CMake, Bazel 등)을 사용하는 것을 권장합니다."
	@echo "         $(FG_MAGENTA)transitive_path$(C_RESET)"
	@echo "             전이적 탐색 (Transitive Dependency Discovery) - 동일 폴더 기반"
	@echo "             BFS 알고리즘을 사용하여 소스->헤더->소스 연결 고리를 끝까지 추적합니다."
	@echo "             include/utils.h -> src/utils.cpp 뿐만 아니라, src/utils.cpp가 포함하는 다른 헤더와 소스 파일도 함께 탐색합니다."
	@echo "             헤더와 소스 파일이 동일 폴더에 위치해야 합니다."
	@echo "         $(FG_MAGENTA)transitive_file$(C_RESET)"
	@echo "             전이적 탐색 (Transitive Dependency Discovery) - 동일 이름 기반"
	@echo "             BFS 알고리즘을 사용하여 소스->헤더->소스 연결 고리를 끝까지 추적합니다."
	@echo "             include/utils.h -> src/utils.cpp 뿐만 아니라, src/utils.cpp가 포함하는 다른 헤더와 소스 파일도 함께 탐색합니다."
	@echo "             헤더와 소스 파일이 동일 이름을 가져야 합니다."
	@echo ""
	@echo "$(FX_BOLD)EXAMPLES$(C_RESET)"
	@echo "    1. 기본 사용 (main.c/main.cpp 자동 빌드):"
	@echo "        $$ make build"
	@echo ""
	@echo "    2. 특정 파일 빌드 (전체 변수명):"
	@echo "        $$ make build MAIN_SRC=leetcode/700.cpp"
	@echo ""
	@echo "    3. 특정 파일 빌드 (짧은 별칭 사용):"
	@echo "        $$ make build s=leetcode/700.cpp"
	@echo ""
	@echo "    4. 빌드 후 즉시 실행:"
	@echo "        $$ make build-run s=swea/1244/main.cpp"
	@echo ""
	@echo "    5. 상세 로그와 함께 클린 빌드 (짧은 별칭 사용):"
	@echo "        $$ make clean-build-run s=leetcode/236.cpp m=verbose"
	@echo ""
	@echo "    6. 출력 모드 축약 사용:"
	@echo "        $$ make build s=leetcode/450.cpp m=v  # v는 verbose의 축약"
	@echo ""
	@echo "    7. 벤치마크 도구와 연동 (바이너리 경로 출력):"
	@echo ""
	@echo "       $(FG_CYAN)/usr/bin/time$(C_RESET) - 실행 시간 및 리소스 측정"
	@echo "         # 기본 시간 측정 (real/user/sys) - 짧은 별칭 사용"
	@echo "         /usr/bin/time \$$(make build s=leetcode/700.cpp m=binary)"
	@echo ""
	@echo "         # 상세 리소스 정보 출력 (-v)"
	@echo "         /usr/bin/time -v \$$(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 커스텀 포맷 지정 (-f)"
	@echo "         /usr/bin/time -f \"Time: %e sec, Memory: %M KB, CPU: %P\" \\"
	@echo "           \$$(make build MAIN_SRC=swea/1244/main.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 결과를 파일에 저장 (-o, -a)"
	@echo "         /usr/bin/time -f \"%e,%M,%P\" -o benchmark.log -a \\"
	@echo "           \$$(make build MAIN_SRC=leetcode/450.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "       $(FG_CYAN)hyperfine$(C_RESET) - 통계적 벤치마크 및 성능 비교"
	@echo "         # 기본 벤치마크 (10회 반복)"
	@echo "         hyperfine '\$$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "         # 웜업 및 실행 횟수 지정 (--warmup, --min-runs)"
	@echo "         hyperfine --warmup 3 --min-runs 20 \\"
	@echo "           '\$$(make build MAIN_SRC=swea/5215/main.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "         # 여러 솔루션 비교 (짧은 별칭 사용)"
	@echo "         hyperfine '\$$(make build s=leetcode/700.cpp m=binary)' \\"
	@echo "                   '\$$(make build s=leetcode/450.cpp m=binary)'"
	@echo ""
	@echo "    8. 여러 솔루션 성능 비교 (축약형 활용):"
	@echo "         hyperfine '\$$(make build s=leetcode/700.cpp m=b)' \\"
	@echo "                      '\$$(make build s=leetcode/450.cpp m=b)'  # b는 binary의 축약"
	@echo ""
	@echo "         # 명명된 비교 (--command-name)"
	@echo "         hyperfine --command-name 'DFS' '\$$(make build MAIN_SRC=leetcode/104.cpp OUTPUT_MODE=binary)' \\"
	@echo "                   --command-name 'BFS' '\$$(make build MAIN_SRC=leetcode/1161.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "         # 파라미터 치환 (-L)"
	@echo "         hyperfine -L file 700,450,236 \\"
	@echo "           '\$$(make build MAIN_SRC=leetcode/{file}.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "         # 매 실행 전 정리 작업 (--prepare)"
	@echo "         hyperfine --prepare 'make clean' --warmup 2 \\"
	@echo "           '\$$(make build MAIN_SRC=leetcode/1466.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "         # 결과 내보내기 (--export-markdown, --export-json)"
	@echo "         hyperfine --export-markdown results.md --export-json results.json \\"
	@echo "           '\$$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "       $(FG_CYAN)perf$(C_RESET) - CPU 프로파일링 및 성능 분석"
	@echo "         # 기본 통계 (stat)"
	@echo "         perf stat \$$(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 이벤트 지정 (-e)"
	@echo "         perf stat -e cycles,instructions,cache-misses \\"
	@echo "           \$$(make build MAIN_SRC=leetcode/1448.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 프로파일 기록 (record)"
	@echo "         perf record \$$(make build MAIN_SRC=swea/1209/main.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 함수별 프로파일 (top)"
	@echo "         perf top \$$(make build MAIN_SRC=leetcode/437.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "       $(FG_CYAN)valgrind$(C_RESET) - 메모리 누수 및 오류 검사"
	@echo "         # 메모리 누수 검사 (--leak-check)"
	@echo "         valgrind --leak-check=full \\"
	@echo "           \$$(make build MAIN_SRC=leetcode/1448.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 상세 누수 정보 (--show-leak-kinds)"
	@echo "         valgrind --leak-check=full --show-leak-kinds=all \\"
	@echo "           \$$(make build MAIN_SRC=leetcode/206.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 캐시 프로파일링 (cachegrind)"
	@echo "         valgrind --tool=cachegrind \\"
	@echo "           \$$(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "         # 힙 프로파일링 (massif)"
	@echo "         valgrind --tool=massif \\"
	@echo "           \$$(make build MAIN_SRC=swea/5215/main.cpp OUTPUT_MODE=binary)"
	@echo ""
	@echo "       $(FG_CYAN)gprof$(C_RESET) - 함수별 실행 시간 프로파일링"
	@echo "         # 프로파일링 활성화하여 빌드 (-pg 플래그 필요)"
	@echo "         CXXFLAGS=\"-pg\" make build MAIN_SRC=leetcode/700.cpp"
	@echo "         ./build/leetcode/700  # 실행하여 gmon.out 생성"
	@echo "         gprof ./build/leetcode/700 gmon.out > profile.txt"
	@echo ""
	@echo "    6. 여러 솔루션 성능 비교:"
	@echo "         hyperfine '\$$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)' \\"
	@echo "                      '\$$(make build MAIN_SRC=leetcode/450.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "$(FX_BOLD)EXIT STATUS$(C_RESET)"
	@echo "    빌드 성공 시 0을 반환합니다."
	@echo "    소스 파일을 찾을 수 없거나 컴파일/링킹 실패 시 1을 반환합니다."
	@echo "    안전 마커가 없는 디렉토리에 clean 시도 시 1을 반환합니다."
	@echo ""
	@echo "$(FX_BOLD)NOTES$(C_RESET)"
	@echo "    • VSCode, Zed 등의 tasks.json에서 이 Makefile을 활용할 수 있습니다."
	@echo "    • 헤더 파일이 변경되면 관련 소스 파일이 자동으로 재컴파일됩니다."
	@echo "    • OUTPUT_MODE=binary는 타 도구와 연동 시 유용합니다."
	@echo "    • $(FG_GREEN)[안전 기능]$(C_RESET) clean 타겟은 마커 파일을 확인하여 실수로 중요한 디렉토리를 삭제하는 것을 방지합니다."
	@echo "    • 빌드 시 BUILD_ROOT에 .make_safe_marker 파일이 자동 생성됩니다."
	@echo ""
	@echo "$(FX_BOLD)SEE ALSO$(C_RESET)"
	@echo "    gcc(1), g++(1), clang(1), time(1), hyperfine(1), perf(1), valgrind(1)"
	@echo ""

# ------------------------------------------------------------------------------
# 5.2 주요 빌드 타겟 정의
# ------------------------------------------------------------------------------
# 동작: 사용자가 호출할 수 있는 주요 빌드 작업을 정의합니다.
# 조건: 각 타겟은 다른 타겟에 의존할 수 있으며, 의존 관계에 따라 순차 실행됩니다.

# build 타겟: 소스 코드를 컴파일하고 실행 파일을 생성합니다.
# 동작: $(TARGET) 규칙을 실행하여 최종 바이너리를 생성합니다.
# 조건: MAIN_SRC가 지정되었거나 main.c/main.cpp가 존재해야 합니다.
# 의존성: $(TARGET) 규칙에 의존 (링킹 규칙)
build: $(TARGET)
	$(call LOG_BUILD_FINISH,$(TARGET))

# run 타겟: 빌드된 실행 파일을 실행합니다.
# 동작: 실행 파일이 존재하는지 확인하고, 존재하면 실행합니다.
# 조건: build 타겟이 먼저 실행되어 실행 파일이 생성되어 있어야 합니다.
run:
	$(Q)test -f "$(TARGET)" $(call ABORT_ON_ERR,$(ERR_RUN_NO_BIN): $(TARGET))
	$(call LOG_RUN_START,$(TARGET))
	$(Q)$(TARGET) $(FINAL_ARGS) $(call ABORT_ON_ERR,$(ERR_RUN_FAIL))

# clean 타겟: 빌드 디렉토리와 모든 빌드 결과물을 삭제합니다.
# 동작: BUILD_ROOT 디렉토리 전체를 재귀적으로 삭제합니다.
# 조건: 항상 실행 가능합니다 (소스 파일 없어도 동작).
# 안전장치: 마커 파일이 없으면 삭제를 거부하고 종료 코드 1을 반환합니다.
clean:
	$(if $(and $(wildcard $(BUILD_ROOT)),$(filter-out $(wildcard $(BUILD_ROOT)/.make_safe_marker),$(wildcard $(BUILD_ROOT)/.make_safe_marker))), \
		$(error $(ERR_CLN_NO_MARKER): $(BUILD_ROOT)))
	$(LOG_CLN_MARKER_OK)
	$(Q)rm -rf $(BUILD_ROOT)
	$(LOG_CLN_SUCCESS)

# ------------------------------------------------------------------------------
# 5.3 복합 타겟 정의
# ------------------------------------------------------------------------------
# 동작: 여러 타겟을 조합하여 순차적으로 실행합니다.
# 조건: 왼쪽에서 오른쪽 순서로 의존 타겟이 실행됩니다.

# build-run: 빌드 후 즉시 실행
# 동작 순서: 1. build → 2. run
build-run: build run

# clean-build: 이전 빌드 결과물을 삭제하고 새로 빌드
# 동작 순서: 1. clean → 2. build
clean-build: clean build

# clean-build-run: 이전 빌드 결과물 삭제, 새로 빌드, 실행
# 동작 순서: 1. clean → 2. build → 3. run
clean-build-run: clean build run

# ------------------------------------------------------------------------------
# 5.4 빌드 준비 타겟
# ------------------------------------------------------------------------------
# 동작: 실제 컴파일 전에 수행되어야 할 준비 작업을 처리합니다.
# 조건: 컴파일 규칙의 order-only 전제조건(|)으로 지정되어 매번 실행되지만
#       타임스탬프에는 영향을 주지 않습니다.

.PHONY: pre-build-setup
pre-build-setup:
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
	$(call LOG_CFG_TARGET,$(MAIN_SRC_NORM))

# ------------------------------------------------------------------------------
# 5.5 .PHONY 타겟 선언
# ------------------------------------------------------------------------------
# 동작: 파일 이름이 아닌 작업을 나타내는 타겟임을 명시합니다.
# 조건: .PHONY로 선언된 타겟은 항상 실행되며, 동일한 이름의 파일이 있어도
#       파일 타임스탬프를 확인하지 않습니다.

.PHONY: all help build run build-run clean clean-build clean-build-run compile_commands

# ==============================================================================
# 5.6 컴파일 및 링킹 규칙
# ==============================================================================
# 동작: 소스 파일(.c, .cpp)을 오브젝트 파일(.o)로 컴파일하고,
#       오브젝트 파일들을 링킹하여 최종 실행 파일을 생성합니다.
# 조건: Make의 패턴 규칙과 자동 변수를 활용하여 모든 소스 파일에 적용됩니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 5.6.1 링킹 규칙: 오브젝트 파일들을 실행 파일로 결합
# ------------------------------------------------------------------------------
# 동작: 모든 오브젝트 파일(.o)을 링크하여 최종 실행 파일을 생성합니다.
# 조건: 
#   - 모든 LINK_OBJS가 컴파일되어 있어야 합니다.
#   - | pre-build-setup : order-only 전제조건 (타임스탬프 영향 없음)
# 자동 변수:
#   $@  : 타겟 이름 (예: build/leetcode/700)
#   $^  : 모든 전제조건 (예: build/leetcode/700.o)

$(TARGET): $(LINK_OBJS) | pre-build-setup
	$(if $(wildcard $(dir $@)),,$(Q)$(MKDIR_P) $(dir $@))
	$(call LOG_BLD_LINK,$@)
	$(Q)$(LINKER) $(LDFLAGS) -o $@ $(LINK_OBJS) $(LDLIBS) $(call ABORT_ON_ERR,$(ERR_BLD_LINK): $@)
	$(call LOG_BLD_SUCCESS,$@)

# ------------------------------------------------------------------------------
# 5.6.2 C++ 컴파일 규칙 (패턴 규칙 생성 매크로)
# ------------------------------------------------------------------------------
# 동작: C++ 소스 파일(.cpp, .cc, .cxx, .C)을 오브젝트 파일(.o)로 컴파일합니다.
# 조건: 각 C++ 확장자마다 별도의 패턴 규칙이 생성됩니다.
# 의존성 추적:
#   -MMD : 사용자 헤더 파일 의존성만 추적 (.d 파일 생성)
#   -MP  : 헤더 파일 삭제 시 빌드 오류 방지 (phony 타겟 생성)
# 자동 변수:
#   $<  : 첫 번째 전제조건 (소스 파일, 예: leetcode/700.cpp)
#   $@  : 타겟 이름 (오브젝트 파일, 예: build/leetcode/700.o)
#   $(@D) : 타겟 디렉토리 (예: build/leetcode)

define RULE_CPP
$(BUILD_ROOT)/%.o: %$(1) | pre-build-setup
	$$(if $$(wildcard $$(@D)),,$$(Q)$(MKDIR_P) $$(@D))
	$$(call LOG_BLD_COMPILE,$$<,$$@)
	$$(Q)$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ $$(call ABORT_ON_ERR,$(ERR_BLD_COMPILE): $$<)
endef

# ------------------------------------------------------------------------------
# 5.6.3 C 컴파일 규칙 (패턴 규칙 생성 매크로)
# ------------------------------------------------------------------------------
# 동작: C 소스 파일(.c)을 오브젝트 파일(.o)로 컴파일합니다.
# 조건: C 확장자에 대한 패턴 규칙이 생성됩니다.
# 의존성 추적: C++ 규칙과 동일 (-MMD -MP)

define RULE_C
$(BUILD_ROOT)/%.o: %$(1) | pre-build-setup
	$$(if $$(wildcard $$(@D)),,$$(Q)$(MKDIR_P) $$(@D))
	$$(call LOG_BLD_COMPILE,$$<,$$@)
	$$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ $$(call ABORT_ON_ERR,$(ERR_BLD_COMPILE): $$<)
endef

# ------------------------------------------------------------------------------
# 5.6.4 컴파일 규칙 생성 (매크로 평가)
# ------------------------------------------------------------------------------
# 동작: 정의된 매크로를 각 파일 확장자에 대해 평가하여 실제 규칙을 생성합니다.
# 조건: EXT_CPP와 EXT_C에 정의된 모든 확장자에 대해 규칙이 생성됩니다.
# 예시:
#   .cpp → build/%.o: %.cpp 규칙 생성
#   .cc  → build/%.o: %.cc 규칙 생성
#   .c   → build/%.o: %.c 규칙 생성

$(foreach ext,$(EXT_CPP),$(eval $(call RULE_CPP,$(ext))))
$(foreach ext,$(EXT_C),$(eval $(call RULE_C,$(ext))))

# ------------------------------------------------------------------------------
# 5.6.5 의존성 파일 포함
# ------------------------------------------------------------------------------
# 동작: 컴파일러가 생성한 의존성 파일(.d)을 Make에 포함시킵니다.
# 조건: LINK_OBJS가 정의되어 있을 때만 의존성 파일을 포함합니다.
# 효과: 헤더 파일이 변경되면 자동으로 관련 소스 파일이 재컴파일됩니다.
# -include: 파일이 없어도 에러를 발생시키지 않음 (첫 빌드 시 .d 파일 없음)

ifneq ($(LINK_OBJS),)
    -include $(LINK_OBJS:.o=.d)
endif

# ------------------------------------------------------------------------------
# 5.7 컴파일 데이터베이스 생성 (LSP 지원)
# ------------------------------------------------------------------------------
# 동작: compile_commands.json 파일을 생성합니다.
#       VSCode, clangd, ccls 등 최신 에디터의 인텔리센스 기능을 지원합니다.
#       외부 도구(bear 등) 없이 Makefile 자체적으로 생성합니다.

# compile_commands:
# 	@echo "$(FG_BLUE)[정보] compile_commands.json 생성 중...$(C_RESET)"
# 	$(Q)echo "[" > compile_commands.json
# 	$(Q)$(foreach src,$(SRCS), \
# 		printf "  {\n" >> compile_commands.json; \
# 		printf "    \"directory\": \"$(shell pwd)\",\n" >> compile_commands.json; \
# 		printf "    \"command\": \"$(if $(call IS_CPP,$(src)),$(CXX) $(CPPFLAGS) $(CXXFLAGS),$(CC) $(CPPFLAGS) $(CFLAGS)) -c $(src) -o $(BUILD_ROOT)/$(basename $(src)).o\",\n" >> compile_commands.json; \
# 		printf "    \"file\": \"$(src)\"\n" >> compile_commands.json; \
# 		printf "  },\n" >> compile_commands.json; \
# 	)
# 	$(Q)sed -i.bak '$$s/,$$//' compile_commands.json && rm compile_commands.json.bak
# 	$(Q)echo "]" >> compile_commands.json
# 	@echo "$(FG_GREEN)[완료] compile_commands.json 생성 완료.$(C_RESET)"