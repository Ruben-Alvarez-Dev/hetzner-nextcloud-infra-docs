# Contributing to Hetzner Nextcloud Infrastructure Documentation

Thank you for your interest in contributing! This document provides guidelines and standards for contributing to this infrastructure documentation project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Documentation Standards](#documentation-standards)
- [Git Commit Guidelines](#git-commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)

---

## 🤝 Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome diverse perspectives
- Focus on constructive feedback
- Maintain academic integrity

---

## 🚀 How to Contribute

### 1. Report Issues

- Use GitHub Issues for bug reports
- Include reproduction steps
- Provide system information
- Add screenshots if relevant

### 2. Suggest Improvements

- Open a discussion first
- Explain the educational value
- Consider security implications
- Provide academic references

### 3. Submit Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Follow commit guidelines
5. Submit a pull request

---

## 📝 Documentation Standards

### Markdown Formatting

```markdown
# Main Title

## Section Title

### Subsection Title

**Bold text** for emphasis
*Italic text* for terms
`code` for commands/filenames
```

### Code Blocks

Use syntax highlighting:

```bash
# Shell commands
sudo systemctl restart service
```

```yaml
# Configuration files
key: value
```

```sql
-- SQL queries
SELECT * FROM users;
```

### File Naming

- Use lowercase with hyphens: `deployment-guide.md`
- Number sequentially: `01-intro.md`, `02-setup.md`
- Be descriptive and concise

### Directory Structure

```
docs/
├── architecture/     # System architecture docs
├── network/          # Network configuration
├── security/         # Security measures
├── deployment/        # Deployment procedures
diagrams/             # Excalidraw diagrams
assets/               # Images and screenshots
reports/              # Analysis reports
```

---

## 🔄 Git Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(diagrams): add network topology diagram` |
| `docs` | Documentation | `docs(security): add authentication guide` |
| `fix` | Bug fix | `fix(config): correct port number` |
| `refactor` | Code refactoring | `refactor(structure): reorganize docs folder` |
| `test` | Adding tests | `test(script): add deployment script test` |
| `chore` | Maintenance | `chore(ci): update GitHub workflow` |

### Scopes

- `architecture` - System architecture
- `network` - Network configuration
- `security` - Security measures
- `deployment` - Deployment procedures
- `diagrams` - Visual documentation
- `reports` - Analysis reports

### Examples

#### Good Commits ✅

```
docs(security): add Authelia configuration guide

Document complete Authelia setup including:
- SSO configuration
- MFA enrollment
- ACL rules
- Session management

Refs: #15
```

```
feat(diagrams): add defense in depth layers diagram

Create Excalidraw visualization showing all security layers
from network perimeter to application level.

Refs: #23
```

#### Bad Commits ❌

```
update docs
```

```
changes
```

```
fixed stuff
```

---

## 🔀 Pull Request Process

### Before Submitting

1. **Test locally**
   - Verify all markdown renders correctly
   - Check all links work
   - Validate code examples

2. **Review guidelines**
   - Follow documentation standards
   - Use conventional commits
   - Add appropriate references

3. **Quality checklist**
   - [ ] Documentation is clear and concise
   - [ ] Code examples are tested
   - [ ] Diagrams are readable
   - [ ] No security secrets exposed
   - [ ] Academic integrity maintained

### PR Template

```markdown
## Description
[Describe your changes]

## Type of Change
- [ ] Documentation
- [ ] Bug fix
- [ ] New feature
- [ ] Security improvement

## Testing
- [ ] Tested locally
- [ ] Verified rendering
- [ ] Checked links

## Academic Value
[Explain educational significance]

## References
- Issue: #XX
- Related: #XX
```

### Review Process

1. Automated checks pass
2. At least one maintainer review
3. No unresolved conflicts
4. All conversations resolved

---

## 📚 Style Guide

### Voice and Tone

- **Voice**: Professional, technical, educational
- **Tone**: Clear, concise, objective
- **Person**: Use "we" for collective actions, "you" for instructions

### Writing Guidelines

#### DO ✅

- Use active voice: "Configure the firewall" not "The firewall should be configured"
- Be specific: "Run `systemctl restart apache2`" not "Restart the service"
- Include context: Explain WHY, not just WHAT
- Use examples: Show code, not just describe it
- Reference sources: Cite documentation and academic sources

#### DON'T ❌

- Use passive voice excessively
- Be vague: "might want to consider"
- Assume prior knowledge
- Include sensitive information
- Plagiarize content

### Technical Writing Tips

1. **Define acronyms** on first use: "Single Sign-On (SSO)"
2. **Use formatting** for readability:
   - Bold for **important terms**
   - Italics for *variables*
   - Code for `commands`
3. **Break down complex topics** into sections
4. **Include diagrams** for visual learners
5. **Add references** for further reading

### Markdown Best Practices

#### Headers

```markdown
# H1 - Main Title (once per document)
## H2 - Major Sections
### H3 - Subsections
#### H4 - Details
```

#### Lists

```markdown
- Unordered item 1
- Unordered item 2
  - Nested item

1. Ordered item 1
2. Ordered item 2
   1. Nested ordered
```

#### Tables

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
```

#### Links and Images

```markdown
[Link text](URL)
![Alt text](image-path.png)
```

---

## 🎓 Academic Integrity

### Citations

When referencing external sources:

```markdown
According to [Author, Year], the security architecture...

[1]: Author, A. (Year). *Title*. Publisher.
```

### Plagiarism

- **DO**: Paraphrase with attribution
- **DO**: Quote with proper citation
- **DON'T**: Copy without attribution
- **DON'T**: Claim others' work as your own

### Academic Value

All contributions should:
1. Demonstrate learning objectives
2. Show practical application
3. Provide educational value
4. Follow best practices

---

## 🔒 Security Considerations

### What NOT to Include

- Passwords or secrets
- API tokens or keys
- Private IP addresses (if sensitive)
- Personal information
- Proprietary configurations

### Redaction Guidelines

```markdown
# Bad ❌
password = "MySecretPassword123"

# Good ✅
password = "YOUR_STRONG_PASSWORD_HERE"
```

---

## 📞 Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Create a GitHub Issue
- **Security**: Email ruben@alvarezconsult.es
- **General**: Review existing documentation first

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 🙏 Recognition

Contributors will be acknowledged in:
- README.md contributors section
- Release notes (if applicable)
- Git history

---

Thank you for contributing to make this infrastructure documentation better for everyone! 🚀

---

**Last Updated**: 2026-03-04  
**Maintainer**: Ruben Alvarez
