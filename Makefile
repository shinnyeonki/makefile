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
# 1.2 인클루드 경로 설정
# ------------------------------------------------------------------------------
# 동작: 컴파일러가 헤더 파일(.h)을 탐색할 디렉토리 목록을 정의합니다.
# 조건: -I 플래그와 함께 컴파일러에 전달되어 #include 지시문을 해석할 때 사용됩니다.
#       여러 경로를 추가하려면 += 연산자를 사용하여 확장할 수 있습니다.

# 기본 인클루드 경로로 소스 루트 디렉토리를 지정
INCLUDE_DIRS := $(SRC_ROOT)

# 추가 인클루드 경로 예시 (필요시 주석 해제 및 수정):
# INCLUDE_DIRS += ./include
# INCLUDE_DIRS += ./third_party/lib
# INCLUDE_DIRS += /usr/local/include

# ------------------------------------------------------------------------------
# 1.3 컴파일러 플래그 설정
# ------------------------------------------------------------------------------
# 동작: C++ 및 C 컴파일러에 전달할 옵션을 정의합니다.
# 조건: 컴파일 단계에서 각 소스 파일을 오브젝트 파일로 변환할 때 적용됩니다.
#       사용자는 여기서 최적화 수준, 경고 옵션, 표준 버전 등을 조정할 수 있습니다.

# CXXFLAGS: C++ 컴파일러 옵션
# -std=c++17  : C++17 표준을 사용합니다 (범위 기반 for, auto, 람다 등 활용 가능)
# -g          : 디버깅 정보를 포함합니다 (GDB 등의 디버거에서 소스 코드 확인 가능)
# -Wall       : 일반적인 경고를 모두 활성화합니다 (코드 품질 향상에 도움)
# -I 경로     : INCLUDE_DIRS의 각 경로를 -I 플래그로 변환하여 추가
CXXFLAGS := -std=c++17 -g -Wall $(addprefix -I,$(INCLUDE_DIRS))


# CFLAGS: C 컴파일러 옵션
# -std=c11    : C11 표준을 사용합니다
# -g          : 디버깅 정보를 포함합니다
# -Wall       : 일반적인 경고를 모두 활성화합니다
# -I 경로     : INCLUDE_DIRS의 각 경로를 -I 플래그로 변환하여 추가
CFLAGS := -std=c11 -g -Wall $(addprefix -I,$(INCLUDE_DIRS))

# 추가 컴파일러 플래그 예시 (필요시 주석 해제 및 수정):
# CXXFLAGS += -O2              # 최적화 레벨 2 (릴리즈 빌드)
# CXXFLAGS += -Werror          # 모든 경고를 에러로 처리
# CXXFLAGS += -fsanitize=address # AddressSanitizer 활성화 (메모리 오류 검출)

# ------------------------------------------------------------------------------
# 1.4 링커 플래그 설정
# ------------------------------------------------------------------------------
# 동작: 링커에 전달할 옵션을 정의합니다.
# 조건: 모든 오브젝트 파일을 실행 파일로 결합하는 링킹 단계에서 적용됩니다.
#       외부 라이브러리를 연결하거나 링커 동작을 제어할 때 사용합니다.

# LDFLAGS: 링커 옵션 (링커 경로, 링커 동작 제어 등)
# 예: -L/usr/local/lib (라이브러리 검색 경로 추가)
LDFLAGS :=

# LDLIBS: 링크할 라이브러리 목록
# 예: -lm (수학 라이브러리), -lpthread (POSIX 스레드 라이브러리)
LDLIBS :=

# 라이브러리 연결 예시 (필요시 주석 해제 및 수정):
# LDLIBS += -lm                # 수학 라이브러리 연결
# LDLIBS += -lpthread          # 멀티스레딩 라이브러리 연결
# LDFLAGS += -L./lib           # 사용자 정의 라이브러리 경로 추가

# ------------------------------------------------------------------------------
# 1.5 명령줄 별칭 및 값 정규화 (CLI Aliases & Normalization)
# ------------------------------------------------------------------------------
# 동작: 긴 변수명 대신 짧은 별칭(s, m 등)이나 축약된 값(v, s 등)을 사용할 수 있게 합니다.
# 조건: 사용자가 입력한 짧은 변수가 실제 값을 가질 때만 정식 변수(MAIN_SRC, OUTPUT_MODE)로 변환합니다.
#       빈 값은 무시되어 기본값 설정 로직(?=)이 정상 작동합니다.

# [변수명 별칭 처리]
# 사용자가 's' 변수에 값을 입력했다면 MAIN_SRC로 설정
# 예: make build s=test.cpp  ->  MAIN_SRC=test.cpp
# 주의: s= (빈 값)은 무시되어 MAIN_SRC의 기본값 설정에 영향을 주지 않습니다.
ifndef MAIN_SRC
    ifneq ($(s),)
        MAIN_SRC := $(firstword $(s))
    endif
endif

# 사용자가 'm' 변수에 값을 입력했다면 OUTPUT_MODE로 설정
# 예: make build m=verbose  ->  OUTPUT_MODE=verbose
# 주의: m= (빈 값)은 무시되어 OUTPUT_MODE의 기본값 설정에 영향을 주지 않습니다.
ifndef OUTPUT_MODE
    ifneq ($(m),)
        OUTPUT_MODE := $(firstword $(m))
    endif
