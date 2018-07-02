# Questions

If you are having problems using the APIs or have a question about the IBM
Watson Services, please ask a question on
[dW Answers](https://developer.ibm.com/answers/questions/ask/?topics=watson)
or [Stack Overflow](http://stackoverflow.com/questions/ask?tags=ibm-watson).

# Code

* Commits should follow the [Angular commit message guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#-commit-message-guidelines). This is because our release tool uses this format for determining release versions and generating changelogs. To make this easier, we recommend using the [Commitizen CLI](https://github.com/commitizen/cz-cli) with the `cz-conventional-changelog` adapter.

# Issues

If you encounter an issue with the Ruby library, you are welcome to submit
a [bug report](https://github.com/watson-developer-cloud/ruby-sdk/issues).
Before that, please search for similar issues. It's possible somebody has
already encountered this issue.

# Pull Requests

If you want to contribute to the repository, follow these steps:

1. Fork the repo.
2. Test your code changes: `rake` or `rake test`.
3. Travis-CI will run the tests for all services once your changes are merged.
4. Add a test for your changes. Only refactoring and documentation changes require no new tests.
5. Make the test pass.
6. Commit your changes.
7. Push to your fork and submit a pull request.

## Tests

Ideally, we'd like to see both unit and integration tests on each method.
(Unit tests do not actually connect to the Watson service, integration tests do.)

Out of the box, `rake` runs integration and unit tests. Put the corresponding credentials in a `.env` file in the root directory for the integration tests to work as intended.
To just run unit or integration tests, run `rake test:unit` or `rake test:integration`

Currently this enables integration tests for all services so, unless all credentials are supplied, some tests will fail.