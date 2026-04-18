---
title: "Enhancement: Progress Update Hook — 从文本规则升级为程序化保障"
type: enhancement
created: 2026-04-13
author: claude
status: proposed
priority: high
---

# Enhancement: Progress Update Hook — 从文本规则升级为程序化保障

## 1. 问题背景

在 persona-agents-platform5 项目中，AI（Claude）在 tech-lead 阶段反复遗漏 progress.md 和 progress-history.md 的更新：

1. 第 1 次：完成设计修复后忘记更新 progress.md
2. 第 2 次：记住了 progress.md 但忘记 progress-history.md
3. 第 3 次：两个都更新了但在"声称修复"时没有验证文件实际内容是否落盘

已尝试的文本层面修复：
- 在 tech-lead skill Completion Checklist 中展开为两行独立条目
- 在 workflow-protocol 中新增 "Progress Update Hook (mandatory, all skills)" 章节
- 在 AI 记忆中记录反馈

**结论：纯文本规则不足以可靠保障。** AI 可以"知道"规则但仍然遗漏执行。需要程序化机制。

## 2. 方案设计

### 2.1 目标

当 AI 在 skill 工作中修改了 workflow 产物（需求、验收、架构、设计、代码等），但没有同步更新 progress.md 和 progress-history.md 时，**自动提醒**（而非自动修改，因为 progress 内容需要语义理解）。

### 2.2 实现机制：Claude Code Hook

利用 Claude Code 的 hooks 功能（settings.json），在特定事件后运行检查脚本。

```jsonc
// .claude/settings.json（项目级）
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": ".claude/hooks/check-progress-update.sh"
      }
    ]
  }
}
```

### 2.3 检查脚本逻辑

`.claude/hooks/check-progress-update.sh`：

```bash
#!/bin/bash
# 检查：如果 workflow 产物被修改但 progress 没有被修改，发出提醒

# 从 workflow-project.yaml 读取路径配置
PROGRESS_FILE="docs/workflow/progress.md"
HISTORY_FILE="docs/workflow/progress-history.md"

# 获取 git 工作区中已修改的文件
MODIFIED=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null)

# 判断是否修改了 workflow 产物（排除 progress 文件本身）
WORKFLOW_CHANGED=false
for f in $MODIFIED; do
  case "$f" in
    docs/releases/*|docs/acceptance/*|docs/architecture/*|docs/requirements/*|src/*)
      WORKFLOW_CHANGED=true
      break
      ;;
  esac
done

if [ "$WORKFLOW_CHANGED" = false ]; then
  exit 0  # 没有修改 workflow 产物，不需要提醒
fi

# 检查 progress 文件是否也被修改了
PROGRESS_UPDATED=false
HISTORY_UPDATED=false
for f in $MODIFIED; do
  [ "$f" = "$PROGRESS_FILE" ] && PROGRESS_UPDATED=true
  [ "$f" = "$HISTORY_FILE" ] && HISTORY_UPDATED=true
done

# 发出提醒
WARNINGS=""
if [ "$PROGRESS_UPDATED" = false ]; then
  WARNINGS="$WARNINGS\n- $PROGRESS_FILE (dashboard) 未更新"
fi
if [ "$HISTORY_UPDATED" = false ]; then
  WARNINGS="$WARNINGS\n- $HISTORY_FILE (history) 未更新"
fi

if [ -n "$WARNINGS" ]; then
  echo "⚠️ Progress Update Hook: workflow 产物已修改，但以下进度文件未同步更新：$WARNINGS"
  echo "请在本轮工作完成前更新这些文件。"
fi
```

### 2.4 Skill 自动安装机制

在 workflow-protocol 的 Startup Checklist 中增加一步：

> 8. If `.claude/hooks/check-progress-update.sh` does not exist, create it and configure the hook in `.claude/settings.json`.

每个 skill 启动时都会读 workflow-protocol，因此第一个被调用的 skill 会自动安装 hook，后续 skill 检测到已存在就跳过。

安装逻辑：
1. 检查 `.claude/hooks/check-progress-update.sh` 是否存在
2. 不存在则创建脚本并 `chmod +x`
3. 检查 `.claude/settings.json` 是否包含对应 hook 配置
4. 不包含则追加配置

### 2.5 需要 skill-writer 生成的文件

| 文件 | 说明 |
|------|------|
| `skills/workflow-protocol/hooks/check-progress-update.sh` | hook 脚本模板 |
| `skills/workflow-protocol/hooks/install-hooks.sh` | 安装脚本（skill 启动时调用） |
| `skills/workflow-protocol/SKILL.md` 更新 | Startup Checklist 增加 hook 安装步骤 |

## 3. 替代方案对比

| 方案 | 可靠性 | 复杂度 | 缺点 |
|------|--------|--------|------|
| A. 纯文本规则（当前） | 低 | 低 | AI 可以"知道"但仍遗漏 |
| **B. PostToolUse hook 提醒（推荐）** | **中高** | **中** | 提醒但不自动修改，需 AI 响应 |
| C. PreCommit hook 阻断 | 高 | 中 | 只在 commit 时触发，修复反馈延迟大 |
| D. 自动修改 progress | 高 | 高 | progress 内容需要语义理解，自动生成质量差 |

推荐方案 B：在不增加过多复杂度的前提下，将"纯靠 AI 记忆"升级为"程序提醒 + AI 执行"。

## 4. 实施步骤

1. **验证 Claude Code hook API**：确认 PostToolUse hook 的 matcher 语法、输出如何反馈到对话上下文
2. **编写 hook 脚本**：基于 §2.3 的逻辑，处理边界情况（git 未初始化、路径配置差异等）
3. **编写安装脚本**：基于 §2.4 的逻辑
4. **修改 workflow-protocol**：Startup Checklist 增加安装步骤
5. **在 persona-agents-platform5 中验证**：安装 hook 后走一轮完整的 skill 工作流，确认提醒生效
6. **文档化**：在 workflow-protocol references 中补充 hook 说明

## 5. 风险

- Claude Code hook API 的 matcher 语法可能与预期不同，需要先验证
- hook 脚本在非 git 仓库中需要 fallback 逻辑
- 频繁的提醒可能产生噪音——需要调优"什么算 workflow 产物修改"的判定范围
