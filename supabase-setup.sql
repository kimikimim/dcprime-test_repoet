-- ============================================================
-- dcprime-test_repoet (성적표 시스템) Supabase 셋업 SQL
-- 기존 대치프라임 DB(smnakhjdtbqgwocwlluz)에 그대로 추가 실행
-- Supabase SQL Editor에 전체 붙여넣고 한 번에 실행 (재실행해도 안전 — 기존 데이터 보존)
-- 테이블명은 기존 테이블(dcprime-academy)과 dcprime-students(staff_)와
-- 겹치지 않도록 rc_(report card) 접두사 사용
-- ============================================================

-- 예전 버전(로그인 게이트 + 구글시트 연동 버전)의 잔재 정리
DROP FUNCTION IF EXISTS verify_rc_admin_password(text);
DROP FUNCTION IF EXISTS get_rc_sheet_id();
DROP FUNCTION IF EXISTS set_rc_sheet_id(text);
DROP TABLE IF EXISTS rc_config;

-- ────────────────────────────────────────────
-- 1. 시험 (관리자가 "시험 관리" 탭에서 직접 생성)
--    대상학년은 여러 개 선택 가능(text[]), 과목은 시험 하나당 하나
--    (같은 시험명으로 과목별 시험을 여러 개 만들면, 성적표 탭에서 같은 시험명으로 자동으로 묶여서 보임)
--    comment: 시험 상세 화면에서 입력하는 총평, 성적표 하단에 과목별로 표시
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rc_exams (
  id           uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  grades       text[]      NOT NULL,
  subject      text        NOT NULL,
  name         text        NOT NULL,
  period_start date        NOT NULL,
  period_end   date        NOT NULL,
  comment      text        NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE rc_exams ADD COLUMN IF NOT EXISTS comment text NOT NULL DEFAULT '';

ALTER TABLE rc_exams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon all rc_exams" ON rc_exams;
CREATE POLICY "anon all rc_exams" ON rc_exams
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- ────────────────────────────────────────────
-- 2. 학생 성적 (엑셀 업로드 또는 시험 상세 화면에서 수동 추가/수정/삭제로 채워지는 명단)
--    class_avg/class_stddev/class_rank/class_size는 같은 exam_id + grade 그룹 안에서 계산해서 저장
--    (학년별로 별도 순위 — 대상학년이 여러 개인 시험이어도 학년끼리는 안 섞임)
--    예상등급은 저장하지 않고, class_rank/class_size로 화면에서 계산해서 보여줌
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rc_scores (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  exam_id       uuid        NOT NULL REFERENCES rc_exams(id) ON DELETE CASCADE,
  grade         text        NOT NULL,
  student_name  text        NOT NULL,
  score         numeric     NOT NULL,
  class_avg     numeric     NOT NULL DEFAULT 0,
  class_stddev  numeric     NOT NULL DEFAULT 0,
  class_rank    int         NOT NULL DEFAULT 0,
  class_size    int         NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (exam_id, grade, student_name)
);

ALTER TABLE rc_scores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon all rc_scores" ON rc_scores;
CREATE POLICY "anon all rc_scores" ON rc_scores
  FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_rc_scores_exam_grade ON rc_scores (exam_id, grade);
