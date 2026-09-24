#!/bin/sh

# ============================================================
# GitHub Repo Cleaner - FULL RESET
#
# الهدف:
#   - حذف محتوى المستودع بالكامل
#   - الاحتفاظ فقط بـ README.md في الجذر إن كان موجوداً
#   - إنشاء تاريخ Git جديد من الصفر (Orphan Commit)
#   - لا توجد حلقة حذف ولا DELETE لكل ملف
#
# ملف التوكن يجب أن يكون بجوار هذا السكربت:
#   github_token.txt
# ============================================================

set -u

REPO_OWNER="KhaledAli65"
REPO_NAME="Channels"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TOKEN_FILE="$SCRIPT_DIR/github_token.txt"

if [ ! -f "$TOKEN_FILE" ]; then
    echo ">> [خطأ] ملف التوكن غير موجود:"
    echo ">> $TOKEN_FILE"
    echo ">> أنشئ الملف وضع التوكن الجديد في سطر واحد."
    exit 1
fi

GITHUB_TOKEN=$(sed -n '1p' "$TOKEN_FILE" | tr -d '\r\n')

if [ -z "$GITHUB_TOKEN" ]; then
    echo ">> [خطأ] ملف github_token.txt فارغ."
    exit 1
fi

API="https://api.github.com"
AUTH="Authorization: Bearer $GITHUB_TOKEN"
ACCEPT="Accept: application/vnd.github+json"

echo "********************************************"
echo "*      GitHub Repo Cleaner - FULL RESET     *"
echo "********************************************"
echo ">> المستودع: $REPO_OWNER/$REPO_NAME"
echo ">> تنفيذ مباشر بدون تأكيد."

# ------------------------------------------------------------
# 1) قراءة معلومات المستودع
# ------------------------------------------------------------
echo ">> فحص المستودع..."

repo_json=$(curl -fsS \
    -H "$AUTH" -H "$ACCEPT" \
    "$API/repos/$REPO_OWNER/$REPO_NAME") || {
    echo ">> [خطأ] فشل الاتصال بالمستودع أو التوكن غير صالح."
    exit 1
}

