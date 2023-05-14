# README: Virtual Git Tool for LLMs - Focused on Extracting Information Efficiently

## Introduction

The virtual git tool, `gpt-git`, is designed to address the context limitations of Language Learning Models (LLMs) like GPT-3. It provides a simulated git interface that allows users to collaborate with LLMs effectively, focusing on extracting relevant information without requiring the model to output large amounts of text for small updates.

## Why Use a Virtual Git with LLMs?

LLMs often face context limitations, making it challenging to display large amounts of information on the screen. The virtual git tool, `gpt-git`, is specifically designed to overcome this issue by:

1. **Efficiently managing repositories**: `gpt-git` enables you to switch between repositories and list them with simple commands, letting the LLM concentrate on retrieving the most relevant information.

2. **Retrieving file chunks**: Instead of displaying an entire file, `gpt-git` retrieves specific chunks of a file, allowing you to control the amount of data displayed and ensuring that the output remains within the LLM's context limitations.
- Human Note: You may edit and reprompt continuously to fetch a larger file than you could easily retrieve otherwise. the models are fairly good at not switching the contents of the file mid stream despite fetching
- it out of sequence in reprompts.

3. **Generating terminal diffs**: `gpt-git` can generate diffs in a terminal-friendly format, making it easy to compare changes between versions without requiring the LLM to output excessive amounts of text.

4. **Extending behavior**: The virtual git tool can be extended with additional features to further enhance its ability to extract information efficiently when working with LLMs.

## Commands and Usage

Here's a summary of the `gpt-git` commands:

- **Switch repos**: Change the active repository with `@gpt-git repo #{repo-name}`.
- **List repos**: Display a list of available repositories using `@gpt-git repos`.
- **Retrieve file chunks**: View specific portions of a file with `@gpt-git view #{file_path} --start_byte=#{start_byte} --end_byte=#{end_byte} --encoding=#{encoding}`.
- **Generate terminal diffs**: Create diffs with `@gpt-git diff #{file_path} --output_format=terminal`.

`gpt-git` also supports Linux-like CLI commands with the `!` symbol, such as `! tree` and `! locate *.md`.

The supported encodings are utf-8 (default), base64, and hex. Use `--start_byte` and `--end_byte` for binary files.

Example command for viewing a portion of an image file:

```
@gpt-git view image.jpg --start_byte=0 --end_byte=4096 --encoding=hex
```

To extend the behavior of `gpt-git`, use the `@gpt-git extend` command followed by the desired feature.

## Conclusion

The `gpt-git` virtual git tool offers a convenient and efficient way to work with LLMs by allowing users to extract relevant information without overwhelming the model with large amounts of text. By providing a simulated git interface that focuses on repository management, file chunk retrieval, and terminal diffs, it ensures effective collaboration with LLMs while respecting their context limitations.
