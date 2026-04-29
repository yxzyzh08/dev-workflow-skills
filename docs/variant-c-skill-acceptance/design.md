# Variant C — Skill 项目验收：设计

> 状态：基线 v0.4，**frozen** (2026-04-29 post-Review 01)。
> 修订历史：
> - **v0.4 (2026-04-29)** — Frozen post-Review 01。无内容变更（M1 修复落在 requirements；M2/M3 修复落在 references）。设计本体通过评审。
> - **v0.3 (2026-04-28)** — 任务 #1 一轮迭代（Phase A 骨架 + Phase B fixture 反推 + Phase C 收敛）：State Catalog 加 Invariants + How-to-reach 块（R1）；新增 "Acceptance Preparation 段绑定模板" 节落地 R8/R9；SKILL.md 改动点细化为 5 项含 old/new 对照；references 大纲补"markdown 产出的观察策略"（Phase B 暴露的 markdown body file-field 语义缺口）；R10 决议为"暂不写入主 SKILL.md"。
> - **v0.2 (2026-04-28)** — 对齐 requirements v0.3：references 大纲新增 "LLM 非确定性 recipes" 节（落 D2 决议）；删除"待决"段（D1-D3 已解析，详见 decisions.md D-004）。
> - **v0.1 (2026-04-28)** — 初稿。
>
> 相关：[requirements.md](requirements.md) · [decisions.md](decisions.md) · [fixtures/](fixtures/)

## 总体方案

在 `skills/acceptance-designer/SKILL.md` 内新增 **Variant C：fixture-based / artifact-only**，与现有 Variant A/B 平行。详细定义放进 `skills/acceptance-designer/references/variant-c-skill-projects.md`。不拆分新 skill，不引入仓库级 `workflow-project.yaml`。

## State Catalog Variant C 形态（骨架）

### 段位置与块结构

```markdown
## 3. State Catalog (Variant C: fixture-based / artifact-only)

### 3.0 Suite-level rules
- Workspace isolation: per-case `<output-dir>/<case-id>/`（推荐；解锁未来并行）或共享 `<output-dir>/`（需 run-lock）
- Fixture root: `<fixture-root>`（**只读**，cleanup 不重置——见 R9）
- Output cleanup: 删除 `<output-dir>/<case-id>/` 在 case 开始与 cleanup 时
- Run-lock: 默认不需要；仅当多 case 共享 `<output-dir>` 时使用
- Harness invocation: `<harness-cmd>`（详见 §2.1 Acceptance Preparation）

### S0 — empty workspace
**Invariants:**
- `directory-absent <output-dir>/<case-id>`
- （fixture 是否加载由 case 自定，S0 不约束）

**How to reach:**
- step (actor=ai): `rm -rf <output-dir>/<case-id>`
  expected:
  - `directory-absent <output-dir>/<case-id>`

### S1 — fixture "<scenario-name>" available + empty output
**Invariants:**
- `directory-exists <fixture-root>/<scenario-name>`
- `file-exists <fixture-root>/<scenario-name>/<input-file-1>`
- ...
- `directory-absent <output-dir>/<case-id>`

**How to reach:** [from S0:]
- step (actor=ai): 确认 `<fixture-root>/<scenario-name>/` 已就绪（fixture 预先准备好且只读）；清空 `<output-dir>/<case-id>`
  expected:
  - `file-exists <fixture-root>/<scenario-name>/<input-file-1>`
  - `directory-absent <output-dir>/<case-id>`

### S2, S3, ... — 其他 fixture 集
（每个 fixture 场景一个 S<n>，结构同 S1）
```

### 关键语义

- 状态本质是 **workspace 文件态**，非运行时状态。
- Invariants 仅用 R3 "适用"列里的文件态模式（`file-exists` / `file-absent` / `directory-exists` / `directory-absent` / `file-field` / `file-field-delta`）。
- How to reach 只做文件系统操作（`rm` / `cp` / `ln`），不调用 service。
- S0 ≡ "冷启动空 workspace"。
- fixture 集与产品的"主要验收场景"一一对应；S 数量受场景数量约束。

> **Phase B 暴露的字段粒度问题**：S<n> Invariants 应列到何种粒度？是只列入口文件 `file-exists`，还是同时 `file-field` 校验夹具内容完整？
> **决议**：基础 Invariants = 入口 `file-exists` + workspace 边界 `directory-absent`。`file-field` 内容校验属于 case 级 Pass checklist 关注，不进 Invariants（避免 fixture 内容变动需同步改两处）。

## Acceptance Preparation 段绑定模板（落 R8 / R9）

`output-artifacts.md` §1.2 #2 Acceptance Preparation 在 Variant C 下需绑定以下三组：

