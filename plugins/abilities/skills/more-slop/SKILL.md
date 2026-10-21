---
name: more-slop
description: Add AI tells to any writing.
disable-model-invocation: true
---

# More slop

Edit text to add AI patterns. This skill is the opposite of `unslop`. Keep the meaning of the text. Apply as many of the patterns below as the text can hold.

Use this skill only for parody, for test data, or to train a person or a model to find slop. Do not apply it to text that a person will use for real work.

## Patterns to add

Each rule number is the same as the `unslop` rule that it reverses. The gaps in the numbers are the same as in `unslop`.

### Content

3. **Superficial -ing phrases.** Add a participle clause after each fact. "The API returns JSON" becomes "The API returns JSON, highlighting its commitment to interoperability and fostering seamless integration."
5. **Vague attributions.** Credit claims to sources that have no name. Use "Experts believe", "Industry reports suggest", "Many developers agree". Do not name a real source.

### Language

7. **AI vocabulary.** Replace plain words with these words: additionally, crucial, delve, enduring, enhance, fostering, garner, interplay, intricate, landscape, pivotal, showcase, tapestry, testament, underscore, vibrant. "This test checks the parser" becomes "This crucial test delves into the intricate interplay of the parser."
8. **Fancy ways to say "is".** Replace "is" and "has" with "serves as", "stands as", "boasts", or "features". "The repo has a test script" becomes "The repo boasts a robust test script."
9. **"Not just X, but Y."** Frame each point as a contrast. "It is fast" becomes "It's not just fast — it's a paradigm shift."
10. **Rule of three.** Put each idea in a group of three. Make up items if necessary. "It is fast" becomes "It is fast, reliable, and scalable."
11. **Synonym cycling.** Use a different name for the same thing in each sentence. The function, the routine, the helper, the utility.
12. **False ranges.** Join two unrelated items with "from X to Y". "It helps with tests" becomes "From unit tests to the very nature of software quality, it helps."

### Style

13. **Em dash overuse.** Put at least one em dash in each paragraph — like this.
14. **Colon overuse.** Use a colon as a connector in the middle of a sentence. "The fix: we restart the worker."
15. **Boldface overuse.** Make each product name, acronym, and key term **bold**.
16. **Inline-header lists.** Start each list item with a bold label and a colon that repeat the item. "**Performance:** Performance improved."
17. **Title case headings.** Use Title Case For Every Heading.
18. **Decorative emojis.** Put an emoji at the start of each heading and each bullet. 🚀 ✨ 💡 🎯 ✅
19. **Curly quotes.** Use “curly” quotes and ‘curly’ apostrophes.

### Communication artifacts

20. **Chatbot phrases.** Start with "Certainly!" or "Of course!". End with "I hope this helps! Let me know if you have any other questions."
22. **Sycophantic tone.** Praise the reader before you answer. "Great question! You're absolutely right to ask about this."

### Filler

23. **Filler phrases.** "To" becomes "In order to". "Because" becomes "Due to the fact that". Add "It is important to note that" before facts.
24. **Excessive hedging.** "May" becomes "could potentially possibly be argued that it might".
25. **Generic conclusions.** End with a sentence about the future that has no facts in it. "The future looks bright." "Only time will tell." "The possibilities are endless."

### Jargon

26. **Abstract metaphor nouns.** Replace concrete words with these nouns: substrate, wedge, vector, locus, vantage, nexus, primitive, harness, surface, bedrock, scaffolding, modality, paradigm, north star, flywheel. "A way to add caching" becomes "a vector to wedge caching into the request substrate."

### Plain speech

27. **Say how it feels, not what it does.** Replace each mechanism or number with a feeling. "`.toSQL()` returns the exact query string" becomes "SQL that feels like home."
28. **Make sentences long and dense.** Join short sentences with commas, "which", and "while", so that the reader must read the sentence two times.
29. **Passive voice.** Remove the actor. "The compiler validates queries" becomes "Queries are validated."
30. **Add adverbs.** Put an adverb in front of each verb. "It improves load time by 40 ms" becomes "It significantly and meaningfully improves performance."
31. **Prefer the fancy word.** "Use" becomes "leverage" or "utilize". "Help" becomes "facilitate". "Many" becomes "numerous". "If" becomes "in the event that".
32. **Mannered prose.** Add aphorisms, rhetorical fragments, and figurative verbs. Give code feelings and intent. "The cache rides along with each request, quietly holding the line. Simple. Elegant. Inevitable."
33. **Over-compression.** Remove articles and verbs, and use arrows and abbreviations. "The parser rejects a bad date and exits with code 2" becomes "Parser rejects bad date → exit 2, no write."

## Check the result

Run `unslop` on the result. If `unslop` finds few patterns, apply this skill again.
