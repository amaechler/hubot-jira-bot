class Config
  @maps:
    projects: JSON.parse process.env.HUBOT_JIRA_PROJECTS_MAP
    types: JSON.parse process.env.HUBOT_JIRA_TYPES_MAP
    priorities:
      if process.env.HUBOT_JIRA_PRIORITIES_MAP
        JSON.parse process.env.HUBOT_JIRA_PRIORITIES_MAP
    transitions:
      if process.env.HUBOT_JIRA_TRANSITIONS_MAP
        JSON.parse process.env.HUBOT_JIRA_TRANSITIONS_MAP

  @projects:
    prefixes: (key for team, key of Config.maps.projects).reduce (x,y) -> x + "-|" + y

  @jira:
      url: process.env.HUBOT_JIRA_URL
      username: process.env.HUBOT_JIRA_USERNAME
      password: process.env.HUBOT_JIRA_PASSWORD
      expand: "transitions"
      fields: ["issuetype", "status", "assignee", "reporter", "summary"]
  @jira.urlRegexBase = "#{Config.jira.url}/browse/".replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'
  @jira.urlRegex = eval "/(?:#{Config.jira.urlRegexBase})((?:#{Config.projects.prefixes}-)\\d+)\\s*/i"
  @jira.urlRegexGlobal = eval "/(?:#{Config.jira.urlRegexBase})((?:#{Config.projects.prefixes}-)\\d+)\\s*/gi"

  @github:
    token: process.env.HUBOT_GITHUB_TOKEN

  @slack:
    token: process.env.HUBOT_SLACK_TOKEN

  @ticket:
    regex: eval "/(^|\\s)(" + Config.projects.prefixes + "-)(\\d+)\\b/gi"
    CREATED_TEXT: "Ticket created"

  commands = (command for command, type of Config.maps.types).reduce (x,y) -> x + "|" + y
  @commands:
    regex: eval "/(#{commands}) ([^]+)/i"

  @transitions:
    if Config.maps.transitions
      regex: eval "/(?\:^|\\s)((?\:#{Config.projects.prefixes}-)(?\:\\d+))\\s+(?\:to\\s+|>\\s?)(#{(Config.maps.transitions.map (t) -> t.name).join "|"})/i"
      shouldRegex: eval "/\\s+>\\s?(#{(Config.maps.transitions.map (t) -> t.name).join "|"})/i"

  @priority:
    if Config.maps.priorities
      regex: eval "/\\s+!(#{(Config.maps.priorities.map (priority) -> priority.name).join '|'})\\b/i"

  @quote:
    regex: /`{1,3}([^]*?)`{1,3}/

  @mention:
    regex: eval "/(?:@([\\w._]*))/i"

  @rank:
    regex: eval "/(?\:^|\\s)((?\:#{Config.projects.prefixes}-)(?\:\\d+)) rank (.*)/i"

  @watch:
    regex: eval "/(?\:^|\\s)((?\:#{Config.projects.prefixes}-)(?\:\\d+)) (un)?watch(?: @?([\\w._]*))?/i"

  @assign:
    regex: eval "/(?\:^|\\s)((?\:#{Config.projects.prefixes}-)(?\:\\d+)) (un)?assign @?([\\w._]*)/i"

  @comment:
    regex: eval "/(?\:^|\\s)((?\:#{Config.projects.prefixes}-)(?\:\\d+))\\s?(?\:<\\s?)([^]+)/i"

  @labels:
    regex: /(?:\s+|^)#\S+/g

  @search:
    regex: /(?:j|jira) (?:s|search|find|query) (.+)/

  @help:
    regex:/(?:help jira|jira help)(?: (.*))?/

module.exports = Config