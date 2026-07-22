---
name: tailnet-fleet
description: Reference for the machines on the user's Tailscale tailnet that agents can reach over passwordless SSH (fedora, happy, chubbs, cachy). Use when deciding which machine to run or offload a task to, when a task needs more CPU/RAM/GPU than the current machine, when connecting to or running commands on a named machine, or when orchestrating work across the fleet.
---

# Tailnet Fleet

The machines the user owns on their Tailscale tailnet (`tail7e37b4.ts.net`). All are reachable over **passwordless key-based SSH** as user `efox`. Use this skill to pick the right machine for a task and to connect to it.

## Connecting

MagicDNS resolves the bare short names — no config, no password, no key path needed.

```bash
ssh happy                      # interactive shell
ssh happy 'nproc; free -h'     # run a command remotely
rsync -avz ./out/ chubbs:~/in/ # copy files
scp file.tar happy:~/          # copy a file
```

Check `hostname` to know which machine you're already on. **fedora is usually the machine you are running on** — "local" work happens there; offload elsewhere via `ssh`.

Not every machine is always up. Verify liveness before offloading:

```bash
tailscale status | grep -E 'happy|chubbs|cachy|fedora'   # online/offline at a glance
ssh -o BatchMode=yes -o ConnectTimeout=6 cachy true && echo up || echo down
```

## The fleet

| Machine    | Role                          | CPU                          | RAM   | Storage      | GPU            | OS                     | Availability |
| ---------- | ----------------------------- | ---------------------------- | ----- | ------------ | -------------- | ---------------------- | ------------ |
| **fedora** | Orchestrator / user's laptop  | Ryzen AI 5 340               | 64 GB | 2 TB         | —              | Fedora 44 Workstation  | Intermittent — laptop, opened/closed unpredictably |
| **happy**  | Heavy-CPU beast / main dev    | Ryzen 9 7945HX (16c/32t)     | 64 GB | 2 TB         | —              | Debian 13 (trixie)     | Generally up; offers exit node |
| **chubbs** | Fedora server / spare node    | Intel i9-12900H (14c/20t)    | 32 GB | 1 TB         | —              | Fedora 44 Server       | Generally up |
| **cachy**  | Gaming + desktop, some dev    | Ryzen 5 5500                 | 32 GB | ~2.5 TB free¹ | NVIDIA RTX 3060 | CachyOS (Windows dual boot) | Usually asleep/offline |

¹ 3 TB physical, ~2.5 TB usable — the Windows partition takes the rest.

## Picking a machine

- **Heavy CPU, long builds, parallel jobs, main dev work, anything you don't want draining the laptop battery → `happy`.** Most cores, most RAM, generally up. This is the default workhorse for offloaded compute.
- **GPU / CUDA / ML inference or training / anything needing a discrete NVIDIA GPU → `cachy`.** It's the only machine with a dGPU (RTX 3060). But it's usually asleep — **confirm it's reachable first**, and it may need to be woken (ask the user, or wake-on-LAN if configured). Also the machine to use for GPU-accelerated gaming/desktop tasks.
- **A second machine for multi-node / distributed tasks, or a persistent always-on server → `chubbs`.** Headless Fedora server; the natural pick when a task needs two coordinating machines or a long-lived background service.
- **Orchestration, and where the user actually sits → `fedora`.** This is typically the machine you're on. It's a laptop and comes and goes — don't leave critical long-running work here expecting it to stay up if the user closes the lid or steps away. Kick heavy or long jobs out to `happy`/`chubbs`.

## Notes

- SSH login is passwordless (key-based). Remote `sudo` may still prompt — don't assume rootless privilege escalation.
- Prefer offloading long/heavy work off `fedora` (laptop, intermittent) and off `cachy` (usually asleep) — `happy` and `chubbs` are the dependable always-on targets.
- Always verify a target is online before assigning it work; `fedora` and `cachy` are the flaky ones.
- Other devices on the tailnet (e.g. `shooter`, `minix`, phones, an iPad) are **not** part of this compute fleet — don't offload work to them unless the user explicitly asks.