endif

# [출력 모드 값 축약 처리]
# 사용자가 'v', 's' 같은 한 글자 값을 입력했을 때 전체 단어로 확장
# 예: make build m=v  ->  OUTPUT_MODE=verbose

# v -> verbose
ifeq ($(OUTPUT_MODE),v)
    OUTPUT_MODE := verbose
endif
# s -> silent
ifeq ($(OUTPUT_MODE),s)
    OUTPUT_MODE := silent
endif
# n -> normal
ifeq ($(OUTPUT_MODE),n)
    OUTPUT_MODE := normal
endif
# b -> binary
ifeq ($(OUTPUT_MODE),b)
    OUTPUT_MODE := binary
endif
# r -> raw
ifeq ($(OUTPUT_MODE),r)
    OUTPUT_MODE := raw
endif

# ------------------------------------------------------------------------------
# 1.6 출력 모드 설정
# ------------------------------------------------------------------------------
# 동작: 빌드 과정에서 터미널에 출력되는 메시지의 형식과 상세도를 제어합니다.
# 조건: ?= 연산자로 기본값을 설정하며, 명령줄에서 변경 가능합니다.
#       예: make build OUTPUT_MODE=verbose

# OUTPUT_MODE: 빌드 로그 출력 모드 선택
# - normal  : 한글 메시지와 색상 강조 (기본값, 일반 사용자에게 친화적)
# - verbose : 영어 메시지와 모든 명령어 출력 (디버깅 및 상세 분석용)
# - silent  : 성공 시 출력 없음, 에러만 표시 (CI/CD 환경에 적합)
# - binary  : 빌드 성공 시 바이너리 경로만 출력 (스크립트 연동용)
# - raw     : Make와 컴파일러의 원본 출력만 표시 (고급 사용자용)
OUTPUT_MODE ?= normal

# # ------------------------------------------------------------------------------
# # 1.7 명령줄 인자 파싱 (CLI Argument Parsing)
# # ------------------------------------------------------------------------------
# # 동작: 'MAIN_SRC=경로' 없이 파일 경로만 입력해도 자동으로 MAIN_SRC로 인식합니다.
# #       예: make build test.cpp -> 자동으로 MAIN_SRC=test.cpp로 설정
# # 조건: 정의된 타겟(build, run 등)이 아닌 인자를 소스 파일로 간주합니다.

# # Makefile에 정의된 주요 타겟 목록 (이 이름들은 파일명으로 오인되지 않음)
# KNOWN_TARGETS := $(shell grep -h "^\.PHONY" $(MAKEFILE_LIST) | sed 's/^\.PHONY: *//' | tr ' ' '\n' | sort -u)

# # 커맨드 라인 인자 중 KNOWN_TARGETS에 포함되지 않는 첫 번째 단어를 추출
# CLI_ARGS := $(filter-out $(KNOWN_TARGETS),$(MAKECMDGOALS))
# POTENTIAL_FILE := $(firstword $(CLI_ARGS))

# # 1. MAIN_SRC가 명시적으로 지정되지 않았고 ('MAIN_SRC=...' 없음)
# # 2. 추출한 인자가 존재하며
# # 3. 실제 파일 시스템에 존재하는 파일이라면 -> MAIN_SRC로 할당
# ifeq ($(origin MAIN_SRC), undefined)
#     ifneq ($(POTENTIAL_FILE),)
#         ifneq ($(wildcard $(POTENTIAL_FILE)),)
#             MAIN_SRC := $(POTENTIAL_FILE)
            
#             # 중요: Make는 인자로 들어온 파일명을 '타겟'으로 인식하고 빌드하려 시도합니다.
#             # 이를 방지하기 위해 해당 파일명에 대한 아무 동작도 하지 않는 더미 규칙을 생성합니다.
#             $(POTENTIAL_FILE):
# 				@:
#         endif
#     endif
# endif


# ------------------------------------------------------------------------------
# 1.8 실행 I/O 설정 및 별칭 (Execution I/O & Aliases)
# ------------------------------------------------------------------------------
# 동작: 실행 시 사용할 입출력 파일 변수를 처리하고 별칭을 연결합니다.
#       i -> STDIN, o -> STDOUT, e -> STDERR

# [별칭 처리]
# i=input.txt -> STDIN=input.txt
ifndef STDIN
    ifneq ($(i),)
        STDIN := $(firstword $(i))
    endif
endif

# o=output.txt -> STDOUT=output.txt
ifndef STDOUT
    ifneq ($(o),)
        STDOUT := $(firstword $(o))
    endif
endif

# e=error.log -> STDERR=error.log
ifndef STDERR
    ifneq ($(e),)
        STDERR := $(firstword $(e))
    endif
endif

# [실행 인자 구성]
# 정의된 변수에 따라 리다이렉션 문자열을 조합합니다.
RUN_ARGS :=
ifneq ($(STDIN),)
    RUN_ARGS += < $(STDIN)
endif
ifneq ($(STDOUT),)
    RUN_ARGS += > $(STDOUT)
endif
ifneq ($(STDERR),)
    RUN_ARGS += 2> $(STDERR)
