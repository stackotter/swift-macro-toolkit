# Contributing

## Environment setup

- Fork and clone SwiftMacroToolkit
- Open the package in your editor of choice and you're ready to code, have fun!

## Contribution workflow

- Look through the issues on GitHub and choose an issue to work on (or open one if you have an idea)
- Leave a comment on the issue to let people know that you're working on it
- Make necessary changes to the codebase
- Open a PR, making sure to reference the issue that your changes address
- If a maintainer requests changes, implement the changes
- A maintainer will merge the changes and the issue can be closed

Thank you for improving SwiftMacroToolkit!

## Before opening a PR

- [ ] Document any new code and update existing documentation as necessary
- [ ] Ensure that you haven't introduced any new warnings
- [ ] Check that `swift build` and `swift test` both succeed

Feel free to open a draft PR before you've completed the checklist if you want feedback.

## Package structure

- `Sources/MacroToolkit`: The toolkit itself
- `Sources/MacroToolkitExample`: Declarations of some example macros which are tested by the tests
- `Sources/MacroToolkitExamplePlugin`: Implementations for the macros declared by `MacroToolkitExample`
- `Tests/MacroToolkitTests`: The tests for the toolkit. They simply test that the example macros are
  working correctly, acting as integration tests for the toolkit. Ideally these will eventually be
  complimented by more specific unit tests.

## Codestyle

- 4 space tabs
- Add comments to any code you think would need explaining to other contributors.
- Document all methods, properties, classes, structs, protocols and enums with documentation comments (if it's trivial,
  you can just keep the documentation comment short). In Xcode you can press option+cmd+/ when your cursor is on a
  declaration to autogenerate a template documentation comment (it mostly works).
- Avoid using shorthand when the alternative is more readable at a glance.
