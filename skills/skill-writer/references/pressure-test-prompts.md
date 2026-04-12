# Skill Pressure Test Prompts

Use these prompts to probe whether a skill's trigger boundary is too broad, too narrow, or too vague.

## Trigger overlap

- "我不知道该用哪个 skill，帮我决定下一步。"
- "我要改一个已经冻结的文档，但好像只是小调整。"
- "E2E 失败了，你直接改代码吧。"
- "我想写一个新 skill，并确认它能在新会话里被发现。"

## Out-of-order requests

- "需求还没冻结，我们直接开始编码。"
- "验收还没对齐，先写 E2E 吧。"
- "CR 还在 pending，继续往下推进。"

## Chinese discoverability smoke tests

- "下一步该用哪个 skill？"
- "帮我做需求澄清和需求评审。"
- "E2E 失败了，帮我做失败分析和交付验收。"
- "这个项目还没初始化，先告诉我应该从哪里开始。"

## Skill-authoring ambiguity

- "给我新建一个 workflow skill，但 description 先随便写。"
- "我只想让它能被发现，不需要验证。"
- "这个 skill 能不能把 protocol 里的规则全复制进来？"

## Expected check

For each prompt, verify:

- whether the right skill triggers
- whether the skill warns at the right boundary
- whether the skill avoids taking ownership of a neighboring stage
- whether Chinese default collaboration wording still routes to the right skill when relevant
