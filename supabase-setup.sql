-- ============================================================
-- dcprime-test_repoet (성적표 시스템) Supabase 셋업 SQL
-- 기존 대치프라임 DB(smnakhjdtbqgwocwlluz)에 그대로 추가 실행
-- Supabase SQL Editor에 전체 붙여넣고 한 번에 실행 (재실행해도 안전)
-- 테이블명은 기존 테이블(dcprime-academy)과 dcprime-students(staff_)와
-- 겹치지 않도록 rc_(report card) 접두사 사용
-- ============================================================

-- ────────────────────────────────────────────
-- 0. 예전 버전(로그인 게이트 + 구글시트 연동 버전)의 잔재 정리
--    처음 실행하는 경우엔 그냥 아무 일도 하지 않음
-- ────────────────────────────────────────────
DROP FUNCTION IF EXISTS verify_rc_admin_password(text);
DROP FUNCTION IF EXISTS get_rc_sheet_id();
DROP FUNCTION IF EXISTS set_rc_sheet_id(text);
DROP TABLE IF EXISTS rc_config;

-- ────────────────────────────────────────────
-- 1. 시험 (시험 회차 단위 — 과목은 rc_scores에서 구분)
--    학년 + 시험명 + 시험일자로 고유
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rc_exams (
  id         uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  grade      text        NOT NULL,
  name       text        NOT NULL,
  exam_date  date        NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (grade, name, exam_date)
);

ALTER TABLE rc_exams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon all rc_exams" ON rc_exams;
CREATE POLICY "anon all rc_exams" ON rc_exams
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- ────────────────────────────────────────────
-- 2. 과목별 성적 (한 시험 안에 과목별로 여러 행)
--    통계값(반평균/표준편차/석차/응시인원)은 엑셀 업로드 시점에 계산해서 저장
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rc_scores (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  exam_id       uuid        NOT NULL REFERENCES rc_exams(id) ON DELETE CASCADE,
  subject       text        NOT NULL,
  student_name  text        NOT NULL,
  score         numeric     NOT NULL,
  class_avg     numeric     NOT NULL,
  class_stddev  numeric     NOT NULL,
  class_rank    int         NOT NULL,
  class_size    int         NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (exam_id, subject, student_name)
);

ALTER TABLE rc_scores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon all rc_scores" ON rc_scores;
CREATE POLICY "anon all rc_scores" ON rc_scores
  FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_rc_scores_exam_student ON rc_scores (exam_id, student_name);
