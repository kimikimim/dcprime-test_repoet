# 대치프라임 성적표 시스템 (dcprime-test_repoet)

시험 성적을 구글 스프레드시트로 입력받아 Supabase에 동기화하고, 학생별 성적표를 JPG로 다운로드하는 관리자 전용 내부 도구.

- `dcprime-academy`(dcprime.co.kr)와는 별도 도메인·레포지만, 같은 Supabase 프로젝트(`smnakhjdtbqgwocwlluz`)를 테이블 접두사 `rc_`로 분리해서 공유합니다.
- 마케팅 페이지가 없는 단일 관리자 도구로, `src/pages/index.astro` 하나에 로그인 게이트 + 시험 관리 + 성적표 다운로드가 모두 들어있습니다.

## 시작하기

```bash
npm install
npm run dev
```

`.env`에 `PUBLIC_SUPABASE_URL`, `PUBLIC_SUPABASE_ANON_KEY`가 필요합니다 (`.env.example` 참고, dcprime-academy와 동일한 값 사용).

## DB 세팅

`supabase-setup.sql`을 Supabase SQL Editor에 붙여넣고 실행하세요 (MCP로 원격 실행 불가, 수동 실행 필요). 실행 후 `rc_config` 테이블의 `admin_password` 값을 원하는 비밀번호로 바꿔주세요 (기본값 `CHANGE_ME`).

```sql
UPDATE rc_config SET value = '원하는비밀번호' WHERE key = 'admin_password';
```

## 구글 시트 연동

관리자 화면 "시험 관리" 탭에서 구글 스프레드시트 ID를 입력하고 저장하면 됩니다. 시트는 "링크가 있는 모든 사용자 - 뷰어"로 공유되어 있어야 하고, 첫 번째 시트 탭의 컬럼 순서는 다음과 같아야 합니다 (헤더 행 1줄 포함):

| 학년 | 시험명 | 시험일자 | 과목 | 이름 | 점수 |
|------|--------|----------|------|------|------|

"구글시트 동기화" 버튼을 누르면 `(학년, 시험명, 시험일자)`로 시험을 묶고, 그 안의 `(과목)` 단위로 반평균·표준편차·석차를 계산해 저장합니다. 같은 시험·과목에 동명이인이 있으면 마지막 행이 이전 값을 덮어씁니다.

## 성적표 다운로드

"성적표" 탭에서 시험을 선택하면 그 시험에 응시한 학생 목록이 뜹니다. 학생별 "다운로드" 버튼을 누르면 과목별 점수·반평균·표준편차·석차가 담긴 JPG 이미지가 다운로드됩니다. 카카오톡 전송은 수동으로 진행합니다.
