```man

NAME
    make - C/C++ 프로젝트 빌드 시스템

SYNOPSIS
    make [target] [MAIN_SRC=file] [OUTPUT_MODE=mode] [STDIN, STDOUT, STDERR=file]

DESCRIPTION
    C/C++ 소스 코드를 컴파일하고 실행 파일을 생성합니다.
    헤더 파일 의존성을 자동으로 분석하여 관련 소스 파일을 함께 컴파일합니다. 만약 정교한 의존성 분석이 필요하다면 DEPENDENCY_MODE 변수를 조정할 수 있습니다.

TARGETS
    build
        소스 파일을 컴파일하여 실행 파일을 생성합니다.
        MAIN_SRC가 지정되지 않으면 main.c 또는 main.cpp를 자동 탐색합니다.

    run
        빌드된 실행 파일을 실행합니다.
        실행 파일이 없으면 에러를 반환합니다.

    build-run
        빌드와 실행을 연속으로 수행합니다. 가장 많이 사용되는 타겟입니다.

    clean
        빌드 디렉토리(ex: build/)를 안전하게 삭제합니다.
        이 Makefile로 생성된 디렉토리만 삭제합니다.
        안전을 위해 마커 파일(.make_safe_marker)이 없으면 삭제를 거부하고 종료 코드 1을 반환합니다.

    clean-build
        클린 후 완전히 새로 빌드합니다.

    clean-build-run
        클린, 빌드, 실행을 순차적으로 수행합니다.

    help
        이 도움말을 표시합니다.

VARIABLES
    MAIN_SRC=file  (짧은 별칭: s=file) (관련 타켓 : build, run)
        빌드할 메인 소스 파일의 경로를 지정합니다.
        지정하지 않으면 main.c 또는 main.cpp를 자동으로 탐색합니다.
        예: make build s=test.cpp

    OUTPUT_MODE=mode  (짧은 별칭: m=mode) (관련 타켓 : 전체)
        빌드 과정의 출력 형식을 제어합니다.
        예: make build m=verbose 또는 make build m=v

        normal  (n)    한글 메시지, 색상 강조 (기본값)
        silent  (s)    성공 시 출력 없음, 에러만 표시
        verbose (v)    영어 메시지, 모든 명령어 출력
        binary  (b)    바이너리 경로만 출력 (도구 연동용)
        raw     (r)    Make, 컴파일러, 링커 원본 출력만 표시

    STDIN=file (짧은 별칭: i=file) (관련 타켓 : run)
        실행 파일의 표준 입력을 지정된 파일로 리다이렉션합니다.
        예: make run s=leetcode/700.cpp STDIN=input.txt

    STDOUT=file (짧은 별칭: o=file) (관련 타켓 : run)
        실행 파일의 표준 출력을 지정된 파일로 리다이렉션합니다.
        예: make run s=leetcode/700.cpp STDOUT=output.txt

    STDERR=file (짧은 별칭: e=file) (관련 타켓 : run)
        실행 파일의 표준 오류 출력을 지정된 파일로 리다이렉션합니다.
        예: make run s=leetcode/700.cpp STDERR=error.log

    ARGS=you want (짧은 별칭: a=you want) (관련 타켓 : run)
        실행 파일에 전달할 명령줄 인수를 지정합니다.
        예: make run s=leetcode/700.cpp ARGS="arg1 arg2"
        예: make run s=leetcode/700.cpp a="| grep 'test'"
        예: make run s=leetcode/700.cpp a="< input.txt > output.txt"
        STDIN, STDOUT, STDERR 변수 대신 사용할 수 있습니다.

ADVANCED VARIABLES : 일반적으로 인수로 지정하지 않고 Makefile 내에서 설정합니다. 하지만 필요에 따라 인수로 지정할 수 있습니다.

    PROJECT_ROOT=dir
        프로젝트의 루트 디렉토리를 지정합니다. 기본값은 현재 디렉토리(./)입니다.

    SRC_ROOT=dir
        소스 파일이 위치한 디렉토리를 지정합니다. 기본값은 프로젝트 루트 디렉토리(./)입니다.

    BUILD_ROOT=dir
        빌드 결과물이 생성될 디렉토리를 지정합니다. 기본값은 ./build/입니다.

    CC=compiler
        C 컴파일러를 지정합니다. 기본값은 gcc입니다. mac 의 경우 지정하지 않아도 clang이 기본 사용됩니다.

    CXX=compiler
        C++ 컴파일러를 지정합니다. 기본값은 g++입니다. mac 의 경우 지정하지 않아도 clang++이 기본 사용됩니다.

    CPPFLAGS+=flags (= 대신 += 사용)
        공통 전처리기 플래그를 지정합니다. 기본값은 SRC_ROOT 경로입니다.

    CFLAGS+=flags (= 대신 += 사용)
        C++ 컴파일러 플래그를 지정합니다. 기본값은 -std=c11 -g -Wall I. 입니다.

    CXXFLAGS+=flags (= 대신 += 사용)
        C 컴파일러 플래그를 지정합니다. 기본값은 -std=c++17 -g -Wall I.입니다.

    LDFLAGS+=flags (= 대신 += 사용)
        링커 플래그를 지정합니다. 기본값은 빈 문자열입니다.
        예: make build LDFLAGS+=-pthread

    LDLIBS+=flags (= 대신 += 사용)
        링커 라이브러리 플래그를 지정합니다. 기본값은 빈 문자열입니다.
        예: make build LDLIBS+=-lm
    DEPENDENCY_MODE=mode
        의존성 탐색 방식을 설정합니다. (기본값: path)
         file : [기본값] 파일명 기반 매칭 (Filename Matching)
             include/ 와 src/ 가 분리된 일반적인 프로젝트 구조 지원
             헤더: include/utils.h -> 소스: src/utils.cpp (찾음)
             단, 프로젝트 내에 '파일명'은 유일해야 합니다. (중복 시 충돌 가능)
         path : 경로 기반 매칭 (Path Matching)
             헤더와 소스가 같은 폴더에 위치해야 함 (Colocation)
             소스 파일명이 중복되는 경우 필수
             헤더: problem1/sol.h -> 소스: problem1/sol.cpp (찾음)
             헤더: problem1/sol.h -> 소스: problem2/sol.cpp (무시함 - 안전)
         standalone : 단독 빌드.
             의존성 파일을 찾지 않고 MAIN_SRC만 빌드.
         all
             전체 링크. 프로젝트 내 모든 소스를 링크 (main 중복 시 링커 에러).
             프로젝트 내의 모든 소스 파일을 컴파일 목록에 포함합니다 (전이적 의존성 임시 해결책).
             링커의 Dead Code Stripping 기능을 신뢰해 모든 파일을 포함하는 방식입니다.
             사용하지 않는 함수의 코드 제거를 위해 다음 플래그 사용 권장
                 CXXFLAGS += -fdata-sections -ffunction-sections
                 CFLAGS   += -fdata-sections -ffunction-sections
                 LDFLAGS  += -Wl,--gc-sections
             정확한 전이적 의존성 해결 또는 정교한 빌드 기능을 원한다면 다른 고수준의 빌드 시스템(CMake, Bazel 등)을 사용하는 것을 권장합니다.
         transitive_path
             전이적 탐색 (Transitive Dependency Discovery) - 동일 폴더 기반
             BFS 알고리즘을 사용하여 소스->헤더->소스 연결 고리를 끝까지 추적합니다.
             include/utils.h -> src/utils.cpp 뿐만 아니라, src/utils.cpp가 포함하는 다른 헤더와 소스 파일도 함께 탐색합니다.
             헤더와 소스 파일이 동일 폴더에 위치해야 합니다.
         transitive_file
             전이적 탐색 (Transitive Dependency Discovery) - 동일 이름 기반
             BFS 알고리즘을 사용하여 소스->헤더->소스 연결 고리를 끝까지 추적합니다.
             include/utils.h -> src/utils.cpp 뿐만 아니라, src/utils.cpp가 포함하는 다른 헤더와 소스 파일도 함께 탐색합니다.
             헤더와 소스 파일이 동일 이름을 가져야 합니다.

EXAMPLES
    1. 기본 사용 (main.c/main.cpp 자동 빌드):
        $ make build

    2. 특정 파일 빌드 (전체 변수명):
        $ make build MAIN_SRC=leetcode/700.cpp

    3. 특정 파일 빌드 (짧은 별칭 사용):
        $ make build s=leetcode/700.cpp

    4. 빌드 후 즉시 실행:
        $ make build-run s=swea/1244/main.cpp

    5. 상세 로그와 함께 클린 빌드 (짧은 별칭 사용):
        $ make clean-build-run s=leetcode/236.cpp m=verbose

    6. 출력 모드 축약 사용:
        $ make build s=leetcode/450.cpp m=v  # v는 verbose의 축약

    7. 벤치마크 도구와 연동 (바이너리 경로 출력):

       /usr/bin/time - 실행 시간 및 리소스 측정
         # 기본 시간 측정 (real/user/sys) - 짧은 별칭 사용
         /usr/bin/time $(make build s=leetcode/700.cpp m=binary)

         # 상세 리소스 정보 출력 (-v)
         /usr/bin/time -v $(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)

         # 커스텀 포맷 지정 (-f)
         /usr/bin/time -f "Time: %e sec, Memory: %M KB, CPU: %P" \
           $(make build MAIN_SRC=swea/1244/main.cpp OUTPUT_MODE=binary)

         # 결과를 파일에 저장 (-o, -a)
         /usr/bin/time -f "%e,%M,%P" -o benchmark.log -a \
           $(make build MAIN_SRC=leetcode/450.cpp OUTPUT_MODE=binary)

       hyperfine - 통계적 벤치마크 및 성능 비교
         # 기본 벤치마크 (10회 반복)
         hyperfine '$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)'

         # 웜업 및 실행 횟수 지정 (--warmup, --min-runs)
         hyperfine --warmup 3 --min-runs 20 \
           '$(make build MAIN_SRC=swea/5215/main.cpp OUTPUT_MODE=binary)'

         # 여러 솔루션 비교 (짧은 별칭 사용)
         hyperfine '$(make build s=leetcode/700.cpp m=binary)' \
                   '$(make build s=leetcode/450.cpp m=binary)'

    8. 여러 솔루션 성능 비교 (축약형 활용):
         hyperfine '$(make build s=leetcode/700.cpp m=b)' \
                      '$(make build s=leetcode/450.cpp m=b)'  # b는 binary의 축약

         # 명명된 비교 (--command-name)
         hyperfine --command-name 'DFS' '$(make build MAIN_SRC=leetcode/104.cpp OUTPUT_MODE=binary)' \
                   --command-name 'BFS' '$(make build MAIN_SRC=leetcode/1161.cpp OUTPUT_MODE=binary)'

         # 파라미터 치환 (-L)
         hyperfine -L file 700,450,236 \
           '$(make build MAIN_SRC=leetcode/{file}.cpp OUTPUT_MODE=binary)'

         # 매 실행 전 정리 작업 (--prepare)
         hyperfine --prepare 'make clean' --warmup 2 \
           '$(make build MAIN_SRC=leetcode/1466.cpp OUTPUT_MODE=binary)'

         # 결과 내보내기 (--export-markdown, --export-json)
         hyperfine --export-markdown results.md --export-json results.json \
           '$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)'

       perf - CPU 프로파일링 및 성능 분석
         # 기본 통계 (stat)
         perf stat $(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)

         # 이벤트 지정 (-e)
         perf stat -e cycles,instructions,cache-misses \
           $(make build MAIN_SRC=leetcode/1448.cpp OUTPUT_MODE=binary)

         # 프로파일 기록 (record)
         perf record $(make build MAIN_SRC=swea/1209/main.cpp OUTPUT_MODE=binary)

         # 함수별 프로파일 (top)
         perf top $(make build MAIN_SRC=leetcode/437.cpp OUTPUT_MODE=binary)

       valgrind - 메모리 누수 및 오류 검사
         # 메모리 누수 검사 (--leak-check)
         valgrind --leak-check=full \
           $(make build MAIN_SRC=leetcode/1448.cpp OUTPUT_MODE=binary)

         # 상세 누수 정보 (--show-leak-kinds)
         valgrind --leak-check=full --show-leak-kinds=all \
           $(make build MAIN_SRC=leetcode/206.cpp OUTPUT_MODE=binary)

         # 캐시 프로파일링 (cachegrind)
         valgrind --tool=cachegrind \
           $(make build MAIN_SRC=leetcode/236.cpp OUTPUT_MODE=binary)

         # 힙 프로파일링 (massif)
         valgrind --tool=massif \
           $(make build MAIN_SRC=swea/5215/main.cpp OUTPUT_MODE=binary)

       gprof - 함수별 실행 시간 프로파일링
         # 프로파일링 활성화하여 빌드 (-pg 플래그 필요)
         CXXFLAGS="-pg" make build MAIN_SRC=leetcode/700.cpp
         ./build/leetcode/700  # 실행하여 gmon.out 생성
         gprof ./build/leetcode/700 gmon.out > profile.txt

    6. 여러 솔루션 성능 비교:
         hyperfine '$(make build MAIN_SRC=leetcode/700.cpp OUTPUT_MODE=binary)' \
                      '$(make build MAIN_SRC=leetcode/450.cpp OUTPUT_MODE=binary)'

EXIT STATUS
    빌드 성공 시 0을 반환합니다.
    소스 파일을 찾을 수 없거나 컴파일/링킹 실패 시 1을 반환합니다.
    안전 마커가 없는 디렉토리에 clean 시도 시 1을 반환합니다.

NOTES
    • VSCode, Zed 등의 tasks.json에서 이 Makefile을 활용할 수 있습니다.
    • 헤더 파일이 변경되면 관련 소스 파일이 자동으로 재컴파일됩니다.
    • OUTPUT_MODE=binary는 타 도구와 연동 시 유용합니다.
    • [안전 기능] clean 타겟은 마커 파일을 확인하여 실수로 중요한 디렉토리를 삭제하는 것을 방지합니다.
    • 빌드 시 BUILD_ROOT에 .make_safe_marker 파일이 자동 생성됩니다.

SEE ALSO
    gcc(1), g++(1), clang(1), time(1), hyperfine(1), perf(1), valgrind(1)
```
