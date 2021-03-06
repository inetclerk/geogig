@Commands
Feature: Log
  The log command allows a user to view the commit log of a repo and is supported through the "/repos/{repository}/log" endpoint
  The command must be executed using the HTTP GET method

  Scenario: Verify wrong HTTP method issues 405 "Method not allowed"
    Given There is an empty repository named repo1
     When I call "PUT /repos/repo1/log"
     Then the response status should be '405'
      And the response allowed methods should be "GET"
    
  Scenario: Log outside of a repository issues 404 "Not found"
    Given There is an empty multirepo server
     When I call "GET /repos/repo1/log"
     Then the response status should be '404'
      And the response ContentType should be "text/plain"
      And the response body should contain "Repository not found"
      
  Scenario: Log will return the history of the current branch
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 5 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch2 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~1}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch1 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~2}"
      And there is an xpath "/response/commit/message/text()" that contains "point1, line1, poly1"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|branch1}"
      And there is an xpath "/response/commit/message/text()" that contains "point2, line2, poly2"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|branch2}"
      And there is an xpath "/response/commit/message/text()" that contains "point3, line3, poly3"
      
  Scenario: The firstParentOnly parameter limits the log to the first parent of each commit
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?firstParentOnly=true"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 3 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch2 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~1}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch1 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~2}"
      And there is an xpath "/response/commit/message/text()" that contains "point1, line1, poly1"
      
  Scenario: The offset parameter skips a number of log entries
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?offset=2"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 3 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~2}"
      And there is an xpath "/response/commit/message/text()" that contains "point1, line1, poly1"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|branch1}"
      And there is an xpath "/response/commit/message/text()" that contains "point2, line2, poly2"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|branch2}"
      And there is an xpath "/response/commit/message/text()" that contains "point3, line3, poly3"
      
  Scenario: The limit parameter limits the number of entries returned
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?limit=2"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 2 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch2 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~1}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch1 onto master"
      
  Scenario: The since parameter limits the log to commits that happened after it
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?since=master~1"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 1 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch2 onto master"
      
  Scenario: The until parameter limits the log to commits that happened before it
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?until=master~1"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 3 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~1}"
      And there is an xpath "/response/commit/message/text()" that contains "merge branch branch1 onto master"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~2}"
      And there is an xpath "/response/commit/message/text()" that contains "point1, line1, poly1"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|branch1}"
      And there is an xpath "/response/commit/message/text()" that contains "point2, line2, poly2"
      
  Scenario: The countChanges parameter counts the number of features affected by each commit
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?since=master~1&countChanges=true"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 1 times
      And the xpath "/response/commit/id/text()" equals "{@ObjectId|repo1|master}"
      And the xpath "/response/commit/message/text()" contains "merge branch branch2 onto master"
      And the xpath "/response/commit/adds/text()" equals "3"
      And the xpath "/response/commit/modifies/text()" equals "0"
      And the xpath "/response/commit/removes/text()" equals "0"
      
  Scenario: The returnRange parameter returns the first and last commit as well as the number of commits in the range
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?returnRange=true"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xpath "/response/untilCommit/id/text()" equals "{@ObjectId|repo1|master}"
      And the xpath "/response/untilCommit/message/text()" contains "merge branch branch2 onto master"
      And the xpath "/response/sinceCommit/id/text()" equals "{@ObjectId|repo1|master~2}"
      And the xpath "/response/sinceCommit/message/text()" contains "point1, line1, poly1"
      And the xpath "/response/numCommits/text()" equals "5"
      
  Scenario: The path parameter limits the log to commits that affected that path
    Given There is an empty repository named repo1
      And I have committed "Point.1" on the "repo1" repo in the "" transaction
      And I have committed "Line.2" on the "repo1" repo in the "" transaction
      And I have committed "Point.2" on the "repo1" repo in the "" transaction
      And I have committed "Polygon.1" on the "repo1" repo in the "" transaction
      And I have committed "Polygon.2" on the "repo1" repo in the "" transaction
     When I call "GET /repos/repo1/log?path=Points"
     Then the response status should be '200'
      And the xpath "/response/success/text()" equals "true"
      And the xml response should contain "/response/commit" 2 times
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~2}"
      And there is an xpath "/response/commit/message/text()" that contains "Added Point.2"
      And there is an xpath "/response/commit/id/text()" that equals "{@ObjectId|repo1|master~4}"
      And there is an xpath "/response/commit/message/text()" that contains "Added Point.1"
      
  Scenario: Using the summary parameter without a path issues a 500 status code
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?summary=true"
     Then the response status should be '500'
      And the xpath "/response/error/text()" equals "You must specify a feature type path when getting a summary."
      
  Scenario: Using the summary parameter without using text/csv content type issues a 500 status code
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log?path=Points&summary=true"
     Then the response status should be '500'
      And the xpath "/response/error/text()" equals "Unsupported Media Type: This response is only compatible with text/csv."
      
  Scenario: The summary parameter summarizes all of the changes to a feature type as a CSV
    Given There is a default multirepo server
     When I call "GET /repos/repo1/log.csv?since=master~1&path=Points&summary=true"
     Then the response status should be '200'
      And the response ContentType should be "text/csv"
      And the response body should contain "ADDED,Points/Point.3"
      And the response body should contain "{@ObjectId|repo1|master}"
      And the response body should not contain "ADDED,Points/Point.2"
      And the response body should not contain "ADDED,Points/Point.1"
      And the response body should not contain "Lines"
      And the response body should not contain "Polygons"