```markdown
## 2. Acceptance Preparation

### 2.1 Harness binding（落 R8 第一句）
- Skill under test: `<skill-name>`（例：`acceptance-designer`）
- Invocation harness: `<harness-cmd>`
  - 输入：fixture 集名 + workspace 路径
  - 产出：`<output-dir>/<case-id>/` 下的 markdown 文件
  - 确定性契约：harness 须可重复触发；同一 fixture 应产出**结构同构**的输出（措辞差异由 R5 + LLM recipes 处理）
- 示例（具体形态由项目自选）：
  - `claude-code --skill <skill-name> --input <fixture-root>/<scenario>/ --output <output-dir>/<case-id>/`（若 CLI 支持）
  - 自定义 runner：`./scripts/run-skill.sh <skill-name> <fixture-root>/<scenario> <output-dir>/<case-id>`
  - Anthropic API + Agents SDK 直接调用 skill harness

### 2.2 Fixture root binding（落 R8 第二句 + R9）
- Fixture root: `<fixture-root>`
- 子结构约定：`<fixture-root>/<scenario-name>/<input-files>`
- **R9 约束**：cases 不可修改 fixture；harness 必须以只读模式读取（推荐文件系统 `chmod -w` 或挂载 ro）

### 2.3 Output workspace binding
- Output root: `<output-dir>`
- 隔离粒度：`<output-dir>/<case-id>/`（推荐；与 §3.0 Workspace isolation 一致）
- Cleanup 语义：删除 `<output-dir>/<case-id>/`；`<fixture-root>` 永不触碰
```

> **Phase B 暴露的 harness 实践问题**：`claude-code` 是否支持非交互式 skill 调用、产出落到指定目录？目前不确定。
> **决议**：示例段列三种候选（CLI / 自定义 runner / API），由 #5 meta-acceptance 选定具体形态后回填。本设计不绑死单一实现。

## SKILL.md 改动点（细化）

### 改动 1：Working Loop 第 2 步 — 增加 Variant C 选项

**Old:**
> Pick the **State Catalog variant** based on product capability:
> - Variant A (serial-only, singleton shared state) is the default. Requires a suite-level run-lock.
> - Variant B (workspace-parameterized) only when the product accepts a per-workspace home/flag.

**New:**
> Pick the **State Catalog variant** based on product type and capability:
> - **Variant A** (serial-only, singleton shared state) — default for runtime products with shared global state.
> - **Variant B** (workspace-parameterized) — runtime products that accept a per-workspace home/flag.
> - **Variant C** (fixture-based / artifact-only) — products whose deliverable is a static artifact (skill, document, article); no runtime process. See `references/variant-c-skill-projects.md`.

### 改动 2：Shared structural rules — 加 Variant C 例外条

在现有 "Under Variant A: serial execution + run-lock..." 规则后追加：

> - **Under Variant C**: invariants use only file-state observation modes (`file-exists` / `file-absent` / `directory-exists` / `directory-absent` / `file-field` / `file-field-delta`); runtime modes (`process-running` / `socket-listening` / `log-line`) are not used. Cleanup defaults to clearing the per-case output directory; fixtures are read-only and never reset. Run-lock is optional (required only when cases share the output directory). Acceptance Preparation must bind the invocation harness, fixture root, and output workspace per the template in `references/variant-c-skill-projects.md`.

### 改动 3：AI 案例骨架 — Cleanup 注脚（不单独实施 — 合并进改动 2）

