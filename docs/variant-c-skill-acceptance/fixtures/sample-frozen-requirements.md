---
title: Sample Frozen Requirements — Toy Counter Service
type: requirements
status: frozen
version: "1.0"
release: r1
created: 2026-04-28 10:00
last_modified: 2026-04-28 10:00
author: human
change_history:
  - { date: 2026-04-28, author: human, description: initial freeze for Variant C dogfood }
---

# Toy Counter Service — Frozen Requirements (r1)

> 用途：作为 `acceptance-designer` 在 Variant C 验收下的输入夹具。被测产物：`acceptance-designer` 自身。
> "被验收的产品"是一个虚构的 Toy Counter Service；acceptance-designer 应能基于它产出一份合规的 acceptance 文档。
>
> 选择 toy 服务的理由：服务有真实运行时状态（计数器值、持久化），acceptance-designer 应产出 Variant A 风格的 acceptance；这样 dogfood 同时考验"Variant C 能验证一个产 Variant A 的 skill"——递归层级清晰。

## 1. 产品概述

Toy Counter Service 是最小化 HTTP 服务，向客户端暴露一个递增计数器。

## 2. 主要需求

### R1 Counter increment

服务暴露 `POST /counter/inc` 端点。每次成功调用后：
- 内部计数器值加 1
- 响应体为 `{"value": <int>}`，HTTP 200

### R2 Counter read

服务暴露 `GET /counter` 端点。响应体为 `{"value": <int>}`，HTTP 200。任何时刻读到的值 = R1 端点累计被成功调用的次数（除 R3 重启情况外）。

### R3 Counter persistence

服务重启后，计数器值不丢失。重启前最后一次 R1 调用累计的值 = 重启后第一次 `GET /counter` 读到的值。

## 3. 主要场景

### 主流程 M1

1. 启动服务 → counter = 0
2. 三次调用 `POST /counter/inc` → counter = 3
3. 调用 `GET /counter` → 响应 `{"value": 3}`
4. 重启服务
5. 再次 `GET /counter` → 响应 `{"value": 3}`

## 4. 验收范围

- R1, R2, R3 均为 r1 主流程
- 无 CR，无 branched 需求
- 不在范围：性能、并发、错误处理、认证（保留至 r2+）

## 5. 假定

- 服务以单实例运行（无分布式 / replication 考虑）
- 持久化机制由实现决定（文件 / 内嵌 DB 均可）；本需求不约束机制
- 服务监听端口 / 配置读取方式由实现决定
