# ybrain-skill 安装

> ybrain 外脑技能套件：主技能 + 四个指令技能。本文件面向 AI 编码代理——按步骤安装并汇报。

我想安装 ybrain 技能套件。按以下步骤顺序执行，遇到要求确认的步骤就先停下。

OBJECTIVE: 把本项目的五个技能安装到目标代理的 skills 目录，使其立即可用。

DONE WHEN:

- 目标 skills 根目录下存在 `ybrain`、`ybrain-capture`、`ybrain-organize`、`ybrain-distill`、`ybrain-express` 五个目录
- 每个技能目录顶层有 SKILL.md（单层结构，无嵌套）；ybrain 目录还含 `scripts/` 与 `references/`
- 用户被告知可用的指令技能与生效条件

TODO:

- [ ] 确认目标代理与安装级别
- [ ] 运行安装器（或等价手动复制）
- [ ] 校验目标结构
- [ ] 汇报指令清单与生效方式

## 1. 确认目标

用户使用的代理决定安装目录：

| 代理 | 用户级（跨项目） | 项目级（仅该项目） |
| --- | --- | --- |
| Claude Code | `~/.claude/skills` | `<项目>/.claude/skills` |
| Codex | `~/.agents/skills` | `<项目>/.agents/skills` |
| Qoder | `~/.qoder/skills` | `<项目>/.qoder/skills` |
| OpenCode | `~/.config/opencode/skills` | `<项目>/.opencode/skills` |
| 其他 / 任意 | 请用户提供 skills 根目录，用 `--target` / `-Target` 指定 | 同左 |

注：OpenCode 还会自动发现 `.claude/skills` 与 `.agents/skills`（用户级与项目级同理）中的技能，为 claude/codex 安装的副本对 OpenCode 同样可见。

用户没说明用哪个代理、装哪级时，先问再装；同一台机器可为多个代理各装一份，运行多次安装器即可。

## 2. 安装

优先运行安装器，在本项目根目录执行（macOS/Linux/WSL 用 sh，Windows 用 ps1）：

```bash
./install.sh --agent claude --level user
./install.sh --agent codex --level project --project-path <项目根>
./install.sh --target <任意 skills 根目录>
```

```powershell
pwsh -File install.ps1 -Agent qoder -Level User
pwsh -File install.ps1 -Agent claude -Level Project -ProjectPath <项目根>
pwsh -File install.ps1 -Target <任意 skills 根目录>
```

安装器以本项目 `skills/` 为唯一源，**完全覆盖**目标下的同名技能目录，幂等可重复执行。

若无法运行脚本，可手动复制本项目 `skills/` 下的五个技能目录到目标。注意已知陷阱：
复制目录**内容**（`skills/<name>/*`）到**已存在的**目标同名目录，而不是复制目录本身——
否则会嵌套成 `<name>/<name>`，代理只读顶层 SKILL.md，会静默失效。

## 3. 校验

- 五个技能目录各自顶层有 SKILL.md，无 `<name>/<name>` 嵌套
- ybrain 主技能目录含 `scripts/ima_api.cjs` 与 `references/`（8 个文档）
- 四个指令技能目录只有 SKILL.md 一个文件

## 4. 汇报

向用户说明：

- 已安装到哪个目录、五个技能各自的角色
- 指令技能：`ybrain-capture`（捕获）、`ybrain-organize`（整理收件箱 / 项目归档）、`ybrain-distill`（提炼）、`ybrain-express`（表达）；调用语法随所在代理（如 `/ybrain-capture`、`$ybrain-capture`、OpenCode 的 `@ybrain-capture`）。主技能 ybrain 仍可被自然语言触发（"记一下 / 整理收件箱 / 提炼这篇 / 帮我写 / 外脑…"）
- 多数代理需要重启或新开会话，新技能才进入可用列表
- 运行前提：Node.js；IMA OpenAPI 凭证写入 `~/.config/ima/`（client_id 与 api_key 两个文件）；首次使用时主技能会引导 Bootstrap 自动建齐外脑结构（详见主技能 `references/best-practices.md`）

EXECUTE NOW: 完成 TODO 清单，达成：五个技能安装到位，用户知道有哪些指令、如何生效。
