#include "manual.h"

#include "string.h"

struct manual_page {
    const char *topic;
    const char *body;
};

static const char *all_commands =
    "help, man, ls, cat, write, open, readfd, writefd, close, fork, execve, run, waitpid, "
    "ping, ps, netstat, mouse status, net send, net inject, net loopback, clear, gui on, gui off, "
    "uname, uptime, fsinfo, state, smpinfo, explain, posix status, perf, demo record, demo replay, "
    "trace start, trace stop, trace list, trace stats, traceview, replay session, meminfo, irqstat, "
    "attack_sim, sysload, lifecycle_test, proc";

static const struct manual_page pages[] = {
    {"help",
     "NAME\n"
     "  help - show the command surface in one line\n\n"
     "USAGE\n"
     "  help\n\n"
     "DESCRIPTION\n"
     "  Prints all commands as a comma-separated list. Use 'man <command>' for a full manual page.\n"},
    {"man",
     "NAME\n"
     "  man - print a built-in manual page\n\n"
     "USAGE\n"
     "  man <topic>\n\n"
     "TOPICS\n"
     "  commands, help, ls, cat, write, open, readfd, writefd, close, fork, execve, run, waitpid,\n"
     "  ping, ps, netstat, mouse, gui, trace, demo, proc, posix, perf\n"},
    {"commands",
     "COMMANDS\n"
     "  help, man, ls, cat, write, open, readfd, writefd, close, fork, execve, run, waitpid,\n"
     "  ping, ps, netstat, mouse status, net send, net inject, net loopback, clear, gui on,\n"
     "  gui off, uname, uptime, fsinfo, state, smpinfo, explain, posix status, perf,\n"
     "  demo record, demo replay, trace start, trace stop, trace list, trace stats, traceview,\n"
     "  replay session, meminfo, irqstat, attack_sim, sysload, lifecycle_test, proc\n"},
    {"ls",
     "NAME\n"
     "  ls - list kernel namespaces and virtual directories\n\n"
     "USAGE\n"
     "  ls\n"
     "  ls /\n"
     "  ls /bin\n"
     "  ls /trace\n"
     "  ls /net\n"
     "  ls /proc\n\n"
     "DESCRIPTION\n"
     "  Lists the root VFS layout or a supported namespace. '/bin' lists file-backed executable paths.\n"
     "  '/trace' lists recorded trace sessions. '/net' lists packet files. '/proc' lists live kernel views.\n"},
    {"cat",
     "NAME\n"
     "  cat - read a VFS path through the syscall layer\n\n"
     "USAGE\n"
     "  cat <path>\n\n"
     "DESCRIPTION\n"
     "  Reads virtual files such as '/proc/tasks', '/proc/aspace', '/net/stats', '/trace/index',\n"
     "  '/bin/ping', and '/bin/ring3demo'. Useful for inspecting the kernel state without leaving the shell.\n"},
    {"write",
     "NAME\n"
     "  write - write text into a writable VFS path\n\n"
     "USAGE\n"
     "  write /net/tx <payload>\n"
     "  write /net/rx/inject <payload>\n"
     "  write /net/config/loopback <0|1>\n\n"
     "DESCRIPTION\n"
     "  Sends packets, injects receive packets, or updates simple network configuration by treating\n"
     "  those interfaces as writable files.\n"},
    {"open",
     "NAME\n"
     "  open, readfd, writefd, close - file descriptor workflow\n\n"
     "USAGE\n"
     "  open <path> <r|w|rw>\n"
     "  readfd <fd>\n"
     "  writefd <fd> <data>\n"
     "  close <fd>\n\n"
     "DESCRIPTION\n"
     "  Demonstrates a POSIX-like descriptor API over the kernel VFS. This is the lowest-level user-visible\n"
     "  file interface in the shell.\n"},
    {"fork",
     "NAME\n"
     "  fork - spawn a child kernel task\n\n"
     "USAGE\n"
     "  fork\n\n"
     "DESCRIPTION\n"
     "  Creates a child task for scheduler and lifecycle testing. Current semantics are kernel-task style,\n"
     "  not full process-memory cloning.\n"},
    {"execve",
     "NAME\n"
     "  execve, run - start a built-in executable path\n\n"
     "USAGE\n"
     "  execve /bin/ping loopback 2\n"
     "  run /bin/ring3demo\n"
     "  run /bin/ps\n"
     "  run /bin/netstat\n\n"
     "DESCRIPTION\n"
     "  '/bin' paths now expose file-backed executable images. The stable user-facing paths are 'run /bin/ping',\n"
     "  'run /bin/ps', 'run /bin/netstat', and 'run /bin/ring3demo'. The deeper spawned-task exec path remains\n"
     "  a prototype ABI surface rather than a full POSIX process loader.\n"},
    {"waitpid",
     "NAME\n"
     "  waitpid - wait for a task to finish\n\n"
     "USAGE\n"
     "  waitpid <pid>\n\n"
     "DESCRIPTION\n"
     "  Waits until the chosen task reaches zombie state or the shell timeout expires.\n"},
    {"ping",
     "NAME\n"
     "  ping - send ICMP-like loopback traffic through /net\n\n"
     "USAGE\n"
     "  ping loopback 1\n"
     "  ping loopback 4\n\n"
     "DESCRIPTION\n"
     "  Uses the stable shell networking path and can also be reached through 'run /bin/ping'. Packets are\n"
     "  emitted as file writes into '/net/tx', looped back, and counted through the network filesystem.\n"},
    {"ps",
     "NAME\n"
     "  ps - print the task table\n\n"
     "USAGE\n"
     "  ps\n\n"
     "DESCRIPTION\n"
     "  Prints PID, parent PID, state, CPU accounting, and command identity for kernel tasks. It is available\n"
     "  directly as a shell command and through 'run /bin/ps'.\n"},
    {"netstat",
     "NAME\n"
     "  netstat - print network counters\n\n"
     "USAGE\n"
     "  netstat\n\n"
     "DESCRIPTION\n"
     "  Prints packet counts, bytes, queue depth, drops, and loopback status from the network filesystem. It is\n"
     "  available directly as a shell command and through 'run /bin/netstat'.\n"},
    {"mouse",
     "NAME\n"
     "  mouse status - inspect the PS/2 mouse integration state\n\n"
     "USAGE\n"
     "  mouse status\n\n"
     "DESCRIPTION\n"
     "  Shows whether a PS/2 mouse was initialized, the current cursor coordinates tracked by packet input,\n"
     "  button mask, and the number of packets seen.\n"},
    {"gui",
     "NAME\n"
     "  gui on, gui off - toggle the VGA dashboard shell frame\n\n"
     "USAGE\n"
     "  gui on\n"
     "  gui off\n\n"
     "DESCRIPTION\n"
     "  'gui on' enables the framed dashboard with live counters. The shell screen now supports scrollback.\n"
     "  Use PageUp and PageDown to scroll, and Home or End to jump to the oldest or newest visible output.\n"},
    {"trace",
     "NAME\n"
     "  trace - control execution trace recording and inspection\n\n"
     "USAGE\n"
     "  trace start\n"
     "  trace stop\n"
     "  trace list\n"
     "  trace stats\n"
     "  traceview <id>\n\n"
     "DESCRIPTION\n"
     "  Starts or stops recording trace events, lists saved sessions, prints trace counters, or shows a\n"
     "  short decoded preview of one recorded session.\n"},
    {"demo",
     "NAME\n"
     "  demo - record or replay built-in workloads\n\n"
     "USAGE\n"
     "  demo record attack\n"
     "  demo record sysload\n"
     "  demo replay <session-id>\n\n"
     "DESCRIPTION\n"
     "  Runs built-in workload profiles to generate repeatable kernel activity and persistent trace sessions.\n"},
    {"proc",
     "NAME\n"
     "  proc, /proc/tasks, /proc/meminfo, /proc/aspace - live kernel process views\n\n"
     "USAGE\n"
     "  proc\n"
     "  cat /proc/tasks\n"
     "  cat /proc/meminfo\n"
     "  cat /proc/aspace\n\n"
     "DESCRIPTION\n"
     "  Shows task state, memory allocator state, and address-space metadata including CR3 roots and user stack tops.\n"},
    {"posix",
     "NAME\n"
     "  posix status - report the current Unix-like surface area\n\n"
     "USAGE\n"
     "  posix status\n\n"
     "DESCRIPTION\n"
     "  Summarizes which parts of a POSIX-like kernel are already present and which parts remain incomplete.\n"},
    {"perf",
     "NAME\n"
     "  perf - print a compact kernel performance matrix\n\n"
     "USAGE\n"
     "  perf\n\n"
     "DESCRIPTION\n"
     "  Shows timer, task, trace, memory, filesystem, and network counters in one line-oriented report.\n"},
};

const char *manual_command_list(void) {
    return all_commands;
}

int manual_print(const char *topic, void (*emit)(const char *text)) {
    if (!topic || !emit) {
        return -1;
    }
    for (unsigned i = 0; i < (sizeof(pages) / sizeof(pages[0])); ++i) {
        if (strcmp(topic, pages[i].topic) == 0) {
            emit(pages[i].body);
            return 0;
        }
    }
    return -1;
}