endif


# ==============================================================================
# 컴파일러 및 시스템 설정 (Compiler & System Detection)
# ------------------------------------------------------------------------------
# 동작: 운영체제를 자동으로 감지하여 적절한 컴파일러를 선택하고,
#       빌드에 필요한 도구와 파일 확장자를 정의합니다.
# 조건: Makefile이 로드될 때 한 번 실행되며, 이후 변경되지 않습니다.
#       크로스 플랫폼 빌드를 지원하기 위해 운영체제별로 최적의 컴파일러를 자동 선택합니다.
# ==============================================================================

# ------------------------------------------------------------------------------
# 2.1 운영체제 감지 및 컴파일러 선택
# ------------------------------------------------------------------------------
# 동작: uname -s 명령으로 OS를 확인하고, OS에 맞는 컴파일러를 설정합니다.
# 조건: 
#   - Darwin (macOS)  : clang/clang++ 사용 (Apple의 기본 컴파일러)
#   - Linux           : gcc/g++ 사용 (GNU 컴파일러 컬렉션)
#   - 기타 OS         : gcc/g++를 기본값으로 사용

ifeq ($(shell uname -s),Darwin)
    # macOS 감지: LLVM 기반의 clang 컴파일러 사용
    CXX = clang++  # C++ 컴파일러
    CC = clang     # C 컴파일러
else ifeq ($(shell uname -s),Linux)
    # Linux 감지: GNU 컴파일러 사용
    CXX = g++      # C++ 컴파일러
    CC = gcc       # C 컴파일러
else
    # 기타 UNIX 계열 또는 미지원 OS: GNU 컴파일러를 기본값으로 사용
    CXX = g++      # C++ 컴파일러 (기본값)
    CC = gcc       # C 컴파일러 (기본값)
endif

# 컴파일러 오버라이드 예시 (필요시 명령줄에서 사용):
# make build CXX=clang++ CC=clang

# ------------------------------------------------------------------------------
# 2.2 파일 확장자 정의
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

# ALL_EXTS: 모든 지원 확장자를 하나의 리스트로 결합
# C++와 C 파일을 모두 포함하여 프로젝트 전체 소스 파일을 탐색할 때 사용
ALL_EXTS := $(EXT_CPP) $(EXT_C)

# ------------------------------------------------------------------------------
# 2.3 유틸리티 명령 정의
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

ifneq ($(filter $(OUTPUT_MODE), normal silent verbose binary raw),)
    # 유효한 모드: OUTPUT_MODE 값을 MODE 변수에 그대로 할당
    MODE := $(OUTPUT_MODE)
