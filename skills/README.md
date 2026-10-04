# ybrain skills

本目录下的五个技能随项目一起安装（install.sh / install.ps1，或由代理按 install.md 执行）：

| 技能 | 角色 | 触发 |
| --- | --- | --- |
| `ybrain` | 主技能：外脑方法论全流程，自带 scripts/ 与 references/ | 自然语言意图路由（"记一下 / 整理收件箱 / 提炼 / 帮我写 / 外脑…"） |
| `ybrain-capture` | 捕获指令入口 | `/ybrain-capture`（斜杠语法随所在代理） |
| `ybrain-organize` | 组织指令入口（整理收件箱、项目归档） | `/ybrain-organize` |
| `ybrain-distill` | 提炼指令入口 | `/ybrain-distill` |
| `ybrain-express` | 表达指令入口 | `/ybrain-express` |

四个指令技能是主技能的薄入口，依赖同目录安装的 `ybrain/`（脚本与 API 文档），不能单独分发；两者描述冲突时以主技能 SKILL.md 为准。
