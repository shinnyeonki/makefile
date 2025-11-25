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
    help             이 도움말 표시

VARIABLES
    MAIN_SRC=file  (별칭: s=file) (관련: build(target), run(target))
        빌드할 메인 소스 파일 경로. 미지정 시 main.c/main.cpp 자동 탐색

    MODE_LOG=mode  (별칭: ml=mode) (관련: 모든 빌드 관련 타겟)
        빌드 출력 형식 제어. 기본값: normal
        normal (n)            한글 메시지, 색상 강조 (기본값)
        silent (s)            성공 시 출력 없음, 에러만 표시
        verbose (v)           영어 메시지, 모든 명령어 출력
        binary (b)            바이너리 경로만 출력 (도구 연동용)
        raw (r)               컴파일러 원본 출력만 표시

    MODE_TARGET=mode  (별칭: mt=mode) (관련: build(target), LIB_NAME(option))
        빌드 유형. 기본값: executable
        executable (exe, bin, out)        실행파일 생성 (기본값)
        static (a)                        정적 라이브러리 (a)
        shared (so, dll, dylib)           동적 라이브러리 (so, dll, dylib)

    MODE_DEPS=mode  (별칭: md=mode) (관련: build(target))
        의존성 탐색 방식. 기본값: path
        path (p)                      경로 기반 매칭 (동일 폴더)
        file (f)                      파일명 기반 매칭 (include/src 분리)
        standalone (s)                단독 빌드 (의존성 무시)
        all (a)                       전체 링크 (모든 소스 포함)
        transitive_path (tp)          전이적 경로 기반
        transitive_file (tf)          전이적 파일명 기반

    LIB_NAME=name  (별칭: n=name) (관련: build(target), MODE_TARGET(option))
        라이브러리 빌드 시 결과물 이름 지정 경로와 함께 지정 가능 (라이브러리 모드에서만 사용)

    STDIN=file (별칭: i), STDOUT=file (별칭: o), STDERR=file (별칭: e), ARGS=args (별칭: a) (관련: run(target))
        실행 시 입출력 리다이렉션 및 추가 인자 지정

ADVANCED VARIABLES
    일반적으로 파일을 고쳐서 변경하는 것이 좋음
    SRC_ROOT=path : 소스 파일 탐색의 루트 디렉토리 지정 (기본값: ./)
    BUILD_ROOT=path : 빌드 출력 디렉토리 경로 지정 (기본값: ./build)
    CPPFLAGS+=flags : 전처리기 플래그 지정 C/C++ 공통
    CFLAGS+=flags : C 컴파일러에 전달할 추가 플래그 지정
    CXXFLAGS+=flags : C++ 컴파일러에 전달할 추가 플래그 지정
    LDFLAGS+=flags : 링커에 전달할 추가 플래그 지정
    LDLIBS+=libs : 링커에 전달할 추가 라이브러리 지정
    PKGS="pkg1 pkg2 ..." : pkg-config를 통해 포함할 외부 라이브러리 목록 지정

EXAMPLES
    1. 기본 빌드 (main.c/main.cpp 자동 탐색):
        $ make build

    2. 특정 파일 빌드 및 실행 (짧은 별칭):
        $ make build-run s=leetcode/700.cpp

    3. 상세 로그와 함께 클린 빌드:
        $ make clean-build s=swea/1244/main.cpp m=v

    4. 벤치마크 도구와 연동 (바이너리 경로 출력):
        $ hyperfine '$(make build s=leetcode/700.cpp m=b)'

    5. 라이브러리 빌드:
        $ make build LIB_NAME=mylib MODE_TARGET=static s=mylib/util.cpp

EXIT STATUS
    빌드 성공 시 0 반환, 실패 시 1 반환

NOTES
    • [안전 기능] clean은 마커 파일 확인으로 실수 삭제 방지
    • 헤더 파일 변경 시 관련 소스 자동 재컴파일
    • TARGET_TYPE이 라이브러리인 경우 run 타겟은 실행 불가
    • TARGET_TYPE이 라이브러리인 경우 링킹 시 LDLIBS 무시
    • TARGET_TYPE이 라이브러리인 경우 LIB_NAME 지정 필수
    • TARGET_TYPE이 실행파일인 경우 && MAIN_SRC 가 없으면 main.c/main.cpp 자동 탐색
    • 다중 코어(-j 옵션) 사용시 clean build run 같이 타겟을 분할해서 하지 말고 clean-build-run 같이 한 번에 처리하면 경쟁 상태를 방지할 수 있음
```
