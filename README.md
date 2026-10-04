# ybrain-skill

ybrain 个人外脑技能套件：以 CODE 循环（捕获→组织→提炼→表达）+ PARA 组织法为方法论，基于腾讯 IMA OpenAPI，用双层单库架构（记忆层=知识库，思想层=笔记本）管理个人知识。

## 技能清单

| 技能 | 角色 | 调用 |
| --- | --- | --- |
| `ybrain` | 主技能：外脑方法论全流程（Bootstrap、捕获、组织、提炼、表达、唤起、归档），自带传输脚本与 API 文档 | 自然语言意图（"记一下 / 整理收件箱 / 提炼这篇 / 帮我写一篇 / 外脑…"） |
| `ybrain-capture` | 捕获：链接 / 文件 / 灵感不问分类直入收件箱 | `/ybrain-capture` |
| `ybrain-organize` | 组织：整理收件箱（四问筛选、全自动归位）与项目归档 | `/ybrain-organize` |
| `ybrain-distill` | 提炼：材料蒸馏成结构化要点，持续追加进知识包 | `/ybrain-distill` |
| `ybrain-express` | 表达：汇聚素材起草成文，成品落盘为【输出】笔记 | `/ybrain-express` |

调用语法随所在代理：斜杠（如 `/ybrain-capture`）、OpenCode 的 `@ybrain-capture` 提及式均可用。

四个指令技能是主技能的薄入口，依赖同目录的 `skills/ybrain/`；两者描述冲突时以主技能 SKILL.md 为准。

## 安装

所有技能均为开放的 SKILL.md 格式（frontmatter `name` + `description`），任何支持该格式的编码代理均可使用。

两条路径**二选一**，同时安装会让每个技能出现两份。

### 1. 通用安装器（推荐，任意代理）

```bash
npx skills@latest add cyrainfall/ybrain-skill
```

安装器会自动探测本机的编码代理（Claude Code、Codex、Cursor、Qoder、OpenCode 等 80 余个），让你挑选要安装的技能与目标代理。本套件五个技能互相依赖，**请全选**（`ybrain` + 四个指令技能）。安装后的技能是归你所有的普通文件，可自由编辑。

常用参数：

| 场景 | 命令 |
| --- | --- |
| 先看有哪些技能 | `npx skills add cyrainfall/ybrain-skill --list` |
| 全装、免确认 | `npx skills add cyrainfall/ybrain-skill --all` |
| 指定代理 | `npx skills add cyrainfall/ybrain-skill -a claude-code -a codex` |
| 安装到用户级（跨项目） | `npx skills add cyrainfall/ybrain-skill -g` |
| 更新已安装技能 | `npx skills update` |

也可从本地克隆安装：`npx skills@latest add ./skills`。

### 2. Claude Code 插件（只读、随仓库更新）

```
/plugin marketplace add cyrainfall/ybrain-skill
/plugin install ybrain-skills@ybrain-skill
```

作为受管、只读的 bundle 安装，本地不留可编辑副本，适合只跟随版本、不改造技能的用户。

### 安装目录参考

| Agent | 用户级（跨项目） | 项目级（仅该项目） |
| --- | --- | --- |
| Claude Code | `~/.claude/skills` | `<项目>/.claude/skills` |
| Codex | `~/.agents/skills` | `<项目>/.agents/skills` |
| Qoder | `~/.qoder/skills` | `<项目>/.qoder/skills` |
| OpenCode | `~/.config/opencode/skills` | `<项目>/.agents/skills` |
| 其他代理 | 由安装器自动探测，或用 `-a` 指定 | 同左 |

注：OpenCode 还会自动发现 `.claude/skills` 与 `.agents/skills`（用户级与项目级同理）中的技能，为 claude/codex 安装的副本对 OpenCode 同样可见；OpenCode 中用 `@ybrain-capture` 提及技能。

`.claude-plugin/` 下的 `marketplace.json` 与 `plugin.json` 声明了五个技能的路径，插件安装与 `npx skills` 发现都依赖它，改动技能目录时需同步更新。安装或更新后重启代理（或新开会话）生效。

## 运行前提

- Node.js（传输脚本以 node 运行）
- IMA OpenAPI 凭证：写入 `~/.config/ima/client_id` 与 `~/.config/ima/api_key` 两个文件
- 首次使用时主技能会引导 Bootstrap，自动建齐外脑结构（知识库 + 笔记本 + 收件箱），详见 `skills/ybrain/references/best-practices.md`

## 维护

- 本目录 `skills/` 是唯一维护源；安装到各代理的副本由 `npx skills update` 刷新，不要手改副本（改了就失去干净更新）
- 改主技能工作流后，同步检查四个指令技能的同名章节
- 指令技能保持"中厚度"：流程要点与硬规则就地，API 细节一律指向主技能 `references/`，不复制正文
- 技能文档（SKILL.md、references/）内禁止绝对路径与机器特定引用（可移植性要求）
