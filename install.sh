#!/usr/bin/env bash
# ybrain 技能套件安装器：把主技能 ybrain 与四个指令技能安装到目标代理的 skills 目录。
#
# 用法：
#   ./install.sh --agent <claude|codex|qoder|opencode> [--level <user|project>] [--project-path <路径>]
#   ./install.sh --target <任意 skills 根目录>
#
# 默认目标目录：
#   Agent     --level user           --level project
#   claude    ~/.claude/skills       <ProjectPath>/.claude/skills
#   codex     ~/.agents/skills       <ProjectPath>/.agents/skills
#   qoder     ~/.qoder/skills        <ProjectPath>/.qoder/skills
#   opencode  ~/.config/opencode/skills <ProjectPath>/.opencode/skills
#
# OpenCode 也会自动发现 ~/.claude/skills 与 ~/.agents/skills 中的技能（项目级同理），
# 为 claude/codex 安装的副本同样对 OpenCode 可见。
#
# 安装器以本项目 skills/ 为唯一源，完全覆盖目标下的同名技能目录，幂等可重复执行。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILL_NAMES=(ybrain ybrain-capture ybrain-organize ybrain-distill ybrain-express)

AGENT=""
LEVEL="user"
PROJECT_PATH="$(pwd)"
TARGET=""

usage() {
  cat <<'EOF'
用法: install.sh [选项]

  --agent <claude|codex|qoder|opencode>   目标代理（与 --level 搭配）
  --level <user|project>         安装级别，默认 user
  --project-path <路径>          项目级安装时的项目根目录，默认当前目录
  --target <路径>                直接指定目标 skills 根目录（优先级最高）
  -h, --help                     显示本帮助

默认目标目录：
  Agent     --level user           --level project
  claude    ~/.claude/skills       <项目>/.claude/skills
  codex     ~/.agents/skills       <项目>/.agents/skills
  qoder     ~/.qoder/skills        <项目>/.qoder/skills
  opencode  ~/.config/opencode/skills <项目>/.opencode/skills
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)        AGENT="$2"; shift 2 ;;
    --level)        LEVEL="$2"; shift 2 ;;
    --project-path) PROJECT_PATH="$2"; shift 2 ;;
    --target)       TARGET="$2"; shift 2 ;;
    -h|--help)      usage; exit 0 ;;
    *)              echo "未知参数: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# ---------- 解析安装目标 ----------
if [[ -n "$TARGET" ]]; then
  TARGET_ROOT="$TARGET"
else
  if [[ -z "$AGENT" ]]; then
    echo "错误: 请指定 --agent（claude/codex/qoder/opencode）或 --target <skills 根目录>" >&2
    usage >&2
    exit 1
  fi
  case "$AGENT:$LEVEL" in
    claude:user)    TARGET_ROOT="$HOME/.claude/skills" ;;
    claude:project) TARGET_ROOT="$PROJECT_PATH/.claude/skills" ;;
    codex:user)     TARGET_ROOT="$HOME/.agents/skills" ;;
    codex:project)  TARGET_ROOT="$PROJECT_PATH/.agents/skills" ;;
    qoder:user)     TARGET_ROOT="$HOME/.qoder/skills" ;;
    qoder:project)  TARGET_ROOT="$PROJECT_PATH/.qoder/skills" ;;
    opencode:user)    TARGET_ROOT="$HOME/.config/opencode/skills" ;;
    opencode:project) TARGET_ROOT="$PROJECT_PATH/.opencode/skills" ;;
    *)
      echo "错误: 无效的 --level: $LEVEL（可选 user|project）" >&2
      exit 1
      ;;
  esac
fi

# ---------- 源完整性校验 ----------
for name in "${SKILL_NAMES[@]}"; do
  if [[ ! -f "$SKILLS_SOURCE/$name/SKILL.md" ]]; then
    echo "错误: 源缺失 $SKILLS_SOURCE/$name/SKILL.md（须从 ybrain-skill 项目根运行）" >&2
    exit 1
  fi
done
if [[ ! -f "$SKILLS_SOURCE/ybrain/scripts/ima_api.cjs" ]]; then
  echo "错误: 源缺失 $SKILLS_SOURCE/ybrain/scripts/ima_api.cjs（主技能必须自带 scripts/）" >&2
  exit 1
fi

# ---------- 安装 ----------
mkdir -p "$TARGET_ROOT"

for name in "${SKILL_NAMES[@]}"; do
  src="$SKILLS_SOURCE/$name"
  dest="$TARGET_ROOT/$name"

  # 先删后拷：保证目标与源完全一致（清掉旧版本残留文件）
  rm -rf "$dest"
  mkdir -p "$dest"

  # 注意：复制目录"内容"（"$src/."）而非目录本身，避免嵌套成 <name>/<name>
  cp -R "$src/." "$dest/"

  # 校验单层结构：顶层必须有 SKILL.md
  if [[ ! -f "$dest/SKILL.md" ]]; then
    echo "错误: 安装后校验失败，$dest/SKILL.md 不存在（可能发生了目录嵌套）" >&2
    exit 1
  fi
  echo "[OK] $name -> $TARGET_ROOT"
done

# ---------- 汇报 ----------
echo ""
echo "已安装 5 个技能到：$TARGET_ROOT"
echo "主技能  ：ybrain —— 外脑方法论全流程（Bootstrap、捕获、组织、提炼、表达、唤起、归档）"
echo "指令技能：ybrain-capture  ybrain-organize  ybrain-distill  ybrain-express（斜杠语法随所在代理）"
echo "重启代理（或新开会话）后技能生效。"
echo "运行前提：IMA 凭证已写入 ~/.config/ima/（client_id 与 api_key），详见主技能 references/best-practices.md"
