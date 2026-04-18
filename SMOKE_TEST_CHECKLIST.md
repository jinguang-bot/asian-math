# 💨 Smoke Test Checklist (冒烟测试清单)

> **目标**: 本清单用于 Agent 在开发一个 Feature 的“启动时”和“交付前”验证项目处于健康的 Clean State。
> **要求**: 在任何一个 Coding Agent 进行实现 (Step 3) 之前，必须执行自动化检查。若失败，必须先修复或停止。

## 1. 自动化环境检查
- [ ] 运行自动化占位脚本验证脚手架正常:
  ```bash
  npm run test:smoke
  ```

## 2. 运行时手动/自动化检查 (待项目有前端/后端代码后适用)

当真实服务被建立后（比如 Mock Server 跑起来，前端 Vite 跑起来），Coding Agent 应补充执行以下验证：

- [ ] **服务启动**:
  - `npm run dev` (前端能够成功启动无报错)
  - `npm run mock` (Mock Server 能够成功挂载 OpenAPI 契约)
- [ ] **核心页面可达性**:
  - `curl -s http://localhost:PORT/` 能够获取到主页 HTML / JSON
  - `curl -s http://localhost:PORT/login` 能够获取到登录页 HTML
- [ ] **接口健康检查**:
  - `curl -s http://localhost:PORT/api/v1/health` 能够返回 `200 OK`

## 3. 日志记录
- [ ] 在 `PROGRESS.md` 的当次会话记录中，必须显式声明：“Smoke Test 执行通过”。