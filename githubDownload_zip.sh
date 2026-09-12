#!/bin/sh
set -u

# GitHub ZIP Downloader - يعمل من أي فولدر
REPO_OWNER="KhaledAli65"
REPO_NAME="picon"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TOKEN_FILE="$SCRIPT_DIR/github_token.txt"
OUTPUT_FILE="$SCRIPT_DIR/$REPO_NAME.zip"
TEMP_FILE="$OUTPUT_FILE.tmp"

API="https://api.github.com"
ACCEPT="Accept: application/vnd.github+json"

echo "********************************************"
echo "*   GitHub Repository ZIP Downloader       *"
echo "********************************************"
echo ">> Repository : $REPO_OWNER/$REPO_NAME"
echo ">> Output     : $OUTPUT_FILE"

if ! command -v curl >/dev/null 2>&1; then
    echo ">> [خطأ] curl غير مثبت على الجهاز."
    exit 1
fi

AUTH_HEADER=""
if [ -f "$TOKEN_FILE" ]; then
    GITHUB_TOKEN=$(sed -n '1p' "$TOKEN_FILE" | tr -d '\r\n')
    [ -n "$GITHUB_TOKEN" ] && AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"
fi

echo ">> قراءة الفرع الافتراضي..."

if [ -n "$AUTH_HEADER" ]; then
    repo_json=$(curl -fsS -H "$AUTH_HEADER" -H "$ACCEPT"         "$API/repos/$REPO_OWNER/$REPO_NAME")
else
    repo_json=$(curl -fsS -H "$ACCEPT"         "$API/repos/$REPO_OWNER/$REPO_NAME")
fi

if [ $? -ne 0 ]; then
    echo ">> [خطأ] تعذر الوصول إلى المستودع."
    echo ">> إذا كان Private تأكد من وجود github_token.txt."
    exit 1
fi

BRANCH=$(printf '%s\n' "$repo_json" |
    sed -n 's/.*"default_branch":[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -n 1)

if [ -z "$BRANCH" ]; then
    echo ">> [خطأ] لم يتم التعرف على الفرع الافتراضي."
    exit 1
fi

echo ">> Default branch: $BRANCH"
echo ">> بدء تنزيل محتويات المستودع..."

rm -f "$TEMP_FILE"

ZIP_URL="$API/repos/$REPO_OWNER/$REPO_NAME/zipball/$BRANCH"

if [ -n "$AUTH_HEADER" ]; then
    curl -fL --retry 3 --retry-delay 2         -H "$AUTH_HEADER" -H "$ACCEPT"         -o "$TEMP_FILE" "$ZIP_URL"
else
    curl -fL --retry 3 --retry-delay 2         -H "$ACCEPT" -o "$TEMP_FILE" "$ZIP_URL"
fi

if [ $? -ne 0 ] || [ ! -s "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
    echo ">> [خطأ] فشل تنزيل ملف ZIP."
    exit 1
fi

mv -f "$TEMP_FILE" "$OUTPUT_FILE" || {
    rm -f "$TEMP_FILE"
    echo ">> [خطأ] تعذر حفظ ملف ZIP."
    exit 1
}

FILE_SIZE=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')

echo "********************************************"
echo ">> تم التنزيل بنجاح."
echo ">> الملف : $OUTPUT_FILE"
echo ">> الحجم : $FILE_SIZE bytes"
echo ">> الفرع : $BRANCH"
echo "********************************************"