BRANCH=$(printf '%s\n' "$repo_json" |
    sed -n 's/.*"default_branch":[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -n 1)

if [ -z "$BRANCH" ]; then
    echo ">> [خطأ] لم يتم التعرف على الفرع الافتراضي."
    exit 1
fi

echo ">> الفرع الافتراضي: $BRANCH"

# ------------------------------------------------------------
# 2) قراءة HEAD الحالي
# ------------------------------------------------------------
ref_json=$(curl -fsS \
    -H "$AUTH" -H "$ACCEPT" \
    "$API/repos/$REPO_OWNER/$REPO_NAME/git/ref/heads/$BRANCH") || {
    echo ">> [خطأ] تعذر قراءة مرجع الفرع."
    exit 1
}

OLD_HEAD=$(printf '%s\n' "$ref_json" |
    sed -n 's/.*"sha":[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -n 1)

if [ -z "$OLD_HEAD" ]; then
    echo ">> [خطأ] لم يتم الحصول على SHA الحالي."
    exit 1
fi

echo ">> HEAD القديم: $OLD_HEAD"

# ------------------------------------------------------------
# 3) قراءة الشجرة مرة واحدة للحصول على README.md فقط
# ------------------------------------------------------------
echo ">> قراءة الشجرة الحالية مرة واحدة..."

tree_json=$(curl -fsS \
    -H "$AUTH" -H "$ACCEPT" \
    "$API/repos/$REPO_OWNER/$REPO_NAME/git/trees/$OLD_HEAD?recursive=1") || {
    echo ">> [خطأ] تعذر قراءة شجرة المستودع."
    exit 1
}

README_SHA=$(printf '%s\n' "$tree_json" |
    awk '
        /"path": "README\.md"/ { found=1; next }
        found && /"sha":/ {
            gsub(/.*"sha":[[:space:]]*"/, "", $0)
            gsub(/".*/, "", $0)
            print
            exit
        }
    ')

# SHA الثابت لشجرة فارغة في Git (نفسه دائماً في كل مستودع،
# وليس شيئاً يُطلب إنشاؤه عبر API - GitHub يرفض ذلك بخطأ 422).
EMPTY_TREE_SHA="4b825dc642cb6eb9a060e54bf8d69288fbee4904"

if [ -n "$README_SHA" ]; then
    echo ">> README.md موجود وسيتم الاحتفاظ به."
    TREE_BODY='{"tree":[{"path":"README.md","mode":"100644","type":"blob","sha":"'"$README_SHA"'"}]}'

    # ------------------------------------------------------------
    # 4) إنشاء Tree جديدة تحتوي على README فقط
    # ------------------------------------------------------------
    echo ">> إنشاء Tree جديدة..."

    new_tree_json=$(curl -fsS -X POST \
        -H "$AUTH" -H "$ACCEPT" \
        -H "Content-Type: application/json" \
        -d "$TREE_BODY" \
        "$API/repos/$REPO_OWNER/$REPO_NAME/git/trees") || {
        echo ">> [خطأ] فشل إنشاء Tree الجديدة."
        exit 1
    }

    NEW_TREE_SHA=$(printf '%s\n' "$new_tree_json" |
        sed -n 's/.*"sha":[[:space:]]*"\([^"]*\)".*/\1/p' |
        head -n 1)

    if [ -z "$NEW_TREE_SHA" ]; then
        echo ">> [خطأ] لم يتم الحصول على SHA للشجرة الجديدة."
        exit 1
    fi
else
    echo ">> لا يوجد README.md في الجذر."
    echo ">> سيتم إنشاء مستودع فارغ تماماً."
    # لا حاجة لأي طلب API هنا؛ نستخدم SHA الشجرة الفارغة الثابت مباشرة.
    NEW_TREE_SHA="$EMPTY_TREE_SHA"
fi

echo ">> Tree الجديدة: $NEW_TREE_SHA"

# ------------------------------------------------------------
# 5) إنشاء Commit بدون أي Parent
#
# هذا هو الجزء الذي يمسح التاريخ من منظور الفرع:
# Commit جديد مستقل (Orphan Commit).
# ------------------------------------------------------------
COMMIT_BODY='{"message":"Reset repository - keep README only","tree":"'"$NEW_TREE_SHA"'"}'

echo ">> إنشاء Commit جديد بدون تاريخ سابق..."

commit_json=$(curl -fsS -X POST \
    -H "$AUTH" -H "$ACCEPT" \
    -H "Content-Type: application/json" \
    -d "$COMMIT_BODY" \
    "$API/repos/$REPO_OWNER/$REPO_NAME/git/commits") || {
    echo ">> [خطأ] فشل إنشاء الـ Commit الجديد."
    exit 1
}

NEW_COMMIT_SHA=$(printf '%s\n' "$commit_json" |
    sed -n 's/.*"sha":[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -n 1)

if [ -z "$NEW_COMMIT_SHA" ]; then
    echo ">> [خطأ] لم يتم الحصول على SHA للـ Commit الجديد."
    exit 1
fi

echo ">> Commit الجديد: $NEW_COMMIT_SHA"

# ------------------------------------------------------------
# 6) Force update للفرع
#
# الآن الفرع لا يشير إلى التاريخ القديم إطلاقاً.
# ------------------------------------------------------------
REF_BODY='{"sha":"'"$NEW_COMMIT_SHA"'","force":true}'

echo ">> إعادة توجيه الفرع إلى التاريخ الجديد..."

curl -fsS -X PATCH \
    -H "$AUTH" -H "$ACCEPT" \
    -H "Content-Type: application/json" \
    -d "$REF_BODY" \
    "$API/repos/$REPO_OWNER/$REPO_NAME/git/refs/heads/$BRANCH" > /dev/null || {
    echo ">> [خطأ] فشل تحديث الفرع."
    echo ">> إذا كان الفرع محمياً، أوقف حماية الفرع مؤقتاً ثم أعد التشغيل."
    exit 1
}

echo "********************************************"
echo ">> تمت العملية بنجاح."
echo ">> تم إنشاء تاريخ Git جديد من الصفر."
if [ -n "$README_SHA" ]; then
    echo ">> الملف المتبقي: README.md"
else
    echo ">> المستودع أصبح فارغاً."
fi
echo ">> HEAD الجديد: $NEW_COMMIT_SHA"
echo "********************************************"
echo ">> ملاحظة: التاريخ القديم لم يعد مرتبطاً بالفرع."
echo ">> GitHub قد يحتفظ بالكائنات القديمة مؤقتاً قبل Garbage Collection."
