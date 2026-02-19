# Welcome to Claude Code Environment

**Greetings, AI Assistant!**

You are now operating within the **Claude Code** environment - a powerful CLI tool for software development that provides specialized tools and capabilities beyond standard conversation.

---

## 🎯 Your First Step

Before proceeding with any tasks, you **MUST** read the tools documentation:

```
Read the file: /pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.summary.md
```

This documentation is **essential** for effective operation in this environment. It contains navigation links to category-specific summaries.

---

## 📚 What You'll Learn

The tools documentation covers:

1. **File Operations** (Read, Write, Edit, NotebookEdit)
2. **Search & Discovery** (Glob, Grep)
3. **Command Execution** (Bash)
4. **Agent Management** (Task, TaskOutput, TaskStop)
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

- [ ] Use the **Read** tool to open `/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.summary.md`
- [ ] Review the "Quick Reference" table for tool call examples
- [ ] Navigate to category summaries (`docs/claude/tools/*.summary.md`) as needed
- [ ] Review "Important Agent Usage Guidelines" for agent invocation patterns and context management

---

## 📖 Example: Reading the Documentation

Invoke the Read tool like this:

```json
{
  "file_path": "/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.summary.md"
}
```

Navigate to category-specific summaries via the links provided.

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

- **Tool usage questions**: Refer back to `docs/claude/tools.summary.md` and category summaries (`docs/claude/tools/*.summary.md`)
- **Extended details**: Load `docs/claude/tools/*.md` (non-summary) files only when you need comprehensive documentation
- **Project conventions**: Check `CLAUDE.md`
- **User clarification**: Use the **AskUserQuestion** tool
- **Complex exploration**: Use the **Task** tool with `Explore` agent
- **Planning help**: Use **EnterPlanMode** to design implementation approach before coding

---

## 🎬 Ready to Begin

Now that you know what to do:

1. **Read** `/pools/throughput/users/keith/github/ai/NoizuPromptLingo/docs/claude/tools.summary.md`
2. **Understand** the tools available to you
3. **Apply** them to help the user with their tasks
4. **Reference** category summaries (`docs/claude/tools/*.summary.md`) as needed during work
5. **Load** full docs (`docs/claude/tools/*.md`) only for extended details when needed

Welcome aboard, and happy coding! 🚀

---

*This is a custom skill for the NoizuPromptLingo project. Invoke it with `/guest` or the Skill tool.*
