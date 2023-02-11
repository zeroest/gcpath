# GCPATH

현재 사용중인 Spring 서버의 엔드포인트를 기준으로 ElasticSearch(http log data)에 호출된 기록을 찾아 Deprecate되어야 할 경로를 찾는다

## Install

필자는 Mac, zsh을 사용하기에 zsh기준의 커맨드를 기록함

### 환경변수 설정

`GCPATH_ES_BASE_URL_DEV` - 사용할 ElasticSearch의 개발환경 주소를 입력한다

`GCPATH_ES_BASE_URL_PROD` - 사용할 ElasticSearch의 운영환경 주소를 입력한다

```
echo "
### GCPATH
export GCPATH_ES_BASE_URL_PROD=https://es-log-prod.service.com
export GCPATH_ES_BASE_URL_DEV=https://es-log-dev.service.com
" >> ~/.zshrc

```

### 실행파일 설치

포함된 `install.sh` 파일을 실행한다. (필요시 실행권한을 확하여 부여하도록 한다.)

해당 파일은 json 파싱에 필요한 jq 라이브러리와 gcpath 실행파일을 `/usr/local/bin` 에 위치하도록 도와준다

```
# chmod +x install.sh
./install.sh

```

## Run

### Spring 엔드포인트 추출

[Get All Endpoints in Spring Boot](https://www.baeldung.com/spring-boot-get-all-endpoints)

- `3.1. ApplicationListener Interface`
- `3.2. @EventListener Annotation`

baeldung에서 spring-boot-get-all-endpoints글을 참고하여 모든 엔드포인트를 추출한다.

추출한 로그 데이터를 복사하여 파일로 저장해두도록 한다.

추출 결과 예시 로그데이터

```
INFO  2023-02-10 19:14:25.745 [main] [c.t.a.w.o.a.c.ApiConfig:43] - {POST [/api/proxy/work-process/create]} c.t.a.w.o.a.p.WorkProcessProxyController#createPolicy(PolicyRequestDto)
INFO  2023-02-10 19:14:25.745 [main] [c.t.a.w.o.a.c.ApiConfig:43] - {POST [/api/proxy/work-process]} c.t.a.w.o.a.p.WorkProcessProxyController#listPolicy()

```

### gcpath 명령어 실행

- [t | trim] Spring에서 추출한 원본 로그 데이터 파일을 정리하여 엔드포인트만 정리된 파일로 변경해준다.
    - `gcpath t`[trim 명령어] `./raw.log`[Spring에서 추출한 원본 로그 데이터]
    - 설정 가능한 옵션
        - [-out | --output ] 정돈된 엔드포인트 파일이 나올 경로 설정 (경로 설정이 없을경우 현재위치의 `paths.txt` 파일로 저장됨)
            - `gcpath t -out ./path/trimed_endpoints.txt`[추출 경로 및 파일명 설정] `./raw.log`

정리된 파일 예시 데이터

```
/api/proxy/work-process/create
/api/proxy/work-process

```

- [gc | ] 정돈된 엔드포인트를 기준으로 실제 호출된 기록과 비교하여 Deprecate되어야할 경로를 로그로 반환한다.
    - `gcpath gc`[gc 명령어 (생략가능)] `servicename`[서비스명을 입력한다] `2023-01-01`[입력한 일자부터 현재까지 호출된 기록을 확인한다]
    - 설정 가능한 옵션
        - [-in | --input ] 입력할 모든 엔드포인트 파일을 설정 (경로 설정이 없을경우 현재위치의 `paths.txt` 파일로 입력됨)
            - `gcpath gc -in ./path/trimed_endpoints.txt`[엔드포인트 파일 경로 설정] `servicename 2023-01-01`
        - [-p | --profile] dev, prod 환경 중 선택할 수 있도록 한다 (설정이 없을경우 prod가 기본으로 설정된다)
            - `gcpath gc -p dev servicename 2023-01-01`
        - [-id | --esid ] ElasticSearch username을 설정한다. (해당 옵션 설정은 -pw와 함께 설정되어야한다)
            - `gcpath gc -id username -pw password servicename 2023-01-01`
        - [-pw | --espw ] ElasticSearch password를 설정한다. (해당 옵션 설정은 -id와 함께 설정되어야한다)
            - `gcpath gc -id username -pw password servicename 2023-01-01`

~~불친절한~~ 설명서는 `gcpath -h`를 사용해서 볼 수 있다.

```
usage: gcpath [t | gc |  ]
[trim | t ]            Trim path from log file                                            Example: gcpath t raw.log
[gc   |   ]            Show paths that no longer in use                                   Example: gcpath gc servicename 2023-01-01
  options
  [-h   | --help   ]   Show help                                                          Example: gcpath -h
  [-p   | --profile]   Set profile dev or prod (default prod)                             Example: gcpath -p dev servicename 2023-01-01
  [-id  | --esid   ]   Set elastic search auth username                                   Example: gcpath -id esid -pw espw servicename 2023-01-01
  [-pw  | --espw   ]   Set elastic search auth password                                   Example: gcpath -id esid -pw espw servicename 2023-01-01
  [-in  | --input  ]   Set input path that trimed endpoints file  (default ./paths.txt)   Example: gcpath gc -in ./path/trimed_endpoints.txt servicename 2023-01-01
  [-out | --output ]   Set output path that trimed endpoints file (default ./paths.txt)   Example: gcpath t -out ./path/trimed_endpoints.txt ./raw.log

```
