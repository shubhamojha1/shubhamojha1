# Shubham Ojha

Backend engineer working on **LLM inference and systems infrastructure**. Currently on Java 21 / Spring Boot / Kubernetes by day; writing inference engines, brokers, and an OS by night.

Mumbai, India · [shubham-ojha.com](https://shubham-ojha.com) · [whatwhyhow.substack.com](https://whatwhyhow.substack.com) · [@claudeabuser](https://x.com/claudeabuser)

---

### What I'm building

**[Helios](https://github.com/shubhamojha1/helios)** — LLM inference engine in PyTorch. Paged KV-cache, continuous batching, benchmarked on a single RTX 4070. Built to understand what vLLM actually does under the hood.

**[Serving Sommelier](https://github.com/shubhamojha1/serving-sommelier)** — Empirical autotuner for LLM serving. Searches batch size, KV block size, quantization, and speculative decoding against vLLM and returns a Pareto frontier of latency/throughput/cost — measured, not guessed.

**[Mnemosyne](https://github.com/shubhamojha1/mnemosyne)** — Shared memory and coordinated task execution across coding agents (Claude Code, Codex). MCP memory server + thin routing CLI + session audit trail. Plugin-based, agent-agnostic.

**[Chronos](https://github.com/shubhamojha1/chronos)** — An OS from scratch in Rust and x86 assembly. Zero C. Boots in QEMU, headed for bare metal.

### Systems I've written to learn how they work

| Project | What it is |
|---|---|
| [simplemq](https://github.com/shubhamojha1/simplemq) | Kafka-style message broker in Go — segmented logs, consumer groups, ~50K msg/sec |
| [heimdall](https://github.com/shubhamojha1/heimdall) | L4/L7 load balancer in Go — health checks, connection pooling, multiple balancing strategies |
| [bifrost](https://github.com/shubhamojha1/bifrost) | Hash-join execution engine in C++ — partitioned build/probe, spill-to-disk |
| [sqlite-clone](https://github.com/shubhamojha1/sqlite-clone) | SQLite reimplemented in C — B-tree pager, VM, SQL front end |

### Writing

[**whatwhyhow**](https://whatwhyhow.substack.com) — long-form posts on LLM internals and the agentic dev stack, with working code.

[**systemsfailed.dev**](https://systemsfailed.dev) — an archive of distributed systems postmortems. Git as the database, one markdown file per incident.

### Stack

`Go` `Rust` `C/C++` `Python` `Java` · `PyTorch` `CUDA` `vLLM` · `Kubernetes` `Istio` `Docker` `AWS`

---

📫 [contact.shubhamojha@gmail.com](mailto:contact.shubhamojha@gmail.com) · open to conversations about anything in cs/real-world systems.
