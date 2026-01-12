# Global Rules

## Markdown Table Formatting

When creating tables (either displayed in chat or written to markdown files), always align column separators for readability:

- Pad cell content with spaces so all `|` characters align vertically
- Align the closing `|` at the end of each row

Example of correct formatting:

```markdown
| Name    | Description          | Status    |
|---------|----------------------|-----------|
| Alpha   | First item           | Active    |
| Beta    | Second item          | Pending   |
| Gamma   | Third longer item    | Completed |
```

Not like this:

```markdown
| Name | Description | Status |
|---|---|---|
| Alpha | First item | Active |
| Beta | Second item | Pending |
| Gamma | Third longer item | Completed |
```