else
    # 무효한 모드: 경고 메시지 출력 후 기본값으로 설정
    $(warning 적절한 출력 모드가 아닙니다: '$(OUTPUT_MODE)', 기본값 'normal'로 설정합니다.)
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
    # 텍스트 메시지 정의 (태그 포함)
    TXT_START       := [시작] 빌드 프로세스를 시작합니다.
    TXT_AUTO        := [정보] MAIN_SRC 미지정. 프로젝트 내 main 파일을 자동 탐색합니다.
    TXT_MANUAL      := [정보] 수동 모드. 다음 파일을 빌드합니다:
    TXT_TARGET      := [정보] 빌드 대상:
    TXT_COMPILE     := [컴파일]
    TXT_LINK        := [링킹] 실행 파일 생성:
    TXT_CLEAN       := [청소] 빌드 디렉토리 삭제:
    TXT_SUCCESS     := [완료] 생성된 바이너리:
    TXT_RUN         := [실행] 프로그램 실행:
    TXT_ERR_PREFIX  := [오류]
    TXT_ERR_NO_MAIN := 'main.c' 또는 'main.cpp'를 찾을 수 없습니다.
    TXT_ERR_NO_FILE := 지정된 소스 파일이 존재하지 않습니다.
    TXT_ERR_NOT_SRC := 지정된 파일이 C/C++ 소스가 아닙니다.
    TXT_ERR_NO_EXEC := 실행할 파일이 없습니다.
    TXT_FAIL_CMP    := 컴파일 실패
    TXT_FAIL_LNK    := 링킹 실패
    
    # Q 변수: 명령 출력 억제 (@는 명령을 숨기고 결과만 표시)
    Q := @
    
    # --------------------------------------------------------------------------
    # 로그 매크로 정의 (스타일 규칙)
    # --------------------------------------------------------------------------
    # 1. 태그(Tag): 메시지 유형별로 다른 색상 사용 (Blue, Cyan, Green, Yellow, Red)
    # 2. 본문(Body): FG_BR_BLUE (밝은 파랑)으로 설명 텍스트 통일
    # 3. 대상(Obj): FG_BOLD_UL_MAGENTA (굵고 밑줄친 자주색)으로 파일 경로 강조
    	
    LOG_START        = @echo "$(FG_BLUE)$(TXT_START)$(C_RESET)"
    LOG_INFO_AUTO    = @echo "$(FG_BLUE)$(TXT_AUTO)$(C_RESET)"
    LOG_INFO_MAN     = @echo "$(FG_BLUE)$(TXT_MANUAL) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_TARGET       = @echo "$(FG_BLUE)$(TXT_TARGET) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_COMPILE      = @printf "$(FG_CYAN)%s$(C_RESET) $(FG_BOLD_UL_MAGENTA)%s$(C_RESET) $(FG_BR_BLUE)=>$(C_RESET) $(FG_BOLD_UL_MAGENTA)%s$(C_RESET)\n" "$(TXT_COMPILE)" "$(1)" "$(2)"
    LOG_LINK         = @echo "$(FG_CYAN)$(TXT_LINK) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_CLEAN        = @echo "$(FG_YELLOW)$(TXT_CLEAN) $(FG_BOLD_UL_MAGENTA)$(BUILD_ROOT)$(C_RESET)"
    LOG_SUCCESS      = @echo "$(FG_GREEN)$(TXT_SUCCESS) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    LOG_RUN          = @echo "$(FG_GREEN)$(TXT_RUN) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)..."
    LOG_RUN_START    = @echo "$(FG_GREEN)$(TXT_RUN) $(FG_BOLD_UL_MAGENTA)$(1)$(C_RESET)"
    
    # 에러 처리 매크로
    ON_FAIL          = ( echo "$(FG_RED)$(TXT_ERR_PREFIX) $(1)$(C_RESET)" >&2; exit 1 )
    MK_ERR_FMT       = $(TXT_ERR_PREFIX) $(1)
    
    # 빌드 완료 후 추가 메시지 (normal 모드에서는 출력하지 않음)
    LOG_BUILD_FINISH := @:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 2: verbose (상세 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 영어 메시지를 사용하고 모든 셸 명령을 그대로 출력합니다.
# 조건: 디버깅이나 빌드 과정의 세부 사항을 확인할 때 사용합니다.
#       CI/CD 로그 분석이나 빌드 문제 해결에 유용합니다.
else ifeq ($(MODE),verbose)
    # 영어 텍스트 메시지 정의 (태그 포함)
    TXT_START       := [INFO] Build process started.
    TXT_AUTO        := [INFO] Auto-detecting main source file.
    TXT_MANUAL      := [INFO] Manual mode selected. File:
    TXT_TARGET      := [INFO] Target binary:
    TXT_COMPILE     := [INFO] Compiling:
    TXT_LINK        := [INFO] Linking object files to:
    TXT_CLEAN       := [INFO] Cleaning build directory:
    TXT_SUCCESS     := [INFO] Build successful. Binary at:
    TXT_RUN         := [INFO] Executing binary:
    TXT_ERR_PREFIX  := [FATAL]
    TXT_ERR_NO_MAIN := Could not find main.c or main.cpp.
    TXT_ERR_NO_FILE := The specified file does not exist
    TXT_ERR_NOT_SRC := The specified file is not a valid C/C++ extension
    TXT_ERR_NO_EXEC := Executable not found
    TXT_FAIL_CMP    := Compilation error
    TXT_FAIL_LNK    := Linking error
    
    # Q 변수: 비워서 모든 명령을 출력 (셸 명령이 실행 전에 화면에 표시됨)
    Q :=
    
    LOG_START        = @echo "$(TXT_START)"
    LOG_INFO_AUTO    = @echo "$(TXT_AUTO)"
    LOG_INFO_MAN     = @echo "$(TXT_MANUAL) $(1)"
    LOG_TARGET       = @echo "$(TXT_TARGET) $(1)"
    LOG_COMPILE      = @echo "$(TXT_COMPILE) $(1)"
    LOG_LINK         = @echo "$(TXT_LINK) $(1)"
    LOG_CLEAN        = @echo "$(TXT_CLEAN) $(BUILD_ROOT)"
    LOG_SUCCESS      = @echo "$(TXT_SUCCESS) $(1)"
    LOG_RUN          = @echo "$(TXT_RUN) $(1)"
    LOG_RUN_START    = @echo "$(TXT_RUN) $(1)"
    
    ON_FAIL          = ( echo "$(TXT_ERR_PREFIX) $(1)" >&2; exit 1 )
    MK_ERR_FMT       = $(TXT_ERR_PREFIX) $(1)
    LOG_BUILD_FINISH := @:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 3: silent (조용한 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 성공 시에는 아무것도 출력하지 않고, 에러 발생 시에만 메시지를 출력합니다.
# 조건: 스크립트 내에서 사용하거나, 출력을 최소화하고 싶을 때 사용합니다.
else ifeq ($(MODE),silent)
    # 텍스트 메시지 정의 (정보성 메시지는 비워둠, 에러만 정의)
    TXT_START       :=
    TXT_AUTO        :=
    TXT_MANUAL      :=
    TXT_TARGET      :=
    TXT_COMPILE     :=
    TXT_LINK        :=
    TXT_CLEAN       :=
    TXT_SUCCESS     :=
    TXT_RUN         :=
    TXT_ERR_PREFIX  := Error:
    TXT_ERR_NO_MAIN := Main file not found.
    TXT_ERR_NO_FILE := Source file not found.
    TXT_ERR_NOT_SRC := Not a source file.
    TXT_ERR_NO_EXEC := Binary not found.
    TXT_FAIL_CMP    := Compilation failed
    TXT_FAIL_LNK    := Linking failed
    
    # Q 변수: 명령 출력 억제
    Q := @
    
    # 모든 정보성 로그는 no-op (@:)
    LOG_START        = @:
    LOG_INFO_AUTO    = @:
    LOG_INFO_MAN     = @:
    LOG_TARGET       = @:
    LOG_COMPILE      = @:
    LOG_LINK         = @:
    LOG_CLEAN        = @:
    LOG_SUCCESS      = @:
    LOG_RUN          = @:
    LOG_RUN_START    = @:
    	
    ON_FAIL          = ( echo "$(TXT_ERR_PREFIX) $(1)" >&2; exit 1 )
    MK_ERR_FMT       = $(TXT_ERR_PREFIX) $(1)
    LOG_BUILD_FINISH := @:
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 4: binary (바이너리 경로 출력 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: 빌드 성공 시 생성된 실행 파일의 경로만 출력합니다.
# 조건: 빌드 시스템을 다른 스크립트와 연동할 때 사용합니다.
#       파싱이 쉬워 자동화 스크립트에서 실행 파일 경로를 추출하기 용이합니다.
else ifeq ($(MODE),binary)
    # 텍스트 메시지 정의 (정보성 메시지는 비워둠, 에러만 정의)
    TXT_START       :=
    TXT_AUTO        :=
    TXT_MANUAL      :=
    TXT_TARGET      :=
    TXT_COMPILE     :=
    TXT_LINK        :=
    TXT_CLEAN       :=
    TXT_SUCCESS     :=
    TXT_RUN         :=
    TXT_ERR_PREFIX  := [ERR]
    TXT_ERR_NO_MAIN := No main file
    TXT_ERR_NO_FILE := Missing file
    TXT_ERR_NOT_SRC := Invalid type
    TXT_ERR_NO_EXEC := No binary
    TXT_FAIL_CMP    := Compile error
    TXT_FAIL_LNK    := Link error
    
    # Make의 내장 출력도 모두 억제
    MAKEFLAGS += -s --no-print-directory
    Q := @
    
    # 모든 정보성 로그는 출력하지 않음 (@:는 아무것도 하지 않는 명령)
    LOG_START        = @:
    LOG_INFO_AUTO    = @:
    LOG_INFO_MAN     = @:
    LOG_TARGET       = @:
    LOG_COMPILE      = @:
    LOG_LINK         = @:
    LOG_CLEAN        = @:
    LOG_SUCCESS      = @:
    LOG_RUN          = @:
    LOG_RUN_START    = @:
    
    ON_FAIL          = ( exit 1 )
    MK_ERR_FMT       = $(1)
    
    # 빌드 완료 시 바이너리 경로만 출력
    LOG_BUILD_FINISH = @echo "$(1)"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 모드 5: raw (원시 출력 모드)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 동작: Make와 컴파일러의 원본 출력만 표시하고, 추가 메시지를 출력하지 않습니다.
# 조건: 고급 사용자가 빌드 도구의 기본 동작을 확인하거나,
#       외부 빌드 분석 도구와 연동할 때 사용합니다.
else ifeq ($(MODE),raw)
    # 텍스트 메시지 정의 (모두 비워둠)
    TXT_START       :=
    TXT_AUTO        :=
    TXT_MANUAL      :=
    TXT_TARGET      :=
    TXT_COMPILE     :=
    TXT_LINK        :=
    TXT_CLEAN       :=
    TXT_SUCCESS     :=
    TXT_RUN         :=
    TXT_ERR_PREFIX  :=
    TXT_ERR_NO_MAIN :=
    TXT_ERR_NO_FILE :=
    TXT_ERR_NOT_SRC :=
    TXT_ERR_NO_EXEC :=
    TXT_FAIL_CMP    :=
    TXT_FAIL_LNK    :=
    
    # 명령 출력 억제 없음 (Q를 비워서 모든 셸 명령이 그대로 출력됨)
    Q :=
    
    # 모든 커스텀 로그 매크로를 no-op(@:)으로 설정하여 중복 출력 방지
    LOG_START        = @:
    LOG_INFO_AUTO    = @:
    LOG_INFO_MAN     = @:
    LOG_TARGET       = @:
    LOG_COMPILE      = @:
    LOG_LINK         = @:
    LOG_CLEAN        = @:
    LOG_SUCCESS      = @:
    LOG_RUN          = @:
    LOG_RUN_START    = @:
    
    ON_FAIL          = exit 1
    MK_ERR_FMT       = $(1)
    LOG_BUILD_FINISH := @:
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
    # 4.3.1 프로젝트 내 모든 소스 파일 탐색
    # --------------------------------------------------------------------------
    # 동작: find 명령으로 SRC_ROOT 하위의 모든 C/C++ 소스 파일을 찾습니다.
    # 조건: BUILD_ROOT 내부의 파일은 제외합니다 (빌드 결과물을 소스로 취급하지 않음)
    
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
    # 조건:
    #   - MAIN_SRC가 없으면: main.c 또는 main.cpp를 자동으로 찾습니다.
    #   - MAIN_SRC가 있으면: 해당 파일의 존재 및 유효성을 검증합니다.
    
    ifeq ($(origin MAIN_SRC), undefined)
        # 케이스 1: 자동 탐색 모드
        # 동작: SRC_ROOT 내에서 main.cpp 또는 main.c 파일을 찾습니다.
        # 조건: 찾지 못하면 에러를 발생시켜 빌드를 중단합니다.
        
        MAIN_SRC_AUTO := $(firstword $(shell find $(SRC_ROOT) -name 'main.cpp' -o -name 'main.c' | sed 's|^./||'))
        ifeq ($(MAIN_SRC_AUTO),)
            # 메인 파일을 찾지 못한 경우: 빌드 중단
            $(error $(call MK_ERR_FMT,$(TXT_ERR_NO_MAIN)))
        endif
        MAIN_SRC_NORM := $(MAIN_SRC_AUTO)
        CMD_LOG_MODE  := $(LOG_INFO_AUTO)
    else
        # 케이스 2: 수동 지정 모드
        # 동작: 사용자가 지정한 MAIN_SRC 파일의 유효성을 검증합니다.
        # 조건: 
        #   1. 파일이 실제로 존재하는지 확인
        #   2. 파일 확장자가 C/C++ 소스 파일(.c, .cpp 등)인지 확인
        
        # 경로 정규화: ./로 시작하는 경로를 제거 (./test.cpp → test.cpp)
        MAIN_SRC_NORM := $(shell echo $(MAIN_SRC) | sed 's|^./||')
        
        # 유효성 검증 1: 파일 존재 여부 확인
        ifeq ($(wildcard $(MAIN_SRC_NORM)),)
            $(error $(call MK_ERR_FMT,$(TXT_ERR_NO_FILE): $(MAIN_SRC_NORM)))
        endif
        
        # 유효성 검증 2: C/C++ 소스 파일인지 확인
        ifneq ($(call IS_SRC,$(MAIN_SRC_NORM)),1)
            $(error $(call MK_ERR_FMT,$(TXT_ERR_NOT_SRC): $(MAIN_SRC_NORM)))
            CMD_LOG_MODE := $(call LOG_INFO_MAN,$(MAIN_SRC_NORM))
        endif
    # --------------------------------------------------------------------------
    # 4.3.3 빌드 타겟 경로 생성
    # --------------------------------------------------------------------------
    # 동작: 메인 소스 파일에서 실행 파일 경로를 생성합니다.
endif
    # 예: leetcode/700.cpp → build/leetcode/700
    
    TARGET := $(BUILD_ROOT)/$(basename $(MAIN_SRC_NORM))
    # --------------------------------------------------------------------------
    # 4.3.4 컴파일러 선택 (C vs C++)
    # --------------------------------------------------------------------------
    # 동작: 메인 소스 파일의 확장자에 따라 적절한 컴파일러를 선택합니다.
    # 조건: C++ 파일이면 CXX, C 파일이면 CC 컴파일러를 사용합니다.
    
    ifeq ($(call IS_CPP,$(MAIN_SRC_NORM)),1)
        # C++ 파일: g++ 또는 clang++ 사용
        PREPROC := $(CXX) $(CXXFLAGS)
    else
        # C 파일: gcc 또는 clang 사용
        PREPROC := $(CC) $(CFLAGS)
    endif
    # --------------------------------------------------------------------------
    # 4.3.5 헤더 파일 의존성 분석
    # --------------------------------------------------------------------------
    # 동작: 컴파일러의 -MM 옵션을 사용하여 메인 소스 파일이 포함하는
    #       헤더 파일(.h) 목록을 자동으로 추출합니다.
    # 조건: 컴파일러가 정상적으로 전처리를 수행할 수 있어야 합니다.
    
    # DEPS_RAW: 컴파일러가 출력한 원시 의존성 정보
    # 예: main.o: main.cpp utils.h math.h
    DEPS_RAW := $(shell $(PREPROC) -MM $(MAIN_SRC_NORM) 2>/dev/null)
    
    # HDRS: 의존성에서 헤더 파일(.h)만 추출
    # 동작: DEPS_RAW에서 ':'를 공백으로 치환하고, %.h 패턴으로 필터링
    # 예: utils.h math.h
    HDRS := $(filter %.h,$(subst :, ,$(DEPS_RAW)))
    
    # HDR_BASE: 헤더 파일의 베이스 이름만 추출 (경로와 확장자 제거)
    # 예: include/utils.h → utils, math/calc.h → calc
    HDR_BASE := $(notdir $(basename $(HDRS)))
    # --------------------------------------------------------------------------
    # 4.3.6 대응하는 소스 파일 탐색
    # --------------------------------------------------------------------------
    # 동작: 헤더 파일에 대응하는 구현 파일(.c, .cpp)을 찾습니다.
    # 조건: utils.h가 있으면 utils.c 또는 utils.cpp를 찾아 컴파일 대상에 추가합니다.
    
    # POTENTIAL_C: 헤더에 대응하는 가능한 C 파일 이름
    # 예: utils → utils.c
    POTENTIAL_C := $(addsuffix .c,$(HDR_BASE))
    
    # POTENTIAL_CPP: 헤더에 대응하는 가능한 C++ 파일 이름
    # 예: utils → utils.cpp
    POTENTIAL_CPP := $(addsuffix .cpp,$(HDR_BASE))
    
    # POTENTIAL_PAT: 경로 유무와 상관없이 매칭할 수 있는 패턴 생성
    # 예: utils.c, */utils.c, utils.cpp, */utils.cpp
    POTENTIAL_PAT := $(addprefix %/,$(POTENTIAL_C)) $(POTENTIAL_C) $(addprefix %/,$(POTENTIAL_CPP)) $(POTENTIAL_CPP)
    # REAL_DEPS: SRCS에서 실제로 존재하는 대응 소스 파일만 필터링
    # 예: utils.cpp가 실제로 존재하면 포함됨
    REAL_DEPS := $(filter $(POTENTIAL_PAT),$(SRCS))
    
    # FINAL_SRCS: 최종 컴파일 대상 파일 목록 (메인 파일 + 의존 파일)
    # 동작: 메인 소스 파일과 의존 소스 파일을 결합하고 중복 제거
    # 예: main.cpp utils.cpp math.cpp
    FINAL_SRCS := $(sort $(MAIN_SRC_NORM) $(REAL_DEPS))
    # --------------------------------------------------------------------------
    # 4.3.7 오브젝트 파일 경로 생성
    # --------------------------------------------------------------------------
    # 동작: 각 소스 파일에 대응하는 오브젝트 파일(.o) 경로를 생성합니다.
    # 조건: 소스 파일의 디렉토리 구조를 BUILD_ROOT 하위에 그대로 복제합니다.
    
    # LINK_OBJS: 링킹 단계에서 사용할 오브젝트 파일 목록
    # 예: main.cpp → build/main.o
    #     leetcode/700.cpp → build/leetcode/700.o
    LINK_OBJS := $(addsuffix .o,$(addprefix $(BUILD_ROOT)/,$(basename $(FINAL_SRCS))))
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
	@echo "    헤더 파일 의존성을 자동으로 분석하여 관련 소스 파일을 함께 컴파일합니다."
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
	@echo "        빌드 디렉토리(ex: build/)디렉토리를 삭제합니다."
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
	@echo "    $(FG_YELLOW)MAIN_SRC$(C_RESET)=$(FG_MAGENTA)file$(C_RESET)  (짧은 별칭: $(FG_YELLOW)s$(C_RESET)=$(FG_MAGENTA)file$(C_RESET))"
	@echo "        빌드할 메인 소스 파일의 경로를 지정합니다."
	@echo "        지정하지 않으면 main.c 또는 main.cpp를 자동으로 탐색합니다."
	@echo "        예: make build s=test.cpp"
	@echo ""
	@echo "    $(FG_YELLOW)OUTPUT_MODE$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET)  (짧은 별칭: $(FG_YELLOW)m$(C_RESET)=$(FG_MAGENTA)mode$(C_RESET))"
	@echo "        빌드 과정의 출력 형식을 제어합니다."
	@echo "        예: make build m=verbose 또는 make build m=v"
	@echo ""
	@echo "        $(FG_MAGENTA)normal  (n)$(C_RESET)    한글 메시지, 색상 강조 (기본값)"
	@echo "        $(FG_MAGENTA)silent  (s)$(C_RESET)    성공 시 출력 없음, 에러만 표시"
	@echo "        $(FG_MAGENTA)verbose (v)$(C_RESET)    영어 메시지, 모든 명령어 출력"
	@echo "        $(FG_MAGENTA)binary  (b)$(C_RESET)    바이너리 경로만 출력 (도구 연동용)"
	@echo "        $(FG_MAGENTA)raw     (r)$(C_RESET)    Make, 컴파일러, 링커 원본 출력만 표시"
	@echo ""
	@echo "    $(FG_YELLOW)STDIN$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)i$(C_RESET)=$(FG_MAGENTA)file$(C_RESET))"
	@echo "        실행 파일의 표준 입력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDIN=input.txt"
	@echo ""
	@echo "    $(FG_YELLOW)STDOUT$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)o$(C_RESET)=$(FG_MAGENTA)file$(C_RESET))"
	@echo "        실행 파일의 표준 출력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDOUT=output.txt"
	@echo ""
	@echo "    $(FG_YELLOW)STDERR$(C_RESET)=$(FG_MAGENTA)file$(C_RESET) (짧은 별칭: $(FG_YELLOW)e$(C_RESET)=$(FG_MAGENTA)file$(C_RESET))"
	@echo "        실행 파일의 표준 오류 출력을 지정된 파일로 리다이렉션합니다."
	@echo "        예: make run s=leetcode/700.cpp STDERR=error.log"
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
	@echo "    $(FG_YELLOW)INCLUDE_DIRS$(C_RESET)+=$(FG_MAGENTA)dir$(C_RESET)"
	@echo "        추가 헤더 파일 디렉토리를 지정합니다. 여러 디렉토리를 추가적으로 지정할 수 있습니다."
	@echo "        예: make build INCLUDE_DIRS+=include/ INCLUDE_DIRS+=third_party/"
	@echo ""
	@echo "    $(FG_YELLOW)CC$(C_RESET)=$(FG_MAGENTA)compiler$(C_RESET)"
	@echo "        C 컴파일러를 지정합니다. 기본값은 gcc입니다. mac 의 경우 지정하지 않아도 clang이 기본 사용됩니다."
	@echo ""
	@echo "    $(FG_YELLOW)CXX$(C_RESET)=$(FG_MAGENTA)compiler$(C_RESET)"
	@echo "        C++ 컴파일러를 지정합니다. 기본값은 g++입니다. mac 의 경우 지정하지 않아도 clang++이 기본 사용됩니다."
	@echo ""
	@echo "    $(FG_YELLOW)CFLAGS$(C_RESET)=$(FG_MAGENTA)flags$(C_RESET)"
	@echo "        C++ 컴파일러 플래그를 지정합니다. 기본값은 -std=c11 -g -Wall I. 입니다."
	@echo ""
	@echo "    $(FG_YELLOW)CXXFLAGS$(C_RESET)=$(FG_MAGENTA)flags$(C_RESET)"
	@echo "        C 컴파일러 플래그를 지정합니다. 기본값은 -std=c++17 -g -Wall I.입니다."
	@echo ""
	@echo "    $(FG_YELLOW)LDFLAGS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET)"
	@echo "        링커 플래그를 지정합니다. 기본값은 빈 문자열입니다."
	@echo "        예: make build LDFLAGS+=-pthread"
	@echo ""
	@echo "    $(FG_YELLOW)LDLIBS$(C_RESET)+=$(FG_MAGENTA)flags$(C_RESET)"
	@echo "        링커 라이브러리 플래그를 지정합니다. 기본값은 빈 문자열입니다."
	@echo "        예: make build LDLIBS+=-lm"
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
	@echo "        $$ hyperfine '\$$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)' \\"
	@echo "                      '\$$(make build MAIN_SRC=leetcode/450.cpp OUTPUT_MODE=binary)'"
	@echo ""
	@echo "$(FX_BOLD)EXIT STATUS$(C_RESET)"
	@echo "    빌드 성공 시 0을 반환합니다."
	@echo "    소스 파일을 찾을 수 없거나 컴파일/링킹 실패 시 1을 반환합니다."
	@echo ""
	@echo "$(FX_BOLD)NOTES$(C_RESET)"
	@echo "    • VSCode, Zed 등의 tasks.json에서 이 Makefile을 활용할 수 있습니다."
	@echo "    • 헤더 파일이 변경되면 관련 소스 파일이 자동으로 재컴파일됩니다."
	@echo "    • OUTPUT_MODE=binary는 타 도구와 연동 시 유용합니다."
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
	@if [ ! -f "$(TARGET)" ]; then \
	    echo "$(TXT_ERR_PREFIX) $(TXT_ERR_NO_EXEC): $(TARGET)" >&2; exit 1; \
	fi
	$(call LOG_RUN_START,$(TARGET))
	$(Q)$(TARGET) $(RUN_ARGS)

# clean 타겟: 빌드 디렉토리와 모든 빌드 결과물을 삭제합니다.
# 동작: BUILD_ROOT 디렉토리 전체를 재귀적으로 삭제합니다.
# 조건: 항상 실행 가능합니다 (소스 파일 없어도 동작).
clean:
	$(LOG_CLEAN)
	$(Q)rm -rf $(BUILD_ROOT)

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
	$(LOG_START)
	$(CMD_LOG_MODE)
	$(call LOG_TARGET,$(MAIN_SRC_NORM))

# ------------------------------------------------------------------------------
# 5.5 .PHONY 타겟 선언
# ------------------------------------------------------------------------------
# 동작: 파일 이름이 아닌 작업을 나타내는 타겟임을 명시합니다.
# 조건: .PHONY로 선언된 타겟은 항상 실행되며, 동일한 이름의 파일이 있어도
#       파일 타임스탬프를 확인하지 않습니다.

.PHONY: all help build run build-run clean clean-build clean-build-run

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
	$(Q)$(MKDIR_P) $(dir $@)
	$(call LOG_LINK,$@)
	$(Q)$(CXX) $(LDFLAGS) -o $@ $(LINK_OBJS) $(LDLIBS) || $(call ON_FAIL,$(TXT_FAIL_LNK): $@)
	$(call LOG_SUCCESS,$@)

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
	$$(Q)$(MKDIR_P) $$(@D)
	$$(call LOG_COMPILE,$$<,$$@)
	$$(Q)$(CXX) $(CXXFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ || $$(call ON_FAIL,$(TXT_FAIL_CMP): $$<)
endef

# ------------------------------------------------------------------------------
# 5.6.3 C 컴파일 규칙 (패턴 규칙 생성 매크로)
# ------------------------------------------------------------------------------
# 동작: C 소스 파일(.c)을 오브젝트 파일(.o)로 컴파일합니다.
# 조건: C 확장자에 대한 패턴 규칙이 생성됩니다.
# 의존성 추적: C++ 규칙과 동일 (-MMD -MP)

define RULE_C
$(BUILD_ROOT)/%.o: %$(1) | pre-build-setup
	$$(Q)$(MKDIR_P) $$(@D)
	$$(call LOG_COMPILE,$$<,$$@)
	$$(Q)$(CC) $(CFLAGS) -MMD -MP -MF $$(@:.o=.d) -c $$< -o $$@ || $$(call ON_FAIL,$(TXT_FAIL_CMP): $$<)
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