**实现决议（2026-04-29，详见 decisions.md D-005）**：在案例骨架的 ` ```markdown ` 代码块内插入 `*(Under Variant C, ...)*` 注脚会让该注脚成为模板文本的一部分，读者会照抄进自己的 case，污染输出。改为：

- **改动 2 的 "Under Variant C" bullet** 内嵌 `Cleanup defaults to rm -rf <output-dir>/<case-id>` 一句覆盖。
- **`references/variant-c-skill-projects.md` §7 Section Defaults** 给详细推荐模板。

两层声明充分；案例骨架代码块保持原样（与 Variant A/B 一致风格）。

### 改动 4：Support Files — 加 references 引用

在现有 Support Files 列表追加：

> - `references/variant-c-skill-projects.md` — Variant C (fixture-based / artifact-only) authoring rules: when to use, State Catalog template, AI-tier observation patterns for static artifacts, Pass checklist examples, LLM non-determinism recipes, dogfood case.

### 改动 5：First Step / Inputs / Outputs / Completion Checklist

以上四节 R7 范围内**不变**。Variant C 的 case 仍走 §1.2 / §4 / §10 / §11 / §12 主文档结构，无 Variant 特化。

## R10 处理（Section Defaults 兼容）

**决议**：暂不在 SKILL.md 主文本里专门列出 Variant C 的 Section Defaults 默认值。

**理由**：
- §3 Section Defaults 机制对所有 variant 透明；Variant C 用 `Cleanup = clear output dir` 当默认值即可，无需文法变更。
- 在 `references/variant-c-skill-projects.md` 给出推荐 Section Defaults 模板（含 `Cleanup` / `default-actor` / `verifier` 默认建议），便于复用。
- 是否升级为强制约束待 #4 fixture + #5 meta-acceptance 实证（若多 case 都要写相同 Cleanup，则升级）。

**Phase B 反馈**：本次 fixture（`fixtures/expected-output-properties.md`）只产出单一 case 雏形，未触发 Section Defaults 复用需求；R10 维持决议。

## references/variant-c-skill-projects.md 内容大纲

（#2 任务起草时按此大纲落实。）

- **何时用 Variant C**（决策树：交付物是否运行时？是否有可观测进程？）
- **State Catalog 模板**（含 fixture 目录约定，遵循 §2.2 的 `<fixture-root>` 模式）
- **Acceptance Preparation 段绑定要点**（落 R8/R9，复用本文件 §"Acceptance Preparation 段绑定模板"）
- **AI-tier 观察模式在 skill 项目下的典型用法**
  - `exit-code`：跑 `skills/skill-writer/scripts/*` 中已有脚本（含 `check-skill-discovery.py` 作静态可见性观察）。**推荐封装 markdown 结构断言为辅助脚本**（如 `markdown-section-exists.sh` / `markdown-trace-extractor.py`），通过 `exit-code` 观察判定（Phase B 暴露的 markdown body 观察缺口的解决方案）。
  - `file-field`：直接可用于产出文档的 **frontmatter**（YAML key 路径，如 `frontmatter.type`）；对 **markdown body** 的字段提取需先经辅助脚本转 JSON 后再用 `file-field`。
- **Pass checklist 写法范例**
  - ✓ 结构性属性：`产出含 ## 3. State Catalog 段`、`每个 case 含 default-actor 字段`
  - ✗ 文本相等：`产出第 12 行等于 "S1: ..."`
  - ✓ "每个输入需求都被追溯" 推荐 pattern：用 `for-each {req} in [<input-req-ids>] → step: probe → expected: <file-field 或 grep matches>` + Scope 1 "every expected held"，**不**用 Scope 2 `at-least-once`（后者表达不了"每一个"）
- **LLM 非确定性 recipes**（应对 skill 调用产出措辞变化，落 D2 决议）
  - 措辞变化：`file-field <doc> -> body matches /regex/i`
  - "M of N" 软断言：`for-each {kw} in [...]` 配 Scope 2 `count-matching(file-field <doc> -> body matches /{kw}/i) in {kw} ≥ M`
  - 枚举值变化：`file-field <doc> -> <key> ∈ {valid-values}`
  - 反模式（一律禁止）：exact 字符串相等 / 行号定位 / 顺序敏感断言
- **推荐 Section Defaults 模板**（落 R10）：示例化默认 `Cleanup` / `default-actor` / `verifier`
- **完整 dogfood 案例**（详见 `fixtures/`）：用 `acceptance-designer` 自己当被测产物
  - 输入 fixture：`fixtures/sample-frozen-requirements.md`（Toy Counter Service）
  - 期望产出属性：见 `fixtures/expected-output-properties.md`
  - 完整 Variant C case 写法示范（由 #5 落实）

## 进度

- ✅ Phase A — #1 骨架（State Catalog 块、Acceptance Preparation 模板、SKILL.md 5 项改动、R10 决议）
- ✅ Phase B — #4 dogfood fixture 起草（`fixtures/sample-frozen-requirements.md` + `fixtures/expected-output-properties.md`）
- ✅ Phase C — fixture 反推 #1 收敛（markdown body 观察策略 + for-each + Scope 1 pattern + harness 三种候选）
- ✅ Phase D — #1 收口
- ✅ #2 起草 references 文件（`skills/acceptance-designer/references/variant-c-skill-projects.md`，433 行 / 9 章）
- ✅ #3 改 `skills/acceptance-designer/SKILL.md`（4 处增量；改动 3 合并进改动 2，详见 decisions.md D-005）
- ✅ #5 meta-acceptance case 草案完成（`meta-acceptance.md`，paper-complete v0.1；helper scripts + harness 验证 + fixture 重构留作后续，详见文档 §5 / Appendix B）

## 不影响项

- Variant A/B 文档与现有 case 不动
- skill-writer / 其他 skill 不受影响
