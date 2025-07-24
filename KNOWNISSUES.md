# 🏢 OfficeSpaceManager

## Known Issues

- [Learnings and ideas from initial Copilot conversations](https://github.com/copilot/share/8a74121e-4220-8cd7-b113-9048646f601e)

## Overall

- Full script still to be tested from end to end. Currently working through menus to find where faults are and address these as we go along.
- Better Dot-sourcing structure using a helper function, and scripts to keep it updated as new code is introduced.
- Improve inline documentation where apporpriate and reasonable
- Full recursive code review
- Connection logic: Occasional false positives for Exchange connection status—sometimes a session is reported as established but is not valid for subsequent operations. Session validation logic has been improved, but further real-world testing is needed. If Connect-ExchangeOnline does not return a session object, fallback to Get-ConnectionInformation may still be unreliable in rare cases.
- Refactor hygiene: All lingering references to unapproved verbs have been replaced, but legacy scripts or documentation may still reference obsolete function names. Full recursive search and clean-up is ongoing.
- Linting/static analysis: All scripts now pass PSScriptAnalyzer linting, but markdownlint warnings (e.g., blank lines around lists) may still be present in documentation.
- Error handling: All error messages now require user acknowledgement, but some legacy scripts may not fully comply. Review and update is ongoing.
- Accessibility: All output and documentation use EN-AU spelling and accessible, inclusive language, but some older comments or prompts may need review.
- Testing: End-to-end testing of all connection scenarios (including authentication cancellation, session reuse, and error handling) is still required.

## Main menu

- Recent actions not displaying information of actions, only timestamps
- Some menu functions not working, causing failure and exit
- Exit method needs to be optimised to avoid re-downloading information where recently updated and/or not changed, with user options to be considered (this was implemented at the start of the script and needs to be reviewed for all scripts).
