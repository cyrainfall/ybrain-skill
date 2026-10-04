#Requires -Version 5.1
<#
.SYNOPSIS
    ybrain 技能套件安装器：把主技能 ybrain 与四个指令技能安装到目标代理的 skills 目录。

.DESCRIPTION
    安装（或刷新）以下五个技能，目标为单层结构（<目标>\<技能名>\SKILL.md）：
      ybrain            主技能（方法论 + scripts/ + references/，完全自包含）
      ybrain-capture    捕获
      ybrain-organize   组织（整理收件箱 / 项目归档）
      ybrain-distill    提炼
      ybrain-express    表达

    支持的代理与默认目录（-Agent + -Level 决定目标；-Target 直接指定 skills 根目录，优先级最高）：

      Agent     Level=User               Level=Project
      claude    ~\.claude\skills         <ProjectPath>\.claude\skills
      codex     ~\.agents\skills         <ProjectPath>\.agents\skills
      qoder     ~\.qoder\skills          <ProjectPath>\.qoder\skills
      opencode  ~\.config\opencode\skills <ProjectPath>\.opencode\skills

    OpenCode 也会自动发现 ~/.claude/skills 与 ~/.agents/skills 中的技能（项目级同理），
    为 claude/codex 安装的副本同样对 OpenCode 可见。

    安装器以本项目 skills\ 为唯一源，完全覆盖目标下的同名技能目录，幂等可重复执行；
    修改源后重跑即可刷新部署副本。

.EXAMPLE
    pwsh -File install.ps1 -Agent claude -Level User
    安装到 ~/.claude/skills（用户级，所有项目可用）

.EXAMPLE
    pwsh -File install.ps1 -Agent qoder -Level Project -ProjectPath D:\path\to\project
    安装到指定项目的 .qoder\skills

.EXAMPLE
    pwsh -File install.ps1 -Target D:\any\skills-root
    安装到任意 skills 根目录
#>
[CmdletBinding()]
param(
    # 目标代理：决定默认 skills 目录（与 -Level 搭配使用）
    [ValidateSet('claude', 'codex', 'qoder', 'opencode')]
    [string]$Agent,

    # 安装级别：User = 用户级（所有项目可用，默认）；Project = 项目级（搭配 -ProjectPath）
    [ValidateSet('User', 'Project')]
    [string]$Level = 'User',

    # 项目级安装时的项目根目录（默认当前目录）
    [string]$ProjectPath = (Get-Location).Path,

    # 直接指定目标 skills 根目录（优先级最高，忽略 Agent/Level）
    [string]$Target
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = $PSScriptRoot
$SkillsSource = Join-Path $ProjectRoot 'skills'
$SkillNames = @('ybrain', 'ybrain-capture', 'ybrain-organize', 'ybrain-distill', 'ybrain-express')

# ---------- 解析安装目标 ----------
$TargetRoot = $Target
if (-not $TargetRoot) {
    if (-not $Agent) {
        throw '请指定 -Agent（claude/codex/qoder/opencode）或 -Target <skills 根目录>'
    }
    switch ($Agent) {
        'claude'   { $userDir = Join-Path $HOME '.claude\skills';          $projDir = '.claude\skills'    }
        'codex'    { $userDir = Join-Path $HOME '.agents\skills';          $projDir = '.agents\skills'    }
        'qoder'    { $userDir = Join-Path $HOME '.qoder\skills';           $projDir = '.qoder\skills'     }
        'opencode' { $userDir = Join-Path $HOME '.config\opencode\skills'; $projDir = '.opencode\skills'  }
    }
    if ($Level -eq 'User') {
        $TargetRoot = $userDir
    }
    else {
        $TargetRoot = Join-Path $ProjectPath $projDir
    }
}

# ---------- 源完整性校验 ----------
foreach ($name in $SkillNames) {
    $skillMd = Join-Path $SkillsSource "$name\SKILL.md"
    if (-not (Test-Path $skillMd)) {
        throw "源缺失：$skillMd（本脚本必须从 ybrain-skill 项目根运行）"
    }
}
if (-not (Test-Path (Join-Path $SkillsSource 'ybrain\scripts\ima_api.cjs'))) {
    throw "源缺失：$SkillsSource\ybrain\scripts\ima_api.cjs（主技能必须自带 scripts/）"
}

# ---------- 安装 ----------
New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

foreach ($name in $SkillNames) {
    $dest = Join-Path $TargetRoot $name
    $srcSkill = Join-Path $SkillsSource $name

    # 先删后拷：保证目标与源完全一致（清掉旧版本残留文件）
    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    # 注意：复制目录"内容"（\<name>\*）而非目录本身，避免嵌套成 <name>\<name>
    Copy-Item -Path (Join-Path $srcSkill '*') -Destination $dest -Recurse -Force

    # 校验单层结构：顶层必须有 SKILL.md
    if (-not (Test-Path (Join-Path $dest 'SKILL.md'))) {
        throw "安装后校验失败：$dest\SKILL.md 不存在（可能发生了目录嵌套）"
    }
    Write-Host "[OK] $name -> $TargetRoot"
}

# ---------- 汇报 ----------
Write-Host ''
Write-Host "已安装 5 个技能到：$TargetRoot"
Write-Host '主技能  ：ybrain —— 外脑方法论全流程（Bootstrap、捕获、组织、提炼、表达、唤起、归档）'
Write-Host '指令技能：ybrain-capture  ybrain-organize  ybrain-distill  ybrain-express（斜杠语法随所在代理）'
Write-Host '重启代理（或新开会话）后技能生效。'
Write-Host '运行前提：IMA 凭证已写入 ~/.config/ima/（client_id 与 api_key），详见主技能 references/best-practices.md'
