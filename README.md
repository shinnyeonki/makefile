```man

NAME
    make - C/C++ 프로젝트 빌드 시스템

SYNOPSIS
    make [target] [MAIN_SRC=file] [MODE_LOG=mode]

TARGETS
    build            소스 파일을 컴파일하여 실행 파일 생성
    run              빌드된 실행 파일을 실행
    build-run        빌드와 실행을 연속으로 수행
    clean            빌드 디렉토리 안전하게 삭제
    clean-build      클린 후 완전히 새로 빌드
    clean-build-run  클린, 빌드, 실행을 순차 수행
    list-headers     의존된 헤더 파일 목록 출력(경로 포함)
    help             이 도움말 표시

VARIABLES
    MAIN_SRC=file  (별칭: m=file) (관련: build(target), run(target))
        빌드할 메인 소스 파일 경로. 미지정 시 main.c/main.cpp 자동 탐색

    SRCS="file1 file2 ..."  (별칭: s="file1 file2 ...") (관련: build(target), MODE_DEPS(option), MODE_TARGET(option))
        추가로 빌드할 소스 파일 수동 목록 지정.

    MODE_LOG=mode  (별칭: l=mode) (관련: 모든 빌드 관련 타겟)
        빌드 출력 형식 제어. 기본값: normal
        normal (n)            한글 메시지, 색상 강조 (기본값)
        silent (s)            성공 시 출력 없음, 에러만 표시
        verbose (v)           영어 메시지, 모든 명령어 출력
        binary (b)            바이너리 경로만 출력 (도구 연동용)
        raw (r)               컴파일러 원본 출력만 표시

    MODE_TARGET=mode  (별칭: t=mode) (static, shared 모드일때는 LIB_NAME 옵션 필수)
        빌드 유형. 기본값: executable
        executable (exe, bin, out)        실행파일 생성 (기본값)
        static (a)                        정적 라이브러리 (a)
        shared (so, dll, dylib)           동적 라이브러리 (so, dll, dylib)

    MODE_DEPS=mode  (별칭: d=mode)
        의존성 탐색 방식. 기본값: path
        standalone (s)                단독 빌드 (의존성 무시)
        path (p)                      전이적 경로 기반
        file (f)                      전이적 파일명 기반
        all (a)                       전체 링크 (모든 소스 포함)

    LIB_NAME=name  (별칭: n=name) (관련: build(target), MODE_TARGET(option))
        라이브러리 모드시에 필수 옵션, 이름, 경로와 함께 지정 가능

    STDIN=file (별칭: i), STDOUT=file (별칭: o), STDERR=file (별칭: e), ARGS=args (별칭: a) (관련: run(target))
        실행 시 입출력 리다이렉션 및 추가 인자 지정

    PKGS="pkg1 pkg2 ..."
         pkg-config를 통해 포함할 외부 라이브러리 목록 지정

ADVANCED VARIABLES
    일반적으로 파일을 고쳐서 변경하는 것이 좋음
    SRC_ROOT    = path          소스 파일 탐색의 루트 디렉토리 지정 (기본값: ./)
    BUILD_ROOT  = path          빌드 출력 디렉토리 경로 지정 (기본값: ./build)
    CPPFLAGS   += flags         전처리기 플래그 지정 C/C++ 공통
    CFLAGS     += flags         C 컴파일러에 전달할 추가 플래그 지정
    CXXFLAGS   += flags         C++ 컴파일러에 전달할 추가 플래그 지정
    LDFLAGS    += flags         링커에 전달할 추가 플래그 지정
    LDLIBS     += libs          링커에 전달할 추가 라이브러리 지정

EXAMPLES
    1. 기본 빌드 (main.c/main.cpp 자동 탐색):
        make build

    2. 특정 파일 빌드 및 실행 (짧은 별칭):
        make build-run m=leetcode/700.cpp

    3. 상세 로그와 함께 클린 빌드:
        make clean-build m=swea/1244/main.cpp l=v

    4. 벤치마크 도구와 연동 (바이너리 경로 출력):
        hyperfine '$(make build m=leetcode/700.cpp l=b)'

    5. 라이브러리 빌드:
        make build LIB_NAME=mylib MODE_TARGET=static m=mylib/util.cpp

    6. 입력 파일로 실행 (stdin 리다이렉션):
        make build-run m=swea/1206/main.cpp i=swea/1206/input.txt

    7. 출력을 파일로 저장:
        make build-run m=swea/1206/main.cpp i=swea/1206/input.txt o=swea/1206/output.txt

    8. 단독 빌드 (의존성 무시, 단일 파일만, PS 문제들):
        make build m=leetcode/104.cpp d=s

    9. 전이적 의존성 탐색 (깊은 의존성 추적):
        make build m=include_transitive/main.c d=tp

    10. 디버그 플래그 추가 빌드:
        make build m=leetcode/236.cpp CXXFLAGS+='-g3 -O0 -fsanitize=address'

    11. 릴리즈 최적화 빌드:
        make build m=leetcode/700.cpp CXXFLAGS+='-O3 -march=native -flto'

    12. 외부 라이브러리 연동 (pkg-config):
        make build m=main.cpp PKGS='opencv4 gtk+-3.0'

    13. 조용한 모드로 CI/CD 파이프라인 빌드:
        make build-run m=test/main.cpp l=s

    14. 동적 라이브러리(shared) 빌드:
        make build t=shared n=libutil.so

    15. 명령행 인자와 함께 실행:
        make build-run m=main.cpp a='--verbose --config=test.json'

    16. 15번과 동일 but binary 모드로 연동:
        ./$(make build m=main.cpp MODE_LOG=binary) --verbose --config=test.json

    17. 의존 헤더 목록 확인:
        make list-headers m=include/main.c

EXIT STATUS
    빌드 성공 시 0 반환, 실패 시 1 반환

NOTES
    • [안전 기능] clean은 마커 파일 확인으로 실수 삭제 방지
    • 헤더 파일 변경 시 관련 소스 자동 재컴파일
    • MODE_TARGET이 라이브러리인 경우 run 타겟은 실행 불가
    • MODE_TARGET이 라이브러리인 경우 링킹 시 LDLIBS 무시
    • MODE_TARGET이 라이브러리인 경우 LIB_NAME 지정 필수
    • MODE_TARGET이 실행파일인 경우 && MAIN_SRC 가 없으면 main.c/main.cpp 자동 탐색
    • 다중 코어(-j 옵션) 사용시 clean build run 같이 타겟을 분할해서 하지 말고 clean-build-run 같이 한 번에 처리하면 경쟁 상태를 방지할 수 있음
```
