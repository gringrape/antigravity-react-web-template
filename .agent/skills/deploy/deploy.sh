#!/usr/bin/env bash
# 현재 작업 폴더(프로젝트 루트)에서 실행한다. cd 로 이동하지 않는다.
# id 확보 → 빌드 → zip → 업로드. 진행 상황은 'PROGRESS:' 줄로, 최종 주소는 마지막 줄에 출력.
# 업로드가 몇 분 걸릴 수 있으므로 백그라운드로 돌리고 진행 상황을 계속 전한다(SKILL.md 참고).
set -euo pipefail

# 업로드 엔드포인트 (강사 운영) — 바뀌면 여기만 고친다
UPLOAD_URL="https://lg-vibe-deployer.fly.dev/deploy"

# 1) 사이트 이름 확보 — 있으면 재사용(주소 고정), 없으면 만들어 저장
if [ -f .deploy-site-id ]; then
  SITE_ID="$(cat .deploy-site-id)"
else
  RAND="$(uuidgen 2>/dev/null | tr -d '-' | tr 'A-Z' 'a-z' | cut -c1-12)"
  [ -z "$RAND" ] && RAND="$(cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d '-' | cut -c1-12)"
  [ -z "$RAND" ] && RAND="$(date +%s)"
  SITE_ID="vibe-${RAND}"
  echo "$SITE_ID" > .deploy-site-id
fi

# 진행 상황은 stdout 에 'PROGRESS:' 로 — Agent 가 수강생에게 그대로 전한다.
echo "PROGRESS: 🛠  결과물을 만들고 있어요... (빌드 중)"
npm run build >&2   # 빌드 로그는 stderr 로 (진행/주소 출력과 분리)

echo "PROGRESS: 📦 파일을 포장하고 있어요..."
rm -f site.zip
( cd dist && zip -r -q ../site.zip . )

echo "PROGRESS: ☁️  인터넷에 올리는 중이에요... 최대 몇 분 걸릴 수 있어요. 조금만 기다려 주세요!"
# 업로드: 연결은 빨리 실패, 처리(배포)는 최대 5분까지 기다림
RESPONSE="$(curl -s --connect-timeout 20 --max-time 300 --retry 2 --retry-connrefused \
  -X POST "$UPLOAD_URL" \
  -F "siteId=${SITE_ID}" \
  -F "site=@site.zip")"

# 응답 JSON 의 url 추출 (없으면 SITE_ID 로 구성)
URL="$(printf '%s' "$RESPONSE" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s).url||"")}catch{process.stdout.write("")}})' 2>/dev/null || true)"
[ -z "$URL" ] && URL="https://${SITE_ID}.web.app"

rm -f site.zip
echo "$URL"   # 마지막 줄 = 배포 주소
