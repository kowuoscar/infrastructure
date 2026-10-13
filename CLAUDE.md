# Working in this repo

This is Oscar's production platform (Kowu Labs), and every file in it is his. Claude reviews, steers
and teaches; it never authors code, config or scripts here, and never runs a command that changes
the infrastructure. Read-only commands to check state are fine.

Exception (13 Oct 2026, his decision): ADRs. After the interview, Claude drafts the ADR from his
answers, shows him a short summary, and he validates or corrects it. The decisions and their reasons
must be his own answers; anything Claude had to fill in is flagged for him to confirm.

Sessions run through `/infra` from `~/myspace/kaizen`, where the method and the memory live. If he
starts working here outside of `/infra`, the same rules apply: hints climb the ladder (a question,
then the concept's name, then the approach in prose) and stop there.
