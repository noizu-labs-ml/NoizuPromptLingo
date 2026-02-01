# Welcome to Claude Code Environment

**Greetings, AI Assistant!**

You are now operating within the **Claude Code** environment - a powerful CLI tool for software development that provides specialized tools and capabilities beyond standard conversation.

---

## 🎯 Your First Step

Before proceeding with any tasks, you **MUST** read the comprehensive tools documentation:

```
Read the file: /pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.md
```

This documentation is **essential** for effective operation in this environment.

---

## 📚 What You'll Learn

The tools documentation covers:

1. **File Operations** (Read, Write, Edit)
2. **Search & Discovery** (Glob, Grep)
3. **Command Execution** (Bash)
4. **Agent Management** (Task)
5. **Planning & Workflow** (EnterPlanMode, ExitPlanMode)
6. **Task Tracking** (TaskCreate, TaskUpdate, TaskList, TaskGet)
7. **User Interaction** (AskUserQuestion, Skill)
8. **Web Operations** (WebFetch, WebSearch)
9. **Best Practices & Common Patterns**
10. **Error Recovery & Performance Tips**

---

## ⚠️ Critical Differences from Standard Chat

Unlike typical conversational AI, in Claude Code you must:

- **Use specialized tools** instead of describing what you would do
- **Use Read/Write/Edit** for files, NOT bash commands like `cat` or `sed`
- **Use Glob/Grep** for searching, NOT `find` or `grep` commands
- **Use absolute paths** for all file operations
- **Execute in parallel** when operations are independent
- **Read before editing** - always examine files before modifying them

---

## 🚀 Quick Start Checklist

- [ ] Use the **Read** tool to open `/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.md`
- [ ] Review the tool categories and their purposes
- [ ] Study the "Best Practices" section
- [ ] Review "Common Patterns" for proven workflows
- [ ] Reference "Quick Reference" table as needed during work

---

## 📖 Example: Reading the Documentation

Invoke the Read tool like this:

```json
{
  "file_path": "/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.md"
}
```

Or if you need to read in sections (the file is ~1,154 lines):

```json
{
  "file_path": "/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.md",
  "offset": 0,
  "limit": 200
}
```

---

## 🎓 After Reading the Documentation

Once you've familiarized yourself with the tools:

1. **Understand the environment**: Check `CLAUDE.md` for project-specific guidance
2. **Know the project**: Review `README.md` for project overview
3. **Learn the structure**: Check `docs/PROJ-LAYOUT.md` for directory layout
4. **Understand architecture**: Review `docs/PROJ-ARCH.md` for system design

---

## 💡 Key Principles

1. **Tools over description**: Use tools to accomplish tasks, don't just describe them
2. **Specialized over general**: Use Read instead of `cat`, Glob instead of `find`
3. **Parallel execution**: Make independent tool calls together in one message
4. **Plan complex work**: Use EnterPlanMode for non-trivial implementations
5. **Track progress**: Use TaskCreate/TaskUpdate for multi-step work

---

## 🆘 When You Need Help

- **Tool usage questions**: Refer back to `docs/claude/tools.md`
- **Project conventions**: Check `CLAUDE.md`
- **User clarification**: Use the **AskUserQuestion** tool
- **Complex exploration**: Use the **Task** tool with `Explore` agent
- **Planning help**: Use **EnterPlanMode** to design approach

---

## 🎬 Ready to Begin

Now that you know what to do:

1. **Read** `/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.md` in full
2. **Understand** the tools available to you
3. **Apply** them to help the user with their tasks
4. **Reference** the documentation whenever needed

Welcome aboard, and happy coding! 🚀

---

*This is a custom skill for the NoizuPromptLingo project. Invoke it with `/guest` or the Skill tool.*
