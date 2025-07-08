# 🏢 OfficeSpaceManager
# Known issues

## Overall
- Full script still to be tested from end to end. Currently working through menus to find where faults are and address these as we go along.
- Learnings and ideas from initial Copilot conversations: https://github.com/copilot/share/8a74121e-4220-8cd7-b113-9048646f601e
- - Better Dot-sourcing structure using a helper function, and scripts to keep it updated as new code is introduced.
- Improve inline documentation where apporpriate and reasonable
- Full recursive code review

## Main menu
- Recent actions not displaying information of actions, only timestamps
- Some menu functions not working, causing failure and exit
- Exit method needs to be optimised to avoid re-downloading information where recently updated and/or not changed, with user options to be considered (this was implimented at the start of the script already, but not on exit)