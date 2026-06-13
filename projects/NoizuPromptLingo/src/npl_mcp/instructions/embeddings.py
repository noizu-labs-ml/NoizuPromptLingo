"""Instruction embedding pipeline -- extract descriptive phrases, embed, store.

On create/update, an LLM extracts 3-5 descriptive phrases about the
instruction, an embedding model converts them to vectors, and the
(label, embedding) pairs are stored in ``npl_instruction_embeddings``
for future cosine-similarity search.

Failures are logged but never raised -- embedding is best-effort
so that instruction writes are never blocked.
"""

import json
import logging
import uuid as _uuid_mod

from npl_mcp.meta_tools.llm_client import chat_completion, embed_texts
from npl_mcp.storage import get_pool

logger = logging.getLogger(__name__)

_EXTRACT_SYSTEM_PROMPT = """\
You are a metadata extraction assistant. Given an instruction document with its \
title, description, tags, and body, generate 3-5 short descriptive phrases that \
capture the different facets of what this instruction is about, what it enables, \
and when someone would want to find it.

Return ONLY a valid JSON array of strings, e.g.:
["phrase one", "phrase two", "phrase three"]

Rules:
- Each phrase should be 5-15 words
- Cover different angles: purpose, use case, domain, capability
- Do not repeat the title verbatim; paraphrase or expand on it
- Include at least one phrase about when/why someone would search for this\
"""


async def extract_descriptive_phrases(
    title: str,
    description: str,
    tags: list[str],
    body: str,
) -> list[str]:
    """Use LLM to extract 3-5 descriptive phrases from instruction content.

    Args:
        title: Instruction title.
        description: Instruction description.
        tags: Instruction tags.
        body: Instruction body (truncated to 2000 chars internally).

    Returns:
        List of 3-5 descriptive phrase strings.

    Raises:
        Exception: On LLM or parsing failure.
    """
    user_content = (
        f"Title: {title}\n"
        f"Description: {description}\n"
        f"Tags: {', '.join(tags) if tags else '(none)'}\n"
        f"Body:\n{body[:2000]}"
    )

    messages = [
        {"role": "system", "content": _EXTRACT_SYSTEM_PROMPT},
        {"role": "user", "content": user_content},
    ]

    response = await chat_completion(messages, temperature=0.3, max_tokens=500)
    content = response["choices"][0]["message"]["content"].strip()

    # Strip markdown fences if present
    if content.startswith("```"):
        content = content.split("\n", 1)[1] if "\n" in content else content[3:]
    if content.endswith("```"):
        content = content[:-3]
    content = content.strip()

    phrases = json.loads(content)
    if not isinstance(phrases, list):
        raise ValueError(f"Expected JSON array, got {type(phrases).__name__}")
    return [str(p) for p in phrases[:5]]


async def generate_and_store_embeddings(
    instruction_id: _uuid_mod.UUID,
    title: str,
    description: str,
    tags: list[str],
    body: str,
) -> None:
    """Full pipeline: extract phrases, embed them, store in DB.

    Failures are logged but not raised -- embedding is best-effort.

    Args:
        instruction_id: UUID of the instruction to embed.
        title: Instruction title.
        description: Instruction description.
        tags: Instruction tags.
        body: Instruction body content.
    """
    try:
        # Step 1: Extract descriptive phrases via LLM
        phrases = await extract_descriptive_phrases(title, description, tags, body)

        if not phrases:
            logger.warning("No phrases extracted for instruction %s", instruction_id)
            return

        # Step 2: Embed all phrases in a single batch call
        vectors = await embed_texts(phrases)

        # Step 3: Store in DB
        pool = await get_pool()
        async with pool.acquire() as conn:
            async with conn.transaction():
                # Delete existing embeddings for this instruction
                await conn.execute(
                    "DELETE FROM npl_instruction_embeddings WHERE instruction_id = $1",
                    instruction_id,
                )

                # Insert new embeddings
                for label, vector in zip(phrases, vectors):
                    await conn.execute(
                        """INSERT INTO npl_instruction_embeddings
                               (instruction_id, label, embedding, created_at)
                           VALUES ($1, $2, $3::vector, NOW())""",
                        instruction_id,
                        label,
                        str(vector),
                    )

    except Exception:
        logger.exception(
            "Failed to generate embeddings for instruction %s", instruction_id
        )
