# GLOBAL LANGUAGE PROTOCOL

1. Chat Interface (The Conversation):

   * Language: Chinese (Simplified) ONLY.

   * Scope: All reasoning, explanations, questions, plans, and clarifications presented in the chat sidebar.

   * Verbatim Exemption (DO NOT translate these): Commands, code, file/folder names, error traces/stack traces, configuration keys, and literal output snippets must be kept verbatim (typically English). Surrounding explanations must still be Chinese.

2. Project Artifacts (The Deliverables):

   * Language: English ONLY.

   * Scope:

     * All Code (Variable names, Function names).
  
     * All Comments & Docstrings.

     * README.md & Documentation.

     * Figure Labels, Titles, Axes (e.g., in Matplotlib/Seaborn).

     * Terminal Outputs & Log Messages.

3. Exemptions & Precedence (Important):

   * Uncontrollable Output Exemption: External tools and system-native error messages/output may appear in their original language (English or localized). Do NOT wrap exceptions or rewrite output just to translate it.

   * Fail-Fast Precedence: Language rules must NEVER motivate adding `try/except`, swallowing errors, or hiding tracebacks. Prefer preserving the original error and traceback over forcing English output.

4. How to Present Artifacts in Chat (choose per situation):

   * Option A (Allowed): Paste short English artifact snippets in chat (e.g., a README paragraph, comment/docstring, log example). The surrounding explanation remains Chinese.

   * Option B (Preferred by default): Do not paste large English artifacts in chat. Instead, state what changed and point to the updated file(s); the files themselves carry the English content.